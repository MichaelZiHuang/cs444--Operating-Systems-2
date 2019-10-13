
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2e 00 00 00       	call   80005f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  800039:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  800040:	e8 1e 01 00 00       	call   800163 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800045:	a1 08 40 80 00       	mov    0x804008,%eax
  80004a:	8b 40 48             	mov    0x48(%eax),%eax
  80004d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800051:	c7 04 24 ce 1f 80 00 	movl   $0x801fce,(%esp)
  800058:	e8 06 01 00 00       	call   800163 <cprintf>
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	83 ec 10             	sub    $0x10,%esp
  800067:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  80006d:	e8 f3 0a 00 00       	call   800b65 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800072:	25 ff 03 00 00       	and    $0x3ff,%eax
  800077:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007f:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800084:	85 db                	test   %ebx,%ebx
  800086:	7e 07                	jle    80008f <libmain+0x30>
		binaryname = argv[0];
  800088:	8b 06                	mov    (%esi),%eax
  80008a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800093:	89 1c 24             	mov    %ebx,(%esp)
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 07 00 00 00       	call   8000a7 <exit>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ad:	e8 33 0f 00 00       	call   800fe5 <close_all>
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 55 0a 00 00       	call   800b13 <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 14             	sub    $0x14,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 19                	jne    8000f8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000df:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e6:	00 
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	89 04 24             	mov    %eax,(%esp)
  8000ed:	e8 e4 09 00 00       	call   800ad6 <sys_cputs>
		b->idx = 0;
  8000f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fc:	83 c4 14             	add    $0x14,%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800122:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800133:	89 44 24 04          	mov    %eax,0x4(%esp)
  800137:	c7 04 24 c0 00 80 00 	movl   $0x8000c0,(%esp)
  80013e:	e8 ab 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800149:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800153:	89 04 24             	mov    %eax,(%esp)
  800156:	e8 7b 09 00 00       	call   800ad6 <sys_cputs>

	return b.cnt;
}
  80015b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800169:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	8b 45 08             	mov    0x8(%ebp),%eax
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 87 ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    
  80017d:	66 90                	xchg   %ax,%ax
  80017f:	90                   	nop

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 c3                	mov    %eax,%ebx
  800199:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ad:	39 d9                	cmp    %ebx,%ecx
  8001af:	72 05                	jb     8001b6 <printnum+0x36>
  8001b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b4:	77 69                	ja     80021f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001bd:	83 ee 01             	sub    $0x1,%esi
  8001c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001d0:	89 c3                	mov    %eax,%ebx
  8001d2:	89 d6                	mov    %edx,%esi
  8001d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ef:	e8 3c 1b 00 00       	call   801d30 <__udivdi3>
  8001f4:	89 d9                	mov    %ebx,%ecx
  8001f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001fe:	89 04 24             	mov    %eax,(%esp)
  800201:	89 54 24 04          	mov    %edx,0x4(%esp)
  800205:	89 fa                	mov    %edi,%edx
  800207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020a:	e8 71 ff ff ff       	call   800180 <printnum>
  80020f:	eb 1b                	jmp    80022c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800215:	8b 45 18             	mov    0x18(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	ff d3                	call   *%ebx
  80021d:	eb 03                	jmp    800222 <printnum+0xa2>
  80021f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800222:	83 ee 01             	sub    $0x1,%esi
  800225:	85 f6                	test   %esi,%esi
  800227:	7f e8                	jg     800211 <printnum+0x91>
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800230:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800234:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800237:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80023a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 0c 1c 00 00       	call   801e60 <__umoddi3>
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800258:	0f be 80 ef 1f 80 00 	movsbl 0x801fef(%eax),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800265:	ff d0                	call   *%eax
}
  800267:	83 c4 3c             	add    $0x3c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800272:	83 fa 01             	cmp    $0x1,%edx
  800275:	7e 0e                	jle    800285 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	8b 52 04             	mov    0x4(%edx),%edx
  800283:	eb 22                	jmp    8002a7 <getuint+0x38>
	else if (lflag)
  800285:	85 d2                	test   %edx,%edx
  800287:	74 10                	je     800299 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	eb 0e                	jmp    8002a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 0a                	jae    8002c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	88 02                	mov    %al,(%edx)
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <printfmt>:
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8002cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	e8 02 00 00 00       	call   8002ee <vprintfmt>
}
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 3c             	sub    $0x3c,%esp
  8002f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fd:	eb 1f                	jmp    80031e <vprintfmt+0x30>
			if (ch == '\0'){
  8002ff:	85 c0                	test   %eax,%eax
  800301:	75 0f                	jne    800312 <vprintfmt+0x24>
				color = 0x0100;
  800303:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80030a:	01 00 00 
  80030d:	e9 b3 03 00 00       	jmp    8006c5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800312:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031c:	89 f3                	mov    %esi,%ebx
  80031e:	8d 73 01             	lea    0x1(%ebx),%esi
  800321:	0f b6 03             	movzbl (%ebx),%eax
  800324:	83 f8 25             	cmp    $0x25,%eax
  800327:	75 d6                	jne    8002ff <vprintfmt+0x11>
  800329:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80032d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800334:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80033b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800342:	ba 00 00 00 00       	mov    $0x0,%edx
  800347:	eb 1d                	jmp    800366 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800349:	89 de                	mov    %ebx,%esi
			padc = '-';
  80034b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034f:	eb 15                	jmp    800366 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800351:	89 de                	mov    %ebx,%esi
			padc = '0';
  800353:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800357:	eb 0d                	jmp    800366 <vprintfmt+0x78>
				width = precision, precision = -1;
  800359:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80035f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8d 5e 01             	lea    0x1(%esi),%ebx
  800369:	0f b6 0e             	movzbl (%esi),%ecx
  80036c:	0f b6 c1             	movzbl %cl,%eax
  80036f:	83 e9 23             	sub    $0x23,%ecx
  800372:	80 f9 55             	cmp    $0x55,%cl
  800375:	0f 87 2a 03 00 00    	ja     8006a5 <vprintfmt+0x3b7>
  80037b:	0f b6 c9             	movzbl %cl,%ecx
  80037e:	ff 24 8d 40 21 80 00 	jmp    *0x802140(,%ecx,4)
  800385:	89 de                	mov    %ebx,%esi
  800387:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80038c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80038f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800393:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800396:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800399:	83 fb 09             	cmp    $0x9,%ebx
  80039c:	77 36                	ja     8003d4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80039e:	83 c6 01             	add    $0x1,%esi
			}
  8003a1:	eb e9                	jmp    80038c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8003a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ac:	8b 00                	mov    (%eax),%eax
  8003ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8003b3:	eb 22                	jmp    8003d7 <vprintfmt+0xe9>
  8003b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003b8:	85 c9                	test   %ecx,%ecx
  8003ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bf:	0f 49 c1             	cmovns %ecx,%eax
  8003c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	89 de                	mov    %ebx,%esi
  8003c7:	eb 9d                	jmp    800366 <vprintfmt+0x78>
  8003c9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8003cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003d2:	eb 92                	jmp    800366 <vprintfmt+0x78>
  8003d4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8003d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003db:	79 89                	jns    800366 <vprintfmt+0x78>
  8003dd:	e9 77 ff ff ff       	jmp    800359 <vprintfmt+0x6b>
			lflag++;
  8003e2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8003e7:	e9 7a ff ff ff       	jmp    800366 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800401:	e9 18 ff ff ff       	jmp    80031e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8d 50 04             	lea    0x4(%eax),%edx
  80040c:	89 55 14             	mov    %edx,0x14(%ebp)
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	99                   	cltd   
  800412:	31 d0                	xor    %edx,%eax
  800414:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800416:	83 f8 0f             	cmp    $0xf,%eax
  800419:	7f 0b                	jg     800426 <vprintfmt+0x138>
  80041b:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  800422:	85 d2                	test   %edx,%edx
  800424:	75 20                	jne    800446 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800426:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042a:	c7 44 24 08 07 20 80 	movl   $0x802007,0x8(%esp)
  800431:	00 
  800432:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
  800439:	89 04 24             	mov    %eax,(%esp)
  80043c:	e8 85 fe ff ff       	call   8002c6 <printfmt>
  800441:	e9 d8 fe ff ff       	jmp    80031e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800446:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044a:	c7 44 24 08 fa 23 80 	movl   $0x8023fa,0x8(%esp)
  800451:	00 
  800452:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800456:	8b 45 08             	mov    0x8(%ebp),%eax
  800459:	89 04 24             	mov    %eax,(%esp)
  80045c:	e8 65 fe ff ff       	call   8002c6 <printfmt>
  800461:	e9 b8 fe ff ff       	jmp    80031e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800469:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80046c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80047a:	85 f6                	test   %esi,%esi
  80047c:	b8 00 20 80 00       	mov    $0x802000,%eax
  800481:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800484:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800488:	0f 84 97 00 00 00    	je     800525 <vprintfmt+0x237>
  80048e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800492:	0f 8e 9b 00 00 00    	jle    800533 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800498:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80049c:	89 34 24             	mov    %esi,(%esp)
  80049f:	e8 c4 02 00 00       	call   800768 <strnlen>
  8004a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004a7:	29 c2                	sub    %eax,%edx
  8004a9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8004ac:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004bc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004be:	eb 0f                	jmp    8004cf <vprintfmt+0x1e1>
					putch(padc, putdat);
  8004c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c7:	89 04 24             	mov    %eax,(%esp)
  8004ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	83 eb 01             	sub    $0x1,%ebx
  8004cf:	85 db                	test   %ebx,%ebx
  8004d1:	7f ed                	jg     8004c0 <vprintfmt+0x1d2>
  8004d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004d9:	85 d2                	test   %edx,%edx
  8004db:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e0:	0f 49 c2             	cmovns %edx,%eax
  8004e3:	29 c2                	sub    %eax,%edx
  8004e5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004e8:	89 d7                	mov    %edx,%edi
  8004ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004ed:	eb 50                	jmp    80053f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	74 1e                	je     800513 <vprintfmt+0x225>
  8004f5:	0f be d2             	movsbl %dl,%edx
  8004f8:	83 ea 20             	sub    $0x20,%edx
  8004fb:	83 fa 5e             	cmp    $0x5e,%edx
  8004fe:	76 13                	jbe    800513 <vprintfmt+0x225>
					putch('?', putdat);
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80050e:	ff 55 08             	call   *0x8(%ebp)
  800511:	eb 0d                	jmp    800520 <vprintfmt+0x232>
					putch(ch, putdat);
  800513:	8b 55 0c             	mov    0xc(%ebp),%edx
  800516:	89 54 24 04          	mov    %edx,0x4(%esp)
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800520:	83 ef 01             	sub    $0x1,%edi
  800523:	eb 1a                	jmp    80053f <vprintfmt+0x251>
  800525:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800528:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80052b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80052e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800531:	eb 0c                	jmp    80053f <vprintfmt+0x251>
  800533:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800536:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800539:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80053c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80053f:	83 c6 01             	add    $0x1,%esi
  800542:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800546:	0f be c2             	movsbl %dl,%eax
  800549:	85 c0                	test   %eax,%eax
  80054b:	74 27                	je     800574 <vprintfmt+0x286>
  80054d:	85 db                	test   %ebx,%ebx
  80054f:	78 9e                	js     8004ef <vprintfmt+0x201>
  800551:	83 eb 01             	sub    $0x1,%ebx
  800554:	79 99                	jns    8004ef <vprintfmt+0x201>
  800556:	89 f8                	mov    %edi,%eax
  800558:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	89 c3                	mov    %eax,%ebx
  800560:	eb 1a                	jmp    80057c <vprintfmt+0x28e>
				putch(' ', putdat);
  800562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800566:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80056f:	83 eb 01             	sub    $0x1,%ebx
  800572:	eb 08                	jmp    80057c <vprintfmt+0x28e>
  800574:	89 fb                	mov    %edi,%ebx
  800576:	8b 75 08             	mov    0x8(%ebp),%esi
  800579:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80057c:	85 db                	test   %ebx,%ebx
  80057e:	7f e2                	jg     800562 <vprintfmt+0x274>
  800580:	89 75 08             	mov    %esi,0x8(%ebp)
  800583:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800586:	e9 93 fd ff ff       	jmp    80031e <vprintfmt+0x30>
	if (lflag >= 2)
  80058b:	83 fa 01             	cmp    $0x1,%edx
  80058e:	7e 16                	jle    8005a6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 08             	lea    0x8(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 50 04             	mov    0x4(%eax),%edx
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a4:	eb 32                	jmp    8005d8 <vprintfmt+0x2ea>
	else if (lflag)
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 18                	je     8005c2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 30                	mov    (%eax),%esi
  8005b5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005b8:	89 f0                	mov    %esi,%eax
  8005ba:	c1 f8 1f             	sar    $0x1f,%eax
  8005bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c0:	eb 16                	jmp    8005d8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 30                	mov    (%eax),%esi
  8005cd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005d0:	89 f0                	mov    %esi,%eax
  8005d2:	c1 f8 1f             	sar    $0x1f,%eax
  8005d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8005d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8005de:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e7:	0f 89 80 00 00 00    	jns    80066d <vprintfmt+0x37f>
				putch('-', putdat);
  8005ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005f8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800601:	f7 d8                	neg    %eax
  800603:	83 d2 00             	adc    $0x0,%edx
  800606:	f7 da                	neg    %edx
			base = 10;
  800608:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060d:	eb 5e                	jmp    80066d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80060f:	8d 45 14             	lea    0x14(%ebp),%eax
  800612:	e8 58 fc ff ff       	call   80026f <getuint>
			base = 10;
  800617:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061c:	eb 4f                	jmp    80066d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 49 fc ff ff       	call   80026f <getuint>
            base = 8;
  800626:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80062b:	eb 40                	jmp    80066d <vprintfmt+0x37f>
			putch('0', putdat);
  80062d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800631:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800638:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80063b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800646:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800652:	8b 00                	mov    (%eax),%eax
  800654:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800659:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80065e:	eb 0d                	jmp    80066d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 07 fc ff ff       	call   80026f <getuint>
			base = 16;
  800668:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80066d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800671:	89 74 24 10          	mov    %esi,0x10(%esp)
  800675:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800678:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80067c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800680:	89 04 24             	mov    %eax,(%esp)
  800683:	89 54 24 04          	mov    %edx,0x4(%esp)
  800687:	89 fa                	mov    %edi,%edx
  800689:	8b 45 08             	mov    0x8(%ebp),%eax
  80068c:	e8 ef fa ff ff       	call   800180 <printnum>
			break;
  800691:	e9 88 fc ff ff       	jmp    80031e <vprintfmt+0x30>
			putch(ch, putdat);
  800696:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069a:	89 04 24             	mov    %eax,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006a0:	e9 79 fc ff ff       	jmp    80031e <vprintfmt+0x30>
			putch('%', putdat);
  8006a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006b0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b3:	89 f3                	mov    %esi,%ebx
  8006b5:	eb 03                	jmp    8006ba <vprintfmt+0x3cc>
  8006b7:	83 eb 01             	sub    $0x1,%ebx
  8006ba:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006be:	75 f7                	jne    8006b7 <vprintfmt+0x3c9>
  8006c0:	e9 59 fc ff ff       	jmp    80031e <vprintfmt+0x30>
}
  8006c5:	83 c4 3c             	add    $0x3c,%esp
  8006c8:	5b                   	pop    %ebx
  8006c9:	5e                   	pop    %esi
  8006ca:	5f                   	pop    %edi
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 28             	sub    $0x28,%esp
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	74 30                	je     80071e <vsnprintf+0x51>
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	7e 2c                	jle    80071e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800700:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800703:	89 44 24 04          	mov    %eax,0x4(%esp)
  800707:	c7 04 24 a9 02 80 00 	movl   $0x8002a9,(%esp)
  80070e:	e8 db fb ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800713:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800716:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071c:	eb 05                	jmp    800723 <vsnprintf+0x56>
		return -E_INVAL;
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800732:	8b 45 10             	mov    0x10(%ebp),%eax
  800735:	89 44 24 08          	mov    %eax,0x8(%esp)
  800739:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	89 04 24             	mov    %eax,(%esp)
  800746:	e8 82 ff ff ff       	call   8006cd <vsnprintf>
	va_end(ap);

	return rc;
}
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    
  80074d:	66 90                	xchg   %ax,%ax
  80074f:	90                   	nop

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	eb 03                	jmp    800760 <strlen+0x10>
		n++;
  80075d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800760:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800764:	75 f7                	jne    80075d <strlen+0xd>
	return n;
}
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800771:	b8 00 00 00 00       	mov    $0x0,%eax
  800776:	eb 03                	jmp    80077b <strnlen+0x13>
		n++;
  800778:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077b:	39 d0                	cmp    %edx,%eax
  80077d:	74 06                	je     800785 <strnlen+0x1d>
  80077f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800783:	75 f3                	jne    800778 <strnlen+0x10>
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	83 c1 01             	add    $0x1,%ecx
  800799:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a0:	84 db                	test   %bl,%bl
  8007a2:	75 ef                	jne    800793 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a4:	5b                   	pop    %ebx
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b1:	89 1c 24             	mov    %ebx,(%esp)
  8007b4:	e8 97 ff ff ff       	call   800750 <strlen>
	strcpy(dst + len, src);
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c0:	01 d8                	add    %ebx,%eax
  8007c2:	89 04 24             	mov    %eax,(%esp)
  8007c5:	e8 bd ff ff ff       	call   800787 <strcpy>
	return dst;
}
  8007ca:	89 d8                	mov    %ebx,%eax
  8007cc:	83 c4 08             	add    $0x8,%esp
  8007cf:	5b                   	pop    %ebx
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dd:	89 f3                	mov    %esi,%ebx
  8007df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e2:	89 f2                	mov    %esi,%edx
  8007e4:	eb 0f                	jmp    8007f5 <strncpy+0x23>
		*dst++ = *src;
  8007e6:	83 c2 01             	add    $0x1,%edx
  8007e9:	0f b6 01             	movzbl (%ecx),%eax
  8007ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007f5:	39 da                	cmp    %ebx,%edx
  8007f7:	75 ed                	jne    8007e6 <strncpy+0x14>
	}
	return ret;
}
  8007f9:	89 f0                	mov    %esi,%eax
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	8b 75 08             	mov    0x8(%ebp),%esi
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800813:	85 c9                	test   %ecx,%ecx
  800815:	75 0b                	jne    800822 <strlcpy+0x23>
  800817:	eb 1d                	jmp    800836 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800822:	39 d8                	cmp    %ebx,%eax
  800824:	74 0b                	je     800831 <strlcpy+0x32>
  800826:	0f b6 0a             	movzbl (%edx),%ecx
  800829:	84 c9                	test   %cl,%cl
  80082b:	75 ec                	jne    800819 <strlcpy+0x1a>
  80082d:	89 c2                	mov    %eax,%edx
  80082f:	eb 02                	jmp    800833 <strlcpy+0x34>
  800831:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800833:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800836:	29 f0                	sub    %esi,%eax
}
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800845:	eb 06                	jmp    80084d <strcmp+0x11>
		p++, q++;
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80084d:	0f b6 01             	movzbl (%ecx),%eax
  800850:	84 c0                	test   %al,%al
  800852:	74 04                	je     800858 <strcmp+0x1c>
  800854:	3a 02                	cmp    (%edx),%al
  800856:	74 ef                	je     800847 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800858:	0f b6 c0             	movzbl %al,%eax
  80085b:	0f b6 12             	movzbl (%edx),%edx
  80085e:	29 d0                	sub    %edx,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	89 c3                	mov    %eax,%ebx
  80086e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800871:	eb 06                	jmp    800879 <strncmp+0x17>
		n--, p++, q++;
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800879:	39 d8                	cmp    %ebx,%eax
  80087b:	74 15                	je     800892 <strncmp+0x30>
  80087d:	0f b6 08             	movzbl (%eax),%ecx
  800880:	84 c9                	test   %cl,%cl
  800882:	74 04                	je     800888 <strncmp+0x26>
  800884:	3a 0a                	cmp    (%edx),%cl
  800886:	74 eb                	je     800873 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800888:	0f b6 00             	movzbl (%eax),%eax
  80088b:	0f b6 12             	movzbl (%edx),%edx
  80088e:	29 d0                	sub    %edx,%eax
  800890:	eb 05                	jmp    800897 <strncmp+0x35>
		return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a4:	eb 07                	jmp    8008ad <strchr+0x13>
		if (*s == c)
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 0f                	je     8008b9 <strchr+0x1f>
	for (; *s; s++)
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 10             	movzbl (%eax),%edx
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	75 f2                	jne    8008a6 <strchr+0xc>
			return (char *) s;
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	eb 07                	jmp    8008ce <strfind+0x13>
		if (*s == c)
  8008c7:	38 ca                	cmp    %cl,%dl
  8008c9:	74 0a                	je     8008d5 <strfind+0x1a>
	for (; *s; s++)
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 10             	movzbl (%eax),%edx
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	75 f2                	jne    8008c7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	74 36                	je     80091d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ed:	75 28                	jne    800917 <memset+0x40>
  8008ef:	f6 c1 03             	test   $0x3,%cl
  8008f2:	75 23                	jne    800917 <memset+0x40>
		c &= 0xFF;
  8008f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f8:	89 d3                	mov    %edx,%ebx
  8008fa:	c1 e3 08             	shl    $0x8,%ebx
  8008fd:	89 d6                	mov    %edx,%esi
  8008ff:	c1 e6 18             	shl    $0x18,%esi
  800902:	89 d0                	mov    %edx,%eax
  800904:	c1 e0 10             	shl    $0x10,%eax
  800907:	09 f0                	or     %esi,%eax
  800909:	09 c2                	or     %eax,%edx
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800912:	fc                   	cld    
  800913:	f3 ab                	rep stos %eax,%es:(%edi)
  800915:	eb 06                	jmp    80091d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091a:	fc                   	cld    
  80091b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800932:	39 c6                	cmp    %eax,%esi
  800934:	73 35                	jae    80096b <memmove+0x47>
  800936:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800939:	39 d0                	cmp    %edx,%eax
  80093b:	73 2e                	jae    80096b <memmove+0x47>
		s += n;
		d += n;
  80093d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800940:	89 d6                	mov    %edx,%esi
  800942:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094a:	75 13                	jne    80095f <memmove+0x3b>
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 0e                	jne    80095f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800951:	83 ef 04             	sub    $0x4,%edi
  800954:	8d 72 fc             	lea    -0x4(%edx),%esi
  800957:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80095a:	fd                   	std    
  80095b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095d:	eb 09                	jmp    800968 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095f:	83 ef 01             	sub    $0x1,%edi
  800962:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800965:	fd                   	std    
  800966:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800968:	fc                   	cld    
  800969:	eb 1d                	jmp    800988 <memmove+0x64>
  80096b:	89 f2                	mov    %esi,%edx
  80096d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	f6 c2 03             	test   $0x3,%dl
  800972:	75 0f                	jne    800983 <memmove+0x5f>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 0a                	jne    800983 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800979:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80097c:	89 c7                	mov    %eax,%edi
  80097e:	fc                   	cld    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 05                	jmp    800988 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800992:	8b 45 10             	mov    0x10(%ebp),%eax
  800995:	89 44 24 08          	mov    %eax,0x8(%esp)
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	89 04 24             	mov    %eax,(%esp)
  8009a6:	e8 79 ff ff ff       	call   800924 <memmove>
}
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b8:	89 d6                	mov    %edx,%esi
  8009ba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bd:	eb 1a                	jmp    8009d9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009bf:	0f b6 02             	movzbl (%edx),%eax
  8009c2:	0f b6 19             	movzbl (%ecx),%ebx
  8009c5:	38 d8                	cmp    %bl,%al
  8009c7:	74 0a                	je     8009d3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c9:	0f b6 c0             	movzbl %al,%eax
  8009cc:	0f b6 db             	movzbl %bl,%ebx
  8009cf:	29 d8                	sub    %ebx,%eax
  8009d1:	eb 0f                	jmp    8009e2 <memcmp+0x35>
		s1++, s2++;
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  8009d9:	39 f2                	cmp    %esi,%edx
  8009db:	75 e2                	jne    8009bf <memcmp+0x12>
	}

	return 0;
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ef:	89 c2                	mov    %eax,%edx
  8009f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f4:	eb 07                	jmp    8009fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f6:	38 08                	cmp    %cl,(%eax)
  8009f8:	74 07                	je     800a01 <memfind+0x1b>
	for (; s < ends; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	72 f5                	jb     8009f6 <memfind+0x10>
			break;
	return (void *) s;
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	eb 03                	jmp    800a14 <strtol+0x11>
		s++;
  800a11:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a14:	0f b6 0a             	movzbl (%edx),%ecx
  800a17:	80 f9 09             	cmp    $0x9,%cl
  800a1a:	74 f5                	je     800a11 <strtol+0xe>
  800a1c:	80 f9 20             	cmp    $0x20,%cl
  800a1f:	74 f0                	je     800a11 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a21:	80 f9 2b             	cmp    $0x2b,%cl
  800a24:	75 0a                	jne    800a30 <strtol+0x2d>
		s++;
  800a26:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2e:	eb 11                	jmp    800a41 <strtol+0x3e>
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800a35:	80 f9 2d             	cmp    $0x2d,%cl
  800a38:	75 07                	jne    800a41 <strtol+0x3e>
		s++, neg = 1;
  800a3a:	8d 52 01             	lea    0x1(%edx),%edx
  800a3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a46:	75 15                	jne    800a5d <strtol+0x5a>
  800a48:	80 3a 30             	cmpb   $0x30,(%edx)
  800a4b:	75 10                	jne    800a5d <strtol+0x5a>
  800a4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a51:	75 0a                	jne    800a5d <strtol+0x5a>
		s += 2, base = 16;
  800a53:	83 c2 02             	add    $0x2,%edx
  800a56:	b8 10 00 00 00       	mov    $0x10,%eax
  800a5b:	eb 10                	jmp    800a6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	75 0c                	jne    800a6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a61:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800a63:	80 3a 30             	cmpb   $0x30,(%edx)
  800a66:	75 05                	jne    800a6d <strtol+0x6a>
		s++, base = 8;
  800a68:	83 c2 01             	add    $0x1,%edx
  800a6b:	b0 08                	mov    $0x8,%al
		base = 10;
  800a6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a75:	0f b6 0a             	movzbl (%edx),%ecx
  800a78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a7b:	89 f0                	mov    %esi,%eax
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	77 08                	ja     800a89 <strtol+0x86>
			dig = *s - '0';
  800a81:	0f be c9             	movsbl %cl,%ecx
  800a84:	83 e9 30             	sub    $0x30,%ecx
  800a87:	eb 20                	jmp    800aa9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800a89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a8c:	89 f0                	mov    %esi,%eax
  800a8e:	3c 19                	cmp    $0x19,%al
  800a90:	77 08                	ja     800a9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800a92:	0f be c9             	movsbl %cl,%ecx
  800a95:	83 e9 57             	sub    $0x57,%ecx
  800a98:	eb 0f                	jmp    800aa9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a9d:	89 f0                	mov    %esi,%eax
  800a9f:	3c 19                	cmp    $0x19,%al
  800aa1:	77 16                	ja     800ab9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800aa3:	0f be c9             	movsbl %cl,%ecx
  800aa6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800aac:	7d 0f                	jge    800abd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800aae:	83 c2 01             	add    $0x1,%edx
  800ab1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ab5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ab7:	eb bc                	jmp    800a75 <strtol+0x72>
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	eb 02                	jmp    800abf <strtol+0xbc>
  800abd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800abf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac3:	74 05                	je     800aca <strtol+0xc7>
		*endptr = (char *) s;
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800aca:	f7 d8                	neg    %eax
  800acc:	85 ff                	test   %edi,%edi
  800ace:	0f 44 c3             	cmove  %ebx,%eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	89 c7                	mov    %eax,%edi
  800aeb:	89 c6                	mov    %eax,%esi
  800aed:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800afa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aff:	b8 01 00 00 00       	mov    $0x1,%eax
  800b04:	89 d1                	mov    %edx,%ecx
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	89 d7                	mov    %edx,%edi
  800b0a:	89 d6                	mov    %edx,%esi
  800b0c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800b1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b21:	b8 03 00 00 00       	mov    $0x3,%eax
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	89 cb                	mov    %ecx,%ebx
  800b2b:	89 cf                	mov    %ecx,%edi
  800b2d:	89 ce                	mov    %ecx,%esi
  800b2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7e 28                	jle    800b5d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b40:	00 
  800b41:	c7 44 24 08 ff 22 80 	movl   $0x8022ff,0x8(%esp)
  800b48:	00 
  800b49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b50:	00 
  800b51:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  800b58:	e8 29 10 00 00       	call   801b86 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5d:	83 c4 2c             	add    $0x2c,%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 02 00 00 00       	mov    $0x2,%eax
  800b75:	89 d1                	mov    %edx,%ecx
  800b77:	89 d3                	mov    %edx,%ebx
  800b79:	89 d7                	mov    %edx,%edi
  800b7b:	89 d6                	mov    %edx,%esi
  800b7d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_yield>:

void
sys_yield(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bac:	be 00 00 00 00       	mov    $0x0,%esi
  800bb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbf:	89 f7                	mov    %esi,%edi
  800bc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	7e 28                	jle    800bef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd2:	00 
  800bd3:	c7 44 24 08 ff 22 80 	movl   $0x8022ff,0x8(%esp)
  800bda:	00 
  800bdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be2:	00 
  800be3:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  800bea:	e8 97 0f 00 00       	call   801b86 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bef:	83 c4 2c             	add    $0x2c,%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c00:	b8 05 00 00 00       	mov    $0x5,%eax
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c11:	8b 75 18             	mov    0x18(%ebp),%esi
  800c14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 28                	jle    800c42 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c25:	00 
  800c26:	c7 44 24 08 ff 22 80 	movl   $0x8022ff,0x8(%esp)
  800c2d:	00 
  800c2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c35:	00 
  800c36:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  800c3d:	e8 44 0f 00 00       	call   801b86 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c42:	83 c4 2c             	add    $0x2c,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 28                	jle    800c95 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c71:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c78:	00 
  800c79:	c7 44 24 08 ff 22 80 	movl   $0x8022ff,0x8(%esp)
  800c80:	00 
  800c81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c88:	00 
  800c89:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  800c90:	e8 f1 0e 00 00       	call   801b86 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c95:	83 c4 2c             	add    $0x2c,%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 28                	jle    800ce8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ccb:	00 
  800ccc:	c7 44 24 08 ff 22 80 	movl   $0x8022ff,0x8(%esp)
  800cd3:	00 
  800cd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdb:	00 
  800cdc:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  800ce3:	e8 9e 0e 00 00       	call   801b86 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce8:	83 c4 2c             	add    $0x2c,%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 df                	mov    %ebx,%edi
  800d0b:	89 de                	mov    %ebx,%esi
  800d0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 28                	jle    800d3b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d17:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d1e:	00 
  800d1f:	c7 44 24 08 ff 22 80 	movl   $0x8022ff,0x8(%esp)
  800d26:	00 
  800d27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2e:	00 
  800d2f:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  800d36:	e8 4b 0e 00 00       	call   801b86 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3b:	83 c4 2c             	add    $0x2c,%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 28                	jle    800d8e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d71:	00 
  800d72:	c7 44 24 08 ff 22 80 	movl   $0x8022ff,0x8(%esp)
  800d79:	00 
  800d7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d81:	00 
  800d82:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  800d89:	e8 f8 0d 00 00       	call   801b86 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8e:	83 c4 2c             	add    $0x2c,%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9c:	be 00 00 00 00       	mov    $0x0,%esi
  800da1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
  800dbf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 cb                	mov    %ecx,%ebx
  800dd1:	89 cf                	mov    %ecx,%edi
  800dd3:	89 ce                	mov    %ecx,%esi
  800dd5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	7e 28                	jle    800e03 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de6:	00 
  800de7:	c7 44 24 08 ff 22 80 	movl   $0x8022ff,0x8(%esp)
  800dee:	00 
  800def:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df6:	00 
  800df7:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  800dfe:	e8 83 0d 00 00       	call   801b86 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e03:	83 c4 2c             	add    $0x2c,%esp
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e30:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e42:	89 c2                	mov    %eax,%edx
  800e44:	c1 ea 16             	shr    $0x16,%edx
  800e47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4e:	f6 c2 01             	test   $0x1,%dl
  800e51:	74 11                	je     800e64 <fd_alloc+0x2d>
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	c1 ea 0c             	shr    $0xc,%edx
  800e58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5f:	f6 c2 01             	test   $0x1,%dl
  800e62:	75 09                	jne    800e6d <fd_alloc+0x36>
			*fd_store = fd;
  800e64:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e66:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6b:	eb 17                	jmp    800e84 <fd_alloc+0x4d>
  800e6d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e72:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e77:	75 c9                	jne    800e42 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800e79:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e7f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e8c:	83 f8 1f             	cmp    $0x1f,%eax
  800e8f:	77 36                	ja     800ec7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e91:	c1 e0 0c             	shl    $0xc,%eax
  800e94:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	c1 ea 16             	shr    $0x16,%edx
  800e9e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea5:	f6 c2 01             	test   $0x1,%dl
  800ea8:	74 24                	je     800ece <fd_lookup+0x48>
  800eaa:	89 c2                	mov    %eax,%edx
  800eac:	c1 ea 0c             	shr    $0xc,%edx
  800eaf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb6:	f6 c2 01             	test   $0x1,%dl
  800eb9:	74 1a                	je     800ed5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ebb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebe:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	eb 13                	jmp    800eda <fd_lookup+0x54>
		return -E_INVAL;
  800ec7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecc:	eb 0c                	jmp    800eda <fd_lookup+0x54>
		return -E_INVAL;
  800ece:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed3:	eb 05                	jmp    800eda <fd_lookup+0x54>
  800ed5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 18             	sub    $0x18,%esp
  800ee2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee5:	ba a8 23 80 00       	mov    $0x8023a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eea:	eb 13                	jmp    800eff <dev_lookup+0x23>
  800eec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eef:	39 08                	cmp    %ecx,(%eax)
  800ef1:	75 0c                	jne    800eff <dev_lookup+0x23>
			*dev = devtab[i];
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	eb 30                	jmp    800f2f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800eff:	8b 02                	mov    (%edx),%eax
  800f01:	85 c0                	test   %eax,%eax
  800f03:	75 e7                	jne    800eec <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f05:	a1 08 40 80 00       	mov    0x804008,%eax
  800f0a:	8b 40 48             	mov    0x48(%eax),%eax
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f15:	c7 04 24 2c 23 80 00 	movl   $0x80232c,(%esp)
  800f1c:	e8 42 f2 ff ff       	call   800163 <cprintf>
	*dev = 0;
  800f21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    

00800f31 <fd_close>:
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 20             	sub    $0x20,%esp
  800f39:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f42:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f46:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f4c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f4f:	89 04 24             	mov    %eax,(%esp)
  800f52:	e8 2f ff ff ff       	call   800e86 <fd_lookup>
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 05                	js     800f60 <fd_close+0x2f>
	    || fd != fd2)
  800f5b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f5e:	74 0c                	je     800f6c <fd_close+0x3b>
		return (must_exist ? r : 0);
  800f60:	84 db                	test   %bl,%bl
  800f62:	ba 00 00 00 00       	mov    $0x0,%edx
  800f67:	0f 44 c2             	cmove  %edx,%eax
  800f6a:	eb 3f                	jmp    800fab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f73:	8b 06                	mov    (%esi),%eax
  800f75:	89 04 24             	mov    %eax,(%esp)
  800f78:	e8 5f ff ff ff       	call   800edc <dev_lookup>
  800f7d:	89 c3                	mov    %eax,%ebx
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 16                	js     800f99 <fd_close+0x68>
		if (dev->dev_close)
  800f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f86:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f89:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	74 07                	je     800f99 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800f92:	89 34 24             	mov    %esi,(%esp)
  800f95:	ff d0                	call   *%eax
  800f97:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  800f99:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa4:	e8 a1 fc ff ff       	call   800c4a <sys_page_unmap>
	return r;
  800fa9:	89 d8                	mov    %ebx,%eax
}
  800fab:	83 c4 20             	add    $0x20,%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <close>:

