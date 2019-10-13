
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 ed 01 00 00       	call   80021e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  800048:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  80004f:	e8 24 03 00 00       	call   800378 <cprintf>
	if ((r = pipe(p)) < 0)
  800054:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800057:	89 04 24             	mov    %eax,(%esp)
  80005a:	e8 64 1e 00 00       	call   801ec3 <pipe>
  80005f:	85 c0                	test   %eax,%eax
  800061:	79 20                	jns    800083 <umain+0x43>
		panic("pipe: %e", r);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 79 25 80 	movl   $0x802579,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 82 25 80 00 	movl   $0x802582,(%esp)
  80007e:	e8 fc 01 00 00       	call   80027f <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800083:	e8 ca 10 00 00       	call   801152 <fork>
  800088:	89 c6                	mov    %eax,%esi
  80008a:	85 c0                	test   %eax,%eax
  80008c:	79 20                	jns    8000ae <umain+0x6e>
		panic("fork: %e", r);
  80008e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800092:	c7 44 24 08 96 25 80 	movl   $0x802596,0x8(%esp)
  800099:	00 
  80009a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000a1:	00 
  8000a2:	c7 04 24 82 25 80 00 	movl   $0x802582,(%esp)
  8000a9:	e8 d1 01 00 00       	call   80027f <_panic>
	if (r == 0) {
  8000ae:	85 c0                	test   %eax,%eax
  8000b0:	75 56                	jne    800108 <umain+0xc8>
		close(p[1]);
  8000b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b5:	89 04 24             	mov    %eax,(%esp)
  8000b8:	e8 45 15 00 00       	call   801602 <close>
  8000bd:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000c5:	89 04 24             	mov    %eax,(%esp)
  8000c8:	e8 67 1f 00 00       	call   802034 <pipeisclosed>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 11                	je     8000e2 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000d1:	c7 04 24 9f 25 80 00 	movl   $0x80259f,(%esp)
  8000d8:	e8 9b 02 00 00       	call   800378 <cprintf>
				exit();
  8000dd:	e8 84 01 00 00       	call   800266 <exit>
			}
			sys_yield();
  8000e2:	e8 bd 0c 00 00       	call   800da4 <sys_yield>
		for (i=0; i<max; i++) {
  8000e7:	83 eb 01             	sub    $0x1,%ebx
  8000ea:	75 d6                	jne    8000c2 <umain+0x82>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000f3:	00 
  8000f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000fb:	00 
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 48 12 00 00       	call   801350 <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800108:	89 74 24 04          	mov    %esi,0x4(%esp)
  80010c:	c7 04 24 ba 25 80 00 	movl   $0x8025ba,(%esp)
  800113:	e8 60 02 00 00       	call   800378 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800118:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80011e:	6b f6 7c             	imul   $0x7c,%esi,%esi
	cprintf("kid is %d\n", kid-envs);
  800121:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800127:	c1 ee 02             	shr    $0x2,%esi
  80012a:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
  800130:	89 74 24 04          	mov    %esi,0x4(%esp)
  800134:	c7 04 24 c5 25 80 00 	movl   $0x8025c5,(%esp)
  80013b:	e8 38 02 00 00       	call   800378 <cprintf>
	dup(p[0], 10);
  800140:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800147:	00 
  800148:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80014b:	89 04 24             	mov    %eax,(%esp)
  80014e:	e8 04 15 00 00       	call   801657 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800153:	eb 13                	jmp    800168 <umain+0x128>
		dup(p[0], 10);
  800155:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80015c:	00 
  80015d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 ef 14 00 00       	call   801657 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800168:	8b 43 54             	mov    0x54(%ebx),%eax
  80016b:	83 f8 02             	cmp    $0x2,%eax
  80016e:	74 e5                	je     800155 <umain+0x115>

	cprintf("child done with loop\n");
  800170:	c7 04 24 d0 25 80 00 	movl   $0x8025d0,(%esp)
  800177:	e8 fc 01 00 00       	call   800378 <cprintf>
	if (pipeisclosed(p[0]))
  80017c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 ad 1e 00 00       	call   802034 <pipeisclosed>
  800187:	85 c0                	test   %eax,%eax
  800189:	74 1c                	je     8001a7 <umain+0x167>
		panic("somehow the other end of p[0] got closed!");
  80018b:	c7 44 24 08 2c 26 80 	movl   $0x80262c,0x8(%esp)
  800192:	00 
  800193:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 82 25 80 00 	movl   $0x802582,(%esp)
  8001a2:	e8 d8 00 00 00       	call   80027f <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 1d 13 00 00       	call   8014d6 <fd_lookup>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	79 20                	jns    8001dd <umain+0x19d>
		panic("cannot look up p[0]: %e", r);
  8001bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c1:	c7 44 24 08 e6 25 80 	movl   $0x8025e6,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 82 25 80 00 	movl   $0x802582,(%esp)
  8001d8:	e8 a2 00 00 00       	call   80027f <_panic>
	va = fd2data(fd);
  8001dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 88 12 00 00       	call   801470 <fd2data>
	if (pageref(va) != 3+1)
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 bc 1a 00 00       	call   801cac <pageref>
  8001f0:	83 f8 04             	cmp    $0x4,%eax
  8001f3:	74 0e                	je     800203 <umain+0x1c3>
		cprintf("\nchild detected race\n");
  8001f5:	c7 04 24 fe 25 80 00 	movl   $0x8025fe,(%esp)
  8001fc:	e8 77 01 00 00       	call   800378 <cprintf>
  800201:	eb 14                	jmp    800217 <umain+0x1d7>
	else
		cprintf("\nrace didn't happen\n", max);
  800203:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  80020a:	00 
  80020b:	c7 04 24 14 26 80 00 	movl   $0x802614,(%esp)
  800212:	e8 61 01 00 00       	call   800378 <cprintf>
}
  800217:	83 c4 20             	add    $0x20,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 10             	sub    $0x10,%esp
  800226:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800229:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  80022c:	e8 54 0b 00 00       	call   800d85 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800231:	25 ff 03 00 00       	and    $0x3ff,%eax
  800236:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800239:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023e:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800243:	85 db                	test   %ebx,%ebx
  800245:	7e 07                	jle    80024e <libmain+0x30>
		binaryname = argv[0];
  800247:	8b 06                	mov    (%esi),%eax
  800249:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80024e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800252:	89 1c 24             	mov    %ebx,(%esp)
  800255:	e8 e6 fd ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80025a:	e8 07 00 00 00       	call   800266 <exit>
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80026c:	e8 c4 13 00 00       	call   801635 <close_all>
	sys_env_destroy(0);
  800271:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800278:	e8 b6 0a 00 00       	call   800d33 <sys_env_destroy>
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	56                   	push   %esi
  800283:	53                   	push   %ebx
  800284:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800287:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80028a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800290:	e8 f0 0a 00 00       	call   800d85 <sys_getenvid>
  800295:	8b 55 0c             	mov    0xc(%ebp),%edx
  800298:	89 54 24 10          	mov    %edx,0x10(%esp)
  80029c:	8b 55 08             	mov    0x8(%ebp),%edx
  80029f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ab:	c7 04 24 60 26 80 00 	movl   $0x802660,(%esp)
  8002b2:	e8 c1 00 00 00       	call   800378 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002be:	89 04 24             	mov    %eax,(%esp)
  8002c1:	e8 51 00 00 00       	call   800317 <vcprintf>
	cprintf("\n");
  8002c6:	c7 04 24 77 25 80 00 	movl   $0x802577,(%esp)
  8002cd:	e8 a6 00 00 00       	call   800378 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d2:	cc                   	int3   
  8002d3:	eb fd                	jmp    8002d2 <_panic+0x53>

008002d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	53                   	push   %ebx
  8002d9:	83 ec 14             	sub    $0x14,%esp
  8002dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002df:	8b 13                	mov    (%ebx),%edx
  8002e1:	8d 42 01             	lea    0x1(%edx),%eax
  8002e4:	89 03                	mov    %eax,(%ebx)
  8002e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f2:	75 19                	jne    80030d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002f4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002fb:	00 
  8002fc:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	e8 ef 09 00 00       	call   800cf6 <sys_cputs>
		b->idx = 0;
  800307:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80030d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800311:	83 c4 14             	add    $0x14,%esp
  800314:	5b                   	pop    %ebx
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800320:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800327:	00 00 00 
	b.cnt = 0;
  80032a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800331:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80033b:	8b 45 08             	mov    0x8(%ebp),%eax
  80033e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800342:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800348:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034c:	c7 04 24 d5 02 80 00 	movl   $0x8002d5,(%esp)
  800353:	e8 b6 01 00 00       	call   80050e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800358:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80035e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800362:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	e8 86 09 00 00       	call   800cf6 <sys_cputs>

	return b.cnt;
}
  800370:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80037e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	e8 87 ff ff ff       	call   800317 <vcprintf>
	va_end(ap);

	return cnt;
}
  800390:	c9                   	leave  
  800391:	c3                   	ret    
  800392:	66 90                	xchg   %ax,%ax
  800394:	66 90                	xchg   %ax,%ax
  800396:	66 90                	xchg   %ax,%ax
  800398:	66 90                	xchg   %ax,%ax
  80039a:	66 90                	xchg   %ax,%ax
  80039c:	66 90                	xchg   %ax,%ax
  80039e:	66 90                	xchg   %ax,%ax

008003a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 3c             	sub    $0x3c,%esp
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	89 d7                	mov    %edx,%edi
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b7:	89 c3                	mov    %eax,%ebx
  8003b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003cd:	39 d9                	cmp    %ebx,%ecx
  8003cf:	72 05                	jb     8003d6 <printnum+0x36>
  8003d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003d4:	77 69                	ja     80043f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003dd:	83 ee 01             	sub    $0x1,%esi
  8003e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003f0:	89 c3                	mov    %eax,%ebx
  8003f2:	89 d6                	mov    %edx,%esi
  8003f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80040b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040f:	e8 bc 1e 00 00       	call   8022d0 <__udivdi3>
  800414:	89 d9                	mov    %ebx,%ecx
  800416:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80041a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	89 54 24 04          	mov    %edx,0x4(%esp)
  800425:	89 fa                	mov    %edi,%edx
  800427:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80042a:	e8 71 ff ff ff       	call   8003a0 <printnum>
  80042f:	eb 1b                	jmp    80044c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800431:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800435:	8b 45 18             	mov    0x18(%ebp),%eax
  800438:	89 04 24             	mov    %eax,(%esp)
  80043b:	ff d3                	call   *%ebx
  80043d:	eb 03                	jmp    800442 <printnum+0xa2>
  80043f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800442:	83 ee 01             	sub    $0x1,%esi
  800445:	85 f6                	test   %esi,%esi
  800447:	7f e8                	jg     800431 <printnum+0x91>
  800449:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800450:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800454:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800457:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80045a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800462:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80046b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046f:	e8 8c 1f 00 00       	call   802400 <__umoddi3>
  800474:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800478:	0f be 80 83 26 80 00 	movsbl 0x802683(%eax),%eax
  80047f:	89 04 24             	mov    %eax,(%esp)
  800482:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800485:	ff d0                	call   *%eax
}
  800487:	83 c4 3c             	add    $0x3c,%esp
  80048a:	5b                   	pop    %ebx
  80048b:	5e                   	pop    %esi
  80048c:	5f                   	pop    %edi
  80048d:	5d                   	pop    %ebp
  80048e:	c3                   	ret    

0080048f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800492:	83 fa 01             	cmp    $0x1,%edx
  800495:	7e 0e                	jle    8004a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800497:	8b 10                	mov    (%eax),%edx
  800499:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049c:	89 08                	mov    %ecx,(%eax)
  80049e:	8b 02                	mov    (%edx),%eax
  8004a0:	8b 52 04             	mov    0x4(%edx),%edx
  8004a3:	eb 22                	jmp    8004c7 <getuint+0x38>
	else if (lflag)
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	74 10                	je     8004b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b7:	eb 0e                	jmp    8004c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004be:	89 08                	mov    %ecx,(%eax)
  8004c0:	8b 02                	mov    (%edx),%eax
  8004c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004c7:	5d                   	pop    %ebp
  8004c8:	c3                   	ret    

008004c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d8:	73 0a                	jae    8004e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e2:	88 02                	mov    %al,(%edx)
}
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <printfmt>:
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8004ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800501:	8b 45 08             	mov    0x8(%ebp),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	e8 02 00 00 00       	call   80050e <vprintfmt>
}
  80050c:	c9                   	leave  
  80050d:	c3                   	ret    

