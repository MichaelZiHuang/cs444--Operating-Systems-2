
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 b9 01 00 00       	call   8001ea <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  800043:	e8 fc 02 00 00       	call   800344 <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 e5 1c 00 00       	call   801d38 <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x44>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 6e 25 80 	movl   $0x80256e,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 77 25 80 00 	movl   $0x802577,(%esp)
  800072:	e8 d4 01 00 00       	call   80024b <_panic>
	if ((r = fork()) < 0)
  800077:	e8 96 10 00 00       	call   801112 <fork>
  80007c:	89 c7                	mov    %eax,%edi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6f>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 8c 25 80 	movl   $0x80258c,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 77 25 80 00 	movl   $0x802577,(%esp)
  80009d:	e8 a9 01 00 00       	call   80024b <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 75                	jne    80011b <umain+0xe8>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 01 14 00 00       	call   8014b2 <close>
		for (i = 0; i < 200; i++) {
  8000b1:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  8000b6:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000bb:	89 d8                	mov    %ebx,%eax
  8000bd:	f7 ee                	imul   %esi
  8000bf:	c1 fa 02             	sar    $0x2,%edx
  8000c2:	89 d8                	mov    %ebx,%eax
  8000c4:	c1 f8 1f             	sar    $0x1f,%eax
  8000c7:	29 c2                	sub    %eax,%edx
  8000c9:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000cc:	01 c0                	add    %eax,%eax
  8000ce:	39 c3                	cmp    %eax,%ebx
  8000d0:	75 10                	jne    8000e2 <umain+0xaf>
				cprintf("%d.", i);
  8000d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d6:	c7 04 24 95 25 80 00 	movl   $0x802595,(%esp)
  8000dd:	e8 62 02 00 00       	call   800344 <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000e2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8000e9:	00 
  8000ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000ed:	89 04 24             	mov    %eax,(%esp)
  8000f0:	e8 12 14 00 00       	call   801507 <dup>
			sys_yield();
  8000f5:	e8 6a 0c 00 00       	call   800d64 <sys_yield>
			close(10);
  8000fa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800101:	e8 ac 13 00 00       	call   8014b2 <close>
			sys_yield();
  800106:	e8 59 0c 00 00       	call   800d64 <sys_yield>
		for (i = 0; i < 200; i++) {
  80010b:	83 c3 01             	add    $0x1,%ebx
  80010e:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  800114:	75 a5                	jne    8000bb <umain+0x88>
		}
		exit();
  800116:	e8 17 01 00 00       	call   800232 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  80011b:	89 fb                	mov    %edi,%ebx
  80011d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800123:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  800126:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80012c:	eb 28                	jmp    800156 <umain+0x123>
		if (pipeisclosed(p[0]) != 0) {
  80012e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800131:	89 04 24             	mov    %eax,(%esp)
  800134:	e8 70 1d 00 00       	call   801ea9 <pipeisclosed>
  800139:	85 c0                	test   %eax,%eax
  80013b:	74 19                	je     800156 <umain+0x123>
			cprintf("\nRACE: pipe appears closed\n");
  80013d:	c7 04 24 99 25 80 00 	movl   $0x802599,(%esp)
  800144:	e8 fb 01 00 00       	call   800344 <cprintf>
			sys_env_destroy(r);
  800149:	89 3c 24             	mov    %edi,(%esp)
  80014c:	e8 a2 0b 00 00       	call   800cf3 <sys_env_destroy>
			exit();
  800151:	e8 dc 00 00 00       	call   800232 <exit>
	while (kid->env_status == ENV_RUNNABLE)
  800156:	8b 43 54             	mov    0x54(%ebx),%eax
  800159:	83 f8 02             	cmp    $0x2,%eax
  80015c:	74 d0                	je     80012e <umain+0xfb>
		}
	cprintf("child done with loop\n");
  80015e:	c7 04 24 b5 25 80 00 	movl   $0x8025b5,(%esp)
  800165:	e8 da 01 00 00       	call   800344 <cprintf>
	if (pipeisclosed(p[0]))
  80016a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80016d:	89 04 24             	mov    %eax,(%esp)
  800170:	e8 34 1d 00 00       	call   801ea9 <pipeisclosed>
  800175:	85 c0                	test   %eax,%eax
  800177:	74 1c                	je     800195 <umain+0x162>
		panic("somehow the other end of p[0] got closed!");
  800179:	c7 44 24 08 44 25 80 	movl   $0x802544,0x8(%esp)
  800180:	00 
  800181:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800188:	00 
  800189:	c7 04 24 77 25 80 00 	movl   $0x802577,(%esp)
  800190:	e8 b6 00 00 00       	call   80024b <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800195:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80019f:	89 04 24             	mov    %eax,(%esp)
  8001a2:	e8 df 11 00 00       	call   801386 <fd_lookup>
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	79 20                	jns    8001cb <umain+0x198>
		panic("cannot look up p[0]: %e", r);
  8001ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001af:	c7 44 24 08 cb 25 80 	movl   $0x8025cb,0x8(%esp)
  8001b6:	00 
  8001b7:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001be:	00 
  8001bf:	c7 04 24 77 25 80 00 	movl   $0x802577,(%esp)
  8001c6:	e8 80 00 00 00       	call   80024b <_panic>
	(void) fd2data(fd);
  8001cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 4a 11 00 00       	call   801320 <fd2data>
	cprintf("race didn't happen\n");
  8001d6:	c7 04 24 e3 25 80 00 	movl   $0x8025e3,(%esp)
  8001dd:	e8 62 01 00 00       	call   800344 <cprintf>
}
  8001e2:	83 c4 2c             	add    $0x2c,%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5f                   	pop    %edi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 10             	sub    $0x10,%esp
  8001f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8001f8:	e8 48 0b 00 00       	call   800d45 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8001fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800202:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800205:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020f:	85 db                	test   %ebx,%ebx
  800211:	7e 07                	jle    80021a <libmain+0x30>
		binaryname = argv[0];
  800213:	8b 06                	mov    (%esi),%eax
  800215:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021e:	89 1c 24             	mov    %ebx,(%esp)
  800221:	e8 0d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800226:	e8 07 00 00 00       	call   800232 <exit>
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800238:	e8 a8 12 00 00       	call   8014e5 <close_all>
	sys_env_destroy(0);
  80023d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800244:	e8 aa 0a 00 00       	call   800cf3 <sys_env_destroy>
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800253:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800256:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80025c:	e8 e4 0a 00 00       	call   800d45 <sys_getenvid>
  800261:	8b 55 0c             	mov    0xc(%ebp),%edx
  800264:	89 54 24 10          	mov    %edx,0x10(%esp)
  800268:	8b 55 08             	mov    0x8(%ebp),%edx
  80026b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026f:	89 74 24 08          	mov    %esi,0x8(%esp)
  800273:	89 44 24 04          	mov    %eax,0x4(%esp)
  800277:	c7 04 24 04 26 80 00 	movl   $0x802604,(%esp)
  80027e:	e8 c1 00 00 00       	call   800344 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800283:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800287:	8b 45 10             	mov    0x10(%ebp),%eax
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	e8 51 00 00 00       	call   8002e3 <vcprintf>
	cprintf("\n");
  800292:	c7 04 24 a1 2b 80 00 	movl   $0x802ba1,(%esp)
  800299:	e8 a6 00 00 00       	call   800344 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80029e:	cc                   	int3   
  80029f:	eb fd                	jmp    80029e <_panic+0x53>

008002a1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 14             	sub    $0x14,%esp
  8002a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ab:	8b 13                	mov    (%ebx),%edx
  8002ad:	8d 42 01             	lea    0x1(%edx),%eax
  8002b0:	89 03                	mov    %eax,(%ebx)
  8002b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002be:	75 19                	jne    8002d9 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002c0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c7:	00 
  8002c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 e3 09 00 00       	call   800cb6 <sys_cputs>
		b->idx = 0;
  8002d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002d9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f3:	00 00 00 
	b.cnt = 0;
  8002f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	c7 04 24 a1 02 80 00 	movl   $0x8002a1,(%esp)
  80031f:	e8 aa 01 00 00       	call   8004ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800324:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 7a 09 00 00       	call   800cb6 <sys_cputs>

	return b.cnt;
}
  80033c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 87 ff ff ff       	call   8002e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    
  80035e:	66 90                	xchg   %ax,%ax

00800360 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 3c             	sub    $0x3c,%esp
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	89 d7                	mov    %edx,%edi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
  800377:	89 c3                	mov    %eax,%ebx
  800379:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80037c:	8b 45 10             	mov    0x10(%ebp),%eax
  80037f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
  800387:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80038d:	39 d9                	cmp    %ebx,%ecx
  80038f:	72 05                	jb     800396 <printnum+0x36>
  800391:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800394:	77 69                	ja     8003ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800396:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800399:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80039d:	83 ee 01             	sub    $0x1,%esi
  8003a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003b0:	89 c3                	mov    %eax,%ebx
  8003b2:	89 d6                	mov    %edx,%esi
  8003b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	e8 bc 1e 00 00       	call   802290 <__udivdi3>
  8003d4:	89 d9                	mov    %ebx,%ecx
  8003d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003de:	89 04 24             	mov    %eax,(%esp)
  8003e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e5:	89 fa                	mov    %edi,%edx
  8003e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ea:	e8 71 ff ff ff       	call   800360 <printnum>
  8003ef:	eb 1b                	jmp    80040c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	ff d3                	call   *%ebx
  8003fd:	eb 03                	jmp    800402 <printnum+0xa2>
  8003ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800402:	83 ee 01             	sub    $0x1,%esi
  800405:	85 f6                	test   %esi,%esi
  800407:	7f e8                	jg     8003f1 <printnum+0x91>
  800409:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800410:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800414:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800417:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80041a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800422:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042f:	e8 8c 1f 00 00       	call   8023c0 <__umoddi3>
  800434:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800438:	0f be 80 27 26 80 00 	movsbl 0x802627(%eax),%eax
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800445:	ff d0                	call   *%eax
}
  800447:	83 c4 3c             	add    $0x3c,%esp
  80044a:	5b                   	pop    %ebx
  80044b:	5e                   	pop    %esi
  80044c:	5f                   	pop    %edi
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800452:	83 fa 01             	cmp    $0x1,%edx
  800455:	7e 0e                	jle    800465 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800457:	8b 10                	mov    (%eax),%edx
  800459:	8d 4a 08             	lea    0x8(%edx),%ecx
  80045c:	89 08                	mov    %ecx,(%eax)
  80045e:	8b 02                	mov    (%edx),%eax
  800460:	8b 52 04             	mov    0x4(%edx),%edx
  800463:	eb 22                	jmp    800487 <getuint+0x38>
	else if (lflag)
  800465:	85 d2                	test   %edx,%edx
  800467:	74 10                	je     800479 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800469:	8b 10                	mov    (%eax),%edx
  80046b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046e:	89 08                	mov    %ecx,(%eax)
  800470:	8b 02                	mov    (%edx),%eax
  800472:	ba 00 00 00 00       	mov    $0x0,%edx
  800477:	eb 0e                	jmp    800487 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800479:	8b 10                	mov    (%eax),%edx
  80047b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047e:	89 08                	mov    %ecx,(%eax)
  800480:	8b 02                	mov    (%edx),%eax
  800482:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    

00800489 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80048f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800493:	8b 10                	mov    (%eax),%edx
  800495:	3b 50 04             	cmp    0x4(%eax),%edx
  800498:	73 0a                	jae    8004a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80049a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a2:	88 02                	mov    %al,(%edx)
}
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    

008004a6 <printfmt>:
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8004ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	e8 02 00 00 00       	call   8004ce <vprintfmt>
}
  8004cc:	c9                   	leave  
  8004cd:	c3                   	ret    

