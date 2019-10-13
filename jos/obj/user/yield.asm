
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 00 20 80 00 	movl   $0x802000,(%esp)
  80004d:	e8 50 01 00 00       	call   8001a2 <cprintf>
	for (i = 0; i < 5; i++) {
  800052:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800057:	e8 68 0b 00 00       	call   800bc4 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005c:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800061:	8b 40 48             	mov    0x48(%eax),%eax
  800064:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  800073:	e8 2a 01 00 00       	call   8001a2 <cprintf>
	for (i = 0; i < 5; i++) {
  800078:	83 c3 01             	add    $0x1,%ebx
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d7                	jne    800057 <umain+0x24>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 08 40 80 00       	mov    0x804008,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	c7 04 24 4c 20 80 00 	movl   $0x80204c,(%esp)
  800093:	e8 0a 01 00 00       	call   8001a2 <cprintf>
}
  800098:	83 c4 14             	add    $0x14,%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 10             	sub    $0x10,%esp
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8000ac:	e8 f4 0a 00 00       	call   800ba5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x30>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d2:	89 1c 24             	mov    %ebx,(%esp)
  8000d5:	e8 59 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000da:	e8 07 00 00 00       	call   8000e6 <exit>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ec:	e8 34 0f 00 00       	call   801025 <close_all>
	sys_env_destroy(0);
  8000f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f8:	e8 56 0a 00 00       	call   800b53 <sys_env_destroy>
}
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    

