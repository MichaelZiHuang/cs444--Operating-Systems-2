
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 e8 01 00 00       	call   800219 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800043:	00 
  800044:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80004b:	e8 a1 1a 00 00       	call   801af1 <open>
  800050:	89 c3                	mov    %eax,%ebx
  800052:	85 c0                	test   %eax,%eax
  800054:	79 20                	jns    800076 <umain+0x43>
		panic("open motd: %e", fd);
  800056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005a:	c7 44 24 08 c5 25 80 	movl   $0x8025c5,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 d3 25 80 00 	movl   $0x8025d3,(%esp)
  800071:	e8 04 02 00 00       	call   80027a <_panic>
	seek(fd, 0);
  800076:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007d:	00 
  80007e:	89 04 24             	mov    %eax,(%esp)
  800081:	e8 29 17 00 00       	call   8017af <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800086:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 20 42 80 	movl   $0x804220,0x4(%esp)
  800095:	00 
  800096:	89 1c 24             	mov    %ebx,(%esp)
  800099:	e8 39 16 00 00       	call   8016d7 <readn>
  80009e:	89 c7                	mov    %eax,%edi
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	7f 20                	jg     8000c4 <umain+0x91>
		panic("readn: %e", n);
  8000a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a8:	c7 44 24 08 e8 25 80 	movl   $0x8025e8,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b7:	00 
  8000b8:	c7 04 24 d3 25 80 00 	movl   $0x8025d3,(%esp)
  8000bf:	e8 b6 01 00 00       	call   80027a <_panic>

	if ((r = fork()) < 0)
  8000c4:	e8 79 10 00 00       	call   801142 <fork>
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	79 20                	jns    8000ef <umain+0xbc>
		panic("fork: %e", r);
  8000cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d3:	c7 44 24 08 f2 25 80 	movl   $0x8025f2,0x8(%esp)
  8000da:	00 
  8000db:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e2:	00 
  8000e3:	c7 04 24 d3 25 80 00 	movl   $0x8025d3,(%esp)
  8000ea:	e8 8b 01 00 00       	call   80027a <_panic>
	if (r == 0) {
  8000ef:	85 c0                	test   %eax,%eax
  8000f1:	0f 85 bd 00 00 00    	jne    8001b4 <umain+0x181>
		seek(fd, 0);
  8000f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000fe:	00 
  8000ff:	89 1c 24             	mov    %ebx,(%esp)
  800102:	e8 a8 16 00 00       	call   8017af <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800107:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
  80010e:	e8 60 02 00 00       	call   800373 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800113:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800122:	00 
  800123:	89 1c 24             	mov    %ebx,(%esp)
  800126:	e8 ac 15 00 00       	call   8016d7 <readn>
  80012b:	39 f8                	cmp    %edi,%eax
  80012d:	74 24                	je     800153 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  80012f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800133:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800137:	c7 44 24 08 74 26 80 	movl   $0x802674,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 d3 25 80 00 	movl   $0x8025d3,(%esp)
  80014e:	e8 27 01 00 00       	call   80027a <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800153:	89 44 24 08          	mov    %eax,0x8(%esp)
  800157:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  800166:	e8 52 0a 00 00       	call   800bbd <memcmp>
  80016b:	85 c0                	test   %eax,%eax
  80016d:	74 1c                	je     80018b <umain+0x158>
			panic("read in parent got different bytes from read in child");
  80016f:	c7 44 24 08 a0 26 80 	movl   $0x8026a0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017e:	00 
  80017f:	c7 04 24 d3 25 80 00 	movl   $0x8025d3,(%esp)
  800186:	e8 ef 00 00 00       	call   80027a <_panic>
		cprintf("read in child succeeded\n");
  80018b:	c7 04 24 fb 25 80 00 	movl   $0x8025fb,(%esp)
  800192:	e8 dc 01 00 00       	call   800373 <cprintf>
		seek(fd, 0);
  800197:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019e:	00 
  80019f:	89 1c 24             	mov    %ebx,(%esp)
  8001a2:	e8 08 16 00 00       	call   8017af <seek>
		close(fd);
  8001a7:	89 1c 24             	mov    %ebx,(%esp)
  8001aa:	e8 33 13 00 00       	call   8014e2 <close>
		exit();
  8001af:	e8 ad 00 00 00       	call   800261 <exit>
	}
	wait(r);
  8001b4:	89 34 24             	mov    %esi,(%esp)
  8001b7:	e8 52 1d 00 00       	call   801f0e <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c3:	00 
  8001c4:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  8001cb:	00 
  8001cc:	89 1c 24             	mov    %ebx,(%esp)
  8001cf:	e8 03 15 00 00       	call   8016d7 <readn>
  8001d4:	39 f8                	cmp    %edi,%eax
  8001d6:	74 24                	je     8001fc <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e0:	c7 44 24 08 d8 26 80 	movl   $0x8026d8,0x8(%esp)
  8001e7:	00 
  8001e8:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 d3 25 80 00 	movl   $0x8025d3,(%esp)
  8001f7:	e8 7e 00 00 00       	call   80027a <_panic>
	cprintf("read in parent succeeded\n");
  8001fc:	c7 04 24 14 26 80 00 	movl   $0x802614,(%esp)
  800203:	e8 6b 01 00 00       	call   800373 <cprintf>
	close(fd);
  800208:	89 1c 24             	mov    %ebx,(%esp)
  80020b:	e8 d2 12 00 00       	call   8014e2 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800210:	cc                   	int3   

	breakpoint();
}
  800211:	83 c4 2c             	add    $0x2c,%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 10             	sub    $0x10,%esp
  800221:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800224:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800227:	e8 49 0b 00 00       	call   800d75 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  80022c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800231:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800234:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800239:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80023e:	85 db                	test   %ebx,%ebx
  800240:	7e 07                	jle    800249 <libmain+0x30>
		binaryname = argv[0];
  800242:	8b 06                	mov    (%esi),%eax
  800244:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800249:	89 74 24 04          	mov    %esi,0x4(%esp)
  80024d:	89 1c 24             	mov    %ebx,(%esp)
  800250:	e8 de fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800255:	e8 07 00 00 00       	call   800261 <exit>
}
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5e                   	pop    %esi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800267:	e8 a9 12 00 00       	call   801515 <close_all>
	sys_env_destroy(0);
  80026c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800273:	e8 ab 0a 00 00       	call   800d23 <sys_env_destroy>
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800282:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800285:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80028b:	e8 e5 0a 00 00       	call   800d75 <sys_getenvid>
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 54 24 10          	mov    %edx,0x10(%esp)
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80029e:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a6:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  8002ad:	e8 c1 00 00 00       	call   800373 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b9:	89 04 24             	mov    %eax,(%esp)
  8002bc:	e8 51 00 00 00       	call   800312 <vcprintf>
	cprintf("\n");
  8002c1:	c7 04 24 12 26 80 00 	movl   $0x802612,(%esp)
  8002c8:	e8 a6 00 00 00       	call   800373 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002cd:	cc                   	int3   
  8002ce:	eb fd                	jmp    8002cd <_panic+0x53>

008002d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 14             	sub    $0x14,%esp
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002da:	8b 13                	mov    (%ebx),%edx
  8002dc:	8d 42 01             	lea    0x1(%edx),%eax
  8002df:	89 03                	mov    %eax,(%ebx)
  8002e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ed:	75 19                	jne    800308 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002f6:	00 
  8002f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	e8 e4 09 00 00       	call   800ce6 <sys_cputs>
		b->idx = 0;
  800302:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800308:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80030c:	83 c4 14             	add    $0x14,%esp
  80030f:	5b                   	pop    %ebx
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80031b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800322:	00 00 00 
	b.cnt = 0;
  800325:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80032c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80032f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800343:	89 44 24 04          	mov    %eax,0x4(%esp)
  800347:	c7 04 24 d0 02 80 00 	movl   $0x8002d0,(%esp)
  80034e:	e8 ab 01 00 00       	call   8004fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800353:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	e8 7b 09 00 00       	call   800ce6 <sys_cputs>

	return b.cnt;
}
  80036b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800371:	c9                   	leave  
  800372:	c3                   	ret    

00800373 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800379:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	e8 87 ff ff ff       	call   800312 <vcprintf>
	va_end(ap);

	return cnt;
}
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    
  80038d:	66 90                	xchg   %ax,%ax
  80038f:	90                   	nop

00800390 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 3c             	sub    $0x3c,%esp
  800399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039c:	89 d7                	mov    %edx,%edi
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a7:	89 c3                	mov    %eax,%ebx
  8003a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8003af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003bd:	39 d9                	cmp    %ebx,%ecx
  8003bf:	72 05                	jb     8003c6 <printnum+0x36>
  8003c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003c4:	77 69                	ja     80042f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003cd:	83 ee 01             	sub    $0x1,%esi
  8003d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003e0:	89 c3                	mov    %eax,%ebx
  8003e2:	89 d6                	mov    %edx,%esi
  8003e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	e8 1c 1f 00 00       	call   802320 <__udivdi3>
  800404:	89 d9                	mov    %ebx,%ecx
  800406:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80040a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80040e:	89 04 24             	mov    %eax,(%esp)
  800411:	89 54 24 04          	mov    %edx,0x4(%esp)
  800415:	89 fa                	mov    %edi,%edx
  800417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041a:	e8 71 ff ff ff       	call   800390 <printnum>
  80041f:	eb 1b                	jmp    80043c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800421:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800425:	8b 45 18             	mov    0x18(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	ff d3                	call   *%ebx
  80042d:	eb 03                	jmp    800432 <printnum+0xa2>
  80042f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800432:	83 ee 01             	sub    $0x1,%esi
  800435:	85 f6                	test   %esi,%esi
  800437:	7f e8                	jg     800421 <printnum+0x91>
  800439:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800440:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800444:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800447:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80044a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800452:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800455:	89 04 24             	mov    %eax,(%esp)
  800458:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80045b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045f:	e8 ec 1f 00 00       	call   802450 <__umoddi3>
  800464:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800468:	0f be 80 2b 27 80 00 	movsbl 0x80272b(%eax),%eax
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800475:	ff d0                	call   *%eax
}
  800477:	83 c4 3c             	add    $0x3c,%esp
  80047a:	5b                   	pop    %ebx
  80047b:	5e                   	pop    %esi
  80047c:	5f                   	pop    %edi
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800482:	83 fa 01             	cmp    $0x1,%edx
  800485:	7e 0e                	jle    800495 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800487:	8b 10                	mov    (%eax),%edx
  800489:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048c:	89 08                	mov    %ecx,(%eax)
  80048e:	8b 02                	mov    (%edx),%eax
  800490:	8b 52 04             	mov    0x4(%edx),%edx
  800493:	eb 22                	jmp    8004b7 <getuint+0x38>
	else if (lflag)
  800495:	85 d2                	test   %edx,%edx
  800497:	74 10                	je     8004a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800499:	8b 10                	mov    (%eax),%edx
  80049b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049e:	89 08                	mov    %ecx,(%eax)
  8004a0:	8b 02                	mov    (%edx),%eax
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	eb 0e                	jmp    8004b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b7:	5d                   	pop    %ebp
  8004b8:	c3                   	ret    

008004b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c8:	73 0a                	jae    8004d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d2:	88 02                	mov    %al,(%edx)
}
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <printfmt>:
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8004dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 02 00 00 00       	call   8004fe <vprintfmt>
}
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    

