
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 61 00 00 00       	call   800092 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 a0 20 80 00 	movl   $0x8020a0,(%esp)
  800060:	e8 31 01 00 00       	call   800196 <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 2b 0b 00 00       	call   800b95 <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 d1 0a 00 00       	call   800b43 <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 b5 0d 00 00       	call   800e3b <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	83 ec 10             	sub    $0x10,%esp
  80009a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80009d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8000a0:	e8 f0 0a 00 00       	call   800b95 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8000a5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000aa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b2:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b7:	85 db                	test   %ebx,%ebx
  8000b9:	7e 07                	jle    8000c2 <libmain+0x30>
		binaryname = argv[0];
  8000bb:	8b 06                	mov    (%esi),%eax
  8000bd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	e8 a6 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000ce:	e8 07 00 00 00       	call   8000da <exit>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000e0:	e8 e0 0f 00 00       	call   8010c5 <close_all>
	sys_env_destroy(0);
  8000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ec:	e8 52 0a 00 00       	call   800b43 <sys_env_destroy>
}
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 14             	sub    $0x14,%esp
  8000fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fd:	8b 13                	mov    (%ebx),%edx
  8000ff:	8d 42 01             	lea    0x1(%edx),%eax
  800102:	89 03                	mov    %eax,(%ebx)
  800104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800107:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800110:	75 19                	jne    80012b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800112:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800119:	00 
  80011a:	8d 43 08             	lea    0x8(%ebx),%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 e1 09 00 00       	call   800b06 <sys_cputs>
		b->idx = 0;
  800125:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	83 c4 14             	add    $0x14,%esp
  800132:	5b                   	pop    %ebx
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80013e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800145:	00 00 00 
	b.cnt = 0;
  800148:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800152:	8b 45 0c             	mov    0xc(%ebp),%eax
  800155:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800159:	8b 45 08             	mov    0x8(%ebp),%eax
  80015c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016a:	c7 04 24 f3 00 80 00 	movl   $0x8000f3,(%esp)
  800171:	e8 a8 01 00 00       	call   80031e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800176:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 78 09 00 00       	call   800b06 <sys_cputs>

	return b.cnt;
}
  80018e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 87 ff ff ff       	call   800135 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 3c             	sub    $0x3c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d7                	mov    %edx,%edi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c7:	89 c3                	mov    %eax,%ebx
  8001c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001dd:	39 d9                	cmp    %ebx,%ecx
  8001df:	72 05                	jb     8001e6 <printnum+0x36>
  8001e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001e4:	77 69                	ja     80024f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ed:	83 ee 01             	sub    $0x1,%esi
  8001f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800200:	89 c3                	mov    %eax,%ebx
  800202:	89 d6                	mov    %edx,%esi
  800204:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800207:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80020a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80020e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800212:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	e8 ec 1b 00 00       	call   801e10 <__udivdi3>
  800224:	89 d9                	mov    %ebx,%ecx
  800226:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80022a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	89 54 24 04          	mov    %edx,0x4(%esp)
  800235:	89 fa                	mov    %edi,%edx
  800237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023a:	e8 71 ff ff ff       	call   8001b0 <printnum>
  80023f:	eb 1b                	jmp    80025c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800241:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800245:	8b 45 18             	mov    0x18(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	ff d3                	call   *%ebx
  80024d:	eb 03                	jmp    800252 <printnum+0xa2>
  80024f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800252:	83 ee 01             	sub    $0x1,%esi
  800255:	85 f6                	test   %esi,%esi
  800257:	7f e8                	jg     800241 <printnum+0x91>
  800259:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800260:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800264:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800267:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 bc 1c 00 00       	call   801f40 <__umoddi3>
  800284:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800288:	0f be 80 c6 20 80 00 	movsbl 0x8020c6(%eax),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800295:	ff d0                	call   *%eax
}
  800297:	83 c4 3c             	add    $0x3c,%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5e                   	pop    %esi
  80029c:	5f                   	pop    %edi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a2:	83 fa 01             	cmp    $0x1,%edx
  8002a5:	7e 0e                	jle    8002b5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 02                	mov    (%edx),%eax
  8002b0:	8b 52 04             	mov    0x4(%edx),%edx
  8002b3:	eb 22                	jmp    8002d7 <getuint+0x38>
	else if (lflag)
  8002b5:	85 d2                	test   %edx,%edx
  8002b7:	74 10                	je     8002c9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c7:	eb 0e                	jmp    8002d7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002df:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e8:	73 0a                	jae    8002f4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ea:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	88 02                	mov    %al,(%edx)
}
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <printfmt>:
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8002fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800303:	8b 45 10             	mov    0x10(%ebp),%eax
  800306:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	e8 02 00 00 00       	call   80031e <vprintfmt>
}
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <vprintfmt>:
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 3c             	sub    $0x3c,%esp
  800327:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80032a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032d:	eb 1f                	jmp    80034e <vprintfmt+0x30>
			if (ch == '\0'){
  80032f:	85 c0                	test   %eax,%eax
  800331:	75 0f                	jne    800342 <vprintfmt+0x24>
				color = 0x0100;
  800333:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80033a:	01 00 00 
  80033d:	e9 b3 03 00 00       	jmp    8006f5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800342:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034c:	89 f3                	mov    %esi,%ebx
  80034e:	8d 73 01             	lea    0x1(%ebx),%esi
  800351:	0f b6 03             	movzbl (%ebx),%eax
  800354:	83 f8 25             	cmp    $0x25,%eax
  800357:	75 d6                	jne    80032f <vprintfmt+0x11>
  800359:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80035d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800364:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80036b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 1d                	jmp    800396 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800379:	89 de                	mov    %ebx,%esi
			padc = '-';
  80037b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80037f:	eb 15                	jmp    800396 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800381:	89 de                	mov    %ebx,%esi
			padc = '0';
  800383:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800387:	eb 0d                	jmp    800396 <vprintfmt+0x78>
				width = precision, precision = -1;
  800389:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80038f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8d 5e 01             	lea    0x1(%esi),%ebx
  800399:	0f b6 0e             	movzbl (%esi),%ecx
  80039c:	0f b6 c1             	movzbl %cl,%eax
  80039f:	83 e9 23             	sub    $0x23,%ecx
  8003a2:	80 f9 55             	cmp    $0x55,%cl
  8003a5:	0f 87 2a 03 00 00    	ja     8006d5 <vprintfmt+0x3b7>
  8003ab:	0f b6 c9             	movzbl %cl,%ecx
  8003ae:	ff 24 8d 00 22 80 00 	jmp    *0x802200(,%ecx,4)
  8003b5:	89 de                	mov    %ebx,%esi
  8003b7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8003bc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003bf:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003c3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003c9:	83 fb 09             	cmp    $0x9,%ebx
  8003cc:	77 36                	ja     800404 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8003ce:	83 c6 01             	add    $0x1,%esi
			}
  8003d1:	eb e9                	jmp    8003bc <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8003e3:	eb 22                	jmp    800407 <vprintfmt+0xe9>
  8003e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003e8:	85 c9                	test   %ecx,%ecx
  8003ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ef:	0f 49 c1             	cmovns %ecx,%eax
  8003f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	89 de                	mov    %ebx,%esi
  8003f7:	eb 9d                	jmp    800396 <vprintfmt+0x78>
  8003f9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8003fb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800402:	eb 92                	jmp    800396 <vprintfmt+0x78>
  800404:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800407:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80040b:	79 89                	jns    800396 <vprintfmt+0x78>
  80040d:	e9 77 ff ff ff       	jmp    800389 <vprintfmt+0x6b>
			lflag++;
  800412:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800415:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800417:	e9 7a ff ff ff       	jmp    800396 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	89 04 24             	mov    %eax,(%esp)
  80042e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800431:	e9 18 ff ff ff       	jmp    80034e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	99                   	cltd   
  800442:	31 d0                	xor    %edx,%eax
  800444:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800446:	83 f8 0f             	cmp    $0xf,%eax
  800449:	7f 0b                	jg     800456 <vprintfmt+0x138>
  80044b:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  800452:	85 d2                	test   %edx,%edx
  800454:	75 20                	jne    800476 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800456:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045a:	c7 44 24 08 de 20 80 	movl   $0x8020de,0x8(%esp)
  800461:	00 
  800462:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800466:	8b 45 08             	mov    0x8(%ebp),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 85 fe ff ff       	call   8002f6 <printfmt>
  800471:	e9 d8 fe ff ff       	jmp    80034e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800476:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047a:	c7 44 24 08 26 25 80 	movl   $0x802526,0x8(%esp)
  800481:	00 
  800482:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800486:	8b 45 08             	mov    0x8(%ebp),%eax
  800489:	89 04 24             	mov    %eax,(%esp)
  80048c:	e8 65 fe ff ff       	call   8002f6 <printfmt>
  800491:	e9 b8 fe ff ff       	jmp    80034e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800499:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80049c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 50 04             	lea    0x4(%eax),%edx
  8004a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004aa:	85 f6                	test   %esi,%esi
  8004ac:	b8 d7 20 80 00       	mov    $0x8020d7,%eax
  8004b1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004b4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b8:	0f 84 97 00 00 00    	je     800555 <vprintfmt+0x237>
  8004be:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004c2:	0f 8e 9b 00 00 00    	jle    800563 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004cc:	89 34 24             	mov    %esi,(%esp)
  8004cf:	e8 c4 02 00 00       	call   800798 <strnlen>
  8004d4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004d7:	29 c2                	sub    %eax,%edx
  8004d9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8004dc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004e3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004ec:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	eb 0f                	jmp    8004ff <vprintfmt+0x1e1>
					putch(padc, putdat);
  8004f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	83 eb 01             	sub    $0x1,%ebx
  8004ff:	85 db                	test   %ebx,%ebx
  800501:	7f ed                	jg     8004f0 <vprintfmt+0x1d2>
  800503:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800506:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800509:	85 d2                	test   %edx,%edx
  80050b:	b8 00 00 00 00       	mov    $0x0,%eax
  800510:	0f 49 c2             	cmovns %edx,%eax
  800513:	29 c2                	sub    %eax,%edx
  800515:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800518:	89 d7                	mov    %edx,%edi
  80051a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80051d:	eb 50                	jmp    80056f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80051f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800523:	74 1e                	je     800543 <vprintfmt+0x225>
  800525:	0f be d2             	movsbl %dl,%edx
  800528:	83 ea 20             	sub    $0x20,%edx
  80052b:	83 fa 5e             	cmp    $0x5e,%edx
  80052e:	76 13                	jbe    800543 <vprintfmt+0x225>
					putch('?', putdat);
  800530:	8b 45 0c             	mov    0xc(%ebp),%eax
  800533:	89 44 24 04          	mov    %eax,0x4(%esp)
  800537:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	eb 0d                	jmp    800550 <vprintfmt+0x232>
					putch(ch, putdat);
  800543:	8b 55 0c             	mov    0xc(%ebp),%edx
  800546:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	eb 1a                	jmp    80056f <vprintfmt+0x251>
  800555:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800558:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80055b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80055e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800561:	eb 0c                	jmp    80056f <vprintfmt+0x251>
  800563:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800566:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800569:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80056c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80056f:	83 c6 01             	add    $0x1,%esi
  800572:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800576:	0f be c2             	movsbl %dl,%eax
  800579:	85 c0                	test   %eax,%eax
  80057b:	74 27                	je     8005a4 <vprintfmt+0x286>
  80057d:	85 db                	test   %ebx,%ebx
  80057f:	78 9e                	js     80051f <vprintfmt+0x201>
  800581:	83 eb 01             	sub    $0x1,%ebx
  800584:	79 99                	jns    80051f <vprintfmt+0x201>
  800586:	89 f8                	mov    %edi,%eax
  800588:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80058b:	8b 75 08             	mov    0x8(%ebp),%esi
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	eb 1a                	jmp    8005ac <vprintfmt+0x28e>
				putch(' ', putdat);
  800592:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800596:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80059f:	83 eb 01             	sub    $0x1,%ebx
  8005a2:	eb 08                	jmp    8005ac <vprintfmt+0x28e>
  8005a4:	89 fb                	mov    %edi,%ebx
  8005a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005ac:	85 db                	test   %ebx,%ebx
  8005ae:	7f e2                	jg     800592 <vprintfmt+0x274>
  8005b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005b6:	e9 93 fd ff ff       	jmp    80034e <vprintfmt+0x30>
	if (lflag >= 2)
  8005bb:	83 fa 01             	cmp    $0x1,%edx
  8005be:	7e 16                	jle    8005d6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 50 04             	mov    0x4(%eax),%edx
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005d4:	eb 32                	jmp    800608 <vprintfmt+0x2ea>
	else if (lflag)
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	74 18                	je     8005f2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 30                	mov    (%eax),%esi
  8005e5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005e8:	89 f0                	mov    %esi,%eax
  8005ea:	c1 f8 1f             	sar    $0x1f,%eax
  8005ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f0:	eb 16                	jmp    800608 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 30                	mov    (%eax),%esi
  8005fd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800600:	89 f0                	mov    %esi,%eax
  800602:	c1 f8 1f             	sar    $0x1f,%eax
  800605:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800608:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80060e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800613:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800617:	0f 89 80 00 00 00    	jns    80069d <vprintfmt+0x37f>
				putch('-', putdat);
  80061d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800621:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800628:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80062b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800631:	f7 d8                	neg    %eax
  800633:	83 d2 00             	adc    $0x0,%edx
  800636:	f7 da                	neg    %edx
			base = 10;
  800638:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063d:	eb 5e                	jmp    80069d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 58 fc ff ff       	call   80029f <getuint>
			base = 10;
  800647:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064c:	eb 4f                	jmp    80069d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 49 fc ff ff       	call   80029f <getuint>
            base = 8;
  800656:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80065b:	eb 40                	jmp    80069d <vprintfmt+0x37f>
			putch('0', putdat);
  80065d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800661:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80066b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800676:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 50 04             	lea    0x4(%eax),%edx
  80067f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800682:	8b 00                	mov    (%eax),%eax
  800684:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800689:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068e:	eb 0d                	jmp    80069d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
  800693:	e8 07 fc ff ff       	call   80029f <getuint>
			base = 16;
  800698:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80069d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8006a1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006a5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006a8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006ac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b7:	89 fa                	mov    %edi,%edx
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	e8 ef fa ff ff       	call   8001b0 <printnum>
			break;
  8006c1:	e9 88 fc ff ff       	jmp    80034e <vprintfmt+0x30>
			putch(ch, putdat);
  8006c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ca:	89 04 24             	mov    %eax,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d0:	e9 79 fc ff ff       	jmp    80034e <vprintfmt+0x30>
			putch('%', putdat);
  8006d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e3:	89 f3                	mov    %esi,%ebx
  8006e5:	eb 03                	jmp    8006ea <vprintfmt+0x3cc>
  8006e7:	83 eb 01             	sub    $0x1,%ebx
  8006ea:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006ee:	75 f7                	jne    8006e7 <vprintfmt+0x3c9>
  8006f0:	e9 59 fc ff ff       	jmp    80034e <vprintfmt+0x30>
}
  8006f5:	83 c4 3c             	add    $0x3c,%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 28             	sub    $0x28,%esp
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800709:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800710:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800713:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071a:	85 c0                	test   %eax,%eax
  80071c:	74 30                	je     80074e <vsnprintf+0x51>
  80071e:	85 d2                	test   %edx,%edx
  800720:	7e 2c                	jle    80074e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800729:	8b 45 10             	mov    0x10(%ebp),%eax
  80072c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800730:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800733:	89 44 24 04          	mov    %eax,0x4(%esp)
  800737:	c7 04 24 d9 02 80 00 	movl   $0x8002d9,(%esp)
  80073e:	e8 db fb ff ff       	call   80031e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800743:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800746:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	eb 05                	jmp    800753 <vsnprintf+0x56>
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 82 ff ff ff       	call   8006fd <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
  80077d:	66 90                	xchg   %ax,%ax
  80077f:	90                   	nop

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 03                	jmp    800790 <strlen+0x10>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800790:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800794:	75 f7                	jne    80078d <strlen+0xd>
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	eb 03                	jmp    8007ab <strnlen+0x13>
		n++;
  8007a8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	39 d0                	cmp    %edx,%eax
  8007ad:	74 06                	je     8007b5 <strnlen+0x1d>
  8007af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b3:	75 f3                	jne    8007a8 <strnlen+0x10>
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c1:	89 c2                	mov    %eax,%edx
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d0:	84 db                	test   %bl,%bl
  8007d2:	75 ef                	jne    8007c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e1:	89 1c 24             	mov    %ebx,(%esp)
  8007e4:	e8 97 ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f0:	01 d8                	add    %ebx,%eax
  8007f2:	89 04 24             	mov    %eax,(%esp)
  8007f5:	e8 bd ff ff ff       	call   8007b7 <strcpy>
	return dst;
}
  8007fa:	89 d8                	mov    %ebx,%eax
  8007fc:	83 c4 08             	add    $0x8,%esp
  8007ff:	5b                   	pop    %ebx
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	89 f3                	mov    %esi,%ebx
  80080f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800812:	89 f2                	mov    %esi,%edx
  800814:	eb 0f                	jmp    800825 <strncpy+0x23>
		*dst++ = *src;
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	0f b6 01             	movzbl (%ecx),%eax
  80081c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081f:	80 39 01             	cmpb   $0x1,(%ecx)
  800822:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800825:	39 da                	cmp    %ebx,%edx
  800827:	75 ed                	jne    800816 <strncpy+0x14>
	}
	return ret;
}
  800829:	89 f0                	mov    %esi,%eax
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800843:	85 c9                	test   %ecx,%ecx
  800845:	75 0b                	jne    800852 <strlcpy+0x23>
  800847:	eb 1d                	jmp    800866 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	83 c2 01             	add    $0x1,%edx
  80084f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800852:	39 d8                	cmp    %ebx,%eax
  800854:	74 0b                	je     800861 <strlcpy+0x32>
  800856:	0f b6 0a             	movzbl (%edx),%ecx
  800859:	84 c9                	test   %cl,%cl
  80085b:	75 ec                	jne    800849 <strlcpy+0x1a>
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	eb 02                	jmp    800863 <strlcpy+0x34>
  800861:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800863:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800866:	29 f0                	sub    %esi,%eax
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800875:	eb 06                	jmp    80087d <strcmp+0x11>
		p++, q++;
  800877:	83 c1 01             	add    $0x1,%ecx
  80087a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80087d:	0f b6 01             	movzbl (%ecx),%eax
  800880:	84 c0                	test   %al,%al
  800882:	74 04                	je     800888 <strcmp+0x1c>
  800884:	3a 02                	cmp    (%edx),%al
  800886:	74 ef                	je     800877 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800888:	0f b6 c0             	movzbl %al,%eax
  80088b:	0f b6 12             	movzbl (%edx),%edx
  80088e:	29 d0                	sub    %edx,%eax
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 c3                	mov    %eax,%ebx
  80089e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a1:	eb 06                	jmp    8008a9 <strncmp+0x17>
		n--, p++, q++;
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008a9:	39 d8                	cmp    %ebx,%eax
  8008ab:	74 15                	je     8008c2 <strncmp+0x30>
  8008ad:	0f b6 08             	movzbl (%eax),%ecx
  8008b0:	84 c9                	test   %cl,%cl
  8008b2:	74 04                	je     8008b8 <strncmp+0x26>
  8008b4:	3a 0a                	cmp    (%edx),%cl
  8008b6:	74 eb                	je     8008a3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 00             	movzbl (%eax),%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
  8008c0:	eb 05                	jmp    8008c7 <strncmp+0x35>
		return 0;
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d4:	eb 07                	jmp    8008dd <strchr+0x13>
		if (*s == c)
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	74 0f                	je     8008e9 <strchr+0x1f>
	for (; *s; s++)
  8008da:	83 c0 01             	add    $0x1,%eax
  8008dd:	0f b6 10             	movzbl (%eax),%edx
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	75 f2                	jne    8008d6 <strchr+0xc>
			return (char *) s;
	return 0;
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f5:	eb 07                	jmp    8008fe <strfind+0x13>
		if (*s == c)
  8008f7:	38 ca                	cmp    %cl,%dl
  8008f9:	74 0a                	je     800905 <strfind+0x1a>
	for (; *s; s++)
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	0f b6 10             	movzbl (%eax),%edx
  800901:	84 d2                	test   %dl,%dl
  800903:	75 f2                	jne    8008f7 <strfind+0xc>
			break;
	return (char *) s;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800913:	85 c9                	test   %ecx,%ecx
  800915:	74 36                	je     80094d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800917:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091d:	75 28                	jne    800947 <memset+0x40>
  80091f:	f6 c1 03             	test   $0x3,%cl
  800922:	75 23                	jne    800947 <memset+0x40>
		c &= 0xFF;
  800924:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800928:	89 d3                	mov    %edx,%ebx
  80092a:	c1 e3 08             	shl    $0x8,%ebx
  80092d:	89 d6                	mov    %edx,%esi
  80092f:	c1 e6 18             	shl    $0x18,%esi
  800932:	89 d0                	mov    %edx,%eax
  800934:	c1 e0 10             	shl    $0x10,%eax
  800937:	09 f0                	or     %esi,%eax
  800939:	09 c2                	or     %eax,%edx
  80093b:	89 d0                	mov    %edx,%eax
  80093d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800942:	fc                   	cld    
  800943:	f3 ab                	rep stos %eax,%es:(%edi)
  800945:	eb 06                	jmp    80094d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	fc                   	cld    
  80094b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094d:	89 f8                	mov    %edi,%eax
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800962:	39 c6                	cmp    %eax,%esi
  800964:	73 35                	jae    80099b <memmove+0x47>
  800966:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800969:	39 d0                	cmp    %edx,%eax
  80096b:	73 2e                	jae    80099b <memmove+0x47>
		s += n;
		d += n;
  80096d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800970:	89 d6                	mov    %edx,%esi
  800972:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097a:	75 13                	jne    80098f <memmove+0x3b>
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 0e                	jne    80098f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800981:	83 ef 04             	sub    $0x4,%edi
  800984:	8d 72 fc             	lea    -0x4(%edx),%esi
  800987:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098a:	fd                   	std    
  80098b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098d:	eb 09                	jmp    800998 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098f:	83 ef 01             	sub    $0x1,%edi
  800992:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800995:	fd                   	std    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800998:	fc                   	cld    
  800999:	eb 1d                	jmp    8009b8 <memmove+0x64>
  80099b:	89 f2                	mov    %esi,%edx
  80099d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	f6 c2 03             	test   $0x3,%dl
  8009a2:	75 0f                	jne    8009b3 <memmove+0x5f>
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 0a                	jne    8009b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ac:	89 c7                	mov    %eax,%edi
  8009ae:	fc                   	cld    
  8009af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b1:	eb 05                	jmp    8009b8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  8009b3:	89 c7                	mov    %eax,%edi
  8009b5:	fc                   	cld    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	89 04 24             	mov    %eax,(%esp)
  8009d6:	e8 79 ff ff ff       	call   800954 <memmove>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e8:	89 d6                	mov    %edx,%esi
  8009ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ed:	eb 1a                	jmp    800a09 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ef:	0f b6 02             	movzbl (%edx),%eax
  8009f2:	0f b6 19             	movzbl (%ecx),%ebx
  8009f5:	38 d8                	cmp    %bl,%al
  8009f7:	74 0a                	je     800a03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f9:	0f b6 c0             	movzbl %al,%eax
  8009fc:	0f b6 db             	movzbl %bl,%ebx
  8009ff:	29 d8                	sub    %ebx,%eax
  800a01:	eb 0f                	jmp    800a12 <memcmp+0x35>
		s1++, s2++;
  800a03:	83 c2 01             	add    $0x1,%edx
  800a06:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800a09:	39 f2                	cmp    %esi,%edx
  800a0b:	75 e2                	jne    8009ef <memcmp+0x12>
	}

	return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1f:	89 c2                	mov    %eax,%edx
  800a21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a24:	eb 07                	jmp    800a2d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a26:	38 08                	cmp    %cl,(%eax)
  800a28:	74 07                	je     800a31 <memfind+0x1b>
	for (; s < ends; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	39 d0                	cmp    %edx,%eax
  800a2f:	72 f5                	jb     800a26 <memfind+0x10>
			break;
	return (void *) s;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3f:	eb 03                	jmp    800a44 <strtol+0x11>
		s++;
  800a41:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a44:	0f b6 0a             	movzbl (%edx),%ecx
  800a47:	80 f9 09             	cmp    $0x9,%cl
  800a4a:	74 f5                	je     800a41 <strtol+0xe>
  800a4c:	80 f9 20             	cmp    $0x20,%cl
  800a4f:	74 f0                	je     800a41 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a51:	80 f9 2b             	cmp    $0x2b,%cl
  800a54:	75 0a                	jne    800a60 <strtol+0x2d>
		s++;
  800a56:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5e:	eb 11                	jmp    800a71 <strtol+0x3e>
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800a65:	80 f9 2d             	cmp    $0x2d,%cl
  800a68:	75 07                	jne    800a71 <strtol+0x3e>
		s++, neg = 1;
  800a6a:	8d 52 01             	lea    0x1(%edx),%edx
  800a6d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a71:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a76:	75 15                	jne    800a8d <strtol+0x5a>
  800a78:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7b:	75 10                	jne    800a8d <strtol+0x5a>
  800a7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a81:	75 0a                	jne    800a8d <strtol+0x5a>
		s += 2, base = 16;
  800a83:	83 c2 02             	add    $0x2,%edx
  800a86:	b8 10 00 00 00       	mov    $0x10,%eax
  800a8b:	eb 10                	jmp    800a9d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 c0                	test   %eax,%eax
  800a8f:	75 0c                	jne    800a9d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a91:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800a93:	80 3a 30             	cmpb   $0x30,(%edx)
  800a96:	75 05                	jne    800a9d <strtol+0x6a>
		s++, base = 8;
  800a98:	83 c2 01             	add    $0x1,%edx
  800a9b:	b0 08                	mov    $0x8,%al
		base = 10;
  800a9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aa2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa5:	0f b6 0a             	movzbl (%edx),%ecx
  800aa8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800aab:	89 f0                	mov    %esi,%eax
  800aad:	3c 09                	cmp    $0x9,%al
  800aaf:	77 08                	ja     800ab9 <strtol+0x86>
			dig = *s - '0';
  800ab1:	0f be c9             	movsbl %cl,%ecx
  800ab4:	83 e9 30             	sub    $0x30,%ecx
  800ab7:	eb 20                	jmp    800ad9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ab9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800abc:	89 f0                	mov    %esi,%eax
  800abe:	3c 19                	cmp    $0x19,%al
  800ac0:	77 08                	ja     800aca <strtol+0x97>
			dig = *s - 'a' + 10;
  800ac2:	0f be c9             	movsbl %cl,%ecx
  800ac5:	83 e9 57             	sub    $0x57,%ecx
  800ac8:	eb 0f                	jmp    800ad9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800acd:	89 f0                	mov    %esi,%eax
  800acf:	3c 19                	cmp    $0x19,%al
  800ad1:	77 16                	ja     800ae9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ad3:	0f be c9             	movsbl %cl,%ecx
  800ad6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800adc:	7d 0f                	jge    800aed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800ade:	83 c2 01             	add    $0x1,%edx
  800ae1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ae5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ae7:	eb bc                	jmp    800aa5 <strtol+0x72>
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	eb 02                	jmp    800aef <strtol+0xbc>
  800aed:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af3:	74 05                	je     800afa <strtol+0xc7>
		*endptr = (char *) s;
  800af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800afa:	f7 d8                	neg    %eax
  800afc:	85 ff                	test   %edi,%edi
  800afe:	0f 44 c3             	cmove  %ebx,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	89 c7                	mov    %eax,%edi
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	b8 03 00 00 00       	mov    $0x3,%eax
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	89 cb                	mov    %ecx,%ebx
  800b5b:	89 cf                	mov    %ecx,%edi
  800b5d:	89 ce                	mov    %ecx,%esi
  800b5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 28                	jle    800b8d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b69:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b70:	00 
  800b71:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800b78:	00 
  800b79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b80:	00 
  800b81:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800b88:	e8 d9 10 00 00       	call   801c66 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8d:	83 c4 2c             	add    $0x2c,%esp
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_yield>:

void
sys_yield(void)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc4:	89 d1                	mov    %edx,%ecx
  800bc6:	89 d3                	mov    %edx,%ebx
  800bc8:	89 d7                	mov    %edx,%edi
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bdc:	be 00 00 00 00       	mov    $0x0,%esi
  800be1:	b8 04 00 00 00       	mov    $0x4,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bef:	89 f7                	mov    %esi,%edi
  800bf1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 28                	jle    800c1f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c02:	00 
  800c03:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c12:	00 
  800c13:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800c1a:	e8 47 10 00 00       	call   801c66 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c1f:	83 c4 2c             	add    $0x2c,%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c30:	b8 05 00 00 00       	mov    $0x5,%eax
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c41:	8b 75 18             	mov    0x18(%ebp),%esi
  800c44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	7e 28                	jle    800c72 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c55:	00 
  800c56:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800c5d:	00 
  800c5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c65:	00 
  800c66:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800c6d:	e8 f4 0f 00 00       	call   801c66 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c72:	83 c4 2c             	add    $0x2c,%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 28                	jle    800cc5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb8:	00 
  800cb9:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800cc0:	e8 a1 0f 00 00       	call   801c66 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc5:	83 c4 2c             	add    $0x2c,%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 df                	mov    %ebx,%edi
  800ce8:	89 de                	mov    %ebx,%esi
  800cea:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7e 28                	jle    800d18 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cfb:	00 
  800cfc:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800d03:	00 
  800d04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0b:	00 
  800d0c:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800d13:	e8 4e 0f 00 00       	call   801c66 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d18:	83 c4 2c             	add    $0x2c,%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 df                	mov    %ebx,%edi
  800d3b:	89 de                	mov    %ebx,%esi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7e 28                	jle    800d6b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d47:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d4e:	00 
  800d4f:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800d56:	00 
  800d57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5e:	00 
  800d5f:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800d66:	e8 fb 0e 00 00       	call   801c66 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d6b:	83 c4 2c             	add    $0x2c,%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 28                	jle    800dbe <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800da1:	00 
  800da2:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800da9:	00 
  800daa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db1:	00 
  800db2:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800db9:	e8 a8 0e 00 00       	call   801c66 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbe:	83 c4 2c             	add    $0x2c,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 28                	jle    800e33 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e16:	00 
  800e17:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e26:	00 
  800e27:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800e2e:	e8 33 0e 00 00       	call   801c66 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e33:	83 c4 2c             	add    $0x2c,%esp
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  800e41:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e48:	75 70                	jne    800eba <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  800e4a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e59:	ee 
  800e5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e61:	e8 6d fd ff ff       	call   800bd3 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	79 1c                	jns    800e86 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  800e6a:	c7 44 24 08 ec 23 80 	movl   $0x8023ec,0x8(%esp)
  800e71:	00 
  800e72:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800e79:	00 
  800e7a:	c7 04 24 47 24 80 00 	movl   $0x802447,(%esp)
  800e81:	e8 e0 0d 00 00       	call   801c66 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  800e86:	c7 44 24 04 c4 0e 80 	movl   $0x800ec4,0x4(%esp)
  800e8d:	00 
  800e8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e95:	e8 d9 fe ff ff       	call   800d73 <sys_env_set_pgfault_upcall>
        if(r < 0)
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	79 1c                	jns    800eba <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  800e9e:	c7 44 24 08 14 24 80 	movl   $0x802414,0x8(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ead:	00 
  800eae:	c7 04 24 47 24 80 00 	movl   $0x802447,(%esp)
  800eb5:	e8 ac 0d 00 00       	call   801c66 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebd:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ec4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ec5:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800eca:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ecc:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  800ecf:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  800ed3:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  800ed7:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  800ed9:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  800edb:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  800edc:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  800edf:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  800ee1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  800ee4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  800ee5:	83 c4 04             	add    $0x4,%esp
    popf;
  800ee8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  800ee9:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  800eea:	c3                   	ret    
  800eeb:	66 90                	xchg   %ax,%ax
  800eed:	66 90                	xchg   %ax,%ax
  800eef:	90                   	nop

00800ef0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	05 00 00 00 30       	add    $0x30000000,%eax
  800efb:	c1 e8 0c             	shr    $0xc,%eax
}
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
  800f06:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f10:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f22:	89 c2                	mov    %eax,%edx
  800f24:	c1 ea 16             	shr    $0x16,%edx
  800f27:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2e:	f6 c2 01             	test   $0x1,%dl
  800f31:	74 11                	je     800f44 <fd_alloc+0x2d>
  800f33:	89 c2                	mov    %eax,%edx
  800f35:	c1 ea 0c             	shr    $0xc,%edx
  800f38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3f:	f6 c2 01             	test   $0x1,%dl
  800f42:	75 09                	jne    800f4d <fd_alloc+0x36>
			*fd_store = fd;
  800f44:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4b:	eb 17                	jmp    800f64 <fd_alloc+0x4d>
  800f4d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f52:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f57:	75 c9                	jne    800f22 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800f59:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f5f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f6c:	83 f8 1f             	cmp    $0x1f,%eax
  800f6f:	77 36                	ja     800fa7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f71:	c1 e0 0c             	shl    $0xc,%eax
  800f74:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f79:	89 c2                	mov    %eax,%edx
  800f7b:	c1 ea 16             	shr    $0x16,%edx
  800f7e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f85:	f6 c2 01             	test   $0x1,%dl
  800f88:	74 24                	je     800fae <fd_lookup+0x48>
  800f8a:	89 c2                	mov    %eax,%edx
  800f8c:	c1 ea 0c             	shr    $0xc,%edx
  800f8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f96:	f6 c2 01             	test   $0x1,%dl
  800f99:	74 1a                	je     800fb5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9e:	89 02                	mov    %eax,(%edx)
	return 0;
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa5:	eb 13                	jmp    800fba <fd_lookup+0x54>
		return -E_INVAL;
  800fa7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fac:	eb 0c                	jmp    800fba <fd_lookup+0x54>
		return -E_INVAL;
  800fae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb3:	eb 05                	jmp    800fba <fd_lookup+0x54>
  800fb5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 18             	sub    $0x18,%esp
  800fc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc5:	ba d4 24 80 00       	mov    $0x8024d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fca:	eb 13                	jmp    800fdf <dev_lookup+0x23>
  800fcc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fcf:	39 08                	cmp    %ecx,(%eax)
  800fd1:	75 0c                	jne    800fdf <dev_lookup+0x23>
			*dev = devtab[i];
  800fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdd:	eb 30                	jmp    80100f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800fdf:	8b 02                	mov    (%edx),%eax
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	75 e7                	jne    800fcc <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fe5:	a1 08 40 80 00       	mov    0x804008,%eax
  800fea:	8b 40 48             	mov    0x48(%eax),%eax
  800fed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff5:	c7 04 24 58 24 80 00 	movl   $0x802458,(%esp)
  800ffc:	e8 95 f1 ff ff       	call   800196 <cprintf>
	*dev = 0;
  801001:	8b 45 0c             	mov    0xc(%ebp),%eax
  801004:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80100a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80100f:	c9                   	leave  
  801010:	c3                   	ret    

00801011 <fd_close>:
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 20             	sub    $0x20,%esp
  801019:	8b 75 08             	mov    0x8(%ebp),%esi
  80101c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80101f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801022:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801026:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80102c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80102f:	89 04 24             	mov    %eax,(%esp)
  801032:	e8 2f ff ff ff       	call   800f66 <fd_lookup>
  801037:	85 c0                	test   %eax,%eax
  801039:	78 05                	js     801040 <fd_close+0x2f>
	    || fd != fd2)
  80103b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80103e:	74 0c                	je     80104c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801040:	84 db                	test   %bl,%bl
  801042:	ba 00 00 00 00       	mov    $0x0,%edx
  801047:	0f 44 c2             	cmove  %edx,%eax
  80104a:	eb 3f                	jmp    80108b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80104c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80104f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801053:	8b 06                	mov    (%esi),%eax
  801055:	89 04 24             	mov    %eax,(%esp)
  801058:	e8 5f ff ff ff       	call   800fbc <dev_lookup>
  80105d:	89 c3                	mov    %eax,%ebx
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 16                	js     801079 <fd_close+0x68>
		if (dev->dev_close)
  801063:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801066:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801069:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80106e:	85 c0                	test   %eax,%eax
  801070:	74 07                	je     801079 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801072:	89 34 24             	mov    %esi,(%esp)
  801075:	ff d0                	call   *%eax
  801077:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801079:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801084:	e8 f1 fb ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801089:	89 d8                	mov    %ebx,%eax
}
  80108b:	83 c4 20             	add    $0x20,%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <close>:

int
close(int fdnum)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801098:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a2:	89 04 24             	mov    %eax,(%esp)
  8010a5:	e8 bc fe ff ff       	call   800f66 <fd_lookup>
  8010aa:	89 c2                	mov    %eax,%edx
  8010ac:	85 d2                	test   %edx,%edx
  8010ae:	78 13                	js     8010c3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8010b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b7:	00 
  8010b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010bb:	89 04 24             	mov    %eax,(%esp)
  8010be:	e8 4e ff ff ff       	call   801011 <fd_close>
}
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <close_all>:

void
close_all(void)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010d1:	89 1c 24             	mov    %ebx,(%esp)
  8010d4:	e8 b9 ff ff ff       	call   801092 <close>
	for (i = 0; i < MAXFD; i++)
  8010d9:	83 c3 01             	add    $0x1,%ebx
  8010dc:	83 fb 20             	cmp    $0x20,%ebx
  8010df:	75 f0                	jne    8010d1 <close_all+0xc>
}
  8010e1:	83 c4 14             	add    $0x14,%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	57                   	push   %edi
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	89 04 24             	mov    %eax,(%esp)
  8010fd:	e8 64 fe ff ff       	call   800f66 <fd_lookup>
  801102:	89 c2                	mov    %eax,%edx
  801104:	85 d2                	test   %edx,%edx
  801106:	0f 88 e1 00 00 00    	js     8011ed <dup+0x106>
		return r;
	close(newfdnum);
  80110c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110f:	89 04 24             	mov    %eax,(%esp)
  801112:	e8 7b ff ff ff       	call   801092 <close>

	newfd = INDEX2FD(newfdnum);
  801117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80111a:	c1 e3 0c             	shl    $0xc,%ebx
  80111d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801123:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801126:	89 04 24             	mov    %eax,(%esp)
  801129:	e8 d2 fd ff ff       	call   800f00 <fd2data>
  80112e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801130:	89 1c 24             	mov    %ebx,(%esp)
  801133:	e8 c8 fd ff ff       	call   800f00 <fd2data>
  801138:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80113a:	89 f0                	mov    %esi,%eax
  80113c:	c1 e8 16             	shr    $0x16,%eax
  80113f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801146:	a8 01                	test   $0x1,%al
  801148:	74 43                	je     80118d <dup+0xa6>
  80114a:	89 f0                	mov    %esi,%eax
  80114c:	c1 e8 0c             	shr    $0xc,%eax
  80114f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801156:	f6 c2 01             	test   $0x1,%dl
  801159:	74 32                	je     80118d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80115b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801162:	25 07 0e 00 00       	and    $0xe07,%eax
  801167:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801176:	00 
  801177:	89 74 24 04          	mov    %esi,0x4(%esp)
  80117b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801182:	e8 a0 fa ff ff       	call   800c27 <sys_page_map>
  801187:	89 c6                	mov    %eax,%esi
  801189:	85 c0                	test   %eax,%eax
  80118b:	78 3e                	js     8011cb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80118d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801190:	89 c2                	mov    %eax,%edx
  801192:	c1 ea 0c             	shr    $0xc,%edx
  801195:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011a2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011b1:	00 
  8011b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011bd:	e8 65 fa ff ff       	call   800c27 <sys_page_map>
  8011c2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8011c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011c7:	85 f6                	test   %esi,%esi
  8011c9:	79 22                	jns    8011ed <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8011cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d6:	e8 9f fa ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e6:	e8 8f fa ff ff       	call   800c7a <sys_page_unmap>
	return r;
  8011eb:	89 f0                	mov    %esi,%eax
}
  8011ed:	83 c4 3c             	add    $0x3c,%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 24             	sub    $0x24,%esp
  8011fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801202:	89 44 24 04          	mov    %eax,0x4(%esp)
  801206:	89 1c 24             	mov    %ebx,(%esp)
  801209:	e8 58 fd ff ff       	call   800f66 <fd_lookup>
  80120e:	89 c2                	mov    %eax,%edx
  801210:	85 d2                	test   %edx,%edx
  801212:	78 6d                	js     801281 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801214:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121e:	8b 00                	mov    (%eax),%eax
  801220:	89 04 24             	mov    %eax,(%esp)
  801223:	e8 94 fd ff ff       	call   800fbc <dev_lookup>
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 55                	js     801281 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80122c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122f:	8b 50 08             	mov    0x8(%eax),%edx
  801232:	83 e2 03             	and    $0x3,%edx
  801235:	83 fa 01             	cmp    $0x1,%edx
  801238:	75 23                	jne    80125d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80123a:	a1 08 40 80 00       	mov    0x804008,%eax
  80123f:	8b 40 48             	mov    0x48(%eax),%eax
  801242:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124a:	c7 04 24 99 24 80 00 	movl   $0x802499,(%esp)
  801251:	e8 40 ef ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125b:	eb 24                	jmp    801281 <read+0x8c>
	}
	if (!dev->dev_read)
  80125d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801260:	8b 52 08             	mov    0x8(%edx),%edx
  801263:	85 d2                	test   %edx,%edx
  801265:	74 15                	je     80127c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801267:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80126a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801271:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801275:	89 04 24             	mov    %eax,(%esp)
  801278:	ff d2                	call   *%edx
  80127a:	eb 05                	jmp    801281 <read+0x8c>
		return -E_NOT_SUPP;
  80127c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801281:	83 c4 24             	add    $0x24,%esp
  801284:	5b                   	pop    %ebx
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	57                   	push   %edi
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 1c             	sub    $0x1c,%esp
  801290:	8b 7d 08             	mov    0x8(%ebp),%edi
  801293:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801296:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129b:	eb 23                	jmp    8012c0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129d:	89 f0                	mov    %esi,%eax
  80129f:	29 d8                	sub    %ebx,%eax
  8012a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a5:	89 d8                	mov    %ebx,%eax
  8012a7:	03 45 0c             	add    0xc(%ebp),%eax
  8012aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ae:	89 3c 24             	mov    %edi,(%esp)
  8012b1:	e8 3f ff ff ff       	call   8011f5 <read>
		if (m < 0)
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 10                	js     8012ca <readn+0x43>
			return m;
		if (m == 0)
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	74 0a                	je     8012c8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8012be:	01 c3                	add    %eax,%ebx
  8012c0:	39 f3                	cmp    %esi,%ebx
  8012c2:	72 d9                	jb     80129d <readn+0x16>
  8012c4:	89 d8                	mov    %ebx,%eax
  8012c6:	eb 02                	jmp    8012ca <readn+0x43>
  8012c8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012ca:	83 c4 1c             	add    $0x1c,%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 24             	sub    $0x24,%esp
  8012d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e3:	89 1c 24             	mov    %ebx,(%esp)
  8012e6:	e8 7b fc ff ff       	call   800f66 <fd_lookup>
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	85 d2                	test   %edx,%edx
  8012ef:	78 68                	js     801359 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fb:	8b 00                	mov    (%eax),%eax
  8012fd:	89 04 24             	mov    %eax,(%esp)
  801300:	e8 b7 fc ff ff       	call   800fbc <dev_lookup>
  801305:	85 c0                	test   %eax,%eax
  801307:	78 50                	js     801359 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801310:	75 23                	jne    801335 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801312:	a1 08 40 80 00       	mov    0x804008,%eax
  801317:	8b 40 48             	mov    0x48(%eax),%eax
  80131a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801322:	c7 04 24 b5 24 80 00 	movl   $0x8024b5,(%esp)
  801329:	e8 68 ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  80132e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801333:	eb 24                	jmp    801359 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801335:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801338:	8b 52 0c             	mov    0xc(%edx),%edx
  80133b:	85 d2                	test   %edx,%edx
  80133d:	74 15                	je     801354 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801342:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801346:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801349:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80134d:	89 04 24             	mov    %eax,(%esp)
  801350:	ff d2                	call   *%edx
  801352:	eb 05                	jmp    801359 <write+0x87>
		return -E_NOT_SUPP;
  801354:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801359:	83 c4 24             	add    $0x24,%esp
  80135c:	5b                   	pop    %ebx
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <seek>:

int
seek(int fdnum, off_t offset)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801365:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136c:	8b 45 08             	mov    0x8(%ebp),%eax
  80136f:	89 04 24             	mov    %eax,(%esp)
  801372:	e8 ef fb ff ff       	call   800f66 <fd_lookup>
  801377:	85 c0                	test   %eax,%eax
  801379:	78 0e                	js     801389 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80137b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80137e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801381:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801384:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	53                   	push   %ebx
  80138f:	83 ec 24             	sub    $0x24,%esp
  801392:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801395:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139c:	89 1c 24             	mov    %ebx,(%esp)
  80139f:	e8 c2 fb ff ff       	call   800f66 <fd_lookup>
  8013a4:	89 c2                	mov    %eax,%edx
  8013a6:	85 d2                	test   %edx,%edx
  8013a8:	78 61                	js     80140b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b4:	8b 00                	mov    (%eax),%eax
  8013b6:	89 04 24             	mov    %eax,(%esp)
  8013b9:	e8 fe fb ff ff       	call   800fbc <dev_lookup>
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 49                	js     80140b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c9:	75 23                	jne    8013ee <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013cb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013d0:	8b 40 48             	mov    0x48(%eax),%eax
  8013d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013db:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  8013e2:	e8 af ed ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8013e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ec:	eb 1d                	jmp    80140b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8013ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f1:	8b 52 18             	mov    0x18(%edx),%edx
  8013f4:	85 d2                	test   %edx,%edx
  8013f6:	74 0e                	je     801406 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ff:	89 04 24             	mov    %eax,(%esp)
  801402:	ff d2                	call   *%edx
  801404:	eb 05                	jmp    80140b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801406:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80140b:	83 c4 24             	add    $0x24,%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	53                   	push   %ebx
  801415:	83 ec 24             	sub    $0x24,%esp
  801418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	89 04 24             	mov    %eax,(%esp)
  801428:	e8 39 fb ff ff       	call   800f66 <fd_lookup>
  80142d:	89 c2                	mov    %eax,%edx
  80142f:	85 d2                	test   %edx,%edx
  801431:	78 52                	js     801485 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801433:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801436:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143d:	8b 00                	mov    (%eax),%eax
  80143f:	89 04 24             	mov    %eax,(%esp)
  801442:	e8 75 fb ff ff       	call   800fbc <dev_lookup>
  801447:	85 c0                	test   %eax,%eax
  801449:	78 3a                	js     801485 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80144b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801452:	74 2c                	je     801480 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801454:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801457:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80145e:	00 00 00 
	stat->st_isdir = 0;
  801461:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801468:	00 00 00 
	stat->st_dev = dev;
  80146b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801471:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801475:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801478:	89 14 24             	mov    %edx,(%esp)
  80147b:	ff 50 14             	call   *0x14(%eax)
  80147e:	eb 05                	jmp    801485 <fstat+0x74>
		return -E_NOT_SUPP;
  801480:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801485:	83 c4 24             	add    $0x24,%esp
  801488:	5b                   	pop    %ebx
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	56                   	push   %esi
  80148f:	53                   	push   %ebx
  801490:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801493:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80149a:	00 
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	89 04 24             	mov    %eax,(%esp)
  8014a1:	e8 fb 01 00 00       	call   8016a1 <open>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	85 db                	test   %ebx,%ebx
  8014aa:	78 1b                	js     8014c7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b3:	89 1c 24             	mov    %ebx,(%esp)
  8014b6:	e8 56 ff ff ff       	call   801411 <fstat>
  8014bb:	89 c6                	mov    %eax,%esi
	close(fd);
  8014bd:	89 1c 24             	mov    %ebx,(%esp)
  8014c0:	e8 cd fb ff ff       	call   801092 <close>
	return r;
  8014c5:	89 f0                	mov    %esi,%eax
}
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	5b                   	pop    %ebx
  8014cb:	5e                   	pop    %esi
  8014cc:	5d                   	pop    %ebp
  8014cd:	c3                   	ret    

