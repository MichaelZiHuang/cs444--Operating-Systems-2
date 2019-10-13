
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 62 00 00 00       	call   800093 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	89 44 24 04          	mov    %eax,0x4(%esp)
  800045:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80004c:	e8 9c 01 00 00       	call   8001ed <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 de 25 80 	movl   $0x8025de,0x4(%esp)
  800060:	00 
  800061:	c7 04 24 de 25 80 00 	movl   $0x8025de,(%esp)
  800068:	e8 c4 1b 00 00       	call   801c31 <spawnl>
  80006d:	85 c0                	test   %eax,%eax
  80006f:	79 20                	jns    800091 <umain+0x5e>
		panic("spawn(hello) failed: %e", r);
  800071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800075:	c7 44 24 08 e4 25 80 	movl   $0x8025e4,0x8(%esp)
  80007c:	00 
  80007d:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800084:	00 
  800085:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  80008c:	e8 63 00 00 00       	call   8000f4 <_panic>
}
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
  800098:	83 ec 10             	sub    $0x10,%esp
  80009b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80009e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8000a1:	e8 4f 0b 00 00       	call   800bf5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8000a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b3:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b8:	85 db                	test   %ebx,%ebx
  8000ba:	7e 07                	jle    8000c3 <libmain+0x30>
		binaryname = argv[0];
  8000bc:	8b 06                	mov    (%esi),%eax
  8000be:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c7:	89 1c 24             	mov    %ebx,(%esp)
  8000ca:	e8 64 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cf:	e8 07 00 00 00       	call   8000db <exit>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000e1:	e8 8f 0f 00 00       	call   801075 <close_all>
	sys_env_destroy(0);
  8000e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ed:	e8 b1 0a 00 00       	call   800ba3 <sys_env_destroy>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8000fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800105:	e8 eb 0a 00 00       	call   800bf5 <sys_getenvid>
  80010a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80010d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800111:	8b 55 08             	mov    0x8(%ebp),%edx
  800114:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800118:	89 74 24 08          	mov    %esi,0x8(%esp)
  80011c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800120:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  800127:	e8 c1 00 00 00       	call   8001ed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	8b 45 10             	mov    0x10(%ebp),%eax
  800133:	89 04 24             	mov    %eax,(%esp)
  800136:	e8 51 00 00 00       	call   80018c <vcprintf>
	cprintf("\n");
  80013b:	c7 04 24 00 2b 80 00 	movl   $0x802b00,(%esp)
  800142:	e8 a6 00 00 00       	call   8001ed <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800147:	cc                   	int3   
  800148:	eb fd                	jmp    800147 <_panic+0x53>

0080014a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	53                   	push   %ebx
  80014e:	83 ec 14             	sub    $0x14,%esp
  800151:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800154:	8b 13                	mov    (%ebx),%edx
  800156:	8d 42 01             	lea    0x1(%edx),%eax
  800159:	89 03                	mov    %eax,(%ebx)
  80015b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800162:	3d ff 00 00 00       	cmp    $0xff,%eax
  800167:	75 19                	jne    800182 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800169:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800170:	00 
  800171:	8d 43 08             	lea    0x8(%ebx),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 ea 09 00 00       	call   800b66 <sys_cputs>
		b->idx = 0;
  80017c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800182:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800186:	83 c4 14             	add    $0x14,%esp
  800189:	5b                   	pop    %ebx
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800195:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019c:	00 00 00 
	b.cnt = 0;
  80019f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	c7 04 24 4a 01 80 00 	movl   $0x80014a,(%esp)
  8001c8:	e8 b1 01 00 00       	call   80037e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001dd:	89 04 24             	mov    %eax,(%esp)
  8001e0:	e8 81 09 00 00       	call   800b66 <sys_cputs>

	return b.cnt;
}
  8001e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    

008001ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fd:	89 04 24             	mov    %eax,(%esp)
  800200:	e8 87 ff ff ff       	call   80018c <vcprintf>
	va_end(ap);

	return cnt;
}
  800205:	c9                   	leave  
  800206:	c3                   	ret    
  800207:	66 90                	xchg   %ax,%ax
  800209:	66 90                	xchg   %ax,%ax
  80020b:	66 90                	xchg   %ax,%ax
  80020d:	66 90                	xchg   %ax,%ax
  80020f:	90                   	nop

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 3c             	sub    $0x3c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d7                	mov    %edx,%edi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 c3                	mov    %eax,%ebx
  800229:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80022c:	8b 45 10             	mov    0x10(%ebp),%eax
  80022f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	b9 00 00 00 00       	mov    $0x0,%ecx
  800237:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023d:	39 d9                	cmp    %ebx,%ecx
  80023f:	72 05                	jb     800246 <printnum+0x36>
  800241:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800244:	77 69                	ja     8002af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800246:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800249:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80024d:	83 ee 01             	sub    $0x1,%esi
  800250:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	8b 44 24 08          	mov    0x8(%esp),%eax
  80025c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800260:	89 c3                	mov    %eax,%ebx
  800262:	89 d6                	mov    %edx,%esi
  800264:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800267:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80026a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80026e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 ac 20 00 00       	call   802330 <__udivdi3>
  800284:	89 d9                	mov    %ebx,%ecx
  800286:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028e:	89 04 24             	mov    %eax,(%esp)
  800291:	89 54 24 04          	mov    %edx,0x4(%esp)
  800295:	89 fa                	mov    %edi,%edx
  800297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029a:	e8 71 ff ff ff       	call   800210 <printnum>
  80029f:	eb 1b                	jmp    8002bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff d3                	call   *%ebx
  8002ad:	eb 03                	jmp    8002b2 <printnum+0xa2>
  8002af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8002b2:	83 ee 01             	sub    $0x1,%esi
  8002b5:	85 f6                	test   %esi,%esi
  8002b7:	7f e8                	jg     8002a1 <printnum+0x91>
  8002b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 7c 21 00 00       	call   802460 <__umoddi3>
  8002e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e8:	0f be 80 3b 26 80 00 	movsbl 0x80263b(%eax),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f5:	ff d0                	call   *%eax
}
  8002f7:	83 c4 3c             	add    $0x3c,%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800302:	83 fa 01             	cmp    $0x1,%edx
  800305:	7e 0e                	jle    800315 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	8b 52 04             	mov    0x4(%edx),%edx
  800313:	eb 22                	jmp    800337 <getuint+0x38>
	else if (lflag)
  800315:	85 d2                	test   %edx,%edx
  800317:	74 10                	je     800329 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	eb 0e                	jmp    800337 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032e:	89 08                	mov    %ecx,(%eax)
  800330:	8b 02                	mov    (%edx),%eax
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800343:	8b 10                	mov    (%eax),%edx
  800345:	3b 50 04             	cmp    0x4(%eax),%edx
  800348:	73 0a                	jae    800354 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 45 08             	mov    0x8(%ebp),%eax
  800352:	88 02                	mov    %al,(%edx)
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <printfmt>:
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80035c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800363:	8b 45 10             	mov    0x10(%ebp),%eax
  800366:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	e8 02 00 00 00       	call   80037e <vprintfmt>
}
  80037c:	c9                   	leave  
  80037d:	c3                   	ret    