int
close(int fdnum)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	89 04 24             	mov    %eax,(%esp)
  800fc5:	e8 bc fe ff ff       	call   800e86 <fd_lookup>
  800fca:	89 c2                	mov    %eax,%edx
  800fcc:	85 d2                	test   %edx,%edx
  800fce:	78 13                	js     800fe3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  800fd0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fd7:	00 
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 4e ff ff ff       	call   800f31 <fd_close>
}
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <close_all>:

void
close_all(void)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff1:	89 1c 24             	mov    %ebx,(%esp)
  800ff4:	e8 b9 ff ff ff       	call   800fb2 <close>
	for (i = 0; i < MAXFD; i++)
  800ff9:	83 c3 01             	add    $0x1,%ebx
  800ffc:	83 fb 20             	cmp    $0x20,%ebx
  800fff:	75 f0                	jne    800ff1 <close_all+0xc>
}
  801001:	83 c4 14             	add    $0x14,%esp
  801004:	5b                   	pop    %ebx
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801010:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801013:	89 44 24 04          	mov    %eax,0x4(%esp)
  801017:	8b 45 08             	mov    0x8(%ebp),%eax
  80101a:	89 04 24             	mov    %eax,(%esp)
  80101d:	e8 64 fe ff ff       	call   800e86 <fd_lookup>
  801022:	89 c2                	mov    %eax,%edx
  801024:	85 d2                	test   %edx,%edx
  801026:	0f 88 e1 00 00 00    	js     80110d <dup+0x106>
		return r;
	close(newfdnum);
  80102c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102f:	89 04 24             	mov    %eax,(%esp)
  801032:	e8 7b ff ff ff       	call   800fb2 <close>

	newfd = INDEX2FD(newfdnum);
  801037:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80103a:	c1 e3 0c             	shl    $0xc,%ebx
  80103d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801043:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801046:	89 04 24             	mov    %eax,(%esp)
  801049:	e8 d2 fd ff ff       	call   800e20 <fd2data>
  80104e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801050:	89 1c 24             	mov    %ebx,(%esp)
  801053:	e8 c8 fd ff ff       	call   800e20 <fd2data>
  801058:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80105a:	89 f0                	mov    %esi,%eax
  80105c:	c1 e8 16             	shr    $0x16,%eax
  80105f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801066:	a8 01                	test   $0x1,%al
  801068:	74 43                	je     8010ad <dup+0xa6>
  80106a:	89 f0                	mov    %esi,%eax
  80106c:	c1 e8 0c             	shr    $0xc,%eax
  80106f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801076:	f6 c2 01             	test   $0x1,%dl
  801079:	74 32                	je     8010ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801082:	25 07 0e 00 00       	and    $0xe07,%eax
  801087:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80108f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801096:	00 
  801097:	89 74 24 04          	mov    %esi,0x4(%esp)
  80109b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a2:	e8 50 fb ff ff       	call   800bf7 <sys_page_map>
  8010a7:	89 c6                	mov    %eax,%esi
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 3e                	js     8010eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b0:	89 c2                	mov    %eax,%edx
  8010b2:	c1 ea 0c             	shr    $0xc,%edx
  8010b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010d1:	00 
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010dd:	e8 15 fb ff ff       	call   800bf7 <sys_page_map>
  8010e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8010e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e7:	85 f6                	test   %esi,%esi
  8010e9:	79 22                	jns    80110d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8010eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f6:	e8 4f fb ff ff       	call   800c4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801106:	e8 3f fb ff ff       	call   800c4a <sys_page_unmap>
	return r;
  80110b:	89 f0                	mov    %esi,%eax
}
  80110d:	83 c4 3c             	add    $0x3c,%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	53                   	push   %ebx
  801119:	83 ec 24             	sub    $0x24,%esp
  80111c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801122:	89 44 24 04          	mov    %eax,0x4(%esp)
  801126:	89 1c 24             	mov    %ebx,(%esp)
  801129:	e8 58 fd ff ff       	call   800e86 <fd_lookup>
  80112e:	89 c2                	mov    %eax,%edx
  801130:	85 d2                	test   %edx,%edx
  801132:	78 6d                	js     8011a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801134:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113e:	8b 00                	mov    (%eax),%eax
  801140:	89 04 24             	mov    %eax,(%esp)
  801143:	e8 94 fd ff ff       	call   800edc <dev_lookup>
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 55                	js     8011a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80114c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114f:	8b 50 08             	mov    0x8(%eax),%edx
  801152:	83 e2 03             	and    $0x3,%edx
  801155:	83 fa 01             	cmp    $0x1,%edx
  801158:	75 23                	jne    80117d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115a:	a1 08 40 80 00       	mov    0x804008,%eax
  80115f:	8b 40 48             	mov    0x48(%eax),%eax
  801162:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116a:	c7 04 24 6d 23 80 00 	movl   $0x80236d,(%esp)
  801171:	e8 ed ef ff ff       	call   800163 <cprintf>
		return -E_INVAL;
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117b:	eb 24                	jmp    8011a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80117d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801180:	8b 52 08             	mov    0x8(%edx),%edx
  801183:	85 d2                	test   %edx,%edx
  801185:	74 15                	je     80119c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801187:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80118e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801191:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	ff d2                	call   *%edx
  80119a:	eb 05                	jmp    8011a1 <read+0x8c>
		return -E_NOT_SUPP;
  80119c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8011a1:	83 c4 24             	add    $0x24,%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 1c             	sub    $0x1c,%esp
  8011b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bb:	eb 23                	jmp    8011e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011bd:	89 f0                	mov    %esi,%eax
  8011bf:	29 d8                	sub    %ebx,%eax
  8011c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	03 45 0c             	add    0xc(%ebp),%eax
  8011ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ce:	89 3c 24             	mov    %edi,(%esp)
  8011d1:	e8 3f ff ff ff       	call   801115 <read>
		if (m < 0)
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 10                	js     8011ea <readn+0x43>
			return m;
		if (m == 0)
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	74 0a                	je     8011e8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8011de:	01 c3                	add    %eax,%ebx
  8011e0:	39 f3                	cmp    %esi,%ebx
  8011e2:	72 d9                	jb     8011bd <readn+0x16>
  8011e4:	89 d8                	mov    %ebx,%eax
  8011e6:	eb 02                	jmp    8011ea <readn+0x43>
  8011e8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011ea:	83 c4 1c             	add    $0x1c,%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 24             	sub    $0x24,%esp
  8011f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801203:	89 1c 24             	mov    %ebx,(%esp)
  801206:	e8 7b fc ff ff       	call   800e86 <fd_lookup>
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	85 d2                	test   %edx,%edx
  80120f:	78 68                	js     801279 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	89 44 24 04          	mov    %eax,0x4(%esp)
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	8b 00                	mov    (%eax),%eax
  80121d:	89 04 24             	mov    %eax,(%esp)
  801220:	e8 b7 fc ff ff       	call   800edc <dev_lookup>
  801225:	85 c0                	test   %eax,%eax
  801227:	78 50                	js     801279 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801229:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801230:	75 23                	jne    801255 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801232:	a1 08 40 80 00       	mov    0x804008,%eax
  801237:	8b 40 48             	mov    0x48(%eax),%eax
  80123a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80123e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801242:	c7 04 24 89 23 80 00 	movl   $0x802389,(%esp)
  801249:	e8 15 ef ff ff       	call   800163 <cprintf>
		return -E_INVAL;
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801253:	eb 24                	jmp    801279 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801255:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801258:	8b 52 0c             	mov    0xc(%edx),%edx
  80125b:	85 d2                	test   %edx,%edx
  80125d:	74 15                	je     801274 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80125f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801262:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801266:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801269:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80126d:	89 04 24             	mov    %eax,(%esp)
  801270:	ff d2                	call   *%edx
  801272:	eb 05                	jmp    801279 <write+0x87>
		return -E_NOT_SUPP;
  801274:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801279:	83 c4 24             	add    $0x24,%esp
  80127c:	5b                   	pop    %ebx
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <seek>:

int
seek(int fdnum, off_t offset)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801285:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128c:	8b 45 08             	mov    0x8(%ebp),%eax
  80128f:	89 04 24             	mov    %eax,(%esp)
  801292:	e8 ef fb ff ff       	call   800e86 <fd_lookup>
  801297:	85 c0                	test   %eax,%eax
  801299:	78 0e                	js     8012a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80129b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80129e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	53                   	push   %ebx
  8012af:	83 ec 24             	sub    $0x24,%esp
  8012b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bc:	89 1c 24             	mov    %ebx,(%esp)
  8012bf:	e8 c2 fb ff ff       	call   800e86 <fd_lookup>
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	85 d2                	test   %edx,%edx
  8012c8:	78 61                	js     80132b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	8b 00                	mov    (%eax),%eax
  8012d6:	89 04 24             	mov    %eax,(%esp)
  8012d9:	e8 fe fb ff ff       	call   800edc <dev_lookup>
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 49                	js     80132b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e9:	75 23                	jne    80130e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012eb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f0:	8b 40 48             	mov    0x48(%eax),%eax
  8012f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fb:	c7 04 24 4c 23 80 00 	movl   $0x80234c,(%esp)
  801302:	e8 5c ee ff ff       	call   800163 <cprintf>
		return -E_INVAL;
  801307:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130c:	eb 1d                	jmp    80132b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80130e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801311:	8b 52 18             	mov    0x18(%edx),%edx
  801314:	85 d2                	test   %edx,%edx
  801316:	74 0e                	je     801326 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80131f:	89 04 24             	mov    %eax,(%esp)
  801322:	ff d2                	call   *%edx
  801324:	eb 05                	jmp    80132b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801326:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80132b:	83 c4 24             	add    $0x24,%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	53                   	push   %ebx
  801335:	83 ec 24             	sub    $0x24,%esp
  801338:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801342:	8b 45 08             	mov    0x8(%ebp),%eax
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	e8 39 fb ff ff       	call   800e86 <fd_lookup>
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	85 d2                	test   %edx,%edx
  801351:	78 52                	js     8013a5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801353:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135d:	8b 00                	mov    (%eax),%eax
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	e8 75 fb ff ff       	call   800edc <dev_lookup>
  801367:	85 c0                	test   %eax,%eax
  801369:	78 3a                	js     8013a5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801372:	74 2c                	je     8013a0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801374:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801377:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137e:	00 00 00 
	stat->st_isdir = 0;
  801381:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801388:	00 00 00 
	stat->st_dev = dev;
  80138b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801391:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801395:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801398:	89 14 24             	mov    %edx,(%esp)
  80139b:	ff 50 14             	call   *0x14(%eax)
  80139e:	eb 05                	jmp    8013a5 <fstat+0x74>
		return -E_NOT_SUPP;
  8013a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013a5:	83 c4 24             	add    $0x24,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	56                   	push   %esi
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013ba:	00 
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	89 04 24             	mov    %eax,(%esp)
  8013c1:	e8 fb 01 00 00       	call   8015c1 <open>
  8013c6:	89 c3                	mov    %eax,%ebx
  8013c8:	85 db                	test   %ebx,%ebx
  8013ca:	78 1b                	js     8013e7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d3:	89 1c 24             	mov    %ebx,(%esp)
  8013d6:	e8 56 ff ff ff       	call   801331 <fstat>
  8013db:	89 c6                	mov    %eax,%esi
	close(fd);
  8013dd:	89 1c 24             	mov    %ebx,(%esp)
  8013e0:	e8 cd fb ff ff       	call   800fb2 <close>
	return r;
  8013e5:	89 f0                	mov    %esi,%eax
}
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 10             	sub    $0x10,%esp
  8013f6:	89 c6                	mov    %eax,%esi
  8013f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013fa:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801401:	75 11                	jne    801414 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801403:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80140a:	e8 a0 08 00 00       	call   801caf <ipc_find_env>
  80140f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801414:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80141b:	00 
  80141c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801423:	00 
  801424:	89 74 24 04          	mov    %esi,0x4(%esp)
  801428:	a1 04 40 80 00       	mov    0x804004,%eax
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	e8 13 08 00 00       	call   801c48 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801435:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80143c:	00 
  80143d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801448:	e8 93 07 00 00       	call   801be0 <ipc_recv>
}
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	5b                   	pop    %ebx
  801451:	5e                   	pop    %esi
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    