008014ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 10             	sub    $0x10,%esp
  8014d6:	89 c6                	mov    %eax,%esi
  8014d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014da:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014e1:	75 11                	jne    8014f4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014ea:	e8 a0 08 00 00       	call   801d8f <ipc_find_env>
  8014ef:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014f4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014fb:	00 
  8014fc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801503:	00 
  801504:	89 74 24 04          	mov    %esi,0x4(%esp)
  801508:	a1 04 40 80 00       	mov    0x804004,%eax
  80150d:	89 04 24             	mov    %eax,(%esp)
  801510:	e8 13 08 00 00       	call   801d28 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801515:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80151c:	00 
  80151d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801521:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801528:	e8 93 07 00 00       	call   801cc0 <ipc_recv>
}
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	8b 40 0c             	mov    0xc(%eax),%eax
  801540:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801545:	8b 45 0c             	mov    0xc(%ebp),%eax
  801548:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80154d:	ba 00 00 00 00       	mov    $0x0,%edx
  801552:	b8 02 00 00 00       	mov    $0x2,%eax
  801557:	e8 72 ff ff ff       	call   8014ce <fsipc>
}
  80155c:	c9                   	leave  
  80155d:	c3                   	ret    

0080155e <devfile_flush>:
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801564:	8b 45 08             	mov    0x8(%ebp),%eax
  801567:	8b 40 0c             	mov    0xc(%eax),%eax
  80156a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	b8 06 00 00 00       	mov    $0x6,%eax
  801579:	e8 50 ff ff ff       	call   8014ce <fsipc>
}
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <devfile_stat>:
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	53                   	push   %ebx
  801584:	83 ec 14             	sub    $0x14,%esp
  801587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80158a:	8b 45 08             	mov    0x8(%ebp),%eax
  80158d:	8b 40 0c             	mov    0xc(%eax),%eax
  801590:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801595:	ba 00 00 00 00       	mov    $0x0,%edx
  80159a:	b8 05 00 00 00       	mov    $0x5,%eax
  80159f:	e8 2a ff ff ff       	call   8014ce <fsipc>
  8015a4:	89 c2                	mov    %eax,%edx
  8015a6:	85 d2                	test   %edx,%edx
  8015a8:	78 2b                	js     8015d5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015aa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015b1:	00 
  8015b2:	89 1c 24             	mov    %ebx,(%esp)
  8015b5:	e8 fd f1 ff ff       	call   8007b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ba:	a1 80 50 80 00       	mov    0x805080,%eax
  8015bf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015c5:	a1 84 50 80 00       	mov    0x805084,%eax
  8015ca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d5:	83 c4 14             	add    $0x14,%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <devfile_write>:
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  8015e1:	c7 44 24 08 e4 24 80 	movl   $0x8024e4,0x8(%esp)
  8015e8:	00 
  8015e9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8015f0:	00 
  8015f1:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  8015f8:	e8 69 06 00 00       	call   801c66 <_panic>