008004fe <vprintfmt>:
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	57                   	push   %edi
  800502:	56                   	push   %esi
  800503:	53                   	push   %ebx
  800504:	83 ec 3c             	sub    $0x3c,%esp
  800507:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80050a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80050d:	eb 1f                	jmp    80052e <vprintfmt+0x30>
			if (ch == '\0'){
  80050f:	85 c0                	test   %eax,%eax
  800511:	75 0f                	jne    800522 <vprintfmt+0x24>
				color = 0x0100;
  800513:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80051a:	01 00 00 
  80051d:	e9 b3 03 00 00       	jmp    8008d5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800522:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800526:	89 04 24             	mov    %eax,(%esp)
  800529:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052c:	89 f3                	mov    %esi,%ebx
  80052e:	8d 73 01             	lea    0x1(%ebx),%esi
  800531:	0f b6 03             	movzbl (%ebx),%eax
  800534:	83 f8 25             	cmp    $0x25,%eax
  800537:	75 d6                	jne    80050f <vprintfmt+0x11>
  800539:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80053d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800544:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80054b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800552:	ba 00 00 00 00       	mov    $0x0,%edx
  800557:	eb 1d                	jmp    800576 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800559:	89 de                	mov    %ebx,%esi
			padc = '-';
  80055b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80055f:	eb 15                	jmp    800576 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800561:	89 de                	mov    %ebx,%esi
			padc = '0';
  800563:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800567:	eb 0d                	jmp    800576 <vprintfmt+0x78>
				width = precision, precision = -1;
  800569:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80056f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8d 5e 01             	lea    0x1(%esi),%ebx
  800579:	0f b6 0e             	movzbl (%esi),%ecx
  80057c:	0f b6 c1             	movzbl %cl,%eax
  80057f:	83 e9 23             	sub    $0x23,%ecx
  800582:	80 f9 55             	cmp    $0x55,%cl
  800585:	0f 87 2a 03 00 00    	ja     8008b5 <vprintfmt+0x3b7>
  80058b:	0f b6 c9             	movzbl %cl,%ecx
  80058e:	ff 24 8d 60 28 80 00 	jmp    *0x802860(,%ecx,4)
  800595:	89 de                	mov    %ebx,%esi
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80059c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80059f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8005a3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005a6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005a9:	83 fb 09             	cmp    $0x9,%ebx
  8005ac:	77 36                	ja     8005e4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8005ae:	83 c6 01             	add    $0x1,%esi
			}
  8005b1:	eb e9                	jmp    80059c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8005c3:	eb 22                	jmp    8005e7 <vprintfmt+0xe9>
  8005c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c8:	85 c9                	test   %ecx,%ecx
  8005ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cf:	0f 49 c1             	cmovns %ecx,%eax
  8005d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	89 de                	mov    %ebx,%esi
  8005d7:	eb 9d                	jmp    800576 <vprintfmt+0x78>
  8005d9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8005db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005e2:	eb 92                	jmp    800576 <vprintfmt+0x78>
  8005e4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8005e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005eb:	79 89                	jns    800576 <vprintfmt+0x78>
  8005ed:	e9 77 ff ff ff       	jmp    800569 <vprintfmt+0x6b>
			lflag++;
  8005f2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8005f7:	e9 7a ff ff ff       	jmp    800576 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 04 24             	mov    %eax,(%esp)
  80060e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800611:	e9 18 ff ff ff       	jmp    80052e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	99                   	cltd   
  800622:	31 d0                	xor    %edx,%eax
  800624:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800626:	83 f8 0f             	cmp    $0xf,%eax
  800629:	7f 0b                	jg     800636 <vprintfmt+0x138>
  80062b:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800632:	85 d2                	test   %edx,%edx
  800634:	75 20                	jne    800656 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800636:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80063a:	c7 44 24 08 43 27 80 	movl   $0x802743,0x8(%esp)
  800641:	00 
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	8b 45 08             	mov    0x8(%ebp),%eax
  800649:	89 04 24             	mov    %eax,(%esp)
  80064c:	e8 85 fe ff ff       	call   8004d6 <printfmt>
  800651:	e9 d8 fe ff ff       	jmp    80052e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800656:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065a:	c7 44 24 08 7a 2c 80 	movl   $0x802c7a,0x8(%esp)
  800661:	00 
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	8b 45 08             	mov    0x8(%ebp),%eax
  800669:	89 04 24             	mov    %eax,(%esp)
  80066c:	e8 65 fe ff ff       	call   8004d6 <printfmt>
  800671:	e9 b8 fe ff ff       	jmp    80052e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800679:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80067c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 04             	lea    0x4(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80068a:	85 f6                	test   %esi,%esi
  80068c:	b8 3c 27 80 00       	mov    $0x80273c,%eax
  800691:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800694:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800698:	0f 84 97 00 00 00    	je     800735 <vprintfmt+0x237>
  80069e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006a2:	0f 8e 9b 00 00 00    	jle    800743 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ac:	89 34 24             	mov    %esi,(%esp)
  8006af:	e8 c4 02 00 00       	call   800978 <strnlen>
  8006b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006b7:	29 c2                	sub    %eax,%edx
  8006b9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006bc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006cc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ce:	eb 0f                	jmp    8006df <vprintfmt+0x1e1>
					putch(padc, putdat);
  8006d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006d7:	89 04 24             	mov    %eax,(%esp)
  8006da:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dc:	83 eb 01             	sub    $0x1,%ebx
  8006df:	85 db                	test   %ebx,%ebx
  8006e1:	7f ed                	jg     8006d0 <vprintfmt+0x1d2>
  8006e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006e6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	0f 49 c2             	cmovns %edx,%eax
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006f8:	89 d7                	mov    %edx,%edi
  8006fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006fd:	eb 50                	jmp    80074f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800703:	74 1e                	je     800723 <vprintfmt+0x225>
  800705:	0f be d2             	movsbl %dl,%edx
  800708:	83 ea 20             	sub    $0x20,%edx
  80070b:	83 fa 5e             	cmp    $0x5e,%edx
  80070e:	76 13                	jbe    800723 <vprintfmt+0x225>
					putch('?', putdat);
  800710:	8b 45 0c             	mov    0xc(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80071e:	ff 55 08             	call   *0x8(%ebp)
  800721:	eb 0d                	jmp    800730 <vprintfmt+0x232>
					putch(ch, putdat);
  800723:	8b 55 0c             	mov    0xc(%ebp),%edx
  800726:	89 54 24 04          	mov    %edx,0x4(%esp)
  80072a:	89 04 24             	mov    %eax,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800730:	83 ef 01             	sub    $0x1,%edi
  800733:	eb 1a                	jmp    80074f <vprintfmt+0x251>
  800735:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800738:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80073b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80073e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800741:	eb 0c                	jmp    80074f <vprintfmt+0x251>
  800743:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800746:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800749:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80074c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80074f:	83 c6 01             	add    $0x1,%esi
  800752:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800756:	0f be c2             	movsbl %dl,%eax
  800759:	85 c0                	test   %eax,%eax
  80075b:	74 27                	je     800784 <vprintfmt+0x286>
  80075d:	85 db                	test   %ebx,%ebx
  80075f:	78 9e                	js     8006ff <vprintfmt+0x201>
  800761:	83 eb 01             	sub    $0x1,%ebx
  800764:	79 99                	jns    8006ff <vprintfmt+0x201>
  800766:	89 f8                	mov    %edi,%eax
  800768:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80076b:	8b 75 08             	mov    0x8(%ebp),%esi
  80076e:	89 c3                	mov    %eax,%ebx
  800770:	eb 1a                	jmp    80078c <vprintfmt+0x28e>
				putch(' ', putdat);
  800772:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800776:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80077d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80077f:	83 eb 01             	sub    $0x1,%ebx
  800782:	eb 08                	jmp    80078c <vprintfmt+0x28e>
  800784:	89 fb                	mov    %edi,%ebx
  800786:	8b 75 08             	mov    0x8(%ebp),%esi
  800789:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80078c:	85 db                	test   %ebx,%ebx
  80078e:	7f e2                	jg     800772 <vprintfmt+0x274>
  800790:	89 75 08             	mov    %esi,0x8(%ebp)
  800793:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800796:	e9 93 fd ff ff       	jmp    80052e <vprintfmt+0x30>
	if (lflag >= 2)
  80079b:	83 fa 01             	cmp    $0x1,%edx
  80079e:	7e 16                	jle    8007b6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 50 08             	lea    0x8(%eax),%edx
  8007a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a9:	8b 50 04             	mov    0x4(%eax),%edx
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007b4:	eb 32                	jmp    8007e8 <vprintfmt+0x2ea>
	else if (lflag)
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	74 18                	je     8007d2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 50 04             	lea    0x4(%eax),%edx
  8007c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c3:	8b 30                	mov    (%eax),%esi
  8007c5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007c8:	89 f0                	mov    %esi,%eax
  8007ca:	c1 f8 1f             	sar    $0x1f,%eax
  8007cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d0:	eb 16                	jmp    8007e8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007db:	8b 30                	mov    (%eax),%esi
  8007dd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	c1 f8 1f             	sar    $0x1f,%eax
  8007e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8007e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8007ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8007f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f7:	0f 89 80 00 00 00    	jns    80087d <vprintfmt+0x37f>
				putch('-', putdat);
  8007fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800801:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800808:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80080b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80080e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800811:	f7 d8                	neg    %eax
  800813:	83 d2 00             	adc    $0x0,%edx
  800816:	f7 da                	neg    %edx
			base = 10;
  800818:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80081d:	eb 5e                	jmp    80087d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
  800822:	e8 58 fc ff ff       	call   80047f <getuint>
			base = 10;
  800827:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80082c:	eb 4f                	jmp    80087d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80082e:	8d 45 14             	lea    0x14(%ebp),%eax
  800831:	e8 49 fc ff ff       	call   80047f <getuint>
            base = 8;
  800836:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80083b:	eb 40                	jmp    80087d <vprintfmt+0x37f>
			putch('0', putdat);
  80083d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800841:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800848:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80084b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800856:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8d 50 04             	lea    0x4(%eax),%edx
  80085f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800862:	8b 00                	mov    (%eax),%eax
  800864:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800869:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086e:	eb 0d                	jmp    80087d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800870:	8d 45 14             	lea    0x14(%ebp),%eax
  800873:	e8 07 fc ff ff       	call   80047f <getuint>
			base = 16;
  800878:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80087d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800881:	89 74 24 10          	mov    %esi,0x10(%esp)
  800885:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800888:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80088c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800890:	89 04 24             	mov    %eax,(%esp)
  800893:	89 54 24 04          	mov    %edx,0x4(%esp)
  800897:	89 fa                	mov    %edi,%edx
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	e8 ef fa ff ff       	call   800390 <printnum>
			break;
  8008a1:	e9 88 fc ff ff       	jmp    80052e <vprintfmt+0x30>
			putch(ch, putdat);
  8008a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008aa:	89 04 24             	mov    %eax,(%esp)
  8008ad:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008b0:	e9 79 fc ff ff       	jmp    80052e <vprintfmt+0x30>
			putch('%', putdat);
  8008b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c3:	89 f3                	mov    %esi,%ebx
  8008c5:	eb 03                	jmp    8008ca <vprintfmt+0x3cc>
  8008c7:	83 eb 01             	sub    $0x1,%ebx
  8008ca:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008ce:	75 f7                	jne    8008c7 <vprintfmt+0x3c9>
  8008d0:	e9 59 fc ff ff       	jmp    80052e <vprintfmt+0x30>
}
  8008d5:	83 c4 3c             	add    $0x3c,%esp
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5f                   	pop    %edi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	83 ec 28             	sub    $0x28,%esp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fa:	85 c0                	test   %eax,%eax
  8008fc:	74 30                	je     80092e <vsnprintf+0x51>
  8008fe:	85 d2                	test   %edx,%edx
  800900:	7e 2c                	jle    80092e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800909:	8b 45 10             	mov    0x10(%ebp),%eax
  80090c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800910:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800913:	89 44 24 04          	mov    %eax,0x4(%esp)
  800917:	c7 04 24 b9 04 80 00 	movl   $0x8004b9,(%esp)
  80091e:	e8 db fb ff ff       	call   8004fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800923:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800926:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092c:	eb 05                	jmp    800933 <vsnprintf+0x56>
		return -E_INVAL;
  80092e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80093b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800942:	8b 45 10             	mov    0x10(%ebp),%eax
  800945:	89 44 24 08          	mov    %eax,0x8(%esp)
  800949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	89 04 24             	mov    %eax,(%esp)
  800956:	e8 82 ff ff ff       	call   8008dd <vsnprintf>
	va_end(ap);

	return rc;
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    
  80095d:	66 90                	xchg   %ax,%ax
  80095f:	90                   	nop

00800960 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
  80096b:	eb 03                	jmp    800970 <strlen+0x10>
		n++;
  80096d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800970:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800974:	75 f7                	jne    80096d <strlen+0xd>
	return n;
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 03                	jmp    80098b <strnlen+0x13>
		n++;
  800988:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098b:	39 d0                	cmp    %edx,%eax
  80098d:	74 06                	je     800995 <strnlen+0x1d>
  80098f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800993:	75 f3                	jne    800988 <strnlen+0x10>
	return n;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	83 c2 01             	add    $0x1,%edx
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b0:	84 db                	test   %bl,%bl
  8009b2:	75 ef                	jne    8009a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c1:	89 1c 24             	mov    %ebx,(%esp)
  8009c4:	e8 97 ff ff ff       	call   800960 <strlen>
	strcpy(dst + len, src);
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d0:	01 d8                	add    %ebx,%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 bd ff ff ff       	call   800997 <strcpy>
	return dst;
}
  8009da:	89 d8                	mov    %ebx,%eax
  8009dc:	83 c4 08             	add    $0x8,%esp
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f2:	89 f2                	mov    %esi,%edx
  8009f4:	eb 0f                	jmp    800a05 <strncpy+0x23>
		*dst++ = *src;
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800a02:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a05:	39 da                	cmp    %ebx,%edx
  800a07:	75 ed                	jne    8009f6 <strncpy+0x14>
	}
	return ret;
}
  800a09:	89 f0                	mov    %esi,%eax
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 75 08             	mov    0x8(%ebp),%esi
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a1d:	89 f0                	mov    %esi,%eax
  800a1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a23:	85 c9                	test   %ecx,%ecx
  800a25:	75 0b                	jne    800a32 <strlcpy+0x23>
  800a27:	eb 1d                	jmp    800a46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	83 c2 01             	add    $0x1,%edx
  800a2f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a32:	39 d8                	cmp    %ebx,%eax
  800a34:	74 0b                	je     800a41 <strlcpy+0x32>
  800a36:	0f b6 0a             	movzbl (%edx),%ecx
  800a39:	84 c9                	test   %cl,%cl
  800a3b:	75 ec                	jne    800a29 <strlcpy+0x1a>
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	eb 02                	jmp    800a43 <strlcpy+0x34>
  800a41:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800a43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a46:	29 f0                	sub    %esi,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a55:	eb 06                	jmp    800a5d <strcmp+0x11>
		p++, q++;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a5d:	0f b6 01             	movzbl (%ecx),%eax
  800a60:	84 c0                	test   %al,%al
  800a62:	74 04                	je     800a68 <strcmp+0x1c>
  800a64:	3a 02                	cmp    (%edx),%al
  800a66:	74 ef                	je     800a57 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 c0             	movzbl %al,%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	53                   	push   %ebx
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 c3                	mov    %eax,%ebx
  800a7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a81:	eb 06                	jmp    800a89 <strncmp+0x17>
		n--, p++, q++;
  800a83:	83 c0 01             	add    $0x1,%eax
  800a86:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a89:	39 d8                	cmp    %ebx,%eax
  800a8b:	74 15                	je     800aa2 <strncmp+0x30>
  800a8d:	0f b6 08             	movzbl (%eax),%ecx
  800a90:	84 c9                	test   %cl,%cl
  800a92:	74 04                	je     800a98 <strncmp+0x26>
  800a94:	3a 0a                	cmp    (%edx),%cl
  800a96:	74 eb                	je     800a83 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a98:	0f b6 00             	movzbl (%eax),%eax
  800a9b:	0f b6 12             	movzbl (%edx),%edx
  800a9e:	29 d0                	sub    %edx,%eax
  800aa0:	eb 05                	jmp    800aa7 <strncmp+0x35>
		return 0;
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab4:	eb 07                	jmp    800abd <strchr+0x13>
		if (*s == c)
  800ab6:	38 ca                	cmp    %cl,%dl
  800ab8:	74 0f                	je     800ac9 <strchr+0x1f>
	for (; *s; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	75 f2                	jne    800ab6 <strchr+0xc>
			return (char *) s;
	return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad5:	eb 07                	jmp    800ade <strfind+0x13>
		if (*s == c)
  800ad7:	38 ca                	cmp    %cl,%dl
  800ad9:	74 0a                	je     800ae5 <strfind+0x1a>
	for (; *s; s++)
  800adb:	83 c0 01             	add    $0x1,%eax
  800ade:	0f b6 10             	movzbl (%eax),%edx
  800ae1:	84 d2                	test   %dl,%dl
  800ae3:	75 f2                	jne    800ad7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af3:	85 c9                	test   %ecx,%ecx
  800af5:	74 36                	je     800b2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afd:	75 28                	jne    800b27 <memset+0x40>
  800aff:	f6 c1 03             	test   $0x3,%cl
  800b02:	75 23                	jne    800b27 <memset+0x40>
		c &= 0xFF;
  800b04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	c1 e3 08             	shl    $0x8,%ebx
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	c1 e6 18             	shl    $0x18,%esi
  800b12:	89 d0                	mov    %edx,%eax
  800b14:	c1 e0 10             	shl    $0x10,%eax
  800b17:	09 f0                	or     %esi,%eax
  800b19:	09 c2                	or     %eax,%edx
  800b1b:	89 d0                	mov    %edx,%eax
  800b1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b22:	fc                   	cld    
  800b23:	f3 ab                	rep stos %eax,%es:(%edi)
  800b25:	eb 06                	jmp    800b2d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	fc                   	cld    
  800b2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2d:	89 f8                	mov    %edi,%eax
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b42:	39 c6                	cmp    %eax,%esi
  800b44:	73 35                	jae    800b7b <memmove+0x47>
  800b46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b49:	39 d0                	cmp    %edx,%eax
  800b4b:	73 2e                	jae    800b7b <memmove+0x47>
		s += n;
		d += n;
  800b4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5a:	75 13                	jne    800b6f <memmove+0x3b>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	75 0e                	jne    800b6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b61:	83 ef 04             	sub    $0x4,%edi
  800b64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b6a:	fd                   	std    
  800b6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6d:	eb 09                	jmp    800b78 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b6f:	83 ef 01             	sub    $0x1,%edi
  800b72:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b75:	fd                   	std    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b78:	fc                   	cld    
  800b79:	eb 1d                	jmp    800b98 <memmove+0x64>
  800b7b:	89 f2                	mov    %esi,%edx
  800b7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7f:	f6 c2 03             	test   $0x3,%dl
  800b82:	75 0f                	jne    800b93 <memmove+0x5f>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	75 0a                	jne    800b93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b89:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b8c:	89 c7                	mov    %eax,%edi
  800b8e:	fc                   	cld    
  800b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b91:	eb 05                	jmp    800b98 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	fc                   	cld    
  800b96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	89 04 24             	mov    %eax,(%esp)
  800bb6:	e8 79 ff ff ff       	call   800b34 <memmove>
}
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcd:	eb 1a                	jmp    800be9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bcf:	0f b6 02             	movzbl (%edx),%eax
  800bd2:	0f b6 19             	movzbl (%ecx),%ebx
  800bd5:	38 d8                	cmp    %bl,%al
  800bd7:	74 0a                	je     800be3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd9:	0f b6 c0             	movzbl %al,%eax
  800bdc:	0f b6 db             	movzbl %bl,%ebx
  800bdf:	29 d8                	sub    %ebx,%eax
  800be1:	eb 0f                	jmp    800bf2 <memcmp+0x35>
		s1++, s2++;
  800be3:	83 c2 01             	add    $0x1,%edx
  800be6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800be9:	39 f2                	cmp    %esi,%edx
  800beb:	75 e2                	jne    800bcf <memcmp+0x12>
	}

	return 0;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bff:	89 c2                	mov    %eax,%edx
  800c01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c04:	eb 07                	jmp    800c0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c06:	38 08                	cmp    %cl,(%eax)
  800c08:	74 07                	je     800c11 <memfind+0x1b>
	for (; s < ends; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	39 d0                	cmp    %edx,%eax
  800c0f:	72 f5                	jb     800c06 <memfind+0x10>
			break;
	return (void *) s;
}
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1f:	eb 03                	jmp    800c24 <strtol+0x11>
		s++;
  800c21:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c24:	0f b6 0a             	movzbl (%edx),%ecx
  800c27:	80 f9 09             	cmp    $0x9,%cl
  800c2a:	74 f5                	je     800c21 <strtol+0xe>
  800c2c:	80 f9 20             	cmp    $0x20,%cl
  800c2f:	74 f0                	je     800c21 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c31:	80 f9 2b             	cmp    $0x2b,%cl
  800c34:	75 0a                	jne    800c40 <strtol+0x2d>
		s++;
  800c36:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c39:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3e:	eb 11                	jmp    800c51 <strtol+0x3e>
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800c45:	80 f9 2d             	cmp    $0x2d,%cl
  800c48:	75 07                	jne    800c51 <strtol+0x3e>
		s++, neg = 1;
  800c4a:	8d 52 01             	lea    0x1(%edx),%edx
  800c4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c56:	75 15                	jne    800c6d <strtol+0x5a>
  800c58:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5b:	75 10                	jne    800c6d <strtol+0x5a>
  800c5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c61:	75 0a                	jne    800c6d <strtol+0x5a>
		s += 2, base = 16;
  800c63:	83 c2 02             	add    $0x2,%edx
  800c66:	b8 10 00 00 00       	mov    $0x10,%eax
  800c6b:	eb 10                	jmp    800c7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	75 0c                	jne    800c7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c71:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c73:	80 3a 30             	cmpb   $0x30,(%edx)
  800c76:	75 05                	jne    800c7d <strtol+0x6a>
		s++, base = 8;
  800c78:	83 c2 01             	add    $0x1,%edx
  800c7b:	b0 08                	mov    $0x8,%al
		base = 10;
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c85:	0f b6 0a             	movzbl (%edx),%ecx
  800c88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c8b:	89 f0                	mov    %esi,%eax
  800c8d:	3c 09                	cmp    $0x9,%al
  800c8f:	77 08                	ja     800c99 <strtol+0x86>
			dig = *s - '0';
  800c91:	0f be c9             	movsbl %cl,%ecx
  800c94:	83 e9 30             	sub    $0x30,%ecx
  800c97:	eb 20                	jmp    800cb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c9c:	89 f0                	mov    %esi,%eax
  800c9e:	3c 19                	cmp    $0x19,%al
  800ca0:	77 08                	ja     800caa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ca2:	0f be c9             	movsbl %cl,%ecx
  800ca5:	83 e9 57             	sub    $0x57,%ecx
  800ca8:	eb 0f                	jmp    800cb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800caa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cad:	89 f0                	mov    %esi,%eax
  800caf:	3c 19                	cmp    $0x19,%al
  800cb1:	77 16                	ja     800cc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800cb3:	0f be c9             	movsbl %cl,%ecx
  800cb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cbc:	7d 0f                	jge    800ccd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cbe:	83 c2 01             	add    $0x1,%edx
  800cc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800cc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800cc7:	eb bc                	jmp    800c85 <strtol+0x72>
  800cc9:	89 d8                	mov    %ebx,%eax
  800ccb:	eb 02                	jmp    800ccf <strtol+0xbc>
  800ccd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ccf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd3:	74 05                	je     800cda <strtol+0xc7>
		*endptr = (char *) s;
  800cd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cda:	f7 d8                	neg    %eax
  800cdc:	85 ff                	test   %edi,%edi
  800cde:	0f 44 c3             	cmove  %ebx,%eax
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 c3                	mov    %eax,%ebx
  800cf9:	89 c7                	mov    %eax,%edi
  800cfb:	89 c6                	mov    %eax,%esi
  800cfd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	89 d3                	mov    %edx,%ebx
  800d18:	89 d7                	mov    %edx,%edi
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d31:	b8 03 00 00 00       	mov    $0x3,%eax
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 cb                	mov    %ecx,%ebx
  800d3b:	89 cf                	mov    %ecx,%edi
  800d3d:	89 ce                	mov    %ecx,%esi
  800d3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 28                	jle    800d6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d50:	00 
  800d51:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800d58:	00 
  800d59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d60:	00 
  800d61:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800d68:	e8 0d f5 ff ff       	call   80027a <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6d:	83 c4 2c             	add    $0x2c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 02 00 00 00       	mov    $0x2,%eax
  800d85:	89 d1                	mov    %edx,%ecx
  800d87:	89 d3                	mov    %edx,%ebx
  800d89:	89 d7                	mov    %edx,%edi
  800d8b:	89 d6                	mov    %edx,%esi
  800d8d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_yield>:

