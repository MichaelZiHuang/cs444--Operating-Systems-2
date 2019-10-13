
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 0c                	je     80004c <umain+0x19>
		cprintf("eflags wrong\n");
  800040:	c7 04 24 e0 1f 80 00 	movl   $0x801fe0,(%esp)
  800047:	e8 1d 01 00 00       	call   800169 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80004c:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800051:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800056:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  800057:	c7 04 24 ee 1f 80 00 	movl   $0x801fee,(%esp)
  80005e:	e8 06 01 00 00       	call   800169 <cprintf>
}
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	83 ec 10             	sub    $0x10,%esp
  80006d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800070:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800073:	e8 fd 0a 00 00       	call   800b75 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x30>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	89 74 24 04          	mov    %esi,0x4(%esp)
  800099:	89 1c 24             	mov    %ebx,(%esp)
  80009c:	e8 92 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 07 00 00 00       	call   8000ad <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b3:	e8 3d 0f 00 00       	call   800ff5 <close_all>
	sys_env_destroy(0);
  8000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bf:	e8 5f 0a 00 00       	call   800b23 <sys_env_destroy>
}
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    

008000c6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	53                   	push   %ebx
  8000ca:	83 ec 14             	sub    $0x14,%esp
  8000cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d0:	8b 13                	mov    (%ebx),%edx
  8000d2:	8d 42 01             	lea    0x1(%edx),%eax
  8000d5:	89 03                	mov    %eax,(%ebx)
  8000d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 19                	jne    8000fe <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ec:	00 
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	89 04 24             	mov    %eax,(%esp)
  8000f3:	e8 ee 09 00 00       	call   800ae6 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fe:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800102:	83 c4 14             	add    $0x14,%esp
  800105:	5b                   	pop    %ebx
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800111:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800118:	00 00 00 
	b.cnt = 0;
  80011b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800122:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012c:	8b 45 08             	mov    0x8(%ebp),%eax
  80012f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800133:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013d:	c7 04 24 c6 00 80 00 	movl   $0x8000c6,(%esp)
  800144:	e8 b5 01 00 00       	call   8002fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800149:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800159:	89 04 24             	mov    %eax,(%esp)
  80015c:	e8 85 09 00 00       	call   800ae6 <sys_cputs>

	return b.cnt;
}
  800161:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 87 ff ff ff       	call   800108 <vcprintf>
	va_end(ap);

	return cnt;
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    
  800183:	66 90                	xchg   %ax,%ax
  800185:	66 90                	xchg   %ax,%ax
  800187:	66 90                	xchg   %ax,%ax
  800189:	66 90                	xchg   %ax,%ax
  80018b:	66 90                	xchg   %ax,%ax
  80018d:	66 90                	xchg   %ax,%ax
  80018f:	90                   	nop

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 c3                	mov    %eax,%ebx
  8001a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bd:	39 d9                	cmp    %ebx,%ecx
  8001bf:	72 05                	jb     8001c6 <printnum+0x36>
  8001c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001c4:	77 69                	ja     80022f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001cd:	83 ee 01             	sub    $0x1,%esi
  8001d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001e0:	89 c3                	mov    %eax,%ebx
  8001e2:	89 d6                	mov    %edx,%esi
  8001e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	e8 3c 1b 00 00       	call   801d40 <__udivdi3>
  800204:	89 d9                	mov    %ebx,%ecx
  800206:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	89 54 24 04          	mov    %edx,0x4(%esp)
  800215:	89 fa                	mov    %edi,%edx
  800217:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021a:	e8 71 ff ff ff       	call   800190 <printnum>
  80021f:	eb 1b                	jmp    80023c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800225:	8b 45 18             	mov    0x18(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	ff d3                	call   *%ebx
  80022d:	eb 03                	jmp    800232 <printnum+0xa2>
  80022f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800232:	83 ee 01             	sub    $0x1,%esi
  800235:	85 f6                	test   %esi,%esi
  800237:	7f e8                	jg     800221 <printnum+0x91>
  800239:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800240:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800244:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800247:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80024a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800252:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	e8 0c 1c 00 00       	call   801e70 <__umoddi3>
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	0f be 80 12 20 80 00 	movsbl 0x802012(%eax),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800275:	ff d0                	call   *%eax
}
  800277:	83 c4 3c             	add    $0x3c,%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800282:	83 fa 01             	cmp    $0x1,%edx
  800285:	7e 0e                	jle    800295 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800287:	8b 10                	mov    (%eax),%edx
  800289:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 02                	mov    (%edx),%eax
  800290:	8b 52 04             	mov    0x4(%edx),%edx
  800293:	eb 22                	jmp    8002b7 <getuint+0x38>
	else if (lflag)
  800295:	85 d2                	test   %edx,%edx
  800297:	74 10                	je     8002a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	eb 0e                	jmp    8002b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c8:	73 0a                	jae    8002d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	88 02                	mov    %al,(%edx)
}
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <printfmt>:
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8002dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	e8 02 00 00 00       	call   8002fe <vprintfmt>
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <vprintfmt>:
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	57                   	push   %edi
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	83 ec 3c             	sub    $0x3c,%esp
  800307:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80030a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030d:	eb 1f                	jmp    80032e <vprintfmt+0x30>
			if (ch == '\0'){
  80030f:	85 c0                	test   %eax,%eax
  800311:	75 0f                	jne    800322 <vprintfmt+0x24>
				color = 0x0100;
  800313:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80031a:	01 00 00 
  80031d:	e9 b3 03 00 00       	jmp    8006d5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800322:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032c:	89 f3                	mov    %esi,%ebx
  80032e:	8d 73 01             	lea    0x1(%ebx),%esi
  800331:	0f b6 03             	movzbl (%ebx),%eax
  800334:	83 f8 25             	cmp    $0x25,%eax
  800337:	75 d6                	jne    80030f <vprintfmt+0x11>
  800339:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80033d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800344:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80034b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	eb 1d                	jmp    800376 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800359:	89 de                	mov    %ebx,%esi
			padc = '-';
  80035b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80035f:	eb 15                	jmp    800376 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800361:	89 de                	mov    %ebx,%esi
			padc = '0';
  800363:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800367:	eb 0d                	jmp    800376 <vprintfmt+0x78>
				width = precision, precision = -1;
  800369:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80036f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8d 5e 01             	lea    0x1(%esi),%ebx
  800379:	0f b6 0e             	movzbl (%esi),%ecx
  80037c:	0f b6 c1             	movzbl %cl,%eax
  80037f:	83 e9 23             	sub    $0x23,%ecx
  800382:	80 f9 55             	cmp    $0x55,%cl
  800385:	0f 87 2a 03 00 00    	ja     8006b5 <vprintfmt+0x3b7>
  80038b:	0f b6 c9             	movzbl %cl,%ecx
  80038e:	ff 24 8d 60 21 80 00 	jmp    *0x802160(,%ecx,4)
  800395:	89 de                	mov    %ebx,%esi
  800397:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80039c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80039f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003a3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003a9:	83 fb 09             	cmp    $0x9,%ebx
  8003ac:	77 36                	ja     8003e4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8003ae:	83 c6 01             	add    $0x1,%esi
			}
  8003b1:	eb e9                	jmp    80039c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8003c3:	eb 22                	jmp    8003e7 <vprintfmt+0xe9>
  8003c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003c8:	85 c9                	test   %ecx,%ecx
  8003ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cf:	0f 49 c1             	cmovns %ecx,%eax
  8003d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	89 de                	mov    %ebx,%esi
  8003d7:	eb 9d                	jmp    800376 <vprintfmt+0x78>
  8003d9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8003db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003e2:	eb 92                	jmp    800376 <vprintfmt+0x78>
  8003e4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8003e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003eb:	79 89                	jns    800376 <vprintfmt+0x78>
  8003ed:	e9 77 ff ff ff       	jmp    800369 <vprintfmt+0x6b>
			lflag++;
  8003f2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8003f7:	e9 7a ff ff ff       	jmp    800376 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800411:	e9 18 ff ff ff       	jmp    80032e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 50 04             	lea    0x4(%eax),%edx
  80041c:	89 55 14             	mov    %edx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	99                   	cltd   
  800422:	31 d0                	xor    %edx,%eax
  800424:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800426:	83 f8 0f             	cmp    $0xf,%eax
  800429:	7f 0b                	jg     800436 <vprintfmt+0x138>
  80042b:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  800432:	85 d2                	test   %edx,%edx
  800434:	75 20                	jne    800456 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800436:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043a:	c7 44 24 08 2a 20 80 	movl   $0x80202a,0x8(%esp)
  800441:	00 
  800442:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800446:	8b 45 08             	mov    0x8(%ebp),%eax
  800449:	89 04 24             	mov    %eax,(%esp)
  80044c:	e8 85 fe ff ff       	call   8002d6 <printfmt>
  800451:	e9 d8 fe ff ff       	jmp    80032e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800456:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045a:	c7 44 24 08 1a 24 80 	movl   $0x80241a,0x8(%esp)
  800461:	00 
  800462:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800466:	8b 45 08             	mov    0x8(%ebp),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 65 fe ff ff       	call   8002d6 <printfmt>
  800471:	e9 b8 fe ff ff       	jmp    80032e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800479:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80048a:	85 f6                	test   %esi,%esi
  80048c:	b8 23 20 80 00       	mov    $0x802023,%eax
  800491:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800494:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800498:	0f 84 97 00 00 00    	je     800535 <vprintfmt+0x237>
  80049e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004a2:	0f 8e 9b 00 00 00    	jle    800543 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ac:	89 34 24             	mov    %esi,(%esp)
  8004af:	e8 c4 02 00 00       	call   800778 <strnlen>
  8004b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004b7:	29 c2                	sub    %eax,%edx
  8004b9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8004bc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004cc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	eb 0f                	jmp    8004df <vprintfmt+0x1e1>
					putch(padc, putdat);
  8004d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d7:	89 04 24             	mov    %eax,(%esp)
  8004da:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	83 eb 01             	sub    $0x1,%ebx
  8004df:	85 db                	test   %ebx,%ebx
  8004e1:	7f ed                	jg     8004d0 <vprintfmt+0x1d2>
  8004e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004e9:	85 d2                	test   %edx,%edx
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	0f 49 c2             	cmovns %edx,%eax
  8004f3:	29 c2                	sub    %eax,%edx
  8004f5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004f8:	89 d7                	mov    %edx,%edi
  8004fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004fd:	eb 50                	jmp    80054f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800503:	74 1e                	je     800523 <vprintfmt+0x225>
  800505:	0f be d2             	movsbl %dl,%edx
  800508:	83 ea 20             	sub    $0x20,%edx
  80050b:	83 fa 5e             	cmp    $0x5e,%edx
  80050e:	76 13                	jbe    800523 <vprintfmt+0x225>
					putch('?', putdat);
  800510:	8b 45 0c             	mov    0xc(%ebp),%eax
  800513:	89 44 24 04          	mov    %eax,0x4(%esp)
  800517:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051e:	ff 55 08             	call   *0x8(%ebp)
  800521:	eb 0d                	jmp    800530 <vprintfmt+0x232>
					putch(ch, putdat);
  800523:	8b 55 0c             	mov    0xc(%ebp),%edx
  800526:	89 54 24 04          	mov    %edx,0x4(%esp)
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800530:	83 ef 01             	sub    $0x1,%edi
  800533:	eb 1a                	jmp    80054f <vprintfmt+0x251>
  800535:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800538:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80053b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80053e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800541:	eb 0c                	jmp    80054f <vprintfmt+0x251>
  800543:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800546:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800549:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80054c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80054f:	83 c6 01             	add    $0x1,%esi
  800552:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800556:	0f be c2             	movsbl %dl,%eax
  800559:	85 c0                	test   %eax,%eax
  80055b:	74 27                	je     800584 <vprintfmt+0x286>
  80055d:	85 db                	test   %ebx,%ebx
  80055f:	78 9e                	js     8004ff <vprintfmt+0x201>
  800561:	83 eb 01             	sub    $0x1,%ebx
  800564:	79 99                	jns    8004ff <vprintfmt+0x201>
  800566:	89 f8                	mov    %edi,%eax
  800568:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	89 c3                	mov    %eax,%ebx
  800570:	eb 1a                	jmp    80058c <vprintfmt+0x28e>
				putch(' ', putdat);
  800572:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800576:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80057f:	83 eb 01             	sub    $0x1,%ebx
  800582:	eb 08                	jmp    80058c <vprintfmt+0x28e>
  800584:	89 fb                	mov    %edi,%ebx
  800586:	8b 75 08             	mov    0x8(%ebp),%esi
  800589:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f e2                	jg     800572 <vprintfmt+0x274>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800596:	e9 93 fd ff ff       	jmp    80032e <vprintfmt+0x30>
	if (lflag >= 2)
  80059b:	83 fa 01             	cmp    $0x1,%edx
  80059e:	7e 16                	jle    8005b6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 08             	lea    0x8(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	8b 50 04             	mov    0x4(%eax),%edx
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b4:	eb 32                	jmp    8005e8 <vprintfmt+0x2ea>
	else if (lflag)
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	74 18                	je     8005d2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c3:	8b 30                	mov    (%eax),%esi
  8005c5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005c8:	89 f0                	mov    %esi,%eax
  8005ca:	c1 f8 1f             	sar    $0x1f,%eax
  8005cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d0:	eb 16                	jmp    8005e8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 30                	mov    (%eax),%esi
  8005dd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005e0:	89 f0                	mov    %esi,%eax
  8005e2:	c1 f8 1f             	sar    $0x1f,%eax
  8005e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8005e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8005ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f7:	0f 89 80 00 00 00    	jns    80067d <vprintfmt+0x37f>
				putch('-', putdat);
  8005fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800601:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800608:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800611:	f7 d8                	neg    %eax
  800613:	83 d2 00             	adc    $0x0,%edx
  800616:	f7 da                	neg    %edx
			base = 10;
  800618:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80061d:	eb 5e                	jmp    80067d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 58 fc ff ff       	call   80027f <getuint>
			base = 10;
  800627:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80062c:	eb 4f                	jmp    80067d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 49 fc ff ff       	call   80027f <getuint>
            base = 8;
  800636:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80063b:	eb 40                	jmp    80067d <vprintfmt+0x37f>
			putch('0', putdat);
  80063d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800641:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80064b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800656:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800669:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066e:	eb 0d                	jmp    80067d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 07 fc ff ff       	call   80027f <getuint>
			base = 16;
  800678:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80067d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800681:	89 74 24 10          	mov    %esi,0x10(%esp)
  800685:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800688:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80068c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	89 54 24 04          	mov    %edx,0x4(%esp)
  800697:	89 fa                	mov    %edi,%edx
  800699:	8b 45 08             	mov    0x8(%ebp),%eax
  80069c:	e8 ef fa ff ff       	call   800190 <printnum>
			break;
  8006a1:	e9 88 fc ff ff       	jmp    80032e <vprintfmt+0x30>
			putch(ch, putdat);
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	89 04 24             	mov    %eax,(%esp)
  8006ad:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006b0:	e9 79 fc ff ff       	jmp    80032e <vprintfmt+0x30>
			putch('%', putdat);
  8006b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c3:	89 f3                	mov    %esi,%ebx
  8006c5:	eb 03                	jmp    8006ca <vprintfmt+0x3cc>
  8006c7:	83 eb 01             	sub    $0x1,%ebx
  8006ca:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006ce:	75 f7                	jne    8006c7 <vprintfmt+0x3c9>
  8006d0:	e9 59 fc ff ff       	jmp    80032e <vprintfmt+0x30>
}
  8006d5:	83 c4 3c             	add    $0x3c,%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5f                   	pop    %edi
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 28             	sub    $0x28,%esp
  8006e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	74 30                	je     80072e <vsnprintf+0x51>
  8006fe:	85 d2                	test   %edx,%edx
  800700:	7e 2c                	jle    80072e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800709:	8b 45 10             	mov    0x10(%ebp),%eax
  80070c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800710:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	c7 04 24 b9 02 80 00 	movl   $0x8002b9,(%esp)
  80071e:	e8 db fb ff ff       	call   8002fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800723:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800726:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072c:	eb 05                	jmp    800733 <vsnprintf+0x56>
		return -E_INVAL;
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800742:	8b 45 10             	mov    0x10(%ebp),%eax
  800745:	89 44 24 08          	mov    %eax,0x8(%esp)
  800749:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 82 ff ff ff       	call   8006dd <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    
  80075d:	66 90                	xchg   %ax,%ax
  80075f:	90                   	nop

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	eb 03                	jmp    800770 <strlen+0x10>
		n++;
  80076d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	75 f7                	jne    80076d <strlen+0xd>
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
  800786:	eb 03                	jmp    80078b <strnlen+0x13>
		n++;
  800788:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 d0                	cmp    %edx,%eax
  80078d:	74 06                	je     800795 <strnlen+0x1d>
  80078f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800793:	75 f3                	jne    800788 <strnlen+0x10>
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ef                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	89 1c 24             	mov    %ebx,(%esp)
  8007c4:	e8 97 ff ff ff       	call   800760 <strlen>
	strcpy(dst + len, src);
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d0:	01 d8                	add    %ebx,%eax
  8007d2:	89 04 24             	mov    %eax,(%esp)
  8007d5:	e8 bd ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	83 c4 08             	add    $0x8,%esp
  8007df:	5b                   	pop    %ebx
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	89 f3                	mov    %esi,%ebx
  8007ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f2:	89 f2                	mov    %esi,%edx
  8007f4:	eb 0f                	jmp    800805 <strncpy+0x23>
		*dst++ = *src;
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	0f b6 01             	movzbl (%ecx),%eax
  8007fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800802:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800805:	39 da                	cmp    %ebx,%edx
  800807:	75 ed                	jne    8007f6 <strncpy+0x14>
	}
	return ret;
}
  800809:	89 f0                	mov    %esi,%eax
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	8b 75 08             	mov    0x8(%ebp),%esi
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80081d:	89 f0                	mov    %esi,%eax
  80081f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800823:	85 c9                	test   %ecx,%ecx
  800825:	75 0b                	jne    800832 <strlcpy+0x23>
  800827:	eb 1d                	jmp    800846 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800832:	39 d8                	cmp    %ebx,%eax
  800834:	74 0b                	je     800841 <strlcpy+0x32>
  800836:	0f b6 0a             	movzbl (%edx),%ecx
  800839:	84 c9                	test   %cl,%cl
  80083b:	75 ec                	jne    800829 <strlcpy+0x1a>
  80083d:	89 c2                	mov    %eax,%edx
  80083f:	eb 02                	jmp    800843 <strlcpy+0x34>
  800841:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800843:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800846:	29 f0                	sub    %esi,%eax
}
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800855:	eb 06                	jmp    80085d <strcmp+0x11>
		p++, q++;
  800857:	83 c1 01             	add    $0x1,%ecx
  80085a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	84 c0                	test   %al,%al
  800862:	74 04                	je     800868 <strcmp+0x1c>
  800864:	3a 02                	cmp    (%edx),%al
  800866:	74 ef                	je     800857 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800868:	0f b6 c0             	movzbl %al,%eax
  80086b:	0f b6 12             	movzbl (%edx),%edx
  80086e:	29 d0                	sub    %edx,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 c3                	mov    %eax,%ebx
  80087e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800881:	eb 06                	jmp    800889 <strncmp+0x17>
		n--, p++, q++;
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800889:	39 d8                	cmp    %ebx,%eax
  80088b:	74 15                	je     8008a2 <strncmp+0x30>
  80088d:	0f b6 08             	movzbl (%eax),%ecx
  800890:	84 c9                	test   %cl,%cl
  800892:	74 04                	je     800898 <strncmp+0x26>
  800894:	3a 0a                	cmp    (%edx),%cl
  800896:	74 eb                	je     800883 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 00             	movzbl (%eax),%eax
  80089b:	0f b6 12             	movzbl (%edx),%edx
  80089e:	29 d0                	sub    %edx,%eax
  8008a0:	eb 05                	jmp    8008a7 <strncmp+0x35>
		return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b4:	eb 07                	jmp    8008bd <strchr+0x13>
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	74 0f                	je     8008c9 <strchr+0x1f>
	for (; *s; s++)
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	0f b6 10             	movzbl (%eax),%edx
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	75 f2                	jne    8008b6 <strchr+0xc>
			return (char *) s;
	return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d5:	eb 07                	jmp    8008de <strfind+0x13>
		if (*s == c)
  8008d7:	38 ca                	cmp    %cl,%dl
  8008d9:	74 0a                	je     8008e5 <strfind+0x1a>
	for (; *s; s++)
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	0f b6 10             	movzbl (%eax),%edx
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	75 f2                	jne    8008d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	74 36                	je     80092d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fd:	75 28                	jne    800927 <memset+0x40>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 23                	jne    800927 <memset+0x40>
		c &= 0xFF;
  800904:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800908:	89 d3                	mov    %edx,%ebx
  80090a:	c1 e3 08             	shl    $0x8,%ebx
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	c1 e6 18             	shl    $0x18,%esi
  800912:	89 d0                	mov    %edx,%eax
  800914:	c1 e0 10             	shl    $0x10,%eax
  800917:	09 f0                	or     %esi,%eax
  800919:	09 c2                	or     %eax,%edx
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800922:	fc                   	cld    
  800923:	f3 ab                	rep stos %eax,%es:(%edi)
  800925:	eb 06                	jmp    80092d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	fc                   	cld    
  80092b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800942:	39 c6                	cmp    %eax,%esi
  800944:	73 35                	jae    80097b <memmove+0x47>
  800946:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800949:	39 d0                	cmp    %edx,%eax
  80094b:	73 2e                	jae    80097b <memmove+0x47>
		s += n;
		d += n;
  80094d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800950:	89 d6                	mov    %edx,%esi
  800952:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095a:	75 13                	jne    80096f <memmove+0x3b>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 0e                	jne    80096f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800961:	83 ef 04             	sub    $0x4,%edi
  800964:	8d 72 fc             	lea    -0x4(%edx),%esi
  800967:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80096a:	fd                   	std    
  80096b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096d:	eb 09                	jmp    800978 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096f:	83 ef 01             	sub    $0x1,%edi
  800972:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800975:	fd                   	std    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800978:	fc                   	cld    
  800979:	eb 1d                	jmp    800998 <memmove+0x64>
  80097b:	89 f2                	mov    %esi,%edx
  80097d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	f6 c2 03             	test   $0x3,%dl
  800982:	75 0f                	jne    800993 <memmove+0x5f>
  800984:	f6 c1 03             	test   $0x3,%cl
  800987:	75 0a                	jne    800993 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800989:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80098c:	89 c7                	mov    %eax,%edi
  80098e:	fc                   	cld    
  80098f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800991:	eb 05                	jmp    800998 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	e8 79 ff ff ff       	call   800934 <memmove>
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c8:	89 d6                	mov    %edx,%esi
  8009ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	eb 1a                	jmp    8009e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cf:	0f b6 02             	movzbl (%edx),%eax
  8009d2:	0f b6 19             	movzbl (%ecx),%ebx
  8009d5:	38 d8                	cmp    %bl,%al
  8009d7:	74 0a                	je     8009e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 db             	movzbl %bl,%ebx
  8009df:	29 d8                	sub    %ebx,%eax
  8009e1:	eb 0f                	jmp    8009f2 <memcmp+0x35>
		s1++, s2++;
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  8009e9:	39 f2                	cmp    %esi,%edx
  8009eb:	75 e2                	jne    8009cf <memcmp+0x12>
	}

	return 0;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a04:	eb 07                	jmp    800a0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	38 08                	cmp    %cl,(%eax)
  800a08:	74 07                	je     800a11 <memfind+0x1b>
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 d0                	cmp    %edx,%eax
  800a0f:	72 f5                	jb     800a06 <memfind+0x10>
			break;
	return (void *) s;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1f:	eb 03                	jmp    800a24 <strtol+0x11>
		s++;
  800a21:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a24:	0f b6 0a             	movzbl (%edx),%ecx
  800a27:	80 f9 09             	cmp    $0x9,%cl
  800a2a:	74 f5                	je     800a21 <strtol+0xe>
  800a2c:	80 f9 20             	cmp    $0x20,%cl
  800a2f:	74 f0                	je     800a21 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a31:	80 f9 2b             	cmp    $0x2b,%cl
  800a34:	75 0a                	jne    800a40 <strtol+0x2d>
		s++;
  800a36:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a39:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3e:	eb 11                	jmp    800a51 <strtol+0x3e>
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800a45:	80 f9 2d             	cmp    $0x2d,%cl
  800a48:	75 07                	jne    800a51 <strtol+0x3e>
		s++, neg = 1;
  800a4a:	8d 52 01             	lea    0x1(%edx),%edx
  800a4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a56:	75 15                	jne    800a6d <strtol+0x5a>
  800a58:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5b:	75 10                	jne    800a6d <strtol+0x5a>
  800a5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a61:	75 0a                	jne    800a6d <strtol+0x5a>
		s += 2, base = 16;
  800a63:	83 c2 02             	add    $0x2,%edx
  800a66:	b8 10 00 00 00       	mov    $0x10,%eax
  800a6b:	eb 10                	jmp    800a7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	75 0c                	jne    800a7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800a73:	80 3a 30             	cmpb   $0x30,(%edx)
  800a76:	75 05                	jne    800a7d <strtol+0x6a>
		s++, base = 8;
  800a78:	83 c2 01             	add    $0x1,%edx
  800a7b:	b0 08                	mov    $0x8,%al
		base = 10;
  800a7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a85:	0f b6 0a             	movzbl (%edx),%ecx
  800a88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a8b:	89 f0                	mov    %esi,%eax
  800a8d:	3c 09                	cmp    $0x9,%al
  800a8f:	77 08                	ja     800a99 <strtol+0x86>
			dig = *s - '0';
  800a91:	0f be c9             	movsbl %cl,%ecx
  800a94:	83 e9 30             	sub    $0x30,%ecx
  800a97:	eb 20                	jmp    800ab9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800a99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a9c:	89 f0                	mov    %esi,%eax
  800a9e:	3c 19                	cmp    $0x19,%al
  800aa0:	77 08                	ja     800aaa <strtol+0x97>
			dig = *s - 'a' + 10;
  800aa2:	0f be c9             	movsbl %cl,%ecx
  800aa5:	83 e9 57             	sub    $0x57,%ecx
  800aa8:	eb 0f                	jmp    800ab9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aaa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800aad:	89 f0                	mov    %esi,%eax
  800aaf:	3c 19                	cmp    $0x19,%al
  800ab1:	77 16                	ja     800ac9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ab3:	0f be c9             	movsbl %cl,%ecx
  800ab6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800abc:	7d 0f                	jge    800acd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800abe:	83 c2 01             	add    $0x1,%edx
  800ac1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ac5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ac7:	eb bc                	jmp    800a85 <strtol+0x72>
  800ac9:	89 d8                	mov    %ebx,%eax
  800acb:	eb 02                	jmp    800acf <strtol+0xbc>
  800acd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800acf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad3:	74 05                	je     800ada <strtol+0xc7>
		*endptr = (char *) s;
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ada:	f7 d8                	neg    %eax
  800adc:	85 ff                	test   %edi,%edi
  800ade:	0f 44 c3             	cmove  %ebx,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	89 c7                	mov    %eax,%edi
  800afb:	89 c6                	mov    %eax,%esi
  800afd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800b2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b31:	b8 03 00 00 00       	mov    $0x3,%eax
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 cb                	mov    %ecx,%ebx
  800b3b:	89 cf                	mov    %ecx,%edi
  800b3d:	89 ce                	mov    %ecx,%esi
  800b3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7e 28                	jle    800b6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b50:	00 
  800b51:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800b58:	00 
  800b59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b60:	00 
  800b61:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800b68:	e8 29 10 00 00       	call   801b96 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6d:	83 c4 2c             	add    $0x2c,%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 02 00 00 00       	mov    $0x2,%eax
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	89 d7                	mov    %edx,%edi
  800b8b:	89 d6                	mov    %edx,%esi
  800b8d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_yield>:

void
sys_yield(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bbc:	be 00 00 00 00       	mov    $0x0,%esi
  800bc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcf:	89 f7                	mov    %esi,%edi
  800bd1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 28                	jle    800bff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800be2:	00 
  800be3:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800bea:	00 
  800beb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf2:	00 
  800bf3:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800bfa:	e8 97 0f 00 00       	call   801b96 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bff:	83 c4 2c             	add    $0x2c,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c10:	b8 05 00 00 00       	mov    $0x5,%eax
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c21:	8b 75 18             	mov    0x18(%ebp),%esi
  800c24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 28                	jle    800c52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c35:	00 
  800c36:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800c3d:	00 
  800c3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c45:	00 
  800c46:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800c4d:	e8 44 0f 00 00       	call   801b96 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c52:	83 c4 2c             	add    $0x2c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 df                	mov    %ebx,%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 28                	jle    800ca5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c88:	00 
  800c89:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800c90:	00 
  800c91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c98:	00 
  800c99:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800ca0:	e8 f1 0e 00 00       	call   801b96 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca5:	83 c4 2c             	add    $0x2c,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 28                	jle    800cf8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cdb:	00 
  800cdc:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ceb:	00 
  800cec:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800cf3:	e8 9e 0e 00 00       	call   801b96 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf8:	83 c4 2c             	add    $0x2c,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 28                	jle    800d4b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d27:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d2e:	00 
  800d2f:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800d36:	00 
  800d37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3e:	00 
  800d3f:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800d46:	e8 4b 0e 00 00       	call   801b96 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4b:	83 c4 2c             	add    $0x2c,%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 28                	jle    800d9e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d81:	00 
  800d82:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800d89:	00 
  800d8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d91:	00 
  800d92:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800d99:	e8 f8 0d 00 00       	call   801b96 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9e:	83 c4 2c             	add    $0x2c,%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dac:	be 00 00 00 00       	mov    $0x0,%esi
  800db1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 cb                	mov    %ecx,%ebx
  800de1:	89 cf                	mov    %ecx,%edi
  800de3:	89 ce                	mov    %ecx,%esi
  800de5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 28                	jle    800e13 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800def:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800df6:	00 
  800df7:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800e0e:	e8 83 0d 00 00       	call   801b96 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e13:	83 c4 2c             	add    $0x2c,%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    
  800e1b:	66 90                	xchg   %ax,%ax
  800e1d:	66 90                	xchg   %ax,%ax
  800e1f:	90                   	nop

00800e20 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e40:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e52:	89 c2                	mov    %eax,%edx
  800e54:	c1 ea 16             	shr    $0x16,%edx
  800e57:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5e:	f6 c2 01             	test   $0x1,%dl
  800e61:	74 11                	je     800e74 <fd_alloc+0x2d>
  800e63:	89 c2                	mov    %eax,%edx
  800e65:	c1 ea 0c             	shr    $0xc,%edx
  800e68:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6f:	f6 c2 01             	test   $0x1,%dl
  800e72:	75 09                	jne    800e7d <fd_alloc+0x36>
			*fd_store = fd;
  800e74:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	eb 17                	jmp    800e94 <fd_alloc+0x4d>
  800e7d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e82:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e87:	75 c9                	jne    800e52 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800e89:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e8f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e9c:	83 f8 1f             	cmp    $0x1f,%eax
  800e9f:	77 36                	ja     800ed7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea1:	c1 e0 0c             	shl    $0xc,%eax
  800ea4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	c1 ea 16             	shr    $0x16,%edx
  800eae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb5:	f6 c2 01             	test   $0x1,%dl
  800eb8:	74 24                	je     800ede <fd_lookup+0x48>
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	c1 ea 0c             	shr    $0xc,%edx
  800ebf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	74 1a                	je     800ee5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ece:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	eb 13                	jmp    800eea <fd_lookup+0x54>
		return -E_INVAL;
  800ed7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edc:	eb 0c                	jmp    800eea <fd_lookup+0x54>
		return -E_INVAL;
  800ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee3:	eb 05                	jmp    800eea <fd_lookup+0x54>
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 18             	sub    $0x18,%esp
  800ef2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef5:	ba c8 23 80 00       	mov    $0x8023c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800efa:	eb 13                	jmp    800f0f <dev_lookup+0x23>
  800efc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eff:	39 08                	cmp    %ecx,(%eax)
  800f01:	75 0c                	jne    800f0f <dev_lookup+0x23>
			*dev = devtab[i];
  800f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f06:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0d:	eb 30                	jmp    800f3f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800f0f:	8b 02                	mov    (%edx),%eax
  800f11:	85 c0                	test   %eax,%eax
  800f13:	75 e7                	jne    800efc <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f15:	a1 08 40 80 00       	mov    0x804008,%eax
  800f1a:	8b 40 48             	mov    0x48(%eax),%eax
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f25:	c7 04 24 4c 23 80 00 	movl   $0x80234c,(%esp)
  800f2c:	e8 38 f2 ff ff       	call   800169 <cprintf>
	*dev = 0;
  800f31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <fd_close>:
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 20             	sub    $0x20,%esp
  800f49:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f52:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f56:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f5c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5f:	89 04 24             	mov    %eax,(%esp)
  800f62:	e8 2f ff ff ff       	call   800e96 <fd_lookup>
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 05                	js     800f70 <fd_close+0x2f>
	    || fd != fd2)
  800f6b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f6e:	74 0c                	je     800f7c <fd_close+0x3b>
		return (must_exist ? r : 0);
  800f70:	84 db                	test   %bl,%bl
  800f72:	ba 00 00 00 00       	mov    $0x0,%edx
  800f77:	0f 44 c2             	cmove  %edx,%eax
  800f7a:	eb 3f                	jmp    800fbb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f83:	8b 06                	mov    (%esi),%eax
  800f85:	89 04 24             	mov    %eax,(%esp)
  800f88:	e8 5f ff ff ff       	call   800eec <dev_lookup>
  800f8d:	89 c3                	mov    %eax,%ebx
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 16                	js     800fa9 <fd_close+0x68>
		if (dev->dev_close)
  800f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f96:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f99:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	74 07                	je     800fa9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800fa2:	89 34 24             	mov    %esi,(%esp)
  800fa5:	ff d0                	call   *%eax
  800fa7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  800fa9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fb4:	e8 a1 fc ff ff       	call   800c5a <sys_page_unmap>
	return r;
  800fb9:	89 d8                	mov    %ebx,%eax
}
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <close>:

int
close(int fdnum)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd2:	89 04 24             	mov    %eax,(%esp)
  800fd5:	e8 bc fe ff ff       	call   800e96 <fd_lookup>
  800fda:	89 c2                	mov    %eax,%edx
  800fdc:	85 d2                	test   %edx,%edx
  800fde:	78 13                	js     800ff3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  800fe0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fe7:	00 
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 4e ff ff ff       	call   800f41 <fd_close>
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <close_all>:

void
close_all(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801001:	89 1c 24             	mov    %ebx,(%esp)
  801004:	e8 b9 ff ff ff       	call   800fc2 <close>
	for (i = 0; i < MAXFD; i++)
  801009:	83 c3 01             	add    $0x1,%ebx
  80100c:	83 fb 20             	cmp    $0x20,%ebx
  80100f:	75 f0                	jne    801001 <close_all+0xc>
}
  801011:	83 c4 14             	add    $0x14,%esp
  801014:	5b                   	pop    %ebx
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
  80101d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801020:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801023:	89 44 24 04          	mov    %eax,0x4(%esp)
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
  80102a:	89 04 24             	mov    %eax,(%esp)
  80102d:	e8 64 fe ff ff       	call   800e96 <fd_lookup>
  801032:	89 c2                	mov    %eax,%edx
  801034:	85 d2                	test   %edx,%edx
  801036:	0f 88 e1 00 00 00    	js     80111d <dup+0x106>
		return r;
	close(newfdnum);
  80103c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103f:	89 04 24             	mov    %eax,(%esp)
  801042:	e8 7b ff ff ff       	call   800fc2 <close>

	newfd = INDEX2FD(newfdnum);
  801047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80104a:	c1 e3 0c             	shl    $0xc,%ebx
  80104d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801056:	89 04 24             	mov    %eax,(%esp)
  801059:	e8 d2 fd ff ff       	call   800e30 <fd2data>
  80105e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801060:	89 1c 24             	mov    %ebx,(%esp)
  801063:	e8 c8 fd ff ff       	call   800e30 <fd2data>
  801068:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80106a:	89 f0                	mov    %esi,%eax
  80106c:	c1 e8 16             	shr    $0x16,%eax
  80106f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801076:	a8 01                	test   $0x1,%al
  801078:	74 43                	je     8010bd <dup+0xa6>
  80107a:	89 f0                	mov    %esi,%eax
  80107c:	c1 e8 0c             	shr    $0xc,%eax
  80107f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801086:	f6 c2 01             	test   $0x1,%dl
  801089:	74 32                	je     8010bd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80108b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801092:	25 07 0e 00 00       	and    $0xe07,%eax
  801097:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80109f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a6:	00 
  8010a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b2:	e8 50 fb ff ff       	call   800c07 <sys_page_map>
  8010b7:	89 c6                	mov    %eax,%esi
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 3e                	js     8010fb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c0:	89 c2                	mov    %eax,%edx
  8010c2:	c1 ea 0c             	shr    $0xc,%edx
  8010c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e1:	00 
  8010e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ed:	e8 15 fb ff ff       	call   800c07 <sys_page_map>
  8010f2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8010f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f7:	85 f6                	test   %esi,%esi
  8010f9:	79 22                	jns    80111d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8010fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801106:	e8 4f fb ff ff       	call   800c5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80110b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80110f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801116:	e8 3f fb ff ff       	call   800c5a <sys_page_unmap>
	return r;
  80111b:	89 f0                	mov    %esi,%eax
}
  80111d:	83 c4 3c             	add    $0x3c,%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	53                   	push   %ebx
  801129:	83 ec 24             	sub    $0x24,%esp
  80112c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801132:	89 44 24 04          	mov    %eax,0x4(%esp)
  801136:	89 1c 24             	mov    %ebx,(%esp)
  801139:	e8 58 fd ff ff       	call   800e96 <fd_lookup>
  80113e:	89 c2                	mov    %eax,%edx
  801140:	85 d2                	test   %edx,%edx
  801142:	78 6d                	js     8011b1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801144:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114e:	8b 00                	mov    (%eax),%eax
  801150:	89 04 24             	mov    %eax,(%esp)
  801153:	e8 94 fd ff ff       	call   800eec <dev_lookup>
  801158:	85 c0                	test   %eax,%eax
  80115a:	78 55                	js     8011b1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80115c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115f:	8b 50 08             	mov    0x8(%eax),%edx
  801162:	83 e2 03             	and    $0x3,%edx
  801165:	83 fa 01             	cmp    $0x1,%edx
  801168:	75 23                	jne    80118d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80116a:	a1 08 40 80 00       	mov    0x804008,%eax
  80116f:	8b 40 48             	mov    0x48(%eax),%eax
  801172:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117a:	c7 04 24 8d 23 80 00 	movl   $0x80238d,(%esp)
  801181:	e8 e3 ef ff ff       	call   800169 <cprintf>
		return -E_INVAL;
  801186:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118b:	eb 24                	jmp    8011b1 <read+0x8c>
	}
	if (!dev->dev_read)
  80118d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801190:	8b 52 08             	mov    0x8(%edx),%edx
  801193:	85 d2                	test   %edx,%edx
  801195:	74 15                	je     8011ac <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801197:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80119a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80119e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011a5:	89 04 24             	mov    %eax,(%esp)
  8011a8:	ff d2                	call   *%edx
  8011aa:	eb 05                	jmp    8011b1 <read+0x8c>
		return -E_NOT_SUPP;
  8011ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8011b1:	83 c4 24             	add    $0x24,%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	57                   	push   %edi
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 1c             	sub    $0x1c,%esp
  8011c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cb:	eb 23                	jmp    8011f0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011cd:	89 f0                	mov    %esi,%eax
  8011cf:	29 d8                	sub    %ebx,%eax
  8011d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d5:	89 d8                	mov    %ebx,%eax
  8011d7:	03 45 0c             	add    0xc(%ebp),%eax
  8011da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011de:	89 3c 24             	mov    %edi,(%esp)
  8011e1:	e8 3f ff ff ff       	call   801125 <read>
		if (m < 0)
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 10                	js     8011fa <readn+0x43>
			return m;
		if (m == 0)
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 0a                	je     8011f8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8011ee:	01 c3                	add    %eax,%ebx
  8011f0:	39 f3                	cmp    %esi,%ebx
  8011f2:	72 d9                	jb     8011cd <readn+0x16>
  8011f4:	89 d8                	mov    %ebx,%eax
  8011f6:	eb 02                	jmp    8011fa <readn+0x43>
  8011f8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011fa:	83 c4 1c             	add    $0x1c,%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	53                   	push   %ebx
  801206:	83 ec 24             	sub    $0x24,%esp
  801209:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801213:	89 1c 24             	mov    %ebx,(%esp)
  801216:	e8 7b fc ff ff       	call   800e96 <fd_lookup>
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	85 d2                	test   %edx,%edx
  80121f:	78 68                	js     801289 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801221:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801224:	89 44 24 04          	mov    %eax,0x4(%esp)
  801228:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122b:	8b 00                	mov    (%eax),%eax
  80122d:	89 04 24             	mov    %eax,(%esp)
  801230:	e8 b7 fc ff ff       	call   800eec <dev_lookup>
  801235:	85 c0                	test   %eax,%eax
  801237:	78 50                	js     801289 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801239:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801240:	75 23                	jne    801265 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801242:	a1 08 40 80 00       	mov    0x804008,%eax
  801247:	8b 40 48             	mov    0x48(%eax),%eax
  80124a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80124e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801252:	c7 04 24 a9 23 80 00 	movl   $0x8023a9,(%esp)
  801259:	e8 0b ef ff ff       	call   800169 <cprintf>
		return -E_INVAL;
  80125e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801263:	eb 24                	jmp    801289 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801265:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801268:	8b 52 0c             	mov    0xc(%edx),%edx
  80126b:	85 d2                	test   %edx,%edx
  80126d:	74 15                	je     801284 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80126f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801272:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801279:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80127d:	89 04 24             	mov    %eax,(%esp)
  801280:	ff d2                	call   *%edx
  801282:	eb 05                	jmp    801289 <write+0x87>
		return -E_NOT_SUPP;
  801284:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801289:	83 c4 24             	add    $0x24,%esp
  80128c:	5b                   	pop    %ebx
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <seek>:

int
seek(int fdnum, off_t offset)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801295:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
  80129f:	89 04 24             	mov    %eax,(%esp)
  8012a2:	e8 ef fb ff ff       	call   800e96 <fd_lookup>
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 0e                	js     8012b9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 24             	sub    $0x24,%esp
  8012c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cc:	89 1c 24             	mov    %ebx,(%esp)
  8012cf:	e8 c2 fb ff ff       	call   800e96 <fd_lookup>
  8012d4:	89 c2                	mov    %eax,%edx
  8012d6:	85 d2                	test   %edx,%edx
  8012d8:	78 61                	js     80133b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e4:	8b 00                	mov    (%eax),%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 fe fb ff ff       	call   800eec <dev_lookup>
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 49                	js     80133b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f9:	75 23                	jne    80131e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801300:	8b 40 48             	mov    0x48(%eax),%eax
  801303:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130b:	c7 04 24 6c 23 80 00 	movl   $0x80236c,(%esp)
  801312:	e8 52 ee ff ff       	call   800169 <cprintf>
		return -E_INVAL;
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131c:	eb 1d                	jmp    80133b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80131e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801321:	8b 52 18             	mov    0x18(%edx),%edx
  801324:	85 d2                	test   %edx,%edx
  801326:	74 0e                	je     801336 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	ff d2                	call   *%edx
  801334:	eb 05                	jmp    80133b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801336:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80133b:	83 c4 24             	add    $0x24,%esp
  80133e:	5b                   	pop    %ebx
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	53                   	push   %ebx
  801345:	83 ec 24             	sub    $0x24,%esp
  801348:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801352:	8b 45 08             	mov    0x8(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 39 fb ff ff       	call   800e96 <fd_lookup>
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	85 d2                	test   %edx,%edx
  801361:	78 52                	js     8013b5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801363:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801366:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136d:	8b 00                	mov    (%eax),%eax
  80136f:	89 04 24             	mov    %eax,(%esp)
  801372:	e8 75 fb ff ff       	call   800eec <dev_lookup>
  801377:	85 c0                	test   %eax,%eax
  801379:	78 3a                	js     8013b5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801382:	74 2c                	je     8013b0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801384:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801387:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138e:	00 00 00 
	stat->st_isdir = 0;
  801391:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801398:	00 00 00 
	stat->st_dev = dev;
  80139b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a8:	89 14 24             	mov    %edx,(%esp)
  8013ab:	ff 50 14             	call   *0x14(%eax)
  8013ae:	eb 05                	jmp    8013b5 <fstat+0x74>
		return -E_NOT_SUPP;
  8013b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013b5:	83 c4 24             	add    $0x24,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013ca:	00 
  8013cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ce:	89 04 24             	mov    %eax,(%esp)
  8013d1:	e8 fb 01 00 00       	call   8015d1 <open>
  8013d6:	89 c3                	mov    %eax,%ebx
  8013d8:	85 db                	test   %ebx,%ebx
  8013da:	78 1b                	js     8013f7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	e8 56 ff ff ff       	call   801341 <fstat>
  8013eb:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ed:	89 1c 24             	mov    %ebx,(%esp)
  8013f0:	e8 cd fb ff ff       	call   800fc2 <close>
	return r;
  8013f5:	89 f0                	mov    %esi,%eax
}
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	5b                   	pop    %ebx
  8013fb:	5e                   	pop    %esi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 10             	sub    $0x10,%esp
  801406:	89 c6                	mov    %eax,%esi
  801408:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80140a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801411:	75 11                	jne    801424 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801413:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80141a:	e8 a0 08 00 00       	call   801cbf <ipc_find_env>
  80141f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801424:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80142b:	00 
  80142c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801433:	00 
  801434:	89 74 24 04          	mov    %esi,0x4(%esp)
  801438:	a1 04 40 80 00       	mov    0x804004,%eax
  80143d:	89 04 24             	mov    %eax,(%esp)
  801440:	e8 13 08 00 00       	call   801c58 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801445:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80144c:	00 
  80144d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801451:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801458:	e8 93 07 00 00       	call   801bf0 <ipc_recv>
}
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	5b                   	pop    %ebx
  801461:	5e                   	pop    %esi
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    

