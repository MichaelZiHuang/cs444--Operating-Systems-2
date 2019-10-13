
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 16 01 00 00       	call   800147 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 bb 11 00 00       	call   8011fc <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 5e                	je     8000a6 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 02 0c 00 00       	call   800c55 <sys_getenvid>
  800053:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  800062:	e8 e4 01 00 00       	call   80024b <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800067:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006a:	e8 e6 0b 00 00       	call   800c55 <sys_getenvid>
  80006f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 9a 24 80 00 	movl   $0x80249a,(%esp)
  80007e:	e8 c8 01 00 00       	call   80024b <cprintf>
		ipc_send(who, 0, 0, 0);
  800083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008a:	00 
  80008b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009a:	00 
  80009b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009e:	89 04 24             	mov    %eax,(%esp)
  8000a1:	e8 e2 11 00 00       	call   801288 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 5f 11 00 00       	call   801220 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c1:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000c7:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000cd:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d5:	e8 7b 0b 00 00       	call   800c55 <sys_getenvid>
  8000da:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000de:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 b0 24 80 00 	movl   $0x8024b0,(%esp)
  8000f8:	e8 4e 01 00 00       	call   80024b <cprintf>
		if (val == 10)
  8000fd:	a1 08 40 80 00       	mov    0x804008,%eax
  800102:	83 f8 0a             	cmp    $0xa,%eax
  800105:	74 38                	je     80013f <umain+0x10c>
			return;
		++val;
  800107:	83 c0 01             	add    $0x1,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 56 11 00 00       	call   801288 <ipc_send>
		if (val == 10)
  800132:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
  800139:	0f 85 67 ff ff ff    	jne    8000a6 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 3c             	add    $0x3c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	83 ec 10             	sub    $0x10,%esp
  80014f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800152:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800155:	e8 fb 0a 00 00       	call   800c55 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  80015a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800162:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800167:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016c:	85 db                	test   %ebx,%ebx
  80016e:	7e 07                	jle    800177 <libmain+0x30>
		binaryname = argv[0];
  800170:	8b 06                	mov    (%esi),%eax
  800172:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800177:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017b:	89 1c 24             	mov    %ebx,(%esp)
  80017e:	e8 b0 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800183:	e8 07 00 00 00       	call   80018f <exit>
}
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800195:	e8 6b 13 00 00       	call   801505 <close_all>
	sys_env_destroy(0);
  80019a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a1:	e8 5d 0a 00 00       	call   800c03 <sys_env_destroy>
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 14             	sub    $0x14,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 13                	mov    (%ebx),%edx
  8001b4:	8d 42 01             	lea    0x1(%edx),%eax
  8001b7:	89 03                	mov    %eax,(%ebx)
  8001b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c5:	75 19                	jne    8001e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ce:	00 
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 ec 09 00 00       	call   800bc6 <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fa:	00 00 00 
	b.cnt = 0;
  8001fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800204:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	c7 04 24 a8 01 80 00 	movl   $0x8001a8,(%esp)
  800226:	e8 b3 01 00 00       	call   8003de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	e8 83 09 00 00       	call   800bc6 <sys_cputs>

	return b.cnt;
}
  800243:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800251:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 87 ff ff ff       	call   8001ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    
  800265:	66 90                	xchg   %ax,%ax
  800267:	66 90                	xchg   %ax,%ax
  800269:	66 90                	xchg   %ax,%ax
  80026b:	66 90                	xchg   %ax,%ax
  80026d:	66 90                	xchg   %ax,%ax
  80026f:	90                   	nop

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 c3                	mov    %eax,%ebx
  800289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80028c:	8b 45 10             	mov    0x10(%ebp),%eax
  80028f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800292:	b9 00 00 00 00       	mov    $0x0,%ecx
  800297:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029d:	39 d9                	cmp    %ebx,%ecx
  80029f:	72 05                	jb     8002a6 <printnum+0x36>
  8002a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a4:	77 69                	ja     80030f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ad:	83 ee 01             	sub    $0x1,%esi
  8002b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002c0:	89 c3                	mov    %eax,%ebx
  8002c2:	89 d6                	mov    %edx,%esi
  8002c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 0c 1f 00 00       	call   8021f0 <__udivdi3>
  8002e4:	89 d9                	mov    %ebx,%ecx
  8002e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f5:	89 fa                	mov    %edi,%edx
  8002f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fa:	e8 71 ff ff ff       	call   800270 <printnum>
  8002ff:	eb 1b                	jmp    80031c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	8b 45 18             	mov    0x18(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff d3                	call   *%ebx
  80030d:	eb 03                	jmp    800312 <printnum+0xa2>
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800312:	83 ee 01             	sub    $0x1,%esi
  800315:	85 f6                	test   %esi,%esi
  800317:	7f e8                	jg     800301 <printnum+0x91>
  800319:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800320:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800324:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800327:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033f:	e8 dc 1f 00 00       	call   802320 <__umoddi3>
  800344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800348:	0f be 80 e0 24 80 00 	movsbl 0x8024e0(%eax),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800355:	ff d0                	call   *%eax
}
  800357:	83 c4 3c             	add    $0x3c,%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800362:	83 fa 01             	cmp    $0x1,%edx
  800365:	7e 0e                	jle    800375 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	8b 52 04             	mov    0x4(%edx),%edx
  800373:	eb 22                	jmp    800397 <getuint+0x38>
	else if (lflag)
  800375:	85 d2                	test   %edx,%edx
  800377:	74 10                	je     800389 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 0e                	jmp    800397 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a8:	73 0a                	jae    8003b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b2:	88 02                	mov    %al,(%edx)
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <printfmt>:
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	e8 02 00 00 00       	call   8003de <vprintfmt>
}
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <vprintfmt>:
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	57                   	push   %edi
  8003e2:	56                   	push   %esi
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 3c             	sub    $0x3c,%esp
  8003e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ed:	eb 1f                	jmp    80040e <vprintfmt+0x30>
			if (ch == '\0'){
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	75 0f                	jne    800402 <vprintfmt+0x24>
				color = 0x0100;
  8003f3:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  8003fa:	01 00 00 
  8003fd:	e9 b3 03 00 00       	jmp    8007b5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800402:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040c:	89 f3                	mov    %esi,%ebx
  80040e:	8d 73 01             	lea    0x1(%ebx),%esi
  800411:	0f b6 03             	movzbl (%ebx),%eax
  800414:	83 f8 25             	cmp    $0x25,%eax
  800417:	75 d6                	jne    8003ef <vprintfmt+0x11>
  800419:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80041d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800424:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80042b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800432:	ba 00 00 00 00       	mov    $0x0,%edx
  800437:	eb 1d                	jmp    800456 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800439:	89 de                	mov    %ebx,%esi
			padc = '-';
  80043b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80043f:	eb 15                	jmp    800456 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800441:	89 de                	mov    %ebx,%esi
			padc = '0';
  800443:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800447:	eb 0d                	jmp    800456 <vprintfmt+0x78>
				width = precision, precision = -1;
  800449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80044c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80044f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8d 5e 01             	lea    0x1(%esi),%ebx
  800459:	0f b6 0e             	movzbl (%esi),%ecx
  80045c:	0f b6 c1             	movzbl %cl,%eax
  80045f:	83 e9 23             	sub    $0x23,%ecx
  800462:	80 f9 55             	cmp    $0x55,%cl
  800465:	0f 87 2a 03 00 00    	ja     800795 <vprintfmt+0x3b7>
  80046b:	0f b6 c9             	movzbl %cl,%ecx
  80046e:	ff 24 8d 20 26 80 00 	jmp    *0x802620(,%ecx,4)
  800475:	89 de                	mov    %ebx,%esi
  800477:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80047c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80047f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800483:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800486:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800489:	83 fb 09             	cmp    $0x9,%ebx
  80048c:	77 36                	ja     8004c4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80048e:	83 c6 01             	add    $0x1,%esi
			}
  800491:	eb e9                	jmp    80047c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 48 04             	lea    0x4(%eax),%ecx
  800499:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80049c:	8b 00                	mov    (%eax),%eax
  80049e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004a3:	eb 22                	jmp    8004c7 <vprintfmt+0xe9>
  8004a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004a8:	85 c9                	test   %ecx,%ecx
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	0f 49 c1             	cmovns %ecx,%eax
  8004b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	89 de                	mov    %ebx,%esi
  8004b7:	eb 9d                	jmp    800456 <vprintfmt+0x78>
  8004b9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004bb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004c2:	eb 92                	jmp    800456 <vprintfmt+0x78>
  8004c4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8004c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004cb:	79 89                	jns    800456 <vprintfmt+0x78>
  8004cd:	e9 77 ff ff ff       	jmp    800449 <vprintfmt+0x6b>
			lflag++;
  8004d2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004d7:	e9 7a ff ff ff       	jmp    800456 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f1:	e9 18 ff ff ff       	jmp    80040e <vprintfmt+0x30>
			err = va_arg(ap, int);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	99                   	cltd   
  800502:	31 d0                	xor    %edx,%eax
  800504:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800506:	83 f8 0f             	cmp    $0xf,%eax
  800509:	7f 0b                	jg     800516 <vprintfmt+0x138>
  80050b:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800512:	85 d2                	test   %edx,%edx
  800514:	75 20                	jne    800536 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800516:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051a:	c7 44 24 08 f8 24 80 	movl   $0x8024f8,0x8(%esp)
  800521:	00 
  800522:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 85 fe ff ff       	call   8003b6 <printfmt>
  800531:	e9 d8 fe ff ff       	jmp    80040e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800536:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053a:	c7 44 24 08 5a 2a 80 	movl   $0x802a5a,0x8(%esp)
  800541:	00 
  800542:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	89 04 24             	mov    %eax,(%esp)
  80054c:	e8 65 fe ff ff       	call   8003b6 <printfmt>
  800551:	e9 b8 fe ff ff       	jmp    80040e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800559:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80055c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80056a:	85 f6                	test   %esi,%esi
  80056c:	b8 f1 24 80 00       	mov    $0x8024f1,%eax
  800571:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800574:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800578:	0f 84 97 00 00 00    	je     800615 <vprintfmt+0x237>
  80057e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800582:	0f 8e 9b 00 00 00    	jle    800623 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800588:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80058c:	89 34 24             	mov    %esi,(%esp)
  80058f:	e8 c4 02 00 00       	call   800858 <strnlen>
  800594:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800597:	29 c2                	sub    %eax,%edx
  800599:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80059c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005ac:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ae:	eb 0f                	jmp    8005bf <vprintfmt+0x1e1>
					putch(padc, putdat);
  8005b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bc:	83 eb 01             	sub    $0x1,%ebx
  8005bf:	85 db                	test   %ebx,%ebx
  8005c1:	7f ed                	jg     8005b0 <vprintfmt+0x1d2>
  8005c3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005c6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005c9:	85 d2                	test   %edx,%edx
  8005cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d0:	0f 49 c2             	cmovns %edx,%eax
  8005d3:	29 c2                	sub    %eax,%edx
  8005d5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005d8:	89 d7                	mov    %edx,%edi
  8005da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005dd:	eb 50                	jmp    80062f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8005df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e3:	74 1e                	je     800603 <vprintfmt+0x225>
  8005e5:	0f be d2             	movsbl %dl,%edx
  8005e8:	83 ea 20             	sub    $0x20,%edx
  8005eb:	83 fa 5e             	cmp    $0x5e,%edx
  8005ee:	76 13                	jbe    800603 <vprintfmt+0x225>
					putch('?', putdat);
  8005f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005fe:	ff 55 08             	call   *0x8(%ebp)
  800601:	eb 0d                	jmp    800610 <vprintfmt+0x232>
					putch(ch, putdat);
  800603:	8b 55 0c             	mov    0xc(%ebp),%edx
  800606:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800610:	83 ef 01             	sub    $0x1,%edi
  800613:	eb 1a                	jmp    80062f <vprintfmt+0x251>
  800615:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800618:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80061b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80061e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800621:	eb 0c                	jmp    80062f <vprintfmt+0x251>
  800623:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800626:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800629:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80062c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80062f:	83 c6 01             	add    $0x1,%esi
  800632:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800636:	0f be c2             	movsbl %dl,%eax
  800639:	85 c0                	test   %eax,%eax
  80063b:	74 27                	je     800664 <vprintfmt+0x286>
  80063d:	85 db                	test   %ebx,%ebx
  80063f:	78 9e                	js     8005df <vprintfmt+0x201>
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	79 99                	jns    8005df <vprintfmt+0x201>
  800646:	89 f8                	mov    %edi,%eax
  800648:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80064b:	8b 75 08             	mov    0x8(%ebp),%esi
  80064e:	89 c3                	mov    %eax,%ebx
  800650:	eb 1a                	jmp    80066c <vprintfmt+0x28e>
				putch(' ', putdat);
  800652:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800656:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80065f:	83 eb 01             	sub    $0x1,%ebx
  800662:	eb 08                	jmp    80066c <vprintfmt+0x28e>
  800664:	89 fb                	mov    %edi,%ebx
  800666:	8b 75 08             	mov    0x8(%ebp),%esi
  800669:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80066c:	85 db                	test   %ebx,%ebx
  80066e:	7f e2                	jg     800652 <vprintfmt+0x274>
  800670:	89 75 08             	mov    %esi,0x8(%ebp)
  800673:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800676:	e9 93 fd ff ff       	jmp    80040e <vprintfmt+0x30>
	if (lflag >= 2)
  80067b:	83 fa 01             	cmp    $0x1,%edx
  80067e:	7e 16                	jle    800696 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 08             	lea    0x8(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 50 04             	mov    0x4(%eax),%edx
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800691:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800694:	eb 32                	jmp    8006c8 <vprintfmt+0x2ea>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 18                	je     8006b2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a3:	8b 30                	mov    (%eax),%esi
  8006a5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006a8:	89 f0                	mov    %esi,%eax
  8006aa:	c1 f8 1f             	sar    $0x1f,%eax
  8006ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b0:	eb 16                	jmp    8006c8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 30                	mov    (%eax),%esi
  8006bd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006c0:	89 f0                	mov    %esi,%eax
  8006c2:	c1 f8 1f             	sar    $0x1f,%eax
  8006c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8006c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8006ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d7:	0f 89 80 00 00 00    	jns    80075d <vprintfmt+0x37f>
				putch('-', putdat);
  8006dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006e8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f1:	f7 d8                	neg    %eax
  8006f3:	83 d2 00             	adc    $0x0,%edx
  8006f6:	f7 da                	neg    %edx
			base = 10;
  8006f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006fd:	eb 5e                	jmp    80075d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	e8 58 fc ff ff       	call   80035f <getuint>
			base = 10;
  800707:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80070c:	eb 4f                	jmp    80075d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
  800711:	e8 49 fc ff ff       	call   80035f <getuint>
            base = 8;
  800716:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80071b:	eb 40                	jmp    80075d <vprintfmt+0x37f>
			putch('0', putdat);
  80071d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800721:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800728:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80072b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800736:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8d 50 04             	lea    0x4(%eax),%edx
  80073f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800742:	8b 00                	mov    (%eax),%eax
  800744:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800749:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80074e:	eb 0d                	jmp    80075d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800750:	8d 45 14             	lea    0x14(%ebp),%eax
  800753:	e8 07 fc ff ff       	call   80035f <getuint>
			base = 16;
  800758:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80075d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800761:	89 74 24 10          	mov    %esi,0x10(%esp)
  800765:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800768:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80076c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800770:	89 04 24             	mov    %eax,(%esp)
  800773:	89 54 24 04          	mov    %edx,0x4(%esp)
  800777:	89 fa                	mov    %edi,%edx
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	e8 ef fa ff ff       	call   800270 <printnum>
			break;
  800781:	e9 88 fc ff ff       	jmp    80040e <vprintfmt+0x30>
			putch(ch, putdat);
  800786:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078a:	89 04 24             	mov    %eax,(%esp)
  80078d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800790:	e9 79 fc ff ff       	jmp    80040e <vprintfmt+0x30>
			putch('%', putdat);
  800795:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800799:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a3:	89 f3                	mov    %esi,%ebx
  8007a5:	eb 03                	jmp    8007aa <vprintfmt+0x3cc>
  8007a7:	83 eb 01             	sub    $0x1,%ebx
  8007aa:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007ae:	75 f7                	jne    8007a7 <vprintfmt+0x3c9>
  8007b0:	e9 59 fc ff ff       	jmp    80040e <vprintfmt+0x30>
}
  8007b5:	83 c4 3c             	add    $0x3c,%esp
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5f                   	pop    %edi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 28             	sub    $0x28,%esp
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007da:	85 c0                	test   %eax,%eax
  8007dc:	74 30                	je     80080e <vsnprintf+0x51>
  8007de:	85 d2                	test   %edx,%edx
  8007e0:	7e 2c                	jle    80080e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f7:	c7 04 24 99 03 80 00 	movl   $0x800399,(%esp)
  8007fe:	e8 db fb ff ff       	call   8003de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800803:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800806:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800809:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080c:	eb 05                	jmp    800813 <vsnprintf+0x56>
		return -E_INVAL;
  80080e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800822:	8b 45 10             	mov    0x10(%ebp),%eax
  800825:	89 44 24 08          	mov    %eax,0x8(%esp)
  800829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 82 ff ff ff       	call   8007bd <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    
  80083d:	66 90                	xchg   %ax,%ax
  80083f:	90                   	nop

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	eb 03                	jmp    800850 <strlen+0x10>
		n++;
  80084d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800850:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800854:	75 f7                	jne    80084d <strlen+0xd>
	return n;
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strnlen+0x13>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086b:	39 d0                	cmp    %edx,%eax
  80086d:	74 06                	je     800875 <strnlen+0x1d>
  80086f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800873:	75 f3                	jne    800868 <strnlen+0x10>
	return n;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800881:	89 c2                	mov    %eax,%edx
  800883:	83 c2 01             	add    $0x1,%edx
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800890:	84 db                	test   %bl,%bl
  800892:	75 ef                	jne    800883 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800894:	5b                   	pop    %ebx
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a1:	89 1c 24             	mov    %ebx,(%esp)
  8008a4:	e8 97 ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b0:	01 d8                	add    %ebx,%eax
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	e8 bd ff ff ff       	call   800877 <strcpy>
	return dst;
}
  8008ba:	89 d8                	mov    %ebx,%eax
  8008bc:	83 c4 08             	add    $0x8,%esp
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	89 f3                	mov    %esi,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	eb 0f                	jmp    8008e5 <strncpy+0x23>
		*dst++ = *src;
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008df:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008e5:	39 da                	cmp    %ebx,%edx
  8008e7:	75 ed                	jne    8008d6 <strncpy+0x14>
	}
	return ret;
}
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800903:	85 c9                	test   %ecx,%ecx
  800905:	75 0b                	jne    800912 <strlcpy+0x23>
  800907:	eb 1d                	jmp    800926 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	83 c2 01             	add    $0x1,%edx
  80090f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800912:	39 d8                	cmp    %ebx,%eax
  800914:	74 0b                	je     800921 <strlcpy+0x32>
  800916:	0f b6 0a             	movzbl (%edx),%ecx
  800919:	84 c9                	test   %cl,%cl
  80091b:	75 ec                	jne    800909 <strlcpy+0x1a>
  80091d:	89 c2                	mov    %eax,%edx
  80091f:	eb 02                	jmp    800923 <strlcpy+0x34>
  800921:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800923:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800926:	29 f0                	sub    %esi,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800935:	eb 06                	jmp    80093d <strcmp+0x11>
		p++, q++;
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80093d:	0f b6 01             	movzbl (%ecx),%eax
  800940:	84 c0                	test   %al,%al
  800942:	74 04                	je     800948 <strcmp+0x1c>
  800944:	3a 02                	cmp    (%edx),%al
  800946:	74 ef                	je     800937 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 c0             	movzbl %al,%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	53                   	push   %ebx
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	89 c3                	mov    %eax,%ebx
  80095e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800961:	eb 06                	jmp    800969 <strncmp+0x17>
		n--, p++, q++;
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800969:	39 d8                	cmp    %ebx,%eax
  80096b:	74 15                	je     800982 <strncmp+0x30>
  80096d:	0f b6 08             	movzbl (%eax),%ecx
  800970:	84 c9                	test   %cl,%cl
  800972:	74 04                	je     800978 <strncmp+0x26>
  800974:	3a 0a                	cmp    (%edx),%cl
  800976:	74 eb                	je     800963 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 00             	movzbl (%eax),%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
  800980:	eb 05                	jmp    800987 <strncmp+0x35>
		return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800994:	eb 07                	jmp    80099d <strchr+0x13>
		if (*s == c)
  800996:	38 ca                	cmp    %cl,%dl
  800998:	74 0f                	je     8009a9 <strchr+0x1f>
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f2                	jne    800996 <strchr+0xc>
			return (char *) s;
	return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	eb 07                	jmp    8009be <strfind+0x13>
		if (*s == c)
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	74 0a                	je     8009c5 <strfind+0x1a>
	for (; *s; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	0f b6 10             	movzbl (%eax),%edx
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	75 f2                	jne    8009b7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	74 36                	je     800a0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009dd:	75 28                	jne    800a07 <memset+0x40>
  8009df:	f6 c1 03             	test   $0x3,%cl
  8009e2:	75 23                	jne    800a07 <memset+0x40>
		c &= 0xFF;
  8009e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e8:	89 d3                	mov    %edx,%ebx
  8009ea:	c1 e3 08             	shl    $0x8,%ebx
  8009ed:	89 d6                	mov    %edx,%esi
  8009ef:	c1 e6 18             	shl    $0x18,%esi
  8009f2:	89 d0                	mov    %edx,%eax
  8009f4:	c1 e0 10             	shl    $0x10,%eax
  8009f7:	09 f0                	or     %esi,%eax
  8009f9:	09 c2                	or     %eax,%edx
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a02:	fc                   	cld    
  800a03:	f3 ab                	rep stos %eax,%es:(%edi)
  800a05:	eb 06                	jmp    800a0d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a22:	39 c6                	cmp    %eax,%esi
  800a24:	73 35                	jae    800a5b <memmove+0x47>
  800a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a29:	39 d0                	cmp    %edx,%eax
  800a2b:	73 2e                	jae    800a5b <memmove+0x47>
		s += n;
		d += n;
  800a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a30:	89 d6                	mov    %edx,%esi
  800a32:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3a:	75 13                	jne    800a4f <memmove+0x3b>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 0e                	jne    800a4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a41:	83 ef 04             	sub    $0x4,%edi
  800a44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a47:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4d:	eb 09                	jmp    800a58 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a4f:	83 ef 01             	sub    $0x1,%edi
  800a52:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a55:	fd                   	std    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a58:	fc                   	cld    
  800a59:	eb 1d                	jmp    800a78 <memmove+0x64>
  800a5b:	89 f2                	mov    %esi,%edx
  800a5d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5f:	f6 c2 03             	test   $0x3,%dl
  800a62:	75 0f                	jne    800a73 <memmove+0x5f>
  800a64:	f6 c1 03             	test   $0x3,%cl
  800a67:	75 0a                	jne    800a73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a69:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a71:	eb 05                	jmp    800a78 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	fc                   	cld    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a82:	8b 45 10             	mov    0x10(%ebp),%eax
  800a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 79 ff ff ff       	call   800a14 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aad:	eb 1a                	jmp    800ac9 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaf:	0f b6 02             	movzbl (%edx),%eax
  800ab2:	0f b6 19             	movzbl (%ecx),%ebx
  800ab5:	38 d8                	cmp    %bl,%al
  800ab7:	74 0a                	je     800ac3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 0f                	jmp    800ad2 <memcmp+0x35>
		s1++, s2++;
  800ac3:	83 c2 01             	add    $0x1,%edx
  800ac6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800ac9:	39 f2                	cmp    %esi,%edx
  800acb:	75 e2                	jne    800aaf <memcmp+0x12>
	}

	return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae4:	eb 07                	jmp    800aed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	38 08                	cmp    %cl,(%eax)
  800ae8:	74 07                	je     800af1 <memfind+0x1b>
	for (; s < ends; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	39 d0                	cmp    %edx,%eax
  800aef:	72 f5                	jb     800ae6 <memfind+0x10>
			break;
	return (void *) s;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
		s++;
  800b01:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b04:	0f b6 0a             	movzbl (%edx),%ecx
  800b07:	80 f9 09             	cmp    $0x9,%cl
  800b0a:	74 f5                	je     800b01 <strtol+0xe>
  800b0c:	80 f9 20             	cmp    $0x20,%cl
  800b0f:	74 f0                	je     800b01 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b11:	80 f9 2b             	cmp    $0x2b,%cl
  800b14:	75 0a                	jne    800b20 <strtol+0x2d>
		s++;
  800b16:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	eb 11                	jmp    800b31 <strtol+0x3e>
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b25:	80 f9 2d             	cmp    $0x2d,%cl
  800b28:	75 07                	jne    800b31 <strtol+0x3e>
		s++, neg = 1;
  800b2a:	8d 52 01             	lea    0x1(%edx),%edx
  800b2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b36:	75 15                	jne    800b4d <strtol+0x5a>
  800b38:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3b:	75 10                	jne    800b4d <strtol+0x5a>
  800b3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b41:	75 0a                	jne    800b4d <strtol+0x5a>
		s += 2, base = 16;
  800b43:	83 c2 02             	add    $0x2,%edx
  800b46:	b8 10 00 00 00       	mov    $0x10,%eax
  800b4b:	eb 10                	jmp    800b5d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	75 0c                	jne    800b5d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b51:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b53:	80 3a 30             	cmpb   $0x30,(%edx)
  800b56:	75 05                	jne    800b5d <strtol+0x6a>
		s++, base = 8;
  800b58:	83 c2 01             	add    $0x1,%edx
  800b5b:	b0 08                	mov    $0x8,%al
		base = 10;
  800b5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b62:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b65:	0f b6 0a             	movzbl (%edx),%ecx
  800b68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b6b:	89 f0                	mov    %esi,%eax
  800b6d:	3c 09                	cmp    $0x9,%al
  800b6f:	77 08                	ja     800b79 <strtol+0x86>
			dig = *s - '0';
  800b71:	0f be c9             	movsbl %cl,%ecx
  800b74:	83 e9 30             	sub    $0x30,%ecx
  800b77:	eb 20                	jmp    800b99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b7c:	89 f0                	mov    %esi,%eax
  800b7e:	3c 19                	cmp    $0x19,%al
  800b80:	77 08                	ja     800b8a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b82:	0f be c9             	movsbl %cl,%ecx
  800b85:	83 e9 57             	sub    $0x57,%ecx
  800b88:	eb 0f                	jmp    800b99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	3c 19                	cmp    $0x19,%al
  800b91:	77 16                	ja     800ba9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b93:	0f be c9             	movsbl %cl,%ecx
  800b96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b9c:	7d 0f                	jge    800bad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ba5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ba7:	eb bc                	jmp    800b65 <strtol+0x72>
  800ba9:	89 d8                	mov    %ebx,%eax
  800bab:	eb 02                	jmp    800baf <strtol+0xbc>
  800bad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800baf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb3:	74 05                	je     800bba <strtol+0xc7>
		*endptr = (char *) s;
  800bb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bba:	f7 d8                	neg    %eax
  800bbc:	85 ff                	test   %edi,%edi
  800bbe:	0f 44 c3             	cmove  %ebx,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 c3                	mov    %eax,%ebx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	89 c6                	mov    %eax,%esi
  800bdd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c11:	b8 03 00 00 00       	mov    $0x3,%eax
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 cb                	mov    %ecx,%ebx
  800c1b:	89 cf                	mov    %ecx,%edi
  800c1d:	89 ce                	mov    %ecx,%esi
  800c1f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800c48:	e8 59 14 00 00       	call   8020a6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 02 00 00 00       	mov    $0x2,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_yield>:

void
sys_yield(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ca1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800cda:	e8 c7 13 00 00       	call   8020a6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cf0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	8b 75 18             	mov    0x18(%ebp),%esi
  800d04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800d2d:	e8 74 13 00 00       	call   8020a6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800d80:	e8 21 13 00 00       	call   8020a6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800dd3:	e8 ce 12 00 00       	call   8020a6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	b8 09 00 00 00       	mov    $0x9,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 28                	jle    800e2b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e07:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800e26:	e8 7b 12 00 00       	call   8020a6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e2b:	83 c4 2c             	add    $0x2c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7e 28                	jle    800e7e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e61:	00 
  800e62:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800e79:	e8 28 12 00 00       	call   8020a6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7e:	83 c4 2c             	add    $0x2c,%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	89 ce                	mov    %ecx,%esi
  800ec5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 28                	jle    800ef3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800eee:	e8 b3 11 00 00       	call   8020a6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef3:	83 c4 2c             	add    $0x2c,%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    
  800efb:	66 90                	xchg   %ax,%ax
  800efd:	66 90                	xchg   %ax,%ax
  800eff:	90                   	nop

00800f00 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	53                   	push   %ebx
  800f04:	83 ec 24             	sub    $0x24,%esp
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  800f0a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  800f0c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f10:	74 18                	je     800f2a <pgfault+0x2a>
  800f12:	89 d8                	mov    %ebx,%eax
  800f14:	c1 e8 0c             	shr    $0xc,%eax
  800f17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1e:	25 05 08 00 00       	and    $0x805,%eax
  800f23:	3d 05 08 00 00       	cmp    $0x805,%eax
  800f28:	74 1c                	je     800f46 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  800f2a:	c7 44 24 08 0c 28 80 	movl   $0x80280c,0x8(%esp)
  800f31:	00 
  800f32:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f39:	00 
  800f3a:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  800f41:	e8 60 11 00 00       	call   8020a6 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  800f46:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f55:	00 
  800f56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5d:	e8 31 fd ff ff       	call   800c93 <sys_page_alloc>
	if(r < 0){
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 1c                	jns    800f82 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  800f66:	c7 44 24 08 3c 28 80 	movl   $0x80283c,0x8(%esp)
  800f6d:	00 
  800f6e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800f75:	00 
  800f76:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  800f7d:	e8 24 11 00 00       	call   8020a6 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f82:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f88:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f8f:	00 
  800f90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f94:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f9b:	e8 dc fa ff ff       	call   800a7c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  800fa0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fa7:	00 
  800fa8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fbb:	00 
  800fbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc3:	e8 1f fd ff ff       	call   800ce7 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 1c                	jns    800fe8 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  800fcc:	c7 44 24 08 08 29 80 	movl   $0x802908,0x8(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800fdb:	00 
  800fdc:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  800fe3:	e8 be 10 00 00       	call   8020a6 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  800fe8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fef:	00 
  800ff0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff7:	e8 3e fd ff ff       	call   800d3a <sys_page_unmap>
    if(r < 0){
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	79 1c                	jns    80101c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  801000:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  801007:	00 
  801008:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80100f:	00 
  801010:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801017:	e8 8a 10 00 00       	call   8020a6 <_panic>
    }
    // LAB 4
}
  80101c:	83 c4 24             	add    $0x24,%esp
  80101f:	5b                   	pop    %ebx
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  80102b:	c7 04 24 00 0f 80 00 	movl   $0x800f00,(%esp)
  801032:	e8 c5 10 00 00       	call   8020fc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801037:	b8 07 00 00 00       	mov    $0x7,%eax
  80103c:	cd 30                	int    $0x30
  80103e:	89 c7                	mov    %eax,%edi
  801040:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801043:	85 c0                	test   %eax,%eax
  801045:	79 1c                	jns    801063 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801047:	c7 44 24 08 38 29 80 	movl   $0x802938,0x8(%esp)
  80104e:	00 
  80104f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801056:	00 
  801057:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  80105e:	e8 43 10 00 00       	call   8020a6 <_panic>
    }
    if(child == 0){
  801063:	bb 00 00 00 00       	mov    $0x0,%ebx
  801068:	85 c0                	test   %eax,%eax
  80106a:	75 21                	jne    80108d <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80106c:	e8 e4 fb ff ff       	call   800c55 <sys_getenvid>
  801071:	25 ff 03 00 00       	and    $0x3ff,%eax
  801076:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80107e:	a3 0c 40 80 00       	mov    %eax,0x80400c
        // It's a whole lot like lab3 with the env stuff
        return 0;
  801083:	b8 00 00 00 00       	mov    $0x0,%eax
  801088:	e9 67 01 00 00       	jmp    8011f4 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  80108d:	89 d8                	mov    %ebx,%eax
  80108f:	c1 e8 16             	shr    $0x16,%eax
  801092:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801099:	a8 01                	test   $0x1,%al
  80109b:	74 4b                	je     8010e8 <fork+0xc6>
  80109d:	89 de                	mov    %ebx,%esi
  80109f:	c1 ee 0c             	shr    $0xc,%esi
  8010a2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a9:	a8 01                	test   $0x1,%al
  8010ab:	74 3b                	je     8010e8 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  8010ad:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b4:	a9 02 08 00 00       	test   $0x802,%eax
  8010b9:	0f 85 02 01 00 00    	jne    8011c1 <fork+0x19f>
  8010bf:	e9 d2 00 00 00       	jmp    801196 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  8010c4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010cb:	00 
  8010cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010d7:	00 
  8010d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e3:	e8 ff fb ff ff       	call   800ce7 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  8010e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ee:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010f4:	75 97                	jne    80108d <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  8010f6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801105:	ee 
  801106:	89 3c 24             	mov    %edi,(%esp)
  801109:	e8 85 fb ff ff       	call   800c93 <sys_page_alloc>

    if(r < 0){
  80110e:	85 c0                	test   %eax,%eax
  801110:	79 1c                	jns    80112e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801112:	c7 44 24 08 70 28 80 	movl   $0x802870,0x8(%esp)
  801119:	00 
  80111a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801121:	00 
  801122:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801129:	e8 78 0f 00 00       	call   8020a6 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80112e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801133:	8b 40 64             	mov    0x64(%eax),%eax
  801136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113a:	89 3c 24             	mov    %edi,(%esp)
  80113d:	e8 f1 fc ff ff       	call   800e33 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801142:	85 c0                	test   %eax,%eax
  801144:	79 1c                	jns    801162 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801146:	c7 44 24 08 90 28 80 	movl   $0x802890,0x8(%esp)
  80114d:	00 
  80114e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801155:	00 
  801156:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  80115d:	e8 44 0f 00 00       	call   8020a6 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801162:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801169:	00 
  80116a:	89 3c 24             	mov    %edi,(%esp)
  80116d:	e8 1b fc ff ff       	call   800d8d <sys_env_set_status>
    if(r < 0){
  801172:	85 c0                	test   %eax,%eax
  801174:	79 1c                	jns    801192 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801176:	c7 44 24 08 b8 28 80 	movl   $0x8028b8,0x8(%esp)
  80117d:	00 
  80117e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  801185:	00 
  801186:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  80118d:	e8 14 0f 00 00       	call   8020a6 <_panic>
    }
    return child;
  801192:	89 f8                	mov    %edi,%eax
  801194:	eb 5e                	jmp    8011f4 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  801196:	c1 e6 0c             	shl    $0xc,%esi
  801199:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011a0:	00 
  8011a1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b7:	e8 2b fb ff ff       	call   800ce7 <sys_page_map>
  8011bc:	e9 27 ff ff ff       	jmp    8010e8 <fork+0xc6>
  8011c1:	c1 e6 0c             	shl    $0xc,%esi
  8011c4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011cb:	00 
  8011cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e2:	e8 00 fb ff ff       	call   800ce7 <sys_page_map>
    if( r < 0 ){
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	0f 89 d5 fe ff ff    	jns    8010c4 <fork+0xa2>
  8011ef:	e9 f4 fe ff ff       	jmp    8010e8 <fork+0xc6>
//	panic("fork not implemented");
}
  8011f4:	83 c4 2c             	add    $0x2c,%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5f                   	pop    %edi
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <sfork>:

// Challenge!
int
sfork(void)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801202:	c7 44 24 08 55 29 80 	movl   $0x802955,0x8(%esp)
  801209:	00 
  80120a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801211:	00 
  801212:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801219:	e8 88 0e 00 00       	call   8020a6 <_panic>
  80121e:	66 90                	xchg   %ax,%ax

00801220 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	83 ec 10             	sub    $0x10,%esp
  801228:	8b 75 08             	mov    0x8(%ebp),%esi
  80122b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801231:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801233:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801238:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80123b:	89 04 24             	mov    %eax,(%esp)
  80123e:	e8 66 fc ff ff       	call   800ea9 <sys_ipc_recv>
    if(r < 0){
  801243:	85 c0                	test   %eax,%eax
  801245:	79 16                	jns    80125d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801247:	85 f6                	test   %esi,%esi
  801249:	74 06                	je     801251 <ipc_recv+0x31>
            *from_env_store = 0;
  80124b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801251:	85 db                	test   %ebx,%ebx
  801253:	74 2c                	je     801281 <ipc_recv+0x61>
            *perm_store = 0;
  801255:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80125b:	eb 24                	jmp    801281 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80125d:	85 f6                	test   %esi,%esi
  80125f:	74 0a                	je     80126b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801261:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801266:	8b 40 74             	mov    0x74(%eax),%eax
  801269:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80126b:	85 db                	test   %ebx,%ebx
  80126d:	74 0a                	je     801279 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80126f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801274:	8b 40 78             	mov    0x78(%eax),%eax
  801277:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801279:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80127e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	5b                   	pop    %ebx
  801285:	5e                   	pop    %esi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 1c             	sub    $0x1c,%esp
  801291:	8b 7d 08             	mov    0x8(%ebp),%edi
  801294:	8b 75 0c             	mov    0xc(%ebp),%esi
  801297:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80129a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80129c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8012a1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8012a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012b3:	89 3c 24             	mov    %edi,(%esp)
  8012b6:	e8 cb fb ff ff       	call   800e86 <sys_ipc_try_send>
        if(r == 0){
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	74 28                	je     8012e7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8012bf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012c2:	74 1c                	je     8012e0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8012c4:	c7 44 24 08 6b 29 80 	movl   $0x80296b,0x8(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8012d3:	00 
  8012d4:	c7 04 24 82 29 80 00 	movl   $0x802982,(%esp)
  8012db:	e8 c6 0d 00 00       	call   8020a6 <_panic>
        }
        sys_yield();
  8012e0:	e8 8f f9 ff ff       	call   800c74 <sys_yield>
    }
  8012e5:	eb bd                	jmp    8012a4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8012e7:	83 c4 1c             	add    $0x1c,%esp
  8012ea:	5b                   	pop    %ebx
  8012eb:	5e                   	pop    %esi
  8012ec:	5f                   	pop    %edi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012f5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012fa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012fd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801303:	8b 52 50             	mov    0x50(%edx),%edx
  801306:	39 ca                	cmp    %ecx,%edx
  801308:	75 0d                	jne    801317 <ipc_find_env+0x28>
			return envs[i].env_id;
  80130a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80130d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801312:	8b 40 40             	mov    0x40(%eax),%eax
  801315:	eb 0e                	jmp    801325 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801317:	83 c0 01             	add    $0x1,%eax
  80131a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80131f:	75 d9                	jne    8012fa <ipc_find_env+0xb>
	return 0;
  801321:	66 b8 00 00          	mov    $0x0,%ax
}
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    
  801327:	66 90                	xchg   %ax,%ax
  801329:	66 90                	xchg   %ax,%ax
  80132b:	66 90                	xchg   %ax,%ax
  80132d:	66 90                	xchg   %ax,%ax
  80132f:	90                   	nop

00801330 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
  801336:	05 00 00 00 30       	add    $0x30000000,%eax
  80133b:	c1 e8 0c             	shr    $0xc,%eax
}
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
  801346:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80134b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801350:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    

00801357 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801362:	89 c2                	mov    %eax,%edx
  801364:	c1 ea 16             	shr    $0x16,%edx
  801367:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80136e:	f6 c2 01             	test   $0x1,%dl
  801371:	74 11                	je     801384 <fd_alloc+0x2d>
  801373:	89 c2                	mov    %eax,%edx
  801375:	c1 ea 0c             	shr    $0xc,%edx
  801378:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137f:	f6 c2 01             	test   $0x1,%dl
  801382:	75 09                	jne    80138d <fd_alloc+0x36>
			*fd_store = fd;
  801384:	89 01                	mov    %eax,(%ecx)
			return 0;
  801386:	b8 00 00 00 00       	mov    $0x0,%eax
  80138b:	eb 17                	jmp    8013a4 <fd_alloc+0x4d>
  80138d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801392:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801397:	75 c9                	jne    801362 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801399:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80139f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013ac:	83 f8 1f             	cmp    $0x1f,%eax
  8013af:	77 36                	ja     8013e7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013b1:	c1 e0 0c             	shl    $0xc,%eax
  8013b4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	c1 ea 16             	shr    $0x16,%edx
  8013be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013c5:	f6 c2 01             	test   $0x1,%dl
  8013c8:	74 24                	je     8013ee <fd_lookup+0x48>
  8013ca:	89 c2                	mov    %eax,%edx
  8013cc:	c1 ea 0c             	shr    $0xc,%edx
  8013cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013d6:	f6 c2 01             	test   $0x1,%dl
  8013d9:	74 1a                	je     8013f5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013de:	89 02                	mov    %eax,(%edx)
	return 0;
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e5:	eb 13                	jmp    8013fa <fd_lookup+0x54>
		return -E_INVAL;
  8013e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ec:	eb 0c                	jmp    8013fa <fd_lookup+0x54>
		return -E_INVAL;
  8013ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f3:	eb 05                	jmp    8013fa <fd_lookup+0x54>
  8013f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    

008013fc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 18             	sub    $0x18,%esp
  801402:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801405:	ba 08 2a 80 00       	mov    $0x802a08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80140a:	eb 13                	jmp    80141f <dev_lookup+0x23>
  80140c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80140f:	39 08                	cmp    %ecx,(%eax)
  801411:	75 0c                	jne    80141f <dev_lookup+0x23>
			*dev = devtab[i];
  801413:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801416:	89 01                	mov    %eax,(%ecx)
			return 0;
  801418:	b8 00 00 00 00       	mov    $0x0,%eax
  80141d:	eb 30                	jmp    80144f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80141f:	8b 02                	mov    (%edx),%eax
  801421:	85 c0                	test   %eax,%eax
  801423:	75 e7                	jne    80140c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801425:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80142a:	8b 40 48             	mov    0x48(%eax),%eax
  80142d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801431:	89 44 24 04          	mov    %eax,0x4(%esp)
  801435:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  80143c:	e8 0a ee ff ff       	call   80024b <cprintf>
	*dev = 0;
  801441:	8b 45 0c             	mov    0xc(%ebp),%eax
  801444:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80144a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <fd_close>:
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
  801456:	83 ec 20             	sub    $0x20,%esp
  801459:	8b 75 08             	mov    0x8(%ebp),%esi
  80145c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80145f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801462:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801466:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80146c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80146f:	89 04 24             	mov    %eax,(%esp)
  801472:	e8 2f ff ff ff       	call   8013a6 <fd_lookup>
  801477:	85 c0                	test   %eax,%eax
  801479:	78 05                	js     801480 <fd_close+0x2f>
	    || fd != fd2)
  80147b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80147e:	74 0c                	je     80148c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801480:	84 db                	test   %bl,%bl
  801482:	ba 00 00 00 00       	mov    $0x0,%edx
  801487:	0f 44 c2             	cmove  %edx,%eax
  80148a:	eb 3f                	jmp    8014cb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80148c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801493:	8b 06                	mov    (%esi),%eax
  801495:	89 04 24             	mov    %eax,(%esp)
  801498:	e8 5f ff ff ff       	call   8013fc <dev_lookup>
  80149d:	89 c3                	mov    %eax,%ebx
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 16                	js     8014b9 <fd_close+0x68>
		if (dev->dev_close)
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	74 07                	je     8014b9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8014b2:	89 34 24             	mov    %esi,(%esp)
  8014b5:	ff d0                	call   *%eax
  8014b7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8014b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c4:	e8 71 f8 ff ff       	call   800d3a <sys_page_unmap>
	return r;
  8014c9:	89 d8                	mov    %ebx,%eax
}
  8014cb:	83 c4 20             	add    $0x20,%esp
  8014ce:	5b                   	pop    %ebx
  8014cf:	5e                   	pop    %esi
  8014d0:	5d                   	pop    %ebp
  8014d1:	c3                   	ret    

008014d2 <close>:

int
close(int fdnum)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014df:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e2:	89 04 24             	mov    %eax,(%esp)
  8014e5:	e8 bc fe ff ff       	call   8013a6 <fd_lookup>
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	85 d2                	test   %edx,%edx
  8014ee:	78 13                	js     801503 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8014f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014f7:	00 
  8014f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fb:	89 04 24             	mov    %eax,(%esp)
  8014fe:	e8 4e ff ff ff       	call   801451 <fd_close>
}
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <close_all>:

void
close_all(void)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80150c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801511:	89 1c 24             	mov    %ebx,(%esp)
  801514:	e8 b9 ff ff ff       	call   8014d2 <close>
	for (i = 0; i < MAXFD; i++)
  801519:	83 c3 01             	add    $0x1,%ebx
  80151c:	83 fb 20             	cmp    $0x20,%ebx
  80151f:	75 f0                	jne    801511 <close_all+0xc>
}
  801521:	83 c4 14             	add    $0x14,%esp
  801524:	5b                   	pop    %ebx
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	57                   	push   %edi
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801530:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801533:	89 44 24 04          	mov    %eax,0x4(%esp)
  801537:	8b 45 08             	mov    0x8(%ebp),%eax
  80153a:	89 04 24             	mov    %eax,(%esp)
  80153d:	e8 64 fe ff ff       	call   8013a6 <fd_lookup>
  801542:	89 c2                	mov    %eax,%edx
  801544:	85 d2                	test   %edx,%edx
  801546:	0f 88 e1 00 00 00    	js     80162d <dup+0x106>
		return r;
	close(newfdnum);
  80154c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154f:	89 04 24             	mov    %eax,(%esp)
  801552:	e8 7b ff ff ff       	call   8014d2 <close>

	newfd = INDEX2FD(newfdnum);
  801557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80155a:	c1 e3 0c             	shl    $0xc,%ebx
  80155d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801563:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801566:	89 04 24             	mov    %eax,(%esp)
  801569:	e8 d2 fd ff ff       	call   801340 <fd2data>
  80156e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801570:	89 1c 24             	mov    %ebx,(%esp)
  801573:	e8 c8 fd ff ff       	call   801340 <fd2data>
  801578:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80157a:	89 f0                	mov    %esi,%eax
  80157c:	c1 e8 16             	shr    $0x16,%eax
  80157f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801586:	a8 01                	test   $0x1,%al
  801588:	74 43                	je     8015cd <dup+0xa6>
  80158a:	89 f0                	mov    %esi,%eax
  80158c:	c1 e8 0c             	shr    $0xc,%eax
  80158f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801596:	f6 c2 01             	test   $0x1,%dl
  801599:	74 32                	je     8015cd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80159b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8015a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015b6:	00 
  8015b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c2:	e8 20 f7 ff ff       	call   800ce7 <sys_page_map>
  8015c7:	89 c6                	mov    %eax,%esi
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 3e                	js     80160b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d0:	89 c2                	mov    %eax,%edx
  8015d2:	c1 ea 0c             	shr    $0xc,%edx
  8015d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015dc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015e2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015e6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f1:	00 
  8015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fd:	e8 e5 f6 ff ff       	call   800ce7 <sys_page_map>
  801602:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801604:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801607:	85 f6                	test   %esi,%esi
  801609:	79 22                	jns    80162d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80160b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80160f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801616:	e8 1f f7 ff ff       	call   800d3a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80161b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80161f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801626:	e8 0f f7 ff ff       	call   800d3a <sys_page_unmap>
	return r;
  80162b:	89 f0                	mov    %esi,%eax
}
  80162d:	83 c4 3c             	add    $0x3c,%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5f                   	pop    %edi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	53                   	push   %ebx
  801639:	83 ec 24             	sub    $0x24,%esp
  80163c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801642:	89 44 24 04          	mov    %eax,0x4(%esp)
  801646:	89 1c 24             	mov    %ebx,(%esp)
  801649:	e8 58 fd ff ff       	call   8013a6 <fd_lookup>
  80164e:	89 c2                	mov    %eax,%edx
  801650:	85 d2                	test   %edx,%edx
  801652:	78 6d                	js     8016c1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165e:	8b 00                	mov    (%eax),%eax
  801660:	89 04 24             	mov    %eax,(%esp)
  801663:	e8 94 fd ff ff       	call   8013fc <dev_lookup>
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 55                	js     8016c1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166f:	8b 50 08             	mov    0x8(%eax),%edx
  801672:	83 e2 03             	and    $0x3,%edx
  801675:	83 fa 01             	cmp    $0x1,%edx
  801678:	75 23                	jne    80169d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80167a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80167f:	8b 40 48             	mov    0x48(%eax),%eax
  801682:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168a:	c7 04 24 cd 29 80 00 	movl   $0x8029cd,(%esp)
  801691:	e8 b5 eb ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  801696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169b:	eb 24                	jmp    8016c1 <read+0x8c>
	}
	if (!dev->dev_read)
  80169d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a0:	8b 52 08             	mov    0x8(%edx),%edx
  8016a3:	85 d2                	test   %edx,%edx
  8016a5:	74 15                	je     8016bc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016b5:	89 04 24             	mov    %eax,(%esp)
  8016b8:	ff d2                	call   *%edx
  8016ba:	eb 05                	jmp    8016c1 <read+0x8c>
		return -E_NOT_SUPP;
  8016bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016c1:	83 c4 24             	add    $0x24,%esp
  8016c4:	5b                   	pop    %ebx
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	57                   	push   %edi
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 1c             	sub    $0x1c,%esp
  8016d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016db:	eb 23                	jmp    801700 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016dd:	89 f0                	mov    %esi,%eax
  8016df:	29 d8                	sub    %ebx,%eax
  8016e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e5:	89 d8                	mov    %ebx,%eax
  8016e7:	03 45 0c             	add    0xc(%ebp),%eax
  8016ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ee:	89 3c 24             	mov    %edi,(%esp)
  8016f1:	e8 3f ff ff ff       	call   801635 <read>
		if (m < 0)
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 10                	js     80170a <readn+0x43>
			return m;
		if (m == 0)
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	74 0a                	je     801708 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8016fe:	01 c3                	add    %eax,%ebx
  801700:	39 f3                	cmp    %esi,%ebx
  801702:	72 d9                	jb     8016dd <readn+0x16>
  801704:	89 d8                	mov    %ebx,%eax
  801706:	eb 02                	jmp    80170a <readn+0x43>
  801708:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80170a:	83 c4 1c             	add    $0x1c,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5f                   	pop    %edi
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	53                   	push   %ebx
  801716:	83 ec 24             	sub    $0x24,%esp
  801719:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	89 1c 24             	mov    %ebx,(%esp)
  801726:	e8 7b fc ff ff       	call   8013a6 <fd_lookup>
  80172b:	89 c2                	mov    %eax,%edx
  80172d:	85 d2                	test   %edx,%edx
  80172f:	78 68                	js     801799 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	89 44 24 04          	mov    %eax,0x4(%esp)
  801738:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173b:	8b 00                	mov    (%eax),%eax
  80173d:	89 04 24             	mov    %eax,(%esp)
  801740:	e8 b7 fc ff ff       	call   8013fc <dev_lookup>
  801745:	85 c0                	test   %eax,%eax
  801747:	78 50                	js     801799 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801749:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801750:	75 23                	jne    801775 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801752:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801757:	8b 40 48             	mov    0x48(%eax),%eax
  80175a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80175e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801762:	c7 04 24 e9 29 80 00 	movl   $0x8029e9,(%esp)
  801769:	e8 dd ea ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  80176e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801773:	eb 24                	jmp    801799 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801775:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801778:	8b 52 0c             	mov    0xc(%edx),%edx
  80177b:	85 d2                	test   %edx,%edx
  80177d:	74 15                	je     801794 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80177f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801782:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801786:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801789:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80178d:	89 04 24             	mov    %eax,(%esp)
  801790:	ff d2                	call   *%edx
  801792:	eb 05                	jmp    801799 <write+0x87>
		return -E_NOT_SUPP;
  801794:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801799:	83 c4 24             	add    $0x24,%esp
  80179c:	5b                   	pop    %ebx
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <seek>:

int
seek(int fdnum, off_t offset)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	89 04 24             	mov    %eax,(%esp)
  8017b2:	e8 ef fb ff ff       	call   8013a6 <fd_lookup>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 0e                	js     8017c9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c9:	c9                   	leave  
  8017ca:	c3                   	ret    

008017cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	53                   	push   %ebx
  8017cf:	83 ec 24             	sub    $0x24,%esp
  8017d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dc:	89 1c 24             	mov    %ebx,(%esp)
  8017df:	e8 c2 fb ff ff       	call   8013a6 <fd_lookup>
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	85 d2                	test   %edx,%edx
  8017e8:	78 61                	js     80184b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f4:	8b 00                	mov    (%eax),%eax
  8017f6:	89 04 24             	mov    %eax,(%esp)
  8017f9:	e8 fe fb ff ff       	call   8013fc <dev_lookup>
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 49                	js     80184b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801805:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801809:	75 23                	jne    80182e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80180b:	a1 0c 40 80 00       	mov    0x80400c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801810:	8b 40 48             	mov    0x48(%eax),%eax
  801813:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181b:	c7 04 24 ac 29 80 00 	movl   $0x8029ac,(%esp)
  801822:	e8 24 ea ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  801827:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182c:	eb 1d                	jmp    80184b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80182e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801831:	8b 52 18             	mov    0x18(%edx),%edx
  801834:	85 d2                	test   %edx,%edx
  801836:	74 0e                	je     801846 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	ff d2                	call   *%edx
  801844:	eb 05                	jmp    80184b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801846:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80184b:	83 c4 24             	add    $0x24,%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    

