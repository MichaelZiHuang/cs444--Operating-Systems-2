
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 91 00 00 00       	call   8000c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 85 0b 00 00       	call   800bc5 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 34                	jne    800082 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800060:	00 
  800061:	89 34 24             	mov    %esi,(%esp)
  800064:	e8 07 0e 00 00       	call   800e70 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  800069:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  80007b:	e8 46 01 00 00       	call   8001c6 <cprintf>
  800080:	eb cf                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800082:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008f:	c7 04 24 31 20 80 00 	movl   $0x802031,(%esp)
  800096:	e8 2b 01 00 00       	call   8001c6 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a7:	00 
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 18 0e 00 00       	call   800ed8 <ipc_send>
  8000c0:	eb d9                	jmp    80009b <umain+0x68>

008000c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 10             	sub    $0x10,%esp
  8000ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8000d0:	e8 f0 0a 00 00       	call   800bc5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e2:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e7:	85 db                	test   %ebx,%ebx
  8000e9:	7e 07                	jle    8000f2 <libmain+0x30>
		binaryname = argv[0];
  8000eb:	8b 06                	mov    (%esi),%eax
  8000ed:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f6:	89 1c 24             	mov    %ebx,(%esp)
  8000f9:	e8 35 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fe:	e8 07 00 00 00       	call   80010a <exit>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800110:	e8 40 10 00 00       	call   801155 <close_all>
	sys_env_destroy(0);
  800115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011c:	e8 52 0a 00 00       	call   800b73 <sys_env_destroy>
}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	53                   	push   %ebx
  800127:	83 ec 14             	sub    $0x14,%esp
  80012a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012d:	8b 13                	mov    (%ebx),%edx
  80012f:	8d 42 01             	lea    0x1(%edx),%eax
  800132:	89 03                	mov    %eax,(%ebx)
  800134:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800137:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800140:	75 19                	jne    80015b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800142:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800149:	00 
  80014a:	8d 43 08             	lea    0x8(%ebx),%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 e1 09 00 00       	call   800b36 <sys_cputs>
		b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015f:	83 c4 14             	add    $0x14,%esp
  800162:	5b                   	pop    %ebx
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
	b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800182:	8b 45 0c             	mov    0xc(%ebp),%eax
  800185:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800190:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	c7 04 24 23 01 80 00 	movl   $0x800123,(%esp)
  8001a1:	e8 a8 01 00 00       	call   80034e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 78 09 00 00       	call   800b36 <sys_cputs>

	return b.cnt;
}
  8001be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	e8 87 ff ff ff       	call   800165 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

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
  80024f:	e8 3c 1b 00 00       	call   801d90 <__udivdi3>
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
  8002af:	e8 0c 1c 00 00       	call   801ec0 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 52 20 80 00 	movsbl 0x802052(%eax),%eax
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
  8003de:	ff 24 8d a0 21 80 00 	jmp    *0x8021a0(,%ecx,4)
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
  80047b:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  800482:	85 d2                	test   %edx,%edx
  800484:	75 20                	jne    8004a6 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800486:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048a:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  800491:	00 
  800492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	89 04 24             	mov    %eax,(%esp)
  80049c:	e8 85 fe ff ff       	call   800326 <printfmt>
  8004a1:	e9 d8 fe ff ff       	jmp    80037e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  8004a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004aa:	c7 44 24 08 7a 24 80 	movl   $0x80247a,0x8(%esp)
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
  8004dc:	b8 63 20 80 00       	mov    $0x802063,%eax
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
  800ba1:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800bb8:	e8 39 11 00 00       	call   801cf6 <_panic>
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
  800c33:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800c4a:	e8 a7 10 00 00       	call   801cf6 <_panic>
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
  800c86:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800c9d:	e8 54 10 00 00       	call   801cf6 <_panic>
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
  800cd9:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800cf0:	e8 01 10 00 00       	call   801cf6 <_panic>
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
  800d2c:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800d43:	e8 ae 0f 00 00       	call   801cf6 <_panic>
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
  800d7f:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800d96:	e8 5b 0f 00 00       	call   801cf6 <_panic>
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
  800dd2:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800de9:	e8 08 0f 00 00       	call   801cf6 <_panic>
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
  800e47:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e56:	00 
  800e57:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800e5e:	e8 93 0e 00 00       	call   801cf6 <_panic>
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

00800e70 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 10             	sub    $0x10,%esp
  800e78:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  800e81:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  800e83:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  800e88:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  800e8b:	89 04 24             	mov    %eax,(%esp)
  800e8e:	e8 86 ff ff ff       	call   800e19 <sys_ipc_recv>
    if(r < 0){
  800e93:	85 c0                	test   %eax,%eax
  800e95:	79 16                	jns    800ead <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  800e97:	85 f6                	test   %esi,%esi
  800e99:	74 06                	je     800ea1 <ipc_recv+0x31>
            *from_env_store = 0;
  800e9b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  800ea1:	85 db                	test   %ebx,%ebx
  800ea3:	74 2c                	je     800ed1 <ipc_recv+0x61>
            *perm_store = 0;
  800ea5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800eab:	eb 24                	jmp    800ed1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  800ead:	85 f6                	test   %esi,%esi
  800eaf:	74 0a                	je     800ebb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  800eb1:	a1 08 40 80 00       	mov    0x804008,%eax
  800eb6:	8b 40 74             	mov    0x74(%eax),%eax
  800eb9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  800ebb:	85 db                	test   %ebx,%ebx
  800ebd:	74 0a                	je     800ec9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  800ebf:	a1 08 40 80 00       	mov    0x804008,%eax
  800ec4:	8b 40 78             	mov    0x78(%eax),%eax
  800ec7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  800ec9:	a1 08 40 80 00       	mov    0x804008,%eax
  800ece:	8b 40 70             	mov    0x70(%eax),%eax
}
  800ed1:	83 c4 10             	add    $0x10,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	83 ec 1c             	sub    $0x1c,%esp
  800ee1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ee4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  800eea:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  800eec:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  800ef1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  800ef4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800eff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f03:	89 3c 24             	mov    %edi,(%esp)
  800f06:	e8 eb fe ff ff       	call   800df6 <sys_ipc_try_send>
        if(r == 0){
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	74 28                	je     800f37 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  800f0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800f12:	74 1c                	je     800f30 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  800f14:	c7 44 24 08 8a 23 80 	movl   $0x80238a,0x8(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 a1 23 80 00 	movl   $0x8023a1,(%esp)
  800f2b:	e8 c6 0d 00 00       	call   801cf6 <_panic>
        }
        sys_yield();
  800f30:	e8 af fc ff ff       	call   800be4 <sys_yield>
    }
  800f35:	eb bd                	jmp    800ef4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  800f37:	83 c4 1c             	add    $0x1c,%esp
  800f3a:	5b                   	pop    %ebx
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800f4a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800f4d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f53:	8b 52 50             	mov    0x50(%edx),%edx
  800f56:	39 ca                	cmp    %ecx,%edx
  800f58:	75 0d                	jne    800f67 <ipc_find_env+0x28>
			return envs[i].env_id;
  800f5a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f5d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800f62:	8b 40 40             	mov    0x40(%eax),%eax
  800f65:	eb 0e                	jmp    800f75 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  800f67:	83 c0 01             	add    $0x1,%eax
  800f6a:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f6f:	75 d9                	jne    800f4a <ipc_find_env+0xb>
	return 0;
  800f71:	66 b8 00 00          	mov    $0x0,%ax
}
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    
  800f77:	66 90                	xchg   %ax,%ax
  800f79:	66 90                	xchg   %ax,%ax
  800f7b:	66 90                	xchg   %ax,%ax
  800f7d:	66 90                	xchg   %ax,%ax
  800f7f:	90                   	nop