008000ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	53                   	push   %ebx
  800103:	83 ec 14             	sub    $0x14,%esp
  800106:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800109:	8b 13                	mov    (%ebx),%edx
  80010b:	8d 42 01             	lea    0x1(%edx),%eax
  80010e:	89 03                	mov    %eax,(%ebx)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800117:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011c:	75 19                	jne    800137 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80011e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800125:	00 
  800126:	8d 43 08             	lea    0x8(%ebx),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 e5 09 00 00       	call   800b16 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	83 c4 14             	add    $0x14,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800151:	00 00 00 
	b.cnt = 0;
  800154:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800161:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800165:	8b 45 08             	mov    0x8(%ebp),%eax
  800168:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	c7 04 24 ff 00 80 00 	movl   $0x8000ff,(%esp)
  80017d:	e8 ac 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800182:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	89 04 24             	mov    %eax,(%esp)
  800195:	e8 7c 09 00 00       	call   800b16 <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b2:	89 04 24             	mov    %eax,(%esp)
  8001b5:	e8 87 ff ff ff       	call   800141 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    
  8001bc:	66 90                	xchg   %ax,%ax
  8001be:	66 90                	xchg   %ax,%ax

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 c3                	mov    %eax,%ebx
  8001d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ed:	39 d9                	cmp    %ebx,%ecx
  8001ef:	72 05                	jb     8001f6 <printnum+0x36>
  8001f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001f4:	77 69                	ja     80025f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001fd:	83 ee 01             	sub    $0x1,%esi
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	89 44 24 08          	mov    %eax,0x8(%esp)
  800208:	8b 44 24 08          	mov    0x8(%esp),%eax
  80020c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800210:	89 c3                	mov    %eax,%ebx
  800212:	89 d6                	mov    %edx,%esi
  800214:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800217:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80021a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80021e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800222:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	e8 3c 1b 00 00       	call   801d70 <__udivdi3>
  800234:	89 d9                	mov    %ebx,%ecx
  800236:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80023a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	89 54 24 04          	mov    %edx,0x4(%esp)
  800245:	89 fa                	mov    %edi,%edx
  800247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024a:	e8 71 ff ff ff       	call   8001c0 <printnum>
  80024f:	eb 1b                	jmp    80026c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800255:	8b 45 18             	mov    0x18(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	ff d3                	call   *%ebx
  80025d:	eb 03                	jmp    800262 <printnum+0xa2>
  80025f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800262:	83 ee 01             	sub    $0x1,%esi
  800265:	85 f6                	test   %esi,%esi
  800267:	7f e8                	jg     800251 <printnum+0x91>
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800270:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800274:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800277:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80027a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	e8 0c 1c 00 00       	call   801ea0 <__umoddi3>
  800294:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800298:	0f be 80 75 20 80 00 	movsbl 0x802075(%eax),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a5:	ff d0                	call   *%eax
}
  8002a7:	83 c4 3c             	add    $0x3c,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b2:	83 fa 01             	cmp    $0x1,%edx
  8002b5:	7e 0e                	jle    8002c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	8b 52 04             	mov    0x4(%edx),%edx
  8002c3:	eb 22                	jmp    8002e7 <getuint+0x38>
	else if (lflag)
  8002c5:	85 d2                	test   %edx,%edx
  8002c7:	74 10                	je     8002d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d7:	eb 0e                	jmp    8002e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800313:	8b 45 10             	mov    0x10(%ebp),%eax
  800316:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	e8 02 00 00 00       	call   80032e <vprintfmt>
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 3c             	sub    $0x3c,%esp
  800337:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80033a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033d:	eb 1f                	jmp    80035e <vprintfmt+0x30>
			if (ch == '\0'){
  80033f:	85 c0                	test   %eax,%eax
  800341:	75 0f                	jne    800352 <vprintfmt+0x24>
				color = 0x0100;
  800343:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80034a:	01 00 00 
  80034d:	e9 b3 03 00 00       	jmp    800705 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800352:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800356:	89 04 24             	mov    %eax,(%esp)
  800359:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035c:	89 f3                	mov    %esi,%ebx
  80035e:	8d 73 01             	lea    0x1(%ebx),%esi
  800361:	0f b6 03             	movzbl (%ebx),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 d6                	jne    80033f <vprintfmt+0x11>
  800369:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80036d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800374:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80037b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 1d                	jmp    8003a6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800389:	89 de                	mov    %ebx,%esi
			padc = '-';
  80038b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80038f:	eb 15                	jmp    8003a6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800391:	89 de                	mov    %ebx,%esi
			padc = '0';
  800393:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800397:	eb 0d                	jmp    8003a6 <vprintfmt+0x78>
				width = precision, precision = -1;
  800399:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80039c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80039f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003a9:	0f b6 0e             	movzbl (%esi),%ecx
  8003ac:	0f b6 c1             	movzbl %cl,%eax
  8003af:	83 e9 23             	sub    $0x23,%ecx
  8003b2:	80 f9 55             	cmp    $0x55,%cl
  8003b5:	0f 87 2a 03 00 00    	ja     8006e5 <vprintfmt+0x3b7>
  8003bb:	0f b6 c9             	movzbl %cl,%ecx
  8003be:	ff 24 8d c0 21 80 00 	jmp    *0x8021c0(,%ecx,4)
  8003c5:	89 de                	mov    %ebx,%esi
  8003c7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8003cc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003cf:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003d3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003d9:	83 fb 09             	cmp    $0x9,%ebx
  8003dc:	77 36                	ja     800414 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8003de:	83 c6 01             	add    $0x1,%esi
			}
  8003e1:	eb e9                	jmp    8003cc <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ec:	8b 00                	mov    (%eax),%eax
  8003ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8003f3:	eb 22                	jmp    800417 <vprintfmt+0xe9>
  8003f5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003f8:	85 c9                	test   %ecx,%ecx
  8003fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ff:	0f 49 c1             	cmovns %ecx,%eax
  800402:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800405:	89 de                	mov    %ebx,%esi
  800407:	eb 9d                	jmp    8003a6 <vprintfmt+0x78>
  800409:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80040b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800412:	eb 92                	jmp    8003a6 <vprintfmt+0x78>
  800414:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800417:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80041b:	79 89                	jns    8003a6 <vprintfmt+0x78>
  80041d:	e9 77 ff ff ff       	jmp    800399 <vprintfmt+0x6b>
			lflag++;
  800422:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800425:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800427:	e9 7a ff ff ff       	jmp    8003a6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8d 50 04             	lea    0x4(%eax),%edx
  800432:	89 55 14             	mov    %edx,0x14(%ebp)
  800435:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	89 04 24             	mov    %eax,(%esp)
  80043e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800441:	e9 18 ff ff ff       	jmp    80035e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 50 04             	lea    0x4(%eax),%edx
  80044c:	89 55 14             	mov    %edx,0x14(%ebp)
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	99                   	cltd   
  800452:	31 d0                	xor    %edx,%eax
  800454:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800456:	83 f8 0f             	cmp    $0xf,%eax
  800459:	7f 0b                	jg     800466 <vprintfmt+0x138>
  80045b:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  800462:	85 d2                	test   %edx,%edx
  800464:	75 20                	jne    800486 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800466:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046a:	c7 44 24 08 8d 20 80 	movl   $0x80208d,0x8(%esp)
  800471:	00 
  800472:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800476:	8b 45 08             	mov    0x8(%ebp),%eax
  800479:	89 04 24             	mov    %eax,(%esp)
  80047c:	e8 85 fe ff ff       	call   800306 <printfmt>
  800481:	e9 d8 fe ff ff       	jmp    80035e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800486:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048a:	c7 44 24 08 7a 24 80 	movl   $0x80247a,0x8(%esp)
  800491:	00 
  800492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	89 04 24             	mov    %eax,(%esp)
  80049c:	e8 65 fe ff ff       	call   800306 <printfmt>
  8004a1:	e9 b8 fe ff ff       	jmp    80035e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004ba:	85 f6                	test   %esi,%esi
  8004bc:	b8 86 20 80 00       	mov    $0x802086,%eax
  8004c1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004c4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004c8:	0f 84 97 00 00 00    	je     800565 <vprintfmt+0x237>
  8004ce:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004d2:	0f 8e 9b 00 00 00    	jle    800573 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004dc:	89 34 24             	mov    %esi,(%esp)
  8004df:	e8 c4 02 00 00       	call   8007a8 <strnlen>
  8004e4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004e7:	29 c2                	sub    %eax,%edx
  8004e9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8004ec:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004f3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004fc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	eb 0f                	jmp    80050f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800500:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800504:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800507:	89 04 24             	mov    %eax,(%esp)
  80050a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	83 eb 01             	sub    $0x1,%ebx
  80050f:	85 db                	test   %ebx,%ebx
  800511:	7f ed                	jg     800500 <vprintfmt+0x1d2>
  800513:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800516:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800519:	85 d2                	test   %edx,%edx
  80051b:	b8 00 00 00 00       	mov    $0x0,%eax
  800520:	0f 49 c2             	cmovns %edx,%eax
  800523:	29 c2                	sub    %eax,%edx
  800525:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800528:	89 d7                	mov    %edx,%edi
  80052a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80052d:	eb 50                	jmp    80057f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80052f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800533:	74 1e                	je     800553 <vprintfmt+0x225>
  800535:	0f be d2             	movsbl %dl,%edx
  800538:	83 ea 20             	sub    $0x20,%edx
  80053b:	83 fa 5e             	cmp    $0x5e,%edx
  80053e:	76 13                	jbe    800553 <vprintfmt+0x225>
					putch('?', putdat);
  800540:	8b 45 0c             	mov    0xc(%ebp),%eax
  800543:	89 44 24 04          	mov    %eax,0x4(%esp)
  800547:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80054e:	ff 55 08             	call   *0x8(%ebp)
  800551:	eb 0d                	jmp    800560 <vprintfmt+0x232>
					putch(ch, putdat);
  800553:	8b 55 0c             	mov    0xc(%ebp),%edx
  800556:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055a:	89 04 24             	mov    %eax,(%esp)
  80055d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800560:	83 ef 01             	sub    $0x1,%edi
  800563:	eb 1a                	jmp    80057f <vprintfmt+0x251>
  800565:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800568:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80056b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80056e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800571:	eb 0c                	jmp    80057f <vprintfmt+0x251>
  800573:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800576:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800579:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80057c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80057f:	83 c6 01             	add    $0x1,%esi
  800582:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800586:	0f be c2             	movsbl %dl,%eax
  800589:	85 c0                	test   %eax,%eax
  80058b:	74 27                	je     8005b4 <vprintfmt+0x286>
  80058d:	85 db                	test   %ebx,%ebx
  80058f:	78 9e                	js     80052f <vprintfmt+0x201>
  800591:	83 eb 01             	sub    $0x1,%ebx
  800594:	79 99                	jns    80052f <vprintfmt+0x201>
  800596:	89 f8                	mov    %edi,%eax
  800598:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80059b:	8b 75 08             	mov    0x8(%ebp),%esi
  80059e:	89 c3                	mov    %eax,%ebx
  8005a0:	eb 1a                	jmp    8005bc <vprintfmt+0x28e>
				putch(' ', putdat);
  8005a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ad:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005af:	83 eb 01             	sub    $0x1,%ebx
  8005b2:	eb 08                	jmp    8005bc <vprintfmt+0x28e>
  8005b4:	89 fb                	mov    %edi,%ebx
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005bc:	85 db                	test   %ebx,%ebx
  8005be:	7f e2                	jg     8005a2 <vprintfmt+0x274>
  8005c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005c6:	e9 93 fd ff ff       	jmp    80035e <vprintfmt+0x30>
	if (lflag >= 2)
  8005cb:	83 fa 01             	cmp    $0x1,%edx
  8005ce:	7e 16                	jle    8005e6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 08             	lea    0x8(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 50 04             	mov    0x4(%eax),%edx
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005e4:	eb 32                	jmp    800618 <vprintfmt+0x2ea>
	else if (lflag)
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	74 18                	je     800602 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 30                	mov    (%eax),%esi
  8005f5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005f8:	89 f0                	mov    %esi,%eax
  8005fa:	c1 f8 1f             	sar    $0x1f,%eax
  8005fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800600:	eb 16                	jmp    800618 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 04             	lea    0x4(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	8b 30                	mov    (%eax),%esi
  80060d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800610:	89 f0                	mov    %esi,%eax
  800612:	c1 f8 1f             	sar    $0x1f,%eax
  800615:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800618:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80061e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800623:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800627:	0f 89 80 00 00 00    	jns    8006ad <vprintfmt+0x37f>
				putch('-', putdat);
  80062d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800631:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800638:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80063b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800641:	f7 d8                	neg    %eax
  800643:	83 d2 00             	adc    $0x0,%edx
  800646:	f7 da                	neg    %edx
			base = 10;
  800648:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064d:	eb 5e                	jmp    8006ad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 58 fc ff ff       	call   8002af <getuint>
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065c:	eb 4f                	jmp    8006ad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 49 fc ff ff       	call   8002af <getuint>
            base = 8;
  800666:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80066b:	eb 40                	jmp    8006ad <vprintfmt+0x37f>
			putch('0', putdat);
  80066d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800671:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800678:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80067b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800686:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800692:	8b 00                	mov    (%eax),%eax
  800694:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800699:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069e:	eb 0d                	jmp    8006ad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a3:	e8 07 fc ff ff       	call   8002af <getuint>
			base = 16;
  8006a8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006ad:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8006b1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006b5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006b8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006bc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c7:	89 fa                	mov    %edi,%edx
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	e8 ef fa ff ff       	call   8001c0 <printnum>
			break;
  8006d1:	e9 88 fc ff ff       	jmp    80035e <vprintfmt+0x30>
			putch(ch, putdat);
  8006d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006e0:	e9 79 fc ff ff       	jmp    80035e <vprintfmt+0x30>
			putch('%', putdat);
  8006e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f3:	89 f3                	mov    %esi,%ebx
  8006f5:	eb 03                	jmp    8006fa <vprintfmt+0x3cc>
  8006f7:	83 eb 01             	sub    $0x1,%ebx
  8006fa:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006fe:	75 f7                	jne    8006f7 <vprintfmt+0x3c9>
  800700:	e9 59 fc ff ff       	jmp    80035e <vprintfmt+0x30>
}
  800705:	83 c4 3c             	add    $0x3c,%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 28             	sub    $0x28,%esp
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800719:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800720:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800723:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072a:	85 c0                	test   %eax,%eax
  80072c:	74 30                	je     80075e <vsnprintf+0x51>
  80072e:	85 d2                	test   %edx,%edx
  800730:	7e 2c                	jle    80075e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800739:	8b 45 10             	mov    0x10(%ebp),%eax
  80073c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	c7 04 24 e9 02 80 00 	movl   $0x8002e9,(%esp)
  80074e:	e8 db fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800753:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800756:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075c:	eb 05                	jmp    800763 <vsnprintf+0x56>
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800772:	8b 45 10             	mov    0x10(%ebp),%eax
  800775:	89 44 24 08          	mov    %eax,0x8(%esp)
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	89 04 24             	mov    %eax,(%esp)
  800786:	e8 82 ff ff ff       	call   80070d <vsnprintf>
	va_end(ap);

	return rc;
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    
  80078d:	66 90                	xchg   %ax,%ax
  80078f:	90                   	nop

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	eb 03                	jmp    8007a0 <strlen+0x10>
		n++;
  80079d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a4:	75 f7                	jne    80079d <strlen+0xd>
	return n;
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb 03                	jmp    8007bb <strnlen+0x13>
		n++;
  8007b8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	39 d0                	cmp    %edx,%eax
  8007bd:	74 06                	je     8007c5 <strnlen+0x1d>
  8007bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c3:	75 f3                	jne    8007b8 <strnlen+0x10>
	return n;
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	83 c2 01             	add    $0x1,%edx
  8007d6:	83 c1 01             	add    $0x1,%ecx
  8007d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007dd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ef                	jne    8007d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f1:	89 1c 24             	mov    %ebx,(%esp)
  8007f4:	e8 97 ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800800:	01 d8                	add    %ebx,%eax
  800802:	89 04 24             	mov    %eax,(%esp)
  800805:	e8 bd ff ff ff       	call   8007c7 <strcpy>
	return dst;
}
  80080a:	89 d8                	mov    %ebx,%eax
  80080c:	83 c4 08             	add    $0x8,%esp
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	89 f3                	mov    %esi,%ebx
  80081f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	89 f2                	mov    %esi,%edx
  800824:	eb 0f                	jmp    800835 <strncpy+0x23>
		*dst++ = *src;
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082f:	80 39 01             	cmpb   $0x1,(%ecx)
  800832:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800835:	39 da                	cmp    %ebx,%edx
  800837:	75 ed                	jne    800826 <strncpy+0x14>
	}
	return ret;
}
  800839:	89 f0                	mov    %esi,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	85 c9                	test   %ecx,%ecx
  800855:	75 0b                	jne    800862 <strlcpy+0x23>
  800857:	eb 1d                	jmp    800876 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800859:	83 c0 01             	add    $0x1,%eax
  80085c:	83 c2 01             	add    $0x1,%edx
  80085f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800862:	39 d8                	cmp    %ebx,%eax
  800864:	74 0b                	je     800871 <strlcpy+0x32>
  800866:	0f b6 0a             	movzbl (%edx),%ecx
  800869:	84 c9                	test   %cl,%cl
  80086b:	75 ec                	jne    800859 <strlcpy+0x1a>
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	eb 02                	jmp    800873 <strlcpy+0x34>
  800871:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800873:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800876:	29 f0                	sub    %esi,%eax
}
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800885:	eb 06                	jmp    80088d <strcmp+0x11>
		p++, q++;
  800887:	83 c1 01             	add    $0x1,%ecx
  80088a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088d:	0f b6 01             	movzbl (%ecx),%eax
  800890:	84 c0                	test   %al,%al
  800892:	74 04                	je     800898 <strcmp+0x1c>
  800894:	3a 02                	cmp    (%edx),%al
  800896:	74 ef                	je     800887 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 c0             	movzbl %al,%eax
  80089b:	0f b6 12             	movzbl (%edx),%edx
  80089e:	29 d0                	sub    %edx,%eax
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 c3                	mov    %eax,%ebx
  8008ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b1:	eb 06                	jmp    8008b9 <strncmp+0x17>
		n--, p++, q++;
  8008b3:	83 c0 01             	add    $0x1,%eax
  8008b6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b9:	39 d8                	cmp    %ebx,%eax
  8008bb:	74 15                	je     8008d2 <strncmp+0x30>
  8008bd:	0f b6 08             	movzbl (%eax),%ecx
  8008c0:	84 c9                	test   %cl,%cl
  8008c2:	74 04                	je     8008c8 <strncmp+0x26>
  8008c4:	3a 0a                	cmp    (%edx),%cl
  8008c6:	74 eb                	je     8008b3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 00             	movzbl (%eax),%eax
  8008cb:	0f b6 12             	movzbl (%edx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
  8008d0:	eb 05                	jmp    8008d7 <strncmp+0x35>
		return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e4:	eb 07                	jmp    8008ed <strchr+0x13>
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 0f                	je     8008f9 <strchr+0x1f>
	for (; *s; s++)
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f2                	jne    8008e6 <strchr+0xc>
			return (char *) s;
	return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	eb 07                	jmp    80090e <strfind+0x13>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 0a                	je     800915 <strfind+0x1a>
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	0f b6 10             	movzbl (%eax),%edx
  800911:	84 d2                	test   %dl,%dl
  800913:	75 f2                	jne    800907 <strfind+0xc>
			break;
	return (char *) s;
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800923:	85 c9                	test   %ecx,%ecx
  800925:	74 36                	je     80095d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800927:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092d:	75 28                	jne    800957 <memset+0x40>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 23                	jne    800957 <memset+0x40>
		c &= 0xFF;
  800934:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800938:	89 d3                	mov    %edx,%ebx
  80093a:	c1 e3 08             	shl    $0x8,%ebx
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	c1 e6 18             	shl    $0x18,%esi
  800942:	89 d0                	mov    %edx,%eax
  800944:	c1 e0 10             	shl    $0x10,%eax
  800947:	09 f0                	or     %esi,%eax
  800949:	09 c2                	or     %eax,%edx
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800952:	fc                   	cld    
  800953:	f3 ab                	rep stos %eax,%es:(%edi)
  800955:	eb 06                	jmp    80095d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	fc                   	cld    
  80095b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095d:	89 f8                	mov    %edi,%eax
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5f                   	pop    %edi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800972:	39 c6                	cmp    %eax,%esi
  800974:	73 35                	jae    8009ab <memmove+0x47>
  800976:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800979:	39 d0                	cmp    %edx,%eax
  80097b:	73 2e                	jae    8009ab <memmove+0x47>
		s += n;
		d += n;
  80097d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800980:	89 d6                	mov    %edx,%esi
  800982:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098a:	75 13                	jne    80099f <memmove+0x3b>
  80098c:	f6 c1 03             	test   $0x3,%cl
  80098f:	75 0e                	jne    80099f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800991:	83 ef 04             	sub    $0x4,%edi
  800994:	8d 72 fc             	lea    -0x4(%edx),%esi
  800997:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80099a:	fd                   	std    
  80099b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099d:	eb 09                	jmp    8009a8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099f:	83 ef 01             	sub    $0x1,%edi
  8009a2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a5:	fd                   	std    
  8009a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a8:	fc                   	cld    
  8009a9:	eb 1d                	jmp    8009c8 <memmove+0x64>
  8009ab:	89 f2                	mov    %esi,%edx
  8009ad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009af:	f6 c2 03             	test   $0x3,%dl
  8009b2:	75 0f                	jne    8009c3 <memmove+0x5f>
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 0a                	jne    8009c3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009bc:	89 c7                	mov    %eax,%edi
  8009be:	fc                   	cld    
  8009bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c1:	eb 05                	jmp    8009c8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  8009c3:	89 c7                	mov    %eax,%edi
  8009c5:	fc                   	cld    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c8:	5e                   	pop    %esi
  8009c9:	5f                   	pop    %edi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	89 04 24             	mov    %eax,(%esp)
  8009e6:	e8 79 ff ff ff       	call   800964 <memmove>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f8:	89 d6                	mov    %edx,%esi
  8009fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fd:	eb 1a                	jmp    800a19 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ff:	0f b6 02             	movzbl (%edx),%eax
  800a02:	0f b6 19             	movzbl (%ecx),%ebx
  800a05:	38 d8                	cmp    %bl,%al
  800a07:	74 0a                	je     800a13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c0             	movzbl %al,%eax
  800a0c:	0f b6 db             	movzbl %bl,%ebx
  800a0f:	29 d8                	sub    %ebx,%eax
  800a11:	eb 0f                	jmp    800a22 <memcmp+0x35>
		s1++, s2++;
  800a13:	83 c2 01             	add    $0x1,%edx
  800a16:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800a19:	39 f2                	cmp    %esi,%edx
  800a1b:	75 e2                	jne    8009ff <memcmp+0x12>
	}

	return 0;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a34:	eb 07                	jmp    800a3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a36:	38 08                	cmp    %cl,(%eax)
  800a38:	74 07                	je     800a41 <memfind+0x1b>
	for (; s < ends; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	39 d0                	cmp    %edx,%eax
  800a3f:	72 f5                	jb     800a36 <memfind+0x10>
			break;
	return (void *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 03                	jmp    800a54 <strtol+0x11>
		s++;
  800a51:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a54:	0f b6 0a             	movzbl (%edx),%ecx
  800a57:	80 f9 09             	cmp    $0x9,%cl
  800a5a:	74 f5                	je     800a51 <strtol+0xe>
  800a5c:	80 f9 20             	cmp    $0x20,%cl
  800a5f:	74 f0                	je     800a51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a61:	80 f9 2b             	cmp    $0x2b,%cl
  800a64:	75 0a                	jne    800a70 <strtol+0x2d>
		s++;
  800a66:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6e:	eb 11                	jmp    800a81 <strtol+0x3e>
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800a75:	80 f9 2d             	cmp    $0x2d,%cl
  800a78:	75 07                	jne    800a81 <strtol+0x3e>
		s++, neg = 1;
  800a7a:	8d 52 01             	lea    0x1(%edx),%edx
  800a7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a86:	75 15                	jne    800a9d <strtol+0x5a>
  800a88:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8b:	75 10                	jne    800a9d <strtol+0x5a>
  800a8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a91:	75 0a                	jne    800a9d <strtol+0x5a>
		s += 2, base = 16;
  800a93:	83 c2 02             	add    $0x2,%edx
  800a96:	b8 10 00 00 00       	mov    $0x10,%eax
  800a9b:	eb 10                	jmp    800aad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	75 0c                	jne    800aad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800aa3:	80 3a 30             	cmpb   $0x30,(%edx)
  800aa6:	75 05                	jne    800aad <strtol+0x6a>
		s++, base = 8;
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	b0 08                	mov    $0x8,%al
		base = 10;
  800aad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ab2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab5:	0f b6 0a             	movzbl (%edx),%ecx
  800ab8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800abb:	89 f0                	mov    %esi,%eax
  800abd:	3c 09                	cmp    $0x9,%al
  800abf:	77 08                	ja     800ac9 <strtol+0x86>
			dig = *s - '0';
  800ac1:	0f be c9             	movsbl %cl,%ecx
  800ac4:	83 e9 30             	sub    $0x30,%ecx
  800ac7:	eb 20                	jmp    800ae9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ac9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800acc:	89 f0                	mov    %esi,%eax
  800ace:	3c 19                	cmp    $0x19,%al
  800ad0:	77 08                	ja     800ada <strtol+0x97>
			dig = *s - 'a' + 10;
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 57             	sub    $0x57,%ecx
  800ad8:	eb 0f                	jmp    800ae9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800add:	89 f0                	mov    %esi,%eax
  800adf:	3c 19                	cmp    $0x19,%al
  800ae1:	77 16                	ja     800af9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ae3:	0f be c9             	movsbl %cl,%ecx
  800ae6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800aec:	7d 0f                	jge    800afd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800aee:	83 c2 01             	add    $0x1,%edx
  800af1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800af5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800af7:	eb bc                	jmp    800ab5 <strtol+0x72>
  800af9:	89 d8                	mov    %ebx,%eax
  800afb:	eb 02                	jmp    800aff <strtol+0xbc>
  800afd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b03:	74 05                	je     800b0a <strtol+0xc7>
		*endptr = (char *) s;
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b0a:	f7 d8                	neg    %eax
  800b0c:	85 ff                	test   %edi,%edi
  800b0e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 c3                	mov    %eax,%ebx
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	89 c6                	mov    %eax,%esi
  800b2d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800b5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b61:	b8 03 00 00 00       	mov    $0x3,%eax
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 cb                	mov    %ecx,%ebx
  800b6b:	89 cf                	mov    %ecx,%edi
  800b6d:	89 ce                	mov    %ecx,%esi
  800b6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b71:	85 c0                	test   %eax,%eax
  800b73:	7e 28                	jle    800b9d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b79:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b80:	00 
  800b81:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800b88:	00 
  800b89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b90:	00 
  800b91:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800b98:	e8 29 10 00 00       	call   801bc6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9d:	83 c4 2c             	add    $0x2c,%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_yield>:

void
sys_yield(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bec:	be 00 00 00 00       	mov    $0x0,%esi
  800bf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bff:	89 f7                	mov    %esi,%edi
  800c01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 28                	jle    800c2f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c12:	00 
  800c13:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800c1a:	00 
  800c1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c22:	00 
  800c23:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800c2a:	e8 97 0f 00 00       	call   801bc6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2f:	83 c4 2c             	add    $0x2c,%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c40:	b8 05 00 00 00       	mov    $0x5,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 75 18             	mov    0x18(%ebp),%esi
  800c54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 28                	jle    800c82 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c65:	00 
  800c66:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800c6d:	00 
  800c6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c75:	00 
  800c76:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800c7d:	e8 44 0f 00 00       	call   801bc6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c82:	83 c4 2c             	add    $0x2c,%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 28                	jle    800cd5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc8:	00 
  800cc9:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800cd0:	e8 f1 0e 00 00       	call   801bc6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd5:	83 c4 2c             	add    $0x2c,%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ceb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 df                	mov    %ebx,%edi
  800cf8:	89 de                	mov    %ebx,%esi
  800cfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7e 28                	jle    800d28 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d0b:	00 
  800d0c:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800d13:	00 
  800d14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1b:	00 
  800d1c:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800d23:	e8 9e 0e 00 00       	call   801bc6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d28:	83 c4 2c             	add    $0x2c,%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 28                	jle    800d7b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d57:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800d66:	00 
  800d67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6e:	00 
  800d6f:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800d76:	e8 4b 0e 00 00       	call   801bc6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7b:	83 c4 2c             	add    $0x2c,%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 df                	mov    %ebx,%edi
  800d9e:	89 de                	mov    %ebx,%esi
  800da0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 28                	jle    800dce <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800db1:	00 
  800db2:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800db9:	00 
  800dba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc1:	00 
  800dc2:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800dc9:	e8 f8 0d 00 00       	call   801bc6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dce:	83 c4 2c             	add    $0x2c,%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ddc:	be 00 00 00 00       	mov    $0x0,%esi
  800de1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800def:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e07:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 cb                	mov    %ecx,%ebx
  800e11:	89 cf                	mov    %ecx,%edi
  800e13:	89 ce                	mov    %ecx,%esi
  800e15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 28                	jle    800e43 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e26:	00 
  800e27:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e36:	00 
  800e37:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800e3e:	e8 83 0d 00 00       	call   801bc6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e43:	83 c4 2c             	add    $0x2c,%esp
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    
  800e4b:	66 90                	xchg   %ax,%ax
  800e4d:	66 90                	xchg   %ax,%ax
  800e4f:	90                   	nop

00800e50 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e70:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e82:	89 c2                	mov    %eax,%edx
  800e84:	c1 ea 16             	shr    $0x16,%edx
  800e87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8e:	f6 c2 01             	test   $0x1,%dl
  800e91:	74 11                	je     800ea4 <fd_alloc+0x2d>
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	c1 ea 0c             	shr    $0xc,%edx
  800e98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e9f:	f6 c2 01             	test   $0x1,%dl
  800ea2:	75 09                	jne    800ead <fd_alloc+0x36>
			*fd_store = fd;
  800ea4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eab:	eb 17                	jmp    800ec4 <fd_alloc+0x4d>
  800ead:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800eb2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb7:	75 c9                	jne    800e82 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800eb9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ebf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ecc:	83 f8 1f             	cmp    $0x1f,%eax
  800ecf:	77 36                	ja     800f07 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed1:	c1 e0 0c             	shl    $0xc,%eax
  800ed4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ed9:	89 c2                	mov    %eax,%edx
  800edb:	c1 ea 16             	shr    $0x16,%edx
  800ede:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee5:	f6 c2 01             	test   $0x1,%dl
  800ee8:	74 24                	je     800f0e <fd_lookup+0x48>
  800eea:	89 c2                	mov    %eax,%edx
  800eec:	c1 ea 0c             	shr    $0xc,%edx
  800eef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef6:	f6 c2 01             	test   $0x1,%dl
  800ef9:	74 1a                	je     800f15 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800efb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efe:	89 02                	mov    %eax,(%edx)
	return 0;
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
  800f05:	eb 13                	jmp    800f1a <fd_lookup+0x54>
		return -E_INVAL;
  800f07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0c:	eb 0c                	jmp    800f1a <fd_lookup+0x54>
		return -E_INVAL;
  800f0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f13:	eb 05                	jmp    800f1a <fd_lookup+0x54>
  800f15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 18             	sub    $0x18,%esp
  800f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f25:	ba 28 24 80 00       	mov    $0x802428,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f2a:	eb 13                	jmp    800f3f <dev_lookup+0x23>
  800f2c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f2f:	39 08                	cmp    %ecx,(%eax)
  800f31:	75 0c                	jne    800f3f <dev_lookup+0x23>
			*dev = devtab[i];
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f36:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f38:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3d:	eb 30                	jmp    800f6f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800f3f:	8b 02                	mov    (%edx),%eax
  800f41:	85 c0                	test   %eax,%eax
  800f43:	75 e7                	jne    800f2c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f45:	a1 08 40 80 00       	mov    0x804008,%eax
  800f4a:	8b 40 48             	mov    0x48(%eax),%eax
  800f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f55:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  800f5c:	e8 41 f2 ff ff       	call   8001a2 <cprintf>
	*dev = 0;
  800f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <fd_close>:
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
  800f76:	83 ec 20             	sub    $0x20,%esp
  800f79:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f82:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f86:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f8c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f8f:	89 04 24             	mov    %eax,(%esp)
  800f92:	e8 2f ff ff ff       	call   800ec6 <fd_lookup>
  800f97:	85 c0                	test   %eax,%eax
  800f99:	78 05                	js     800fa0 <fd_close+0x2f>
	    || fd != fd2)
  800f9b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f9e:	74 0c                	je     800fac <fd_close+0x3b>
		return (must_exist ? r : 0);
  800fa0:	84 db                	test   %bl,%bl
  800fa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa7:	0f 44 c2             	cmove  %edx,%eax
  800faa:	eb 3f                	jmp    800feb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800faf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb3:	8b 06                	mov    (%esi),%eax
  800fb5:	89 04 24             	mov    %eax,(%esp)
  800fb8:	e8 5f ff ff ff       	call   800f1c <dev_lookup>
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 16                	js     800fd9 <fd_close+0x68>
		if (dev->dev_close)
  800fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fc9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	74 07                	je     800fd9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800fd2:	89 34 24             	mov    %esi,(%esp)
  800fd5:	ff d0                	call   *%eax
  800fd7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  800fd9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe4:	e8 a1 fc ff ff       	call   800c8a <sys_page_unmap>
	return r;
  800fe9:	89 d8                	mov    %ebx,%eax
}
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <close>:

int
close(int fdnum)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fff:	8b 45 08             	mov    0x8(%ebp),%eax
  801002:	89 04 24             	mov    %eax,(%esp)
  801005:	e8 bc fe ff ff       	call   800ec6 <fd_lookup>
  80100a:	89 c2                	mov    %eax,%edx
  80100c:	85 d2                	test   %edx,%edx
  80100e:	78 13                	js     801023 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801010:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801017:	00 
  801018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101b:	89 04 24             	mov    %eax,(%esp)
  80101e:	e8 4e ff ff ff       	call   800f71 <fd_close>
}
  801023:	c9                   	leave  
  801024:	c3                   	ret    

