
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 95 01 00 00       	call   8001c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 30             	sub    $0x30,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	e9 84 00 00 00       	jmp    8000ca <num+0x97>
		if (bol) {
  800046:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004d:	74 27                	je     800076 <num+0x43>
			printf("%5d ", ++line);
  80004f:	a1 00 40 80 00       	mov    0x804000,%eax
  800054:	83 c0 01             	add    $0x1,%eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800060:	c7 04 24 80 22 80 00 	movl   $0x802280,(%esp)
  800067:	e8 c5 18 00 00       	call   801931 <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 24 13 00 00       	call   8013b2 <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 27                	je     8000ba <num+0x87>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	8b 45 0c             	mov    0xc(%ebp),%eax
  80009a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009e:	c7 44 24 08 85 22 80 	movl   $0x802285,0x8(%esp)
  8000a5:	00 
  8000a6:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000ad:	00 
  8000ae:	c7 04 24 a0 22 80 00 	movl   $0x8022a0,(%esp)
  8000b5:	e8 6d 01 00 00       	call   800227 <_panic>
		if (c == '\n')
  8000ba:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000be:	75 0a                	jne    8000ca <num+0x97>
			bol = 1;
  8000c0:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c7:	00 00 00 
	while ((n = read(f, &c, 1)) > 0) {
  8000ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d1:	00 
  8000d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d6:	89 34 24             	mov    %esi,(%esp)
  8000d9:	e8 f7 11 00 00       	call   8012d5 <read>
  8000de:	85 c0                	test   %eax,%eax
  8000e0:	0f 8f 60 ff ff ff    	jg     800046 <num+0x13>
	}
	if (n < 0)
  8000e6:	85 c0                	test   %eax,%eax
  8000e8:	79 27                	jns    800111 <num+0xde>
		panic("error reading %s: %e", s, n);
  8000ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f5:	c7 44 24 08 ab 22 80 	movl   $0x8022ab,0x8(%esp)
  8000fc:	00 
  8000fd:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  800104:	00 
  800105:	c7 04 24 a0 22 80 00 	movl   $0x8022a0,(%esp)
  80010c:	e8 16 01 00 00       	call   800227 <_panic>
}
  800111:	83 c4 30             	add    $0x30,%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <umain>:

void
umain(int argc, char **argv)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 2c             	sub    $0x2c,%esp
	int f, i;

	binaryname = "num";
  800121:	c7 05 04 30 80 00 c0 	movl   $0x8022c0,0x803004
  800128:	22 80 00 
	if (argc == 1)
  80012b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012f:	74 0d                	je     80013e <umain+0x26>
  800131:	8b 45 0c             	mov    0xc(%ebp),%eax
  800134:	8d 58 04             	lea    0x4(%eax),%ebx
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
  80013c:	eb 76                	jmp    8001b4 <umain+0x9c>
		num(0, "<stdin>");
  80013e:	c7 44 24 04 c4 22 80 	movl   $0x8022c4,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 e1 fe ff ff       	call   800033 <num>
  800152:	eb 65                	jmp    8001b9 <umain+0xa1>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800154:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800157:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80015e:	00 
  80015f:	8b 03                	mov    (%ebx),%eax
  800161:	89 04 24             	mov    %eax,(%esp)
  800164:	e8 18 16 00 00       	call   801781 <open>
  800169:	89 c6                	mov    %eax,%esi
			if (f < 0)
  80016b:	85 c0                	test   %eax,%eax
  80016d:	79 29                	jns    800198 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800176:	8b 00                	mov    (%eax),%eax
  800178:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80017c:	c7 44 24 08 cc 22 80 	movl   $0x8022cc,0x8(%esp)
  800183:	00 
  800184:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80018b:	00 
  80018c:	c7 04 24 a0 22 80 00 	movl   $0x8022a0,(%esp)
  800193:	e8 8f 00 00 00       	call   800227 <_panic>
			else {
				num(f, argv[i]);
  800198:	8b 03                	mov    (%ebx),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	89 34 24             	mov    %esi,(%esp)
  8001a1:	e8 8d fe ff ff       	call   800033 <num>
				close(f);
  8001a6:	89 34 24             	mov    %esi,(%esp)
  8001a9:	e8 c4 0f 00 00       	call   801172 <close>
		for (i = 1; i < argc; i++) {
  8001ae:	83 c7 01             	add    $0x1,%edi
  8001b1:	83 c3 04             	add    $0x4,%ebx
  8001b4:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001b7:	7c 9b                	jl     800154 <umain+0x3c>
			}
		}
	exit();
  8001b9:	e8 50 00 00 00       	call   80020e <exit>
}
  8001be:	83 c4 2c             	add    $0x2c,%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 10             	sub    $0x10,%esp
  8001ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8001d4:	e8 4c 0b 00 00       	call   800d25 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8001d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e6:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001eb:	85 db                	test   %ebx,%ebx
  8001ed:	7e 07                	jle    8001f6 <libmain+0x30>
		binaryname = argv[0];
  8001ef:	8b 06                	mov    (%esi),%eax
  8001f1:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fa:	89 1c 24             	mov    %ebx,(%esp)
  8001fd:	e8 16 ff ff ff       	call   800118 <umain>

	// exit gracefully
	exit();
  800202:	e8 07 00 00 00       	call   80020e <exit>
}
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800214:	e8 8c 0f 00 00       	call   8011a5 <close_all>
	sys_env_destroy(0);
  800219:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800220:	e8 ae 0a 00 00       	call   800cd3 <sys_env_destroy>
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80022f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800232:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800238:	e8 e8 0a 00 00       	call   800d25 <sys_getenvid>
  80023d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800240:	89 54 24 10          	mov    %edx,0x10(%esp)
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80024b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  80025a:	e8 c1 00 00 00       	call   800320 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800263:	8b 45 10             	mov    0x10(%ebp),%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	e8 51 00 00 00       	call   8002bf <vcprintf>
	cprintf("\n");
  80026e:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  800275:	e8 a6 00 00 00       	call   800320 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027a:	cc                   	int3   
  80027b:	eb fd                	jmp    80027a <_panic+0x53>

0080027d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	53                   	push   %ebx
  800281:	83 ec 14             	sub    $0x14,%esp
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800287:	8b 13                	mov    (%ebx),%edx
  800289:	8d 42 01             	lea    0x1(%edx),%eax
  80028c:	89 03                	mov    %eax,(%ebx)
  80028e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800291:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800295:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029a:	75 19                	jne    8002b5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80029c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a3:	00 
  8002a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 e7 09 00 00       	call   800c96 <sys_cputs>
		b->idx = 0;
  8002af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	5b                   	pop    %ebx
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cf:	00 00 00 
	b.cnt = 0;
  8002d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f4:	c7 04 24 7d 02 80 00 	movl   $0x80027d,(%esp)
  8002fb:	e8 ae 01 00 00       	call   8004ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800306:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 7e 09 00 00       	call   800c96 <sys_cputs>

	return b.cnt;
}
  800318:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800326:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	e8 87 ff ff ff       	call   8002bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800338:	c9                   	leave  
  800339:	c3                   	ret    
  80033a:	66 90                	xchg   %ax,%ax
  80033c:	66 90                	xchg   %ax,%ax
  80033e:	66 90                	xchg   %ax,%ax

00800340 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 3c             	sub    $0x3c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d7                	mov    %edx,%edi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 c3                	mov    %eax,%ebx
  800359:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
  800367:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80036d:	39 d9                	cmp    %ebx,%ecx
  80036f:	72 05                	jb     800376 <printnum+0x36>
  800371:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800374:	77 69                	ja     8003df <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800376:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800379:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80037d:	83 ee 01             	sub    $0x1,%esi
  800380:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800384:	89 44 24 08          	mov    %eax,0x8(%esp)
  800388:	8b 44 24 08          	mov    0x8(%esp),%eax
  80038c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800390:	89 c3                	mov    %eax,%ebx
  800392:	89 d6                	mov    %edx,%esi
  800394:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800397:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80039a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80039e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003af:	e8 2c 1c 00 00       	call   801fe0 <__udivdi3>
  8003b4:	89 d9                	mov    %ebx,%ecx
  8003b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003be:	89 04 24             	mov    %eax,(%esp)
  8003c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003c5:	89 fa                	mov    %edi,%edx
  8003c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ca:	e8 71 ff ff ff       	call   800340 <printnum>
  8003cf:	eb 1b                	jmp    8003ec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	ff d3                	call   *%ebx
  8003dd:	eb 03                	jmp    8003e2 <printnum+0xa2>
  8003df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8003e2:	83 ee 01             	sub    $0x1,%esi
  8003e5:	85 f6                	test   %esi,%esi
  8003e7:	7f e8                	jg     8003d1 <printnum+0x91>
  8003e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80040b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040f:	e8 fc 1c 00 00       	call   802110 <__umoddi3>
  800414:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800418:	0f be 80 0b 23 80 00 	movsbl 0x80230b(%eax),%eax
  80041f:	89 04 24             	mov    %eax,(%esp)
  800422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800425:	ff d0                	call   *%eax
}
  800427:	83 c4 3c             	add    $0x3c,%esp
  80042a:	5b                   	pop    %ebx
  80042b:	5e                   	pop    %esi
  80042c:	5f                   	pop    %edi
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800432:	83 fa 01             	cmp    $0x1,%edx
  800435:	7e 0e                	jle    800445 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800437:	8b 10                	mov    (%eax),%edx
  800439:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043c:	89 08                	mov    %ecx,(%eax)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	8b 52 04             	mov    0x4(%edx),%edx
  800443:	eb 22                	jmp    800467 <getuint+0x38>
	else if (lflag)
  800445:	85 d2                	test   %edx,%edx
  800447:	74 10                	je     800459 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
  800457:	eb 0e                	jmp    800467 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045e:	89 08                	mov    %ecx,(%eax)
  800460:	8b 02                	mov    (%edx),%eax
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    

00800469 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800473:	8b 10                	mov    (%eax),%edx
  800475:	3b 50 04             	cmp    0x4(%eax),%edx
  800478:	73 0a                	jae    800484 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047d:	89 08                	mov    %ecx,(%eax)
  80047f:	8b 45 08             	mov    0x8(%ebp),%eax
  800482:	88 02                	mov    %al,(%edx)
}
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <printfmt>:
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80048c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800493:	8b 45 10             	mov    0x10(%ebp),%eax
  800496:	89 44 24 08          	mov    %eax,0x8(%esp)
  80049a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 02 00 00 00       	call   8004ae <vprintfmt>
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    