void
sys_yield(void)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da4:	89 d1                	mov    %edx,%ecx
  800da6:	89 d3                	mov    %edx,%ebx
  800da8:	89 d7                	mov    %edx,%edi
  800daa:	89 d6                	mov    %edx,%esi
  800dac:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dbc:	be 00 00 00 00       	mov    $0x0,%esi
  800dc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	89 f7                	mov    %esi,%edi
  800dd1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 28                	jle    800dff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de2:	00 
  800de3:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800dea:	00 
  800deb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df2:	00 
  800df3:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800dfa:	e8 7b f4 ff ff       	call   80027a <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dff:	83 c4 2c             	add    $0x2c,%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e10:	b8 05 00 00 00       	mov    $0x5,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e21:	8b 75 18             	mov    0x18(%ebp),%esi
  800e24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800e4d:	e8 28 f4 ff ff       	call   80027a <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e52:	83 c4 2c             	add    $0x2c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	b8 06 00 00 00       	mov    $0x6,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 df                	mov    %ebx,%edi
  800e75:	89 de                	mov    %ebx,%esi
  800e77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 28                	jle    800ea5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800ea0:	e8 d5 f3 ff ff       	call   80027a <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ea5:	83 c4 2c             	add    $0x2c,%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 df                	mov    %ebx,%edi
  800ec8:	89 de                	mov    %ebx,%esi
  800eca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 28                	jle    800ef8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800edb:	00 
  800edc:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eeb:	00 
  800eec:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800ef3:	e8 82 f3 ff ff       	call   80027a <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef8:	83 c4 2c             	add    $0x2c,%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
  800f19:	89 df                	mov    %ebx,%edi
  800f1b:	89 de                	mov    %ebx,%esi
  800f1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	7e 28                	jle    800f4b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f27:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800f46:	e8 2f f3 ff ff       	call   80027a <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f4b:	83 c4 2c             	add    $0x2c,%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	89 df                	mov    %ebx,%edi
  800f6e:	89 de                	mov    %ebx,%esi
  800f70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	7e 28                	jle    800f9e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f81:	00 
  800f82:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800f99:	e8 dc f2 ff ff       	call   80027a <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f9e:	83 c4 2c             	add    $0x2c,%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fac:	be 00 00 00 00       	mov    $0x0,%esi
  800fb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdf:	89 cb                	mov    %ecx,%ebx
  800fe1:	89 cf                	mov    %ecx,%edi
  800fe3:	89 ce                	mov    %ecx,%esi
  800fe5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	7e 28                	jle    801013 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800feb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  80100e:	e8 67 f2 ff ff       	call   80027a <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801013:	83 c4 2c             	add    $0x2c,%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    
  80101b:	66 90                	xchg   %ax,%ax
  80101d:	66 90                	xchg   %ax,%ax
  80101f:	90                   	nop

