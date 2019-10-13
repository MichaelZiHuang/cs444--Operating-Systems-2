
obj/user/dumbfork.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1d 02 00 00       	call   80024e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 91 0d 00 00       	call   800df3 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 c0 21 80 	movl   $0x8021c0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  800081:	e8 29 02 00 00       	call   8002af <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 9d 0d 00 00       	call   800e47 <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 e3 21 80 	movl   $0x8021e3,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  8000c9:	e8 e1 01 00 00       	call   8002af <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 8e 0a 00 00       	call   800b74 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 a0 0d 00 00       	call   800e9a <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 f4 21 80 	movl   $0x8021f4,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  800119:	e8 91 01 00 00       	call   8002af <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80012d:	b8 07 00 00 00       	mov    $0x7,%eax
  800132:	cd 30                	int    $0x30
  800134:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	79 20                	jns    80015a <dumbfork+0x35>
		panic("sys_exofork: %e", envid);
  80013a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013e:	c7 44 24 08 07 22 80 	movl   $0x802207,0x8(%esp)
  800145:	00 
  800146:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014d:	00 
  80014e:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  800155:	e8 55 01 00 00       	call   8002af <_panic>
  80015a:	89 c3                	mov    %eax,%ebx
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 1e                	jne    80017e <dumbfork+0x59>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 50 0c 00 00       	call   800db5 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800177:	b8 00 00 00 00       	mov    $0x0,%eax
  80017c:	eb 71                	jmp    8001ef <dumbfork+0xca>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017e:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800185:	eb 13                	jmp    80019a <dumbfork+0x75>
		duppage(envid, addr);
  800187:	89 54 24 04          	mov    %edx,0x4(%esp)
  80018b:	89 1c 24             	mov    %ebx,(%esp)
  80018e:	e8 ad fe ff ff       	call   800040 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800193:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80019a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80019d:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  8001a3:	72 e2                	jb     800187 <dumbfork+0x62>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 87 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c0:	00 
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 24 0d 00 00       	call   800eed <sys_env_set_status>
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	79 20                	jns    8001ed <dumbfork+0xc8>
		panic("sys_env_set_status: %e", r);
  8001cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d1:	c7 44 24 08 17 22 80 	movl   $0x802217,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e0:	00 
  8001e1:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  8001e8:	e8 c2 00 00 00       	call   8002af <_panic>

	return envid;
  8001ed:	89 f0                	mov    %esi,%eax
}
  8001ef:	83 c4 20             	add    $0x20,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 10             	sub    $0x10,%esp
	who = dumbfork();
  8001fe:	e8 22 ff ff ff       	call   800125 <dumbfork>
  800203:	89 c6                	mov    %eax,%esi
	for (i = 0; i < (who ? 10 : 20); i++) {
  800205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020a:	eb 28                	jmp    800234 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020c:	b8 35 22 80 00       	mov    $0x802235,%eax
  800211:	eb 05                	jmp    800218 <umain+0x22>
  800213:	b8 2e 22 80 00       	mov    $0x80222e,%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800220:	c7 04 24 3b 22 80 00 	movl   $0x80223b,(%esp)
  800227:	e8 7c 01 00 00       	call   8003a8 <cprintf>
		sys_yield();
  80022c:	e8 a3 0b 00 00       	call   800dd4 <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  800231:	83 c3 01             	add    $0x1,%ebx
  800234:	85 f6                	test   %esi,%esi
  800236:	75 0a                	jne    800242 <umain+0x4c>
  800238:	83 fb 13             	cmp    $0x13,%ebx
  80023b:	7e cf                	jle    80020c <umain+0x16>
  80023d:	8d 76 00             	lea    0x0(%esi),%esi
  800240:	eb 05                	jmp    800247 <umain+0x51>
  800242:	83 fb 09             	cmp    $0x9,%ebx
  800245:	7e cc                	jle    800213 <umain+0x1d>
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 10             	sub    $0x10,%esp
  800256:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800259:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  80025c:	e8 54 0b 00 00       	call   800db5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800261:	25 ff 03 00 00       	and    $0x3ff,%eax
  800266:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800269:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80026e:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800273:	85 db                	test   %ebx,%ebx
  800275:	7e 07                	jle    80027e <libmain+0x30>
		binaryname = argv[0];
  800277:	8b 06                	mov    (%esi),%eax
  800279:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80027e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800282:	89 1c 24             	mov    %ebx,(%esp)
  800285:	e8 6c ff ff ff       	call   8001f6 <umain>

	// exit gracefully
	exit();
  80028a:	e8 07 00 00 00       	call   800296 <exit>
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80029c:	e8 94 0f 00 00       	call   801235 <close_all>
	sys_env_destroy(0);
  8002a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a8:	e8 b6 0a 00 00       	call   800d63 <sys_env_destroy>
}
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ba:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002c0:	e8 f0 0a 00 00       	call   800db5 <sys_getenvid>
  8002c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002db:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  8002e2:	e8 c1 00 00 00       	call   8003a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 51 00 00 00       	call   800347 <vcprintf>
	cprintf("\n");
  8002f6:	c7 04 24 4b 22 80 00 	movl   $0x80224b,(%esp)
  8002fd:	e8 a6 00 00 00       	call   8003a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800302:	cc                   	int3   
  800303:	eb fd                	jmp    800302 <_panic+0x53>

00800305 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	53                   	push   %ebx
  800309:	83 ec 14             	sub    $0x14,%esp
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030f:	8b 13                	mov    (%ebx),%edx
  800311:	8d 42 01             	lea    0x1(%edx),%eax
  800314:	89 03                	mov    %eax,(%ebx)
  800316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800319:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80031d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800322:	75 19                	jne    80033d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800324:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80032b:	00 
  80032c:	8d 43 08             	lea    0x8(%ebx),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	e8 ef 09 00 00       	call   800d26 <sys_cputs>
		b->idx = 0;
  800337:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80033d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800341:	83 c4 14             	add    $0x14,%esp
  800344:	5b                   	pop    %ebx
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800350:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800357:	00 00 00 
	b.cnt = 0;
  80035a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800361:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
  800367:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800372:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037c:	c7 04 24 05 03 80 00 	movl   $0x800305,(%esp)
  800383:	e8 b6 01 00 00       	call   80053e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80038e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800392:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 86 09 00 00       	call   800d26 <sys_cputs>

	return b.cnt;
}
  8003a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 87 ff ff ff       	call   800347 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    
  8003c2:	66 90                	xchg   %ax,%ax
  8003c4:	66 90                	xchg   %ax,%ax
  8003c6:	66 90                	xchg   %ax,%ax
  8003c8:	66 90                	xchg   %ax,%ax
  8003ca:	66 90                	xchg   %ax,%ax
  8003cc:	66 90                	xchg   %ax,%ax
  8003ce:	66 90                	xchg   %ax,%ax

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 3c             	sub    $0x3c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e7:	89 c3                	mov    %eax,%ebx
  8003e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003fd:	39 d9                	cmp    %ebx,%ecx
  8003ff:	72 05                	jb     800406 <printnum+0x36>
  800401:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800404:	77 69                	ja     80046f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800406:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800409:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80040d:	83 ee 01             	sub    $0x1,%esi
  800410:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800414:	89 44 24 08          	mov    %eax,0x8(%esp)
  800418:	8b 44 24 08          	mov    0x8(%esp),%eax
  80041c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800420:	89 c3                	mov    %eax,%ebx
  800422:	89 d6                	mov    %edx,%esi
  800424:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800427:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80042a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80042e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800432:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800435:	89 04 24             	mov    %eax,(%esp)
  800438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80043b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043f:	e8 ec 1a 00 00       	call   801f30 <__udivdi3>
  800444:	89 d9                	mov    %ebx,%ecx
  800446:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80044a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	89 54 24 04          	mov    %edx,0x4(%esp)
  800455:	89 fa                	mov    %edi,%edx
  800457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045a:	e8 71 ff ff ff       	call   8003d0 <printnum>
  80045f:	eb 1b                	jmp    80047c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800461:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800465:	8b 45 18             	mov    0x18(%ebp),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	ff d3                	call   *%ebx
  80046d:	eb 03                	jmp    800472 <printnum+0xa2>
  80046f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800472:	83 ee 01             	sub    $0x1,%esi
  800475:	85 f6                	test   %esi,%esi
  800477:	7f e8                	jg     800461 <printnum+0x91>
  800479:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800480:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800484:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800487:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80048a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049f:	e8 bc 1b 00 00       	call   802060 <__umoddi3>
  8004a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a8:	0f be 80 7b 22 80 00 	movsbl 0x80227b(%eax),%eax
  8004af:	89 04 24             	mov    %eax,(%esp)
  8004b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b5:	ff d0                	call   *%eax
}
  8004b7:	83 c4 3c             	add    $0x3c,%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c2:	83 fa 01             	cmp    $0x1,%edx
  8004c5:	7e 0e                	jle    8004d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	8b 52 04             	mov    0x4(%edx),%edx
  8004d3:	eb 22                	jmp    8004f7 <getuint+0x38>
	else if (lflag)
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 10                	je     8004e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 02                	mov    (%edx),%eax
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	eb 0e                	jmp    8004f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e9:	8b 10                	mov    (%eax),%edx
  8004eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ee:	89 08                	mov    %ecx,(%eax)
  8004f0:	8b 02                	mov    (%edx),%eax
  8004f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f7:	5d                   	pop    %ebp
  8004f8:	c3                   	ret    