00801851 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	53                   	push   %ebx
  801855:	83 ec 24             	sub    $0x24,%esp
  801858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	89 04 24             	mov    %eax,(%esp)
  801868:	e8 39 fb ff ff       	call   8013a6 <fd_lookup>
  80186d:	89 c2                	mov    %eax,%edx
  80186f:	85 d2                	test   %edx,%edx
  801871:	78 52                	js     8018c5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801873:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187d:	8b 00                	mov    (%eax),%eax
  80187f:	89 04 24             	mov    %eax,(%esp)
  801882:	e8 75 fb ff ff       	call   8013fc <dev_lookup>
  801887:	85 c0                	test   %eax,%eax
  801889:	78 3a                	js     8018c5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801892:	74 2c                	je     8018c0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801894:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801897:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80189e:	00 00 00 
	stat->st_isdir = 0;
  8018a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a8:	00 00 00 
	stat->st_dev = dev;
  8018ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018b8:	89 14 24             	mov    %edx,(%esp)
  8018bb:	ff 50 14             	call   *0x14(%eax)
  8018be:	eb 05                	jmp    8018c5 <fstat+0x74>
		return -E_NOT_SUPP;
  8018c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018c5:	83 c4 24             	add    $0x24,%esp
  8018c8:	5b                   	pop    %ebx
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018da:	00 
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	89 04 24             	mov    %eax,(%esp)
  8018e1:	e8 fb 01 00 00       	call   801ae1 <open>
  8018e6:	89 c3                	mov    %eax,%ebx
  8018e8:	85 db                	test   %ebx,%ebx
  8018ea:	78 1b                	js     801907 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8018ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f3:	89 1c 24             	mov    %ebx,(%esp)
  8018f6:	e8 56 ff ff ff       	call   801851 <fstat>
  8018fb:	89 c6                	mov    %eax,%esi
	close(fd);
  8018fd:	89 1c 24             	mov    %ebx,(%esp)
  801900:	e8 cd fb ff ff       	call   8014d2 <close>
	return r;
  801905:	89 f0                	mov    %esi,%eax
}
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	83 ec 10             	sub    $0x10,%esp
  801916:	89 c6                	mov    %eax,%esi
  801918:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80191a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801921:	75 11                	jne    801934 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801923:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80192a:	e8 c0 f9 ff ff       	call   8012ef <ipc_find_env>
  80192f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801934:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80193b:	00 
  80193c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801943:	00 
  801944:	89 74 24 04          	mov    %esi,0x4(%esp)
  801948:	a1 04 40 80 00       	mov    0x804004,%eax
  80194d:	89 04 24             	mov    %eax,(%esp)
  801950:	e8 33 f9 ff ff       	call   801288 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801955:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80195c:	00 
  80195d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801961:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801968:	e8 b3 f8 ff ff       	call   801220 <ipc_recv>
}
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	8b 40 0c             	mov    0xc(%eax),%eax
  801980:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801985:	8b 45 0c             	mov    0xc(%ebp),%eax
  801988:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 02 00 00 00       	mov    $0x2,%eax
  801997:	e8 72 ff ff ff       	call   80190e <fsipc>
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devfile_flush>:
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019af:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b9:	e8 50 ff ff ff       	call   80190e <fsipc>
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <devfile_stat>:
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 14             	sub    $0x14,%esp
  8019c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019da:	b8 05 00 00 00       	mov    $0x5,%eax
  8019df:	e8 2a ff ff ff       	call   80190e <fsipc>
  8019e4:	89 c2                	mov    %eax,%edx
  8019e6:	85 d2                	test   %edx,%edx
  8019e8:	78 2b                	js     801a15 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ea:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019f1:	00 
  8019f2:	89 1c 24             	mov    %ebx,(%esp)
  8019f5:	e8 7d ee ff ff       	call   800877 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019fa:	a1 80 50 80 00       	mov    0x805080,%eax
  8019ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a05:	a1 84 50 80 00       	mov    0x805084,%eax
  801a0a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a15:	83 c4 14             	add    $0x14,%esp
  801a18:	5b                   	pop    %ebx
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <devfile_write>:
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801a21:	c7 44 24 08 18 2a 80 	movl   $0x802a18,0x8(%esp)
  801a28:	00 
  801a29:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a30:	00 
  801a31:	c7 04 24 36 2a 80 00 	movl   $0x802a36,(%esp)
  801a38:	e8 69 06 00 00       	call   8020a6 <_panic>

