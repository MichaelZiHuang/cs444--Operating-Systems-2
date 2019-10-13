
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 34 01 00 00       	call   800165 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003e:	eb 43                	jmp    800083 <cat+0x50>
		if ((r = write(1, buf, n)) != n)
  800040:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800044:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80004b:	00 
  80004c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800053:	e8 fa 12 00 00       	call   801352 <write>
  800058:	39 d8                	cmp    %ebx,%eax
  80005a:	74 27                	je     800083 <cat+0x50>
			panic("write error copying %s: %e", s, r);
  80005c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800060:	8b 45 0c             	mov    0xc(%ebp),%eax
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 20 22 80 	movl   $0x802220,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 3b 22 80 00 	movl   $0x80223b,(%esp)
  80007e:	e8 43 01 00 00       	call   8001c6 <_panic>
	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800083:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008a:	00 
  80008b:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800092:	00 
  800093:	89 34 24             	mov    %esi,(%esp)
  800096:	e8 da 11 00 00       	call   801275 <read>
  80009b:	89 c3                	mov    %eax,%ebx
  80009d:	85 c0                	test   %eax,%eax
  80009f:	7f 9f                	jg     800040 <cat+0xd>
	if (n < 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	79 27                	jns    8000cc <cat+0x99>
		panic("error reading %s: %e", s, n);
  8000a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	c7 44 24 08 46 22 80 	movl   $0x802246,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 3b 22 80 00 	movl   $0x80223b,(%esp)
  8000c7:	e8 fa 00 00 00       	call   8001c6 <_panic>
}
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 5b 	movl   $0x80225b,0x803000
  8000e6:	22 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	74 07                	je     8000f6 <umain+0x23>
  8000ef:	bb 01 00 00 00       	mov    $0x1,%ebx
  8000f4:	eb 62                	jmp    800158 <umain+0x85>
		cat(0, "<stdin>");
  8000f6:	c7 44 24 04 5f 22 80 	movl   $0x80225f,0x4(%esp)
  8000fd:	00 
  8000fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800105:	e8 29 ff ff ff       	call   800033 <cat>
  80010a:	eb 51                	jmp    80015d <umain+0x8a>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80010c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800113:	00 
  800114:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800117:	89 04 24             	mov    %eax,(%esp)
  80011a:	e8 02 16 00 00       	call   801721 <open>
  80011f:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	79 19                	jns    80013e <umain+0x6b>
				printf("can't open %s: %e\n", argv[i], f);
  800125:	89 44 24 08          	mov    %eax,0x8(%esp)
  800129:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 67 22 80 00 	movl   $0x802267,(%esp)
  800137:	e8 95 17 00 00       	call   8018d1 <printf>
  80013c:	eb 17                	jmp    800155 <umain+0x82>
			else {
				cat(f, argv[i]);
  80013e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	89 34 24             	mov    %esi,(%esp)
  800148:	e8 e6 fe ff ff       	call   800033 <cat>
				close(f);
  80014d:	89 34 24             	mov    %esi,(%esp)
  800150:	e8 bd 0f 00 00       	call   801112 <close>
		for (i = 1; i < argc; i++) {
  800155:	83 c3 01             	add    $0x1,%ebx
  800158:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80015b:	7c af                	jl     80010c <umain+0x39>
			}
		}
}
  80015d:	83 c4 1c             	add    $0x1c,%esp
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	83 ec 10             	sub    $0x10,%esp
  80016d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800170:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800173:	e8 4d 0b 00 00       	call   800cc5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800178:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800180:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800185:	a3 20 60 80 00       	mov    %eax,0x806020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80018a:	85 db                	test   %ebx,%ebx
  80018c:	7e 07                	jle    800195 <libmain+0x30>
		binaryname = argv[0];
  80018e:	8b 06                	mov    (%esi),%eax
  800190:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800195:	89 74 24 04          	mov    %esi,0x4(%esp)
  800199:	89 1c 24             	mov    %ebx,(%esp)
  80019c:	e8 32 ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001a1:	e8 07 00 00 00       	call   8001ad <exit>
}
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b3:	e8 8d 0f 00 00       	call   801145 <close_all>
	sys_env_destroy(0);
  8001b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001bf:	e8 af 0a 00 00       	call   800c73 <sys_env_destroy>
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001d7:	e8 e9 0a 00 00       	call   800cc5 <sys_getenvid>
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  8001f9:	e8 c1 00 00 00       	call   8002bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800202:	8b 45 10             	mov    0x10(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 51 00 00 00       	call   80025e <vcprintf>
	cprintf("\n");
  80020d:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  800214:	e8 a6 00 00 00       	call   8002bf <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800219:	cc                   	int3   
  80021a:	eb fd                	jmp    800219 <_panic+0x53>

0080021c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	53                   	push   %ebx
  800220:	83 ec 14             	sub    $0x14,%esp
  800223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800226:	8b 13                	mov    (%ebx),%edx
  800228:	8d 42 01             	lea    0x1(%edx),%eax
  80022b:	89 03                	mov    %eax,(%ebx)
  80022d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800230:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800234:	3d ff 00 00 00       	cmp    $0xff,%eax
  800239:	75 19                	jne    800254 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80023b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800242:	00 
  800243:	8d 43 08             	lea    0x8(%ebx),%eax
  800246:	89 04 24             	mov    %eax,(%esp)
  800249:	e8 e8 09 00 00       	call   800c36 <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800254:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800258:	83 c4 14             	add    $0x14,%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800267:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026e:	00 00 00 
	b.cnt = 0;
  800271:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800278:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 44 24 08          	mov    %eax,0x8(%esp)
  800289:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800293:	c7 04 24 1c 02 80 00 	movl   $0x80021c,(%esp)
  80029a:	e8 af 01 00 00       	call   80044e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	e8 7f 09 00 00       	call   800c36 <sys_cputs>

	return b.cnt;
}
  8002b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	e8 87 ff ff ff       	call   80025e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    
  8002d9:	66 90                	xchg   %ax,%ax
  8002db:	66 90                	xchg   %ax,%ax
  8002dd:	66 90                	xchg   %ax,%ax
  8002df:	90                   	nop

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 c3                	mov    %eax,%ebx
  8002f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800302:	b9 00 00 00 00       	mov    $0x0,%ecx
  800307:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80030d:	39 d9                	cmp    %ebx,%ecx
  80030f:	72 05                	jb     800316 <printnum+0x36>
  800311:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800314:	77 69                	ja     80037f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800316:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800319:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80031d:	83 ee 01             	sub    $0x1,%esi
  800320:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800324:	89 44 24 08          	mov    %eax,0x8(%esp)
  800328:	8b 44 24 08          	mov    0x8(%esp),%eax
  80032c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800330:	89 c3                	mov    %eax,%ebx
  800332:	89 d6                	mov    %edx,%esi
  800334:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800337:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80033a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80033e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 2c 1c 00 00       	call   801f80 <__udivdi3>
  800354:	89 d9                	mov    %ebx,%ecx
  800356:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80035e:	89 04 24             	mov    %eax,(%esp)
  800361:	89 54 24 04          	mov    %edx,0x4(%esp)
  800365:	89 fa                	mov    %edi,%edx
  800367:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036a:	e8 71 ff ff ff       	call   8002e0 <printnum>
  80036f:	eb 1b                	jmp    80038c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800371:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800375:	8b 45 18             	mov    0x18(%ebp),%eax
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	ff d3                	call   *%ebx
  80037d:	eb 03                	jmp    800382 <printnum+0xa2>
  80037f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800382:	83 ee 01             	sub    $0x1,%esi
  800385:	85 f6                	test   %esi,%esi
  800387:	7f e8                	jg     800371 <printnum+0x91>
  800389:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800390:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800394:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800397:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003af:	e8 fc 1c 00 00       	call   8020b0 <__umoddi3>
  8003b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b8:	0f be 80 a7 22 80 00 	movsbl 0x8022a7(%eax),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003c5:	ff d0                	call   *%eax
}
  8003c7:	83 c4 3c             	add    $0x3c,%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d2:	83 fa 01             	cmp    $0x1,%edx
  8003d5:	7e 0e                	jle    8003e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d7:	8b 10                	mov    (%eax),%edx
  8003d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003dc:	89 08                	mov    %ecx,(%eax)
  8003de:	8b 02                	mov    (%edx),%eax
  8003e0:	8b 52 04             	mov    0x4(%edx),%edx
  8003e3:	eb 22                	jmp    800407 <getuint+0x38>
	else if (lflag)
  8003e5:	85 d2                	test   %edx,%edx
  8003e7:	74 10                	je     8003f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 02                	mov    (%edx),%eax
  8003f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f7:	eb 0e                	jmp    800407 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 02                	mov    (%edx),%eax
  800402:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800413:	8b 10                	mov    (%eax),%edx
  800415:	3b 50 04             	cmp    0x4(%eax),%edx
  800418:	73 0a                	jae    800424 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041d:	89 08                	mov    %ecx,(%eax)
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	88 02                	mov    %al,(%edx)
}
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <printfmt>:
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80042c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800433:	8b 45 10             	mov    0x10(%ebp),%eax
  800436:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	e8 02 00 00 00       	call   80044e <vprintfmt>
}
  80044c:	c9                   	leave  
  80044d:	c3                   	ret    

