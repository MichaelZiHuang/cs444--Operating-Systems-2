// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
    const char *name;
    const char *desc;
    // return -1 to force monitor to exit
    int (*func)(int argc, char** argv, struct Trapframe* tf);
};

// LAB 1: add your command to here...
static struct Command commands[] = {
    { "help", "Display this list of commands", mon_help },
    { "kerninfo", "Display information about the kernel", mon_kerninfo },
    { "backtrace", "Display the stack information with backtrace", mon_backtrace},
    { "showmapping", "Display mapping of a virtual address range", mon_showmapping},
    { "dumpmem", "Display a memory of of a vritual/physical range", mon_dumpmem},
    { "setperms", "Set the perms of an address", mon_setperms},
};

/***** Implementations of basic kernel monitor commands *****/

    int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
    int i;

    for (i = 0; i < ARRAY_SIZE(commands); i++)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    return 0;
}

    int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
    extern char _start[], entry[], etext[], edata[], end[];

    cprintf("Special kernel symbols:\n");
    cprintf("  _start                  %08x (phys)\n", _start);
    cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
    cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
    cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
    cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
    cprintf("Kernel executable memory footprint: %dKB\n",
            ROUNDUP(end - entry, 1024) / 1024);
    return 0;
}

    int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
    // LAB 1: Your code here.
    // HINT 1: use read_ebp().
    // HINT 2: print the current ebp on the first line (not current_ebp[0])
    uint32_t *ebp;

    cprintf("Stack backtrace:\n");
    struct Eipdebuginfo ed;

    ebp = ((uint32_t*)read_ebp());

    while(ebp){
        cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
                ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);

        debuginfo_eip(ebp[1], &ed);
        cprintf("\t%s:%d: %.*s+%d\n", ed.eip_file, ed.eip_line, ed.eip_fn_namelen,ed.eip_fn_name, ebp[1]-ed.eip_fn_addr);
        ebp = (uint32_t *)(*ebp); // Go "UP" the stack, reminder that the stack increments when we want to read it.
    }
    return 0;
}

int
dumpmemhelper(void* start_va, void* end_va){
    // I think we have to use round?
    //start_va = ROUNDDOWN(start_va, PGSIZE);
    //end_va = ROUNDUP(end_va, PGSIZE);
    for(; start_va <= end_va; start_va += 4) {// We need to add a byte
        pte_t *pte = pgdir_walk(kern_pgdir, start_va, 0);
        if(!pte) cprintf("Inaccessible @ 0x%x\n", start_va);
        else{
            cprintf("Address: 0x%x Found 0x%x\n", start_va, *(uint32_t*)start_va);
        }
    }
    return 0;
}

int
mon_dumpmem(int argc, char**argv, struct Trapframe *tf){
    if(argc != 4){
        cprintf("We cannot do mon_dumpmem with these parameters\n");
        panic("Format: dumpmem va start_va end_va OR dumpmem pa start_pa end_pa\n");
    }

    int flag = 0;

    uintptr_t start_va = strtol(argv[2], NULL, 0);
    uintptr_t end_va = strtol(argv[3], NULL, 0);

    physaddr_t start_va2 = (physaddr_t)(start_va);
    physaddr_t end_va2 = (physaddr_t)(end_va);
    if(strcmp(argv[1], "pa") == 0){
       // *start_va = (physaddr_t)(strtol(argv[2], NULL, 0));
       dumpmemhelper(KADDR(start_va2), KADDR(end_va2));
        return 0;
    }
    else if (strcmp(argv[1], "va") == 0){
        dumpmemhelper((void *)start_va, (void *)end_va);
    }
    return 0;
}