00800f80 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	05 00 00 00 30       	add    $0x30000000,%eax
  800f8b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fa0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fad:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fb2:	89 c2                	mov    %eax,%edx
  800fb4:	c1 ea 16             	shr    $0x16,%edx
  800fb7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fbe:	f6 c2 01             	test   $0x1,%dl
  800fc1:	74 11                	je     800fd4 <fd_alloc+0x2d>
  800fc3:	89 c2                	mov    %eax,%edx
  800fc5:	c1 ea 0c             	shr    $0xc,%edx
  800fc8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fcf:	f6 c2 01             	test   $0x1,%dl
  800fd2:	75 09                	jne    800fdd <fd_alloc+0x36>
			*fd_store = fd;
  800fd4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdb:	eb 17                	jmp    800ff4 <fd_alloc+0x4d>
  800fdd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800fe2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fe7:	75 c9                	jne    800fb2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800fe9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ffc:	83 f8 1f             	cmp    $0x1f,%eax
  800fff:	77 36                	ja     801037 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801001:	c1 e0 0c             	shl    $0xc,%eax
  801004:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801009:	89 c2                	mov    %eax,%edx
  80100b:	c1 ea 16             	shr    $0x16,%edx
  80100e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801015:	f6 c2 01             	test   $0x1,%dl
  801018:	74 24                	je     80103e <fd_lookup+0x48>
  80101a:	89 c2                	mov    %eax,%edx
  80101c:	c1 ea 0c             	shr    $0xc,%edx
  80101f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801026:	f6 c2 01             	test   $0x1,%dl
  801029:	74 1a                	je     801045 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80102b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80102e:	89 02                	mov    %eax,(%edx)
	return 0;
  801030:	b8 00 00 00 00       	mov    $0x0,%eax
  801035:	eb 13                	jmp    80104a <fd_lookup+0x54>
		return -E_INVAL;
  801037:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80103c:	eb 0c                	jmp    80104a <fd_lookup+0x54>
		return -E_INVAL;
  80103e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801043:	eb 05                	jmp    80104a <fd_lookup+0x54>
  801045:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	83 ec 18             	sub    $0x18,%esp
  801052:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801055:	ba 28 24 80 00       	mov    $0x802428,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80105a:	eb 13                	jmp    80106f <dev_lookup+0x23>
  80105c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80105f:	39 08                	cmp    %ecx,(%eax)
  801061:	75 0c                	jne    80106f <dev_lookup+0x23>
			*dev = devtab[i];
  801063:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801066:	89 01                	mov    %eax,(%ecx)
			return 0;
  801068:	b8 00 00 00 00       	mov    $0x0,%eax
  80106d:	eb 30                	jmp    80109f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80106f:	8b 02                	mov    (%edx),%eax
  801071:	85 c0                	test   %eax,%eax
  801073:	75 e7                	jne    80105c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801075:	a1 08 40 80 00       	mov    0x804008,%eax
  80107a:	8b 40 48             	mov    0x48(%eax),%eax
  80107d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801081:	89 44 24 04          	mov    %eax,0x4(%esp)
  801085:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  80108c:	e8 35 f1 ff ff       	call   8001c6 <cprintf>
	*dev = 0;
  801091:	8b 45 0c             	mov    0xc(%ebp),%eax
  801094:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80109a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80109f:	c9                   	leave  
  8010a0:	c3                   	ret    

008010a1 <fd_close>:
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 20             	sub    $0x20,%esp
  8010a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010bc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010bf:	89 04 24             	mov    %eax,(%esp)
  8010c2:	e8 2f ff ff ff       	call   800ff6 <fd_lookup>
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 05                	js     8010d0 <fd_close+0x2f>
	    || fd != fd2)
  8010cb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010ce:	74 0c                	je     8010dc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8010d0:	84 db                	test   %bl,%bl
  8010d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d7:	0f 44 c2             	cmove  %edx,%eax
  8010da:	eb 3f                	jmp    80111b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e3:	8b 06                	mov    (%esi),%eax
  8010e5:	89 04 24             	mov    %eax,(%esp)
  8010e8:	e8 5f ff ff ff       	call   80104c <dev_lookup>
  8010ed:	89 c3                	mov    %eax,%ebx
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 16                	js     801109 <fd_close+0x68>
		if (dev->dev_close)
  8010f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010fe:	85 c0                	test   %eax,%eax
  801100:	74 07                	je     801109 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801102:	89 34 24             	mov    %esi,(%esp)
  801105:	ff d0                	call   *%eax
  801107:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801109:	89 74 24 04          	mov    %esi,0x4(%esp)
  80110d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801114:	e8 91 fb ff ff       	call   800caa <sys_page_unmap>
	return r;
  801119:	89 d8                	mov    %ebx,%eax
}
  80111b:	83 c4 20             	add    $0x20,%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <close>:

int
close(int fdnum)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801128:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	89 04 24             	mov    %eax,(%esp)
  801135:	e8 bc fe ff ff       	call   800ff6 <fd_lookup>
  80113a:	89 c2                	mov    %eax,%edx
  80113c:	85 d2                	test   %edx,%edx
  80113e:	78 13                	js     801153 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801140:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801147:	00 
  801148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114b:	89 04 24             	mov    %eax,(%esp)
  80114e:	e8 4e ff ff ff       	call   8010a1 <fd_close>
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    

00801155 <close_all>:

void
close_all(void)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	53                   	push   %ebx
  801159:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80115c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801161:	89 1c 24             	mov    %ebx,(%esp)
  801164:	e8 b9 ff ff ff       	call   801122 <close>
	for (i = 0; i < MAXFD; i++)
  801169:	83 c3 01             	add    $0x1,%ebx
  80116c:	83 fb 20             	cmp    $0x20,%ebx
  80116f:	75 f0                	jne    801161 <close_all+0xc>
}
  801171:	83 c4 14             	add    $0x14,%esp
  801174:	5b                   	pop    %ebx
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	57                   	push   %edi
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801180:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801183:	89 44 24 04          	mov    %eax,0x4(%esp)
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	89 04 24             	mov    %eax,(%esp)
  80118d:	e8 64 fe ff ff       	call   800ff6 <fd_lookup>
  801192:	89 c2                	mov    %eax,%edx
  801194:	85 d2                	test   %edx,%edx
  801196:	0f 88 e1 00 00 00    	js     80127d <dup+0x106>
		return r;
	close(newfdnum);
  80119c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	e8 7b ff ff ff       	call   801122 <close>

	newfd = INDEX2FD(newfdnum);
  8011a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011aa:	c1 e3 0c             	shl    $0xc,%ebx
  8011ad:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b6:	89 04 24             	mov    %eax,(%esp)
  8011b9:	e8 d2 fd ff ff       	call   800f90 <fd2data>
  8011be:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8011c0:	89 1c 24             	mov    %ebx,(%esp)
  8011c3:	e8 c8 fd ff ff       	call   800f90 <fd2data>
  8011c8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ca:	89 f0                	mov    %esi,%eax
  8011cc:	c1 e8 16             	shr    $0x16,%eax
  8011cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011d6:	a8 01                	test   $0x1,%al
  8011d8:	74 43                	je     80121d <dup+0xa6>
  8011da:	89 f0                	mov    %esi,%eax
  8011dc:	c1 e8 0c             	shr    $0xc,%eax
  8011df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011e6:	f6 c2 01             	test   $0x1,%dl
  8011e9:	74 32                	je     80121d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801206:	00 
  801207:	89 74 24 04          	mov    %esi,0x4(%esp)
  80120b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801212:	e8 40 fa ff ff       	call   800c57 <sys_page_map>
  801217:	89 c6                	mov    %eax,%esi
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 3e                	js     80125b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80121d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801220:	89 c2                	mov    %eax,%edx
  801222:	c1 ea 0c             	shr    $0xc,%edx
  801225:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801232:	89 54 24 10          	mov    %edx,0x10(%esp)
  801236:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80123a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801241:	00 
  801242:	89 44 24 04          	mov    %eax,0x4(%esp)
  801246:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80124d:	e8 05 fa ff ff       	call   800c57 <sys_page_map>
  801252:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801254:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801257:	85 f6                	test   %esi,%esi
  801259:	79 22                	jns    80127d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80125b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80125f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801266:	e8 3f fa ff ff       	call   800caa <sys_page_unmap>
	sys_page_unmap(0, nva);
  80126b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80126f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801276:	e8 2f fa ff ff       	call   800caa <sys_page_unmap>
	return r;
  80127b:	89 f0                	mov    %esi,%eax
}
  80127d:	83 c4 3c             	add    $0x3c,%esp
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	53                   	push   %ebx
  801289:	83 ec 24             	sub    $0x24,%esp
  80128c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801292:	89 44 24 04          	mov    %eax,0x4(%esp)
  801296:	89 1c 24             	mov    %ebx,(%esp)
  801299:	e8 58 fd ff ff       	call   800ff6 <fd_lookup>
  80129e:	89 c2                	mov    %eax,%edx
  8012a0:	85 d2                	test   %edx,%edx
  8012a2:	78 6d                	js     801311 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ae:	8b 00                	mov    (%eax),%eax
  8012b0:	89 04 24             	mov    %eax,(%esp)
  8012b3:	e8 94 fd ff ff       	call   80104c <dev_lookup>
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 55                	js     801311 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	8b 50 08             	mov    0x8(%eax),%edx
  8012c2:	83 e2 03             	and    $0x3,%edx
  8012c5:	83 fa 01             	cmp    $0x1,%edx
  8012c8:	75 23                	jne    8012ed <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8012cf:	8b 40 48             	mov    0x48(%eax),%eax
  8012d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012da:	c7 04 24 ed 23 80 00 	movl   $0x8023ed,(%esp)
  8012e1:	e8 e0 ee ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  8012e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012eb:	eb 24                	jmp    801311 <read+0x8c>
	}
	if (!dev->dev_read)
  8012ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f0:	8b 52 08             	mov    0x8(%edx),%edx
  8012f3:	85 d2                	test   %edx,%edx
  8012f5:	74 15                	je     80130c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801301:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801305:	89 04 24             	mov    %eax,(%esp)
  801308:	ff d2                	call   *%edx
  80130a:	eb 05                	jmp    801311 <read+0x8c>
		return -E_NOT_SUPP;
  80130c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801311:	83 c4 24             	add    $0x24,%esp
  801314:	5b                   	pop    %ebx
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    

00801317 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	57                   	push   %edi
  80131b:	56                   	push   %esi
  80131c:	53                   	push   %ebx
  80131d:	83 ec 1c             	sub    $0x1c,%esp
  801320:	8b 7d 08             	mov    0x8(%ebp),%edi
  801323:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801326:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132b:	eb 23                	jmp    801350 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80132d:	89 f0                	mov    %esi,%eax
  80132f:	29 d8                	sub    %ebx,%eax
  801331:	89 44 24 08          	mov    %eax,0x8(%esp)
  801335:	89 d8                	mov    %ebx,%eax
  801337:	03 45 0c             	add    0xc(%ebp),%eax
  80133a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133e:	89 3c 24             	mov    %edi,(%esp)
  801341:	e8 3f ff ff ff       	call   801285 <read>
		if (m < 0)
  801346:	85 c0                	test   %eax,%eax
  801348:	78 10                	js     80135a <readn+0x43>
			return m;
		if (m == 0)
  80134a:	85 c0                	test   %eax,%eax
  80134c:	74 0a                	je     801358 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80134e:	01 c3                	add    %eax,%ebx
  801350:	39 f3                	cmp    %esi,%ebx
  801352:	72 d9                	jb     80132d <readn+0x16>
  801354:	89 d8                	mov    %ebx,%eax
  801356:	eb 02                	jmp    80135a <readn+0x43>
  801358:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80135a:	83 c4 1c             	add    $0x1c,%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5f                   	pop    %edi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	53                   	push   %ebx
  801366:	83 ec 24             	sub    $0x24,%esp
  801369:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801373:	89 1c 24             	mov    %ebx,(%esp)
  801376:	e8 7b fc ff ff       	call   800ff6 <fd_lookup>
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	85 d2                	test   %edx,%edx
  80137f:	78 68                	js     8013e9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138b:	8b 00                	mov    (%eax),%eax
  80138d:	89 04 24             	mov    %eax,(%esp)
  801390:	e8 b7 fc ff ff       	call   80104c <dev_lookup>
  801395:	85 c0                	test   %eax,%eax
  801397:	78 50                	js     8013e9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801399:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013a0:	75 23                	jne    8013c5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a2:	a1 08 40 80 00       	mov    0x804008,%eax
  8013a7:	8b 40 48             	mov    0x48(%eax),%eax
  8013aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b2:	c7 04 24 09 24 80 00 	movl   $0x802409,(%esp)
  8013b9:	e8 08 ee ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  8013be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c3:	eb 24                	jmp    8013e9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013cb:	85 d2                	test   %edx,%edx
  8013cd:	74 15                	je     8013e4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013d2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013dd:	89 04 24             	mov    %eax,(%esp)
  8013e0:	ff d2                	call   *%edx
  8013e2:	eb 05                	jmp    8013e9 <write+0x87>
		return -E_NOT_SUPP;
  8013e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013e9:	83 c4 24             	add    $0x24,%esp
  8013ec:	5b                   	pop    %ebx
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <seek>:

int
seek(int fdnum, off_t offset)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	89 04 24             	mov    %eax,(%esp)
  801402:	e8 ef fb ff ff       	call   800ff6 <fd_lookup>
  801407:	85 c0                	test   %eax,%eax
  801409:	78 0e                	js     801419 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80140b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80140e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801411:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801414:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	53                   	push   %ebx
  80141f:	83 ec 24             	sub    $0x24,%esp
  801422:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801425:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142c:	89 1c 24             	mov    %ebx,(%esp)
  80142f:	e8 c2 fb ff ff       	call   800ff6 <fd_lookup>
  801434:	89 c2                	mov    %eax,%edx
  801436:	85 d2                	test   %edx,%edx
  801438:	78 61                	js     80149b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801441:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801444:	8b 00                	mov    (%eax),%eax
  801446:	89 04 24             	mov    %eax,(%esp)
  801449:	e8 fe fb ff ff       	call   80104c <dev_lookup>
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 49                	js     80149b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801455:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801459:	75 23                	jne    80147e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80145b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801460:	8b 40 48             	mov    0x48(%eax),%eax
  801463:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  801472:	e8 4f ed ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  801477:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147c:	eb 1d                	jmp    80149b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80147e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801481:	8b 52 18             	mov    0x18(%edx),%edx
  801484:	85 d2                	test   %edx,%edx
  801486:	74 0e                	je     801496 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80148f:	89 04 24             	mov    %eax,(%esp)
  801492:	ff d2                	call   *%edx
  801494:	eb 05                	jmp    80149b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801496:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80149b:	83 c4 24             	add    $0x24,%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5d                   	pop    %ebp
  8014a0:	c3                   	ret    