00801464 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	8b 40 0c             	mov    0xc(%eax),%eax
  801470:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801475:	8b 45 0c             	mov    0xc(%ebp),%eax
  801478:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80147d:	ba 00 00 00 00       	mov    $0x0,%edx
  801482:	b8 02 00 00 00       	mov    $0x2,%eax
  801487:	e8 72 ff ff ff       	call   8013fe <fsipc>
}
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <devfile_flush>:
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801494:	8b 45 08             	mov    0x8(%ebp),%eax
  801497:	8b 40 0c             	mov    0xc(%eax),%eax
  80149a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80149f:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a9:	e8 50 ff ff ff       	call   8013fe <fsipc>
}
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <devfile_stat>:
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 14             	sub    $0x14,%esp
  8014b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8014cf:	e8 2a ff ff ff       	call   8013fe <fsipc>
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	85 d2                	test   %edx,%edx
  8014d8:	78 2b                	js     801505 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014da:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014e1:	00 
  8014e2:	89 1c 24             	mov    %ebx,(%esp)
  8014e5:	e8 ad f2 ff ff       	call   800797 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8014fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801500:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801505:	83 c4 14             	add    $0x14,%esp
  801508:	5b                   	pop    %ebx
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <devfile_write>:
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801511:	c7 44 24 08 d8 23 80 	movl   $0x8023d8,0x8(%esp)
  801518:	00 
  801519:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801520:	00 
  801521:	c7 04 24 f6 23 80 00 	movl   $0x8023f6,(%esp)
  801528:	e8 69 06 00 00       	call   801b96 <_panic>

0080152d <devfile_read>:
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	83 ec 10             	sub    $0x10,%esp
  801535:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801538:	8b 45 08             	mov    0x8(%ebp),%eax
  80153b:	8b 40 0c             	mov    0xc(%eax),%eax
  80153e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801543:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801549:	ba 00 00 00 00       	mov    $0x0,%edx
  80154e:	b8 03 00 00 00       	mov    $0x3,%eax
  801553:	e8 a6 fe ff ff       	call   8013fe <fsipc>
  801558:	89 c3                	mov    %eax,%ebx
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 6a                	js     8015c8 <devfile_read+0x9b>
	assert(r <= n);
  80155e:	39 c6                	cmp    %eax,%esi
  801560:	73 24                	jae    801586 <devfile_read+0x59>
  801562:	c7 44 24 0c 01 24 80 	movl   $0x802401,0xc(%esp)
  801569:	00 
  80156a:	c7 44 24 08 08 24 80 	movl   $0x802408,0x8(%esp)
  801571:	00 
  801572:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801579:	00 
  80157a:	c7 04 24 f6 23 80 00 	movl   $0x8023f6,(%esp)
  801581:	e8 10 06 00 00       	call   801b96 <_panic>
	assert(r <= PGSIZE);
  801586:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80158b:	7e 24                	jle    8015b1 <devfile_read+0x84>
  80158d:	c7 44 24 0c 1d 24 80 	movl   $0x80241d,0xc(%esp)
  801594:	00 
  801595:	c7 44 24 08 08 24 80 	movl   $0x802408,0x8(%esp)
  80159c:	00 
  80159d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8015a4:	00 
  8015a5:	c7 04 24 f6 23 80 00 	movl   $0x8023f6,(%esp)
  8015ac:	e8 e5 05 00 00       	call   801b96 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015bc:	00 
  8015bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	e8 6c f3 ff ff       	call   800934 <memmove>
}
  8015c8:	89 d8                	mov    %ebx,%eax
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    