008015fd <devfile_read>:
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	56                   	push   %esi
  801601:	53                   	push   %ebx
  801602:	83 ec 10             	sub    $0x10,%esp
  801605:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801608:	8b 45 08             	mov    0x8(%ebp),%eax
  80160b:	8b 40 0c             	mov    0xc(%eax),%eax
  80160e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801613:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801619:	ba 00 00 00 00       	mov    $0x0,%edx
  80161e:	b8 03 00 00 00       	mov    $0x3,%eax
  801623:	e8 a6 fe ff ff       	call   8014ce <fsipc>
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 6a                	js     801698 <devfile_read+0x9b>
	assert(r <= n);
  80162e:	39 c6                	cmp    %eax,%esi
  801630:	73 24                	jae    801656 <devfile_read+0x59>
  801632:	c7 44 24 0c 0d 25 80 	movl   $0x80250d,0xc(%esp)
  801639:	00 
  80163a:	c7 44 24 08 14 25 80 	movl   $0x802514,0x8(%esp)
  801641:	00 
  801642:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801649:	00 
  80164a:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  801651:	e8 10 06 00 00       	call   801c66 <_panic>
	assert(r <= PGSIZE);
  801656:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80165b:	7e 24                	jle    801681 <devfile_read+0x84>
  80165d:	c7 44 24 0c 29 25 80 	movl   $0x802529,0xc(%esp)
  801664:	00 
  801665:	c7 44 24 08 14 25 80 	movl   $0x802514,0x8(%esp)
  80166c:	00 
  80166d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801674:	00 
  801675:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  80167c:	e8 e5 05 00 00       	call   801c66 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801681:	89 44 24 08          	mov    %eax,0x8(%esp)
  801685:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80168c:	00 
  80168d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801690:	89 04 24             	mov    %eax,(%esp)
  801693:	e8 bc f2 ff ff       	call   800954 <memmove>
}
  801698:	89 d8                	mov    %ebx,%eax
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <open>:
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 24             	sub    $0x24,%esp
  8016a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8016ab:	89 1c 24             	mov    %ebx,(%esp)
  8016ae:	e8 cd f0 ff ff       	call   800780 <strlen>
  8016b3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016b8:	7f 60                	jg     80171a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8016ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 52 f8 ff ff       	call   800f17 <fd_alloc>
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	85 d2                	test   %edx,%edx
  8016c9:	78 54                	js     80171f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8016cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016cf:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016d6:	e8 dc f0 ff ff       	call   8007b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016de:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8016eb:	e8 de fd ff ff       	call   8014ce <fsipc>
  8016f0:	89 c3                	mov    %eax,%ebx
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	79 17                	jns    80170d <open+0x6c>
		fd_close(fd, 0);
  8016f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016fd:	00 
  8016fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801701:	89 04 24             	mov    %eax,(%esp)
  801704:	e8 08 f9 ff ff       	call   801011 <fd_close>
		return r;
  801709:	89 d8                	mov    %ebx,%eax
  80170b:	eb 12                	jmp    80171f <open+0x7e>
	return fd2num(fd);
  80170d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801710:	89 04 24             	mov    %eax,(%esp)
  801713:	e8 d8 f7 ff ff       	call   800ef0 <fd2num>
  801718:	eb 05                	jmp    80171f <open+0x7e>
		return -E_BAD_PATH;
  80171a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80171f:	83 c4 24             	add    $0x24,%esp
  801722:	5b                   	pop    %ebx
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	b8 08 00 00 00       	mov    $0x8,%eax
  801735:	e8 94 fd ff ff       	call   8014ce <fsipc>
}
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	83 ec 10             	sub    $0x10,%esp
  801744:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801747:	8b 45 08             	mov    0x8(%ebp),%eax
  80174a:	89 04 24             	mov    %eax,(%esp)
  80174d:	e8 ae f7 ff ff       	call   800f00 <fd2data>
  801752:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801754:	c7 44 24 04 35 25 80 	movl   $0x802535,0x4(%esp)
  80175b:	00 
  80175c:	89 1c 24             	mov    %ebx,(%esp)
  80175f:	e8 53 f0 ff ff       	call   8007b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801764:	8b 46 04             	mov    0x4(%esi),%eax
  801767:	2b 06                	sub    (%esi),%eax
  801769:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80176f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801776:	00 00 00 
	stat->st_dev = &devpipe;
  801779:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801780:	30 80 00 
	return 0;
}
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	53                   	push   %ebx
  801793:	83 ec 14             	sub    $0x14,%esp
  801796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801799:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80179d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a4:	e8 d1 f4 ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017a9:	89 1c 24             	mov    %ebx,(%esp)
  8017ac:	e8 4f f7 ff ff       	call   800f00 <fd2data>
  8017b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bc:	e8 b9 f4 ff ff       	call   800c7a <sys_page_unmap>
}
  8017c1:	83 c4 14             	add    $0x14,%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <_pipeisclosed>:
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	57                   	push   %edi
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 2c             	sub    $0x2c,%esp
  8017d0:	89 c6                	mov    %eax,%esi
  8017d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8017d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8017da:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017dd:	89 34 24             	mov    %esi,(%esp)
  8017e0:	e8 e2 05 00 00       	call   801dc7 <pageref>
  8017e5:	89 c7                	mov    %eax,%edi
  8017e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ea:	89 04 24             	mov    %eax,(%esp)
  8017ed:	e8 d5 05 00 00       	call   801dc7 <pageref>
  8017f2:	39 c7                	cmp    %eax,%edi
  8017f4:	0f 94 c2             	sete   %dl
  8017f7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8017fa:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801800:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801803:	39 fb                	cmp    %edi,%ebx
  801805:	74 21                	je     801828 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801807:	84 d2                	test   %dl,%dl
  801809:	74 ca                	je     8017d5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80180b:	8b 51 58             	mov    0x58(%ecx),%edx
  80180e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801812:	89 54 24 08          	mov    %edx,0x8(%esp)
  801816:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80181a:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  801821:	e8 70 e9 ff ff       	call   800196 <cprintf>
  801826:	eb ad                	jmp    8017d5 <_pipeisclosed+0xe>
}
  801828:	83 c4 2c             	add    $0x2c,%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	5f                   	pop    %edi
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <devpipe_write>:
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	57                   	push   %edi
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	83 ec 1c             	sub    $0x1c,%esp
  801839:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80183c:	89 34 24             	mov    %esi,(%esp)
  80183f:	e8 bc f6 ff ff       	call   800f00 <fd2data>
  801844:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801846:	bf 00 00 00 00       	mov    $0x0,%edi
  80184b:	eb 45                	jmp    801892 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  80184d:	89 da                	mov    %ebx,%edx
  80184f:	89 f0                	mov    %esi,%eax
  801851:	e8 71 ff ff ff       	call   8017c7 <_pipeisclosed>
  801856:	85 c0                	test   %eax,%eax
  801858:	75 41                	jne    80189b <devpipe_write+0x6b>
			sys_yield();
  80185a:	e8 55 f3 ff ff       	call   800bb4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80185f:	8b 43 04             	mov    0x4(%ebx),%eax
  801862:	8b 0b                	mov    (%ebx),%ecx
  801864:	8d 51 20             	lea    0x20(%ecx),%edx
  801867:	39 d0                	cmp    %edx,%eax
  801869:	73 e2                	jae    80184d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80186b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801872:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801875:	99                   	cltd   
  801876:	c1 ea 1b             	shr    $0x1b,%edx
  801879:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80187c:	83 e1 1f             	and    $0x1f,%ecx
  80187f:	29 d1                	sub    %edx,%ecx
  801881:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801885:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801889:	83 c0 01             	add    $0x1,%eax
  80188c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80188f:	83 c7 01             	add    $0x1,%edi
  801892:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801895:	75 c8                	jne    80185f <devpipe_write+0x2f>
	return i;
  801897:	89 f8                	mov    %edi,%eax
  801899:	eb 05                	jmp    8018a0 <devpipe_write+0x70>
				return 0;
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a0:	83 c4 1c             	add    $0x1c,%esp
  8018a3:	5b                   	pop    %ebx
  8018a4:	5e                   	pop    %esi
  8018a5:	5f                   	pop    %edi
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <devpipe_read>:
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 1c             	sub    $0x1c,%esp
  8018b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018b4:	89 3c 24             	mov    %edi,(%esp)
  8018b7:	e8 44 f6 ff ff       	call   800f00 <fd2data>
  8018bc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018be:	be 00 00 00 00       	mov    $0x0,%esi
  8018c3:	eb 3d                	jmp    801902 <devpipe_read+0x5a>
			if (i > 0)
  8018c5:	85 f6                	test   %esi,%esi
  8018c7:	74 04                	je     8018cd <devpipe_read+0x25>
				return i;
  8018c9:	89 f0                	mov    %esi,%eax
  8018cb:	eb 43                	jmp    801910 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  8018cd:	89 da                	mov    %ebx,%edx
  8018cf:	89 f8                	mov    %edi,%eax
  8018d1:	e8 f1 fe ff ff       	call   8017c7 <_pipeisclosed>
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	75 31                	jne    80190b <devpipe_read+0x63>
			sys_yield();
  8018da:	e8 d5 f2 ff ff       	call   800bb4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8018df:	8b 03                	mov    (%ebx),%eax
  8018e1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018e4:	74 df                	je     8018c5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018e6:	99                   	cltd   
  8018e7:	c1 ea 1b             	shr    $0x1b,%edx
  8018ea:	01 d0                	add    %edx,%eax
  8018ec:	83 e0 1f             	and    $0x1f,%eax
  8018ef:	29 d0                	sub    %edx,%eax
  8018f1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8018f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8018fc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8018ff:	83 c6 01             	add    $0x1,%esi
  801902:	3b 75 10             	cmp    0x10(%ebp),%esi
  801905:	75 d8                	jne    8018df <devpipe_read+0x37>
	return i;
  801907:	89 f0                	mov    %esi,%eax
  801909:	eb 05                	jmp    801910 <devpipe_read+0x68>
				return 0;
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801910:	83 c4 1c             	add    $0x1c,%esp
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	5f                   	pop    %edi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <pipe>:
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	56                   	push   %esi
  80191c:	53                   	push   %ebx
  80191d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801920:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801923:	89 04 24             	mov    %eax,(%esp)
  801926:	e8 ec f5 ff ff       	call   800f17 <fd_alloc>
  80192b:	89 c2                	mov    %eax,%edx
  80192d:	85 d2                	test   %edx,%edx
  80192f:	0f 88 4d 01 00 00    	js     801a82 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801935:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80193c:	00 
  80193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801940:	89 44 24 04          	mov    %eax,0x4(%esp)
  801944:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194b:	e8 83 f2 ff ff       	call   800bd3 <sys_page_alloc>
  801950:	89 c2                	mov    %eax,%edx
  801952:	85 d2                	test   %edx,%edx
  801954:	0f 88 28 01 00 00    	js     801a82 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  80195a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195d:	89 04 24             	mov    %eax,(%esp)
  801960:	e8 b2 f5 ff ff       	call   800f17 <fd_alloc>
  801965:	89 c3                	mov    %eax,%ebx
  801967:	85 c0                	test   %eax,%eax
  801969:	0f 88 fe 00 00 00    	js     801a6d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80196f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801976:	00 
  801977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801985:	e8 49 f2 ff ff       	call   800bd3 <sys_page_alloc>
  80198a:	89 c3                	mov    %eax,%ebx
  80198c:	85 c0                	test   %eax,%eax
  80198e:	0f 88 d9 00 00 00    	js     801a6d <pipe+0x155>
	va = fd2data(fd0);
  801994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801997:	89 04 24             	mov    %eax,(%esp)
  80199a:	e8 61 f5 ff ff       	call   800f00 <fd2data>
  80199f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019a8:	00 
  8019a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b4:	e8 1a f2 ff ff       	call   800bd3 <sys_page_alloc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	0f 88 97 00 00 00    	js     801a5a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c6:	89 04 24             	mov    %eax,(%esp)
  8019c9:	e8 32 f5 ff ff       	call   800f00 <fd2data>
  8019ce:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019d5:	00 
  8019d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019e1:	00 
  8019e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ed:	e8 35 f2 ff ff       	call   800c27 <sys_page_map>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 52                	js     801a4a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  8019f8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a01:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801a0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a16:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	89 04 24             	mov    %eax,(%esp)
  801a28:	e8 c3 f4 ff ff       	call   800ef0 <fd2num>
  801a2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a30:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a35:	89 04 24             	mov    %eax,(%esp)
  801a38:	e8 b3 f4 ff ff       	call   800ef0 <fd2num>
  801a3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a40:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
  801a48:	eb 38                	jmp    801a82 <pipe+0x16a>
	sys_page_unmap(0, va);
  801a4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a55:	e8 20 f2 ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a68:	e8 0d f2 ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7b:	e8 fa f1 ff ff       	call   800c7a <sys_page_unmap>
  801a80:	89 d8                	mov    %ebx,%eax
}
  801a82:	83 c4 30             	add    $0x30,%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <pipeisclosed>:
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	89 04 24             	mov    %eax,(%esp)
  801a9c:	e8 c5 f4 ff ff       	call   800f66 <fd_lookup>
  801aa1:	89 c2                	mov    %eax,%edx
  801aa3:	85 d2                	test   %edx,%edx
  801aa5:	78 15                	js     801abc <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	e8 4e f4 ff ff       	call   800f00 <fd2data>
	return _pipeisclosed(fd, p);
  801ab2:	89 c2                	mov    %eax,%edx
  801ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab7:	e8 0b fd ff ff       	call   8017c7 <_pipeisclosed>
}
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    
  801abe:	66 90                	xchg   %ax,%ax

