
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 8e 00 00 00       	call   8000bf <libmain>
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
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  80004e:	e8 70 01 00 00       	call   8001c3 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 3a 0f 00 00       	call   800f92 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  800065:	e8 59 01 00 00       	call   8001c3 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 28 24 80 00 	movl   $0x802428,(%esp)
  800073:	e8 4b 01 00 00       	call   8001c3 <cprintf>
	sys_yield();
  800078:	e8 67 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80007d:	e8 62 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800082:	e8 5d 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800087:	e8 58 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 4f 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800095:	e8 4a 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80009a:	e8 45 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 3f 0b 00 00       	call   800be4 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 50 24 80 00 	movl   $0x802450,(%esp)
  8000ac:	e8 12 01 00 00       	call   8001c3 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 ba 0a 00 00       	call   800b73 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 10             	sub    $0x10,%esp
  8000c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8000cd:	e8 f3 0a 00 00       	call   800bc5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000df:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 db                	test   %ebx,%ebx
  8000e6:	7e 07                	jle    8000ef <libmain+0x30>
		binaryname = argv[0];
  8000e8:	8b 06                	mov    (%esi),%eax
  8000ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f3:	89 1c 24             	mov    %ebx,(%esp)
  8000f6:	e8 45 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 07 00 00 00       	call   800107 <exit>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80010d:	e8 53 12 00 00       	call   801365 <close_all>
	sys_env_destroy(0);
  800112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800119:	e8 55 0a 00 00       	call   800b73 <sys_env_destroy>
}
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	75 19                	jne    800158 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80013f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800146:	00 
  800147:	8d 43 08             	lea    0x8(%ebx),%eax
  80014a:	89 04 24             	mov    %eax,(%esp)
  80014d:	e8 e4 09 00 00       	call   800b36 <sys_cputs>
		b->idx = 0;
  800152:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800158:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015c:	83 c4 14             	add    $0x14,%esp
  80015f:	5b                   	pop    %ebx
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800172:	00 00 00 
	b.cnt = 0;
  800175:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800182:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800193:	89 44 24 04          	mov    %eax,0x4(%esp)
  800197:	c7 04 24 20 01 80 00 	movl   $0x800120,(%esp)
  80019e:	e8 ab 01 00 00       	call   80034e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 7b 09 00 00       	call   800b36 <sys_cputs>

	return b.cnt;
}
  8001bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 87 ff ff ff       	call   800162 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	66 90                	xchg   %ax,%ax
  8001df:	90                   	nop

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800202:	b9 00 00 00 00       	mov    $0x0,%ecx
  800207:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80020d:	39 d9                	cmp    %ebx,%ecx
  80020f:	72 05                	jb     800216 <printnum+0x36>
  800211:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800214:	77 69                	ja     80027f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800216:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800219:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80021d:	83 ee 01             	sub    $0x1,%esi
  800220:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	8b 44 24 08          	mov    0x8(%esp),%eax
  80022c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800230:	89 c3                	mov    %eax,%ebx
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800237:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80023a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80023e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 0c 1f 00 00       	call   802160 <__udivdi3>
  800254:	89 d9                	mov    %ebx,%ecx
  800256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	89 54 24 04          	mov    %edx,0x4(%esp)
  800265:	89 fa                	mov    %edi,%edx
  800267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026a:	e8 71 ff ff ff       	call   8001e0 <printnum>
  80026f:	eb 1b                	jmp    80028c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff d3                	call   *%ebx
  80027d:	eb 03                	jmp    800282 <printnum+0xa2>
  80027f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800282:	83 ee 01             	sub    $0x1,%esi
  800285:	85 f6                	test   %esi,%esi
  800287:	7f e8                	jg     800271 <printnum+0x91>
  800289:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800290:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800294:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800297:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	e8 dc 1f 00 00       	call   802290 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 a0 24 80 00 	movsbl 0x8024a0(%eax),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c5:	ff d0                	call   *%eax
}
  8002c7:	83 c4 3c             	add    $0x3c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d2:	83 fa 01             	cmp    $0x1,%edx
  8002d5:	7e 0e                	jle    8002e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 02                	mov    (%edx),%eax
  8002e0:	8b 52 04             	mov    0x4(%edx),%edx
  8002e3:	eb 22                	jmp    800307 <getuint+0x38>
	else if (lflag)
  8002e5:	85 d2                	test   %edx,%edx
  8002e7:	74 10                	je     8002f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f7:	eb 0e                	jmp    800307 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800313:	8b 10                	mov    (%eax),%edx
  800315:	3b 50 04             	cmp    0x4(%eax),%edx
  800318:	73 0a                	jae    800324 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 45 08             	mov    0x8(%ebp),%eax
  800322:	88 02                	mov    %al,(%edx)
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <printfmt>:
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80032c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800333:	8b 45 10             	mov    0x10(%ebp),%eax
  800336:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	8b 45 08             	mov    0x8(%ebp),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	e8 02 00 00 00       	call   80034e <vprintfmt>
}
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <vprintfmt>:
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 3c             	sub    $0x3c,%esp
  800357:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80035a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035d:	eb 1f                	jmp    80037e <vprintfmt+0x30>
			if (ch == '\0'){
  80035f:	85 c0                	test   %eax,%eax
  800361:	75 0f                	jne    800372 <vprintfmt+0x24>
				color = 0x0100;
  800363:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80036a:	01 00 00 
  80036d:	e9 b3 03 00 00       	jmp    800725 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800372:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800376:	89 04 24             	mov    %eax,(%esp)
  800379:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037c:	89 f3                	mov    %esi,%ebx
  80037e:	8d 73 01             	lea    0x1(%ebx),%esi
  800381:	0f b6 03             	movzbl (%ebx),%eax
  800384:	83 f8 25             	cmp    $0x25,%eax
  800387:	75 d6                	jne    80035f <vprintfmt+0x11>
  800389:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80038d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800394:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80039b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a7:	eb 1d                	jmp    8003c6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	89 de                	mov    %ebx,%esi
			padc = '-';
  8003ab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003af:	eb 15                	jmp    8003c6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	89 de                	mov    %ebx,%esi
			padc = '0';
  8003b3:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003b7:	eb 0d                	jmp    8003c6 <vprintfmt+0x78>
				width = precision, precision = -1;
  8003b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003bf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003c9:	0f b6 0e             	movzbl (%esi),%ecx
  8003cc:	0f b6 c1             	movzbl %cl,%eax
  8003cf:	83 e9 23             	sub    $0x23,%ecx
  8003d2:	80 f9 55             	cmp    $0x55,%cl
  8003d5:	0f 87 2a 03 00 00    	ja     800705 <vprintfmt+0x3b7>
  8003db:	0f b6 c9             	movzbl %cl,%ecx
  8003de:	ff 24 8d e0 25 80 00 	jmp    *0x8025e0(,%ecx,4)
  8003e5:	89 de                	mov    %ebx,%esi
  8003e7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8003ec:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003ef:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003f3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003f9:	83 fb 09             	cmp    $0x9,%ebx
  8003fc:	77 36                	ja     800434 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8003fe:	83 c6 01             	add    $0x1,%esi
			}
  800401:	eb e9                	jmp    8003ec <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 48 04             	lea    0x4(%eax),%ecx
  800409:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040c:	8b 00                	mov    (%eax),%eax
  80040e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800411:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800413:	eb 22                	jmp    800437 <vprintfmt+0xe9>
  800415:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800418:	85 c9                	test   %ecx,%ecx
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	0f 49 c1             	cmovns %ecx,%eax
  800422:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800425:	89 de                	mov    %ebx,%esi
  800427:	eb 9d                	jmp    8003c6 <vprintfmt+0x78>
  800429:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80042b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800432:	eb 92                	jmp    8003c6 <vprintfmt+0x78>
  800434:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800437:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80043b:	79 89                	jns    8003c6 <vprintfmt+0x78>
  80043d:	e9 77 ff ff ff       	jmp    8003b9 <vprintfmt+0x6b>
			lflag++;
  800442:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800445:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800447:	e9 7a ff ff ff       	jmp    8003c6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8d 50 04             	lea    0x4(%eax),%edx
  800452:	89 55 14             	mov    %edx,0x14(%ebp)
  800455:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800461:	e9 18 ff ff ff       	jmp    80037e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	99                   	cltd   
  800472:	31 d0                	xor    %edx,%eax
  800474:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800476:	83 f8 0f             	cmp    $0xf,%eax
  800479:	7f 0b                	jg     800486 <vprintfmt+0x138>
  80047b:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800482:	85 d2                	test   %edx,%edx
  800484:	75 20                	jne    8004a6 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800486:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048a:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  800491:	00 
  800492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	89 04 24             	mov    %eax,(%esp)
  80049c:	e8 85 fe ff ff       	call   800326 <printfmt>
  8004a1:	e9 d8 fe ff ff       	jmp    80037e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  8004a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004aa:	c7 44 24 08 fa 29 80 	movl   $0x8029fa,0x8(%esp)
  8004b1:	00 
  8004b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b9:	89 04 24             	mov    %eax,(%esp)
  8004bc:	e8 65 fe ff ff       	call   800326 <printfmt>
  8004c1:	e9 b8 fe ff ff       	jmp    80037e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	b8 b1 24 80 00       	mov    $0x8024b1,%eax
  8004e1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004e4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004e8:	0f 84 97 00 00 00    	je     800585 <vprintfmt+0x237>
  8004ee:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004f2:	0f 8e 9b 00 00 00    	jle    800593 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004fc:	89 34 24             	mov    %esi,(%esp)
  8004ff:	e8 c4 02 00 00       	call   8007c8 <strnlen>
  800504:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800507:	29 c2                	sub    %eax,%edx
  800509:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80050c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800510:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800513:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800516:	8b 75 08             	mov    0x8(%ebp),%esi
  800519:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80051c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	eb 0f                	jmp    80052f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800520:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800524:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	85 db                	test   %ebx,%ebx
  800531:	7f ed                	jg     800520 <vprintfmt+0x1d2>
  800533:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800536:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800539:	85 d2                	test   %edx,%edx
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	0f 49 c2             	cmovns %edx,%eax
  800543:	29 c2                	sub    %eax,%edx
  800545:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800548:	89 d7                	mov    %edx,%edi
  80054a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80054d:	eb 50                	jmp    80059f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800553:	74 1e                	je     800573 <vprintfmt+0x225>
  800555:	0f be d2             	movsbl %dl,%edx
  800558:	83 ea 20             	sub    $0x20,%edx
  80055b:	83 fa 5e             	cmp    $0x5e,%edx
  80055e:	76 13                	jbe    800573 <vprintfmt+0x225>
					putch('?', putdat);
  800560:	8b 45 0c             	mov    0xc(%ebp),%eax
  800563:	89 44 24 04          	mov    %eax,0x4(%esp)
  800567:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056e:	ff 55 08             	call   *0x8(%ebp)
  800571:	eb 0d                	jmp    800580 <vprintfmt+0x232>
					putch(ch, putdat);
  800573:	8b 55 0c             	mov    0xc(%ebp),%edx
  800576:	89 54 24 04          	mov    %edx,0x4(%esp)
  80057a:	89 04 24             	mov    %eax,(%esp)
  80057d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	83 ef 01             	sub    $0x1,%edi
  800583:	eb 1a                	jmp    80059f <vprintfmt+0x251>
  800585:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800588:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80058b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80058e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800591:	eb 0c                	jmp    80059f <vprintfmt+0x251>
  800593:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800596:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800599:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80059c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80059f:	83 c6 01             	add    $0x1,%esi
  8005a2:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005a6:	0f be c2             	movsbl %dl,%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	74 27                	je     8005d4 <vprintfmt+0x286>
  8005ad:	85 db                	test   %ebx,%ebx
  8005af:	78 9e                	js     80054f <vprintfmt+0x201>
  8005b1:	83 eb 01             	sub    $0x1,%ebx
  8005b4:	79 99                	jns    80054f <vprintfmt+0x201>
  8005b6:	89 f8                	mov    %edi,%eax
  8005b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005be:	89 c3                	mov    %eax,%ebx
  8005c0:	eb 1a                	jmp    8005dc <vprintfmt+0x28e>
				putch(' ', putdat);
  8005c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005cd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005cf:	83 eb 01             	sub    $0x1,%ebx
  8005d2:	eb 08                	jmp    8005dc <vprintfmt+0x28e>
  8005d4:	89 fb                	mov    %edi,%ebx
  8005d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005dc:	85 db                	test   %ebx,%ebx
  8005de:	7f e2                	jg     8005c2 <vprintfmt+0x274>
  8005e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005e6:	e9 93 fd ff ff       	jmp    80037e <vprintfmt+0x30>
	if (lflag >= 2)
  8005eb:	83 fa 01             	cmp    $0x1,%edx
  8005ee:	7e 16                	jle    800606 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 08             	lea    0x8(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	8b 50 04             	mov    0x4(%eax),%edx
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800601:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800604:	eb 32                	jmp    800638 <vprintfmt+0x2ea>
	else if (lflag)
  800606:	85 d2                	test   %edx,%edx
  800608:	74 18                	je     800622 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 50 04             	lea    0x4(%eax),%edx
  800610:	89 55 14             	mov    %edx,0x14(%ebp)
  800613:	8b 30                	mov    (%eax),%esi
  800615:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800618:	89 f0                	mov    %esi,%eax
  80061a:	c1 f8 1f             	sar    $0x1f,%eax
  80061d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800620:	eb 16                	jmp    800638 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 30                	mov    (%eax),%esi
  80062d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800630:	89 f0                	mov    %esi,%eax
  800632:	c1 f8 1f             	sar    $0x1f,%eax
  800635:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800638:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80063e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800643:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800647:	0f 89 80 00 00 00    	jns    8006cd <vprintfmt+0x37f>
				putch('-', putdat);
  80064d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800651:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800658:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80065e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800661:	f7 d8                	neg    %eax
  800663:	83 d2 00             	adc    $0x0,%edx
  800666:	f7 da                	neg    %edx
			base = 10;
  800668:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066d:	eb 5e                	jmp    8006cd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	e8 58 fc ff ff       	call   8002cf <getuint>
			base = 10;
  800677:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067c:	eb 4f                	jmp    8006cd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 49 fc ff ff       	call   8002cf <getuint>
            base = 8;
  800686:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80068b:	eb 40                	jmp    8006cd <vprintfmt+0x37f>
			putch('0', putdat);
  80068d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800691:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80069b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a6:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 04             	lea    0x4(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8006b9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006be:	eb 0d                	jmp    8006cd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c3:	e8 07 fc ff ff       	call   8002cf <getuint>
			base = 16;
  8006c8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006cd:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8006d1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006d5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006dc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e7:	89 fa                	mov    %edi,%edx
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	e8 ef fa ff ff       	call   8001e0 <printnum>
			break;
  8006f1:	e9 88 fc ff ff       	jmp    80037e <vprintfmt+0x30>
			putch(ch, putdat);
  8006f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fa:	89 04 24             	mov    %eax,(%esp)
  8006fd:	ff 55 08             	call   *0x8(%ebp)
			break;
  800700:	e9 79 fc ff ff       	jmp    80037e <vprintfmt+0x30>
			putch('%', putdat);
  800705:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800709:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800710:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800713:	89 f3                	mov    %esi,%ebx
  800715:	eb 03                	jmp    80071a <vprintfmt+0x3cc>
  800717:	83 eb 01             	sub    $0x1,%ebx
  80071a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80071e:	75 f7                	jne    800717 <vprintfmt+0x3c9>
  800720:	e9 59 fc ff ff       	jmp    80037e <vprintfmt+0x30>
}
  800725:	83 c4 3c             	add    $0x3c,%esp
  800728:	5b                   	pop    %ebx
  800729:	5e                   	pop    %esi
  80072a:	5f                   	pop    %edi
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 28             	sub    $0x28,%esp
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800739:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800740:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800743:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074a:	85 c0                	test   %eax,%eax
  80074c:	74 30                	je     80077e <vsnprintf+0x51>
  80074e:	85 d2                	test   %edx,%edx
  800750:	7e 2c                	jle    80077e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800759:	8b 45 10             	mov    0x10(%ebp),%eax
  80075c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800760:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800763:	89 44 24 04          	mov    %eax,0x4(%esp)
  800767:	c7 04 24 09 03 80 00 	movl   $0x800309,(%esp)
  80076e:	e8 db fb ff ff       	call   80034e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800773:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800776:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077c:	eb 05                	jmp    800783 <vsnprintf+0x56>
		return -E_INVAL;
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800792:	8b 45 10             	mov    0x10(%ebp),%eax
  800795:	89 44 24 08          	mov    %eax,0x8(%esp)
  800799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	e8 82 ff ff ff       	call   80072d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    
  8007ad:	66 90                	xchg   %ax,%ax
  8007af:	90                   	nop

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 03                	jmp    8007c0 <strlen+0x10>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c4:	75 f7                	jne    8007bd <strlen+0xd>
	return n;
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	eb 03                	jmp    8007db <strnlen+0x13>
		n++;
  8007d8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	39 d0                	cmp    %edx,%eax
  8007dd:	74 06                	je     8007e5 <strnlen+0x1d>
  8007df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e3:	75 f3                	jne    8007d8 <strnlen+0x10>
	return n;
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f1:	89 c2                	mov    %eax,%edx
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	83 c1 01             	add    $0x1,%ecx
  8007f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800800:	84 db                	test   %bl,%bl
  800802:	75 ef                	jne    8007f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800804:	5b                   	pop    %ebx
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800811:	89 1c 24             	mov    %ebx,(%esp)
  800814:	e8 97 ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  800819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800820:	01 d8                	add    %ebx,%eax
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	e8 bd ff ff ff       	call   8007e7 <strcpy>
	return dst;
}
  80082a:	89 d8                	mov    %ebx,%eax
  80082c:	83 c4 08             	add    $0x8,%esp
  80082f:	5b                   	pop    %ebx
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
		*dst++ = *src;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084f:	80 39 01             	cmpb   $0x1,(%ecx)
  800852:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800855:	39 da                	cmp    %ebx,%edx
  800857:	75 ed                	jne    800846 <strncpy+0x14>
	}
	return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800873:	85 c9                	test   %ecx,%ecx
  800875:	75 0b                	jne    800882 <strlcpy+0x23>
  800877:	eb 1d                	jmp    800896 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800882:	39 d8                	cmp    %ebx,%eax
  800884:	74 0b                	je     800891 <strlcpy+0x32>
  800886:	0f b6 0a             	movzbl (%edx),%ecx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 ec                	jne    800879 <strlcpy+0x1a>
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	eb 02                	jmp    800893 <strlcpy+0x34>
  800891:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800893:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 07                	jmp    80092e <strfind+0x13>
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 0a                	je     800935 <strfind+0x1a>
	for (; *s; s++)
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 79 ff ff ff       	call   800984 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a18:	89 d6                	mov    %edx,%esi
  800a1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	eb 1a                	jmp    800a39 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1f:	0f b6 02             	movzbl (%edx),%eax
  800a22:	0f b6 19             	movzbl (%ecx),%ebx
  800a25:	38 d8                	cmp    %bl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 db             	movzbl %bl,%ebx
  800a2f:	29 d8                	sub    %ebx,%eax
  800a31:	eb 0f                	jmp    800a42 <memcmp+0x35>
		s1++, s2++;
  800a33:	83 c2 01             	add    $0x1,%edx
  800a36:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800a39:	39 f2                	cmp    %esi,%edx
  800a3b:	75 e2                	jne    800a1f <memcmp+0x12>
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a54:	eb 07                	jmp    800a5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	38 08                	cmp    %cl,(%eax)
  800a58:	74 07                	je     800a61 <memfind+0x1b>
	for (; s < ends; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	39 d0                	cmp    %edx,%eax
  800a5f:	72 f5                	jb     800a56 <memfind+0x10>
			break;
	return (void *) s;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	eb 03                	jmp    800a74 <strtol+0x11>
		s++;
  800a71:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a74:	0f b6 0a             	movzbl (%edx),%ecx
  800a77:	80 f9 09             	cmp    $0x9,%cl
  800a7a:	74 f5                	je     800a71 <strtol+0xe>
  800a7c:	80 f9 20             	cmp    $0x20,%cl
  800a7f:	74 f0                	je     800a71 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a81:	80 f9 2b             	cmp    $0x2b,%cl
  800a84:	75 0a                	jne    800a90 <strtol+0x2d>
		s++;
  800a86:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	eb 11                	jmp    800aa1 <strtol+0x3e>
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800a95:	80 f9 2d             	cmp    $0x2d,%cl
  800a98:	75 07                	jne    800aa1 <strtol+0x3e>
		s++, neg = 1;
  800a9a:	8d 52 01             	lea    0x1(%edx),%edx
  800a9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800aa6:	75 15                	jne    800abd <strtol+0x5a>
  800aa8:	80 3a 30             	cmpb   $0x30,(%edx)
  800aab:	75 10                	jne    800abd <strtol+0x5a>
  800aad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab1:	75 0a                	jne    800abd <strtol+0x5a>
		s += 2, base = 16;
  800ab3:	83 c2 02             	add    $0x2,%edx
  800ab6:	b8 10 00 00 00       	mov    $0x10,%eax
  800abb:	eb 10                	jmp    800acd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800abd:	85 c0                	test   %eax,%eax
  800abf:	75 0c                	jne    800acd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800ac3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ac6:	75 05                	jne    800acd <strtol+0x6a>
		s++, base = 8;
  800ac8:	83 c2 01             	add    $0x1,%edx
  800acb:	b0 08                	mov    $0x8,%al
		base = 10;
  800acd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ad2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad5:	0f b6 0a             	movzbl (%edx),%ecx
  800ad8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800adb:	89 f0                	mov    %esi,%eax
  800add:	3c 09                	cmp    $0x9,%al
  800adf:	77 08                	ja     800ae9 <strtol+0x86>
			dig = *s - '0';
  800ae1:	0f be c9             	movsbl %cl,%ecx
  800ae4:	83 e9 30             	sub    $0x30,%ecx
  800ae7:	eb 20                	jmp    800b09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800aec:	89 f0                	mov    %esi,%eax
  800aee:	3c 19                	cmp    $0x19,%al
  800af0:	77 08                	ja     800afa <strtol+0x97>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0f                	jmp    800b09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800afd:	89 f0                	mov    %esi,%eax
  800aff:	3c 19                	cmp    $0x19,%al
  800b01:	77 16                	ja     800b19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b03:	0f be c9             	movsbl %cl,%ecx
  800b06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b0c:	7d 0f                	jge    800b1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b17:	eb bc                	jmp    800ad5 <strtol+0x72>
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	eb 02                	jmp    800b1f <strtol+0xbc>
  800b1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b23:	74 05                	je     800b2a <strtol+0xc7>
		*endptr = (char *) s;
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b2a:	f7 d8                	neg    %eax
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	89 c6                	mov    %eax,%esi
  800b4d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	89 d1                	mov    %edx,%ecx
  800b66:	89 d3                	mov    %edx,%ebx
  800b68:	89 d7                	mov    %edx,%edi
  800b6a:	89 d6                	mov    %edx,%esi
  800b6c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800b7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 cb                	mov    %ecx,%ebx
  800b8b:	89 cf                	mov    %ecx,%edi
  800b8d:	89 ce                	mov    %ecx,%esi
  800b8f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 28                	jle    800bbd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800bb8:	e8 49 13 00 00       	call   801f06 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbd:	83 c4 2c             	add    $0x2c,%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd5:	89 d1                	mov    %edx,%ecx
  800bd7:	89 d3                	mov    %edx,%ebx
  800bd9:	89 d7                	mov    %edx,%edi
  800bdb:	89 d6                	mov    %edx,%esi
  800bdd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_yield>:

void
sys_yield(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c0c:	be 00 00 00 00       	mov    $0x0,%esi
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	89 f7                	mov    %esi,%edi
  800c21:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800c4a:	e8 b7 12 00 00       	call   801f06 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800c9d:	e8 64 12 00 00       	call   801f06 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800cf0:	e8 11 12 00 00       	call   801f06 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800d43:	e8 be 11 00 00       	call   801f06 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 28                	jle    800d9b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800d96:	e8 6b 11 00 00       	call   801f06 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d9b:	83 c4 2c             	add    $0x2c,%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 df                	mov    %ebx,%edi
  800dbe:	89 de                	mov    %ebx,%esi
  800dc0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 28                	jle    800dee <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800de9:	e8 18 11 00 00       	call   801f06 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dee:	83 c4 2c             	add    $0x2c,%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfc:	be 00 00 00 00       	mov    $0x0,%esi
  800e01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e12:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e27:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 cb                	mov    %ecx,%ebx
  800e31:	89 cf                	mov    %ecx,%edi
  800e33:	89 ce                	mov    %ecx,%esi
  800e35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7e 28                	jle    800e63 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e46:	00 
  800e47:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e56:	00 
  800e57:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800e5e:	e8 a3 10 00 00       	call   801f06 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e63:	83 c4 2c             	add    $0x2c,%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    
  800e6b:	66 90                	xchg   %ax,%ax
  800e6d:	66 90                	xchg   %ax,%ax
  800e6f:	90                   	nop

00800e70 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	53                   	push   %ebx
  800e74:	83 ec 24             	sub    $0x24,%esp
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  800e7a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  800e7c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e80:	74 18                	je     800e9a <pgfault+0x2a>
  800e82:	89 d8                	mov    %ebx,%eax
  800e84:	c1 e8 0c             	shr    $0xc,%eax
  800e87:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e8e:	25 05 08 00 00       	and    $0x805,%eax
  800e93:	3d 05 08 00 00       	cmp    $0x805,%eax
  800e98:	74 1c                	je     800eb6 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  800e9a:	c7 44 24 08 cc 27 80 	movl   $0x8027cc,0x8(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800ea9:	00 
  800eaa:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  800eb1:	e8 50 10 00 00       	call   801f06 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  800eb6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ebd:	00 
  800ebe:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ec5:	00 
  800ec6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ecd:	e8 31 fd ff ff       	call   800c03 <sys_page_alloc>
	if(r < 0){
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	79 1c                	jns    800ef2 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  800ed6:	c7 44 24 08 fc 27 80 	movl   $0x8027fc,0x8(%esp)
  800edd:	00 
  800ede:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800ee5:	00 
  800ee6:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  800eed:	e8 14 10 00 00       	call   801f06 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ef2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ef8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800eff:	00 
  800f00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f04:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f0b:	e8 dc fa ff ff       	call   8009ec <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  800f10:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f17:	00 
  800f18:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f1c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f33:	e8 1f fd ff ff       	call   800c57 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	79 1c                	jns    800f58 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  800f3c:	c7 44 24 08 c8 28 80 	movl   $0x8028c8,0x8(%esp)
  800f43:	00 
  800f44:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800f4b:	00 
  800f4c:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  800f53:	e8 ae 0f 00 00       	call   801f06 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  800f58:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f5f:	00 
  800f60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f67:	e8 3e fd ff ff       	call   800caa <sys_page_unmap>
    if(r < 0){
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	79 1c                	jns    800f8c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  800f70:	c7 44 24 08 df 28 80 	movl   $0x8028df,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  800f87:	e8 7a 0f 00 00       	call   801f06 <_panic>
    }
    // LAB 4
}
  800f8c:	83 c4 24             	add    $0x24,%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  800f9b:	c7 04 24 70 0e 80 00 	movl   $0x800e70,(%esp)
  800fa2:	e8 b5 0f 00 00       	call   801f5c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fac:	cd 30                	int    $0x30
  800fae:	89 c7                	mov    %eax,%edi
  800fb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 1c                	jns    800fd3 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  800fb7:	c7 44 24 08 f8 28 80 	movl   $0x8028f8,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  800fce:	e8 33 0f 00 00       	call   801f06 <_panic>
    }
    if(child == 0){
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	75 21                	jne    800ffd <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  800fdc:	e8 e4 fb ff ff       	call   800bc5 <sys_getenvid>
  800fe1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fee:	a3 08 40 80 00       	mov    %eax,0x804008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	e9 67 01 00 00       	jmp    801164 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  800ffd:	89 d8                	mov    %ebx,%eax
  800fff:	c1 e8 16             	shr    $0x16,%eax
  801002:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801009:	a8 01                	test   $0x1,%al
  80100b:	74 4b                	je     801058 <fork+0xc6>
  80100d:	89 de                	mov    %ebx,%esi
  80100f:	c1 ee 0c             	shr    $0xc,%esi
  801012:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801019:	a8 01                	test   $0x1,%al
  80101b:	74 3b                	je     801058 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  80101d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801024:	a9 02 08 00 00       	test   $0x802,%eax
  801029:	0f 85 02 01 00 00    	jne    801131 <fork+0x19f>
  80102f:	e9 d2 00 00 00       	jmp    801106 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  801034:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80103b:	00 
  80103c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801047:	00 
  801048:	89 74 24 04          	mov    %esi,0x4(%esp)
  80104c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801053:	e8 ff fb ff ff       	call   800c57 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801058:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80105e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801064:	75 97                	jne    800ffd <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801066:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80106d:	00 
  80106e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801075:	ee 
  801076:	89 3c 24             	mov    %edi,(%esp)
  801079:	e8 85 fb ff ff       	call   800c03 <sys_page_alloc>

    if(r < 0){
  80107e:	85 c0                	test   %eax,%eax
  801080:	79 1c                	jns    80109e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801082:	c7 44 24 08 30 28 80 	movl   $0x802830,0x8(%esp)
  801089:	00 
  80108a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801091:	00 
  801092:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  801099:	e8 68 0e 00 00       	call   801f06 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80109e:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a3:	8b 40 64             	mov    0x64(%eax),%eax
  8010a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010aa:	89 3c 24             	mov    %edi,(%esp)
  8010ad:	e8 f1 fc ff ff       	call   800da3 <sys_env_set_pgfault_upcall>
    if(r < 0){
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	79 1c                	jns    8010d2 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  8010b6:	c7 44 24 08 50 28 80 	movl   $0x802850,0x8(%esp)
  8010bd:	00 
  8010be:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  8010c5:	00 
  8010c6:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  8010cd:	e8 34 0e 00 00       	call   801f06 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  8010d2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8010d9:	00 
  8010da:	89 3c 24             	mov    %edi,(%esp)
  8010dd:	e8 1b fc ff ff       	call   800cfd <sys_env_set_status>
    if(r < 0){
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	79 1c                	jns    801102 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  8010e6:	c7 44 24 08 78 28 80 	movl   $0x802878,0x8(%esp)
  8010ed:	00 
  8010ee:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  8010f5:	00 
  8010f6:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  8010fd:	e8 04 0e 00 00       	call   801f06 <_panic>
    }
    return child;
  801102:	89 f8                	mov    %edi,%eax
  801104:	eb 5e                	jmp    801164 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  801106:	c1 e6 0c             	shl    $0xc,%esi
  801109:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801110:	00 
  801111:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801118:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801120:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801127:	e8 2b fb ff ff       	call   800c57 <sys_page_map>
  80112c:	e9 27 ff ff ff       	jmp    801058 <fork+0xc6>
  801131:	c1 e6 0c             	shl    $0xc,%esi
  801134:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80113b:	00 
  80113c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801143:	89 44 24 08          	mov    %eax,0x8(%esp)
  801147:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801152:	e8 00 fb ff ff       	call   800c57 <sys_page_map>
    if( r < 0 ){
  801157:	85 c0                	test   %eax,%eax
  801159:	0f 89 d5 fe ff ff    	jns    801034 <fork+0xa2>
  80115f:	e9 f4 fe ff ff       	jmp    801058 <fork+0xc6>
//	panic("fork not implemented");
}
  801164:	83 c4 2c             	add    $0x2c,%esp
  801167:	5b                   	pop    %ebx
  801168:	5e                   	pop    %esi
  801169:	5f                   	pop    %edi
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <sfork>:

// Challenge!
int
sfork(void)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801172:	c7 44 24 08 15 29 80 	movl   $0x802915,0x8(%esp)
  801179:	00 
  80117a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801181:	00 
  801182:	c7 04 24 bd 28 80 00 	movl   $0x8028bd,(%esp)
  801189:	e8 78 0d 00 00       	call   801f06 <_panic>
  80118e:	66 90                	xchg   %ax,%ax

00801190 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	05 00 00 00 30       	add    $0x30000000,%eax
  80119b:	c1 e8 0c             	shr    $0xc,%eax
}
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	c1 ea 16             	shr    $0x16,%edx
  8011c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ce:	f6 c2 01             	test   $0x1,%dl
  8011d1:	74 11                	je     8011e4 <fd_alloc+0x2d>
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	c1 ea 0c             	shr    $0xc,%edx
  8011d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	75 09                	jne    8011ed <fd_alloc+0x36>
			*fd_store = fd;
  8011e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	eb 17                	jmp    801204 <fd_alloc+0x4d>
  8011ed:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f7:	75 c9                	jne    8011c2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8011f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120c:	83 f8 1f             	cmp    $0x1f,%eax
  80120f:	77 36                	ja     801247 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801211:	c1 e0 0c             	shl    $0xc,%eax
  801214:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801219:	89 c2                	mov    %eax,%edx
  80121b:	c1 ea 16             	shr    $0x16,%edx
  80121e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801225:	f6 c2 01             	test   $0x1,%dl
  801228:	74 24                	je     80124e <fd_lookup+0x48>
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	c1 ea 0c             	shr    $0xc,%edx
  80122f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801236:	f6 c2 01             	test   $0x1,%dl
  801239:	74 1a                	je     801255 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123e:	89 02                	mov    %eax,(%edx)
	return 0;
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
  801245:	eb 13                	jmp    80125a <fd_lookup+0x54>
		return -E_INVAL;
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124c:	eb 0c                	jmp    80125a <fd_lookup+0x54>
		return -E_INVAL;
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801253:	eb 05                	jmp    80125a <fd_lookup+0x54>
  801255:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	83 ec 18             	sub    $0x18,%esp
  801262:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801265:	ba a8 29 80 00       	mov    $0x8029a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80126a:	eb 13                	jmp    80127f <dev_lookup+0x23>
  80126c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80126f:	39 08                	cmp    %ecx,(%eax)
  801271:	75 0c                	jne    80127f <dev_lookup+0x23>
			*dev = devtab[i];
  801273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801276:	89 01                	mov    %eax,(%ecx)
			return 0;
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
  80127d:	eb 30                	jmp    8012af <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80127f:	8b 02                	mov    (%edx),%eax
  801281:	85 c0                	test   %eax,%eax
  801283:	75 e7                	jne    80126c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801285:	a1 08 40 80 00       	mov    0x804008,%eax
  80128a:	8b 40 48             	mov    0x48(%eax),%eax
  80128d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801291:	89 44 24 04          	mov    %eax,0x4(%esp)
  801295:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
  80129c:	e8 22 ef ff ff       	call   8001c3 <cprintf>
	*dev = 0;
  8012a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012af:	c9                   	leave  
  8012b0:	c3                   	ret    

008012b1 <fd_close>:
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
  8012b6:	83 ec 20             	sub    $0x20,%esp
  8012b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012cc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012cf:	89 04 24             	mov    %eax,(%esp)
  8012d2:	e8 2f ff ff ff       	call   801206 <fd_lookup>
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 05                	js     8012e0 <fd_close+0x2f>
	    || fd != fd2)
  8012db:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012de:	74 0c                	je     8012ec <fd_close+0x3b>
		return (must_exist ? r : 0);
  8012e0:	84 db                	test   %bl,%bl
  8012e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e7:	0f 44 c2             	cmove  %edx,%eax
  8012ea:	eb 3f                	jmp    80132b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f3:	8b 06                	mov    (%esi),%eax
  8012f5:	89 04 24             	mov    %eax,(%esp)
  8012f8:	e8 5f ff ff ff       	call   80125c <dev_lookup>
  8012fd:	89 c3                	mov    %eax,%ebx
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 16                	js     801319 <fd_close+0x68>
		if (dev->dev_close)
  801303:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801306:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80130e:	85 c0                	test   %eax,%eax
  801310:	74 07                	je     801319 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801312:	89 34 24             	mov    %esi,(%esp)
  801315:	ff d0                	call   *%eax
  801317:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801319:	89 74 24 04          	mov    %esi,0x4(%esp)
  80131d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801324:	e8 81 f9 ff ff       	call   800caa <sys_page_unmap>
	return r;
  801329:	89 d8                	mov    %ebx,%eax
}
  80132b:	83 c4 20             	add    $0x20,%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <close>:

int
close(int fdnum)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133f:	8b 45 08             	mov    0x8(%ebp),%eax
  801342:	89 04 24             	mov    %eax,(%esp)
  801345:	e8 bc fe ff ff       	call   801206 <fd_lookup>
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	85 d2                	test   %edx,%edx
  80134e:	78 13                	js     801363 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801350:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801357:	00 
  801358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	e8 4e ff ff ff       	call   8012b1 <fd_close>
}
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <close_all>:

void
close_all(void)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	53                   	push   %ebx
  801369:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801371:	89 1c 24             	mov    %ebx,(%esp)
  801374:	e8 b9 ff ff ff       	call   801332 <close>
	for (i = 0; i < MAXFD; i++)
  801379:	83 c3 01             	add    $0x1,%ebx
  80137c:	83 fb 20             	cmp    $0x20,%ebx
  80137f:	75 f0                	jne    801371 <close_all+0xc>
}
  801381:	83 c4 14             	add    $0x14,%esp
  801384:	5b                   	pop    %ebx
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	57                   	push   %edi
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801390:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801393:	89 44 24 04          	mov    %eax,0x4(%esp)
  801397:	8b 45 08             	mov    0x8(%ebp),%eax
  80139a:	89 04 24             	mov    %eax,(%esp)
  80139d:	e8 64 fe ff ff       	call   801206 <fd_lookup>
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	85 d2                	test   %edx,%edx
  8013a6:	0f 88 e1 00 00 00    	js     80148d <dup+0x106>
		return r;
	close(newfdnum);
  8013ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013af:	89 04 24             	mov    %eax,(%esp)
  8013b2:	e8 7b ff ff ff       	call   801332 <close>

	newfd = INDEX2FD(newfdnum);
  8013b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ba:	c1 e3 0c             	shl    $0xc,%ebx
  8013bd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c6:	89 04 24             	mov    %eax,(%esp)
  8013c9:	e8 d2 fd ff ff       	call   8011a0 <fd2data>
  8013ce:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8013d0:	89 1c 24             	mov    %ebx,(%esp)
  8013d3:	e8 c8 fd ff ff       	call   8011a0 <fd2data>
  8013d8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013da:	89 f0                	mov    %esi,%eax
  8013dc:	c1 e8 16             	shr    $0x16,%eax
  8013df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e6:	a8 01                	test   $0x1,%al
  8013e8:	74 43                	je     80142d <dup+0xa6>
  8013ea:	89 f0                	mov    %esi,%eax
  8013ec:	c1 e8 0c             	shr    $0xc,%eax
  8013ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	74 32                	je     80142d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801402:	25 07 0e 00 00       	and    $0xe07,%eax
  801407:	89 44 24 10          	mov    %eax,0x10(%esp)
  80140b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80140f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801416:	00 
  801417:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801422:	e8 30 f8 ff ff       	call   800c57 <sys_page_map>
  801427:	89 c6                	mov    %eax,%esi
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 3e                	js     80146b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801430:	89 c2                	mov    %eax,%edx
  801432:	c1 ea 0c             	shr    $0xc,%edx
  801435:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801442:	89 54 24 10          	mov    %edx,0x10(%esp)
  801446:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80144a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801451:	00 
  801452:	89 44 24 04          	mov    %eax,0x4(%esp)
  801456:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145d:	e8 f5 f7 ff ff       	call   800c57 <sys_page_map>
  801462:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801464:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801467:	85 f6                	test   %esi,%esi
  801469:	79 22                	jns    80148d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80146b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80146f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801476:	e8 2f f8 ff ff       	call   800caa <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80147f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801486:	e8 1f f8 ff ff       	call   800caa <sys_page_unmap>
	return r;
  80148b:	89 f0                	mov    %esi,%eax
}
  80148d:	83 c4 3c             	add    $0x3c,%esp
  801490:	5b                   	pop    %ebx
  801491:	5e                   	pop    %esi
  801492:	5f                   	pop    %edi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	53                   	push   %ebx
  801499:	83 ec 24             	sub    $0x24,%esp
  80149c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a6:	89 1c 24             	mov    %ebx,(%esp)
  8014a9:	e8 58 fd ff ff       	call   801206 <fd_lookup>
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	85 d2                	test   %edx,%edx
  8014b2:	78 6d                	js     801521 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014be:	8b 00                	mov    (%eax),%eax
  8014c0:	89 04 24             	mov    %eax,(%esp)
  8014c3:	e8 94 fd ff ff       	call   80125c <dev_lookup>
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 55                	js     801521 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cf:	8b 50 08             	mov    0x8(%eax),%edx
  8014d2:	83 e2 03             	and    $0x3,%edx
  8014d5:	83 fa 01             	cmp    $0x1,%edx
  8014d8:	75 23                	jne    8014fd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014da:	a1 08 40 80 00       	mov    0x804008,%eax
  8014df:	8b 40 48             	mov    0x48(%eax),%eax
  8014e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ea:	c7 04 24 6d 29 80 00 	movl   $0x80296d,(%esp)
  8014f1:	e8 cd ec ff ff       	call   8001c3 <cprintf>
		return -E_INVAL;
  8014f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fb:	eb 24                	jmp    801521 <read+0x8c>
	}
	if (!dev->dev_read)
  8014fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801500:	8b 52 08             	mov    0x8(%edx),%edx
  801503:	85 d2                	test   %edx,%edx
  801505:	74 15                	je     80151c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801507:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80150a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80150e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801511:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801515:	89 04 24             	mov    %eax,(%esp)
  801518:	ff d2                	call   *%edx
  80151a:	eb 05                	jmp    801521 <read+0x8c>
		return -E_NOT_SUPP;
  80151c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801521:	83 c4 24             	add    $0x24,%esp
  801524:	5b                   	pop    %ebx
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	57                   	push   %edi
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 1c             	sub    $0x1c,%esp
  801530:	8b 7d 08             	mov    0x8(%ebp),%edi
  801533:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801536:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153b:	eb 23                	jmp    801560 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80153d:	89 f0                	mov    %esi,%eax
  80153f:	29 d8                	sub    %ebx,%eax
  801541:	89 44 24 08          	mov    %eax,0x8(%esp)
  801545:	89 d8                	mov    %ebx,%eax
  801547:	03 45 0c             	add    0xc(%ebp),%eax
  80154a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154e:	89 3c 24             	mov    %edi,(%esp)
  801551:	e8 3f ff ff ff       	call   801495 <read>
		if (m < 0)
  801556:	85 c0                	test   %eax,%eax
  801558:	78 10                	js     80156a <readn+0x43>
			return m;
		if (m == 0)
  80155a:	85 c0                	test   %eax,%eax
  80155c:	74 0a                	je     801568 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80155e:	01 c3                	add    %eax,%ebx
  801560:	39 f3                	cmp    %esi,%ebx
  801562:	72 d9                	jb     80153d <readn+0x16>
  801564:	89 d8                	mov    %ebx,%eax
  801566:	eb 02                	jmp    80156a <readn+0x43>
  801568:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80156a:	83 c4 1c             	add    $0x1c,%esp
  80156d:	5b                   	pop    %ebx
  80156e:	5e                   	pop    %esi
  80156f:	5f                   	pop    %edi
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    