00801025 <close_all>:

void
close_all(void)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	53                   	push   %ebx
  801029:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80102c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801031:	89 1c 24             	mov    %ebx,(%esp)
  801034:	e8 b9 ff ff ff       	call   800ff2 <close>
	for (i = 0; i < MAXFD; i++)
  801039:	83 c3 01             	add    $0x1,%ebx
  80103c:	83 fb 20             	cmp    $0x20,%ebx
  80103f:	75 f0                	jne    801031 <close_all+0xc>
}
  801041:	83 c4 14             	add    $0x14,%esp
  801044:	5b                   	pop    %ebx
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	57                   	push   %edi
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
  80104d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801050:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801053:	89 44 24 04          	mov    %eax,0x4(%esp)
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	89 04 24             	mov    %eax,(%esp)
  80105d:	e8 64 fe ff ff       	call   800ec6 <fd_lookup>
  801062:	89 c2                	mov    %eax,%edx
  801064:	85 d2                	test   %edx,%edx
  801066:	0f 88 e1 00 00 00    	js     80114d <dup+0x106>
		return r;
	close(newfdnum);
  80106c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106f:	89 04 24             	mov    %eax,(%esp)
  801072:	e8 7b ff ff ff       	call   800ff2 <close>

	newfd = INDEX2FD(newfdnum);
  801077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80107a:	c1 e3 0c             	shl    $0xc,%ebx
  80107d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801083:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801086:	89 04 24             	mov    %eax,(%esp)
  801089:	e8 d2 fd ff ff       	call   800e60 <fd2data>
  80108e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801090:	89 1c 24             	mov    %ebx,(%esp)
  801093:	e8 c8 fd ff ff       	call   800e60 <fd2data>
  801098:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80109a:	89 f0                	mov    %esi,%eax
  80109c:	c1 e8 16             	shr    $0x16,%eax
  80109f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a6:	a8 01                	test   $0x1,%al
  8010a8:	74 43                	je     8010ed <dup+0xa6>
  8010aa:	89 f0                	mov    %esi,%eax
  8010ac:	c1 e8 0c             	shr    $0xc,%eax
  8010af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b6:	f6 c2 01             	test   $0x1,%dl
  8010b9:	74 32                	je     8010ed <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010d6:	00 
  8010d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e2:	e8 50 fb ff ff       	call   800c37 <sys_page_map>
  8010e7:	89 c6                	mov    %eax,%esi
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 3e                	js     80112b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f0:	89 c2                	mov    %eax,%edx
  8010f2:	c1 ea 0c             	shr    $0xc,%edx
  8010f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801102:	89 54 24 10          	mov    %edx,0x10(%esp)
  801106:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80110a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801111:	00 
  801112:	89 44 24 04          	mov    %eax,0x4(%esp)
  801116:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80111d:	e8 15 fb ff ff       	call   800c37 <sys_page_map>
  801122:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801124:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801127:	85 f6                	test   %esi,%esi
  801129:	79 22                	jns    80114d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80112b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80112f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801136:	e8 4f fb ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80113b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80113f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801146:	e8 3f fb ff ff       	call   800c8a <sys_page_unmap>
	return r;
  80114b:	89 f0                	mov    %esi,%eax
}
  80114d:	83 c4 3c             	add    $0x3c,%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	53                   	push   %ebx
  801159:	83 ec 24             	sub    $0x24,%esp
  80115c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80115f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801162:	89 44 24 04          	mov    %eax,0x4(%esp)
  801166:	89 1c 24             	mov    %ebx,(%esp)
  801169:	e8 58 fd ff ff       	call   800ec6 <fd_lookup>
  80116e:	89 c2                	mov    %eax,%edx
  801170:	85 d2                	test   %edx,%edx
  801172:	78 6d                	js     8011e1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117e:	8b 00                	mov    (%eax),%eax
  801180:	89 04 24             	mov    %eax,(%esp)
  801183:	e8 94 fd ff ff       	call   800f1c <dev_lookup>
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 55                	js     8011e1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80118c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118f:	8b 50 08             	mov    0x8(%eax),%edx
  801192:	83 e2 03             	and    $0x3,%edx
  801195:	83 fa 01             	cmp    $0x1,%edx
  801198:	75 23                	jne    8011bd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80119a:	a1 08 40 80 00       	mov    0x804008,%eax
  80119f:	8b 40 48             	mov    0x48(%eax),%eax
  8011a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011aa:	c7 04 24 ed 23 80 00 	movl   $0x8023ed,(%esp)
  8011b1:	e8 ec ef ff ff       	call   8001a2 <cprintf>
		return -E_INVAL;
  8011b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bb:	eb 24                	jmp    8011e1 <read+0x8c>
	}
	if (!dev->dev_read)
  8011bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c0:	8b 52 08             	mov    0x8(%edx),%edx
  8011c3:	85 d2                	test   %edx,%edx
  8011c5:	74 15                	je     8011dc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011d5:	89 04 24             	mov    %eax,(%esp)
  8011d8:	ff d2                	call   *%edx
  8011da:	eb 05                	jmp    8011e1 <read+0x8c>
		return -E_NOT_SUPP;
  8011dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8011e1:	83 c4 24             	add    $0x24,%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	57                   	push   %edi
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 1c             	sub    $0x1c,%esp
  8011f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fb:	eb 23                	jmp    801220 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011fd:	89 f0                	mov    %esi,%eax
  8011ff:	29 d8                	sub    %ebx,%eax
  801201:	89 44 24 08          	mov    %eax,0x8(%esp)
  801205:	89 d8                	mov    %ebx,%eax
  801207:	03 45 0c             	add    0xc(%ebp),%eax
  80120a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120e:	89 3c 24             	mov    %edi,(%esp)
  801211:	e8 3f ff ff ff       	call   801155 <read>
		if (m < 0)
  801216:	85 c0                	test   %eax,%eax
  801218:	78 10                	js     80122a <readn+0x43>
			return m;
		if (m == 0)
  80121a:	85 c0                	test   %eax,%eax
  80121c:	74 0a                	je     801228 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80121e:	01 c3                	add    %eax,%ebx
  801220:	39 f3                	cmp    %esi,%ebx
  801222:	72 d9                	jb     8011fd <readn+0x16>
  801224:	89 d8                	mov    %ebx,%eax
  801226:	eb 02                	jmp    80122a <readn+0x43>
  801228:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80122a:	83 c4 1c             	add    $0x1c,%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	53                   	push   %ebx
  801236:	83 ec 24             	sub    $0x24,%esp
  801239:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801243:	89 1c 24             	mov    %ebx,(%esp)
  801246:	e8 7b fc ff ff       	call   800ec6 <fd_lookup>
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	85 d2                	test   %edx,%edx
  80124f:	78 68                	js     8012b9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801251:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801254:	89 44 24 04          	mov    %eax,0x4(%esp)
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	8b 00                	mov    (%eax),%eax
  80125d:	89 04 24             	mov    %eax,(%esp)
  801260:	e8 b7 fc ff ff       	call   800f1c <dev_lookup>
  801265:	85 c0                	test   %eax,%eax
  801267:	78 50                	js     8012b9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801269:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801270:	75 23                	jne    801295 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801272:	a1 08 40 80 00       	mov    0x804008,%eax
  801277:	8b 40 48             	mov    0x48(%eax),%eax
  80127a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80127e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801282:	c7 04 24 09 24 80 00 	movl   $0x802409,(%esp)
  801289:	e8 14 ef ff ff       	call   8001a2 <cprintf>
		return -E_INVAL;
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801293:	eb 24                	jmp    8012b9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801295:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801298:	8b 52 0c             	mov    0xc(%edx),%edx
  80129b:	85 d2                	test   %edx,%edx
  80129d:	74 15                	je     8012b4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80129f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012ad:	89 04 24             	mov    %eax,(%esp)
  8012b0:	ff d2                	call   *%edx
  8012b2:	eb 05                	jmp    8012b9 <write+0x87>
		return -E_NOT_SUPP;
  8012b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8012b9:	83 c4 24             	add    $0x24,%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <seek>:

int
seek(int fdnum, off_t offset)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cf:	89 04 24             	mov    %eax,(%esp)
  8012d2:	e8 ef fb ff ff       	call   800ec6 <fd_lookup>
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 0e                	js     8012e9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	53                   	push   %ebx
  8012ef:	83 ec 24             	sub    $0x24,%esp
  8012f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fc:	89 1c 24             	mov    %ebx,(%esp)
  8012ff:	e8 c2 fb ff ff       	call   800ec6 <fd_lookup>
  801304:	89 c2                	mov    %eax,%edx
  801306:	85 d2                	test   %edx,%edx
  801308:	78 61                	js     80136b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801314:	8b 00                	mov    (%eax),%eax
  801316:	89 04 24             	mov    %eax,(%esp)
  801319:	e8 fe fb ff ff       	call   800f1c <dev_lookup>
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 49                	js     80136b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801325:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801329:	75 23                	jne    80134e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80132b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801330:	8b 40 48             	mov    0x48(%eax),%eax
  801333:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133b:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  801342:	e8 5b ee ff ff       	call   8001a2 <cprintf>
		return -E_INVAL;
  801347:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134c:	eb 1d                	jmp    80136b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80134e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801351:	8b 52 18             	mov    0x18(%edx),%edx
  801354:	85 d2                	test   %edx,%edx
  801356:	74 0e                	je     801366 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801358:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	ff d2                	call   *%edx
  801364:	eb 05                	jmp    80136b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801366:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80136b:	83 c4 24             	add    $0x24,%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5d                   	pop    %ebp
  801370:	c3                   	ret    