00801454 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801465:	8b 45 0c             	mov    0xc(%ebp),%eax
  801468:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80146d:	ba 00 00 00 00       	mov    $0x0,%edx
  801472:	b8 02 00 00 00       	mov    $0x2,%eax
  801477:	e8 72 ff ff ff       	call   8013ee <fsipc>
}
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <devfile_flush>:
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	8b 40 0c             	mov    0xc(%eax),%eax
  80148a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80148f:	ba 00 00 00 00       	mov    $0x0,%edx
  801494:	b8 06 00 00 00       	mov    $0x6,%eax
  801499:	e8 50 ff ff ff       	call   8013ee <fsipc>
}
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <devfile_stat>:
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 14             	sub    $0x14,%esp
  8014a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8014bf:	e8 2a ff ff ff       	call   8013ee <fsipc>
  8014c4:	89 c2                	mov    %eax,%edx
  8014c6:	85 d2                	test   %edx,%edx
  8014c8:	78 2b                	js     8014f5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014d1:	00 
  8014d2:	89 1c 24             	mov    %ebx,(%esp)
  8014d5:	e8 ad f2 ff ff       	call   800787 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014da:	a1 80 50 80 00       	mov    0x805080,%eax
  8014df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e5:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f5:	83 c4 14             	add    $0x14,%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <devfile_write>:
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801501:	c7 44 24 08 b8 23 80 	movl   $0x8023b8,0x8(%esp)
  801508:	00 
  801509:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801510:	00 
  801511:	c7 04 24 d6 23 80 00 	movl   $0x8023d6,(%esp)
  801518:	e8 69 06 00 00       	call   801b86 <_panic>