00801572 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	53                   	push   %ebx
  801576:	83 ec 24             	sub    $0x24,%esp
  801579:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801583:	89 1c 24             	mov    %ebx,(%esp)
  801586:	e8 7b fc ff ff       	call   801206 <fd_lookup>
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	85 d2                	test   %edx,%edx
  80158f:	78 68                	js     8015f9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801594:	89 44 24 04          	mov    %eax,0x4(%esp)
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	8b 00                	mov    (%eax),%eax
  80159d:	89 04 24             	mov    %eax,(%esp)
  8015a0:	e8 b7 fc ff ff       	call   80125c <dev_lookup>
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 50                	js     8015f9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b0:	75 23                	jne    8015d5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8015b7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c2:	c7 04 24 89 29 80 00 	movl   $0x802989,(%esp)
  8015c9:	e8 f5 eb ff ff       	call   8001c3 <cprintf>
		return -E_INVAL;
  8015ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d3:	eb 24                	jmp    8015f9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015db:	85 d2                	test   %edx,%edx
  8015dd:	74 15                	je     8015f4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ed:	89 04 24             	mov    %eax,(%esp)
  8015f0:	ff d2                	call   *%edx
  8015f2:	eb 05                	jmp    8015f9 <write+0x87>
		return -E_NOT_SUPP;
  8015f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015f9:	83 c4 24             	add    $0x24,%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801605:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160c:	8b 45 08             	mov    0x8(%ebp),%eax
  80160f:	89 04 24             	mov    %eax,(%esp)
  801612:	e8 ef fb ff ff       	call   801206 <fd_lookup>
  801617:	85 c0                	test   %eax,%eax
  801619:	78 0e                	js     801629 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80161b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801621:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801624:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	53                   	push   %ebx
  80162f:	83 ec 24             	sub    $0x24,%esp
  801632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163c:	89 1c 24             	mov    %ebx,(%esp)
  80163f:	e8 c2 fb ff ff       	call   801206 <fd_lookup>
  801644:	89 c2                	mov    %eax,%edx
  801646:	85 d2                	test   %edx,%edx
  801648:	78 61                	js     8016ab <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801651:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801654:	8b 00                	mov    (%eax),%eax
  801656:	89 04 24             	mov    %eax,(%esp)
  801659:	e8 fe fb ff ff       	call   80125c <dev_lookup>
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 49                	js     8016ab <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801669:	75 23                	jne    80168e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80166b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801670:	8b 40 48             	mov    0x48(%eax),%eax
  801673:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801677:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167b:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  801682:	e8 3c eb ff ff       	call   8001c3 <cprintf>
		return -E_INVAL;
  801687:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80168c:	eb 1d                	jmp    8016ab <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80168e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801691:	8b 52 18             	mov    0x18(%edx),%edx
  801694:	85 d2                	test   %edx,%edx
  801696:	74 0e                	je     8016a6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801698:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80169b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80169f:	89 04 24             	mov    %eax,(%esp)
  8016a2:	ff d2                	call   *%edx
  8016a4:	eb 05                	jmp    8016ab <ftruncate+0x80>
		return -E_NOT_SUPP;
  8016a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016ab:	83 c4 24             	add    $0x24,%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5d                   	pop    %ebp
  8016b0:	c3                   	ret    