00801a3d <devfile_read>:
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	83 ec 10             	sub    $0x10,%esp
  801a45:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a53:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a59:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a63:	e8 a6 fe ff ff       	call   80190e <fsipc>
  801a68:	89 c3                	mov    %eax,%ebx
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 6a                	js     801ad8 <devfile_read+0x9b>
	assert(r <= n);
  801a6e:	39 c6                	cmp    %eax,%esi
  801a70:	73 24                	jae    801a96 <devfile_read+0x59>
  801a72:	c7 44 24 0c 41 2a 80 	movl   $0x802a41,0xc(%esp)
  801a79:	00 
  801a7a:	c7 44 24 08 48 2a 80 	movl   $0x802a48,0x8(%esp)
  801a81:	00 
  801a82:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a89:	00 
  801a8a:	c7 04 24 36 2a 80 00 	movl   $0x802a36,(%esp)
  801a91:	e8 10 06 00 00       	call   8020a6 <_panic>
	assert(r <= PGSIZE);
  801a96:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a9b:	7e 24                	jle    801ac1 <devfile_read+0x84>
  801a9d:	c7 44 24 0c 5d 2a 80 	movl   $0x802a5d,0xc(%esp)
  801aa4:	00 
  801aa5:	c7 44 24 08 48 2a 80 	movl   $0x802a48,0x8(%esp)
  801aac:	00 
  801aad:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ab4:	00 
  801ab5:	c7 04 24 36 2a 80 00 	movl   $0x802a36,(%esp)
  801abc:	e8 e5 05 00 00       	call   8020a6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ac1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801acc:	00 
  801acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad0:	89 04 24             	mov    %eax,(%esp)
  801ad3:	e8 3c ef ff ff       	call   800a14 <memmove>
}
  801ad8:	89 d8                	mov    %ebx,%eax
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <open>:
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 24             	sub    $0x24,%esp
  801ae8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801aeb:	89 1c 24             	mov    %ebx,(%esp)
  801aee:	e8 4d ed ff ff       	call   800840 <strlen>
  801af3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801af8:	7f 60                	jg     801b5a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801afa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afd:	89 04 24             	mov    %eax,(%esp)
  801b00:	e8 52 f8 ff ff       	call   801357 <fd_alloc>
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	85 d2                	test   %edx,%edx
  801b09:	78 54                	js     801b5f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801b0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b0f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b16:	e8 5c ed ff ff       	call   800877 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b26:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2b:	e8 de fd ff ff       	call   80190e <fsipc>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	85 c0                	test   %eax,%eax
  801b34:	79 17                	jns    801b4d <open+0x6c>
		fd_close(fd, 0);
  801b36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b3d:	00 
  801b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 08 f9 ff ff       	call   801451 <fd_close>
		return r;
  801b49:	89 d8                	mov    %ebx,%eax
  801b4b:	eb 12                	jmp    801b5f <open+0x7e>
	return fd2num(fd);
  801b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b50:	89 04 24             	mov    %eax,(%esp)
  801b53:	e8 d8 f7 ff ff       	call   801330 <fd2num>
  801b58:	eb 05                	jmp    801b5f <open+0x7e>
		return -E_BAD_PATH;
  801b5a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801b5f:	83 c4 24             	add    $0x24,%esp
  801b62:	5b                   	pop    %ebx
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b70:	b8 08 00 00 00       	mov    $0x8,%eax
  801b75:	e8 94 fd ff ff       	call   80190e <fsipc>
}
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 10             	sub    $0x10,%esp
  801b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8a:	89 04 24             	mov    %eax,(%esp)
  801b8d:	e8 ae f7 ff ff       	call   801340 <fd2data>
  801b92:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b94:	c7 44 24 04 69 2a 80 	movl   $0x802a69,0x4(%esp)
  801b9b:	00 
  801b9c:	89 1c 24             	mov    %ebx,(%esp)
  801b9f:	e8 d3 ec ff ff       	call   800877 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba4:	8b 46 04             	mov    0x4(%esi),%eax
  801ba7:	2b 06                	sub    (%esi),%eax
  801ba9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801baf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb6:	00 00 00 
	stat->st_dev = &devpipe;
  801bb9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bc0:	30 80 00 
	return 0;
}
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 14             	sub    $0x14,%esp
  801bd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bd9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be4:	e8 51 f1 ff ff       	call   800d3a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801be9:	89 1c 24             	mov    %ebx,(%esp)
  801bec:	e8 4f f7 ff ff       	call   801340 <fd2data>
  801bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfc:	e8 39 f1 ff ff       	call   800d3a <sys_page_unmap>
}
  801c01:	83 c4 14             	add    $0x14,%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <_pipeisclosed>:
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	57                   	push   %edi
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 2c             	sub    $0x2c,%esp
  801c10:	89 c6                	mov    %eax,%esi
  801c12:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801c15:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801c1a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c1d:	89 34 24             	mov    %esi,(%esp)
  801c20:	e8 87 05 00 00       	call   8021ac <pageref>
  801c25:	89 c7                	mov    %eax,%edi
  801c27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2a:	89 04 24             	mov    %eax,(%esp)
  801c2d:	e8 7a 05 00 00       	call   8021ac <pageref>
  801c32:	39 c7                	cmp    %eax,%edi
  801c34:	0f 94 c2             	sete   %dl
  801c37:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c3a:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  801c40:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c43:	39 fb                	cmp    %edi,%ebx
  801c45:	74 21                	je     801c68 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801c47:	84 d2                	test   %dl,%dl
  801c49:	74 ca                	je     801c15 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c4b:	8b 51 58             	mov    0x58(%ecx),%edx
  801c4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c52:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c5a:	c7 04 24 70 2a 80 00 	movl   $0x802a70,(%esp)
  801c61:	e8 e5 e5 ff ff       	call   80024b <cprintf>
  801c66:	eb ad                	jmp    801c15 <_pipeisclosed+0xe>
}
  801c68:	83 c4 2c             	add    $0x2c,%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5f                   	pop    %edi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <devpipe_write>:
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	57                   	push   %edi
  801c74:	56                   	push   %esi
  801c75:	53                   	push   %ebx
  801c76:	83 ec 1c             	sub    $0x1c,%esp
  801c79:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c7c:	89 34 24             	mov    %esi,(%esp)
  801c7f:	e8 bc f6 ff ff       	call   801340 <fd2data>
  801c84:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c86:	bf 00 00 00 00       	mov    $0x0,%edi
  801c8b:	eb 45                	jmp    801cd2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801c8d:	89 da                	mov    %ebx,%edx
  801c8f:	89 f0                	mov    %esi,%eax
  801c91:	e8 71 ff ff ff       	call   801c07 <_pipeisclosed>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	75 41                	jne    801cdb <devpipe_write+0x6b>
			sys_yield();
  801c9a:	e8 d5 ef ff ff       	call   800c74 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c9f:	8b 43 04             	mov    0x4(%ebx),%eax
  801ca2:	8b 0b                	mov    (%ebx),%ecx
  801ca4:	8d 51 20             	lea    0x20(%ecx),%edx
  801ca7:	39 d0                	cmp    %edx,%eax
  801ca9:	73 e2                	jae    801c8d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cae:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cb2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cb5:	99                   	cltd   
  801cb6:	c1 ea 1b             	shr    $0x1b,%edx
  801cb9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801cbc:	83 e1 1f             	and    $0x1f,%ecx
  801cbf:	29 d1                	sub    %edx,%ecx
  801cc1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801cc5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801cc9:	83 c0 01             	add    $0x1,%eax
  801ccc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ccf:	83 c7 01             	add    $0x1,%edi
  801cd2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cd5:	75 c8                	jne    801c9f <devpipe_write+0x2f>
	return i;
  801cd7:	89 f8                	mov    %edi,%eax
  801cd9:	eb 05                	jmp    801ce0 <devpipe_write+0x70>
				return 0;
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <devpipe_read>:
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	57                   	push   %edi
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	83 ec 1c             	sub    $0x1c,%esp
  801cf1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cf4:	89 3c 24             	mov    %edi,(%esp)
  801cf7:	e8 44 f6 ff ff       	call   801340 <fd2data>
  801cfc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cfe:	be 00 00 00 00       	mov    $0x0,%esi
  801d03:	eb 3d                	jmp    801d42 <devpipe_read+0x5a>
			if (i > 0)
  801d05:	85 f6                	test   %esi,%esi
  801d07:	74 04                	je     801d0d <devpipe_read+0x25>
				return i;
  801d09:	89 f0                	mov    %esi,%eax
  801d0b:	eb 43                	jmp    801d50 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801d0d:	89 da                	mov    %ebx,%edx
  801d0f:	89 f8                	mov    %edi,%eax
  801d11:	e8 f1 fe ff ff       	call   801c07 <_pipeisclosed>
  801d16:	85 c0                	test   %eax,%eax
  801d18:	75 31                	jne    801d4b <devpipe_read+0x63>
			sys_yield();
  801d1a:	e8 55 ef ff ff       	call   800c74 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d1f:	8b 03                	mov    (%ebx),%eax
  801d21:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d24:	74 df                	je     801d05 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d26:	99                   	cltd   
  801d27:	c1 ea 1b             	shr    $0x1b,%edx
  801d2a:	01 d0                	add    %edx,%eax
  801d2c:	83 e0 1f             	and    $0x1f,%eax
  801d2f:	29 d0                	sub    %edx,%eax
  801d31:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d39:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d3c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d3f:	83 c6 01             	add    $0x1,%esi
  801d42:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d45:	75 d8                	jne    801d1f <devpipe_read+0x37>
	return i;
  801d47:	89 f0                	mov    %esi,%eax
  801d49:	eb 05                	jmp    801d50 <devpipe_read+0x68>
				return 0;
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d50:	83 c4 1c             	add    $0x1c,%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5e                   	pop    %esi
  801d55:	5f                   	pop    %edi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <pipe>:
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	56                   	push   %esi
  801d5c:	53                   	push   %ebx
  801d5d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d63:	89 04 24             	mov    %eax,(%esp)
  801d66:	e8 ec f5 ff ff       	call   801357 <fd_alloc>
  801d6b:	89 c2                	mov    %eax,%edx
  801d6d:	85 d2                	test   %edx,%edx
  801d6f:	0f 88 4d 01 00 00    	js     801ec2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d75:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d7c:	00 
  801d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d8b:	e8 03 ef ff ff       	call   800c93 <sys_page_alloc>
  801d90:	89 c2                	mov    %eax,%edx
  801d92:	85 d2                	test   %edx,%edx
  801d94:	0f 88 28 01 00 00    	js     801ec2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801d9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d9d:	89 04 24             	mov    %eax,(%esp)
  801da0:	e8 b2 f5 ff ff       	call   801357 <fd_alloc>
  801da5:	89 c3                	mov    %eax,%ebx
  801da7:	85 c0                	test   %eax,%eax
  801da9:	0f 88 fe 00 00 00    	js     801ead <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801daf:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801db6:	00 
  801db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc5:	e8 c9 ee ff ff       	call   800c93 <sys_page_alloc>
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	0f 88 d9 00 00 00    	js     801ead <pipe+0x155>
	va = fd2data(fd0);
  801dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd7:	89 04 24             	mov    %eax,(%esp)
  801dda:	e8 61 f5 ff ff       	call   801340 <fd2data>
  801ddf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801de8:	00 
  801de9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ded:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df4:	e8 9a ee ff ff       	call   800c93 <sys_page_alloc>
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	0f 88 97 00 00 00    	js     801e9a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e06:	89 04 24             	mov    %eax,(%esp)
  801e09:	e8 32 f5 ff ff       	call   801340 <fd2data>
  801e0e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e15:	00 
  801e16:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e21:	00 
  801e22:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2d:	e8 b5 ee ff ff       	call   800ce7 <sys_page_map>
  801e32:	89 c3                	mov    %eax,%ebx
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 52                	js     801e8a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801e38:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e41:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e46:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e56:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e5b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e65:	89 04 24             	mov    %eax,(%esp)
  801e68:	e8 c3 f4 ff ff       	call   801330 <fd2num>
  801e6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e70:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e75:	89 04 24             	mov    %eax,(%esp)
  801e78:	e8 b3 f4 ff ff       	call   801330 <fd2num>
  801e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e80:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
  801e88:	eb 38                	jmp    801ec2 <pipe+0x16a>
	sys_page_unmap(0, va);
  801e8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e95:	e8 a0 ee ff ff       	call   800d3a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea8:	e8 8d ee ff ff       	call   800d3a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebb:	e8 7a ee ff ff       	call   800d3a <sys_page_unmap>
  801ec0:	89 d8                	mov    %ebx,%eax
}
  801ec2:	83 c4 30             	add    $0x30,%esp
  801ec5:	5b                   	pop    %ebx
  801ec6:	5e                   	pop    %esi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <pipeisclosed>:
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ecf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed9:	89 04 24             	mov    %eax,(%esp)
  801edc:	e8 c5 f4 ff ff       	call   8013a6 <fd_lookup>
  801ee1:	89 c2                	mov    %eax,%edx
  801ee3:	85 d2                	test   %edx,%edx
  801ee5:	78 15                	js     801efc <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	89 04 24             	mov    %eax,(%esp)
  801eed:	e8 4e f4 ff ff       	call   801340 <fd2data>
	return _pipeisclosed(fd, p);
  801ef2:	89 c2                	mov    %eax,%edx
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	e8 0b fd ff ff       	call   801c07 <_pipeisclosed>
}
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    
  801efe:	66 90                	xchg   %ax,%ax