00801ac0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ad0:	c7 44 24 04 54 25 80 	movl   $0x802554,0x4(%esp)
  801ad7:	00 
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	89 04 24             	mov    %eax,(%esp)
  801ade:	e8 d4 ec ff ff       	call   8007b7 <strcpy>
	return 0;
}
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <devcons_write>:
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	57                   	push   %edi
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801af6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801afb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b01:	eb 31                	jmp    801b34 <devcons_write+0x4a>
		m = n - tot;
  801b03:	8b 75 10             	mov    0x10(%ebp),%esi
  801b06:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b08:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801b0b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b10:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b13:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b17:	03 45 0c             	add    0xc(%ebp),%eax
  801b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1e:	89 3c 24             	mov    %edi,(%esp)
  801b21:	e8 2e ee ff ff       	call   800954 <memmove>
		sys_cputs(buf, m);
  801b26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b2a:	89 3c 24             	mov    %edi,(%esp)
  801b2d:	e8 d4 ef ff ff       	call   800b06 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b32:	01 f3                	add    %esi,%ebx
  801b34:	89 d8                	mov    %ebx,%eax
  801b36:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b39:	72 c8                	jb     801b03 <devcons_write+0x19>
}
  801b3b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	5f                   	pop    %edi
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    

00801b46 <devcons_read>:
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b55:	75 07                	jne    801b5e <devcons_read+0x18>
  801b57:	eb 2a                	jmp    801b83 <devcons_read+0x3d>
		sys_yield();
  801b59:	e8 56 f0 ff ff       	call   800bb4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801b5e:	66 90                	xchg   %ax,%ax
  801b60:	e8 bf ef ff ff       	call   800b24 <sys_cgetc>
  801b65:	85 c0                	test   %eax,%eax
  801b67:	74 f0                	je     801b59 <devcons_read+0x13>
	if (c < 0)
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 16                	js     801b83 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801b6d:	83 f8 04             	cmp    $0x4,%eax
  801b70:	74 0c                	je     801b7e <devcons_read+0x38>
	*(char*)vbuf = c;
  801b72:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b75:	88 02                	mov    %al,(%edx)
	return 1;
  801b77:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7c:	eb 05                	jmp    801b83 <devcons_read+0x3d>
		return 0;
  801b7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <cputchar>:
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b91:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b98:	00 
  801b99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b9c:	89 04 24             	mov    %eax,(%esp)
  801b9f:	e8 62 ef ff ff       	call   800b06 <sys_cputs>
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <getchar>:
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801bac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801bb3:	00 
  801bb4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc2:	e8 2e f6 ff ff       	call   8011f5 <read>
	if (r < 0)
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 0f                	js     801bda <getchar+0x34>
	if (r < 1)
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	7e 06                	jle    801bd5 <getchar+0x2f>
	return c;
  801bcf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bd3:	eb 05                	jmp    801bda <getchar+0x34>
		return -E_EOF;
  801bd5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    

