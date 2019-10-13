
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 27 01 00 00       	call   800158 <libmain>
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
  800038:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 80 	movl   $0x802680,0x803000
  800045:	26 80 00 

	cprintf("icode startup\n");
  800048:	c7 04 24 86 26 80 00 	movl   $0x802686,(%esp)
  80004f:	e8 5e 02 00 00       	call   8002b2 <cprintf>

	cprintf("icode: open /motd\n");
  800054:	c7 04 24 95 26 80 00 	movl   $0x802695,(%esp)
  80005b:	e8 52 02 00 00       	call   8002b2 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800060:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800067:	00 
  800068:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  80006f:	e8 9d 16 00 00       	call   801711 <open>
  800074:	89 c6                	mov    %eax,%esi
  800076:	85 c0                	test   %eax,%eax
  800078:	79 20                	jns    80009a <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007e:	c7 44 24 08 ae 26 80 	movl   $0x8026ae,0x8(%esp)
  800085:	00 
  800086:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008d:	00 
  80008e:	c7 04 24 c4 26 80 00 	movl   $0x8026c4,(%esp)
  800095:	e8 1f 01 00 00       	call   8001b9 <_panic>

	cprintf("icode: read /motd\n");
  80009a:	c7 04 24 d1 26 80 00 	movl   $0x8026d1,(%esp)
  8000a1:	e8 0c 02 00 00       	call   8002b2 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a6:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ac:	eb 0c                	jmp    8000ba <umain+0x87>
		sys_cputs(buf, n);
  8000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b2:	89 1c 24             	mov    %ebx,(%esp)
  8000b5:	e8 6c 0b 00 00       	call   800c26 <sys_cputs>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ba:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c1:	00 
  8000c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c6:	89 34 24             	mov    %esi,(%esp)
  8000c9:	e8 97 11 00 00       	call   801265 <read>
  8000ce:	85 c0                	test   %eax,%eax
  8000d0:	7f dc                	jg     8000ae <umain+0x7b>

	cprintf("icode: close /motd\n");
  8000d2:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  8000d9:	e8 d4 01 00 00       	call   8002b2 <cprintf>
	close(fd);
  8000de:	89 34 24             	mov    %esi,(%esp)
  8000e1:	e8 1c 10 00 00       	call   801102 <close>

	cprintf("icode: spawn /init\n");
  8000e6:	c7 04 24 f8 26 80 00 	movl   $0x8026f8,(%esp)
  8000ed:	e8 c0 01 00 00       	call   8002b2 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000f9:	00 
  8000fa:	c7 44 24 0c 0c 27 80 	movl   $0x80270c,0xc(%esp)
  800101:	00 
  800102:	c7 44 24 08 15 27 80 	movl   $0x802715,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 1f 27 80 	movl   $0x80271f,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 1e 27 80 00 	movl   $0x80271e,(%esp)
  800119:	e8 d3 1b 00 00       	call   801cf1 <spawnl>
  80011e:	85 c0                	test   %eax,%eax
  800120:	79 20                	jns    800142 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800122:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800126:	c7 44 24 08 24 27 80 	movl   $0x802724,0x8(%esp)
  80012d:	00 
  80012e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800135:	00 
  800136:	c7 04 24 c4 26 80 00 	movl   $0x8026c4,(%esp)
  80013d:	e8 77 00 00 00       	call   8001b9 <_panic>

	cprintf("icode: exiting\n");
  800142:	c7 04 24 3b 27 80 00 	movl   $0x80273b,(%esp)
  800149:	e8 64 01 00 00       	call   8002b2 <cprintf>
}
  80014e:	81 c4 30 02 00 00    	add    $0x230,%esp
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 10             	sub    $0x10,%esp
  800160:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800163:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800166:	e8 4a 0b 00 00       	call   800cb5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  80016b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800170:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800173:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800178:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80017d:	85 db                	test   %ebx,%ebx
  80017f:	7e 07                	jle    800188 <libmain+0x30>
		binaryname = argv[0];
  800181:	8b 06                	mov    (%esi),%eax
  800183:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800188:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018c:	89 1c 24             	mov    %ebx,(%esp)
  80018f:	e8 9f fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800194:	e8 07 00 00 00       	call   8001a0 <exit>
}
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a6:	e8 8a 0f 00 00       	call   801135 <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 ac 0a 00 00       	call   800c63 <sys_env_destroy>
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ca:	e8 e6 0a 00 00       	call   800cb5 <sys_getenvid>
  8001cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001dd:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	c7 04 24 58 27 80 00 	movl   $0x802758,(%esp)
  8001ec:	e8 c1 00 00 00       	call   8002b2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 51 00 00 00       	call   800251 <vcprintf>
	cprintf("\n");
  800200:	c7 04 24 40 2c 80 00 	movl   $0x802c40,(%esp)
  800207:	e8 a6 00 00 00       	call   8002b2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020c:	cc                   	int3   
  80020d:	eb fd                	jmp    80020c <_panic+0x53>

0080020f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	53                   	push   %ebx
  800213:	83 ec 14             	sub    $0x14,%esp
  800216:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800219:	8b 13                	mov    (%ebx),%edx
  80021b:	8d 42 01             	lea    0x1(%edx),%eax
  80021e:	89 03                	mov    %eax,(%ebx)
  800220:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800223:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800227:	3d ff 00 00 00       	cmp    $0xff,%eax
  80022c:	75 19                	jne    800247 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80022e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800235:	00 
  800236:	8d 43 08             	lea    0x8(%ebx),%eax
  800239:	89 04 24             	mov    %eax,(%esp)
  80023c:	e8 e5 09 00 00       	call   800c26 <sys_cputs>
		b->idx = 0;
  800241:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800247:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80024b:	83 c4 14             	add    $0x14,%esp
  80024e:	5b                   	pop    %ebx
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80025a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800261:	00 00 00 
	b.cnt = 0;
  800264:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80026b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800271:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800282:	89 44 24 04          	mov    %eax,0x4(%esp)
  800286:	c7 04 24 0f 02 80 00 	movl   $0x80020f,(%esp)
  80028d:	e8 ac 01 00 00       	call   80043e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800292:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a2:	89 04 24             	mov    %eax,(%esp)
  8002a5:	e8 7c 09 00 00       	call   800c26 <sys_cputs>

	return b.cnt;
}
  8002aa:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	e8 87 ff ff ff       	call   800251 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    
  8002cc:	66 90                	xchg   %ax,%ax
  8002ce:	66 90                	xchg   %ax,%ax

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 3c             	sub    $0x3c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d7                	mov    %edx,%edi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 c3                	mov    %eax,%ebx
  8002e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002fd:	39 d9                	cmp    %ebx,%ecx
  8002ff:	72 05                	jb     800306 <printnum+0x36>
  800301:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800304:	77 69                	ja     80036f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800306:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800309:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80030d:	83 ee 01             	sub    $0x1,%esi
  800310:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	8b 44 24 08          	mov    0x8(%esp),%eax
  80031c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800320:	89 c3                	mov    %eax,%ebx
  800322:	89 d6                	mov    %edx,%esi
  800324:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800327:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80032a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80032e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033f:	e8 ac 20 00 00       	call   8023f0 <__udivdi3>
  800344:	89 d9                	mov    %ebx,%ecx
  800346:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	89 54 24 04          	mov    %edx,0x4(%esp)
  800355:	89 fa                	mov    %edi,%edx
  800357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035a:	e8 71 ff ff ff       	call   8002d0 <printnum>
  80035f:	eb 1b                	jmp    80037c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800361:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800365:	8b 45 18             	mov    0x18(%ebp),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	ff d3                	call   *%ebx
  80036d:	eb 03                	jmp    800372 <printnum+0xa2>
  80036f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800372:	83 ee 01             	sub    $0x1,%esi
  800375:	85 f6                	test   %esi,%esi
  800377:	7f e8                	jg     800361 <printnum+0x91>
  800379:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80037c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800380:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800384:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800387:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80038a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80039b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039f:	e8 7c 21 00 00       	call   802520 <__umoddi3>
  8003a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a8:	0f be 80 7b 27 80 00 	movsbl 0x80277b(%eax),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b5:	ff d0                	call   *%eax
}
  8003b7:	83 c4 3c             	add    $0x3c,%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c2:	83 fa 01             	cmp    $0x1,%edx
  8003c5:	7e 0e                	jle    8003d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c7:	8b 10                	mov    (%eax),%edx
  8003c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cc:	89 08                	mov    %ecx,(%eax)
  8003ce:	8b 02                	mov    (%edx),%eax
  8003d0:	8b 52 04             	mov    0x4(%edx),%edx
  8003d3:	eb 22                	jmp    8003f7 <getuint+0x38>
	else if (lflag)
  8003d5:	85 d2                	test   %edx,%edx
  8003d7:	74 10                	je     8003e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 02                	mov    (%edx),%eax
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e7:	eb 0e                	jmp    8003f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 02                	mov    (%edx),%eax
  8003f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    

008003f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
  8003fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800403:	8b 10                	mov    (%eax),%edx
  800405:	3b 50 04             	cmp    0x4(%eax),%edx
  800408:	73 0a                	jae    800414 <sprintputch+0x1b>
		*b->buf++ = ch;
  80040a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80040d:	89 08                	mov    %ecx,(%eax)
  80040f:	8b 45 08             	mov    0x8(%ebp),%eax
  800412:	88 02                	mov    %al,(%edx)
}
  800414:	5d                   	pop    %ebp
  800415:	c3                   	ret    