008014a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 24             	sub    $0x24,%esp
  8014a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	89 04 24             	mov    %eax,(%esp)
  8014b8:	e8 39 fb ff ff       	call   800ff6 <fd_lookup>
  8014bd:	89 c2                	mov    %eax,%edx
  8014bf:	85 d2                	test   %edx,%edx
  8014c1:	78 52                	js     801515 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cd:	8b 00                	mov    (%eax),%eax
  8014cf:	89 04 24             	mov    %eax,(%esp)
  8014d2:	e8 75 fb ff ff       	call   80104c <dev_lookup>
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 3a                	js     801515 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8014db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014e2:	74 2c                	je     801510 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014ee:	00 00 00 
	stat->st_isdir = 0;
  8014f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014f8:	00 00 00 
	stat->st_dev = dev;
  8014fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801501:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801505:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801508:	89 14 24             	mov    %edx,(%esp)
  80150b:	ff 50 14             	call   *0x14(%eax)
  80150e:	eb 05                	jmp    801515 <fstat+0x74>
		return -E_NOT_SUPP;
  801510:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801515:	83 c4 24             	add    $0x24,%esp
  801518:	5b                   	pop    %ebx
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    

0080151b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	56                   	push   %esi
  80151f:	53                   	push   %ebx
  801520:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801523:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80152a:	00 
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	e8 fb 01 00 00       	call   801731 <open>
  801536:	89 c3                	mov    %eax,%ebx
  801538:	85 db                	test   %ebx,%ebx
  80153a:	78 1b                	js     801557 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80153c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801543:	89 1c 24             	mov    %ebx,(%esp)
  801546:	e8 56 ff ff ff       	call   8014a1 <fstat>
  80154b:	89 c6                	mov    %eax,%esi
	close(fd);
  80154d:	89 1c 24             	mov    %ebx,(%esp)
  801550:	e8 cd fb ff ff       	call   801122 <close>
	return r;
  801555:	89 f0                	mov    %esi,%eax
}
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	56                   	push   %esi
  801562:	53                   	push   %ebx
  801563:	83 ec 10             	sub    $0x10,%esp
  801566:	89 c6                	mov    %eax,%esi
  801568:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80156a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801571:	75 11                	jne    801584 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801573:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80157a:	e8 c0 f9 ff ff       	call   800f3f <ipc_find_env>
  80157f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801584:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80158b:	00 
  80158c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801593:	00 
  801594:	89 74 24 04          	mov    %esi,0x4(%esp)
  801598:	a1 04 40 80 00       	mov    0x804004,%eax
  80159d:	89 04 24             	mov    %eax,(%esp)
  8015a0:	e8 33 f9 ff ff       	call   800ed8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015ac:	00 
  8015ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b8:	e8 b3 f8 ff ff       	call   800e70 <ipc_recv>
}
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5e                   	pop    %esi
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    

008015c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8015e7:	e8 72 ff ff ff       	call   80155e <fsipc>
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <devfile_flush>:
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801604:	b8 06 00 00 00       	mov    $0x6,%eax
  801609:	e8 50 ff ff ff       	call   80155e <fsipc>
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <devfile_stat>:
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	53                   	push   %ebx
  801614:	83 ec 14             	sub    $0x14,%esp
  801617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80161a:	8b 45 08             	mov    0x8(%ebp),%eax
  80161d:	8b 40 0c             	mov    0xc(%eax),%eax
  801620:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801625:	ba 00 00 00 00       	mov    $0x0,%edx
  80162a:	b8 05 00 00 00       	mov    $0x5,%eax
  80162f:	e8 2a ff ff ff       	call   80155e <fsipc>
  801634:	89 c2                	mov    %eax,%edx
  801636:	85 d2                	test   %edx,%edx
  801638:	78 2b                	js     801665 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80163a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801641:	00 
  801642:	89 1c 24             	mov    %ebx,(%esp)
  801645:	e8 9d f1 ff ff       	call   8007e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80164a:	a1 80 50 80 00       	mov    0x805080,%eax
  80164f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801655:	a1 84 50 80 00       	mov    0x805084,%eax
  80165a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801660:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801665:	83 c4 14             	add    $0x14,%esp
  801668:	5b                   	pop    %ebx
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    

0080166b <devfile_write>:
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801671:	c7 44 24 08 38 24 80 	movl   $0x802438,0x8(%esp)
  801678:	00 
  801679:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801680:	00 
  801681:	c7 04 24 56 24 80 00 	movl   $0x802456,(%esp)
  801688:	e8 69 06 00 00       	call   801cf6 <_panic>