008004ce <vprintfmt>:
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	57                   	push   %edi
  8004d2:	56                   	push   %esi
  8004d3:	53                   	push   %ebx
  8004d4:	83 ec 3c             	sub    $0x3c,%esp
  8004d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004dd:	eb 1f                	jmp    8004fe <vprintfmt+0x30>
			if (ch == '\0'){
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	75 0f                	jne    8004f2 <vprintfmt+0x24>
				color = 0x0100;
  8004e3:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  8004ea:	01 00 00 
  8004ed:	e9 b3 03 00 00       	jmp    8008a5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8004f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f6:	89 04 24             	mov    %eax,(%esp)
  8004f9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fc:	89 f3                	mov    %esi,%ebx
  8004fe:	8d 73 01             	lea    0x1(%ebx),%esi
  800501:	0f b6 03             	movzbl (%ebx),%eax
  800504:	83 f8 25             	cmp    $0x25,%eax
  800507:	75 d6                	jne    8004df <vprintfmt+0x11>
  800509:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80050d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800514:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80051b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800522:	ba 00 00 00 00       	mov    $0x0,%edx
  800527:	eb 1d                	jmp    800546 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800529:	89 de                	mov    %ebx,%esi
			padc = '-';
  80052b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80052f:	eb 15                	jmp    800546 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800531:	89 de                	mov    %ebx,%esi
			padc = '0';
  800533:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800537:	eb 0d                	jmp    800546 <vprintfmt+0x78>
				width = precision, precision = -1;
  800539:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80053c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80053f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8d 5e 01             	lea    0x1(%esi),%ebx
  800549:	0f b6 0e             	movzbl (%esi),%ecx
  80054c:	0f b6 c1             	movzbl %cl,%eax
  80054f:	83 e9 23             	sub    $0x23,%ecx
  800552:	80 f9 55             	cmp    $0x55,%cl
  800555:	0f 87 2a 03 00 00    	ja     800885 <vprintfmt+0x3b7>
  80055b:	0f b6 c9             	movzbl %cl,%ecx
  80055e:	ff 24 8d 60 27 80 00 	jmp    *0x802760(,%ecx,4)
  800565:	89 de                	mov    %ebx,%esi
  800567:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80056c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80056f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800573:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800576:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800579:	83 fb 09             	cmp    $0x9,%ebx
  80057c:	77 36                	ja     8005b4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80057e:	83 c6 01             	add    $0x1,%esi
			}
  800581:	eb e9                	jmp    80056c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 48 04             	lea    0x4(%eax),%ecx
  800589:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800591:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800593:	eb 22                	jmp    8005b7 <vprintfmt+0xe9>
  800595:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	b8 00 00 00 00       	mov    $0x0,%eax
  80059f:	0f 49 c1             	cmovns %ecx,%eax
  8005a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	89 de                	mov    %ebx,%esi
  8005a7:	eb 9d                	jmp    800546 <vprintfmt+0x78>
  8005a9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8005ab:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005b2:	eb 92                	jmp    800546 <vprintfmt+0x78>
  8005b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8005b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005bb:	79 89                	jns    800546 <vprintfmt+0x78>
  8005bd:	e9 77 ff ff ff       	jmp    800539 <vprintfmt+0x6b>
			lflag++;
  8005c2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8005c7:	e9 7a ff ff ff       	jmp    800546 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 04 24             	mov    %eax,(%esp)
  8005de:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005e1:	e9 18 ff ff ff       	jmp    8004fe <vprintfmt+0x30>
			err = va_arg(ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	99                   	cltd   
  8005f2:	31 d0                	xor    %edx,%eax
  8005f4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f6:	83 f8 0f             	cmp    $0xf,%eax
  8005f9:	7f 0b                	jg     800606 <vprintfmt+0x138>
  8005fb:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  800602:	85 d2                	test   %edx,%edx
  800604:	75 20                	jne    800626 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800606:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80060a:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800611:	00 
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	8b 45 08             	mov    0x8(%ebp),%eax
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	e8 85 fe ff ff       	call   8004a6 <printfmt>
  800621:	e9 d8 fe ff ff       	jmp    8004fe <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800626:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062a:	c7 44 24 08 7a 2b 80 	movl   $0x802b7a,0x8(%esp)
  800631:	00 
  800632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800636:	8b 45 08             	mov    0x8(%ebp),%eax
  800639:	89 04 24             	mov    %eax,(%esp)
  80063c:	e8 65 fe ff ff       	call   8004a6 <printfmt>
  800641:	e9 b8 fe ff ff       	jmp    8004fe <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800649:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80064c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80065a:	85 f6                	test   %esi,%esi
  80065c:	b8 38 26 80 00       	mov    $0x802638,%eax
  800661:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800664:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800668:	0f 84 97 00 00 00    	je     800705 <vprintfmt+0x237>
  80066e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800672:	0f 8e 9b 00 00 00    	jle    800713 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800678:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80067c:	89 34 24             	mov    %esi,(%esp)
  80067f:	e8 c4 02 00 00       	call   800948 <strnlen>
  800684:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800687:	29 c2                	sub    %eax,%edx
  800689:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80068c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800690:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800693:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800696:	8b 75 08             	mov    0x8(%ebp),%esi
  800699:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80069c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80069e:	eb 0f                	jmp    8006af <vprintfmt+0x1e1>
					putch(padc, putdat);
  8006a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006a7:	89 04 24             	mov    %eax,(%esp)
  8006aa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ac:	83 eb 01             	sub    $0x1,%ebx
  8006af:	85 db                	test   %ebx,%ebx
  8006b1:	7f ed                	jg     8006a0 <vprintfmt+0x1d2>
  8006b3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006b6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c0:	0f 49 c2             	cmovns %edx,%eax
  8006c3:	29 c2                	sub    %eax,%edx
  8006c5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006c8:	89 d7                	mov    %edx,%edi
  8006ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006cd:	eb 50                	jmp    80071f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8006cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d3:	74 1e                	je     8006f3 <vprintfmt+0x225>
  8006d5:	0f be d2             	movsbl %dl,%edx
  8006d8:	83 ea 20             	sub    $0x20,%edx
  8006db:	83 fa 5e             	cmp    $0x5e,%edx
  8006de:	76 13                	jbe    8006f3 <vprintfmt+0x225>
					putch('?', putdat);
  8006e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006ee:	ff 55 08             	call   *0x8(%ebp)
  8006f1:	eb 0d                	jmp    800700 <vprintfmt+0x232>
					putch(ch, putdat);
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006fa:	89 04 24             	mov    %eax,(%esp)
  8006fd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800700:	83 ef 01             	sub    $0x1,%edi
  800703:	eb 1a                	jmp    80071f <vprintfmt+0x251>
  800705:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800708:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80070b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80070e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800711:	eb 0c                	jmp    80071f <vprintfmt+0x251>
  800713:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800716:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800719:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80071c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80071f:	83 c6 01             	add    $0x1,%esi
  800722:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800726:	0f be c2             	movsbl %dl,%eax
  800729:	85 c0                	test   %eax,%eax
  80072b:	74 27                	je     800754 <vprintfmt+0x286>
  80072d:	85 db                	test   %ebx,%ebx
  80072f:	78 9e                	js     8006cf <vprintfmt+0x201>
  800731:	83 eb 01             	sub    $0x1,%ebx
  800734:	79 99                	jns    8006cf <vprintfmt+0x201>
  800736:	89 f8                	mov    %edi,%eax
  800738:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80073b:	8b 75 08             	mov    0x8(%ebp),%esi
  80073e:	89 c3                	mov    %eax,%ebx
  800740:	eb 1a                	jmp    80075c <vprintfmt+0x28e>
				putch(' ', putdat);
  800742:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800746:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80074d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80074f:	83 eb 01             	sub    $0x1,%ebx
  800752:	eb 08                	jmp    80075c <vprintfmt+0x28e>
  800754:	89 fb                	mov    %edi,%ebx
  800756:	8b 75 08             	mov    0x8(%ebp),%esi
  800759:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80075c:	85 db                	test   %ebx,%ebx
  80075e:	7f e2                	jg     800742 <vprintfmt+0x274>
  800760:	89 75 08             	mov    %esi,0x8(%ebp)
  800763:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800766:	e9 93 fd ff ff       	jmp    8004fe <vprintfmt+0x30>
	if (lflag >= 2)
  80076b:	83 fa 01             	cmp    $0x1,%edx
  80076e:	7e 16                	jle    800786 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 50 08             	lea    0x8(%eax),%edx
  800776:	89 55 14             	mov    %edx,0x14(%ebp)
  800779:	8b 50 04             	mov    0x4(%eax),%edx
  80077c:	8b 00                	mov    (%eax),%eax
  80077e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800781:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800784:	eb 32                	jmp    8007b8 <vprintfmt+0x2ea>
	else if (lflag)
  800786:	85 d2                	test   %edx,%edx
  800788:	74 18                	je     8007a2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 50 04             	lea    0x4(%eax),%edx
  800790:	89 55 14             	mov    %edx,0x14(%ebp)
  800793:	8b 30                	mov    (%eax),%esi
  800795:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800798:	89 f0                	mov    %esi,%eax
  80079a:	c1 f8 1f             	sar    $0x1f,%eax
  80079d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a0:	eb 16                	jmp    8007b8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8d 50 04             	lea    0x4(%eax),%edx
  8007a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ab:	8b 30                	mov    (%eax),%esi
  8007ad:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007b0:	89 f0                	mov    %esi,%eax
  8007b2:	c1 f8 1f             	sar    $0x1f,%eax
  8007b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8007b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8007be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8007c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c7:	0f 89 80 00 00 00    	jns    80084d <vprintfmt+0x37f>
				putch('-', putdat);
  8007cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007d8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007e1:	f7 d8                	neg    %eax
  8007e3:	83 d2 00             	adc    $0x0,%edx
  8007e6:	f7 da                	neg    %edx
			base = 10;
  8007e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ed:	eb 5e                	jmp    80084d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f2:	e8 58 fc ff ff       	call   80044f <getuint>
			base = 10;
  8007f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007fc:	eb 4f                	jmp    80084d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800801:	e8 49 fc ff ff       	call   80044f <getuint>
            base = 8;
  800806:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80080b:	eb 40                	jmp    80084d <vprintfmt+0x37f>
			putch('0', putdat);
  80080d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800811:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800818:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80081b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80081f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800826:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8d 50 04             	lea    0x4(%eax),%edx
  80082f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800832:	8b 00                	mov    (%eax),%eax
  800834:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800839:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80083e:	eb 0d                	jmp    80084d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800840:	8d 45 14             	lea    0x14(%ebp),%eax
  800843:	e8 07 fc ff ff       	call   80044f <getuint>
			base = 16;
  800848:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80084d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800851:	89 74 24 10          	mov    %esi,0x10(%esp)
  800855:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800858:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80085c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	89 54 24 04          	mov    %edx,0x4(%esp)
  800867:	89 fa                	mov    %edi,%edx
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	e8 ef fa ff ff       	call   800360 <printnum>
			break;
  800871:	e9 88 fc ff ff       	jmp    8004fe <vprintfmt+0x30>
			putch(ch, putdat);
  800876:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80087a:	89 04 24             	mov    %eax,(%esp)
  80087d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800880:	e9 79 fc ff ff       	jmp    8004fe <vprintfmt+0x30>
			putch('%', putdat);
  800885:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800889:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800890:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800893:	89 f3                	mov    %esi,%ebx
  800895:	eb 03                	jmp    80089a <vprintfmt+0x3cc>
  800897:	83 eb 01             	sub    $0x1,%ebx
  80089a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80089e:	75 f7                	jne    800897 <vprintfmt+0x3c9>
  8008a0:	e9 59 fc ff ff       	jmp    8004fe <vprintfmt+0x30>
}
  8008a5:	83 c4 3c             	add    $0x3c,%esp
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5f                   	pop    %edi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	83 ec 28             	sub    $0x28,%esp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ca:	85 c0                	test   %eax,%eax
  8008cc:	74 30                	je     8008fe <vsnprintf+0x51>
  8008ce:	85 d2                	test   %edx,%edx
  8008d0:	7e 2c                	jle    8008fe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8008dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e7:	c7 04 24 89 04 80 00 	movl   $0x800489,(%esp)
  8008ee:	e8 db fb ff ff       	call   8004ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fc:	eb 05                	jmp    800903 <vsnprintf+0x56>
		return -E_INVAL;
  8008fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80090e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800912:	8b 45 10             	mov    0x10(%ebp),%eax
  800915:	89 44 24 08          	mov    %eax,0x8(%esp)
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	89 04 24             	mov    %eax,(%esp)
  800926:	e8 82 ff ff ff       	call   8008ad <vsnprintf>
	va_end(ap);

	return rc;
}
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    
  80092d:	66 90                	xchg   %ax,%ax
  80092f:	90                   	nop