0080037e <vprintfmt>:
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	57                   	push   %edi
  800382:	56                   	push   %esi
  800383:	53                   	push   %ebx
  800384:	83 ec 3c             	sub    $0x3c,%esp
  800387:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80038a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038d:	eb 1f                	jmp    8003ae <vprintfmt+0x30>
			if (ch == '\0'){
  80038f:	85 c0                	test   %eax,%eax
  800391:	75 0f                	jne    8003a2 <vprintfmt+0x24>
				color = 0x0100;
  800393:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80039a:	01 00 00 
  80039d:	e9 b3 03 00 00       	jmp    800755 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8003a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ac:	89 f3                	mov    %esi,%ebx
  8003ae:	8d 73 01             	lea    0x1(%ebx),%esi
  8003b1:	0f b6 03             	movzbl (%ebx),%eax
  8003b4:	83 f8 25             	cmp    $0x25,%eax
  8003b7:	75 d6                	jne    80038f <vprintfmt+0x11>
  8003b9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003bd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003c4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003cb:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	eb 1d                	jmp    8003f6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	89 de                	mov    %ebx,%esi
			padc = '-';
  8003db:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003df:	eb 15                	jmp    8003f6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	89 de                	mov    %ebx,%esi
			padc = '0';
  8003e3:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003e7:	eb 0d                	jmp    8003f6 <vprintfmt+0x78>
				width = precision, precision = -1;
  8003e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003ef:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003f9:	0f b6 0e             	movzbl (%esi),%ecx
  8003fc:	0f b6 c1             	movzbl %cl,%eax
  8003ff:	83 e9 23             	sub    $0x23,%ecx
  800402:	80 f9 55             	cmp    $0x55,%cl
  800405:	0f 87 2a 03 00 00    	ja     800735 <vprintfmt+0x3b7>
  80040b:	0f b6 c9             	movzbl %cl,%ecx
  80040e:	ff 24 8d 80 27 80 00 	jmp    *0x802780(,%ecx,4)
  800415:	89 de                	mov    %ebx,%esi
  800417:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80041c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80041f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800423:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800426:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800429:	83 fb 09             	cmp    $0x9,%ebx
  80042c:	77 36                	ja     800464 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80042e:	83 c6 01             	add    $0x1,%esi
			}
  800431:	eb e9                	jmp    80041c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 48 04             	lea    0x4(%eax),%ecx
  800439:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800441:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800443:	eb 22                	jmp    800467 <vprintfmt+0xe9>
  800445:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800448:	85 c9                	test   %ecx,%ecx
  80044a:	b8 00 00 00 00       	mov    $0x0,%eax
  80044f:	0f 49 c1             	cmovns %ecx,%eax
  800452:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800455:	89 de                	mov    %ebx,%esi
  800457:	eb 9d                	jmp    8003f6 <vprintfmt+0x78>
  800459:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80045b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800462:	eb 92                	jmp    8003f6 <vprintfmt+0x78>
  800464:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800467:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80046b:	79 89                	jns    8003f6 <vprintfmt+0x78>
  80046d:	e9 77 ff ff ff       	jmp    8003e9 <vprintfmt+0x6b>
			lflag++;
  800472:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800475:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800477:	e9 7a ff ff ff       	jmp    8003f6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	89 04 24             	mov    %eax,(%esp)
  80048e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800491:	e9 18 ff ff ff       	jmp    8003ae <vprintfmt+0x30>
			err = va_arg(ap, int);
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	99                   	cltd   
  8004a2:	31 d0                	xor    %edx,%eax
  8004a4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a6:	83 f8 0f             	cmp    $0xf,%eax
  8004a9:	7f 0b                	jg     8004b6 <vprintfmt+0x138>
  8004ab:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  8004b2:	85 d2                	test   %edx,%edx
  8004b4:	75 20                	jne    8004d6 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  8004b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ba:	c7 44 24 08 53 26 80 	movl   $0x802653,0x8(%esp)
  8004c1:	00 
  8004c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c9:	89 04 24             	mov    %eax,(%esp)
  8004cc:	e8 85 fe ff ff       	call   800356 <printfmt>
  8004d1:	e9 d8 fe ff ff       	jmp    8003ae <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  8004d6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004da:	c7 44 24 08 3a 2a 80 	movl   $0x802a3a,0x8(%esp)
  8004e1:	00 
  8004e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 65 fe ff ff       	call   800356 <printfmt>
  8004f1:	e9 b8 fe ff ff       	jmp    8003ae <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 50 04             	lea    0x4(%eax),%edx
  800505:	89 55 14             	mov    %edx,0x14(%ebp)
  800508:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80050a:	85 f6                	test   %esi,%esi
  80050c:	b8 4c 26 80 00       	mov    $0x80264c,%eax
  800511:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800514:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800518:	0f 84 97 00 00 00    	je     8005b5 <vprintfmt+0x237>
  80051e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800522:	0f 8e 9b 00 00 00    	jle    8005c3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800528:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80052c:	89 34 24             	mov    %esi,(%esp)
  80052f:	e8 c4 02 00 00       	call   8007f8 <strnlen>
  800534:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800537:	29 c2                	sub    %eax,%edx
  800539:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80053c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800540:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800543:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800546:	8b 75 08             	mov    0x8(%ebp),%esi
  800549:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80054c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80054e:	eb 0f                	jmp    80055f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800550:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800554:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80055c:	83 eb 01             	sub    $0x1,%ebx
  80055f:	85 db                	test   %ebx,%ebx
  800561:	7f ed                	jg     800550 <vprintfmt+0x1d2>
  800563:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800566:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800569:	85 d2                	test   %edx,%edx
  80056b:	b8 00 00 00 00       	mov    $0x0,%eax
  800570:	0f 49 c2             	cmovns %edx,%eax
  800573:	29 c2                	sub    %eax,%edx
  800575:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800578:	89 d7                	mov    %edx,%edi
  80057a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80057d:	eb 50                	jmp    8005cf <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80057f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800583:	74 1e                	je     8005a3 <vprintfmt+0x225>
  800585:	0f be d2             	movsbl %dl,%edx
  800588:	83 ea 20             	sub    $0x20,%edx
  80058b:	83 fa 5e             	cmp    $0x5e,%edx
  80058e:	76 13                	jbe    8005a3 <vprintfmt+0x225>
					putch('?', putdat);
  800590:	8b 45 0c             	mov    0xc(%ebp),%eax
  800593:	89 44 24 04          	mov    %eax,0x4(%esp)
  800597:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80059e:	ff 55 08             	call   *0x8(%ebp)
  8005a1:	eb 0d                	jmp    8005b0 <vprintfmt+0x232>
					putch(ch, putdat);
  8005a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005aa:	89 04 24             	mov    %eax,(%esp)
  8005ad:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b0:	83 ef 01             	sub    $0x1,%edi
  8005b3:	eb 1a                	jmp    8005cf <vprintfmt+0x251>
  8005b5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005b8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005bb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005c1:	eb 0c                	jmp    8005cf <vprintfmt+0x251>
  8005c3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005c6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005c9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005cf:	83 c6 01             	add    $0x1,%esi
  8005d2:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005d6:	0f be c2             	movsbl %dl,%eax
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	74 27                	je     800604 <vprintfmt+0x286>
  8005dd:	85 db                	test   %ebx,%ebx
  8005df:	78 9e                	js     80057f <vprintfmt+0x201>
  8005e1:	83 eb 01             	sub    $0x1,%ebx
  8005e4:	79 99                	jns    80057f <vprintfmt+0x201>
  8005e6:	89 f8                	mov    %edi,%eax
  8005e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ee:	89 c3                	mov    %eax,%ebx
  8005f0:	eb 1a                	jmp    80060c <vprintfmt+0x28e>
				putch(' ', putdat);
  8005f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005ff:	83 eb 01             	sub    $0x1,%ebx
  800602:	eb 08                	jmp    80060c <vprintfmt+0x28e>
  800604:	89 fb                	mov    %edi,%ebx
  800606:	8b 75 08             	mov    0x8(%ebp),%esi
  800609:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80060c:	85 db                	test   %ebx,%ebx
  80060e:	7f e2                	jg     8005f2 <vprintfmt+0x274>
  800610:	89 75 08             	mov    %esi,0x8(%ebp)
  800613:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800616:	e9 93 fd ff ff       	jmp    8003ae <vprintfmt+0x30>
	if (lflag >= 2)
  80061b:	83 fa 01             	cmp    $0x1,%edx
  80061e:	7e 16                	jle    800636 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 08             	lea    0x8(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 50 04             	mov    0x4(%eax),%edx
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800631:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800634:	eb 32                	jmp    800668 <vprintfmt+0x2ea>
	else if (lflag)
  800636:	85 d2                	test   %edx,%edx
  800638:	74 18                	je     800652 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 30                	mov    (%eax),%esi
  800645:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800648:	89 f0                	mov    %esi,%eax
  80064a:	c1 f8 1f             	sar    $0x1f,%eax
  80064d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800650:	eb 16                	jmp    800668 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 30                	mov    (%eax),%esi
  80065d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800660:	89 f0                	mov    %esi,%eax
  800662:	c1 f8 1f             	sar    $0x1f,%eax
  800665:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800668:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80066e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800673:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800677:	0f 89 80 00 00 00    	jns    8006fd <vprintfmt+0x37f>
				putch('-', putdat);
  80067d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800681:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800688:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80068b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800691:	f7 d8                	neg    %eax
  800693:	83 d2 00             	adc    $0x0,%edx
  800696:	f7 da                	neg    %edx
			base = 10;
  800698:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80069d:	eb 5e                	jmp    8006fd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 58 fc ff ff       	call   8002ff <getuint>
			base = 10;
  8006a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ac:	eb 4f                	jmp    8006fd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b1:	e8 49 fc ff ff       	call   8002ff <getuint>
            base = 8;
  8006b6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  8006bb:	eb 40                	jmp    8006fd <vprintfmt+0x37f>
			putch('0', putdat);
  8006bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d6:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 50 04             	lea    0x4(%eax),%edx
  8006df:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8006e9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ee:	eb 0d                	jmp    8006fd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f3:	e8 07 fc ff ff       	call   8002ff <getuint>
			base = 16;
  8006f8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006fd:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800701:	89 74 24 10          	mov    %esi,0x10(%esp)
  800705:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800708:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80070c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	89 54 24 04          	mov    %edx,0x4(%esp)
  800717:	89 fa                	mov    %edi,%edx
  800719:	8b 45 08             	mov    0x8(%ebp),%eax
  80071c:	e8 ef fa ff ff       	call   800210 <printnum>
			break;
  800721:	e9 88 fc ff ff       	jmp    8003ae <vprintfmt+0x30>
			putch(ch, putdat);
  800726:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072a:	89 04 24             	mov    %eax,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800730:	e9 79 fc ff ff       	jmp    8003ae <vprintfmt+0x30>
			putch('%', putdat);
  800735:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800739:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800743:	89 f3                	mov    %esi,%ebx
  800745:	eb 03                	jmp    80074a <vprintfmt+0x3cc>
  800747:	83 eb 01             	sub    $0x1,%ebx
  80074a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80074e:	75 f7                	jne    800747 <vprintfmt+0x3c9>
  800750:	e9 59 fc ff ff       	jmp    8003ae <vprintfmt+0x30>
}
  800755:	83 c4 3c             	add    $0x3c,%esp
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5f                   	pop    %edi
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 28             	sub    $0x28,%esp
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800769:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800770:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800773:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077a:	85 c0                	test   %eax,%eax
  80077c:	74 30                	je     8007ae <vsnprintf+0x51>
  80077e:	85 d2                	test   %edx,%edx
  800780:	7e 2c                	jle    8007ae <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800789:	8b 45 10             	mov    0x10(%ebp),%eax
  80078c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800790:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800793:	89 44 24 04          	mov    %eax,0x4(%esp)
  800797:	c7 04 24 39 03 80 00 	movl   $0x800339,(%esp)
  80079e:	e8 db fb ff ff       	call   80037e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ac:	eb 05                	jmp    8007b3 <vsnprintf+0x56>
		return -E_INVAL;
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	89 04 24             	mov    %eax,(%esp)
  8007d6:	e8 82 ff ff ff       	call   80075d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
  8007dd:	66 90                	xchg   %ax,%ax
  8007df:	90                   	nop

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 03                	jmp    8007f0 <strlen+0x10>
		n++;
  8007ed:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f4:	75 f7                	jne    8007ed <strlen+0xd>
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
  800806:	eb 03                	jmp    80080b <strnlen+0x13>
		n++;
  800808:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	39 d0                	cmp    %edx,%eax
  80080d:	74 06                	je     800815 <strnlen+0x1d>
  80080f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800813:	75 f3                	jne    800808 <strnlen+0x10>
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800821:	89 c2                	mov    %eax,%edx
  800823:	83 c2 01             	add    $0x1,%edx
  800826:	83 c1 01             	add    $0x1,%ecx
  800829:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800830:	84 db                	test   %bl,%bl
  800832:	75 ef                	jne    800823 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800841:	89 1c 24             	mov    %ebx,(%esp)
  800844:	e8 97 ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800850:	01 d8                	add    %ebx,%eax
  800852:	89 04 24             	mov    %eax,(%esp)
  800855:	e8 bd ff ff ff       	call   800817 <strcpy>
	return dst;
}
  80085a:	89 d8                	mov    %ebx,%eax
  80085c:	83 c4 08             	add    $0x8,%esp
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086d:	89 f3                	mov    %esi,%ebx
  80086f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800872:	89 f2                	mov    %esi,%edx
  800874:	eb 0f                	jmp    800885 <strncpy+0x23>
		*dst++ = *src;
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	0f b6 01             	movzbl (%ecx),%eax
  80087c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087f:	80 39 01             	cmpb   $0x1,(%ecx)
  800882:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800885:	39 da                	cmp    %ebx,%edx
  800887:	75 ed                	jne    800876 <strncpy+0x14>
	}
	return ret;
}
  800889:	89 f0                	mov    %esi,%eax
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	8b 75 08             	mov    0x8(%ebp),%esi
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a3:	85 c9                	test   %ecx,%ecx
  8008a5:	75 0b                	jne    8008b2 <strlcpy+0x23>
  8008a7:	eb 1d                	jmp    8008c6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	83 c2 01             	add    $0x1,%edx
  8008af:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008b2:	39 d8                	cmp    %ebx,%eax
  8008b4:	74 0b                	je     8008c1 <strlcpy+0x32>
  8008b6:	0f b6 0a             	movzbl (%edx),%ecx
  8008b9:	84 c9                	test   %cl,%cl
  8008bb:	75 ec                	jne    8008a9 <strlcpy+0x1a>
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 02                	jmp    8008c3 <strlcpy+0x34>
  8008c1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  8008c3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008c6:	29 f0                	sub    %esi,%eax
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d5:	eb 06                	jmp    8008dd <strcmp+0x11>
		p++, q++;
  8008d7:	83 c1 01             	add    $0x1,%ecx
  8008da:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008dd:	0f b6 01             	movzbl (%ecx),%eax
  8008e0:	84 c0                	test   %al,%al
  8008e2:	74 04                	je     8008e8 <strcmp+0x1c>
  8008e4:	3a 02                	cmp    (%edx),%al
  8008e6:	74 ef                	je     8008d7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 c0             	movzbl %al,%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 c3                	mov    %eax,%ebx
  8008fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800901:	eb 06                	jmp    800909 <strncmp+0x17>
		n--, p++, q++;
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800909:	39 d8                	cmp    %ebx,%eax
  80090b:	74 15                	je     800922 <strncmp+0x30>
  80090d:	0f b6 08             	movzbl (%eax),%ecx
  800910:	84 c9                	test   %cl,%cl
  800912:	74 04                	je     800918 <strncmp+0x26>
  800914:	3a 0a                	cmp    (%edx),%cl
  800916:	74 eb                	je     800903 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 00             	movzbl (%eax),%eax
  80091b:	0f b6 12             	movzbl (%edx),%edx
  80091e:	29 d0                	sub    %edx,%eax
  800920:	eb 05                	jmp    800927 <strncmp+0x35>
		return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800934:	eb 07                	jmp    80093d <strchr+0x13>
		if (*s == c)
  800936:	38 ca                	cmp    %cl,%dl
  800938:	74 0f                	je     800949 <strchr+0x1f>
	for (; *s; s++)
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f2                	jne    800936 <strchr+0xc>
			return (char *) s;
	return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	eb 07                	jmp    80095e <strfind+0x13>
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 0a                	je     800965 <strfind+0x1a>
	for (; *s; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	0f b6 10             	movzbl (%eax),%edx
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f2                	jne    800957 <strfind+0xc>
			break;
	return (char *) s;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800973:	85 c9                	test   %ecx,%ecx
  800975:	74 36                	je     8009ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800977:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097d:	75 28                	jne    8009a7 <memset+0x40>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 23                	jne    8009a7 <memset+0x40>
		c &= 0xFF;
  800984:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800988:	89 d3                	mov    %edx,%ebx
  80098a:	c1 e3 08             	shl    $0x8,%ebx
  80098d:	89 d6                	mov    %edx,%esi
  80098f:	c1 e6 18             	shl    $0x18,%esi
  800992:	89 d0                	mov    %edx,%eax
  800994:	c1 e0 10             	shl    $0x10,%eax
  800997:	09 f0                	or     %esi,%eax
  800999:	09 c2                	or     %eax,%edx
  80099b:	89 d0                	mov    %edx,%eax
  80099d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009a2:	fc                   	cld    
  8009a3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a5:	eb 06                	jmp    8009ad <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	fc                   	cld    
  8009ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c2:	39 c6                	cmp    %eax,%esi
  8009c4:	73 35                	jae    8009fb <memmove+0x47>
  8009c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c9:	39 d0                	cmp    %edx,%eax
  8009cb:	73 2e                	jae    8009fb <memmove+0x47>
		s += n;
		d += n;
  8009cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009d0:	89 d6                	mov    %edx,%esi
  8009d2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009da:	75 13                	jne    8009ef <memmove+0x3b>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0e                	jne    8009ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e1:	83 ef 04             	sub    $0x4,%edi
  8009e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ea:	fd                   	std    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 09                	jmp    8009f8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ef:	83 ef 01             	sub    $0x1,%edi
  8009f2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f5:	fd                   	std    
  8009f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f8:	fc                   	cld    
  8009f9:	eb 1d                	jmp    800a18 <memmove+0x64>
  8009fb:	89 f2                	mov    %esi,%edx
  8009fd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ff:	f6 c2 03             	test   $0x3,%dl
  800a02:	75 0f                	jne    800a13 <memmove+0x5f>
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 0a                	jne    800a13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a0c:	89 c7                	mov    %eax,%edi
  800a0e:	fc                   	cld    
  800a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a11:	eb 05                	jmp    800a18 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a22:	8b 45 10             	mov    0x10(%ebp),%eax
  800a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 79 ff ff ff       	call   8009b4 <memmove>
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a48:	89 d6                	mov    %edx,%esi
  800a4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4d:	eb 1a                	jmp    800a69 <memcmp+0x2c>
		if (*s1 != *s2)
  800a4f:	0f b6 02             	movzbl (%edx),%eax
  800a52:	0f b6 19             	movzbl (%ecx),%ebx
  800a55:	38 d8                	cmp    %bl,%al
  800a57:	74 0a                	je     800a63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a59:	0f b6 c0             	movzbl %al,%eax
  800a5c:	0f b6 db             	movzbl %bl,%ebx
  800a5f:	29 d8                	sub    %ebx,%eax
  800a61:	eb 0f                	jmp    800a72 <memcmp+0x35>
		s1++, s2++;
  800a63:	83 c2 01             	add    $0x1,%edx
  800a66:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800a69:	39 f2                	cmp    %esi,%edx
  800a6b:	75 e2                	jne    800a4f <memcmp+0x12>
	}

	return 0;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a7f:	89 c2                	mov    %eax,%edx
  800a81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a84:	eb 07                	jmp    800a8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a86:	38 08                	cmp    %cl,(%eax)
  800a88:	74 07                	je     800a91 <memfind+0x1b>
	for (; s < ends; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	39 d0                	cmp    %edx,%eax
  800a8f:	72 f5                	jb     800a86 <memfind+0x10>
			break;
	return (void *) s;
}
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9f:	eb 03                	jmp    800aa4 <strtol+0x11>
		s++;
  800aa1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800aa4:	0f b6 0a             	movzbl (%edx),%ecx
  800aa7:	80 f9 09             	cmp    $0x9,%cl
  800aaa:	74 f5                	je     800aa1 <strtol+0xe>
  800aac:	80 f9 20             	cmp    $0x20,%cl
  800aaf:	74 f0                	je     800aa1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ab1:	80 f9 2b             	cmp    $0x2b,%cl
  800ab4:	75 0a                	jne    800ac0 <strtol+0x2d>
		s++;
  800ab6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ab9:	bf 00 00 00 00       	mov    $0x0,%edi
  800abe:	eb 11                	jmp    800ad1 <strtol+0x3e>
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800ac5:	80 f9 2d             	cmp    $0x2d,%cl
  800ac8:	75 07                	jne    800ad1 <strtol+0x3e>
		s++, neg = 1;
  800aca:	8d 52 01             	lea    0x1(%edx),%edx
  800acd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ad6:	75 15                	jne    800aed <strtol+0x5a>
  800ad8:	80 3a 30             	cmpb   $0x30,(%edx)
  800adb:	75 10                	jne    800aed <strtol+0x5a>
  800add:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae1:	75 0a                	jne    800aed <strtol+0x5a>
		s += 2, base = 16;
  800ae3:	83 c2 02             	add    $0x2,%edx
  800ae6:	b8 10 00 00 00       	mov    $0x10,%eax
  800aeb:	eb 10                	jmp    800afd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800aed:	85 c0                	test   %eax,%eax
  800aef:	75 0c                	jne    800afd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800af3:	80 3a 30             	cmpb   $0x30,(%edx)
  800af6:	75 05                	jne    800afd <strtol+0x6a>
		s++, base = 8;
  800af8:	83 c2 01             	add    $0x1,%edx
  800afb:	b0 08                	mov    $0x8,%al
		base = 10;
  800afd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b02:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b05:	0f b6 0a             	movzbl (%edx),%ecx
  800b08:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b0b:	89 f0                	mov    %esi,%eax
  800b0d:	3c 09                	cmp    $0x9,%al
  800b0f:	77 08                	ja     800b19 <strtol+0x86>
			dig = *s - '0';
  800b11:	0f be c9             	movsbl %cl,%ecx
  800b14:	83 e9 30             	sub    $0x30,%ecx
  800b17:	eb 20                	jmp    800b39 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b19:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b1c:	89 f0                	mov    %esi,%eax
  800b1e:	3c 19                	cmp    $0x19,%al
  800b20:	77 08                	ja     800b2a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b22:	0f be c9             	movsbl %cl,%ecx
  800b25:	83 e9 57             	sub    $0x57,%ecx
  800b28:	eb 0f                	jmp    800b39 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b2a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b2d:	89 f0                	mov    %esi,%eax
  800b2f:	3c 19                	cmp    $0x19,%al
  800b31:	77 16                	ja     800b49 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b33:	0f be c9             	movsbl %cl,%ecx
  800b36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b39:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b3c:	7d 0f                	jge    800b4d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b3e:	83 c2 01             	add    $0x1,%edx
  800b41:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b45:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b47:	eb bc                	jmp    800b05 <strtol+0x72>
  800b49:	89 d8                	mov    %ebx,%eax
  800b4b:	eb 02                	jmp    800b4f <strtol+0xbc>
  800b4d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b53:	74 05                	je     800b5a <strtol+0xc7>
		*endptr = (char *) s;
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b5a:	f7 d8                	neg    %eax
  800b5c:	85 ff                	test   %edi,%edi
  800b5e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 c3                	mov    %eax,%ebx
  800b79:	89 c7                	mov    %eax,%edi
  800b7b:	89 c6                	mov    %eax,%esi
  800b7d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 cb                	mov    %ecx,%ebx
  800bbb:	89 cf                	mov    %ecx,%edi
  800bbd:	89 ce                	mov    %ecx,%esi
  800bbf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 28                	jle    800bed <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800bd8:	00 
  800bd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be0:	00 
  800be1:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800be8:	e8 07 f5 ff ff       	call   8000f4 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bed:	83 c4 2c             	add    $0x2c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 02 00 00 00       	mov    $0x2,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_yield>:

void
sys_yield(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c24:	89 d1                	mov    %edx,%ecx
  800c26:	89 d3                	mov    %edx,%ebx
  800c28:	89 d7                	mov    %edx,%edi
  800c2a:	89 d6                	mov    %edx,%esi
  800c2c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c3c:	be 00 00 00 00       	mov    $0x0,%esi
  800c41:	b8 04 00 00 00       	mov    $0x4,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	89 f7                	mov    %esi,%edi
  800c51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 28                	jle    800c7f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c62:	00 
  800c63:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c72:	00 
  800c73:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800c7a:	e8 75 f4 ff ff       	call   8000f4 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7f:	83 c4 2c             	add    $0x2c,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c90:	b8 05 00 00 00       	mov    $0x5,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 28                	jle    800cd2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cb5:	00 
  800cb6:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800cbd:	00 
  800cbe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc5:	00 
  800cc6:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800ccd:	e8 22 f4 ff ff       	call   8000f4 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd2:	83 c4 2c             	add    $0x2c,%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 28                	jle    800d25 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d01:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d08:	00 
  800d09:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800d10:	00 
  800d11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d18:	00 
  800d19:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800d20:	e8 cf f3 ff ff       	call   8000f4 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d25:	83 c4 2c             	add    $0x2c,%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 df                	mov    %ebx,%edi
  800d48:	89 de                	mov    %ebx,%esi
  800d4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 28                	jle    800d78 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d54:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d5b:	00 
  800d5c:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800d63:	00 
  800d64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6b:	00 
  800d6c:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800d73:	e8 7c f3 ff ff       	call   8000f4 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d78:	83 c4 2c             	add    $0x2c,%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	89 df                	mov    %ebx,%edi
  800d9b:	89 de                	mov    %ebx,%esi
  800d9d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	7e 28                	jle    800dcb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dae:	00 
  800daf:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800db6:	00 
  800db7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbe:	00 
  800dbf:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800dc6:	e8 29 f3 ff ff       	call   8000f4 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dcb:	83 c4 2c             	add    $0x2c,%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ddc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	89 df                	mov    %ebx,%edi
  800dee:	89 de                	mov    %ebx,%esi
  800df0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df2:	85 c0                	test   %eax,%eax
  800df4:	7e 28                	jle    800e1e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e01:	00 
  800e02:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800e09:	00 
  800e0a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e11:	00 
  800e12:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800e19:	e8 d6 f2 ff ff       	call   8000f4 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1e:	83 c4 2c             	add    $0x2c,%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2c:	be 00 00 00 00       	mov    $0x0,%esi
  800e31:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e42:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 cb                	mov    %ecx,%ebx
  800e61:	89 cf                	mov    %ecx,%edi
  800e63:	89 ce                	mov    %ecx,%esi
  800e65:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e67:	85 c0                	test   %eax,%eax
  800e69:	7e 28                	jle    800e93 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e76:	00 
  800e77:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e86:	00 
  800e87:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800e8e:	e8 61 f2 ff ff       	call   8000f4 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e93:	83 c4 2c             	add    $0x2c,%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    
  800e9b:	66 90                	xchg   %ax,%ax
  800e9d:	66 90                	xchg   %ax,%ax
  800e9f:	90                   	nop

00800ea0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea6:	05 00 00 00 30       	add    $0x30000000,%eax
  800eab:	c1 e8 0c             	shr    $0xc,%eax
}
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ebb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed2:	89 c2                	mov    %eax,%edx
  800ed4:	c1 ea 16             	shr    $0x16,%edx
  800ed7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ede:	f6 c2 01             	test   $0x1,%dl
  800ee1:	74 11                	je     800ef4 <fd_alloc+0x2d>
  800ee3:	89 c2                	mov    %eax,%edx
  800ee5:	c1 ea 0c             	shr    $0xc,%edx
  800ee8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eef:	f6 c2 01             	test   $0x1,%dl
  800ef2:	75 09                	jne    800efd <fd_alloc+0x36>
			*fd_store = fd;
  800ef4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  800efb:	eb 17                	jmp    800f14 <fd_alloc+0x4d>
  800efd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f02:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f07:	75 c9                	jne    800ed2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800f09:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f0f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f1c:	83 f8 1f             	cmp    $0x1f,%eax
  800f1f:	77 36                	ja     800f57 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f21:	c1 e0 0c             	shl    $0xc,%eax
  800f24:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f29:	89 c2                	mov    %eax,%edx
  800f2b:	c1 ea 16             	shr    $0x16,%edx
  800f2e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f35:	f6 c2 01             	test   $0x1,%dl
  800f38:	74 24                	je     800f5e <fd_lookup+0x48>
  800f3a:	89 c2                	mov    %eax,%edx
  800f3c:	c1 ea 0c             	shr    $0xc,%edx
  800f3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f46:	f6 c2 01             	test   $0x1,%dl
  800f49:	74 1a                	je     800f65 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4e:	89 02                	mov    %eax,(%edx)
	return 0;
  800f50:	b8 00 00 00 00       	mov    $0x0,%eax
  800f55:	eb 13                	jmp    800f6a <fd_lookup+0x54>
		return -E_INVAL;
  800f57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5c:	eb 0c                	jmp    800f6a <fd_lookup+0x54>
		return -E_INVAL;
  800f5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f63:	eb 05                	jmp    800f6a <fd_lookup+0x54>
  800f65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 18             	sub    $0x18,%esp
  800f72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f75:	ba e8 29 80 00       	mov    $0x8029e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f7a:	eb 13                	jmp    800f8f <dev_lookup+0x23>
  800f7c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f7f:	39 08                	cmp    %ecx,(%eax)
  800f81:	75 0c                	jne    800f8f <dev_lookup+0x23>
			*dev = devtab[i];
  800f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f86:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8d:	eb 30                	jmp    800fbf <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800f8f:	8b 02                	mov    (%edx),%eax
  800f91:	85 c0                	test   %eax,%eax
  800f93:	75 e7                	jne    800f7c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f95:	a1 08 40 80 00       	mov    0x804008,%eax
  800f9a:	8b 40 48             	mov    0x48(%eax),%eax
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa5:	c7 04 24 6c 29 80 00 	movl   $0x80296c,(%esp)
  800fac:	e8 3c f2 ff ff       	call   8001ed <cprintf>
	*dev = 0;
  800fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <fd_close>:
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
  800fc6:	83 ec 20             	sub    $0x20,%esp
  800fc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fd6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fdf:	89 04 24             	mov    %eax,(%esp)
  800fe2:	e8 2f ff ff ff       	call   800f16 <fd_lookup>
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 05                	js     800ff0 <fd_close+0x2f>
	    || fd != fd2)
  800feb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fee:	74 0c                	je     800ffc <fd_close+0x3b>
		return (must_exist ? r : 0);
  800ff0:	84 db                	test   %bl,%bl
  800ff2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff7:	0f 44 c2             	cmove  %edx,%eax
  800ffa:	eb 3f                	jmp    80103b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ffc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801003:	8b 06                	mov    (%esi),%eax
  801005:	89 04 24             	mov    %eax,(%esp)
  801008:	e8 5f ff ff ff       	call   800f6c <dev_lookup>
  80100d:	89 c3                	mov    %eax,%ebx
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 16                	js     801029 <fd_close+0x68>
		if (dev->dev_close)
  801013:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801016:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80101e:	85 c0                	test   %eax,%eax
  801020:	74 07                	je     801029 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801022:	89 34 24             	mov    %esi,(%esp)
  801025:	ff d0                	call   *%eax
  801027:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801029:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801034:	e8 a1 fc ff ff       	call   800cda <sys_page_unmap>
	return r;
  801039:	89 d8                	mov    %ebx,%eax
}
  80103b:	83 c4 20             	add    $0x20,%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <close>:

int
close(int fdnum)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	89 04 24             	mov    %eax,(%esp)
  801055:	e8 bc fe ff ff       	call   800f16 <fd_lookup>
  80105a:	89 c2                	mov    %eax,%edx
  80105c:	85 d2                	test   %edx,%edx
  80105e:	78 13                	js     801073 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801060:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801067:	00 
  801068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106b:	89 04 24             	mov    %eax,(%esp)
  80106e:	e8 4e ff ff ff       	call   800fc1 <fd_close>
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <close_all>:

void
close_all(void)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	53                   	push   %ebx
  801079:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80107c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801081:	89 1c 24             	mov    %ebx,(%esp)
  801084:	e8 b9 ff ff ff       	call   801042 <close>
	for (i = 0; i < MAXFD; i++)
  801089:	83 c3 01             	add    $0x1,%ebx
  80108c:	83 fb 20             	cmp    $0x20,%ebx
  80108f:	75 f0                	jne    801081 <close_all+0xc>
}
  801091:	83 c4 14             	add    $0x14,%esp
  801094:	5b                   	pop    %ebx
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	57                   	push   %edi
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010aa:	89 04 24             	mov    %eax,(%esp)
  8010ad:	e8 64 fe ff ff       	call   800f16 <fd_lookup>
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	85 d2                	test   %edx,%edx
  8010b6:	0f 88 e1 00 00 00    	js     80119d <dup+0x106>
		return r;
	close(newfdnum);
  8010bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bf:	89 04 24             	mov    %eax,(%esp)
  8010c2:	e8 7b ff ff ff       	call   801042 <close>

	newfd = INDEX2FD(newfdnum);
  8010c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010ca:	c1 e3 0c             	shl    $0xc,%ebx
  8010cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d6:	89 04 24             	mov    %eax,(%esp)
  8010d9:	e8 d2 fd ff ff       	call   800eb0 <fd2data>
  8010de:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8010e0:	89 1c 24             	mov    %ebx,(%esp)
  8010e3:	e8 c8 fd ff ff       	call   800eb0 <fd2data>
  8010e8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ea:	89 f0                	mov    %esi,%eax
  8010ec:	c1 e8 16             	shr    $0x16,%eax
  8010ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f6:	a8 01                	test   $0x1,%al
  8010f8:	74 43                	je     80113d <dup+0xa6>
  8010fa:	89 f0                	mov    %esi,%eax
  8010fc:	c1 e8 0c             	shr    $0xc,%eax
  8010ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801106:	f6 c2 01             	test   $0x1,%dl
  801109:	74 32                	je     80113d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80110b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801112:	25 07 0e 00 00       	and    $0xe07,%eax
  801117:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80111f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801126:	00 
  801127:	89 74 24 04          	mov    %esi,0x4(%esp)
  80112b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801132:	e8 50 fb ff ff       	call   800c87 <sys_page_map>
  801137:	89 c6                	mov    %eax,%esi
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 3e                	js     80117b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801140:	89 c2                	mov    %eax,%edx
  801142:	c1 ea 0c             	shr    $0xc,%edx
  801145:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801152:	89 54 24 10          	mov    %edx,0x10(%esp)
  801156:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80115a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801161:	00 
  801162:	89 44 24 04          	mov    %eax,0x4(%esp)
  801166:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116d:	e8 15 fb ff ff       	call   800c87 <sys_page_map>
  801172:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801174:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801177:	85 f6                	test   %esi,%esi
  801179:	79 22                	jns    80119d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80117b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80117f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801186:	e8 4f fb ff ff       	call   800cda <sys_page_unmap>
	sys_page_unmap(0, nva);
  80118b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80118f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801196:	e8 3f fb ff ff       	call   800cda <sys_page_unmap>
	return r;
  80119b:	89 f0                	mov    %esi,%eax
}
  80119d:	83 c4 3c             	add    $0x3c,%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 24             	sub    $0x24,%esp
  8011ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b6:	89 1c 24             	mov    %ebx,(%esp)
  8011b9:	e8 58 fd ff ff       	call   800f16 <fd_lookup>
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	85 d2                	test   %edx,%edx
  8011c2:	78 6d                	js     801231 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ce:	8b 00                	mov    (%eax),%eax
  8011d0:	89 04 24             	mov    %eax,(%esp)
  8011d3:	e8 94 fd ff ff       	call   800f6c <dev_lookup>
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 55                	js     801231 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011df:	8b 50 08             	mov    0x8(%eax),%edx
  8011e2:	83 e2 03             	and    $0x3,%edx
  8011e5:	83 fa 01             	cmp    $0x1,%edx
  8011e8:	75 23                	jne    80120d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ea:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ef:	8b 40 48             	mov    0x48(%eax),%eax
  8011f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fa:	c7 04 24 ad 29 80 00 	movl   $0x8029ad,(%esp)
  801201:	e8 e7 ef ff ff       	call   8001ed <cprintf>
		return -E_INVAL;
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120b:	eb 24                	jmp    801231 <read+0x8c>
	}
	if (!dev->dev_read)
  80120d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801210:	8b 52 08             	mov    0x8(%edx),%edx
  801213:	85 d2                	test   %edx,%edx
  801215:	74 15                	je     80122c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801217:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80121a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80121e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801221:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801225:	89 04 24             	mov    %eax,(%esp)
  801228:	ff d2                	call   *%edx
  80122a:	eb 05                	jmp    801231 <read+0x8c>
		return -E_NOT_SUPP;
  80122c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801231:	83 c4 24             	add    $0x24,%esp
  801234:	5b                   	pop    %ebx
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 1c             	sub    $0x1c,%esp
  801240:	8b 7d 08             	mov    0x8(%ebp),%edi
  801243:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124b:	eb 23                	jmp    801270 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124d:	89 f0                	mov    %esi,%eax
  80124f:	29 d8                	sub    %ebx,%eax
  801251:	89 44 24 08          	mov    %eax,0x8(%esp)
  801255:	89 d8                	mov    %ebx,%eax
  801257:	03 45 0c             	add    0xc(%ebp),%eax
  80125a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125e:	89 3c 24             	mov    %edi,(%esp)
  801261:	e8 3f ff ff ff       	call   8011a5 <read>
		if (m < 0)
  801266:	85 c0                	test   %eax,%eax
  801268:	78 10                	js     80127a <readn+0x43>
			return m;
		if (m == 0)
  80126a:	85 c0                	test   %eax,%eax
  80126c:	74 0a                	je     801278 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80126e:	01 c3                	add    %eax,%ebx
  801270:	39 f3                	cmp    %esi,%ebx
  801272:	72 d9                	jb     80124d <readn+0x16>
  801274:	89 d8                	mov    %ebx,%eax
  801276:	eb 02                	jmp    80127a <readn+0x43>
  801278:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80127a:	83 c4 1c             	add    $0x1c,%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	53                   	push   %ebx
  801286:	83 ec 24             	sub    $0x24,%esp
  801289:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801293:	89 1c 24             	mov    %ebx,(%esp)
  801296:	e8 7b fc ff ff       	call   800f16 <fd_lookup>
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	85 d2                	test   %edx,%edx
  80129f:	78 68                	js     801309 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	8b 00                	mov    (%eax),%eax
  8012ad:	89 04 24             	mov    %eax,(%esp)
  8012b0:	e8 b7 fc ff ff       	call   800f6c <dev_lookup>
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 50                	js     801309 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c0:	75 23                	jne    8012e5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012c2:	a1 08 40 80 00       	mov    0x804008,%eax
  8012c7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d2:	c7 04 24 c9 29 80 00 	movl   $0x8029c9,(%esp)
  8012d9:	e8 0f ef ff ff       	call   8001ed <cprintf>
		return -E_INVAL;
  8012de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e3:	eb 24                	jmp    801309 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8012eb:	85 d2                	test   %edx,%edx
  8012ed:	74 15                	je     801304 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012fd:	89 04 24             	mov    %eax,(%esp)
  801300:	ff d2                	call   *%edx
  801302:	eb 05                	jmp    801309 <write+0x87>
		return -E_NOT_SUPP;
  801304:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801309:	83 c4 24             	add    $0x24,%esp
  80130c:	5b                   	pop    %ebx
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <seek>:

int
seek(int fdnum, off_t offset)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801315:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131c:	8b 45 08             	mov    0x8(%ebp),%eax
  80131f:	89 04 24             	mov    %eax,(%esp)
  801322:	e8 ef fb ff ff       	call   800f16 <fd_lookup>
  801327:	85 c0                	test   %eax,%eax
  801329:	78 0e                	js     801339 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80132b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80132e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801331:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801334:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	53                   	push   %ebx
  80133f:	83 ec 24             	sub    $0x24,%esp
  801342:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801345:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801348:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134c:	89 1c 24             	mov    %ebx,(%esp)
  80134f:	e8 c2 fb ff ff       	call   800f16 <fd_lookup>
  801354:	89 c2                	mov    %eax,%edx
  801356:	85 d2                	test   %edx,%edx
  801358:	78 61                	js     8013bb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801361:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801364:	8b 00                	mov    (%eax),%eax
  801366:	89 04 24             	mov    %eax,(%esp)
  801369:	e8 fe fb ff ff       	call   800f6c <dev_lookup>
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 49                	js     8013bb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801372:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801375:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801379:	75 23                	jne    80139e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80137b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801380:	8b 40 48             	mov    0x48(%eax),%eax
  801383:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138b:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  801392:	e8 56 ee ff ff       	call   8001ed <cprintf>
		return -E_INVAL;
  801397:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139c:	eb 1d                	jmp    8013bb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80139e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a1:	8b 52 18             	mov    0x18(%edx),%edx
  8013a4:	85 d2                	test   %edx,%edx
  8013a6:	74 0e                	je     8013b6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013af:	89 04 24             	mov    %eax,(%esp)
  8013b2:	ff d2                	call   *%edx
  8013b4:	eb 05                	jmp    8013bb <ftruncate+0x80>
		return -E_NOT_SUPP;
  8013b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013bb:	83 c4 24             	add    $0x24,%esp
  8013be:	5b                   	pop    %ebx
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    

008013c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 24             	sub    $0x24,%esp
  8013c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d5:	89 04 24             	mov    %eax,(%esp)
  8013d8:	e8 39 fb ff ff       	call   800f16 <fd_lookup>
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	85 d2                	test   %edx,%edx
  8013e1:	78 52                	js     801435 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ed:	8b 00                	mov    (%eax),%eax
  8013ef:	89 04 24             	mov    %eax,(%esp)
  8013f2:	e8 75 fb ff ff       	call   800f6c <dev_lookup>
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 3a                	js     801435 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8013fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801402:	74 2c                	je     801430 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801404:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801407:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80140e:	00 00 00 
	stat->st_isdir = 0;
  801411:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801418:	00 00 00 
	stat->st_dev = dev;
  80141b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801421:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801425:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801428:	89 14 24             	mov    %edx,(%esp)
  80142b:	ff 50 14             	call   *0x14(%eax)
  80142e:	eb 05                	jmp    801435 <fstat+0x74>
		return -E_NOT_SUPP;
  801430:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801435:	83 c4 24             	add    $0x24,%esp
  801438:	5b                   	pop    %ebx
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	56                   	push   %esi
  80143f:	53                   	push   %ebx
  801440:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801443:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80144a:	00 
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	89 04 24             	mov    %eax,(%esp)
  801451:	e8 fb 01 00 00       	call   801651 <open>
  801456:	89 c3                	mov    %eax,%ebx
  801458:	85 db                	test   %ebx,%ebx
  80145a:	78 1b                	js     801477 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80145c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801463:	89 1c 24             	mov    %ebx,(%esp)
  801466:	e8 56 ff ff ff       	call   8013c1 <fstat>
  80146b:	89 c6                	mov    %eax,%esi
	close(fd);
  80146d:	89 1c 24             	mov    %ebx,(%esp)
  801470:	e8 cd fb ff ff       	call   801042 <close>
	return r;
  801475:	89 f0                	mov    %esi,%eax
}
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	5b                   	pop    %ebx
  80147b:	5e                   	pop    %esi
  80147c:	5d                   	pop    %ebp
  80147d:	c3                   	ret    