00800416 <printfmt>:
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80041c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800423:	8b 45 10             	mov    0x10(%ebp),%eax
  800426:	89 44 24 08          	mov    %eax,0x8(%esp)
  80042a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	e8 02 00 00 00       	call   80043e <vprintfmt>
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <vprintfmt>:
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
  800444:	83 ec 3c             	sub    $0x3c,%esp
  800447:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80044a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80044d:	eb 1f                	jmp    80046e <vprintfmt+0x30>
			if (ch == '\0'){
  80044f:	85 c0                	test   %eax,%eax
  800451:	75 0f                	jne    800462 <vprintfmt+0x24>
				color = 0x0100;
  800453:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80045a:	01 00 00 
  80045d:	e9 b3 03 00 00       	jmp    800815 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800462:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800466:	89 04 24             	mov    %eax,(%esp)
  800469:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	89 f3                	mov    %esi,%ebx
  80046e:	8d 73 01             	lea    0x1(%ebx),%esi
  800471:	0f b6 03             	movzbl (%ebx),%eax
  800474:	83 f8 25             	cmp    $0x25,%eax
  800477:	75 d6                	jne    80044f <vprintfmt+0x11>
  800479:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80047d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800484:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80048b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800492:	ba 00 00 00 00       	mov    $0x0,%edx
  800497:	eb 1d                	jmp    8004b6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800499:	89 de                	mov    %ebx,%esi
			padc = '-';
  80049b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80049f:	eb 15                	jmp    8004b6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	89 de                	mov    %ebx,%esi
			padc = '0';
  8004a3:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004a7:	eb 0d                	jmp    8004b6 <vprintfmt+0x78>
				width = precision, precision = -1;
  8004a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004af:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004b9:	0f b6 0e             	movzbl (%esi),%ecx
  8004bc:	0f b6 c1             	movzbl %cl,%eax
  8004bf:	83 e9 23             	sub    $0x23,%ecx
  8004c2:	80 f9 55             	cmp    $0x55,%cl
  8004c5:	0f 87 2a 03 00 00    	ja     8007f5 <vprintfmt+0x3b7>
  8004cb:	0f b6 c9             	movzbl %cl,%ecx
  8004ce:	ff 24 8d c0 28 80 00 	jmp    *0x8028c0(,%ecx,4)
  8004d5:	89 de                	mov    %ebx,%esi
  8004d7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8004dc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004df:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004e3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004e6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004e9:	83 fb 09             	cmp    $0x9,%ebx
  8004ec:	77 36                	ja     800524 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8004ee:	83 c6 01             	add    $0x1,%esi
			}
  8004f1:	eb e9                	jmp    8004dc <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004fc:	8b 00                	mov    (%eax),%eax
  8004fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800501:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800503:	eb 22                	jmp    800527 <vprintfmt+0xe9>
  800505:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c1             	cmovns %ecx,%eax
  800512:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800515:	89 de                	mov    %ebx,%esi
  800517:	eb 9d                	jmp    8004b6 <vprintfmt+0x78>
  800519:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80051b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800522:	eb 92                	jmp    8004b6 <vprintfmt+0x78>
  800524:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800527:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80052b:	79 89                	jns    8004b6 <vprintfmt+0x78>
  80052d:	e9 77 ff ff ff       	jmp    8004a9 <vprintfmt+0x6b>
			lflag++;
  800532:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800535:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800537:	e9 7a ff ff ff       	jmp    8004b6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 04             	lea    0x4(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800551:	e9 18 ff ff ff       	jmp    80046e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	99                   	cltd   
  800562:	31 d0                	xor    %edx,%eax
  800564:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800566:	83 f8 0f             	cmp    $0xf,%eax
  800569:	7f 0b                	jg     800576 <vprintfmt+0x138>
  80056b:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  800572:	85 d2                	test   %edx,%edx
  800574:	75 20                	jne    800596 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800576:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057a:	c7 44 24 08 93 27 80 	movl   $0x802793,0x8(%esp)
  800581:	00 
  800582:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800586:	8b 45 08             	mov    0x8(%ebp),%eax
  800589:	89 04 24             	mov    %eax,(%esp)
  80058c:	e8 85 fe ff ff       	call   800416 <printfmt>
  800591:	e9 d8 fe ff ff       	jmp    80046e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800596:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059a:	c7 44 24 08 7a 2b 80 	movl   $0x802b7a,0x8(%esp)
  8005a1:	00 
  8005a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a9:	89 04 24             	mov    %eax,(%esp)
  8005ac:	e8 65 fe ff ff       	call   800416 <printfmt>
  8005b1:	e9 b8 fe ff ff       	jmp    80046e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 50 04             	lea    0x4(%eax),%edx
  8005c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005ca:	85 f6                	test   %esi,%esi
  8005cc:	b8 8c 27 80 00       	mov    $0x80278c,%eax
  8005d1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005d4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005d8:	0f 84 97 00 00 00    	je     800675 <vprintfmt+0x237>
  8005de:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005e2:	0f 8e 9b 00 00 00    	jle    800683 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ec:	89 34 24             	mov    %esi,(%esp)
  8005ef:	e8 c4 02 00 00       	call   8008b8 <strnlen>
  8005f4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005f7:	29 c2                	sub    %eax,%edx
  8005f9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005fc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800600:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800603:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800606:	8b 75 08             	mov    0x8(%ebp),%esi
  800609:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80060c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80060e:	eb 0f                	jmp    80061f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800610:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800614:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80061c:	83 eb 01             	sub    $0x1,%ebx
  80061f:	85 db                	test   %ebx,%ebx
  800621:	7f ed                	jg     800610 <vprintfmt+0x1d2>
  800623:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800626:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	b8 00 00 00 00       	mov    $0x0,%eax
  800630:	0f 49 c2             	cmovns %edx,%eax
  800633:	29 c2                	sub    %eax,%edx
  800635:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800638:	89 d7                	mov    %edx,%edi
  80063a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80063d:	eb 50                	jmp    80068f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80063f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800643:	74 1e                	je     800663 <vprintfmt+0x225>
  800645:	0f be d2             	movsbl %dl,%edx
  800648:	83 ea 20             	sub    $0x20,%edx
  80064b:	83 fa 5e             	cmp    $0x5e,%edx
  80064e:	76 13                	jbe    800663 <vprintfmt+0x225>
					putch('?', putdat);
  800650:	8b 45 0c             	mov    0xc(%ebp),%eax
  800653:	89 44 24 04          	mov    %eax,0x4(%esp)
  800657:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80065e:	ff 55 08             	call   *0x8(%ebp)
  800661:	eb 0d                	jmp    800670 <vprintfmt+0x232>
					putch(ch, putdat);
  800663:	8b 55 0c             	mov    0xc(%ebp),%edx
  800666:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800670:	83 ef 01             	sub    $0x1,%edi
  800673:	eb 1a                	jmp    80068f <vprintfmt+0x251>
  800675:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800678:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80067b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80067e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800681:	eb 0c                	jmp    80068f <vprintfmt+0x251>
  800683:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800686:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800689:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80068c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80068f:	83 c6 01             	add    $0x1,%esi
  800692:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800696:	0f be c2             	movsbl %dl,%eax
  800699:	85 c0                	test   %eax,%eax
  80069b:	74 27                	je     8006c4 <vprintfmt+0x286>
  80069d:	85 db                	test   %ebx,%ebx
  80069f:	78 9e                	js     80063f <vprintfmt+0x201>
  8006a1:	83 eb 01             	sub    $0x1,%ebx
  8006a4:	79 99                	jns    80063f <vprintfmt+0x201>
  8006a6:	89 f8                	mov    %edi,%eax
  8006a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ae:	89 c3                	mov    %eax,%ebx
  8006b0:	eb 1a                	jmp    8006cc <vprintfmt+0x28e>
				putch(' ', putdat);
  8006b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006bd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006bf:	83 eb 01             	sub    $0x1,%ebx
  8006c2:	eb 08                	jmp    8006cc <vprintfmt+0x28e>
  8006c4:	89 fb                	mov    %edi,%ebx
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006cc:	85 db                	test   %ebx,%ebx
  8006ce:	7f e2                	jg     8006b2 <vprintfmt+0x274>
  8006d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006d6:	e9 93 fd ff ff       	jmp    80046e <vprintfmt+0x30>
	if (lflag >= 2)
  8006db:	83 fa 01             	cmp    $0x1,%edx
  8006de:	7e 16                	jle    8006f6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 08             	lea    0x8(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 50 04             	mov    0x4(%eax),%edx
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006f4:	eb 32                	jmp    800728 <vprintfmt+0x2ea>
	else if (lflag)
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	74 18                	je     800712 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 04             	lea    0x4(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 30                	mov    (%eax),%esi
  800705:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800708:	89 f0                	mov    %esi,%eax
  80070a:	c1 f8 1f             	sar    $0x1f,%eax
  80070d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800710:	eb 16                	jmp    800728 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 04             	lea    0x4(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)
  80071b:	8b 30                	mov    (%eax),%esi
  80071d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800720:	89 f0                	mov    %esi,%eax
  800722:	c1 f8 1f             	sar    $0x1f,%eax
  800725:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800728:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80072b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80072e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800733:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800737:	0f 89 80 00 00 00    	jns    8007bd <vprintfmt+0x37f>
				putch('-', putdat);
  80073d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800741:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80074b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80074e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800751:	f7 d8                	neg    %eax
  800753:	83 d2 00             	adc    $0x0,%edx
  800756:	f7 da                	neg    %edx
			base = 10;
  800758:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80075d:	eb 5e                	jmp    8007bd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	e8 58 fc ff ff       	call   8003bf <getuint>
			base = 10;
  800767:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80076c:	eb 4f                	jmp    8007bd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
  800771:	e8 49 fc ff ff       	call   8003bf <getuint>
            base = 8;
  800776:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80077b:	eb 40                	jmp    8007bd <vprintfmt+0x37f>
			putch('0', putdat);
  80077d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800781:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800788:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80078b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800796:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 50 04             	lea    0x4(%eax),%edx
  80079f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8007a9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ae:	eb 0d                	jmp    8007bd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b3:	e8 07 fc ff ff       	call   8003bf <getuint>
			base = 16;
  8007b8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8007bd:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007c1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007c5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007c8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007cc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d7:	89 fa                	mov    %edi,%edx
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	e8 ef fa ff ff       	call   8002d0 <printnum>
			break;
  8007e1:	e9 88 fc ff ff       	jmp    80046e <vprintfmt+0x30>
			putch(ch, putdat);
  8007e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ea:	89 04 24             	mov    %eax,(%esp)
  8007ed:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007f0:	e9 79 fc ff ff       	jmp    80046e <vprintfmt+0x30>
			putch('%', putdat);
  8007f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800800:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800803:	89 f3                	mov    %esi,%ebx
  800805:	eb 03                	jmp    80080a <vprintfmt+0x3cc>
  800807:	83 eb 01             	sub    $0x1,%ebx
  80080a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80080e:	75 f7                	jne    800807 <vprintfmt+0x3c9>
  800810:	e9 59 fc ff ff       	jmp    80046e <vprintfmt+0x30>
}
  800815:	83 c4 3c             	add    $0x3c,%esp
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5f                   	pop    %edi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	83 ec 28             	sub    $0x28,%esp
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800829:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800830:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083a:	85 c0                	test   %eax,%eax
  80083c:	74 30                	je     80086e <vsnprintf+0x51>
  80083e:	85 d2                	test   %edx,%edx
  800840:	7e 2c                	jle    80086e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800849:	8b 45 10             	mov    0x10(%ebp),%eax
  80084c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800850:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800853:	89 44 24 04          	mov    %eax,0x4(%esp)
  800857:	c7 04 24 f9 03 80 00 	movl   $0x8003f9,(%esp)
  80085e:	e8 db fb ff ff       	call   80043e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800863:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800866:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086c:	eb 05                	jmp    800873 <vsnprintf+0x56>
		return -E_INVAL;
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800882:	8b 45 10             	mov    0x10(%ebp),%eax
  800885:	89 44 24 08          	mov    %eax,0x8(%esp)
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 82 ff ff ff       	call   80081d <vsnprintf>
	va_end(ap);

	return rc;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    
  80089d:	66 90                	xchg   %ax,%ax
  80089f:	90                   	nop

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	eb 03                	jmp    8008b0 <strlen+0x10>
		n++;
  8008ad:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b4:	75 f7                	jne    8008ad <strlen+0xd>
	return n;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c6:	eb 03                	jmp    8008cb <strnlen+0x13>
		n++;
  8008c8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cb:	39 d0                	cmp    %edx,%eax
  8008cd:	74 06                	je     8008d5 <strnlen+0x1d>
  8008cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d3:	75 f3                	jne    8008c8 <strnlen+0x10>
	return n;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e1:	89 c2                	mov    %eax,%edx
  8008e3:	83 c2 01             	add    $0x1,%edx
  8008e6:	83 c1 01             	add    $0x1,%ecx
  8008e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f0:	84 db                	test   %bl,%bl
  8008f2:	75 ef                	jne    8008e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	53                   	push   %ebx
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800901:	89 1c 24             	mov    %ebx,(%esp)
  800904:	e8 97 ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800910:	01 d8                	add    %ebx,%eax
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	e8 bd ff ff ff       	call   8008d7 <strcpy>
	return dst;
}
  80091a:	89 d8                	mov    %ebx,%eax
  80091c:	83 c4 08             	add    $0x8,%esp
  80091f:	5b                   	pop    %ebx
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	89 f3                	mov    %esi,%ebx
  80092f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800932:	89 f2                	mov    %esi,%edx
  800934:	eb 0f                	jmp    800945 <strncpy+0x23>
		*dst++ = *src;
  800936:	83 c2 01             	add    $0x1,%edx
  800939:	0f b6 01             	movzbl (%ecx),%eax
  80093c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093f:	80 39 01             	cmpb   $0x1,(%ecx)
  800942:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800945:	39 da                	cmp    %ebx,%edx
  800947:	75 ed                	jne    800936 <strncpy+0x14>
	}
	return ret;
}
  800949:	89 f0                	mov    %esi,%eax
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 75 08             	mov    0x8(%ebp),%esi
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80095d:	89 f0                	mov    %esi,%eax
  80095f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800963:	85 c9                	test   %ecx,%ecx
  800965:	75 0b                	jne    800972 <strlcpy+0x23>
  800967:	eb 1d                	jmp    800986 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	83 c2 01             	add    $0x1,%edx
  80096f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800972:	39 d8                	cmp    %ebx,%eax
  800974:	74 0b                	je     800981 <strlcpy+0x32>
  800976:	0f b6 0a             	movzbl (%edx),%ecx
  800979:	84 c9                	test   %cl,%cl
  80097b:	75 ec                	jne    800969 <strlcpy+0x1a>
  80097d:	89 c2                	mov    %eax,%edx
  80097f:	eb 02                	jmp    800983 <strlcpy+0x34>
  800981:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800983:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800986:	29 f0                	sub    %esi,%eax
}
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800995:	eb 06                	jmp    80099d <strcmp+0x11>
		p++, q++;
  800997:	83 c1 01             	add    $0x1,%ecx
  80099a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80099d:	0f b6 01             	movzbl (%ecx),%eax
  8009a0:	84 c0                	test   %al,%al
  8009a2:	74 04                	je     8009a8 <strcmp+0x1c>
  8009a4:	3a 02                	cmp    (%edx),%al
  8009a6:	74 ef                	je     800997 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 c0             	movzbl %al,%eax
  8009ab:	0f b6 12             	movzbl (%edx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
}
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	53                   	push   %ebx
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bc:	89 c3                	mov    %eax,%ebx
  8009be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c1:	eb 06                	jmp    8009c9 <strncmp+0x17>
		n--, p++, q++;
  8009c3:	83 c0 01             	add    $0x1,%eax
  8009c6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c9:	39 d8                	cmp    %ebx,%eax
  8009cb:	74 15                	je     8009e2 <strncmp+0x30>
  8009cd:	0f b6 08             	movzbl (%eax),%ecx
  8009d0:	84 c9                	test   %cl,%cl
  8009d2:	74 04                	je     8009d8 <strncmp+0x26>
  8009d4:	3a 0a                	cmp    (%edx),%cl
  8009d6:	74 eb                	je     8009c3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d8:	0f b6 00             	movzbl (%eax),%eax
  8009db:	0f b6 12             	movzbl (%edx),%edx
  8009de:	29 d0                	sub    %edx,%eax
  8009e0:	eb 05                	jmp    8009e7 <strncmp+0x35>
		return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f4:	eb 07                	jmp    8009fd <strchr+0x13>
		if (*s == c)
  8009f6:	38 ca                	cmp    %cl,%dl
  8009f8:	74 0f                	je     800a09 <strchr+0x1f>
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 f2                	jne    8009f6 <strchr+0xc>
			return (char *) s;
	return 0;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	eb 07                	jmp    800a1e <strfind+0x13>
		if (*s == c)
  800a17:	38 ca                	cmp    %cl,%dl
  800a19:	74 0a                	je     800a25 <strfind+0x1a>
	for (; *s; s++)
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	0f b6 10             	movzbl (%eax),%edx
  800a21:	84 d2                	test   %dl,%dl
  800a23:	75 f2                	jne    800a17 <strfind+0xc>
			break;
	return (char *) s;
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a33:	85 c9                	test   %ecx,%ecx
  800a35:	74 36                	je     800a6d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a37:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3d:	75 28                	jne    800a67 <memset+0x40>
  800a3f:	f6 c1 03             	test   $0x3,%cl
  800a42:	75 23                	jne    800a67 <memset+0x40>
		c &= 0xFF;
  800a44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a48:	89 d3                	mov    %edx,%ebx
  800a4a:	c1 e3 08             	shl    $0x8,%ebx
  800a4d:	89 d6                	mov    %edx,%esi
  800a4f:	c1 e6 18             	shl    $0x18,%esi
  800a52:	89 d0                	mov    %edx,%eax
  800a54:	c1 e0 10             	shl    $0x10,%eax
  800a57:	09 f0                	or     %esi,%eax
  800a59:	09 c2                	or     %eax,%edx
  800a5b:	89 d0                	mov    %edx,%eax
  800a5d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a62:	fc                   	cld    
  800a63:	f3 ab                	rep stos %eax,%es:(%edi)
  800a65:	eb 06                	jmp    800a6d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	fc                   	cld    
  800a6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6d:	89 f8                	mov    %edi,%eax
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a82:	39 c6                	cmp    %eax,%esi
  800a84:	73 35                	jae    800abb <memmove+0x47>
  800a86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a89:	39 d0                	cmp    %edx,%eax
  800a8b:	73 2e                	jae    800abb <memmove+0x47>
		s += n;
		d += n;
  800a8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a90:	89 d6                	mov    %edx,%esi
  800a92:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a94:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9a:	75 13                	jne    800aaf <memmove+0x3b>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	75 0e                	jne    800aaf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa1:	83 ef 04             	sub    $0x4,%edi
  800aa4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aaa:	fd                   	std    
  800aab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aad:	eb 09                	jmp    800ab8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aaf:	83 ef 01             	sub    $0x1,%edi
  800ab2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ab5:	fd                   	std    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab8:	fc                   	cld    
  800ab9:	eb 1d                	jmp    800ad8 <memmove+0x64>
  800abb:	89 f2                	mov    %esi,%edx
  800abd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abf:	f6 c2 03             	test   $0x3,%dl
  800ac2:	75 0f                	jne    800ad3 <memmove+0x5f>
  800ac4:	f6 c1 03             	test   $0x3,%cl
  800ac7:	75 0a                	jne    800ad3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800acc:	89 c7                	mov    %eax,%edi
  800ace:	fc                   	cld    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad1:	eb 05                	jmp    800ad8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	fc                   	cld    
  800ad6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	89 04 24             	mov    %eax,(%esp)
  800af6:	e8 79 ff ff ff       	call   800a74 <memmove>
}
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	8b 55 08             	mov    0x8(%ebp),%edx
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0d:	eb 1a                	jmp    800b29 <memcmp+0x2c>
		if (*s1 != *s2)
  800b0f:	0f b6 02             	movzbl (%edx),%eax
  800b12:	0f b6 19             	movzbl (%ecx),%ebx
  800b15:	38 d8                	cmp    %bl,%al
  800b17:	74 0a                	je     800b23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b19:	0f b6 c0             	movzbl %al,%eax
  800b1c:	0f b6 db             	movzbl %bl,%ebx
  800b1f:	29 d8                	sub    %ebx,%eax
  800b21:	eb 0f                	jmp    800b32 <memcmp+0x35>
		s1++, s2++;
  800b23:	83 c2 01             	add    $0x1,%edx
  800b26:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800b29:	39 f2                	cmp    %esi,%edx
  800b2b:	75 e2                	jne    800b0f <memcmp+0x12>
	}

	return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3f:	89 c2                	mov    %eax,%edx
  800b41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b44:	eb 07                	jmp    800b4d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b46:	38 08                	cmp    %cl,(%eax)
  800b48:	74 07                	je     800b51 <memfind+0x1b>
	for (; s < ends; s++)
  800b4a:	83 c0 01             	add    $0x1,%eax
  800b4d:	39 d0                	cmp    %edx,%eax
  800b4f:	72 f5                	jb     800b46 <memfind+0x10>
			break;
	return (void *) s;
}
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5f:	eb 03                	jmp    800b64 <strtol+0x11>
		s++;
  800b61:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b64:	0f b6 0a             	movzbl (%edx),%ecx
  800b67:	80 f9 09             	cmp    $0x9,%cl
  800b6a:	74 f5                	je     800b61 <strtol+0xe>
  800b6c:	80 f9 20             	cmp    $0x20,%cl
  800b6f:	74 f0                	je     800b61 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b71:	80 f9 2b             	cmp    $0x2b,%cl
  800b74:	75 0a                	jne    800b80 <strtol+0x2d>
		s++;
  800b76:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b79:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7e:	eb 11                	jmp    800b91 <strtol+0x3e>
  800b80:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b85:	80 f9 2d             	cmp    $0x2d,%cl
  800b88:	75 07                	jne    800b91 <strtol+0x3e>
		s++, neg = 1;
  800b8a:	8d 52 01             	lea    0x1(%edx),%edx
  800b8d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b91:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b96:	75 15                	jne    800bad <strtol+0x5a>
  800b98:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9b:	75 10                	jne    800bad <strtol+0x5a>
  800b9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba1:	75 0a                	jne    800bad <strtol+0x5a>
		s += 2, base = 16;
  800ba3:	83 c2 02             	add    $0x2,%edx
  800ba6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bab:	eb 10                	jmp    800bbd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bad:	85 c0                	test   %eax,%eax
  800baf:	75 0c                	jne    800bbd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800bb3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb6:	75 05                	jne    800bbd <strtol+0x6a>
		s++, base = 8;
  800bb8:	83 c2 01             	add    $0x1,%edx
  800bbb:	b0 08                	mov    $0x8,%al
		base = 10;
  800bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc5:	0f b6 0a             	movzbl (%edx),%ecx
  800bc8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bcb:	89 f0                	mov    %esi,%eax
  800bcd:	3c 09                	cmp    $0x9,%al
  800bcf:	77 08                	ja     800bd9 <strtol+0x86>
			dig = *s - '0';
  800bd1:	0f be c9             	movsbl %cl,%ecx
  800bd4:	83 e9 30             	sub    $0x30,%ecx
  800bd7:	eb 20                	jmp    800bf9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bd9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bdc:	89 f0                	mov    %esi,%eax
  800bde:	3c 19                	cmp    $0x19,%al
  800be0:	77 08                	ja     800bea <strtol+0x97>
			dig = *s - 'a' + 10;
  800be2:	0f be c9             	movsbl %cl,%ecx
  800be5:	83 e9 57             	sub    $0x57,%ecx
  800be8:	eb 0f                	jmp    800bf9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bed:	89 f0                	mov    %esi,%eax
  800bef:	3c 19                	cmp    $0x19,%al
  800bf1:	77 16                	ja     800c09 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bf3:	0f be c9             	movsbl %cl,%ecx
  800bf6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bf9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bfc:	7d 0f                	jge    800c0d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bfe:	83 c2 01             	add    $0x1,%edx
  800c01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c05:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c07:	eb bc                	jmp    800bc5 <strtol+0x72>
  800c09:	89 d8                	mov    %ebx,%eax
  800c0b:	eb 02                	jmp    800c0f <strtol+0xbc>
  800c0d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c13:	74 05                	je     800c1a <strtol+0xc7>
		*endptr = (char *) s;
  800c15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c18:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c1a:	f7 d8                	neg    %eax
  800c1c:	85 ff                	test   %edi,%edi
  800c1e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 c3                	mov    %eax,%ebx
  800c39:	89 c7                	mov    %eax,%edi
  800c3b:	89 c6                	mov    %eax,%esi
  800c3d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	89 d3                	mov    %edx,%ebx
  800c58:	89 d7                	mov    %edx,%edi
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c71:	b8 03 00 00 00       	mov    $0x3,%eax
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 cb                	mov    %ecx,%ebx
  800c7b:	89 cf                	mov    %ecx,%edi
  800c7d:	89 ce                	mov    %ecx,%esi
  800c7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 28                	jle    800cad <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c89:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c90:	00 
  800c91:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800c98:	00 
  800c99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca0:	00 
  800ca1:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800ca8:	e8 0c f5 ff ff       	call   8001b9 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cad:	83 c4 2c             	add    $0x2c,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	89 d3                	mov    %edx,%ebx
  800cc9:	89 d7                	mov    %edx,%edi
  800ccb:	89 d6                	mov    %edx,%esi
  800ccd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_yield>:

void
sys_yield(void)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce4:	89 d1                	mov    %edx,%ecx
  800ce6:	89 d3                	mov    %edx,%ebx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cfc:	be 00 00 00 00       	mov    $0x0,%esi
  800d01:	b8 04 00 00 00       	mov    $0x4,%eax
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0f:	89 f7                	mov    %esi,%edi
  800d11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 28                	jle    800d3f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d22:	00 
  800d23:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800d3a:	e8 7a f4 ff ff       	call   8001b9 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d3f:	83 c4 2c             	add    $0x2c,%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d50:	b8 05 00 00 00       	mov    $0x5,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d61:	8b 75 18             	mov    0x18(%ebp),%esi
  800d64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 28                	jle    800d92 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d75:	00 
  800d76:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d85:	00 
  800d86:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800d8d:	e8 27 f4 ff ff       	call   8001b9 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d92:	83 c4 2c             	add    $0x2c,%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800de0:	e8 d4 f3 ff ff       	call   8001b9 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de5:	83 c4 2c             	add    $0x2c,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	b8 08 00 00 00       	mov    $0x8,%eax
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 28                	jle    800e38 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e14:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800e33:	e8 81 f3 ff ff       	call   8001b9 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e38:	83 c4 2c             	add    $0x2c,%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 df                	mov    %ebx,%edi
  800e5b:	89 de                	mov    %ebx,%esi
  800e5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	7e 28                	jle    800e8b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e67:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7e:	00 
  800e7f:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800e86:	e8 2e f3 ff ff       	call   8001b9 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e8b:	83 c4 2c             	add    $0x2c,%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	89 df                	mov    %ebx,%edi
  800eae:	89 de                	mov    %ebx,%esi
  800eb0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	7e 28                	jle    800ede <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eba:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800ec9:	00 
  800eca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed1:	00 
  800ed2:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800ed9:	e8 db f2 ff ff       	call   8001b9 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ede:	83 c4 2c             	add    $0x2c,%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eec:	be 00 00 00 00       	mov    $0x0,%esi
  800ef1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f02:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f17:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	89 cb                	mov    %ecx,%ebx
  800f21:	89 cf                	mov    %ecx,%edi
  800f23:	89 ce                	mov    %ecx,%esi
  800f25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 28                	jle    800f53 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f36:	00 
  800f37:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800f4e:	e8 66 f2 ff ff       	call   8001b9 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f53:	83 c4 2c             	add    $0x2c,%esp
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5f                   	pop    %edi
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    
  800f5b:	66 90                	xchg   %ax,%ax
  800f5d:	66 90                	xchg   %ax,%ax
  800f5f:	90                   	nop