0080168d <devfile_read>:
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	56                   	push   %esi
  801691:	53                   	push   %ebx
  801692:	83 ec 10             	sub    $0x10,%esp
  801695:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	8b 40 0c             	mov    0xc(%eax),%eax
  80169e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8016b3:	e8 a6 fe ff ff       	call   80155e <fsipc>
  8016b8:	89 c3                	mov    %eax,%ebx
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 6a                	js     801728 <devfile_read+0x9b>
	assert(r <= n);
  8016be:	39 c6                	cmp    %eax,%esi
  8016c0:	73 24                	jae    8016e6 <devfile_read+0x59>
  8016c2:	c7 44 24 0c 61 24 80 	movl   $0x802461,0xc(%esp)
  8016c9:	00 
  8016ca:	c7 44 24 08 68 24 80 	movl   $0x802468,0x8(%esp)
  8016d1:	00 
  8016d2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016d9:	00 
  8016da:	c7 04 24 56 24 80 00 	movl   $0x802456,(%esp)
  8016e1:	e8 10 06 00 00       	call   801cf6 <_panic>
	assert(r <= PGSIZE);
  8016e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016eb:	7e 24                	jle    801711 <devfile_read+0x84>
  8016ed:	c7 44 24 0c 7d 24 80 	movl   $0x80247d,0xc(%esp)
  8016f4:	00 
  8016f5:	c7 44 24 08 68 24 80 	movl   $0x802468,0x8(%esp)
  8016fc:	00 
  8016fd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801704:	00 
  801705:	c7 04 24 56 24 80 00 	movl   $0x802456,(%esp)
  80170c:	e8 e5 05 00 00       	call   801cf6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801711:	89 44 24 08          	mov    %eax,0x8(%esp)
  801715:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80171c:	00 
  80171d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801720:	89 04 24             	mov    %eax,(%esp)
  801723:	e8 5c f2 ff ff       	call   800984 <memmove>
}
  801728:	89 d8                	mov    %ebx,%eax
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <open>:
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	53                   	push   %ebx
  801735:	83 ec 24             	sub    $0x24,%esp
  801738:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80173b:	89 1c 24             	mov    %ebx,(%esp)
  80173e:	e8 6d f0 ff ff       	call   8007b0 <strlen>
  801743:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801748:	7f 60                	jg     8017aa <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80174a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174d:	89 04 24             	mov    %eax,(%esp)
  801750:	e8 52 f8 ff ff       	call   800fa7 <fd_alloc>
  801755:	89 c2                	mov    %eax,%edx
  801757:	85 d2                	test   %edx,%edx
  801759:	78 54                	js     8017af <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80175b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80175f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801766:	e8 7c f0 ff ff       	call   8007e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801773:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801776:	b8 01 00 00 00       	mov    $0x1,%eax
  80177b:	e8 de fd ff ff       	call   80155e <fsipc>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	85 c0                	test   %eax,%eax
  801784:	79 17                	jns    80179d <open+0x6c>
		fd_close(fd, 0);
  801786:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80178d:	00 
  80178e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 08 f9 ff ff       	call   8010a1 <fd_close>
		return r;
  801799:	89 d8                	mov    %ebx,%eax
  80179b:	eb 12                	jmp    8017af <open+0x7e>
	return fd2num(fd);
  80179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a0:	89 04 24             	mov    %eax,(%esp)
  8017a3:	e8 d8 f7 ff ff       	call   800f80 <fd2num>
  8017a8:	eb 05                	jmp    8017af <open+0x7e>
		return -E_BAD_PATH;
  8017aa:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8017af:	83 c4 24             	add    $0x24,%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8017c5:	e8 94 fd ff ff       	call   80155e <fsipc>
}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	83 ec 10             	sub    $0x10,%esp
  8017d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	89 04 24             	mov    %eax,(%esp)
  8017dd:	e8 ae f7 ff ff       	call   800f90 <fd2data>
  8017e2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017e4:	c7 44 24 04 89 24 80 	movl   $0x802489,0x4(%esp)
  8017eb:	00 
  8017ec:	89 1c 24             	mov    %ebx,(%esp)
  8017ef:	e8 f3 ef ff ff       	call   8007e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017f4:	8b 46 04             	mov    0x4(%esi),%eax
  8017f7:	2b 06                	sub    (%esi),%eax
  8017f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801806:	00 00 00 
	stat->st_dev = &devpipe;
  801809:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801810:	30 80 00 
	return 0;
}
  801813:	b8 00 00 00 00       	mov    $0x0,%eax
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 14             	sub    $0x14,%esp
  801826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801829:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80182d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801834:	e8 71 f4 ff ff       	call   800caa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801839:	89 1c 24             	mov    %ebx,(%esp)
  80183c:	e8 4f f7 ff ff       	call   800f90 <fd2data>
  801841:	89 44 24 04          	mov    %eax,0x4(%esp)
  801845:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80184c:	e8 59 f4 ff ff       	call   800caa <sys_page_unmap>
}
  801851:	83 c4 14             	add    $0x14,%esp
  801854:	5b                   	pop    %ebx
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <_pipeisclosed>:
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	57                   	push   %edi
  80185b:	56                   	push   %esi
  80185c:	53                   	push   %ebx
  80185d:	83 ec 2c             	sub    $0x2c,%esp
  801860:	89 c6                	mov    %eax,%esi
  801862:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801865:	a1 08 40 80 00       	mov    0x804008,%eax
  80186a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80186d:	89 34 24             	mov    %esi,(%esp)
  801870:	e8 d7 04 00 00       	call   801d4c <pageref>
  801875:	89 c7                	mov    %eax,%edi
  801877:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80187a:	89 04 24             	mov    %eax,(%esp)
  80187d:	e8 ca 04 00 00       	call   801d4c <pageref>
  801882:	39 c7                	cmp    %eax,%edi
  801884:	0f 94 c2             	sete   %dl
  801887:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80188a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801890:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801893:	39 fb                	cmp    %edi,%ebx
  801895:	74 21                	je     8018b8 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801897:	84 d2                	test   %dl,%dl
  801899:	74 ca                	je     801865 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80189b:	8b 51 58             	mov    0x58(%ecx),%edx
  80189e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018aa:	c7 04 24 90 24 80 00 	movl   $0x802490,(%esp)
  8018b1:	e8 10 e9 ff ff       	call   8001c6 <cprintf>
  8018b6:	eb ad                	jmp    801865 <_pipeisclosed+0xe>
}
  8018b8:	83 c4 2c             	add    $0x2c,%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5f                   	pop    %edi
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    

008018c0 <devpipe_write>:
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	57                   	push   %edi
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	83 ec 1c             	sub    $0x1c,%esp
  8018c9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8018cc:	89 34 24             	mov    %esi,(%esp)
  8018cf:	e8 bc f6 ff ff       	call   800f90 <fd2data>
  8018d4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018d6:	bf 00 00 00 00       	mov    $0x0,%edi
  8018db:	eb 45                	jmp    801922 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  8018dd:	89 da                	mov    %ebx,%edx
  8018df:	89 f0                	mov    %esi,%eax
  8018e1:	e8 71 ff ff ff       	call   801857 <_pipeisclosed>
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	75 41                	jne    80192b <devpipe_write+0x6b>
			sys_yield();
  8018ea:	e8 f5 f2 ff ff       	call   800be4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8018f2:	8b 0b                	mov    (%ebx),%ecx
  8018f4:	8d 51 20             	lea    0x20(%ecx),%edx
  8018f7:	39 d0                	cmp    %edx,%eax
  8018f9:	73 e2                	jae    8018dd <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801902:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801905:	99                   	cltd   
  801906:	c1 ea 1b             	shr    $0x1b,%edx
  801909:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80190c:	83 e1 1f             	and    $0x1f,%ecx
  80190f:	29 d1                	sub    %edx,%ecx
  801911:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801915:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801919:	83 c0 01             	add    $0x1,%eax
  80191c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80191f:	83 c7 01             	add    $0x1,%edi
  801922:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801925:	75 c8                	jne    8018ef <devpipe_write+0x2f>
	return i;
  801927:	89 f8                	mov    %edi,%eax
  801929:	eb 05                	jmp    801930 <devpipe_write+0x70>
				return 0;
  80192b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801930:	83 c4 1c             	add    $0x1c,%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	5f                   	pop    %edi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    