00801371 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	53                   	push   %ebx
  801375:	83 ec 24             	sub    $0x24,%esp
  801378:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801382:	8b 45 08             	mov    0x8(%ebp),%eax
  801385:	89 04 24             	mov    %eax,(%esp)
  801388:	e8 39 fb ff ff       	call   800ec6 <fd_lookup>
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	85 d2                	test   %edx,%edx
  801391:	78 52                	js     8013e5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139d:	8b 00                	mov    (%eax),%eax
  80139f:	89 04 24             	mov    %eax,(%esp)
  8013a2:	e8 75 fb ff ff       	call   800f1c <dev_lookup>
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 3a                	js     8013e5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8013ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ae:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013b2:	74 2c                	je     8013e0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013be:	00 00 00 
	stat->st_isdir = 0;
  8013c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c8:	00 00 00 
	stat->st_dev = dev;
  8013cb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d8:	89 14 24             	mov    %edx,(%esp)
  8013db:	ff 50 14             	call   *0x14(%eax)
  8013de:	eb 05                	jmp    8013e5 <fstat+0x74>
		return -E_NOT_SUPP;
  8013e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013e5:	83 c4 24             	add    $0x24,%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013fa:	00 
  8013fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fe:	89 04 24             	mov    %eax,(%esp)
  801401:	e8 fb 01 00 00       	call   801601 <open>
  801406:	89 c3                	mov    %eax,%ebx
  801408:	85 db                	test   %ebx,%ebx
  80140a:	78 1b                	js     801427 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80140c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801413:	89 1c 24             	mov    %ebx,(%esp)
  801416:	e8 56 ff ff ff       	call   801371 <fstat>
  80141b:	89 c6                	mov    %eax,%esi
	close(fd);
  80141d:	89 1c 24             	mov    %ebx,(%esp)
  801420:	e8 cd fb ff ff       	call   800ff2 <close>
	return r;
  801425:	89 f0                	mov    %esi,%eax
}
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	56                   	push   %esi
  801432:	53                   	push   %ebx
  801433:	83 ec 10             	sub    $0x10,%esp
  801436:	89 c6                	mov    %eax,%esi
  801438:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80143a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801441:	75 11                	jne    801454 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801443:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80144a:	e8 a0 08 00 00       	call   801cef <ipc_find_env>
  80144f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801454:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80145b:	00 
  80145c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801463:	00 
  801464:	89 74 24 04          	mov    %esi,0x4(%esp)
  801468:	a1 04 40 80 00       	mov    0x804004,%eax
  80146d:	89 04 24             	mov    %eax,(%esp)
  801470:	e8 13 08 00 00       	call   801c88 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801475:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80147c:	00 
  80147d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801481:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801488:	e8 93 07 00 00       	call   801c20 <ipc_recv>
}
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	5b                   	pop    %ebx
  801491:	5e                   	pop    %esi
  801492:	5d                   	pop    %ebp
  801493:	c3                   	ret    

00801494 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b7:	e8 72 ff ff ff       	call   80142e <fsipc>
}
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <devfile_flush>:
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ca:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d9:	e8 50 ff ff ff       	call   80142e <fsipc>
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <devfile_stat>:
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 14             	sub    $0x14,%esp
  8014e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ff:	e8 2a ff ff ff       	call   80142e <fsipc>
  801504:	89 c2                	mov    %eax,%edx
  801506:	85 d2                	test   %edx,%edx
  801508:	78 2b                	js     801535 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80150a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801511:	00 
  801512:	89 1c 24             	mov    %ebx,(%esp)
  801515:	e8 ad f2 ff ff       	call   8007c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80151a:	a1 80 50 80 00       	mov    0x805080,%eax
  80151f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801525:	a1 84 50 80 00       	mov    0x805084,%eax
  80152a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801530:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801535:	83 c4 14             	add    $0x14,%esp
  801538:	5b                   	pop    %ebx
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <devfile_write>:
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801541:	c7 44 24 08 38 24 80 	movl   $0x802438,0x8(%esp)
  801548:	00 
  801549:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801550:	00 
  801551:	c7 04 24 56 24 80 00 	movl   $0x802456,(%esp)
  801558:	e8 69 06 00 00       	call   801bc6 <_panic>