0080044e <vprintfmt>:
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	57                   	push   %edi
  800452:	56                   	push   %esi
  800453:	53                   	push   %ebx
  800454:	83 ec 3c             	sub    $0x3c,%esp
  800457:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80045a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80045d:	eb 1f                	jmp    80047e <vprintfmt+0x30>
			if (ch == '\0'){
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 0f                	jne    800472 <vprintfmt+0x24>
				color = 0x0100;
  800463:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80046a:	01 00 00 
  80046d:	e9 b3 03 00 00       	jmp    800825 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800472:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800476:	89 04 24             	mov    %eax,(%esp)
  800479:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047c:	89 f3                	mov    %esi,%ebx
  80047e:	8d 73 01             	lea    0x1(%ebx),%esi
  800481:	0f b6 03             	movzbl (%ebx),%eax
  800484:	83 f8 25             	cmp    $0x25,%eax
  800487:	75 d6                	jne    80045f <vprintfmt+0x11>
  800489:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80048d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800494:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80049b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	eb 1d                	jmp    8004c6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	89 de                	mov    %ebx,%esi
			padc = '-';
  8004ab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004af:	eb 15                	jmp    8004c6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	89 de                	mov    %ebx,%esi
			padc = '0';
  8004b3:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004b7:	eb 0d                	jmp    8004c6 <vprintfmt+0x78>
				width = precision, precision = -1;
  8004b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004bf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004c9:	0f b6 0e             	movzbl (%esi),%ecx
  8004cc:	0f b6 c1             	movzbl %cl,%eax
  8004cf:	83 e9 23             	sub    $0x23,%ecx
  8004d2:	80 f9 55             	cmp    $0x55,%cl
  8004d5:	0f 87 2a 03 00 00    	ja     800805 <vprintfmt+0x3b7>
  8004db:	0f b6 c9             	movzbl %cl,%ecx
  8004de:	ff 24 8d e0 23 80 00 	jmp    *0x8023e0(,%ecx,4)
  8004e5:	89 de                	mov    %ebx,%esi
  8004e7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8004ec:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004ef:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004f3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004f6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004f9:	83 fb 09             	cmp    $0x9,%ebx
  8004fc:	77 36                	ja     800534 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8004fe:	83 c6 01             	add    $0x1,%esi
			}
  800501:	eb e9                	jmp    8004ec <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 48 04             	lea    0x4(%eax),%ecx
  800509:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80050c:	8b 00                	mov    (%eax),%eax
  80050e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800511:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800513:	eb 22                	jmp    800537 <vprintfmt+0xe9>
  800515:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800518:	85 c9                	test   %ecx,%ecx
  80051a:	b8 00 00 00 00       	mov    $0x0,%eax
  80051f:	0f 49 c1             	cmovns %ecx,%eax
  800522:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800525:	89 de                	mov    %ebx,%esi
  800527:	eb 9d                	jmp    8004c6 <vprintfmt+0x78>
  800529:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80052b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800532:	eb 92                	jmp    8004c6 <vprintfmt+0x78>
  800534:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800537:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053b:	79 89                	jns    8004c6 <vprintfmt+0x78>
  80053d:	e9 77 ff ff ff       	jmp    8004b9 <vprintfmt+0x6b>
			lflag++;
  800542:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800545:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800547:	e9 7a ff ff ff       	jmp    8004c6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800561:	e9 18 ff ff ff       	jmp    80047e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	99                   	cltd   
  800572:	31 d0                	xor    %edx,%eax
  800574:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800576:	83 f8 0f             	cmp    $0xf,%eax
  800579:	7f 0b                	jg     800586 <vprintfmt+0x138>
  80057b:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800582:	85 d2                	test   %edx,%edx
  800584:	75 20                	jne    8005a6 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800586:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058a:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800591:	00 
  800592:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800596:	8b 45 08             	mov    0x8(%ebp),%eax
  800599:	89 04 24             	mov    %eax,(%esp)
  80059c:	e8 85 fe ff ff       	call   800426 <printfmt>
  8005a1:	e9 d8 fe ff ff       	jmp    80047e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  8005a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005aa:	c7 44 24 08 9e 26 80 	movl   $0x80269e,0x8(%esp)
  8005b1:	00 
  8005b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 65 fe ff ff       	call   800426 <printfmt>
  8005c1:	e9 b8 fe ff ff       	jmp    80047e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005da:	85 f6                	test   %esi,%esi
  8005dc:	b8 b8 22 80 00       	mov    $0x8022b8,%eax
  8005e1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005e4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005e8:	0f 84 97 00 00 00    	je     800685 <vprintfmt+0x237>
  8005ee:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005f2:	0f 8e 9b 00 00 00    	jle    800693 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005fc:	89 34 24             	mov    %esi,(%esp)
  8005ff:	e8 c4 02 00 00       	call   8008c8 <strnlen>
  800604:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800607:	29 c2                	sub    %eax,%edx
  800609:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80060c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800610:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800613:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800616:	8b 75 08             	mov    0x8(%ebp),%esi
  800619:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80061c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	eb 0f                	jmp    80062f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80062c:	83 eb 01             	sub    $0x1,%ebx
  80062f:	85 db                	test   %ebx,%ebx
  800631:	7f ed                	jg     800620 <vprintfmt+0x1d2>
  800633:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800636:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800639:	85 d2                	test   %edx,%edx
  80063b:	b8 00 00 00 00       	mov    $0x0,%eax
  800640:	0f 49 c2             	cmovns %edx,%eax
  800643:	29 c2                	sub    %eax,%edx
  800645:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800648:	89 d7                	mov    %edx,%edi
  80064a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80064d:	eb 50                	jmp    80069f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80064f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800653:	74 1e                	je     800673 <vprintfmt+0x225>
  800655:	0f be d2             	movsbl %dl,%edx
  800658:	83 ea 20             	sub    $0x20,%edx
  80065b:	83 fa 5e             	cmp    $0x5e,%edx
  80065e:	76 13                	jbe    800673 <vprintfmt+0x225>
					putch('?', putdat);
  800660:	8b 45 0c             	mov    0xc(%ebp),%eax
  800663:	89 44 24 04          	mov    %eax,0x4(%esp)
  800667:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	eb 0d                	jmp    800680 <vprintfmt+0x232>
					putch(ch, putdat);
  800673:	8b 55 0c             	mov    0xc(%ebp),%edx
  800676:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800680:	83 ef 01             	sub    $0x1,%edi
  800683:	eb 1a                	jmp    80069f <vprintfmt+0x251>
  800685:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800688:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80068b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80068e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800691:	eb 0c                	jmp    80069f <vprintfmt+0x251>
  800693:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800696:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800699:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80069c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80069f:	83 c6 01             	add    $0x1,%esi
  8006a2:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006a6:	0f be c2             	movsbl %dl,%eax
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	74 27                	je     8006d4 <vprintfmt+0x286>
  8006ad:	85 db                	test   %ebx,%ebx
  8006af:	78 9e                	js     80064f <vprintfmt+0x201>
  8006b1:	83 eb 01             	sub    $0x1,%ebx
  8006b4:	79 99                	jns    80064f <vprintfmt+0x201>
  8006b6:	89 f8                	mov    %edi,%eax
  8006b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006be:	89 c3                	mov    %eax,%ebx
  8006c0:	eb 1a                	jmp    8006dc <vprintfmt+0x28e>
				putch(' ', putdat);
  8006c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006cd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006cf:	83 eb 01             	sub    $0x1,%ebx
  8006d2:	eb 08                	jmp    8006dc <vprintfmt+0x28e>
  8006d4:	89 fb                	mov    %edi,%ebx
  8006d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006dc:	85 db                	test   %ebx,%ebx
  8006de:	7f e2                	jg     8006c2 <vprintfmt+0x274>
  8006e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006e6:	e9 93 fd ff ff       	jmp    80047e <vprintfmt+0x30>
	if (lflag >= 2)
  8006eb:	83 fa 01             	cmp    $0x1,%edx
  8006ee:	7e 16                	jle    800706 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 08             	lea    0x8(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f9:	8b 50 04             	mov    0x4(%eax),%edx
  8006fc:	8b 00                	mov    (%eax),%eax
  8006fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800701:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800704:	eb 32                	jmp    800738 <vprintfmt+0x2ea>
	else if (lflag)
  800706:	85 d2                	test   %edx,%edx
  800708:	74 18                	je     800722 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 30                	mov    (%eax),%esi
  800715:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800718:	89 f0                	mov    %esi,%eax
  80071a:	c1 f8 1f             	sar    $0x1f,%eax
  80071d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800720:	eb 16                	jmp    800738 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 50 04             	lea    0x4(%eax),%edx
  800728:	89 55 14             	mov    %edx,0x14(%ebp)
  80072b:	8b 30                	mov    (%eax),%esi
  80072d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800730:	89 f0                	mov    %esi,%eax
  800732:	c1 f8 1f             	sar    $0x1f,%eax
  800735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800738:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80073b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80073e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800743:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800747:	0f 89 80 00 00 00    	jns    8007cd <vprintfmt+0x37f>
				putch('-', putdat);
  80074d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800751:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800758:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80075b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80075e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800761:	f7 d8                	neg    %eax
  800763:	83 d2 00             	adc    $0x0,%edx
  800766:	f7 da                	neg    %edx
			base = 10;
  800768:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80076d:	eb 5e                	jmp    8007cd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
  800772:	e8 58 fc ff ff       	call   8003cf <getuint>
			base = 10;
  800777:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80077c:	eb 4f                	jmp    8007cd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
  800781:	e8 49 fc ff ff       	call   8003cf <getuint>
            base = 8;
  800786:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80078b:	eb 40                	jmp    8007cd <vprintfmt+0x37f>
			putch('0', putdat);
  80078d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800791:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800798:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80079b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a6:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8d 50 04             	lea    0x4(%eax),%edx
  8007af:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8007b9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007be:	eb 0d                	jmp    8007cd <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c3:	e8 07 fc ff ff       	call   8003cf <getuint>
			base = 16;
  8007c8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8007cd:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007d1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007d5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007dc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e7:	89 fa                	mov    %edi,%edx
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	e8 ef fa ff ff       	call   8002e0 <printnum>
			break;
  8007f1:	e9 88 fc ff ff       	jmp    80047e <vprintfmt+0x30>
			putch(ch, putdat);
  8007f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007fa:	89 04 24             	mov    %eax,(%esp)
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			break;
  800800:	e9 79 fc ff ff       	jmp    80047e <vprintfmt+0x30>
			putch('%', putdat);
  800805:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800809:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800810:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800813:	89 f3                	mov    %esi,%ebx
  800815:	eb 03                	jmp    80081a <vprintfmt+0x3cc>
  800817:	83 eb 01             	sub    $0x1,%ebx
  80081a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80081e:	75 f7                	jne    800817 <vprintfmt+0x3c9>
  800820:	e9 59 fc ff ff       	jmp    80047e <vprintfmt+0x30>
}
  800825:	83 c4 3c             	add    $0x3c,%esp
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5f                   	pop    %edi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	83 ec 28             	sub    $0x28,%esp
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800839:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80083c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800840:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800843:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084a:	85 c0                	test   %eax,%eax
  80084c:	74 30                	je     80087e <vsnprintf+0x51>
  80084e:	85 d2                	test   %edx,%edx
  800850:	7e 2c                	jle    80087e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800859:	8b 45 10             	mov    0x10(%ebp),%eax
  80085c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800860:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800863:	89 44 24 04          	mov    %eax,0x4(%esp)
  800867:	c7 04 24 09 04 80 00 	movl   $0x800409,(%esp)
  80086e:	e8 db fb ff ff       	call   80044e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800873:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800876:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800879:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087c:	eb 05                	jmp    800883 <vsnprintf+0x56>
		return -E_INVAL;
  80087e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80088e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800892:	8b 45 10             	mov    0x10(%ebp),%eax
  800895:	89 44 24 08          	mov    %eax,0x8(%esp)
  800899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	89 04 24             	mov    %eax,(%esp)
  8008a6:	e8 82 ff ff ff       	call   80082d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    
  8008ad:	66 90                	xchg   %ax,%ax
  8008af:	90                   	nop

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	eb 03                	jmp    8008c0 <strlen+0x10>
		n++;
  8008bd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c4:	75 f7                	jne    8008bd <strlen+0xd>
	return n;
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb 03                	jmp    8008db <strnlen+0x13>
		n++;
  8008d8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	39 d0                	cmp    %edx,%eax
  8008dd:	74 06                	je     8008e5 <strnlen+0x1d>
  8008df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e3:	75 f3                	jne    8008d8 <strnlen+0x10>
	return n;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f1:	89 c2                	mov    %eax,%edx
  8008f3:	83 c2 01             	add    $0x1,%edx
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800900:	84 db                	test   %bl,%bl
  800902:	75 ef                	jne    8008f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800904:	5b                   	pop    %ebx
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800911:	89 1c 24             	mov    %ebx,(%esp)
  800914:	e8 97 ff ff ff       	call   8008b0 <strlen>
	strcpy(dst + len, src);
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800920:	01 d8                	add    %ebx,%eax
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	e8 bd ff ff ff       	call   8008e7 <strcpy>
	return dst;
}
  80092a:	89 d8                	mov    %ebx,%eax
  80092c:	83 c4 08             	add    $0x8,%esp
  80092f:	5b                   	pop    %ebx
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 75 08             	mov    0x8(%ebp),%esi
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	89 f3                	mov    %esi,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	89 f2                	mov    %esi,%edx
  800944:	eb 0f                	jmp    800955 <strncpy+0x23>
		*dst++ = *src;
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094f:	80 39 01             	cmpb   $0x1,(%ecx)
  800952:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800955:	39 da                	cmp    %ebx,%edx
  800957:	75 ed                	jne    800946 <strncpy+0x14>
	}
	return ret;
}
  800959:	89 f0                	mov    %esi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096d:	89 f0                	mov    %esi,%eax
  80096f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800973:	85 c9                	test   %ecx,%ecx
  800975:	75 0b                	jne    800982 <strlcpy+0x23>
  800977:	eb 1d                	jmp    800996 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800982:	39 d8                	cmp    %ebx,%eax
  800984:	74 0b                	je     800991 <strlcpy+0x32>
  800986:	0f b6 0a             	movzbl (%edx),%ecx
  800989:	84 c9                	test   %cl,%cl
  80098b:	75 ec                	jne    800979 <strlcpy+0x1a>
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	eb 02                	jmp    800993 <strlcpy+0x34>
  800991:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800993:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800996:	29 f0                	sub    %esi,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a5:	eb 06                	jmp    8009ad <strcmp+0x11>
		p++, q++;
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009ad:	0f b6 01             	movzbl (%ecx),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 04                	je     8009b8 <strcmp+0x1c>
  8009b4:	3a 02                	cmp    (%edx),%al
  8009b6:	74 ef                	je     8009a7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 c0             	movzbl %al,%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 c3                	mov    %eax,%ebx
  8009ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d1:	eb 06                	jmp    8009d9 <strncmp+0x17>
		n--, p++, q++;
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d9:	39 d8                	cmp    %ebx,%eax
  8009db:	74 15                	je     8009f2 <strncmp+0x30>
  8009dd:	0f b6 08             	movzbl (%eax),%ecx
  8009e0:	84 c9                	test   %cl,%cl
  8009e2:	74 04                	je     8009e8 <strncmp+0x26>
  8009e4:	3a 0a                	cmp    (%edx),%cl
  8009e6:	74 eb                	je     8009d3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 00             	movzbl (%eax),%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
  8009f0:	eb 05                	jmp    8009f7 <strncmp+0x35>
		return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	eb 07                	jmp    800a0d <strchr+0x13>
		if (*s == c)
  800a06:	38 ca                	cmp    %cl,%dl
  800a08:	74 0f                	je     800a19 <strchr+0x1f>
	for (; *s; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 f2                	jne    800a06 <strchr+0xc>
			return (char *) s;
	return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	eb 07                	jmp    800a2e <strfind+0x13>
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 0a                	je     800a35 <strfind+0x1a>
	for (; *s; s++)
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
  800a31:	84 d2                	test   %dl,%dl
  800a33:	75 f2                	jne    800a27 <strfind+0xc>
			break;
	return (char *) s;
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	74 36                	je     800a7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4d:	75 28                	jne    800a77 <memset+0x40>
  800a4f:	f6 c1 03             	test   $0x3,%cl
  800a52:	75 23                	jne    800a77 <memset+0x40>
		c &= 0xFF;
  800a54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a58:	89 d3                	mov    %edx,%ebx
  800a5a:	c1 e3 08             	shl    $0x8,%ebx
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	c1 e6 18             	shl    $0x18,%esi
  800a62:	89 d0                	mov    %edx,%eax
  800a64:	c1 e0 10             	shl    $0x10,%eax
  800a67:	09 f0                	or     %esi,%eax
  800a69:	09 c2                	or     %eax,%edx
  800a6b:	89 d0                	mov    %edx,%eax
  800a6d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a6f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a72:	fc                   	cld    
  800a73:	f3 ab                	rep stos %eax,%es:(%edi)
  800a75:	eb 06                	jmp    800a7d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7a:	fc                   	cld    
  800a7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7d:	89 f8                	mov    %edi,%eax
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a92:	39 c6                	cmp    %eax,%esi
  800a94:	73 35                	jae    800acb <memmove+0x47>
  800a96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a99:	39 d0                	cmp    %edx,%eax
  800a9b:	73 2e                	jae    800acb <memmove+0x47>
		s += n;
		d += n;
  800a9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aaa:	75 13                	jne    800abf <memmove+0x3b>
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	75 0e                	jne    800abf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab1:	83 ef 04             	sub    $0x4,%edi
  800ab4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aba:	fd                   	std    
  800abb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abd:	eb 09                	jmp    800ac8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800abf:	83 ef 01             	sub    $0x1,%edi
  800ac2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ac5:	fd                   	std    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac8:	fc                   	cld    
  800ac9:	eb 1d                	jmp    800ae8 <memmove+0x64>
  800acb:	89 f2                	mov    %esi,%edx
  800acd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	f6 c2 03             	test   $0x3,%dl
  800ad2:	75 0f                	jne    800ae3 <memmove+0x5f>
  800ad4:	f6 c1 03             	test   $0x3,%cl
  800ad7:	75 0a                	jne    800ae3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800adc:	89 c7                	mov    %eax,%edi
  800ade:	fc                   	cld    
  800adf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae1:	eb 05                	jmp    800ae8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ae3:	89 c7                	mov    %eax,%edi
  800ae5:	fc                   	cld    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af2:	8b 45 10             	mov    0x10(%ebp),%eax
  800af5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	89 04 24             	mov    %eax,(%esp)
  800b06:	e8 79 ff ff ff       	call   800a84 <memmove>
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1d:	eb 1a                	jmp    800b39 <memcmp+0x2c>
		if (*s1 != *s2)
  800b1f:	0f b6 02             	movzbl (%edx),%eax
  800b22:	0f b6 19             	movzbl (%ecx),%ebx
  800b25:	38 d8                	cmp    %bl,%al
  800b27:	74 0a                	je     800b33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b29:	0f b6 c0             	movzbl %al,%eax
  800b2c:	0f b6 db             	movzbl %bl,%ebx
  800b2f:	29 d8                	sub    %ebx,%eax
  800b31:	eb 0f                	jmp    800b42 <memcmp+0x35>
		s1++, s2++;
  800b33:	83 c2 01             	add    $0x1,%edx
  800b36:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800b39:	39 f2                	cmp    %esi,%edx
  800b3b:	75 e2                	jne    800b1f <memcmp+0x12>
	}

	return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b4f:	89 c2                	mov    %eax,%edx
  800b51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b54:	eb 07                	jmp    800b5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b56:	38 08                	cmp    %cl,(%eax)
  800b58:	74 07                	je     800b61 <memfind+0x1b>
	for (; s < ends; s++)
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	39 d0                	cmp    %edx,%eax
  800b5f:	72 f5                	jb     800b56 <memfind+0x10>
			break;
	return (void *) s;
}
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6f:	eb 03                	jmp    800b74 <strtol+0x11>
		s++;
  800b71:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b74:	0f b6 0a             	movzbl (%edx),%ecx
  800b77:	80 f9 09             	cmp    $0x9,%cl
  800b7a:	74 f5                	je     800b71 <strtol+0xe>
  800b7c:	80 f9 20             	cmp    $0x20,%cl
  800b7f:	74 f0                	je     800b71 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b81:	80 f9 2b             	cmp    $0x2b,%cl
  800b84:	75 0a                	jne    800b90 <strtol+0x2d>
		s++;
  800b86:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8e:	eb 11                	jmp    800ba1 <strtol+0x3e>
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b95:	80 f9 2d             	cmp    $0x2d,%cl
  800b98:	75 07                	jne    800ba1 <strtol+0x3e>
		s++, neg = 1;
  800b9a:	8d 52 01             	lea    0x1(%edx),%edx
  800b9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ba6:	75 15                	jne    800bbd <strtol+0x5a>
  800ba8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bab:	75 10                	jne    800bbd <strtol+0x5a>
  800bad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb1:	75 0a                	jne    800bbd <strtol+0x5a>
		s += 2, base = 16;
  800bb3:	83 c2 02             	add    $0x2,%edx
  800bb6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bbb:	eb 10                	jmp    800bcd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	75 0c                	jne    800bcd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800bc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc6:	75 05                	jne    800bcd <strtol+0x6a>
		s++, base = 8;
  800bc8:	83 c2 01             	add    $0x1,%edx
  800bcb:	b0 08                	mov    $0x8,%al
		base = 10;
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 0a             	movzbl (%edx),%ecx
  800bd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bdb:	89 f0                	mov    %esi,%eax
  800bdd:	3c 09                	cmp    $0x9,%al
  800bdf:	77 08                	ja     800be9 <strtol+0x86>
			dig = *s - '0';
  800be1:	0f be c9             	movsbl %cl,%ecx
  800be4:	83 e9 30             	sub    $0x30,%ecx
  800be7:	eb 20                	jmp    800c09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800be9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bec:	89 f0                	mov    %esi,%eax
  800bee:	3c 19                	cmp    $0x19,%al
  800bf0:	77 08                	ja     800bfa <strtol+0x97>
			dig = *s - 'a' + 10;
  800bf2:	0f be c9             	movsbl %cl,%ecx
  800bf5:	83 e9 57             	sub    $0x57,%ecx
  800bf8:	eb 0f                	jmp    800c09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bfa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bfd:	89 f0                	mov    %esi,%eax
  800bff:	3c 19                	cmp    $0x19,%al
  800c01:	77 16                	ja     800c19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c03:	0f be c9             	movsbl %cl,%ecx
  800c06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c0c:	7d 0f                	jge    800c1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c0e:	83 c2 01             	add    $0x1,%edx
  800c11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c17:	eb bc                	jmp    800bd5 <strtol+0x72>
  800c19:	89 d8                	mov    %ebx,%eax
  800c1b:	eb 02                	jmp    800c1f <strtol+0xbc>
  800c1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c23:	74 05                	je     800c2a <strtol+0xc7>
		*endptr = (char *) s;
  800c25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c2a:	f7 d8                	neg    %eax
  800c2c:	85 ff                	test   %edi,%edi
  800c2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 c3                	mov    %eax,%ebx
  800c49:	89 c7                	mov    %eax,%edi
  800c4b:	89 c6                	mov    %eax,%esi
  800c4d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	89 d3                	mov    %edx,%ebx
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c81:	b8 03 00 00 00       	mov    $0x3,%eax
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 cb                	mov    %ecx,%ebx
  800c8b:	89 cf                	mov    %ecx,%edi
  800c8d:	89 ce                	mov    %ecx,%esi
  800c8f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 28                	jle    800cbd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb0:	00 
  800cb1:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800cb8:	e8 09 f5 ff ff       	call   8001c6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbd:	83 c4 2c             	add    $0x2c,%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_yield>:

void
sys_yield(void)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cea:	ba 00 00 00 00       	mov    $0x0,%edx
  800cef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf4:	89 d1                	mov    %edx,%ecx
  800cf6:	89 d3                	mov    %edx,%ebx
  800cf8:	89 d7                	mov    %edx,%edi
  800cfa:	89 d6                	mov    %edx,%esi
  800cfc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 04 00 00 00       	mov    $0x4,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	89 f7                	mov    %esi,%edi
  800d21:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 28                	jle    800d4f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d32:	00 
  800d33:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800d4a:	e8 77 f4 ff ff       	call   8001c6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d4f:	83 c4 2c             	add    $0x2c,%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d60:	b8 05 00 00 00       	mov    $0x5,%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d71:	8b 75 18             	mov    0x18(%ebp),%esi
  800d74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7e 28                	jle    800da2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d85:	00 
  800d86:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d95:	00 
  800d96:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800d9d:	e8 24 f4 ff ff       	call   8001c6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da2:	83 c4 2c             	add    $0x2c,%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800df0:	e8 d1 f3 ff ff       	call   8001c6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800df5:	83 c4 2c             	add    $0x2c,%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 28                	jle    800e48 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800e33:	00 
  800e34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3b:	00 
  800e3c:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800e43:	e8 7e f3 ff ff       	call   8001c6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e48:	83 c4 2c             	add    $0x2c,%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 de                	mov    %ebx,%esi
  800e6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 28                	jle    800e9b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8e:	00 
  800e8f:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800e96:	e8 2b f3 ff ff       	call   8001c6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e9b:	83 c4 2c             	add    $0x2c,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 df                	mov    %ebx,%edi
  800ebe:	89 de                	mov    %ebx,%esi
  800ec0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 28                	jle    800eee <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800ee9:	e8 d8 f2 ff ff       	call   8001c6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eee:	83 c4 2c             	add    $0x2c,%esp
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800efc:	be 00 00 00 00       	mov    $0x0,%esi
  800f01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f12:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f27:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2f:	89 cb                	mov    %ecx,%ebx
  800f31:	89 cf                	mov    %ecx,%edi
  800f33:	89 ce                	mov    %ecx,%esi
  800f35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f37:	85 c0                	test   %eax,%eax
  800f39:	7e 28                	jle    800f63 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f46:	00 
  800f47:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f56:	00 
  800f57:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800f5e:	e8 63 f2 ff ff       	call   8001c6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f63:	83 c4 2c             	add    $0x2c,%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    
  800f6b:	66 90                	xchg   %ax,%ax
  800f6d:	66 90                	xchg   %ax,%ax
  800f6f:	90                   	nop