0080151d <devfile_read>:
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 10             	sub    $0x10,%esp
  801525:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801528:	8b 45 08             	mov    0x8(%ebp),%eax
  80152b:	8b 40 0c             	mov    0xc(%eax),%eax
  80152e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801533:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 03 00 00 00       	mov    $0x3,%eax
  801543:	e8 a6 fe ff ff       	call   8013ee <fsipc>
  801548:	89 c3                	mov    %eax,%ebx
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 6a                	js     8015b8 <devfile_read+0x9b>
	assert(r <= n);
  80154e:	39 c6                	cmp    %eax,%esi
  801550:	73 24                	jae    801576 <devfile_read+0x59>
  801552:	c7 44 24 0c e1 23 80 	movl   $0x8023e1,0xc(%esp)
  801559:	00 
  80155a:	c7 44 24 08 e8 23 80 	movl   $0x8023e8,0x8(%esp)
  801561:	00 
  801562:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801569:	00 
  80156a:	c7 04 24 d6 23 80 00 	movl   $0x8023d6,(%esp)
  801571:	e8 10 06 00 00       	call   801b86 <_panic>
	assert(r <= PGSIZE);
  801576:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80157b:	7e 24                	jle    8015a1 <devfile_read+0x84>
  80157d:	c7 44 24 0c fd 23 80 	movl   $0x8023fd,0xc(%esp)
  801584:	00 
  801585:	c7 44 24 08 e8 23 80 	movl   $0x8023e8,0x8(%esp)
  80158c:	00 
  80158d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801594:	00 
  801595:	c7 04 24 d6 23 80 00 	movl   $0x8023d6,(%esp)
  80159c:	e8 e5 05 00 00       	call   801b86 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015a5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015ac:	00 
  8015ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b0:	89 04 24             	mov    %eax,(%esp)
  8015b3:	e8 6c f3 ff ff       	call   800924 <memmove>
}
  8015b8:	89 d8                	mov    %ebx,%eax
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	5b                   	pop    %ebx
  8015be:	5e                   	pop    %esi
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <open>:
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 24             	sub    $0x24,%esp
  8015c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8015cb:	89 1c 24             	mov    %ebx,(%esp)
  8015ce:	e8 7d f1 ff ff       	call   800750 <strlen>
  8015d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d8:	7f 60                	jg     80163a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	89 04 24             	mov    %eax,(%esp)
  8015e0:	e8 52 f8 ff ff       	call   800e37 <fd_alloc>
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	85 d2                	test   %edx,%edx
  8015e9:	78 54                	js     80163f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8015eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ef:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015f6:	e8 8c f1 ff ff       	call   800787 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fe:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801603:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801606:	b8 01 00 00 00       	mov    $0x1,%eax
  80160b:	e8 de fd ff ff       	call   8013ee <fsipc>
  801610:	89 c3                	mov    %eax,%ebx
  801612:	85 c0                	test   %eax,%eax
  801614:	79 17                	jns    80162d <open+0x6c>
		fd_close(fd, 0);
  801616:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80161d:	00 
  80161e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801621:	89 04 24             	mov    %eax,(%esp)
  801624:	e8 08 f9 ff ff       	call   800f31 <fd_close>
		return r;
  801629:	89 d8                	mov    %ebx,%eax
  80162b:	eb 12                	jmp    80163f <open+0x7e>
	return fd2num(fd);
  80162d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801630:	89 04 24             	mov    %eax,(%esp)
  801633:	e8 d8 f7 ff ff       	call   800e10 <fd2num>
  801638:	eb 05                	jmp    80163f <open+0x7e>
		return -E_BAD_PATH;
  80163a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80163f:	83 c4 24             	add    $0x24,%esp
  801642:	5b                   	pop    %ebx
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164b:	ba 00 00 00 00       	mov    $0x0,%edx
  801650:	b8 08 00 00 00       	mov    $0x8,%eax
  801655:	e8 94 fd ff ff       	call   8013ee <fsipc>
}
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 10             	sub    $0x10,%esp
  801664:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	89 04 24             	mov    %eax,(%esp)
  80166d:	e8 ae f7 ff ff       	call   800e20 <fd2data>
  801672:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801674:	c7 44 24 04 09 24 80 	movl   $0x802409,0x4(%esp)
  80167b:	00 
  80167c:	89 1c 24             	mov    %ebx,(%esp)
  80167f:	e8 03 f1 ff ff       	call   800787 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801684:	8b 46 04             	mov    0x4(%esi),%eax
  801687:	2b 06                	sub    (%esi),%eax
  801689:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80168f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801696:	00 00 00 
	stat->st_dev = &devpipe;
  801699:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016a0:	30 80 00 
	return 0;
}
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 14             	sub    $0x14,%esp
  8016b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c4:	e8 81 f5 ff ff       	call   800c4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016c9:	89 1c 24             	mov    %ebx,(%esp)
  8016cc:	e8 4f f7 ff ff       	call   800e20 <fd2data>
  8016d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016dc:	e8 69 f5 ff ff       	call   800c4a <sys_page_unmap>
}
  8016e1:	83 c4 14             	add    $0x14,%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <_pipeisclosed>:
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	57                   	push   %edi
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 2c             	sub    $0x2c,%esp
  8016f0:	89 c6                	mov    %eax,%esi
  8016f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8016f5:	a1 08 40 80 00       	mov    0x804008,%eax
  8016fa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016fd:	89 34 24             	mov    %esi,(%esp)
  801700:	e8 e2 05 00 00       	call   801ce7 <pageref>
  801705:	89 c7                	mov    %eax,%edi
  801707:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80170a:	89 04 24             	mov    %eax,(%esp)
  80170d:	e8 d5 05 00 00       	call   801ce7 <pageref>
  801712:	39 c7                	cmp    %eax,%edi
  801714:	0f 94 c2             	sete   %dl
  801717:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80171a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801720:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801723:	39 fb                	cmp    %edi,%ebx
  801725:	74 21                	je     801748 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801727:	84 d2                	test   %dl,%dl
  801729:	74 ca                	je     8016f5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80172b:	8b 51 58             	mov    0x58(%ecx),%edx
  80172e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801732:	89 54 24 08          	mov    %edx,0x8(%esp)
  801736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80173a:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  801741:	e8 1d ea ff ff       	call   800163 <cprintf>
  801746:	eb ad                	jmp    8016f5 <_pipeisclosed+0xe>
}
  801748:	83 c4 2c             	add    $0x2c,%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5f                   	pop    %edi
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <devpipe_write>:
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	57                   	push   %edi
  801754:	56                   	push   %esi
  801755:	53                   	push   %ebx
  801756:	83 ec 1c             	sub    $0x1c,%esp
  801759:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80175c:	89 34 24             	mov    %esi,(%esp)
  80175f:	e8 bc f6 ff ff       	call   800e20 <fd2data>
  801764:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801766:	bf 00 00 00 00       	mov    $0x0,%edi
  80176b:	eb 45                	jmp    8017b2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  80176d:	89 da                	mov    %ebx,%edx
  80176f:	89 f0                	mov    %esi,%eax
  801771:	e8 71 ff ff ff       	call   8016e7 <_pipeisclosed>
  801776:	85 c0                	test   %eax,%eax
  801778:	75 41                	jne    8017bb <devpipe_write+0x6b>
			sys_yield();
  80177a:	e8 05 f4 ff ff       	call   800b84 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80177f:	8b 43 04             	mov    0x4(%ebx),%eax
  801782:	8b 0b                	mov    (%ebx),%ecx
  801784:	8d 51 20             	lea    0x20(%ecx),%edx
  801787:	39 d0                	cmp    %edx,%eax
  801789:	73 e2                	jae    80176d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80178b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801792:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801795:	99                   	cltd   
  801796:	c1 ea 1b             	shr    $0x1b,%edx
  801799:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80179c:	83 e1 1f             	and    $0x1f,%ecx
  80179f:	29 d1                	sub    %edx,%ecx
  8017a1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8017a5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8017a9:	83 c0 01             	add    $0x1,%eax
  8017ac:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017af:	83 c7 01             	add    $0x1,%edi
  8017b2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017b5:	75 c8                	jne    80177f <devpipe_write+0x2f>
	return i;
  8017b7:	89 f8                	mov    %edi,%eax
  8017b9:	eb 05                	jmp    8017c0 <devpipe_write+0x70>
				return 0;
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c0:	83 c4 1c             	add    $0x1c,%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5f                   	pop    %edi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <devpipe_read>:
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	57                   	push   %edi
  8017cc:	56                   	push   %esi
  8017cd:	53                   	push   %ebx
  8017ce:	83 ec 1c             	sub    $0x1c,%esp
  8017d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017d4:	89 3c 24             	mov    %edi,(%esp)
  8017d7:	e8 44 f6 ff ff       	call   800e20 <fd2data>
  8017dc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017de:	be 00 00 00 00       	mov    $0x0,%esi
  8017e3:	eb 3d                	jmp    801822 <devpipe_read+0x5a>
			if (i > 0)
  8017e5:	85 f6                	test   %esi,%esi
  8017e7:	74 04                	je     8017ed <devpipe_read+0x25>
				return i;
  8017e9:	89 f0                	mov    %esi,%eax
  8017eb:	eb 43                	jmp    801830 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  8017ed:	89 da                	mov    %ebx,%edx
  8017ef:	89 f8                	mov    %edi,%eax
  8017f1:	e8 f1 fe ff ff       	call   8016e7 <_pipeisclosed>
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	75 31                	jne    80182b <devpipe_read+0x63>
			sys_yield();
  8017fa:	e8 85 f3 ff ff       	call   800b84 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017ff:	8b 03                	mov    (%ebx),%eax
  801801:	3b 43 04             	cmp    0x4(%ebx),%eax
  801804:	74 df                	je     8017e5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801806:	99                   	cltd   
  801807:	c1 ea 1b             	shr    $0x1b,%edx
  80180a:	01 d0                	add    %edx,%eax
  80180c:	83 e0 1f             	and    $0x1f,%eax
  80180f:	29 d0                	sub    %edx,%eax
  801811:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801819:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80181c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80181f:	83 c6 01             	add    $0x1,%esi
  801822:	3b 75 10             	cmp    0x10(%ebp),%esi
  801825:	75 d8                	jne    8017ff <devpipe_read+0x37>
	return i;
  801827:	89 f0                	mov    %esi,%eax
  801829:	eb 05                	jmp    801830 <devpipe_read+0x68>
				return 0;
  80182b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801830:	83 c4 1c             	add    $0x1c,%esp
  801833:	5b                   	pop    %ebx
  801834:	5e                   	pop    %esi
  801835:	5f                   	pop    %edi
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <pipe>:
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801843:	89 04 24             	mov    %eax,(%esp)
  801846:	e8 ec f5 ff ff       	call   800e37 <fd_alloc>
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	85 d2                	test   %edx,%edx
  80184f:	0f 88 4d 01 00 00    	js     8019a2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801855:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80185c:	00 
  80185d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801860:	89 44 24 04          	mov    %eax,0x4(%esp)
  801864:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186b:	e8 33 f3 ff ff       	call   800ba3 <sys_page_alloc>
  801870:	89 c2                	mov    %eax,%edx
  801872:	85 d2                	test   %edx,%edx
  801874:	0f 88 28 01 00 00    	js     8019a2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  80187a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187d:	89 04 24             	mov    %eax,(%esp)
  801880:	e8 b2 f5 ff ff       	call   800e37 <fd_alloc>
  801885:	89 c3                	mov    %eax,%ebx
  801887:	85 c0                	test   %eax,%eax
  801889:	0f 88 fe 00 00 00    	js     80198d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801896:	00 
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a5:	e8 f9 f2 ff ff       	call   800ba3 <sys_page_alloc>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	0f 88 d9 00 00 00    	js     80198d <pipe+0x155>
	va = fd2data(fd0);
  8018b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b7:	89 04 24             	mov    %eax,(%esp)
  8018ba:	e8 61 f5 ff ff       	call   800e20 <fd2data>
  8018bf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018c8:	00 
  8018c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d4:	e8 ca f2 ff ff       	call   800ba3 <sys_page_alloc>
  8018d9:	89 c3                	mov    %eax,%ebx
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	0f 88 97 00 00 00    	js     80197a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e6:	89 04 24             	mov    %eax,(%esp)
  8018e9:	e8 32 f5 ff ff       	call   800e20 <fd2data>
  8018ee:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8018f5:	00 
  8018f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801901:	00 
  801902:	89 74 24 04          	mov    %esi,0x4(%esp)
  801906:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190d:	e8 e5 f2 ff ff       	call   800bf7 <sys_page_map>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	85 c0                	test   %eax,%eax
  801916:	78 52                	js     80196a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801918:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80191e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801921:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801926:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80192d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801933:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801936:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801942:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801945:	89 04 24             	mov    %eax,(%esp)
  801948:	e8 c3 f4 ff ff       	call   800e10 <fd2num>
  80194d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801950:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801952:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801955:	89 04 24             	mov    %eax,(%esp)
  801958:	e8 b3 f4 ff ff       	call   800e10 <fd2num>
  80195d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801960:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801963:	b8 00 00 00 00       	mov    $0x0,%eax
  801968:	eb 38                	jmp    8019a2 <pipe+0x16a>
	sys_page_unmap(0, va);
  80196a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80196e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801975:	e8 d0 f2 ff ff       	call   800c4a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  80197a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801981:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801988:	e8 bd f2 ff ff       	call   800c4a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  80198d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801990:	89 44 24 04          	mov    %eax,0x4(%esp)
  801994:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199b:	e8 aa f2 ff ff       	call   800c4a <sys_page_unmap>
  8019a0:	89 d8                	mov    %ebx,%eax
}
  8019a2:	83 c4 30             	add    $0x30,%esp
  8019a5:	5b                   	pop    %ebx
  8019a6:	5e                   	pop    %esi
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <pipeisclosed>:
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b9:	89 04 24             	mov    %eax,(%esp)
  8019bc:	e8 c5 f4 ff ff       	call   800e86 <fd_lookup>
  8019c1:	89 c2                	mov    %eax,%edx
  8019c3:	85 d2                	test   %edx,%edx
  8019c5:	78 15                	js     8019dc <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  8019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ca:	89 04 24             	mov    %eax,(%esp)
  8019cd:	e8 4e f4 ff ff       	call   800e20 <fd2data>
	return _pipeisclosed(fd, p);
  8019d2:	89 c2                	mov    %eax,%edx
  8019d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d7:	e8 0b fd ff ff       	call   8016e7 <_pipeisclosed>
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    
  8019de:	66 90                	xchg   %ax,%ax