00801020 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	53                   	push   %ebx
  801024:	83 ec 24             	sub    $0x24,%esp
  801027:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  80102a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  80102c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801030:	74 18                	je     80104a <pgfault+0x2a>
  801032:	89 d8                	mov    %ebx,%eax
  801034:	c1 e8 0c             	shr    $0xc,%eax
  801037:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103e:	25 05 08 00 00       	and    $0x805,%eax
  801043:	3d 05 08 00 00       	cmp    $0x805,%eax
  801048:	74 1c                	je     801066 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  80104a:	c7 44 24 08 4c 2a 80 	movl   $0x802a4c,0x8(%esp)
  801051:	00 
  801052:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801059:	00 
  80105a:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  801061:	e8 14 f2 ff ff       	call   80027a <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  801066:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80106d:	00 
  80106e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801075:	00 
  801076:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107d:	e8 31 fd ff ff       	call   800db3 <sys_page_alloc>
	if(r < 0){
  801082:	85 c0                	test   %eax,%eax
  801084:	79 1c                	jns    8010a2 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  801086:	c7 44 24 08 7c 2a 80 	movl   $0x802a7c,0x8(%esp)
  80108d:	00 
  80108e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801095:	00 
  801096:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  80109d:	e8 d8 f1 ff ff       	call   80027a <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8010a2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8010a8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010af:	00 
  8010b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010b4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010bb:	e8 dc fa ff ff       	call   800b9c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  8010c0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010c7:	00 
  8010c8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010db:	00 
  8010dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e3:	e8 1f fd ff ff       	call   800e07 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	79 1c                	jns    801108 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  8010ec:	c7 44 24 08 48 2b 80 	movl   $0x802b48,0x8(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8010fb:	00 
  8010fc:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  801103:	e8 72 f1 ff ff       	call   80027a <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  801108:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80110f:	00 
  801110:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801117:	e8 3e fd ff ff       	call   800e5a <sys_page_unmap>
    if(r < 0){
  80111c:	85 c0                	test   %eax,%eax
  80111e:	79 1c                	jns    80113c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  801120:	c7 44 24 08 5f 2b 80 	movl   $0x802b5f,0x8(%esp)
  801127:	00 
  801128:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80112f:	00 
  801130:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  801137:	e8 3e f1 ff ff       	call   80027a <_panic>
    }
    // LAB 4
}
  80113c:	83 c4 24             	add    $0x24,%esp
  80113f:	5b                   	pop    %ebx
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  80114b:	c7 04 24 20 10 80 00 	movl   $0x801020,(%esp)
  801152:	e8 bf 0f 00 00       	call   802116 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801157:	b8 07 00 00 00       	mov    $0x7,%eax
  80115c:	cd 30                	int    $0x30
  80115e:	89 c7                	mov    %eax,%edi
  801160:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801163:	85 c0                	test   %eax,%eax
  801165:	79 1c                	jns    801183 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801167:	c7 44 24 08 78 2b 80 	movl   $0x802b78,0x8(%esp)
  80116e:	00 
  80116f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801176:	00 
  801177:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  80117e:	e8 f7 f0 ff ff       	call   80027a <_panic>
    }
    if(child == 0){
  801183:	bb 00 00 00 00       	mov    $0x0,%ebx
  801188:	85 c0                	test   %eax,%eax
  80118a:	75 21                	jne    8011ad <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80118c:	e8 e4 fb ff ff       	call   800d75 <sys_getenvid>
  801191:	25 ff 03 00 00       	and    $0x3ff,%eax
  801196:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801199:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80119e:	a3 20 44 80 00       	mov    %eax,0x804420
        // It's a whole lot like lab3 with the env stuff
        return 0;
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a8:	e9 67 01 00 00       	jmp    801314 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  8011ad:	89 d8                	mov    %ebx,%eax
  8011af:	c1 e8 16             	shr    $0x16,%eax
  8011b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b9:	a8 01                	test   $0x1,%al
  8011bb:	74 4b                	je     801208 <fork+0xc6>
  8011bd:	89 de                	mov    %ebx,%esi
  8011bf:	c1 ee 0c             	shr    $0xc,%esi
  8011c2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c9:	a8 01                	test   $0x1,%al
  8011cb:	74 3b                	je     801208 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  8011cd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011d4:	a9 02 08 00 00       	test   $0x802,%eax
  8011d9:	0f 85 02 01 00 00    	jne    8012e1 <fork+0x19f>
  8011df:	e9 d2 00 00 00       	jmp    8012b6 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  8011e4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011eb:	00 
  8011ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011f7:	00 
  8011f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801203:	e8 ff fb ff ff       	call   800e07 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801208:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80120e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801214:	75 97                	jne    8011ad <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801216:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801225:	ee 
  801226:	89 3c 24             	mov    %edi,(%esp)
  801229:	e8 85 fb ff ff       	call   800db3 <sys_page_alloc>

    if(r < 0){
  80122e:	85 c0                	test   %eax,%eax
  801230:	79 1c                	jns    80124e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801232:	c7 44 24 08 b0 2a 80 	movl   $0x802ab0,0x8(%esp)
  801239:	00 
  80123a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801241:	00 
  801242:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  801249:	e8 2c f0 ff ff       	call   80027a <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80124e:	a1 20 44 80 00       	mov    0x804420,%eax
  801253:	8b 40 64             	mov    0x64(%eax),%eax
  801256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125a:	89 3c 24             	mov    %edi,(%esp)
  80125d:	e8 f1 fc ff ff       	call   800f53 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801262:	85 c0                	test   %eax,%eax
  801264:	79 1c                	jns    801282 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801266:	c7 44 24 08 d0 2a 80 	movl   $0x802ad0,0x8(%esp)
  80126d:	00 
  80126e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801275:	00 
  801276:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  80127d:	e8 f8 ef ff ff       	call   80027a <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801282:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801289:	00 
  80128a:	89 3c 24             	mov    %edi,(%esp)
  80128d:	e8 1b fc ff ff       	call   800ead <sys_env_set_status>
    if(r < 0){
  801292:	85 c0                	test   %eax,%eax
  801294:	79 1c                	jns    8012b2 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801296:	c7 44 24 08 f8 2a 80 	movl   $0x802af8,0x8(%esp)
  80129d:	00 
  80129e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  8012a5:	00 
  8012a6:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  8012ad:	e8 c8 ef ff ff       	call   80027a <_panic>
    }
    return child;
  8012b2:	89 f8                	mov    %edi,%eax
  8012b4:	eb 5e                	jmp    801314 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  8012b6:	c1 e6 0c             	shl    $0xc,%esi
  8012b9:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012c0:	00 
  8012c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d7:	e8 2b fb ff ff       	call   800e07 <sys_page_map>
  8012dc:	e9 27 ff ff ff       	jmp    801208 <fork+0xc6>
  8012e1:	c1 e6 0c             	shl    $0xc,%esi
  8012e4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012eb:	00 
  8012ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801302:	e8 00 fb ff ff       	call   800e07 <sys_page_map>
    if( r < 0 ){
  801307:	85 c0                	test   %eax,%eax
  801309:	0f 89 d5 fe ff ff    	jns    8011e4 <fork+0xa2>
  80130f:	e9 f4 fe ff ff       	jmp    801208 <fork+0xc6>
//	panic("fork not implemented");
}
  801314:	83 c4 2c             	add    $0x2c,%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5f                   	pop    %edi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <sfork>:

// Challenge!
int
sfork(void)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801322:	c7 44 24 08 95 2b 80 	movl   $0x802b95,0x8(%esp)
  801329:	00 
  80132a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801331:	00 
  801332:	c7 04 24 3d 2b 80 00 	movl   $0x802b3d,(%esp)
  801339:	e8 3c ef ff ff       	call   80027a <_panic>
  80133e:	66 90                	xchg   %ax,%ax

00801340 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
  801346:	05 00 00 00 30       	add    $0x30000000,%eax
  80134b:	c1 e8 0c             	shr    $0xc,%eax
}
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801353:	8b 45 08             	mov    0x8(%ebp),%eax
  801356:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80135b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801360:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801372:	89 c2                	mov    %eax,%edx
  801374:	c1 ea 16             	shr    $0x16,%edx
  801377:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80137e:	f6 c2 01             	test   $0x1,%dl
  801381:	74 11                	je     801394 <fd_alloc+0x2d>
  801383:	89 c2                	mov    %eax,%edx
  801385:	c1 ea 0c             	shr    $0xc,%edx
  801388:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80138f:	f6 c2 01             	test   $0x1,%dl
  801392:	75 09                	jne    80139d <fd_alloc+0x36>
			*fd_store = fd;
  801394:	89 01                	mov    %eax,(%ecx)
			return 0;
  801396:	b8 00 00 00 00       	mov    $0x0,%eax
  80139b:	eb 17                	jmp    8013b4 <fd_alloc+0x4d>
  80139d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013a7:	75 c9                	jne    801372 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8013a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013bc:	83 f8 1f             	cmp    $0x1f,%eax
  8013bf:	77 36                	ja     8013f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013c1:	c1 e0 0c             	shl    $0xc,%eax
  8013c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	c1 ea 16             	shr    $0x16,%edx
  8013ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013d5:	f6 c2 01             	test   $0x1,%dl
  8013d8:	74 24                	je     8013fe <fd_lookup+0x48>
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	c1 ea 0c             	shr    $0xc,%edx
  8013df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e6:	f6 c2 01             	test   $0x1,%dl
  8013e9:	74 1a                	je     801405 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8013f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f5:	eb 13                	jmp    80140a <fd_lookup+0x54>
		return -E_INVAL;
  8013f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fc:	eb 0c                	jmp    80140a <fd_lookup+0x54>
		return -E_INVAL;
  8013fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801403:	eb 05                	jmp    80140a <fd_lookup+0x54>
  801405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 18             	sub    $0x18,%esp
  801412:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801415:	ba 28 2c 80 00       	mov    $0x802c28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80141a:	eb 13                	jmp    80142f <dev_lookup+0x23>
  80141c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80141f:	39 08                	cmp    %ecx,(%eax)
  801421:	75 0c                	jne    80142f <dev_lookup+0x23>
			*dev = devtab[i];
  801423:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801426:	89 01                	mov    %eax,(%ecx)
			return 0;
  801428:	b8 00 00 00 00       	mov    $0x0,%eax
  80142d:	eb 30                	jmp    80145f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80142f:	8b 02                	mov    (%edx),%eax
  801431:	85 c0                	test   %eax,%eax
  801433:	75 e7                	jne    80141c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801435:	a1 20 44 80 00       	mov    0x804420,%eax
  80143a:	8b 40 48             	mov    0x48(%eax),%eax
  80143d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801441:	89 44 24 04          	mov    %eax,0x4(%esp)
  801445:	c7 04 24 ac 2b 80 00 	movl   $0x802bac,(%esp)
  80144c:	e8 22 ef ff ff       	call   800373 <cprintf>
	*dev = 0;
  801451:	8b 45 0c             	mov    0xc(%ebp),%eax
  801454:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80145a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <fd_close>:
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	56                   	push   %esi
  801465:	53                   	push   %ebx
  801466:	83 ec 20             	sub    $0x20,%esp
  801469:	8b 75 08             	mov    0x8(%ebp),%esi
  80146c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80146f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801472:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801476:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80147c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80147f:	89 04 24             	mov    %eax,(%esp)
  801482:	e8 2f ff ff ff       	call   8013b6 <fd_lookup>
  801487:	85 c0                	test   %eax,%eax
  801489:	78 05                	js     801490 <fd_close+0x2f>
	    || fd != fd2)
  80148b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80148e:	74 0c                	je     80149c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801490:	84 db                	test   %bl,%bl
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	0f 44 c2             	cmove  %edx,%eax
  80149a:	eb 3f                	jmp    8014db <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80149c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a3:	8b 06                	mov    (%esi),%eax
  8014a5:	89 04 24             	mov    %eax,(%esp)
  8014a8:	e8 5f ff ff ff       	call   80140c <dev_lookup>
  8014ad:	89 c3                	mov    %eax,%ebx
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	78 16                	js     8014c9 <fd_close+0x68>
		if (dev->dev_close)
  8014b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	74 07                	je     8014c9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8014c2:	89 34 24             	mov    %esi,(%esp)
  8014c5:	ff d0                	call   *%eax
  8014c7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8014c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d4:	e8 81 f9 ff ff       	call   800e5a <sys_page_unmap>
	return r;
  8014d9:	89 d8                	mov    %ebx,%eax
}
  8014db:	83 c4 20             	add    $0x20,%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5e                   	pop    %esi
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <close>:

int
close(int fdnum)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f2:	89 04 24             	mov    %eax,(%esp)
  8014f5:	e8 bc fe ff ff       	call   8013b6 <fd_lookup>
  8014fa:	89 c2                	mov    %eax,%edx
  8014fc:	85 d2                	test   %edx,%edx
  8014fe:	78 13                	js     801513 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801500:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801507:	00 
  801508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150b:	89 04 24             	mov    %eax,(%esp)
  80150e:	e8 4e ff ff ff       	call   801461 <fd_close>
}
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <close_all>:

void
close_all(void)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80151c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801521:	89 1c 24             	mov    %ebx,(%esp)
  801524:	e8 b9 ff ff ff       	call   8014e2 <close>
	for (i = 0; i < MAXFD; i++)
  801529:	83 c3 01             	add    $0x1,%ebx
  80152c:	83 fb 20             	cmp    $0x20,%ebx
  80152f:	75 f0                	jne    801521 <close_all+0xc>
}
  801531:	83 c4 14             	add    $0x14,%esp
  801534:	5b                   	pop    %ebx
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	57                   	push   %edi
  80153b:	56                   	push   %esi
  80153c:	53                   	push   %ebx
  80153d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801540:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801543:	89 44 24 04          	mov    %eax,0x4(%esp)
  801547:	8b 45 08             	mov    0x8(%ebp),%eax
  80154a:	89 04 24             	mov    %eax,(%esp)
  80154d:	e8 64 fe ff ff       	call   8013b6 <fd_lookup>
  801552:	89 c2                	mov    %eax,%edx
  801554:	85 d2                	test   %edx,%edx
  801556:	0f 88 e1 00 00 00    	js     80163d <dup+0x106>
		return r;
	close(newfdnum);
  80155c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155f:	89 04 24             	mov    %eax,(%esp)
  801562:	e8 7b ff ff ff       	call   8014e2 <close>

	newfd = INDEX2FD(newfdnum);
  801567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80156a:	c1 e3 0c             	shl    $0xc,%ebx
  80156d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 d2 fd ff ff       	call   801350 <fd2data>
  80157e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801580:	89 1c 24             	mov    %ebx,(%esp)
  801583:	e8 c8 fd ff ff       	call   801350 <fd2data>
  801588:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80158a:	89 f0                	mov    %esi,%eax
  80158c:	c1 e8 16             	shr    $0x16,%eax
  80158f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801596:	a8 01                	test   $0x1,%al
  801598:	74 43                	je     8015dd <dup+0xa6>
  80159a:	89 f0                	mov    %esi,%eax
  80159c:	c1 e8 0c             	shr    $0xc,%eax
  80159f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015a6:	f6 c2 01             	test   $0x1,%dl
  8015a9:	74 32                	je     8015dd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015c6:	00 
  8015c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d2:	e8 30 f8 ff ff       	call   800e07 <sys_page_map>
  8015d7:	89 c6                	mov    %eax,%esi
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 3e                	js     80161b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	c1 ea 0c             	shr    $0xc,%edx
  8015e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015f2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015f6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801601:	00 
  801602:	89 44 24 04          	mov    %eax,0x4(%esp)
  801606:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160d:	e8 f5 f7 ff ff       	call   800e07 <sys_page_map>
  801612:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801614:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801617:	85 f6                	test   %esi,%esi
  801619:	79 22                	jns    80163d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80161b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80161f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801626:	e8 2f f8 ff ff       	call   800e5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80162b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80162f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801636:	e8 1f f8 ff ff       	call   800e5a <sys_page_unmap>
	return r;
  80163b:	89 f0                	mov    %esi,%eax
}
  80163d:	83 c4 3c             	add    $0x3c,%esp
  801640:	5b                   	pop    %ebx
  801641:	5e                   	pop    %esi
  801642:	5f                   	pop    %edi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	53                   	push   %ebx
  801649:	83 ec 24             	sub    $0x24,%esp
  80164c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801652:	89 44 24 04          	mov    %eax,0x4(%esp)
  801656:	89 1c 24             	mov    %ebx,(%esp)
  801659:	e8 58 fd ff ff       	call   8013b6 <fd_lookup>
  80165e:	89 c2                	mov    %eax,%edx
  801660:	85 d2                	test   %edx,%edx
  801662:	78 6d                	js     8016d1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	8b 00                	mov    (%eax),%eax
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	e8 94 fd ff ff       	call   80140c <dev_lookup>
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 55                	js     8016d1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80167c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167f:	8b 50 08             	mov    0x8(%eax),%edx
  801682:	83 e2 03             	and    $0x3,%edx
  801685:	83 fa 01             	cmp    $0x1,%edx
  801688:	75 23                	jne    8016ad <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80168a:	a1 20 44 80 00       	mov    0x804420,%eax
  80168f:	8b 40 48             	mov    0x48(%eax),%eax
  801692:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169a:	c7 04 24 ed 2b 80 00 	movl   $0x802bed,(%esp)
  8016a1:	e8 cd ec ff ff       	call   800373 <cprintf>
		return -E_INVAL;
  8016a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ab:	eb 24                	jmp    8016d1 <read+0x8c>
	}
	if (!dev->dev_read)
  8016ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b0:	8b 52 08             	mov    0x8(%edx),%edx
  8016b3:	85 d2                	test   %edx,%edx
  8016b5:	74 15                	je     8016cc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	ff d2                	call   *%edx
  8016ca:	eb 05                	jmp    8016d1 <read+0x8c>
		return -E_NOT_SUPP;
  8016cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016d1:	83 c4 24             	add    $0x24,%esp
  8016d4:	5b                   	pop    %ebx
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	57                   	push   %edi
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 1c             	sub    $0x1c,%esp
  8016e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016eb:	eb 23                	jmp    801710 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016ed:	89 f0                	mov    %esi,%eax
  8016ef:	29 d8                	sub    %ebx,%eax
  8016f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f5:	89 d8                	mov    %ebx,%eax
  8016f7:	03 45 0c             	add    0xc(%ebp),%eax
  8016fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fe:	89 3c 24             	mov    %edi,(%esp)
  801701:	e8 3f ff ff ff       	call   801645 <read>
		if (m < 0)
  801706:	85 c0                	test   %eax,%eax
  801708:	78 10                	js     80171a <readn+0x43>
			return m;
		if (m == 0)
  80170a:	85 c0                	test   %eax,%eax
  80170c:	74 0a                	je     801718 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80170e:	01 c3                	add    %eax,%ebx
  801710:	39 f3                	cmp    %esi,%ebx
  801712:	72 d9                	jb     8016ed <readn+0x16>
  801714:	89 d8                	mov    %ebx,%eax
  801716:	eb 02                	jmp    80171a <readn+0x43>
  801718:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80171a:	83 c4 1c             	add    $0x1c,%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5e                   	pop    %esi
  80171f:	5f                   	pop    %edi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	83 ec 24             	sub    $0x24,%esp
  801729:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801733:	89 1c 24             	mov    %ebx,(%esp)
  801736:	e8 7b fc ff ff       	call   8013b6 <fd_lookup>
  80173b:	89 c2                	mov    %eax,%edx
  80173d:	85 d2                	test   %edx,%edx
  80173f:	78 68                	js     8017a9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801744:	89 44 24 04          	mov    %eax,0x4(%esp)
  801748:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174b:	8b 00                	mov    (%eax),%eax
  80174d:	89 04 24             	mov    %eax,(%esp)
  801750:	e8 b7 fc ff ff       	call   80140c <dev_lookup>
  801755:	85 c0                	test   %eax,%eax
  801757:	78 50                	js     8017a9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801759:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801760:	75 23                	jne    801785 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801762:	a1 20 44 80 00       	mov    0x804420,%eax
  801767:	8b 40 48             	mov    0x48(%eax),%eax
  80176a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80176e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801772:	c7 04 24 09 2c 80 00 	movl   $0x802c09,(%esp)
  801779:	e8 f5 eb ff ff       	call   800373 <cprintf>
		return -E_INVAL;
  80177e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801783:	eb 24                	jmp    8017a9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801785:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801788:	8b 52 0c             	mov    0xc(%edx),%edx
  80178b:	85 d2                	test   %edx,%edx
  80178d:	74 15                	je     8017a4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80178f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801792:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801799:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80179d:	89 04 24             	mov    %eax,(%esp)
  8017a0:	ff d2                	call   *%edx
  8017a2:	eb 05                	jmp    8017a9 <write+0x87>
		return -E_NOT_SUPP;
  8017a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017a9:	83 c4 24             	add    $0x24,%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <seek>:

int
seek(int fdnum, off_t offset)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	89 04 24             	mov    %eax,(%esp)
  8017c2:	e8 ef fb ff ff       	call   8013b6 <fd_lookup>
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 0e                	js     8017d9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	53                   	push   %ebx
  8017df:	83 ec 24             	sub    $0x24,%esp
  8017e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ec:	89 1c 24             	mov    %ebx,(%esp)
  8017ef:	e8 c2 fb ff ff       	call   8013b6 <fd_lookup>
  8017f4:	89 c2                	mov    %eax,%edx
  8017f6:	85 d2                	test   %edx,%edx
  8017f8:	78 61                	js     80185b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801804:	8b 00                	mov    (%eax),%eax
  801806:	89 04 24             	mov    %eax,(%esp)
  801809:	e8 fe fb ff ff       	call   80140c <dev_lookup>
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 49                	js     80185b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801819:	75 23                	jne    80183e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80181b:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801820:	8b 40 48             	mov    0x48(%eax),%eax
  801823:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182b:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  801832:	e8 3c eb ff ff       	call   800373 <cprintf>
		return -E_INVAL;
  801837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183c:	eb 1d                	jmp    80185b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80183e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801841:	8b 52 18             	mov    0x18(%edx),%edx
  801844:	85 d2                	test   %edx,%edx
  801846:	74 0e                	je     801856 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80184f:	89 04 24             	mov    %eax,(%esp)
  801852:	ff d2                	call   *%edx
  801854:	eb 05                	jmp    80185b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801856:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80185b:	83 c4 24             	add    $0x24,%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5d                   	pop    %ebp
  801860:	c3                   	ret    

00801861 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	53                   	push   %ebx
  801865:	83 ec 24             	sub    $0x24,%esp
  801868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801872:	8b 45 08             	mov    0x8(%ebp),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 39 fb ff ff       	call   8013b6 <fd_lookup>
  80187d:	89 c2                	mov    %eax,%edx
  80187f:	85 d2                	test   %edx,%edx
  801881:	78 52                	js     8018d5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801883:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801886:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188d:	8b 00                	mov    (%eax),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 75 fb ff ff       	call   80140c <dev_lookup>
  801897:	85 c0                	test   %eax,%eax
  801899:	78 3a                	js     8018d5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80189b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a2:	74 2c                	je     8018d0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ae:	00 00 00 
	stat->st_isdir = 0;
  8018b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b8:	00 00 00 
	stat->st_dev = dev;
  8018bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018c8:	89 14 24             	mov    %edx,(%esp)
  8018cb:	ff 50 14             	call   *0x14(%eax)
  8018ce:	eb 05                	jmp    8018d5 <fstat+0x74>
		return -E_NOT_SUPP;
  8018d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018d5:	83 c4 24             	add    $0x24,%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	56                   	push   %esi
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ea:	00 
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	e8 fb 01 00 00       	call   801af1 <open>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	85 db                	test   %ebx,%ebx
  8018fa:	78 1b                	js     801917 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8018fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801903:	89 1c 24             	mov    %ebx,(%esp)
  801906:	e8 56 ff ff ff       	call   801861 <fstat>
  80190b:	89 c6                	mov    %eax,%esi
	close(fd);
  80190d:	89 1c 24             	mov    %ebx,(%esp)
  801910:	e8 cd fb ff ff       	call   8014e2 <close>
	return r;
  801915:	89 f0                	mov    %esi,%eax
}
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	56                   	push   %esi
  801922:	53                   	push   %ebx
  801923:	83 ec 10             	sub    $0x10,%esp
  801926:	89 c6                	mov    %eax,%esi
  801928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80192a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801931:	75 11                	jne    801944 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801933:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80193a:	e8 60 09 00 00       	call   80229f <ipc_find_env>
  80193f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801944:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80194b:	00 
  80194c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801953:	00 
  801954:	89 74 24 04          	mov    %esi,0x4(%esp)
  801958:	a1 04 40 80 00       	mov    0x804004,%eax
  80195d:	89 04 24             	mov    %eax,(%esp)
  801960:	e8 d3 08 00 00       	call   802238 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801965:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80196c:	00 
  80196d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801971:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801978:	e8 53 08 00 00       	call   8021d0 <ipc_recv>
}
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	5b                   	pop    %ebx
  801981:	5e                   	pop    %esi
  801982:	5d                   	pop    %ebp
  801983:	c3                   	ret    

00801984 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80198a:	8b 45 08             	mov    0x8(%ebp),%eax
  80198d:	8b 40 0c             	mov    0xc(%eax),%eax
  801990:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801995:	8b 45 0c             	mov    0xc(%ebp),%eax
  801998:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80199d:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8019a7:	e8 72 ff ff ff       	call   80191e <fsipc>
}
  8019ac:	c9                   	leave  
  8019ad:	c3                   	ret    