00800f70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	05 00 00 00 30       	add    $0x30000000,%eax
  800f7b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f90:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fa2:	89 c2                	mov    %eax,%edx
  800fa4:	c1 ea 16             	shr    $0x16,%edx
  800fa7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fae:	f6 c2 01             	test   $0x1,%dl
  800fb1:	74 11                	je     800fc4 <fd_alloc+0x2d>
  800fb3:	89 c2                	mov    %eax,%edx
  800fb5:	c1 ea 0c             	shr    $0xc,%edx
  800fb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbf:	f6 c2 01             	test   $0x1,%dl
  800fc2:	75 09                	jne    800fcd <fd_alloc+0x36>
			*fd_store = fd;
  800fc4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	eb 17                	jmp    800fe4 <fd_alloc+0x4d>
  800fcd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800fd2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fd7:	75 c9                	jne    800fa2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800fd9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fdf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fec:	83 f8 1f             	cmp    $0x1f,%eax
  800fef:	77 36                	ja     801027 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ff1:	c1 e0 0c             	shl    $0xc,%eax
  800ff4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ff9:	89 c2                	mov    %eax,%edx
  800ffb:	c1 ea 16             	shr    $0x16,%edx
  800ffe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801005:	f6 c2 01             	test   $0x1,%dl
  801008:	74 24                	je     80102e <fd_lookup+0x48>
  80100a:	89 c2                	mov    %eax,%edx
  80100c:	c1 ea 0c             	shr    $0xc,%edx
  80100f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801016:	f6 c2 01             	test   $0x1,%dl
  801019:	74 1a                	je     801035 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80101b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101e:	89 02                	mov    %eax,(%edx)
	return 0;
  801020:	b8 00 00 00 00       	mov    $0x0,%eax
  801025:	eb 13                	jmp    80103a <fd_lookup+0x54>
		return -E_INVAL;
  801027:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80102c:	eb 0c                	jmp    80103a <fd_lookup+0x54>
		return -E_INVAL;
  80102e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801033:	eb 05                	jmp    80103a <fd_lookup+0x54>
  801035:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 18             	sub    $0x18,%esp
  801042:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801045:	ba 4c 26 80 00       	mov    $0x80264c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80104a:	eb 13                	jmp    80105f <dev_lookup+0x23>
  80104c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80104f:	39 08                	cmp    %ecx,(%eax)
  801051:	75 0c                	jne    80105f <dev_lookup+0x23>
			*dev = devtab[i];
  801053:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801056:	89 01                	mov    %eax,(%ecx)
			return 0;
  801058:	b8 00 00 00 00       	mov    $0x0,%eax
  80105d:	eb 30                	jmp    80108f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80105f:	8b 02                	mov    (%edx),%eax
  801061:	85 c0                	test   %eax,%eax
  801063:	75 e7                	jne    80104c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801065:	a1 20 60 80 00       	mov    0x806020,%eax
  80106a:	8b 40 48             	mov    0x48(%eax),%eax
  80106d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801071:	89 44 24 04          	mov    %eax,0x4(%esp)
  801075:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  80107c:	e8 3e f2 ff ff       	call   8002bf <cprintf>
	*dev = 0;
  801081:	8b 45 0c             	mov    0xc(%ebp),%eax
  801084:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80108a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <fd_close>:
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 20             	sub    $0x20,%esp
  801099:	8b 75 08             	mov    0x8(%ebp),%esi
  80109c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80109f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010ac:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 2f ff ff ff       	call   800fe6 <fd_lookup>
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 05                	js     8010c0 <fd_close+0x2f>
	    || fd != fd2)
  8010bb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010be:	74 0c                	je     8010cc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8010c0:	84 db                	test   %bl,%bl
  8010c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c7:	0f 44 c2             	cmove  %edx,%eax
  8010ca:	eb 3f                	jmp    80110b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d3:	8b 06                	mov    (%esi),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	e8 5f ff ff ff       	call   80103c <dev_lookup>
  8010dd:	89 c3                	mov    %eax,%ebx
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 16                	js     8010f9 <fd_close+0x68>
		if (dev->dev_close)
  8010e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	74 07                	je     8010f9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8010f2:	89 34 24             	mov    %esi,(%esp)
  8010f5:	ff d0                	call   *%eax
  8010f7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8010f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801104:	e8 a1 fc ff ff       	call   800daa <sys_page_unmap>
	return r;
  801109:	89 d8                	mov    %ebx,%eax
}
  80110b:	83 c4 20             	add    $0x20,%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <close>:

int
close(int fdnum)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801118:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	89 04 24             	mov    %eax,(%esp)
  801125:	e8 bc fe ff ff       	call   800fe6 <fd_lookup>
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	85 d2                	test   %edx,%edx
  80112e:	78 13                	js     801143 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801130:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801137:	00 
  801138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113b:	89 04 24             	mov    %eax,(%esp)
  80113e:	e8 4e ff ff ff       	call   801091 <fd_close>
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <close_all>:

void
close_all(void)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	53                   	push   %ebx
  801149:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801151:	89 1c 24             	mov    %ebx,(%esp)
  801154:	e8 b9 ff ff ff       	call   801112 <close>
	for (i = 0; i < MAXFD; i++)
  801159:	83 c3 01             	add    $0x1,%ebx
  80115c:	83 fb 20             	cmp    $0x20,%ebx
  80115f:	75 f0                	jne    801151 <close_all+0xc>
}
  801161:	83 c4 14             	add    $0x14,%esp
  801164:	5b                   	pop    %ebx
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801170:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801173:	89 44 24 04          	mov    %eax,0x4(%esp)
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
  80117a:	89 04 24             	mov    %eax,(%esp)
  80117d:	e8 64 fe ff ff       	call   800fe6 <fd_lookup>
  801182:	89 c2                	mov    %eax,%edx
  801184:	85 d2                	test   %edx,%edx
  801186:	0f 88 e1 00 00 00    	js     80126d <dup+0x106>
		return r;
	close(newfdnum);
  80118c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118f:	89 04 24             	mov    %eax,(%esp)
  801192:	e8 7b ff ff ff       	call   801112 <close>

	newfd = INDEX2FD(newfdnum);
  801197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80119a:	c1 e3 0c             	shl    $0xc,%ebx
  80119d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a6:	89 04 24             	mov    %eax,(%esp)
  8011a9:	e8 d2 fd ff ff       	call   800f80 <fd2data>
  8011ae:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8011b0:	89 1c 24             	mov    %ebx,(%esp)
  8011b3:	e8 c8 fd ff ff       	call   800f80 <fd2data>
  8011b8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ba:	89 f0                	mov    %esi,%eax
  8011bc:	c1 e8 16             	shr    $0x16,%eax
  8011bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c6:	a8 01                	test   $0x1,%al
  8011c8:	74 43                	je     80120d <dup+0xa6>
  8011ca:	89 f0                	mov    %esi,%eax
  8011cc:	c1 e8 0c             	shr    $0xc,%eax
  8011cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011d6:	f6 c2 01             	test   $0x1,%dl
  8011d9:	74 32                	je     80120d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011f6:	00 
  8011f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801202:	e8 50 fb ff ff       	call   800d57 <sys_page_map>
  801207:	89 c6                	mov    %eax,%esi
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 3e                	js     80124b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80120d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801210:	89 c2                	mov    %eax,%edx
  801212:	c1 ea 0c             	shr    $0xc,%edx
  801215:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801222:	89 54 24 10          	mov    %edx,0x10(%esp)
  801226:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80122a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801231:	00 
  801232:	89 44 24 04          	mov    %eax,0x4(%esp)
  801236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123d:	e8 15 fb ff ff       	call   800d57 <sys_page_map>
  801242:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801244:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801247:	85 f6                	test   %esi,%esi
  801249:	79 22                	jns    80126d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80124b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80124f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801256:	e8 4f fb ff ff       	call   800daa <sys_page_unmap>
	sys_page_unmap(0, nva);
  80125b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80125f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801266:	e8 3f fb ff ff       	call   800daa <sys_page_unmap>
	return r;
  80126b:	89 f0                	mov    %esi,%eax
}
  80126d:	83 c4 3c             	add    $0x3c,%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 24             	sub    $0x24,%esp
  80127c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	89 44 24 04          	mov    %eax,0x4(%esp)
  801286:	89 1c 24             	mov    %ebx,(%esp)
  801289:	e8 58 fd ff ff       	call   800fe6 <fd_lookup>
  80128e:	89 c2                	mov    %eax,%edx
  801290:	85 d2                	test   %edx,%edx
  801292:	78 6d                	js     801301 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	8b 00                	mov    (%eax),%eax
  8012a0:	89 04 24             	mov    %eax,(%esp)
  8012a3:	e8 94 fd ff ff       	call   80103c <dev_lookup>
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 55                	js     801301 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012af:	8b 50 08             	mov    0x8(%eax),%edx
  8012b2:	83 e2 03             	and    $0x3,%edx
  8012b5:	83 fa 01             	cmp    $0x1,%edx
  8012b8:	75 23                	jne    8012dd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ba:	a1 20 60 80 00       	mov    0x806020,%eax
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ca:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  8012d1:	e8 e9 ef ff ff       	call   8002bf <cprintf>
		return -E_INVAL;
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012db:	eb 24                	jmp    801301 <read+0x8c>
	}
	if (!dev->dev_read)
  8012dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e0:	8b 52 08             	mov    0x8(%edx),%edx
  8012e3:	85 d2                	test   %edx,%edx
  8012e5:	74 15                	je     8012fc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012f5:	89 04 24             	mov    %eax,(%esp)
  8012f8:	ff d2                	call   *%edx
  8012fa:	eb 05                	jmp    801301 <read+0x8c>
		return -E_NOT_SUPP;
  8012fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801301:	83 c4 24             	add    $0x24,%esp
  801304:	5b                   	pop    %ebx
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	57                   	push   %edi
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	83 ec 1c             	sub    $0x1c,%esp
  801310:	8b 7d 08             	mov    0x8(%ebp),%edi
  801313:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801316:	bb 00 00 00 00       	mov    $0x0,%ebx
  80131b:	eb 23                	jmp    801340 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80131d:	89 f0                	mov    %esi,%eax
  80131f:	29 d8                	sub    %ebx,%eax
  801321:	89 44 24 08          	mov    %eax,0x8(%esp)
  801325:	89 d8                	mov    %ebx,%eax
  801327:	03 45 0c             	add    0xc(%ebp),%eax
  80132a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132e:	89 3c 24             	mov    %edi,(%esp)
  801331:	e8 3f ff ff ff       	call   801275 <read>
		if (m < 0)
  801336:	85 c0                	test   %eax,%eax
  801338:	78 10                	js     80134a <readn+0x43>
			return m;
		if (m == 0)
  80133a:	85 c0                	test   %eax,%eax
  80133c:	74 0a                	je     801348 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80133e:	01 c3                	add    %eax,%ebx
  801340:	39 f3                	cmp    %esi,%ebx
  801342:	72 d9                	jb     80131d <readn+0x16>
  801344:	89 d8                	mov    %ebx,%eax
  801346:	eb 02                	jmp    80134a <readn+0x43>
  801348:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80134a:	83 c4 1c             	add    $0x1c,%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5f                   	pop    %edi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	53                   	push   %ebx
  801356:	83 ec 24             	sub    $0x24,%esp
  801359:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801363:	89 1c 24             	mov    %ebx,(%esp)
  801366:	e8 7b fc ff ff       	call   800fe6 <fd_lookup>
  80136b:	89 c2                	mov    %eax,%edx
  80136d:	85 d2                	test   %edx,%edx
  80136f:	78 68                	js     8013d9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801371:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801374:	89 44 24 04          	mov    %eax,0x4(%esp)
  801378:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137b:	8b 00                	mov    (%eax),%eax
  80137d:	89 04 24             	mov    %eax,(%esp)
  801380:	e8 b7 fc ff ff       	call   80103c <dev_lookup>
  801385:	85 c0                	test   %eax,%eax
  801387:	78 50                	js     8013d9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801390:	75 23                	jne    8013b5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801392:	a1 20 60 80 00       	mov    0x806020,%eax
  801397:	8b 40 48             	mov    0x48(%eax),%eax
  80139a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80139e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a2:	c7 04 24 2c 26 80 00 	movl   $0x80262c,(%esp)
  8013a9:	e8 11 ef ff ff       	call   8002bf <cprintf>
		return -E_INVAL;
  8013ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b3:	eb 24                	jmp    8013d9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013bb:	85 d2                	test   %edx,%edx
  8013bd:	74 15                	je     8013d4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013c2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	ff d2                	call   *%edx
  8013d2:	eb 05                	jmp    8013d9 <write+0x87>
		return -E_NOT_SUPP;
  8013d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013d9:	83 c4 24             	add    $0x24,%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <seek>:

int
seek(int fdnum, off_t offset)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ef:	89 04 24             	mov    %eax,(%esp)
  8013f2:	e8 ef fb ff ff       	call   800fe6 <fd_lookup>
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 0e                	js     801409 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801401:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 24             	sub    $0x24,%esp
  801412:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801415:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141c:	89 1c 24             	mov    %ebx,(%esp)
  80141f:	e8 c2 fb ff ff       	call   800fe6 <fd_lookup>
  801424:	89 c2                	mov    %eax,%edx
  801426:	85 d2                	test   %edx,%edx
  801428:	78 61                	js     80148b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801434:	8b 00                	mov    (%eax),%eax
  801436:	89 04 24             	mov    %eax,(%esp)
  801439:	e8 fe fb ff ff       	call   80103c <dev_lookup>
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 49                	js     80148b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801445:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801449:	75 23                	jne    80146e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80144b:	a1 20 60 80 00       	mov    0x806020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801450:	8b 40 48             	mov    0x48(%eax),%eax
  801453:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145b:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  801462:	e8 58 ee ff ff       	call   8002bf <cprintf>
		return -E_INVAL;
  801467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146c:	eb 1d                	jmp    80148b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80146e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801471:	8b 52 18             	mov    0x18(%edx),%edx
  801474:	85 d2                	test   %edx,%edx
  801476:	74 0e                	je     801486 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801478:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80147f:	89 04 24             	mov    %eax,(%esp)
  801482:	ff d2                	call   *%edx
  801484:	eb 05                	jmp    80148b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801486:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80148b:	83 c4 24             	add    $0x24,%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	53                   	push   %ebx
  801495:	83 ec 24             	sub    $0x24,%esp
  801498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	89 04 24             	mov    %eax,(%esp)
  8014a8:	e8 39 fb ff ff       	call   800fe6 <fd_lookup>
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	85 d2                	test   %edx,%edx
  8014b1:	78 52                	js     801505 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bd:	8b 00                	mov    (%eax),%eax
  8014bf:	89 04 24             	mov    %eax,(%esp)
  8014c2:	e8 75 fb ff ff       	call   80103c <dev_lookup>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 3a                	js     801505 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8014cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ce:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014d2:	74 2c                	je     801500 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014d4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014d7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014de:	00 00 00 
	stat->st_isdir = 0;
  8014e1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014e8:	00 00 00 
	stat->st_dev = dev;
  8014eb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f8:	89 14 24             	mov    %edx,(%esp)
  8014fb:	ff 50 14             	call   *0x14(%eax)
  8014fe:	eb 05                	jmp    801505 <fstat+0x74>
		return -E_NOT_SUPP;
  801500:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801505:	83 c4 24             	add    $0x24,%esp
  801508:	5b                   	pop    %ebx
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801513:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80151a:	00 
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	89 04 24             	mov    %eax,(%esp)
  801521:	e8 fb 01 00 00       	call   801721 <open>
  801526:	89 c3                	mov    %eax,%ebx
  801528:	85 db                	test   %ebx,%ebx
  80152a:	78 1b                	js     801547 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80152c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801533:	89 1c 24             	mov    %ebx,(%esp)
  801536:	e8 56 ff ff ff       	call   801491 <fstat>
  80153b:	89 c6                	mov    %eax,%esi
	close(fd);
  80153d:	89 1c 24             	mov    %ebx,(%esp)
  801540:	e8 cd fb ff ff       	call   801112 <close>
	return r;
  801545:	89 f0                	mov    %esi,%eax
}
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5e                   	pop    %esi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 10             	sub    $0x10,%esp
  801556:	89 c6                	mov    %eax,%esi
  801558:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80155a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801561:	75 11                	jne    801574 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801563:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80156a:	e8 90 09 00 00       	call   801eff <ipc_find_env>
  80156f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801574:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80157b:	00 
  80157c:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801583:	00 
  801584:	89 74 24 04          	mov    %esi,0x4(%esp)
  801588:	a1 04 40 80 00       	mov    0x804004,%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 03 09 00 00       	call   801e98 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801595:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80159c:	00 
  80159d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a8:	e8 83 08 00 00       	call   801e30 <ipc_recv>
}
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	5b                   	pop    %ebx
  8015b1:	5e                   	pop    %esi
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c0:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8015c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c8:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8015d7:	e8 72 ff ff ff       	call   80154e <fsipc>
}
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <devfile_flush>:
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ea:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8015f9:	e8 50 ff ff ff       	call   80154e <fsipc>
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <devfile_stat>:
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 14             	sub    $0x14,%esp
  801607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	8b 40 0c             	mov    0xc(%eax),%eax
  801610:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801615:	ba 00 00 00 00       	mov    $0x0,%edx
  80161a:	b8 05 00 00 00       	mov    $0x5,%eax
  80161f:	e8 2a ff ff ff       	call   80154e <fsipc>
  801624:	89 c2                	mov    %eax,%edx
  801626:	85 d2                	test   %edx,%edx
  801628:	78 2b                	js     801655 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80162a:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801631:	00 
  801632:	89 1c 24             	mov    %ebx,(%esp)
  801635:	e8 ad f2 ff ff       	call   8008e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80163a:	a1 80 70 80 00       	mov    0x807080,%eax
  80163f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801645:	a1 84 70 80 00       	mov    0x807084,%eax
  80164a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801650:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801655:	83 c4 14             	add    $0x14,%esp
  801658:	5b                   	pop    %ebx
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    

0080165b <devfile_write>:
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801661:	c7 44 24 08 5c 26 80 	movl   $0x80265c,0x8(%esp)
  801668:	00 
  801669:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801670:	00 
  801671:	c7 04 24 7a 26 80 00 	movl   $0x80267a,(%esp)
  801678:	e8 49 eb ff ff       	call   8001c6 <_panic>

0080167d <devfile_read>:
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
  801682:	83 ec 10             	sub    $0x10,%esp
  801685:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801688:	8b 45 08             	mov    0x8(%ebp),%eax
  80168b:	8b 40 0c             	mov    0xc(%eax),%eax
  80168e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801693:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801699:	ba 00 00 00 00       	mov    $0x0,%edx
  80169e:	b8 03 00 00 00       	mov    $0x3,%eax
  8016a3:	e8 a6 fe ff ff       	call   80154e <fsipc>
  8016a8:	89 c3                	mov    %eax,%ebx
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 6a                	js     801718 <devfile_read+0x9b>
	assert(r <= n);
  8016ae:	39 c6                	cmp    %eax,%esi
  8016b0:	73 24                	jae    8016d6 <devfile_read+0x59>
  8016b2:	c7 44 24 0c 85 26 80 	movl   $0x802685,0xc(%esp)
  8016b9:	00 
  8016ba:	c7 44 24 08 8c 26 80 	movl   $0x80268c,0x8(%esp)
  8016c1:	00 
  8016c2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016c9:	00 
  8016ca:	c7 04 24 7a 26 80 00 	movl   $0x80267a,(%esp)
  8016d1:	e8 f0 ea ff ff       	call   8001c6 <_panic>
	assert(r <= PGSIZE);
  8016d6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016db:	7e 24                	jle    801701 <devfile_read+0x84>
  8016dd:	c7 44 24 0c a1 26 80 	movl   $0x8026a1,0xc(%esp)
  8016e4:	00 
  8016e5:	c7 44 24 08 8c 26 80 	movl   $0x80268c,0x8(%esp)
  8016ec:	00 
  8016ed:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016f4:	00 
  8016f5:	c7 04 24 7a 26 80 00 	movl   $0x80267a,(%esp)
  8016fc:	e8 c5 ea ff ff       	call   8001c6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801701:	89 44 24 08          	mov    %eax,0x8(%esp)
  801705:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80170c:	00 
  80170d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801710:	89 04 24             	mov    %eax,(%esp)
  801713:	e8 6c f3 ff ff       	call   800a84 <memmove>
}
  801718:	89 d8                	mov    %ebx,%eax
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5e                   	pop    %esi
  80171f:	5d                   	pop    %ebp
  801720:	c3                   	ret    