0080050e <vprintfmt>:
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	57                   	push   %edi
  800512:	56                   	push   %esi
  800513:	53                   	push   %ebx
  800514:	83 ec 3c             	sub    $0x3c,%esp
  800517:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80051a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80051d:	eb 1f                	jmp    80053e <vprintfmt+0x30>
			if (ch == '\0'){
  80051f:	85 c0                	test   %eax,%eax
  800521:	75 0f                	jne    800532 <vprintfmt+0x24>
				color = 0x0100;
  800523:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80052a:	01 00 00 
  80052d:	e9 b3 03 00 00       	jmp    8008e5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800532:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800536:	89 04 24             	mov    %eax,(%esp)
  800539:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053c:	89 f3                	mov    %esi,%ebx
  80053e:	8d 73 01             	lea    0x1(%ebx),%esi
  800541:	0f b6 03             	movzbl (%ebx),%eax
  800544:	83 f8 25             	cmp    $0x25,%eax
  800547:	75 d6                	jne    80051f <vprintfmt+0x11>
  800549:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80054d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800554:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80055b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	eb 1d                	jmp    800586 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800569:	89 de                	mov    %ebx,%esi
			padc = '-';
  80056b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80056f:	eb 15                	jmp    800586 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800571:	89 de                	mov    %ebx,%esi
			padc = '0';
  800573:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800577:	eb 0d                	jmp    800586 <vprintfmt+0x78>
				width = precision, precision = -1;
  800579:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80057c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80057f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8d 5e 01             	lea    0x1(%esi),%ebx
  800589:	0f b6 0e             	movzbl (%esi),%ecx
  80058c:	0f b6 c1             	movzbl %cl,%eax
  80058f:	83 e9 23             	sub    $0x23,%ecx
  800592:	80 f9 55             	cmp    $0x55,%cl
  800595:	0f 87 2a 03 00 00    	ja     8008c5 <vprintfmt+0x3b7>
  80059b:	0f b6 c9             	movzbl %cl,%ecx
  80059e:	ff 24 8d c0 27 80 00 	jmp    *0x8027c0(,%ecx,4)
  8005a5:	89 de                	mov    %ebx,%esi
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8005ac:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005af:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8005b3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005b6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005b9:	83 fb 09             	cmp    $0x9,%ebx
  8005bc:	77 36                	ja     8005f4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8005be:	83 c6 01             	add    $0x1,%esi
			}
  8005c1:	eb e9                	jmp    8005ac <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8005d3:	eb 22                	jmp    8005f7 <vprintfmt+0xe9>
  8005d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d8:	85 c9                	test   %ecx,%ecx
  8005da:	b8 00 00 00 00       	mov    $0x0,%eax
  8005df:	0f 49 c1             	cmovns %ecx,%eax
  8005e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	eb 9d                	jmp    800586 <vprintfmt+0x78>
  8005e9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8005eb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005f2:	eb 92                	jmp    800586 <vprintfmt+0x78>
  8005f4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8005f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fb:	79 89                	jns    800586 <vprintfmt+0x78>
  8005fd:	e9 77 ff ff ff       	jmp    800579 <vprintfmt+0x6b>
			lflag++;
  800602:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800605:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800607:	e9 7a ff ff ff       	jmp    800586 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800621:	e9 18 ff ff ff       	jmp    80053e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	99                   	cltd   
  800632:	31 d0                	xor    %edx,%eax
  800634:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800636:	83 f8 0f             	cmp    $0xf,%eax
  800639:	7f 0b                	jg     800646 <vprintfmt+0x138>
  80063b:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  800642:	85 d2                	test   %edx,%edx
  800644:	75 20                	jne    800666 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800646:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80064a:	c7 44 24 08 9b 26 80 	movl   $0x80269b,0x8(%esp)
  800651:	00 
  800652:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800656:	8b 45 08             	mov    0x8(%ebp),%eax
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	e8 85 fe ff ff       	call   8004e6 <printfmt>
  800661:	e9 d8 fe ff ff       	jmp    80053e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800666:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80066a:	c7 44 24 08 fa 2b 80 	movl   $0x802bfa,0x8(%esp)
  800671:	00 
  800672:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	89 04 24             	mov    %eax,(%esp)
  80067c:	e8 65 fe ff ff       	call   8004e6 <printfmt>
  800681:	e9 b8 fe ff ff       	jmp    80053e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800689:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80068c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80069a:	85 f6                	test   %esi,%esi
  80069c:	b8 94 26 80 00       	mov    $0x802694,%eax
  8006a1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006a4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006a8:	0f 84 97 00 00 00    	je     800745 <vprintfmt+0x237>
  8006ae:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006b2:	0f 8e 9b 00 00 00    	jle    800753 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006bc:	89 34 24             	mov    %esi,(%esp)
  8006bf:	e8 c4 02 00 00       	call   800988 <strnlen>
  8006c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006c7:	29 c2                	sub    %eax,%edx
  8006c9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006cc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006d3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006dc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006de:	eb 0f                	jmp    8006ef <vprintfmt+0x1e1>
					putch(padc, putdat);
  8006e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ec:	83 eb 01             	sub    $0x1,%ebx
  8006ef:	85 db                	test   %ebx,%ebx
  8006f1:	7f ed                	jg     8006e0 <vprintfmt+0x1d2>
  8006f3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	0f 49 c2             	cmovns %edx,%eax
  800703:	29 c2                	sub    %eax,%edx
  800705:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800708:	89 d7                	mov    %edx,%edi
  80070a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80070d:	eb 50                	jmp    80075f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80070f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800713:	74 1e                	je     800733 <vprintfmt+0x225>
  800715:	0f be d2             	movsbl %dl,%edx
  800718:	83 ea 20             	sub    $0x20,%edx
  80071b:	83 fa 5e             	cmp    $0x5e,%edx
  80071e:	76 13                	jbe    800733 <vprintfmt+0x225>
					putch('?', putdat);
  800720:	8b 45 0c             	mov    0xc(%ebp),%eax
  800723:	89 44 24 04          	mov    %eax,0x4(%esp)
  800727:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80072e:	ff 55 08             	call   *0x8(%ebp)
  800731:	eb 0d                	jmp    800740 <vprintfmt+0x232>
					putch(ch, putdat);
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
  800736:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073a:	89 04 24             	mov    %eax,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800740:	83 ef 01             	sub    $0x1,%edi
  800743:	eb 1a                	jmp    80075f <vprintfmt+0x251>
  800745:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800748:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80074b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80074e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800751:	eb 0c                	jmp    80075f <vprintfmt+0x251>
  800753:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800756:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800759:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80075c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80075f:	83 c6 01             	add    $0x1,%esi
  800762:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800766:	0f be c2             	movsbl %dl,%eax
  800769:	85 c0                	test   %eax,%eax
  80076b:	74 27                	je     800794 <vprintfmt+0x286>
  80076d:	85 db                	test   %ebx,%ebx
  80076f:	78 9e                	js     80070f <vprintfmt+0x201>
  800771:	83 eb 01             	sub    $0x1,%ebx
  800774:	79 99                	jns    80070f <vprintfmt+0x201>
  800776:	89 f8                	mov    %edi,%eax
  800778:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
  80077e:	89 c3                	mov    %eax,%ebx
  800780:	eb 1a                	jmp    80079c <vprintfmt+0x28e>
				putch(' ', putdat);
  800782:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800786:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80078d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80078f:	83 eb 01             	sub    $0x1,%ebx
  800792:	eb 08                	jmp    80079c <vprintfmt+0x28e>
  800794:	89 fb                	mov    %edi,%ebx
  800796:	8b 75 08             	mov    0x8(%ebp),%esi
  800799:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80079c:	85 db                	test   %ebx,%ebx
  80079e:	7f e2                	jg     800782 <vprintfmt+0x274>
  8007a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007a6:	e9 93 fd ff ff       	jmp    80053e <vprintfmt+0x30>
	if (lflag >= 2)
  8007ab:	83 fa 01             	cmp    $0x1,%edx
  8007ae:	7e 16                	jle    8007c6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 50 08             	lea    0x8(%eax),%edx
  8007b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b9:	8b 50 04             	mov    0x4(%eax),%edx
  8007bc:	8b 00                	mov    (%eax),%eax
  8007be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007c4:	eb 32                	jmp    8007f8 <vprintfmt+0x2ea>
	else if (lflag)
  8007c6:	85 d2                	test   %edx,%edx
  8007c8:	74 18                	je     8007e2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8d 50 04             	lea    0x4(%eax),%edx
  8007d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d3:	8b 30                	mov    (%eax),%esi
  8007d5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	c1 f8 1f             	sar    $0x1f,%eax
  8007dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e0:	eb 16                	jmp    8007f8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 04             	lea    0x4(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007eb:	8b 30                	mov    (%eax),%esi
  8007ed:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007f0:	89 f0                	mov    %esi,%eax
  8007f2:	c1 f8 1f             	sar    $0x1f,%eax
  8007f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8007f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8007fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800803:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800807:	0f 89 80 00 00 00    	jns    80088d <vprintfmt+0x37f>
				putch('-', putdat);
  80080d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800811:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800818:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80081b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80081e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800821:	f7 d8                	neg    %eax
  800823:	83 d2 00             	adc    $0x0,%edx
  800826:	f7 da                	neg    %edx
			base = 10;
  800828:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80082d:	eb 5e                	jmp    80088d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	e8 58 fc ff ff       	call   80048f <getuint>
			base = 10;
  800837:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80083c:	eb 4f                	jmp    80088d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
  800841:	e8 49 fc ff ff       	call   80048f <getuint>
            base = 8;
  800846:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80084b:	eb 40                	jmp    80088d <vprintfmt+0x37f>
			putch('0', putdat);
  80084d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800851:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800858:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80085b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800866:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8d 50 04             	lea    0x4(%eax),%edx
  80086f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800872:	8b 00                	mov    (%eax),%eax
  800874:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800879:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087e:	eb 0d                	jmp    80088d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800880:	8d 45 14             	lea    0x14(%ebp),%eax
  800883:	e8 07 fc ff ff       	call   80048f <getuint>
			base = 16;
  800888:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80088d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800891:	89 74 24 10          	mov    %esi,0x10(%esp)
  800895:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800898:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80089c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a7:	89 fa                	mov    %edi,%edx
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	e8 ef fa ff ff       	call   8003a0 <printnum>
			break;
  8008b1:	e9 88 fc ff ff       	jmp    80053e <vprintfmt+0x30>
			putch(ch, putdat);
  8008b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ba:	89 04 24             	mov    %eax,(%esp)
  8008bd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008c0:	e9 79 fc ff ff       	jmp    80053e <vprintfmt+0x30>
			putch('%', putdat);
  8008c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008d0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d3:	89 f3                	mov    %esi,%ebx
  8008d5:	eb 03                	jmp    8008da <vprintfmt+0x3cc>
  8008d7:	83 eb 01             	sub    $0x1,%ebx
  8008da:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008de:	75 f7                	jne    8008d7 <vprintfmt+0x3c9>
  8008e0:	e9 59 fc ff ff       	jmp    80053e <vprintfmt+0x30>
}
  8008e5:	83 c4 3c             	add    $0x3c,%esp
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5f                   	pop    %edi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	83 ec 28             	sub    $0x28,%esp
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800900:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800903:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090a:	85 c0                	test   %eax,%eax
  80090c:	74 30                	je     80093e <vsnprintf+0x51>
  80090e:	85 d2                	test   %edx,%edx
  800910:	7e 2c                	jle    80093e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800919:	8b 45 10             	mov    0x10(%ebp),%eax
  80091c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800920:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800923:	89 44 24 04          	mov    %eax,0x4(%esp)
  800927:	c7 04 24 c9 04 80 00 	movl   $0x8004c9,(%esp)
  80092e:	e8 db fb ff ff       	call   80050e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800933:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800936:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093c:	eb 05                	jmp    800943 <vsnprintf+0x56>
		return -E_INVAL;
  80093e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80094b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80094e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800952:	8b 45 10             	mov    0x10(%ebp),%eax
  800955:	89 44 24 08          	mov    %eax,0x8(%esp)
  800959:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	89 04 24             	mov    %eax,(%esp)
  800966:	e8 82 ff ff ff       	call   8008ed <vsnprintf>
	va_end(ap);

	return rc;
}
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    
  80096d:	66 90                	xchg   %ax,%ax
  80096f:	90                   	nop