0080147e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
  801483:	83 ec 10             	sub    $0x10,%esp
  801486:	89 c6                	mov    %eax,%esi
  801488:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80148a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801491:	75 11                	jne    8014a4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801493:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80149a:	e8 10 0e 00 00       	call   8022af <ipc_find_env>
  80149f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014a4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014ab:	00 
  8014ac:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8014b3:	00 
  8014b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8014bd:	89 04 24             	mov    %eax,(%esp)
  8014c0:	e8 83 0d 00 00       	call   802248 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014cc:	00 
  8014cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d8:	e8 03 0d 00 00       	call   8021e0 <ipc_recv>
}
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	5b                   	pop    %ebx
  8014e1:	5e                   	pop    %esi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801502:	b8 02 00 00 00       	mov    $0x2,%eax
  801507:	e8 72 ff ff ff       	call   80147e <fsipc>
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <devfile_flush>:
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801514:	8b 45 08             	mov    0x8(%ebp),%eax
  801517:	8b 40 0c             	mov    0xc(%eax),%eax
  80151a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80151f:	ba 00 00 00 00       	mov    $0x0,%edx
  801524:	b8 06 00 00 00       	mov    $0x6,%eax
  801529:	e8 50 ff ff ff       	call   80147e <fsipc>
}
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <devfile_stat>:
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 14             	sub    $0x14,%esp
  801537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	8b 40 0c             	mov    0xc(%eax),%eax
  801540:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801545:	ba 00 00 00 00       	mov    $0x0,%edx
  80154a:	b8 05 00 00 00       	mov    $0x5,%eax
  80154f:	e8 2a ff ff ff       	call   80147e <fsipc>
  801554:	89 c2                	mov    %eax,%edx
  801556:	85 d2                	test   %edx,%edx
  801558:	78 2b                	js     801585 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80155a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801561:	00 
  801562:	89 1c 24             	mov    %ebx,(%esp)
  801565:	e8 ad f2 ff ff       	call   800817 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80156a:	a1 80 50 80 00       	mov    0x805080,%eax
  80156f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801575:	a1 84 50 80 00       	mov    0x805084,%eax
  80157a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801580:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801585:	83 c4 14             	add    $0x14,%esp
  801588:	5b                   	pop    %ebx
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <devfile_write>:
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801591:	c7 44 24 08 f8 29 80 	movl   $0x8029f8,0x8(%esp)
  801598:	00 
  801599:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8015a0:	00 
  8015a1:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  8015a8:	e8 47 eb ff ff       	call   8000f4 <_panic>

008015ad <devfile_read>:
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 10             	sub    $0x10,%esp
  8015b5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015c3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d3:	e8 a6 fe ff ff       	call   80147e <fsipc>
  8015d8:	89 c3                	mov    %eax,%ebx
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 6a                	js     801648 <devfile_read+0x9b>
	assert(r <= n);
  8015de:	39 c6                	cmp    %eax,%esi
  8015e0:	73 24                	jae    801606 <devfile_read+0x59>
  8015e2:	c7 44 24 0c 21 2a 80 	movl   $0x802a21,0xc(%esp)
  8015e9:	00 
  8015ea:	c7 44 24 08 28 2a 80 	movl   $0x802a28,0x8(%esp)
  8015f1:	00 
  8015f2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015f9:	00 
  8015fa:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  801601:	e8 ee ea ff ff       	call   8000f4 <_panic>
	assert(r <= PGSIZE);
  801606:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80160b:	7e 24                	jle    801631 <devfile_read+0x84>
  80160d:	c7 44 24 0c 3d 2a 80 	movl   $0x802a3d,0xc(%esp)
  801614:	00 
  801615:	c7 44 24 08 28 2a 80 	movl   $0x802a28,0x8(%esp)
  80161c:	00 
  80161d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801624:	00 
  801625:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  80162c:	e8 c3 ea ff ff       	call   8000f4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801631:	89 44 24 08          	mov    %eax,0x8(%esp)
  801635:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80163c:	00 
  80163d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801640:	89 04 24             	mov    %eax,(%esp)
  801643:	e8 6c f3 ff ff       	call   8009b4 <memmove>
}
  801648:	89 d8                	mov    %ebx,%eax
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <open>:
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	53                   	push   %ebx
  801655:	83 ec 24             	sub    $0x24,%esp
  801658:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80165b:	89 1c 24             	mov    %ebx,(%esp)
  80165e:	e8 7d f1 ff ff       	call   8007e0 <strlen>
  801663:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801668:	7f 60                	jg     8016ca <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80166a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	e8 52 f8 ff ff       	call   800ec7 <fd_alloc>
  801675:	89 c2                	mov    %eax,%edx
  801677:	85 d2                	test   %edx,%edx
  801679:	78 54                	js     8016cf <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80167b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80167f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801686:	e8 8c f1 ff ff       	call   800817 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80168b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801693:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801696:	b8 01 00 00 00       	mov    $0x1,%eax
  80169b:	e8 de fd ff ff       	call   80147e <fsipc>
  8016a0:	89 c3                	mov    %eax,%ebx
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	79 17                	jns    8016bd <open+0x6c>
		fd_close(fd, 0);
  8016a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016ad:	00 
  8016ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b1:	89 04 24             	mov    %eax,(%esp)
  8016b4:	e8 08 f9 ff ff       	call   800fc1 <fd_close>
		return r;
  8016b9:	89 d8                	mov    %ebx,%eax
  8016bb:	eb 12                	jmp    8016cf <open+0x7e>
	return fd2num(fd);
  8016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c0:	89 04 24             	mov    %eax,(%esp)
  8016c3:	e8 d8 f7 ff ff       	call   800ea0 <fd2num>
  8016c8:	eb 05                	jmp    8016cf <open+0x7e>
		return -E_BAD_PATH;
  8016ca:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8016cf:	83 c4 24             	add    $0x24,%esp
  8016d2:	5b                   	pop    %ebx
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    

008016d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016db:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016e5:	e8 94 fd ff ff       	call   80147e <fsipc>
}
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    
  8016ec:	66 90                	xchg   %ax,%ax
  8016ee:	66 90                	xchg   %ax,%ax