00800f60 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f63:	8b 45 08             	mov    0x8(%ebp),%eax
  800f66:	05 00 00 00 30       	add    $0x30000000,%eax
  800f6b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f80:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f92:	89 c2                	mov    %eax,%edx
  800f94:	c1 ea 16             	shr    $0x16,%edx
  800f97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f9e:	f6 c2 01             	test   $0x1,%dl
  800fa1:	74 11                	je     800fb4 <fd_alloc+0x2d>
  800fa3:	89 c2                	mov    %eax,%edx
  800fa5:	c1 ea 0c             	shr    $0xc,%edx
  800fa8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800faf:	f6 c2 01             	test   $0x1,%dl
  800fb2:	75 09                	jne    800fbd <fd_alloc+0x36>
			*fd_store = fd;
  800fb4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbb:	eb 17                	jmp    800fd4 <fd_alloc+0x4d>
  800fbd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800fc2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fc7:	75 c9                	jne    800f92 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800fc9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fcf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fdc:	83 f8 1f             	cmp    $0x1f,%eax
  800fdf:	77 36                	ja     801017 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fe1:	c1 e0 0c             	shl    $0xc,%eax
  800fe4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fe9:	89 c2                	mov    %eax,%edx
  800feb:	c1 ea 16             	shr    $0x16,%edx
  800fee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ff5:	f6 c2 01             	test   $0x1,%dl
  800ff8:	74 24                	je     80101e <fd_lookup+0x48>
  800ffa:	89 c2                	mov    %eax,%edx
  800ffc:	c1 ea 0c             	shr    $0xc,%edx
  800fff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801006:	f6 c2 01             	test   $0x1,%dl
  801009:	74 1a                	je     801025 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80100b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100e:	89 02                	mov    %eax,(%edx)
	return 0;
  801010:	b8 00 00 00 00       	mov    $0x0,%eax
  801015:	eb 13                	jmp    80102a <fd_lookup+0x54>
		return -E_INVAL;
  801017:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80101c:	eb 0c                	jmp    80102a <fd_lookup+0x54>
		return -E_INVAL;
  80101e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801023:	eb 05                	jmp    80102a <fd_lookup+0x54>
  801025:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 18             	sub    $0x18,%esp
  801032:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801035:	ba 28 2b 80 00       	mov    $0x802b28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80103a:	eb 13                	jmp    80104f <dev_lookup+0x23>
  80103c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80103f:	39 08                	cmp    %ecx,(%eax)
  801041:	75 0c                	jne    80104f <dev_lookup+0x23>
			*dev = devtab[i];
  801043:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801046:	89 01                	mov    %eax,(%ecx)
			return 0;
  801048:	b8 00 00 00 00       	mov    $0x0,%eax
  80104d:	eb 30                	jmp    80107f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80104f:	8b 02                	mov    (%edx),%eax
  801051:	85 c0                	test   %eax,%eax
  801053:	75 e7                	jne    80103c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801055:	a1 08 40 80 00       	mov    0x804008,%eax
  80105a:	8b 40 48             	mov    0x48(%eax),%eax
  80105d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801061:	89 44 24 04          	mov    %eax,0x4(%esp)
  801065:	c7 04 24 ac 2a 80 00 	movl   $0x802aac,(%esp)
  80106c:	e8 41 f2 ff ff       	call   8002b2 <cprintf>
	*dev = 0;
  801071:	8b 45 0c             	mov    0xc(%ebp),%eax
  801074:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80107a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <fd_close>:
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 20             	sub    $0x20,%esp
  801089:	8b 75 08             	mov    0x8(%ebp),%esi
  80108c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80108f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801092:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801096:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80109c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80109f:	89 04 24             	mov    %eax,(%esp)
  8010a2:	e8 2f ff ff ff       	call   800fd6 <fd_lookup>
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 05                	js     8010b0 <fd_close+0x2f>
	    || fd != fd2)
  8010ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010ae:	74 0c                	je     8010bc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8010b0:	84 db                	test   %bl,%bl
  8010b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b7:	0f 44 c2             	cmove  %edx,%eax
  8010ba:	eb 3f                	jmp    8010fb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c3:	8b 06                	mov    (%esi),%eax
  8010c5:	89 04 24             	mov    %eax,(%esp)
  8010c8:	e8 5f ff ff ff       	call   80102c <dev_lookup>
  8010cd:	89 c3                	mov    %eax,%ebx
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 16                	js     8010e9 <fd_close+0x68>
		if (dev->dev_close)
  8010d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	74 07                	je     8010e9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8010e2:	89 34 24             	mov    %esi,(%esp)
  8010e5:	ff d0                	call   *%eax
  8010e7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8010e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f4:	e8 a1 fc ff ff       	call   800d9a <sys_page_unmap>
	return r;
  8010f9:	89 d8                	mov    %ebx,%eax
}
  8010fb:	83 c4 20             	add    $0x20,%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <close>:

int
close(int fdnum)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801108:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	89 04 24             	mov    %eax,(%esp)
  801115:	e8 bc fe ff ff       	call   800fd6 <fd_lookup>
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	85 d2                	test   %edx,%edx
  80111e:	78 13                	js     801133 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801120:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801127:	00 
  801128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112b:	89 04 24             	mov    %eax,(%esp)
  80112e:	e8 4e ff ff ff       	call   801081 <fd_close>
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <close_all>:

void
close_all(void)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	53                   	push   %ebx
  801139:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80113c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801141:	89 1c 24             	mov    %ebx,(%esp)
  801144:	e8 b9 ff ff ff       	call   801102 <close>
	for (i = 0; i < MAXFD; i++)
  801149:	83 c3 01             	add    $0x1,%ebx
  80114c:	83 fb 20             	cmp    $0x20,%ebx
  80114f:	75 f0                	jne    801141 <close_all+0xc>
}
  801151:	83 c4 14             	add    $0x14,%esp
  801154:	5b                   	pop    %ebx
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801160:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801163:	89 44 24 04          	mov    %eax,0x4(%esp)
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	89 04 24             	mov    %eax,(%esp)
  80116d:	e8 64 fe ff ff       	call   800fd6 <fd_lookup>
  801172:	89 c2                	mov    %eax,%edx
  801174:	85 d2                	test   %edx,%edx
  801176:	0f 88 e1 00 00 00    	js     80125d <dup+0x106>
		return r;
	close(newfdnum);
  80117c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117f:	89 04 24             	mov    %eax,(%esp)
  801182:	e8 7b ff ff ff       	call   801102 <close>

	newfd = INDEX2FD(newfdnum);
  801187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80118a:	c1 e3 0c             	shl    $0xc,%ebx
  80118d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801193:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801196:	89 04 24             	mov    %eax,(%esp)
  801199:	e8 d2 fd ff ff       	call   800f70 <fd2data>
  80119e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8011a0:	89 1c 24             	mov    %ebx,(%esp)
  8011a3:	e8 c8 fd ff ff       	call   800f70 <fd2data>
  8011a8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011aa:	89 f0                	mov    %esi,%eax
  8011ac:	c1 e8 16             	shr    $0x16,%eax
  8011af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b6:	a8 01                	test   $0x1,%al
  8011b8:	74 43                	je     8011fd <dup+0xa6>
  8011ba:	89 f0                	mov    %esi,%eax
  8011bc:	c1 e8 0c             	shr    $0xc,%eax
  8011bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011c6:	f6 c2 01             	test   $0x1,%dl
  8011c9:	74 32                	je     8011fd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8011d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e6:	00 
  8011e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f2:	e8 50 fb ff ff       	call   800d47 <sys_page_map>
  8011f7:	89 c6                	mov    %eax,%esi
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 3e                	js     80123b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801200:	89 c2                	mov    %eax,%edx
  801202:	c1 ea 0c             	shr    $0xc,%edx
  801205:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801212:	89 54 24 10          	mov    %edx,0x10(%esp)
  801216:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80121a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801221:	00 
  801222:	89 44 24 04          	mov    %eax,0x4(%esp)
  801226:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122d:	e8 15 fb ff ff       	call   800d47 <sys_page_map>
  801232:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801234:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801237:	85 f6                	test   %esi,%esi
  801239:	79 22                	jns    80125d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80123b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80123f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801246:	e8 4f fb ff ff       	call   800d9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80124b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80124f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801256:	e8 3f fb ff ff       	call   800d9a <sys_page_unmap>
	return r;
  80125b:	89 f0                	mov    %esi,%eax
}
  80125d:	83 c4 3c             	add    $0x3c,%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	53                   	push   %ebx
  801269:	83 ec 24             	sub    $0x24,%esp
  80126c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	89 1c 24             	mov    %ebx,(%esp)
  801279:	e8 58 fd ff ff       	call   800fd6 <fd_lookup>
  80127e:	89 c2                	mov    %eax,%edx
  801280:	85 d2                	test   %edx,%edx
  801282:	78 6d                	js     8012f1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801284:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128e:	8b 00                	mov    (%eax),%eax
  801290:	89 04 24             	mov    %eax,(%esp)
  801293:	e8 94 fd ff ff       	call   80102c <dev_lookup>
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 55                	js     8012f1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80129c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129f:	8b 50 08             	mov    0x8(%eax),%edx
  8012a2:	83 e2 03             	and    $0x3,%edx
  8012a5:	83 fa 01             	cmp    $0x1,%edx
  8012a8:	75 23                	jne    8012cd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8012af:	8b 40 48             	mov    0x48(%eax),%eax
  8012b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ba:	c7 04 24 ed 2a 80 00 	movl   $0x802aed,(%esp)
  8012c1:	e8 ec ef ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  8012c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cb:	eb 24                	jmp    8012f1 <read+0x8c>
	}
	if (!dev->dev_read)
  8012cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d0:	8b 52 08             	mov    0x8(%edx),%edx
  8012d3:	85 d2                	test   %edx,%edx
  8012d5:	74 15                	je     8012ec <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e5:	89 04 24             	mov    %eax,(%esp)
  8012e8:	ff d2                	call   *%edx
  8012ea:	eb 05                	jmp    8012f1 <read+0x8c>
		return -E_NOT_SUPP;
  8012ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8012f1:	83 c4 24             	add    $0x24,%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	57                   	push   %edi
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 1c             	sub    $0x1c,%esp
  801300:	8b 7d 08             	mov    0x8(%ebp),%edi
  801303:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130b:	eb 23                	jmp    801330 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80130d:	89 f0                	mov    %esi,%eax
  80130f:	29 d8                	sub    %ebx,%eax
  801311:	89 44 24 08          	mov    %eax,0x8(%esp)
  801315:	89 d8                	mov    %ebx,%eax
  801317:	03 45 0c             	add    0xc(%ebp),%eax
  80131a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131e:	89 3c 24             	mov    %edi,(%esp)
  801321:	e8 3f ff ff ff       	call   801265 <read>
		if (m < 0)
  801326:	85 c0                	test   %eax,%eax
  801328:	78 10                	js     80133a <readn+0x43>
			return m;
		if (m == 0)
  80132a:	85 c0                	test   %eax,%eax
  80132c:	74 0a                	je     801338 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80132e:	01 c3                	add    %eax,%ebx
  801330:	39 f3                	cmp    %esi,%ebx
  801332:	72 d9                	jb     80130d <readn+0x16>
  801334:	89 d8                	mov    %ebx,%eax
  801336:	eb 02                	jmp    80133a <readn+0x43>
  801338:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80133a:	83 c4 1c             	add    $0x1c,%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	53                   	push   %ebx
  801346:	83 ec 24             	sub    $0x24,%esp
  801349:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801353:	89 1c 24             	mov    %ebx,(%esp)
  801356:	e8 7b fc ff ff       	call   800fd6 <fd_lookup>
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	85 d2                	test   %edx,%edx
  80135f:	78 68                	js     8013c9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801361:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801364:	89 44 24 04          	mov    %eax,0x4(%esp)
  801368:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136b:	8b 00                	mov    (%eax),%eax
  80136d:	89 04 24             	mov    %eax,(%esp)
  801370:	e8 b7 fc ff ff       	call   80102c <dev_lookup>
  801375:	85 c0                	test   %eax,%eax
  801377:	78 50                	js     8013c9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801379:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801380:	75 23                	jne    8013a5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801382:	a1 08 40 80 00       	mov    0x804008,%eax
  801387:	8b 40 48             	mov    0x48(%eax),%eax
  80138a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80138e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801392:	c7 04 24 09 2b 80 00 	movl   $0x802b09,(%esp)
  801399:	e8 14 ef ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a3:	eb 24                	jmp    8013c9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ab:	85 d2                	test   %edx,%edx
  8013ad:	74 15                	je     8013c4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013af:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013bd:	89 04 24             	mov    %eax,(%esp)
  8013c0:	ff d2                	call   *%edx
  8013c2:	eb 05                	jmp    8013c9 <write+0x87>
		return -E_NOT_SUPP;
  8013c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013c9:	83 c4 24             	add    $0x24,%esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013df:	89 04 24             	mov    %eax,(%esp)
  8013e2:	e8 ef fb ff ff       	call   800fd6 <fd_lookup>
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 0e                	js     8013f9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    

008013fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 24             	sub    $0x24,%esp
  801402:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801405:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140c:	89 1c 24             	mov    %ebx,(%esp)
  80140f:	e8 c2 fb ff ff       	call   800fd6 <fd_lookup>
  801414:	89 c2                	mov    %eax,%edx
  801416:	85 d2                	test   %edx,%edx
  801418:	78 61                	js     80147b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801421:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801424:	8b 00                	mov    (%eax),%eax
  801426:	89 04 24             	mov    %eax,(%esp)
  801429:	e8 fe fb ff ff       	call   80102c <dev_lookup>
  80142e:	85 c0                	test   %eax,%eax
  801430:	78 49                	js     80147b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801432:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801435:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801439:	75 23                	jne    80145e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80143b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801440:	8b 40 48             	mov    0x48(%eax),%eax
  801443:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144b:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801452:	e8 5b ee ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  801457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145c:	eb 1d                	jmp    80147b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80145e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801461:	8b 52 18             	mov    0x18(%edx),%edx
  801464:	85 d2                	test   %edx,%edx
  801466:	74 0e                	je     801476 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80146b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80146f:	89 04 24             	mov    %eax,(%esp)
  801472:	ff d2                	call   *%edx
  801474:	eb 05                	jmp    80147b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801476:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80147b:	83 c4 24             	add    $0x24,%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    