00800930 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	eb 03                	jmp    800940 <strlen+0x10>
		n++;
  80093d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800940:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800944:	75 f7                	jne    80093d <strlen+0xd>
	return n;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
  800956:	eb 03                	jmp    80095b <strnlen+0x13>
		n++;
  800958:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095b:	39 d0                	cmp    %edx,%eax
  80095d:	74 06                	je     800965 <strnlen+0x1d>
  80095f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800963:	75 f3                	jne    800958 <strnlen+0x10>
	return n;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800971:	89 c2                	mov    %eax,%edx
  800973:	83 c2 01             	add    $0x1,%edx
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80097d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800980:	84 db                	test   %bl,%bl
  800982:	75 ef                	jne    800973 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800984:	5b                   	pop    %ebx
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800991:	89 1c 24             	mov    %ebx,(%esp)
  800994:	e8 97 ff ff ff       	call   800930 <strlen>
	strcpy(dst + len, src);
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a0:	01 d8                	add    %ebx,%eax
  8009a2:	89 04 24             	mov    %eax,(%esp)
  8009a5:	e8 bd ff ff ff       	call   800967 <strcpy>
	return dst;
}
  8009aa:	89 d8                	mov    %ebx,%eax
  8009ac:	83 c4 08             	add    $0x8,%esp
  8009af:	5b                   	pop    %ebx
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	eb 0f                	jmp    8009d5 <strncpy+0x23>
		*dst++ = *src;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	0f b6 01             	movzbl (%ecx),%eax
  8009cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	75 ed                	jne    8009c6 <strncpy+0x14>
	}
	return ret;
}
  8009d9:	89 f0                	mov    %esi,%eax
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ed:	89 f0                	mov    %esi,%eax
  8009ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	75 0b                	jne    800a02 <strlcpy+0x23>
  8009f7:	eb 1d                	jmp    800a16 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a02:	39 d8                	cmp    %ebx,%eax
  800a04:	74 0b                	je     800a11 <strlcpy+0x32>
  800a06:	0f b6 0a             	movzbl (%edx),%ecx
  800a09:	84 c9                	test   %cl,%cl
  800a0b:	75 ec                	jne    8009f9 <strlcpy+0x1a>
  800a0d:	89 c2                	mov    %eax,%edx
  800a0f:	eb 02                	jmp    800a13 <strlcpy+0x34>
  800a11:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800a13:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a16:	29 f0                	sub    %esi,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strcmp+0x11>
		p++, q++;
  800a27:	83 c1 01             	add    $0x1,%ecx
  800a2a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a2d:	0f b6 01             	movzbl (%ecx),%eax
  800a30:	84 c0                	test   %al,%al
  800a32:	74 04                	je     800a38 <strcmp+0x1c>
  800a34:	3a 02                	cmp    (%edx),%al
  800a36:	74 ef                	je     800a27 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 c0             	movzbl %al,%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 c3                	mov    %eax,%ebx
  800a4e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a51:	eb 06                	jmp    800a59 <strncmp+0x17>
		n--, p++, q++;
  800a53:	83 c0 01             	add    $0x1,%eax
  800a56:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a59:	39 d8                	cmp    %ebx,%eax
  800a5b:	74 15                	je     800a72 <strncmp+0x30>
  800a5d:	0f b6 08             	movzbl (%eax),%ecx
  800a60:	84 c9                	test   %cl,%cl
  800a62:	74 04                	je     800a68 <strncmp+0x26>
  800a64:	3a 0a                	cmp    (%edx),%cl
  800a66:	74 eb                	je     800a53 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 00             	movzbl (%eax),%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
  800a70:	eb 05                	jmp    800a77 <strncmp+0x35>
		return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a84:	eb 07                	jmp    800a8d <strchr+0x13>
		if (*s == c)
  800a86:	38 ca                	cmp    %cl,%dl
  800a88:	74 0f                	je     800a99 <strchr+0x1f>
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 f2                	jne    800a86 <strchr+0xc>
			return (char *) s;
	return 0;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	eb 07                	jmp    800aae <strfind+0x13>
		if (*s == c)
  800aa7:	38 ca                	cmp    %cl,%dl
  800aa9:	74 0a                	je     800ab5 <strfind+0x1a>
	for (; *s; s++)
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	0f b6 10             	movzbl (%eax),%edx
  800ab1:	84 d2                	test   %dl,%dl
  800ab3:	75 f2                	jne    800aa7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac3:	85 c9                	test   %ecx,%ecx
  800ac5:	74 36                	je     800afd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acd:	75 28                	jne    800af7 <memset+0x40>
  800acf:	f6 c1 03             	test   $0x3,%cl
  800ad2:	75 23                	jne    800af7 <memset+0x40>
		c &= 0xFF;
  800ad4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	c1 e3 08             	shl    $0x8,%ebx
  800add:	89 d6                	mov    %edx,%esi
  800adf:	c1 e6 18             	shl    $0x18,%esi
  800ae2:	89 d0                	mov    %edx,%eax
  800ae4:	c1 e0 10             	shl    $0x10,%eax
  800ae7:	09 f0                	or     %esi,%eax
  800ae9:	09 c2                	or     %eax,%edx
  800aeb:	89 d0                	mov    %edx,%eax
  800aed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aef:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800af2:	fc                   	cld    
  800af3:	f3 ab                	rep stos %eax,%es:(%edi)
  800af5:	eb 06                	jmp    800afd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afa:	fc                   	cld    
  800afb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afd:	89 f8                	mov    %edi,%eax
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b12:	39 c6                	cmp    %eax,%esi
  800b14:	73 35                	jae    800b4b <memmove+0x47>
  800b16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b19:	39 d0                	cmp    %edx,%eax
  800b1b:	73 2e                	jae    800b4b <memmove+0x47>
		s += n;
		d += n;
  800b1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2a:	75 13                	jne    800b3f <memmove+0x3b>
  800b2c:	f6 c1 03             	test   $0x3,%cl
  800b2f:	75 0e                	jne    800b3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b31:	83 ef 04             	sub    $0x4,%edi
  800b34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b37:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b3a:	fd                   	std    
  800b3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3d:	eb 09                	jmp    800b48 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3f:	83 ef 01             	sub    $0x1,%edi
  800b42:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b45:	fd                   	std    
  800b46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b48:	fc                   	cld    
  800b49:	eb 1d                	jmp    800b68 <memmove+0x64>
  800b4b:	89 f2                	mov    %esi,%edx
  800b4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4f:	f6 c2 03             	test   $0x3,%dl
  800b52:	75 0f                	jne    800b63 <memmove+0x5f>
  800b54:	f6 c1 03             	test   $0x3,%cl
  800b57:	75 0a                	jne    800b63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b59:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	fc                   	cld    
  800b5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b61:	eb 05                	jmp    800b68 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	fc                   	cld    
  800b66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b72:	8b 45 10             	mov    0x10(%ebp),%eax
  800b75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	89 04 24             	mov    %eax,(%esp)
  800b86:	e8 79 ff ff ff       	call   800b04 <memmove>
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9d:	eb 1a                	jmp    800bb9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b9f:	0f b6 02             	movzbl (%edx),%eax
  800ba2:	0f b6 19             	movzbl (%ecx),%ebx
  800ba5:	38 d8                	cmp    %bl,%al
  800ba7:	74 0a                	je     800bb3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ba9:	0f b6 c0             	movzbl %al,%eax
  800bac:	0f b6 db             	movzbl %bl,%ebx
  800baf:	29 d8                	sub    %ebx,%eax
  800bb1:	eb 0f                	jmp    800bc2 <memcmp+0x35>
		s1++, s2++;
  800bb3:	83 c2 01             	add    $0x1,%edx
  800bb6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800bb9:	39 f2                	cmp    %esi,%edx
  800bbb:	75 e2                	jne    800b9f <memcmp+0x12>
	}

	return 0;
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bcf:	89 c2                	mov    %eax,%edx
  800bd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd4:	eb 07                	jmp    800bdd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd6:	38 08                	cmp    %cl,(%eax)
  800bd8:	74 07                	je     800be1 <memfind+0x1b>
	for (; s < ends; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	39 d0                	cmp    %edx,%eax
  800bdf:	72 f5                	jb     800bd6 <memfind+0x10>
			break;
	return (void *) s;
}
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	eb 03                	jmp    800bf4 <strtol+0x11>
		s++;
  800bf1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bf4:	0f b6 0a             	movzbl (%edx),%ecx
  800bf7:	80 f9 09             	cmp    $0x9,%cl
  800bfa:	74 f5                	je     800bf1 <strtol+0xe>
  800bfc:	80 f9 20             	cmp    $0x20,%cl
  800bff:	74 f0                	je     800bf1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c01:	80 f9 2b             	cmp    $0x2b,%cl
  800c04:	75 0a                	jne    800c10 <strtol+0x2d>
		s++;
  800c06:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c09:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0e:	eb 11                	jmp    800c21 <strtol+0x3e>
  800c10:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800c15:	80 f9 2d             	cmp    $0x2d,%cl
  800c18:	75 07                	jne    800c21 <strtol+0x3e>
		s++, neg = 1;
  800c1a:	8d 52 01             	lea    0x1(%edx),%edx
  800c1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c26:	75 15                	jne    800c3d <strtol+0x5a>
  800c28:	80 3a 30             	cmpb   $0x30,(%edx)
  800c2b:	75 10                	jne    800c3d <strtol+0x5a>
  800c2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c31:	75 0a                	jne    800c3d <strtol+0x5a>
		s += 2, base = 16;
  800c33:	83 c2 02             	add    $0x2,%edx
  800c36:	b8 10 00 00 00       	mov    $0x10,%eax
  800c3b:	eb 10                	jmp    800c4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	75 0c                	jne    800c4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c41:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c43:	80 3a 30             	cmpb   $0x30,(%edx)
  800c46:	75 05                	jne    800c4d <strtol+0x6a>
		s++, base = 8;
  800c48:	83 c2 01             	add    $0x1,%edx
  800c4b:	b0 08                	mov    $0x8,%al
		base = 10;
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c55:	0f b6 0a             	movzbl (%edx),%ecx
  800c58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c5b:	89 f0                	mov    %esi,%eax
  800c5d:	3c 09                	cmp    $0x9,%al
  800c5f:	77 08                	ja     800c69 <strtol+0x86>
			dig = *s - '0';
  800c61:	0f be c9             	movsbl %cl,%ecx
  800c64:	83 e9 30             	sub    $0x30,%ecx
  800c67:	eb 20                	jmp    800c89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c6c:	89 f0                	mov    %esi,%eax
  800c6e:	3c 19                	cmp    $0x19,%al
  800c70:	77 08                	ja     800c7a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c72:	0f be c9             	movsbl %cl,%ecx
  800c75:	83 e9 57             	sub    $0x57,%ecx
  800c78:	eb 0f                	jmp    800c89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	3c 19                	cmp    $0x19,%al
  800c81:	77 16                	ja     800c99 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c83:	0f be c9             	movsbl %cl,%ecx
  800c86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c8c:	7d 0f                	jge    800c9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c8e:	83 c2 01             	add    $0x1,%edx
  800c91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c97:	eb bc                	jmp    800c55 <strtol+0x72>
  800c99:	89 d8                	mov    %ebx,%eax
  800c9b:	eb 02                	jmp    800c9f <strtol+0xbc>
  800c9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca3:	74 05                	je     800caa <strtol+0xc7>
		*endptr = (char *) s;
  800ca5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800caa:	f7 d8                	neg    %eax
  800cac:	85 ff                	test   %edi,%edi
  800cae:	0f 44 c3             	cmove  %ebx,%eax
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 c3                	mov    %eax,%ebx
  800cc9:	89 c7                	mov    %eax,%edi
  800ccb:	89 c6                	mov    %eax,%esi
  800ccd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce4:	89 d1                	mov    %edx,%ecx
  800ce6:	89 d3                	mov    %edx,%ebx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	b8 03 00 00 00       	mov    $0x3,%eax
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 28                	jle    800d3d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d19:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d20:	00 
  800d21:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800d28:	00 
  800d29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d30:	00 
  800d31:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800d38:	e8 0e f5 ff ff       	call   80024b <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3d:	83 c4 2c             	add    $0x2c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d50:	b8 02 00 00 00       	mov    $0x2,%eax
  800d55:	89 d1                	mov    %edx,%ecx
  800d57:	89 d3                	mov    %edx,%ebx
  800d59:	89 d7                	mov    %edx,%edi
  800d5b:	89 d6                	mov    %edx,%esi
  800d5d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_yield>:

void
sys_yield(void)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d74:	89 d1                	mov    %edx,%ecx
  800d76:	89 d3                	mov    %edx,%ebx
  800d78:	89 d7                	mov    %edx,%edi
  800d7a:	89 d6                	mov    %edx,%esi
  800d7c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d8c:	be 00 00 00 00       	mov    $0x0,%esi
  800d91:	b8 04 00 00 00       	mov    $0x4,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9f:	89 f7                	mov    %esi,%edi
  800da1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 28                	jle    800dcf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db2:	00 
  800db3:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800dba:	00 
  800dbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc2:	00 
  800dc3:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800dca:	e8 7c f4 ff ff       	call   80024b <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dcf:	83 c4 2c             	add    $0x2c,%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800de0:	b8 05 00 00 00       	mov    $0x5,%eax
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df1:	8b 75 18             	mov    0x18(%ebp),%esi
  800df4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df6:	85 c0                	test   %eax,%eax
  800df8:	7e 28                	jle    800e22 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e05:	00 
  800e06:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800e1d:	e8 29 f4 ff ff       	call   80024b <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e22:	83 c4 2c             	add    $0x2c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e38:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	89 df                	mov    %ebx,%edi
  800e45:	89 de                	mov    %ebx,%esi
  800e47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 28                	jle    800e75 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e51:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e58:	00 
  800e59:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800e70:	e8 d6 f3 ff ff       	call   80024b <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e75:	83 c4 2c             	add    $0x2c,%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
  800e96:	89 df                	mov    %ebx,%edi
  800e98:	89 de                	mov    %ebx,%esi
  800e9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	7e 28                	jle    800ec8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eab:	00 
  800eac:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebb:	00 
  800ebc:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800ec3:	e8 83 f3 ff ff       	call   80024b <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec8:	83 c4 2c             	add    $0x2c,%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	b8 09 00 00 00       	mov    $0x9,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 de                	mov    %ebx,%esi
  800eed:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 28                	jle    800f1b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800efe:	00 
  800eff:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800f16:	e8 30 f3 ff ff       	call   80024b <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f1b:	83 c4 2c             	add    $0x2c,%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	89 df                	mov    %ebx,%edi
  800f3e:	89 de                	mov    %ebx,%esi
  800f40:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f42:	85 c0                	test   %eax,%eax
  800f44:	7e 28                	jle    800f6e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800f69:	e8 dd f2 ff ff       	call   80024b <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f6e:	83 c4 2c             	add    $0x2c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f7c:	be 00 00 00 00       	mov    $0x0,%esi
  800f81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f89:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f92:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fac:	8b 55 08             	mov    0x8(%ebp),%edx
  800faf:	89 cb                	mov    %ecx,%ebx
  800fb1:	89 cf                	mov    %ecx,%edi
  800fb3:	89 ce                	mov    %ecx,%esi
  800fb5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	7e 28                	jle    800fe3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  800fce:	00 
  800fcf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd6:	00 
  800fd7:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800fde:	e8 68 f2 ff ff       	call   80024b <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fe3:	83 c4 2c             	add    $0x2c,%esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5e                   	pop    %esi
  800fe8:	5f                   	pop    %edi
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    
  800feb:	66 90                	xchg   %ax,%ax
  800fed:	66 90                	xchg   %ax,%ax
  800fef:	90                   	nop

00800ff0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 24             	sub    $0x24,%esp
  800ff7:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  800ffa:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  800ffc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801000:	74 18                	je     80101a <pgfault+0x2a>
  801002:	89 d8                	mov    %ebx,%eax
  801004:	c1 e8 0c             	shr    $0xc,%eax
  801007:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100e:	25 05 08 00 00       	and    $0x805,%eax
  801013:	3d 05 08 00 00       	cmp    $0x805,%eax
  801018:	74 1c                	je     801036 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  80101a:	c7 44 24 08 4c 29 80 	movl   $0x80294c,0x8(%esp)
  801021:	00 
  801022:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801029:	00 
  80102a:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  801031:	e8 15 f2 ff ff       	call   80024b <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  801036:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80103d:	00 
  80103e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801045:	00 
  801046:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80104d:	e8 31 fd ff ff       	call   800d83 <sys_page_alloc>
	if(r < 0){
  801052:	85 c0                	test   %eax,%eax
  801054:	79 1c                	jns    801072 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  801056:	c7 44 24 08 7c 29 80 	movl   $0x80297c,0x8(%esp)
  80105d:	00 
  80105e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801065:	00 
  801066:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  80106d:	e8 d9 f1 ff ff       	call   80024b <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801072:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801078:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80107f:	00 
  801080:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801084:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80108b:	e8 dc fa ff ff       	call   800b6c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  801090:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801097:	00 
  801098:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80109c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a3:	00 
  8010a4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010ab:	00 
  8010ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b3:	e8 1f fd ff ff       	call   800dd7 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	79 1c                	jns    8010d8 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  8010bc:	c7 44 24 08 48 2a 80 	movl   $0x802a48,0x8(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  8010d3:	e8 73 f1 ff ff       	call   80024b <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  8010d8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e7:	e8 3e fd ff ff       	call   800e2a <sys_page_unmap>
    if(r < 0){
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	79 1c                	jns    80110c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  8010f0:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  8010f7:	00 
  8010f8:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8010ff:	00 
  801100:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  801107:	e8 3f f1 ff ff       	call   80024b <_panic>
    }
    // LAB 4
}
  80110c:	83 c4 24             	add    $0x24,%esp
  80110f:	5b                   	pop    %ebx
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	57                   	push   %edi
  801116:	56                   	push   %esi
  801117:	53                   	push   %ebx
  801118:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  80111b:	c7 04 24 f0 0f 80 00 	movl   $0x800ff0,(%esp)
  801122:	e8 5f 0f 00 00       	call   802086 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801127:	b8 07 00 00 00       	mov    $0x7,%eax
  80112c:	cd 30                	int    $0x30
  80112e:	89 c7                	mov    %eax,%edi
  801130:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801133:	85 c0                	test   %eax,%eax
  801135:	79 1c                	jns    801153 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801137:	c7 44 24 08 78 2a 80 	movl   $0x802a78,0x8(%esp)
  80113e:	00 
  80113f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801146:	00 
  801147:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  80114e:	e8 f8 f0 ff ff       	call   80024b <_panic>
    }
    if(child == 0){
  801153:	bb 00 00 00 00       	mov    $0x0,%ebx
  801158:	85 c0                	test   %eax,%eax
  80115a:	75 21                	jne    80117d <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80115c:	e8 e4 fb ff ff       	call   800d45 <sys_getenvid>
  801161:	25 ff 03 00 00       	and    $0x3ff,%eax
  801166:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801169:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80116e:	a3 08 40 80 00       	mov    %eax,0x804008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  801173:	b8 00 00 00 00       	mov    $0x0,%eax
  801178:	e9 67 01 00 00       	jmp    8012e4 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	c1 e8 16             	shr    $0x16,%eax
  801182:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801189:	a8 01                	test   $0x1,%al
  80118b:	74 4b                	je     8011d8 <fork+0xc6>
  80118d:	89 de                	mov    %ebx,%esi
  80118f:	c1 ee 0c             	shr    $0xc,%esi
  801192:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801199:	a8 01                	test   $0x1,%al
  80119b:	74 3b                	je     8011d8 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  80119d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011a4:	a9 02 08 00 00       	test   $0x802,%eax
  8011a9:	0f 85 02 01 00 00    	jne    8012b1 <fork+0x19f>
  8011af:	e9 d2 00 00 00       	jmp    801286 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  8011b4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011bb:	00 
  8011bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c7:	00 
  8011c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d3:	e8 ff fb ff ff       	call   800dd7 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  8011d8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011de:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011e4:	75 97                	jne    80117d <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  8011e6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011ed:	00 
  8011ee:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011f5:	ee 
  8011f6:	89 3c 24             	mov    %edi,(%esp)
  8011f9:	e8 85 fb ff ff       	call   800d83 <sys_page_alloc>

    if(r < 0){
  8011fe:	85 c0                	test   %eax,%eax
  801200:	79 1c                	jns    80121e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801202:	c7 44 24 08 b0 29 80 	movl   $0x8029b0,0x8(%esp)
  801209:	00 
  80120a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801211:	00 
  801212:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  801219:	e8 2d f0 ff ff       	call   80024b <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80121e:	a1 08 40 80 00       	mov    0x804008,%eax
  801223:	8b 40 64             	mov    0x64(%eax),%eax
  801226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122a:	89 3c 24             	mov    %edi,(%esp)
  80122d:	e8 f1 fc ff ff       	call   800f23 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801232:	85 c0                	test   %eax,%eax
  801234:	79 1c                	jns    801252 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801236:	c7 44 24 08 d0 29 80 	movl   $0x8029d0,0x8(%esp)
  80123d:	00 
  80123e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801245:	00 
  801246:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  80124d:	e8 f9 ef ff ff       	call   80024b <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801252:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801259:	00 
  80125a:	89 3c 24             	mov    %edi,(%esp)
  80125d:	e8 1b fc ff ff       	call   800e7d <sys_env_set_status>
    if(r < 0){
  801262:	85 c0                	test   %eax,%eax
  801264:	79 1c                	jns    801282 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801266:	c7 44 24 08 f8 29 80 	movl   $0x8029f8,0x8(%esp)
  80126d:	00 
  80126e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  801275:	00 
  801276:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  80127d:	e8 c9 ef ff ff       	call   80024b <_panic>
    }
    return child;
  801282:	89 f8                	mov    %edi,%eax
  801284:	eb 5e                	jmp    8012e4 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  801286:	c1 e6 0c             	shl    $0xc,%esi
  801289:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801290:	00 
  801291:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80129c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a7:	e8 2b fb ff ff       	call   800dd7 <sys_page_map>
  8012ac:	e9 27 ff ff ff       	jmp    8011d8 <fork+0xc6>
  8012b1:	c1 e6 0c             	shl    $0xc,%esi
  8012b4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012bb:	00 
  8012bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d2:	e8 00 fb ff ff       	call   800dd7 <sys_page_map>
    if( r < 0 ){
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	0f 89 d5 fe ff ff    	jns    8011b4 <fork+0xa2>
  8012df:	e9 f4 fe ff ff       	jmp    8011d8 <fork+0xc6>
//	panic("fork not implemented");
}
  8012e4:	83 c4 2c             	add    $0x2c,%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5e                   	pop    %esi
  8012e9:	5f                   	pop    %edi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <sfork>:

// Challenge!
int
sfork(void)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012f2:	c7 44 24 08 95 2a 80 	movl   $0x802a95,0x8(%esp)
  8012f9:	00 
  8012fa:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801301:	00 
  801302:	c7 04 24 3d 2a 80 00 	movl   $0x802a3d,(%esp)
  801309:	e8 3d ef ff ff       	call   80024b <_panic>
  80130e:	66 90                	xchg   %ax,%ax

00801310 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801313:	8b 45 08             	mov    0x8(%ebp),%eax
  801316:	05 00 00 00 30       	add    $0x30000000,%eax
  80131b:	c1 e8 0c             	shr    $0xc,%eax
}
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80132b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801330:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801342:	89 c2                	mov    %eax,%edx
  801344:	c1 ea 16             	shr    $0x16,%edx
  801347:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	74 11                	je     801364 <fd_alloc+0x2d>
  801353:	89 c2                	mov    %eax,%edx
  801355:	c1 ea 0c             	shr    $0xc,%edx
  801358:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135f:	f6 c2 01             	test   $0x1,%dl
  801362:	75 09                	jne    80136d <fd_alloc+0x36>
			*fd_store = fd;
  801364:	89 01                	mov    %eax,(%ecx)
			return 0;
  801366:	b8 00 00 00 00       	mov    $0x0,%eax
  80136b:	eb 17                	jmp    801384 <fd_alloc+0x4d>
  80136d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801372:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801377:	75 c9                	jne    801342 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801379:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80137f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80138c:	83 f8 1f             	cmp    $0x1f,%eax
  80138f:	77 36                	ja     8013c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801391:	c1 e0 0c             	shl    $0xc,%eax
  801394:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801399:	89 c2                	mov    %eax,%edx
  80139b:	c1 ea 16             	shr    $0x16,%edx
  80139e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a5:	f6 c2 01             	test   $0x1,%dl
  8013a8:	74 24                	je     8013ce <fd_lookup+0x48>
  8013aa:	89 c2                	mov    %eax,%edx
  8013ac:	c1 ea 0c             	shr    $0xc,%edx
  8013af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b6:	f6 c2 01             	test   $0x1,%dl
  8013b9:	74 1a                	je     8013d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013be:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c5:	eb 13                	jmp    8013da <fd_lookup+0x54>
		return -E_INVAL;
  8013c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cc:	eb 0c                	jmp    8013da <fd_lookup+0x54>
		return -E_INVAL;
  8013ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d3:	eb 05                	jmp    8013da <fd_lookup+0x54>
  8013d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 18             	sub    $0x18,%esp
  8013e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e5:	ba 28 2b 80 00       	mov    $0x802b28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ea:	eb 13                	jmp    8013ff <dev_lookup+0x23>
  8013ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ef:	39 08                	cmp    %ecx,(%eax)
  8013f1:	75 0c                	jne    8013ff <dev_lookup+0x23>
			*dev = devtab[i];
  8013f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fd:	eb 30                	jmp    80142f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8013ff:	8b 02                	mov    (%edx),%eax
  801401:	85 c0                	test   %eax,%eax
  801403:	75 e7                	jne    8013ec <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801405:	a1 08 40 80 00       	mov    0x804008,%eax
  80140a:	8b 40 48             	mov    0x48(%eax),%eax
  80140d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801411:	89 44 24 04          	mov    %eax,0x4(%esp)
  801415:	c7 04 24 ac 2a 80 00 	movl   $0x802aac,(%esp)
  80141c:	e8 23 ef ff ff       	call   800344 <cprintf>
	*dev = 0;
  801421:	8b 45 0c             	mov    0xc(%ebp),%eax
  801424:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80142a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <fd_close>:
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	83 ec 20             	sub    $0x20,%esp
  801439:	8b 75 08             	mov    0x8(%ebp),%esi
  80143c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801446:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80144c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144f:	89 04 24             	mov    %eax,(%esp)
  801452:	e8 2f ff ff ff       	call   801386 <fd_lookup>
  801457:	85 c0                	test   %eax,%eax
  801459:	78 05                	js     801460 <fd_close+0x2f>
	    || fd != fd2)
  80145b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80145e:	74 0c                	je     80146c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801460:	84 db                	test   %bl,%bl
  801462:	ba 00 00 00 00       	mov    $0x0,%edx
  801467:	0f 44 c2             	cmove  %edx,%eax
  80146a:	eb 3f                	jmp    8014ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80146c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801473:	8b 06                	mov    (%esi),%eax
  801475:	89 04 24             	mov    %eax,(%esp)
  801478:	e8 5f ff ff ff       	call   8013dc <dev_lookup>
  80147d:	89 c3                	mov    %eax,%ebx
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 16                	js     801499 <fd_close+0x68>
		if (dev->dev_close)
  801483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801486:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801489:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80148e:	85 c0                	test   %eax,%eax
  801490:	74 07                	je     801499 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801492:	89 34 24             	mov    %esi,(%esp)
  801495:	ff d0                	call   *%eax
  801497:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801499:	89 74 24 04          	mov    %esi,0x4(%esp)
  80149d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a4:	e8 81 f9 ff ff       	call   800e2a <sys_page_unmap>
	return r;
  8014a9:	89 d8                	mov    %ebx,%eax
}
  8014ab:	83 c4 20             	add    $0x20,%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    