008004f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800503:	8b 10                	mov    (%eax),%edx
  800505:	3b 50 04             	cmp    0x4(%eax),%edx
  800508:	73 0a                	jae    800514 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050d:	89 08                	mov    %ecx,(%eax)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	88 02                	mov    %al,(%edx)
}
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <printfmt>:
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80051c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800523:	8b 45 10             	mov    0x10(%ebp),%eax
  800526:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	8b 45 08             	mov    0x8(%ebp),%eax
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	e8 02 00 00 00       	call   80053e <vprintfmt>
}
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <vprintfmt>:
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	57                   	push   %edi
  800542:	56                   	push   %esi
  800543:	53                   	push   %ebx
  800544:	83 ec 3c             	sub    $0x3c,%esp
  800547:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80054a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80054d:	eb 1f                	jmp    80056e <vprintfmt+0x30>
			if (ch == '\0'){
  80054f:	85 c0                	test   %eax,%eax
  800551:	75 0f                	jne    800562 <vprintfmt+0x24>
				color = 0x0100;
  800553:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80055a:	01 00 00 
  80055d:	e9 b3 03 00 00       	jmp    800915 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056c:	89 f3                	mov    %esi,%ebx
  80056e:	8d 73 01             	lea    0x1(%ebx),%esi
  800571:	0f b6 03             	movzbl (%ebx),%eax
  800574:	83 f8 25             	cmp    $0x25,%eax
  800577:	75 d6                	jne    80054f <vprintfmt+0x11>
  800579:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80057d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800584:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80058b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800592:	ba 00 00 00 00       	mov    $0x0,%edx
  800597:	eb 1d                	jmp    8005b6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800599:	89 de                	mov    %ebx,%esi
			padc = '-';
  80059b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80059f:	eb 15                	jmp    8005b6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	89 de                	mov    %ebx,%esi
			padc = '0';
  8005a3:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005a7:	eb 0d                	jmp    8005b6 <vprintfmt+0x78>
				width = precision, precision = -1;
  8005a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005af:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005b9:	0f b6 0e             	movzbl (%esi),%ecx
  8005bc:	0f b6 c1             	movzbl %cl,%eax
  8005bf:	83 e9 23             	sub    $0x23,%ecx
  8005c2:	80 f9 55             	cmp    $0x55,%cl
  8005c5:	0f 87 2a 03 00 00    	ja     8008f5 <vprintfmt+0x3b7>
  8005cb:	0f b6 c9             	movzbl %cl,%ecx
  8005ce:	ff 24 8d c0 23 80 00 	jmp    *0x8023c0(,%ecx,4)
  8005d5:	89 de                	mov    %ebx,%esi
  8005d7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8005dc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005df:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8005e3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005e6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005e9:	83 fb 09             	cmp    $0x9,%ebx
  8005ec:	77 36                	ja     800624 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8005ee:	83 c6 01             	add    $0x1,%esi
			}
  8005f1:	eb e9                	jmp    8005dc <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800601:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800603:	eb 22                	jmp    800627 <vprintfmt+0xe9>
  800605:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800608:	85 c9                	test   %ecx,%ecx
  80060a:	b8 00 00 00 00       	mov    $0x0,%eax
  80060f:	0f 49 c1             	cmovns %ecx,%eax
  800612:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800615:	89 de                	mov    %ebx,%esi
  800617:	eb 9d                	jmp    8005b6 <vprintfmt+0x78>
  800619:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80061b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800622:	eb 92                	jmp    8005b6 <vprintfmt+0x78>
  800624:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800627:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062b:	79 89                	jns    8005b6 <vprintfmt+0x78>
  80062d:	e9 77 ff ff ff       	jmp    8005a9 <vprintfmt+0x6b>
			lflag++;
  800632:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800635:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800637:	e9 7a ff ff ff       	jmp    8005b6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800651:	e9 18 ff ff ff       	jmp    80056e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 0f             	cmp    $0xf,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x138>
  80066b:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 20                	jne    800696 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800676:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067a:	c7 44 24 08 93 22 80 	movl   $0x802293,0x8(%esp)
  800681:	00 
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	e8 85 fe ff ff       	call   800516 <printfmt>
  800691:	e9 d8 fe ff ff       	jmp    80056e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800696:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069a:	c7 44 24 08 7e 26 80 	movl   $0x80267e,0x8(%esp)
  8006a1:	00 
  8006a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a9:	89 04 24             	mov    %eax,(%esp)
  8006ac:	e8 65 fe ff ff       	call   800516 <printfmt>
  8006b1:	e9 b8 fe ff ff       	jmp    80056e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006ca:	85 f6                	test   %esi,%esi
  8006cc:	b8 8c 22 80 00       	mov    $0x80228c,%eax
  8006d1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006d4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006d8:	0f 84 97 00 00 00    	je     800775 <vprintfmt+0x237>
  8006de:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006e2:	0f 8e 9b 00 00 00    	jle    800783 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ec:	89 34 24             	mov    %esi,(%esp)
  8006ef:	e8 c4 02 00 00       	call   8009b8 <strnlen>
  8006f4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006f7:	29 c2                	sub    %eax,%edx
  8006f9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006fc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800700:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800703:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800706:	8b 75 08             	mov    0x8(%ebp),%esi
  800709:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80070c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80070e:	eb 0f                	jmp    80071f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800714:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800717:	89 04 24             	mov    %eax,(%esp)
  80071a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80071c:	83 eb 01             	sub    $0x1,%ebx
  80071f:	85 db                	test   %ebx,%ebx
  800721:	7f ed                	jg     800710 <vprintfmt+0x1d2>
  800723:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800726:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800729:	85 d2                	test   %edx,%edx
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
  800730:	0f 49 c2             	cmovns %edx,%eax
  800733:	29 c2                	sub    %eax,%edx
  800735:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800738:	89 d7                	mov    %edx,%edi
  80073a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80073d:	eb 50                	jmp    80078f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80073f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800743:	74 1e                	je     800763 <vprintfmt+0x225>
  800745:	0f be d2             	movsbl %dl,%edx
  800748:	83 ea 20             	sub    $0x20,%edx
  80074b:	83 fa 5e             	cmp    $0x5e,%edx
  80074e:	76 13                	jbe    800763 <vprintfmt+0x225>
					putch('?', putdat);
  800750:	8b 45 0c             	mov    0xc(%ebp),%eax
  800753:	89 44 24 04          	mov    %eax,0x4(%esp)
  800757:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80075e:	ff 55 08             	call   *0x8(%ebp)
  800761:	eb 0d                	jmp    800770 <vprintfmt+0x232>
					putch(ch, putdat);
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
  800766:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076a:	89 04 24             	mov    %eax,(%esp)
  80076d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800770:	83 ef 01             	sub    $0x1,%edi
  800773:	eb 1a                	jmp    80078f <vprintfmt+0x251>
  800775:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800778:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80077b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80077e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800781:	eb 0c                	jmp    80078f <vprintfmt+0x251>
  800783:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800786:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800789:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80078c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80078f:	83 c6 01             	add    $0x1,%esi
  800792:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800796:	0f be c2             	movsbl %dl,%eax
  800799:	85 c0                	test   %eax,%eax
  80079b:	74 27                	je     8007c4 <vprintfmt+0x286>
  80079d:	85 db                	test   %ebx,%ebx
  80079f:	78 9e                	js     80073f <vprintfmt+0x201>
  8007a1:	83 eb 01             	sub    $0x1,%ebx
  8007a4:	79 99                	jns    80073f <vprintfmt+0x201>
  8007a6:	89 f8                	mov    %edi,%eax
  8007a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ae:	89 c3                	mov    %eax,%ebx
  8007b0:	eb 1a                	jmp    8007cc <vprintfmt+0x28e>
				putch(' ', putdat);
  8007b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007bd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007bf:	83 eb 01             	sub    $0x1,%ebx
  8007c2:	eb 08                	jmp    8007cc <vprintfmt+0x28e>
  8007c4:	89 fb                	mov    %edi,%ebx
  8007c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007cc:	85 db                	test   %ebx,%ebx
  8007ce:	7f e2                	jg     8007b2 <vprintfmt+0x274>
  8007d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8007d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007d6:	e9 93 fd ff ff       	jmp    80056e <vprintfmt+0x30>
	if (lflag >= 2)
  8007db:	83 fa 01             	cmp    $0x1,%edx
  8007de:	7e 16                	jle    8007f6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 08             	lea    0x8(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 50 04             	mov    0x4(%eax),%edx
  8007ec:	8b 00                	mov    (%eax),%eax
  8007ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007f4:	eb 32                	jmp    800828 <vprintfmt+0x2ea>
	else if (lflag)
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 18                	je     800812 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	8b 30                	mov    (%eax),%esi
  800805:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800808:	89 f0                	mov    %esi,%eax
  80080a:	c1 f8 1f             	sar    $0x1f,%eax
  80080d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800810:	eb 16                	jmp    800828 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)
  80081b:	8b 30                	mov    (%eax),%esi
  80081d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800820:	89 f0                	mov    %esi,%eax
  800822:	c1 f8 1f             	sar    $0x1f,%eax
  800825:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800828:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80082b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80082e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800833:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800837:	0f 89 80 00 00 00    	jns    8008bd <vprintfmt+0x37f>
				putch('-', putdat);
  80083d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800841:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800848:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80084b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80084e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800851:	f7 d8                	neg    %eax
  800853:	83 d2 00             	adc    $0x0,%edx
  800856:	f7 da                	neg    %edx
			base = 10;
  800858:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80085d:	eb 5e                	jmp    8008bd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80085f:	8d 45 14             	lea    0x14(%ebp),%eax
  800862:	e8 58 fc ff ff       	call   8004bf <getuint>
			base = 10;
  800867:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80086c:	eb 4f                	jmp    8008bd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80086e:	8d 45 14             	lea    0x14(%ebp),%eax
  800871:	e8 49 fc ff ff       	call   8004bf <getuint>
            base = 8;
  800876:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80087b:	eb 40                	jmp    8008bd <vprintfmt+0x37f>
			putch('0', putdat);
  80087d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800881:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800888:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80088b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80088f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800896:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8d 50 04             	lea    0x4(%eax),%edx
  80089f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8008a2:	8b 00                	mov    (%eax),%eax
  8008a4:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8008a9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008ae:	eb 0d                	jmp    8008bd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8008b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b3:	e8 07 fc ff ff       	call   8004bf <getuint>
			base = 16;
  8008b8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8008bd:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8008c1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008c5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8008c8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008cc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008d0:	89 04 24             	mov    %eax,(%esp)
  8008d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d7:	89 fa                	mov    %edi,%edx
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	e8 ef fa ff ff       	call   8003d0 <printnum>
			break;
  8008e1:	e9 88 fc ff ff       	jmp    80056e <vprintfmt+0x30>
			putch(ch, putdat);
  8008e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ea:	89 04 24             	mov    %eax,(%esp)
  8008ed:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008f0:	e9 79 fc ff ff       	jmp    80056e <vprintfmt+0x30>
			putch('%', putdat);
  8008f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800900:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800903:	89 f3                	mov    %esi,%ebx
  800905:	eb 03                	jmp    80090a <vprintfmt+0x3cc>
  800907:	83 eb 01             	sub    $0x1,%ebx
  80090a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80090e:	75 f7                	jne    800907 <vprintfmt+0x3c9>
  800910:	e9 59 fc ff ff       	jmp    80056e <vprintfmt+0x30>
}
  800915:	83 c4 3c             	add    $0x3c,%esp
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 28             	sub    $0x28,%esp
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800929:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800930:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800933:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093a:	85 c0                	test   %eax,%eax
  80093c:	74 30                	je     80096e <vsnprintf+0x51>
  80093e:	85 d2                	test   %edx,%edx
  800940:	7e 2c                	jle    80096e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800949:	8b 45 10             	mov    0x10(%ebp),%eax
  80094c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800950:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800953:	89 44 24 04          	mov    %eax,0x4(%esp)
  800957:	c7 04 24 f9 04 80 00 	movl   $0x8004f9,(%esp)
  80095e:	e8 db fb ff ff       	call   80053e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800963:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800966:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096c:	eb 05                	jmp    800973 <vsnprintf+0x56>
		return -E_INVAL;
  80096e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800982:	8b 45 10             	mov    0x10(%ebp),%eax
  800985:	89 44 24 08          	mov    %eax,0x8(%esp)
  800989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 82 ff ff ff       	call   80091d <vsnprintf>
	va_end(ap);

	return rc;
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    
  80099d:	66 90                	xchg   %ax,%ax
  80099f:	90                   	nop

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	eb 03                	jmp    8009b0 <strlen+0x10>
		n++;
  8009ad:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b4:	75 f7                	jne    8009ad <strlen+0xd>
	return n;
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	eb 03                	jmp    8009cb <strnlen+0x13>
		n++;
  8009c8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cb:	39 d0                	cmp    %edx,%eax
  8009cd:	74 06                	je     8009d5 <strnlen+0x1d>
  8009cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009d3:	75 f3                	jne    8009c8 <strnlen+0x10>
	return n;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e1:	89 c2                	mov    %eax,%edx
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f0:	84 db                	test   %bl,%bl
  8009f2:	75 ef                	jne    8009e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	83 ec 08             	sub    $0x8,%esp
  8009fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a01:	89 1c 24             	mov    %ebx,(%esp)
  800a04:	e8 97 ff ff ff       	call   8009a0 <strlen>
	strcpy(dst + len, src);
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a10:	01 d8                	add    %ebx,%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 bd ff ff ff       	call   8009d7 <strcpy>
	return dst;
}
  800a1a:	89 d8                	mov    %ebx,%eax
  800a1c:	83 c4 08             	add    $0x8,%esp
  800a1f:	5b                   	pop    %ebx
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a32:	89 f2                	mov    %esi,%edx
  800a34:	eb 0f                	jmp    800a45 <strncpy+0x23>
		*dst++ = *src;
  800a36:	83 c2 01             	add    $0x1,%edx
  800a39:	0f b6 01             	movzbl (%ecx),%eax
  800a3c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a42:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a45:	39 da                	cmp    %ebx,%edx
  800a47:	75 ed                	jne    800a36 <strncpy+0x14>
	}
	return ret;
}
  800a49:	89 f0                	mov    %esi,%eax
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 75 08             	mov    0x8(%ebp),%esi
  800a57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a5d:	89 f0                	mov    %esi,%eax
  800a5f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a63:	85 c9                	test   %ecx,%ecx
  800a65:	75 0b                	jne    800a72 <strlcpy+0x23>
  800a67:	eb 1d                	jmp    800a86 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a72:	39 d8                	cmp    %ebx,%eax
  800a74:	74 0b                	je     800a81 <strlcpy+0x32>
  800a76:	0f b6 0a             	movzbl (%edx),%ecx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	75 ec                	jne    800a69 <strlcpy+0x1a>
  800a7d:	89 c2                	mov    %eax,%edx
  800a7f:	eb 02                	jmp    800a83 <strlcpy+0x34>
  800a81:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800a83:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a86:	29 f0                	sub    %esi,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a95:	eb 06                	jmp    800a9d <strcmp+0x11>
		p++, q++;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a9d:	0f b6 01             	movzbl (%ecx),%eax
  800aa0:	84 c0                	test   %al,%al
  800aa2:	74 04                	je     800aa8 <strcmp+0x1c>
  800aa4:	3a 02                	cmp    (%edx),%al
  800aa6:	74 ef                	je     800a97 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa8:	0f b6 c0             	movzbl %al,%eax
  800aab:	0f b6 12             	movzbl (%edx),%edx
  800aae:	29 d0                	sub    %edx,%eax
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac1:	eb 06                	jmp    800ac9 <strncmp+0x17>
		n--, p++, q++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ac9:	39 d8                	cmp    %ebx,%eax
  800acb:	74 15                	je     800ae2 <strncmp+0x30>
  800acd:	0f b6 08             	movzbl (%eax),%ecx
  800ad0:	84 c9                	test   %cl,%cl
  800ad2:	74 04                	je     800ad8 <strncmp+0x26>
  800ad4:	3a 0a                	cmp    (%edx),%cl
  800ad6:	74 eb                	je     800ac3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad8:	0f b6 00             	movzbl (%eax),%eax
  800adb:	0f b6 12             	movzbl (%edx),%edx
  800ade:	29 d0                	sub    %edx,%eax
  800ae0:	eb 05                	jmp    800ae7 <strncmp+0x35>
		return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af4:	eb 07                	jmp    800afd <strchr+0x13>
		if (*s == c)
  800af6:	38 ca                	cmp    %cl,%dl
  800af8:	74 0f                	je     800b09 <strchr+0x1f>
	for (; *s; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	0f b6 10             	movzbl (%eax),%edx
  800b00:	84 d2                	test   %dl,%dl
  800b02:	75 f2                	jne    800af6 <strchr+0xc>
			return (char *) s;
	return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b15:	eb 07                	jmp    800b1e <strfind+0x13>
		if (*s == c)
  800b17:	38 ca                	cmp    %cl,%dl
  800b19:	74 0a                	je     800b25 <strfind+0x1a>
	for (; *s; s++)
  800b1b:	83 c0 01             	add    $0x1,%eax
  800b1e:	0f b6 10             	movzbl (%eax),%edx
  800b21:	84 d2                	test   %dl,%dl
  800b23:	75 f2                	jne    800b17 <strfind+0xc>
			break;
	return (char *) s;
}
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b33:	85 c9                	test   %ecx,%ecx
  800b35:	74 36                	je     800b6d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b37:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3d:	75 28                	jne    800b67 <memset+0x40>
  800b3f:	f6 c1 03             	test   $0x3,%cl
  800b42:	75 23                	jne    800b67 <memset+0x40>
		c &= 0xFF;
  800b44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	c1 e3 08             	shl    $0x8,%ebx
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	c1 e6 18             	shl    $0x18,%esi
  800b52:	89 d0                	mov    %edx,%eax
  800b54:	c1 e0 10             	shl    $0x10,%eax
  800b57:	09 f0                	or     %esi,%eax
  800b59:	09 c2                	or     %eax,%edx
  800b5b:	89 d0                	mov    %edx,%eax
  800b5d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b5f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b62:	fc                   	cld    
  800b63:	f3 ab                	rep stos %eax,%es:(%edi)
  800b65:	eb 06                	jmp    800b6d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	fc                   	cld    
  800b6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b82:	39 c6                	cmp    %eax,%esi
  800b84:	73 35                	jae    800bbb <memmove+0x47>
  800b86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b89:	39 d0                	cmp    %edx,%eax
  800b8b:	73 2e                	jae    800bbb <memmove+0x47>
		s += n;
		d += n;
  800b8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b94:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9a:	75 13                	jne    800baf <memmove+0x3b>
  800b9c:	f6 c1 03             	test   $0x3,%cl
  800b9f:	75 0e                	jne    800baf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba1:	83 ef 04             	sub    $0x4,%edi
  800ba4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800baa:	fd                   	std    
  800bab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bad:	eb 09                	jmp    800bb8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800baf:	83 ef 01             	sub    $0x1,%edi
  800bb2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bb5:	fd                   	std    
  800bb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb8:	fc                   	cld    
  800bb9:	eb 1d                	jmp    800bd8 <memmove+0x64>
  800bbb:	89 f2                	mov    %esi,%edx
  800bbd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbf:	f6 c2 03             	test   $0x3,%dl
  800bc2:	75 0f                	jne    800bd3 <memmove+0x5f>
  800bc4:	f6 c1 03             	test   $0x3,%cl
  800bc7:	75 0a                	jne    800bd3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bcc:	89 c7                	mov    %eax,%edi
  800bce:	fc                   	cld    
  800bcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd1:	eb 05                	jmp    800bd8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800bd3:	89 c7                	mov    %eax,%edi
  800bd5:	fc                   	cld    
  800bd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800be2:	8b 45 10             	mov    0x10(%ebp),%eax
  800be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	89 04 24             	mov    %eax,(%esp)
  800bf6:	e8 79 ff ff ff       	call   800b74 <memmove>
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0d:	eb 1a                	jmp    800c29 <memcmp+0x2c>
		if (*s1 != *s2)
  800c0f:	0f b6 02             	movzbl (%edx),%eax
  800c12:	0f b6 19             	movzbl (%ecx),%ebx
  800c15:	38 d8                	cmp    %bl,%al
  800c17:	74 0a                	je     800c23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c19:	0f b6 c0             	movzbl %al,%eax
  800c1c:	0f b6 db             	movzbl %bl,%ebx
  800c1f:	29 d8                	sub    %ebx,%eax
  800c21:	eb 0f                	jmp    800c32 <memcmp+0x35>
		s1++, s2++;
  800c23:	83 c2 01             	add    $0x1,%edx
  800c26:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800c29:	39 f2                	cmp    %esi,%edx
  800c2b:	75 e2                	jne    800c0f <memcmp+0x12>
	}

	return 0;
  800c2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c3f:	89 c2                	mov    %eax,%edx
  800c41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c44:	eb 07                	jmp    800c4d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c46:	38 08                	cmp    %cl,(%eax)
  800c48:	74 07                	je     800c51 <memfind+0x1b>
	for (; s < ends; s++)
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	39 d0                	cmp    %edx,%eax
  800c4f:	72 f5                	jb     800c46 <memfind+0x10>
			break;
	return (void *) s;
}
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5f:	eb 03                	jmp    800c64 <strtol+0x11>
		s++;
  800c61:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c64:	0f b6 0a             	movzbl (%edx),%ecx
  800c67:	80 f9 09             	cmp    $0x9,%cl
  800c6a:	74 f5                	je     800c61 <strtol+0xe>
  800c6c:	80 f9 20             	cmp    $0x20,%cl
  800c6f:	74 f0                	je     800c61 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c71:	80 f9 2b             	cmp    $0x2b,%cl
  800c74:	75 0a                	jne    800c80 <strtol+0x2d>
		s++;
  800c76:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c79:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7e:	eb 11                	jmp    800c91 <strtol+0x3e>
  800c80:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800c85:	80 f9 2d             	cmp    $0x2d,%cl
  800c88:	75 07                	jne    800c91 <strtol+0x3e>
		s++, neg = 1;
  800c8a:	8d 52 01             	lea    0x1(%edx),%edx
  800c8d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c91:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c96:	75 15                	jne    800cad <strtol+0x5a>
  800c98:	80 3a 30             	cmpb   $0x30,(%edx)
  800c9b:	75 10                	jne    800cad <strtol+0x5a>
  800c9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca1:	75 0a                	jne    800cad <strtol+0x5a>
		s += 2, base = 16;
  800ca3:	83 c2 02             	add    $0x2,%edx
  800ca6:	b8 10 00 00 00       	mov    $0x10,%eax
  800cab:	eb 10                	jmp    800cbd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800cad:	85 c0                	test   %eax,%eax
  800caf:	75 0c                	jne    800cbd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800cb3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cb6:	75 05                	jne    800cbd <strtol+0x6a>
		s++, base = 8;
  800cb8:	83 c2 01             	add    $0x1,%edx
  800cbb:	b0 08                	mov    $0x8,%al
		base = 10;
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc5:	0f b6 0a             	movzbl (%edx),%ecx
  800cc8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ccb:	89 f0                	mov    %esi,%eax
  800ccd:	3c 09                	cmp    $0x9,%al
  800ccf:	77 08                	ja     800cd9 <strtol+0x86>
			dig = *s - '0';
  800cd1:	0f be c9             	movsbl %cl,%ecx
  800cd4:	83 e9 30             	sub    $0x30,%ecx
  800cd7:	eb 20                	jmp    800cf9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800cd9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cdc:	89 f0                	mov    %esi,%eax
  800cde:	3c 19                	cmp    $0x19,%al
  800ce0:	77 08                	ja     800cea <strtol+0x97>
			dig = *s - 'a' + 10;
  800ce2:	0f be c9             	movsbl %cl,%ecx
  800ce5:	83 e9 57             	sub    $0x57,%ecx
  800ce8:	eb 0f                	jmp    800cf9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800cea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ced:	89 f0                	mov    %esi,%eax
  800cef:	3c 19                	cmp    $0x19,%al
  800cf1:	77 16                	ja     800d09 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800cf3:	0f be c9             	movsbl %cl,%ecx
  800cf6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cf9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cfc:	7d 0f                	jge    800d0d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cfe:	83 c2 01             	add    $0x1,%edx
  800d01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800d05:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800d07:	eb bc                	jmp    800cc5 <strtol+0x72>
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	eb 02                	jmp    800d0f <strtol+0xbc>
  800d0d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800d0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d13:	74 05                	je     800d1a <strtol+0xc7>
		*endptr = (char *) s;
  800d15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d18:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d1a:	f7 d8                	neg    %eax
  800d1c:	85 ff                	test   %edi,%edi
  800d1e:	0f 44 c3             	cmove  %ebx,%eax
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 c3                	mov    %eax,%ebx
  800d39:	89 c7                	mov    %eax,%edi
  800d3b:	89 c6                	mov    %eax,%esi
  800d3d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d54:	89 d1                	mov    %edx,%ecx
  800d56:	89 d3                	mov    %edx,%ebx
  800d58:	89 d7                	mov    %edx,%edi
  800d5a:	89 d6                	mov    %edx,%esi
  800d5c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d71:	b8 03 00 00 00       	mov    $0x3,%eax
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 cb                	mov    %ecx,%ebx
  800d7b:	89 cf                	mov    %ecx,%edi
  800d7d:	89 ce                	mov    %ecx,%esi
  800d7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 28                	jle    800dad <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800da8:	e8 02 f5 ff ff       	call   8002af <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dad:	83 c4 2c             	add    $0x2c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 d3                	mov    %edx,%ebx
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 d6                	mov    %edx,%esi
  800dcd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_yield>:

void
sys_yield(void)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dda:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de4:	89 d1                	mov    %edx,%ecx
  800de6:	89 d3                	mov    %edx,%ebx
  800de8:	89 d7                	mov    %edx,%edi
  800dea:	89 d6                	mov    %edx,%esi
  800dec:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dfc:	be 00 00 00 00       	mov    $0x0,%esi
  800e01:	b8 04 00 00 00       	mov    $0x4,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	89 f7                	mov    %esi,%edi
  800e11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7e 28                	jle    800e3f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e22:	00 
  800e23:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800e3a:	e8 70 f4 ff ff       	call   8002af <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e3f:	83 c4 2c             	add    $0x2c,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e50:	b8 05 00 00 00       	mov    $0x5,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e61:	8b 75 18             	mov    0x18(%ebp),%esi
  800e64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800e8d:	e8 1d f4 ff ff       	call   8002af <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e92:	83 c4 2c             	add    $0x2c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800ee0:	e8 ca f3 ff ff       	call   8002af <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ee5:	83 c4 2c             	add    $0x2c,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 08 00 00 00       	mov    $0x8,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800f33:	e8 77 f3 ff ff       	call   8002af <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f38:	83 c4 2c             	add    $0x2c,%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 df                	mov    %ebx,%edi
  800f5b:	89 de                	mov    %ebx,%esi
  800f5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	7e 28                	jle    800f8b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f67:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800f86:	e8 24 f3 ff ff       	call   8002af <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f8b:	83 c4 2c             	add    $0x2c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	89 df                	mov    %ebx,%edi
  800fae:	89 de                	mov    %ebx,%esi
  800fb0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	7e 28                	jle    800fde <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fba:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800fd9:	e8 d1 f2 ff ff       	call   8002af <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fde:	83 c4 2c             	add    $0x2c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fec:	be 00 00 00 00       	mov    $0x0,%esi
  800ff1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fff:	8b 7d 14             	mov    0x14(%ebp),%edi
  801002:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801004:	5b                   	pop    %ebx
  801005:	5e                   	pop    %esi
  801006:	5f                   	pop    %edi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	57                   	push   %edi
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801012:	b9 00 00 00 00       	mov    $0x0,%ecx
  801017:	b8 0d 00 00 00       	mov    $0xd,%eax
  80101c:	8b 55 08             	mov    0x8(%ebp),%edx
  80101f:	89 cb                	mov    %ecx,%ebx
  801021:	89 cf                	mov    %ecx,%edi
  801023:	89 ce                	mov    %ecx,%esi
  801025:	cd 30                	int    $0x30
	if(check && ret > 0)
  801027:	85 c0                	test   %eax,%eax
  801029:	7e 28                	jle    801053 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801036:	00 
  801037:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  80103e:	00 
  80103f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801046:	00 
  801047:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  80104e:	e8 5c f2 ff ff       	call   8002af <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801053:	83 c4 2c             	add    $0x2c,%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    
  80105b:	66 90                	xchg   %ax,%ax
  80105d:	66 90                	xchg   %ax,%ax
  80105f:	90                   	nop