0080155d <devfile_read>:
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	56                   	push   %esi
  801561:	53                   	push   %ebx
  801562:	83 ec 10             	sub    $0x10,%esp
  801565:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801568:	8b 45 08             	mov    0x8(%ebp),%eax
  80156b:	8b 40 0c             	mov    0xc(%eax),%eax
  80156e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801573:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801579:	ba 00 00 00 00       	mov    $0x0,%edx
  80157e:	b8 03 00 00 00       	mov    $0x3,%eax
  801583:	e8 a6 fe ff ff       	call   80142e <fsipc>
  801588:	89 c3                	mov    %eax,%ebx
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 6a                	js     8015f8 <devfile_read+0x9b>
	assert(r <= n);
  80158e:	39 c6                	cmp    %eax,%esi
  801590:	73 24                	jae    8015b6 <devfile_read+0x59>
  801592:	c7 44 24 0c 61 24 80 	movl   $0x802461,0xc(%esp)
  801599:	00 
  80159a:	c7 44 24 08 68 24 80 	movl   $0x802468,0x8(%esp)
  8015a1:	00 
  8015a2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015a9:	00 
  8015aa:	c7 04 24 56 24 80 00 	movl   $0x802456,(%esp)
  8015b1:	e8 10 06 00 00       	call   801bc6 <_panic>
	assert(r <= PGSIZE);
  8015b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015bb:	7e 24                	jle    8015e1 <devfile_read+0x84>
  8015bd:	c7 44 24 0c 7d 24 80 	movl   $0x80247d,0xc(%esp)
  8015c4:	00 
  8015c5:	c7 44 24 08 68 24 80 	movl   $0x802468,0x8(%esp)
  8015cc:	00 
  8015cd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8015d4:	00 
  8015d5:	c7 04 24 56 24 80 00 	movl   $0x802456,(%esp)
  8015dc:	e8 e5 05 00 00       	call   801bc6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015ec:	00 
  8015ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f0:	89 04 24             	mov    %eax,(%esp)
  8015f3:	e8 6c f3 ff ff       	call   800964 <memmove>
}
  8015f8:	89 d8                	mov    %ebx,%eax
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	5b                   	pop    %ebx
  8015fe:	5e                   	pop    %esi
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <open>:
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	53                   	push   %ebx
  801605:	83 ec 24             	sub    $0x24,%esp
  801608:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80160b:	89 1c 24             	mov    %ebx,(%esp)
  80160e:	e8 7d f1 ff ff       	call   800790 <strlen>
  801613:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801618:	7f 60                	jg     80167a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80161a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161d:	89 04 24             	mov    %eax,(%esp)
  801620:	e8 52 f8 ff ff       	call   800e77 <fd_alloc>
  801625:	89 c2                	mov    %eax,%edx
  801627:	85 d2                	test   %edx,%edx
  801629:	78 54                	js     80167f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80162b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80162f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801636:	e8 8c f1 ff ff       	call   8007c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80163b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801643:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801646:	b8 01 00 00 00       	mov    $0x1,%eax
  80164b:	e8 de fd ff ff       	call   80142e <fsipc>
  801650:	89 c3                	mov    %eax,%ebx
  801652:	85 c0                	test   %eax,%eax
  801654:	79 17                	jns    80166d <open+0x6c>
		fd_close(fd, 0);
  801656:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80165d:	00 
  80165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801661:	89 04 24             	mov    %eax,(%esp)
  801664:	e8 08 f9 ff ff       	call   800f71 <fd_close>
		return r;
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	eb 12                	jmp    80167f <open+0x7e>
	return fd2num(fd);
  80166d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	e8 d8 f7 ff ff       	call   800e50 <fd2num>
  801678:	eb 05                	jmp    80167f <open+0x7e>
		return -E_BAD_PATH;
  80167a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80167f:	83 c4 24             	add    $0x24,%esp
  801682:	5b                   	pop    %ebx
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80168b:	ba 00 00 00 00       	mov    $0x0,%edx
  801690:	b8 08 00 00 00       	mov    $0x8,%eax
  801695:	e8 94 fd ff ff       	call   80142e <fsipc>
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 10             	sub    $0x10,%esp
  8016a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016aa:	89 04 24             	mov    %eax,(%esp)
  8016ad:	e8 ae f7 ff ff       	call   800e60 <fd2data>
  8016b2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016b4:	c7 44 24 04 89 24 80 	movl   $0x802489,0x4(%esp)
  8016bb:	00 
  8016bc:	89 1c 24             	mov    %ebx,(%esp)
  8016bf:	e8 03 f1 ff ff       	call   8007c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016c4:	8b 46 04             	mov    0x4(%esi),%eax
  8016c7:	2b 06                	sub    (%esi),%eax
  8016c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d6:	00 00 00 
	stat->st_dev = &devpipe;
  8016d9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016e0:	30 80 00 
	return 0;
}
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	5e                   	pop    %esi
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 14             	sub    $0x14,%esp
  8016f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801704:	e8 81 f5 ff ff       	call   800c8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801709:	89 1c 24             	mov    %ebx,(%esp)
  80170c:	e8 4f f7 ff ff       	call   800e60 <fd2data>
  801711:	89 44 24 04          	mov    %eax,0x4(%esp)
  801715:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171c:	e8 69 f5 ff ff       	call   800c8a <sys_page_unmap>
}
  801721:	83 c4 14             	add    $0x14,%esp
  801724:	5b                   	pop    %ebx
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <_pipeisclosed>:
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 2c             	sub    $0x2c,%esp
  801730:	89 c6                	mov    %eax,%esi
  801732:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801735:	a1 08 40 80 00       	mov    0x804008,%eax
  80173a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80173d:	89 34 24             	mov    %esi,(%esp)
  801740:	e8 e2 05 00 00       	call   801d27 <pageref>
  801745:	89 c7                	mov    %eax,%edi
  801747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80174a:	89 04 24             	mov    %eax,(%esp)
  80174d:	e8 d5 05 00 00       	call   801d27 <pageref>
  801752:	39 c7                	cmp    %eax,%edi
  801754:	0f 94 c2             	sete   %dl
  801757:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80175a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801760:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801763:	39 fb                	cmp    %edi,%ebx
  801765:	74 21                	je     801788 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801767:	84 d2                	test   %dl,%dl
  801769:	74 ca                	je     801735 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80176b:	8b 51 58             	mov    0x58(%ecx),%edx
  80176e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801772:	89 54 24 08          	mov    %edx,0x8(%esp)
  801776:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177a:	c7 04 24 90 24 80 00 	movl   $0x802490,(%esp)
  801781:	e8 1c ea ff ff       	call   8001a2 <cprintf>
  801786:	eb ad                	jmp    801735 <_pipeisclosed+0xe>
}
  801788:	83 c4 2c             	add    $0x2c,%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5f                   	pop    %edi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <devpipe_write>:
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	57                   	push   %edi
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 1c             	sub    $0x1c,%esp
  801799:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80179c:	89 34 24             	mov    %esi,(%esp)
  80179f:	e8 bc f6 ff ff       	call   800e60 <fd2data>
  8017a4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8017ab:	eb 45                	jmp    8017f2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  8017ad:	89 da                	mov    %ebx,%edx
  8017af:	89 f0                	mov    %esi,%eax
  8017b1:	e8 71 ff ff ff       	call   801727 <_pipeisclosed>
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	75 41                	jne    8017fb <devpipe_write+0x6b>
			sys_yield();
  8017ba:	e8 05 f4 ff ff       	call   800bc4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017bf:	8b 43 04             	mov    0x4(%ebx),%eax
  8017c2:	8b 0b                	mov    (%ebx),%ecx
  8017c4:	8d 51 20             	lea    0x20(%ecx),%edx
  8017c7:	39 d0                	cmp    %edx,%eax
  8017c9:	73 e2                	jae    8017ad <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ce:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017d2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017d5:	99                   	cltd   
  8017d6:	c1 ea 1b             	shr    $0x1b,%edx
  8017d9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8017dc:	83 e1 1f             	and    $0x1f,%ecx
  8017df:	29 d1                	sub    %edx,%ecx
  8017e1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8017e5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8017e9:	83 c0 01             	add    $0x1,%eax
  8017ec:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017ef:	83 c7 01             	add    $0x1,%edi
  8017f2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017f5:	75 c8                	jne    8017bf <devpipe_write+0x2f>
	return i;
  8017f7:	89 f8                	mov    %edi,%eax
  8017f9:	eb 05                	jmp    801800 <devpipe_write+0x70>
				return 0;
  8017fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801800:	83 c4 1c             	add    $0x1c,%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5f                   	pop    %edi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <devpipe_read>:
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	57                   	push   %edi
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
  80180e:	83 ec 1c             	sub    $0x1c,%esp
  801811:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801814:	89 3c 24             	mov    %edi,(%esp)
  801817:	e8 44 f6 ff ff       	call   800e60 <fd2data>
  80181c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80181e:	be 00 00 00 00       	mov    $0x0,%esi
  801823:	eb 3d                	jmp    801862 <devpipe_read+0x5a>
			if (i > 0)
  801825:	85 f6                	test   %esi,%esi
  801827:	74 04                	je     80182d <devpipe_read+0x25>
				return i;
  801829:	89 f0                	mov    %esi,%eax
  80182b:	eb 43                	jmp    801870 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  80182d:	89 da                	mov    %ebx,%edx
  80182f:	89 f8                	mov    %edi,%eax
  801831:	e8 f1 fe ff ff       	call   801727 <_pipeisclosed>
  801836:	85 c0                	test   %eax,%eax
  801838:	75 31                	jne    80186b <devpipe_read+0x63>
			sys_yield();
  80183a:	e8 85 f3 ff ff       	call   800bc4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80183f:	8b 03                	mov    (%ebx),%eax
  801841:	3b 43 04             	cmp    0x4(%ebx),%eax
  801844:	74 df                	je     801825 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801846:	99                   	cltd   
  801847:	c1 ea 1b             	shr    $0x1b,%edx
  80184a:	01 d0                	add    %edx,%eax
  80184c:	83 e0 1f             	and    $0x1f,%eax
  80184f:	29 d0                	sub    %edx,%eax
  801851:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801859:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80185c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80185f:	83 c6 01             	add    $0x1,%esi
  801862:	3b 75 10             	cmp    0x10(%ebp),%esi
  801865:	75 d8                	jne    80183f <devpipe_read+0x37>
	return i;
  801867:	89 f0                	mov    %esi,%eax
  801869:	eb 05                	jmp    801870 <devpipe_read+0x68>
				return 0;
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801870:	83 c4 1c             	add    $0x1c,%esp
  801873:	5b                   	pop    %ebx
  801874:	5e                   	pop    %esi
  801875:	5f                   	pop    %edi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <pipe>:
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 ec f5 ff ff       	call   800e77 <fd_alloc>
  80188b:	89 c2                	mov    %eax,%edx
  80188d:	85 d2                	test   %edx,%edx
  80188f:	0f 88 4d 01 00 00    	js     8019e2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801895:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80189c:	00 
  80189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ab:	e8 33 f3 ff ff       	call   800be3 <sys_page_alloc>
  8018b0:	89 c2                	mov    %eax,%edx
  8018b2:	85 d2                	test   %edx,%edx
  8018b4:	0f 88 28 01 00 00    	js     8019e2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  8018ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	e8 b2 f5 ff ff       	call   800e77 <fd_alloc>
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	0f 88 fe 00 00 00    	js     8019cd <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018cf:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018d6:	00 
  8018d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e5:	e8 f9 f2 ff ff       	call   800be3 <sys_page_alloc>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	0f 88 d9 00 00 00    	js     8019cd <pipe+0x155>
	va = fd2data(fd0);
  8018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f7:	89 04 24             	mov    %eax,(%esp)
  8018fa:	e8 61 f5 ff ff       	call   800e60 <fd2data>
  8018ff:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801901:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801908:	00 
  801909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801914:	e8 ca f2 ff ff       	call   800be3 <sys_page_alloc>
  801919:	89 c3                	mov    %eax,%ebx
  80191b:	85 c0                	test   %eax,%eax
  80191d:	0f 88 97 00 00 00    	js     8019ba <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801923:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801926:	89 04 24             	mov    %eax,(%esp)
  801929:	e8 32 f5 ff ff       	call   800e60 <fd2data>
  80192e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801935:	00 
  801936:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801941:	00 
  801942:	89 74 24 04          	mov    %esi,0x4(%esp)
  801946:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194d:	e8 e5 f2 ff ff       	call   800c37 <sys_page_map>
  801952:	89 c3                	mov    %eax,%ebx
  801954:	85 c0                	test   %eax,%eax
  801956:	78 52                	js     8019aa <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801958:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801961:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801966:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80196d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801973:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801976:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801978:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801985:	89 04 24             	mov    %eax,(%esp)
  801988:	e8 c3 f4 ff ff       	call   800e50 <fd2num>
  80198d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801990:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801992:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801995:	89 04 24             	mov    %eax,(%esp)
  801998:	e8 b3 f4 ff ff       	call   800e50 <fd2num>
  80199d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a8:	eb 38                	jmp    8019e2 <pipe+0x16a>
	sys_page_unmap(0, va);
  8019aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b5:	e8 d0 f2 ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  8019ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c8:	e8 bd f2 ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  8019cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019db:	e8 aa f2 ff ff       	call   800c8a <sys_page_unmap>
  8019e0:	89 d8                	mov    %ebx,%eax
}
  8019e2:	83 c4 30             	add    $0x30,%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <pipeisclosed>:
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	89 04 24             	mov    %eax,(%esp)
  8019fc:	e8 c5 f4 ff ff       	call   800ec6 <fd_lookup>
  801a01:	89 c2                	mov    %eax,%edx
  801a03:	85 d2                	test   %edx,%edx
  801a05:	78 15                	js     801a1c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0a:	89 04 24             	mov    %eax,(%esp)
  801a0d:	e8 4e f4 ff ff       	call   800e60 <fd2data>
	return _pipeisclosed(fd, p);
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a17:	e8 0b fd ff ff       	call   801727 <_pipeisclosed>
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    
  801a1e:	66 90                	xchg   %ax,%ax