008014b2 <close>:

int
close(int fdnum)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c2:	89 04 24             	mov    %eax,(%esp)
  8014c5:	e8 bc fe ff ff       	call   801386 <fd_lookup>
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	85 d2                	test   %edx,%edx
  8014ce:	78 13                	js     8014e3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8014d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014d7:	00 
  8014d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	e8 4e ff ff ff       	call   801431 <fd_close>
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <close_all>:

void
close_all(void)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014f1:	89 1c 24             	mov    %ebx,(%esp)
  8014f4:	e8 b9 ff ff ff       	call   8014b2 <close>
	for (i = 0; i < MAXFD; i++)
  8014f9:	83 c3 01             	add    $0x1,%ebx
  8014fc:	83 fb 20             	cmp    $0x20,%ebx
  8014ff:	75 f0                	jne    8014f1 <close_all+0xc>
}
  801501:	83 c4 14             	add    $0x14,%esp
  801504:	5b                   	pop    %ebx
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    

00801507 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	57                   	push   %edi
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801510:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801513:	89 44 24 04          	mov    %eax,0x4(%esp)
  801517:	8b 45 08             	mov    0x8(%ebp),%eax
  80151a:	89 04 24             	mov    %eax,(%esp)
  80151d:	e8 64 fe ff ff       	call   801386 <fd_lookup>
  801522:	89 c2                	mov    %eax,%edx
  801524:	85 d2                	test   %edx,%edx
  801526:	0f 88 e1 00 00 00    	js     80160d <dup+0x106>
		return r;
	close(newfdnum);
  80152c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	e8 7b ff ff ff       	call   8014b2 <close>

	newfd = INDEX2FD(newfdnum);
  801537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80153a:	c1 e3 0c             	shl    $0xc,%ebx
  80153d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801543:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801546:	89 04 24             	mov    %eax,(%esp)
  801549:	e8 d2 fd ff ff       	call   801320 <fd2data>
  80154e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801550:	89 1c 24             	mov    %ebx,(%esp)
  801553:	e8 c8 fd ff ff       	call   801320 <fd2data>
  801558:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155a:	89 f0                	mov    %esi,%eax
  80155c:	c1 e8 16             	shr    $0x16,%eax
  80155f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801566:	a8 01                	test   $0x1,%al
  801568:	74 43                	je     8015ad <dup+0xa6>
  80156a:	89 f0                	mov    %esi,%eax
  80156c:	c1 e8 0c             	shr    $0xc,%eax
  80156f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	74 32                	je     8015ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80157b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801582:	25 07 0e 00 00       	and    $0xe07,%eax
  801587:	89 44 24 10          	mov    %eax,0x10(%esp)
  80158b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80158f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801596:	00 
  801597:	89 74 24 04          	mov    %esi,0x4(%esp)
  80159b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a2:	e8 30 f8 ff ff       	call   800dd7 <sys_page_map>
  8015a7:	89 c6                	mov    %eax,%esi
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 3e                	js     8015eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	c1 ea 0c             	shr    $0xc,%edx
  8015b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015d1:	00 
  8015d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015dd:	e8 f5 f7 ff ff       	call   800dd7 <sys_page_map>
  8015e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8015e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e7:	85 f6                	test   %esi,%esi
  8015e9:	79 22                	jns    80160d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8015eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f6:	e8 2f f8 ff ff       	call   800e2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801606:	e8 1f f8 ff ff       	call   800e2a <sys_page_unmap>
	return r;
  80160b:	89 f0                	mov    %esi,%eax
}
  80160d:	83 c4 3c             	add    $0x3c,%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5f                   	pop    %edi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	53                   	push   %ebx
  801619:	83 ec 24             	sub    $0x24,%esp
  80161c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801622:	89 44 24 04          	mov    %eax,0x4(%esp)
  801626:	89 1c 24             	mov    %ebx,(%esp)
  801629:	e8 58 fd ff ff       	call   801386 <fd_lookup>
  80162e:	89 c2                	mov    %eax,%edx
  801630:	85 d2                	test   %edx,%edx
  801632:	78 6d                	js     8016a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163e:	8b 00                	mov    (%eax),%eax
  801640:	89 04 24             	mov    %eax,(%esp)
  801643:	e8 94 fd ff ff       	call   8013dc <dev_lookup>
  801648:	85 c0                	test   %eax,%eax
  80164a:	78 55                	js     8016a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	8b 50 08             	mov    0x8(%eax),%edx
  801652:	83 e2 03             	and    $0x3,%edx
  801655:	83 fa 01             	cmp    $0x1,%edx
  801658:	75 23                	jne    80167d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80165a:	a1 08 40 80 00       	mov    0x804008,%eax
  80165f:	8b 40 48             	mov    0x48(%eax),%eax
  801662:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166a:	c7 04 24 ed 2a 80 00 	movl   $0x802aed,(%esp)
  801671:	e8 ce ec ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  801676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167b:	eb 24                	jmp    8016a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80167d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801680:	8b 52 08             	mov    0x8(%edx),%edx
  801683:	85 d2                	test   %edx,%edx
  801685:	74 15                	je     80169c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801687:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80168a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80168e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801691:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801695:	89 04 24             	mov    %eax,(%esp)
  801698:	ff d2                	call   *%edx
  80169a:	eb 05                	jmp    8016a1 <read+0x8c>
		return -E_NOT_SUPP;
  80169c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016a1:	83 c4 24             	add    $0x24,%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	57                   	push   %edi
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 1c             	sub    $0x1c,%esp
  8016b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016bb:	eb 23                	jmp    8016e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016bd:	89 f0                	mov    %esi,%eax
  8016bf:	29 d8                	sub    %ebx,%eax
  8016c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c5:	89 d8                	mov    %ebx,%eax
  8016c7:	03 45 0c             	add    0xc(%ebp),%eax
  8016ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ce:	89 3c 24             	mov    %edi,(%esp)
  8016d1:	e8 3f ff ff ff       	call   801615 <read>
		if (m < 0)
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 10                	js     8016ea <readn+0x43>
			return m;
		if (m == 0)
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	74 0a                	je     8016e8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8016de:	01 c3                	add    %eax,%ebx
  8016e0:	39 f3                	cmp    %esi,%ebx
  8016e2:	72 d9                	jb     8016bd <readn+0x16>
  8016e4:	89 d8                	mov    %ebx,%eax
  8016e6:	eb 02                	jmp    8016ea <readn+0x43>
  8016e8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016ea:	83 c4 1c             	add    $0x1c,%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5f                   	pop    %edi
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 24             	sub    $0x24,%esp
  8016f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801703:	89 1c 24             	mov    %ebx,(%esp)
  801706:	e8 7b fc ff ff       	call   801386 <fd_lookup>
  80170b:	89 c2                	mov    %eax,%edx
  80170d:	85 d2                	test   %edx,%edx
  80170f:	78 68                	js     801779 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801711:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801714:	89 44 24 04          	mov    %eax,0x4(%esp)
  801718:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171b:	8b 00                	mov    (%eax),%eax
  80171d:	89 04 24             	mov    %eax,(%esp)
  801720:	e8 b7 fc ff ff       	call   8013dc <dev_lookup>
  801725:	85 c0                	test   %eax,%eax
  801727:	78 50                	js     801779 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801730:	75 23                	jne    801755 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801732:	a1 08 40 80 00       	mov    0x804008,%eax
  801737:	8b 40 48             	mov    0x48(%eax),%eax
  80173a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80173e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801742:	c7 04 24 09 2b 80 00 	movl   $0x802b09,(%esp)
  801749:	e8 f6 eb ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  80174e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801753:	eb 24                	jmp    801779 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801755:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801758:	8b 52 0c             	mov    0xc(%edx),%edx
  80175b:	85 d2                	test   %edx,%edx
  80175d:	74 15                	je     801774 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80175f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801762:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801769:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80176d:	89 04 24             	mov    %eax,(%esp)
  801770:	ff d2                	call   *%edx
  801772:	eb 05                	jmp    801779 <write+0x87>
		return -E_NOT_SUPP;
  801774:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801779:	83 c4 24             	add    $0x24,%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <seek>:

int
seek(int fdnum, off_t offset)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801785:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	89 04 24             	mov    %eax,(%esp)
  801792:	e8 ef fb ff ff       	call   801386 <fd_lookup>
  801797:	85 c0                	test   %eax,%eax
  801799:	78 0e                	js     8017a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80179b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80179e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 24             	sub    $0x24,%esp
  8017b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bc:	89 1c 24             	mov    %ebx,(%esp)
  8017bf:	e8 c2 fb ff ff       	call   801386 <fd_lookup>
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	85 d2                	test   %edx,%edx
  8017c8:	78 61                	js     80182b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d4:	8b 00                	mov    (%eax),%eax
  8017d6:	89 04 24             	mov    %eax,(%esp)
  8017d9:	e8 fe fb ff ff       	call   8013dc <dev_lookup>
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 49                	js     80182b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e9:	75 23                	jne    80180e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017eb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017f0:	8b 40 48             	mov    0x48(%eax),%eax
  8017f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fb:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801802:	e8 3d eb ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  801807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80180c:	eb 1d                	jmp    80182b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80180e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801811:	8b 52 18             	mov    0x18(%edx),%edx
  801814:	85 d2                	test   %edx,%edx
  801816:	74 0e                	je     801826 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80181b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80181f:	89 04 24             	mov    %eax,(%esp)
  801822:	ff d2                	call   *%edx
  801824:	eb 05                	jmp    80182b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801826:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80182b:	83 c4 24             	add    $0x24,%esp
  80182e:	5b                   	pop    %ebx
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	53                   	push   %ebx
  801835:	83 ec 24             	sub    $0x24,%esp
  801838:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	89 04 24             	mov    %eax,(%esp)
  801848:	e8 39 fb ff ff       	call   801386 <fd_lookup>
  80184d:	89 c2                	mov    %eax,%edx
  80184f:	85 d2                	test   %edx,%edx
  801851:	78 52                	js     8018a5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801853:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801856:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185d:	8b 00                	mov    (%eax),%eax
  80185f:	89 04 24             	mov    %eax,(%esp)
  801862:	e8 75 fb ff ff       	call   8013dc <dev_lookup>
  801867:	85 c0                	test   %eax,%eax
  801869:	78 3a                	js     8018a5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801872:	74 2c                	je     8018a0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801874:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801877:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80187e:	00 00 00 
	stat->st_isdir = 0;
  801881:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801888:	00 00 00 
	stat->st_dev = dev;
  80188b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801891:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801895:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801898:	89 14 24             	mov    %edx,(%esp)
  80189b:	ff 50 14             	call   *0x14(%eax)
  80189e:	eb 05                	jmp    8018a5 <fstat+0x74>
		return -E_NOT_SUPP;
  8018a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018a5:	83 c4 24             	add    $0x24,%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ba:	00 
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	89 04 24             	mov    %eax,(%esp)
  8018c1:	e8 fb 01 00 00       	call   801ac1 <open>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	85 db                	test   %ebx,%ebx
  8018ca:	78 1b                	js     8018e7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d3:	89 1c 24             	mov    %ebx,(%esp)
  8018d6:	e8 56 ff ff ff       	call   801831 <fstat>
  8018db:	89 c6                	mov    %eax,%esi
	close(fd);
  8018dd:	89 1c 24             	mov    %ebx,(%esp)
  8018e0:	e8 cd fb ff ff       	call   8014b2 <close>
	return r;
  8018e5:	89 f0                	mov    %esi,%eax
}
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	56                   	push   %esi
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 10             	sub    $0x10,%esp
  8018f6:	89 c6                	mov    %eax,%esi
  8018f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018fa:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801901:	75 11                	jne    801914 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801903:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80190a:	e8 00 09 00 00       	call   80220f <ipc_find_env>
  80190f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801914:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80191b:	00 
  80191c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801923:	00 
  801924:	89 74 24 04          	mov    %esi,0x4(%esp)
  801928:	a1 04 40 80 00       	mov    0x804004,%eax
  80192d:	89 04 24             	mov    %eax,(%esp)
  801930:	e8 73 08 00 00       	call   8021a8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801935:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80193c:	00 
  80193d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801941:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801948:	e8 f3 07 00 00       	call   802140 <ipc_recv>
}
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
  801960:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801965:	8b 45 0c             	mov    0xc(%ebp),%eax
  801968:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
  801972:	b8 02 00 00 00       	mov    $0x2,%eax
  801977:	e8 72 ff ff ff       	call   8018ee <fsipc>
}
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <devfile_flush>:
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801984:	8b 45 08             	mov    0x8(%ebp),%eax
  801987:	8b 40 0c             	mov    0xc(%eax),%eax
  80198a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	b8 06 00 00 00       	mov    $0x6,%eax
  801999:	e8 50 ff ff ff       	call   8018ee <fsipc>
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <devfile_stat>:
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 14             	sub    $0x14,%esp
  8019a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8019bf:	e8 2a ff ff ff       	call   8018ee <fsipc>
  8019c4:	89 c2                	mov    %eax,%edx
  8019c6:	85 d2                	test   %edx,%edx
  8019c8:	78 2b                	js     8019f5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019d1:	00 
  8019d2:	89 1c 24             	mov    %ebx,(%esp)
  8019d5:	e8 8d ef ff ff       	call   800967 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019da:	a1 80 50 80 00       	mov    0x805080,%eax
  8019df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019e5:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f5:	83 c4 14             	add    $0x14,%esp
  8019f8:	5b                   	pop    %ebx
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    