00800970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb 03                	jmp    800980 <strlen+0x10>
		n++;
  80097d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800980:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800984:	75 f7                	jne    80097d <strlen+0xd>
	return n;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
  800996:	eb 03                	jmp    80099b <strnlen+0x13>
		n++;
  800998:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	74 06                	je     8009a5 <strnlen+0x1d>
  80099f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009a3:	75 f3                	jne    800998 <strnlen+0x10>
	return n;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b1:	89 c2                	mov    %eax,%edx
  8009b3:	83 c2 01             	add    $0x1,%edx
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c0:	84 db                	test   %bl,%bl
  8009c2:	75 ef                	jne    8009b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	53                   	push   %ebx
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d1:	89 1c 24             	mov    %ebx,(%esp)
  8009d4:	e8 97 ff ff ff       	call   800970 <strlen>
	strcpy(dst + len, src);
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e0:	01 d8                	add    %ebx,%eax
  8009e2:	89 04 24             	mov    %eax,(%esp)
  8009e5:	e8 bd ff ff ff       	call   8009a7 <strcpy>
	return dst;
}
  8009ea:	89 d8                	mov    %ebx,%eax
  8009ec:	83 c4 08             	add    $0x8,%esp
  8009ef:	5b                   	pop    %ebx
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fd:	89 f3                	mov    %esi,%ebx
  8009ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a02:	89 f2                	mov    %esi,%edx
  800a04:	eb 0f                	jmp    800a15 <strncpy+0x23>
		*dst++ = *src;
  800a06:	83 c2 01             	add    $0x1,%edx
  800a09:	0f b6 01             	movzbl (%ecx),%eax
  800a0c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a0f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a12:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a15:	39 da                	cmp    %ebx,%edx
  800a17:	75 ed                	jne    800a06 <strncpy+0x14>
	}
	return ret;
}
  800a19:	89 f0                	mov    %esi,%eax
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 75 08             	mov    0x8(%ebp),%esi
  800a27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a2d:	89 f0                	mov    %esi,%eax
  800a2f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a33:	85 c9                	test   %ecx,%ecx
  800a35:	75 0b                	jne    800a42 <strlcpy+0x23>
  800a37:	eb 1d                	jmp    800a56 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	83 c2 01             	add    $0x1,%edx
  800a3f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a42:	39 d8                	cmp    %ebx,%eax
  800a44:	74 0b                	je     800a51 <strlcpy+0x32>
  800a46:	0f b6 0a             	movzbl (%edx),%ecx
  800a49:	84 c9                	test   %cl,%cl
  800a4b:	75 ec                	jne    800a39 <strlcpy+0x1a>
  800a4d:	89 c2                	mov    %eax,%edx
  800a4f:	eb 02                	jmp    800a53 <strlcpy+0x34>
  800a51:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800a53:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a56:	29 f0                	sub    %esi,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a65:	eb 06                	jmp    800a6d <strcmp+0x11>
		p++, q++;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a6d:	0f b6 01             	movzbl (%ecx),%eax
  800a70:	84 c0                	test   %al,%al
  800a72:	74 04                	je     800a78 <strcmp+0x1c>
  800a74:	3a 02                	cmp    (%edx),%al
  800a76:	74 ef                	je     800a67 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 c0             	movzbl %al,%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
}
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8c:	89 c3                	mov    %eax,%ebx
  800a8e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a91:	eb 06                	jmp    800a99 <strncmp+0x17>
		n--, p++, q++;
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a99:	39 d8                	cmp    %ebx,%eax
  800a9b:	74 15                	je     800ab2 <strncmp+0x30>
  800a9d:	0f b6 08             	movzbl (%eax),%ecx
  800aa0:	84 c9                	test   %cl,%cl
  800aa2:	74 04                	je     800aa8 <strncmp+0x26>
  800aa4:	3a 0a                	cmp    (%edx),%cl
  800aa6:	74 eb                	je     800a93 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa8:	0f b6 00             	movzbl (%eax),%eax
  800aab:	0f b6 12             	movzbl (%edx),%edx
  800aae:	29 d0                	sub    %edx,%eax
  800ab0:	eb 05                	jmp    800ab7 <strncmp+0x35>
		return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac4:	eb 07                	jmp    800acd <strchr+0x13>
		if (*s == c)
  800ac6:	38 ca                	cmp    %cl,%dl
  800ac8:	74 0f                	je     800ad9 <strchr+0x1f>
	for (; *s; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	0f b6 10             	movzbl (%eax),%edx
  800ad0:	84 d2                	test   %dl,%dl
  800ad2:	75 f2                	jne    800ac6 <strchr+0xc>
			return (char *) s;
	return 0;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae5:	eb 07                	jmp    800aee <strfind+0x13>
		if (*s == c)
  800ae7:	38 ca                	cmp    %cl,%dl
  800ae9:	74 0a                	je     800af5 <strfind+0x1a>
	for (; *s; s++)
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	0f b6 10             	movzbl (%eax),%edx
  800af1:	84 d2                	test   %dl,%dl
  800af3:	75 f2                	jne    800ae7 <strfind+0xc>
			break;
	return (char *) s;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b03:	85 c9                	test   %ecx,%ecx
  800b05:	74 36                	je     800b3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0d:	75 28                	jne    800b37 <memset+0x40>
  800b0f:	f6 c1 03             	test   $0x3,%cl
  800b12:	75 23                	jne    800b37 <memset+0x40>
		c &= 0xFF;
  800b14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	c1 e3 08             	shl    $0x8,%ebx
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	c1 e6 18             	shl    $0x18,%esi
  800b22:	89 d0                	mov    %edx,%eax
  800b24:	c1 e0 10             	shl    $0x10,%eax
  800b27:	09 f0                	or     %esi,%eax
  800b29:	09 c2                	or     %eax,%edx
  800b2b:	89 d0                	mov    %edx,%eax
  800b2d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b32:	fc                   	cld    
  800b33:	f3 ab                	rep stos %eax,%es:(%edi)
  800b35:	eb 06                	jmp    800b3d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	fc                   	cld    
  800b3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3d:	89 f8                	mov    %edi,%eax
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b52:	39 c6                	cmp    %eax,%esi
  800b54:	73 35                	jae    800b8b <memmove+0x47>
  800b56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b59:	39 d0                	cmp    %edx,%eax
  800b5b:	73 2e                	jae    800b8b <memmove+0x47>
		s += n;
		d += n;
  800b5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6a:	75 13                	jne    800b7f <memmove+0x3b>
  800b6c:	f6 c1 03             	test   $0x3,%cl
  800b6f:	75 0e                	jne    800b7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b71:	83 ef 04             	sub    $0x4,%edi
  800b74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b77:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b7a:	fd                   	std    
  800b7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7d:	eb 09                	jmp    800b88 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b7f:	83 ef 01             	sub    $0x1,%edi
  800b82:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b85:	fd                   	std    
  800b86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b88:	fc                   	cld    
  800b89:	eb 1d                	jmp    800ba8 <memmove+0x64>
  800b8b:	89 f2                	mov    %esi,%edx
  800b8d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8f:	f6 c2 03             	test   $0x3,%dl
  800b92:	75 0f                	jne    800ba3 <memmove+0x5f>
  800b94:	f6 c1 03             	test   $0x3,%cl
  800b97:	75 0a                	jne    800ba3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b99:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b9c:	89 c7                	mov    %eax,%edi
  800b9e:	fc                   	cld    
  800b9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba1:	eb 05                	jmp    800ba8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	fc                   	cld    
  800ba6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	89 04 24             	mov    %eax,(%esp)
  800bc6:	e8 79 ff ff ff       	call   800b44 <memmove>
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdd:	eb 1a                	jmp    800bf9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bdf:	0f b6 02             	movzbl (%edx),%eax
  800be2:	0f b6 19             	movzbl (%ecx),%ebx
  800be5:	38 d8                	cmp    %bl,%al
  800be7:	74 0a                	je     800bf3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be9:	0f b6 c0             	movzbl %al,%eax
  800bec:	0f b6 db             	movzbl %bl,%ebx
  800bef:	29 d8                	sub    %ebx,%eax
  800bf1:	eb 0f                	jmp    800c02 <memcmp+0x35>
		s1++, s2++;
  800bf3:	83 c2 01             	add    $0x1,%edx
  800bf6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800bf9:	39 f2                	cmp    %esi,%edx
  800bfb:	75 e2                	jne    800bdf <memcmp+0x12>
	}

	return 0;
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c0f:	89 c2                	mov    %eax,%edx
  800c11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c14:	eb 07                	jmp    800c1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c16:	38 08                	cmp    %cl,(%eax)
  800c18:	74 07                	je     800c21 <memfind+0x1b>
	for (; s < ends; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	39 d0                	cmp    %edx,%eax
  800c1f:	72 f5                	jb     800c16 <memfind+0x10>
			break;
	return (void *) s;
}
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2f:	eb 03                	jmp    800c34 <strtol+0x11>
		s++;
  800c31:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c34:	0f b6 0a             	movzbl (%edx),%ecx
  800c37:	80 f9 09             	cmp    $0x9,%cl
  800c3a:	74 f5                	je     800c31 <strtol+0xe>
  800c3c:	80 f9 20             	cmp    $0x20,%cl
  800c3f:	74 f0                	je     800c31 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c41:	80 f9 2b             	cmp    $0x2b,%cl
  800c44:	75 0a                	jne    800c50 <strtol+0x2d>
		s++;
  800c46:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c49:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4e:	eb 11                	jmp    800c61 <strtol+0x3e>
  800c50:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800c55:	80 f9 2d             	cmp    $0x2d,%cl
  800c58:	75 07                	jne    800c61 <strtol+0x3e>
		s++, neg = 1;
  800c5a:	8d 52 01             	lea    0x1(%edx),%edx
  800c5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c66:	75 15                	jne    800c7d <strtol+0x5a>
  800c68:	80 3a 30             	cmpb   $0x30,(%edx)
  800c6b:	75 10                	jne    800c7d <strtol+0x5a>
  800c6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c71:	75 0a                	jne    800c7d <strtol+0x5a>
		s += 2, base = 16;
  800c73:	83 c2 02             	add    $0x2,%edx
  800c76:	b8 10 00 00 00       	mov    $0x10,%eax
  800c7b:	eb 10                	jmp    800c8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	75 0c                	jne    800c8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c81:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c83:	80 3a 30             	cmpb   $0x30,(%edx)
  800c86:	75 05                	jne    800c8d <strtol+0x6a>
		s++, base = 8;
  800c88:	83 c2 01             	add    $0x1,%edx
  800c8b:	b0 08                	mov    $0x8,%al
		base = 10;
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c95:	0f b6 0a             	movzbl (%edx),%ecx
  800c98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c9b:	89 f0                	mov    %esi,%eax
  800c9d:	3c 09                	cmp    $0x9,%al
  800c9f:	77 08                	ja     800ca9 <strtol+0x86>
			dig = *s - '0';
  800ca1:	0f be c9             	movsbl %cl,%ecx
  800ca4:	83 e9 30             	sub    $0x30,%ecx
  800ca7:	eb 20                	jmp    800cc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ca9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cac:	89 f0                	mov    %esi,%eax
  800cae:	3c 19                	cmp    $0x19,%al
  800cb0:	77 08                	ja     800cba <strtol+0x97>
			dig = *s - 'a' + 10;
  800cb2:	0f be c9             	movsbl %cl,%ecx
  800cb5:	83 e9 57             	sub    $0x57,%ecx
  800cb8:	eb 0f                	jmp    800cc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800cba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cbd:	89 f0                	mov    %esi,%eax
  800cbf:	3c 19                	cmp    $0x19,%al
  800cc1:	77 16                	ja     800cd9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800cc3:	0f be c9             	movsbl %cl,%ecx
  800cc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cc9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ccc:	7d 0f                	jge    800cdd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cce:	83 c2 01             	add    $0x1,%edx
  800cd1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800cd5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800cd7:	eb bc                	jmp    800c95 <strtol+0x72>
  800cd9:	89 d8                	mov    %ebx,%eax
  800cdb:	eb 02                	jmp    800cdf <strtol+0xbc>
  800cdd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800cdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce3:	74 05                	je     800cea <strtol+0xc7>
		*endptr = (char *) s;
  800ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cea:	f7 d8                	neg    %eax
  800cec:	85 ff                	test   %edi,%edi
  800cee:	0f 44 c3             	cmove  %ebx,%eax
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 c3                	mov    %eax,%ebx
  800d09:	89 c7                	mov    %eax,%edi
  800d0b:	89 c6                	mov    %eax,%esi
  800d0d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d24:	89 d1                	mov    %edx,%ecx
  800d26:	89 d3                	mov    %edx,%ebx
  800d28:	89 d7                	mov    %edx,%edi
  800d2a:	89 d6                	mov    %edx,%esi
  800d2c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d41:	b8 03 00 00 00       	mov    $0x3,%eax
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 cb                	mov    %ecx,%ebx
  800d4b:	89 cf                	mov    %ecx,%edi
  800d4d:	89 ce                	mov    %ecx,%esi
  800d4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 28                	jle    800d7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d60:	00 
  800d61:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800d68:	00 
  800d69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d70:	00 
  800d71:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800d78:	e8 02 f5 ff ff       	call   80027f <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d7d:	83 c4 2c             	add    $0x2c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 02 00 00 00       	mov    $0x2,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_yield>:

void
sys_yield(void)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800daa:	ba 00 00 00 00       	mov    $0x0,%edx
  800daf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db4:	89 d1                	mov    %edx,%ecx
  800db6:	89 d3                	mov    %edx,%ebx
  800db8:	89 d7                	mov    %edx,%edi
  800dba:	89 d6                	mov    %edx,%esi
  800dbc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	89 f7                	mov    %esi,%edi
  800de1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 28                	jle    800e0f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800deb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800df2:	00 
  800df3:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e02:	00 
  800e03:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800e0a:	e8 70 f4 ff ff       	call   80027f <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e0f:	83 c4 2c             	add    $0x2c,%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e20:	b8 05 00 00 00       	mov    $0x5,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e31:	8b 75 18             	mov    0x18(%ebp),%esi
  800e34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e36:	85 c0                	test   %eax,%eax
  800e38:	7e 28                	jle    800e62 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e45:	00 
  800e46:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e55:	00 
  800e56:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800e5d:	e8 1d f4 ff ff       	call   80027f <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e62:	83 c4 2c             	add    $0x2c,%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	b8 06 00 00 00       	mov    $0x6,%eax
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	89 df                	mov    %ebx,%edi
  800e85:	89 de                	mov    %ebx,%esi
  800e87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 28                	jle    800eb5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e98:	00 
  800e99:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800eb0:	e8 ca f3 ff ff       	call   80027f <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eb5:	83 c4 2c             	add    $0x2c,%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ed0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed6:	89 df                	mov    %ebx,%edi
  800ed8:	89 de                	mov    %ebx,%esi
  800eda:	cd 30                	int    $0x30
	if(check && ret > 0)
  800edc:	85 c0                	test   %eax,%eax
  800ede:	7e 28                	jle    800f08 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eeb:	00 
  800eec:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efb:	00 
  800efc:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800f03:	e8 77 f3 ff ff       	call   80027f <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f08:	83 c4 2c             	add    $0x2c,%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 df                	mov    %ebx,%edi
  800f2b:	89 de                	mov    %ebx,%esi
  800f2d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	7e 28                	jle    800f5b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f37:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800f46:	00 
  800f47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4e:	00 
  800f4f:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800f56:	e8 24 f3 ff ff       	call   80027f <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f5b:	83 c4 2c             	add    $0x2c,%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	89 df                	mov    %ebx,%edi
  800f7e:	89 de                	mov    %ebx,%esi
  800f80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7e 28                	jle    800fae <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f91:	00 
  800f92:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800f99:	00 
  800f9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa1:	00 
  800fa2:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800fa9:	e8 d1 f2 ff ff       	call   80027f <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fae:	83 c4 2c             	add    $0x2c,%esp
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fbc:	be 00 00 00 00       	mov    $0x0,%esi
  800fc1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7e 28                	jle    801023 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fff:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801006:	00 
  801007:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  80100e:	00 
  80100f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801016:	00 
  801017:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  80101e:	e8 5c f2 ff ff       	call   80027f <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801023:	83 c4 2c             	add    $0x2c,%esp
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    
  80102b:	66 90                	xchg   %ax,%ax
  80102d:	66 90                	xchg   %ax,%ax
  80102f:	90                   	nop

00801030 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	53                   	push   %ebx
  801034:	83 ec 24             	sub    $0x24,%esp
  801037:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  80103a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  80103c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801040:	74 18                	je     80105a <pgfault+0x2a>
  801042:	89 d8                	mov    %ebx,%eax
  801044:	c1 e8 0c             	shr    $0xc,%eax
  801047:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104e:	25 05 08 00 00       	and    $0x805,%eax
  801053:	3d 05 08 00 00       	cmp    $0x805,%eax
  801058:	74 1c                	je     801076 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  80105a:	c7 44 24 08 ac 29 80 	movl   $0x8029ac,0x8(%esp)
  801061:	00 
  801062:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801069:	00 
  80106a:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  801071:	e8 09 f2 ff ff       	call   80027f <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  801076:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80107d:	00 
  80107e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801085:	00 
  801086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108d:	e8 31 fd ff ff       	call   800dc3 <sys_page_alloc>
	if(r < 0){
  801092:	85 c0                	test   %eax,%eax
  801094:	79 1c                	jns    8010b2 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  801096:	c7 44 24 08 dc 29 80 	movl   $0x8029dc,0x8(%esp)
  80109d:	00 
  80109e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8010a5:	00 
  8010a6:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  8010ad:	e8 cd f1 ff ff       	call   80027f <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8010b2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8010b8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010bf:	00 
  8010c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010cb:	e8 dc fa ff ff       	call   800bac <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  8010d0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010d7:	00 
  8010d8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e3:	00 
  8010e4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010eb:	00 
  8010ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f3:	e8 1f fd ff ff       	call   800e17 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	79 1c                	jns    801118 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  8010fc:	c7 44 24 08 a8 2a 80 	movl   $0x802aa8,0x8(%esp)
  801103:	00 
  801104:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80110b:	00 
  80110c:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  801113:	e8 67 f1 ff ff       	call   80027f <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  801118:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801127:	e8 3e fd ff ff       	call   800e6a <sys_page_unmap>
    if(r < 0){
  80112c:	85 c0                	test   %eax,%eax
  80112e:	79 1c                	jns    80114c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  801130:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801137:	00 
  801138:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80113f:	00 
  801140:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  801147:	e8 33 f1 ff ff       	call   80027f <_panic>
    }
    // LAB 4
}
  80114c:	83 c4 24             	add    $0x24,%esp
  80114f:	5b                   	pop    %ebx
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	57                   	push   %edi
  801156:	56                   	push   %esi
  801157:	53                   	push   %ebx
  801158:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  80115b:	c7 04 24 30 10 80 00 	movl   $0x801030,(%esp)
  801162:	e8 af 10 00 00       	call   802216 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801167:	b8 07 00 00 00       	mov    $0x7,%eax
  80116c:	cd 30                	int    $0x30
  80116e:	89 c7                	mov    %eax,%edi
  801170:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801173:	85 c0                	test   %eax,%eax
  801175:	79 1c                	jns    801193 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801177:	c7 44 24 08 d8 2a 80 	movl   $0x802ad8,0x8(%esp)
  80117e:	00 
  80117f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  80118e:	e8 ec f0 ff ff       	call   80027f <_panic>
    }
    if(child == 0){
  801193:	bb 00 00 00 00       	mov    $0x0,%ebx
  801198:	85 c0                	test   %eax,%eax
  80119a:	75 21                	jne    8011bd <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80119c:	e8 e4 fb ff ff       	call   800d85 <sys_getenvid>
  8011a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ae:	a3 08 40 80 00       	mov    %eax,0x804008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	e9 67 01 00 00       	jmp    801324 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  8011bd:	89 d8                	mov    %ebx,%eax
  8011bf:	c1 e8 16             	shr    $0x16,%eax
  8011c2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c9:	a8 01                	test   $0x1,%al
  8011cb:	74 4b                	je     801218 <fork+0xc6>
  8011cd:	89 de                	mov    %ebx,%esi
  8011cf:	c1 ee 0c             	shr    $0xc,%esi
  8011d2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011d9:	a8 01                	test   $0x1,%al
  8011db:	74 3b                	je     801218 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  8011dd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011e4:	a9 02 08 00 00       	test   $0x802,%eax
  8011e9:	0f 85 02 01 00 00    	jne    8012f1 <fork+0x19f>
  8011ef:	e9 d2 00 00 00       	jmp    8012c6 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  8011f4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011fb:	00 
  8011fc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801200:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801207:	00 
  801208:	89 74 24 04          	mov    %esi,0x4(%esp)
  80120c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801213:	e8 ff fb ff ff       	call   800e17 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801218:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80121e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801224:	75 97                	jne    8011bd <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801226:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80122d:	00 
  80122e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801235:	ee 
  801236:	89 3c 24             	mov    %edi,(%esp)
  801239:	e8 85 fb ff ff       	call   800dc3 <sys_page_alloc>

    if(r < 0){
  80123e:	85 c0                	test   %eax,%eax
  801240:	79 1c                	jns    80125e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801242:	c7 44 24 08 10 2a 80 	movl   $0x802a10,0x8(%esp)
  801249:	00 
  80124a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801251:	00 
  801252:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  801259:	e8 21 f0 ff ff       	call   80027f <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80125e:	a1 08 40 80 00       	mov    0x804008,%eax
  801263:	8b 40 64             	mov    0x64(%eax),%eax
  801266:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126a:	89 3c 24             	mov    %edi,(%esp)
  80126d:	e8 f1 fc ff ff       	call   800f63 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801272:	85 c0                	test   %eax,%eax
  801274:	79 1c                	jns    801292 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801276:	c7 44 24 08 30 2a 80 	movl   $0x802a30,0x8(%esp)
  80127d:	00 
  80127e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801285:	00 
  801286:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  80128d:	e8 ed ef ff ff       	call   80027f <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801292:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801299:	00 
  80129a:	89 3c 24             	mov    %edi,(%esp)
  80129d:	e8 1b fc ff ff       	call   800ebd <sys_env_set_status>
    if(r < 0){
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	79 1c                	jns    8012c2 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  8012a6:	c7 44 24 08 58 2a 80 	movl   $0x802a58,0x8(%esp)
  8012ad:	00 
  8012ae:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  8012b5:	00 
  8012b6:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  8012bd:	e8 bd ef ff ff       	call   80027f <_panic>
    }
    return child;
  8012c2:	89 f8                	mov    %edi,%eax
  8012c4:	eb 5e                	jmp    801324 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  8012c6:	c1 e6 0c             	shl    $0xc,%esi
  8012c9:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012d0:	00 
  8012d1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e7:	e8 2b fb ff ff       	call   800e17 <sys_page_map>
  8012ec:	e9 27 ff ff ff       	jmp    801218 <fork+0xc6>
  8012f1:	c1 e6 0c             	shl    $0xc,%esi
  8012f4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012fb:	00 
  8012fc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801300:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801303:	89 44 24 08          	mov    %eax,0x8(%esp)
  801307:	89 74 24 04          	mov    %esi,0x4(%esp)
  80130b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801312:	e8 00 fb ff ff       	call   800e17 <sys_page_map>
    if( r < 0 ){
  801317:	85 c0                	test   %eax,%eax
  801319:	0f 89 d5 fe ff ff    	jns    8011f4 <fork+0xa2>
  80131f:	e9 f4 fe ff ff       	jmp    801218 <fork+0xc6>
//	panic("fork not implemented");
}
  801324:	83 c4 2c             	add    $0x2c,%esp
  801327:	5b                   	pop    %ebx
  801328:	5e                   	pop    %esi
  801329:	5f                   	pop    %edi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <sfork>:

// Challenge!
int
sfork(void)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801332:	c7 44 24 08 f5 2a 80 	movl   $0x802af5,0x8(%esp)
  801339:	00 
  80133a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801341:	00 
  801342:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  801349:	e8 31 ef ff ff       	call   80027f <_panic>
  80134e:	66 90                	xchg   %ax,%ax

00801350 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
  801355:	83 ec 10             	sub    $0x10,%esp
  801358:	8b 75 08             	mov    0x8(%ebp),%esi
  80135b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801361:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801363:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801368:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80136b:	89 04 24             	mov    %eax,(%esp)
  80136e:	e8 66 fc ff ff       	call   800fd9 <sys_ipc_recv>
    if(r < 0){
  801373:	85 c0                	test   %eax,%eax
  801375:	79 16                	jns    80138d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801377:	85 f6                	test   %esi,%esi
  801379:	74 06                	je     801381 <ipc_recv+0x31>
            *from_env_store = 0;
  80137b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801381:	85 db                	test   %ebx,%ebx
  801383:	74 2c                	je     8013b1 <ipc_recv+0x61>
            *perm_store = 0;
  801385:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80138b:	eb 24                	jmp    8013b1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80138d:	85 f6                	test   %esi,%esi
  80138f:	74 0a                	je     80139b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801391:	a1 08 40 80 00       	mov    0x804008,%eax
  801396:	8b 40 74             	mov    0x74(%eax),%eax
  801399:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80139b:	85 db                	test   %ebx,%ebx
  80139d:	74 0a                	je     8013a9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80139f:	a1 08 40 80 00       	mov    0x804008,%eax
  8013a4:	8b 40 78             	mov    0x78(%eax),%eax
  8013a7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8013a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ae:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	57                   	push   %edi
  8013bc:	56                   	push   %esi
  8013bd:	53                   	push   %ebx
  8013be:	83 ec 1c             	sub    $0x1c,%esp
  8013c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  8013ca:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  8013cc:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8013d1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8013d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013e3:	89 3c 24             	mov    %edi,(%esp)
  8013e6:	e8 cb fb ff ff       	call   800fb6 <sys_ipc_try_send>
        if(r == 0){
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	74 28                	je     801417 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8013ef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013f2:	74 1c                	je     801410 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8013f4:	c7 44 24 08 0b 2b 80 	movl   $0x802b0b,0x8(%esp)
  8013fb:	00 
  8013fc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801403:	00 
  801404:	c7 04 24 22 2b 80 00 	movl   $0x802b22,(%esp)
  80140b:	e8 6f ee ff ff       	call   80027f <_panic>
        }
        sys_yield();
  801410:	e8 8f f9 ff ff       	call   800da4 <sys_yield>
    }
  801415:	eb bd                	jmp    8013d4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801417:	83 c4 1c             	add    $0x1c,%esp
  80141a:	5b                   	pop    %ebx
  80141b:	5e                   	pop    %esi
  80141c:	5f                   	pop    %edi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801425:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80142a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80142d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801433:	8b 52 50             	mov    0x50(%edx),%edx
  801436:	39 ca                	cmp    %ecx,%edx
  801438:	75 0d                	jne    801447 <ipc_find_env+0x28>
			return envs[i].env_id;
  80143a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80143d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801442:	8b 40 40             	mov    0x40(%eax),%eax
  801445:	eb 0e                	jmp    801455 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801447:	83 c0 01             	add    $0x1,%eax
  80144a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80144f:	75 d9                	jne    80142a <ipc_find_env+0xb>
	return 0;
  801451:	66 b8 00 00          	mov    $0x0,%ax
}
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    
  801457:	66 90                	xchg   %ax,%ax
  801459:	66 90                	xchg   %ax,%ax
  80145b:	66 90                	xchg   %ax,%ax
  80145d:	66 90                	xchg   %ax,%ax
  80145f:	90                   	nop

00801460 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	05 00 00 00 30       	add    $0x30000000,%eax
  80146b:	c1 e8 0c             	shr    $0xc,%eax
}
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801473:	8b 45 08             	mov    0x8(%ebp),%eax
  801476:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80147b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801480:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80148d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801492:	89 c2                	mov    %eax,%edx
  801494:	c1 ea 16             	shr    $0x16,%edx
  801497:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80149e:	f6 c2 01             	test   $0x1,%dl
  8014a1:	74 11                	je     8014b4 <fd_alloc+0x2d>
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	c1 ea 0c             	shr    $0xc,%edx
  8014a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014af:	f6 c2 01             	test   $0x1,%dl
  8014b2:	75 09                	jne    8014bd <fd_alloc+0x36>
			*fd_store = fd;
  8014b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bb:	eb 17                	jmp    8014d4 <fd_alloc+0x4d>
  8014bd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8014c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014c7:	75 c9                	jne    801492 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8014c9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014dc:	83 f8 1f             	cmp    $0x1f,%eax
  8014df:	77 36                	ja     801517 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e1:	c1 e0 0c             	shl    $0xc,%eax
  8014e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	c1 ea 16             	shr    $0x16,%edx
  8014ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014f5:	f6 c2 01             	test   $0x1,%dl
  8014f8:	74 24                	je     80151e <fd_lookup+0x48>
  8014fa:	89 c2                	mov    %eax,%edx
  8014fc:	c1 ea 0c             	shr    $0xc,%edx
  8014ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801506:	f6 c2 01             	test   $0x1,%dl
  801509:	74 1a                	je     801525 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80150b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150e:	89 02                	mov    %eax,(%edx)
	return 0;
  801510:	b8 00 00 00 00       	mov    $0x0,%eax
  801515:	eb 13                	jmp    80152a <fd_lookup+0x54>
		return -E_INVAL;
  801517:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151c:	eb 0c                	jmp    80152a <fd_lookup+0x54>
		return -E_INVAL;
  80151e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801523:	eb 05                	jmp    80152a <fd_lookup+0x54>
  801525:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	83 ec 18             	sub    $0x18,%esp
  801532:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801535:	ba a8 2b 80 00       	mov    $0x802ba8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80153a:	eb 13                	jmp    80154f <dev_lookup+0x23>
  80153c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80153f:	39 08                	cmp    %ecx,(%eax)
  801541:	75 0c                	jne    80154f <dev_lookup+0x23>
			*dev = devtab[i];
  801543:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801546:	89 01                	mov    %eax,(%ecx)
			return 0;
  801548:	b8 00 00 00 00       	mov    $0x0,%eax
  80154d:	eb 30                	jmp    80157f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80154f:	8b 02                	mov    (%edx),%eax
  801551:	85 c0                	test   %eax,%eax
  801553:	75 e7                	jne    80153c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801555:	a1 08 40 80 00       	mov    0x804008,%eax
  80155a:	8b 40 48             	mov    0x48(%eax),%eax
  80155d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801561:	89 44 24 04          	mov    %eax,0x4(%esp)
  801565:	c7 04 24 2c 2b 80 00 	movl   $0x802b2c,(%esp)
  80156c:	e8 07 ee ff ff       	call   800378 <cprintf>
	*dev = 0;
  801571:	8b 45 0c             	mov    0xc(%ebp),%eax
  801574:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80157a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <fd_close>:
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	83 ec 20             	sub    $0x20,%esp
  801589:	8b 75 08             	mov    0x8(%ebp),%esi
  80158c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80158f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801592:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801596:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80159c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80159f:	89 04 24             	mov    %eax,(%esp)
  8015a2:	e8 2f ff ff ff       	call   8014d6 <fd_lookup>
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 05                	js     8015b0 <fd_close+0x2f>
	    || fd != fd2)
  8015ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015ae:	74 0c                	je     8015bc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8015b0:	84 db                	test   %bl,%bl
  8015b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b7:	0f 44 c2             	cmove  %edx,%eax
  8015ba:	eb 3f                	jmp    8015fb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c3:	8b 06                	mov    (%esi),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 5f ff ff ff       	call   80152c <dev_lookup>
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 16                	js     8015e9 <fd_close+0x68>
		if (dev->dev_close)
  8015d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 07                	je     8015e9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8015e2:	89 34 24             	mov    %esi,(%esp)
  8015e5:	ff d0                	call   *%eax
  8015e7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8015e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f4:	e8 71 f8 ff ff       	call   800e6a <sys_page_unmap>
	return r;
  8015f9:	89 d8                	mov    %ebx,%eax
}
  8015fb:	83 c4 20             	add    $0x20,%esp
  8015fe:	5b                   	pop    %ebx
  8015ff:	5e                   	pop    %esi
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <close>:

int
close(int fdnum)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160f:	8b 45 08             	mov    0x8(%ebp),%eax
  801612:	89 04 24             	mov    %eax,(%esp)
  801615:	e8 bc fe ff ff       	call   8014d6 <fd_lookup>
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	85 d2                	test   %edx,%edx
  80161e:	78 13                	js     801633 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801620:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801627:	00 
  801628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162b:	89 04 24             	mov    %eax,(%esp)
  80162e:	e8 4e ff ff ff       	call   801581 <fd_close>
}
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <close_all>:

void
close_all(void)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	53                   	push   %ebx
  801639:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801641:	89 1c 24             	mov    %ebx,(%esp)
  801644:	e8 b9 ff ff ff       	call   801602 <close>
	for (i = 0; i < MAXFD; i++)
  801649:	83 c3 01             	add    $0x1,%ebx
  80164c:	83 fb 20             	cmp    $0x20,%ebx
  80164f:	75 f0                	jne    801641 <close_all+0xc>
}
  801651:	83 c4 14             	add    $0x14,%esp
  801654:	5b                   	pop    %ebx
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    

00801657 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	57                   	push   %edi
  80165b:	56                   	push   %esi
  80165c:	53                   	push   %ebx
  80165d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801660:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801663:	89 44 24 04          	mov    %eax,0x4(%esp)
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	89 04 24             	mov    %eax,(%esp)
  80166d:	e8 64 fe ff ff       	call   8014d6 <fd_lookup>
  801672:	89 c2                	mov    %eax,%edx
  801674:	85 d2                	test   %edx,%edx
  801676:	0f 88 e1 00 00 00    	js     80175d <dup+0x106>
		return r;
	close(newfdnum);
  80167c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167f:	89 04 24             	mov    %eax,(%esp)
  801682:	e8 7b ff ff ff       	call   801602 <close>

	newfd = INDEX2FD(newfdnum);
  801687:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80168a:	c1 e3 0c             	shl    $0xc,%ebx
  80168d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801693:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801696:	89 04 24             	mov    %eax,(%esp)
  801699:	e8 d2 fd ff ff       	call   801470 <fd2data>
  80169e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8016a0:	89 1c 24             	mov    %ebx,(%esp)
  8016a3:	e8 c8 fd ff ff       	call   801470 <fd2data>
  8016a8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016aa:	89 f0                	mov    %esi,%eax
  8016ac:	c1 e8 16             	shr    $0x16,%eax
  8016af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b6:	a8 01                	test   $0x1,%al
  8016b8:	74 43                	je     8016fd <dup+0xa6>
  8016ba:	89 f0                	mov    %esi,%eax
  8016bc:	c1 e8 0c             	shr    $0xc,%eax
  8016bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c6:	f6 c2 01             	test   $0x1,%dl
  8016c9:	74 32                	je     8016fd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016e6:	00 
  8016e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f2:	e8 20 f7 ff ff       	call   800e17 <sys_page_map>
  8016f7:	89 c6                	mov    %eax,%esi
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 3e                	js     80173b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801700:	89 c2                	mov    %eax,%edx
  801702:	c1 ea 0c             	shr    $0xc,%edx
  801705:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80170c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801712:	89 54 24 10          	mov    %edx,0x10(%esp)
  801716:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80171a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801721:	00 
  801722:	89 44 24 04          	mov    %eax,0x4(%esp)
  801726:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172d:	e8 e5 f6 ff ff       	call   800e17 <sys_page_map>
  801732:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801734:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801737:	85 f6                	test   %esi,%esi
  801739:	79 22                	jns    80175d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80173b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80173f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801746:	e8 1f f7 ff ff       	call   800e6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80174b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80174f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801756:	e8 0f f7 ff ff       	call   800e6a <sys_page_unmap>
	return r;
  80175b:	89 f0                	mov    %esi,%eax
}
  80175d:	83 c4 3c             	add    $0x3c,%esp
  801760:	5b                   	pop    %ebx
  801761:	5e                   	pop    %esi
  801762:	5f                   	pop    %edi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	53                   	push   %ebx
  801769:	83 ec 24             	sub    $0x24,%esp
  80176c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801772:	89 44 24 04          	mov    %eax,0x4(%esp)
  801776:	89 1c 24             	mov    %ebx,(%esp)
  801779:	e8 58 fd ff ff       	call   8014d6 <fd_lookup>
  80177e:	89 c2                	mov    %eax,%edx
  801780:	85 d2                	test   %edx,%edx
  801782:	78 6d                	js     8017f1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801784:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178e:	8b 00                	mov    (%eax),%eax
  801790:	89 04 24             	mov    %eax,(%esp)
  801793:	e8 94 fd ff ff       	call   80152c <dev_lookup>
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 55                	js     8017f1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80179c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179f:	8b 50 08             	mov    0x8(%eax),%edx
  8017a2:	83 e2 03             	and    $0x3,%edx
  8017a5:	83 fa 01             	cmp    $0x1,%edx
  8017a8:	75 23                	jne    8017cd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8017af:	8b 40 48             	mov    0x48(%eax),%eax
  8017b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ba:	c7 04 24 6d 2b 80 00 	movl   $0x802b6d,(%esp)
  8017c1:	e8 b2 eb ff ff       	call   800378 <cprintf>
		return -E_INVAL;
  8017c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017cb:	eb 24                	jmp    8017f1 <read+0x8c>
	}
	if (!dev->dev_read)
  8017cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d0:	8b 52 08             	mov    0x8(%edx),%edx
  8017d3:	85 d2                	test   %edx,%edx
  8017d5:	74 15                	je     8017ec <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017e5:	89 04 24             	mov    %eax,(%esp)
  8017e8:	ff d2                	call   *%edx
  8017ea:	eb 05                	jmp    8017f1 <read+0x8c>
		return -E_NOT_SUPP;
  8017ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017f1:	83 c4 24             	add    $0x24,%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	57                   	push   %edi
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 1c             	sub    $0x1c,%esp
  801800:	8b 7d 08             	mov    0x8(%ebp),%edi
  801803:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801806:	bb 00 00 00 00       	mov    $0x0,%ebx
  80180b:	eb 23                	jmp    801830 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80180d:	89 f0                	mov    %esi,%eax
  80180f:	29 d8                	sub    %ebx,%eax
  801811:	89 44 24 08          	mov    %eax,0x8(%esp)
  801815:	89 d8                	mov    %ebx,%eax
  801817:	03 45 0c             	add    0xc(%ebp),%eax
  80181a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181e:	89 3c 24             	mov    %edi,(%esp)
  801821:	e8 3f ff ff ff       	call   801765 <read>
		if (m < 0)
  801826:	85 c0                	test   %eax,%eax
  801828:	78 10                	js     80183a <readn+0x43>
			return m;
		if (m == 0)
  80182a:	85 c0                	test   %eax,%eax
  80182c:	74 0a                	je     801838 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80182e:	01 c3                	add    %eax,%ebx
  801830:	39 f3                	cmp    %esi,%ebx
  801832:	72 d9                	jb     80180d <readn+0x16>
  801834:	89 d8                	mov    %ebx,%eax
  801836:	eb 02                	jmp    80183a <readn+0x43>
  801838:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80183a:	83 c4 1c             	add    $0x1c,%esp
  80183d:	5b                   	pop    %ebx
  80183e:	5e                   	pop    %esi
  80183f:	5f                   	pop    %edi
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	53                   	push   %ebx
  801846:	83 ec 24             	sub    $0x24,%esp
  801849:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801853:	89 1c 24             	mov    %ebx,(%esp)
  801856:	e8 7b fc ff ff       	call   8014d6 <fd_lookup>
  80185b:	89 c2                	mov    %eax,%edx
  80185d:	85 d2                	test   %edx,%edx
  80185f:	78 68                	js     8018c9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801864:	89 44 24 04          	mov    %eax,0x4(%esp)
  801868:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186b:	8b 00                	mov    (%eax),%eax
  80186d:	89 04 24             	mov    %eax,(%esp)
  801870:	e8 b7 fc ff ff       	call   80152c <dev_lookup>
  801875:	85 c0                	test   %eax,%eax
  801877:	78 50                	js     8018c9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801880:	75 23                	jne    8018a5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801882:	a1 08 40 80 00       	mov    0x804008,%eax
  801887:	8b 40 48             	mov    0x48(%eax),%eax
  80188a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801892:	c7 04 24 89 2b 80 00 	movl   $0x802b89,(%esp)
  801899:	e8 da ea ff ff       	call   800378 <cprintf>
		return -E_INVAL;
  80189e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018a3:	eb 24                	jmp    8018c9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ab:	85 d2                	test   %edx,%edx
  8018ad:	74 15                	je     8018c4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018af:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	ff d2                	call   *%edx
  8018c2:	eb 05                	jmp    8018c9 <write+0x87>
		return -E_NOT_SUPP;
  8018c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018c9:	83 c4 24             	add    $0x24,%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	89 04 24             	mov    %eax,(%esp)
  8018e2:	e8 ef fb ff ff       	call   8014d6 <fd_lookup>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 0e                	js     8018f9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    