008016f0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	57                   	push   %edi
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8016fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801703:	00 
  801704:	8b 45 08             	mov    0x8(%ebp),%eax
  801707:	89 04 24             	mov    %eax,(%esp)
  80170a:	e8 42 ff ff ff       	call   801651 <open>
  80170f:	89 c1                	mov    %eax,%ecx
  801711:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801717:	85 c0                	test   %eax,%eax
  801719:	0f 88 a8 04 00 00    	js     801bc7 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80171f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801726:	00 
  801727:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80172d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801731:	89 0c 24             	mov    %ecx,(%esp)
  801734:	e8 fe fa ff ff       	call   801237 <readn>
  801739:	3d 00 02 00 00       	cmp    $0x200,%eax
  80173e:	75 0c                	jne    80174c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801740:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801747:	45 4c 46 
  80174a:	74 36                	je     801782 <spawn+0x92>
		close(fd);
  80174c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	e8 e8 f8 ff ff       	call   801042 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80175a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801761:	46 
  801762:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176c:	c7 04 24 49 2a 80 00 	movl   $0x802a49,(%esp)
  801773:	e8 75 ea ff ff       	call   8001ed <cprintf>
		return -E_NOT_EXEC;
  801778:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80177d:	e9 a4 04 00 00       	jmp    801c26 <spawn+0x536>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801782:	b8 07 00 00 00       	mov    $0x7,%eax
  801787:	cd 30                	int    $0x30
  801789:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80178f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801795:	85 c0                	test   %eax,%eax
  801797:	0f 88 32 04 00 00    	js     801bcf <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80179d:	89 c6                	mov    %eax,%esi
  80179f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8017a5:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8017a8:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8017ae:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8017b4:	b9 11 00 00 00       	mov    $0x11,%ecx
  8017b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8017bb:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8017c1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8017c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8017cc:	be 00 00 00 00       	mov    $0x0,%esi
  8017d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8017d4:	eb 0f                	jmp    8017e5 <spawn+0xf5>
		string_size += strlen(argv[argc]) + 1;
  8017d6:	89 04 24             	mov    %eax,(%esp)
  8017d9:	e8 02 f0 ff ff       	call   8007e0 <strlen>
  8017de:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8017e2:	83 c3 01             	add    $0x1,%ebx
  8017e5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8017ec:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	75 e3                	jne    8017d6 <spawn+0xe6>
  8017f3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8017f9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8017ff:	bf 00 10 40 00       	mov    $0x401000,%edi
  801804:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801806:	89 fa                	mov    %edi,%edx
  801808:	83 e2 fc             	and    $0xfffffffc,%edx
  80180b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801812:	29 c2                	sub    %eax,%edx
  801814:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80181a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80181d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801822:	0f 86 b7 03 00 00    	jbe    801bdf <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801828:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80182f:	00 
  801830:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801837:	00 
  801838:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183f:	e8 ef f3 ff ff       	call   800c33 <sys_page_alloc>
  801844:	85 c0                	test   %eax,%eax
  801846:	0f 88 da 03 00 00    	js     801c26 <spawn+0x536>
  80184c:	be 00 00 00 00       	mov    $0x0,%esi
  801851:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801857:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80185a:	eb 30                	jmp    80188c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80185c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801862:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801868:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80186b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80186e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801872:	89 3c 24             	mov    %edi,(%esp)
  801875:	e8 9d ef ff ff       	call   800817 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80187a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80187d:	89 04 24             	mov    %eax,(%esp)
  801880:	e8 5b ef ff ff       	call   8007e0 <strlen>
  801885:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801889:	83 c6 01             	add    $0x1,%esi
  80188c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801892:	7f c8                	jg     80185c <spawn+0x16c>
	}
	argv_store[argc] = 0;
  801894:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80189a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8018a0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8018a7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8018ad:	74 24                	je     8018d3 <spawn+0x1e3>
  8018af:	c7 44 24 0c c0 2a 80 	movl   $0x802ac0,0xc(%esp)
  8018b6:	00 
  8018b7:	c7 44 24 08 28 2a 80 	movl   $0x802a28,0x8(%esp)
  8018be:	00 
  8018bf:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  8018c6:	00 
  8018c7:	c7 04 24 63 2a 80 00 	movl   $0x802a63,(%esp)
  8018ce:	e8 21 e8 ff ff       	call   8000f4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8018d3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8018d9:	89 c8                	mov    %ecx,%eax
  8018db:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8018e0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8018e3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8018e9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8018ec:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8018f2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8018f8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018ff:	00 
  801900:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801907:	ee 
  801908:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80190e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801912:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801919:	00 
  80191a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801921:	e8 61 f3 ff ff       	call   800c87 <sys_page_map>
  801926:	89 c3                	mov    %eax,%ebx
  801928:	85 c0                	test   %eax,%eax
  80192a:	0f 88 e0 02 00 00    	js     801c10 <spawn+0x520>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801930:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801937:	00 
  801938:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193f:	e8 96 f3 ff ff       	call   800cda <sys_page_unmap>
  801944:	89 c3                	mov    %eax,%ebx
  801946:	85 c0                	test   %eax,%eax
  801948:	0f 88 c2 02 00 00    	js     801c10 <spawn+0x520>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80194e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801954:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80195b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801961:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801968:	00 00 00 
  80196b:	e9 b6 01 00 00       	jmp    801b26 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801970:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801976:	83 38 01             	cmpl   $0x1,(%eax)
  801979:	0f 85 99 01 00 00    	jne    801b18 <spawn+0x428>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80197f:	89 c1                	mov    %eax,%ecx
  801981:	8b 40 18             	mov    0x18(%eax),%eax
  801984:	83 e0 02             	and    $0x2,%eax
		perm = PTE_P | PTE_U;
  801987:	83 f8 01             	cmp    $0x1,%eax
  80198a:	19 c0                	sbb    %eax,%eax
  80198c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801992:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801999:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8019a0:	89 c8                	mov    %ecx,%eax
  8019a2:	8b 51 04             	mov    0x4(%ecx),%edx
  8019a5:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  8019ab:	8b 49 10             	mov    0x10(%ecx),%ecx
  8019ae:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  8019b4:	8b 50 14             	mov    0x14(%eax),%edx
  8019b7:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8019bd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8019c0:	89 f0                	mov    %esi,%eax
  8019c2:	25 ff 0f 00 00       	and    $0xfff,%eax
  8019c7:	74 14                	je     8019dd <spawn+0x2ed>
		va -= i;
  8019c9:	29 c6                	sub    %eax,%esi
		memsz += i;
  8019cb:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8019d1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8019d7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e2:	e9 23 01 00 00       	jmp    801b0a <spawn+0x41a>
		if (i >= filesz) {
  8019e7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8019ed:	77 2b                	ja     801a1a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8019ef:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8019f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a03:	89 04 24             	mov    %eax,(%esp)
  801a06:	e8 28 f2 ff ff       	call   800c33 <sys_page_alloc>
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	0f 89 eb 00 00 00    	jns    801afe <spawn+0x40e>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	e9 d6 01 00 00       	jmp    801bf0 <spawn+0x500>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a1a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a21:	00 
  801a22:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a29:	00 
  801a2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a31:	e8 fd f1 ff ff       	call   800c33 <sys_page_alloc>
  801a36:	85 c0                	test   %eax,%eax
  801a38:	0f 88 a8 01 00 00    	js     801be6 <spawn+0x4f6>
  801a3e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a44:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a50:	89 04 24             	mov    %eax,(%esp)
  801a53:	e8 b7 f8 ff ff       	call   80130f <seek>
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	0f 88 8a 01 00 00    	js     801bea <spawn+0x4fa>
  801a60:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a66:	29 fa                	sub    %edi,%edx
  801a68:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a6a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801a70:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801a75:	0f 47 c1             	cmova  %ecx,%eax
  801a78:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a7c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a83:	00 
  801a84:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a8a:	89 04 24             	mov    %eax,(%esp)
  801a8d:	e8 a5 f7 ff ff       	call   801237 <readn>
  801a92:	85 c0                	test   %eax,%eax
  801a94:	0f 88 54 01 00 00    	js     801bee <spawn+0x4fe>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a9a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801aa0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801aa4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801aa8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801aae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ab9:	00 
  801aba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac1:	e8 c1 f1 ff ff       	call   800c87 <sys_page_map>
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	79 20                	jns    801aea <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801aca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ace:	c7 44 24 08 6f 2a 80 	movl   $0x802a6f,0x8(%esp)
  801ad5:	00 
  801ad6:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801add:	00 
  801ade:	c7 04 24 63 2a 80 00 	movl   $0x802a63,(%esp)
  801ae5:	e8 0a e6 ff ff       	call   8000f4 <_panic>
			sys_page_unmap(0, UTEMP);
  801aea:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801af1:	00 
  801af2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af9:	e8 dc f1 ff ff       	call   800cda <sys_page_unmap>
	for (i = 0; i < memsz; i += PGSIZE) {
  801afe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b04:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801b0a:	89 df                	mov    %ebx,%edi
  801b0c:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801b12:	0f 87 cf fe ff ff    	ja     8019e7 <spawn+0x2f7>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b18:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801b1f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801b26:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801b2d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801b33:	0f 8c 37 fe ff ff    	jl     801970 <spawn+0x280>
	close(fd);
  801b39:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b3f:	89 04 24             	mov    %eax,(%esp)
  801b42:	e8 fb f4 ff ff       	call   801042 <close>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b47:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b4e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b51:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b61:	89 04 24             	mov    %eax,(%esp)
  801b64:	e8 17 f2 ff ff       	call   800d80 <sys_env_set_trapframe>
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	79 20                	jns    801b8d <spawn+0x49d>
		panic("sys_env_set_trapframe: %e", r);
  801b6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b71:	c7 44 24 08 8c 2a 80 	movl   $0x802a8c,0x8(%esp)
  801b78:	00 
  801b79:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801b80:	00 
  801b81:	c7 04 24 63 2a 80 00 	movl   $0x802a63,(%esp)
  801b88:	e8 67 e5 ff ff       	call   8000f4 <_panic>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b8d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801b94:	00 
  801b95:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b9b:	89 04 24             	mov    %eax,(%esp)
  801b9e:	e8 8a f1 ff ff       	call   800d2d <sys_env_set_status>
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	79 30                	jns    801bd7 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801ba7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bab:	c7 44 24 08 a6 2a 80 	movl   $0x802aa6,0x8(%esp)
  801bb2:	00 
  801bb3:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801bba:	00 
  801bbb:	c7 04 24 63 2a 80 00 	movl   $0x802a63,(%esp)
  801bc2:	e8 2d e5 ff ff       	call   8000f4 <_panic>
		return r;
  801bc7:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bcd:	eb 57                	jmp    801c26 <spawn+0x536>
		return r;
  801bcf:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801bd5:	eb 4f                	jmp    801c26 <spawn+0x536>
	return child;
  801bd7:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801bdd:	eb 47                	jmp    801c26 <spawn+0x536>
		return -E_NO_MEM;
  801bdf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801be4:	eb 40                	jmp    801c26 <spawn+0x536>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	eb 06                	jmp    801bf0 <spawn+0x500>
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	eb 02                	jmp    801bf0 <spawn+0x500>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bee:	89 c3                	mov    %eax,%ebx
	sys_env_destroy(child);
  801bf0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801bf6:	89 04 24             	mov    %eax,(%esp)
  801bf9:	e8 a5 ef ff ff       	call   800ba3 <sys_env_destroy>
	close(fd);
  801bfe:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c04:	89 04 24             	mov    %eax,(%esp)
  801c07:	e8 36 f4 ff ff       	call   801042 <close>
	return r;
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	eb 16                	jmp    801c26 <spawn+0x536>
	sys_page_unmap(0, UTEMP);
  801c10:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c17:	00 
  801c18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1f:	e8 b6 f0 ff ff       	call   800cda <sys_page_unmap>
  801c24:	89 d8                	mov    %ebx,%eax
}
  801c26:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <spawnl>:
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	56                   	push   %esi
  801c35:	53                   	push   %ebx
  801c36:	83 ec 10             	sub    $0x10,%esp
	while(va_arg(vl, void *) != NULL)
  801c39:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  801c3c:	ba 00 00 00 00       	mov    $0x0,%edx
	while(va_arg(vl, void *) != NULL)
  801c41:	eb 03                	jmp    801c46 <spawnl+0x15>
		argc++;
  801c43:	83 c2 01             	add    $0x1,%edx
	while(va_arg(vl, void *) != NULL)
  801c46:	83 c0 04             	add    $0x4,%eax
  801c49:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801c4d:	75 f4                	jne    801c43 <spawnl+0x12>
	const char *argv[argc+2];
  801c4f:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  801c56:	83 e0 f0             	and    $0xfffffff0,%eax
  801c59:	29 c4                	sub    %eax,%esp
  801c5b:	8d 44 24 0b          	lea    0xb(%esp),%eax
  801c5f:	c1 e8 02             	shr    $0x2,%eax
  801c62:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801c69:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6e:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801c75:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  801c7c:	00 
	for(i=0;i<argc;i++)
  801c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c82:	eb 0a                	jmp    801c8e <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  801c84:	83 c0 01             	add    $0x1,%eax
  801c87:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c8b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	for(i=0;i<argc;i++)
  801c8e:	39 d0                	cmp    %edx,%eax
  801c90:	75 f2                	jne    801c84 <spawnl+0x53>
	return spawn(prog, argv);
  801c92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c96:	8b 45 08             	mov    0x8(%ebp),%eax
  801c99:	89 04 24             	mov    %eax,(%esp)
  801c9c:	e8 4f fa ff ff       	call   8016f0 <spawn>
}
  801ca1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	83 ec 10             	sub    $0x10,%esp
  801cb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	89 04 24             	mov    %eax,(%esp)
  801cb9:	e8 f2 f1 ff ff       	call   800eb0 <fd2data>
  801cbe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cc0:	c7 44 24 04 e8 2a 80 	movl   $0x802ae8,0x4(%esp)
  801cc7:	00 
  801cc8:	89 1c 24             	mov    %ebx,(%esp)
  801ccb:	e8 47 eb ff ff       	call   800817 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cd0:	8b 46 04             	mov    0x4(%esi),%eax
  801cd3:	2b 06                	sub    (%esi),%eax
  801cd5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cdb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ce2:	00 00 00 
	stat->st_dev = &devpipe;
  801ce5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801cec:	30 80 00 
	return 0;
}
  801cef:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	53                   	push   %ebx
  801cff:	83 ec 14             	sub    $0x14,%esp
  801d02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d10:	e8 c5 ef ff ff       	call   800cda <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d15:	89 1c 24             	mov    %ebx,(%esp)
  801d18:	e8 93 f1 ff ff       	call   800eb0 <fd2data>
  801d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d28:	e8 ad ef ff ff       	call   800cda <sys_page_unmap>
}
  801d2d:	83 c4 14             	add    $0x14,%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <_pipeisclosed>:
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	57                   	push   %edi
  801d37:	56                   	push   %esi
  801d38:	53                   	push   %ebx
  801d39:	83 ec 2c             	sub    $0x2c,%esp
  801d3c:	89 c6                	mov    %eax,%esi
  801d3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801d41:	a1 08 40 80 00       	mov    0x804008,%eax
  801d46:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d49:	89 34 24             	mov    %esi,(%esp)
  801d4c:	e8 96 05 00 00       	call   8022e7 <pageref>
  801d51:	89 c7                	mov    %eax,%edi
  801d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d56:	89 04 24             	mov    %eax,(%esp)
  801d59:	e8 89 05 00 00       	call   8022e7 <pageref>
  801d5e:	39 c7                	cmp    %eax,%edi
  801d60:	0f 94 c2             	sete   %dl
  801d63:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d66:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801d6c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d6f:	39 fb                	cmp    %edi,%ebx
  801d71:	74 21                	je     801d94 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801d73:	84 d2                	test   %dl,%dl
  801d75:	74 ca                	je     801d41 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d77:	8b 51 58             	mov    0x58(%ecx),%edx
  801d7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d7e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d86:	c7 04 24 ef 2a 80 00 	movl   $0x802aef,(%esp)
  801d8d:	e8 5b e4 ff ff       	call   8001ed <cprintf>
  801d92:	eb ad                	jmp    801d41 <_pipeisclosed+0xe>
}
  801d94:	83 c4 2c             	add    $0x2c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <devpipe_write>:
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	57                   	push   %edi
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	83 ec 1c             	sub    $0x1c,%esp
  801da5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801da8:	89 34 24             	mov    %esi,(%esp)
  801dab:	e8 00 f1 ff ff       	call   800eb0 <fd2data>
  801db0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801db2:	bf 00 00 00 00       	mov    $0x0,%edi
  801db7:	eb 45                	jmp    801dfe <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801db9:	89 da                	mov    %ebx,%edx
  801dbb:	89 f0                	mov    %esi,%eax
  801dbd:	e8 71 ff ff ff       	call   801d33 <_pipeisclosed>
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	75 41                	jne    801e07 <devpipe_write+0x6b>
			sys_yield();
  801dc6:	e8 49 ee ff ff       	call   800c14 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dcb:	8b 43 04             	mov    0x4(%ebx),%eax
  801dce:	8b 0b                	mov    (%ebx),%ecx
  801dd0:	8d 51 20             	lea    0x20(%ecx),%edx
  801dd3:	39 d0                	cmp    %edx,%eax
  801dd5:	73 e2                	jae    801db9 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dda:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dde:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801de1:	99                   	cltd   
  801de2:	c1 ea 1b             	shr    $0x1b,%edx
  801de5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801de8:	83 e1 1f             	and    $0x1f,%ecx
  801deb:	29 d1                	sub    %edx,%ecx
  801ded:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801df1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801df5:	83 c0 01             	add    $0x1,%eax
  801df8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801dfb:	83 c7 01             	add    $0x1,%edi
  801dfe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e01:	75 c8                	jne    801dcb <devpipe_write+0x2f>
	return i;
  801e03:	89 f8                	mov    %edi,%eax
  801e05:	eb 05                	jmp    801e0c <devpipe_write+0x70>
				return 0;
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e0c:	83 c4 1c             	add    $0x1c,%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5f                   	pop    %edi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <devpipe_read>:
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	57                   	push   %edi
  801e18:	56                   	push   %esi
  801e19:	53                   	push   %ebx
  801e1a:	83 ec 1c             	sub    $0x1c,%esp
  801e1d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e20:	89 3c 24             	mov    %edi,(%esp)
  801e23:	e8 88 f0 ff ff       	call   800eb0 <fd2data>
  801e28:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e2a:	be 00 00 00 00       	mov    $0x0,%esi
  801e2f:	eb 3d                	jmp    801e6e <devpipe_read+0x5a>
			if (i > 0)
  801e31:	85 f6                	test   %esi,%esi
  801e33:	74 04                	je     801e39 <devpipe_read+0x25>
				return i;
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	eb 43                	jmp    801e7c <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801e39:	89 da                	mov    %ebx,%edx
  801e3b:	89 f8                	mov    %edi,%eax
  801e3d:	e8 f1 fe ff ff       	call   801d33 <_pipeisclosed>
  801e42:	85 c0                	test   %eax,%eax
  801e44:	75 31                	jne    801e77 <devpipe_read+0x63>
			sys_yield();
  801e46:	e8 c9 ed ff ff       	call   800c14 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e4b:	8b 03                	mov    (%ebx),%eax
  801e4d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e50:	74 df                	je     801e31 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e52:	99                   	cltd   
  801e53:	c1 ea 1b             	shr    $0x1b,%edx
  801e56:	01 d0                	add    %edx,%eax
  801e58:	83 e0 1f             	and    $0x1f,%eax
  801e5b:	29 d0                	sub    %edx,%eax
  801e5d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e65:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e68:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e6b:	83 c6 01             	add    $0x1,%esi
  801e6e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e71:	75 d8                	jne    801e4b <devpipe_read+0x37>
	return i;
  801e73:	89 f0                	mov    %esi,%eax
  801e75:	eb 05                	jmp    801e7c <devpipe_read+0x68>
				return 0;
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e7c:	83 c4 1c             	add    $0x1c,%esp
  801e7f:	5b                   	pop    %ebx
  801e80:	5e                   	pop    %esi
  801e81:	5f                   	pop    %edi
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