int
mon_setperms(int argc, char **argv, struct Trapframe *tf){
    pte_t *pte;
    uintptr_t va = strtol(argv[2], NULL, 0);
    pte = pgdir_walk(kern_pgdir, (void *)va, 0);
    if(argc <= 1) {
        cprintf("Format required\n");
        panic("setperms clear va OR setperms set va [W|U|P]\n");
    }
    if(!pte){
        panic("The given address does not have a page mapped\n");
    }

    if(strcmp(argv[1], "clear") == 0){
        cprintf("Clearing\n");
        *pte &= ~0x7;
    }
    else if(strcmp(argv[1], "set") == 0){
        int i = 1;
        *pte &= ~0x7;
        while(argv[3][i]){
            if(argv[3][i] == 'P') *pte |= PTE_P;
            if(argv[3][i] == 'U') *pte |= PTE_U;
            if(argv[3][i] == 'W') *pte |= PTE_W;
            i += 2;
        }
    }
    return 0;

}

int
mon_showmapping(int argc, char **argv, struct Trapframe *tf){

    if(argc != 3){
        panic("We cannot do showmapping with these parameters\n The format is: showmapping start_va end_va\n");
    }



    uintptr_t start_va = ROUNDDOWN(strtol(argv[1], NULL, 0), PGSIZE); // Someone on the Discord gave me this advice for converting into base16.
    uintptr_t end_va = ROUNDUP(strtol(argv[2], NULL, 0), PGSIZE);
    uintptr_t pageoffset = 0x1000;
    cprintf("Start_va: %p, End_va: %p\n", start_va, end_va);

    for(; start_va <= end_va; start_va += PGSIZE){
        pte_t *pte;
        //page_lookup(kern_pgdir, (void *)start_va, &pte); // I'm not sure if we'll need this.
        pte = pgdir_walk(kern_pgdir, (void *)start_va, 0);
        if(pte){
            cprintf("VA: 0x%x maps to 0x%x\n  Permissions: [ ", start_va,PTE_ADDR(*pte));
            if(*pte & PTE_P) cprintf("P ");
            if(*pte & PTE_U) cprintf("U ");
            if(*pte & PTE_W) cprintf("W ");
            /*if(*pte & PTE_PWT) cprintf("PWT ");
            if(*pte & PTE_PCD) cprintf("PCD ");
            if(*pte & PTE_A) cprintf("A ");
            if(*pte & PTE_D) cprintf("D ");
            if(*pte & PTE_PS) cprintf("PS ");
            if(*pte & PTE_G) cprintf("G ");*/
            cprintf("]\n");
        }
        else{
            cprintf("Location at %p does not have a valid page\n", start_va);
        }
    }
    return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

    static int
runcmd(char *buf, struct Trapframe *tf)
{
    int argc;
    char *argv[MAXARGS];
    int i;

    // Parse the command buffer into whitespace-separated arguments
    argc = 0;
    argv[argc] = 0;
    while (1) {
        // gobble whitespace
        while (*buf && strchr(WHITESPACE, *buf))
            *buf++ = 0;
        if (*buf == 0)
            break;

        // save and scan past next arg
        if (argc == MAXARGS-1) {
            cprintf("Too many arguments (max %d)\n", MAXARGS);
            return 0;
        }
        argv[argc++] = buf;
        while (*buf && !strchr(WHITESPACE, *buf))
            buf++;
    }
    argv[argc] = 0;

    // Lookup and invoke the command
    if (argc == 0)
        return 0;
    for (i = 0; i < ARRAY_SIZE(commands); i++) {
        if (strcmp(argv[0], commands[i].name) == 0)
            return commands[i].func(argc, argv, tf);
    }
    cprintf("Unknown command '%s'\n", argv[0]);
    return 0;
}

    void
monitor(struct Trapframe *tf)
{

    char *buf;
    //cprintf("\033[1;31m");
    cprintf("Welcome to the JOS kernel monitor!\n");
    cprintf("Type 'help' for a list of commands.\n");
	if (tf != NULL)
		print_trapframe(tf);
    //   cprintf("\033[1;31m");
    //    cprintf("\033[1;31m Color Test my GUY");
    while (1) {
        buf = readline("K> ");
        if (buf != NULL)
            if (runcmd(buf, tf) < 0)
                break;
    }
}