00801060 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
}
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80107b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801080:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801092:	89 c2                	mov    %eax,%edx
  801094:	c1 ea 16             	shr    $0x16,%edx
  801097:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109e:	f6 c2 01             	test   $0x1,%dl
  8010a1:	74 11                	je     8010b4 <fd_alloc+0x2d>
  8010a3:	89 c2                	mov    %eax,%edx
  8010a5:	c1 ea 0c             	shr    $0xc,%edx
  8010a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	75 09                	jne    8010bd <fd_alloc+0x36>
			*fd_store = fd;
  8010b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bb:	eb 17                	jmp    8010d4 <fd_alloc+0x4d>
  8010bd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c7:	75 c9                	jne    801092 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8010c9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010dc:	83 f8 1f             	cmp    $0x1f,%eax
  8010df:	77 36                	ja     801117 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010e1:	c1 e0 0c             	shl    $0xc,%eax
  8010e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e9:	89 c2                	mov    %eax,%edx
  8010eb:	c1 ea 16             	shr    $0x16,%edx
  8010ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f5:	f6 c2 01             	test   $0x1,%dl
  8010f8:	74 24                	je     80111e <fd_lookup+0x48>
  8010fa:	89 c2                	mov    %eax,%edx
  8010fc:	c1 ea 0c             	shr    $0xc,%edx
  8010ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801106:	f6 c2 01             	test   $0x1,%dl
  801109:	74 1a                	je     801125 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80110b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110e:	89 02                	mov    %eax,(%edx)
	return 0;
  801110:	b8 00 00 00 00       	mov    $0x0,%eax
  801115:	eb 13                	jmp    80112a <fd_lookup+0x54>
		return -E_INVAL;
  801117:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111c:	eb 0c                	jmp    80112a <fd_lookup+0x54>
		return -E_INVAL;
  80111e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801123:	eb 05                	jmp    80112a <fd_lookup+0x54>
  801125:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 18             	sub    $0x18,%esp
  801132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801135:	ba 2c 26 80 00       	mov    $0x80262c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80113a:	eb 13                	jmp    80114f <dev_lookup+0x23>
  80113c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80113f:	39 08                	cmp    %ecx,(%eax)
  801141:	75 0c                	jne    80114f <dev_lookup+0x23>
			*dev = devtab[i];
  801143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801146:	89 01                	mov    %eax,(%ecx)
			return 0;
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
  80114d:	eb 30                	jmp    80117f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80114f:	8b 02                	mov    (%edx),%eax
  801151:	85 c0                	test   %eax,%eax
  801153:	75 e7                	jne    80113c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801155:	a1 08 40 80 00       	mov    0x804008,%eax
  80115a:	8b 40 48             	mov    0x48(%eax),%eax
  80115d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801161:	89 44 24 04          	mov    %eax,0x4(%esp)
  801165:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  80116c:	e8 37 f2 ff ff       	call   8003a8 <cprintf>
	*dev = 0;
  801171:	8b 45 0c             	mov    0xc(%ebp),%eax
  801174:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80117a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    

00801181 <fd_close>:
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	56                   	push   %esi
  801185:	53                   	push   %ebx
  801186:	83 ec 20             	sub    $0x20,%esp
  801189:	8b 75 08             	mov    0x8(%ebp),%esi
  80118c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80118f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801192:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801196:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80119c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	e8 2f ff ff ff       	call   8010d6 <fd_lookup>
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 05                	js     8011b0 <fd_close+0x2f>
	    || fd != fd2)
  8011ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ae:	74 0c                	je     8011bc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8011b0:	84 db                	test   %bl,%bl
  8011b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b7:	0f 44 c2             	cmove  %edx,%eax
  8011ba:	eb 3f                	jmp    8011fb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c3:	8b 06                	mov    (%esi),%eax
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 5f ff ff ff       	call   80112c <dev_lookup>
  8011cd:	89 c3                	mov    %eax,%ebx
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 16                	js     8011e9 <fd_close+0x68>
		if (dev->dev_close)
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	74 07                	je     8011e9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011e2:	89 34 24             	mov    %esi,(%esp)
  8011e5:	ff d0                	call   *%eax
  8011e7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8011e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f4:	e8 a1 fc ff ff       	call   800e9a <sys_page_unmap>
	return r;
  8011f9:	89 d8                	mov    %ebx,%eax
}
  8011fb:	83 c4 20             	add    $0x20,%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <close>:

int
close(int fdnum)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	89 04 24             	mov    %eax,(%esp)
  801215:	e8 bc fe ff ff       	call   8010d6 <fd_lookup>
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	85 d2                	test   %edx,%edx
  80121e:	78 13                	js     801233 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801220:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801227:	00 
  801228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122b:	89 04 24             	mov    %eax,(%esp)
  80122e:	e8 4e ff ff ff       	call   801181 <fd_close>
}
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <close_all>:

void
close_all(void)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	53                   	push   %ebx
  801239:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80123c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801241:	89 1c 24             	mov    %ebx,(%esp)
  801244:	e8 b9 ff ff ff       	call   801202 <close>
	for (i = 0; i < MAXFD; i++)
  801249:	83 c3 01             	add    $0x1,%ebx
  80124c:	83 fb 20             	cmp    $0x20,%ebx
  80124f:	75 f0                	jne    801241 <close_all+0xc>
}
  801251:	83 c4 14             	add    $0x14,%esp
  801254:	5b                   	pop    %ebx
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	57                   	push   %edi
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
  80125d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801260:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801263:	89 44 24 04          	mov    %eax,0x4(%esp)
  801267:	8b 45 08             	mov    0x8(%ebp),%eax
  80126a:	89 04 24             	mov    %eax,(%esp)
  80126d:	e8 64 fe ff ff       	call   8010d6 <fd_lookup>
  801272:	89 c2                	mov    %eax,%edx
  801274:	85 d2                	test   %edx,%edx
  801276:	0f 88 e1 00 00 00    	js     80135d <dup+0x106>
		return r;
	close(newfdnum);
  80127c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 7b ff ff ff       	call   801202 <close>

	newfd = INDEX2FD(newfdnum);
  801287:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80128a:	c1 e3 0c             	shl    $0xc,%ebx
  80128d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801296:	89 04 24             	mov    %eax,(%esp)
  801299:	e8 d2 fd ff ff       	call   801070 <fd2data>
  80129e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8012a0:	89 1c 24             	mov    %ebx,(%esp)
  8012a3:	e8 c8 fd ff ff       	call   801070 <fd2data>
  8012a8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012aa:	89 f0                	mov    %esi,%eax
  8012ac:	c1 e8 16             	shr    $0x16,%eax
  8012af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b6:	a8 01                	test   $0x1,%al
  8012b8:	74 43                	je     8012fd <dup+0xa6>
  8012ba:	89 f0                	mov    %esi,%eax
  8012bc:	c1 e8 0c             	shr    $0xc,%eax
  8012bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c6:	f6 c2 01             	test   $0x1,%dl
  8012c9:	74 32                	je     8012fd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012e6:	00 
  8012e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f2:	e8 50 fb ff ff       	call   800e47 <sys_page_map>
  8012f7:	89 c6                	mov    %eax,%esi
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 3e                	js     80133b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801300:	89 c2                	mov    %eax,%edx
  801302:	c1 ea 0c             	shr    $0xc,%edx
  801305:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801312:	89 54 24 10          	mov    %edx,0x10(%esp)
  801316:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80131a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801321:	00 
  801322:	89 44 24 04          	mov    %eax,0x4(%esp)
  801326:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132d:	e8 15 fb ff ff       	call   800e47 <sys_page_map>
  801332:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801334:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801337:	85 f6                	test   %esi,%esi
  801339:	79 22                	jns    80135d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80133b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80133f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801346:	e8 4f fb ff ff       	call   800e9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80134b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80134f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801356:	e8 3f fb ff ff       	call   800e9a <sys_page_unmap>
	return r;
  80135b:	89 f0                	mov    %esi,%eax
}
  80135d:	83 c4 3c             	add    $0x3c,%esp
  801360:	5b                   	pop    %ebx
  801361:	5e                   	pop    %esi
  801362:	5f                   	pop    %edi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	53                   	push   %ebx
  801369:	83 ec 24             	sub    $0x24,%esp
  80136c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801372:	89 44 24 04          	mov    %eax,0x4(%esp)
  801376:	89 1c 24             	mov    %ebx,(%esp)
  801379:	e8 58 fd ff ff       	call   8010d6 <fd_lookup>
  80137e:	89 c2                	mov    %eax,%edx
  801380:	85 d2                	test   %edx,%edx
  801382:	78 6d                	js     8013f1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801384:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138e:	8b 00                	mov    (%eax),%eax
  801390:	89 04 24             	mov    %eax,(%esp)
  801393:	e8 94 fd ff ff       	call   80112c <dev_lookup>
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 55                	js     8013f1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80139c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139f:	8b 50 08             	mov    0x8(%eax),%edx
  8013a2:	83 e2 03             	and    $0x3,%edx
  8013a5:	83 fa 01             	cmp    $0x1,%edx
  8013a8:	75 23                	jne    8013cd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8013af:	8b 40 48             	mov    0x48(%eax),%eax
  8013b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ba:	c7 04 24 f0 25 80 00 	movl   $0x8025f0,(%esp)
  8013c1:	e8 e2 ef ff ff       	call   8003a8 <cprintf>
		return -E_INVAL;
  8013c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cb:	eb 24                	jmp    8013f1 <read+0x8c>
	}
	if (!dev->dev_read)
  8013cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d0:	8b 52 08             	mov    0x8(%edx),%edx
  8013d3:	85 d2                	test   %edx,%edx
  8013d5:	74 15                	je     8013ec <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013e5:	89 04 24             	mov    %eax,(%esp)
  8013e8:	ff d2                	call   *%edx
  8013ea:	eb 05                	jmp    8013f1 <read+0x8c>
		return -E_NOT_SUPP;
  8013ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013f1:	83 c4 24             	add    $0x24,%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	57                   	push   %edi
  8013fb:	56                   	push   %esi
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 1c             	sub    $0x1c,%esp
  801400:	8b 7d 08             	mov    0x8(%ebp),%edi
  801403:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140b:	eb 23                	jmp    801430 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80140d:	89 f0                	mov    %esi,%eax
  80140f:	29 d8                	sub    %ebx,%eax
  801411:	89 44 24 08          	mov    %eax,0x8(%esp)
  801415:	89 d8                	mov    %ebx,%eax
  801417:	03 45 0c             	add    0xc(%ebp),%eax
  80141a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141e:	89 3c 24             	mov    %edi,(%esp)
  801421:	e8 3f ff ff ff       	call   801365 <read>
		if (m < 0)
  801426:	85 c0                	test   %eax,%eax
  801428:	78 10                	js     80143a <readn+0x43>
			return m;
		if (m == 0)
  80142a:	85 c0                	test   %eax,%eax
  80142c:	74 0a                	je     801438 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80142e:	01 c3                	add    %eax,%ebx
  801430:	39 f3                	cmp    %esi,%ebx
  801432:	72 d9                	jb     80140d <readn+0x16>
  801434:	89 d8                	mov    %ebx,%eax
  801436:	eb 02                	jmp    80143a <readn+0x43>
  801438:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80143a:	83 c4 1c             	add    $0x1c,%esp
  80143d:	5b                   	pop    %ebx
  80143e:	5e                   	pop    %esi
  80143f:	5f                   	pop    %edi
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	83 ec 24             	sub    $0x24,%esp
  801449:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801453:	89 1c 24             	mov    %ebx,(%esp)
  801456:	e8 7b fc ff ff       	call   8010d6 <fd_lookup>
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	85 d2                	test   %edx,%edx
  80145f:	78 68                	js     8014c9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801461:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146b:	8b 00                	mov    (%eax),%eax
  80146d:	89 04 24             	mov    %eax,(%esp)
  801470:	e8 b7 fc ff ff       	call   80112c <dev_lookup>
  801475:	85 c0                	test   %eax,%eax
  801477:	78 50                	js     8014c9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801479:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801480:	75 23                	jne    8014a5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801482:	a1 08 40 80 00       	mov    0x804008,%eax
  801487:	8b 40 48             	mov    0x48(%eax),%eax
  80148a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80148e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801492:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  801499:	e8 0a ef ff ff       	call   8003a8 <cprintf>
		return -E_INVAL;
  80149e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a3:	eb 24                	jmp    8014c9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	74 15                	je     8014c4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014af:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014bd:	89 04 24             	mov    %eax,(%esp)
  8014c0:	ff d2                	call   *%edx
  8014c2:	eb 05                	jmp    8014c9 <write+0x87>
		return -E_NOT_SUPP;
  8014c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014c9:	83 c4 24             	add    $0x24,%esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    

008014cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	89 04 24             	mov    %eax,(%esp)
  8014e2:	e8 ef fb ff ff       	call   8010d6 <fd_lookup>
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 0e                	js     8014f9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 24             	sub    $0x24,%esp
  801502:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801505:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150c:	89 1c 24             	mov    %ebx,(%esp)
  80150f:	e8 c2 fb ff ff       	call   8010d6 <fd_lookup>
  801514:	89 c2                	mov    %eax,%edx
  801516:	85 d2                	test   %edx,%edx
  801518:	78 61                	js     80157b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801524:	8b 00                	mov    (%eax),%eax
  801526:	89 04 24             	mov    %eax,(%esp)
  801529:	e8 fe fb ff ff       	call   80112c <dev_lookup>
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 49                	js     80157b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801535:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801539:	75 23                	jne    80155e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80153b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801540:	8b 40 48             	mov    0x48(%eax),%eax
  801543:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  801552:	e8 51 ee ff ff       	call   8003a8 <cprintf>
		return -E_INVAL;
  801557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155c:	eb 1d                	jmp    80157b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801561:	8b 52 18             	mov    0x18(%edx),%edx
  801564:	85 d2                	test   %edx,%edx
  801566:	74 0e                	je     801576 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801568:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80156b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80156f:	89 04 24             	mov    %eax,(%esp)
  801572:	ff d2                	call   *%edx
  801574:	eb 05                	jmp    80157b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801576:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80157b:	83 c4 24             	add    $0x24,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	53                   	push   %ebx
  801585:	83 ec 24             	sub    $0x24,%esp
  801588:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	e8 39 fb ff ff       	call   8010d6 <fd_lookup>
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 d2                	test   %edx,%edx
  8015a1:	78 52                	js     8015f5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	8b 00                	mov    (%eax),%eax
  8015af:	89 04 24             	mov    %eax,(%esp)
  8015b2:	e8 75 fb ff ff       	call   80112c <dev_lookup>
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 3a                	js     8015f5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c2:	74 2c                	je     8015f0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ce:	00 00 00 
	stat->st_isdir = 0;
  8015d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d8:	00 00 00 
	stat->st_dev = dev;
  8015db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e8:	89 14 24             	mov    %edx,(%esp)
  8015eb:	ff 50 14             	call   *0x14(%eax)
  8015ee:	eb 05                	jmp    8015f5 <fstat+0x74>
		return -E_NOT_SUPP;
  8015f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015f5:	83 c4 24             	add    $0x24,%esp
  8015f8:	5b                   	pop    %ebx
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    

008015fb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	56                   	push   %esi
  8015ff:	53                   	push   %ebx
  801600:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801603:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80160a:	00 
  80160b:	8b 45 08             	mov    0x8(%ebp),%eax
  80160e:	89 04 24             	mov    %eax,(%esp)
  801611:	e8 fb 01 00 00       	call   801811 <open>
  801616:	89 c3                	mov    %eax,%ebx
  801618:	85 db                	test   %ebx,%ebx
  80161a:	78 1b                	js     801637 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80161c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	89 1c 24             	mov    %ebx,(%esp)
  801626:	e8 56 ff ff ff       	call   801581 <fstat>
  80162b:	89 c6                	mov    %eax,%esi
	close(fd);
  80162d:	89 1c 24             	mov    %ebx,(%esp)
  801630:	e8 cd fb ff ff       	call   801202 <close>
	return r;
  801635:	89 f0                	mov    %esi,%eax
}
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	83 ec 10             	sub    $0x10,%esp
  801646:	89 c6                	mov    %eax,%esi
  801648:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80164a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801651:	75 11                	jne    801664 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801653:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80165a:	e8 50 08 00 00       	call   801eaf <ipc_find_env>
  80165f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801664:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80166b:	00 
  80166c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801673:	00 
  801674:	89 74 24 04          	mov    %esi,0x4(%esp)
  801678:	a1 04 40 80 00       	mov    0x804004,%eax
  80167d:	89 04 24             	mov    %eax,(%esp)
  801680:	e8 c3 07 00 00       	call   801e48 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801685:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80168c:	00 
  80168d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801691:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801698:	e8 43 07 00 00       	call   801de0 <ipc_recv>
}
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	5b                   	pop    %ebx
  8016a1:	5e                   	pop    %esi
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c7:	e8 72 ff ff ff       	call   80163e <fsipc>
}
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devfile_flush>:
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016da:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016df:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e9:	e8 50 ff ff ff       	call   80163e <fsipc>
}
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devfile_stat>:
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 14             	sub    $0x14,%esp
  8016f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801700:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 05 00 00 00       	mov    $0x5,%eax
  80170f:	e8 2a ff ff ff       	call   80163e <fsipc>
  801714:	89 c2                	mov    %eax,%edx
  801716:	85 d2                	test   %edx,%edx
  801718:	78 2b                	js     801745 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80171a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801721:	00 
  801722:	89 1c 24             	mov    %ebx,(%esp)
  801725:	e8 ad f2 ff ff       	call   8009d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80172a:	a1 80 50 80 00       	mov    0x805080,%eax
  80172f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801735:	a1 84 50 80 00       	mov    0x805084,%eax
  80173a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801740:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801745:	83 c4 14             	add    $0x14,%esp
  801748:	5b                   	pop    %ebx
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <devfile_write>:
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801751:	c7 44 24 08 3c 26 80 	movl   $0x80263c,0x8(%esp)
  801758:	00 
  801759:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801760:	00 
  801761:	c7 04 24 5a 26 80 00 	movl   $0x80265a,(%esp)
  801768:	e8 42 eb ff ff       	call   8002af <_panic>

