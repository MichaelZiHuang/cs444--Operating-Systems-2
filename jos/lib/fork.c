// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{

	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;
    int perm = PTE_U | PTE_P; // I REALLY dont want to write this for the 1000th time this class.
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    // Permissions: PTE_COW
    // Errors for pagefault:
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
        panic("pgfault error: Incorrect permissions OR FEC_WR");
    }
    //if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)))
      //          panic("pgfault: not copy-on-write\n");
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
	if(r < 0){
        panic("Pgfault error: syscall for page alloc has failed");
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
        panic("Pgfault error: map bad");
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
    if(r < 0){
        panic("Pgfault error: unmap bad");
    }
    // LAB 4
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
    int t = 0;
    int defaultperms = PTE_U | PTE_P; // Reminder that U should always be active, we are in user afterall.
    if(uvpt[pn] & (PTE_W | PTE_COW)){
        defaultperms =  PTE_U | PTE_P | PTE_COW;
        t = 1;
    }
	// LAB 4: Your code here.
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
    if( r < 0 ){
        return -E_INVAL;
    }

    if(t){
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
        if( r < 0 ){
            return -E_INVAL;
        }
    }
    //panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
    /* Okay, so I looked into the above part and it looks like
     * that the user is the one that sets up the set_pgfault_handler
     * Some of the files (like faultalloc.c) have an example of this
     * I'm going to copy the same format and see what happens.
     */


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
        panic("fork: Error on sys_exofork()");
    }
    if(child == 0){
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
        // It's a whole lot like lab3 with the env stuff
        return 0;
    }
    /* Parent time
    / We need to complete the later portions.
    / Reminder that by now, the parent should have the child's information.
    / We need to do a copy address, how should we do this?
    / We need to get everything the parent has to the child, it's a literal copy.
    / This probably means we need to go through every page they have.... SO! That means we need to get the parent's addr.
    / Thanks to the before logic, "0" can be addr. Then we need to increment by pg until we smash until UYXSTACKTOP.
    / Let's keep thinking. Remember that whole rule about perms on the page directory versus the table?
    / ya know, lesser permissions and all that? Let's keep that in mind during these memes.
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
            // Well, the pages are present. I think it's okay just to do pte_p?
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.

    if(r < 0){
        panic("fork: sys_page_alloc has failed");
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
    if(r < 0){
        panic("fork: set_env_pgfault_upcall has failed");
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
    if(r < 0){
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
    }
    return child;
//	panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