008019ae <devfile_flush>:
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8019c9:	e8 50 ff ff ff       	call   80191e <fsipc>
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <devfile_stat>:
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	53                   	push   %ebx
  8019d4:	83 ec 14             	sub    $0x14,%esp
  8019d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019da:	8b 45 08             	mov    0x8(%ebp),%eax
  8019dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8019ef:	e8 2a ff ff ff       	call   80191e <fsipc>
  8019f4:	89 c2                	mov    %eax,%edx
  8019f6:	85 d2                	test   %edx,%edx
  8019f8:	78 2b                	js     801a25 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019fa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a01:	00 
  801a02:	89 1c 24             	mov    %ebx,(%esp)
  801a05:	e8 8d ef ff ff       	call   800997 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a0a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a15:	a1 84 50 80 00       	mov    0x805084,%eax
  801a1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a25:	83 c4 14             	add    $0x14,%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <devfile_write>:
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801a31:	c7 44 24 08 38 2c 80 	movl   $0x802c38,0x8(%esp)
  801a38:	00 
  801a39:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a40:	00 
  801a41:	c7 04 24 56 2c 80 00 	movl   $0x802c56,(%esp)
  801a48:	e8 2d e8 ff ff       	call   80027a <_panic>

00801a4d <devfile_read>:
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	83 ec 10             	sub    $0x10,%esp
  801a55:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a58:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a63:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a69:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a73:	e8 a6 fe ff ff       	call   80191e <fsipc>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 6a                	js     801ae8 <devfile_read+0x9b>
	assert(r <= n);
  801a7e:	39 c6                	cmp    %eax,%esi
  801a80:	73 24                	jae    801aa6 <devfile_read+0x59>
  801a82:	c7 44 24 0c 61 2c 80 	movl   $0x802c61,0xc(%esp)
  801a89:	00 
  801a8a:	c7 44 24 08 68 2c 80 	movl   $0x802c68,0x8(%esp)
  801a91:	00 
  801a92:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a99:	00 
  801a9a:	c7 04 24 56 2c 80 00 	movl   $0x802c56,(%esp)
  801aa1:	e8 d4 e7 ff ff       	call   80027a <_panic>
	assert(r <= PGSIZE);
  801aa6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aab:	7e 24                	jle    801ad1 <devfile_read+0x84>
  801aad:	c7 44 24 0c 7d 2c 80 	movl   $0x802c7d,0xc(%esp)
  801ab4:	00 
  801ab5:	c7 44 24 08 68 2c 80 	movl   $0x802c68,0x8(%esp)
  801abc:	00 
  801abd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ac4:	00 
  801ac5:	c7 04 24 56 2c 80 00 	movl   $0x802c56,(%esp)
  801acc:	e8 a9 e7 ff ff       	call   80027a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ad1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801adc:	00 
  801add:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae0:	89 04 24             	mov    %eax,(%esp)
  801ae3:	e8 4c f0 ff ff       	call   800b34 <memmove>
}
  801ae8:	89 d8                	mov    %ebx,%eax
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <open>:
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	53                   	push   %ebx
  801af5:	83 ec 24             	sub    $0x24,%esp
  801af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801afb:	89 1c 24             	mov    %ebx,(%esp)
  801afe:	e8 5d ee ff ff       	call   800960 <strlen>
  801b03:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b08:	7f 60                	jg     801b6a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801b0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0d:	89 04 24             	mov    %eax,(%esp)
  801b10:	e8 52 f8 ff ff       	call   801367 <fd_alloc>
  801b15:	89 c2                	mov    %eax,%edx
  801b17:	85 d2                	test   %edx,%edx
  801b19:	78 54                	js     801b6f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801b1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b26:	e8 6c ee ff ff       	call   800997 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b36:	b8 01 00 00 00       	mov    $0x1,%eax
  801b3b:	e8 de fd ff ff       	call   80191e <fsipc>
  801b40:	89 c3                	mov    %eax,%ebx
  801b42:	85 c0                	test   %eax,%eax
  801b44:	79 17                	jns    801b5d <open+0x6c>
		fd_close(fd, 0);
  801b46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b4d:	00 
  801b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 08 f9 ff ff       	call   801461 <fd_close>
		return r;
  801b59:	89 d8                	mov    %ebx,%eax
  801b5b:	eb 12                	jmp    801b6f <open+0x7e>
	return fd2num(fd);
  801b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b60:	89 04 24             	mov    %eax,(%esp)
  801b63:	e8 d8 f7 ff ff       	call   801340 <fd2num>
  801b68:	eb 05                	jmp    801b6f <open+0x7e>
		return -E_BAD_PATH;
  801b6a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801b6f:	83 c4 24             	add    $0x24,%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b80:	b8 08 00 00 00       	mov    $0x8,%eax
  801b85:	e8 94 fd ff ff       	call   80191e <fsipc>
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	83 ec 10             	sub    $0x10,%esp
  801b94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9a:	89 04 24             	mov    %eax,(%esp)
  801b9d:	e8 ae f7 ff ff       	call   801350 <fd2data>
  801ba2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ba4:	c7 44 24 04 89 2c 80 	movl   $0x802c89,0x4(%esp)
  801bab:	00 
  801bac:	89 1c 24             	mov    %ebx,(%esp)
  801baf:	e8 e3 ed ff ff       	call   800997 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bb4:	8b 46 04             	mov    0x4(%esi),%eax
  801bb7:	2b 06                	sub    (%esi),%eax
  801bb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bbf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bc6:	00 00 00 
	stat->st_dev = &devpipe;
  801bc9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bd0:	30 80 00 
	return 0;
}
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	53                   	push   %ebx
  801be3:	83 ec 14             	sub    $0x14,%esp
  801be6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801be9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf4:	e8 61 f2 ff ff       	call   800e5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bf9:	89 1c 24             	mov    %ebx,(%esp)
  801bfc:	e8 4f f7 ff ff       	call   801350 <fd2data>
  801c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0c:	e8 49 f2 ff ff       	call   800e5a <sys_page_unmap>
}
  801c11:	83 c4 14             	add    $0x14,%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <_pipeisclosed>:
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	57                   	push   %edi
  801c1b:	56                   	push   %esi
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 2c             	sub    $0x2c,%esp
  801c20:	89 c6                	mov    %eax,%esi
  801c22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801c25:	a1 20 44 80 00       	mov    0x804420,%eax
  801c2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c2d:	89 34 24             	mov    %esi,(%esp)
  801c30:	e8 a2 06 00 00       	call   8022d7 <pageref>
  801c35:	89 c7                	mov    %eax,%edi
  801c37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3a:	89 04 24             	mov    %eax,(%esp)
  801c3d:	e8 95 06 00 00       	call   8022d7 <pageref>
  801c42:	39 c7                	cmp    %eax,%edi
  801c44:	0f 94 c2             	sete   %dl
  801c47:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c4a:	8b 0d 20 44 80 00    	mov    0x804420,%ecx
  801c50:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c53:	39 fb                	cmp    %edi,%ebx
  801c55:	74 21                	je     801c78 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801c57:	84 d2                	test   %dl,%dl
  801c59:	74 ca                	je     801c25 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c5b:	8b 51 58             	mov    0x58(%ecx),%edx
  801c5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c62:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c6a:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  801c71:	e8 fd e6 ff ff       	call   800373 <cprintf>
  801c76:	eb ad                	jmp    801c25 <_pipeisclosed+0xe>
}
  801c78:	83 c4 2c             	add    $0x2c,%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5e                   	pop    %esi
  801c7d:	5f                   	pop    %edi
  801c7e:	5d                   	pop    %ebp
  801c7f:	c3                   	ret    

00801c80 <devpipe_write>:
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	57                   	push   %edi
  801c84:	56                   	push   %esi
  801c85:	53                   	push   %ebx
  801c86:	83 ec 1c             	sub    $0x1c,%esp
  801c89:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c8c:	89 34 24             	mov    %esi,(%esp)
  801c8f:	e8 bc f6 ff ff       	call   801350 <fd2data>
  801c94:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c96:	bf 00 00 00 00       	mov    $0x0,%edi
  801c9b:	eb 45                	jmp    801ce2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801c9d:	89 da                	mov    %ebx,%edx
  801c9f:	89 f0                	mov    %esi,%eax
  801ca1:	e8 71 ff ff ff       	call   801c17 <_pipeisclosed>
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	75 41                	jne    801ceb <devpipe_write+0x6b>
			sys_yield();
  801caa:	e8 e5 f0 ff ff       	call   800d94 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801caf:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb2:	8b 0b                	mov    (%ebx),%ecx
  801cb4:	8d 51 20             	lea    0x20(%ecx),%edx
  801cb7:	39 d0                	cmp    %edx,%eax
  801cb9:	73 e2                	jae    801c9d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cbe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cc2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cc5:	99                   	cltd   
  801cc6:	c1 ea 1b             	shr    $0x1b,%edx
  801cc9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801ccc:	83 e1 1f             	and    $0x1f,%ecx
  801ccf:	29 d1                	sub    %edx,%ecx
  801cd1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801cd5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801cd9:	83 c0 01             	add    $0x1,%eax
  801cdc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cdf:	83 c7 01             	add    $0x1,%edi
  801ce2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ce5:	75 c8                	jne    801caf <devpipe_write+0x2f>
	return i;
  801ce7:	89 f8                	mov    %edi,%eax
  801ce9:	eb 05                	jmp    801cf0 <devpipe_write+0x70>
				return 0;
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <devpipe_read>:
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	57                   	push   %edi
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 1c             	sub    $0x1c,%esp
  801d01:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d04:	89 3c 24             	mov    %edi,(%esp)
  801d07:	e8 44 f6 ff ff       	call   801350 <fd2data>
  801d0c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d0e:	be 00 00 00 00       	mov    $0x0,%esi
  801d13:	eb 3d                	jmp    801d52 <devpipe_read+0x5a>
			if (i > 0)
  801d15:	85 f6                	test   %esi,%esi
  801d17:	74 04                	je     801d1d <devpipe_read+0x25>
				return i;
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	eb 43                	jmp    801d60 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801d1d:	89 da                	mov    %ebx,%edx
  801d1f:	89 f8                	mov    %edi,%eax
  801d21:	e8 f1 fe ff ff       	call   801c17 <_pipeisclosed>
  801d26:	85 c0                	test   %eax,%eax
  801d28:	75 31                	jne    801d5b <devpipe_read+0x63>
			sys_yield();
  801d2a:	e8 65 f0 ff ff       	call   800d94 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d2f:	8b 03                	mov    (%ebx),%eax
  801d31:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d34:	74 df                	je     801d15 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d36:	99                   	cltd   
  801d37:	c1 ea 1b             	shr    $0x1b,%edx
  801d3a:	01 d0                	add    %edx,%eax
  801d3c:	83 e0 1f             	and    $0x1f,%eax
  801d3f:	29 d0                	sub    %edx,%eax
  801d41:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d49:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d4c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d4f:	83 c6 01             	add    $0x1,%esi
  801d52:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d55:	75 d8                	jne    801d2f <devpipe_read+0x37>
	return i;
  801d57:	89 f0                	mov    %esi,%eax
  801d59:	eb 05                	jmp    801d60 <devpipe_read+0x68>
				return 0;
  801d5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <pipe>:
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	56                   	push   %esi
  801d6c:	53                   	push   %ebx
  801d6d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d73:	89 04 24             	mov    %eax,(%esp)
  801d76:	e8 ec f5 ff ff       	call   801367 <fd_alloc>
  801d7b:	89 c2                	mov    %eax,%edx
  801d7d:	85 d2                	test   %edx,%edx
  801d7f:	0f 88 4d 01 00 00    	js     801ed2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d85:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d8c:	00 
  801d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d9b:	e8 13 f0 ff ff       	call   800db3 <sys_page_alloc>
  801da0:	89 c2                	mov    %eax,%edx
  801da2:	85 d2                	test   %edx,%edx
  801da4:	0f 88 28 01 00 00    	js     801ed2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801daa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dad:	89 04 24             	mov    %eax,(%esp)
  801db0:	e8 b2 f5 ff ff       	call   801367 <fd_alloc>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	85 c0                	test   %eax,%eax
  801db9:	0f 88 fe 00 00 00    	js     801ebd <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbf:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dc6:	00 
  801dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd5:	e8 d9 ef ff ff       	call   800db3 <sys_page_alloc>
  801dda:	89 c3                	mov    %eax,%ebx
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	0f 88 d9 00 00 00    	js     801ebd <pipe+0x155>
	va = fd2data(fd0);
  801de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de7:	89 04 24             	mov    %eax,(%esp)
  801dea:	e8 61 f5 ff ff       	call   801350 <fd2data>
  801def:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801df8:	00 
  801df9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e04:	e8 aa ef ff ff       	call   800db3 <sys_page_alloc>
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	0f 88 97 00 00 00    	js     801eaa <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e16:	89 04 24             	mov    %eax,(%esp)
  801e19:	e8 32 f5 ff ff       	call   801350 <fd2data>
  801e1e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e25:	00 
  801e26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e31:	00 
  801e32:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3d:	e8 c5 ef ff ff       	call   800e07 <sys_page_map>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	85 c0                	test   %eax,%eax
  801e46:	78 52                	js     801e9a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801e48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e51:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e5d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e66:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e75:	89 04 24             	mov    %eax,(%esp)
  801e78:	e8 c3 f4 ff ff       	call   801340 <fd2num>
  801e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e80:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e85:	89 04 24             	mov    %eax,(%esp)
  801e88:	e8 b3 f4 ff ff       	call   801340 <fd2num>
  801e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e90:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e93:	b8 00 00 00 00       	mov    $0x0,%eax
  801e98:	eb 38                	jmp    801ed2 <pipe+0x16a>
	sys_page_unmap(0, va);
  801e9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea5:	e8 b0 ef ff ff       	call   800e5a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ead:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb8:	e8 9d ef ff ff       	call   800e5a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecb:	e8 8a ef ff ff       	call   800e5a <sys_page_unmap>
  801ed0:	89 d8                	mov    %ebx,%eax
}
  801ed2:	83 c4 30             	add    $0x30,%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <pipeisclosed>:
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801edf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee9:	89 04 24             	mov    %eax,(%esp)
  801eec:	e8 c5 f4 ff ff       	call   8013b6 <fd_lookup>
  801ef1:	89 c2                	mov    %eax,%edx
  801ef3:	85 d2                	test   %edx,%edx
  801ef5:	78 15                	js     801f0c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efa:	89 04 24             	mov    %eax,(%esp)
  801efd:	e8 4e f4 ff ff       	call   801350 <fd2data>
	return _pipeisclosed(fd, p);
  801f02:	89 c2                	mov    %eax,%edx
  801f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f07:	e8 0b fd ff ff       	call   801c17 <_pipeisclosed>
}
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	83 ec 10             	sub    $0x10,%esp
  801f16:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801f19:	85 f6                	test   %esi,%esi
  801f1b:	75 24                	jne    801f41 <wait+0x33>
  801f1d:	c7 44 24 0c a8 2c 80 	movl   $0x802ca8,0xc(%esp)
  801f24:	00 
  801f25:	c7 44 24 08 68 2c 80 	movl   $0x802c68,0x8(%esp)
  801f2c:	00 
  801f2d:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  801f34:	00 
  801f35:	c7 04 24 b3 2c 80 00 	movl   $0x802cb3,(%esp)
  801f3c:	e8 39 e3 ff ff       	call   80027a <_panic>
	e = &envs[ENVX(envid)];
  801f41:	89 f3                	mov    %esi,%ebx
  801f43:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801f49:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801f4c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f52:	eb 05                	jmp    801f59 <wait+0x4b>
		sys_yield();
  801f54:	e8 3b ee ff ff       	call   800d94 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f59:	8b 43 48             	mov    0x48(%ebx),%eax
  801f5c:	39 f0                	cmp    %esi,%eax
  801f5e:	75 07                	jne    801f67 <wait+0x59>
  801f60:	8b 43 54             	mov    0x54(%ebx),%eax
  801f63:	85 c0                	test   %eax,%eax
  801f65:	75 ed                	jne    801f54 <wait+0x46>
}
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5d                   	pop    %ebp
  801f6d:	c3                   	ret    
  801f6e:	66 90                	xchg   %ax,%ax