008019e0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8019f0:	c7 44 24 04 28 24 80 	movl   $0x802428,0x4(%esp)
  8019f7:	00 
  8019f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fb:	89 04 24             	mov    %eax,(%esp)
  8019fe:	e8 84 ed ff ff       	call   800787 <strcpy>
	return 0;
}
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devcons_write>:
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	57                   	push   %edi
  801a0e:	56                   	push   %esi
  801a0f:	53                   	push   %ebx
  801a10:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a16:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a21:	eb 31                	jmp    801a54 <devcons_write+0x4a>
		m = n - tot;
  801a23:	8b 75 10             	mov    0x10(%ebp),%esi
  801a26:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a28:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801a2b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a30:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a33:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a37:	03 45 0c             	add    0xc(%ebp),%eax
  801a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3e:	89 3c 24             	mov    %edi,(%esp)
  801a41:	e8 de ee ff ff       	call   800924 <memmove>
		sys_cputs(buf, m);
  801a46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a4a:	89 3c 24             	mov    %edi,(%esp)
  801a4d:	e8 84 f0 ff ff       	call   800ad6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a52:	01 f3                	add    %esi,%ebx
  801a54:	89 d8                	mov    %ebx,%eax
  801a56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a59:	72 c8                	jb     801a23 <devcons_write+0x19>
}
  801a5b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a61:	5b                   	pop    %ebx
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <devcons_read>:
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801a6c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a75:	75 07                	jne    801a7e <devcons_read+0x18>
  801a77:	eb 2a                	jmp    801aa3 <devcons_read+0x3d>
		sys_yield();
  801a79:	e8 06 f1 ff ff       	call   800b84 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a7e:	66 90                	xchg   %ax,%ax
  801a80:	e8 6f f0 ff ff       	call   800af4 <sys_cgetc>
  801a85:	85 c0                	test   %eax,%eax
  801a87:	74 f0                	je     801a79 <devcons_read+0x13>
	if (c < 0)
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 16                	js     801aa3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801a8d:	83 f8 04             	cmp    $0x4,%eax
  801a90:	74 0c                	je     801a9e <devcons_read+0x38>
	*(char*)vbuf = c;
  801a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a95:	88 02                	mov    %al,(%edx)
	return 1;
  801a97:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9c:	eb 05                	jmp    801aa3 <devcons_read+0x3d>
		return 0;
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <cputchar>:
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ab1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ab8:	00 
  801ab9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801abc:	89 04 24             	mov    %eax,(%esp)
  801abf:	e8 12 f0 ff ff       	call   800ad6 <sys_cputs>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <getchar>:
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801acc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ad3:	00 
  801ad4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae2:	e8 2e f6 ff ff       	call   801115 <read>
	if (r < 0)
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 0f                	js     801afa <getchar+0x34>
	if (r < 1)
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	7e 06                	jle    801af5 <getchar+0x2f>
	return c;
  801aef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801af3:	eb 05                	jmp    801afa <getchar+0x34>
		return -E_EOF;
  801af5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <iscons>:
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	e8 72 f3 ff ff       	call   800e86 <fd_lookup>
  801b14:	85 c0                	test   %eax,%eax
  801b16:	78 11                	js     801b29 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b21:	39 10                	cmp    %edx,(%eax)
  801b23:	0f 94 c0             	sete   %al
  801b26:	0f b6 c0             	movzbl %al,%eax
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <opencons>:
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b34:	89 04 24             	mov    %eax,(%esp)
  801b37:	e8 fb f2 ff ff       	call   800e37 <fd_alloc>
		return r;
  801b3c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 40                	js     801b82 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b42:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b49:	00 
  801b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b58:	e8 46 f0 ff ff       	call   800ba3 <sys_page_alloc>
		return r;
  801b5d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 1f                	js     801b82 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801b63:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b71:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b78:	89 04 24             	mov    %eax,(%esp)
  801b7b:	e8 90 f2 ff ff       	call   800e10 <fd2num>
  801b80:	89 c2                	mov    %eax,%edx
}
  801b82:	89 d0                	mov    %edx,%eax
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	56                   	push   %esi
  801b8a:	53                   	push   %ebx
  801b8b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b8e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b91:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b97:	e8 c9 ef ff ff       	call   800b65 <sys_getenvid>
  801b9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b9f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ba6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801baa:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb2:	c7 04 24 34 24 80 00 	movl   $0x802434,(%esp)
  801bb9:	e8 a5 e5 ff ff       	call   800163 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc5:	89 04 24             	mov    %eax,(%esp)
  801bc8:	e8 35 e5 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801bcd:	c7 04 24 21 24 80 00 	movl   $0x802421,(%esp)
  801bd4:	e8 8a e5 ff ff       	call   800163 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bd9:	cc                   	int3   
  801bda:	eb fd                	jmp    801bd9 <_panic+0x53>
  801bdc:	66 90                	xchg   %ax,%ax
  801bde:	66 90                	xchg   %ax,%ax