00801a20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801a30:	c7 44 24 04 a8 24 80 	movl   $0x8024a8,0x4(%esp)
  801a37:	00 
  801a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3b:	89 04 24             	mov    %eax,(%esp)
  801a3e:	e8 84 ed ff ff       	call   8007c7 <strcpy>
	return 0;
}
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <devcons_write>:
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	57                   	push   %edi
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a56:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a5b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a61:	eb 31                	jmp    801a94 <devcons_write+0x4a>
		m = n - tot;
  801a63:	8b 75 10             	mov    0x10(%ebp),%esi
  801a66:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a68:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801a6b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a70:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a73:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a77:	03 45 0c             	add    0xc(%ebp),%eax
  801a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7e:	89 3c 24             	mov    %edi,(%esp)
  801a81:	e8 de ee ff ff       	call   800964 <memmove>
		sys_cputs(buf, m);
  801a86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a8a:	89 3c 24             	mov    %edi,(%esp)
  801a8d:	e8 84 f0 ff ff       	call   800b16 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a92:	01 f3                	add    %esi,%ebx
  801a94:	89 d8                	mov    %ebx,%eax
  801a96:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a99:	72 c8                	jb     801a63 <devcons_write+0x19>
}
  801a9b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801aa1:	5b                   	pop    %ebx
  801aa2:	5e                   	pop    %esi
  801aa3:	5f                   	pop    %edi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <devcons_read>:
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801aac:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ab1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ab5:	75 07                	jne    801abe <devcons_read+0x18>
  801ab7:	eb 2a                	jmp    801ae3 <devcons_read+0x3d>
		sys_yield();
  801ab9:	e8 06 f1 ff ff       	call   800bc4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801abe:	66 90                	xchg   %ax,%ax
  801ac0:	e8 6f f0 ff ff       	call   800b34 <sys_cgetc>
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	74 f0                	je     801ab9 <devcons_read+0x13>
	if (c < 0)
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 16                	js     801ae3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801acd:	83 f8 04             	cmp    $0x4,%eax
  801ad0:	74 0c                	je     801ade <devcons_read+0x38>
	*(char*)vbuf = c;
  801ad2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad5:	88 02                	mov    %al,(%edx)
	return 1;
  801ad7:	b8 01 00 00 00       	mov    $0x1,%eax
  801adc:	eb 05                	jmp    801ae3 <devcons_read+0x3d>
		return 0;
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <cputchar>:
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801af1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801af8:	00 
  801af9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801afc:	89 04 24             	mov    %eax,(%esp)
  801aff:	e8 12 f0 ff ff       	call   800b16 <sys_cputs>
}
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <getchar>:
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801b0c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801b13:	00 
  801b14:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b22:	e8 2e f6 ff ff       	call   801155 <read>
	if (r < 0)
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 0f                	js     801b3a <getchar+0x34>
	if (r < 1)
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	7e 06                	jle    801b35 <getchar+0x2f>
	return c;
  801b2f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b33:	eb 05                	jmp    801b3a <getchar+0x34>
		return -E_EOF;
  801b35:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <iscons>:
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	89 04 24             	mov    %eax,(%esp)
  801b4f:	e8 72 f3 ff ff       	call   800ec6 <fd_lookup>
  801b54:	85 c0                	test   %eax,%eax
  801b56:	78 11                	js     801b69 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b61:	39 10                	cmp    %edx,(%eax)
  801b63:	0f 94 c0             	sete   %al
  801b66:	0f b6 c0             	movzbl %al,%eax
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <opencons>:
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b74:	89 04 24             	mov    %eax,(%esp)
  801b77:	e8 fb f2 ff ff       	call   800e77 <fd_alloc>
		return r;
  801b7c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 40                	js     801bc2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b89:	00 
  801b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b98:	e8 46 f0 ff ff       	call   800be3 <sys_page_alloc>
		return r;
  801b9d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 1f                	js     801bc2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801ba3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bb8:	89 04 24             	mov    %eax,(%esp)
  801bbb:	e8 90 f2 ff ff       	call   800e50 <fd2num>
  801bc0:	89 c2                	mov    %eax,%edx
}
  801bc2:	89 d0                	mov    %edx,%eax
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	56                   	push   %esi
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801bce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801bd1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801bd7:	e8 c9 ef ff ff       	call   800ba5 <sys_getenvid>
  801bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bdf:	89 54 24 10          	mov    %edx,0x10(%esp)
  801be3:	8b 55 08             	mov    0x8(%ebp),%edx
  801be6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801bea:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf2:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  801bf9:	e8 a4 e5 ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bfe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c02:	8b 45 10             	mov    0x10(%ebp),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 34 e5 ff ff       	call   800141 <vcprintf>
	cprintf("\n");
  801c0d:	c7 04 24 a1 24 80 00 	movl   $0x8024a1,(%esp)
  801c14:	e8 89 e5 ff ff       	call   8001a2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c19:	cc                   	int3   
  801c1a:	eb fd                	jmp    801c19 <_panic+0x53>
  801c1c:	66 90                	xchg   %ax,%ax
  801c1e:	66 90                	xchg   %ax,%ax

00801c20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	56                   	push   %esi
  801c24:	53                   	push   %ebx
  801c25:	83 ec 10             	sub    $0x10,%esp
  801c28:	8b 75 08             	mov    0x8(%ebp),%esi
  801c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801c31:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801c33:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801c38:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801c3b:	89 04 24             	mov    %eax,(%esp)
  801c3e:	e8 b6 f1 ff ff       	call   800df9 <sys_ipc_recv>
    if(r < 0){
  801c43:	85 c0                	test   %eax,%eax
  801c45:	79 16                	jns    801c5d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801c47:	85 f6                	test   %esi,%esi
  801c49:	74 06                	je     801c51 <ipc_recv+0x31>
            *from_env_store = 0;
  801c4b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801c51:	85 db                	test   %ebx,%ebx
  801c53:	74 2c                	je     801c81 <ipc_recv+0x61>
            *perm_store = 0;
  801c55:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c5b:	eb 24                	jmp    801c81 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801c5d:	85 f6                	test   %esi,%esi
  801c5f:	74 0a                	je     801c6b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801c61:	a1 08 40 80 00       	mov    0x804008,%eax
  801c66:	8b 40 74             	mov    0x74(%eax),%eax
  801c69:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801c6b:	85 db                	test   %ebx,%ebx
  801c6d:	74 0a                	je     801c79 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801c6f:	a1 08 40 80 00       	mov    0x804008,%eax
  801c74:	8b 40 78             	mov    0x78(%eax),%eax
  801c77:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c79:	a1 08 40 80 00       	mov    0x804008,%eax
  801c7e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    

00801c88 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	57                   	push   %edi
  801c8c:	56                   	push   %esi
  801c8d:	53                   	push   %ebx
  801c8e:	83 ec 1c             	sub    $0x1c,%esp
  801c91:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c94:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801c9a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801c9c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801ca1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801ca4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801caf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	e8 1b f1 ff ff       	call   800dd6 <sys_ipc_try_send>
        if(r == 0){
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	74 28                	je     801ce7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801cbf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cc2:	74 1c                	je     801ce0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801cc4:	c7 44 24 08 d8 24 80 	movl   $0x8024d8,0x8(%esp)
  801ccb:	00 
  801ccc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801cd3:	00 
  801cd4:	c7 04 24 ef 24 80 00 	movl   $0x8024ef,(%esp)
  801cdb:	e8 e6 fe ff ff       	call   801bc6 <_panic>
        }
        sys_yield();
  801ce0:	e8 df ee ff ff       	call   800bc4 <sys_yield>
    }
  801ce5:	eb bd                	jmp    801ca4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801ce7:	83 c4 1c             	add    $0x1c,%esp
  801cea:	5b                   	pop    %ebx
  801ceb:	5e                   	pop    %esi
  801cec:	5f                   	pop    %edi
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    