008019fb <devfile_write>:
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801a01:	c7 44 24 08 38 2b 80 	movl   $0x802b38,0x8(%esp)
  801a08:	00 
  801a09:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a10:	00 
  801a11:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  801a18:	e8 2e e8 ff ff       	call   80024b <_panic>

00801a1d <devfile_read>:
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	83 ec 10             	sub    $0x10,%esp
  801a25:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a33:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a39:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a43:	e8 a6 fe ff ff       	call   8018ee <fsipc>
  801a48:	89 c3                	mov    %eax,%ebx
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 6a                	js     801ab8 <devfile_read+0x9b>
	assert(r <= n);
  801a4e:	39 c6                	cmp    %eax,%esi
  801a50:	73 24                	jae    801a76 <devfile_read+0x59>
  801a52:	c7 44 24 0c 61 2b 80 	movl   $0x802b61,0xc(%esp)
  801a59:	00 
  801a5a:	c7 44 24 08 68 2b 80 	movl   $0x802b68,0x8(%esp)
  801a61:	00 
  801a62:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a69:	00 
  801a6a:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  801a71:	e8 d5 e7 ff ff       	call   80024b <_panic>
	assert(r <= PGSIZE);
  801a76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a7b:	7e 24                	jle    801aa1 <devfile_read+0x84>
  801a7d:	c7 44 24 0c 7d 2b 80 	movl   $0x802b7d,0xc(%esp)
  801a84:	00 
  801a85:	c7 44 24 08 68 2b 80 	movl   $0x802b68,0x8(%esp)
  801a8c:	00 
  801a8d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a94:	00 
  801a95:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  801a9c:	e8 aa e7 ff ff       	call   80024b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801aac:	00 
  801aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab0:	89 04 24             	mov    %eax,(%esp)
  801ab3:	e8 4c f0 ff ff       	call   800b04 <memmove>
}
  801ab8:	89 d8                	mov    %ebx,%eax
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <open>:
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 24             	sub    $0x24,%esp
  801ac8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801acb:	89 1c 24             	mov    %ebx,(%esp)
  801ace:	e8 5d ee ff ff       	call   800930 <strlen>
  801ad3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ad8:	7f 60                	jg     801b3a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801ada:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801add:	89 04 24             	mov    %eax,(%esp)
  801ae0:	e8 52 f8 ff ff       	call   801337 <fd_alloc>
  801ae5:	89 c2                	mov    %eax,%edx
  801ae7:	85 d2                	test   %edx,%edx
  801ae9:	78 54                	js     801b3f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801aeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aef:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801af6:	e8 6c ee ff ff       	call   800967 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afe:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b06:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0b:	e8 de fd ff ff       	call   8018ee <fsipc>
  801b10:	89 c3                	mov    %eax,%ebx
  801b12:	85 c0                	test   %eax,%eax
  801b14:	79 17                	jns    801b2d <open+0x6c>
		fd_close(fd, 0);
  801b16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b1d:	00 
  801b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b21:	89 04 24             	mov    %eax,(%esp)
  801b24:	e8 08 f9 ff ff       	call   801431 <fd_close>
		return r;
  801b29:	89 d8                	mov    %ebx,%eax
  801b2b:	eb 12                	jmp    801b3f <open+0x7e>
	return fd2num(fd);
  801b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b30:	89 04 24             	mov    %eax,(%esp)
  801b33:	e8 d8 f7 ff ff       	call   801310 <fd2num>
  801b38:	eb 05                	jmp    801b3f <open+0x7e>
		return -E_BAD_PATH;
  801b3a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801b3f:	83 c4 24             	add    $0x24,%esp
  801b42:	5b                   	pop    %ebx
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b50:	b8 08 00 00 00       	mov    $0x8,%eax
  801b55:	e8 94 fd ff ff       	call   8018ee <fsipc>
}
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	56                   	push   %esi
  801b60:	53                   	push   %ebx
  801b61:	83 ec 10             	sub    $0x10,%esp
  801b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6a:	89 04 24             	mov    %eax,(%esp)
  801b6d:	e8 ae f7 ff ff       	call   801320 <fd2data>
  801b72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b74:	c7 44 24 04 89 2b 80 	movl   $0x802b89,0x4(%esp)
  801b7b:	00 
  801b7c:	89 1c 24             	mov    %ebx,(%esp)
  801b7f:	e8 e3 ed ff ff       	call   800967 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b84:	8b 46 04             	mov    0x4(%esi),%eax
  801b87:	2b 06                	sub    (%esi),%eax
  801b89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b8f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b96:	00 00 00 
	stat->st_dev = &devpipe;
  801b99:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba0:	30 80 00 
	return 0;
}
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 14             	sub    $0x14,%esp
  801bb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc4:	e8 61 f2 ff ff       	call   800e2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc9:	89 1c 24             	mov    %ebx,(%esp)
  801bcc:	e8 4f f7 ff ff       	call   801320 <fd2data>
  801bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bdc:	e8 49 f2 ff ff       	call   800e2a <sys_page_unmap>
}
  801be1:	83 c4 14             	add    $0x14,%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <_pipeisclosed>:
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	57                   	push   %edi
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	83 ec 2c             	sub    $0x2c,%esp
  801bf0:	89 c6                	mov    %eax,%esi
  801bf2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801bf5:	a1 08 40 80 00       	mov    0x804008,%eax
  801bfa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bfd:	89 34 24             	mov    %esi,(%esp)
  801c00:	e8 42 06 00 00       	call   802247 <pageref>
  801c05:	89 c7                	mov    %eax,%edi
  801c07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0a:	89 04 24             	mov    %eax,(%esp)
  801c0d:	e8 35 06 00 00       	call   802247 <pageref>
  801c12:	39 c7                	cmp    %eax,%edi
  801c14:	0f 94 c2             	sete   %dl
  801c17:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c1a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801c20:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c23:	39 fb                	cmp    %edi,%ebx
  801c25:	74 21                	je     801c48 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801c27:	84 d2                	test   %dl,%dl
  801c29:	74 ca                	je     801bf5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c2b:	8b 51 58             	mov    0x58(%ecx),%edx
  801c2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c32:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3a:	c7 04 24 90 2b 80 00 	movl   $0x802b90,(%esp)
  801c41:	e8 fe e6 ff ff       	call   800344 <cprintf>
  801c46:	eb ad                	jmp    801bf5 <_pipeisclosed+0xe>
}
  801c48:	83 c4 2c             	add    $0x2c,%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5f                   	pop    %edi
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <devpipe_write>:
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	57                   	push   %edi
  801c54:	56                   	push   %esi
  801c55:	53                   	push   %ebx
  801c56:	83 ec 1c             	sub    $0x1c,%esp
  801c59:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c5c:	89 34 24             	mov    %esi,(%esp)
  801c5f:	e8 bc f6 ff ff       	call   801320 <fd2data>
  801c64:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c66:	bf 00 00 00 00       	mov    $0x0,%edi
  801c6b:	eb 45                	jmp    801cb2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801c6d:	89 da                	mov    %ebx,%edx
  801c6f:	89 f0                	mov    %esi,%eax
  801c71:	e8 71 ff ff ff       	call   801be7 <_pipeisclosed>
  801c76:	85 c0                	test   %eax,%eax
  801c78:	75 41                	jne    801cbb <devpipe_write+0x6b>
			sys_yield();
  801c7a:	e8 e5 f0 ff ff       	call   800d64 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801c82:	8b 0b                	mov    (%ebx),%ecx
  801c84:	8d 51 20             	lea    0x20(%ecx),%edx
  801c87:	39 d0                	cmp    %edx,%eax
  801c89:	73 e2                	jae    801c6d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c95:	99                   	cltd   
  801c96:	c1 ea 1b             	shr    $0x1b,%edx
  801c99:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801c9c:	83 e1 1f             	and    $0x1f,%ecx
  801c9f:	29 d1                	sub    %edx,%ecx
  801ca1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801ca5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801ca9:	83 c0 01             	add    $0x1,%eax
  801cac:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801caf:	83 c7 01             	add    $0x1,%edi
  801cb2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cb5:	75 c8                	jne    801c7f <devpipe_write+0x2f>
	return i;
  801cb7:	89 f8                	mov    %edi,%eax
  801cb9:	eb 05                	jmp    801cc0 <devpipe_write+0x70>
				return 0;
  801cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc0:	83 c4 1c             	add    $0x1c,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    