008016b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 24             	sub    $0x24,%esp
  8016b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	e8 39 fb ff ff       	call   801206 <fd_lookup>
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	85 d2                	test   %edx,%edx
  8016d1:	78 52                	js     801725 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	8b 00                	mov    (%eax),%eax
  8016df:	89 04 24             	mov    %eax,(%esp)
  8016e2:	e8 75 fb ff ff       	call   80125c <dev_lookup>
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 3a                	js     801725 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8016eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ee:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f2:	74 2c                	je     801720 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fe:	00 00 00 
	stat->st_isdir = 0;
  801701:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801708:	00 00 00 
	stat->st_dev = dev;
  80170b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801715:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801718:	89 14 24             	mov    %edx,(%esp)
  80171b:	ff 50 14             	call   *0x14(%eax)
  80171e:	eb 05                	jmp    801725 <fstat+0x74>
		return -E_NOT_SUPP;
  801720:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801725:	83 c4 24             	add    $0x24,%esp
  801728:	5b                   	pop    %ebx
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801733:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80173a:	00 
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	e8 fb 01 00 00       	call   801941 <open>
  801746:	89 c3                	mov    %eax,%ebx
  801748:	85 db                	test   %ebx,%ebx
  80174a:	78 1b                	js     801767 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80174c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	89 1c 24             	mov    %ebx,(%esp)
  801756:	e8 56 ff ff ff       	call   8016b1 <fstat>
  80175b:	89 c6                	mov    %eax,%esi
	close(fd);
  80175d:	89 1c 24             	mov    %ebx,(%esp)
  801760:	e8 cd fb ff ff       	call   801332 <close>
	return r;
  801765:	89 f0                	mov    %esi,%eax
}
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	5b                   	pop    %ebx
  80176b:	5e                   	pop    %esi
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    