00801481 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	53                   	push   %ebx
  801485:	83 ec 24             	sub    $0x24,%esp
  801488:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	89 04 24             	mov    %eax,(%esp)
  801498:	e8 39 fb ff ff       	call   800fd6 <fd_lookup>
  80149d:	89 c2                	mov    %eax,%edx
  80149f:	85 d2                	test   %edx,%edx
  8014a1:	78 52                	js     8014f5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	8b 00                	mov    (%eax),%eax
  8014af:	89 04 24             	mov    %eax,(%esp)
  8014b2:	e8 75 fb ff ff       	call   80102c <dev_lookup>
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 3a                	js     8014f5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8014bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014c2:	74 2c                	je     8014f0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014ce:	00 00 00 
	stat->st_isdir = 0;
  8014d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014d8:	00 00 00 
	stat->st_dev = dev;
  8014db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e8:	89 14 24             	mov    %edx,(%esp)
  8014eb:	ff 50 14             	call   *0x14(%eax)
  8014ee:	eb 05                	jmp    8014f5 <fstat+0x74>
		return -E_NOT_SUPP;
  8014f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014f5:	83 c4 24             	add    $0x24,%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801503:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80150a:	00 
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	e8 fb 01 00 00       	call   801711 <open>
  801516:	89 c3                	mov    %eax,%ebx
  801518:	85 db                	test   %ebx,%ebx
  80151a:	78 1b                	js     801537 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80151c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801523:	89 1c 24             	mov    %ebx,(%esp)
  801526:	e8 56 ff ff ff       	call   801481 <fstat>
  80152b:	89 c6                	mov    %eax,%esi
	close(fd);
  80152d:	89 1c 24             	mov    %ebx,(%esp)
  801530:	e8 cd fb ff ff       	call   801102 <close>
	return r;
  801535:	89 f0                	mov    %esi,%eax
}
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	5b                   	pop    %ebx
  80153b:	5e                   	pop    %esi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	56                   	push   %esi
  801542:	53                   	push   %ebx
  801543:	83 ec 10             	sub    $0x10,%esp
  801546:	89 c6                	mov    %eax,%esi
  801548:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80154a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801551:	75 11                	jne    801564 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801553:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80155a:	e8 10 0e 00 00       	call   80236f <ipc_find_env>
  80155f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801564:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80156b:	00 
  80156c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801573:	00 
  801574:	89 74 24 04          	mov    %esi,0x4(%esp)
  801578:	a1 04 40 80 00       	mov    0x804004,%eax
  80157d:	89 04 24             	mov    %eax,(%esp)
  801580:	e8 83 0d 00 00       	call   802308 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801585:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80158c:	00 
  80158d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801591:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801598:	e8 03 0d 00 00       	call   8022a0 <ipc_recv>
}
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8015c7:	e8 72 ff ff ff       	call   80153e <fsipc>
}
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <devfile_flush>:
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015da:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015df:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e4:	b8 06 00 00 00       	mov    $0x6,%eax
  8015e9:	e8 50 ff ff ff       	call   80153e <fsipc>
}
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <devfile_stat>:
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 14             	sub    $0x14,%esp
  8015f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801600:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801605:	ba 00 00 00 00       	mov    $0x0,%edx
  80160a:	b8 05 00 00 00       	mov    $0x5,%eax
  80160f:	e8 2a ff ff ff       	call   80153e <fsipc>
  801614:	89 c2                	mov    %eax,%edx
  801616:	85 d2                	test   %edx,%edx
  801618:	78 2b                	js     801645 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80161a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801621:	00 
  801622:	89 1c 24             	mov    %ebx,(%esp)
  801625:	e8 ad f2 ff ff       	call   8008d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80162a:	a1 80 50 80 00       	mov    0x805080,%eax
  80162f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801635:	a1 84 50 80 00       	mov    0x805084,%eax
  80163a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801645:	83 c4 14             	add    $0x14,%esp
  801648:	5b                   	pop    %ebx
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <devfile_write>:
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801651:	c7 44 24 08 38 2b 80 	movl   $0x802b38,0x8(%esp)
  801658:	00 
  801659:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801660:	00 
  801661:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  801668:	e8 4c eb ff ff       	call   8001b9 <_panic>

0080166d <devfile_read>:
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	83 ec 10             	sub    $0x10,%esp
  801675:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	8b 40 0c             	mov    0xc(%eax),%eax
  80167e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801683:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
  80168e:	b8 03 00 00 00       	mov    $0x3,%eax
  801693:	e8 a6 fe ff ff       	call   80153e <fsipc>
  801698:	89 c3                	mov    %eax,%ebx
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 6a                	js     801708 <devfile_read+0x9b>
	assert(r <= n);
  80169e:	39 c6                	cmp    %eax,%esi
  8016a0:	73 24                	jae    8016c6 <devfile_read+0x59>
  8016a2:	c7 44 24 0c 61 2b 80 	movl   $0x802b61,0xc(%esp)
  8016a9:	00 
  8016aa:	c7 44 24 08 68 2b 80 	movl   $0x802b68,0x8(%esp)
  8016b1:	00 
  8016b2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016b9:	00 
  8016ba:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  8016c1:	e8 f3 ea ff ff       	call   8001b9 <_panic>
	assert(r <= PGSIZE);
  8016c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016cb:	7e 24                	jle    8016f1 <devfile_read+0x84>
  8016cd:	c7 44 24 0c 7d 2b 80 	movl   $0x802b7d,0xc(%esp)
  8016d4:	00 
  8016d5:	c7 44 24 08 68 2b 80 	movl   $0x802b68,0x8(%esp)
  8016dc:	00 
  8016dd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016e4:	00 
  8016e5:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  8016ec:	e8 c8 ea ff ff       	call   8001b9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016fc:	00 
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801700:	89 04 24             	mov    %eax,(%esp)
  801703:	e8 6c f3 ff ff       	call   800a74 <memmove>
}
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <open>:
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	53                   	push   %ebx
  801715:	83 ec 24             	sub    $0x24,%esp
  801718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80171b:	89 1c 24             	mov    %ebx,(%esp)
  80171e:	e8 7d f1 ff ff       	call   8008a0 <strlen>
  801723:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801728:	7f 60                	jg     80178a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80172a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172d:	89 04 24             	mov    %eax,(%esp)
  801730:	e8 52 f8 ff ff       	call   800f87 <fd_alloc>
  801735:	89 c2                	mov    %eax,%edx
  801737:	85 d2                	test   %edx,%edx
  801739:	78 54                	js     80178f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80173b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80173f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801746:	e8 8c f1 ff ff       	call   8008d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80174b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801753:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801756:	b8 01 00 00 00       	mov    $0x1,%eax
  80175b:	e8 de fd ff ff       	call   80153e <fsipc>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	85 c0                	test   %eax,%eax
  801764:	79 17                	jns    80177d <open+0x6c>
		fd_close(fd, 0);
  801766:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80176d:	00 
  80176e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801771:	89 04 24             	mov    %eax,(%esp)
  801774:	e8 08 f9 ff ff       	call   801081 <fd_close>
		return r;
  801779:	89 d8                	mov    %ebx,%eax
  80177b:	eb 12                	jmp    80178f <open+0x7e>
	return fd2num(fd);
  80177d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801780:	89 04 24             	mov    %eax,(%esp)
  801783:	e8 d8 f7 ff ff       	call   800f60 <fd2num>
  801788:	eb 05                	jmp    80178f <open+0x7e>
		return -E_BAD_PATH;
  80178a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80178f:	83 c4 24             	add    $0x24,%esp
  801792:	5b                   	pop    %ebx
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8017a5:	e8 94 fd ff ff       	call   80153e <fsipc>
}
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    
  8017ac:	66 90                	xchg   %ax,%ax
  8017ae:	66 90                	xchg   %ax,%ax