00801f70 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f80:	c7 44 24 04 be 2c 80 	movl   $0x802cbe,0x4(%esp)
  801f87:	00 
  801f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8b:	89 04 24             	mov    %eax,(%esp)
  801f8e:	e8 04 ea ff ff       	call   800997 <strcpy>
	return 0;
}
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    

00801f9a <devcons_write>:
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	57                   	push   %edi
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fb1:	eb 31                	jmp    801fe4 <devcons_write+0x4a>
		m = n - tot;
  801fb3:	8b 75 10             	mov    0x10(%ebp),%esi
  801fb6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fb8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801fbb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fc0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fc3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fc7:	03 45 0c             	add    0xc(%ebp),%eax
  801fca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fce:	89 3c 24             	mov    %edi,(%esp)
  801fd1:	e8 5e eb ff ff       	call   800b34 <memmove>
		sys_cputs(buf, m);
  801fd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fda:	89 3c 24             	mov    %edi,(%esp)
  801fdd:	e8 04 ed ff ff       	call   800ce6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fe2:	01 f3                	add    %esi,%ebx
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fe9:	72 c8                	jb     801fb3 <devcons_write+0x19>
}
  801feb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ff1:	5b                   	pop    %ebx
  801ff2:	5e                   	pop    %esi
  801ff3:	5f                   	pop    %edi
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    

00801ff6 <devcons_read>:
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801ffc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802001:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802005:	75 07                	jne    80200e <devcons_read+0x18>
  802007:	eb 2a                	jmp    802033 <devcons_read+0x3d>
		sys_yield();
  802009:	e8 86 ed ff ff       	call   800d94 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80200e:	66 90                	xchg   %ax,%ax
  802010:	e8 ef ec ff ff       	call   800d04 <sys_cgetc>
  802015:	85 c0                	test   %eax,%eax
  802017:	74 f0                	je     802009 <devcons_read+0x13>
	if (c < 0)
  802019:	85 c0                	test   %eax,%eax
  80201b:	78 16                	js     802033 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80201d:	83 f8 04             	cmp    $0x4,%eax
  802020:	74 0c                	je     80202e <devcons_read+0x38>
	*(char*)vbuf = c;
  802022:	8b 55 0c             	mov    0xc(%ebp),%edx
  802025:	88 02                	mov    %al,(%edx)
	return 1;
  802027:	b8 01 00 00 00       	mov    $0x1,%eax
  80202c:	eb 05                	jmp    802033 <devcons_read+0x3d>
		return 0;
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <cputchar>:
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80203b:	8b 45 08             	mov    0x8(%ebp),%eax
  80203e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802041:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802048:	00 
  802049:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204c:	89 04 24             	mov    %eax,(%esp)
  80204f:	e8 92 ec ff ff       	call   800ce6 <sys_cputs>
}
  802054:	c9                   	leave  
  802055:	c3                   	ret    

00802056 <getchar>:
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80205c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802063:	00 
  802064:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802067:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802072:	e8 ce f5 ff ff       	call   801645 <read>
	if (r < 0)
  802077:	85 c0                	test   %eax,%eax
  802079:	78 0f                	js     80208a <getchar+0x34>
	if (r < 1)
  80207b:	85 c0                	test   %eax,%eax
  80207d:	7e 06                	jle    802085 <getchar+0x2f>
	return c;
  80207f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802083:	eb 05                	jmp    80208a <getchar+0x34>
		return -E_EOF;
  802085:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80208a:	c9                   	leave  
  80208b:	c3                   	ret    

0080208c <iscons>:
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802092:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802095:	89 44 24 04          	mov    %eax,0x4(%esp)
  802099:	8b 45 08             	mov    0x8(%ebp),%eax
  80209c:	89 04 24             	mov    %eax,(%esp)
  80209f:	e8 12 f3 ff ff       	call   8013b6 <fd_lookup>
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	78 11                	js     8020b9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020b1:	39 10                	cmp    %edx,(%eax)
  8020b3:	0f 94 c0             	sete   %al
  8020b6:	0f b6 c0             	movzbl %al,%eax
}
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <opencons>:
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c4:	89 04 24             	mov    %eax,(%esp)
  8020c7:	e8 9b f2 ff ff       	call   801367 <fd_alloc>
		return r;
  8020cc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	78 40                	js     802112 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020d9:	00 
  8020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e8:	e8 c6 ec ff ff       	call   800db3 <sys_page_alloc>
		return r;
  8020ed:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	78 1f                	js     802112 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8020f3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802101:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802108:	89 04 24             	mov    %eax,(%esp)
  80210b:	e8 30 f2 ff ff       	call   801340 <fd2num>
  802110:	89 c2                	mov    %eax,%edx
}
  802112:	89 d0                	mov    %edx,%eax
  802114:	c9                   	leave  
  802115:	c3                   	ret    

00802116 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  80211c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802123:	75 70                	jne    802195 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802125:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80212c:	00 
  80212d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802134:	ee 
  802135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213c:	e8 72 ec ff ff       	call   800db3 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  802141:	85 c0                	test   %eax,%eax
  802143:	79 1c                	jns    802161 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  802145:	c7 44 24 08 cc 2c 80 	movl   $0x802ccc,0x8(%esp)
  80214c:	00 
  80214d:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  802154:	00 
  802155:	c7 04 24 28 2d 80 00 	movl   $0x802d28,(%esp)
  80215c:	e8 19 e1 ff ff       	call   80027a <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  802161:	c7 44 24 04 9f 21 80 	movl   $0x80219f,0x4(%esp)
  802168:	00 
  802169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802170:	e8 de ed ff ff       	call   800f53 <sys_env_set_pgfault_upcall>
        if(r < 0)
  802175:	85 c0                	test   %eax,%eax
  802177:	79 1c                	jns    802195 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  802179:	c7 44 24 08 f4 2c 80 	movl   $0x802cf4,0x8(%esp)
  802180:	00 
  802181:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  802188:	00 
  802189:	c7 04 24 28 2d 80 00 	movl   $0x802d28,(%esp)
  802190:	e8 e5 e0 ff ff       	call   80027a <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802195:	8b 45 08             	mov    0x8(%ebp),%eax
  802198:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80219d:	c9                   	leave  
  80219e:	c3                   	ret    

0080219f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80219f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021a0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021a5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021a7:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  8021aa:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  8021ae:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  8021b2:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  8021b4:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  8021b6:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  8021b7:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  8021ba:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  8021bc:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  8021bf:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  8021c0:	83 c4 04             	add    $0x4,%esp
    popf;
  8021c3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  8021c4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  8021c5:	c3                   	ret    
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	56                   	push   %esi
  8021d4:	53                   	push   %ebx
  8021d5:	83 ec 10             	sub    $0x10,%esp
  8021d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021de:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  8021e1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  8021e3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8021e8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  8021eb:	89 04 24             	mov    %eax,(%esp)
  8021ee:	e8 d6 ed ff ff       	call   800fc9 <sys_ipc_recv>
    if(r < 0){
  8021f3:	85 c0                	test   %eax,%eax
  8021f5:	79 16                	jns    80220d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	74 06                	je     802201 <ipc_recv+0x31>
            *from_env_store = 0;
  8021fb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802201:	85 db                	test   %ebx,%ebx
  802203:	74 2c                	je     802231 <ipc_recv+0x61>
            *perm_store = 0;
  802205:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80220b:	eb 24                	jmp    802231 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80220d:	85 f6                	test   %esi,%esi
  80220f:	74 0a                	je     80221b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802211:	a1 20 44 80 00       	mov    0x804420,%eax
  802216:	8b 40 74             	mov    0x74(%eax),%eax
  802219:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80221b:	85 db                	test   %ebx,%ebx
  80221d:	74 0a                	je     802229 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80221f:	a1 20 44 80 00       	mov    0x804420,%eax
  802224:	8b 40 78             	mov    0x78(%eax),%eax
  802227:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802229:	a1 20 44 80 00       	mov    0x804420,%eax
  80222e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802231:	83 c4 10             	add    $0x10,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    

00802238 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802238:	55                   	push   %ebp
  802239:	89 e5                	mov    %esp,%ebp
  80223b:	57                   	push   %edi
  80223c:	56                   	push   %esi
  80223d:	53                   	push   %ebx
  80223e:	83 ec 1c             	sub    $0x1c,%esp
  802241:	8b 7d 08             	mov    0x8(%ebp),%edi
  802244:	8b 75 0c             	mov    0xc(%ebp),%esi
  802247:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80224a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80224c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802251:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802254:	8b 45 14             	mov    0x14(%ebp),%eax
  802257:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80225f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	e8 3b ed ff ff       	call   800fa6 <sys_ipc_try_send>
        if(r == 0){
  80226b:	85 c0                	test   %eax,%eax
  80226d:	74 28                	je     802297 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80226f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802272:	74 1c                	je     802290 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  802274:	c7 44 24 08 36 2d 80 	movl   $0x802d36,0x8(%esp)
  80227b:	00 
  80227c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802283:	00 
  802284:	c7 04 24 4d 2d 80 00 	movl   $0x802d4d,(%esp)
  80228b:	e8 ea df ff ff       	call   80027a <_panic>
        }
        sys_yield();
  802290:	e8 ff ea ff ff       	call   800d94 <sys_yield>
    }
  802295:	eb bd                	jmp    802254 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802297:	83 c4 1c             	add    $0x1c,%esp
  80229a:	5b                   	pop    %ebx
  80229b:	5e                   	pop    %esi
  80229c:	5f                   	pop    %edi
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    

0080229f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022a5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022aa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022ad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022b3:	8b 52 50             	mov    0x50(%edx),%edx
  8022b6:	39 ca                	cmp    %ecx,%edx
  8022b8:	75 0d                	jne    8022c7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022bd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022c2:	8b 40 40             	mov    0x40(%eax),%eax
  8022c5:	eb 0e                	jmp    8022d5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  8022c7:	83 c0 01             	add    $0x1,%eax
  8022ca:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022cf:	75 d9                	jne    8022aa <ipc_find_env+0xb>
	return 0;
  8022d1:	66 b8 00 00          	mov    $0x0,%ax
}
  8022d5:	5d                   	pop    %ebp
  8022d6:	c3                   	ret    