0080176e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	56                   	push   %esi
  801772:	53                   	push   %ebx
  801773:	83 ec 10             	sub    $0x10,%esp
  801776:	89 c6                	mov    %eax,%esi
  801778:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80177a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801781:	75 11                	jne    801794 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801783:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80178a:	e8 50 09 00 00       	call   8020df <ipc_find_env>
  80178f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801794:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80179b:	00 
  80179c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017a3:	00 
  8017a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ad:	89 04 24             	mov    %eax,(%esp)
  8017b0:	e8 c3 08 00 00       	call   802078 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017bc:	00 
  8017bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c8:	e8 43 08 00 00       	call   802010 <ipc_recv>
}
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f7:	e8 72 ff ff ff       	call   80176e <fsipc>
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <devfile_flush>:
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	8b 40 0c             	mov    0xc(%eax),%eax
  80180a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 06 00 00 00       	mov    $0x6,%eax
  801819:	e8 50 ff ff ff       	call   80176e <fsipc>
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <devfile_stat>:
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 14             	sub    $0x14,%esp
  801827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 05 00 00 00       	mov    $0x5,%eax
  80183f:	e8 2a ff ff ff       	call   80176e <fsipc>
  801844:	89 c2                	mov    %eax,%edx
  801846:	85 d2                	test   %edx,%edx
  801848:	78 2b                	js     801875 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801851:	00 
  801852:	89 1c 24             	mov    %ebx,(%esp)
  801855:	e8 8d ef ff ff       	call   8007e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185a:	a1 80 50 80 00       	mov    0x805080,%eax
  80185f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801865:	a1 84 50 80 00       	mov    0x805084,%eax
  80186a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801875:	83 c4 14             	add    $0x14,%esp
  801878:	5b                   	pop    %ebx
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <devfile_write>:
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801881:	c7 44 24 08 b8 29 80 	movl   $0x8029b8,0x8(%esp)
  801888:	00 
  801889:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801890:	00 
  801891:	c7 04 24 d6 29 80 00 	movl   $0x8029d6,(%esp)
  801898:	e8 69 06 00 00       	call   801f06 <_panic>