008015d1 <open>:
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 24             	sub    $0x24,%esp
  8015d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8015db:	89 1c 24             	mov    %ebx,(%esp)
  8015de:	e8 7d f1 ff ff       	call   800760 <strlen>
  8015e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e8:	7f 60                	jg     80164a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8015ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ed:	89 04 24             	mov    %eax,(%esp)
  8015f0:	e8 52 f8 ff ff       	call   800e47 <fd_alloc>
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	85 d2                	test   %edx,%edx
  8015f9:	78 54                	js     80164f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8015fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ff:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801606:	e8 8c f1 ff ff       	call   800797 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801613:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801616:	b8 01 00 00 00       	mov    $0x1,%eax
  80161b:	e8 de fd ff ff       	call   8013fe <fsipc>
  801620:	89 c3                	mov    %eax,%ebx
  801622:	85 c0                	test   %eax,%eax
  801624:	79 17                	jns    80163d <open+0x6c>
		fd_close(fd, 0);
  801626:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80162d:	00 
  80162e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801631:	89 04 24             	mov    %eax,(%esp)
  801634:	e8 08 f9 ff ff       	call   800f41 <fd_close>
		return r;
  801639:	89 d8                	mov    %ebx,%eax
  80163b:	eb 12                	jmp    80164f <open+0x7e>
	return fd2num(fd);
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	89 04 24             	mov    %eax,(%esp)
  801643:	e8 d8 f7 ff ff       	call   800e20 <fd2num>
  801648:	eb 05                	jmp    80164f <open+0x7e>
		return -E_BAD_PATH;
  80164a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80164f:	83 c4 24             	add    $0x24,%esp
  801652:	5b                   	pop    %ebx
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80165b:	ba 00 00 00 00       	mov    $0x0,%edx
  801660:	b8 08 00 00 00       	mov    $0x8,%eax
  801665:	e8 94 fd ff ff       	call   8013fe <fsipc>
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	56                   	push   %esi
  801670:	53                   	push   %ebx
  801671:	83 ec 10             	sub    $0x10,%esp
  801674:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	89 04 24             	mov    %eax,(%esp)
  80167d:	e8 ae f7 ff ff       	call   800e30 <fd2data>
  801682:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801684:	c7 44 24 04 29 24 80 	movl   $0x802429,0x4(%esp)
  80168b:	00 
  80168c:	89 1c 24             	mov    %ebx,(%esp)
  80168f:	e8 03 f1 ff ff       	call   800797 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801694:	8b 46 04             	mov    0x4(%esi),%eax
  801697:	2b 06                	sub    (%esi),%eax
  801699:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80169f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a6:	00 00 00 
	stat->st_dev = &devpipe;
  8016a9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016b0:	30 80 00 
	return 0;
}
  8016b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 14             	sub    $0x14,%esp
  8016c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d4:	e8 81 f5 ff ff       	call   800c5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d9:	89 1c 24             	mov    %ebx,(%esp)
  8016dc:	e8 4f f7 ff ff       	call   800e30 <fd2data>
  8016e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ec:	e8 69 f5 ff ff       	call   800c5a <sys_page_unmap>
}
  8016f1:	83 c4 14             	add    $0x14,%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <_pipeisclosed>:
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	57                   	push   %edi
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	83 ec 2c             	sub    $0x2c,%esp
  801700:	89 c6                	mov    %eax,%esi
  801702:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801705:	a1 08 40 80 00       	mov    0x804008,%eax
  80170a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80170d:	89 34 24             	mov    %esi,(%esp)
  801710:	e8 e2 05 00 00       	call   801cf7 <pageref>
  801715:	89 c7                	mov    %eax,%edi
  801717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171a:	89 04 24             	mov    %eax,(%esp)
  80171d:	e8 d5 05 00 00       	call   801cf7 <pageref>
  801722:	39 c7                	cmp    %eax,%edi
  801724:	0f 94 c2             	sete   %dl
  801727:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80172a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801730:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801733:	39 fb                	cmp    %edi,%ebx
  801735:	74 21                	je     801758 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801737:	84 d2                	test   %dl,%dl
  801739:	74 ca                	je     801705 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80173b:	8b 51 58             	mov    0x58(%ecx),%edx
  80173e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801742:	89 54 24 08          	mov    %edx,0x8(%esp)
  801746:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174a:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  801751:	e8 13 ea ff ff       	call   800169 <cprintf>
  801756:	eb ad                	jmp    801705 <_pipeisclosed+0xe>
}
  801758:	83 c4 2c             	add    $0x2c,%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5e                   	pop    %esi
  80175d:	5f                   	pop    %edi
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <devpipe_write>:
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	57                   	push   %edi
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	83 ec 1c             	sub    $0x1c,%esp
  801769:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80176c:	89 34 24             	mov    %esi,(%esp)
  80176f:	e8 bc f6 ff ff       	call   800e30 <fd2data>
  801774:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801776:	bf 00 00 00 00       	mov    $0x0,%edi
  80177b:	eb 45                	jmp    8017c2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  80177d:	89 da                	mov    %ebx,%edx
  80177f:	89 f0                	mov    %esi,%eax
  801781:	e8 71 ff ff ff       	call   8016f7 <_pipeisclosed>
  801786:	85 c0                	test   %eax,%eax
  801788:	75 41                	jne    8017cb <devpipe_write+0x6b>
			sys_yield();
  80178a:	e8 05 f4 ff ff       	call   800b94 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80178f:	8b 43 04             	mov    0x4(%ebx),%eax
  801792:	8b 0b                	mov    (%ebx),%ecx
  801794:	8d 51 20             	lea    0x20(%ecx),%edx
  801797:	39 d0                	cmp    %edx,%eax
  801799:	73 e2                	jae    80177d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80179b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017a2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017a5:	99                   	cltd   
  8017a6:	c1 ea 1b             	shr    $0x1b,%edx
  8017a9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8017ac:	83 e1 1f             	and    $0x1f,%ecx
  8017af:	29 d1                	sub    %edx,%ecx
  8017b1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8017b5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8017b9:	83 c0 01             	add    $0x1,%eax
  8017bc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017bf:	83 c7 01             	add    $0x1,%edi
  8017c2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017c5:	75 c8                	jne    80178f <devpipe_write+0x2f>
	return i;
  8017c7:	89 f8                	mov    %edi,%eax
  8017c9:	eb 05                	jmp    8017d0 <devpipe_write+0x70>
				return 0;
  8017cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d0:	83 c4 1c             	add    $0x1c,%esp
  8017d3:	5b                   	pop    %ebx
  8017d4:	5e                   	pop    %esi
  8017d5:	5f                   	pop    %edi
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <devpipe_read>:
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	57                   	push   %edi
  8017dc:	56                   	push   %esi
  8017dd:	53                   	push   %ebx
  8017de:	83 ec 1c             	sub    $0x1c,%esp
  8017e1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017e4:	89 3c 24             	mov    %edi,(%esp)
  8017e7:	e8 44 f6 ff ff       	call   800e30 <fd2data>
  8017ec:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017ee:	be 00 00 00 00       	mov    $0x0,%esi
  8017f3:	eb 3d                	jmp    801832 <devpipe_read+0x5a>
			if (i > 0)
  8017f5:	85 f6                	test   %esi,%esi
  8017f7:	74 04                	je     8017fd <devpipe_read+0x25>
				return i;
  8017f9:	89 f0                	mov    %esi,%eax
  8017fb:	eb 43                	jmp    801840 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  8017fd:	89 da                	mov    %ebx,%edx
  8017ff:	89 f8                	mov    %edi,%eax
  801801:	e8 f1 fe ff ff       	call   8016f7 <_pipeisclosed>
  801806:	85 c0                	test   %eax,%eax
  801808:	75 31                	jne    80183b <devpipe_read+0x63>
			sys_yield();
  80180a:	e8 85 f3 ff ff       	call   800b94 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80180f:	8b 03                	mov    (%ebx),%eax
  801811:	3b 43 04             	cmp    0x4(%ebx),%eax
  801814:	74 df                	je     8017f5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801816:	99                   	cltd   
  801817:	c1 ea 1b             	shr    $0x1b,%edx
  80181a:	01 d0                	add    %edx,%eax
  80181c:	83 e0 1f             	and    $0x1f,%eax
  80181f:	29 d0                	sub    %edx,%eax
  801821:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801829:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80182c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80182f:	83 c6 01             	add    $0x1,%esi
  801832:	3b 75 10             	cmp    0x10(%ebp),%esi
  801835:	75 d8                	jne    80180f <devpipe_read+0x37>
	return i;
  801837:	89 f0                	mov    %esi,%eax
  801839:	eb 05                	jmp    801840 <devpipe_read+0x68>
				return 0;
  80183b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801840:	83 c4 1c             	add    $0x1c,%esp
  801843:	5b                   	pop    %ebx
  801844:	5e                   	pop    %esi
  801845:	5f                   	pop    %edi
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <pipe>:
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	89 04 24             	mov    %eax,(%esp)
  801856:	e8 ec f5 ff ff       	call   800e47 <fd_alloc>
  80185b:	89 c2                	mov    %eax,%edx
  80185d:	85 d2                	test   %edx,%edx
  80185f:	0f 88 4d 01 00 00    	js     8019b2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801865:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80186c:	00 
  80186d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801870:	89 44 24 04          	mov    %eax,0x4(%esp)
  801874:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187b:	e8 33 f3 ff ff       	call   800bb3 <sys_page_alloc>
  801880:	89 c2                	mov    %eax,%edx
  801882:	85 d2                	test   %edx,%edx
  801884:	0f 88 28 01 00 00    	js     8019b2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  80188a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188d:	89 04 24             	mov    %eax,(%esp)
  801890:	e8 b2 f5 ff ff       	call   800e47 <fd_alloc>
  801895:	89 c3                	mov    %eax,%ebx
  801897:	85 c0                	test   %eax,%eax
  801899:	0f 88 fe 00 00 00    	js     80199d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018a6:	00 
  8018a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b5:	e8 f9 f2 ff ff       	call   800bb3 <sys_page_alloc>
  8018ba:	89 c3                	mov    %eax,%ebx
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	0f 88 d9 00 00 00    	js     80199d <pipe+0x155>
	va = fd2data(fd0);
  8018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c7:	89 04 24             	mov    %eax,(%esp)
  8018ca:	e8 61 f5 ff ff       	call   800e30 <fd2data>
  8018cf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018d8:	00 
  8018d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e4:	e8 ca f2 ff ff       	call   800bb3 <sys_page_alloc>
  8018e9:	89 c3                	mov    %eax,%ebx
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	0f 88 97 00 00 00    	js     80198a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f6:	89 04 24             	mov    %eax,(%esp)
  8018f9:	e8 32 f5 ff ff       	call   800e30 <fd2data>
  8018fe:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801905:	00 
  801906:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80190a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801911:	00 
  801912:	89 74 24 04          	mov    %esi,0x4(%esp)
  801916:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191d:	e8 e5 f2 ff ff       	call   800c07 <sys_page_map>
  801922:	89 c3                	mov    %eax,%ebx
  801924:	85 c0                	test   %eax,%eax
  801926:	78 52                	js     80197a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801928:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801931:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801933:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801936:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80193d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801946:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801948:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801955:	89 04 24             	mov    %eax,(%esp)
  801958:	e8 c3 f4 ff ff       	call   800e20 <fd2num>
  80195d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801960:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801962:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801965:	89 04 24             	mov    %eax,(%esp)
  801968:	e8 b3 f4 ff ff       	call   800e20 <fd2num>
  80196d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801970:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	eb 38                	jmp    8019b2 <pipe+0x16a>
	sys_page_unmap(0, va);
  80197a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80197e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801985:	e8 d0 f2 ff ff       	call   800c5a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  80198a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801991:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801998:	e8 bd f2 ff ff       	call   800c5a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  80199d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ab:	e8 aa f2 ff ff       	call   800c5a <sys_page_unmap>
  8019b0:	89 d8                	mov    %ebx,%eax
}
  8019b2:	83 c4 30             	add    $0x30,%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    