00801cc8 <devpipe_read>:
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	57                   	push   %edi
  801ccc:	56                   	push   %esi
  801ccd:	53                   	push   %ebx
  801cce:	83 ec 1c             	sub    $0x1c,%esp
  801cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cd4:	89 3c 24             	mov    %edi,(%esp)
  801cd7:	e8 44 f6 ff ff       	call   801320 <fd2data>
  801cdc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cde:	be 00 00 00 00       	mov    $0x0,%esi
  801ce3:	eb 3d                	jmp    801d22 <devpipe_read+0x5a>
			if (i > 0)
  801ce5:	85 f6                	test   %esi,%esi
  801ce7:	74 04                	je     801ced <devpipe_read+0x25>
				return i;
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	eb 43                	jmp    801d30 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801ced:	89 da                	mov    %ebx,%edx
  801cef:	89 f8                	mov    %edi,%eax
  801cf1:	e8 f1 fe ff ff       	call   801be7 <_pipeisclosed>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	75 31                	jne    801d2b <devpipe_read+0x63>
			sys_yield();
  801cfa:	e8 65 f0 ff ff       	call   800d64 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801cff:	8b 03                	mov    (%ebx),%eax
  801d01:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d04:	74 df                	je     801ce5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d06:	99                   	cltd   
  801d07:	c1 ea 1b             	shr    $0x1b,%edx
  801d0a:	01 d0                	add    %edx,%eax
  801d0c:	83 e0 1f             	and    $0x1f,%eax
  801d0f:	29 d0                	sub    %edx,%eax
  801d11:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d19:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d1c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d1f:	83 c6 01             	add    $0x1,%esi
  801d22:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d25:	75 d8                	jne    801cff <devpipe_read+0x37>
	return i;
  801d27:	89 f0                	mov    %esi,%eax
  801d29:	eb 05                	jmp    801d30 <devpipe_read+0x68>
				return 0;
  801d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <pipe>:
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d43:	89 04 24             	mov    %eax,(%esp)
  801d46:	e8 ec f5 ff ff       	call   801337 <fd_alloc>
  801d4b:	89 c2                	mov    %eax,%edx
  801d4d:	85 d2                	test   %edx,%edx
  801d4f:	0f 88 4d 01 00 00    	js     801ea2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d55:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d5c:	00 
  801d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6b:	e8 13 f0 ff ff       	call   800d83 <sys_page_alloc>
  801d70:	89 c2                	mov    %eax,%edx
  801d72:	85 d2                	test   %edx,%edx
  801d74:	0f 88 28 01 00 00    	js     801ea2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801d7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d7d:	89 04 24             	mov    %eax,(%esp)
  801d80:	e8 b2 f5 ff ff       	call   801337 <fd_alloc>
  801d85:	89 c3                	mov    %eax,%ebx
  801d87:	85 c0                	test   %eax,%eax
  801d89:	0f 88 fe 00 00 00    	js     801e8d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d96:	00 
  801d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da5:	e8 d9 ef ff ff       	call   800d83 <sys_page_alloc>
  801daa:	89 c3                	mov    %eax,%ebx
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 d9 00 00 00    	js     801e8d <pipe+0x155>
	va = fd2data(fd0);
  801db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db7:	89 04 24             	mov    %eax,(%esp)
  801dba:	e8 61 f5 ff ff       	call   801320 <fd2data>
  801dbf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dc8:	00 
  801dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd4:	e8 aa ef ff ff       	call   800d83 <sys_page_alloc>
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	0f 88 97 00 00 00    	js     801e7a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de6:	89 04 24             	mov    %eax,(%esp)
  801de9:	e8 32 f5 ff ff       	call   801320 <fd2data>
  801dee:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801df5:	00 
  801df6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dfa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e01:	00 
  801e02:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0d:	e8 c5 ef ff ff       	call   800dd7 <sys_page_map>
  801e12:	89 c3                	mov    %eax,%ebx
  801e14:	85 c0                	test   %eax,%eax
  801e16:	78 52                	js     801e6a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e45:	89 04 24             	mov    %eax,(%esp)
  801e48:	e8 c3 f4 ff ff       	call   801310 <fd2num>
  801e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e55:	89 04 24             	mov    %eax,(%esp)
  801e58:	e8 b3 f4 ff ff       	call   801310 <fd2num>
  801e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	eb 38                	jmp    801ea2 <pipe+0x16a>
	sys_page_unmap(0, va);
  801e6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e75:	e8 b0 ef ff ff       	call   800e2a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e88:	e8 9d ef ff ff       	call   800e2a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9b:	e8 8a ef ff ff       	call   800e2a <sys_page_unmap>
  801ea0:	89 d8                	mov    %ebx,%eax
}
  801ea2:	83 c4 30             	add    $0x30,%esp
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <pipeisclosed>:
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb9:	89 04 24             	mov    %eax,(%esp)
  801ebc:	e8 c5 f4 ff ff       	call   801386 <fd_lookup>
  801ec1:	89 c2                	mov    %eax,%edx
  801ec3:	85 d2                	test   %edx,%edx
  801ec5:	78 15                	js     801edc <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eca:	89 04 24             	mov    %eax,(%esp)
  801ecd:	e8 4e f4 ff ff       	call   801320 <fd2data>
	return _pipeisclosed(fd, p);
  801ed2:	89 c2                	mov    %eax,%edx
  801ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed7:	e8 0b fd ff ff       	call   801be7 <_pipeisclosed>
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    
  801ede:	66 90                	xchg   %ax,%ax

00801ee0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ef0:	c7 44 24 04 a8 2b 80 	movl   $0x802ba8,0x4(%esp)
  801ef7:	00 
  801ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efb:	89 04 24             	mov    %eax,(%esp)
  801efe:	e8 64 ea ff ff       	call   800967 <strcpy>
	return 0;
}
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <devcons_write>:
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	57                   	push   %edi
  801f0e:	56                   	push   %esi
  801f0f:	53                   	push   %ebx
  801f10:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f16:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f21:	eb 31                	jmp    801f54 <devcons_write+0x4a>
		m = n - tot;
  801f23:	8b 75 10             	mov    0x10(%ebp),%esi
  801f26:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f28:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801f2b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f30:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f33:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f37:	03 45 0c             	add    0xc(%ebp),%eax
  801f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3e:	89 3c 24             	mov    %edi,(%esp)
  801f41:	e8 be eb ff ff       	call   800b04 <memmove>
		sys_cputs(buf, m);
  801f46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f4a:	89 3c 24             	mov    %edi,(%esp)
  801f4d:	e8 64 ed ff ff       	call   800cb6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f52:	01 f3                	add    %esi,%ebx
  801f54:	89 d8                	mov    %ebx,%eax
  801f56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f59:	72 c8                	jb     801f23 <devcons_write+0x19>
}
  801f5b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5f                   	pop    %edi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    

00801f66 <devcons_read>:
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f75:	75 07                	jne    801f7e <devcons_read+0x18>
  801f77:	eb 2a                	jmp    801fa3 <devcons_read+0x3d>
		sys_yield();
  801f79:	e8 e6 ed ff ff       	call   800d64 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f7e:	66 90                	xchg   %ax,%ax
  801f80:	e8 4f ed ff ff       	call   800cd4 <sys_cgetc>
  801f85:	85 c0                	test   %eax,%eax
  801f87:	74 f0                	je     801f79 <devcons_read+0x13>
	if (c < 0)
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 16                	js     801fa3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801f8d:	83 f8 04             	cmp    $0x4,%eax
  801f90:	74 0c                	je     801f9e <devcons_read+0x38>
	*(char*)vbuf = c;
  801f92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f95:	88 02                	mov    %al,(%edx)
	return 1;
  801f97:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9c:	eb 05                	jmp    801fa3 <devcons_read+0x3d>
		return 0;
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    

00801fa5 <cputchar>:
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801fb1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fb8:	00 
  801fb9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fbc:	89 04 24             	mov    %eax,(%esp)
  801fbf:	e8 f2 ec ff ff       	call   800cb6 <sys_cputs>
}
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <getchar>:
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801fcc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801fd3:	00 
  801fd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe2:	e8 2e f6 ff ff       	call   801615 <read>
	if (r < 0)
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	78 0f                	js     801ffa <getchar+0x34>
	if (r < 1)
  801feb:	85 c0                	test   %eax,%eax
  801fed:	7e 06                	jle    801ff5 <getchar+0x2f>
	return c;
  801fef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ff3:	eb 05                	jmp    801ffa <getchar+0x34>
		return -E_EOF;
  801ff5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801ffa:	c9                   	leave  
  801ffb:	c3                   	ret    

00801ffc <iscons>:
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802002:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802005:	89 44 24 04          	mov    %eax,0x4(%esp)
  802009:	8b 45 08             	mov    0x8(%ebp),%eax
  80200c:	89 04 24             	mov    %eax,(%esp)
  80200f:	e8 72 f3 ff ff       	call   801386 <fd_lookup>
  802014:	85 c0                	test   %eax,%eax
  802016:	78 11                	js     802029 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802021:	39 10                	cmp    %edx,(%eax)
  802023:	0f 94 c0             	sete   %al
  802026:	0f b6 c0             	movzbl %al,%eax
}
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <opencons>:
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802034:	89 04 24             	mov    %eax,(%esp)
  802037:	e8 fb f2 ff ff       	call   801337 <fd_alloc>
		return r;
  80203c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80203e:	85 c0                	test   %eax,%eax
  802040:	78 40                	js     802082 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802042:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802049:	00 
  80204a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802051:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802058:	e8 26 ed ff ff       	call   800d83 <sys_page_alloc>
		return r;
  80205d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 1f                	js     802082 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802063:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802069:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80206e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802071:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802078:	89 04 24             	mov    %eax,(%esp)
  80207b:	e8 90 f2 ff ff       	call   801310 <fd2num>
  802080:	89 c2                	mov    %eax,%edx
}
  802082:	89 d0                	mov    %edx,%eax
  802084:	c9                   	leave  
  802085:	c3                   	ret    

00802086 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  80208c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802093:	75 70                	jne    802105 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802095:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80209c:	00 
  80209d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8020a4:	ee 
  8020a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ac:	e8 d2 ec ff ff       	call   800d83 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	79 1c                	jns    8020d1 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  8020b5:	c7 44 24 08 b4 2b 80 	movl   $0x802bb4,0x8(%esp)
  8020bc:	00 
  8020bd:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8020c4:	00 
  8020c5:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  8020cc:	e8 7a e1 ff ff       	call   80024b <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  8020d1:	c7 44 24 04 0f 21 80 	movl   $0x80210f,0x4(%esp)
  8020d8:	00 
  8020d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e0:	e8 3e ee ff ff       	call   800f23 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	79 1c                	jns    802105 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  8020e9:	c7 44 24 08 dc 2b 80 	movl   $0x802bdc,0x8(%esp)
  8020f0:	00 
  8020f1:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8020f8:	00 
  8020f9:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  802100:	e8 46 e1 ff ff       	call   80024b <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802105:	8b 45 08             	mov    0x8(%ebp),%eax
  802108:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80210d:	c9                   	leave  
  80210e:	c3                   	ret    

0080210f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80210f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802110:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802115:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802117:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  80211a:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  80211e:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802122:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  802124:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  802126:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  802127:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  80212a:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  80212c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  80212f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802130:	83 c4 04             	add    $0x4,%esp
    popf;
  802133:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  802134:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  802135:	c3                   	ret    
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	56                   	push   %esi
  802144:	53                   	push   %ebx
  802145:	83 ec 10             	sub    $0x10,%esp
  802148:	8b 75 08             	mov    0x8(%ebp),%esi
  80214b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802151:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802153:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802158:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80215b:	89 04 24             	mov    %eax,(%esp)
  80215e:	e8 36 ee ff ff       	call   800f99 <sys_ipc_recv>
    if(r < 0){
  802163:	85 c0                	test   %eax,%eax
  802165:	79 16                	jns    80217d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802167:	85 f6                	test   %esi,%esi
  802169:	74 06                	je     802171 <ipc_recv+0x31>
            *from_env_store = 0;
  80216b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802171:	85 db                	test   %ebx,%ebx
  802173:	74 2c                	je     8021a1 <ipc_recv+0x61>
            *perm_store = 0;
  802175:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80217b:	eb 24                	jmp    8021a1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80217d:	85 f6                	test   %esi,%esi
  80217f:	74 0a                	je     80218b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802181:	a1 08 40 80 00       	mov    0x804008,%eax
  802186:	8b 40 74             	mov    0x74(%eax),%eax
  802189:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80218b:	85 db                	test   %ebx,%ebx
  80218d:	74 0a                	je     802199 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80218f:	a1 08 40 80 00       	mov    0x804008,%eax
  802194:	8b 40 78             	mov    0x78(%eax),%eax
  802197:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802199:	a1 08 40 80 00       	mov    0x804008,%eax
  80219e:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	57                   	push   %edi
  8021ac:	56                   	push   %esi
  8021ad:	53                   	push   %ebx
  8021ae:	83 ec 1c             	sub    $0x1c,%esp
  8021b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  8021ba:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  8021bc:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8021c1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8021c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8021c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021cb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	e8 9b ed ff ff       	call   800f76 <sys_ipc_try_send>
        if(r == 0){
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	74 28                	je     802207 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8021df:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021e2:	74 1c                	je     802200 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8021e4:	c7 44 24 08 1e 2c 80 	movl   $0x802c1e,0x8(%esp)
  8021eb:	00 
  8021ec:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8021f3:	00 
  8021f4:	c7 04 24 35 2c 80 00 	movl   $0x802c35,(%esp)
  8021fb:	e8 4b e0 ff ff       	call   80024b <_panic>
        }
        sys_yield();
  802200:	e8 5f eb ff ff       	call   800d64 <sys_yield>
    }
  802205:	eb bd                	jmp    8021c4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802207:	83 c4 1c             	add    $0x1c,%esp
  80220a:	5b                   	pop    %ebx
  80220b:	5e                   	pop    %esi
  80220c:	5f                   	pop    %edi
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802215:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80221a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80221d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802223:	8b 52 50             	mov    0x50(%edx),%edx
  802226:	39 ca                	cmp    %ecx,%edx
  802228:	75 0d                	jne    802237 <ipc_find_env+0x28>
			return envs[i].env_id;
  80222a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80222d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802232:	8b 40 40             	mov    0x40(%eax),%eax
  802235:	eb 0e                	jmp    802245 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802237:	83 c0 01             	add    $0x1,%eax
  80223a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80223f:	75 d9                	jne    80221a <ipc_find_env+0xb>
	return 0;
  802241:	66 b8 00 00          	mov    $0x0,%ax
}
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    