008018fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 24             	sub    $0x24,%esp
  801902:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801905:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190c:	89 1c 24             	mov    %ebx,(%esp)
  80190f:	e8 c2 fb ff ff       	call   8014d6 <fd_lookup>
  801914:	89 c2                	mov    %eax,%edx
  801916:	85 d2                	test   %edx,%edx
  801918:	78 61                	js     80197b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801924:	8b 00                	mov    (%eax),%eax
  801926:	89 04 24             	mov    %eax,(%esp)
  801929:	e8 fe fb ff ff       	call   80152c <dev_lookup>
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 49                	js     80197b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801932:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801935:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801939:	75 23                	jne    80195e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80193b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801940:	8b 40 48             	mov    0x48(%eax),%eax
  801943:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194b:	c7 04 24 4c 2b 80 00 	movl   $0x802b4c,(%esp)
  801952:	e8 21 ea ff ff       	call   800378 <cprintf>
		return -E_INVAL;
  801957:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80195c:	eb 1d                	jmp    80197b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80195e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801961:	8b 52 18             	mov    0x18(%edx),%edx
  801964:	85 d2                	test   %edx,%edx
  801966:	74 0e                	je     801976 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80196b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80196f:	89 04 24             	mov    %eax,(%esp)
  801972:	ff d2                	call   *%edx
  801974:	eb 05                	jmp    80197b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801976:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80197b:	83 c4 24             	add    $0x24,%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	53                   	push   %ebx
  801985:	83 ec 24             	sub    $0x24,%esp
  801988:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80198b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801992:	8b 45 08             	mov    0x8(%ebp),%eax
  801995:	89 04 24             	mov    %eax,(%esp)
  801998:	e8 39 fb ff ff       	call   8014d6 <fd_lookup>
  80199d:	89 c2                	mov    %eax,%edx
  80199f:	85 d2                	test   %edx,%edx
  8019a1:	78 52                	js     8019f5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ad:	8b 00                	mov    (%eax),%eax
  8019af:	89 04 24             	mov    %eax,(%esp)
  8019b2:	e8 75 fb ff ff       	call   80152c <dev_lookup>
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	78 3a                	js     8019f5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8019bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019c2:	74 2c                	je     8019f0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019ce:	00 00 00 
	stat->st_isdir = 0;
  8019d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d8:	00 00 00 
	stat->st_dev = dev;
  8019db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019e8:	89 14 24             	mov    %edx,(%esp)
  8019eb:	ff 50 14             	call   *0x14(%eax)
  8019ee:	eb 05                	jmp    8019f5 <fstat+0x74>
		return -E_NOT_SUPP;
  8019f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8019f5:	83 c4 24             	add    $0x24,%esp
  8019f8:	5b                   	pop    %ebx
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    

008019fb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a0a:	00 
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 fb 01 00 00       	call   801c11 <open>
  801a16:	89 c3                	mov    %eax,%ebx
  801a18:	85 db                	test   %ebx,%ebx
  801a1a:	78 1b                	js     801a37 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a23:	89 1c 24             	mov    %ebx,(%esp)
  801a26:	e8 56 ff ff ff       	call   801981 <fstat>
  801a2b:	89 c6                	mov    %eax,%esi
	close(fd);
  801a2d:	89 1c 24             	mov    %ebx,(%esp)
  801a30:	e8 cd fb ff ff       	call   801602 <close>
	return r;
  801a35:	89 f0                	mov    %esi,%eax
}
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	83 ec 10             	sub    $0x10,%esp
  801a46:	89 c6                	mov    %eax,%esi
  801a48:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a4a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a51:	75 11                	jne    801a64 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a5a:	e8 c0 f9 ff ff       	call   80141f <ipc_find_env>
  801a5f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a64:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a6b:	00 
  801a6c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a73:	00 
  801a74:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a78:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7d:	89 04 24             	mov    %eax,(%esp)
  801a80:	e8 33 f9 ff ff       	call   8013b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a8c:	00 
  801a8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a98:	e8 b3 f8 ff ff       	call   801350 <ipc_recv>
}
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801aad:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801abd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac2:	b8 02 00 00 00       	mov    $0x2,%eax
  801ac7:	e8 72 ff ff ff       	call   801a3e <fsipc>
}
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <devfile_flush>:
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad7:	8b 40 0c             	mov    0xc(%eax),%eax
  801ada:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801adf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ae9:	e8 50 ff ff ff       	call   801a3e <fsipc>
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <devfile_stat>:
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	53                   	push   %ebx
  801af4:	83 ec 14             	sub    $0x14,%esp
  801af7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	8b 40 0c             	mov    0xc(%eax),%eax
  801b00:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b05:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0a:	b8 05 00 00 00       	mov    $0x5,%eax
  801b0f:	e8 2a ff ff ff       	call   801a3e <fsipc>
  801b14:	89 c2                	mov    %eax,%edx
  801b16:	85 d2                	test   %edx,%edx
  801b18:	78 2b                	js     801b45 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b1a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b21:	00 
  801b22:	89 1c 24             	mov    %ebx,(%esp)
  801b25:	e8 7d ee ff ff       	call   8009a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b2a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b2f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b35:	a1 84 50 80 00       	mov    0x805084,%eax
  801b3a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b45:	83 c4 14             	add    $0x14,%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <devfile_write>:
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801b51:	c7 44 24 08 b8 2b 80 	movl   $0x802bb8,0x8(%esp)
  801b58:	00 
  801b59:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801b60:	00 
  801b61:	c7 04 24 d6 2b 80 00 	movl   $0x802bd6,(%esp)
  801b68:	e8 12 e7 ff ff       	call   80027f <_panic>

00801b6d <devfile_read>:
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	56                   	push   %esi
  801b71:	53                   	push   %ebx
  801b72:	83 ec 10             	sub    $0x10,%esp
  801b75:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b83:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b89:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b93:	e8 a6 fe ff ff       	call   801a3e <fsipc>
  801b98:	89 c3                	mov    %eax,%ebx
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 6a                	js     801c08 <devfile_read+0x9b>
	assert(r <= n);
  801b9e:	39 c6                	cmp    %eax,%esi
  801ba0:	73 24                	jae    801bc6 <devfile_read+0x59>
  801ba2:	c7 44 24 0c e1 2b 80 	movl   $0x802be1,0xc(%esp)
  801ba9:	00 
  801baa:	c7 44 24 08 e8 2b 80 	movl   $0x802be8,0x8(%esp)
  801bb1:	00 
  801bb2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801bb9:	00 
  801bba:	c7 04 24 d6 2b 80 00 	movl   $0x802bd6,(%esp)
  801bc1:	e8 b9 e6 ff ff       	call   80027f <_panic>
	assert(r <= PGSIZE);
  801bc6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bcb:	7e 24                	jle    801bf1 <devfile_read+0x84>
  801bcd:	c7 44 24 0c fd 2b 80 	movl   $0x802bfd,0xc(%esp)
  801bd4:	00 
  801bd5:	c7 44 24 08 e8 2b 80 	movl   $0x802be8,0x8(%esp)
  801bdc:	00 
  801bdd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801be4:	00 
  801be5:	c7 04 24 d6 2b 80 00 	movl   $0x802bd6,(%esp)
  801bec:	e8 8e e6 ff ff       	call   80027f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bf1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bfc:	00 
  801bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c00:	89 04 24             	mov    %eax,(%esp)
  801c03:	e8 3c ef ff ff       	call   800b44 <memmove>
}
  801c08:	89 d8                	mov    %ebx,%eax
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <open>:
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	53                   	push   %ebx
  801c15:	83 ec 24             	sub    $0x24,%esp
  801c18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c1b:	89 1c 24             	mov    %ebx,(%esp)
  801c1e:	e8 4d ed ff ff       	call   800970 <strlen>
  801c23:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c28:	7f 60                	jg     801c8a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801c2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2d:	89 04 24             	mov    %eax,(%esp)
  801c30:	e8 52 f8 ff ff       	call   801487 <fd_alloc>
  801c35:	89 c2                	mov    %eax,%edx
  801c37:	85 d2                	test   %edx,%edx
  801c39:	78 54                	js     801c8f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801c3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c46:	e8 5c ed ff ff       	call   8009a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c56:	b8 01 00 00 00       	mov    $0x1,%eax
  801c5b:	e8 de fd ff ff       	call   801a3e <fsipc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	85 c0                	test   %eax,%eax
  801c64:	79 17                	jns    801c7d <open+0x6c>
		fd_close(fd, 0);
  801c66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c6d:	00 
  801c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c71:	89 04 24             	mov    %eax,(%esp)
  801c74:	e8 08 f9 ff ff       	call   801581 <fd_close>
		return r;
  801c79:	89 d8                	mov    %ebx,%eax
  801c7b:	eb 12                	jmp    801c8f <open+0x7e>
	return fd2num(fd);
  801c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c80:	89 04 24             	mov    %eax,(%esp)
  801c83:	e8 d8 f7 ff ff       	call   801460 <fd2num>
  801c88:	eb 05                	jmp    801c8f <open+0x7e>
		return -E_BAD_PATH;
  801c8a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801c8f:	83 c4 24             	add    $0x24,%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ca5:	e8 94 fd ff ff       	call   801a3e <fsipc>
}
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cb2:	89 d0                	mov    %edx,%eax
  801cb4:	c1 e8 16             	shr    $0x16,%eax
  801cb7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801cc3:	f6 c1 01             	test   $0x1,%cl
  801cc6:	74 1d                	je     801ce5 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801cc8:	c1 ea 0c             	shr    $0xc,%edx
  801ccb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cd2:	f6 c2 01             	test   $0x1,%dl
  801cd5:	74 0e                	je     801ce5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cd7:	c1 ea 0c             	shr    $0xc,%edx
  801cda:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ce1:	ef 
  801ce2:	0f b7 c0             	movzwl %ax,%eax
}
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 10             	sub    $0x10,%esp
  801cef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	89 04 24             	mov    %eax,(%esp)
  801cf8:	e8 73 f7 ff ff       	call   801470 <fd2data>
  801cfd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cff:	c7 44 24 04 09 2c 80 	movl   $0x802c09,0x4(%esp)
  801d06:	00 
  801d07:	89 1c 24             	mov    %ebx,(%esp)
  801d0a:	e8 98 ec ff ff       	call   8009a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d0f:	8b 46 04             	mov    0x4(%esi),%eax
  801d12:	2b 06                	sub    (%esi),%eax
  801d14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d1a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d21:	00 00 00 
	stat->st_dev = &devpipe;
  801d24:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d2b:	30 80 00 
	return 0;
}
  801d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	5b                   	pop    %ebx
  801d37:	5e                   	pop    %esi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 14             	sub    $0x14,%esp
  801d41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4f:	e8 16 f1 ff ff       	call   800e6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d54:	89 1c 24             	mov    %ebx,(%esp)
  801d57:	e8 14 f7 ff ff       	call   801470 <fd2data>
  801d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d67:	e8 fe f0 ff ff       	call   800e6a <sys_page_unmap>
}
  801d6c:	83 c4 14             	add    $0x14,%esp
  801d6f:	5b                   	pop    %ebx
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    