00801721 <open>:
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	53                   	push   %ebx
  801725:	83 ec 24             	sub    $0x24,%esp
  801728:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80172b:	89 1c 24             	mov    %ebx,(%esp)
  80172e:	e8 7d f1 ff ff       	call   8008b0 <strlen>
  801733:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801738:	7f 60                	jg     80179a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80173a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173d:	89 04 24             	mov    %eax,(%esp)
  801740:	e8 52 f8 ff ff       	call   800f97 <fd_alloc>
  801745:	89 c2                	mov    %eax,%edx
  801747:	85 d2                	test   %edx,%edx
  801749:	78 54                	js     80179f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80174b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174f:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801756:	e8 8c f1 ff ff       	call   8008e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80175b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175e:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801763:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801766:	b8 01 00 00 00       	mov    $0x1,%eax
  80176b:	e8 de fd ff ff       	call   80154e <fsipc>
  801770:	89 c3                	mov    %eax,%ebx
  801772:	85 c0                	test   %eax,%eax
  801774:	79 17                	jns    80178d <open+0x6c>
		fd_close(fd, 0);
  801776:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80177d:	00 
  80177e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801781:	89 04 24             	mov    %eax,(%esp)
  801784:	e8 08 f9 ff ff       	call   801091 <fd_close>
		return r;
  801789:	89 d8                	mov    %ebx,%eax
  80178b:	eb 12                	jmp    80179f <open+0x7e>
	return fd2num(fd);
  80178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801790:	89 04 24             	mov    %eax,(%esp)
  801793:	e8 d8 f7 ff ff       	call   800f70 <fd2num>
  801798:	eb 05                	jmp    80179f <open+0x7e>
		return -E_BAD_PATH;
  80179a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80179f:	83 c4 24             	add    $0x24,%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8017b5:	e8 94 fd ff ff       	call   80154e <fsipc>
}
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 14             	sub    $0x14,%esp
  8017c3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8017c5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017c9:	7e 31                	jle    8017fc <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017cb:	8b 40 04             	mov    0x4(%eax),%eax
  8017ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d2:	8d 43 10             	lea    0x10(%ebx),%eax
  8017d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d9:	8b 03                	mov    (%ebx),%eax
  8017db:	89 04 24             	mov    %eax,(%esp)
  8017de:	e8 6f fb ff ff       	call   801352 <write>
		if (result > 0)
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	7e 03                	jle    8017ea <writebuf+0x2e>
			b->result += result;
  8017e7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017ea:	39 43 04             	cmp    %eax,0x4(%ebx)
  8017ed:	74 0d                	je     8017fc <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	0f 4f c2             	cmovg  %edx,%eax
  8017f9:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8017fc:	83 c4 14             	add    $0x14,%esp
  8017ff:	5b                   	pop    %ebx
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <putch>:

static void
putch(int ch, void *thunk)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	53                   	push   %ebx
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80180c:	8b 53 04             	mov    0x4(%ebx),%edx
  80180f:	8d 42 01             	lea    0x1(%edx),%eax
  801812:	89 43 04             	mov    %eax,0x4(%ebx)
  801815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801818:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80181c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801821:	75 0e                	jne    801831 <putch+0x2f>
		writebuf(b);
  801823:	89 d8                	mov    %ebx,%eax
  801825:	e8 92 ff ff ff       	call   8017bc <writebuf>
		b->idx = 0;
  80182a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801831:	83 c4 04             	add    $0x4,%esp
  801834:	5b                   	pop    %ebx
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801849:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801850:	00 00 00 
	b.result = 0;
  801853:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80185a:	00 00 00 
	b.error = 1;
  80185d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801864:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801867:	8b 45 10             	mov    0x10(%ebp),%eax
  80186a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801871:	89 44 24 08          	mov    %eax,0x8(%esp)
  801875:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80187b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187f:	c7 04 24 02 18 80 00 	movl   $0x801802,(%esp)
  801886:	e8 c3 eb ff ff       	call   80044e <vprintfmt>
	if (b.idx > 0)
  80188b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801892:	7e 0b                	jle    80189f <vfprintf+0x68>
		writebuf(&b);
  801894:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80189a:	e8 1d ff ff ff       	call   8017bc <writebuf>

	return (b.result ? b.result : b.error);
  80189f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018b6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c7:	89 04 24             	mov    %eax,(%esp)
  8018ca:	e8 68 ff ff ff       	call   801837 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <printf>:

int
printf(const char *fmt, ...)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018ec:	e8 46 ff ff ff       	call   801837 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 10             	sub    $0x10,%esp
  8018fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	89 04 24             	mov    %eax,(%esp)
  801904:	e8 77 f6 ff ff       	call   800f80 <fd2data>
  801909:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80190b:	c7 44 24 04 ad 26 80 	movl   $0x8026ad,0x4(%esp)
  801912:	00 
  801913:	89 1c 24             	mov    %ebx,(%esp)
  801916:	e8 cc ef ff ff       	call   8008e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80191b:	8b 46 04             	mov    0x4(%esi),%eax
  80191e:	2b 06                	sub    (%esi),%eax
  801920:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801926:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80192d:	00 00 00 
	stat->st_dev = &devpipe;
  801930:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801937:	30 80 00 
	return 0;
}
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	53                   	push   %ebx
  80194a:	83 ec 14             	sub    $0x14,%esp
  80194d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801954:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195b:	e8 4a f4 ff ff       	call   800daa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801960:	89 1c 24             	mov    %ebx,(%esp)
  801963:	e8 18 f6 ff ff       	call   800f80 <fd2data>
  801968:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801973:	e8 32 f4 ff ff       	call   800daa <sys_page_unmap>
}
  801978:	83 c4 14             	add    $0x14,%esp
  80197b:	5b                   	pop    %ebx
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <_pipeisclosed>:
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	57                   	push   %edi
  801982:	56                   	push   %esi
  801983:	53                   	push   %ebx
  801984:	83 ec 2c             	sub    $0x2c,%esp
  801987:	89 c6                	mov    %eax,%esi
  801989:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  80198c:	a1 20 60 80 00       	mov    0x806020,%eax
  801991:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801994:	89 34 24             	mov    %esi,(%esp)
  801997:	e8 9b 05 00 00       	call   801f37 <pageref>
  80199c:	89 c7                	mov    %eax,%edi
  80199e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019a1:	89 04 24             	mov    %eax,(%esp)
  8019a4:	e8 8e 05 00 00       	call   801f37 <pageref>
  8019a9:	39 c7                	cmp    %eax,%edi
  8019ab:	0f 94 c2             	sete   %dl
  8019ae:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8019b1:	8b 0d 20 60 80 00    	mov    0x806020,%ecx
  8019b7:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8019ba:	39 fb                	cmp    %edi,%ebx
  8019bc:	74 21                	je     8019df <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  8019be:	84 d2                	test   %dl,%dl
  8019c0:	74 ca                	je     80198c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019c2:	8b 51 58             	mov    0x58(%ecx),%edx
  8019c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019d1:	c7 04 24 b4 26 80 00 	movl   $0x8026b4,(%esp)
  8019d8:	e8 e2 e8 ff ff       	call   8002bf <cprintf>
  8019dd:	eb ad                	jmp    80198c <_pipeisclosed+0xe>
}
  8019df:	83 c4 2c             	add    $0x2c,%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5e                   	pop    %esi
  8019e4:	5f                   	pop    %edi
  8019e5:	5d                   	pop    %ebp
  8019e6:	c3                   	ret    

008019e7 <devpipe_write>:
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	57                   	push   %edi
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 1c             	sub    $0x1c,%esp
  8019f0:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019f3:	89 34 24             	mov    %esi,(%esp)
  8019f6:	e8 85 f5 ff ff       	call   800f80 <fd2data>
  8019fb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019fd:	bf 00 00 00 00       	mov    $0x0,%edi
  801a02:	eb 45                	jmp    801a49 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801a04:	89 da                	mov    %ebx,%edx
  801a06:	89 f0                	mov    %esi,%eax
  801a08:	e8 71 ff ff ff       	call   80197e <_pipeisclosed>
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	75 41                	jne    801a52 <devpipe_write+0x6b>
			sys_yield();
  801a11:	e8 ce f2 ff ff       	call   800ce4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a16:	8b 43 04             	mov    0x4(%ebx),%eax
  801a19:	8b 0b                	mov    (%ebx),%ecx
  801a1b:	8d 51 20             	lea    0x20(%ecx),%edx
  801a1e:	39 d0                	cmp    %edx,%eax
  801a20:	73 e2                	jae    801a04 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a25:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a29:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a2c:	99                   	cltd   
  801a2d:	c1 ea 1b             	shr    $0x1b,%edx
  801a30:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801a33:	83 e1 1f             	and    $0x1f,%ecx
  801a36:	29 d1                	sub    %edx,%ecx
  801a38:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801a3c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801a40:	83 c0 01             	add    $0x1,%eax
  801a43:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a46:	83 c7 01             	add    $0x1,%edi
  801a49:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a4c:	75 c8                	jne    801a16 <devpipe_write+0x2f>
	return i;
  801a4e:	89 f8                	mov    %edi,%eax
  801a50:	eb 05                	jmp    801a57 <devpipe_write+0x70>
				return 0;
  801a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a57:	83 c4 1c             	add    $0x1c,%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <devpipe_read>:
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	57                   	push   %edi
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 1c             	sub    $0x1c,%esp
  801a68:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a6b:	89 3c 24             	mov    %edi,(%esp)
  801a6e:	e8 0d f5 ff ff       	call   800f80 <fd2data>
  801a73:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a75:	be 00 00 00 00       	mov    $0x0,%esi
  801a7a:	eb 3d                	jmp    801ab9 <devpipe_read+0x5a>
			if (i > 0)
  801a7c:	85 f6                	test   %esi,%esi
  801a7e:	74 04                	je     801a84 <devpipe_read+0x25>
				return i;
  801a80:	89 f0                	mov    %esi,%eax
  801a82:	eb 43                	jmp    801ac7 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801a84:	89 da                	mov    %ebx,%edx
  801a86:	89 f8                	mov    %edi,%eax
  801a88:	e8 f1 fe ff ff       	call   80197e <_pipeisclosed>
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	75 31                	jne    801ac2 <devpipe_read+0x63>
			sys_yield();
  801a91:	e8 4e f2 ff ff       	call   800ce4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a96:	8b 03                	mov    (%ebx),%eax
  801a98:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a9b:	74 df                	je     801a7c <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a9d:	99                   	cltd   
  801a9e:	c1 ea 1b             	shr    $0x1b,%edx
  801aa1:	01 d0                	add    %edx,%eax
  801aa3:	83 e0 1f             	and    $0x1f,%eax
  801aa6:	29 d0                	sub    %edx,%eax
  801aa8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801aad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ab3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ab6:	83 c6 01             	add    $0x1,%esi
  801ab9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801abc:	75 d8                	jne    801a96 <devpipe_read+0x37>
	return i;
  801abe:	89 f0                	mov    %esi,%eax
  801ac0:	eb 05                	jmp    801ac7 <devpipe_read+0x68>
				return 0;
  801ac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac7:	83 c4 1c             	add    $0x1c,%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5f                   	pop    %edi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <pipe>:
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ad7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ada:	89 04 24             	mov    %eax,(%esp)
  801add:	e8 b5 f4 ff ff       	call   800f97 <fd_alloc>
  801ae2:	89 c2                	mov    %eax,%edx
  801ae4:	85 d2                	test   %edx,%edx
  801ae6:	0f 88 4d 01 00 00    	js     801c39 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aec:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801af3:	00 
  801af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b02:	e8 fc f1 ff ff       	call   800d03 <sys_page_alloc>
  801b07:	89 c2                	mov    %eax,%edx
  801b09:	85 d2                	test   %edx,%edx
  801b0b:	0f 88 28 01 00 00    	js     801c39 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801b11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b14:	89 04 24             	mov    %eax,(%esp)
  801b17:	e8 7b f4 ff ff       	call   800f97 <fd_alloc>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	0f 88 fe 00 00 00    	js     801c24 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b2d:	00 
  801b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3c:	e8 c2 f1 ff ff       	call   800d03 <sys_page_alloc>
  801b41:	89 c3                	mov    %eax,%ebx
  801b43:	85 c0                	test   %eax,%eax
  801b45:	0f 88 d9 00 00 00    	js     801c24 <pipe+0x155>
	va = fd2data(fd0);
  801b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 2a f4 ff ff       	call   800f80 <fd2data>
  801b56:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b58:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b5f:	00 
  801b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b6b:	e8 93 f1 ff ff       	call   800d03 <sys_page_alloc>
  801b70:	89 c3                	mov    %eax,%ebx
  801b72:	85 c0                	test   %eax,%eax
  801b74:	0f 88 97 00 00 00    	js     801c11 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7d:	89 04 24             	mov    %eax,(%esp)
  801b80:	e8 fb f3 ff ff       	call   800f80 <fd2data>
  801b85:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b8c:	00 
  801b8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b98:	00 
  801b99:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba4:	e8 ae f1 ff ff       	call   800d57 <sys_page_map>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 52                	js     801c01 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801baf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801bc4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bcd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdc:	89 04 24             	mov    %eax,(%esp)
  801bdf:	e8 8c f3 ff ff       	call   800f70 <fd2num>
  801be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 7c f3 ff ff       	call   800f70 <fd2num>
  801bf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  801bff:	eb 38                	jmp    801c39 <pipe+0x16a>
	sys_page_unmap(0, va);
  801c01:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0c:	e8 99 f1 ff ff       	call   800daa <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1f:	e8 86 f1 ff ff       	call   800daa <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c32:	e8 73 f1 ff ff       	call   800daa <sys_page_unmap>
  801c37:	89 d8                	mov    %ebx,%eax
}
  801c39:	83 c4 30             	add    $0x30,%esp
  801c3c:	5b                   	pop    %ebx
  801c3d:	5e                   	pop    %esi
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <pipeisclosed>:
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	89 04 24             	mov    %eax,(%esp)
  801c53:	e8 8e f3 ff ff       	call   800fe6 <fd_lookup>
  801c58:	89 c2                	mov    %eax,%edx
  801c5a:	85 d2                	test   %edx,%edx
  801c5c:	78 15                	js     801c73 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c61:	89 04 24             	mov    %eax,(%esp)
  801c64:	e8 17 f3 ff ff       	call   800f80 <fd2data>
	return _pipeisclosed(fd, p);
  801c69:	89 c2                	mov    %eax,%edx
  801c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6e:	e8 0b fd ff ff       	call   80197e <_pipeisclosed>
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    
  801c75:	66 90                	xchg   %ax,%ax
  801c77:	66 90                	xchg   %ax,%ax
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c83:	b8 00 00 00 00       	mov    $0x0,%eax
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c90:	c7 44 24 04 cc 26 80 	movl   $0x8026cc,0x4(%esp)
  801c97:	00 
  801c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 44 ec ff ff       	call   8008e7 <strcpy>
	return 0;
}
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <devcons_write>:
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	57                   	push   %edi
  801cae:	56                   	push   %esi
  801caf:	53                   	push   %ebx
  801cb0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cbb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801cc1:	eb 31                	jmp    801cf4 <devcons_write+0x4a>
		m = n - tot;
  801cc3:	8b 75 10             	mov    0x10(%ebp),%esi
  801cc6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801cc8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801ccb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cd0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cd3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cd7:	03 45 0c             	add    0xc(%ebp),%eax
  801cda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cde:	89 3c 24             	mov    %edi,(%esp)
  801ce1:	e8 9e ed ff ff       	call   800a84 <memmove>
		sys_cputs(buf, m);
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	89 3c 24             	mov    %edi,(%esp)
  801ced:	e8 44 ef ff ff       	call   800c36 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cf2:	01 f3                	add    %esi,%ebx
  801cf4:	89 d8                	mov    %ebx,%eax
  801cf6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf9:	72 c8                	jb     801cc3 <devcons_write+0x19>
}
  801cfb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5e                   	pop    %esi
  801d03:	5f                   	pop    %edi
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    