008017b0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	57                   	push   %edi
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8017bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017c3:	00 
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	89 04 24             	mov    %eax,(%esp)
  8017ca:	e8 42 ff ff ff       	call   801711 <open>
  8017cf:	89 c1                	mov    %eax,%ecx
  8017d1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	0f 88 a8 04 00 00    	js     801c87 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8017df:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8017e6:	00 
  8017e7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	89 0c 24             	mov    %ecx,(%esp)
  8017f4:	e8 fe fa ff ff       	call   8012f7 <readn>
  8017f9:	3d 00 02 00 00       	cmp    $0x200,%eax
  8017fe:	75 0c                	jne    80180c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801800:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801807:	45 4c 46 
  80180a:	74 36                	je     801842 <spawn+0x92>
		close(fd);
  80180c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	e8 e8 f8 ff ff       	call   801102 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80181a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801821:	46 
  801822:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182c:	c7 04 24 89 2b 80 00 	movl   $0x802b89,(%esp)
  801833:	e8 7a ea ff ff       	call   8002b2 <cprintf>
		return -E_NOT_EXEC;
  801838:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80183d:	e9 a4 04 00 00       	jmp    801ce6 <spawn+0x536>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801842:	b8 07 00 00 00       	mov    $0x7,%eax
  801847:	cd 30                	int    $0x30
  801849:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80184f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801855:	85 c0                	test   %eax,%eax
  801857:	0f 88 32 04 00 00    	js     801c8f <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80185d:	89 c6                	mov    %eax,%esi
  80185f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801865:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801868:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80186e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801874:	b9 11 00 00 00       	mov    $0x11,%ecx
  801879:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80187b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801881:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801887:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80188c:	be 00 00 00 00       	mov    $0x0,%esi
  801891:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801894:	eb 0f                	jmp    8018a5 <spawn+0xf5>
		string_size += strlen(argv[argc]) + 1;
  801896:	89 04 24             	mov    %eax,(%esp)
  801899:	e8 02 f0 ff ff       	call   8008a0 <strlen>
  80189e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8018a2:	83 c3 01             	add    $0x1,%ebx
  8018a5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8018ac:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	75 e3                	jne    801896 <spawn+0xe6>
  8018b3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8018b9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8018bf:	bf 00 10 40 00       	mov    $0x401000,%edi
  8018c4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8018c6:	89 fa                	mov    %edi,%edx
  8018c8:	83 e2 fc             	and    $0xfffffffc,%edx
  8018cb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8018d2:	29 c2                	sub    %eax,%edx
  8018d4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8018da:	8d 42 f8             	lea    -0x8(%edx),%eax
  8018dd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8018e2:	0f 86 b7 03 00 00    	jbe    801c9f <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018e8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018ef:	00 
  8018f0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018f7:	00 
  8018f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ff:	e8 ef f3 ff ff       	call   800cf3 <sys_page_alloc>
  801904:	85 c0                	test   %eax,%eax
  801906:	0f 88 da 03 00 00    	js     801ce6 <spawn+0x536>
  80190c:	be 00 00 00 00       	mov    $0x0,%esi
  801911:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801917:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80191a:	eb 30                	jmp    80194c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80191c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801922:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801928:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80192b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80192e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801932:	89 3c 24             	mov    %edi,(%esp)
  801935:	e8 9d ef ff ff       	call   8008d7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80193a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80193d:	89 04 24             	mov    %eax,(%esp)
  801940:	e8 5b ef ff ff       	call   8008a0 <strlen>
  801945:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801949:	83 c6 01             	add    $0x1,%esi
  80194c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801952:	7f c8                	jg     80191c <spawn+0x16c>
	}
	argv_store[argc] = 0;
  801954:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80195a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801960:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801967:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80196d:	74 24                	je     801993 <spawn+0x1e3>
  80196f:	c7 44 24 0c 00 2c 80 	movl   $0x802c00,0xc(%esp)
  801976:	00 
  801977:	c7 44 24 08 68 2b 80 	movl   $0x802b68,0x8(%esp)
  80197e:	00 
  80197f:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801986:	00 
  801987:	c7 04 24 a3 2b 80 00 	movl   $0x802ba3,(%esp)
  80198e:	e8 26 e8 ff ff       	call   8001b9 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801993:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801999:	89 c8                	mov    %ecx,%eax
  80199b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8019a0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8019a3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8019a9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8019ac:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8019b2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8019b8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019bf:	00 
  8019c0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8019c7:	ee 
  8019c8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8019ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019d9:	00 
  8019da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e1:	e8 61 f3 ff ff       	call   800d47 <sys_page_map>
  8019e6:	89 c3                	mov    %eax,%ebx
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	0f 88 e0 02 00 00    	js     801cd0 <spawn+0x520>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8019f0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019f7:	00 
  8019f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ff:	e8 96 f3 ff ff       	call   800d9a <sys_page_unmap>
  801a04:	89 c3                	mov    %eax,%ebx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	0f 88 c2 02 00 00    	js     801cd0 <spawn+0x520>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a0e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801a14:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801a1b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a21:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801a28:	00 00 00 
  801a2b:	e9 b6 01 00 00       	jmp    801be6 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801a30:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801a36:	83 38 01             	cmpl   $0x1,(%eax)
  801a39:	0f 85 99 01 00 00    	jne    801bd8 <spawn+0x428>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a3f:	89 c1                	mov    %eax,%ecx
  801a41:	8b 40 18             	mov    0x18(%eax),%eax
  801a44:	83 e0 02             	and    $0x2,%eax
		perm = PTE_P | PTE_U;
  801a47:	83 f8 01             	cmp    $0x1,%eax
  801a4a:	19 c0                	sbb    %eax,%eax
  801a4c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801a52:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801a59:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a60:	89 c8                	mov    %ecx,%eax
  801a62:	8b 51 04             	mov    0x4(%ecx),%edx
  801a65:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801a6b:	8b 49 10             	mov    0x10(%ecx),%ecx
  801a6e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801a74:	8b 50 14             	mov    0x14(%eax),%edx
  801a77:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801a7d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801a80:	89 f0                	mov    %esi,%eax
  801a82:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a87:	74 14                	je     801a9d <spawn+0x2ed>
		va -= i;
  801a89:	29 c6                	sub    %eax,%esi
		memsz += i;
  801a8b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801a91:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801a97:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aa2:	e9 23 01 00 00       	jmp    801bca <spawn+0x41a>
		if (i >= filesz) {
  801aa7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801aad:	77 2b                	ja     801ada <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801aaf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801abd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ac3:	89 04 24             	mov    %eax,(%esp)
  801ac6:	e8 28 f2 ff ff       	call   800cf3 <sys_page_alloc>
  801acb:	85 c0                	test   %eax,%eax
  801acd:	0f 89 eb 00 00 00    	jns    801bbe <spawn+0x40e>
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	e9 d6 01 00 00       	jmp    801cb0 <spawn+0x500>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ada:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ae1:	00 
  801ae2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ae9:	00 
  801aea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af1:	e8 fd f1 ff ff       	call   800cf3 <sys_page_alloc>
  801af6:	85 c0                	test   %eax,%eax
  801af8:	0f 88 a8 01 00 00    	js     801ca6 <spawn+0x4f6>
  801afe:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b04:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b10:	89 04 24             	mov    %eax,(%esp)
  801b13:	e8 b7 f8 ff ff       	call   8013cf <seek>
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	0f 88 8a 01 00 00    	js     801caa <spawn+0x4fa>
  801b20:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b26:	29 fa                	sub    %edi,%edx
  801b28:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b2a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801b30:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801b35:	0f 47 c1             	cmova  %ecx,%eax
  801b38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b3c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b43:	00 
  801b44:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b4a:	89 04 24             	mov    %eax,(%esp)
  801b4d:	e8 a5 f7 ff ff       	call   8012f7 <readn>
  801b52:	85 c0                	test   %eax,%eax
  801b54:	0f 88 54 01 00 00    	js     801cae <spawn+0x4fe>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b5a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801b60:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b64:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b68:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b72:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b79:	00 
  801b7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b81:	e8 c1 f1 ff ff       	call   800d47 <sys_page_map>
  801b86:	85 c0                	test   %eax,%eax
  801b88:	79 20                	jns    801baa <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801b8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8e:	c7 44 24 08 af 2b 80 	movl   $0x802baf,0x8(%esp)
  801b95:	00 
  801b96:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801b9d:	00 
  801b9e:	c7 04 24 a3 2b 80 00 	movl   $0x802ba3,(%esp)
  801ba5:	e8 0f e6 ff ff       	call   8001b9 <_panic>
			sys_page_unmap(0, UTEMP);
  801baa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bb1:	00 
  801bb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb9:	e8 dc f1 ff ff       	call   800d9a <sys_page_unmap>
	for (i = 0; i < memsz; i += PGSIZE) {
  801bbe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801bc4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801bca:	89 df                	mov    %ebx,%edi
  801bcc:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801bd2:	0f 87 cf fe ff ff    	ja     801aa7 <spawn+0x2f7>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bd8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801bdf:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801be6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801bed:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801bf3:	0f 8c 37 fe ff ff    	jl     801a30 <spawn+0x280>
	close(fd);
  801bf9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bff:	89 04 24             	mov    %eax,(%esp)
  801c02:	e8 fb f4 ff ff       	call   801102 <close>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801c07:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801c0e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801c11:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801c17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c21:	89 04 24             	mov    %eax,(%esp)
  801c24:	e8 17 f2 ff ff       	call   800e40 <sys_env_set_trapframe>
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	79 20                	jns    801c4d <spawn+0x49d>
		panic("sys_env_set_trapframe: %e", r);
  801c2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c31:	c7 44 24 08 cc 2b 80 	movl   $0x802bcc,0x8(%esp)
  801c38:	00 
  801c39:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801c40:	00 
  801c41:	c7 04 24 a3 2b 80 00 	movl   $0x802ba3,(%esp)
  801c48:	e8 6c e5 ff ff       	call   8001b9 <_panic>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c4d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801c54:	00 
  801c55:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c5b:	89 04 24             	mov    %eax,(%esp)
  801c5e:	e8 8a f1 ff ff       	call   800ded <sys_env_set_status>
  801c63:	85 c0                	test   %eax,%eax
  801c65:	79 30                	jns    801c97 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6b:	c7 44 24 08 e6 2b 80 	movl   $0x802be6,0x8(%esp)
  801c72:	00 
  801c73:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801c7a:	00 
  801c7b:	c7 04 24 a3 2b 80 00 	movl   $0x802ba3,(%esp)
  801c82:	e8 32 e5 ff ff       	call   8001b9 <_panic>
		return r;
  801c87:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c8d:	eb 57                	jmp    801ce6 <spawn+0x536>
		return r;
  801c8f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c95:	eb 4f                	jmp    801ce6 <spawn+0x536>
	return child;
  801c97:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c9d:	eb 47                	jmp    801ce6 <spawn+0x536>
		return -E_NO_MEM;
  801c9f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801ca4:	eb 40                	jmp    801ce6 <spawn+0x536>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	eb 06                	jmp    801cb0 <spawn+0x500>
			if ((r = seek(fd, fileoffset + i)) < 0)
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	eb 02                	jmp    801cb0 <spawn+0x500>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cae:	89 c3                	mov    %eax,%ebx
	sys_env_destroy(child);
  801cb0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cb6:	89 04 24             	mov    %eax,(%esp)
  801cb9:	e8 a5 ef ff ff       	call   800c63 <sys_env_destroy>
	close(fd);
  801cbe:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801cc4:	89 04 24             	mov    %eax,(%esp)
  801cc7:	e8 36 f4 ff ff       	call   801102 <close>
	return r;
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	eb 16                	jmp    801ce6 <spawn+0x536>
	sys_page_unmap(0, UTEMP);
  801cd0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cd7:	00 
  801cd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdf:	e8 b6 f0 ff ff       	call   800d9a <sys_page_unmap>
  801ce4:	89 d8                	mov    %ebx,%eax
}
  801ce6:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5e                   	pop    %esi
  801cee:	5f                   	pop    %edi
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <spawnl>:
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	56                   	push   %esi
  801cf5:	53                   	push   %ebx
  801cf6:	83 ec 10             	sub    $0x10,%esp
	while(va_arg(vl, void *) != NULL)
  801cf9:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  801cfc:	ba 00 00 00 00       	mov    $0x0,%edx
	while(va_arg(vl, void *) != NULL)
  801d01:	eb 03                	jmp    801d06 <spawnl+0x15>
		argc++;
  801d03:	83 c2 01             	add    $0x1,%edx
	while(va_arg(vl, void *) != NULL)
  801d06:	83 c0 04             	add    $0x4,%eax
  801d09:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801d0d:	75 f4                	jne    801d03 <spawnl+0x12>
	const char *argv[argc+2];
  801d0f:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  801d16:	83 e0 f0             	and    $0xfffffff0,%eax
  801d19:	29 c4                	sub    %eax,%esp
  801d1b:	8d 44 24 0b          	lea    0xb(%esp),%eax
  801d1f:	c1 e8 02             	shr    $0x2,%eax
  801d22:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801d29:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d2e:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801d35:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  801d3c:	00 
	for(i=0;i<argc;i++)
  801d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d42:	eb 0a                	jmp    801d4e <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  801d44:	83 c0 01             	add    $0x1,%eax
  801d47:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801d4b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	for(i=0;i<argc;i++)
  801d4e:	39 d0                	cmp    %edx,%eax
  801d50:	75 f2                	jne    801d44 <spawnl+0x53>
	return spawn(prog, argv);
  801d52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	89 04 24             	mov    %eax,(%esp)
  801d5c:	e8 4f fa ff ff       	call   8017b0 <spawn>
}
  801d61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	56                   	push   %esi
  801d6c:	53                   	push   %ebx
  801d6d:	83 ec 10             	sub    $0x10,%esp
  801d70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d73:	8b 45 08             	mov    0x8(%ebp),%eax
  801d76:	89 04 24             	mov    %eax,(%esp)
  801d79:	e8 f2 f1 ff ff       	call   800f70 <fd2data>
  801d7e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d80:	c7 44 24 04 28 2c 80 	movl   $0x802c28,0x4(%esp)
  801d87:	00 
  801d88:	89 1c 24             	mov    %ebx,(%esp)
  801d8b:	e8 47 eb ff ff       	call   8008d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d90:	8b 46 04             	mov    0x4(%esi),%eax
  801d93:	2b 06                	sub    (%esi),%eax
  801d95:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d9b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801da2:	00 00 00 
	stat->st_dev = &devpipe;
  801da5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801dac:	30 80 00 
	return 0;
}
  801daf:	b8 00 00 00 00       	mov    $0x0,%eax
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 14             	sub    $0x14,%esp
  801dc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd0:	e8 c5 ef ff ff       	call   800d9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dd5:	89 1c 24             	mov    %ebx,(%esp)
  801dd8:	e8 93 f1 ff ff       	call   800f70 <fd2data>
  801ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de8:	e8 ad ef ff ff       	call   800d9a <sys_page_unmap>
}
  801ded:	83 c4 14             	add    $0x14,%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    

00801df3 <_pipeisclosed>:
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	57                   	push   %edi
  801df7:	56                   	push   %esi
  801df8:	53                   	push   %ebx
  801df9:	83 ec 2c             	sub    $0x2c,%esp
  801dfc:	89 c6                	mov    %eax,%esi
  801dfe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801e01:	a1 08 40 80 00       	mov    0x804008,%eax
  801e06:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e09:	89 34 24             	mov    %esi,(%esp)
  801e0c:	e8 96 05 00 00       	call   8023a7 <pageref>
  801e11:	89 c7                	mov    %eax,%edi
  801e13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e16:	89 04 24             	mov    %eax,(%esp)
  801e19:	e8 89 05 00 00       	call   8023a7 <pageref>
  801e1e:	39 c7                	cmp    %eax,%edi
  801e20:	0f 94 c2             	sete   %dl
  801e23:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e26:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801e2c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e2f:	39 fb                	cmp    %edi,%ebx
  801e31:	74 21                	je     801e54 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801e33:	84 d2                	test   %dl,%dl
  801e35:	74 ca                	je     801e01 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e37:	8b 51 58             	mov    0x58(%ecx),%edx
  801e3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e3e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e46:	c7 04 24 2f 2c 80 00 	movl   $0x802c2f,(%esp)
  801e4d:	e8 60 e4 ff ff       	call   8002b2 <cprintf>
  801e52:	eb ad                	jmp    801e01 <_pipeisclosed+0xe>
}
  801e54:	83 c4 2c             	add    $0x2c,%esp
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5f                   	pop    %edi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    

00801e5c <devpipe_write>:
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	57                   	push   %edi
  801e60:	56                   	push   %esi
  801e61:	53                   	push   %ebx
  801e62:	83 ec 1c             	sub    $0x1c,%esp
  801e65:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e68:	89 34 24             	mov    %esi,(%esp)
  801e6b:	e8 00 f1 ff ff       	call   800f70 <fd2data>
  801e70:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e72:	bf 00 00 00 00       	mov    $0x0,%edi
  801e77:	eb 45                	jmp    801ebe <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801e79:	89 da                	mov    %ebx,%edx
  801e7b:	89 f0                	mov    %esi,%eax
  801e7d:	e8 71 ff ff ff       	call   801df3 <_pipeisclosed>
  801e82:	85 c0                	test   %eax,%eax
  801e84:	75 41                	jne    801ec7 <devpipe_write+0x6b>
			sys_yield();
  801e86:	e8 49 ee ff ff       	call   800cd4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e8b:	8b 43 04             	mov    0x4(%ebx),%eax
  801e8e:	8b 0b                	mov    (%ebx),%ecx
  801e90:	8d 51 20             	lea    0x20(%ecx),%edx
  801e93:	39 d0                	cmp    %edx,%eax
  801e95:	73 e2                	jae    801e79 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e9a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e9e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ea1:	99                   	cltd   
  801ea2:	c1 ea 1b             	shr    $0x1b,%edx
  801ea5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801ea8:	83 e1 1f             	and    $0x1f,%ecx
  801eab:	29 d1                	sub    %edx,%ecx
  801ead:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801eb1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801eb5:	83 c0 01             	add    $0x1,%eax
  801eb8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ebb:	83 c7 01             	add    $0x1,%edi
  801ebe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ec1:	75 c8                	jne    801e8b <devpipe_write+0x2f>
	return i;
  801ec3:	89 f8                	mov    %edi,%eax
  801ec5:	eb 05                	jmp    801ecc <devpipe_write+0x70>
				return 0;
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ecc:	83 c4 1c             	add    $0x1c,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <devpipe_read>:
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	83 ec 1c             	sub    $0x1c,%esp
  801edd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ee0:	89 3c 24             	mov    %edi,(%esp)
  801ee3:	e8 88 f0 ff ff       	call   800f70 <fd2data>
  801ee8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801eea:	be 00 00 00 00       	mov    $0x0,%esi
  801eef:	eb 3d                	jmp    801f2e <devpipe_read+0x5a>
			if (i > 0)
  801ef1:	85 f6                	test   %esi,%esi
  801ef3:	74 04                	je     801ef9 <devpipe_read+0x25>
				return i;
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	eb 43                	jmp    801f3c <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801ef9:	89 da                	mov    %ebx,%edx
  801efb:	89 f8                	mov    %edi,%eax
  801efd:	e8 f1 fe ff ff       	call   801df3 <_pipeisclosed>
  801f02:	85 c0                	test   %eax,%eax
  801f04:	75 31                	jne    801f37 <devpipe_read+0x63>
			sys_yield();
  801f06:	e8 c9 ed ff ff       	call   800cd4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f0b:	8b 03                	mov    (%ebx),%eax
  801f0d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f10:	74 df                	je     801ef1 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f12:	99                   	cltd   
  801f13:	c1 ea 1b             	shr    $0x1b,%edx
  801f16:	01 d0                	add    %edx,%eax
  801f18:	83 e0 1f             	and    $0x1f,%eax
  801f1b:	29 d0                	sub    %edx,%eax
  801f1d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f25:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f28:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f2b:	83 c6 01             	add    $0x1,%esi
  801f2e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f31:	75 d8                	jne    801f0b <devpipe_read+0x37>
	return i;
  801f33:	89 f0                	mov    %esi,%eax
  801f35:	eb 05                	jmp    801f3c <devpipe_read+0x68>
				return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f3c:	83 c4 1c             	add    $0x1c,%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <pipe>:
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	56                   	push   %esi
  801f48:	53                   	push   %ebx
  801f49:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4f:	89 04 24             	mov    %eax,(%esp)
  801f52:	e8 30 f0 ff ff       	call   800f87 <fd_alloc>
  801f57:	89 c2                	mov    %eax,%edx
  801f59:	85 d2                	test   %edx,%edx
  801f5b:	0f 88 4d 01 00 00    	js     8020ae <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f61:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f68:	00 
  801f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f77:	e8 77 ed ff ff       	call   800cf3 <sys_page_alloc>
  801f7c:	89 c2                	mov    %eax,%edx
  801f7e:	85 d2                	test   %edx,%edx
  801f80:	0f 88 28 01 00 00    	js     8020ae <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801f86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f89:	89 04 24             	mov    %eax,(%esp)
  801f8c:	e8 f6 ef ff ff       	call   800f87 <fd_alloc>
  801f91:	89 c3                	mov    %eax,%ebx
  801f93:	85 c0                	test   %eax,%eax
  801f95:	0f 88 fe 00 00 00    	js     802099 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fa2:	00 
  801fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801faa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb1:	e8 3d ed ff ff       	call   800cf3 <sys_page_alloc>
  801fb6:	89 c3                	mov    %eax,%ebx
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	0f 88 d9 00 00 00    	js     802099 <pipe+0x155>
	va = fd2data(fd0);
  801fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc3:	89 04 24             	mov    %eax,(%esp)
  801fc6:	e8 a5 ef ff ff       	call   800f70 <fd2data>
  801fcb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fcd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fd4:	00 
  801fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe0:	e8 0e ed ff ff       	call   800cf3 <sys_page_alloc>
  801fe5:	89 c3                	mov    %eax,%ebx
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	0f 88 97 00 00 00    	js     802086 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff2:	89 04 24             	mov    %eax,(%esp)
  801ff5:	e8 76 ef ff ff       	call   800f70 <fd2data>
  801ffa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802001:	00 
  802002:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802006:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80200d:	00 
  80200e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802019:	e8 29 ed ff ff       	call   800d47 <sys_page_map>
  80201e:	89 c3                	mov    %eax,%ebx
  802020:	85 c0                	test   %eax,%eax
  802022:	78 52                	js     802076 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  802024:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80202a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  802039:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80203f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802042:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802044:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802047:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80204e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802051:	89 04 24             	mov    %eax,(%esp)
  802054:	e8 07 ef ff ff       	call   800f60 <fd2num>
  802059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80205c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80205e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802061:	89 04 24             	mov    %eax,(%esp)
  802064:	e8 f7 ee ff ff       	call   800f60 <fd2num>
  802069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80206c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80206f:	b8 00 00 00 00       	mov    $0x0,%eax
  802074:	eb 38                	jmp    8020ae <pipe+0x16a>
	sys_page_unmap(0, va);
  802076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802081:	e8 14 ed ff ff       	call   800d9a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  802086:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802094:	e8 01 ed ff ff       	call   800d9a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  802099:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a7:	e8 ee ec ff ff       	call   800d9a <sys_page_unmap>
  8020ac:	89 d8                	mov    %ebx,%eax
}
  8020ae:	83 c4 30             	add    $0x30,%esp
  8020b1:	5b                   	pop    %ebx
  8020b2:	5e                   	pop    %esi
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    