00802247 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802247:	55                   	push   %ebp
  802248:	89 e5                	mov    %esp,%ebp
  80224a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80224d:	89 d0                	mov    %edx,%eax
  80224f:	c1 e8 16             	shr    $0x16,%eax
  802252:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802259:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80225e:	f6 c1 01             	test   $0x1,%cl
  802261:	74 1d                	je     802280 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802263:	c1 ea 0c             	shr    $0xc,%edx
  802266:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80226d:	f6 c2 01             	test   $0x1,%dl
  802270:	74 0e                	je     802280 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802272:	c1 ea 0c             	shr    $0xc,%edx
  802275:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80227c:	ef 
  80227d:	0f b7 c0             	movzwl %ax,%eax
}
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__udivdi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	83 ec 0c             	sub    $0xc,%esp
  802296:	8b 44 24 28          	mov    0x28(%esp),%eax
  80229a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80229e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8022a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022ac:	89 ea                	mov    %ebp,%edx
  8022ae:	89 0c 24             	mov    %ecx,(%esp)
  8022b1:	75 2d                	jne    8022e0 <__udivdi3+0x50>
  8022b3:	39 e9                	cmp    %ebp,%ecx
  8022b5:	77 61                	ja     802318 <__udivdi3+0x88>
  8022b7:	85 c9                	test   %ecx,%ecx
  8022b9:	89 ce                	mov    %ecx,%esi
  8022bb:	75 0b                	jne    8022c8 <__udivdi3+0x38>
  8022bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c2:	31 d2                	xor    %edx,%edx
  8022c4:	f7 f1                	div    %ecx
  8022c6:	89 c6                	mov    %eax,%esi
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	89 e8                	mov    %ebp,%eax
  8022cc:	f7 f6                	div    %esi
  8022ce:	89 c5                	mov    %eax,%ebp
  8022d0:	89 f8                	mov    %edi,%eax
  8022d2:	f7 f6                	div    %esi
  8022d4:	89 ea                	mov    %ebp,%edx
  8022d6:	83 c4 0c             	add    $0xc,%esp
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	39 e8                	cmp    %ebp,%eax
  8022e2:	77 24                	ja     802308 <__udivdi3+0x78>
  8022e4:	0f bd e8             	bsr    %eax,%ebp
  8022e7:	83 f5 1f             	xor    $0x1f,%ebp
  8022ea:	75 3c                	jne    802328 <__udivdi3+0x98>
  8022ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022f0:	39 34 24             	cmp    %esi,(%esp)
  8022f3:	0f 86 9f 00 00 00    	jbe    802398 <__udivdi3+0x108>
  8022f9:	39 d0                	cmp    %edx,%eax
  8022fb:	0f 82 97 00 00 00    	jb     802398 <__udivdi3+0x108>
  802301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802308:	31 d2                	xor    %edx,%edx
  80230a:	31 c0                	xor    %eax,%eax
  80230c:	83 c4 0c             	add    $0xc,%esp
  80230f:	5e                   	pop    %esi
  802310:	5f                   	pop    %edi
  802311:	5d                   	pop    %ebp
  802312:	c3                   	ret    
  802313:	90                   	nop
  802314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802318:	89 f8                	mov    %edi,%eax
  80231a:	f7 f1                	div    %ecx
  80231c:	31 d2                	xor    %edx,%edx
  80231e:	83 c4 0c             	add    $0xc,%esp
  802321:	5e                   	pop    %esi
  802322:	5f                   	pop    %edi
  802323:	5d                   	pop    %ebp
  802324:	c3                   	ret    
  802325:	8d 76 00             	lea    0x0(%esi),%esi
  802328:	89 e9                	mov    %ebp,%ecx
  80232a:	8b 3c 24             	mov    (%esp),%edi
  80232d:	d3 e0                	shl    %cl,%eax
  80232f:	89 c6                	mov    %eax,%esi
  802331:	b8 20 00 00 00       	mov    $0x20,%eax
  802336:	29 e8                	sub    %ebp,%eax
  802338:	89 c1                	mov    %eax,%ecx
  80233a:	d3 ef                	shr    %cl,%edi
  80233c:	89 e9                	mov    %ebp,%ecx
  80233e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802342:	8b 3c 24             	mov    (%esp),%edi
  802345:	09 74 24 08          	or     %esi,0x8(%esp)
  802349:	89 d6                	mov    %edx,%esi
  80234b:	d3 e7                	shl    %cl,%edi
  80234d:	89 c1                	mov    %eax,%ecx
  80234f:	89 3c 24             	mov    %edi,(%esp)
  802352:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802356:	d3 ee                	shr    %cl,%esi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	d3 e2                	shl    %cl,%edx
  80235c:	89 c1                	mov    %eax,%ecx
  80235e:	d3 ef                	shr    %cl,%edi
  802360:	09 d7                	or     %edx,%edi
  802362:	89 f2                	mov    %esi,%edx
  802364:	89 f8                	mov    %edi,%eax
  802366:	f7 74 24 08          	divl   0x8(%esp)
  80236a:	89 d6                	mov    %edx,%esi
  80236c:	89 c7                	mov    %eax,%edi
  80236e:	f7 24 24             	mull   (%esp)
  802371:	39 d6                	cmp    %edx,%esi
  802373:	89 14 24             	mov    %edx,(%esp)
  802376:	72 30                	jb     8023a8 <__udivdi3+0x118>
  802378:	8b 54 24 04          	mov    0x4(%esp),%edx
  80237c:	89 e9                	mov    %ebp,%ecx
  80237e:	d3 e2                	shl    %cl,%edx
  802380:	39 c2                	cmp    %eax,%edx
  802382:	73 05                	jae    802389 <__udivdi3+0xf9>
  802384:	3b 34 24             	cmp    (%esp),%esi
  802387:	74 1f                	je     8023a8 <__udivdi3+0x118>
  802389:	89 f8                	mov    %edi,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	e9 7a ff ff ff       	jmp    80230c <__udivdi3+0x7c>
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	31 d2                	xor    %edx,%edx
  80239a:	b8 01 00 00 00       	mov    $0x1,%eax
  80239f:	e9 68 ff ff ff       	jmp    80230c <__udivdi3+0x7c>
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	83 c4 0c             	add    $0xc,%esp
  8023b0:	5e                   	pop    %esi
  8023b1:	5f                   	pop    %edi
  8023b2:	5d                   	pop    %ebp
  8023b3:	c3                   	ret    
  8023b4:	66 90                	xchg   %ax,%ax
  8023b6:	66 90                	xchg   %ax,%ax
  8023b8:	66 90                	xchg   %ax,%ax
  8023ba:	66 90                	xchg   %ax,%ax
  8023bc:	66 90                	xchg   %ax,%ax
  8023be:	66 90                	xchg   %ax,%ax

008023c0 <__umoddi3>:
  8023c0:	55                   	push   %ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	83 ec 14             	sub    $0x14,%esp
  8023c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8023ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8023d2:	89 c7                	mov    %eax,%edi
  8023d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8023e0:	89 34 24             	mov    %esi,(%esp)
  8023e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023e7:	85 c0                	test   %eax,%eax
  8023e9:	89 c2                	mov    %eax,%edx
  8023eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023ef:	75 17                	jne    802408 <__umoddi3+0x48>
  8023f1:	39 fe                	cmp    %edi,%esi
  8023f3:	76 4b                	jbe    802440 <__umoddi3+0x80>
  8023f5:	89 c8                	mov    %ecx,%eax
  8023f7:	89 fa                	mov    %edi,%edx
  8023f9:	f7 f6                	div    %esi
  8023fb:	89 d0                	mov    %edx,%eax
  8023fd:	31 d2                	xor    %edx,%edx
  8023ff:	83 c4 14             	add    $0x14,%esp
  802402:	5e                   	pop    %esi
  802403:	5f                   	pop    %edi
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    
  802406:	66 90                	xchg   %ax,%ax
  802408:	39 f8                	cmp    %edi,%eax
  80240a:	77 54                	ja     802460 <__umoddi3+0xa0>
  80240c:	0f bd e8             	bsr    %eax,%ebp
  80240f:	83 f5 1f             	xor    $0x1f,%ebp
  802412:	75 5c                	jne    802470 <__umoddi3+0xb0>
  802414:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802418:	39 3c 24             	cmp    %edi,(%esp)
  80241b:	0f 87 e7 00 00 00    	ja     802508 <__umoddi3+0x148>
  802421:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802425:	29 f1                	sub    %esi,%ecx
  802427:	19 c7                	sbb    %eax,%edi
  802429:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80242d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802431:	8b 44 24 08          	mov    0x8(%esp),%eax
  802435:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802439:	83 c4 14             	add    $0x14,%esp
  80243c:	5e                   	pop    %esi
  80243d:	5f                   	pop    %edi
  80243e:	5d                   	pop    %ebp
  80243f:	c3                   	ret    
  802440:	85 f6                	test   %esi,%esi
  802442:	89 f5                	mov    %esi,%ebp
  802444:	75 0b                	jne    802451 <__umoddi3+0x91>
  802446:	b8 01 00 00 00       	mov    $0x1,%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	f7 f6                	div    %esi
  80244f:	89 c5                	mov    %eax,%ebp
  802451:	8b 44 24 04          	mov    0x4(%esp),%eax
  802455:	31 d2                	xor    %edx,%edx
  802457:	f7 f5                	div    %ebp
  802459:	89 c8                	mov    %ecx,%eax
  80245b:	f7 f5                	div    %ebp
  80245d:	eb 9c                	jmp    8023fb <__umoddi3+0x3b>
  80245f:	90                   	nop
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 fa                	mov    %edi,%edx
  802464:	83 c4 14             	add    $0x14,%esp
  802467:	5e                   	pop    %esi
  802468:	5f                   	pop    %edi
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    
  80246b:	90                   	nop
  80246c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802470:	8b 04 24             	mov    (%esp),%eax
  802473:	be 20 00 00 00       	mov    $0x20,%esi
  802478:	89 e9                	mov    %ebp,%ecx
  80247a:	29 ee                	sub    %ebp,%esi
  80247c:	d3 e2                	shl    %cl,%edx
  80247e:	89 f1                	mov    %esi,%ecx
  802480:	d3 e8                	shr    %cl,%eax
  802482:	89 e9                	mov    %ebp,%ecx
  802484:	89 44 24 04          	mov    %eax,0x4(%esp)
  802488:	8b 04 24             	mov    (%esp),%eax
  80248b:	09 54 24 04          	or     %edx,0x4(%esp)
  80248f:	89 fa                	mov    %edi,%edx
  802491:	d3 e0                	shl    %cl,%eax
  802493:	89 f1                	mov    %esi,%ecx
  802495:	89 44 24 08          	mov    %eax,0x8(%esp)
  802499:	8b 44 24 10          	mov    0x10(%esp),%eax
  80249d:	d3 ea                	shr    %cl,%edx
  80249f:	89 e9                	mov    %ebp,%ecx
  8024a1:	d3 e7                	shl    %cl,%edi
  8024a3:	89 f1                	mov    %esi,%ecx
  8024a5:	d3 e8                	shr    %cl,%eax
  8024a7:	89 e9                	mov    %ebp,%ecx
  8024a9:	09 f8                	or     %edi,%eax
  8024ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8024af:	f7 74 24 04          	divl   0x4(%esp)
  8024b3:	d3 e7                	shl    %cl,%edi
  8024b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024b9:	89 d7                	mov    %edx,%edi
  8024bb:	f7 64 24 08          	mull   0x8(%esp)
  8024bf:	39 d7                	cmp    %edx,%edi
  8024c1:	89 c1                	mov    %eax,%ecx
  8024c3:	89 14 24             	mov    %edx,(%esp)
  8024c6:	72 2c                	jb     8024f4 <__umoddi3+0x134>
  8024c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8024cc:	72 22                	jb     8024f0 <__umoddi3+0x130>
  8024ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024d2:	29 c8                	sub    %ecx,%eax
  8024d4:	19 d7                	sbb    %edx,%edi
  8024d6:	89 e9                	mov    %ebp,%ecx
  8024d8:	89 fa                	mov    %edi,%edx
  8024da:	d3 e8                	shr    %cl,%eax
  8024dc:	89 f1                	mov    %esi,%ecx
  8024de:	d3 e2                	shl    %cl,%edx
  8024e0:	89 e9                	mov    %ebp,%ecx
  8024e2:	d3 ef                	shr    %cl,%edi
  8024e4:	09 d0                	or     %edx,%eax
  8024e6:	89 fa                	mov    %edi,%edx
  8024e8:	83 c4 14             	add    $0x14,%esp
  8024eb:	5e                   	pop    %esi
  8024ec:	5f                   	pop    %edi
  8024ed:	5d                   	pop    %ebp
  8024ee:	c3                   	ret    
  8024ef:	90                   	nop
  8024f0:	39 d7                	cmp    %edx,%edi
  8024f2:	75 da                	jne    8024ce <__umoddi3+0x10e>
  8024f4:	8b 14 24             	mov    (%esp),%edx
  8024f7:	89 c1                	mov    %eax,%ecx
  8024f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8024fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802501:	eb cb                	jmp    8024ce <__umoddi3+0x10e>
  802503:	90                   	nop
  802504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802508:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80250c:	0f 82 0f ff ff ff    	jb     802421 <__umoddi3+0x61>
  802512:	e9 1a ff ff ff       	jmp    802431 <__umoddi3+0x71>