00801d06 <devcons_read>:
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801d0c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d15:	75 07                	jne    801d1e <devcons_read+0x18>
  801d17:	eb 2a                	jmp    801d43 <devcons_read+0x3d>
		sys_yield();
  801d19:	e8 c6 ef ff ff       	call   800ce4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d1e:	66 90                	xchg   %ax,%ax
  801d20:	e8 2f ef ff ff       	call   800c54 <sys_cgetc>
  801d25:	85 c0                	test   %eax,%eax
  801d27:	74 f0                	je     801d19 <devcons_read+0x13>
	if (c < 0)
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	78 16                	js     801d43 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801d2d:	83 f8 04             	cmp    $0x4,%eax
  801d30:	74 0c                	je     801d3e <devcons_read+0x38>
	*(char*)vbuf = c;
  801d32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d35:	88 02                	mov    %al,(%edx)
	return 1;
  801d37:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3c:	eb 05                	jmp    801d43 <devcons_read+0x3d>
		return 0;
  801d3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <cputchar>:
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d58:	00 
  801d59:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d5c:	89 04 24             	mov    %eax,(%esp)
  801d5f:	e8 d2 ee ff ff       	call   800c36 <sys_cputs>
}
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    

00801d66 <getchar>:
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801d6c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d73:	00 
  801d74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d82:	e8 ee f4 ff ff       	call   801275 <read>
	if (r < 0)
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 0f                	js     801d9a <getchar+0x34>
	if (r < 1)
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	7e 06                	jle    801d95 <getchar+0x2f>
	return c;
  801d8f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d93:	eb 05                	jmp    801d9a <getchar+0x34>
		return -E_EOF;
  801d95:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <iscons>:
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	89 04 24             	mov    %eax,(%esp)
  801daf:	e8 32 f2 ff ff       	call   800fe6 <fd_lookup>
  801db4:	85 c0                	test   %eax,%eax
  801db6:	78 11                	js     801dc9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dc1:	39 10                	cmp    %edx,(%eax)
  801dc3:	0f 94 c0             	sete   %al
  801dc6:	0f b6 c0             	movzbl %al,%eax
}
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <opencons>:
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801dd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd4:	89 04 24             	mov    %eax,(%esp)
  801dd7:	e8 bb f1 ff ff       	call   800f97 <fd_alloc>
		return r;
  801ddc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 40                	js     801e22 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801de9:	00 
  801dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ded:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df8:	e8 06 ef ff ff       	call   800d03 <sys_page_alloc>
		return r;
  801dfd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dff:	85 c0                	test   %eax,%eax
  801e01:	78 1f                	js     801e22 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801e03:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e11:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e18:	89 04 24             	mov    %eax,(%esp)
  801e1b:	e8 50 f1 ff ff       	call   800f70 <fd2num>
  801e20:	89 c2                	mov    %eax,%edx
}
  801e22:	89 d0                	mov    %edx,%eax
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    
  801e26:	66 90                	xchg   %ax,%ax
  801e28:	66 90                	xchg   %ax,%ax
  801e2a:	66 90                	xchg   %ax,%ax
  801e2c:	66 90                	xchg   %ax,%ax
  801e2e:	66 90                	xchg   %ax,%ax