008004ae <vprintfmt>:
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	57                   	push   %edi
  8004b2:	56                   	push   %esi
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 3c             	sub    $0x3c,%esp
  8004b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004bd:	eb 1f                	jmp    8004de <vprintfmt+0x30>
			if (ch == '\0'){
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	75 0f                	jne    8004d2 <vprintfmt+0x24>
				color = 0x0100;
  8004c3:	c7 05 04 40 80 00 00 	movl   $0x100,0x804004
  8004ca:	01 00 00 
  8004cd:	e9 b3 03 00 00       	jmp    800885 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8004d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d6:	89 04 24             	mov    %eax,(%esp)
  8004d9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004dc:	89 f3                	mov    %esi,%ebx
  8004de:	8d 73 01             	lea    0x1(%ebx),%esi
  8004e1:	0f b6 03             	movzbl (%ebx),%eax
  8004e4:	83 f8 25             	cmp    $0x25,%eax
  8004e7:	75 d6                	jne    8004bf <vprintfmt+0x11>
  8004e9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ed:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004f4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004fb:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800502:	ba 00 00 00 00       	mov    $0x0,%edx
  800507:	eb 1d                	jmp    800526 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800509:	89 de                	mov    %ebx,%esi
			padc = '-';
  80050b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80050f:	eb 15                	jmp    800526 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800511:	89 de                	mov    %ebx,%esi
			padc = '0';
  800513:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800517:	eb 0d                	jmp    800526 <vprintfmt+0x78>
				width = precision, precision = -1;
  800519:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80051c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80051f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8d 5e 01             	lea    0x1(%esi),%ebx
  800529:	0f b6 0e             	movzbl (%esi),%ecx
  80052c:	0f b6 c1             	movzbl %cl,%eax
  80052f:	83 e9 23             	sub    $0x23,%ecx
  800532:	80 f9 55             	cmp    $0x55,%cl
  800535:	0f 87 2a 03 00 00    	ja     800865 <vprintfmt+0x3b7>
  80053b:	0f b6 c9             	movzbl %cl,%ecx
  80053e:	ff 24 8d 40 24 80 00 	jmp    *0x802440(,%ecx,4)
  800545:	89 de                	mov    %ebx,%esi
  800547:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80054c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80054f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800553:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800556:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800559:	83 fb 09             	cmp    $0x9,%ebx
  80055c:	77 36                	ja     800594 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80055e:	83 c6 01             	add    $0x1,%esi
			}
  800561:	eb e9                	jmp    80054c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 48 04             	lea    0x4(%eax),%ecx
  800569:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800571:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800573:	eb 22                	jmp    800597 <vprintfmt+0xe9>
  800575:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	b8 00 00 00 00       	mov    $0x0,%eax
  80057f:	0f 49 c1             	cmovns %ecx,%eax
  800582:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800585:	89 de                	mov    %ebx,%esi
  800587:	eb 9d                	jmp    800526 <vprintfmt+0x78>
  800589:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80058b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800592:	eb 92                	jmp    800526 <vprintfmt+0x78>
  800594:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800597:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059b:	79 89                	jns    800526 <vprintfmt+0x78>
  80059d:	e9 77 ff ff ff       	jmp    800519 <vprintfmt+0x6b>
			lflag++;
  8005a2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8005a7:	e9 7a ff ff ff       	jmp    800526 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005c1:	e9 18 ff ff ff       	jmp    8004de <vprintfmt+0x30>
			err = va_arg(ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	99                   	cltd   
  8005d2:	31 d0                	xor    %edx,%eax
  8005d4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d6:	83 f8 0f             	cmp    $0xf,%eax
  8005d9:	7f 0b                	jg     8005e6 <vprintfmt+0x138>
  8005db:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	75 20                	jne    800606 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  8005e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ea:	c7 44 24 08 23 23 80 	movl   $0x802323,0x8(%esp)
  8005f1:	00 
  8005f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f9:	89 04 24             	mov    %eax,(%esp)
  8005fc:	e8 85 fe ff ff       	call   800486 <printfmt>
  800601:	e9 d8 fe ff ff       	jmp    8004de <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800606:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060a:	c7 44 24 08 fe 26 80 	movl   $0x8026fe,0x8(%esp)
  800611:	00 
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	8b 45 08             	mov    0x8(%ebp),%eax
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	e8 65 fe ff ff       	call   800486 <printfmt>
  800621:	e9 b8 fe ff ff       	jmp    8004de <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800629:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80062c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 50 04             	lea    0x4(%eax),%edx
  800635:	89 55 14             	mov    %edx,0x14(%ebp)
  800638:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80063a:	85 f6                	test   %esi,%esi
  80063c:	b8 1c 23 80 00       	mov    $0x80231c,%eax
  800641:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800644:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800648:	0f 84 97 00 00 00    	je     8006e5 <vprintfmt+0x237>
  80064e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800652:	0f 8e 9b 00 00 00    	jle    8006f3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800658:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065c:	89 34 24             	mov    %esi,(%esp)
  80065f:	e8 c4 02 00 00       	call   800928 <strnlen>
  800664:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800667:	29 c2                	sub    %eax,%edx
  800669:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80066c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800670:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800673:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800676:	8b 75 08             	mov    0x8(%ebp),%esi
  800679:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80067c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80067e:	eb 0f                	jmp    80068f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800680:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800684:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800687:	89 04 24             	mov    %eax,(%esp)
  80068a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068c:	83 eb 01             	sub    $0x1,%ebx
  80068f:	85 db                	test   %ebx,%ebx
  800691:	7f ed                	jg     800680 <vprintfmt+0x1d2>
  800693:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800696:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800699:	85 d2                	test   %edx,%edx
  80069b:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a0:	0f 49 c2             	cmovns %edx,%eax
  8006a3:	29 c2                	sub    %eax,%edx
  8006a5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006a8:	89 d7                	mov    %edx,%edi
  8006aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006ad:	eb 50                	jmp    8006ff <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8006af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b3:	74 1e                	je     8006d3 <vprintfmt+0x225>
  8006b5:	0f be d2             	movsbl %dl,%edx
  8006b8:	83 ea 20             	sub    $0x20,%edx
  8006bb:	83 fa 5e             	cmp    $0x5e,%edx
  8006be:	76 13                	jbe    8006d3 <vprintfmt+0x225>
					putch('?', putdat);
  8006c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
  8006d1:	eb 0d                	jmp    8006e0 <vprintfmt+0x232>
					putch(ch, putdat);
  8006d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e0:	83 ef 01             	sub    $0x1,%edi
  8006e3:	eb 1a                	jmp    8006ff <vprintfmt+0x251>
  8006e5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006e8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006eb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006f1:	eb 0c                	jmp    8006ff <vprintfmt+0x251>
  8006f3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006fc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006ff:	83 c6 01             	add    $0x1,%esi
  800702:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800706:	0f be c2             	movsbl %dl,%eax
  800709:	85 c0                	test   %eax,%eax
  80070b:	74 27                	je     800734 <vprintfmt+0x286>
  80070d:	85 db                	test   %ebx,%ebx
  80070f:	78 9e                	js     8006af <vprintfmt+0x201>
  800711:	83 eb 01             	sub    $0x1,%ebx
  800714:	79 99                	jns    8006af <vprintfmt+0x201>
  800716:	89 f8                	mov    %edi,%eax
  800718:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80071b:	8b 75 08             	mov    0x8(%ebp),%esi
  80071e:	89 c3                	mov    %eax,%ebx
  800720:	eb 1a                	jmp    80073c <vprintfmt+0x28e>
				putch(' ', putdat);
  800722:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800726:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80072d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80072f:	83 eb 01             	sub    $0x1,%ebx
  800732:	eb 08                	jmp    80073c <vprintfmt+0x28e>
  800734:	89 fb                	mov    %edi,%ebx
  800736:	8b 75 08             	mov    0x8(%ebp),%esi
  800739:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80073c:	85 db                	test   %ebx,%ebx
  80073e:	7f e2                	jg     800722 <vprintfmt+0x274>
  800740:	89 75 08             	mov    %esi,0x8(%ebp)
  800743:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800746:	e9 93 fd ff ff       	jmp    8004de <vprintfmt+0x30>
	if (lflag >= 2)
  80074b:	83 fa 01             	cmp    $0x1,%edx
  80074e:	7e 16                	jle    800766 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8d 50 08             	lea    0x8(%eax),%edx
  800756:	89 55 14             	mov    %edx,0x14(%ebp)
  800759:	8b 50 04             	mov    0x4(%eax),%edx
  80075c:	8b 00                	mov    (%eax),%eax
  80075e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800761:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800764:	eb 32                	jmp    800798 <vprintfmt+0x2ea>
	else if (lflag)
  800766:	85 d2                	test   %edx,%edx
  800768:	74 18                	je     800782 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 50 04             	lea    0x4(%eax),%edx
  800770:	89 55 14             	mov    %edx,0x14(%ebp)
  800773:	8b 30                	mov    (%eax),%esi
  800775:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800778:	89 f0                	mov    %esi,%eax
  80077a:	c1 f8 1f             	sar    $0x1f,%eax
  80077d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800780:	eb 16                	jmp    800798 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 50 04             	lea    0x4(%eax),%edx
  800788:	89 55 14             	mov    %edx,0x14(%ebp)
  80078b:	8b 30                	mov    (%eax),%esi
  80078d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800790:	89 f0                	mov    %esi,%eax
  800792:	c1 f8 1f             	sar    $0x1f,%eax
  800795:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800798:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80079b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80079e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8007a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a7:	0f 89 80 00 00 00    	jns    80082d <vprintfmt+0x37f>
				putch('-', putdat);
  8007ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007b8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c1:	f7 d8                	neg    %eax
  8007c3:	83 d2 00             	adc    $0x0,%edx
  8007c6:	f7 da                	neg    %edx
			base = 10;
  8007c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007cd:	eb 5e                	jmp    80082d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 58 fc ff ff       	call   80042f <getuint>
			base = 10;
  8007d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007dc:	eb 4f                	jmp    80082d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e1:	e8 49 fc ff ff       	call   80042f <getuint>
            base = 8;
  8007e6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  8007eb:	eb 40                	jmp    80082d <vprintfmt+0x37f>
			putch('0', putdat);
  8007ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ff:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800806:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8d 50 04             	lea    0x4(%eax),%edx
  80080f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800812:	8b 00                	mov    (%eax),%eax
  800814:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800819:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80081e:	eb 0d                	jmp    80082d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800820:	8d 45 14             	lea    0x14(%ebp),%eax
  800823:	e8 07 fc ff ff       	call   80042f <getuint>
			base = 16;
  800828:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80082d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800831:	89 74 24 10          	mov    %esi,0x10(%esp)
  800835:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800838:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80083c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800840:	89 04 24             	mov    %eax,(%esp)
  800843:	89 54 24 04          	mov    %edx,0x4(%esp)
  800847:	89 fa                	mov    %edi,%edx
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	e8 ef fa ff ff       	call   800340 <printnum>
			break;
  800851:	e9 88 fc ff ff       	jmp    8004de <vprintfmt+0x30>
			putch(ch, putdat);
  800856:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085a:	89 04 24             	mov    %eax,(%esp)
  80085d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800860:	e9 79 fc ff ff       	jmp    8004de <vprintfmt+0x30>
			putch('%', putdat);
  800865:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800869:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800870:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800873:	89 f3                	mov    %esi,%ebx
  800875:	eb 03                	jmp    80087a <vprintfmt+0x3cc>
  800877:	83 eb 01             	sub    $0x1,%ebx
  80087a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80087e:	75 f7                	jne    800877 <vprintfmt+0x3c9>
  800880:	e9 59 fc ff ff       	jmp    8004de <vprintfmt+0x30>
}
  800885:	83 c4 3c             	add    $0x3c,%esp
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5f                   	pop    %edi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	83 ec 28             	sub    $0x28,%esp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800899:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	74 30                	je     8008de <vsnprintf+0x51>
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	7e 2c                	jle    8008de <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8008bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c7:	c7 04 24 69 04 80 00 	movl   $0x800469,(%esp)
  8008ce:	e8 db fb ff ff       	call   8004ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008dc:	eb 05                	jmp    8008e3 <vsnprintf+0x56>
		return -E_INVAL;
  8008de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	e8 82 ff ff ff       	call   80088d <vsnprintf>
	va_end(ap);

	return rc;
}
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    
  80090d:	66 90                	xchg   %ax,%ax
  80090f:	90                   	nop

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 03                	jmp    800920 <strlen+0x10>
		n++;
  80091d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800920:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800924:	75 f7                	jne    80091d <strlen+0xd>
	return n;
}
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
  800936:	eb 03                	jmp    80093b <strnlen+0x13>
		n++;
  800938:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	74 06                	je     800945 <strnlen+0x1d>
  80093f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800943:	75 f3                	jne    800938 <strnlen+0x10>
	return n;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800951:	89 c2                	mov    %eax,%edx
  800953:	83 c2 01             	add    $0x1,%edx
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80095d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800960:	84 db                	test   %bl,%bl
  800962:	75 ef                	jne    800953 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800964:	5b                   	pop    %ebx
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800971:	89 1c 24             	mov    %ebx,(%esp)
  800974:	e8 97 ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800980:	01 d8                	add    %ebx,%eax
  800982:	89 04 24             	mov    %eax,(%esp)
  800985:	e8 bd ff ff ff       	call   800947 <strcpy>
	return dst;
}
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	83 c4 08             	add    $0x8,%esp
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 75 08             	mov    0x8(%ebp),%esi
  80099a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099d:	89 f3                	mov    %esi,%ebx
  80099f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a2:	89 f2                	mov    %esi,%edx
  8009a4:	eb 0f                	jmp    8009b5 <strncpy+0x23>
		*dst++ = *src;
  8009a6:	83 c2 01             	add    $0x1,%edx
  8009a9:	0f b6 01             	movzbl (%ecx),%eax
  8009ac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009af:	80 39 01             	cmpb   $0x1,(%ecx)
  8009b2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009b5:	39 da                	cmp    %ebx,%edx
  8009b7:	75 ed                	jne    8009a6 <strncpy+0x14>
	}
	return ret;
}
  8009b9:	89 f0                	mov    %esi,%eax
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009cd:	89 f0                	mov    %esi,%eax
  8009cf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	75 0b                	jne    8009e2 <strlcpy+0x23>
  8009d7:	eb 1d                	jmp    8009f6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009e2:	39 d8                	cmp    %ebx,%eax
  8009e4:	74 0b                	je     8009f1 <strlcpy+0x32>
  8009e6:	0f b6 0a             	movzbl (%edx),%ecx
  8009e9:	84 c9                	test   %cl,%cl
  8009eb:	75 ec                	jne    8009d9 <strlcpy+0x1a>
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	eb 02                	jmp    8009f3 <strlcpy+0x34>
  8009f1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  8009f3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009f6:	29 f0                	sub    %esi,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a05:	eb 06                	jmp    800a0d <strcmp+0x11>
		p++, q++;
  800a07:	83 c1 01             	add    $0x1,%ecx
  800a0a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a0d:	0f b6 01             	movzbl (%ecx),%eax
  800a10:	84 c0                	test   %al,%al
  800a12:	74 04                	je     800a18 <strcmp+0x1c>
  800a14:	3a 02                	cmp    (%edx),%al
  800a16:	74 ef                	je     800a07 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 c0             	movzbl %al,%eax
  800a1b:	0f b6 12             	movzbl (%edx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a31:	eb 06                	jmp    800a39 <strncmp+0x17>
		n--, p++, q++;
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a39:	39 d8                	cmp    %ebx,%eax
  800a3b:	74 15                	je     800a52 <strncmp+0x30>
  800a3d:	0f b6 08             	movzbl (%eax),%ecx
  800a40:	84 c9                	test   %cl,%cl
  800a42:	74 04                	je     800a48 <strncmp+0x26>
  800a44:	3a 0a                	cmp    (%edx),%cl
  800a46:	74 eb                	je     800a33 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 00             	movzbl (%eax),%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
  800a50:	eb 05                	jmp    800a57 <strncmp+0x35>
		return 0;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a64:	eb 07                	jmp    800a6d <strchr+0x13>
		if (*s == c)
  800a66:	38 ca                	cmp    %cl,%dl
  800a68:	74 0f                	je     800a79 <strchr+0x1f>
	for (; *s; s++)
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 f2                	jne    800a66 <strchr+0xc>
			return (char *) s;
	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a85:	eb 07                	jmp    800a8e <strfind+0x13>
		if (*s == c)
  800a87:	38 ca                	cmp    %cl,%dl
  800a89:	74 0a                	je     800a95 <strfind+0x1a>
	for (; *s; s++)
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	0f b6 10             	movzbl (%eax),%edx
  800a91:	84 d2                	test   %dl,%dl
  800a93:	75 f2                	jne    800a87 <strfind+0xc>
			break;
	return (char *) s;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa3:	85 c9                	test   %ecx,%ecx
  800aa5:	74 36                	je     800add <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aad:	75 28                	jne    800ad7 <memset+0x40>
  800aaf:	f6 c1 03             	test   $0x3,%cl
  800ab2:	75 23                	jne    800ad7 <memset+0x40>
		c &= 0xFF;
  800ab4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	c1 e3 08             	shl    $0x8,%ebx
  800abd:	89 d6                	mov    %edx,%esi
  800abf:	c1 e6 18             	shl    $0x18,%esi
  800ac2:	89 d0                	mov    %edx,%eax
  800ac4:	c1 e0 10             	shl    $0x10,%eax
  800ac7:	09 f0                	or     %esi,%eax
  800ac9:	09 c2                	or     %eax,%edx
  800acb:	89 d0                	mov    %edx,%eax
  800acd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800acf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad2:	fc                   	cld    
  800ad3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad5:	eb 06                	jmp    800add <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ada:	fc                   	cld    
  800adb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800add:	89 f8                	mov    %edi,%eax
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af2:	39 c6                	cmp    %eax,%esi
  800af4:	73 35                	jae    800b2b <memmove+0x47>
  800af6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af9:	39 d0                	cmp    %edx,%eax
  800afb:	73 2e                	jae    800b2b <memmove+0x47>
		s += n;
		d += n;
  800afd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0a:	75 13                	jne    800b1f <memmove+0x3b>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 0e                	jne    800b1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b11:	83 ef 04             	sub    $0x4,%edi
  800b14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb 09                	jmp    800b28 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b1f:	83 ef 01             	sub    $0x1,%edi
  800b22:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b25:	fd                   	std    
  800b26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b28:	fc                   	cld    
  800b29:	eb 1d                	jmp    800b48 <memmove+0x64>
  800b2b:	89 f2                	mov    %esi,%edx
  800b2d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2f:	f6 c2 03             	test   $0x3,%dl
  800b32:	75 0f                	jne    800b43 <memmove+0x5f>
  800b34:	f6 c1 03             	test   $0x3,%cl
  800b37:	75 0a                	jne    800b43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b39:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b3c:	89 c7                	mov    %eax,%edi
  800b3e:	fc                   	cld    
  800b3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b41:	eb 05                	jmp    800b48 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	fc                   	cld    
  800b46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b52:	8b 45 10             	mov    0x10(%ebp),%eax
  800b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	89 04 24             	mov    %eax,(%esp)
  800b66:	e8 79 ff ff ff       	call   800ae4 <memmove>
}
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7d:	eb 1a                	jmp    800b99 <memcmp+0x2c>
		if (*s1 != *s2)
  800b7f:	0f b6 02             	movzbl (%edx),%eax
  800b82:	0f b6 19             	movzbl (%ecx),%ebx
  800b85:	38 d8                	cmp    %bl,%al
  800b87:	74 0a                	je     800b93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b89:	0f b6 c0             	movzbl %al,%eax
  800b8c:	0f b6 db             	movzbl %bl,%ebx
  800b8f:	29 d8                	sub    %ebx,%eax
  800b91:	eb 0f                	jmp    800ba2 <memcmp+0x35>
		s1++, s2++;
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800b99:	39 f2                	cmp    %esi,%edx
  800b9b:	75 e2                	jne    800b7f <memcmp+0x12>
	}

	return 0;
  800b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb4:	eb 07                	jmp    800bbd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb6:	38 08                	cmp    %cl,(%eax)
  800bb8:	74 07                	je     800bc1 <memfind+0x1b>
	for (; s < ends; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	39 d0                	cmp    %edx,%eax
  800bbf:	72 f5                	jb     800bb6 <memfind+0x10>
			break;
	return (void *) s;
}
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcf:	eb 03                	jmp    800bd4 <strtol+0x11>
		s++;
  800bd1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bd4:	0f b6 0a             	movzbl (%edx),%ecx
  800bd7:	80 f9 09             	cmp    $0x9,%cl
  800bda:	74 f5                	je     800bd1 <strtol+0xe>
  800bdc:	80 f9 20             	cmp    $0x20,%cl
  800bdf:	74 f0                	je     800bd1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800be1:	80 f9 2b             	cmp    $0x2b,%cl
  800be4:	75 0a                	jne    800bf0 <strtol+0x2d>
		s++;
  800be6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800be9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bee:	eb 11                	jmp    800c01 <strtol+0x3e>
  800bf0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800bf5:	80 f9 2d             	cmp    $0x2d,%cl
  800bf8:	75 07                	jne    800c01 <strtol+0x3e>
		s++, neg = 1;
  800bfa:	8d 52 01             	lea    0x1(%edx),%edx
  800bfd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c01:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c06:	75 15                	jne    800c1d <strtol+0x5a>
  800c08:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0b:	75 10                	jne    800c1d <strtol+0x5a>
  800c0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c11:	75 0a                	jne    800c1d <strtol+0x5a>
		s += 2, base = 16;
  800c13:	83 c2 02             	add    $0x2,%edx
  800c16:	b8 10 00 00 00       	mov    $0x10,%eax
  800c1b:	eb 10                	jmp    800c2d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	75 0c                	jne    800c2d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c21:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c23:	80 3a 30             	cmpb   $0x30,(%edx)
  800c26:	75 05                	jne    800c2d <strtol+0x6a>
		s++, base = 8;
  800c28:	83 c2 01             	add    $0x1,%edx
  800c2b:	b0 08                	mov    $0x8,%al
		base = 10;
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c35:	0f b6 0a             	movzbl (%edx),%ecx
  800c38:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c3b:	89 f0                	mov    %esi,%eax
  800c3d:	3c 09                	cmp    $0x9,%al
  800c3f:	77 08                	ja     800c49 <strtol+0x86>
			dig = *s - '0';
  800c41:	0f be c9             	movsbl %cl,%ecx
  800c44:	83 e9 30             	sub    $0x30,%ecx
  800c47:	eb 20                	jmp    800c69 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c49:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c4c:	89 f0                	mov    %esi,%eax
  800c4e:	3c 19                	cmp    $0x19,%al
  800c50:	77 08                	ja     800c5a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c52:	0f be c9             	movsbl %cl,%ecx
  800c55:	83 e9 57             	sub    $0x57,%ecx
  800c58:	eb 0f                	jmp    800c69 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c5a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c5d:	89 f0                	mov    %esi,%eax
  800c5f:	3c 19                	cmp    $0x19,%al
  800c61:	77 16                	ja     800c79 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c63:	0f be c9             	movsbl %cl,%ecx
  800c66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c6c:	7d 0f                	jge    800c7d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c75:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c77:	eb bc                	jmp    800c35 <strtol+0x72>
  800c79:	89 d8                	mov    %ebx,%eax
  800c7b:	eb 02                	jmp    800c7f <strtol+0xbc>
  800c7d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c83:	74 05                	je     800c8a <strtol+0xc7>
		*endptr = (char *) s;
  800c85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c88:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c8a:	f7 d8                	neg    %eax
  800c8c:	85 ff                	test   %edi,%edi
  800c8e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 c3                	mov    %eax,%ebx
  800ca9:	89 c7                	mov    %eax,%edi
  800cab:	89 c6                	mov    %eax,%esi
  800cad:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc4:	89 d1                	mov    %edx,%ecx
  800cc6:	89 d3                	mov    %edx,%ebx
  800cc8:	89 d7                	mov    %edx,%edi
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	89 cb                	mov    %ecx,%ebx
  800ceb:	89 cf                	mov    %ecx,%edi
  800ced:	89 ce                	mov    %ecx,%esi
  800cef:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 28                	jle    800d1d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d00:	00 
  800d01:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800d08:	00 
  800d09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d10:	00 
  800d11:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800d18:	e8 0a f5 ff ff       	call   800227 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d1d:	83 c4 2c             	add    $0x2c,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	b8 02 00 00 00       	mov    $0x2,%eax
  800d35:	89 d1                	mov    %edx,%ecx
  800d37:	89 d3                	mov    %edx,%ebx
  800d39:	89 d7                	mov    %edx,%edi
  800d3b:	89 d6                	mov    %edx,%esi
  800d3d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_yield>:

void
sys_yield(void)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d54:	89 d1                	mov    %edx,%ecx
  800d56:	89 d3                	mov    %edx,%ebx
  800d58:	89 d7                	mov    %edx,%edi
  800d5a:	89 d6                	mov    %edx,%esi
  800d5c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d6c:	be 00 00 00 00       	mov    $0x0,%esi
  800d71:	b8 04 00 00 00       	mov    $0x4,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7f:	89 f7                	mov    %esi,%edi
  800d81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 28                	jle    800daf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d92:	00 
  800d93:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800daa:	e8 78 f4 ff ff       	call   800227 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800daf:	83 c4 2c             	add    $0x2c,%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dc0:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd1:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 28                	jle    800e02 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dde:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800dfd:	e8 25 f4 ff ff       	call   800227 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e02:	83 c4 2c             	add    $0x2c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800e50:	e8 d2 f3 ff ff       	call   800227 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 df                	mov    %ebx,%edi
  800e78:	89 de                	mov    %ebx,%esi
  800e7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 28                	jle    800ea8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e84:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800e93:	00 
  800e94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9b:	00 
  800e9c:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800ea3:	e8 7f f3 ff ff       	call   800227 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea8:	83 c4 2c             	add    $0x2c,%esp
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebe:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	89 df                	mov    %ebx,%edi
  800ecb:	89 de                	mov    %ebx,%esi
  800ecd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	7e 28                	jle    800efb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ede:	00 
  800edf:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eee:	00 
  800eef:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800ef6:	e8 2c f3 ff ff       	call   800227 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800efb:	83 c4 2c             	add    $0x2c,%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	89 df                	mov    %ebx,%edi
  800f1e:	89 de                	mov    %ebx,%esi
  800f20:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	7e 28                	jle    800f4e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f31:	00 
  800f32:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800f39:	00 
  800f3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f41:	00 
  800f42:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800f49:	e8 d9 f2 ff ff       	call   800227 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f4e:	83 c4 2c             	add    $0x2c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f5c:	be 00 00 00 00       	mov    $0x0,%esi
  800f61:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f72:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	57                   	push   %edi
  800f7d:	56                   	push   %esi
  800f7e:	53                   	push   %ebx
  800f7f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f87:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8f:	89 cb                	mov    %ecx,%ebx
  800f91:	89 cf                	mov    %ecx,%edi
  800f93:	89 ce                	mov    %ecx,%esi
  800f95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f97:	85 c0                	test   %eax,%eax
  800f99:	7e 28                	jle    800fc3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fa6:	00 
  800fa7:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800fae:	00 
  800faf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb6:	00 
  800fb7:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800fbe:	e8 64 f2 ff ff       	call   800227 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fc3:	83 c4 2c             	add    $0x2c,%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    
  800fcb:	66 90                	xchg   %ax,%ax
  800fcd:	66 90                	xchg   %ax,%ax
  800fcf:	90                   	nop