0080176d <devfile_read>:
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	56                   	push   %esi
  801771:	53                   	push   %ebx
  801772:	83 ec 10             	sub    $0x10,%esp
  801775:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8b 40 0c             	mov    0xc(%eax),%eax
  80177e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801783:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 03 00 00 00       	mov    $0x3,%eax
  801793:	e8 a6 fe ff ff       	call   80163e <fsipc>
  801798:	89 c3                	mov    %eax,%ebx
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 6a                	js     801808 <devfile_read+0x9b>
	assert(r <= n);
  80179e:	39 c6                	cmp    %eax,%esi
  8017a0:	73 24                	jae    8017c6 <devfile_read+0x59>
  8017a2:	c7 44 24 0c 65 26 80 	movl   $0x802665,0xc(%esp)
  8017a9:	00 
  8017aa:	c7 44 24 08 6c 26 80 	movl   $0x80266c,0x8(%esp)
  8017b1:	00 
  8017b2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017b9:	00 
  8017ba:	c7 04 24 5a 26 80 00 	movl   $0x80265a,(%esp)
  8017c1:	e8 e9 ea ff ff       	call   8002af <_panic>
	assert(r <= PGSIZE);
  8017c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017cb:	7e 24                	jle    8017f1 <devfile_read+0x84>
  8017cd:	c7 44 24 0c 81 26 80 	movl   $0x802681,0xc(%esp)
  8017d4:	00 
  8017d5:	c7 44 24 08 6c 26 80 	movl   $0x80266c,0x8(%esp)
  8017dc:	00 
  8017dd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017e4:	00 
  8017e5:	c7 04 24 5a 26 80 00 	movl   $0x80265a,(%esp)
  8017ec:	e8 be ea ff ff       	call   8002af <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017fc:	00 
  8017fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801800:	89 04 24             	mov    %eax,(%esp)
  801803:	e8 6c f3 ff ff       	call   800b74 <memmove>
}
  801808:	89 d8                	mov    %ebx,%eax
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	5b                   	pop    %ebx
  80180e:	5e                   	pop    %esi
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <open>:
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	53                   	push   %ebx
  801815:	83 ec 24             	sub    $0x24,%esp
  801818:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80181b:	89 1c 24             	mov    %ebx,(%esp)
  80181e:	e8 7d f1 ff ff       	call   8009a0 <strlen>
  801823:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801828:	7f 60                	jg     80188a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80182a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182d:	89 04 24             	mov    %eax,(%esp)
  801830:	e8 52 f8 ff ff       	call   801087 <fd_alloc>
  801835:	89 c2                	mov    %eax,%edx
  801837:	85 d2                	test   %edx,%edx
  801839:	78 54                	js     80188f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80183b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801846:	e8 8c f1 ff ff       	call   8009d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801853:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801856:	b8 01 00 00 00       	mov    $0x1,%eax
  80185b:	e8 de fd ff ff       	call   80163e <fsipc>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	85 c0                	test   %eax,%eax
  801864:	79 17                	jns    80187d <open+0x6c>
		fd_close(fd, 0);
  801866:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80186d:	00 
  80186e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801871:	89 04 24             	mov    %eax,(%esp)
  801874:	e8 08 f9 ff ff       	call   801181 <fd_close>
		return r;
  801879:	89 d8                	mov    %ebx,%eax
  80187b:	eb 12                	jmp    80188f <open+0x7e>
	return fd2num(fd);
  80187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801880:	89 04 24             	mov    %eax,(%esp)
  801883:	e8 d8 f7 ff ff       	call   801060 <fd2num>
  801888:	eb 05                	jmp    80188f <open+0x7e>
		return -E_BAD_PATH;
  80188a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80188f:	83 c4 24             	add    $0x24,%esp
  801892:	5b                   	pop    %ebx
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a5:	e8 94 fd ff ff       	call   80163e <fsipc>
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	83 ec 10             	sub    $0x10,%esp
  8018b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ba:	89 04 24             	mov    %eax,(%esp)
  8018bd:	e8 ae f7 ff ff       	call   801070 <fd2data>
  8018c2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c4:	c7 44 24 04 8d 26 80 	movl   $0x80268d,0x4(%esp)
  8018cb:	00 
  8018cc:	89 1c 24             	mov    %ebx,(%esp)
  8018cf:	e8 03 f1 ff ff       	call   8009d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d4:	8b 46 04             	mov    0x4(%esi),%eax
  8018d7:	2b 06                	sub    (%esi),%eax
  8018d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018df:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e6:	00 00 00 
	stat->st_dev = &devpipe;
  8018e9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018f0:	30 80 00 
	return 0;
}
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	5b                   	pop    %ebx
  8018fc:	5e                   	pop    %esi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	53                   	push   %ebx
  801903:	83 ec 14             	sub    $0x14,%esp
  801906:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801909:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80190d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801914:	e8 81 f5 ff ff       	call   800e9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801919:	89 1c 24             	mov    %ebx,(%esp)
  80191c:	e8 4f f7 ff ff       	call   801070 <fd2data>
  801921:	89 44 24 04          	mov    %eax,0x4(%esp)
  801925:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192c:	e8 69 f5 ff ff       	call   800e9a <sys_page_unmap>
}
  801931:	83 c4 14             	add    $0x14,%esp
  801934:	5b                   	pop    %ebx
  801935:	5d                   	pop    %ebp
  801936:	c3                   	ret    

00801937 <_pipeisclosed>:
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	57                   	push   %edi
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	83 ec 2c             	sub    $0x2c,%esp
  801940:	89 c6                	mov    %eax,%esi
  801942:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801945:	a1 08 40 80 00       	mov    0x804008,%eax
  80194a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80194d:	89 34 24             	mov    %esi,(%esp)
  801950:	e8 92 05 00 00       	call   801ee7 <pageref>
  801955:	89 c7                	mov    %eax,%edi
  801957:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80195a:	89 04 24             	mov    %eax,(%esp)
  80195d:	e8 85 05 00 00       	call   801ee7 <pageref>
  801962:	39 c7                	cmp    %eax,%edi
  801964:	0f 94 c2             	sete   %dl
  801967:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80196a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801970:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801973:	39 fb                	cmp    %edi,%ebx
  801975:	74 21                	je     801998 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801977:	84 d2                	test   %dl,%dl
  801979:	74 ca                	je     801945 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80197b:	8b 51 58             	mov    0x58(%ecx),%edx
  80197e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801982:	89 54 24 08          	mov    %edx,0x8(%esp)
  801986:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198a:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  801991:	e8 12 ea ff ff       	call   8003a8 <cprintf>
  801996:	eb ad                	jmp    801945 <_pipeisclosed+0xe>
}
  801998:	83 c4 2c             	add    $0x2c,%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5e                   	pop    %esi
  80199d:	5f                   	pop    %edi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <devpipe_write>:
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	57                   	push   %edi
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 1c             	sub    $0x1c,%esp
  8019a9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019ac:	89 34 24             	mov    %esi,(%esp)
  8019af:	e8 bc f6 ff ff       	call   801070 <fd2data>
  8019b4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8019bb:	eb 45                	jmp    801a02 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  8019bd:	89 da                	mov    %ebx,%edx
  8019bf:	89 f0                	mov    %esi,%eax
  8019c1:	e8 71 ff ff ff       	call   801937 <_pipeisclosed>
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	75 41                	jne    801a0b <devpipe_write+0x6b>
			sys_yield();
  8019ca:	e8 05 f4 ff ff       	call   800dd4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019cf:	8b 43 04             	mov    0x4(%ebx),%eax
  8019d2:	8b 0b                	mov    (%ebx),%ecx
  8019d4:	8d 51 20             	lea    0x20(%ecx),%edx
  8019d7:	39 d0                	cmp    %edx,%eax
  8019d9:	73 e2                	jae    8019bd <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019de:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019e2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019e5:	99                   	cltd   
  8019e6:	c1 ea 1b             	shr    $0x1b,%edx
  8019e9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8019ec:	83 e1 1f             	and    $0x1f,%ecx
  8019ef:	29 d1                	sub    %edx,%ecx
  8019f1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8019f5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8019f9:	83 c0 01             	add    $0x1,%eax
  8019fc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019ff:	83 c7 01             	add    $0x1,%edi
  801a02:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a05:	75 c8                	jne    8019cf <devpipe_write+0x2f>
	return i;
  801a07:	89 f8                	mov    %edi,%eax
  801a09:	eb 05                	jmp    801a10 <devpipe_write+0x70>
				return 0;
  801a0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a10:	83 c4 1c             	add    $0x1c,%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5e                   	pop    %esi
  801a15:	5f                   	pop    %edi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <devpipe_read>:
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	57                   	push   %edi
  801a1c:	56                   	push   %esi
  801a1d:	53                   	push   %ebx
  801a1e:	83 ec 1c             	sub    $0x1c,%esp
  801a21:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a24:	89 3c 24             	mov    %edi,(%esp)
  801a27:	e8 44 f6 ff ff       	call   801070 <fd2data>
  801a2c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a2e:	be 00 00 00 00       	mov    $0x0,%esi
  801a33:	eb 3d                	jmp    801a72 <devpipe_read+0x5a>
			if (i > 0)
  801a35:	85 f6                	test   %esi,%esi
  801a37:	74 04                	je     801a3d <devpipe_read+0x25>
				return i;
  801a39:	89 f0                	mov    %esi,%eax
  801a3b:	eb 43                	jmp    801a80 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801a3d:	89 da                	mov    %ebx,%edx
  801a3f:	89 f8                	mov    %edi,%eax
  801a41:	e8 f1 fe ff ff       	call   801937 <_pipeisclosed>
  801a46:	85 c0                	test   %eax,%eax
  801a48:	75 31                	jne    801a7b <devpipe_read+0x63>
			sys_yield();
  801a4a:	e8 85 f3 ff ff       	call   800dd4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a4f:	8b 03                	mov    (%ebx),%eax
  801a51:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a54:	74 df                	je     801a35 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a56:	99                   	cltd   
  801a57:	c1 ea 1b             	shr    $0x1b,%edx
  801a5a:	01 d0                	add    %edx,%eax
  801a5c:	83 e0 1f             	and    $0x1f,%eax
  801a5f:	29 d0                	sub    %edx,%eax
  801a61:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a69:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a6c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a6f:	83 c6 01             	add    $0x1,%esi
  801a72:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a75:	75 d8                	jne    801a4f <devpipe_read+0x37>
	return i;
  801a77:	89 f0                	mov    %esi,%eax
  801a79:	eb 05                	jmp    801a80 <devpipe_read+0x68>
				return 0;
  801a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a80:	83 c4 1c             	add    $0x1c,%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5e                   	pop    %esi
  801a85:	5f                   	pop    %edi
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <pipe>:
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a93:	89 04 24             	mov    %eax,(%esp)
  801a96:	e8 ec f5 ff ff       	call   801087 <fd_alloc>
  801a9b:	89 c2                	mov    %eax,%edx
  801a9d:	85 d2                	test   %edx,%edx
  801a9f:	0f 88 4d 01 00 00    	js     801bf2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aac:	00 
  801aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abb:	e8 33 f3 ff ff       	call   800df3 <sys_page_alloc>
  801ac0:	89 c2                	mov    %eax,%edx
  801ac2:	85 d2                	test   %edx,%edx
  801ac4:	0f 88 28 01 00 00    	js     801bf2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801aca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801acd:	89 04 24             	mov    %eax,(%esp)
  801ad0:	e8 b2 f5 ff ff       	call   801087 <fd_alloc>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	0f 88 fe 00 00 00    	js     801bdd <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801adf:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ae6:	00 
  801ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af5:	e8 f9 f2 ff ff       	call   800df3 <sys_page_alloc>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	85 c0                	test   %eax,%eax
  801afe:	0f 88 d9 00 00 00    	js     801bdd <pipe+0x155>
	va = fd2data(fd0);
  801b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 61 f5 ff ff       	call   801070 <fd2data>
  801b0f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b11:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b18:	00 
  801b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b24:	e8 ca f2 ff ff       	call   800df3 <sys_page_alloc>
  801b29:	89 c3                	mov    %eax,%ebx
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	0f 88 97 00 00 00    	js     801bca <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b36:	89 04 24             	mov    %eax,(%esp)
  801b39:	e8 32 f5 ff ff       	call   801070 <fd2data>
  801b3e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b45:	00 
  801b46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b51:	00 
  801b52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5d:	e8 e5 f2 ff ff       	call   800e47 <sys_page_map>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 52                	js     801bba <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801b68:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b71:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b7d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b86:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b95:	89 04 24             	mov    %eax,(%esp)
  801b98:	e8 c3 f4 ff ff       	call   801060 <fd2num>
  801b9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba5:	89 04 24             	mov    %eax,(%esp)
  801ba8:	e8 b3 f4 ff ff       	call   801060 <fd2num>
  801bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb8:	eb 38                	jmp    801bf2 <pipe+0x16a>
	sys_page_unmap(0, va);
  801bba:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc5:	e8 d0 f2 ff ff       	call   800e9a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd8:	e8 bd f2 ff ff       	call   800e9a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801beb:	e8 aa f2 ff ff       	call   800e9a <sys_page_unmap>
  801bf0:	89 d8                	mov    %ebx,%eax
}
  801bf2:	83 c4 30             	add    $0x30,%esp
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <pipeisclosed>:
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c06:	8b 45 08             	mov    0x8(%ebp),%eax
  801c09:	89 04 24             	mov    %eax,(%esp)
  801c0c:	e8 c5 f4 ff ff       	call   8010d6 <fd_lookup>
  801c11:	89 c2                	mov    %eax,%edx
  801c13:	85 d2                	test   %edx,%edx
  801c15:	78 15                	js     801c2c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1a:	89 04 24             	mov    %eax,(%esp)
  801c1d:	e8 4e f4 ff ff       	call   801070 <fd2data>
	return _pipeisclosed(fd, p);
  801c22:	89 c2                	mov    %eax,%edx
  801c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c27:	e8 0b fd ff ff       	call   801937 <_pipeisclosed>
}
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c40:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  801c47:	00 
  801c48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4b:	89 04 24             	mov    %eax,(%esp)
  801c4e:	e8 84 ed ff ff       	call   8009d7 <strcpy>
	return 0;
}
  801c53:	b8 00 00 00 00       	mov    $0x0,%eax
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <devcons_write>:
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	57                   	push   %edi
  801c5e:	56                   	push   %esi
  801c5f:	53                   	push   %ebx
  801c60:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c66:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c6b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c71:	eb 31                	jmp    801ca4 <devcons_write+0x4a>
		m = n - tot;
  801c73:	8b 75 10             	mov    0x10(%ebp),%esi
  801c76:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801c78:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801c7b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c80:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c83:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c87:	03 45 0c             	add    0xc(%ebp),%eax
  801c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8e:	89 3c 24             	mov    %edi,(%esp)
  801c91:	e8 de ee ff ff       	call   800b74 <memmove>
		sys_cputs(buf, m);
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	89 3c 24             	mov    %edi,(%esp)
  801c9d:	e8 84 f0 ff ff       	call   800d26 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ca2:	01 f3                	add    %esi,%ebx
  801ca4:	89 d8                	mov    %ebx,%eax
  801ca6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ca9:	72 c8                	jb     801c73 <devcons_write+0x19>
}
  801cab:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5f                   	pop    %edi
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    