00801f00 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f10:	c7 44 24 04 88 2a 80 	movl   $0x802a88,0x4(%esp)
  801f17:	00 
  801f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1b:	89 04 24             	mov    %eax,(%esp)
  801f1e:	e8 54 e9 ff ff       	call   800877 <strcpy>
	return 0;
}
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <devcons_write>:
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	57                   	push   %edi
  801f2e:	56                   	push   %esi
  801f2f:	53                   	push   %ebx
  801f30:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f36:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f3b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f41:	eb 31                	jmp    801f74 <devcons_write+0x4a>
		m = n - tot;
  801f43:	8b 75 10             	mov    0x10(%ebp),%esi
  801f46:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f48:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801f4b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f50:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f53:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f57:	03 45 0c             	add    0xc(%ebp),%eax
  801f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5e:	89 3c 24             	mov    %edi,(%esp)
  801f61:	e8 ae ea ff ff       	call   800a14 <memmove>
		sys_cputs(buf, m);
  801f66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f6a:	89 3c 24             	mov    %edi,(%esp)
  801f6d:	e8 54 ec ff ff       	call   800bc6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f72:	01 f3                	add    %esi,%ebx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f79:	72 c8                	jb     801f43 <devcons_write+0x19>
}
  801f7b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <devcons_read>:
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f95:	75 07                	jne    801f9e <devcons_read+0x18>
  801f97:	eb 2a                	jmp    801fc3 <devcons_read+0x3d>
		sys_yield();
  801f99:	e8 d6 ec ff ff       	call   800c74 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f9e:	66 90                	xchg   %ax,%ax
  801fa0:	e8 3f ec ff ff       	call   800be4 <sys_cgetc>
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	74 f0                	je     801f99 <devcons_read+0x13>
	if (c < 0)
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 16                	js     801fc3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801fad:	83 f8 04             	cmp    $0x4,%eax
  801fb0:	74 0c                	je     801fbe <devcons_read+0x38>
	*(char*)vbuf = c;
  801fb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb5:	88 02                	mov    %al,(%edx)
	return 1;
  801fb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbc:	eb 05                	jmp    801fc3 <devcons_read+0x3d>
		return 0;
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <cputchar>:
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801fd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fd8:	00 
  801fd9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fdc:	89 04 24             	mov    %eax,(%esp)
  801fdf:	e8 e2 eb ff ff       	call   800bc6 <sys_cputs>
}
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <getchar>:
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801fec:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ff3:	00 
  801ff4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802002:	e8 2e f6 ff ff       	call   801635 <read>
	if (r < 0)
  802007:	85 c0                	test   %eax,%eax
  802009:	78 0f                	js     80201a <getchar+0x34>
	if (r < 1)
  80200b:	85 c0                	test   %eax,%eax
  80200d:	7e 06                	jle    802015 <getchar+0x2f>
	return c;
  80200f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802013:	eb 05                	jmp    80201a <getchar+0x34>
		return -E_EOF;
  802015:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <iscons>:
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802025:	89 44 24 04          	mov    %eax,0x4(%esp)
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 72 f3 ff ff       	call   8013a6 <fd_lookup>
  802034:	85 c0                	test   %eax,%eax
  802036:	78 11                	js     802049 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802041:	39 10                	cmp    %edx,(%eax)
  802043:	0f 94 c0             	sete   %al
  802046:	0f b6 c0             	movzbl %al,%eax
}
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <opencons>:
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802054:	89 04 24             	mov    %eax,(%esp)
  802057:	e8 fb f2 ff ff       	call   801357 <fd_alloc>
		return r;
  80205c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80205e:	85 c0                	test   %eax,%eax
  802060:	78 40                	js     8020a2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802062:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802069:	00 
  80206a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802071:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802078:	e8 16 ec ff ff       	call   800c93 <sys_page_alloc>
		return r;
  80207d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80207f:	85 c0                	test   %eax,%eax
  802081:	78 1f                	js     8020a2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802083:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80208e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802091:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802098:	89 04 24             	mov    %eax,(%esp)
  80209b:	e8 90 f2 ff ff       	call   801330 <fd2num>
  8020a0:	89 c2                	mov    %eax,%edx
}
  8020a2:	89 d0                	mov    %edx,%eax
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	56                   	push   %esi
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8020ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8020b7:	e8 99 eb ff ff       	call   800c55 <sys_getenvid>
  8020bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020bf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8020c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020ca:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d2:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  8020d9:	e8 6d e1 ff ff       	call   80024b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 fd e0 ff ff       	call   8001ea <vcprintf>
	cprintf("\n");
  8020ed:	c7 04 24 81 2a 80 00 	movl   $0x802a81,(%esp)
  8020f4:	e8 52 e1 ff ff       	call   80024b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020f9:	cc                   	int3   
  8020fa:	eb fd                	jmp    8020f9 <_panic+0x53>