0080189d <devfile_read>:
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	56                   	push   %esi
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 10             	sub    $0x10,%esp
  8018a5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018be:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c3:	e8 a6 fe ff ff       	call   80176e <fsipc>
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 6a                	js     801938 <devfile_read+0x9b>
	assert(r <= n);
  8018ce:	39 c6                	cmp    %eax,%esi
  8018d0:	73 24                	jae    8018f6 <devfile_read+0x59>
  8018d2:	c7 44 24 0c e1 29 80 	movl   $0x8029e1,0xc(%esp)
  8018d9:	00 
  8018da:	c7 44 24 08 e8 29 80 	movl   $0x8029e8,0x8(%esp)
  8018e1:	00 
  8018e2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8018e9:	00 
  8018ea:	c7 04 24 d6 29 80 00 	movl   $0x8029d6,(%esp)
  8018f1:	e8 10 06 00 00       	call   801f06 <_panic>
	assert(r <= PGSIZE);
  8018f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018fb:	7e 24                	jle    801921 <devfile_read+0x84>
  8018fd:	c7 44 24 0c fd 29 80 	movl   $0x8029fd,0xc(%esp)
  801904:	00 
  801905:	c7 44 24 08 e8 29 80 	movl   $0x8029e8,0x8(%esp)
  80190c:	00 
  80190d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801914:	00 
  801915:	c7 04 24 d6 29 80 00 	movl   $0x8029d6,(%esp)
  80191c:	e8 e5 05 00 00       	call   801f06 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801921:	89 44 24 08          	mov    %eax,0x8(%esp)
  801925:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80192c:	00 
  80192d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801930:	89 04 24             	mov    %eax,(%esp)
  801933:	e8 4c f0 ff ff       	call   800984 <memmove>
}
  801938:	89 d8                	mov    %ebx,%eax
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <open>:
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	53                   	push   %ebx
  801945:	83 ec 24             	sub    $0x24,%esp
  801948:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80194b:	89 1c 24             	mov    %ebx,(%esp)
  80194e:	e8 5d ee ff ff       	call   8007b0 <strlen>
  801953:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801958:	7f 60                	jg     8019ba <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80195a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195d:	89 04 24             	mov    %eax,(%esp)
  801960:	e8 52 f8 ff ff       	call   8011b7 <fd_alloc>
  801965:	89 c2                	mov    %eax,%edx
  801967:	85 d2                	test   %edx,%edx
  801969:	78 54                	js     8019bf <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80196b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80196f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801976:	e8 6c ee ff ff       	call   8007e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80197b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801983:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801986:	b8 01 00 00 00       	mov    $0x1,%eax
  80198b:	e8 de fd ff ff       	call   80176e <fsipc>
  801990:	89 c3                	mov    %eax,%ebx
  801992:	85 c0                	test   %eax,%eax
  801994:	79 17                	jns    8019ad <open+0x6c>
		fd_close(fd, 0);
  801996:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80199d:	00 
  80199e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a1:	89 04 24             	mov    %eax,(%esp)
  8019a4:	e8 08 f9 ff ff       	call   8012b1 <fd_close>
		return r;
  8019a9:	89 d8                	mov    %ebx,%eax
  8019ab:	eb 12                	jmp    8019bf <open+0x7e>
	return fd2num(fd);
  8019ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b0:	89 04 24             	mov    %eax,(%esp)
  8019b3:	e8 d8 f7 ff ff       	call   801190 <fd2num>
  8019b8:	eb 05                	jmp    8019bf <open+0x7e>
		return -E_BAD_PATH;
  8019ba:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8019bf:	83 c4 24             	add    $0x24,%esp
  8019c2:	5b                   	pop    %ebx
  8019c3:	5d                   	pop    %ebp
  8019c4:	c3                   	ret    