00801938 <devpipe_read>:
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	57                   	push   %edi
  80193c:	56                   	push   %esi
  80193d:	53                   	push   %ebx
  80193e:	83 ec 1c             	sub    $0x1c,%esp
  801941:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801944:	89 3c 24             	mov    %edi,(%esp)
  801947:	e8 44 f6 ff ff       	call   800f90 <fd2data>
  80194c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80194e:	be 00 00 00 00       	mov    $0x0,%esi
  801953:	eb 3d                	jmp    801992 <devpipe_read+0x5a>
			if (i > 0)
  801955:	85 f6                	test   %esi,%esi
  801957:	74 04                	je     80195d <devpipe_read+0x25>
				return i;
  801959:	89 f0                	mov    %esi,%eax
  80195b:	eb 43                	jmp    8019a0 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  80195d:	89 da                	mov    %ebx,%edx
  80195f:	89 f8                	mov    %edi,%eax
  801961:	e8 f1 fe ff ff       	call   801857 <_pipeisclosed>
  801966:	85 c0                	test   %eax,%eax
  801968:	75 31                	jne    80199b <devpipe_read+0x63>
			sys_yield();
  80196a:	e8 75 f2 ff ff       	call   800be4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80196f:	8b 03                	mov    (%ebx),%eax
  801971:	3b 43 04             	cmp    0x4(%ebx),%eax
  801974:	74 df                	je     801955 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801976:	99                   	cltd   
  801977:	c1 ea 1b             	shr    $0x1b,%edx
  80197a:	01 d0                	add    %edx,%eax
  80197c:	83 e0 1f             	and    $0x1f,%eax
  80197f:	29 d0                	sub    %edx,%eax
  801981:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801986:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801989:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80198c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80198f:	83 c6 01             	add    $0x1,%esi
  801992:	3b 75 10             	cmp    0x10(%ebp),%esi
  801995:	75 d8                	jne    80196f <devpipe_read+0x37>
	return i;
  801997:	89 f0                	mov    %esi,%eax
  801999:	eb 05                	jmp    8019a0 <devpipe_read+0x68>
				return 0;
  80199b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a0:	83 c4 1c             	add    $0x1c,%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5f                   	pop    %edi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <pipe>:
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	89 04 24             	mov    %eax,(%esp)
  8019b6:	e8 ec f5 ff ff       	call   800fa7 <fd_alloc>
  8019bb:	89 c2                	mov    %eax,%edx
  8019bd:	85 d2                	test   %edx,%edx
  8019bf:	0f 88 4d 01 00 00    	js     801b12 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019cc:	00 
  8019cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019db:	e8 23 f2 ff ff       	call   800c03 <sys_page_alloc>
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	85 d2                	test   %edx,%edx
  8019e4:	0f 88 28 01 00 00    	js     801b12 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  8019ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ed:	89 04 24             	mov    %eax,(%esp)
  8019f0:	e8 b2 f5 ff ff       	call   800fa7 <fd_alloc>
  8019f5:	89 c3                	mov    %eax,%ebx
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	0f 88 fe 00 00 00    	js     801afd <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019ff:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a06:	00 
  801a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a15:	e8 e9 f1 ff ff       	call   800c03 <sys_page_alloc>
  801a1a:	89 c3                	mov    %eax,%ebx
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	0f 88 d9 00 00 00    	js     801afd <pipe+0x155>
	va = fd2data(fd0);
  801a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a27:	89 04 24             	mov    %eax,(%esp)
  801a2a:	e8 61 f5 ff ff       	call   800f90 <fd2data>
  801a2f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a31:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a38:	00 
  801a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a44:	e8 ba f1 ff ff       	call   800c03 <sys_page_alloc>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	0f 88 97 00 00 00    	js     801aea <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a56:	89 04 24             	mov    %eax,(%esp)
  801a59:	e8 32 f5 ff ff       	call   800f90 <fd2data>
  801a5e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a65:	00 
  801a66:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a71:	00 
  801a72:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7d:	e8 d5 f1 ff ff       	call   800c57 <sys_page_map>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	85 c0                	test   %eax,%eax
  801a86:	78 52                	js     801ada <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801a88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a91:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801a9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aab:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab5:	89 04 24             	mov    %eax,(%esp)
  801ab8:	e8 c3 f4 ff ff       	call   800f80 <fd2num>
  801abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ac0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac5:	89 04 24             	mov    %eax,(%esp)
  801ac8:	e8 b3 f4 ff ff       	call   800f80 <fd2num>
  801acd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad8:	eb 38                	jmp    801b12 <pipe+0x16a>
	sys_page_unmap(0, va);
  801ada:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ade:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae5:	e8 c0 f1 ff ff       	call   800caa <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af8:	e8 ad f1 ff ff       	call   800caa <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b0b:	e8 9a f1 ff ff       	call   800caa <sys_page_unmap>
  801b10:	89 d8                	mov    %ebx,%eax
}
  801b12:	83 c4 30             	add    $0x30,%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <pipeisclosed>:
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	89 04 24             	mov    %eax,(%esp)
  801b2c:	e8 c5 f4 ff ff       	call   800ff6 <fd_lookup>
  801b31:	89 c2                	mov    %eax,%edx
  801b33:	85 d2                	test   %edx,%edx
  801b35:	78 15                	js     801b4c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3a:	89 04 24             	mov    %eax,(%esp)
  801b3d:	e8 4e f4 ff ff       	call   800f90 <fd2data>
	return _pipeisclosed(fd, p);
  801b42:	89 c2                	mov    %eax,%edx
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	e8 0b fd ff ff       	call   801857 <_pipeisclosed>
}
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    
  801b4e:	66 90                	xchg   %ax,%ax

00801b50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801b60:	c7 44 24 04 a8 24 80 	movl   $0x8024a8,0x4(%esp)
  801b67:	00 
  801b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6b:	89 04 24             	mov    %eax,(%esp)
  801b6e:	e8 74 ec ff ff       	call   8007e7 <strcpy>
	return 0;
}
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <devcons_write>:
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	57                   	push   %edi
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b86:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b91:	eb 31                	jmp    801bc4 <devcons_write+0x4a>
		m = n - tot;
  801b93:	8b 75 10             	mov    0x10(%ebp),%esi
  801b96:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b98:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801b9b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ba0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ba3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ba7:	03 45 0c             	add    0xc(%ebp),%eax
  801baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bae:	89 3c 24             	mov    %edi,(%esp)
  801bb1:	e8 ce ed ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  801bb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bba:	89 3c 24             	mov    %edi,(%esp)
  801bbd:	e8 74 ef ff ff       	call   800b36 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801bc2:	01 f3                	add    %esi,%ebx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bc9:	72 c8                	jb     801b93 <devcons_write+0x19>
}
  801bcb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <devcons_read>:
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801be1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801be5:	75 07                	jne    801bee <devcons_read+0x18>
  801be7:	eb 2a                	jmp    801c13 <devcons_read+0x3d>
		sys_yield();
  801be9:	e8 f6 ef ff ff       	call   800be4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801bee:	66 90                	xchg   %ax,%ax
  801bf0:	e8 5f ef ff ff       	call   800b54 <sys_cgetc>
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	74 f0                	je     801be9 <devcons_read+0x13>
	if (c < 0)
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	78 16                	js     801c13 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801bfd:	83 f8 04             	cmp    $0x4,%eax
  801c00:	74 0c                	je     801c0e <devcons_read+0x38>
	*(char*)vbuf = c;
  801c02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c05:	88 02                	mov    %al,(%edx)
	return 1;
  801c07:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0c:	eb 05                	jmp    801c13 <devcons_read+0x3d>
		return 0;
  801c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <cputchar>:
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c28:	00 
  801c29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c2c:	89 04 24             	mov    %eax,(%esp)
  801c2f:	e8 02 ef ff ff       	call   800b36 <sys_cputs>
}
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <getchar>:
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801c3c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c43:	00 
  801c44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c52:	e8 2e f6 ff ff       	call   801285 <read>
	if (r < 0)
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 0f                	js     801c6a <getchar+0x34>
	if (r < 1)
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	7e 06                	jle    801c65 <getchar+0x2f>
	return c;
  801c5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c63:	eb 05                	jmp    801c6a <getchar+0x34>
		return -E_EOF;
  801c65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <iscons>:
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c79:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7c:	89 04 24             	mov    %eax,(%esp)
  801c7f:	e8 72 f3 ff ff       	call   800ff6 <fd_lookup>
  801c84:	85 c0                	test   %eax,%eax
  801c86:	78 11                	js     801c99 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c91:	39 10                	cmp    %edx,(%eax)
  801c93:	0f 94 c0             	sete   %al
  801c96:	0f b6 c0             	movzbl %al,%eax
}
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <opencons>:
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ca1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca4:	89 04 24             	mov    %eax,(%esp)
  801ca7:	e8 fb f2 ff ff       	call   800fa7 <fd_alloc>
		return r;
  801cac:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	78 40                	js     801cf2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cb9:	00 
  801cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc8:	e8 36 ef ff ff       	call   800c03 <sys_page_alloc>
		return r;
  801ccd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 1f                	js     801cf2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801cd3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ce8:	89 04 24             	mov    %eax,(%esp)
  801ceb:	e8 90 f2 ff ff       	call   800f80 <fd2num>
  801cf0:	89 c2                	mov    %eax,%edx
}
  801cf2:	89 d0                	mov    %edx,%eax
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	56                   	push   %esi
  801cfa:	53                   	push   %ebx
  801cfb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801cfe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d01:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d07:	e8 b9 ee ff ff       	call   800bc5 <sys_getenvid>
  801d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d13:	8b 55 08             	mov    0x8(%ebp),%edx
  801d16:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d1a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d22:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  801d29:	e8 98 e4 ff ff       	call   8001c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d32:	8b 45 10             	mov    0x10(%ebp),%eax
  801d35:	89 04 24             	mov    %eax,(%esp)
  801d38:	e8 28 e4 ff ff       	call   800165 <vcprintf>
	cprintf("\n");
  801d3d:	c7 04 24 a1 24 80 00 	movl   $0x8024a1,(%esp)
  801d44:	e8 7d e4 ff ff       	call   8001c6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d49:	cc                   	int3   
  801d4a:	eb fd                	jmp    801d49 <_panic+0x53>