008020fc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  802102:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802109:	75 70                	jne    80217b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  80210b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802112:	00 
  802113:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80211a:	ee 
  80211b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802122:	e8 6c eb ff ff       	call   800c93 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  802127:	85 c0                	test   %eax,%eax
  802129:	79 1c                	jns    802147 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  80212b:	c7 44 24 08 b8 2a 80 	movl   $0x802ab8,0x8(%esp)
  802132:	00 
  802133:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  80213a:	00 
  80213b:	c7 04 24 14 2b 80 00 	movl   $0x802b14,(%esp)
  802142:	e8 5f ff ff ff       	call   8020a6 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  802147:	c7 44 24 04 85 21 80 	movl   $0x802185,0x4(%esp)
  80214e:	00 
  80214f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802156:	e8 d8 ec ff ff       	call   800e33 <sys_env_set_pgfault_upcall>
        if(r < 0)
  80215b:	85 c0                	test   %eax,%eax
  80215d:	79 1c                	jns    80217b <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  80215f:	c7 44 24 08 e0 2a 80 	movl   $0x802ae0,0x8(%esp)
  802166:	00 
  802167:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80216e:	00 
  80216f:	c7 04 24 14 2b 80 00 	movl   $0x802b14,(%esp)
  802176:	e8 2b ff ff ff       	call   8020a6 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80217b:	8b 45 08             	mov    0x8(%ebp),%eax
  80217e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802183:	c9                   	leave  
  802184:	c3                   	ret    

00802185 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802185:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802186:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80218b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80218d:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  802190:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  802194:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802198:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  80219a:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  80219c:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  80219d:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  8021a0:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  8021a2:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  8021a5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  8021a6:	83 c4 04             	add    $0x4,%esp
    popf;
  8021a9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  8021aa:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  8021ab:	c3                   	ret    