00800fd0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
}
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800feb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ff0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ffd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801002:	89 c2                	mov    %eax,%edx
  801004:	c1 ea 16             	shr    $0x16,%edx
  801007:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80100e:	f6 c2 01             	test   $0x1,%dl
  801011:	74 11                	je     801024 <fd_alloc+0x2d>
  801013:	89 c2                	mov    %eax,%edx
  801015:	c1 ea 0c             	shr    $0xc,%edx
  801018:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80101f:	f6 c2 01             	test   $0x1,%dl
  801022:	75 09                	jne    80102d <fd_alloc+0x36>
			*fd_store = fd;
  801024:	89 01                	mov    %eax,(%ecx)
			return 0;
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	eb 17                	jmp    801044 <fd_alloc+0x4d>
  80102d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801032:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801037:	75 c9                	jne    801002 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801039:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80103f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80104c:	83 f8 1f             	cmp    $0x1f,%eax
  80104f:	77 36                	ja     801087 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801051:	c1 e0 0c             	shl    $0xc,%eax
  801054:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801059:	89 c2                	mov    %eax,%edx
  80105b:	c1 ea 16             	shr    $0x16,%edx
  80105e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801065:	f6 c2 01             	test   $0x1,%dl
  801068:	74 24                	je     80108e <fd_lookup+0x48>
  80106a:	89 c2                	mov    %eax,%edx
  80106c:	c1 ea 0c             	shr    $0xc,%edx
  80106f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801076:	f6 c2 01             	test   $0x1,%dl
  801079:	74 1a                	je     801095 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80107b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107e:	89 02                	mov    %eax,(%edx)
	return 0;
  801080:	b8 00 00 00 00       	mov    $0x0,%eax
  801085:	eb 13                	jmp    80109a <fd_lookup+0x54>
		return -E_INVAL;
  801087:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80108c:	eb 0c                	jmp    80109a <fd_lookup+0x54>
		return -E_INVAL;
  80108e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801093:	eb 05                	jmp    80109a <fd_lookup+0x54>
  801095:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 18             	sub    $0x18,%esp
  8010a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a5:	ba ac 26 80 00       	mov    $0x8026ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010aa:	eb 13                	jmp    8010bf <dev_lookup+0x23>
  8010ac:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010af:	39 08                	cmp    %ecx,(%eax)
  8010b1:	75 0c                	jne    8010bf <dev_lookup+0x23>
			*dev = devtab[i];
  8010b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bd:	eb 30                	jmp    8010ef <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8010bf:	8b 02                	mov    (%edx),%eax
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	75 e7                	jne    8010ac <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010c5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010ca:	8b 40 48             	mov    0x48(%eax),%eax
  8010cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d5:	c7 04 24 2c 26 80 00 	movl   $0x80262c,(%esp)
  8010dc:	e8 3f f2 ff ff       	call   800320 <cprintf>
	*dev = 0;
  8010e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <fd_close>:
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 20             	sub    $0x20,%esp
  8010f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801102:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801106:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80110c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80110f:	89 04 24             	mov    %eax,(%esp)
  801112:	e8 2f ff ff ff       	call   801046 <fd_lookup>
  801117:	85 c0                	test   %eax,%eax
  801119:	78 05                	js     801120 <fd_close+0x2f>
	    || fd != fd2)
  80111b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80111e:	74 0c                	je     80112c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801120:	84 db                	test   %bl,%bl
  801122:	ba 00 00 00 00       	mov    $0x0,%edx
  801127:	0f 44 c2             	cmove  %edx,%eax
  80112a:	eb 3f                	jmp    80116b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80112c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801133:	8b 06                	mov    (%esi),%eax
  801135:	89 04 24             	mov    %eax,(%esp)
  801138:	e8 5f ff ff ff       	call   80109c <dev_lookup>
  80113d:	89 c3                	mov    %eax,%ebx
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 16                	js     801159 <fd_close+0x68>
		if (dev->dev_close)
  801143:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801146:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801149:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80114e:	85 c0                	test   %eax,%eax
  801150:	74 07                	je     801159 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801152:	89 34 24             	mov    %esi,(%esp)
  801155:	ff d0                	call   *%eax
  801157:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801159:	89 74 24 04          	mov    %esi,0x4(%esp)
  80115d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801164:	e8 a1 fc ff ff       	call   800e0a <sys_page_unmap>
	return r;
  801169:	89 d8                	mov    %ebx,%eax
}
  80116b:	83 c4 20             	add    $0x20,%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <close>:

int
close(int fdnum)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801178:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	89 04 24             	mov    %eax,(%esp)
  801185:	e8 bc fe ff ff       	call   801046 <fd_lookup>
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	85 d2                	test   %edx,%edx
  80118e:	78 13                	js     8011a3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801190:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801197:	00 
  801198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119b:	89 04 24             	mov    %eax,(%esp)
  80119e:	e8 4e ff ff ff       	call   8010f1 <fd_close>
}
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <close_all>:

void
close_all(void)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011b1:	89 1c 24             	mov    %ebx,(%esp)
  8011b4:	e8 b9 ff ff ff       	call   801172 <close>
	for (i = 0; i < MAXFD; i++)
  8011b9:	83 c3 01             	add    $0x1,%ebx
  8011bc:	83 fb 20             	cmp    $0x20,%ebx
  8011bf:	75 f0                	jne    8011b1 <close_all+0xc>
}
  8011c1:	83 c4 14             	add    $0x14,%esp
  8011c4:	5b                   	pop    %ebx
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	89 04 24             	mov    %eax,(%esp)
  8011dd:	e8 64 fe ff ff       	call   801046 <fd_lookup>
  8011e2:	89 c2                	mov    %eax,%edx
  8011e4:	85 d2                	test   %edx,%edx
  8011e6:	0f 88 e1 00 00 00    	js     8012cd <dup+0x106>
		return r;
	close(newfdnum);
  8011ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ef:	89 04 24             	mov    %eax,(%esp)
  8011f2:	e8 7b ff ff ff       	call   801172 <close>

	newfd = INDEX2FD(newfdnum);
  8011f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011fa:	c1 e3 0c             	shl    $0xc,%ebx
  8011fd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801203:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 d2 fd ff ff       	call   800fe0 <fd2data>
  80120e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801210:	89 1c 24             	mov    %ebx,(%esp)
  801213:	e8 c8 fd ff ff       	call   800fe0 <fd2data>
  801218:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80121a:	89 f0                	mov    %esi,%eax
  80121c:	c1 e8 16             	shr    $0x16,%eax
  80121f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801226:	a8 01                	test   $0x1,%al
  801228:	74 43                	je     80126d <dup+0xa6>
  80122a:	89 f0                	mov    %esi,%eax
  80122c:	c1 e8 0c             	shr    $0xc,%eax
  80122f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801236:	f6 c2 01             	test   $0x1,%dl
  801239:	74 32                	je     80126d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80123b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801242:	25 07 0e 00 00       	and    $0xe07,%eax
  801247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80124b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80124f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801256:	00 
  801257:	89 74 24 04          	mov    %esi,0x4(%esp)
  80125b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801262:	e8 50 fb ff ff       	call   800db7 <sys_page_map>
  801267:	89 c6                	mov    %eax,%esi
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 3e                	js     8012ab <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80126d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801270:	89 c2                	mov    %eax,%edx
  801272:	c1 ea 0c             	shr    $0xc,%edx
  801275:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801282:	89 54 24 10          	mov    %edx,0x10(%esp)
  801286:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80128a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801291:	00 
  801292:	89 44 24 04          	mov    %eax,0x4(%esp)
  801296:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80129d:	e8 15 fb ff ff       	call   800db7 <sys_page_map>
  8012a2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8012a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012a7:	85 f6                	test   %esi,%esi
  8012a9:	79 22                	jns    8012cd <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8012ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b6:	e8 4f fb ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c6:	e8 3f fb ff ff       	call   800e0a <sys_page_unmap>
	return r;
  8012cb:	89 f0                	mov    %esi,%eax
}
  8012cd:	83 c4 3c             	add    $0x3c,%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 24             	sub    $0x24,%esp
  8012dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e6:	89 1c 24             	mov    %ebx,(%esp)
  8012e9:	e8 58 fd ff ff       	call   801046 <fd_lookup>
  8012ee:	89 c2                	mov    %eax,%edx
  8012f0:	85 d2                	test   %edx,%edx
  8012f2:	78 6d                	js     801361 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fe:	8b 00                	mov    (%eax),%eax
  801300:	89 04 24             	mov    %eax,(%esp)
  801303:	e8 94 fd ff ff       	call   80109c <dev_lookup>
  801308:	85 c0                	test   %eax,%eax
  80130a:	78 55                	js     801361 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80130c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130f:	8b 50 08             	mov    0x8(%eax),%edx
  801312:	83 e2 03             	and    $0x3,%edx
  801315:	83 fa 01             	cmp    $0x1,%edx
  801318:	75 23                	jne    80133d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80131a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80131f:	8b 40 48             	mov    0x48(%eax),%eax
  801322:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132a:	c7 04 24 70 26 80 00 	movl   $0x802670,(%esp)
  801331:	e8 ea ef ff ff       	call   800320 <cprintf>
		return -E_INVAL;
  801336:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133b:	eb 24                	jmp    801361 <read+0x8c>
	}
	if (!dev->dev_read)
  80133d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801340:	8b 52 08             	mov    0x8(%edx),%edx
  801343:	85 d2                	test   %edx,%edx
  801345:	74 15                	je     80135c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801347:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80134a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80134e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801351:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	ff d2                	call   *%edx
  80135a:	eb 05                	jmp    801361 <read+0x8c>
		return -E_NOT_SUPP;
  80135c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801361:	83 c4 24             	add    $0x24,%esp
  801364:	5b                   	pop    %ebx
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	57                   	push   %edi
  80136b:	56                   	push   %esi
  80136c:	53                   	push   %ebx
  80136d:	83 ec 1c             	sub    $0x1c,%esp
  801370:	8b 7d 08             	mov    0x8(%ebp),%edi
  801373:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801376:	bb 00 00 00 00       	mov    $0x0,%ebx
  80137b:	eb 23                	jmp    8013a0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80137d:	89 f0                	mov    %esi,%eax
  80137f:	29 d8                	sub    %ebx,%eax
  801381:	89 44 24 08          	mov    %eax,0x8(%esp)
  801385:	89 d8                	mov    %ebx,%eax
  801387:	03 45 0c             	add    0xc(%ebp),%eax
  80138a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138e:	89 3c 24             	mov    %edi,(%esp)
  801391:	e8 3f ff ff ff       	call   8012d5 <read>
		if (m < 0)
  801396:	85 c0                	test   %eax,%eax
  801398:	78 10                	js     8013aa <readn+0x43>
			return m;
		if (m == 0)
  80139a:	85 c0                	test   %eax,%eax
  80139c:	74 0a                	je     8013a8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80139e:	01 c3                	add    %eax,%ebx
  8013a0:	39 f3                	cmp    %esi,%ebx
  8013a2:	72 d9                	jb     80137d <readn+0x16>
  8013a4:	89 d8                	mov    %ebx,%eax
  8013a6:	eb 02                	jmp    8013aa <readn+0x43>
  8013a8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013aa:	83 c4 1c             	add    $0x1c,%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5e                   	pop    %esi
  8013af:	5f                   	pop    %edi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 24             	sub    $0x24,%esp
  8013b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c3:	89 1c 24             	mov    %ebx,(%esp)
  8013c6:	e8 7b fc ff ff       	call   801046 <fd_lookup>
  8013cb:	89 c2                	mov    %eax,%edx
  8013cd:	85 d2                	test   %edx,%edx
  8013cf:	78 68                	js     801439 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013db:	8b 00                	mov    (%eax),%eax
  8013dd:	89 04 24             	mov    %eax,(%esp)
  8013e0:	e8 b7 fc ff ff       	call   80109c <dev_lookup>
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 50                	js     801439 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013f0:	75 23                	jne    801415 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013f7:	8b 40 48             	mov    0x48(%eax),%eax
  8013fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801402:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  801409:	e8 12 ef ff ff       	call   800320 <cprintf>
		return -E_INVAL;
  80140e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801413:	eb 24                	jmp    801439 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801415:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801418:	8b 52 0c             	mov    0xc(%edx),%edx
  80141b:	85 d2                	test   %edx,%edx
  80141d:	74 15                	je     801434 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80141f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801422:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801426:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801429:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	ff d2                	call   *%edx
  801432:	eb 05                	jmp    801439 <write+0x87>
		return -E_NOT_SUPP;
  801434:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801439:	83 c4 24             	add    $0x24,%esp
  80143c:	5b                   	pop    %ebx
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <seek>:

int
seek(int fdnum, off_t offset)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801445:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	89 04 24             	mov    %eax,(%esp)
  801452:	e8 ef fb ff ff       	call   801046 <fd_lookup>
  801457:	85 c0                	test   %eax,%eax
  801459:	78 0e                	js     801469 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80145b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80145e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801461:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801464:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	53                   	push   %ebx
  80146f:	83 ec 24             	sub    $0x24,%esp
  801472:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801475:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147c:	89 1c 24             	mov    %ebx,(%esp)
  80147f:	e8 c2 fb ff ff       	call   801046 <fd_lookup>
  801484:	89 c2                	mov    %eax,%edx
  801486:	85 d2                	test   %edx,%edx
  801488:	78 61                	js     8014eb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801491:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801494:	8b 00                	mov    (%eax),%eax
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	e8 fe fb ff ff       	call   80109c <dev_lookup>
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 49                	js     8014eb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a9:	75 23                	jne    8014ce <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014ab:	a1 0c 40 80 00       	mov    0x80400c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014b0:	8b 40 48             	mov    0x48(%eax),%eax
  8014b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bb:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  8014c2:	e8 59 ee ff ff       	call   800320 <cprintf>
		return -E_INVAL;
  8014c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cc:	eb 1d                	jmp    8014eb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8014ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d1:	8b 52 18             	mov    0x18(%edx),%edx
  8014d4:	85 d2                	test   %edx,%edx
  8014d6:	74 0e                	je     8014e6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014df:	89 04 24             	mov    %eax,(%esp)
  8014e2:	ff d2                	call   *%edx
  8014e4:	eb 05                	jmp    8014eb <ftruncate+0x80>
		return -E_NOT_SUPP;
  8014e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014eb:	83 c4 24             	add    $0x24,%esp
  8014ee:	5b                   	pop    %ebx
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    

008014f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 24             	sub    $0x24,%esp
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801502:	8b 45 08             	mov    0x8(%ebp),%eax
  801505:	89 04 24             	mov    %eax,(%esp)
  801508:	e8 39 fb ff ff       	call   801046 <fd_lookup>
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	85 d2                	test   %edx,%edx
  801511:	78 52                	js     801565 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	8b 00                	mov    (%eax),%eax
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	e8 75 fb ff ff       	call   80109c <dev_lookup>
  801527:	85 c0                	test   %eax,%eax
  801529:	78 3a                	js     801565 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80152b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801532:	74 2c                	je     801560 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801534:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801537:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80153e:	00 00 00 
	stat->st_isdir = 0;
  801541:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801548:	00 00 00 
	stat->st_dev = dev;
  80154b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801551:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801555:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801558:	89 14 24             	mov    %edx,(%esp)
  80155b:	ff 50 14             	call   *0x14(%eax)
  80155e:	eb 05                	jmp    801565 <fstat+0x74>
		return -E_NOT_SUPP;
  801560:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801565:	83 c4 24             	add    $0x24,%esp
  801568:	5b                   	pop    %ebx
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801573:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80157a:	00 
  80157b:	8b 45 08             	mov    0x8(%ebp),%eax
  80157e:	89 04 24             	mov    %eax,(%esp)
  801581:	e8 fb 01 00 00       	call   801781 <open>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	85 db                	test   %ebx,%ebx
  80158a:	78 1b                	js     8015a7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80158c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801593:	89 1c 24             	mov    %ebx,(%esp)
  801596:	e8 56 ff ff ff       	call   8014f1 <fstat>
  80159b:	89 c6                	mov    %eax,%esi
	close(fd);
  80159d:	89 1c 24             	mov    %ebx,(%esp)
  8015a0:	e8 cd fb ff ff       	call   801172 <close>
	return r;
  8015a5:	89 f0                	mov    %esi,%eax
}
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    

008015ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	56                   	push   %esi
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 10             	sub    $0x10,%esp
  8015b6:	89 c6                	mov    %eax,%esi
  8015b8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015ba:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  8015c1:	75 11                	jne    8015d4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015ca:	e8 90 09 00 00       	call   801f5f <ipc_find_env>
  8015cf:	a3 08 40 80 00       	mov    %eax,0x804008
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015d4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015db:	00 
  8015dc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015e3:	00 
  8015e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ed:	89 04 24             	mov    %eax,(%esp)
  8015f0:	e8 03 09 00 00       	call   801ef8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015fc:	00 
  8015fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801601:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801608:	e8 83 08 00 00       	call   801e90 <ipc_recv>
}
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80161a:	8b 45 08             	mov    0x8(%ebp),%eax
  80161d:	8b 40 0c             	mov    0xc(%eax),%eax
  801620:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801625:	8b 45 0c             	mov    0xc(%ebp),%eax
  801628:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	b8 02 00 00 00       	mov    $0x2,%eax
  801637:	e8 72 ff ff ff       	call   8015ae <fsipc>
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <devfile_flush>:
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801644:	8b 45 08             	mov    0x8(%ebp),%eax
  801647:	8b 40 0c             	mov    0xc(%eax),%eax
  80164a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80164f:	ba 00 00 00 00       	mov    $0x0,%edx
  801654:	b8 06 00 00 00       	mov    $0x6,%eax
  801659:	e8 50 ff ff ff       	call   8015ae <fsipc>
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <devfile_stat>:
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	53                   	push   %ebx
  801664:	83 ec 14             	sub    $0x14,%esp
  801667:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80166a:	8b 45 08             	mov    0x8(%ebp),%eax
  80166d:	8b 40 0c             	mov    0xc(%eax),%eax
  801670:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801675:	ba 00 00 00 00       	mov    $0x0,%edx
  80167a:	b8 05 00 00 00       	mov    $0x5,%eax
  80167f:	e8 2a ff ff ff       	call   8015ae <fsipc>
  801684:	89 c2                	mov    %eax,%edx
  801686:	85 d2                	test   %edx,%edx
  801688:	78 2b                	js     8016b5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80168a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801691:	00 
  801692:	89 1c 24             	mov    %ebx,(%esp)
  801695:	e8 ad f2 ff ff       	call   800947 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169a:	a1 80 50 80 00       	mov    0x805080,%eax
  80169f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a5:	a1 84 50 80 00       	mov    0x805084,%eax
  8016aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b5:	83 c4 14             	add    $0x14,%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <devfile_write>:
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  8016c1:	c7 44 24 08 bc 26 80 	movl   $0x8026bc,0x8(%esp)
  8016c8:	00 
  8016c9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016d0:	00 
  8016d1:	c7 04 24 da 26 80 00 	movl   $0x8026da,(%esp)
  8016d8:	e8 4a eb ff ff       	call   800227 <_panic>