00801e30 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	56                   	push   %esi
  801e34:	53                   	push   %ebx
  801e35:	83 ec 10             	sub    $0x10,%esp
  801e38:	8b 75 08             	mov    0x8(%ebp),%esi
  801e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801e41:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801e43:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801e48:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801e4b:	89 04 24             	mov    %eax,(%esp)
  801e4e:	e8 c6 f0 ff ff       	call   800f19 <sys_ipc_recv>
    if(r < 0){
  801e53:	85 c0                	test   %eax,%eax
  801e55:	79 16                	jns    801e6d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801e57:	85 f6                	test   %esi,%esi
  801e59:	74 06                	je     801e61 <ipc_recv+0x31>
            *from_env_store = 0;
  801e5b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801e61:	85 db                	test   %ebx,%ebx
  801e63:	74 2c                	je     801e91 <ipc_recv+0x61>
            *perm_store = 0;
  801e65:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e6b:	eb 24                	jmp    801e91 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801e6d:	85 f6                	test   %esi,%esi
  801e6f:	74 0a                	je     801e7b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801e71:	a1 20 60 80 00       	mov    0x806020,%eax
  801e76:	8b 40 74             	mov    0x74(%eax),%eax
  801e79:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801e7b:	85 db                	test   %ebx,%ebx
  801e7d:	74 0a                	je     801e89 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801e7f:	a1 20 60 80 00       	mov    0x806020,%eax
  801e84:	8b 40 78             	mov    0x78(%eax),%eax
  801e87:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e89:	a1 20 60 80 00       	mov    0x806020,%eax
  801e8e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	57                   	push   %edi
  801e9c:	56                   	push   %esi
  801e9d:	53                   	push   %ebx
  801e9e:	83 ec 1c             	sub    $0x1c,%esp
  801ea1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ea4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801eaa:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801eac:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801eb1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801eb4:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ebf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec3:	89 3c 24             	mov    %edi,(%esp)
  801ec6:	e8 2b f0 ff ff       	call   800ef6 <sys_ipc_try_send>
        if(r == 0){
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	74 28                	je     801ef7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801ecf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed2:	74 1c                	je     801ef0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801ed4:	c7 44 24 08 d8 26 80 	movl   $0x8026d8,0x8(%esp)
  801edb:	00 
  801edc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801ee3:	00 
  801ee4:	c7 04 24 ef 26 80 00 	movl   $0x8026ef,(%esp)
  801eeb:	e8 d6 e2 ff ff       	call   8001c6 <_panic>
        }
        sys_yield();
  801ef0:	e8 ef ed ff ff       	call   800ce4 <sys_yield>
    }
  801ef5:	eb bd                	jmp    801eb4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801ef7:	83 c4 1c             	add    $0x1c,%esp
  801efa:	5b                   	pop    %ebx
  801efb:	5e                   	pop    %esi
  801efc:	5f                   	pop    %edi
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f05:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f0a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f0d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f13:	8b 52 50             	mov    0x50(%edx),%edx
  801f16:	39 ca                	cmp    %ecx,%edx
  801f18:	75 0d                	jne    801f27 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f1a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f1d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f22:	8b 40 40             	mov    0x40(%eax),%eax
  801f25:	eb 0e                	jmp    801f35 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801f27:	83 c0 01             	add    $0x1,%eax
  801f2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f2f:	75 d9                	jne    801f0a <ipc_find_env+0xb>
	return 0;
  801f31:	66 b8 00 00          	mov    $0x0,%ax
}
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3d:	89 d0                	mov    %edx,%eax
  801f3f:	c1 e8 16             	shr    $0x16,%eax
  801f42:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f49:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f4e:	f6 c1 01             	test   $0x1,%cl
  801f51:	74 1d                	je     801f70 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f53:	c1 ea 0c             	shr    $0xc,%edx
  801f56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5d:	f6 c2 01             	test   $0x1,%dl
  801f60:	74 0e                	je     801f70 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f62:	c1 ea 0c             	shr    $0xc,%edx
  801f65:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f6c:	ef 
  801f6d:	0f b7 c0             	movzwl %ax,%eax
}
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    
  801f72:	66 90                	xchg   %ax,%ax
  801f74:	66 90                	xchg   %ax,%ax
  801f76:	66 90                	xchg   %ax,%ax
  801f78:	66 90                	xchg   %ax,%ax
  801f7a:	66 90                	xchg   %ax,%ax
  801f7c:	66 90                	xchg   %ax,%ax
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	83 ec 0c             	sub    $0xc,%esp
  801f86:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f8a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801f8e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801f92:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f96:	85 c0                	test   %eax,%eax
  801f98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f9c:	89 ea                	mov    %ebp,%edx
  801f9e:	89 0c 24             	mov    %ecx,(%esp)
  801fa1:	75 2d                	jne    801fd0 <__udivdi3+0x50>
  801fa3:	39 e9                	cmp    %ebp,%ecx
  801fa5:	77 61                	ja     802008 <__udivdi3+0x88>
  801fa7:	85 c9                	test   %ecx,%ecx
  801fa9:	89 ce                	mov    %ecx,%esi
  801fab:	75 0b                	jne    801fb8 <__udivdi3+0x38>
  801fad:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb2:	31 d2                	xor    %edx,%edx
  801fb4:	f7 f1                	div    %ecx
  801fb6:	89 c6                	mov    %eax,%esi
  801fb8:	31 d2                	xor    %edx,%edx
  801fba:	89 e8                	mov    %ebp,%eax
  801fbc:	f7 f6                	div    %esi
  801fbe:	89 c5                	mov    %eax,%ebp
  801fc0:	89 f8                	mov    %edi,%eax
  801fc2:	f7 f6                	div    %esi
  801fc4:	89 ea                	mov    %ebp,%edx
  801fc6:	83 c4 0c             	add    $0xc,%esp
  801fc9:	5e                   	pop    %esi
  801fca:	5f                   	pop    %edi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    
  801fcd:	8d 76 00             	lea    0x0(%esi),%esi
  801fd0:	39 e8                	cmp    %ebp,%eax
  801fd2:	77 24                	ja     801ff8 <__udivdi3+0x78>
  801fd4:	0f bd e8             	bsr    %eax,%ebp
  801fd7:	83 f5 1f             	xor    $0x1f,%ebp
  801fda:	75 3c                	jne    802018 <__udivdi3+0x98>
  801fdc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801fe0:	39 34 24             	cmp    %esi,(%esp)
  801fe3:	0f 86 9f 00 00 00    	jbe    802088 <__udivdi3+0x108>
  801fe9:	39 d0                	cmp    %edx,%eax
  801feb:	0f 82 97 00 00 00    	jb     802088 <__udivdi3+0x108>
  801ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	31 d2                	xor    %edx,%edx
  801ffa:	31 c0                	xor    %eax,%eax
  801ffc:	83 c4 0c             	add    $0xc,%esp
  801fff:	5e                   	pop    %esi
  802000:	5f                   	pop    %edi
  802001:	5d                   	pop    %ebp
  802002:	c3                   	ret    
  802003:	90                   	nop
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	89 f8                	mov    %edi,%eax
  80200a:	f7 f1                	div    %ecx
  80200c:	31 d2                	xor    %edx,%edx
  80200e:	83 c4 0c             	add    $0xc,%esp
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    
  802015:	8d 76 00             	lea    0x0(%esi),%esi
  802018:	89 e9                	mov    %ebp,%ecx
  80201a:	8b 3c 24             	mov    (%esp),%edi
  80201d:	d3 e0                	shl    %cl,%eax
  80201f:	89 c6                	mov    %eax,%esi
  802021:	b8 20 00 00 00       	mov    $0x20,%eax
  802026:	29 e8                	sub    %ebp,%eax
  802028:	89 c1                	mov    %eax,%ecx
  80202a:	d3 ef                	shr    %cl,%edi
  80202c:	89 e9                	mov    %ebp,%ecx
  80202e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802032:	8b 3c 24             	mov    (%esp),%edi
  802035:	09 74 24 08          	or     %esi,0x8(%esp)
  802039:	89 d6                	mov    %edx,%esi
  80203b:	d3 e7                	shl    %cl,%edi
  80203d:	89 c1                	mov    %eax,%ecx
  80203f:	89 3c 24             	mov    %edi,(%esp)
  802042:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802046:	d3 ee                	shr    %cl,%esi
  802048:	89 e9                	mov    %ebp,%ecx
  80204a:	d3 e2                	shl    %cl,%edx
  80204c:	89 c1                	mov    %eax,%ecx
  80204e:	d3 ef                	shr    %cl,%edi
  802050:	09 d7                	or     %edx,%edi
  802052:	89 f2                	mov    %esi,%edx
  802054:	89 f8                	mov    %edi,%eax
  802056:	f7 74 24 08          	divl   0x8(%esp)
  80205a:	89 d6                	mov    %edx,%esi
  80205c:	89 c7                	mov    %eax,%edi
  80205e:	f7 24 24             	mull   (%esp)
  802061:	39 d6                	cmp    %edx,%esi
  802063:	89 14 24             	mov    %edx,(%esp)
  802066:	72 30                	jb     802098 <__udivdi3+0x118>
  802068:	8b 54 24 04          	mov    0x4(%esp),%edx
  80206c:	89 e9                	mov    %ebp,%ecx
  80206e:	d3 e2                	shl    %cl,%edx
  802070:	39 c2                	cmp    %eax,%edx
  802072:	73 05                	jae    802079 <__udivdi3+0xf9>
  802074:	3b 34 24             	cmp    (%esp),%esi
  802077:	74 1f                	je     802098 <__udivdi3+0x118>
  802079:	89 f8                	mov    %edi,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	e9 7a ff ff ff       	jmp    801ffc <__udivdi3+0x7c>
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 d2                	xor    %edx,%edx
  80208a:	b8 01 00 00 00       	mov    $0x1,%eax
  80208f:	e9 68 ff ff ff       	jmp    801ffc <__udivdi3+0x7c>
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	8d 47 ff             	lea    -0x1(%edi),%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	83 c4 0c             	add    $0xc,%esp
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	83 ec 14             	sub    $0x14,%esp
  8020b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8020ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8020be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8020c2:	89 c7                	mov    %eax,%edi
  8020c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8020cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8020d0:	89 34 24             	mov    %esi,(%esp)
  8020d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	89 c2                	mov    %eax,%edx
  8020db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020df:	75 17                	jne    8020f8 <__umoddi3+0x48>
  8020e1:	39 fe                	cmp    %edi,%esi
  8020e3:	76 4b                	jbe    802130 <__umoddi3+0x80>
  8020e5:	89 c8                	mov    %ecx,%eax
  8020e7:	89 fa                	mov    %edi,%edx
  8020e9:	f7 f6                	div    %esi
  8020eb:	89 d0                	mov    %edx,%eax
  8020ed:	31 d2                	xor    %edx,%edx
  8020ef:	83 c4 14             	add    $0x14,%esp
  8020f2:	5e                   	pop    %esi
  8020f3:	5f                   	pop    %edi
  8020f4:	5d                   	pop    %ebp
  8020f5:	c3                   	ret    
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	39 f8                	cmp    %edi,%eax
  8020fa:	77 54                	ja     802150 <__umoddi3+0xa0>
  8020fc:	0f bd e8             	bsr    %eax,%ebp
  8020ff:	83 f5 1f             	xor    $0x1f,%ebp
  802102:	75 5c                	jne    802160 <__umoddi3+0xb0>
  802104:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802108:	39 3c 24             	cmp    %edi,(%esp)
  80210b:	0f 87 e7 00 00 00    	ja     8021f8 <__umoddi3+0x148>
  802111:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802115:	29 f1                	sub    %esi,%ecx
  802117:	19 c7                	sbb    %eax,%edi
  802119:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80211d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802121:	8b 44 24 08          	mov    0x8(%esp),%eax
  802125:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802129:	83 c4 14             	add    $0x14,%esp
  80212c:	5e                   	pop    %esi
  80212d:	5f                   	pop    %edi
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    
  802130:	85 f6                	test   %esi,%esi
  802132:	89 f5                	mov    %esi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f6                	div    %esi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	8b 44 24 04          	mov    0x4(%esp),%eax
  802145:	31 d2                	xor    %edx,%edx
  802147:	f7 f5                	div    %ebp
  802149:	89 c8                	mov    %ecx,%eax
  80214b:	f7 f5                	div    %ebp
  80214d:	eb 9c                	jmp    8020eb <__umoddi3+0x3b>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 fa                	mov    %edi,%edx
  802154:	83 c4 14             	add    $0x14,%esp
  802157:	5e                   	pop    %esi
  802158:	5f                   	pop    %edi
  802159:	5d                   	pop    %ebp
  80215a:	c3                   	ret    
  80215b:	90                   	nop
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 04 24             	mov    (%esp),%eax
  802163:	be 20 00 00 00       	mov    $0x20,%esi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ee                	sub    %ebp,%esi
  80216c:	d3 e2                	shl    %cl,%edx
  80216e:	89 f1                	mov    %esi,%ecx
  802170:	d3 e8                	shr    %cl,%eax
  802172:	89 e9                	mov    %ebp,%ecx
  802174:	89 44 24 04          	mov    %eax,0x4(%esp)
  802178:	8b 04 24             	mov    (%esp),%eax
  80217b:	09 54 24 04          	or     %edx,0x4(%esp)
  80217f:	89 fa                	mov    %edi,%edx
  802181:	d3 e0                	shl    %cl,%eax
  802183:	89 f1                	mov    %esi,%ecx
  802185:	89 44 24 08          	mov    %eax,0x8(%esp)
  802189:	8b 44 24 10          	mov    0x10(%esp),%eax
  80218d:	d3 ea                	shr    %cl,%edx
  80218f:	89 e9                	mov    %ebp,%ecx
  802191:	d3 e7                	shl    %cl,%edi
  802193:	89 f1                	mov    %esi,%ecx
  802195:	d3 e8                	shr    %cl,%eax
  802197:	89 e9                	mov    %ebp,%ecx
  802199:	09 f8                	or     %edi,%eax
  80219b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80219f:	f7 74 24 04          	divl   0x4(%esp)
  8021a3:	d3 e7                	shl    %cl,%edi
  8021a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021a9:	89 d7                	mov    %edx,%edi
  8021ab:	f7 64 24 08          	mull   0x8(%esp)
  8021af:	39 d7                	cmp    %edx,%edi
  8021b1:	89 c1                	mov    %eax,%ecx
  8021b3:	89 14 24             	mov    %edx,(%esp)
  8021b6:	72 2c                	jb     8021e4 <__umoddi3+0x134>
  8021b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8021bc:	72 22                	jb     8021e0 <__umoddi3+0x130>
  8021be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8021c2:	29 c8                	sub    %ecx,%eax
  8021c4:	19 d7                	sbb    %edx,%edi
  8021c6:	89 e9                	mov    %ebp,%ecx
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	d3 e8                	shr    %cl,%eax
  8021cc:	89 f1                	mov    %esi,%ecx
  8021ce:	d3 e2                	shl    %cl,%edx
  8021d0:	89 e9                	mov    %ebp,%ecx
  8021d2:	d3 ef                	shr    %cl,%edi
  8021d4:	09 d0                	or     %edx,%eax
  8021d6:	89 fa                	mov    %edi,%edx
  8021d8:	83 c4 14             	add    $0x14,%esp
  8021db:	5e                   	pop    %esi
  8021dc:	5f                   	pop    %edi
  8021dd:	5d                   	pop    %ebp
  8021de:	c3                   	ret    
  8021df:	90                   	nop
  8021e0:	39 d7                	cmp    %edx,%edi
  8021e2:	75 da                	jne    8021be <__umoddi3+0x10e>
  8021e4:	8b 14 24             	mov    (%esp),%edx
  8021e7:	89 c1                	mov    %eax,%ecx
  8021e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8021ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8021f1:	eb cb                	jmp    8021be <__umoddi3+0x10e>
  8021f3:	90                   	nop
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8021fc:	0f 82 0f ff ff ff    	jb     802111 <__umoddi3+0x61>
  802202:	e9 1a ff ff ff       	jmp    802121 <__umoddi3+0x71>