00801d72 <_pipeisclosed>:
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	83 ec 2c             	sub    $0x2c,%esp
  801d7b:	89 c6                	mov    %eax,%esi
  801d7d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801d80:	a1 08 40 80 00       	mov    0x804008,%eax
  801d85:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d88:	89 34 24             	mov    %esi,(%esp)
  801d8b:	e8 1c ff ff ff       	call   801cac <pageref>
  801d90:	89 c7                	mov    %eax,%edi
  801d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d95:	89 04 24             	mov    %eax,(%esp)
  801d98:	e8 0f ff ff ff       	call   801cac <pageref>
  801d9d:	39 c7                	cmp    %eax,%edi
  801d9f:	0f 94 c2             	sete   %dl
  801da2:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801da5:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801dab:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801dae:	39 fb                	cmp    %edi,%ebx
  801db0:	74 21                	je     801dd3 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801db2:	84 d2                	test   %dl,%dl
  801db4:	74 ca                	je     801d80 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801db6:	8b 51 58             	mov    0x58(%ecx),%edx
  801db9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dbd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dc5:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  801dcc:	e8 a7 e5 ff ff       	call   800378 <cprintf>
  801dd1:	eb ad                	jmp    801d80 <_pipeisclosed+0xe>
}
  801dd3:	83 c4 2c             	add    $0x2c,%esp
  801dd6:	5b                   	pop    %ebx
  801dd7:	5e                   	pop    %esi
  801dd8:	5f                   	pop    %edi
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <devpipe_write>:
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	57                   	push   %edi
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
  801de1:	83 ec 1c             	sub    $0x1c,%esp
  801de4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801de7:	89 34 24             	mov    %esi,(%esp)
  801dea:	e8 81 f6 ff ff       	call   801470 <fd2data>
  801def:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801df1:	bf 00 00 00 00       	mov    $0x0,%edi
  801df6:	eb 45                	jmp    801e3d <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801df8:	89 da                	mov    %ebx,%edx
  801dfa:	89 f0                	mov    %esi,%eax
  801dfc:	e8 71 ff ff ff       	call   801d72 <_pipeisclosed>
  801e01:	85 c0                	test   %eax,%eax
  801e03:	75 41                	jne    801e46 <devpipe_write+0x6b>
			sys_yield();
  801e05:	e8 9a ef ff ff       	call   800da4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e0a:	8b 43 04             	mov    0x4(%ebx),%eax
  801e0d:	8b 0b                	mov    (%ebx),%ecx
  801e0f:	8d 51 20             	lea    0x20(%ecx),%edx
  801e12:	39 d0                	cmp    %edx,%eax
  801e14:	73 e2                	jae    801df8 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e19:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e1d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e20:	99                   	cltd   
  801e21:	c1 ea 1b             	shr    $0x1b,%edx
  801e24:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801e27:	83 e1 1f             	and    $0x1f,%ecx
  801e2a:	29 d1                	sub    %edx,%ecx
  801e2c:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801e30:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801e34:	83 c0 01             	add    $0x1,%eax
  801e37:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e3a:	83 c7 01             	add    $0x1,%edi
  801e3d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e40:	75 c8                	jne    801e0a <devpipe_write+0x2f>
	return i;
  801e42:	89 f8                	mov    %edi,%eax
  801e44:	eb 05                	jmp    801e4b <devpipe_write+0x70>
				return 0;
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e4b:	83 c4 1c             	add    $0x1c,%esp
  801e4e:	5b                   	pop    %ebx
  801e4f:	5e                   	pop    %esi
  801e50:	5f                   	pop    %edi
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <devpipe_read>:
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	57                   	push   %edi
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
  801e59:	83 ec 1c             	sub    $0x1c,%esp
  801e5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e5f:	89 3c 24             	mov    %edi,(%esp)
  801e62:	e8 09 f6 ff ff       	call   801470 <fd2data>
  801e67:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e69:	be 00 00 00 00       	mov    $0x0,%esi
  801e6e:	eb 3d                	jmp    801ead <devpipe_read+0x5a>
			if (i > 0)
  801e70:	85 f6                	test   %esi,%esi
  801e72:	74 04                	je     801e78 <devpipe_read+0x25>
				return i;
  801e74:	89 f0                	mov    %esi,%eax
  801e76:	eb 43                	jmp    801ebb <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801e78:	89 da                	mov    %ebx,%edx
  801e7a:	89 f8                	mov    %edi,%eax
  801e7c:	e8 f1 fe ff ff       	call   801d72 <_pipeisclosed>
  801e81:	85 c0                	test   %eax,%eax
  801e83:	75 31                	jne    801eb6 <devpipe_read+0x63>
			sys_yield();
  801e85:	e8 1a ef ff ff       	call   800da4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e8a:	8b 03                	mov    (%ebx),%eax
  801e8c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e8f:	74 df                	je     801e70 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e91:	99                   	cltd   
  801e92:	c1 ea 1b             	shr    $0x1b,%edx
  801e95:	01 d0                	add    %edx,%eax
  801e97:	83 e0 1f             	and    $0x1f,%eax
  801e9a:	29 d0                	sub    %edx,%eax
  801e9c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ea7:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801eaa:	83 c6 01             	add    $0x1,%esi
  801ead:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb0:	75 d8                	jne    801e8a <devpipe_read+0x37>
	return i;
  801eb2:	89 f0                	mov    %esi,%eax
  801eb4:	eb 05                	jmp    801ebb <devpipe_read+0x68>
				return 0;
  801eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ebb:	83 c4 1c             	add    $0x1c,%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5e                   	pop    %esi
  801ec0:	5f                   	pop    %edi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <pipe>:
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	56                   	push   %esi
  801ec7:	53                   	push   %ebx
  801ec8:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ecb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ece:	89 04 24             	mov    %eax,(%esp)
  801ed1:	e8 b1 f5 ff ff       	call   801487 <fd_alloc>
  801ed6:	89 c2                	mov    %eax,%edx
  801ed8:	85 d2                	test   %edx,%edx
  801eda:	0f 88 4d 01 00 00    	js     80202d <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ee7:	00 
  801ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef6:	e8 c8 ee ff ff       	call   800dc3 <sys_page_alloc>
  801efb:	89 c2                	mov    %eax,%edx
  801efd:	85 d2                	test   %edx,%edx
  801eff:	0f 88 28 01 00 00    	js     80202d <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801f05:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f08:	89 04 24             	mov    %eax,(%esp)
  801f0b:	e8 77 f5 ff ff       	call   801487 <fd_alloc>
  801f10:	89 c3                	mov    %eax,%ebx
  801f12:	85 c0                	test   %eax,%eax
  801f14:	0f 88 fe 00 00 00    	js     802018 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f21:	00 
  801f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f30:	e8 8e ee ff ff       	call   800dc3 <sys_page_alloc>
  801f35:	89 c3                	mov    %eax,%ebx
  801f37:	85 c0                	test   %eax,%eax
  801f39:	0f 88 d9 00 00 00    	js     802018 <pipe+0x155>
	va = fd2data(fd0);
  801f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f42:	89 04 24             	mov    %eax,(%esp)
  801f45:	e8 26 f5 ff ff       	call   801470 <fd2data>
  801f4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f4c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f53:	00 
  801f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f5f:	e8 5f ee ff ff       	call   800dc3 <sys_page_alloc>
  801f64:	89 c3                	mov    %eax,%ebx
  801f66:	85 c0                	test   %eax,%eax
  801f68:	0f 88 97 00 00 00    	js     802005 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f71:	89 04 24             	mov    %eax,(%esp)
  801f74:	e8 f7 f4 ff ff       	call   801470 <fd2data>
  801f79:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f80:	00 
  801f81:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f8c:	00 
  801f8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f98:	e8 7a ee ff ff       	call   800e17 <sys_page_map>
  801f9d:	89 c3                	mov    %eax,%ebx
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	78 52                	js     801ff5 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801fa3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801fb8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd0:	89 04 24             	mov    %eax,(%esp)
  801fd3:	e8 88 f4 ff ff       	call   801460 <fd2num>
  801fd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fdb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe0:	89 04 24             	mov    %eax,(%esp)
  801fe3:	e8 78 f4 ff ff       	call   801460 <fd2num>
  801fe8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801feb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fee:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff3:	eb 38                	jmp    80202d <pipe+0x16a>
	sys_page_unmap(0, va);
  801ff5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ff9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802000:	e8 65 ee ff ff       	call   800e6a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  802005:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802008:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802013:	e8 52 ee ff ff       	call   800e6a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  802018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802026:	e8 3f ee ff ff       	call   800e6a <sys_page_unmap>
  80202b:	89 d8                	mov    %ebx,%eax
}
  80202d:	83 c4 30             	add    $0x30,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <pipeisclosed>:
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80203a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802041:	8b 45 08             	mov    0x8(%ebp),%eax
  802044:	89 04 24             	mov    %eax,(%esp)
  802047:	e8 8a f4 ff ff       	call   8014d6 <fd_lookup>
  80204c:	89 c2                	mov    %eax,%edx
  80204e:	85 d2                	test   %edx,%edx
  802050:	78 15                	js     802067 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  802052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 13 f4 ff ff       	call   801470 <fd2data>
	return _pipeisclosed(fd, p);
  80205d:	89 c2                	mov    %eax,%edx
  80205f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802062:	e8 0b fd ff ff       	call   801d72 <_pipeisclosed>
}
  802067:	c9                   	leave  
  802068:	c3                   	ret    
  802069:	66 90                	xchg   %ax,%ax
  80206b:	66 90                	xchg   %ax,%ax
  80206d:	66 90                	xchg   %ax,%ax
  80206f:	90                   	nop

00802070 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802080:	c7 44 24 04 28 2c 80 	movl   $0x802c28,0x4(%esp)
  802087:	00 
  802088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 14 e9 ff ff       	call   8009a7 <strcpy>
	return 0;
}
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
  802098:	c9                   	leave  
  802099:	c3                   	ret    

0080209a <devcons_write>:
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	57                   	push   %edi
  80209e:	56                   	push   %esi
  80209f:	53                   	push   %ebx
  8020a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  8020a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8020b1:	eb 31                	jmp    8020e4 <devcons_write+0x4a>
		m = n - tot;
  8020b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8020b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020b8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  8020bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020c0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020c3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020c7:	03 45 0c             	add    0xc(%ebp),%eax
  8020ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ce:	89 3c 24             	mov    %edi,(%esp)
  8020d1:	e8 6e ea ff ff       	call   800b44 <memmove>
		sys_cputs(buf, m);
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	89 3c 24             	mov    %edi,(%esp)
  8020dd:	e8 14 ec ff ff       	call   800cf6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020e2:	01 f3                	add    %esi,%ebx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020e9:	72 c8                	jb     8020b3 <devcons_write+0x19>
}
  8020eb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020f1:	5b                   	pop    %ebx
  8020f2:	5e                   	pop    %esi
  8020f3:	5f                   	pop    %edi
  8020f4:	5d                   	pop    %ebp
  8020f5:	c3                   	ret    

008020f6 <devcons_read>:
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  8020fc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802101:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802105:	75 07                	jne    80210e <devcons_read+0x18>
  802107:	eb 2a                	jmp    802133 <devcons_read+0x3d>
		sys_yield();
  802109:	e8 96 ec ff ff       	call   800da4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80210e:	66 90                	xchg   %ax,%ax
  802110:	e8 ff eb ff ff       	call   800d14 <sys_cgetc>
  802115:	85 c0                	test   %eax,%eax
  802117:	74 f0                	je     802109 <devcons_read+0x13>
	if (c < 0)
  802119:	85 c0                	test   %eax,%eax
  80211b:	78 16                	js     802133 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80211d:	83 f8 04             	cmp    $0x4,%eax
  802120:	74 0c                	je     80212e <devcons_read+0x38>
	*(char*)vbuf = c;
  802122:	8b 55 0c             	mov    0xc(%ebp),%edx
  802125:	88 02                	mov    %al,(%edx)
	return 1;
  802127:	b8 01 00 00 00       	mov    $0x1,%eax
  80212c:	eb 05                	jmp    802133 <devcons_read+0x3d>
		return 0;
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802133:	c9                   	leave  
  802134:	c3                   	ret    

00802135 <cputchar>:
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80213b:	8b 45 08             	mov    0x8(%ebp),%eax
  80213e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802141:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802148:	00 
  802149:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80214c:	89 04 24             	mov    %eax,(%esp)
  80214f:	e8 a2 eb ff ff       	call   800cf6 <sys_cputs>
}
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <getchar>:
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80215c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802163:	00 
  802164:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802167:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802172:	e8 ee f5 ff ff       	call   801765 <read>
	if (r < 0)
  802177:	85 c0                	test   %eax,%eax
  802179:	78 0f                	js     80218a <getchar+0x34>
	if (r < 1)
  80217b:	85 c0                	test   %eax,%eax
  80217d:	7e 06                	jle    802185 <getchar+0x2f>
	return c;
  80217f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802183:	eb 05                	jmp    80218a <getchar+0x34>
		return -E_EOF;
  802185:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80218a:	c9                   	leave  
  80218b:	c3                   	ret    

0080218c <iscons>:
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802195:	89 44 24 04          	mov    %eax,0x4(%esp)
  802199:	8b 45 08             	mov    0x8(%ebp),%eax
  80219c:	89 04 24             	mov    %eax,(%esp)
  80219f:	e8 32 f3 ff ff       	call   8014d6 <fd_lookup>
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 11                	js     8021b9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021b1:	39 10                	cmp    %edx,(%eax)
  8021b3:	0f 94 c0             	sete   %al
  8021b6:	0f b6 c0             	movzbl %al,%eax
}
  8021b9:	c9                   	leave  
  8021ba:	c3                   	ret    

008021bb <opencons>:
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8021c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c4:	89 04 24             	mov    %eax,(%esp)
  8021c7:	e8 bb f2 ff ff       	call   801487 <fd_alloc>
		return r;
  8021cc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	78 40                	js     802212 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021d9:	00 
  8021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e8:	e8 d6 eb ff ff       	call   800dc3 <sys_page_alloc>
		return r;
  8021ed:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	78 1f                	js     802212 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8021f3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802201:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802208:	89 04 24             	mov    %eax,(%esp)
  80220b:	e8 50 f2 ff ff       	call   801460 <fd2num>
  802210:	89 c2                	mov    %eax,%edx
}
  802212:	89 d0                	mov    %edx,%eax
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  80221c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802223:	75 70                	jne    802295 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802225:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80222c:	00 
  80222d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802234:	ee 
  802235:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80223c:	e8 82 eb ff ff       	call   800dc3 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  802241:	85 c0                	test   %eax,%eax
  802243:	79 1c                	jns    802261 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  802245:	c7 44 24 08 34 2c 80 	movl   $0x802c34,0x8(%esp)
  80224c:	00 
  80224d:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  802254:	00 
  802255:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  80225c:	e8 1e e0 ff ff       	call   80027f <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  802261:	c7 44 24 04 9f 22 80 	movl   $0x80229f,0x4(%esp)
  802268:	00 
  802269:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802270:	e8 ee ec ff ff       	call   800f63 <sys_env_set_pgfault_upcall>
        if(r < 0)
  802275:	85 c0                	test   %eax,%eax
  802277:	79 1c                	jns    802295 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  802279:	c7 44 24 08 5c 2c 80 	movl   $0x802c5c,0x8(%esp)
  802280:	00 
  802281:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  802288:	00 
  802289:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  802290:	e8 ea df ff ff       	call   80027f <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802295:	8b 45 08             	mov    0x8(%ebp),%eax
  802298:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80229d:	c9                   	leave  
  80229e:	c3                   	ret    