008022d7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022dd:	89 d0                	mov    %edx,%eax
  8022df:	c1 e8 16             	shr    $0x16,%eax
  8022e2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022e9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8022ee:	f6 c1 01             	test   $0x1,%cl
  8022f1:	74 1d                	je     802310 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8022f3:	c1 ea 0c             	shr    $0xc,%edx
  8022f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022fd:	f6 c2 01             	test   $0x1,%dl
  802300:	74 0e                	je     802310 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802302:	c1 ea 0c             	shr    $0xc,%edx
  802305:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80230c:	ef 
  80230d:	0f b7 c0             	movzwl %ax,%eax
}
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	66 90                	xchg   %ax,%ax
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__udivdi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	83 ec 0c             	sub    $0xc,%esp
  802326:	8b 44 24 28          	mov    0x28(%esp),%eax
  80232a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80232e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802332:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802336:	85 c0                	test   %eax,%eax
  802338:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80233c:	89 ea                	mov    %ebp,%edx
  80233e:	89 0c 24             	mov    %ecx,(%esp)
  802341:	75 2d                	jne    802370 <__udivdi3+0x50>
  802343:	39 e9                	cmp    %ebp,%ecx
  802345:	77 61                	ja     8023a8 <__udivdi3+0x88>
  802347:	85 c9                	test   %ecx,%ecx
  802349:	89 ce                	mov    %ecx,%esi
  80234b:	75 0b                	jne    802358 <__udivdi3+0x38>
  80234d:	b8 01 00 00 00       	mov    $0x1,%eax
  802352:	31 d2                	xor    %edx,%edx
  802354:	f7 f1                	div    %ecx
  802356:	89 c6                	mov    %eax,%esi
  802358:	31 d2                	xor    %edx,%edx
  80235a:	89 e8                	mov    %ebp,%eax
  80235c:	f7 f6                	div    %esi
  80235e:	89 c5                	mov    %eax,%ebp
  802360:	89 f8                	mov    %edi,%eax
  802362:	f7 f6                	div    %esi
  802364:	89 ea                	mov    %ebp,%edx
  802366:	83 c4 0c             	add    $0xc,%esp
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	39 e8                	cmp    %ebp,%eax
  802372:	77 24                	ja     802398 <__udivdi3+0x78>
  802374:	0f bd e8             	bsr    %eax,%ebp
  802377:	83 f5 1f             	xor    $0x1f,%ebp
  80237a:	75 3c                	jne    8023b8 <__udivdi3+0x98>
  80237c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802380:	39 34 24             	cmp    %esi,(%esp)
  802383:	0f 86 9f 00 00 00    	jbe    802428 <__udivdi3+0x108>
  802389:	39 d0                	cmp    %edx,%eax
  80238b:	0f 82 97 00 00 00    	jb     802428 <__udivdi3+0x108>
  802391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802398:	31 d2                	xor    %edx,%edx
  80239a:	31 c0                	xor    %eax,%eax
  80239c:	83 c4 0c             	add    $0xc,%esp
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    
  8023a3:	90                   	nop
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	89 f8                	mov    %edi,%eax
  8023aa:	f7 f1                	div    %ecx
  8023ac:	31 d2                	xor    %edx,%edx
  8023ae:	83 c4 0c             	add    $0xc,%esp
  8023b1:	5e                   	pop    %esi
  8023b2:	5f                   	pop    %edi
  8023b3:	5d                   	pop    %ebp
  8023b4:	c3                   	ret    
  8023b5:	8d 76 00             	lea    0x0(%esi),%esi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	8b 3c 24             	mov    (%esp),%edi
  8023bd:	d3 e0                	shl    %cl,%eax
  8023bf:	89 c6                	mov    %eax,%esi
  8023c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023c6:	29 e8                	sub    %ebp,%eax
  8023c8:	89 c1                	mov    %eax,%ecx
  8023ca:	d3 ef                	shr    %cl,%edi
  8023cc:	89 e9                	mov    %ebp,%ecx
  8023ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023d2:	8b 3c 24             	mov    (%esp),%edi
  8023d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023d9:	89 d6                	mov    %edx,%esi
  8023db:	d3 e7                	shl    %cl,%edi
  8023dd:	89 c1                	mov    %eax,%ecx
  8023df:	89 3c 24             	mov    %edi,(%esp)
  8023e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023e6:	d3 ee                	shr    %cl,%esi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	d3 e2                	shl    %cl,%edx
  8023ec:	89 c1                	mov    %eax,%ecx
  8023ee:	d3 ef                	shr    %cl,%edi
  8023f0:	09 d7                	or     %edx,%edi
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	89 f8                	mov    %edi,%eax
  8023f6:	f7 74 24 08          	divl   0x8(%esp)
  8023fa:	89 d6                	mov    %edx,%esi
  8023fc:	89 c7                	mov    %eax,%edi
  8023fe:	f7 24 24             	mull   (%esp)
  802401:	39 d6                	cmp    %edx,%esi
  802403:	89 14 24             	mov    %edx,(%esp)
  802406:	72 30                	jb     802438 <__udivdi3+0x118>
  802408:	8b 54 24 04          	mov    0x4(%esp),%edx
  80240c:	89 e9                	mov    %ebp,%ecx
  80240e:	d3 e2                	shl    %cl,%edx
  802410:	39 c2                	cmp    %eax,%edx
  802412:	73 05                	jae    802419 <__udivdi3+0xf9>
  802414:	3b 34 24             	cmp    (%esp),%esi
  802417:	74 1f                	je     802438 <__udivdi3+0x118>
  802419:	89 f8                	mov    %edi,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	e9 7a ff ff ff       	jmp    80239c <__udivdi3+0x7c>
  802422:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802428:	31 d2                	xor    %edx,%edx
  80242a:	b8 01 00 00 00       	mov    $0x1,%eax
  80242f:	e9 68 ff ff ff       	jmp    80239c <__udivdi3+0x7c>
  802434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802438:	8d 47 ff             	lea    -0x1(%edi),%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	83 c4 0c             	add    $0xc,%esp
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    
  802444:	66 90                	xchg   %ax,%ax
  802446:	66 90                	xchg   %ax,%ax
  802448:	66 90                	xchg   %ax,%ax
  80244a:	66 90                	xchg   %ax,%ax
  80244c:	66 90                	xchg   %ax,%ax
  80244e:	66 90                	xchg   %ax,%ax

00802450 <__umoddi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	83 ec 14             	sub    $0x14,%esp
  802456:	8b 44 24 28          	mov    0x28(%esp),%eax
  80245a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80245e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802462:	89 c7                	mov    %eax,%edi
  802464:	89 44 24 04          	mov    %eax,0x4(%esp)
  802468:	8b 44 24 30          	mov    0x30(%esp),%eax
  80246c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802470:	89 34 24             	mov    %esi,(%esp)
  802473:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802477:	85 c0                	test   %eax,%eax
  802479:	89 c2                	mov    %eax,%edx
  80247b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80247f:	75 17                	jne    802498 <__umoddi3+0x48>
  802481:	39 fe                	cmp    %edi,%esi
  802483:	76 4b                	jbe    8024d0 <__umoddi3+0x80>
  802485:	89 c8                	mov    %ecx,%eax
  802487:	89 fa                	mov    %edi,%edx
  802489:	f7 f6                	div    %esi
  80248b:	89 d0                	mov    %edx,%eax
  80248d:	31 d2                	xor    %edx,%edx
  80248f:	83 c4 14             	add    $0x14,%esp
  802492:	5e                   	pop    %esi
  802493:	5f                   	pop    %edi
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    
  802496:	66 90                	xchg   %ax,%ax
  802498:	39 f8                	cmp    %edi,%eax
  80249a:	77 54                	ja     8024f0 <__umoddi3+0xa0>
  80249c:	0f bd e8             	bsr    %eax,%ebp
  80249f:	83 f5 1f             	xor    $0x1f,%ebp
  8024a2:	75 5c                	jne    802500 <__umoddi3+0xb0>
  8024a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024a8:	39 3c 24             	cmp    %edi,(%esp)
  8024ab:	0f 87 e7 00 00 00    	ja     802598 <__umoddi3+0x148>
  8024b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024b5:	29 f1                	sub    %esi,%ecx
  8024b7:	19 c7                	sbb    %eax,%edi
  8024b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024c9:	83 c4 14             	add    $0x14,%esp
  8024cc:	5e                   	pop    %esi
  8024cd:	5f                   	pop    %edi
  8024ce:	5d                   	pop    %ebp
  8024cf:	c3                   	ret    
  8024d0:	85 f6                	test   %esi,%esi
  8024d2:	89 f5                	mov    %esi,%ebp
  8024d4:	75 0b                	jne    8024e1 <__umoddi3+0x91>
  8024d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	f7 f6                	div    %esi
  8024df:	89 c5                	mov    %eax,%ebp
  8024e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024e5:	31 d2                	xor    %edx,%edx
  8024e7:	f7 f5                	div    %ebp
  8024e9:	89 c8                	mov    %ecx,%eax
  8024eb:	f7 f5                	div    %ebp
  8024ed:	eb 9c                	jmp    80248b <__umoddi3+0x3b>
  8024ef:	90                   	nop
  8024f0:	89 c8                	mov    %ecx,%eax
  8024f2:	89 fa                	mov    %edi,%edx
  8024f4:	83 c4 14             	add    $0x14,%esp
  8024f7:	5e                   	pop    %esi
  8024f8:	5f                   	pop    %edi
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    
  8024fb:	90                   	nop
  8024fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802500:	8b 04 24             	mov    (%esp),%eax
  802503:	be 20 00 00 00       	mov    $0x20,%esi
  802508:	89 e9                	mov    %ebp,%ecx
  80250a:	29 ee                	sub    %ebp,%esi
  80250c:	d3 e2                	shl    %cl,%edx
  80250e:	89 f1                	mov    %esi,%ecx
  802510:	d3 e8                	shr    %cl,%eax
  802512:	89 e9                	mov    %ebp,%ecx
  802514:	89 44 24 04          	mov    %eax,0x4(%esp)
  802518:	8b 04 24             	mov    (%esp),%eax
  80251b:	09 54 24 04          	or     %edx,0x4(%esp)
  80251f:	89 fa                	mov    %edi,%edx
  802521:	d3 e0                	shl    %cl,%eax
  802523:	89 f1                	mov    %esi,%ecx
  802525:	89 44 24 08          	mov    %eax,0x8(%esp)
  802529:	8b 44 24 10          	mov    0x10(%esp),%eax
  80252d:	d3 ea                	shr    %cl,%edx
  80252f:	89 e9                	mov    %ebp,%ecx
  802531:	d3 e7                	shl    %cl,%edi
  802533:	89 f1                	mov    %esi,%ecx
  802535:	d3 e8                	shr    %cl,%eax
  802537:	89 e9                	mov    %ebp,%ecx
  802539:	09 f8                	or     %edi,%eax
  80253b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80253f:	f7 74 24 04          	divl   0x4(%esp)
  802543:	d3 e7                	shl    %cl,%edi
  802545:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802549:	89 d7                	mov    %edx,%edi
  80254b:	f7 64 24 08          	mull   0x8(%esp)
  80254f:	39 d7                	cmp    %edx,%edi
  802551:	89 c1                	mov    %eax,%ecx
  802553:	89 14 24             	mov    %edx,(%esp)
  802556:	72 2c                	jb     802584 <__umoddi3+0x134>
  802558:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80255c:	72 22                	jb     802580 <__umoddi3+0x130>
  80255e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802562:	29 c8                	sub    %ecx,%eax
  802564:	19 d7                	sbb    %edx,%edi
  802566:	89 e9                	mov    %ebp,%ecx
  802568:	89 fa                	mov    %edi,%edx
  80256a:	d3 e8                	shr    %cl,%eax
  80256c:	89 f1                	mov    %esi,%ecx
  80256e:	d3 e2                	shl    %cl,%edx
  802570:	89 e9                	mov    %ebp,%ecx
  802572:	d3 ef                	shr    %cl,%edi
  802574:	09 d0                	or     %edx,%eax
  802576:	89 fa                	mov    %edi,%edx
  802578:	83 c4 14             	add    $0x14,%esp
  80257b:	5e                   	pop    %esi
  80257c:	5f                   	pop    %edi
  80257d:	5d                   	pop    %ebp
  80257e:	c3                   	ret    
  80257f:	90                   	nop
  802580:	39 d7                	cmp    %edx,%edi
  802582:	75 da                	jne    80255e <__umoddi3+0x10e>
  802584:	8b 14 24             	mov    (%esp),%edx
  802587:	89 c1                	mov    %eax,%ecx
  802589:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80258d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802591:	eb cb                	jmp    80255e <__umoddi3+0x10e>
  802593:	90                   	nop
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80259c:	0f 82 0f ff ff ff    	jb     8024b1 <__umoddi3+0x61>
  8025a2:	e9 1a ff ff ff       	jmp    8024c1 <__umoddi3+0x71>