008016dd <devfile_read>:
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	56                   	push   %esi
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 10             	sub    $0x10,%esp
  8016e5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016f3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	b8 03 00 00 00       	mov    $0x3,%eax
  801703:	e8 a6 fe ff ff       	call   8015ae <fsipc>
  801708:	89 c3                	mov    %eax,%ebx
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 6a                	js     801778 <devfile_read+0x9b>
	assert(r <= n);
  80170e:	39 c6                	cmp    %eax,%esi
  801710:	73 24                	jae    801736 <devfile_read+0x59>
  801712:	c7 44 24 0c e5 26 80 	movl   $0x8026e5,0xc(%esp)
  801719:	00 
  80171a:	c7 44 24 08 ec 26 80 	movl   $0x8026ec,0x8(%esp)
  801721:	00 
  801722:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801729:	00 
  80172a:	c7 04 24 da 26 80 00 	movl   $0x8026da,(%esp)
  801731:	e8 f1 ea ff ff       	call   800227 <_panic>
	assert(r <= PGSIZE);
  801736:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80173b:	7e 24                	jle    801761 <devfile_read+0x84>
  80173d:	c7 44 24 0c 01 27 80 	movl   $0x802701,0xc(%esp)
  801744:	00 
  801745:	c7 44 24 08 ec 26 80 	movl   $0x8026ec,0x8(%esp)
  80174c:	00 
  80174d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801754:	00 
  801755:	c7 04 24 da 26 80 00 	movl   $0x8026da,(%esp)
  80175c:	e8 c6 ea ff ff       	call   800227 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801761:	89 44 24 08          	mov    %eax,0x8(%esp)
  801765:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80176c:	00 
  80176d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801770:	89 04 24             	mov    %eax,(%esp)
  801773:	e8 6c f3 ff ff       	call   800ae4 <memmove>
}
  801778:	89 d8                	mov    %ebx,%eax
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <open>:
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 24             	sub    $0x24,%esp
  801788:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80178b:	89 1c 24             	mov    %ebx,(%esp)
  80178e:	e8 7d f1 ff ff       	call   800910 <strlen>
  801793:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801798:	7f 60                	jg     8017fa <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80179a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179d:	89 04 24             	mov    %eax,(%esp)
  8017a0:	e8 52 f8 ff ff       	call   800ff7 <fd_alloc>
  8017a5:	89 c2                	mov    %eax,%edx
  8017a7:	85 d2                	test   %edx,%edx
  8017a9:	78 54                	js     8017ff <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8017ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017af:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017b6:	e8 8c f1 ff ff       	call   800947 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017be:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017cb:	e8 de fd ff ff       	call   8015ae <fsipc>
  8017d0:	89 c3                	mov    %eax,%ebx
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	79 17                	jns    8017ed <open+0x6c>
		fd_close(fd, 0);
  8017d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017dd:	00 
  8017de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e1:	89 04 24             	mov    %eax,(%esp)
  8017e4:	e8 08 f9 ff ff       	call   8010f1 <fd_close>
		return r;
  8017e9:	89 d8                	mov    %ebx,%eax
  8017eb:	eb 12                	jmp    8017ff <open+0x7e>
	return fd2num(fd);
  8017ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f0:	89 04 24             	mov    %eax,(%esp)
  8017f3:	e8 d8 f7 ff ff       	call   800fd0 <fd2num>
  8017f8:	eb 05                	jmp    8017ff <open+0x7e>
		return -E_BAD_PATH;
  8017fa:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8017ff:	83 c4 24             	add    $0x24,%esp
  801802:	5b                   	pop    %ebx
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80180b:	ba 00 00 00 00       	mov    $0x0,%edx
  801810:	b8 08 00 00 00       	mov    $0x8,%eax
  801815:	e8 94 fd ff ff       	call   8015ae <fsipc>
}
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	53                   	push   %ebx
  801820:	83 ec 14             	sub    $0x14,%esp
  801823:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801825:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801829:	7e 31                	jle    80185c <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80182b:	8b 40 04             	mov    0x4(%eax),%eax
  80182e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801832:	8d 43 10             	lea    0x10(%ebx),%eax
  801835:	89 44 24 04          	mov    %eax,0x4(%esp)
  801839:	8b 03                	mov    (%ebx),%eax
  80183b:	89 04 24             	mov    %eax,(%esp)
  80183e:	e8 6f fb ff ff       	call   8013b2 <write>
		if (result > 0)
  801843:	85 c0                	test   %eax,%eax
  801845:	7e 03                	jle    80184a <writebuf+0x2e>
			b->result += result;
  801847:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80184a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80184d:	74 0d                	je     80185c <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  80184f:	85 c0                	test   %eax,%eax
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	0f 4f c2             	cmovg  %edx,%eax
  801859:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80185c:	83 c4 14             	add    $0x14,%esp
  80185f:	5b                   	pop    %ebx
  801860:	5d                   	pop    %ebp
  801861:	c3                   	ret    

00801862 <putch>:

static void
putch(int ch, void *thunk)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80186c:	8b 53 04             	mov    0x4(%ebx),%edx
  80186f:	8d 42 01             	lea    0x1(%edx),%eax
  801872:	89 43 04             	mov    %eax,0x4(%ebx)
  801875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801878:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80187c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801881:	75 0e                	jne    801891 <putch+0x2f>
		writebuf(b);
  801883:	89 d8                	mov    %ebx,%eax
  801885:	e8 92 ff ff ff       	call   80181c <writebuf>
		b->idx = 0;
  80188a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801891:	83 c4 04             	add    $0x4,%esp
  801894:	5b                   	pop    %ebx
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018a9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018b0:	00 00 00 
	b.result = 0;
  8018b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018ba:	00 00 00 
	b.error = 1;
  8018bd:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018c4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018df:	c7 04 24 62 18 80 00 	movl   $0x801862,(%esp)
  8018e6:	e8 c3 eb ff ff       	call   8004ae <vprintfmt>
	if (b.idx > 0)
  8018eb:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018f2:	7e 0b                	jle    8018ff <vfprintf+0x68>
		writebuf(&b);
  8018f4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018fa:	e8 1d ff ff ff       	call   80181c <writebuf>

	return (b.result ? b.result : b.error);
  8018ff:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801905:	85 c0                	test   %eax,%eax
  801907:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801916:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801919:	89 44 24 08          	mov    %eax,0x8(%esp)
  80191d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801920:	89 44 24 04          	mov    %eax,0x4(%esp)
  801924:	8b 45 08             	mov    0x8(%ebp),%eax
  801927:	89 04 24             	mov    %eax,(%esp)
  80192a:	e8 68 ff ff ff       	call   801897 <vfprintf>
	va_end(ap);

	return cnt;
}
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <printf>:

int
printf(const char *fmt, ...)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801937:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80193a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80193e:	8b 45 08             	mov    0x8(%ebp),%eax
  801941:	89 44 24 04          	mov    %eax,0x4(%esp)
  801945:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80194c:	e8 46 ff ff ff       	call   801897 <vfprintf>
	va_end(ap);

	return cnt;
}
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	83 ec 10             	sub    $0x10,%esp
  80195b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	89 04 24             	mov    %eax,(%esp)
  801964:	e8 77 f6 ff ff       	call   800fe0 <fd2data>
  801969:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80196b:	c7 44 24 04 0d 27 80 	movl   $0x80270d,0x4(%esp)
  801972:	00 
  801973:	89 1c 24             	mov    %ebx,(%esp)
  801976:	e8 cc ef ff ff       	call   800947 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80197b:	8b 46 04             	mov    0x4(%esi),%eax
  80197e:	2b 06                	sub    (%esi),%eax
  801980:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801986:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80198d:	00 00 00 
	stat->st_dev = &devpipe;
  801990:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801997:	30 80 00 
	return 0;
}
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	5b                   	pop    %ebx
  8019a3:	5e                   	pop    %esi
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 14             	sub    $0x14,%esp
  8019ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019bb:	e8 4a f4 ff ff       	call   800e0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019c0:	89 1c 24             	mov    %ebx,(%esp)
  8019c3:	e8 18 f6 ff ff       	call   800fe0 <fd2data>
  8019c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d3:	e8 32 f4 ff ff       	call   800e0a <sys_page_unmap>
}
  8019d8:	83 c4 14             	add    $0x14,%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <_pipeisclosed>:
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	57                   	push   %edi
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 2c             	sub    $0x2c,%esp
  8019e7:	89 c6                	mov    %eax,%esi
  8019e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8019ec:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8019f1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019f4:	89 34 24             	mov    %esi,(%esp)
  8019f7:	e8 9b 05 00 00       	call   801f97 <pageref>
  8019fc:	89 c7                	mov    %eax,%edi
  8019fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a01:	89 04 24             	mov    %eax,(%esp)
  801a04:	e8 8e 05 00 00       	call   801f97 <pageref>
  801a09:	39 c7                	cmp    %eax,%edi
  801a0b:	0f 94 c2             	sete   %dl
  801a0e:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a11:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  801a17:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a1a:	39 fb                	cmp    %edi,%ebx
  801a1c:	74 21                	je     801a3f <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801a1e:	84 d2                	test   %dl,%dl
  801a20:	74 ca                	je     8019ec <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a22:	8b 51 58             	mov    0x58(%ecx),%edx
  801a25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a29:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a31:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  801a38:	e8 e3 e8 ff ff       	call   800320 <cprintf>
  801a3d:	eb ad                	jmp    8019ec <_pipeisclosed+0xe>
}
  801a3f:	83 c4 2c             	add    $0x2c,%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5e                   	pop    %esi
  801a44:	5f                   	pop    %edi
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <devpipe_write>:
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	57                   	push   %edi
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	83 ec 1c             	sub    $0x1c,%esp
  801a50:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a53:	89 34 24             	mov    %esi,(%esp)
  801a56:	e8 85 f5 ff ff       	call   800fe0 <fd2data>
  801a5b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a5d:	bf 00 00 00 00       	mov    $0x0,%edi
  801a62:	eb 45                	jmp    801aa9 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801a64:	89 da                	mov    %ebx,%edx
  801a66:	89 f0                	mov    %esi,%eax
  801a68:	e8 71 ff ff ff       	call   8019de <_pipeisclosed>
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	75 41                	jne    801ab2 <devpipe_write+0x6b>
			sys_yield();
  801a71:	e8 ce f2 ff ff       	call   800d44 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a76:	8b 43 04             	mov    0x4(%ebx),%eax
  801a79:	8b 0b                	mov    (%ebx),%ecx
  801a7b:	8d 51 20             	lea    0x20(%ecx),%edx
  801a7e:	39 d0                	cmp    %edx,%eax
  801a80:	73 e2                	jae    801a64 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a85:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a89:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a8c:	99                   	cltd   
  801a8d:	c1 ea 1b             	shr    $0x1b,%edx
  801a90:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801a93:	83 e1 1f             	and    $0x1f,%ecx
  801a96:	29 d1                	sub    %edx,%ecx
  801a98:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801a9c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801aa0:	83 c0 01             	add    $0x1,%eax
  801aa3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801aa6:	83 c7 01             	add    $0x1,%edi
  801aa9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aac:	75 c8                	jne    801a76 <devpipe_write+0x2f>
	return i;
  801aae:	89 f8                	mov    %edi,%eax
  801ab0:	eb 05                	jmp    801ab7 <devpipe_write+0x70>
				return 0;
  801ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab7:	83 c4 1c             	add    $0x1c,%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5f                   	pop    %edi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <devpipe_read>:
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	57                   	push   %edi
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 1c             	sub    $0x1c,%esp
  801ac8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801acb:	89 3c 24             	mov    %edi,(%esp)
  801ace:	e8 0d f5 ff ff       	call   800fe0 <fd2data>
  801ad3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ad5:	be 00 00 00 00       	mov    $0x0,%esi
  801ada:	eb 3d                	jmp    801b19 <devpipe_read+0x5a>
			if (i > 0)
  801adc:	85 f6                	test   %esi,%esi
  801ade:	74 04                	je     801ae4 <devpipe_read+0x25>
				return i;
  801ae0:	89 f0                	mov    %esi,%eax
  801ae2:	eb 43                	jmp    801b27 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801ae4:	89 da                	mov    %ebx,%edx
  801ae6:	89 f8                	mov    %edi,%eax
  801ae8:	e8 f1 fe ff ff       	call   8019de <_pipeisclosed>
  801aed:	85 c0                	test   %eax,%eax
  801aef:	75 31                	jne    801b22 <devpipe_read+0x63>
			sys_yield();
  801af1:	e8 4e f2 ff ff       	call   800d44 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801af6:	8b 03                	mov    (%ebx),%eax
  801af8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801afb:	74 df                	je     801adc <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801afd:	99                   	cltd   
  801afe:	c1 ea 1b             	shr    $0x1b,%edx
  801b01:	01 d0                	add    %edx,%eax
  801b03:	83 e0 1f             	and    $0x1f,%eax
  801b06:	29 d0                	sub    %edx,%eax
  801b08:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b10:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b13:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b16:	83 c6 01             	add    $0x1,%esi
  801b19:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b1c:	75 d8                	jne    801af6 <devpipe_read+0x37>
	return i;
  801b1e:	89 f0                	mov    %esi,%eax
  801b20:	eb 05                	jmp    801b27 <devpipe_read+0x68>
				return 0;
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b27:	83 c4 1c             	add    $0x1c,%esp
  801b2a:	5b                   	pop    %ebx
  801b2b:	5e                   	pop    %esi
  801b2c:	5f                   	pop    %edi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <pipe>:
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3a:	89 04 24             	mov    %eax,(%esp)
  801b3d:	e8 b5 f4 ff ff       	call   800ff7 <fd_alloc>
  801b42:	89 c2                	mov    %eax,%edx
  801b44:	85 d2                	test   %edx,%edx
  801b46:	0f 88 4d 01 00 00    	js     801c99 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b53:	00 
  801b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b62:	e8 fc f1 ff ff       	call   800d63 <sys_page_alloc>
  801b67:	89 c2                	mov    %eax,%edx
  801b69:	85 d2                	test   %edx,%edx
  801b6b:	0f 88 28 01 00 00    	js     801c99 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801b71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b74:	89 04 24             	mov    %eax,(%esp)
  801b77:	e8 7b f4 ff ff       	call   800ff7 <fd_alloc>
  801b7c:	89 c3                	mov    %eax,%ebx
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	0f 88 fe 00 00 00    	js     801c84 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b86:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b8d:	00 
  801b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b9c:	e8 c2 f1 ff ff       	call   800d63 <sys_page_alloc>
  801ba1:	89 c3                	mov    %eax,%ebx
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 d9 00 00 00    	js     801c84 <pipe+0x155>
	va = fd2data(fd0);
  801bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bae:	89 04 24             	mov    %eax,(%esp)
  801bb1:	e8 2a f4 ff ff       	call   800fe0 <fd2data>
  801bb6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bbf:	00 
  801bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bcb:	e8 93 f1 ff ff       	call   800d63 <sys_page_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	0f 88 97 00 00 00    	js     801c71 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bdd:	89 04 24             	mov    %eax,(%esp)
  801be0:	e8 fb f3 ff ff       	call   800fe0 <fd2data>
  801be5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801bec:	00 
  801bed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bf8:	00 
  801bf9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c04:	e8 ae f1 ff ff       	call   800db7 <sys_page_map>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 52                	js     801c61 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801c0f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c18:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c24:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c32:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3c:	89 04 24             	mov    %eax,(%esp)
  801c3f:	e8 8c f3 ff ff       	call   800fd0 <fd2num>
  801c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c47:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 7c f3 ff ff       	call   800fd0 <fd2num>
  801c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c57:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5f:	eb 38                	jmp    801c99 <pipe+0x16a>
	sys_page_unmap(0, va);
  801c61:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c6c:	e8 99 f1 ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7f:	e8 86 f1 ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c92:	e8 73 f1 ff ff       	call   800e0a <sys_page_unmap>
  801c97:	89 d8                	mov    %ebx,%eax
}
  801c99:	83 c4 30             	add    $0x30,%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <pipeisclosed>:
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cad:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb0:	89 04 24             	mov    %eax,(%esp)
  801cb3:	e8 8e f3 ff ff       	call   801046 <fd_lookup>
  801cb8:	89 c2                	mov    %eax,%edx
  801cba:	85 d2                	test   %edx,%edx
  801cbc:	78 15                	js     801cd3 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	89 04 24             	mov    %eax,(%esp)
  801cc4:	e8 17 f3 ff ff       	call   800fe0 <fd2data>
	return _pipeisclosed(fd, p);
  801cc9:	89 c2                	mov    %eax,%edx
  801ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cce:	e8 0b fd ff ff       	call   8019de <_pipeisclosed>
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    
  801cd5:	66 90                	xchg   %ax,%ax
  801cd7:	66 90                	xchg   %ax,%ax
  801cd9:	66 90                	xchg   %ax,%ax
  801cdb:	66 90                	xchg   %ax,%ax
  801cdd:	66 90                	xchg   %ax,%ax
  801cdf:	90                   	nop