008019c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d5:	e8 94 fd ff ff       	call   80176e <fsipc>
}
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	83 ec 10             	sub    $0x10,%esp
  8019e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ea:	89 04 24             	mov    %eax,(%esp)
  8019ed:	e8 ae f7 ff ff       	call   8011a0 <fd2data>
  8019f2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019f4:	c7 44 24 04 09 2a 80 	movl   $0x802a09,0x4(%esp)
  8019fb:	00 
  8019fc:	89 1c 24             	mov    %ebx,(%esp)
  8019ff:	e8 e3 ed ff ff       	call   8007e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a04:	8b 46 04             	mov    0x4(%esi),%eax
  801a07:	2b 06                	sub    (%esi),%eax
  801a09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a0f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a16:	00 00 00 
	stat->st_dev = &devpipe;
  801a19:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a20:	30 80 00 
	return 0;
}
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
  801a28:	83 c4 10             	add    $0x10,%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	53                   	push   %ebx
  801a33:	83 ec 14             	sub    $0x14,%esp
  801a36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a44:	e8 61 f2 ff ff       	call   800caa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a49:	89 1c 24             	mov    %ebx,(%esp)
  801a4c:	e8 4f f7 ff ff       	call   8011a0 <fd2data>
  801a51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a5c:	e8 49 f2 ff ff       	call   800caa <sys_page_unmap>
}
  801a61:	83 c4 14             	add    $0x14,%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <_pipeisclosed>:
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	57                   	push   %edi
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	83 ec 2c             	sub    $0x2c,%esp
  801a70:	89 c6                	mov    %eax,%esi
  801a72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801a75:	a1 08 40 80 00       	mov    0x804008,%eax
  801a7a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a7d:	89 34 24             	mov    %esi,(%esp)
  801a80:	e8 92 06 00 00       	call   802117 <pageref>
  801a85:	89 c7                	mov    %eax,%edi
  801a87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a8a:	89 04 24             	mov    %eax,(%esp)
  801a8d:	e8 85 06 00 00       	call   802117 <pageref>
  801a92:	39 c7                	cmp    %eax,%edi
  801a94:	0f 94 c2             	sete   %dl
  801a97:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a9a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801aa0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801aa3:	39 fb                	cmp    %edi,%ebx
  801aa5:	74 21                	je     801ac8 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801aa7:	84 d2                	test   %dl,%dl
  801aa9:	74 ca                	je     801a75 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aab:	8b 51 58             	mov    0x58(%ecx),%edx
  801aae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ab6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aba:	c7 04 24 10 2a 80 00 	movl   $0x802a10,(%esp)
  801ac1:	e8 fd e6 ff ff       	call   8001c3 <cprintf>
  801ac6:	eb ad                	jmp    801a75 <_pipeisclosed+0xe>
}
  801ac8:	83 c4 2c             	add    $0x2c,%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5f                   	pop    %edi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <devpipe_write>:
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 1c             	sub    $0x1c,%esp
  801ad9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801adc:	89 34 24             	mov    %esi,(%esp)
  801adf:	e8 bc f6 ff ff       	call   8011a0 <fd2data>
  801ae4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ae6:	bf 00 00 00 00       	mov    $0x0,%edi
  801aeb:	eb 45                	jmp    801b32 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801aed:	89 da                	mov    %ebx,%edx
  801aef:	89 f0                	mov    %esi,%eax
  801af1:	e8 71 ff ff ff       	call   801a67 <_pipeisclosed>
  801af6:	85 c0                	test   %eax,%eax
  801af8:	75 41                	jne    801b3b <devpipe_write+0x6b>
			sys_yield();
  801afa:	e8 e5 f0 ff ff       	call   800be4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aff:	8b 43 04             	mov    0x4(%ebx),%eax
  801b02:	8b 0b                	mov    (%ebx),%ecx
  801b04:	8d 51 20             	lea    0x20(%ecx),%edx
  801b07:	39 d0                	cmp    %edx,%eax
  801b09:	73 e2                	jae    801aed <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b12:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b15:	99                   	cltd   
  801b16:	c1 ea 1b             	shr    $0x1b,%edx
  801b19:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801b1c:	83 e1 1f             	and    $0x1f,%ecx
  801b1f:	29 d1                	sub    %edx,%ecx
  801b21:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801b25:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801b29:	83 c0 01             	add    $0x1,%eax
  801b2c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b2f:	83 c7 01             	add    $0x1,%edi
  801b32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b35:	75 c8                	jne    801aff <devpipe_write+0x2f>
	return i;
  801b37:	89 f8                	mov    %edi,%eax
  801b39:	eb 05                	jmp    801b40 <devpipe_write+0x70>
				return 0;
  801b3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b40:	83 c4 1c             	add    $0x1c,%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5f                   	pop    %edi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <devpipe_read>:
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	57                   	push   %edi
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	83 ec 1c             	sub    $0x1c,%esp
  801b51:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b54:	89 3c 24             	mov    %edi,(%esp)
  801b57:	e8 44 f6 ff ff       	call   8011a0 <fd2data>
  801b5c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b5e:	be 00 00 00 00       	mov    $0x0,%esi
  801b63:	eb 3d                	jmp    801ba2 <devpipe_read+0x5a>
			if (i > 0)
  801b65:	85 f6                	test   %esi,%esi
  801b67:	74 04                	je     801b6d <devpipe_read+0x25>
				return i;
  801b69:	89 f0                	mov    %esi,%eax
  801b6b:	eb 43                	jmp    801bb0 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801b6d:	89 da                	mov    %ebx,%edx
  801b6f:	89 f8                	mov    %edi,%eax
  801b71:	e8 f1 fe ff ff       	call   801a67 <_pipeisclosed>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	75 31                	jne    801bab <devpipe_read+0x63>
			sys_yield();
  801b7a:	e8 65 f0 ff ff       	call   800be4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b7f:	8b 03                	mov    (%ebx),%eax
  801b81:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b84:	74 df                	je     801b65 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b86:	99                   	cltd   
  801b87:	c1 ea 1b             	shr    $0x1b,%edx
  801b8a:	01 d0                	add    %edx,%eax
  801b8c:	83 e0 1f             	and    $0x1f,%eax
  801b8f:	29 d0                	sub    %edx,%eax
  801b91:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b99:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b9c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b9f:	83 c6 01             	add    $0x1,%esi
  801ba2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ba5:	75 d8                	jne    801b7f <devpipe_read+0x37>
	return i;
  801ba7:	89 f0                	mov    %esi,%eax
  801ba9:	eb 05                	jmp    801bb0 <devpipe_read+0x68>
				return 0;
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <pipe>:
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc3:	89 04 24             	mov    %eax,(%esp)
  801bc6:	e8 ec f5 ff ff       	call   8011b7 <fd_alloc>
  801bcb:	89 c2                	mov    %eax,%edx
  801bcd:	85 d2                	test   %edx,%edx
  801bcf:	0f 88 4d 01 00 00    	js     801d22 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bdc:	00 
  801bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801beb:	e8 13 f0 ff ff       	call   800c03 <sys_page_alloc>
  801bf0:	89 c2                	mov    %eax,%edx
  801bf2:	85 d2                	test   %edx,%edx
  801bf4:	0f 88 28 01 00 00    	js     801d22 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801bfa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bfd:	89 04 24             	mov    %eax,(%esp)
  801c00:	e8 b2 f5 ff ff       	call   8011b7 <fd_alloc>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 fe 00 00 00    	js     801d0d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c16:	00 
  801c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c25:	e8 d9 ef ff ff       	call   800c03 <sys_page_alloc>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	0f 88 d9 00 00 00    	js     801d0d <pipe+0x155>
	va = fd2data(fd0);
  801c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c37:	89 04 24             	mov    %eax,(%esp)
  801c3a:	e8 61 f5 ff ff       	call   8011a0 <fd2data>
  801c3f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c41:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c48:	00 
  801c49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c54:	e8 aa ef ff ff       	call   800c03 <sys_page_alloc>
  801c59:	89 c3                	mov    %eax,%ebx
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	0f 88 97 00 00 00    	js     801cfa <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c66:	89 04 24             	mov    %eax,(%esp)
  801c69:	e8 32 f5 ff ff       	call   8011a0 <fd2data>
  801c6e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c75:	00 
  801c76:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c81:	00 
  801c82:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8d:	e8 c5 ef ff ff       	call   800c57 <sys_page_map>
  801c92:	89 c3                	mov    %eax,%ebx
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 52                	js     801cea <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801c98:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801cad:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc5:	89 04 24             	mov    %eax,(%esp)
  801cc8:	e8 c3 f4 ff ff       	call   801190 <fd2num>
  801ccd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd5:	89 04 24             	mov    %eax,(%esp)
  801cd8:	e8 b3 f4 ff ff       	call   801190 <fd2num>
  801cdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce8:	eb 38                	jmp    801d22 <pipe+0x16a>
	sys_page_unmap(0, va);
  801cea:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf5:	e8 b0 ef ff ff       	call   800caa <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d08:	e8 9d ef ff ff       	call   800caa <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d1b:	e8 8a ef ff ff       	call   800caa <sys_page_unmap>
  801d20:	89 d8                	mov    %ebx,%eax
}
  801d22:	83 c4 30             	add    $0x30,%esp
  801d25:	5b                   	pop    %ebx
  801d26:	5e                   	pop    %esi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <pipeisclosed>:
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	89 04 24             	mov    %eax,(%esp)
  801d3c:	e8 c5 f4 ff ff       	call   801206 <fd_lookup>
  801d41:	89 c2                	mov    %eax,%edx
  801d43:	85 d2                	test   %edx,%edx
  801d45:	78 15                	js     801d5c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4a:	89 04 24             	mov    %eax,(%esp)
  801d4d:	e8 4e f4 ff ff       	call   8011a0 <fd2data>
	return _pipeisclosed(fd, p);
  801d52:	89 c2                	mov    %eax,%edx
  801d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d57:	e8 0b fd ff ff       	call   801a67 <_pipeisclosed>
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d70:	c7 44 24 04 28 2a 80 	movl   $0x802a28,0x4(%esp)
  801d77:	00 
  801d78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7b:	89 04 24             	mov    %eax,(%esp)
  801d7e:	e8 64 ea ff ff       	call   8007e7 <strcpy>
	return 0;
}
  801d83:	b8 00 00 00 00       	mov    $0x0,%eax
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <devcons_write>:
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	57                   	push   %edi
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
  801d90:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d96:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d9b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801da1:	eb 31                	jmp    801dd4 <devcons_write+0x4a>
		m = n - tot;
  801da3:	8b 75 10             	mov    0x10(%ebp),%esi
  801da6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801da8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801dab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801db0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801db3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801db7:	03 45 0c             	add    0xc(%ebp),%eax
  801dba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dbe:	89 3c 24             	mov    %edi,(%esp)
  801dc1:	e8 be eb ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  801dc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dca:	89 3c 24             	mov    %edi,(%esp)
  801dcd:	e8 64 ed ff ff       	call   800b36 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801dd2:	01 f3                	add    %esi,%ebx
  801dd4:	89 d8                	mov    %ebx,%eax
  801dd6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dd9:	72 c8                	jb     801da3 <devcons_write+0x19>
}
  801ddb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    