008020b5 <pipeisclosed>:
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c5:	89 04 24             	mov    %eax,(%esp)
  8020c8:	e8 09 ef ff ff       	call   800fd6 <fd_lookup>
  8020cd:	89 c2                	mov    %eax,%edx
  8020cf:	85 d2                	test   %edx,%edx
  8020d1:	78 15                	js     8020e8 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  8020d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d6:	89 04 24             	mov    %eax,(%esp)
  8020d9:	e8 92 ee ff ff       	call   800f70 <fd2data>
	return _pipeisclosed(fd, p);
  8020de:	89 c2                	mov    %eax,%edx
  8020e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e3:	e8 0b fd ff ff       	call   801df3 <_pipeisclosed>
}
  8020e8:	c9                   	leave  
  8020e9:	c3                   	ret    
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    

008020fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802100:	c7 44 24 04 47 2c 80 	movl   $0x802c47,0x4(%esp)
  802107:	00 
  802108:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210b:	89 04 24             	mov    %eax,(%esp)
  80210e:	e8 c4 e7 ff ff       	call   8008d7 <strcpy>
	return 0;
}
  802113:	b8 00 00 00 00       	mov    $0x0,%eax
  802118:	c9                   	leave  
  802119:	c3                   	ret    

0080211a <devcons_write>:
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	57                   	push   %edi
  80211e:	56                   	push   %esi
  80211f:	53                   	push   %ebx
  802120:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  802126:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80212b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802131:	eb 31                	jmp    802164 <devcons_write+0x4a>
		m = n - tot;
  802133:	8b 75 10             	mov    0x10(%ebp),%esi
  802136:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802138:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80213b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802140:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802143:	89 74 24 08          	mov    %esi,0x8(%esp)
  802147:	03 45 0c             	add    0xc(%ebp),%eax
  80214a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80214e:	89 3c 24             	mov    %edi,(%esp)
  802151:	e8 1e e9 ff ff       	call   800a74 <memmove>
		sys_cputs(buf, m);
  802156:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215a:	89 3c 24             	mov    %edi,(%esp)
  80215d:	e8 c4 ea ff ff       	call   800c26 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802162:	01 f3                	add    %esi,%ebx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802169:	72 c8                	jb     802133 <devcons_write+0x19>
}
  80216b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802171:	5b                   	pop    %ebx
  802172:	5e                   	pop    %esi
  802173:	5f                   	pop    %edi
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    

00802176 <devcons_read>:
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80217c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802181:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802185:	75 07                	jne    80218e <devcons_read+0x18>
  802187:	eb 2a                	jmp    8021b3 <devcons_read+0x3d>
		sys_yield();
  802189:	e8 46 eb ff ff       	call   800cd4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80218e:	66 90                	xchg   %ax,%ax
  802190:	e8 af ea ff ff       	call   800c44 <sys_cgetc>
  802195:	85 c0                	test   %eax,%eax
  802197:	74 f0                	je     802189 <devcons_read+0x13>
	if (c < 0)
  802199:	85 c0                	test   %eax,%eax
  80219b:	78 16                	js     8021b3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80219d:	83 f8 04             	cmp    $0x4,%eax
  8021a0:	74 0c                	je     8021ae <devcons_read+0x38>
	*(char*)vbuf = c;
  8021a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021a5:	88 02                	mov    %al,(%edx)
	return 1;
  8021a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ac:	eb 05                	jmp    8021b3 <devcons_read+0x3d>
		return 0;
  8021ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021b3:	c9                   	leave  
  8021b4:	c3                   	ret    

008021b5 <cputchar>:
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021be:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021c8:	00 
  8021c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021cc:	89 04 24             	mov    %eax,(%esp)
  8021cf:	e8 52 ea ff ff       	call   800c26 <sys_cputs>
}
  8021d4:	c9                   	leave  
  8021d5:	c3                   	ret    

008021d6 <getchar>:
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8021dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021e3:	00 
  8021e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f2:	e8 6e f0 ff ff       	call   801265 <read>
	if (r < 0)
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	78 0f                	js     80220a <getchar+0x34>
	if (r < 1)
  8021fb:	85 c0                	test   %eax,%eax
  8021fd:	7e 06                	jle    802205 <getchar+0x2f>
	return c;
  8021ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802203:	eb 05                	jmp    80220a <getchar+0x34>
		return -E_EOF;
  802205:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80220a:	c9                   	leave  
  80220b:	c3                   	ret    

0080220c <iscons>:
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802212:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802215:	89 44 24 04          	mov    %eax,0x4(%esp)
  802219:	8b 45 08             	mov    0x8(%ebp),%eax
  80221c:	89 04 24             	mov    %eax,(%esp)
  80221f:	e8 b2 ed ff ff       	call   800fd6 <fd_lookup>
  802224:	85 c0                	test   %eax,%eax
  802226:	78 11                	js     802239 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802231:	39 10                	cmp    %edx,(%eax)
  802233:	0f 94 c0             	sete   %al
  802236:	0f b6 c0             	movzbl %al,%eax
}
  802239:	c9                   	leave  
  80223a:	c3                   	ret    

0080223b <opencons>:
{
  80223b:	55                   	push   %ebp
  80223c:	89 e5                	mov    %esp,%ebp
  80223e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802244:	89 04 24             	mov    %eax,(%esp)
  802247:	e8 3b ed ff ff       	call   800f87 <fd_alloc>
		return r;
  80224c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80224e:	85 c0                	test   %eax,%eax
  802250:	78 40                	js     802292 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802252:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802259:	00 
  80225a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802261:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802268:	e8 86 ea ff ff       	call   800cf3 <sys_page_alloc>
		return r;
  80226d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 1f                	js     802292 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802273:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802279:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80227e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802281:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802288:	89 04 24             	mov    %eax,(%esp)
  80228b:	e8 d0 ec ff ff       	call   800f60 <fd2num>
  802290:	89 c2                	mov    %eax,%edx
}
  802292:	89 d0                	mov    %edx,%eax
  802294:	c9                   	leave  
  802295:	c3                   	ret    
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	56                   	push   %esi
  8022a4:	53                   	push   %ebx
  8022a5:	83 ec 10             	sub    $0x10,%esp
  8022a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8022ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  8022b1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  8022b3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8022b8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  8022bb:	89 04 24             	mov    %eax,(%esp)
  8022be:	e8 46 ec ff ff       	call   800f09 <sys_ipc_recv>
    if(r < 0){
  8022c3:	85 c0                	test   %eax,%eax
  8022c5:	79 16                	jns    8022dd <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  8022c7:	85 f6                	test   %esi,%esi
  8022c9:	74 06                	je     8022d1 <ipc_recv+0x31>
            *from_env_store = 0;
  8022cb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  8022d1:	85 db                	test   %ebx,%ebx
  8022d3:	74 2c                	je     802301 <ipc_recv+0x61>
            *perm_store = 0;
  8022d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8022db:	eb 24                	jmp    802301 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  8022dd:	85 f6                	test   %esi,%esi
  8022df:	74 0a                	je     8022eb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  8022e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8022e6:	8b 40 74             	mov    0x74(%eax),%eax
  8022e9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  8022eb:	85 db                	test   %ebx,%ebx
  8022ed:	74 0a                	je     8022f9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  8022ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8022f4:	8b 40 78             	mov    0x78(%eax),%eax
  8022f7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8022f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8022fe:	8b 40 70             	mov    0x70(%eax),%eax
}
  802301:	83 c4 10             	add    $0x10,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    

00802308 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802308:	55                   	push   %ebp
  802309:	89 e5                	mov    %esp,%ebp
  80230b:	57                   	push   %edi
  80230c:	56                   	push   %esi
  80230d:	53                   	push   %ebx
  80230e:	83 ec 1c             	sub    $0x1c,%esp
  802311:	8b 7d 08             	mov    0x8(%ebp),%edi
  802314:	8b 75 0c             	mov    0xc(%ebp),%esi
  802317:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80231a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80231c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802321:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802324:	8b 45 14             	mov    0x14(%ebp),%eax
  802327:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80232b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80232f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	e8 ab eb ff ff       	call   800ee6 <sys_ipc_try_send>
        if(r == 0){
  80233b:	85 c0                	test   %eax,%eax
  80233d:	74 28                	je     802367 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80233f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802342:	74 1c                	je     802360 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  802344:	c7 44 24 08 53 2c 80 	movl   $0x802c53,0x8(%esp)
  80234b:	00 
  80234c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802353:	00 
  802354:	c7 04 24 6a 2c 80 00 	movl   $0x802c6a,(%esp)
  80235b:	e8 59 de ff ff       	call   8001b9 <_panic>
        }
        sys_yield();
  802360:	e8 6f e9 ff ff       	call   800cd4 <sys_yield>
    }
  802365:	eb bd                	jmp    802324 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802367:	83 c4 1c             	add    $0x1c,%esp
  80236a:	5b                   	pop    %ebx
  80236b:	5e                   	pop    %esi
  80236c:	5f                   	pop    %edi
  80236d:	5d                   	pop    %ebp
  80236e:	c3                   	ret    

0080236f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802375:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80237a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80237d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802383:	8b 52 50             	mov    0x50(%edx),%edx
  802386:	39 ca                	cmp    %ecx,%edx
  802388:	75 0d                	jne    802397 <ipc_find_env+0x28>
			return envs[i].env_id;
  80238a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80238d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802392:	8b 40 40             	mov    0x40(%eax),%eax
  802395:	eb 0e                	jmp    8023a5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802397:	83 c0 01             	add    $0x1,%eax
  80239a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80239f:	75 d9                	jne    80237a <ipc_find_env+0xb>
	return 0;
  8023a1:	66 b8 00 00          	mov    $0x0,%ax
}
  8023a5:	5d                   	pop    %ebp
  8023a6:	c3                   	ret    