008021ac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b2:	89 d0                	mov    %edx,%eax
  8021b4:	c1 e8 16             	shr    $0x16,%eax
  8021b7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021be:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8021c3:	f6 c1 01             	test   $0x1,%cl
  8021c6:	74 1d                	je     8021e5 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8021c8:	c1 ea 0c             	shr    $0xc,%edx
  8021cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021d2:	f6 c2 01             	test   $0x1,%dl
  8021d5:	74 0e                	je     8021e5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d7:	c1 ea 0c             	shr    $0xc,%edx
  8021da:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021e1:	ef 
  8021e2:	0f b7 c0             	movzwl %ax,%eax
}
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    
  8021e7:	66 90                	xchg   %ax,%ax
  8021e9:	66 90                	xchg   %ax,%ax
  8021eb:	66 90                	xchg   %ax,%ax
  8021ed:	66 90                	xchg   %ax,%ax
  8021ef:	90                   	nop

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	83 ec 0c             	sub    $0xc,%esp
  8021f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8021fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8021fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802202:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802206:	85 c0                	test   %eax,%eax
  802208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80220c:	89 ea                	mov    %ebp,%edx
  80220e:	89 0c 24             	mov    %ecx,(%esp)
  802211:	75 2d                	jne    802240 <__udivdi3+0x50>
  802213:	39 e9                	cmp    %ebp,%ecx
  802215:	77 61                	ja     802278 <__udivdi3+0x88>
  802217:	85 c9                	test   %ecx,%ecx
  802219:	89 ce                	mov    %ecx,%esi
  80221b:	75 0b                	jne    802228 <__udivdi3+0x38>
  80221d:	b8 01 00 00 00       	mov    $0x1,%eax
  802222:	31 d2                	xor    %edx,%edx
  802224:	f7 f1                	div    %ecx
  802226:	89 c6                	mov    %eax,%esi
  802228:	31 d2                	xor    %edx,%edx
  80222a:	89 e8                	mov    %ebp,%eax
  80222c:	f7 f6                	div    %esi
  80222e:	89 c5                	mov    %eax,%ebp
  802230:	89 f8                	mov    %edi,%eax
  802232:	f7 f6                	div    %esi
  802234:	89 ea                	mov    %ebp,%edx
  802236:	83 c4 0c             	add    $0xc,%esp
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	39 e8                	cmp    %ebp,%eax
  802242:	77 24                	ja     802268 <__udivdi3+0x78>
  802244:	0f bd e8             	bsr    %eax,%ebp
  802247:	83 f5 1f             	xor    $0x1f,%ebp
  80224a:	75 3c                	jne    802288 <__udivdi3+0x98>
  80224c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802250:	39 34 24             	cmp    %esi,(%esp)
  802253:	0f 86 9f 00 00 00    	jbe    8022f8 <__udivdi3+0x108>
  802259:	39 d0                	cmp    %edx,%eax
  80225b:	0f 82 97 00 00 00    	jb     8022f8 <__udivdi3+0x108>
  802261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802268:	31 d2                	xor    %edx,%edx
  80226a:	31 c0                	xor    %eax,%eax
  80226c:	83 c4 0c             	add    $0xc,%esp
  80226f:	5e                   	pop    %esi
  802270:	5f                   	pop    %edi
  802271:	5d                   	pop    %ebp
  802272:	c3                   	ret    
  802273:	90                   	nop
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	89 f8                	mov    %edi,%eax
  80227a:	f7 f1                	div    %ecx
  80227c:	31 d2                	xor    %edx,%edx
  80227e:	83 c4 0c             	add    $0xc,%esp
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    
  802285:	8d 76 00             	lea    0x0(%esi),%esi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	8b 3c 24             	mov    (%esp),%edi
  80228d:	d3 e0                	shl    %cl,%eax
  80228f:	89 c6                	mov    %eax,%esi
  802291:	b8 20 00 00 00       	mov    $0x20,%eax
  802296:	29 e8                	sub    %ebp,%eax
  802298:	89 c1                	mov    %eax,%ecx
  80229a:	d3 ef                	shr    %cl,%edi
  80229c:	89 e9                	mov    %ebp,%ecx
  80229e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8022a2:	8b 3c 24             	mov    (%esp),%edi
  8022a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8022a9:	89 d6                	mov    %edx,%esi
  8022ab:	d3 e7                	shl    %cl,%edi
  8022ad:	89 c1                	mov    %eax,%ecx
  8022af:	89 3c 24             	mov    %edi,(%esp)
  8022b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022b6:	d3 ee                	shr    %cl,%esi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	d3 e2                	shl    %cl,%edx
  8022bc:	89 c1                	mov    %eax,%ecx
  8022be:	d3 ef                	shr    %cl,%edi
  8022c0:	09 d7                	or     %edx,%edi
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	89 f8                	mov    %edi,%eax
  8022c6:	f7 74 24 08          	divl   0x8(%esp)
  8022ca:	89 d6                	mov    %edx,%esi
  8022cc:	89 c7                	mov    %eax,%edi
  8022ce:	f7 24 24             	mull   (%esp)
  8022d1:	39 d6                	cmp    %edx,%esi
  8022d3:	89 14 24             	mov    %edx,(%esp)
  8022d6:	72 30                	jb     802308 <__udivdi3+0x118>
  8022d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022dc:	89 e9                	mov    %ebp,%ecx
  8022de:	d3 e2                	shl    %cl,%edx
  8022e0:	39 c2                	cmp    %eax,%edx
  8022e2:	73 05                	jae    8022e9 <__udivdi3+0xf9>
  8022e4:	3b 34 24             	cmp    (%esp),%esi
  8022e7:	74 1f                	je     802308 <__udivdi3+0x118>
  8022e9:	89 f8                	mov    %edi,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	e9 7a ff ff ff       	jmp    80226c <__udivdi3+0x7c>
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	31 d2                	xor    %edx,%edx
  8022fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ff:	e9 68 ff ff ff       	jmp    80226c <__udivdi3+0x7c>
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	8d 47 ff             	lea    -0x1(%edi),%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	83 c4 0c             	add    $0xc,%esp
  802310:	5e                   	pop    %esi
  802311:	5f                   	pop    %edi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	83 ec 14             	sub    $0x14,%esp
  802326:	8b 44 24 28          	mov    0x28(%esp),%eax
  80232a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80232e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802332:	89 c7                	mov    %eax,%edi
  802334:	89 44 24 04          	mov    %eax,0x4(%esp)
  802338:	8b 44 24 30          	mov    0x30(%esp),%eax
  80233c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802340:	89 34 24             	mov    %esi,(%esp)
  802343:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802347:	85 c0                	test   %eax,%eax
  802349:	89 c2                	mov    %eax,%edx
  80234b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80234f:	75 17                	jne    802368 <__umoddi3+0x48>
  802351:	39 fe                	cmp    %edi,%esi
  802353:	76 4b                	jbe    8023a0 <__umoddi3+0x80>
  802355:	89 c8                	mov    %ecx,%eax
  802357:	89 fa                	mov    %edi,%edx
  802359:	f7 f6                	div    %esi
  80235b:	89 d0                	mov    %edx,%eax
  80235d:	31 d2                	xor    %edx,%edx
  80235f:	83 c4 14             	add    $0x14,%esp
  802362:	5e                   	pop    %esi
  802363:	5f                   	pop    %edi
  802364:	5d                   	pop    %ebp
  802365:	c3                   	ret    
  802366:	66 90                	xchg   %ax,%ax
  802368:	39 f8                	cmp    %edi,%eax
  80236a:	77 54                	ja     8023c0 <__umoddi3+0xa0>
  80236c:	0f bd e8             	bsr    %eax,%ebp
  80236f:	83 f5 1f             	xor    $0x1f,%ebp
  802372:	75 5c                	jne    8023d0 <__umoddi3+0xb0>
  802374:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802378:	39 3c 24             	cmp    %edi,(%esp)
  80237b:	0f 87 e7 00 00 00    	ja     802468 <__umoddi3+0x148>
  802381:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802385:	29 f1                	sub    %esi,%ecx
  802387:	19 c7                	sbb    %eax,%edi
  802389:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802391:	8b 44 24 08          	mov    0x8(%esp),%eax
  802395:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802399:	83 c4 14             	add    $0x14,%esp
  80239c:	5e                   	pop    %esi
  80239d:	5f                   	pop    %edi
  80239e:	5d                   	pop    %ebp
  80239f:	c3                   	ret    
  8023a0:	85 f6                	test   %esi,%esi
  8023a2:	89 f5                	mov    %esi,%ebp
  8023a4:	75 0b                	jne    8023b1 <__umoddi3+0x91>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f6                	div    %esi
  8023af:	89 c5                	mov    %eax,%ebp
  8023b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023b5:	31 d2                	xor    %edx,%edx
  8023b7:	f7 f5                	div    %ebp
  8023b9:	89 c8                	mov    %ecx,%eax
  8023bb:	f7 f5                	div    %ebp
  8023bd:	eb 9c                	jmp    80235b <__umoddi3+0x3b>
  8023bf:	90                   	nop
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 fa                	mov    %edi,%edx
  8023c4:	83 c4 14             	add    $0x14,%esp
  8023c7:	5e                   	pop    %esi
  8023c8:	5f                   	pop    %edi
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    
  8023cb:	90                   	nop
  8023cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	8b 04 24             	mov    (%esp),%eax
  8023d3:	be 20 00 00 00       	mov    $0x20,%esi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	29 ee                	sub    %ebp,%esi
  8023dc:	d3 e2                	shl    %cl,%edx
  8023de:	89 f1                	mov    %esi,%ecx
  8023e0:	d3 e8                	shr    %cl,%eax
  8023e2:	89 e9                	mov    %ebp,%ecx
  8023e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e8:	8b 04 24             	mov    (%esp),%eax
  8023eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8023ef:	89 fa                	mov    %edi,%edx
  8023f1:	d3 e0                	shl    %cl,%eax
  8023f3:	89 f1                	mov    %esi,%ecx
  8023f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8023fd:	d3 ea                	shr    %cl,%edx
  8023ff:	89 e9                	mov    %ebp,%ecx
  802401:	d3 e7                	shl    %cl,%edi
  802403:	89 f1                	mov    %esi,%ecx
  802405:	d3 e8                	shr    %cl,%eax
  802407:	89 e9                	mov    %ebp,%ecx
  802409:	09 f8                	or     %edi,%eax
  80240b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80240f:	f7 74 24 04          	divl   0x4(%esp)
  802413:	d3 e7                	shl    %cl,%edi
  802415:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802419:	89 d7                	mov    %edx,%edi
  80241b:	f7 64 24 08          	mull   0x8(%esp)
  80241f:	39 d7                	cmp    %edx,%edi
  802421:	89 c1                	mov    %eax,%ecx
  802423:	89 14 24             	mov    %edx,(%esp)
  802426:	72 2c                	jb     802454 <__umoddi3+0x134>
  802428:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80242c:	72 22                	jb     802450 <__umoddi3+0x130>
  80242e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802432:	29 c8                	sub    %ecx,%eax
  802434:	19 d7                	sbb    %edx,%edi
  802436:	89 e9                	mov    %ebp,%ecx
  802438:	89 fa                	mov    %edi,%edx
  80243a:	d3 e8                	shr    %cl,%eax
  80243c:	89 f1                	mov    %esi,%ecx
  80243e:	d3 e2                	shl    %cl,%edx
  802440:	89 e9                	mov    %ebp,%ecx
  802442:	d3 ef                	shr    %cl,%edi
  802444:	09 d0                	or     %edx,%eax
  802446:	89 fa                	mov    %edi,%edx
  802448:	83 c4 14             	add    $0x14,%esp
  80244b:	5e                   	pop    %esi
  80244c:	5f                   	pop    %edi
  80244d:	5d                   	pop    %ebp
  80244e:	c3                   	ret    
  80244f:	90                   	nop
  802450:	39 d7                	cmp    %edx,%edi
  802452:	75 da                	jne    80242e <__umoddi3+0x10e>
  802454:	8b 14 24             	mov    (%esp),%edx
  802457:	89 c1                	mov    %eax,%ecx
  802459:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80245d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802461:	eb cb                	jmp    80242e <__umoddi3+0x10e>
  802463:	90                   	nop
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80246c:	0f 82 0f ff ff ff    	jb     802381 <__umoddi3+0x61>
  802472:	e9 1a ff ff ff       	jmp    802391 <__umoddi3+0x71>