00801cb6 <devcons_read>:
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cc5:	75 07                	jne    801cce <devcons_read+0x18>
  801cc7:	eb 2a                	jmp    801cf3 <devcons_read+0x3d>
		sys_yield();
  801cc9:	e8 06 f1 ff ff       	call   800dd4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801cce:	66 90                	xchg   %ax,%ax
  801cd0:	e8 6f f0 ff ff       	call   800d44 <sys_cgetc>
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	74 f0                	je     801cc9 <devcons_read+0x13>
	if (c < 0)
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	78 16                	js     801cf3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801cdd:	83 f8 04             	cmp    $0x4,%eax
  801ce0:	74 0c                	je     801cee <devcons_read+0x38>
	*(char*)vbuf = c;
  801ce2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce5:	88 02                	mov    %al,(%edx)
	return 1;
  801ce7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cec:	eb 05                	jmp    801cf3 <devcons_read+0x3d>
		return 0;
  801cee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <cputchar>:
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d08:	00 
  801d09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d0c:	89 04 24             	mov    %eax,(%esp)
  801d0f:	e8 12 f0 ff ff       	call   800d26 <sys_cputs>
}
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <getchar>:
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801d1c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d23:	00 
  801d24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d32:	e8 2e f6 ff ff       	call   801365 <read>
	if (r < 0)
  801d37:	85 c0                	test   %eax,%eax
  801d39:	78 0f                	js     801d4a <getchar+0x34>
	if (r < 1)
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	7e 06                	jle    801d45 <getchar+0x2f>
	return c;
  801d3f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d43:	eb 05                	jmp    801d4a <getchar+0x34>
		return -E_EOF;
  801d45:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <iscons>:
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	89 04 24             	mov    %eax,(%esp)
  801d5f:	e8 72 f3 ff ff       	call   8010d6 <fd_lookup>
  801d64:	85 c0                	test   %eax,%eax
  801d66:	78 11                	js     801d79 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d71:	39 10                	cmp    %edx,(%eax)
  801d73:	0f 94 c0             	sete   %al
  801d76:	0f b6 c0             	movzbl %al,%eax
}
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <opencons>:
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d84:	89 04 24             	mov    %eax,(%esp)
  801d87:	e8 fb f2 ff ff       	call   801087 <fd_alloc>
		return r;
  801d8c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 40                	js     801dd2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d99:	00 
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da8:	e8 46 f0 ff ff       	call   800df3 <sys_page_alloc>
		return r;
  801dad:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 1f                	js     801dd2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801db3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dc8:	89 04 24             	mov    %eax,(%esp)
  801dcb:	e8 90 f2 ff ff       	call   801060 <fd2num>
  801dd0:	89 c2                	mov    %eax,%edx
}
  801dd2:	89 d0                	mov    %edx,%eax
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    
  801dd6:	66 90                	xchg   %ax,%ax
  801dd8:	66 90                	xchg   %ax,%ax
  801dda:	66 90                	xchg   %ax,%ax
  801ddc:	66 90                	xchg   %ax,%ax
  801dde:	66 90                	xchg   %ax,%ax