00801e84 <pipe>:
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
  801e89:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8f:	89 04 24             	mov    %eax,(%esp)
  801e92:	e8 30 f0 ff ff       	call   800ec7 <fd_alloc>
  801e97:	89 c2                	mov    %eax,%edx
  801e99:	85 d2                	test   %edx,%edx
  801e9b:	0f 88 4d 01 00 00    	js     801fee <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ea8:	00 
  801ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb7:	e8 77 ed ff ff       	call   800c33 <sys_page_alloc>
  801ebc:	89 c2                	mov    %eax,%edx
  801ebe:	85 d2                	test   %edx,%edx
  801ec0:	0f 88 28 01 00 00    	js     801fee <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801ec6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec9:	89 04 24             	mov    %eax,(%esp)
  801ecc:	e8 f6 ef ff ff       	call   800ec7 <fd_alloc>
  801ed1:	89 c3                	mov    %eax,%ebx
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	0f 88 fe 00 00 00    	js     801fd9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ee2:	00 
  801ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef1:	e8 3d ed ff ff       	call   800c33 <sys_page_alloc>
  801ef6:	89 c3                	mov    %eax,%ebx
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	0f 88 d9 00 00 00    	js     801fd9 <pipe+0x155>
	va = fd2data(fd0);
  801f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f03:	89 04 24             	mov    %eax,(%esp)
  801f06:	e8 a5 ef ff ff       	call   800eb0 <fd2data>
  801f0b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f0d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f14:	00 
  801f15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f20:	e8 0e ed ff ff       	call   800c33 <sys_page_alloc>
  801f25:	89 c3                	mov    %eax,%ebx
  801f27:	85 c0                	test   %eax,%eax
  801f29:	0f 88 97 00 00 00    	js     801fc6 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f32:	89 04 24             	mov    %eax,(%esp)
  801f35:	e8 76 ef ff ff       	call   800eb0 <fd2data>
  801f3a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f41:	00 
  801f42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f4d:	00 
  801f4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f59:	e8 29 ed ff ff       	call   800c87 <sys_page_map>
  801f5e:	89 c3                	mov    %eax,%ebx
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 52                	js     801fb6 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801f64:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f72:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801f79:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f82:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f87:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 07 ef ff ff       	call   800ea0 <fd2num>
  801f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f9c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa1:	89 04 24             	mov    %eax,(%esp)
  801fa4:	e8 f7 ee ff ff       	call   800ea0 <fd2num>
  801fa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fac:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801faf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb4:	eb 38                	jmp    801fee <pipe+0x16a>
	sys_page_unmap(0, va);
  801fb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc1:	e8 14 ed ff ff       	call   800cda <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd4:	e8 01 ed ff ff       	call   800cda <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe7:	e8 ee ec ff ff       	call   800cda <sys_page_unmap>
  801fec:	89 d8                	mov    %ebx,%eax
}
  801fee:	83 c4 30             	add    $0x30,%esp
  801ff1:	5b                   	pop    %ebx
  801ff2:	5e                   	pop    %esi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    

00801ff5 <pipeisclosed>:
{
  801ff5:	55                   	push   %ebp
  801ff6:	89 e5                	mov    %esp,%ebp
  801ff8:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802002:	8b 45 08             	mov    0x8(%ebp),%eax
  802005:	89 04 24             	mov    %eax,(%esp)
  802008:	e8 09 ef ff ff       	call   800f16 <fd_lookup>
  80200d:	89 c2                	mov    %eax,%edx
  80200f:	85 d2                	test   %edx,%edx
  802011:	78 15                	js     802028 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  802013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802016:	89 04 24             	mov    %eax,(%esp)
  802019:	e8 92 ee ff ff       	call   800eb0 <fd2data>
	return _pipeisclosed(fd, p);
  80201e:	89 c2                	mov    %eax,%edx
  802020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802023:	e8 0b fd ff ff       	call   801d33 <_pipeisclosed>
}
  802028:	c9                   	leave  
  802029:	c3                   	ret    
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802033:	b8 00 00 00 00       	mov    $0x0,%eax
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    

0080203a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802040:	c7 44 24 04 07 2b 80 	movl   $0x802b07,0x4(%esp)
  802047:	00 
  802048:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204b:	89 04 24             	mov    %eax,(%esp)
  80204e:	e8 c4 e7 ff ff       	call   800817 <strcpy>
	return 0;
}
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
  802058:	c9                   	leave  
  802059:	c3                   	ret    

0080205a <devcons_write>:
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	57                   	push   %edi
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  802066:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80206b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802071:	eb 31                	jmp    8020a4 <devcons_write+0x4a>
		m = n - tot;
  802073:	8b 75 10             	mov    0x10(%ebp),%esi
  802076:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802078:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80207b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802080:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802083:	89 74 24 08          	mov    %esi,0x8(%esp)
  802087:	03 45 0c             	add    0xc(%ebp),%eax
  80208a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208e:	89 3c 24             	mov    %edi,(%esp)
  802091:	e8 1e e9 ff ff       	call   8009b4 <memmove>
		sys_cputs(buf, m);
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	89 3c 24             	mov    %edi,(%esp)
  80209d:	e8 c4 ea ff ff       	call   800b66 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020a2:	01 f3                	add    %esi,%ebx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020a9:	72 c8                	jb     802073 <devcons_write+0x19>
}
  8020ab:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020b1:	5b                   	pop    %ebx
  8020b2:	5e                   	pop    %esi
  8020b3:	5f                   	pop    %edi
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    

008020b6 <devcons_read>:
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  8020bc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020c5:	75 07                	jne    8020ce <devcons_read+0x18>
  8020c7:	eb 2a                	jmp    8020f3 <devcons_read+0x3d>
		sys_yield();
  8020c9:	e8 46 eb ff ff       	call   800c14 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020ce:	66 90                	xchg   %ax,%ax
  8020d0:	e8 af ea ff ff       	call   800b84 <sys_cgetc>
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	74 f0                	je     8020c9 <devcons_read+0x13>
	if (c < 0)
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	78 16                	js     8020f3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  8020dd:	83 f8 04             	cmp    $0x4,%eax
  8020e0:	74 0c                	je     8020ee <devcons_read+0x38>
	*(char*)vbuf = c;
  8020e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e5:	88 02                	mov    %al,(%edx)
	return 1;
  8020e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ec:	eb 05                	jmp    8020f3 <devcons_read+0x3d>
		return 0;
  8020ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    

008020f5 <cputchar>:
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fe:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802101:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802108:	00 
  802109:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80210c:	89 04 24             	mov    %eax,(%esp)
  80210f:	e8 52 ea ff ff       	call   800b66 <sys_cputs>
}
  802114:	c9                   	leave  
  802115:	c3                   	ret    

00802116 <getchar>:
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80211c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802123:	00 
  802124:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802132:	e8 6e f0 ff ff       	call   8011a5 <read>
	if (r < 0)
  802137:	85 c0                	test   %eax,%eax
  802139:	78 0f                	js     80214a <getchar+0x34>
	if (r < 1)
  80213b:	85 c0                	test   %eax,%eax
  80213d:	7e 06                	jle    802145 <getchar+0x2f>
	return c;
  80213f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802143:	eb 05                	jmp    80214a <getchar+0x34>
		return -E_EOF;
  802145:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <iscons>:
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802155:	89 44 24 04          	mov    %eax,0x4(%esp)
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	89 04 24             	mov    %eax,(%esp)
  80215f:	e8 b2 ed ff ff       	call   800f16 <fd_lookup>
  802164:	85 c0                	test   %eax,%eax
  802166:	78 11                	js     802179 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802171:	39 10                	cmp    %edx,(%eax)
  802173:	0f 94 c0             	sete   %al
  802176:	0f b6 c0             	movzbl %al,%eax
}
  802179:	c9                   	leave  
  80217a:	c3                   	ret    

0080217b <opencons>:
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802181:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802184:	89 04 24             	mov    %eax,(%esp)
  802187:	e8 3b ed ff ff       	call   800ec7 <fd_alloc>
		return r;
  80218c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80218e:	85 c0                	test   %eax,%eax
  802190:	78 40                	js     8021d2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802192:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802199:	00 
  80219a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a8:	e8 86 ea ff ff       	call   800c33 <sys_page_alloc>
		return r;
  8021ad:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	78 1f                	js     8021d2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8021b3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021c8:	89 04 24             	mov    %eax,(%esp)
  8021cb:	e8 d0 ec ff ff       	call   800ea0 <fd2num>
  8021d0:	89 c2                	mov    %eax,%edx
}
  8021d2:	89 d0                	mov    %edx,%eax
  8021d4:	c9                   	leave  
  8021d5:	c3                   	ret    
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	56                   	push   %esi
  8021e4:	53                   	push   %ebx
  8021e5:	83 ec 10             	sub    $0x10,%esp
  8021e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  8021f1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  8021f3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8021f8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  8021fb:	89 04 24             	mov    %eax,(%esp)
  8021fe:	e8 46 ec ff ff       	call   800e49 <sys_ipc_recv>
    if(r < 0){
  802203:	85 c0                	test   %eax,%eax
  802205:	79 16                	jns    80221d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802207:	85 f6                	test   %esi,%esi
  802209:	74 06                	je     802211 <ipc_recv+0x31>
            *from_env_store = 0;
  80220b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802211:	85 db                	test   %ebx,%ebx
  802213:	74 2c                	je     802241 <ipc_recv+0x61>
            *perm_store = 0;
  802215:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80221b:	eb 24                	jmp    802241 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80221d:	85 f6                	test   %esi,%esi
  80221f:	74 0a                	je     80222b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802221:	a1 08 40 80 00       	mov    0x804008,%eax
  802226:	8b 40 74             	mov    0x74(%eax),%eax
  802229:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80222b:	85 db                	test   %ebx,%ebx
  80222d:	74 0a                	je     802239 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80222f:	a1 08 40 80 00       	mov    0x804008,%eax
  802234:	8b 40 78             	mov    0x78(%eax),%eax
  802237:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802239:	a1 08 40 80 00       	mov    0x804008,%eax
  80223e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802241:	83 c4 10             	add    $0x10,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    

00802248 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	57                   	push   %edi
  80224c:	56                   	push   %esi
  80224d:	53                   	push   %ebx
  80224e:	83 ec 1c             	sub    $0x1c,%esp
  802251:	8b 7d 08             	mov    0x8(%ebp),%edi
  802254:	8b 75 0c             	mov    0xc(%ebp),%esi
  802257:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80225a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80225c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802261:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802264:	8b 45 14             	mov    0x14(%ebp),%eax
  802267:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80226f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	e8 ab eb ff ff       	call   800e26 <sys_ipc_try_send>
        if(r == 0){
  80227b:	85 c0                	test   %eax,%eax
  80227d:	74 28                	je     8022a7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80227f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802282:	74 1c                	je     8022a0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  802284:	c7 44 24 08 13 2b 80 	movl   $0x802b13,0x8(%esp)
  80228b:	00 
  80228c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802293:	00 
  802294:	c7 04 24 2a 2b 80 00 	movl   $0x802b2a,(%esp)
  80229b:	e8 54 de ff ff       	call   8000f4 <_panic>
        }
        sys_yield();
  8022a0:	e8 6f e9 ff ff       	call   800c14 <sys_yield>
    }
  8022a5:	eb bd                	jmp    802264 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8022a7:	83 c4 1c             	add    $0x1c,%esp
  8022aa:	5b                   	pop    %ebx
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    

008022af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022b5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022ba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022c3:	8b 52 50             	mov    0x50(%edx),%edx
  8022c6:	39 ca                	cmp    %ecx,%edx
  8022c8:	75 0d                	jne    8022d7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022cd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022d2:	8b 40 40             	mov    0x40(%eax),%eax
  8022d5:	eb 0e                	jmp    8022e5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  8022d7:	83 c0 01             	add    $0x1,%eax
  8022da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022df:	75 d9                	jne    8022ba <ipc_find_env+0xb>
	return 0;
  8022e1:	66 b8 00 00          	mov    $0x0,%ax
}
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    