00801bdc <iscons>:
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 72 f3 ff ff       	call   800f66 <fd_lookup>
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 11                	js     801c09 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c01:	39 10                	cmp    %edx,(%eax)
  801c03:	0f 94 c0             	sete   %al
  801c06:	0f b6 c0             	movzbl %al,%eax
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <opencons>:
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c14:	89 04 24             	mov    %eax,(%esp)
  801c17:	e8 fb f2 ff ff       	call   800f17 <fd_alloc>
		return r;
  801c1c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	78 40                	js     801c62 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c29:	00 
  801c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c38:	e8 96 ef ff ff       	call   800bd3 <sys_page_alloc>
		return r;
  801c3d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 1f                	js     801c62 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801c43:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c51:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c58:	89 04 24             	mov    %eax,(%esp)
  801c5b:	e8 90 f2 ff ff       	call   800ef0 <fd2num>
  801c60:	89 c2                	mov    %eax,%edx
}
  801c62:	89 d0                	mov    %edx,%eax
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	56                   	push   %esi
  801c6a:	53                   	push   %ebx
  801c6b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c6e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c71:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801c77:	e8 19 ef ff ff       	call   800b95 <sys_getenvid>
  801c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c83:	8b 55 08             	mov    0x8(%ebp),%edx
  801c86:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c8a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c92:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  801c99:	e8 f8 e4 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca5:	89 04 24             	mov    %eax,(%esp)
  801ca8:	e8 88 e4 ff ff       	call   800135 <vcprintf>
	cprintf("\n");
  801cad:	c7 04 24 4d 25 80 00 	movl   $0x80254d,(%esp)
  801cb4:	e8 dd e4 ff ff       	call   800196 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cb9:	cc                   	int3   
  801cba:	eb fd                	jmp    801cb9 <_panic+0x53>
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 10             	sub    $0x10,%esp
  801cc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801cd1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801cd3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801cd8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801cdb:	89 04 24             	mov    %eax,(%esp)
  801cde:	e8 06 f1 ff ff       	call   800de9 <sys_ipc_recv>
    if(r < 0){
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	79 16                	jns    801cfd <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801ce7:	85 f6                	test   %esi,%esi
  801ce9:	74 06                	je     801cf1 <ipc_recv+0x31>
            *from_env_store = 0;
  801ceb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801cf1:	85 db                	test   %ebx,%ebx
  801cf3:	74 2c                	je     801d21 <ipc_recv+0x61>
            *perm_store = 0;
  801cf5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cfb:	eb 24                	jmp    801d21 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801cfd:	85 f6                	test   %esi,%esi
  801cff:	74 0a                	je     801d0b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801d01:	a1 08 40 80 00       	mov    0x804008,%eax
  801d06:	8b 40 74             	mov    0x74(%eax),%eax
  801d09:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801d0b:	85 db                	test   %ebx,%ebx
  801d0d:	74 0a                	je     801d19 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801d0f:	a1 08 40 80 00       	mov    0x804008,%eax
  801d14:	8b 40 78             	mov    0x78(%eax),%eax
  801d17:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d19:	a1 08 40 80 00       	mov    0x804008,%eax
  801d1e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	57                   	push   %edi
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 1c             	sub    $0x1c,%esp
  801d31:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d34:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801d3a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801d3c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801d41:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801d44:	8b 45 14             	mov    0x14(%ebp),%eax
  801d47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d53:	89 3c 24             	mov    %edi,(%esp)
  801d56:	e8 6b f0 ff ff       	call   800dc6 <sys_ipc_try_send>
        if(r == 0){
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	74 28                	je     801d87 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801d5f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d62:	74 1c                	je     801d80 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801d64:	c7 44 24 08 84 25 80 	movl   $0x802584,0x8(%esp)
  801d6b:	00 
  801d6c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801d73:	00 
  801d74:	c7 04 24 9b 25 80 00 	movl   $0x80259b,(%esp)
  801d7b:	e8 e6 fe ff ff       	call   801c66 <_panic>
        }
        sys_yield();
  801d80:	e8 2f ee ff ff       	call   800bb4 <sys_yield>
    }
  801d85:	eb bd                	jmp    801d44 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801d87:	83 c4 1c             	add    $0x1c,%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5f                   	pop    %edi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d9a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d9d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801da3:	8b 52 50             	mov    0x50(%edx),%edx
  801da6:	39 ca                	cmp    %ecx,%edx
  801da8:	75 0d                	jne    801db7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801daa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dad:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801db2:	8b 40 40             	mov    0x40(%eax),%eax
  801db5:	eb 0e                	jmp    801dc5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801db7:	83 c0 01             	add    $0x1,%eax
  801dba:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dbf:	75 d9                	jne    801d9a <ipc_find_env+0xb>
	return 0;
  801dc1:	66 b8 00 00          	mov    $0x0,%ax
}
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dcd:	89 d0                	mov    %edx,%eax
  801dcf:	c1 e8 16             	shr    $0x16,%eax
  801dd2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801dde:	f6 c1 01             	test   $0x1,%cl
  801de1:	74 1d                	je     801e00 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801de3:	c1 ea 0c             	shr    $0xc,%edx
  801de6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ded:	f6 c2 01             	test   $0x1,%dl
  801df0:	74 0e                	je     801e00 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801df2:	c1 ea 0c             	shr    $0xc,%edx
  801df5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dfc:	ef 
  801dfd:	0f b7 c0             	movzwl %ax,%eax
}
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	66 90                	xchg   %ax,%ax
  801e04:	66 90                	xchg   %ax,%ax
  801e06:	66 90                	xchg   %ax,%ax
  801e08:	66 90                	xchg   %ax,%ax
  801e0a:	66 90                	xchg   %ax,%ax
  801e0c:	66 90                	xchg   %ax,%ax
  801e0e:	66 90                	xchg   %ax,%ax