00801be0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 10             	sub    $0x10,%esp
  801be8:	8b 75 08             	mov    0x8(%ebp),%esi
  801beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bee:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801bf1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801bf3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801bf8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801bfb:	89 04 24             	mov    %eax,(%esp)
  801bfe:	e8 b6 f1 ff ff       	call   800db9 <sys_ipc_recv>
    if(r < 0){
  801c03:	85 c0                	test   %eax,%eax
  801c05:	79 16                	jns    801c1d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801c07:	85 f6                	test   %esi,%esi
  801c09:	74 06                	je     801c11 <ipc_recv+0x31>
            *from_env_store = 0;
  801c0b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801c11:	85 db                	test   %ebx,%ebx
  801c13:	74 2c                	je     801c41 <ipc_recv+0x61>
            *perm_store = 0;
  801c15:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c1b:	eb 24                	jmp    801c41 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801c1d:	85 f6                	test   %esi,%esi
  801c1f:	74 0a                	je     801c2b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801c21:	a1 08 40 80 00       	mov    0x804008,%eax
  801c26:	8b 40 74             	mov    0x74(%eax),%eax
  801c29:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801c2b:	85 db                	test   %ebx,%ebx
  801c2d:	74 0a                	je     801c39 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801c2f:	a1 08 40 80 00       	mov    0x804008,%eax
  801c34:	8b 40 78             	mov    0x78(%eax),%eax
  801c37:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c39:	a1 08 40 80 00       	mov    0x804008,%eax
  801c3e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	57                   	push   %edi
  801c4c:	56                   	push   %esi
  801c4d:	53                   	push   %ebx
  801c4e:	83 ec 1c             	sub    $0x1c,%esp
  801c51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801c5a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801c5c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801c61:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801c64:	8b 45 14             	mov    0x14(%ebp),%eax
  801c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c73:	89 3c 24             	mov    %edi,(%esp)
  801c76:	e8 1b f1 ff ff       	call   800d96 <sys_ipc_try_send>
        if(r == 0){
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	74 28                	je     801ca7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801c7f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c82:	74 1c                	je     801ca0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801c84:	c7 44 24 08 58 24 80 	movl   $0x802458,0x8(%esp)
  801c8b:	00 
  801c8c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801c93:	00 
  801c94:	c7 04 24 6f 24 80 00 	movl   $0x80246f,(%esp)
  801c9b:	e8 e6 fe ff ff       	call   801b86 <_panic>
        }
        sys_yield();
  801ca0:	e8 df ee ff ff       	call   800b84 <sys_yield>
    }
  801ca5:	eb bd                	jmp    801c64 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801ca7:	83 c4 1c             	add    $0x1c,%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cbd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cc3:	8b 52 50             	mov    0x50(%edx),%edx
  801cc6:	39 ca                	cmp    %ecx,%edx
  801cc8:	75 0d                	jne    801cd7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ccd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cd2:	8b 40 40             	mov    0x40(%eax),%eax
  801cd5:	eb 0e                	jmp    801ce5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801cd7:	83 c0 01             	add    $0x1,%eax
  801cda:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cdf:	75 d9                	jne    801cba <ipc_find_env+0xb>
	return 0;
  801ce1:	66 b8 00 00          	mov    $0x0,%ax
}
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ced:	89 d0                	mov    %edx,%eax
  801cef:	c1 e8 16             	shr    $0x16,%eax
  801cf2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cf9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801cfe:	f6 c1 01             	test   $0x1,%cl
  801d01:	74 1d                	je     801d20 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801d03:	c1 ea 0c             	shr    $0xc,%edx
  801d06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d0d:	f6 c2 01             	test   $0x1,%dl
  801d10:	74 0e                	je     801d20 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d12:	c1 ea 0c             	shr    $0xc,%edx
  801d15:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d1c:	ef 
  801d1d:	0f b7 c0             	movzwl %ax,%eax
}
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	66 90                	xchg   %ax,%ax
  801d24:	66 90                	xchg   %ax,%ax
  801d26:	66 90                	xchg   %ax,%ax
  801d28:	66 90                	xchg   %ax,%ax
  801d2a:	66 90                	xchg   %ax,%ax
  801d2c:	66 90                	xchg   %ax,%ax
  801d2e:	66 90                	xchg   %ax,%ax