008019b9 <pipeisclosed>:
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 c5 f4 ff ff       	call   800e96 <fd_lookup>
  8019d1:	89 c2                	mov    %eax,%edx
  8019d3:	85 d2                	test   %edx,%edx
  8019d5:	78 15                	js     8019ec <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  8019d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019da:	89 04 24             	mov    %eax,(%esp)
  8019dd:	e8 4e f4 ff ff       	call   800e30 <fd2data>
	return _pipeisclosed(fd, p);
  8019e2:	89 c2                	mov    %eax,%edx
  8019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e7:	e8 0b fd ff ff       	call   8016f7 <_pipeisclosed>
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    
  8019ee:	66 90                	xchg   %ax,%ax

008019f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801a00:	c7 44 24 04 48 24 80 	movl   $0x802448,0x4(%esp)
  801a07:	00 
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	89 04 24             	mov    %eax,(%esp)
  801a0e:	e8 84 ed ff ff       	call   800797 <strcpy>
	return 0;
}
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devcons_write>:
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a26:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a31:	eb 31                	jmp    801a64 <devcons_write+0x4a>
		m = n - tot;
  801a33:	8b 75 10             	mov    0x10(%ebp),%esi
  801a36:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a38:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801a3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a40:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a43:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a47:	03 45 0c             	add    0xc(%ebp),%eax
  801a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4e:	89 3c 24             	mov    %edi,(%esp)
  801a51:	e8 de ee ff ff       	call   800934 <memmove>
		sys_cputs(buf, m);
  801a56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5a:	89 3c 24             	mov    %edi,(%esp)
  801a5d:	e8 84 f0 ff ff       	call   800ae6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a62:	01 f3                	add    %esi,%ebx
  801a64:	89 d8                	mov    %ebx,%eax
  801a66:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a69:	72 c8                	jb     801a33 <devcons_write+0x19>
}
  801a6b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5f                   	pop    %edi
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <devcons_read>:
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801a7c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a85:	75 07                	jne    801a8e <devcons_read+0x18>
  801a87:	eb 2a                	jmp    801ab3 <devcons_read+0x3d>
		sys_yield();
  801a89:	e8 06 f1 ff ff       	call   800b94 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a8e:	66 90                	xchg   %ax,%ax
  801a90:	e8 6f f0 ff ff       	call   800b04 <sys_cgetc>
  801a95:	85 c0                	test   %eax,%eax
  801a97:	74 f0                	je     801a89 <devcons_read+0x13>
	if (c < 0)
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 16                	js     801ab3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801a9d:	83 f8 04             	cmp    $0x4,%eax
  801aa0:	74 0c                	je     801aae <devcons_read+0x38>
	*(char*)vbuf = c;
  801aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa5:	88 02                	mov    %al,(%edx)
	return 1;
  801aa7:	b8 01 00 00 00       	mov    $0x1,%eax
  801aac:	eb 05                	jmp    801ab3 <devcons_read+0x3d>
		return 0;
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <cputchar>:
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ac1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ac8:	00 
  801ac9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 12 f0 ff ff       	call   800ae6 <sys_cputs>
}
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <getchar>:
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801adc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ae3:	00 
  801ae4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aeb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af2:	e8 2e f6 ff ff       	call   801125 <read>
	if (r < 0)
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 0f                	js     801b0a <getchar+0x34>
	if (r < 1)
  801afb:	85 c0                	test   %eax,%eax
  801afd:	7e 06                	jle    801b05 <getchar+0x2f>
	return c;
  801aff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b03:	eb 05                	jmp    801b0a <getchar+0x34>
		return -E_EOF;
  801b05:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <iscons>:
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	89 04 24             	mov    %eax,(%esp)
  801b1f:	e8 72 f3 ff ff       	call   800e96 <fd_lookup>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 11                	js     801b39 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b31:	39 10                	cmp    %edx,(%eax)
  801b33:	0f 94 c0             	sete   %al
  801b36:	0f b6 c0             	movzbl %al,%eax
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <opencons>:
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b44:	89 04 24             	mov    %eax,(%esp)
  801b47:	e8 fb f2 ff ff       	call   800e47 <fd_alloc>
		return r;
  801b4c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 40                	js     801b92 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b59:	00 
  801b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b68:	e8 46 f0 ff ff       	call   800bb3 <sys_page_alloc>
		return r;
  801b6d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 1f                	js     801b92 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801b73:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b81:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b88:	89 04 24             	mov    %eax,(%esp)
  801b8b:	e8 90 f2 ff ff       	call   800e20 <fd2num>
  801b90:	89 c2                	mov    %eax,%edx
}
  801b92:	89 d0                	mov    %edx,%eax
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b9e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ba1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ba7:	e8 c9 ef ff ff       	call   800b75 <sys_getenvid>
  801bac:	8b 55 0c             	mov    0xc(%ebp),%edx
  801baf:	89 54 24 10          	mov    %edx,0x10(%esp)
  801bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  801bb6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801bba:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc2:	c7 04 24 54 24 80 00 	movl   $0x802454,(%esp)
  801bc9:	e8 9b e5 ff ff       	call   800169 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd5:	89 04 24             	mov    %eax,(%esp)
  801bd8:	e8 2b e5 ff ff       	call   800108 <vcprintf>
	cprintf("\n");
  801bdd:	c7 04 24 41 24 80 00 	movl   $0x802441,(%esp)
  801be4:	e8 80 e5 ff ff       	call   800169 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801be9:	cc                   	int3   
  801bea:	eb fd                	jmp    801be9 <_panic+0x53>
  801bec:	66 90                	xchg   %ax,%ax
  801bee:	66 90                	xchg   %ax,%ax

00801bf0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	83 ec 10             	sub    $0x10,%esp
  801bf8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801c01:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801c03:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801c08:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801c0b:	89 04 24             	mov    %eax,(%esp)
  801c0e:	e8 b6 f1 ff ff       	call   800dc9 <sys_ipc_recv>
    if(r < 0){
  801c13:	85 c0                	test   %eax,%eax
  801c15:	79 16                	jns    801c2d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801c17:	85 f6                	test   %esi,%esi
  801c19:	74 06                	je     801c21 <ipc_recv+0x31>
            *from_env_store = 0;
  801c1b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801c21:	85 db                	test   %ebx,%ebx
  801c23:	74 2c                	je     801c51 <ipc_recv+0x61>
            *perm_store = 0;
  801c25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c2b:	eb 24                	jmp    801c51 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801c2d:	85 f6                	test   %esi,%esi
  801c2f:	74 0a                	je     801c3b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801c31:	a1 08 40 80 00       	mov    0x804008,%eax
  801c36:	8b 40 74             	mov    0x74(%eax),%eax
  801c39:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801c3b:	85 db                	test   %ebx,%ebx
  801c3d:	74 0a                	je     801c49 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801c3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801c44:	8b 40 78             	mov    0x78(%eax),%eax
  801c47:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c49:	a1 08 40 80 00       	mov    0x804008,%eax
  801c4e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	57                   	push   %edi
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 1c             	sub    $0x1c,%esp
  801c61:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801c6a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801c6c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801c71:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801c74:	8b 45 14             	mov    0x14(%ebp),%eax
  801c77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	e8 1b f1 ff ff       	call   800da6 <sys_ipc_try_send>
        if(r == 0){
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	74 28                	je     801cb7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801c8f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c92:	74 1c                	je     801cb0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801c94:	c7 44 24 08 78 24 80 	movl   $0x802478,0x8(%esp)
  801c9b:	00 
  801c9c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801ca3:	00 
  801ca4:	c7 04 24 8f 24 80 00 	movl   $0x80248f,(%esp)
  801cab:	e8 e6 fe ff ff       	call   801b96 <_panic>
        }
        sys_yield();
  801cb0:	e8 df ee ff ff       	call   800b94 <sys_yield>
    }
  801cb5:	eb bd                	jmp    801c74 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801cb7:	83 c4 1c             	add    $0x1c,%esp
  801cba:	5b                   	pop    %ebx
  801cbb:	5e                   	pop    %esi
  801cbc:	5f                   	pop    %edi
  801cbd:	5d                   	pop    %ebp
  801cbe:	c3                   	ret    

00801cbf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cca:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ccd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cd3:	8b 52 50             	mov    0x50(%edx),%edx
  801cd6:	39 ca                	cmp    %ecx,%edx
  801cd8:	75 0d                	jne    801ce7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cda:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cdd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ce2:	8b 40 40             	mov    0x40(%eax),%eax
  801ce5:	eb 0e                	jmp    801cf5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801ce7:	83 c0 01             	add    $0x1,%eax
  801cea:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cef:	75 d9                	jne    801cca <ipc_find_env+0xb>
	return 0;
  801cf1:	66 b8 00 00          	mov    $0x0,%ax
}
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    