00801d4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d52:	89 d0                	mov    %edx,%eax
  801d54:	c1 e8 16             	shr    $0x16,%eax
  801d57:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801d63:	f6 c1 01             	test   $0x1,%cl
  801d66:	74 1d                	je     801d85 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801d68:	c1 ea 0c             	shr    $0xc,%edx
  801d6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d72:	f6 c2 01             	test   $0x1,%dl
  801d75:	74 0e                	je     801d85 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d77:	c1 ea 0c             	shr    $0xc,%edx
  801d7a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d81:	ef 
  801d82:	0f b7 c0             	movzwl %ax,%eax
}
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    
  801d87:	66 90                	xchg   %ax,%ax
  801d89:	66 90                	xchg   %ax,%ax
  801d8b:	66 90                	xchg   %ax,%ax
  801d8d:	66 90                	xchg   %ax,%ax
  801d8f:	90                   	nop

00801d90 <__udivdi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	83 ec 0c             	sub    $0xc,%esp
  801d96:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d9a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d9e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801da2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801da6:	85 c0                	test   %eax,%eax
  801da8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dac:	89 ea                	mov    %ebp,%edx
  801dae:	89 0c 24             	mov    %ecx,(%esp)
  801db1:	75 2d                	jne    801de0 <__udivdi3+0x50>
  801db3:	39 e9                	cmp    %ebp,%ecx
  801db5:	77 61                	ja     801e18 <__udivdi3+0x88>
  801db7:	85 c9                	test   %ecx,%ecx
  801db9:	89 ce                	mov    %ecx,%esi
  801dbb:	75 0b                	jne    801dc8 <__udivdi3+0x38>
  801dbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc2:	31 d2                	xor    %edx,%edx
  801dc4:	f7 f1                	div    %ecx
  801dc6:	89 c6                	mov    %eax,%esi
  801dc8:	31 d2                	xor    %edx,%edx
  801dca:	89 e8                	mov    %ebp,%eax
  801dcc:	f7 f6                	div    %esi
  801dce:	89 c5                	mov    %eax,%ebp
  801dd0:	89 f8                	mov    %edi,%eax
  801dd2:	f7 f6                	div    %esi
  801dd4:	89 ea                	mov    %ebp,%edx
  801dd6:	83 c4 0c             	add    $0xc,%esp
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	39 e8                	cmp    %ebp,%eax
  801de2:	77 24                	ja     801e08 <__udivdi3+0x78>
  801de4:	0f bd e8             	bsr    %eax,%ebp
  801de7:	83 f5 1f             	xor    $0x1f,%ebp
  801dea:	75 3c                	jne    801e28 <__udivdi3+0x98>
  801dec:	8b 74 24 04          	mov    0x4(%esp),%esi
  801df0:	39 34 24             	cmp    %esi,(%esp)
  801df3:	0f 86 9f 00 00 00    	jbe    801e98 <__udivdi3+0x108>
  801df9:	39 d0                	cmp    %edx,%eax
  801dfb:	0f 82 97 00 00 00    	jb     801e98 <__udivdi3+0x108>
  801e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e08:	31 d2                	xor    %edx,%edx
  801e0a:	31 c0                	xor    %eax,%eax
  801e0c:	83 c4 0c             	add    $0xc,%esp
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    
  801e13:	90                   	nop
  801e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e18:	89 f8                	mov    %edi,%eax
  801e1a:	f7 f1                	div    %ecx
  801e1c:	31 d2                	xor    %edx,%edx
  801e1e:	83 c4 0c             	add    $0xc,%esp
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    
  801e25:	8d 76 00             	lea    0x0(%esi),%esi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	8b 3c 24             	mov    (%esp),%edi
  801e2d:	d3 e0                	shl    %cl,%eax
  801e2f:	89 c6                	mov    %eax,%esi
  801e31:	b8 20 00 00 00       	mov    $0x20,%eax
  801e36:	29 e8                	sub    %ebp,%eax
  801e38:	89 c1                	mov    %eax,%ecx
  801e3a:	d3 ef                	shr    %cl,%edi
  801e3c:	89 e9                	mov    %ebp,%ecx
  801e3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e42:	8b 3c 24             	mov    (%esp),%edi
  801e45:	09 74 24 08          	or     %esi,0x8(%esp)
  801e49:	89 d6                	mov    %edx,%esi
  801e4b:	d3 e7                	shl    %cl,%edi
  801e4d:	89 c1                	mov    %eax,%ecx
  801e4f:	89 3c 24             	mov    %edi,(%esp)
  801e52:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e56:	d3 ee                	shr    %cl,%esi
  801e58:	89 e9                	mov    %ebp,%ecx
  801e5a:	d3 e2                	shl    %cl,%edx
  801e5c:	89 c1                	mov    %eax,%ecx
  801e5e:	d3 ef                	shr    %cl,%edi
  801e60:	09 d7                	or     %edx,%edi
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	89 f8                	mov    %edi,%eax
  801e66:	f7 74 24 08          	divl   0x8(%esp)
  801e6a:	89 d6                	mov    %edx,%esi
  801e6c:	89 c7                	mov    %eax,%edi
  801e6e:	f7 24 24             	mull   (%esp)
  801e71:	39 d6                	cmp    %edx,%esi
  801e73:	89 14 24             	mov    %edx,(%esp)
  801e76:	72 30                	jb     801ea8 <__udivdi3+0x118>
  801e78:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e7c:	89 e9                	mov    %ebp,%ecx
  801e7e:	d3 e2                	shl    %cl,%edx
  801e80:	39 c2                	cmp    %eax,%edx
  801e82:	73 05                	jae    801e89 <__udivdi3+0xf9>
  801e84:	3b 34 24             	cmp    (%esp),%esi
  801e87:	74 1f                	je     801ea8 <__udivdi3+0x118>
  801e89:	89 f8                	mov    %edi,%eax
  801e8b:	31 d2                	xor    %edx,%edx
  801e8d:	e9 7a ff ff ff       	jmp    801e0c <__udivdi3+0x7c>
  801e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e98:	31 d2                	xor    %edx,%edx
  801e9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9f:	e9 68 ff ff ff       	jmp    801e0c <__udivdi3+0x7c>
  801ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ea8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	83 c4 0c             	add    $0xc,%esp
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    
  801eb4:	66 90                	xchg   %ax,%ax
  801eb6:	66 90                	xchg   %ax,%ax
  801eb8:	66 90                	xchg   %ax,%ax
  801eba:	66 90                	xchg   %ax,%ax
  801ebc:	66 90                	xchg   %ax,%ax
  801ebe:	66 90                	xchg   %ax,%ax