00801ce0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801cf0:	c7 44 24 04 2c 27 80 	movl   $0x80272c,0x4(%esp)
  801cf7:	00 
  801cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfb:	89 04 24             	mov    %eax,(%esp)
  801cfe:	e8 44 ec ff ff       	call   800947 <strcpy>
	return 0;
}
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <devcons_write>:
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	57                   	push   %edi
  801d0e:	56                   	push   %esi
  801d0f:	53                   	push   %ebx
  801d10:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d16:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d21:	eb 31                	jmp    801d54 <devcons_write+0x4a>
		m = n - tot;
  801d23:	8b 75 10             	mov    0x10(%ebp),%esi
  801d26:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d28:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801d2b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d30:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d33:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d37:	03 45 0c             	add    0xc(%ebp),%eax
  801d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3e:	89 3c 24             	mov    %edi,(%esp)
  801d41:	e8 9e ed ff ff       	call   800ae4 <memmove>
		sys_cputs(buf, m);
  801d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4a:	89 3c 24             	mov    %edi,(%esp)
  801d4d:	e8 44 ef ff ff       	call   800c96 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d52:	01 f3                	add    %esi,%ebx
  801d54:	89 d8                	mov    %ebx,%eax
  801d56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d59:	72 c8                	jb     801d23 <devcons_write+0x19>
}
  801d5b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d61:	5b                   	pop    %ebx
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <devcons_read>:
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d75:	75 07                	jne    801d7e <devcons_read+0x18>
  801d77:	eb 2a                	jmp    801da3 <devcons_read+0x3d>
		sys_yield();
  801d79:	e8 c6 ef ff ff       	call   800d44 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d7e:	66 90                	xchg   %ax,%ax
  801d80:	e8 2f ef ff ff       	call   800cb4 <sys_cgetc>
  801d85:	85 c0                	test   %eax,%eax
  801d87:	74 f0                	je     801d79 <devcons_read+0x13>
	if (c < 0)
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 16                	js     801da3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801d8d:	83 f8 04             	cmp    $0x4,%eax
  801d90:	74 0c                	je     801d9e <devcons_read+0x38>
	*(char*)vbuf = c;
  801d92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d95:	88 02                	mov    %al,(%edx)
	return 1;
  801d97:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9c:	eb 05                	jmp    801da3 <devcons_read+0x3d>
		return 0;
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <cputchar>:
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801db1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801db8:	00 
  801db9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dbc:	89 04 24             	mov    %eax,(%esp)
  801dbf:	e8 d2 ee ff ff       	call   800c96 <sys_cputs>
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <getchar>:
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801dcc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801dd3:	00 
  801dd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de2:	e8 ee f4 ff ff       	call   8012d5 <read>
	if (r < 0)
  801de7:	85 c0                	test   %eax,%eax
  801de9:	78 0f                	js     801dfa <getchar+0x34>
	if (r < 1)
  801deb:	85 c0                	test   %eax,%eax
  801ded:	7e 06                	jle    801df5 <getchar+0x2f>
	return c;
  801def:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801df3:	eb 05                	jmp    801dfa <getchar+0x34>
		return -E_EOF;
  801df5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <iscons>:
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e09:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0c:	89 04 24             	mov    %eax,(%esp)
  801e0f:	e8 32 f2 ff ff       	call   801046 <fd_lookup>
  801e14:	85 c0                	test   %eax,%eax
  801e16:	78 11                	js     801e29 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e21:	39 10                	cmp    %edx,(%eax)
  801e23:	0f 94 c0             	sete   %al
  801e26:	0f b6 c0             	movzbl %al,%eax
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <opencons>:
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e34:	89 04 24             	mov    %eax,(%esp)
  801e37:	e8 bb f1 ff ff       	call   800ff7 <fd_alloc>
		return r;
  801e3c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 40                	js     801e82 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e42:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e49:	00 
  801e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e58:	e8 06 ef ff ff       	call   800d63 <sys_page_alloc>
		return r;
  801e5d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 1f                	js     801e82 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801e63:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e71:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e78:	89 04 24             	mov    %eax,(%esp)
  801e7b:	e8 50 f1 ff ff       	call   800fd0 <fd2num>
  801e80:	89 c2                	mov    %eax,%edx
}
  801e82:	89 d0                	mov    %edx,%eax
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    
  801e86:	66 90                	xchg   %ax,%ax
  801e88:	66 90                	xchg   %ax,%ax
  801e8a:	66 90                	xchg   %ax,%ax
  801e8c:	66 90                	xchg   %ax,%ax
  801e8e:	66 90                	xchg   %ax,%ax

00801e90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	83 ec 10             	sub    $0x10,%esp
  801e98:	8b 75 08             	mov    0x8(%ebp),%esi
  801e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801ea1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801ea3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ea8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801eab:	89 04 24             	mov    %eax,(%esp)
  801eae:	e8 c6 f0 ff ff       	call   800f79 <sys_ipc_recv>
    if(r < 0){
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	79 16                	jns    801ecd <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801eb7:	85 f6                	test   %esi,%esi
  801eb9:	74 06                	je     801ec1 <ipc_recv+0x31>
            *from_env_store = 0;
  801ebb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801ec1:	85 db                	test   %ebx,%ebx
  801ec3:	74 2c                	je     801ef1 <ipc_recv+0x61>
            *perm_store = 0;
  801ec5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ecb:	eb 24                	jmp    801ef1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801ecd:	85 f6                	test   %esi,%esi
  801ecf:	74 0a                	je     801edb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801ed1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801ed6:	8b 40 74             	mov    0x74(%eax),%eax
  801ed9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801edb:	85 db                	test   %ebx,%ebx
  801edd:	74 0a                	je     801ee9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801edf:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801ee4:	8b 40 78             	mov    0x78(%eax),%eax
  801ee7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ee9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801eee:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	57                   	push   %edi
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	83 ec 1c             	sub    $0x1c,%esp
  801f01:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801f0a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801f0c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f11:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801f14:	8b 45 14             	mov    0x14(%ebp),%eax
  801f17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f23:	89 3c 24             	mov    %edi,(%esp)
  801f26:	e8 2b f0 ff ff       	call   800f56 <sys_ipc_try_send>
        if(r == 0){
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	74 28                	je     801f57 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801f2f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f32:	74 1c                	je     801f50 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801f34:	c7 44 24 08 38 27 80 	movl   $0x802738,0x8(%esp)
  801f3b:	00 
  801f3c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801f43:	00 
  801f44:	c7 04 24 4f 27 80 00 	movl   $0x80274f,(%esp)
  801f4b:	e8 d7 e2 ff ff       	call   800227 <_panic>
        }
        sys_yield();
  801f50:	e8 ef ed ff ff       	call   800d44 <sys_yield>
    }
  801f55:	eb bd                	jmp    801f14 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801f57:	83 c4 1c             	add    $0x1c,%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5f                   	pop    %edi
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f65:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f73:	8b 52 50             	mov    0x50(%edx),%edx
  801f76:	39 ca                	cmp    %ecx,%edx
  801f78:	75 0d                	jne    801f87 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f7a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f82:	8b 40 40             	mov    0x40(%eax),%eax
  801f85:	eb 0e                	jmp    801f95 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801f87:	83 c0 01             	add    $0x1,%eax
  801f8a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f8f:	75 d9                	jne    801f6a <ipc_find_env+0xb>
	return 0;
  801f91:	66 b8 00 00          	mov    $0x0,%ax
}
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    