0080229f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80229f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022a0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022a5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022a7:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  8022aa:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  8022ae:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  8022b2:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  8022b4:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  8022b6:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  8022b7:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  8022ba:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  8022bc:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  8022bf:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  8022c0:	83 c4 04             	add    $0x4,%esp
    popf;
  8022c3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  8022c4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  8022c5:	c3                   	ret    
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__udivdi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	83 ec 0c             	sub    $0xc,%esp
  8022d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8022da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8022de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8022e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022ec:	89 ea                	mov    %ebp,%edx
  8022ee:	89 0c 24             	mov    %ecx,(%esp)
  8022f1:	75 2d                	jne    802320 <__udivdi3+0x50>
  8022f3:	39 e9                	cmp    %ebp,%ecx
  8022f5:	77 61                	ja     802358 <__udivdi3+0x88>
  8022f7:	85 c9                	test   %ecx,%ecx
  8022f9:	89 ce                	mov    %ecx,%esi
  8022fb:	75 0b                	jne    802308 <__udivdi3+0x38>
  8022fd:	b8 01 00 00 00       	mov    $0x1,%eax
  802302:	31 d2                	xor    %edx,%edx
  802304:	f7 f1                	div    %ecx
  802306:	89 c6                	mov    %eax,%esi
  802308:	31 d2                	xor    %edx,%edx
  80230a:	89 e8                	mov    %ebp,%eax
  80230c:	f7 f6                	div    %esi
  80230e:	89 c5                	mov    %eax,%ebp
  802310:	89 f8                	mov    %edi,%eax
  802312:	f7 f6                	div    %esi
  802314:	89 ea                	mov    %ebp,%edx
  802316:	83 c4 0c             	add    $0xc,%esp
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	39 e8                	cmp    %ebp,%eax
  802322:	77 24                	ja     802348 <__udivdi3+0x78>
  802324:	0f bd e8             	bsr    %eax,%ebp
  802327:	83 f5 1f             	xor    $0x1f,%ebp
  80232a:	75 3c                	jne    802368 <__udivdi3+0x98>
  80232c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802330:	39 34 24             	cmp    %esi,(%esp)
  802333:	0f 86 9f 00 00 00    	jbe    8023d8 <__udivdi3+0x108>
  802339:	39 d0                	cmp    %edx,%eax
  80233b:	0f 82 97 00 00 00    	jb     8023d8 <__udivdi3+0x108>
  802341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802348:	31 d2                	xor    %edx,%edx
  80234a:	31 c0                	xor    %eax,%eax
  80234c:	83 c4 0c             	add    $0xc,%esp
  80234f:	5e                   	pop    %esi
  802350:	5f                   	pop    %edi
  802351:	5d                   	pop    %ebp
  802352:	c3                   	ret    
  802353:	90                   	nop
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	89 f8                	mov    %edi,%eax
  80235a:	f7 f1                	div    %ecx
  80235c:	31 d2                	xor    %edx,%edx
  80235e:	83 c4 0c             	add    $0xc,%esp
  802361:	5e                   	pop    %esi
  802362:	5f                   	pop    %edi
  802363:	5d                   	pop    %ebp
  802364:	c3                   	ret    
  802365:	8d 76 00             	lea    0x0(%esi),%esi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	8b 3c 24             	mov    (%esp),%edi
  80236d:	d3 e0                	shl    %cl,%eax
  80236f:	89 c6                	mov    %eax,%esi
  802371:	b8 20 00 00 00       	mov    $0x20,%eax
  802376:	29 e8                	sub    %ebp,%eax
  802378:	89 c1                	mov    %eax,%ecx
  80237a:	d3 ef                	shr    %cl,%edi
  80237c:	89 e9                	mov    %ebp,%ecx
  80237e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802382:	8b 3c 24             	mov    (%esp),%edi
  802385:	09 74 24 08          	or     %esi,0x8(%esp)
  802389:	89 d6                	mov    %edx,%esi
  80238b:	d3 e7                	shl    %cl,%edi
  80238d:	89 c1                	mov    %eax,%ecx
  80238f:	89 3c 24             	mov    %edi,(%esp)
  802392:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802396:	d3 ee                	shr    %cl,%esi
  802398:	89 e9                	mov    %ebp,%ecx
  80239a:	d3 e2                	shl    %cl,%edx
  80239c:	89 c1                	mov    %eax,%ecx
  80239e:	d3 ef                	shr    %cl,%edi
  8023a0:	09 d7                	or     %edx,%edi
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	89 f8                	mov    %edi,%eax
  8023a6:	f7 74 24 08          	divl   0x8(%esp)
  8023aa:	89 d6                	mov    %edx,%esi
  8023ac:	89 c7                	mov    %eax,%edi
  8023ae:	f7 24 24             	mull   (%esp)
  8023b1:	39 d6                	cmp    %edx,%esi
  8023b3:	89 14 24             	mov    %edx,(%esp)
  8023b6:	72 30                	jb     8023e8 <__udivdi3+0x118>
  8023b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023bc:	89 e9                	mov    %ebp,%ecx
  8023be:	d3 e2                	shl    %cl,%edx
  8023c0:	39 c2                	cmp    %eax,%edx
  8023c2:	73 05                	jae    8023c9 <__udivdi3+0xf9>
  8023c4:	3b 34 24             	cmp    (%esp),%esi
  8023c7:	74 1f                	je     8023e8 <__udivdi3+0x118>
  8023c9:	89 f8                	mov    %edi,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	e9 7a ff ff ff       	jmp    80234c <__udivdi3+0x7c>
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	b8 01 00 00 00       	mov    $0x1,%eax
  8023df:	e9 68 ff ff ff       	jmp    80234c <__udivdi3+0x7c>
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	83 c4 0c             	add    $0xc,%esp
  8023f0:	5e                   	pop    %esi
  8023f1:	5f                   	pop    %edi
  8023f2:	5d                   	pop    %ebp
  8023f3:	c3                   	ret    
  8023f4:	66 90                	xchg   %ax,%ax
  8023f6:	66 90                	xchg   %ax,%ax
  8023f8:	66 90                	xchg   %ax,%ax
  8023fa:	66 90                	xchg   %ax,%ax
  8023fc:	66 90                	xchg   %ax,%ax
  8023fe:	66 90                	xchg   %ax,%ax

00802400 <__umoddi3>:
  802400:	55                   	push   %ebp
  802401:	57                   	push   %edi
  802402:	56                   	push   %esi
  802403:	83 ec 14             	sub    $0x14,%esp
  802406:	8b 44 24 28          	mov    0x28(%esp),%eax
  80240a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80240e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802412:	89 c7                	mov    %eax,%edi
  802414:	89 44 24 04          	mov    %eax,0x4(%esp)
  802418:	8b 44 24 30          	mov    0x30(%esp),%eax
  80241c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802420:	89 34 24             	mov    %esi,(%esp)
  802423:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802427:	85 c0                	test   %eax,%eax
  802429:	89 c2                	mov    %eax,%edx
  80242b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80242f:	75 17                	jne    802448 <__umoddi3+0x48>
  802431:	39 fe                	cmp    %edi,%esi
  802433:	76 4b                	jbe    802480 <__umoddi3+0x80>
  802435:	89 c8                	mov    %ecx,%eax
  802437:	89 fa                	mov    %edi,%edx
  802439:	f7 f6                	div    %esi
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	31 d2                	xor    %edx,%edx
  80243f:	83 c4 14             	add    $0x14,%esp
  802442:	5e                   	pop    %esi
  802443:	5f                   	pop    %edi
  802444:	5d                   	pop    %ebp
  802445:	c3                   	ret    
  802446:	66 90                	xchg   %ax,%ax
  802448:	39 f8                	cmp    %edi,%eax
  80244a:	77 54                	ja     8024a0 <__umoddi3+0xa0>
  80244c:	0f bd e8             	bsr    %eax,%ebp
  80244f:	83 f5 1f             	xor    $0x1f,%ebp
  802452:	75 5c                	jne    8024b0 <__umoddi3+0xb0>
  802454:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802458:	39 3c 24             	cmp    %edi,(%esp)
  80245b:	0f 87 e7 00 00 00    	ja     802548 <__umoddi3+0x148>
  802461:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802465:	29 f1                	sub    %esi,%ecx
  802467:	19 c7                	sbb    %eax,%edi
  802469:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80246d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802471:	8b 44 24 08          	mov    0x8(%esp),%eax
  802475:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802479:	83 c4 14             	add    $0x14,%esp
  80247c:	5e                   	pop    %esi
  80247d:	5f                   	pop    %edi
  80247e:	5d                   	pop    %ebp
  80247f:	c3                   	ret    
  802480:	85 f6                	test   %esi,%esi
  802482:	89 f5                	mov    %esi,%ebp
  802484:	75 0b                	jne    802491 <__umoddi3+0x91>
  802486:	b8 01 00 00 00       	mov    $0x1,%eax
  80248b:	31 d2                	xor    %edx,%edx
  80248d:	f7 f6                	div    %esi
  80248f:	89 c5                	mov    %eax,%ebp
  802491:	8b 44 24 04          	mov    0x4(%esp),%eax
  802495:	31 d2                	xor    %edx,%edx
  802497:	f7 f5                	div    %ebp
  802499:	89 c8                	mov    %ecx,%eax
  80249b:	f7 f5                	div    %ebp
  80249d:	eb 9c                	jmp    80243b <__umoddi3+0x3b>
  80249f:	90                   	nop
  8024a0:	89 c8                	mov    %ecx,%eax
  8024a2:	89 fa                	mov    %edi,%edx
  8024a4:	83 c4 14             	add    $0x14,%esp
  8024a7:	5e                   	pop    %esi
  8024a8:	5f                   	pop    %edi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    
  8024ab:	90                   	nop
  8024ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	8b 04 24             	mov    (%esp),%eax
  8024b3:	be 20 00 00 00       	mov    $0x20,%esi
  8024b8:	89 e9                	mov    %ebp,%ecx
  8024ba:	29 ee                	sub    %ebp,%esi
  8024bc:	d3 e2                	shl    %cl,%edx
  8024be:	89 f1                	mov    %esi,%ecx
  8024c0:	d3 e8                	shr    %cl,%eax
  8024c2:	89 e9                	mov    %ebp,%ecx
  8024c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c8:	8b 04 24             	mov    (%esp),%eax
  8024cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8024cf:	89 fa                	mov    %edi,%edx
  8024d1:	d3 e0                	shl    %cl,%eax
  8024d3:	89 f1                	mov    %esi,%ecx
  8024d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8024dd:	d3 ea                	shr    %cl,%edx
  8024df:	89 e9                	mov    %ebp,%ecx
  8024e1:	d3 e7                	shl    %cl,%edi
  8024e3:	89 f1                	mov    %esi,%ecx
  8024e5:	d3 e8                	shr    %cl,%eax
  8024e7:	89 e9                	mov    %ebp,%ecx
  8024e9:	09 f8                	or     %edi,%eax
  8024eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8024ef:	f7 74 24 04          	divl   0x4(%esp)
  8024f3:	d3 e7                	shl    %cl,%edi
  8024f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024f9:	89 d7                	mov    %edx,%edi
  8024fb:	f7 64 24 08          	mull   0x8(%esp)
  8024ff:	39 d7                	cmp    %edx,%edi
  802501:	89 c1                	mov    %eax,%ecx
  802503:	89 14 24             	mov    %edx,(%esp)
  802506:	72 2c                	jb     802534 <__umoddi3+0x134>
  802508:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80250c:	72 22                	jb     802530 <__umoddi3+0x130>
  80250e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802512:	29 c8                	sub    %ecx,%eax
  802514:	19 d7                	sbb    %edx,%edi
  802516:	89 e9                	mov    %ebp,%ecx
  802518:	89 fa                	mov    %edi,%edx
  80251a:	d3 e8                	shr    %cl,%eax
  80251c:	89 f1                	mov    %esi,%ecx
  80251e:	d3 e2                	shl    %cl,%edx
  802520:	89 e9                	mov    %ebp,%ecx
  802522:	d3 ef                	shr    %cl,%edi
  802524:	09 d0                	or     %edx,%eax
  802526:	89 fa                	mov    %edi,%edx
  802528:	83 c4 14             	add    $0x14,%esp
  80252b:	5e                   	pop    %esi
  80252c:	5f                   	pop    %edi
  80252d:	5d                   	pop    %ebp
  80252e:	c3                   	ret    
  80252f:	90                   	nop
  802530:	39 d7                	cmp    %edx,%edi
  802532:	75 da                	jne    80250e <__umoddi3+0x10e>
  802534:	8b 14 24             	mov    (%esp),%edx
  802537:	89 c1                	mov    %eax,%ecx
  802539:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80253d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802541:	eb cb                	jmp    80250e <__umoddi3+0x10e>
  802543:	90                   	nop
  802544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802548:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80254c:	0f 82 0f ff ff ff    	jb     802461 <__umoddi3+0x61>
  802552:	e9 1a ff ff ff       	jmp    802471 <__umoddi3+0x71>