00801cf7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cfd:	89 d0                	mov    %edx,%eax
  801cff:	c1 e8 16             	shr    $0x16,%eax
  801d02:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d09:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801d0e:	f6 c1 01             	test   $0x1,%cl
  801d11:	74 1d                	je     801d30 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801d13:	c1 ea 0c             	shr    $0xc,%edx
  801d16:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d1d:	f6 c2 01             	test   $0x1,%dl
  801d20:	74 0e                	je     801d30 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d22:	c1 ea 0c             	shr    $0xc,%edx
  801d25:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d2c:	ef 
  801d2d:	0f b7 c0             	movzwl %ax,%eax
}
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__udivdi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d4a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d4e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d52:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d56:	85 c0                	test   %eax,%eax
  801d58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d5c:	89 ea                	mov    %ebp,%edx
  801d5e:	89 0c 24             	mov    %ecx,(%esp)
  801d61:	75 2d                	jne    801d90 <__udivdi3+0x50>
  801d63:	39 e9                	cmp    %ebp,%ecx
  801d65:	77 61                	ja     801dc8 <__udivdi3+0x88>
  801d67:	85 c9                	test   %ecx,%ecx
  801d69:	89 ce                	mov    %ecx,%esi
  801d6b:	75 0b                	jne    801d78 <__udivdi3+0x38>
  801d6d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d72:	31 d2                	xor    %edx,%edx
  801d74:	f7 f1                	div    %ecx
  801d76:	89 c6                	mov    %eax,%esi
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	89 e8                	mov    %ebp,%eax
  801d7c:	f7 f6                	div    %esi
  801d7e:	89 c5                	mov    %eax,%ebp
  801d80:	89 f8                	mov    %edi,%eax
  801d82:	f7 f6                	div    %esi
  801d84:	89 ea                	mov    %ebp,%edx
  801d86:	83 c4 0c             	add    $0xc,%esp
  801d89:	5e                   	pop    %esi
  801d8a:	5f                   	pop    %edi
  801d8b:	5d                   	pop    %ebp
  801d8c:	c3                   	ret    
  801d8d:	8d 76 00             	lea    0x0(%esi),%esi
  801d90:	39 e8                	cmp    %ebp,%eax
  801d92:	77 24                	ja     801db8 <__udivdi3+0x78>
  801d94:	0f bd e8             	bsr    %eax,%ebp
  801d97:	83 f5 1f             	xor    $0x1f,%ebp
  801d9a:	75 3c                	jne    801dd8 <__udivdi3+0x98>
  801d9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801da0:	39 34 24             	cmp    %esi,(%esp)
  801da3:	0f 86 9f 00 00 00    	jbe    801e48 <__udivdi3+0x108>
  801da9:	39 d0                	cmp    %edx,%eax
  801dab:	0f 82 97 00 00 00    	jb     801e48 <__udivdi3+0x108>
  801db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db8:	31 d2                	xor    %edx,%edx
  801dba:	31 c0                	xor    %eax,%eax
  801dbc:	83 c4 0c             	add    $0xc,%esp
  801dbf:	5e                   	pop    %esi
  801dc0:	5f                   	pop    %edi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    
  801dc3:	90                   	nop
  801dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	89 f8                	mov    %edi,%eax
  801dca:	f7 f1                	div    %ecx
  801dcc:	31 d2                	xor    %edx,%edx
  801dce:	83 c4 0c             	add    $0xc,%esp
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	8b 3c 24             	mov    (%esp),%edi
  801ddd:	d3 e0                	shl    %cl,%eax
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	b8 20 00 00 00       	mov    $0x20,%eax
  801de6:	29 e8                	sub    %ebp,%eax
  801de8:	89 c1                	mov    %eax,%ecx
  801dea:	d3 ef                	shr    %cl,%edi
  801dec:	89 e9                	mov    %ebp,%ecx
  801dee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801df2:	8b 3c 24             	mov    (%esp),%edi
  801df5:	09 74 24 08          	or     %esi,0x8(%esp)
  801df9:	89 d6                	mov    %edx,%esi
  801dfb:	d3 e7                	shl    %cl,%edi
  801dfd:	89 c1                	mov    %eax,%ecx
  801dff:	89 3c 24             	mov    %edi,(%esp)
  801e02:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e06:	d3 ee                	shr    %cl,%esi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	d3 e2                	shl    %cl,%edx
  801e0c:	89 c1                	mov    %eax,%ecx
  801e0e:	d3 ef                	shr    %cl,%edi
  801e10:	09 d7                	or     %edx,%edi
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	89 f8                	mov    %edi,%eax
  801e16:	f7 74 24 08          	divl   0x8(%esp)
  801e1a:	89 d6                	mov    %edx,%esi
  801e1c:	89 c7                	mov    %eax,%edi
  801e1e:	f7 24 24             	mull   (%esp)
  801e21:	39 d6                	cmp    %edx,%esi
  801e23:	89 14 24             	mov    %edx,(%esp)
  801e26:	72 30                	jb     801e58 <__udivdi3+0x118>
  801e28:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e2c:	89 e9                	mov    %ebp,%ecx
  801e2e:	d3 e2                	shl    %cl,%edx
  801e30:	39 c2                	cmp    %eax,%edx
  801e32:	73 05                	jae    801e39 <__udivdi3+0xf9>
  801e34:	3b 34 24             	cmp    (%esp),%esi
  801e37:	74 1f                	je     801e58 <__udivdi3+0x118>
  801e39:	89 f8                	mov    %edi,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	e9 7a ff ff ff       	jmp    801dbc <__udivdi3+0x7c>
  801e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e48:	31 d2                	xor    %edx,%edx
  801e4a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4f:	e9 68 ff ff ff       	jmp    801dbc <__udivdi3+0x7c>
  801e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e58:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e5b:	31 d2                	xor    %edx,%edx
  801e5d:	83 c4 0c             	add    $0xc,%esp
  801e60:	5e                   	pop    %esi
  801e61:	5f                   	pop    %edi
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    
  801e64:	66 90                	xchg   %ax,%ax
  801e66:	66 90                	xchg   %ax,%ax
  801e68:	66 90                	xchg   %ax,%ax
  801e6a:	66 90                	xchg   %ax,%ax
  801e6c:	66 90                	xchg   %ax,%ax
  801e6e:	66 90                	xchg   %ax,%ax

00801e70 <__umoddi3>:
  801e70:	55                   	push   %ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	83 ec 14             	sub    $0x14,%esp
  801e76:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e7a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e7e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e82:	89 c7                	mov    %eax,%edi
  801e84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e88:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e90:	89 34 24             	mov    %esi,(%esp)
  801e93:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e97:	85 c0                	test   %eax,%eax
  801e99:	89 c2                	mov    %eax,%edx
  801e9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e9f:	75 17                	jne    801eb8 <__umoddi3+0x48>
  801ea1:	39 fe                	cmp    %edi,%esi
  801ea3:	76 4b                	jbe    801ef0 <__umoddi3+0x80>
  801ea5:	89 c8                	mov    %ecx,%eax
  801ea7:	89 fa                	mov    %edi,%edx
  801ea9:	f7 f6                	div    %esi
  801eab:	89 d0                	mov    %edx,%eax
  801ead:	31 d2                	xor    %edx,%edx
  801eaf:	83 c4 14             	add    $0x14,%esp
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    
  801eb6:	66 90                	xchg   %ax,%ax
  801eb8:	39 f8                	cmp    %edi,%eax
  801eba:	77 54                	ja     801f10 <__umoddi3+0xa0>
  801ebc:	0f bd e8             	bsr    %eax,%ebp
  801ebf:	83 f5 1f             	xor    $0x1f,%ebp
  801ec2:	75 5c                	jne    801f20 <__umoddi3+0xb0>
  801ec4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ec8:	39 3c 24             	cmp    %edi,(%esp)
  801ecb:	0f 87 e7 00 00 00    	ja     801fb8 <__umoddi3+0x148>
  801ed1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ed5:	29 f1                	sub    %esi,%ecx
  801ed7:	19 c7                	sbb    %eax,%edi
  801ed9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801edd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ee1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ee5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ee9:	83 c4 14             	add    $0x14,%esp
  801eec:	5e                   	pop    %esi
  801eed:	5f                   	pop    %edi
  801eee:	5d                   	pop    %ebp
  801eef:	c3                   	ret    
  801ef0:	85 f6                	test   %esi,%esi
  801ef2:	89 f5                	mov    %esi,%ebp
  801ef4:	75 0b                	jne    801f01 <__umoddi3+0x91>
  801ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	f7 f6                	div    %esi
  801eff:	89 c5                	mov    %eax,%ebp
  801f01:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f05:	31 d2                	xor    %edx,%edx
  801f07:	f7 f5                	div    %ebp
  801f09:	89 c8                	mov    %ecx,%eax
  801f0b:	f7 f5                	div    %ebp
  801f0d:	eb 9c                	jmp    801eab <__umoddi3+0x3b>
  801f0f:	90                   	nop
  801f10:	89 c8                	mov    %ecx,%eax
  801f12:	89 fa                	mov    %edi,%edx
  801f14:	83 c4 14             	add    $0x14,%esp
  801f17:	5e                   	pop    %esi
  801f18:	5f                   	pop    %edi
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    
  801f1b:	90                   	nop
  801f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f20:	8b 04 24             	mov    (%esp),%eax
  801f23:	be 20 00 00 00       	mov    $0x20,%esi
  801f28:	89 e9                	mov    %ebp,%ecx
  801f2a:	29 ee                	sub    %ebp,%esi
  801f2c:	d3 e2                	shl    %cl,%edx
  801f2e:	89 f1                	mov    %esi,%ecx
  801f30:	d3 e8                	shr    %cl,%eax
  801f32:	89 e9                	mov    %ebp,%ecx
  801f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f38:	8b 04 24             	mov    (%esp),%eax
  801f3b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f3f:	89 fa                	mov    %edi,%edx
  801f41:	d3 e0                	shl    %cl,%eax
  801f43:	89 f1                	mov    %esi,%ecx
  801f45:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f49:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f4d:	d3 ea                	shr    %cl,%edx
  801f4f:	89 e9                	mov    %ebp,%ecx
  801f51:	d3 e7                	shl    %cl,%edi
  801f53:	89 f1                	mov    %esi,%ecx
  801f55:	d3 e8                	shr    %cl,%eax
  801f57:	89 e9                	mov    %ebp,%ecx
  801f59:	09 f8                	or     %edi,%eax
  801f5b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f5f:	f7 74 24 04          	divl   0x4(%esp)
  801f63:	d3 e7                	shl    %cl,%edi
  801f65:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f69:	89 d7                	mov    %edx,%edi
  801f6b:	f7 64 24 08          	mull   0x8(%esp)
  801f6f:	39 d7                	cmp    %edx,%edi
  801f71:	89 c1                	mov    %eax,%ecx
  801f73:	89 14 24             	mov    %edx,(%esp)
  801f76:	72 2c                	jb     801fa4 <__umoddi3+0x134>
  801f78:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f7c:	72 22                	jb     801fa0 <__umoddi3+0x130>
  801f7e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f82:	29 c8                	sub    %ecx,%eax
  801f84:	19 d7                	sbb    %edx,%edi
  801f86:	89 e9                	mov    %ebp,%ecx
  801f88:	89 fa                	mov    %edi,%edx
  801f8a:	d3 e8                	shr    %cl,%eax
  801f8c:	89 f1                	mov    %esi,%ecx
  801f8e:	d3 e2                	shl    %cl,%edx
  801f90:	89 e9                	mov    %ebp,%ecx
  801f92:	d3 ef                	shr    %cl,%edi
  801f94:	09 d0                	or     %edx,%eax
  801f96:	89 fa                	mov    %edi,%edx
  801f98:	83 c4 14             	add    $0x14,%esp
  801f9b:	5e                   	pop    %esi
  801f9c:	5f                   	pop    %edi
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    
  801f9f:	90                   	nop
  801fa0:	39 d7                	cmp    %edx,%edi
  801fa2:	75 da                	jne    801f7e <__umoddi3+0x10e>
  801fa4:	8b 14 24             	mov    (%esp),%edx
  801fa7:	89 c1                	mov    %eax,%ecx
  801fa9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801fad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801fb1:	eb cb                	jmp    801f7e <__umoddi3+0x10e>
  801fb3:	90                   	nop
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801fbc:	0f 82 0f ff ff ff    	jb     801ed1 <__umoddi3+0x61>
  801fc2:	e9 1a ff ff ff       	jmp    801ee1 <__umoddi3+0x71>