00801cef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cf5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cfa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cfd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d03:	8b 52 50             	mov    0x50(%edx),%edx
  801d06:	39 ca                	cmp    %ecx,%edx
  801d08:	75 0d                	jne    801d17 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d0a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d0d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d12:	8b 40 40             	mov    0x40(%eax),%eax
  801d15:	eb 0e                	jmp    801d25 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801d17:	83 c0 01             	add    $0x1,%eax
  801d1a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d1f:	75 d9                	jne    801cfa <ipc_find_env+0xb>
	return 0;
  801d21:	66 b8 00 00          	mov    $0x0,%ax
}
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d2d:	89 d0                	mov    %edx,%eax
  801d2f:	c1 e8 16             	shr    $0x16,%eax
  801d32:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801d3e:	f6 c1 01             	test   $0x1,%cl
  801d41:	74 1d                	je     801d60 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801d43:	c1 ea 0c             	shr    $0xc,%edx
  801d46:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d4d:	f6 c2 01             	test   $0x1,%dl
  801d50:	74 0e                	je     801d60 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d52:	c1 ea 0c             	shr    $0xc,%edx
  801d55:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d5c:	ef 
  801d5d:	0f b7 c0             	movzwl %ax,%eax
}
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	66 90                	xchg   %ax,%ax
  801d64:	66 90                	xchg   %ax,%ax
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__udivdi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d7a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d7e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d82:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d86:	85 c0                	test   %eax,%eax
  801d88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d8c:	89 ea                	mov    %ebp,%edx
  801d8e:	89 0c 24             	mov    %ecx,(%esp)
  801d91:	75 2d                	jne    801dc0 <__udivdi3+0x50>
  801d93:	39 e9                	cmp    %ebp,%ecx
  801d95:	77 61                	ja     801df8 <__udivdi3+0x88>
  801d97:	85 c9                	test   %ecx,%ecx
  801d99:	89 ce                	mov    %ecx,%esi
  801d9b:	75 0b                	jne    801da8 <__udivdi3+0x38>
  801d9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801da2:	31 d2                	xor    %edx,%edx
  801da4:	f7 f1                	div    %ecx
  801da6:	89 c6                	mov    %eax,%esi
  801da8:	31 d2                	xor    %edx,%edx
  801daa:	89 e8                	mov    %ebp,%eax
  801dac:	f7 f6                	div    %esi
  801dae:	89 c5                	mov    %eax,%ebp
  801db0:	89 f8                	mov    %edi,%eax
  801db2:	f7 f6                	div    %esi
  801db4:	89 ea                	mov    %ebp,%edx
  801db6:	83 c4 0c             	add    $0xc,%esp
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	39 e8                	cmp    %ebp,%eax
  801dc2:	77 24                	ja     801de8 <__udivdi3+0x78>
  801dc4:	0f bd e8             	bsr    %eax,%ebp
  801dc7:	83 f5 1f             	xor    $0x1f,%ebp
  801dca:	75 3c                	jne    801e08 <__udivdi3+0x98>
  801dcc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801dd0:	39 34 24             	cmp    %esi,(%esp)
  801dd3:	0f 86 9f 00 00 00    	jbe    801e78 <__udivdi3+0x108>
  801dd9:	39 d0                	cmp    %edx,%eax
  801ddb:	0f 82 97 00 00 00    	jb     801e78 <__udivdi3+0x108>
  801de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de8:	31 d2                	xor    %edx,%edx
  801dea:	31 c0                	xor    %eax,%eax
  801dec:	83 c4 0c             	add    $0xc,%esp
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
  801df3:	90                   	nop
  801df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df8:	89 f8                	mov    %edi,%eax
  801dfa:	f7 f1                	div    %ecx
  801dfc:	31 d2                	xor    %edx,%edx
  801dfe:	83 c4 0c             	add    $0xc,%esp
  801e01:	5e                   	pop    %esi
  801e02:	5f                   	pop    %edi
  801e03:	5d                   	pop    %ebp
  801e04:	c3                   	ret    
  801e05:	8d 76 00             	lea    0x0(%esi),%esi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	8b 3c 24             	mov    (%esp),%edi
  801e0d:	d3 e0                	shl    %cl,%eax
  801e0f:	89 c6                	mov    %eax,%esi
  801e11:	b8 20 00 00 00       	mov    $0x20,%eax
  801e16:	29 e8                	sub    %ebp,%eax
  801e18:	89 c1                	mov    %eax,%ecx
  801e1a:	d3 ef                	shr    %cl,%edi
  801e1c:	89 e9                	mov    %ebp,%ecx
  801e1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e22:	8b 3c 24             	mov    (%esp),%edi
  801e25:	09 74 24 08          	or     %esi,0x8(%esp)
  801e29:	89 d6                	mov    %edx,%esi
  801e2b:	d3 e7                	shl    %cl,%edi
  801e2d:	89 c1                	mov    %eax,%ecx
  801e2f:	89 3c 24             	mov    %edi,(%esp)
  801e32:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e36:	d3 ee                	shr    %cl,%esi
  801e38:	89 e9                	mov    %ebp,%ecx
  801e3a:	d3 e2                	shl    %cl,%edx
  801e3c:	89 c1                	mov    %eax,%ecx
  801e3e:	d3 ef                	shr    %cl,%edi
  801e40:	09 d7                	or     %edx,%edi
  801e42:	89 f2                	mov    %esi,%edx
  801e44:	89 f8                	mov    %edi,%eax
  801e46:	f7 74 24 08          	divl   0x8(%esp)
  801e4a:	89 d6                	mov    %edx,%esi
  801e4c:	89 c7                	mov    %eax,%edi
  801e4e:	f7 24 24             	mull   (%esp)
  801e51:	39 d6                	cmp    %edx,%esi
  801e53:	89 14 24             	mov    %edx,(%esp)
  801e56:	72 30                	jb     801e88 <__udivdi3+0x118>
  801e58:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e5c:	89 e9                	mov    %ebp,%ecx
  801e5e:	d3 e2                	shl    %cl,%edx
  801e60:	39 c2                	cmp    %eax,%edx
  801e62:	73 05                	jae    801e69 <__udivdi3+0xf9>
  801e64:	3b 34 24             	cmp    (%esp),%esi
  801e67:	74 1f                	je     801e88 <__udivdi3+0x118>
  801e69:	89 f8                	mov    %edi,%eax
  801e6b:	31 d2                	xor    %edx,%edx
  801e6d:	e9 7a ff ff ff       	jmp    801dec <__udivdi3+0x7c>
  801e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e78:	31 d2                	xor    %edx,%edx
  801e7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7f:	e9 68 ff ff ff       	jmp    801dec <__udivdi3+0x7c>
  801e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e88:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e8b:	31 d2                	xor    %edx,%edx
  801e8d:	83 c4 0c             	add    $0xc,%esp
  801e90:	5e                   	pop    %esi
  801e91:	5f                   	pop    %edi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    
  801e94:	66 90                	xchg   %ax,%ax
  801e96:	66 90                	xchg   %ax,%ax
  801e98:	66 90                	xchg   %ax,%ax
  801e9a:	66 90                	xchg   %ax,%ax
  801e9c:	66 90                	xchg   %ax,%ax
  801e9e:	66 90                	xchg   %ax,%ax

00801ea0 <__umoddi3>:
  801ea0:	55                   	push   %ebp
  801ea1:	57                   	push   %edi
  801ea2:	56                   	push   %esi
  801ea3:	83 ec 14             	sub    $0x14,%esp
  801ea6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801eaa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801eae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801eb2:	89 c7                	mov    %eax,%edi
  801eb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801ebc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ec0:	89 34 24             	mov    %esi,(%esp)
  801ec3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	89 c2                	mov    %eax,%edx
  801ecb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ecf:	75 17                	jne    801ee8 <__umoddi3+0x48>
  801ed1:	39 fe                	cmp    %edi,%esi
  801ed3:	76 4b                	jbe    801f20 <__umoddi3+0x80>
  801ed5:	89 c8                	mov    %ecx,%eax
  801ed7:	89 fa                	mov    %edi,%edx
  801ed9:	f7 f6                	div    %esi
  801edb:	89 d0                	mov    %edx,%eax
  801edd:	31 d2                	xor    %edx,%edx
  801edf:	83 c4 14             	add    $0x14,%esp
  801ee2:	5e                   	pop    %esi
  801ee3:	5f                   	pop    %edi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    
  801ee6:	66 90                	xchg   %ax,%ax
  801ee8:	39 f8                	cmp    %edi,%eax
  801eea:	77 54                	ja     801f40 <__umoddi3+0xa0>
  801eec:	0f bd e8             	bsr    %eax,%ebp
  801eef:	83 f5 1f             	xor    $0x1f,%ebp
  801ef2:	75 5c                	jne    801f50 <__umoddi3+0xb0>
  801ef4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ef8:	39 3c 24             	cmp    %edi,(%esp)
  801efb:	0f 87 e7 00 00 00    	ja     801fe8 <__umoddi3+0x148>
  801f01:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f05:	29 f1                	sub    %esi,%ecx
  801f07:	19 c7                	sbb    %eax,%edi
  801f09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f11:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f15:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f19:	83 c4 14             	add    $0x14,%esp
  801f1c:	5e                   	pop    %esi
  801f1d:	5f                   	pop    %edi
  801f1e:	5d                   	pop    %ebp
  801f1f:	c3                   	ret    
  801f20:	85 f6                	test   %esi,%esi
  801f22:	89 f5                	mov    %esi,%ebp
  801f24:	75 0b                	jne    801f31 <__umoddi3+0x91>
  801f26:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	f7 f6                	div    %esi
  801f2f:	89 c5                	mov    %eax,%ebp
  801f31:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f35:	31 d2                	xor    %edx,%edx
  801f37:	f7 f5                	div    %ebp
  801f39:	89 c8                	mov    %ecx,%eax
  801f3b:	f7 f5                	div    %ebp
  801f3d:	eb 9c                	jmp    801edb <__umoddi3+0x3b>
  801f3f:	90                   	nop
  801f40:	89 c8                	mov    %ecx,%eax
  801f42:	89 fa                	mov    %edi,%edx
  801f44:	83 c4 14             	add    $0x14,%esp
  801f47:	5e                   	pop    %esi
  801f48:	5f                   	pop    %edi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    
  801f4b:	90                   	nop
  801f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f50:	8b 04 24             	mov    (%esp),%eax
  801f53:	be 20 00 00 00       	mov    $0x20,%esi
  801f58:	89 e9                	mov    %ebp,%ecx
  801f5a:	29 ee                	sub    %ebp,%esi
  801f5c:	d3 e2                	shl    %cl,%edx
  801f5e:	89 f1                	mov    %esi,%ecx
  801f60:	d3 e8                	shr    %cl,%eax
  801f62:	89 e9                	mov    %ebp,%ecx
  801f64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f68:	8b 04 24             	mov    (%esp),%eax
  801f6b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f6f:	89 fa                	mov    %edi,%edx
  801f71:	d3 e0                	shl    %cl,%eax
  801f73:	89 f1                	mov    %esi,%ecx
  801f75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f79:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f7d:	d3 ea                	shr    %cl,%edx
  801f7f:	89 e9                	mov    %ebp,%ecx
  801f81:	d3 e7                	shl    %cl,%edi
  801f83:	89 f1                	mov    %esi,%ecx
  801f85:	d3 e8                	shr    %cl,%eax
  801f87:	89 e9                	mov    %ebp,%ecx
  801f89:	09 f8                	or     %edi,%eax
  801f8b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f8f:	f7 74 24 04          	divl   0x4(%esp)
  801f93:	d3 e7                	shl    %cl,%edi
  801f95:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f99:	89 d7                	mov    %edx,%edi
  801f9b:	f7 64 24 08          	mull   0x8(%esp)
  801f9f:	39 d7                	cmp    %edx,%edi
  801fa1:	89 c1                	mov    %eax,%ecx
  801fa3:	89 14 24             	mov    %edx,(%esp)
  801fa6:	72 2c                	jb     801fd4 <__umoddi3+0x134>
  801fa8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801fac:	72 22                	jb     801fd0 <__umoddi3+0x130>
  801fae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fb2:	29 c8                	sub    %ecx,%eax
  801fb4:	19 d7                	sbb    %edx,%edi
  801fb6:	89 e9                	mov    %ebp,%ecx
  801fb8:	89 fa                	mov    %edi,%edx
  801fba:	d3 e8                	shr    %cl,%eax
  801fbc:	89 f1                	mov    %esi,%ecx
  801fbe:	d3 e2                	shl    %cl,%edx
  801fc0:	89 e9                	mov    %ebp,%ecx
  801fc2:	d3 ef                	shr    %cl,%edi
  801fc4:	09 d0                	or     %edx,%eax
  801fc6:	89 fa                	mov    %edi,%edx
  801fc8:	83 c4 14             	add    $0x14,%esp
  801fcb:	5e                   	pop    %esi
  801fcc:	5f                   	pop    %edi
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    
  801fcf:	90                   	nop
  801fd0:	39 d7                	cmp    %edx,%edi
  801fd2:	75 da                	jne    801fae <__umoddi3+0x10e>
  801fd4:	8b 14 24             	mov    (%esp),%edx
  801fd7:	89 c1                	mov    %eax,%ecx
  801fd9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801fdd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801fe1:	eb cb                	jmp    801fae <__umoddi3+0x10e>
  801fe3:	90                   	nop
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801fec:	0f 82 0f ff ff ff    	jb     801f01 <__umoddi3+0x61>
  801ff2:	e9 1a ff ff ff       	jmp    801f11 <__umoddi3+0x71>