00801ec0 <__umoddi3>:
  801ec0:	55                   	push   %ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	83 ec 14             	sub    $0x14,%esp
  801ec6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801eca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801ece:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801ed2:	89 c7                	mov    %eax,%edi
  801ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801edc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ee0:	89 34 24             	mov    %esi,(%esp)
  801ee3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	89 c2                	mov    %eax,%edx
  801eeb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eef:	75 17                	jne    801f08 <__umoddi3+0x48>
  801ef1:	39 fe                	cmp    %edi,%esi
  801ef3:	76 4b                	jbe    801f40 <__umoddi3+0x80>
  801ef5:	89 c8                	mov    %ecx,%eax
  801ef7:	89 fa                	mov    %edi,%edx
  801ef9:	f7 f6                	div    %esi
  801efb:	89 d0                	mov    %edx,%eax
  801efd:	31 d2                	xor    %edx,%edx
  801eff:	83 c4 14             	add    $0x14,%esp
  801f02:	5e                   	pop    %esi
  801f03:	5f                   	pop    %edi
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	39 f8                	cmp    %edi,%eax
  801f0a:	77 54                	ja     801f60 <__umoddi3+0xa0>
  801f0c:	0f bd e8             	bsr    %eax,%ebp
  801f0f:	83 f5 1f             	xor    $0x1f,%ebp
  801f12:	75 5c                	jne    801f70 <__umoddi3+0xb0>
  801f14:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f18:	39 3c 24             	cmp    %edi,(%esp)
  801f1b:	0f 87 e7 00 00 00    	ja     802008 <__umoddi3+0x148>
  801f21:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f25:	29 f1                	sub    %esi,%ecx
  801f27:	19 c7                	sbb    %eax,%edi
  801f29:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f2d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f31:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f35:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f39:	83 c4 14             	add    $0x14,%esp
  801f3c:	5e                   	pop    %esi
  801f3d:	5f                   	pop    %edi
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    
  801f40:	85 f6                	test   %esi,%esi
  801f42:	89 f5                	mov    %esi,%ebp
  801f44:	75 0b                	jne    801f51 <__umoddi3+0x91>
  801f46:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4b:	31 d2                	xor    %edx,%edx
  801f4d:	f7 f6                	div    %esi
  801f4f:	89 c5                	mov    %eax,%ebp
  801f51:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f55:	31 d2                	xor    %edx,%edx
  801f57:	f7 f5                	div    %ebp
  801f59:	89 c8                	mov    %ecx,%eax
  801f5b:	f7 f5                	div    %ebp
  801f5d:	eb 9c                	jmp    801efb <__umoddi3+0x3b>
  801f5f:	90                   	nop
  801f60:	89 c8                	mov    %ecx,%eax
  801f62:	89 fa                	mov    %edi,%edx
  801f64:	83 c4 14             	add    $0x14,%esp
  801f67:	5e                   	pop    %esi
  801f68:	5f                   	pop    %edi
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    
  801f6b:	90                   	nop
  801f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f70:	8b 04 24             	mov    (%esp),%eax
  801f73:	be 20 00 00 00       	mov    $0x20,%esi
  801f78:	89 e9                	mov    %ebp,%ecx
  801f7a:	29 ee                	sub    %ebp,%esi
  801f7c:	d3 e2                	shl    %cl,%edx
  801f7e:	89 f1                	mov    %esi,%ecx
  801f80:	d3 e8                	shr    %cl,%eax
  801f82:	89 e9                	mov    %ebp,%ecx
  801f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f88:	8b 04 24             	mov    (%esp),%eax
  801f8b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f8f:	89 fa                	mov    %edi,%edx
  801f91:	d3 e0                	shl    %cl,%eax
  801f93:	89 f1                	mov    %esi,%ecx
  801f95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f99:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f9d:	d3 ea                	shr    %cl,%edx
  801f9f:	89 e9                	mov    %ebp,%ecx
  801fa1:	d3 e7                	shl    %cl,%edi
  801fa3:	89 f1                	mov    %esi,%ecx
  801fa5:	d3 e8                	shr    %cl,%eax
  801fa7:	89 e9                	mov    %ebp,%ecx
  801fa9:	09 f8                	or     %edi,%eax
  801fab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801faf:	f7 74 24 04          	divl   0x4(%esp)
  801fb3:	d3 e7                	shl    %cl,%edi
  801fb5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fb9:	89 d7                	mov    %edx,%edi
  801fbb:	f7 64 24 08          	mull   0x8(%esp)
  801fbf:	39 d7                	cmp    %edx,%edi
  801fc1:	89 c1                	mov    %eax,%ecx
  801fc3:	89 14 24             	mov    %edx,(%esp)
  801fc6:	72 2c                	jb     801ff4 <__umoddi3+0x134>
  801fc8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801fcc:	72 22                	jb     801ff0 <__umoddi3+0x130>
  801fce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fd2:	29 c8                	sub    %ecx,%eax
  801fd4:	19 d7                	sbb    %edx,%edi
  801fd6:	89 e9                	mov    %ebp,%ecx
  801fd8:	89 fa                	mov    %edi,%edx
  801fda:	d3 e8                	shr    %cl,%eax
  801fdc:	89 f1                	mov    %esi,%ecx
  801fde:	d3 e2                	shl    %cl,%edx
  801fe0:	89 e9                	mov    %ebp,%ecx
  801fe2:	d3 ef                	shr    %cl,%edi
  801fe4:	09 d0                	or     %edx,%eax
  801fe6:	89 fa                	mov    %edi,%edx
  801fe8:	83 c4 14             	add    $0x14,%esp
  801feb:	5e                   	pop    %esi
  801fec:	5f                   	pop    %edi
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    
  801fef:	90                   	nop
  801ff0:	39 d7                	cmp    %edx,%edi
  801ff2:	75 da                	jne    801fce <__umoddi3+0x10e>
  801ff4:	8b 14 24             	mov    (%esp),%edx
  801ff7:	89 c1                	mov    %eax,%ecx
  801ff9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801ffd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802001:	eb cb                	jmp    801fce <__umoddi3+0x10e>
  802003:	90                   	nop
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80200c:	0f 82 0f ff ff ff    	jb     801f21 <__umoddi3+0x61>
  802012:	e9 1a ff ff ff       	jmp    801f31 <__umoddi3+0x71>