00801d30 <__udivdi3>:
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	83 ec 0c             	sub    $0xc,%esp
  801d36:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d46:	85 c0                	test   %eax,%eax
  801d48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d4c:	89 ea                	mov    %ebp,%edx
  801d4e:	89 0c 24             	mov    %ecx,(%esp)
  801d51:	75 2d                	jne    801d80 <__udivdi3+0x50>
  801d53:	39 e9                	cmp    %ebp,%ecx
  801d55:	77 61                	ja     801db8 <__udivdi3+0x88>
  801d57:	85 c9                	test   %ecx,%ecx
  801d59:	89 ce                	mov    %ecx,%esi
  801d5b:	75 0b                	jne    801d68 <__udivdi3+0x38>
  801d5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d62:	31 d2                	xor    %edx,%edx
  801d64:	f7 f1                	div    %ecx
  801d66:	89 c6                	mov    %eax,%esi
  801d68:	31 d2                	xor    %edx,%edx
  801d6a:	89 e8                	mov    %ebp,%eax
  801d6c:	f7 f6                	div    %esi
  801d6e:	89 c5                	mov    %eax,%ebp
  801d70:	89 f8                	mov    %edi,%eax
  801d72:	f7 f6                	div    %esi
  801d74:	89 ea                	mov    %ebp,%edx
  801d76:	83 c4 0c             	add    $0xc,%esp
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi
  801d80:	39 e8                	cmp    %ebp,%eax
  801d82:	77 24                	ja     801da8 <__udivdi3+0x78>
  801d84:	0f bd e8             	bsr    %eax,%ebp
  801d87:	83 f5 1f             	xor    $0x1f,%ebp
  801d8a:	75 3c                	jne    801dc8 <__udivdi3+0x98>
  801d8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d90:	39 34 24             	cmp    %esi,(%esp)
  801d93:	0f 86 9f 00 00 00    	jbe    801e38 <__udivdi3+0x108>
  801d99:	39 d0                	cmp    %edx,%eax
  801d9b:	0f 82 97 00 00 00    	jb     801e38 <__udivdi3+0x108>
  801da1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da8:	31 d2                	xor    %edx,%edx
  801daa:	31 c0                	xor    %eax,%eax
  801dac:	83 c4 0c             	add    $0xc,%esp
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    
  801db3:	90                   	nop
  801db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db8:	89 f8                	mov    %edi,%eax
  801dba:	f7 f1                	div    %ecx
  801dbc:	31 d2                	xor    %edx,%edx
  801dbe:	83 c4 0c             	add    $0xc,%esp
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    
  801dc5:	8d 76 00             	lea    0x0(%esi),%esi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	8b 3c 24             	mov    (%esp),%edi
  801dcd:	d3 e0                	shl    %cl,%eax
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd6:	29 e8                	sub    %ebp,%eax
  801dd8:	89 c1                	mov    %eax,%ecx
  801dda:	d3 ef                	shr    %cl,%edi
  801ddc:	89 e9                	mov    %ebp,%ecx
  801dde:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801de2:	8b 3c 24             	mov    (%esp),%edi
  801de5:	09 74 24 08          	or     %esi,0x8(%esp)
  801de9:	89 d6                	mov    %edx,%esi
  801deb:	d3 e7                	shl    %cl,%edi
  801ded:	89 c1                	mov    %eax,%ecx
  801def:	89 3c 24             	mov    %edi,(%esp)
  801df2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801df6:	d3 ee                	shr    %cl,%esi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	d3 e2                	shl    %cl,%edx
  801dfc:	89 c1                	mov    %eax,%ecx
  801dfe:	d3 ef                	shr    %cl,%edi
  801e00:	09 d7                	or     %edx,%edi
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	89 f8                	mov    %edi,%eax
  801e06:	f7 74 24 08          	divl   0x8(%esp)
  801e0a:	89 d6                	mov    %edx,%esi
  801e0c:	89 c7                	mov    %eax,%edi
  801e0e:	f7 24 24             	mull   (%esp)
  801e11:	39 d6                	cmp    %edx,%esi
  801e13:	89 14 24             	mov    %edx,(%esp)
  801e16:	72 30                	jb     801e48 <__udivdi3+0x118>
  801e18:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e1c:	89 e9                	mov    %ebp,%ecx
  801e1e:	d3 e2                	shl    %cl,%edx
  801e20:	39 c2                	cmp    %eax,%edx
  801e22:	73 05                	jae    801e29 <__udivdi3+0xf9>
  801e24:	3b 34 24             	cmp    (%esp),%esi
  801e27:	74 1f                	je     801e48 <__udivdi3+0x118>
  801e29:	89 f8                	mov    %edi,%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	e9 7a ff ff ff       	jmp    801dac <__udivdi3+0x7c>
  801e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e38:	31 d2                	xor    %edx,%edx
  801e3a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3f:	e9 68 ff ff ff       	jmp    801dac <__udivdi3+0x7c>
  801e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e48:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	83 c4 0c             	add    $0xc,%esp
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    
  801e54:	66 90                	xchg   %ax,%ax
  801e56:	66 90                	xchg   %ax,%ax
  801e58:	66 90                	xchg   %ax,%ax
  801e5a:	66 90                	xchg   %ax,%ax
  801e5c:	66 90                	xchg   %ax,%ax
  801e5e:	66 90                	xchg   %ax,%ax

00801e60 <__umoddi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	83 ec 14             	sub    $0x14,%esp
  801e66:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e6e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e72:	89 c7                	mov    %eax,%edi
  801e74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e78:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e80:	89 34 24             	mov    %esi,(%esp)
  801e83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e87:	85 c0                	test   %eax,%eax
  801e89:	89 c2                	mov    %eax,%edx
  801e8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e8f:	75 17                	jne    801ea8 <__umoddi3+0x48>
  801e91:	39 fe                	cmp    %edi,%esi
  801e93:	76 4b                	jbe    801ee0 <__umoddi3+0x80>
  801e95:	89 c8                	mov    %ecx,%eax
  801e97:	89 fa                	mov    %edi,%edx
  801e99:	f7 f6                	div    %esi
  801e9b:	89 d0                	mov    %edx,%eax
  801e9d:	31 d2                	xor    %edx,%edx
  801e9f:	83 c4 14             	add    $0x14,%esp
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    
  801ea6:	66 90                	xchg   %ax,%ax
  801ea8:	39 f8                	cmp    %edi,%eax
  801eaa:	77 54                	ja     801f00 <__umoddi3+0xa0>
  801eac:	0f bd e8             	bsr    %eax,%ebp
  801eaf:	83 f5 1f             	xor    $0x1f,%ebp
  801eb2:	75 5c                	jne    801f10 <__umoddi3+0xb0>
  801eb4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801eb8:	39 3c 24             	cmp    %edi,(%esp)
  801ebb:	0f 87 e7 00 00 00    	ja     801fa8 <__umoddi3+0x148>
  801ec1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ec5:	29 f1                	sub    %esi,%ecx
  801ec7:	19 c7                	sbb    %eax,%edi
  801ec9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ecd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ed1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ed5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ed9:	83 c4 14             	add    $0x14,%esp
  801edc:	5e                   	pop    %esi
  801edd:	5f                   	pop    %edi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    
  801ee0:	85 f6                	test   %esi,%esi
  801ee2:	89 f5                	mov    %esi,%ebp
  801ee4:	75 0b                	jne    801ef1 <__umoddi3+0x91>
  801ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  801eeb:	31 d2                	xor    %edx,%edx
  801eed:	f7 f6                	div    %esi
  801eef:	89 c5                	mov    %eax,%ebp
  801ef1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ef5:	31 d2                	xor    %edx,%edx
  801ef7:	f7 f5                	div    %ebp
  801ef9:	89 c8                	mov    %ecx,%eax
  801efb:	f7 f5                	div    %ebp
  801efd:	eb 9c                	jmp    801e9b <__umoddi3+0x3b>
  801eff:	90                   	nop
  801f00:	89 c8                	mov    %ecx,%eax
  801f02:	89 fa                	mov    %edi,%edx
  801f04:	83 c4 14             	add    $0x14,%esp
  801f07:	5e                   	pop    %esi
  801f08:	5f                   	pop    %edi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    
  801f0b:	90                   	nop
  801f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f10:	8b 04 24             	mov    (%esp),%eax
  801f13:	be 20 00 00 00       	mov    $0x20,%esi
  801f18:	89 e9                	mov    %ebp,%ecx
  801f1a:	29 ee                	sub    %ebp,%esi
  801f1c:	d3 e2                	shl    %cl,%edx
  801f1e:	89 f1                	mov    %esi,%ecx
  801f20:	d3 e8                	shr    %cl,%eax
  801f22:	89 e9                	mov    %ebp,%ecx
  801f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f28:	8b 04 24             	mov    (%esp),%eax
  801f2b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f2f:	89 fa                	mov    %edi,%edx
  801f31:	d3 e0                	shl    %cl,%eax
  801f33:	89 f1                	mov    %esi,%ecx
  801f35:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f39:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f3d:	d3 ea                	shr    %cl,%edx
  801f3f:	89 e9                	mov    %ebp,%ecx
  801f41:	d3 e7                	shl    %cl,%edi
  801f43:	89 f1                	mov    %esi,%ecx
  801f45:	d3 e8                	shr    %cl,%eax
  801f47:	89 e9                	mov    %ebp,%ecx
  801f49:	09 f8                	or     %edi,%eax
  801f4b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f4f:	f7 74 24 04          	divl   0x4(%esp)
  801f53:	d3 e7                	shl    %cl,%edi
  801f55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f59:	89 d7                	mov    %edx,%edi
  801f5b:	f7 64 24 08          	mull   0x8(%esp)
  801f5f:	39 d7                	cmp    %edx,%edi
  801f61:	89 c1                	mov    %eax,%ecx
  801f63:	89 14 24             	mov    %edx,(%esp)
  801f66:	72 2c                	jb     801f94 <__umoddi3+0x134>
  801f68:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f6c:	72 22                	jb     801f90 <__umoddi3+0x130>
  801f6e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f72:	29 c8                	sub    %ecx,%eax
  801f74:	19 d7                	sbb    %edx,%edi
  801f76:	89 e9                	mov    %ebp,%ecx
  801f78:	89 fa                	mov    %edi,%edx
  801f7a:	d3 e8                	shr    %cl,%eax
  801f7c:	89 f1                	mov    %esi,%ecx
  801f7e:	d3 e2                	shl    %cl,%edx
  801f80:	89 e9                	mov    %ebp,%ecx
  801f82:	d3 ef                	shr    %cl,%edi
  801f84:	09 d0                	or     %edx,%eax
  801f86:	89 fa                	mov    %edi,%edx
  801f88:	83 c4 14             	add    $0x14,%esp
  801f8b:	5e                   	pop    %esi
  801f8c:	5f                   	pop    %edi
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    
  801f8f:	90                   	nop
  801f90:	39 d7                	cmp    %edx,%edi
  801f92:	75 da                	jne    801f6e <__umoddi3+0x10e>
  801f94:	8b 14 24             	mov    (%esp),%edx
  801f97:	89 c1                	mov    %eax,%ecx
  801f99:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801f9d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801fa1:	eb cb                	jmp    801f6e <__umoddi3+0x10e>
  801fa3:	90                   	nop
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801fac:	0f 82 0f ff ff ff    	jb     801ec1 <__umoddi3+0x61>
  801fb2:	e9 1a ff ff ff       	jmp    801ed1 <__umoddi3+0x71>