008022e7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022e7:	55                   	push   %ebp
  8022e8:	89 e5                	mov    %esp,%ebp
  8022ea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ed:	89 d0                	mov    %edx,%eax
  8022ef:	c1 e8 16             	shr    $0x16,%eax
  8022f2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022f9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8022fe:	f6 c1 01             	test   $0x1,%cl
  802301:	74 1d                	je     802320 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802303:	c1 ea 0c             	shr    $0xc,%edx
  802306:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80230d:	f6 c2 01             	test   $0x1,%dl
  802310:	74 0e                	je     802320 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802312:	c1 ea 0c             	shr    $0xc,%edx
  802315:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80231c:	ef 
  80231d:	0f b7 c0             	movzwl %ax,%eax
}
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    
  802322:	66 90                	xchg   %ax,%ax
  802324:	66 90                	xchg   %ax,%ax
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	83 ec 0c             	sub    $0xc,%esp
  802336:	8b 44 24 28          	mov    0x28(%esp),%eax
  80233a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80233e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802342:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802346:	85 c0                	test   %eax,%eax
  802348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80234c:	89 ea                	mov    %ebp,%edx
  80234e:	89 0c 24             	mov    %ecx,(%esp)
  802351:	75 2d                	jne    802380 <__udivdi3+0x50>
  802353:	39 e9                	cmp    %ebp,%ecx
  802355:	77 61                	ja     8023b8 <__udivdi3+0x88>
  802357:	85 c9                	test   %ecx,%ecx
  802359:	89 ce                	mov    %ecx,%esi
  80235b:	75 0b                	jne    802368 <__udivdi3+0x38>
  80235d:	b8 01 00 00 00       	mov    $0x1,%eax
  802362:	31 d2                	xor    %edx,%edx
  802364:	f7 f1                	div    %ecx
  802366:	89 c6                	mov    %eax,%esi
  802368:	31 d2                	xor    %edx,%edx
  80236a:	89 e8                	mov    %ebp,%eax
  80236c:	f7 f6                	div    %esi
  80236e:	89 c5                	mov    %eax,%ebp
  802370:	89 f8                	mov    %edi,%eax
  802372:	f7 f6                	div    %esi
  802374:	89 ea                	mov    %ebp,%edx
  802376:	83 c4 0c             	add    $0xc,%esp
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	39 e8                	cmp    %ebp,%eax
  802382:	77 24                	ja     8023a8 <__udivdi3+0x78>
  802384:	0f bd e8             	bsr    %eax,%ebp
  802387:	83 f5 1f             	xor    $0x1f,%ebp
  80238a:	75 3c                	jne    8023c8 <__udivdi3+0x98>
  80238c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802390:	39 34 24             	cmp    %esi,(%esp)
  802393:	0f 86 9f 00 00 00    	jbe    802438 <__udivdi3+0x108>
  802399:	39 d0                	cmp    %edx,%eax
  80239b:	0f 82 97 00 00 00    	jb     802438 <__udivdi3+0x108>
  8023a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	31 c0                	xor    %eax,%eax
  8023ac:	83 c4 0c             	add    $0xc,%esp
  8023af:	5e                   	pop    %esi
  8023b0:	5f                   	pop    %edi
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
  8023b3:	90                   	nop
  8023b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	89 f8                	mov    %edi,%eax
  8023ba:	f7 f1                	div    %ecx
  8023bc:	31 d2                	xor    %edx,%edx
  8023be:	83 c4 0c             	add    $0xc,%esp
  8023c1:	5e                   	pop    %esi
  8023c2:	5f                   	pop    %edi
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    
  8023c5:	8d 76 00             	lea    0x0(%esi),%esi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	8b 3c 24             	mov    (%esp),%edi
  8023cd:	d3 e0                	shl    %cl,%eax
  8023cf:	89 c6                	mov    %eax,%esi
  8023d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023d6:	29 e8                	sub    %ebp,%eax
  8023d8:	89 c1                	mov    %eax,%ecx
  8023da:	d3 ef                	shr    %cl,%edi
  8023dc:	89 e9                	mov    %ebp,%ecx
  8023de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023e2:	8b 3c 24             	mov    (%esp),%edi
  8023e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023e9:	89 d6                	mov    %edx,%esi
  8023eb:	d3 e7                	shl    %cl,%edi
  8023ed:	89 c1                	mov    %eax,%ecx
  8023ef:	89 3c 24             	mov    %edi,(%esp)
  8023f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023f6:	d3 ee                	shr    %cl,%esi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	d3 e2                	shl    %cl,%edx
  8023fc:	89 c1                	mov    %eax,%ecx
  8023fe:	d3 ef                	shr    %cl,%edi
  802400:	09 d7                	or     %edx,%edi
  802402:	89 f2                	mov    %esi,%edx
  802404:	89 f8                	mov    %edi,%eax
  802406:	f7 74 24 08          	divl   0x8(%esp)
  80240a:	89 d6                	mov    %edx,%esi
  80240c:	89 c7                	mov    %eax,%edi
  80240e:	f7 24 24             	mull   (%esp)
  802411:	39 d6                	cmp    %edx,%esi
  802413:	89 14 24             	mov    %edx,(%esp)
  802416:	72 30                	jb     802448 <__udivdi3+0x118>
  802418:	8b 54 24 04          	mov    0x4(%esp),%edx
  80241c:	89 e9                	mov    %ebp,%ecx
  80241e:	d3 e2                	shl    %cl,%edx
  802420:	39 c2                	cmp    %eax,%edx
  802422:	73 05                	jae    802429 <__udivdi3+0xf9>
  802424:	3b 34 24             	cmp    (%esp),%esi
  802427:	74 1f                	je     802448 <__udivdi3+0x118>
  802429:	89 f8                	mov    %edi,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	e9 7a ff ff ff       	jmp    8023ac <__udivdi3+0x7c>
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	31 d2                	xor    %edx,%edx
  80243a:	b8 01 00 00 00       	mov    $0x1,%eax
  80243f:	e9 68 ff ff ff       	jmp    8023ac <__udivdi3+0x7c>
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	8d 47 ff             	lea    -0x1(%edi),%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	83 c4 0c             	add    $0xc,%esp
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    
  802454:	66 90                	xchg   %ax,%ax
  802456:	66 90                	xchg   %ax,%ax
  802458:	66 90                	xchg   %ax,%ax
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 14             	sub    $0x14,%esp
  802466:	8b 44 24 28          	mov    0x28(%esp),%eax
  80246a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80246e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802472:	89 c7                	mov    %eax,%edi
  802474:	89 44 24 04          	mov    %eax,0x4(%esp)
  802478:	8b 44 24 30          	mov    0x30(%esp),%eax
  80247c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802480:	89 34 24             	mov    %esi,(%esp)
  802483:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802487:	85 c0                	test   %eax,%eax
  802489:	89 c2                	mov    %eax,%edx
  80248b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80248f:	75 17                	jne    8024a8 <__umoddi3+0x48>
  802491:	39 fe                	cmp    %edi,%esi
  802493:	76 4b                	jbe    8024e0 <__umoddi3+0x80>
  802495:	89 c8                	mov    %ecx,%eax
  802497:	89 fa                	mov    %edi,%edx
  802499:	f7 f6                	div    %esi
  80249b:	89 d0                	mov    %edx,%eax
  80249d:	31 d2                	xor    %edx,%edx
  80249f:	83 c4 14             	add    $0x14,%esp
  8024a2:	5e                   	pop    %esi
  8024a3:	5f                   	pop    %edi
  8024a4:	5d                   	pop    %ebp
  8024a5:	c3                   	ret    
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	39 f8                	cmp    %edi,%eax
  8024aa:	77 54                	ja     802500 <__umoddi3+0xa0>
  8024ac:	0f bd e8             	bsr    %eax,%ebp
  8024af:	83 f5 1f             	xor    $0x1f,%ebp
  8024b2:	75 5c                	jne    802510 <__umoddi3+0xb0>
  8024b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024b8:	39 3c 24             	cmp    %edi,(%esp)
  8024bb:	0f 87 e7 00 00 00    	ja     8025a8 <__umoddi3+0x148>
  8024c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024c5:	29 f1                	sub    %esi,%ecx
  8024c7:	19 c7                	sbb    %eax,%edi
  8024c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024d9:	83 c4 14             	add    $0x14,%esp
  8024dc:	5e                   	pop    %esi
  8024dd:	5f                   	pop    %edi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    
  8024e0:	85 f6                	test   %esi,%esi
  8024e2:	89 f5                	mov    %esi,%ebp
  8024e4:	75 0b                	jne    8024f1 <__umoddi3+0x91>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f6                	div    %esi
  8024ef:	89 c5                	mov    %eax,%ebp
  8024f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024f5:	31 d2                	xor    %edx,%edx
  8024f7:	f7 f5                	div    %ebp
  8024f9:	89 c8                	mov    %ecx,%eax
  8024fb:	f7 f5                	div    %ebp
  8024fd:	eb 9c                	jmp    80249b <__umoddi3+0x3b>
  8024ff:	90                   	nop
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 fa                	mov    %edi,%edx
  802504:	83 c4 14             	add    $0x14,%esp
  802507:	5e                   	pop    %esi
  802508:	5f                   	pop    %edi
  802509:	5d                   	pop    %ebp
  80250a:	c3                   	ret    
  80250b:	90                   	nop
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	8b 04 24             	mov    (%esp),%eax
  802513:	be 20 00 00 00       	mov    $0x20,%esi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	29 ee                	sub    %ebp,%esi
  80251c:	d3 e2                	shl    %cl,%edx
  80251e:	89 f1                	mov    %esi,%ecx
  802520:	d3 e8                	shr    %cl,%eax
  802522:	89 e9                	mov    %ebp,%ecx
  802524:	89 44 24 04          	mov    %eax,0x4(%esp)
  802528:	8b 04 24             	mov    (%esp),%eax
  80252b:	09 54 24 04          	or     %edx,0x4(%esp)
  80252f:	89 fa                	mov    %edi,%edx
  802531:	d3 e0                	shl    %cl,%eax
  802533:	89 f1                	mov    %esi,%ecx
  802535:	89 44 24 08          	mov    %eax,0x8(%esp)
  802539:	8b 44 24 10          	mov    0x10(%esp),%eax
  80253d:	d3 ea                	shr    %cl,%edx
  80253f:	89 e9                	mov    %ebp,%ecx
  802541:	d3 e7                	shl    %cl,%edi
  802543:	89 f1                	mov    %esi,%ecx
  802545:	d3 e8                	shr    %cl,%eax
  802547:	89 e9                	mov    %ebp,%ecx
  802549:	09 f8                	or     %edi,%eax
  80254b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80254f:	f7 74 24 04          	divl   0x4(%esp)
  802553:	d3 e7                	shl    %cl,%edi
  802555:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802559:	89 d7                	mov    %edx,%edi
  80255b:	f7 64 24 08          	mull   0x8(%esp)
  80255f:	39 d7                	cmp    %edx,%edi
  802561:	89 c1                	mov    %eax,%ecx
  802563:	89 14 24             	mov    %edx,(%esp)
  802566:	72 2c                	jb     802594 <__umoddi3+0x134>
  802568:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80256c:	72 22                	jb     802590 <__umoddi3+0x130>
  80256e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802572:	29 c8                	sub    %ecx,%eax
  802574:	19 d7                	sbb    %edx,%edi
  802576:	89 e9                	mov    %ebp,%ecx
  802578:	89 fa                	mov    %edi,%edx
  80257a:	d3 e8                	shr    %cl,%eax
  80257c:	89 f1                	mov    %esi,%ecx
  80257e:	d3 e2                	shl    %cl,%edx
  802580:	89 e9                	mov    %ebp,%ecx
  802582:	d3 ef                	shr    %cl,%edi
  802584:	09 d0                	or     %edx,%eax
  802586:	89 fa                	mov    %edi,%edx
  802588:	83 c4 14             	add    $0x14,%esp
  80258b:	5e                   	pop    %esi
  80258c:	5f                   	pop    %edi
  80258d:	5d                   	pop    %ebp
  80258e:	c3                   	ret    
  80258f:	90                   	nop
  802590:	39 d7                	cmp    %edx,%edi
  802592:	75 da                	jne    80256e <__umoddi3+0x10e>
  802594:	8b 14 24             	mov    (%esp),%edx
  802597:	89 c1                	mov    %eax,%ecx
  802599:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80259d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025a1:	eb cb                	jmp    80256e <__umoddi3+0x10e>
  8025a3:	90                   	nop
  8025a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025ac:	0f 82 0f ff ff ff    	jb     8024c1 <__umoddi3+0x61>
  8025b2:	e9 1a ff ff ff       	jmp    8024d1 <__umoddi3+0x71>