008023a7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023a7:	55                   	push   %ebp
  8023a8:	89 e5                	mov    %esp,%ebp
  8023aa:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023ad:	89 d0                	mov    %edx,%eax
  8023af:	c1 e8 16             	shr    $0x16,%eax
  8023b2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023b9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8023be:	f6 c1 01             	test   $0x1,%cl
  8023c1:	74 1d                	je     8023e0 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8023c3:	c1 ea 0c             	shr    $0xc,%edx
  8023c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023cd:	f6 c2 01             	test   $0x1,%dl
  8023d0:	74 0e                	je     8023e0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023d2:	c1 ea 0c             	shr    $0xc,%edx
  8023d5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023dc:	ef 
  8023dd:	0f b7 c0             	movzwl %ax,%eax
}
  8023e0:	5d                   	pop    %ebp
  8023e1:	c3                   	ret    
  8023e2:	66 90                	xchg   %ax,%ax
  8023e4:	66 90                	xchg   %ax,%ax
  8023e6:	66 90                	xchg   %ax,%ax
  8023e8:	66 90                	xchg   %ax,%ax
  8023ea:	66 90                	xchg   %ax,%ax
  8023ec:	66 90                	xchg   %ax,%ax
  8023ee:	66 90                	xchg   %ax,%ax

008023f0 <__udivdi3>:
  8023f0:	55                   	push   %ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	83 ec 0c             	sub    $0xc,%esp
  8023f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8023fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802402:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802406:	85 c0                	test   %eax,%eax
  802408:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80240c:	89 ea                	mov    %ebp,%edx
  80240e:	89 0c 24             	mov    %ecx,(%esp)
  802411:	75 2d                	jne    802440 <__udivdi3+0x50>
  802413:	39 e9                	cmp    %ebp,%ecx
  802415:	77 61                	ja     802478 <__udivdi3+0x88>
  802417:	85 c9                	test   %ecx,%ecx
  802419:	89 ce                	mov    %ecx,%esi
  80241b:	75 0b                	jne    802428 <__udivdi3+0x38>
  80241d:	b8 01 00 00 00       	mov    $0x1,%eax
  802422:	31 d2                	xor    %edx,%edx
  802424:	f7 f1                	div    %ecx
  802426:	89 c6                	mov    %eax,%esi
  802428:	31 d2                	xor    %edx,%edx
  80242a:	89 e8                	mov    %ebp,%eax
  80242c:	f7 f6                	div    %esi
  80242e:	89 c5                	mov    %eax,%ebp
  802430:	89 f8                	mov    %edi,%eax
  802432:	f7 f6                	div    %esi
  802434:	89 ea                	mov    %ebp,%edx
  802436:	83 c4 0c             	add    $0xc,%esp
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	39 e8                	cmp    %ebp,%eax
  802442:	77 24                	ja     802468 <__udivdi3+0x78>
  802444:	0f bd e8             	bsr    %eax,%ebp
  802447:	83 f5 1f             	xor    $0x1f,%ebp
  80244a:	75 3c                	jne    802488 <__udivdi3+0x98>
  80244c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802450:	39 34 24             	cmp    %esi,(%esp)
  802453:	0f 86 9f 00 00 00    	jbe    8024f8 <__udivdi3+0x108>
  802459:	39 d0                	cmp    %edx,%eax
  80245b:	0f 82 97 00 00 00    	jb     8024f8 <__udivdi3+0x108>
  802461:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802468:	31 d2                	xor    %edx,%edx
  80246a:	31 c0                	xor    %eax,%eax
  80246c:	83 c4 0c             	add    $0xc,%esp
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
  802473:	90                   	nop
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	89 f8                	mov    %edi,%eax
  80247a:	f7 f1                	div    %ecx
  80247c:	31 d2                	xor    %edx,%edx
  80247e:	83 c4 0c             	add    $0xc,%esp
  802481:	5e                   	pop    %esi
  802482:	5f                   	pop    %edi
  802483:	5d                   	pop    %ebp
  802484:	c3                   	ret    
  802485:	8d 76 00             	lea    0x0(%esi),%esi
  802488:	89 e9                	mov    %ebp,%ecx
  80248a:	8b 3c 24             	mov    (%esp),%edi
  80248d:	d3 e0                	shl    %cl,%eax
  80248f:	89 c6                	mov    %eax,%esi
  802491:	b8 20 00 00 00       	mov    $0x20,%eax
  802496:	29 e8                	sub    %ebp,%eax
  802498:	89 c1                	mov    %eax,%ecx
  80249a:	d3 ef                	shr    %cl,%edi
  80249c:	89 e9                	mov    %ebp,%ecx
  80249e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8024a2:	8b 3c 24             	mov    (%esp),%edi
  8024a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8024a9:	89 d6                	mov    %edx,%esi
  8024ab:	d3 e7                	shl    %cl,%edi
  8024ad:	89 c1                	mov    %eax,%ecx
  8024af:	89 3c 24             	mov    %edi,(%esp)
  8024b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024b6:	d3 ee                	shr    %cl,%esi
  8024b8:	89 e9                	mov    %ebp,%ecx
  8024ba:	d3 e2                	shl    %cl,%edx
  8024bc:	89 c1                	mov    %eax,%ecx
  8024be:	d3 ef                	shr    %cl,%edi
  8024c0:	09 d7                	or     %edx,%edi
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	89 f8                	mov    %edi,%eax
  8024c6:	f7 74 24 08          	divl   0x8(%esp)
  8024ca:	89 d6                	mov    %edx,%esi
  8024cc:	89 c7                	mov    %eax,%edi
  8024ce:	f7 24 24             	mull   (%esp)
  8024d1:	39 d6                	cmp    %edx,%esi
  8024d3:	89 14 24             	mov    %edx,(%esp)
  8024d6:	72 30                	jb     802508 <__udivdi3+0x118>
  8024d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024dc:	89 e9                	mov    %ebp,%ecx
  8024de:	d3 e2                	shl    %cl,%edx
  8024e0:	39 c2                	cmp    %eax,%edx
  8024e2:	73 05                	jae    8024e9 <__udivdi3+0xf9>
  8024e4:	3b 34 24             	cmp    (%esp),%esi
  8024e7:	74 1f                	je     802508 <__udivdi3+0x118>
  8024e9:	89 f8                	mov    %edi,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	e9 7a ff ff ff       	jmp    80246c <__udivdi3+0x7c>
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ff:	e9 68 ff ff ff       	jmp    80246c <__udivdi3+0x7c>
  802504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802508:	8d 47 ff             	lea    -0x1(%edi),%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	83 c4 0c             	add    $0xc,%esp
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	66 90                	xchg   %ax,%ax
  802516:	66 90                	xchg   %ax,%ax
  802518:	66 90                	xchg   %ax,%ax
  80251a:	66 90                	xchg   %ax,%ax
  80251c:	66 90                	xchg   %ax,%ax
  80251e:	66 90                	xchg   %ax,%ax

00802520 <__umoddi3>:
  802520:	55                   	push   %ebp
  802521:	57                   	push   %edi
  802522:	56                   	push   %esi
  802523:	83 ec 14             	sub    $0x14,%esp
  802526:	8b 44 24 28          	mov    0x28(%esp),%eax
  80252a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80252e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802532:	89 c7                	mov    %eax,%edi
  802534:	89 44 24 04          	mov    %eax,0x4(%esp)
  802538:	8b 44 24 30          	mov    0x30(%esp),%eax
  80253c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802540:	89 34 24             	mov    %esi,(%esp)
  802543:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802547:	85 c0                	test   %eax,%eax
  802549:	89 c2                	mov    %eax,%edx
  80254b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80254f:	75 17                	jne    802568 <__umoddi3+0x48>
  802551:	39 fe                	cmp    %edi,%esi
  802553:	76 4b                	jbe    8025a0 <__umoddi3+0x80>
  802555:	89 c8                	mov    %ecx,%eax
  802557:	89 fa                	mov    %edi,%edx
  802559:	f7 f6                	div    %esi
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	31 d2                	xor    %edx,%edx
  80255f:	83 c4 14             	add    $0x14,%esp
  802562:	5e                   	pop    %esi
  802563:	5f                   	pop    %edi
  802564:	5d                   	pop    %ebp
  802565:	c3                   	ret    
  802566:	66 90                	xchg   %ax,%ax
  802568:	39 f8                	cmp    %edi,%eax
  80256a:	77 54                	ja     8025c0 <__umoddi3+0xa0>
  80256c:	0f bd e8             	bsr    %eax,%ebp
  80256f:	83 f5 1f             	xor    $0x1f,%ebp
  802572:	75 5c                	jne    8025d0 <__umoddi3+0xb0>
  802574:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802578:	39 3c 24             	cmp    %edi,(%esp)
  80257b:	0f 87 e7 00 00 00    	ja     802668 <__umoddi3+0x148>
  802581:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802585:	29 f1                	sub    %esi,%ecx
  802587:	19 c7                	sbb    %eax,%edi
  802589:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80258d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802591:	8b 44 24 08          	mov    0x8(%esp),%eax
  802595:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802599:	83 c4 14             	add    $0x14,%esp
  80259c:	5e                   	pop    %esi
  80259d:	5f                   	pop    %edi
  80259e:	5d                   	pop    %ebp
  80259f:	c3                   	ret    
  8025a0:	85 f6                	test   %esi,%esi
  8025a2:	89 f5                	mov    %esi,%ebp
  8025a4:	75 0b                	jne    8025b1 <__umoddi3+0x91>
  8025a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ab:	31 d2                	xor    %edx,%edx
  8025ad:	f7 f6                	div    %esi
  8025af:	89 c5                	mov    %eax,%ebp
  8025b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025b5:	31 d2                	xor    %edx,%edx
  8025b7:	f7 f5                	div    %ebp
  8025b9:	89 c8                	mov    %ecx,%eax
  8025bb:	f7 f5                	div    %ebp
  8025bd:	eb 9c                	jmp    80255b <__umoddi3+0x3b>
  8025bf:	90                   	nop
  8025c0:	89 c8                	mov    %ecx,%eax
  8025c2:	89 fa                	mov    %edi,%edx
  8025c4:	83 c4 14             	add    $0x14,%esp
  8025c7:	5e                   	pop    %esi
  8025c8:	5f                   	pop    %edi
  8025c9:	5d                   	pop    %ebp
  8025ca:	c3                   	ret    
  8025cb:	90                   	nop
  8025cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	8b 04 24             	mov    (%esp),%eax
  8025d3:	be 20 00 00 00       	mov    $0x20,%esi
  8025d8:	89 e9                	mov    %ebp,%ecx
  8025da:	29 ee                	sub    %ebp,%esi
  8025dc:	d3 e2                	shl    %cl,%edx
  8025de:	89 f1                	mov    %esi,%ecx
  8025e0:	d3 e8                	shr    %cl,%eax
  8025e2:	89 e9                	mov    %ebp,%ecx
  8025e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e8:	8b 04 24             	mov    (%esp),%eax
  8025eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8025ef:	89 fa                	mov    %edi,%edx
  8025f1:	d3 e0                	shl    %cl,%eax
  8025f3:	89 f1                	mov    %esi,%ecx
  8025f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8025fd:	d3 ea                	shr    %cl,%edx
  8025ff:	89 e9                	mov    %ebp,%ecx
  802601:	d3 e7                	shl    %cl,%edi
  802603:	89 f1                	mov    %esi,%ecx
  802605:	d3 e8                	shr    %cl,%eax
  802607:	89 e9                	mov    %ebp,%ecx
  802609:	09 f8                	or     %edi,%eax
  80260b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80260f:	f7 74 24 04          	divl   0x4(%esp)
  802613:	d3 e7                	shl    %cl,%edi
  802615:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802619:	89 d7                	mov    %edx,%edi
  80261b:	f7 64 24 08          	mull   0x8(%esp)
  80261f:	39 d7                	cmp    %edx,%edi
  802621:	89 c1                	mov    %eax,%ecx
  802623:	89 14 24             	mov    %edx,(%esp)
  802626:	72 2c                	jb     802654 <__umoddi3+0x134>
  802628:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80262c:	72 22                	jb     802650 <__umoddi3+0x130>
  80262e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802632:	29 c8                	sub    %ecx,%eax
  802634:	19 d7                	sbb    %edx,%edi
  802636:	89 e9                	mov    %ebp,%ecx
  802638:	89 fa                	mov    %edi,%edx
  80263a:	d3 e8                	shr    %cl,%eax
  80263c:	89 f1                	mov    %esi,%ecx
  80263e:	d3 e2                	shl    %cl,%edx
  802640:	89 e9                	mov    %ebp,%ecx
  802642:	d3 ef                	shr    %cl,%edi
  802644:	09 d0                	or     %edx,%eax
  802646:	89 fa                	mov    %edi,%edx
  802648:	83 c4 14             	add    $0x14,%esp
  80264b:	5e                   	pop    %esi
  80264c:	5f                   	pop    %edi
  80264d:	5d                   	pop    %ebp
  80264e:	c3                   	ret    
  80264f:	90                   	nop
  802650:	39 d7                	cmp    %edx,%edi
  802652:	75 da                	jne    80262e <__umoddi3+0x10e>
  802654:	8b 14 24             	mov    (%esp),%edx
  802657:	89 c1                	mov    %eax,%ecx
  802659:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80265d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802661:	eb cb                	jmp    80262e <__umoddi3+0x10e>
  802663:	90                   	nop
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80266c:	0f 82 0f ff ff ff    	jb     802581 <__umoddi3+0x61>
  802672:	e9 1a ff ff ff       	jmp    802591 <__umoddi3+0x71>