00801de0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
  801de5:	83 ec 10             	sub    $0x10,%esp
  801de8:	8b 75 08             	mov    0x8(%ebp),%esi
  801deb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801df1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801df3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801df8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801dfb:	89 04 24             	mov    %eax,(%esp)
  801dfe:	e8 06 f2 ff ff       	call   801009 <sys_ipc_recv>
    if(r < 0){
  801e03:	85 c0                	test   %eax,%eax
  801e05:	79 16                	jns    801e1d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801e07:	85 f6                	test   %esi,%esi
  801e09:	74 06                	je     801e11 <ipc_recv+0x31>
            *from_env_store = 0;
  801e0b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801e11:	85 db                	test   %ebx,%ebx
  801e13:	74 2c                	je     801e41 <ipc_recv+0x61>
            *perm_store = 0;
  801e15:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e1b:	eb 24                	jmp    801e41 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801e1d:	85 f6                	test   %esi,%esi
  801e1f:	74 0a                	je     801e2b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801e21:	a1 08 40 80 00       	mov    0x804008,%eax
  801e26:	8b 40 74             	mov    0x74(%eax),%eax
  801e29:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801e2b:	85 db                	test   %ebx,%ebx
  801e2d:	74 0a                	je     801e39 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801e2f:	a1 08 40 80 00       	mov    0x804008,%eax
  801e34:	8b 40 78             	mov    0x78(%eax),%eax
  801e37:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e39:	a1 08 40 80 00       	mov    0x804008,%eax
  801e3e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	57                   	push   %edi
  801e4c:	56                   	push   %esi
  801e4d:	53                   	push   %ebx
  801e4e:	83 ec 1c             	sub    $0x1c,%esp
  801e51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801e5a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801e5c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801e61:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801e64:	8b 45 14             	mov    0x14(%ebp),%eax
  801e67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e6b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e73:	89 3c 24             	mov    %edi,(%esp)
  801e76:	e8 6b f1 ff ff       	call   800fe6 <sys_ipc_try_send>
        if(r == 0){
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	74 28                	je     801ea7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801e7f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e82:	74 1c                	je     801ea0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801e84:	c7 44 24 08 b8 26 80 	movl   $0x8026b8,0x8(%esp)
  801e8b:	00 
  801e8c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801e93:	00 
  801e94:	c7 04 24 cf 26 80 00 	movl   $0x8026cf,(%esp)
  801e9b:	e8 0f e4 ff ff       	call   8002af <_panic>
        }
        sys_yield();
  801ea0:	e8 2f ef ff ff       	call   800dd4 <sys_yield>
    }
  801ea5:	eb bd                	jmp    801e64 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801ea7:	83 c4 1c             	add    $0x1c,%esp
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5f                   	pop    %edi
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eb5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ebd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec3:	8b 52 50             	mov    0x50(%edx),%edx
  801ec6:	39 ca                	cmp    %ecx,%edx
  801ec8:	75 0d                	jne    801ed7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801eca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ecd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ed2:	8b 40 40             	mov    0x40(%eax),%eax
  801ed5:	eb 0e                	jmp    801ee5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801ed7:	83 c0 01             	add    $0x1,%eax
  801eda:	3d 00 04 00 00       	cmp    $0x400,%eax
  801edf:	75 d9                	jne    801eba <ipc_find_env+0xb>
	return 0;
  801ee1:	66 b8 00 00          	mov    $0x0,%ax
}
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eed:	89 d0                	mov    %edx,%eax
  801eef:	c1 e8 16             	shr    $0x16,%eax
  801ef2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801efe:	f6 c1 01             	test   $0x1,%cl
  801f01:	74 1d                	je     801f20 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f03:	c1 ea 0c             	shr    $0xc,%edx
  801f06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f0d:	f6 c2 01             	test   $0x1,%dl
  801f10:	74 0e                	je     801f20 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f12:	c1 ea 0c             	shr    $0xc,%edx
  801f15:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f1c:	ef 
  801f1d:	0f b7 c0             	movzwl %ax,%eax
}
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    
  801f22:	66 90                	xchg   %ax,%ax
  801f24:	66 90                	xchg   %ax,%ax
  801f26:	66 90                	xchg   %ax,%ax
  801f28:	66 90                	xchg   %ax,%ax
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	83 ec 0c             	sub    $0xc,%esp
  801f36:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801f3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801f42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f46:	85 c0                	test   %eax,%eax
  801f48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f4c:	89 ea                	mov    %ebp,%edx
  801f4e:	89 0c 24             	mov    %ecx,(%esp)
  801f51:	75 2d                	jne    801f80 <__udivdi3+0x50>
  801f53:	39 e9                	cmp    %ebp,%ecx
  801f55:	77 61                	ja     801fb8 <__udivdi3+0x88>
  801f57:	85 c9                	test   %ecx,%ecx
  801f59:	89 ce                	mov    %ecx,%esi
  801f5b:	75 0b                	jne    801f68 <__udivdi3+0x38>
  801f5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f62:	31 d2                	xor    %edx,%edx
  801f64:	f7 f1                	div    %ecx
  801f66:	89 c6                	mov    %eax,%esi
  801f68:	31 d2                	xor    %edx,%edx
  801f6a:	89 e8                	mov    %ebp,%eax
  801f6c:	f7 f6                	div    %esi
  801f6e:	89 c5                	mov    %eax,%ebp
  801f70:	89 f8                	mov    %edi,%eax
  801f72:	f7 f6                	div    %esi
  801f74:	89 ea                	mov    %ebp,%edx
  801f76:	83 c4 0c             	add    $0xc,%esp
  801f79:	5e                   	pop    %esi
  801f7a:	5f                   	pop    %edi
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    
  801f7d:	8d 76 00             	lea    0x0(%esi),%esi
  801f80:	39 e8                	cmp    %ebp,%eax
  801f82:	77 24                	ja     801fa8 <__udivdi3+0x78>
  801f84:	0f bd e8             	bsr    %eax,%ebp
  801f87:	83 f5 1f             	xor    $0x1f,%ebp
  801f8a:	75 3c                	jne    801fc8 <__udivdi3+0x98>
  801f8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f90:	39 34 24             	cmp    %esi,(%esp)
  801f93:	0f 86 9f 00 00 00    	jbe    802038 <__udivdi3+0x108>
  801f99:	39 d0                	cmp    %edx,%eax
  801f9b:	0f 82 97 00 00 00    	jb     802038 <__udivdi3+0x108>
  801fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	31 d2                	xor    %edx,%edx
  801faa:	31 c0                	xor    %eax,%eax
  801fac:	83 c4 0c             	add    $0xc,%esp
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    
  801fb3:	90                   	nop
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	89 f8                	mov    %edi,%eax
  801fba:	f7 f1                	div    %ecx
  801fbc:	31 d2                	xor    %edx,%edx
  801fbe:	83 c4 0c             	add    $0xc,%esp
  801fc1:	5e                   	pop    %esi
  801fc2:	5f                   	pop    %edi
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    
  801fc5:	8d 76 00             	lea    0x0(%esi),%esi
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	8b 3c 24             	mov    (%esp),%edi
  801fcd:	d3 e0                	shl    %cl,%eax
  801fcf:	89 c6                	mov    %eax,%esi
  801fd1:	b8 20 00 00 00       	mov    $0x20,%eax
  801fd6:	29 e8                	sub    %ebp,%eax
  801fd8:	89 c1                	mov    %eax,%ecx
  801fda:	d3 ef                	shr    %cl,%edi
  801fdc:	89 e9                	mov    %ebp,%ecx
  801fde:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801fe2:	8b 3c 24             	mov    (%esp),%edi
  801fe5:	09 74 24 08          	or     %esi,0x8(%esp)
  801fe9:	89 d6                	mov    %edx,%esi
  801feb:	d3 e7                	shl    %cl,%edi
  801fed:	89 c1                	mov    %eax,%ecx
  801fef:	89 3c 24             	mov    %edi,(%esp)
  801ff2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ff6:	d3 ee                	shr    %cl,%esi
  801ff8:	89 e9                	mov    %ebp,%ecx
  801ffa:	d3 e2                	shl    %cl,%edx
  801ffc:	89 c1                	mov    %eax,%ecx
  801ffe:	d3 ef                	shr    %cl,%edi
  802000:	09 d7                	or     %edx,%edi
  802002:	89 f2                	mov    %esi,%edx
  802004:	89 f8                	mov    %edi,%eax
  802006:	f7 74 24 08          	divl   0x8(%esp)
  80200a:	89 d6                	mov    %edx,%esi
  80200c:	89 c7                	mov    %eax,%edi
  80200e:	f7 24 24             	mull   (%esp)
  802011:	39 d6                	cmp    %edx,%esi
  802013:	89 14 24             	mov    %edx,(%esp)
  802016:	72 30                	jb     802048 <__udivdi3+0x118>
  802018:	8b 54 24 04          	mov    0x4(%esp),%edx
  80201c:	89 e9                	mov    %ebp,%ecx
  80201e:	d3 e2                	shl    %cl,%edx
  802020:	39 c2                	cmp    %eax,%edx
  802022:	73 05                	jae    802029 <__udivdi3+0xf9>
  802024:	3b 34 24             	cmp    (%esp),%esi
  802027:	74 1f                	je     802048 <__udivdi3+0x118>
  802029:	89 f8                	mov    %edi,%eax
  80202b:	31 d2                	xor    %edx,%edx
  80202d:	e9 7a ff ff ff       	jmp    801fac <__udivdi3+0x7c>
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 d2                	xor    %edx,%edx
  80203a:	b8 01 00 00 00       	mov    $0x1,%eax
  80203f:	e9 68 ff ff ff       	jmp    801fac <__udivdi3+0x7c>
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	8d 47 ff             	lea    -0x1(%edi),%eax
  80204b:	31 d2                	xor    %edx,%edx
  80204d:	83 c4 0c             	add    $0xc,%esp
  802050:	5e                   	pop    %esi
  802051:	5f                   	pop    %edi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	83 ec 14             	sub    $0x14,%esp
  802066:	8b 44 24 28          	mov    0x28(%esp),%eax
  80206a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80206e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802072:	89 c7                	mov    %eax,%edi
  802074:	89 44 24 04          	mov    %eax,0x4(%esp)
  802078:	8b 44 24 30          	mov    0x30(%esp),%eax
  80207c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802080:	89 34 24             	mov    %esi,(%esp)
  802083:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802087:	85 c0                	test   %eax,%eax
  802089:	89 c2                	mov    %eax,%edx
  80208b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80208f:	75 17                	jne    8020a8 <__umoddi3+0x48>
  802091:	39 fe                	cmp    %edi,%esi
  802093:	76 4b                	jbe    8020e0 <__umoddi3+0x80>
  802095:	89 c8                	mov    %ecx,%eax
  802097:	89 fa                	mov    %edi,%edx
  802099:	f7 f6                	div    %esi
  80209b:	89 d0                	mov    %edx,%eax
  80209d:	31 d2                	xor    %edx,%edx
  80209f:	83 c4 14             	add    $0x14,%esp
  8020a2:	5e                   	pop    %esi
  8020a3:	5f                   	pop    %edi
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	39 f8                	cmp    %edi,%eax
  8020aa:	77 54                	ja     802100 <__umoddi3+0xa0>
  8020ac:	0f bd e8             	bsr    %eax,%ebp
  8020af:	83 f5 1f             	xor    $0x1f,%ebp
  8020b2:	75 5c                	jne    802110 <__umoddi3+0xb0>
  8020b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8020b8:	39 3c 24             	cmp    %edi,(%esp)
  8020bb:	0f 87 e7 00 00 00    	ja     8021a8 <__umoddi3+0x148>
  8020c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020c5:	29 f1                	sub    %esi,%ecx
  8020c7:	19 c7                	sbb    %eax,%edi
  8020c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020d9:	83 c4 14             	add    $0x14,%esp
  8020dc:	5e                   	pop    %esi
  8020dd:	5f                   	pop    %edi
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    
  8020e0:	85 f6                	test   %esi,%esi
  8020e2:	89 f5                	mov    %esi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f6                	div    %esi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020f5:	31 d2                	xor    %edx,%edx
  8020f7:	f7 f5                	div    %ebp
  8020f9:	89 c8                	mov    %ecx,%eax
  8020fb:	f7 f5                	div    %ebp
  8020fd:	eb 9c                	jmp    80209b <__umoddi3+0x3b>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 fa                	mov    %edi,%edx
  802104:	83 c4 14             	add    $0x14,%esp
  802107:	5e                   	pop    %esi
  802108:	5f                   	pop    %edi
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    
  80210b:	90                   	nop
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 04 24             	mov    (%esp),%eax
  802113:	be 20 00 00 00       	mov    $0x20,%esi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ee                	sub    %ebp,%esi
  80211c:	d3 e2                	shl    %cl,%edx
  80211e:	89 f1                	mov    %esi,%ecx
  802120:	d3 e8                	shr    %cl,%eax
  802122:	89 e9                	mov    %ebp,%ecx
  802124:	89 44 24 04          	mov    %eax,0x4(%esp)
  802128:	8b 04 24             	mov    (%esp),%eax
  80212b:	09 54 24 04          	or     %edx,0x4(%esp)
  80212f:	89 fa                	mov    %edi,%edx
  802131:	d3 e0                	shl    %cl,%eax
  802133:	89 f1                	mov    %esi,%ecx
  802135:	89 44 24 08          	mov    %eax,0x8(%esp)
  802139:	8b 44 24 10          	mov    0x10(%esp),%eax
  80213d:	d3 ea                	shr    %cl,%edx
  80213f:	89 e9                	mov    %ebp,%ecx
  802141:	d3 e7                	shl    %cl,%edi
  802143:	89 f1                	mov    %esi,%ecx
  802145:	d3 e8                	shr    %cl,%eax
  802147:	89 e9                	mov    %ebp,%ecx
  802149:	09 f8                	or     %edi,%eax
  80214b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80214f:	f7 74 24 04          	divl   0x4(%esp)
  802153:	d3 e7                	shl    %cl,%edi
  802155:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802159:	89 d7                	mov    %edx,%edi
  80215b:	f7 64 24 08          	mull   0x8(%esp)
  80215f:	39 d7                	cmp    %edx,%edi
  802161:	89 c1                	mov    %eax,%ecx
  802163:	89 14 24             	mov    %edx,(%esp)
  802166:	72 2c                	jb     802194 <__umoddi3+0x134>
  802168:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80216c:	72 22                	jb     802190 <__umoddi3+0x130>
  80216e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802172:	29 c8                	sub    %ecx,%eax
  802174:	19 d7                	sbb    %edx,%edi
  802176:	89 e9                	mov    %ebp,%ecx
  802178:	89 fa                	mov    %edi,%edx
  80217a:	d3 e8                	shr    %cl,%eax
  80217c:	89 f1                	mov    %esi,%ecx
  80217e:	d3 e2                	shl    %cl,%edx
  802180:	89 e9                	mov    %ebp,%ecx
  802182:	d3 ef                	shr    %cl,%edi
  802184:	09 d0                	or     %edx,%eax
  802186:	89 fa                	mov    %edi,%edx
  802188:	83 c4 14             	add    $0x14,%esp
  80218b:	5e                   	pop    %esi
  80218c:	5f                   	pop    %edi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    
  80218f:	90                   	nop
  802190:	39 d7                	cmp    %edx,%edi
  802192:	75 da                	jne    80216e <__umoddi3+0x10e>
  802194:	8b 14 24             	mov    (%esp),%edx
  802197:	89 c1                	mov    %eax,%ecx
  802199:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80219d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8021a1:	eb cb                	jmp    80216e <__umoddi3+0x10e>
  8021a3:	90                   	nop
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8021ac:	0f 82 0f ff ff ff    	jb     8020c1 <__umoddi3+0x61>
  8021b2:	e9 1a ff ff ff       	jmp    8020d1 <__umoddi3+0x71>