00801f97 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9d:	89 d0                	mov    %edx,%eax
  801f9f:	c1 e8 16             	shr    $0x16,%eax
  801fa2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801fae:	f6 c1 01             	test   $0x1,%cl
  801fb1:	74 1d                	je     801fd0 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801fb3:	c1 ea 0c             	shr    $0xc,%edx
  801fb6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbd:	f6 c2 01             	test   $0x1,%dl
  801fc0:	74 0e                	je     801fd0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc2:	c1 ea 0c             	shr    $0xc,%edx
  801fc5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fcc:	ef 
  801fcd:	0f b7 c0             	movzwl %ax,%eax
}
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	66 90                	xchg   %ax,%ax
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801fea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801fee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801ff2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ffc:	89 ea                	mov    %ebp,%edx
  801ffe:	89 0c 24             	mov    %ecx,(%esp)
  802001:	75 2d                	jne    802030 <__udivdi3+0x50>
  802003:	39 e9                	cmp    %ebp,%ecx
  802005:	77 61                	ja     802068 <__udivdi3+0x88>
  802007:	85 c9                	test   %ecx,%ecx
  802009:	89 ce                	mov    %ecx,%esi
  80200b:	75 0b                	jne    802018 <__udivdi3+0x38>
  80200d:	b8 01 00 00 00       	mov    $0x1,%eax
  802012:	31 d2                	xor    %edx,%edx
  802014:	f7 f1                	div    %ecx
  802016:	89 c6                	mov    %eax,%esi
  802018:	31 d2                	xor    %edx,%edx
  80201a:	89 e8                	mov    %ebp,%eax
  80201c:	f7 f6                	div    %esi
  80201e:	89 c5                	mov    %eax,%ebp
  802020:	89 f8                	mov    %edi,%eax
  802022:	f7 f6                	div    %esi
  802024:	89 ea                	mov    %ebp,%edx
  802026:	83 c4 0c             	add    $0xc,%esp
  802029:	5e                   	pop    %esi
  80202a:	5f                   	pop    %edi
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    
  80202d:	8d 76 00             	lea    0x0(%esi),%esi
  802030:	39 e8                	cmp    %ebp,%eax
  802032:	77 24                	ja     802058 <__udivdi3+0x78>
  802034:	0f bd e8             	bsr    %eax,%ebp
  802037:	83 f5 1f             	xor    $0x1f,%ebp
  80203a:	75 3c                	jne    802078 <__udivdi3+0x98>
  80203c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802040:	39 34 24             	cmp    %esi,(%esp)
  802043:	0f 86 9f 00 00 00    	jbe    8020e8 <__udivdi3+0x108>
  802049:	39 d0                	cmp    %edx,%eax
  80204b:	0f 82 97 00 00 00    	jb     8020e8 <__udivdi3+0x108>
  802051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802058:	31 d2                	xor    %edx,%edx
  80205a:	31 c0                	xor    %eax,%eax
  80205c:	83 c4 0c             	add    $0xc,%esp
  80205f:	5e                   	pop    %esi
  802060:	5f                   	pop    %edi
  802061:	5d                   	pop    %ebp
  802062:	c3                   	ret    
  802063:	90                   	nop
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	89 f8                	mov    %edi,%eax
  80206a:	f7 f1                	div    %ecx
  80206c:	31 d2                	xor    %edx,%edx
  80206e:	83 c4 0c             	add    $0xc,%esp
  802071:	5e                   	pop    %esi
  802072:	5f                   	pop    %edi
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    
  802075:	8d 76 00             	lea    0x0(%esi),%esi
  802078:	89 e9                	mov    %ebp,%ecx
  80207a:	8b 3c 24             	mov    (%esp),%edi
  80207d:	d3 e0                	shl    %cl,%eax
  80207f:	89 c6                	mov    %eax,%esi
  802081:	b8 20 00 00 00       	mov    $0x20,%eax
  802086:	29 e8                	sub    %ebp,%eax
  802088:	89 c1                	mov    %eax,%ecx
  80208a:	d3 ef                	shr    %cl,%edi
  80208c:	89 e9                	mov    %ebp,%ecx
  80208e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802092:	8b 3c 24             	mov    (%esp),%edi
  802095:	09 74 24 08          	or     %esi,0x8(%esp)
  802099:	89 d6                	mov    %edx,%esi
  80209b:	d3 e7                	shl    %cl,%edi
  80209d:	89 c1                	mov    %eax,%ecx
  80209f:	89 3c 24             	mov    %edi,(%esp)
  8020a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020a6:	d3 ee                	shr    %cl,%esi
  8020a8:	89 e9                	mov    %ebp,%ecx
  8020aa:	d3 e2                	shl    %cl,%edx
  8020ac:	89 c1                	mov    %eax,%ecx
  8020ae:	d3 ef                	shr    %cl,%edi
  8020b0:	09 d7                	or     %edx,%edi
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	89 f8                	mov    %edi,%eax
  8020b6:	f7 74 24 08          	divl   0x8(%esp)
  8020ba:	89 d6                	mov    %edx,%esi
  8020bc:	89 c7                	mov    %eax,%edi
  8020be:	f7 24 24             	mull   (%esp)
  8020c1:	39 d6                	cmp    %edx,%esi
  8020c3:	89 14 24             	mov    %edx,(%esp)
  8020c6:	72 30                	jb     8020f8 <__udivdi3+0x118>
  8020c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020cc:	89 e9                	mov    %ebp,%ecx
  8020ce:	d3 e2                	shl    %cl,%edx
  8020d0:	39 c2                	cmp    %eax,%edx
  8020d2:	73 05                	jae    8020d9 <__udivdi3+0xf9>
  8020d4:	3b 34 24             	cmp    (%esp),%esi
  8020d7:	74 1f                	je     8020f8 <__udivdi3+0x118>
  8020d9:	89 f8                	mov    %edi,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	e9 7a ff ff ff       	jmp    80205c <__udivdi3+0x7c>
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ef:	e9 68 ff ff ff       	jmp    80205c <__udivdi3+0x7c>
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	83 c4 0c             	add    $0xc,%esp
  802100:	5e                   	pop    %esi
  802101:	5f                   	pop    %edi
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	83 ec 14             	sub    $0x14,%esp
  802116:	8b 44 24 28          	mov    0x28(%esp),%eax
  80211a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80211e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802122:	89 c7                	mov    %eax,%edi
  802124:	89 44 24 04          	mov    %eax,0x4(%esp)
  802128:	8b 44 24 30          	mov    0x30(%esp),%eax
  80212c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802130:	89 34 24             	mov    %esi,(%esp)
  802133:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802137:	85 c0                	test   %eax,%eax
  802139:	89 c2                	mov    %eax,%edx
  80213b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80213f:	75 17                	jne    802158 <__umoddi3+0x48>
  802141:	39 fe                	cmp    %edi,%esi
  802143:	76 4b                	jbe    802190 <__umoddi3+0x80>
  802145:	89 c8                	mov    %ecx,%eax
  802147:	89 fa                	mov    %edi,%edx
  802149:	f7 f6                	div    %esi
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	31 d2                	xor    %edx,%edx
  80214f:	83 c4 14             	add    $0x14,%esp
  802152:	5e                   	pop    %esi
  802153:	5f                   	pop    %edi
  802154:	5d                   	pop    %ebp
  802155:	c3                   	ret    
  802156:	66 90                	xchg   %ax,%ax
  802158:	39 f8                	cmp    %edi,%eax
  80215a:	77 54                	ja     8021b0 <__umoddi3+0xa0>
  80215c:	0f bd e8             	bsr    %eax,%ebp
  80215f:	83 f5 1f             	xor    $0x1f,%ebp
  802162:	75 5c                	jne    8021c0 <__umoddi3+0xb0>
  802164:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802168:	39 3c 24             	cmp    %edi,(%esp)
  80216b:	0f 87 e7 00 00 00    	ja     802258 <__umoddi3+0x148>
  802171:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802175:	29 f1                	sub    %esi,%ecx
  802177:	19 c7                	sbb    %eax,%edi
  802179:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80217d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802181:	8b 44 24 08          	mov    0x8(%esp),%eax
  802185:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802189:	83 c4 14             	add    $0x14,%esp
  80218c:	5e                   	pop    %esi
  80218d:	5f                   	pop    %edi
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    
  802190:	85 f6                	test   %esi,%esi
  802192:	89 f5                	mov    %esi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f6                	div    %esi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021a5:	31 d2                	xor    %edx,%edx
  8021a7:	f7 f5                	div    %ebp
  8021a9:	89 c8                	mov    %ecx,%eax
  8021ab:	f7 f5                	div    %ebp
  8021ad:	eb 9c                	jmp    80214b <__umoddi3+0x3b>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 fa                	mov    %edi,%edx
  8021b4:	83 c4 14             	add    $0x14,%esp
  8021b7:	5e                   	pop    %esi
  8021b8:	5f                   	pop    %edi
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    
  8021bb:	90                   	nop
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 04 24             	mov    (%esp),%eax
  8021c3:	be 20 00 00 00       	mov    $0x20,%esi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ee                	sub    %ebp,%esi
  8021cc:	d3 e2                	shl    %cl,%edx
  8021ce:	89 f1                	mov    %esi,%ecx
  8021d0:	d3 e8                	shr    %cl,%eax
  8021d2:	89 e9                	mov    %ebp,%ecx
  8021d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d8:	8b 04 24             	mov    (%esp),%eax
  8021db:	09 54 24 04          	or     %edx,0x4(%esp)
  8021df:	89 fa                	mov    %edi,%edx
  8021e1:	d3 e0                	shl    %cl,%eax
  8021e3:	89 f1                	mov    %esi,%ecx
  8021e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8021ed:	d3 ea                	shr    %cl,%edx
  8021ef:	89 e9                	mov    %ebp,%ecx
  8021f1:	d3 e7                	shl    %cl,%edi
  8021f3:	89 f1                	mov    %esi,%ecx
  8021f5:	d3 e8                	shr    %cl,%eax
  8021f7:	89 e9                	mov    %ebp,%ecx
  8021f9:	09 f8                	or     %edi,%eax
  8021fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8021ff:	f7 74 24 04          	divl   0x4(%esp)
  802203:	d3 e7                	shl    %cl,%edi
  802205:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802209:	89 d7                	mov    %edx,%edi
  80220b:	f7 64 24 08          	mull   0x8(%esp)
  80220f:	39 d7                	cmp    %edx,%edi
  802211:	89 c1                	mov    %eax,%ecx
  802213:	89 14 24             	mov    %edx,(%esp)
  802216:	72 2c                	jb     802244 <__umoddi3+0x134>
  802218:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80221c:	72 22                	jb     802240 <__umoddi3+0x130>
  80221e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802222:	29 c8                	sub    %ecx,%eax
  802224:	19 d7                	sbb    %edx,%edi
  802226:	89 e9                	mov    %ebp,%ecx
  802228:	89 fa                	mov    %edi,%edx
  80222a:	d3 e8                	shr    %cl,%eax
  80222c:	89 f1                	mov    %esi,%ecx
  80222e:	d3 e2                	shl    %cl,%edx
  802230:	89 e9                	mov    %ebp,%ecx
  802232:	d3 ef                	shr    %cl,%edi
  802234:	09 d0                	or     %edx,%eax
  802236:	89 fa                	mov    %edi,%edx
  802238:	83 c4 14             	add    $0x14,%esp
  80223b:	5e                   	pop    %esi
  80223c:	5f                   	pop    %edi
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    
  80223f:	90                   	nop
  802240:	39 d7                	cmp    %edx,%edi
  802242:	75 da                	jne    80221e <__umoddi3+0x10e>
  802244:	8b 14 24             	mov    (%esp),%edx
  802247:	89 c1                	mov    %eax,%ecx
  802249:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80224d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802251:	eb cb                	jmp    80221e <__umoddi3+0x10e>
  802253:	90                   	nop
  802254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802258:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80225c:	0f 82 0f ff ff ff    	jb     802171 <__umoddi3+0x61>
  802262:	e9 1a ff ff ff       	jmp    802181 <__umoddi3+0x71>