00801de6 <devcons_read>:
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801df1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801df5:	75 07                	jne    801dfe <devcons_read+0x18>
  801df7:	eb 2a                	jmp    801e23 <devcons_read+0x3d>
		sys_yield();
  801df9:	e8 e6 ed ff ff       	call   800be4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801dfe:	66 90                	xchg   %ax,%ax
  801e00:	e8 4f ed ff ff       	call   800b54 <sys_cgetc>
  801e05:	85 c0                	test   %eax,%eax
  801e07:	74 f0                	je     801df9 <devcons_read+0x13>
	if (c < 0)
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 16                	js     801e23 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801e0d:	83 f8 04             	cmp    $0x4,%eax
  801e10:	74 0c                	je     801e1e <devcons_read+0x38>
	*(char*)vbuf = c;
  801e12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e15:	88 02                	mov    %al,(%edx)
	return 1;
  801e17:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1c:	eb 05                	jmp    801e23 <devcons_read+0x3d>
		return 0;
  801e1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    

00801e25 <cputchar>:
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e31:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e38:	00 
  801e39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3c:	89 04 24             	mov    %eax,(%esp)
  801e3f:	e8 f2 ec ff ff       	call   800b36 <sys_cputs>
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <getchar>:
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801e4c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e53:	00 
  801e54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e62:	e8 2e f6 ff ff       	call   801495 <read>
	if (r < 0)
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 0f                	js     801e7a <getchar+0x34>
	if (r < 1)
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	7e 06                	jle    801e75 <getchar+0x2f>
	return c;
  801e6f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e73:	eb 05                	jmp    801e7a <getchar+0x34>
		return -E_EOF;
  801e75:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <iscons>:
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e89:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8c:	89 04 24             	mov    %eax,(%esp)
  801e8f:	e8 72 f3 ff ff       	call   801206 <fd_lookup>
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 11                	js     801ea9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea1:	39 10                	cmp    %edx,(%eax)
  801ea3:	0f 94 c0             	sete   %al
  801ea6:	0f b6 c0             	movzbl %al,%eax
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <opencons>:
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb4:	89 04 24             	mov    %eax,(%esp)
  801eb7:	e8 fb f2 ff ff       	call   8011b7 <fd_alloc>
		return r;
  801ebc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 40                	js     801f02 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec9:	00 
  801eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed8:	e8 26 ed ff ff       	call   800c03 <sys_page_alloc>
		return r;
  801edd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	78 1f                	js     801f02 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801ee3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef8:	89 04 24             	mov    %eax,(%esp)
  801efb:	e8 90 f2 ff ff       	call   801190 <fd2num>
  801f00:	89 c2                	mov    %eax,%edx
}
  801f02:	89 d0                	mov    %edx,%eax
  801f04:	c9                   	leave  
  801f05:	c3                   	ret    

00801f06 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	56                   	push   %esi
  801f0a:	53                   	push   %ebx
  801f0b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801f0e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f11:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f17:	e8 a9 ec ff ff       	call   800bc5 <sys_getenvid>
  801f1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f1f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f23:	8b 55 08             	mov    0x8(%ebp),%edx
  801f26:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f2a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f32:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  801f39:	e8 85 e2 ff ff       	call   8001c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f42:	8b 45 10             	mov    0x10(%ebp),%eax
  801f45:	89 04 24             	mov    %eax,(%esp)
  801f48:	e8 15 e2 ff ff       	call   800162 <vcprintf>
	cprintf("\n");
  801f4d:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  801f54:	e8 6a e2 ff ff       	call   8001c3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f59:	cc                   	int3   
  801f5a:	eb fd                	jmp    801f59 <_panic+0x53>

00801f5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  801f62:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f69:	75 70                	jne    801fdb <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  801f6b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801f72:	00 
  801f73:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801f7a:	ee 
  801f7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f82:	e8 7c ec ff ff       	call   800c03 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  801f87:	85 c0                	test   %eax,%eax
  801f89:	79 1c                	jns    801fa7 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  801f8b:	c7 44 24 08 58 2a 80 	movl   $0x802a58,0x8(%esp)
  801f92:	00 
  801f93:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801f9a:	00 
  801f9b:	c7 04 24 b4 2a 80 00 	movl   $0x802ab4,(%esp)
  801fa2:	e8 5f ff ff ff       	call   801f06 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  801fa7:	c7 44 24 04 e5 1f 80 	movl   $0x801fe5,0x4(%esp)
  801fae:	00 
  801faf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb6:	e8 e8 ed ff ff       	call   800da3 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	79 1c                	jns    801fdb <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  801fbf:	c7 44 24 08 80 2a 80 	movl   $0x802a80,0x8(%esp)
  801fc6:	00 
  801fc7:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801fce:	00 
  801fcf:	c7 04 24 b4 2a 80 00 	movl   $0x802ab4,(%esp)
  801fd6:	e8 2b ff ff ff       	call   801f06 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    

00801fe5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fe5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801feb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fed:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  801ff0:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  801ff4:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  801ff8:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  801ffa:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  801ffc:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  801ffd:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  802000:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  802002:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  802005:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802006:	83 c4 04             	add    $0x4,%esp
    popf;
  802009:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  80200a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  80200b:	c3                   	ret    
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	56                   	push   %esi
  802014:	53                   	push   %ebx
  802015:	83 ec 10             	sub    $0x10,%esp
  802018:	8b 75 08             	mov    0x8(%ebp),%esi
  80201b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802021:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802023:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802028:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80202b:	89 04 24             	mov    %eax,(%esp)
  80202e:	e8 e6 ed ff ff       	call   800e19 <sys_ipc_recv>
    if(r < 0){
  802033:	85 c0                	test   %eax,%eax
  802035:	79 16                	jns    80204d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802037:	85 f6                	test   %esi,%esi
  802039:	74 06                	je     802041 <ipc_recv+0x31>
            *from_env_store = 0;
  80203b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802041:	85 db                	test   %ebx,%ebx
  802043:	74 2c                	je     802071 <ipc_recv+0x61>
            *perm_store = 0;
  802045:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80204b:	eb 24                	jmp    802071 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80204d:	85 f6                	test   %esi,%esi
  80204f:	74 0a                	je     80205b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802051:	a1 08 40 80 00       	mov    0x804008,%eax
  802056:	8b 40 74             	mov    0x74(%eax),%eax
  802059:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80205b:	85 db                	test   %ebx,%ebx
  80205d:	74 0a                	je     802069 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80205f:	a1 08 40 80 00       	mov    0x804008,%eax
  802064:	8b 40 78             	mov    0x78(%eax),%eax
  802067:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802069:	a1 08 40 80 00       	mov    0x804008,%eax
  80206e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    

00802078 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	57                   	push   %edi
  80207c:	56                   	push   %esi
  80207d:	53                   	push   %ebx
  80207e:	83 ec 1c             	sub    $0x1c,%esp
  802081:	8b 7d 08             	mov    0x8(%ebp),%edi
  802084:	8b 75 0c             	mov    0xc(%ebp),%esi
  802087:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80208a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80208c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802091:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802094:	8b 45 14             	mov    0x14(%ebp),%eax
  802097:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020a3:	89 3c 24             	mov    %edi,(%esp)
  8020a6:	e8 4b ed ff ff       	call   800df6 <sys_ipc_try_send>
        if(r == 0){
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	74 28                	je     8020d7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8020af:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b2:	74 1c                	je     8020d0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8020b4:	c7 44 24 08 c2 2a 80 	movl   $0x802ac2,0x8(%esp)
  8020bb:	00 
  8020bc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8020c3:	00 
  8020c4:	c7 04 24 d9 2a 80 00 	movl   $0x802ad9,(%esp)
  8020cb:	e8 36 fe ff ff       	call   801f06 <_panic>
        }
        sys_yield();
  8020d0:	e8 0f eb ff ff       	call   800be4 <sys_yield>
    }
  8020d5:	eb bd                	jmp    802094 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8020d7:	83 c4 1c             	add    $0x1c,%esp
  8020da:	5b                   	pop    %ebx
  8020db:	5e                   	pop    %esi
  8020dc:	5f                   	pop    %edi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    

008020df <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020ea:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020ed:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020f3:	8b 52 50             	mov    0x50(%edx),%edx
  8020f6:	39 ca                	cmp    %ecx,%edx
  8020f8:	75 0d                	jne    802107 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020fd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802102:	8b 40 40             	mov    0x40(%eax),%eax
  802105:	eb 0e                	jmp    802115 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802107:	83 c0 01             	add    $0x1,%eax
  80210a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80210f:	75 d9                	jne    8020ea <ipc_find_env+0xb>
	return 0;
  802111:	66 b8 00 00          	mov    $0x0,%ax
}
  802115:	5d                   	pop    %ebp
  802116:	c3                   	ret    