00801e10 <__udivdi3>:
  801e10:	55                   	push   %ebp
  801e11:	57                   	push   %edi
  801e12:	56                   	push   %esi
  801e13:	83 ec 0c             	sub    $0xc,%esp
  801e16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e1a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e1e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e22:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e26:	85 c0                	test   %eax,%eax
  801e28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e2c:	89 ea                	mov    %ebp,%edx
  801e2e:	89 0c 24             	mov    %ecx,(%esp)
  801e31:	75 2d                	jne    801e60 <__udivdi3+0x50>
  801e33:	39 e9                	cmp    %ebp,%ecx
  801e35:	77 61                	ja     801e98 <__udivdi3+0x88>
  801e37:	85 c9                	test   %ecx,%ecx
  801e39:	89 ce                	mov    %ecx,%esi
  801e3b:	75 0b                	jne    801e48 <__udivdi3+0x38>
  801e3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e42:	31 d2                	xor    %edx,%edx
  801e44:	f7 f1                	div    %ecx
  801e46:	89 c6                	mov    %eax,%esi
  801e48:	31 d2                	xor    %edx,%edx
  801e4a:	89 e8                	mov    %ebp,%eax
  801e4c:	f7 f6                	div    %esi
  801e4e:	89 c5                	mov    %eax,%ebp
  801e50:	89 f8                	mov    %edi,%eax
  801e52:	f7 f6                	div    %esi
  801e54:	89 ea                	mov    %ebp,%edx
  801e56:	83 c4 0c             	add    $0xc,%esp
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	8d 76 00             	lea    0x0(%esi),%esi
  801e60:	39 e8                	cmp    %ebp,%eax
  801e62:	77 24                	ja     801e88 <__udivdi3+0x78>
  801e64:	0f bd e8             	bsr    %eax,%ebp
  801e67:	83 f5 1f             	xor    $0x1f,%ebp
  801e6a:	75 3c                	jne    801ea8 <__udivdi3+0x98>
  801e6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e70:	39 34 24             	cmp    %esi,(%esp)
  801e73:	0f 86 9f 00 00 00    	jbe    801f18 <__udivdi3+0x108>
  801e79:	39 d0                	cmp    %edx,%eax
  801e7b:	0f 82 97 00 00 00    	jb     801f18 <__udivdi3+0x108>
  801e81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	31 c0                	xor    %eax,%eax
  801e8c:	83 c4 0c             	add    $0xc,%esp
  801e8f:	5e                   	pop    %esi
  801e90:	5f                   	pop    %edi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    
  801e93:	90                   	nop
  801e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e98:	89 f8                	mov    %edi,%eax
  801e9a:	f7 f1                	div    %ecx
  801e9c:	31 d2                	xor    %edx,%edx
  801e9e:	83 c4 0c             	add    $0xc,%esp
  801ea1:	5e                   	pop    %esi
  801ea2:	5f                   	pop    %edi
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    
  801ea5:	8d 76 00             	lea    0x0(%esi),%esi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	8b 3c 24             	mov    (%esp),%edi
  801ead:	d3 e0                	shl    %cl,%eax
  801eaf:	89 c6                	mov    %eax,%esi
  801eb1:	b8 20 00 00 00       	mov    $0x20,%eax
  801eb6:	29 e8                	sub    %ebp,%eax
  801eb8:	89 c1                	mov    %eax,%ecx
  801eba:	d3 ef                	shr    %cl,%edi
  801ebc:	89 e9                	mov    %ebp,%ecx
  801ebe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ec2:	8b 3c 24             	mov    (%esp),%edi
  801ec5:	09 74 24 08          	or     %esi,0x8(%esp)
  801ec9:	89 d6                	mov    %edx,%esi
  801ecb:	d3 e7                	shl    %cl,%edi
  801ecd:	89 c1                	mov    %eax,%ecx
  801ecf:	89 3c 24             	mov    %edi,(%esp)
  801ed2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ed6:	d3 ee                	shr    %cl,%esi
  801ed8:	89 e9                	mov    %ebp,%ecx
  801eda:	d3 e2                	shl    %cl,%edx
  801edc:	89 c1                	mov    %eax,%ecx
  801ede:	d3 ef                	shr    %cl,%edi
  801ee0:	09 d7                	or     %edx,%edi
  801ee2:	89 f2                	mov    %esi,%edx
  801ee4:	89 f8                	mov    %edi,%eax
  801ee6:	f7 74 24 08          	divl   0x8(%esp)
  801eea:	89 d6                	mov    %edx,%esi
  801eec:	89 c7                	mov    %eax,%edi
  801eee:	f7 24 24             	mull   (%esp)
  801ef1:	39 d6                	cmp    %edx,%esi
  801ef3:	89 14 24             	mov    %edx,(%esp)
  801ef6:	72 30                	jb     801f28 <__udivdi3+0x118>
  801ef8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801efc:	89 e9                	mov    %ebp,%ecx
  801efe:	d3 e2                	shl    %cl,%edx
  801f00:	39 c2                	cmp    %eax,%edx
  801f02:	73 05                	jae    801f09 <__udivdi3+0xf9>
  801f04:	3b 34 24             	cmp    (%esp),%esi
  801f07:	74 1f                	je     801f28 <__udivdi3+0x118>
  801f09:	89 f8                	mov    %edi,%eax
  801f0b:	31 d2                	xor    %edx,%edx
  801f0d:	e9 7a ff ff ff       	jmp    801e8c <__udivdi3+0x7c>
  801f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f18:	31 d2                	xor    %edx,%edx
  801f1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1f:	e9 68 ff ff ff       	jmp    801e8c <__udivdi3+0x7c>
  801f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f28:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	83 c4 0c             	add    $0xc,%esp
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    
  801f34:	66 90                	xchg   %ax,%ax
  801f36:	66 90                	xchg   %ax,%ax
  801f38:	66 90                	xchg   %ax,%ax
  801f3a:	66 90                	xchg   %ax,%ax
  801f3c:	66 90                	xchg   %ax,%ax
  801f3e:	66 90                	xchg   %ax,%ax

00801f40 <__umoddi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	83 ec 14             	sub    $0x14,%esp
  801f46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f52:	89 c7                	mov    %eax,%edi
  801f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f58:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f60:	89 34 24             	mov    %esi,(%esp)
  801f63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f67:	85 c0                	test   %eax,%eax
  801f69:	89 c2                	mov    %eax,%edx
  801f6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f6f:	75 17                	jne    801f88 <__umoddi3+0x48>
  801f71:	39 fe                	cmp    %edi,%esi
  801f73:	76 4b                	jbe    801fc0 <__umoddi3+0x80>
  801f75:	89 c8                	mov    %ecx,%eax
  801f77:	89 fa                	mov    %edi,%edx
  801f79:	f7 f6                	div    %esi
  801f7b:	89 d0                	mov    %edx,%eax
  801f7d:	31 d2                	xor    %edx,%edx
  801f7f:	83 c4 14             	add    $0x14,%esp
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	39 f8                	cmp    %edi,%eax
  801f8a:	77 54                	ja     801fe0 <__umoddi3+0xa0>
  801f8c:	0f bd e8             	bsr    %eax,%ebp
  801f8f:	83 f5 1f             	xor    $0x1f,%ebp
  801f92:	75 5c                	jne    801ff0 <__umoddi3+0xb0>
  801f94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f98:	39 3c 24             	cmp    %edi,(%esp)
  801f9b:	0f 87 e7 00 00 00    	ja     802088 <__umoddi3+0x148>
  801fa1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fa5:	29 f1                	sub    %esi,%ecx
  801fa7:	19 c7                	sbb    %eax,%edi
  801fa9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fb1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fb9:	83 c4 14             	add    $0x14,%esp
  801fbc:	5e                   	pop    %esi
  801fbd:	5f                   	pop    %edi
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    
  801fc0:	85 f6                	test   %esi,%esi
  801fc2:	89 f5                	mov    %esi,%ebp
  801fc4:	75 0b                	jne    801fd1 <__umoddi3+0x91>
  801fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fcb:	31 d2                	xor    %edx,%edx
  801fcd:	f7 f6                	div    %esi
  801fcf:	89 c5                	mov    %eax,%ebp
  801fd1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fd5:	31 d2                	xor    %edx,%edx
  801fd7:	f7 f5                	div    %ebp
  801fd9:	89 c8                	mov    %ecx,%eax
  801fdb:	f7 f5                	div    %ebp
  801fdd:	eb 9c                	jmp    801f7b <__umoddi3+0x3b>
  801fdf:	90                   	nop
  801fe0:	89 c8                	mov    %ecx,%eax
  801fe2:	89 fa                	mov    %edi,%edx
  801fe4:	83 c4 14             	add    $0x14,%esp
  801fe7:	5e                   	pop    %esi
  801fe8:	5f                   	pop    %edi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    
  801feb:	90                   	nop
  801fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	8b 04 24             	mov    (%esp),%eax
  801ff3:	be 20 00 00 00       	mov    $0x20,%esi
  801ff8:	89 e9                	mov    %ebp,%ecx
  801ffa:	29 ee                	sub    %ebp,%esi
  801ffc:	d3 e2                	shl    %cl,%edx
  801ffe:	89 f1                	mov    %esi,%ecx
  802000:	d3 e8                	shr    %cl,%eax
  802002:	89 e9                	mov    %ebp,%ecx
  802004:	89 44 24 04          	mov    %eax,0x4(%esp)
  802008:	8b 04 24             	mov    (%esp),%eax
  80200b:	09 54 24 04          	or     %edx,0x4(%esp)
  80200f:	89 fa                	mov    %edi,%edx
  802011:	d3 e0                	shl    %cl,%eax
  802013:	89 f1                	mov    %esi,%ecx
  802015:	89 44 24 08          	mov    %eax,0x8(%esp)
  802019:	8b 44 24 10          	mov    0x10(%esp),%eax
  80201d:	d3 ea                	shr    %cl,%edx
  80201f:	89 e9                	mov    %ebp,%ecx
  802021:	d3 e7                	shl    %cl,%edi
  802023:	89 f1                	mov    %esi,%ecx
  802025:	d3 e8                	shr    %cl,%eax
  802027:	89 e9                	mov    %ebp,%ecx
  802029:	09 f8                	or     %edi,%eax
  80202b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80202f:	f7 74 24 04          	divl   0x4(%esp)
  802033:	d3 e7                	shl    %cl,%edi
  802035:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802039:	89 d7                	mov    %edx,%edi
  80203b:	f7 64 24 08          	mull   0x8(%esp)
  80203f:	39 d7                	cmp    %edx,%edi
  802041:	89 c1                	mov    %eax,%ecx
  802043:	89 14 24             	mov    %edx,(%esp)
  802046:	72 2c                	jb     802074 <__umoddi3+0x134>
  802048:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80204c:	72 22                	jb     802070 <__umoddi3+0x130>
  80204e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802052:	29 c8                	sub    %ecx,%eax
  802054:	19 d7                	sbb    %edx,%edi
  802056:	89 e9                	mov    %ebp,%ecx
  802058:	89 fa                	mov    %edi,%edx
  80205a:	d3 e8                	shr    %cl,%eax
  80205c:	89 f1                	mov    %esi,%ecx
  80205e:	d3 e2                	shl    %cl,%edx
  802060:	89 e9                	mov    %ebp,%ecx
  802062:	d3 ef                	shr    %cl,%edi
  802064:	09 d0                	or     %edx,%eax
  802066:	89 fa                	mov    %edi,%edx
  802068:	83 c4 14             	add    $0x14,%esp
  80206b:	5e                   	pop    %esi
  80206c:	5f                   	pop    %edi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    
  80206f:	90                   	nop
  802070:	39 d7                	cmp    %edx,%edi
  802072:	75 da                	jne    80204e <__umoddi3+0x10e>
  802074:	8b 14 24             	mov    (%esp),%edx
  802077:	89 c1                	mov    %eax,%ecx
  802079:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80207d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802081:	eb cb                	jmp    80204e <__umoddi3+0x10e>
  802083:	90                   	nop
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80208c:	0f 82 0f ff ff ff    	jb     801fa1 <__umoddi3+0x61>
  802092:	e9 1a ff ff ff       	jmp    801fb1 <__umoddi3+0x71>