00802117 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802117:	55                   	push   %ebp
  802118:	89 e5                	mov    %esp,%ebp
  80211a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211d:	89 d0                	mov    %edx,%eax
  80211f:	c1 e8 16             	shr    $0x16,%eax
  802122:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802129:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80212e:	f6 c1 01             	test   $0x1,%cl
  802131:	74 1d                	je     802150 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802133:	c1 ea 0c             	shr    $0xc,%edx
  802136:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80213d:	f6 c2 01             	test   $0x1,%dl
  802140:	74 0e                	je     802150 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802142:	c1 ea 0c             	shr    $0xc,%edx
  802145:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80214c:	ef 
  80214d:	0f b7 c0             	movzwl %ax,%eax
}
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	83 ec 0c             	sub    $0xc,%esp
  802166:	8b 44 24 28          	mov    0x28(%esp),%eax
  80216a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80216e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802172:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802176:	85 c0                	test   %eax,%eax
  802178:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80217c:	89 ea                	mov    %ebp,%edx
  80217e:	89 0c 24             	mov    %ecx,(%esp)
  802181:	75 2d                	jne    8021b0 <__udivdi3+0x50>
  802183:	39 e9                	cmp    %ebp,%ecx
  802185:	77 61                	ja     8021e8 <__udivdi3+0x88>
  802187:	85 c9                	test   %ecx,%ecx
  802189:	89 ce                	mov    %ecx,%esi
  80218b:	75 0b                	jne    802198 <__udivdi3+0x38>
  80218d:	b8 01 00 00 00       	mov    $0x1,%eax
  802192:	31 d2                	xor    %edx,%edx
  802194:	f7 f1                	div    %ecx
  802196:	89 c6                	mov    %eax,%esi
  802198:	31 d2                	xor    %edx,%edx
  80219a:	89 e8                	mov    %ebp,%eax
  80219c:	f7 f6                	div    %esi
  80219e:	89 c5                	mov    %eax,%ebp
  8021a0:	89 f8                	mov    %edi,%eax
  8021a2:	f7 f6                	div    %esi
  8021a4:	89 ea                	mov    %ebp,%edx
  8021a6:	83 c4 0c             	add    $0xc,%esp
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	39 e8                	cmp    %ebp,%eax
  8021b2:	77 24                	ja     8021d8 <__udivdi3+0x78>
  8021b4:	0f bd e8             	bsr    %eax,%ebp
  8021b7:	83 f5 1f             	xor    $0x1f,%ebp
  8021ba:	75 3c                	jne    8021f8 <__udivdi3+0x98>
  8021bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8021c0:	39 34 24             	cmp    %esi,(%esp)
  8021c3:	0f 86 9f 00 00 00    	jbe    802268 <__udivdi3+0x108>
  8021c9:	39 d0                	cmp    %edx,%eax
  8021cb:	0f 82 97 00 00 00    	jb     802268 <__udivdi3+0x108>
  8021d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	31 c0                	xor    %eax,%eax
  8021dc:	83 c4 0c             	add    $0xc,%esp
  8021df:	5e                   	pop    %esi
  8021e0:	5f                   	pop    %edi
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    
  8021e3:	90                   	nop
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	89 f8                	mov    %edi,%eax
  8021ea:	f7 f1                	div    %ecx
  8021ec:	31 d2                	xor    %edx,%edx
  8021ee:	83 c4 0c             	add    $0xc,%esp
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	8b 3c 24             	mov    (%esp),%edi
  8021fd:	d3 e0                	shl    %cl,%eax
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	b8 20 00 00 00       	mov    $0x20,%eax
  802206:	29 e8                	sub    %ebp,%eax
  802208:	89 c1                	mov    %eax,%ecx
  80220a:	d3 ef                	shr    %cl,%edi
  80220c:	89 e9                	mov    %ebp,%ecx
  80220e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802212:	8b 3c 24             	mov    (%esp),%edi
  802215:	09 74 24 08          	or     %esi,0x8(%esp)
  802219:	89 d6                	mov    %edx,%esi
  80221b:	d3 e7                	shl    %cl,%edi
  80221d:	89 c1                	mov    %eax,%ecx
  80221f:	89 3c 24             	mov    %edi,(%esp)
  802222:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802226:	d3 ee                	shr    %cl,%esi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	d3 e2                	shl    %cl,%edx
  80222c:	89 c1                	mov    %eax,%ecx
  80222e:	d3 ef                	shr    %cl,%edi
  802230:	09 d7                	or     %edx,%edi
  802232:	89 f2                	mov    %esi,%edx
  802234:	89 f8                	mov    %edi,%eax
  802236:	f7 74 24 08          	divl   0x8(%esp)
  80223a:	89 d6                	mov    %edx,%esi
  80223c:	89 c7                	mov    %eax,%edi
  80223e:	f7 24 24             	mull   (%esp)
  802241:	39 d6                	cmp    %edx,%esi
  802243:	89 14 24             	mov    %edx,(%esp)
  802246:	72 30                	jb     802278 <__udivdi3+0x118>
  802248:	8b 54 24 04          	mov    0x4(%esp),%edx
  80224c:	89 e9                	mov    %ebp,%ecx
  80224e:	d3 e2                	shl    %cl,%edx
  802250:	39 c2                	cmp    %eax,%edx
  802252:	73 05                	jae    802259 <__udivdi3+0xf9>
  802254:	3b 34 24             	cmp    (%esp),%esi
  802257:	74 1f                	je     802278 <__udivdi3+0x118>
  802259:	89 f8                	mov    %edi,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	e9 7a ff ff ff       	jmp    8021dc <__udivdi3+0x7c>
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	31 d2                	xor    %edx,%edx
  80226a:	b8 01 00 00 00       	mov    $0x1,%eax
  80226f:	e9 68 ff ff ff       	jmp    8021dc <__udivdi3+0x7c>
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	8d 47 ff             	lea    -0x1(%edi),%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	83 c4 0c             	add    $0xc,%esp
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	83 ec 14             	sub    $0x14,%esp
  802296:	8b 44 24 28          	mov    0x28(%esp),%eax
  80229a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80229e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8022a2:	89 c7                	mov    %eax,%edi
  8022a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8022ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022b0:	89 34 24             	mov    %esi,(%esp)
  8022b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	89 c2                	mov    %eax,%edx
  8022bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022bf:	75 17                	jne    8022d8 <__umoddi3+0x48>
  8022c1:	39 fe                	cmp    %edi,%esi
  8022c3:	76 4b                	jbe    802310 <__umoddi3+0x80>
  8022c5:	89 c8                	mov    %ecx,%eax
  8022c7:	89 fa                	mov    %edi,%edx
  8022c9:	f7 f6                	div    %esi
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	31 d2                	xor    %edx,%edx
  8022cf:	83 c4 14             	add    $0x14,%esp
  8022d2:	5e                   	pop    %esi
  8022d3:	5f                   	pop    %edi
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    
  8022d6:	66 90                	xchg   %ax,%ax
  8022d8:	39 f8                	cmp    %edi,%eax
  8022da:	77 54                	ja     802330 <__umoddi3+0xa0>
  8022dc:	0f bd e8             	bsr    %eax,%ebp
  8022df:	83 f5 1f             	xor    $0x1f,%ebp
  8022e2:	75 5c                	jne    802340 <__umoddi3+0xb0>
  8022e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8022e8:	39 3c 24             	cmp    %edi,(%esp)
  8022eb:	0f 87 e7 00 00 00    	ja     8023d8 <__umoddi3+0x148>
  8022f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022f5:	29 f1                	sub    %esi,%ecx
  8022f7:	19 c7                	sbb    %eax,%edi
  8022f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802301:	8b 44 24 08          	mov    0x8(%esp),%eax
  802305:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802309:	83 c4 14             	add    $0x14,%esp
  80230c:	5e                   	pop    %esi
  80230d:	5f                   	pop    %edi
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    
  802310:	85 f6                	test   %esi,%esi
  802312:	89 f5                	mov    %esi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f6                	div    %esi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	8b 44 24 04          	mov    0x4(%esp),%eax
  802325:	31 d2                	xor    %edx,%edx
  802327:	f7 f5                	div    %ebp
  802329:	89 c8                	mov    %ecx,%eax
  80232b:	f7 f5                	div    %ebp
  80232d:	eb 9c                	jmp    8022cb <__umoddi3+0x3b>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 fa                	mov    %edi,%edx
  802334:	83 c4 14             	add    $0x14,%esp
  802337:	5e                   	pop    %esi
  802338:	5f                   	pop    %edi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    
  80233b:	90                   	nop
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 04 24             	mov    (%esp),%eax
  802343:	be 20 00 00 00       	mov    $0x20,%esi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ee                	sub    %ebp,%esi
  80234c:	d3 e2                	shl    %cl,%edx
  80234e:	89 f1                	mov    %esi,%ecx
  802350:	d3 e8                	shr    %cl,%eax
  802352:	89 e9                	mov    %ebp,%ecx
  802354:	89 44 24 04          	mov    %eax,0x4(%esp)
  802358:	8b 04 24             	mov    (%esp),%eax
  80235b:	09 54 24 04          	or     %edx,0x4(%esp)
  80235f:	89 fa                	mov    %edi,%edx
  802361:	d3 e0                	shl    %cl,%eax
  802363:	89 f1                	mov    %esi,%ecx
  802365:	89 44 24 08          	mov    %eax,0x8(%esp)
  802369:	8b 44 24 10          	mov    0x10(%esp),%eax
  80236d:	d3 ea                	shr    %cl,%edx
  80236f:	89 e9                	mov    %ebp,%ecx
  802371:	d3 e7                	shl    %cl,%edi
  802373:	89 f1                	mov    %esi,%ecx
  802375:	d3 e8                	shr    %cl,%eax
  802377:	89 e9                	mov    %ebp,%ecx
  802379:	09 f8                	or     %edi,%eax
  80237b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80237f:	f7 74 24 04          	divl   0x4(%esp)
  802383:	d3 e7                	shl    %cl,%edi
  802385:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802389:	89 d7                	mov    %edx,%edi
  80238b:	f7 64 24 08          	mull   0x8(%esp)
  80238f:	39 d7                	cmp    %edx,%edi
  802391:	89 c1                	mov    %eax,%ecx
  802393:	89 14 24             	mov    %edx,(%esp)
  802396:	72 2c                	jb     8023c4 <__umoddi3+0x134>
  802398:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80239c:	72 22                	jb     8023c0 <__umoddi3+0x130>
  80239e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023a2:	29 c8                	sub    %ecx,%eax
  8023a4:	19 d7                	sbb    %edx,%edi
  8023a6:	89 e9                	mov    %ebp,%ecx
  8023a8:	89 fa                	mov    %edi,%edx
  8023aa:	d3 e8                	shr    %cl,%eax
  8023ac:	89 f1                	mov    %esi,%ecx
  8023ae:	d3 e2                	shl    %cl,%edx
  8023b0:	89 e9                	mov    %ebp,%ecx
  8023b2:	d3 ef                	shr    %cl,%edi
  8023b4:	09 d0                	or     %edx,%eax
  8023b6:	89 fa                	mov    %edi,%edx
  8023b8:	83 c4 14             	add    $0x14,%esp
  8023bb:	5e                   	pop    %esi
  8023bc:	5f                   	pop    %edi
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    
  8023bf:	90                   	nop
  8023c0:	39 d7                	cmp    %edx,%edi
  8023c2:	75 da                	jne    80239e <__umoddi3+0x10e>
  8023c4:	8b 14 24             	mov    (%esp),%edx
  8023c7:	89 c1                	mov    %eax,%ecx
  8023c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8023cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8023d1:	eb cb                	jmp    80239e <__umoddi3+0x10e>
  8023d3:	90                   	nop
  8023d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8023dc:	0f 82 0f ff ff ff    	jb     8022f1 <__umoddi3+0x61>
  8023e2:	e9 1a ff ff ff       	jmp    802301 <__umoddi3+0x71>
