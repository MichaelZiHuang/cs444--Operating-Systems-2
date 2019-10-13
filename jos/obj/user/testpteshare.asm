
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 86 01 00 00       	call   8001b7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  800039:	a1 00 40 80 00       	mov    0x804000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800049:	e8 e9 08 00 00       	call   800937 <strcpy>
	exit();
  80004e:	e8 ac 01 00 00       	call   8001ff <exit>
}
  800053:	c9                   	leave  
  800054:	c3                   	ret    

00800055 <umain>:
{
  800055:	55                   	push   %ebp
  800056:	89 e5                	mov    %esp,%ebp
  800058:	53                   	push   %ebx
  800059:	83 ec 14             	sub    $0x14,%esp
	if (argc != 0)
  80005c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800060:	74 05                	je     800067 <umain+0x12>
		childofspawn();
  800062:	e8 cc ff ff ff       	call   800033 <childofspawn>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800067:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800076:	a0 
  800077:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007e:	e8 d0 0c 00 00       	call   800d53 <sys_page_alloc>
  800083:	85 c0                	test   %eax,%eax
  800085:	79 20                	jns    8000a7 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800087:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008b:	c7 44 24 08 2c 2b 80 	movl   $0x802b2c,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009a:	00 
  80009b:	c7 04 24 3f 2b 80 00 	movl   $0x802b3f,(%esp)
  8000a2:	e8 71 01 00 00       	call   800218 <_panic>
	if ((r = fork()) < 0)
  8000a7:	e8 36 10 00 00       	call   8010e2 <fork>
  8000ac:	89 c3                	mov    %eax,%ebx
  8000ae:	85 c0                	test   %eax,%eax
  8000b0:	79 20                	jns    8000d2 <umain+0x7d>
		panic("fork: %e", r);
  8000b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b6:	c7 44 24 08 53 2b 80 	movl   $0x802b53,0x8(%esp)
  8000bd:	00 
  8000be:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c5:	00 
  8000c6:	c7 04 24 3f 2b 80 00 	movl   $0x802b3f,(%esp)
  8000cd:	e8 46 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000d2:	85 c0                	test   %eax,%eax
  8000d4:	75 1a                	jne    8000f0 <umain+0x9b>
		strcpy(VA, msg);
  8000d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000df:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e6:	e8 4c 08 00 00       	call   800937 <strcpy>
		exit();
  8000eb:	e8 0f 01 00 00       	call   8001ff <exit>
	wait(r);
  8000f0:	89 1c 24             	mov    %ebx,(%esp)
  8000f3:	e8 72 23 00 00       	call   80246a <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800108:	e8 df 08 00 00       	call   8009ec <strcmp>
  80010d:	85 c0                	test   %eax,%eax
  80010f:	b8 20 2b 80 00       	mov    $0x802b20,%eax
  800114:	ba 26 2b 80 00       	mov    $0x802b26,%edx
  800119:	0f 45 c2             	cmovne %edx,%eax
  80011c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800120:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800127:	e8 e5 01 00 00       	call   800311 <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 77 2b 80 	movl   $0x802b77,0x8(%esp)
  80013b:	00 
  80013c:	c7 44 24 04 7c 2b 80 	movl   $0x802b7c,0x4(%esp)
  800143:	00 
  800144:	c7 04 24 7b 2b 80 00 	movl   $0x802b7b,(%esp)
  80014b:	e8 21 1f 00 00       	call   802071 <spawnl>
  800150:	85 c0                	test   %eax,%eax
  800152:	79 20                	jns    800174 <umain+0x11f>
		panic("spawn: %e", r);
  800154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800158:	c7 44 24 08 89 2b 80 	movl   $0x802b89,0x8(%esp)
  80015f:	00 
  800160:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800167:	00 
  800168:	c7 04 24 3f 2b 80 00 	movl   $0x802b3f,(%esp)
  80016f:	e8 a4 00 00 00       	call   800218 <_panic>
	wait(r);
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 ee 22 00 00       	call   80246a <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017c:	a1 00 40 80 00       	mov    0x804000,%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018c:	e8 5b 08 00 00       	call   8009ec <strcmp>
  800191:	85 c0                	test   %eax,%eax
  800193:	b8 20 2b 80 00       	mov    $0x802b20,%eax
  800198:	ba 26 2b 80 00       	mov    $0x802b26,%edx
  80019d:	0f 45 c2             	cmovne %edx,%eax
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  8001ab:	e8 61 01 00 00       	call   800311 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001b0:	cc                   	int3   
}
  8001b1:	83 c4 14             	add    $0x14,%esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 10             	sub    $0x10,%esp
  8001bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8001c5:	e8 4b 0b 00 00       	call   800d15 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8001ca:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d7:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001dc:	85 db                	test   %ebx,%ebx
  8001de:	7e 07                	jle    8001e7 <libmain+0x30>
		binaryname = argv[0];
  8001e0:	8b 06                	mov    (%esi),%eax
  8001e2:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001eb:	89 1c 24             	mov    %ebx,(%esp)
  8001ee:	e8 62 fe ff ff       	call   800055 <umain>

	// exit gracefully
	exit();
  8001f3:	e8 07 00 00 00       	call   8001ff <exit>
}
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800205:	e8 ab 12 00 00       	call   8014b5 <close_all>
	sys_env_destroy(0);
  80020a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800211:	e8 ad 0a 00 00       	call   800cc3 <sys_env_destroy>
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800220:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800223:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800229:	e8 e7 0a 00 00       	call   800d15 <sys_getenvid>
  80022e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800231:	89 54 24 10          	mov    %edx,0x10(%esp)
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80023c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	c7 04 24 d8 2b 80 00 	movl   $0x802bd8,(%esp)
  80024b:	e8 c1 00 00 00       	call   800311 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800254:	8b 45 10             	mov    0x10(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 51 00 00 00       	call   8002b0 <vcprintf>
	cprintf("\n");
  80025f:	c7 04 24 1e 32 80 00 	movl   $0x80321e,(%esp)
  800266:	e8 a6 00 00 00       	call   800311 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026b:	cc                   	int3   
  80026c:	eb fd                	jmp    80026b <_panic+0x53>

0080026e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	53                   	push   %ebx
  800272:	83 ec 14             	sub    $0x14,%esp
  800275:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800278:	8b 13                	mov    (%ebx),%edx
  80027a:	8d 42 01             	lea    0x1(%edx),%eax
  80027d:	89 03                	mov    %eax,(%ebx)
  80027f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800282:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800286:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028b:	75 19                	jne    8002a6 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80028d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800294:	00 
  800295:	8d 43 08             	lea    0x8(%ebx),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	e8 e6 09 00 00       	call   800c86 <sys_cputs>
		b->idx = 0;
  8002a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002aa:	83 c4 14             	add    $0x14,%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c0:	00 00 00 
	b.cnt = 0;
  8002c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	c7 04 24 6e 02 80 00 	movl   $0x80026e,(%esp)
  8002ec:	e8 ad 01 00 00       	call   80049e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	89 04 24             	mov    %eax,(%esp)
  800304:	e8 7d 09 00 00       	call   800c86 <sys_cputs>

	return b.cnt;
}
  800309:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800317:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 87 ff ff ff       	call   8002b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800329:	c9                   	leave  
  80032a:	c3                   	ret    
  80032b:	66 90                	xchg   %ax,%ax
  80032d:	66 90                	xchg   %ax,%ax
  80032f:	90                   	nop

00800330 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 3c             	sub    $0x3c,%esp
  800339:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033c:	89 d7                	mov    %edx,%edi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800344:	8b 45 0c             	mov    0xc(%ebp),%eax
  800347:	89 c3                	mov    %eax,%ebx
  800349:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80034c:	8b 45 10             	mov    0x10(%ebp),%eax
  80034f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80035d:	39 d9                	cmp    %ebx,%ecx
  80035f:	72 05                	jb     800366 <printnum+0x36>
  800361:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800364:	77 69                	ja     8003cf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800366:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800369:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80036d:	83 ee 01             	sub    $0x1,%esi
  800370:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800374:	89 44 24 08          	mov    %eax,0x8(%esp)
  800378:	8b 44 24 08          	mov    0x8(%esp),%eax
  80037c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800380:	89 c3                	mov    %eax,%ebx
  800382:	89 d6                	mov    %edx,%esi
  800384:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800387:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80038a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80038e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80039b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039f:	e8 dc 24 00 00       	call   802880 <__udivdi3>
  8003a4:	89 d9                	mov    %ebx,%ecx
  8003a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b5:	89 fa                	mov    %edi,%edx
  8003b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ba:	e8 71 ff ff ff       	call   800330 <printnum>
  8003bf:	eb 1b                	jmp    8003dc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff d3                	call   *%ebx
  8003cd:	eb 03                	jmp    8003d2 <printnum+0xa2>
  8003cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8003d2:	83 ee 01             	sub    $0x1,%esi
  8003d5:	85 f6                	test   %esi,%esi
  8003d7:	7f e8                	jg     8003c1 <printnum+0x91>
  8003d9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	e8 ac 25 00 00       	call   8029b0 <__umoddi3>
  800404:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800408:	0f be 80 fb 2b 80 00 	movsbl 0x802bfb(%eax),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800415:	ff d0                	call   *%eax
}
  800417:	83 c4 3c             	add    $0x3c,%esp
  80041a:	5b                   	pop    %ebx
  80041b:	5e                   	pop    %esi
  80041c:	5f                   	pop    %edi
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800422:	83 fa 01             	cmp    $0x1,%edx
  800425:	7e 0e                	jle    800435 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800427:	8b 10                	mov    (%eax),%edx
  800429:	8d 4a 08             	lea    0x8(%edx),%ecx
  80042c:	89 08                	mov    %ecx,(%eax)
  80042e:	8b 02                	mov    (%edx),%eax
  800430:	8b 52 04             	mov    0x4(%edx),%edx
  800433:	eb 22                	jmp    800457 <getuint+0x38>
	else if (lflag)
  800435:	85 d2                	test   %edx,%edx
  800437:	74 10                	je     800449 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043e:	89 08                	mov    %ecx,(%eax)
  800440:	8b 02                	mov    (%edx),%eax
  800442:	ba 00 00 00 00       	mov    $0x0,%edx
  800447:	eb 0e                	jmp    800457 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    

00800459 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80045f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800463:	8b 10                	mov    (%eax),%edx
  800465:	3b 50 04             	cmp    0x4(%eax),%edx
  800468:	73 0a                	jae    800474 <sprintputch+0x1b>
		*b->buf++ = ch;
  80046a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80046d:	89 08                	mov    %ecx,(%eax)
  80046f:	8b 45 08             	mov    0x8(%ebp),%eax
  800472:	88 02                	mov    %al,(%edx)
}
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <printfmt>:
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80047c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80047f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800483:	8b 45 10             	mov    0x10(%ebp),%eax
  800486:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 02 00 00 00       	call   80049e <vprintfmt>
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    

0080049e <vprintfmt>:
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	57                   	push   %edi
  8004a2:	56                   	push   %esi
  8004a3:	53                   	push   %ebx
  8004a4:	83 ec 3c             	sub    $0x3c,%esp
  8004a7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004ad:	eb 1f                	jmp    8004ce <vprintfmt+0x30>
			if (ch == '\0'){
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	75 0f                	jne    8004c2 <vprintfmt+0x24>
				color = 0x0100;
  8004b3:	c7 05 00 50 80 00 00 	movl   $0x100,0x805000
  8004ba:	01 00 00 
  8004bd:	e9 b3 03 00 00       	jmp    800875 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8004c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004cc:	89 f3                	mov    %esi,%ebx
  8004ce:	8d 73 01             	lea    0x1(%ebx),%esi
  8004d1:	0f b6 03             	movzbl (%ebx),%eax
  8004d4:	83 f8 25             	cmp    $0x25,%eax
  8004d7:	75 d6                	jne    8004af <vprintfmt+0x11>
  8004d9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004dd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004e4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004eb:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f7:	eb 1d                	jmp    800516 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	89 de                	mov    %ebx,%esi
			padc = '-';
  8004fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004ff:	eb 15                	jmp    800516 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800501:	89 de                	mov    %ebx,%esi
			padc = '0';
  800503:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800507:	eb 0d                	jmp    800516 <vprintfmt+0x78>
				width = precision, precision = -1;
  800509:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80050f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8d 5e 01             	lea    0x1(%esi),%ebx
  800519:	0f b6 0e             	movzbl (%esi),%ecx
  80051c:	0f b6 c1             	movzbl %cl,%eax
  80051f:	83 e9 23             	sub    $0x23,%ecx
  800522:	80 f9 55             	cmp    $0x55,%cl
  800525:	0f 87 2a 03 00 00    	ja     800855 <vprintfmt+0x3b7>
  80052b:	0f b6 c9             	movzbl %cl,%ecx
  80052e:	ff 24 8d 40 2d 80 00 	jmp    *0x802d40(,%ecx,4)
  800535:	89 de                	mov    %ebx,%esi
  800537:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80053c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80053f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800543:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800546:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800549:	83 fb 09             	cmp    $0x9,%ebx
  80054c:	77 36                	ja     800584 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80054e:	83 c6 01             	add    $0x1,%esi
			}
  800551:	eb e9                	jmp    80053c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 48 04             	lea    0x4(%eax),%ecx
  800559:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80055c:	8b 00                	mov    (%eax),%eax
  80055e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800561:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800563:	eb 22                	jmp    800587 <vprintfmt+0xe9>
  800565:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800568:	85 c9                	test   %ecx,%ecx
  80056a:	b8 00 00 00 00       	mov    $0x0,%eax
  80056f:	0f 49 c1             	cmovns %ecx,%eax
  800572:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800575:	89 de                	mov    %ebx,%esi
  800577:	eb 9d                	jmp    800516 <vprintfmt+0x78>
  800579:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80057b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800582:	eb 92                	jmp    800516 <vprintfmt+0x78>
  800584:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800587:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058b:	79 89                	jns    800516 <vprintfmt+0x78>
  80058d:	e9 77 ff ff ff       	jmp    800509 <vprintfmt+0x6b>
			lflag++;
  800592:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800595:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800597:	e9 7a ff ff ff       	jmp    800516 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 04 24             	mov    %eax,(%esp)
  8005ae:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005b1:	e9 18 ff ff ff       	jmp    8004ce <vprintfmt+0x30>
			err = va_arg(ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	99                   	cltd   
  8005c2:	31 d0                	xor    %edx,%eax
  8005c4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c6:	83 f8 0f             	cmp    $0xf,%eax
  8005c9:	7f 0b                	jg     8005d6 <vprintfmt+0x138>
  8005cb:	8b 14 85 a0 2e 80 00 	mov    0x802ea0(,%eax,4),%edx
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	75 20                	jne    8005f6 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  8005d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005da:	c7 44 24 08 13 2c 80 	movl   $0x802c13,0x8(%esp)
  8005e1:	00 
  8005e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	e8 85 fe ff ff       	call   800476 <printfmt>
  8005f1:	e9 d8 fe ff ff       	jmp    8004ce <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  8005f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005fa:	c7 44 24 08 5a 31 80 	movl   $0x80315a,0x8(%esp)
  800601:	00 
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	8b 45 08             	mov    0x8(%ebp),%eax
  800609:	89 04 24             	mov    %eax,(%esp)
  80060c:	e8 65 fe ff ff       	call   800476 <printfmt>
  800611:	e9 b8 fe ff ff       	jmp    8004ce <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800619:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)
  800628:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80062a:	85 f6                	test   %esi,%esi
  80062c:	b8 0c 2c 80 00       	mov    $0x802c0c,%eax
  800631:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800634:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800638:	0f 84 97 00 00 00    	je     8006d5 <vprintfmt+0x237>
  80063e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800642:	0f 8e 9b 00 00 00    	jle    8006e3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800648:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80064c:	89 34 24             	mov    %esi,(%esp)
  80064f:	e8 c4 02 00 00       	call   800918 <strnlen>
  800654:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800657:	29 c2                	sub    %eax,%edx
  800659:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80065c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800660:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800663:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800666:	8b 75 08             	mov    0x8(%ebp),%esi
  800669:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80066c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80066e:	eb 0f                	jmp    80067f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800670:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800674:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800677:	89 04 24             	mov    %eax,(%esp)
  80067a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80067c:	83 eb 01             	sub    $0x1,%ebx
  80067f:	85 db                	test   %ebx,%ebx
  800681:	7f ed                	jg     800670 <vprintfmt+0x1d2>
  800683:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800686:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800689:	85 d2                	test   %edx,%edx
  80068b:	b8 00 00 00 00       	mov    $0x0,%eax
  800690:	0f 49 c2             	cmovns %edx,%eax
  800693:	29 c2                	sub    %eax,%edx
  800695:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800698:	89 d7                	mov    %edx,%edi
  80069a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80069d:	eb 50                	jmp    8006ef <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80069f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a3:	74 1e                	je     8006c3 <vprintfmt+0x225>
  8006a5:	0f be d2             	movsbl %dl,%edx
  8006a8:	83 ea 20             	sub    $0x20,%edx
  8006ab:	83 fa 5e             	cmp    $0x5e,%edx
  8006ae:	76 13                	jbe    8006c3 <vprintfmt+0x225>
					putch('?', putdat);
  8006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006be:	ff 55 08             	call   *0x8(%ebp)
  8006c1:	eb 0d                	jmp    8006d0 <vprintfmt+0x232>
					putch(ch, putdat);
  8006c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ca:	89 04 24             	mov    %eax,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d0:	83 ef 01             	sub    $0x1,%edi
  8006d3:	eb 1a                	jmp    8006ef <vprintfmt+0x251>
  8006d5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006d8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006db:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006de:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006e1:	eb 0c                	jmp    8006ef <vprintfmt+0x251>
  8006e3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006e6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006ef:	83 c6 01             	add    $0x1,%esi
  8006f2:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006f6:	0f be c2             	movsbl %dl,%eax
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 27                	je     800724 <vprintfmt+0x286>
  8006fd:	85 db                	test   %ebx,%ebx
  8006ff:	78 9e                	js     80069f <vprintfmt+0x201>
  800701:	83 eb 01             	sub    $0x1,%ebx
  800704:	79 99                	jns    80069f <vprintfmt+0x201>
  800706:	89 f8                	mov    %edi,%eax
  800708:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80070b:	8b 75 08             	mov    0x8(%ebp),%esi
  80070e:	89 c3                	mov    %eax,%ebx
  800710:	eb 1a                	jmp    80072c <vprintfmt+0x28e>
				putch(' ', putdat);
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80071d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80071f:	83 eb 01             	sub    $0x1,%ebx
  800722:	eb 08                	jmp    80072c <vprintfmt+0x28e>
  800724:	89 fb                	mov    %edi,%ebx
  800726:	8b 75 08             	mov    0x8(%ebp),%esi
  800729:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80072c:	85 db                	test   %ebx,%ebx
  80072e:	7f e2                	jg     800712 <vprintfmt+0x274>
  800730:	89 75 08             	mov    %esi,0x8(%ebp)
  800733:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800736:	e9 93 fd ff ff       	jmp    8004ce <vprintfmt+0x30>
	if (lflag >= 2)
  80073b:	83 fa 01             	cmp    $0x1,%edx
  80073e:	7e 16                	jle    800756 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 50 08             	lea    0x8(%eax),%edx
  800746:	89 55 14             	mov    %edx,0x14(%ebp)
  800749:	8b 50 04             	mov    0x4(%eax),%edx
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800751:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800754:	eb 32                	jmp    800788 <vprintfmt+0x2ea>
	else if (lflag)
  800756:	85 d2                	test   %edx,%edx
  800758:	74 18                	je     800772 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8d 50 04             	lea    0x4(%eax),%edx
  800760:	89 55 14             	mov    %edx,0x14(%ebp)
  800763:	8b 30                	mov    (%eax),%esi
  800765:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800768:	89 f0                	mov    %esi,%eax
  80076a:	c1 f8 1f             	sar    $0x1f,%eax
  80076d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800770:	eb 16                	jmp    800788 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 30                	mov    (%eax),%esi
  80077d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800780:	89 f0                	mov    %esi,%eax
  800782:	c1 f8 1f             	sar    $0x1f,%eax
  800785:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800788:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80078e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800793:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800797:	0f 89 80 00 00 00    	jns    80081d <vprintfmt+0x37f>
				putch('-', putdat);
  80079d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b1:	f7 d8                	neg    %eax
  8007b3:	83 d2 00             	adc    $0x0,%edx
  8007b6:	f7 da                	neg    %edx
			base = 10;
  8007b8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007bd:	eb 5e                	jmp    80081d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c2:	e8 58 fc ff ff       	call   80041f <getuint>
			base = 10;
  8007c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007cc:	eb 4f                	jmp    80081d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d1:	e8 49 fc ff ff       	call   80041f <getuint>
            base = 8;
  8007d6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  8007db:	eb 40                	jmp    80081d <vprintfmt+0x37f>
			putch('0', putdat);
  8007dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ef:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007f6:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800809:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80080e:	eb 0d                	jmp    80081d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
  800813:	e8 07 fc ff ff       	call   80041f <getuint>
			base = 16;
  800818:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80081d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800821:	89 74 24 10          	mov    %esi,0x10(%esp)
  800825:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800828:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80082c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	89 54 24 04          	mov    %edx,0x4(%esp)
  800837:	89 fa                	mov    %edi,%edx
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	e8 ef fa ff ff       	call   800330 <printnum>
			break;
  800841:	e9 88 fc ff ff       	jmp    8004ce <vprintfmt+0x30>
			putch(ch, putdat);
  800846:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084a:	89 04 24             	mov    %eax,(%esp)
  80084d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800850:	e9 79 fc ff ff       	jmp    8004ce <vprintfmt+0x30>
			putch('%', putdat);
  800855:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800859:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800860:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800863:	89 f3                	mov    %esi,%ebx
  800865:	eb 03                	jmp    80086a <vprintfmt+0x3cc>
  800867:	83 eb 01             	sub    $0x1,%ebx
  80086a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80086e:	75 f7                	jne    800867 <vprintfmt+0x3c9>
  800870:	e9 59 fc ff ff       	jmp    8004ce <vprintfmt+0x30>
}
  800875:	83 c4 3c             	add    $0x3c,%esp
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5f                   	pop    %edi
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	83 ec 28             	sub    $0x28,%esp
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800889:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800890:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800893:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089a:	85 c0                	test   %eax,%eax
  80089c:	74 30                	je     8008ce <vsnprintf+0x51>
  80089e:	85 d2                	test   %edx,%edx
  8008a0:	7e 2c                	jle    8008ce <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	c7 04 24 59 04 80 00 	movl   $0x800459,(%esp)
  8008be:	e8 db fb ff ff       	call   80049e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cc:	eb 05                	jmp    8008d3 <vsnprintf+0x56>
		return -E_INVAL;
  8008ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	89 04 24             	mov    %eax,(%esp)
  8008f6:	e8 82 ff ff ff       	call   80087d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    
  8008fd:	66 90                	xchg   %ax,%ax
  8008ff:	90                   	nop

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	eb 03                	jmp    800910 <strlen+0x10>
		n++;
  80090d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800910:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800914:	75 f7                	jne    80090d <strlen+0xd>
	return n;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	eb 03                	jmp    80092b <strnlen+0x13>
		n++;
  800928:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092b:	39 d0                	cmp    %edx,%eax
  80092d:	74 06                	je     800935 <strnlen+0x1d>
  80092f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800933:	75 f3                	jne    800928 <strnlen+0x10>
	return n;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800941:	89 c2                	mov    %eax,%edx
  800943:	83 c2 01             	add    $0x1,%edx
  800946:	83 c1 01             	add    $0x1,%ecx
  800949:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80094d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800950:	84 db                	test   %bl,%bl
  800952:	75 ef                	jne    800943 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800954:	5b                   	pop    %ebx
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	83 ec 08             	sub    $0x8,%esp
  80095e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800961:	89 1c 24             	mov    %ebx,(%esp)
  800964:	e8 97 ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800970:	01 d8                	add    %ebx,%eax
  800972:	89 04 24             	mov    %eax,(%esp)
  800975:	e8 bd ff ff ff       	call   800937 <strcpy>
	return dst;
}
  80097a:	89 d8                	mov    %ebx,%eax
  80097c:	83 c4 08             	add    $0x8,%esp
  80097f:	5b                   	pop    %ebx
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	89 f3                	mov    %esi,%ebx
  80098f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800992:	89 f2                	mov    %esi,%edx
  800994:	eb 0f                	jmp    8009a5 <strncpy+0x23>
		*dst++ = *src;
  800996:	83 c2 01             	add    $0x1,%edx
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099f:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009a5:	39 da                	cmp    %ebx,%edx
  8009a7:	75 ed                	jne    800996 <strncpy+0x14>
	}
	return ret;
}
  8009a9:	89 f0                	mov    %esi,%eax
  8009ab:	5b                   	pop    %ebx
  8009ac:	5e                   	pop    %esi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009bd:	89 f0                	mov    %esi,%eax
  8009bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	75 0b                	jne    8009d2 <strlcpy+0x23>
  8009c7:	eb 1d                	jmp    8009e6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009d2:	39 d8                	cmp    %ebx,%eax
  8009d4:	74 0b                	je     8009e1 <strlcpy+0x32>
  8009d6:	0f b6 0a             	movzbl (%edx),%ecx
  8009d9:	84 c9                	test   %cl,%cl
  8009db:	75 ec                	jne    8009c9 <strlcpy+0x1a>
  8009dd:	89 c2                	mov    %eax,%edx
  8009df:	eb 02                	jmp    8009e3 <strlcpy+0x34>
  8009e1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  8009e3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009e6:	29 f0                	sub    %esi,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f5:	eb 06                	jmp    8009fd <strcmp+0x11>
		p++, q++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009fd:	0f b6 01             	movzbl (%ecx),%eax
  800a00:	84 c0                	test   %al,%al
  800a02:	74 04                	je     800a08 <strcmp+0x1c>
  800a04:	3a 02                	cmp    (%edx),%al
  800a06:	74 ef                	je     8009f7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 c0             	movzbl %al,%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1c:	89 c3                	mov    %eax,%ebx
  800a1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a21:	eb 06                	jmp    800a29 <strncmp+0x17>
		n--, p++, q++;
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a29:	39 d8                	cmp    %ebx,%eax
  800a2b:	74 15                	je     800a42 <strncmp+0x30>
  800a2d:	0f b6 08             	movzbl (%eax),%ecx
  800a30:	84 c9                	test   %cl,%cl
  800a32:	74 04                	je     800a38 <strncmp+0x26>
  800a34:	3a 0a                	cmp    (%edx),%cl
  800a36:	74 eb                	je     800a23 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 00             	movzbl (%eax),%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
  800a40:	eb 05                	jmp    800a47 <strncmp+0x35>
		return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a47:	5b                   	pop    %ebx
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	eb 07                	jmp    800a5d <strchr+0x13>
		if (*s == c)
  800a56:	38 ca                	cmp    %cl,%dl
  800a58:	74 0f                	je     800a69 <strchr+0x1f>
	for (; *s; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 f2                	jne    800a56 <strchr+0xc>
			return (char *) s;
	return 0;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	eb 07                	jmp    800a7e <strfind+0x13>
		if (*s == c)
  800a77:	38 ca                	cmp    %cl,%dl
  800a79:	74 0a                	je     800a85 <strfind+0x1a>
	for (; *s; s++)
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
  800a81:	84 d2                	test   %dl,%dl
  800a83:	75 f2                	jne    800a77 <strfind+0xc>
			break;
	return (char *) s;
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a93:	85 c9                	test   %ecx,%ecx
  800a95:	74 36                	je     800acd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9d:	75 28                	jne    800ac7 <memset+0x40>
  800a9f:	f6 c1 03             	test   $0x3,%cl
  800aa2:	75 23                	jne    800ac7 <memset+0x40>
		c &= 0xFF;
  800aa4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa8:	89 d3                	mov    %edx,%ebx
  800aaa:	c1 e3 08             	shl    $0x8,%ebx
  800aad:	89 d6                	mov    %edx,%esi
  800aaf:	c1 e6 18             	shl    $0x18,%esi
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	c1 e0 10             	shl    $0x10,%eax
  800ab7:	09 f0                	or     %esi,%eax
  800ab9:	09 c2                	or     %eax,%edx
  800abb:	89 d0                	mov    %edx,%eax
  800abd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800abf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ac2:	fc                   	cld    
  800ac3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac5:	eb 06                	jmp    800acd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	fc                   	cld    
  800acb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acd:	89 f8                	mov    %edi,%eax
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae2:	39 c6                	cmp    %eax,%esi
  800ae4:	73 35                	jae    800b1b <memmove+0x47>
  800ae6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae9:	39 d0                	cmp    %edx,%eax
  800aeb:	73 2e                	jae    800b1b <memmove+0x47>
		s += n;
		d += n;
  800aed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afa:	75 13                	jne    800b0f <memmove+0x3b>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 0e                	jne    800b0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b01:	83 ef 04             	sub    $0x4,%edi
  800b04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b07:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b0a:	fd                   	std    
  800b0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0d:	eb 09                	jmp    800b18 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0f:	83 ef 01             	sub    $0x1,%edi
  800b12:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b15:	fd                   	std    
  800b16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b18:	fc                   	cld    
  800b19:	eb 1d                	jmp    800b38 <memmove+0x64>
  800b1b:	89 f2                	mov    %esi,%edx
  800b1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	f6 c2 03             	test   $0x3,%dl
  800b22:	75 0f                	jne    800b33 <memmove+0x5f>
  800b24:	f6 c1 03             	test   $0x3,%cl
  800b27:	75 0a                	jne    800b33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b29:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b2c:	89 c7                	mov    %eax,%edi
  800b2e:	fc                   	cld    
  800b2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b31:	eb 05                	jmp    800b38 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	fc                   	cld    
  800b36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b42:	8b 45 10             	mov    0x10(%ebp),%eax
  800b45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	89 04 24             	mov    %eax,(%esp)
  800b56:	e8 79 ff ff ff       	call   800ad4 <memmove>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6d:	eb 1a                	jmp    800b89 <memcmp+0x2c>
		if (*s1 != *s2)
  800b6f:	0f b6 02             	movzbl (%edx),%eax
  800b72:	0f b6 19             	movzbl (%ecx),%ebx
  800b75:	38 d8                	cmp    %bl,%al
  800b77:	74 0a                	je     800b83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c0             	movzbl %al,%eax
  800b7c:	0f b6 db             	movzbl %bl,%ebx
  800b7f:	29 d8                	sub    %ebx,%eax
  800b81:	eb 0f                	jmp    800b92 <memcmp+0x35>
		s1++, s2++;
  800b83:	83 c2 01             	add    $0x1,%edx
  800b86:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800b89:	39 f2                	cmp    %esi,%edx
  800b8b:	75 e2                	jne    800b6f <memcmp+0x12>
	}

	return 0;
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b9f:	89 c2                	mov    %eax,%edx
  800ba1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba4:	eb 07                	jmp    800bad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba6:	38 08                	cmp    %cl,(%eax)
  800ba8:	74 07                	je     800bb1 <memfind+0x1b>
	for (; s < ends; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	39 d0                	cmp    %edx,%eax
  800baf:	72 f5                	jb     800ba6 <memfind+0x10>
			break;
	return (void *) s;
}
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbf:	eb 03                	jmp    800bc4 <strtol+0x11>
		s++;
  800bc1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bc4:	0f b6 0a             	movzbl (%edx),%ecx
  800bc7:	80 f9 09             	cmp    $0x9,%cl
  800bca:	74 f5                	je     800bc1 <strtol+0xe>
  800bcc:	80 f9 20             	cmp    $0x20,%cl
  800bcf:	74 f0                	je     800bc1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bd1:	80 f9 2b             	cmp    $0x2b,%cl
  800bd4:	75 0a                	jne    800be0 <strtol+0x2d>
		s++;
  800bd6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bd9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bde:	eb 11                	jmp    800bf1 <strtol+0x3e>
  800be0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800be5:	80 f9 2d             	cmp    $0x2d,%cl
  800be8:	75 07                	jne    800bf1 <strtol+0x3e>
		s++, neg = 1;
  800bea:	8d 52 01             	lea    0x1(%edx),%edx
  800bed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bf6:	75 15                	jne    800c0d <strtol+0x5a>
  800bf8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfb:	75 10                	jne    800c0d <strtol+0x5a>
  800bfd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c01:	75 0a                	jne    800c0d <strtol+0x5a>
		s += 2, base = 16;
  800c03:	83 c2 02             	add    $0x2,%edx
  800c06:	b8 10 00 00 00       	mov    $0x10,%eax
  800c0b:	eb 10                	jmp    800c1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	75 0c                	jne    800c1d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c11:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c13:	80 3a 30             	cmpb   $0x30,(%edx)
  800c16:	75 05                	jne    800c1d <strtol+0x6a>
		s++, base = 8;
  800c18:	83 c2 01             	add    $0x1,%edx
  800c1b:	b0 08                	mov    $0x8,%al
		base = 10;
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c25:	0f b6 0a             	movzbl (%edx),%ecx
  800c28:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c2b:	89 f0                	mov    %esi,%eax
  800c2d:	3c 09                	cmp    $0x9,%al
  800c2f:	77 08                	ja     800c39 <strtol+0x86>
			dig = *s - '0';
  800c31:	0f be c9             	movsbl %cl,%ecx
  800c34:	83 e9 30             	sub    $0x30,%ecx
  800c37:	eb 20                	jmp    800c59 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c39:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c3c:	89 f0                	mov    %esi,%eax
  800c3e:	3c 19                	cmp    $0x19,%al
  800c40:	77 08                	ja     800c4a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c42:	0f be c9             	movsbl %cl,%ecx
  800c45:	83 e9 57             	sub    $0x57,%ecx
  800c48:	eb 0f                	jmp    800c59 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c4a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c4d:	89 f0                	mov    %esi,%eax
  800c4f:	3c 19                	cmp    $0x19,%al
  800c51:	77 16                	ja     800c69 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c53:	0f be c9             	movsbl %cl,%ecx
  800c56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c5c:	7d 0f                	jge    800c6d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c5e:	83 c2 01             	add    $0x1,%edx
  800c61:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c65:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c67:	eb bc                	jmp    800c25 <strtol+0x72>
  800c69:	89 d8                	mov    %ebx,%eax
  800c6b:	eb 02                	jmp    800c6f <strtol+0xbc>
  800c6d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c73:	74 05                	je     800c7a <strtol+0xc7>
		*endptr = (char *) s;
  800c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c78:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c7a:	f7 d8                	neg    %eax
  800c7c:	85 ff                	test   %edi,%edi
  800c7e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 c3                	mov    %eax,%ebx
  800c99:	89 c7                	mov    %eax,%edi
  800c9b:	89 c6                	mov    %eax,%esi
  800c9d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ccc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 cb                	mov    %ecx,%ebx
  800cdb:	89 cf                	mov    %ecx,%edi
  800cdd:	89 ce                	mov    %ecx,%esi
  800cdf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 28                	jle    800d0d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d00:	00 
  800d01:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800d08:	e8 0b f5 ff ff       	call   800218 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0d:	83 c4 2c             	add    $0x2c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d20:	b8 02 00 00 00       	mov    $0x2,%eax
  800d25:	89 d1                	mov    %edx,%ecx
  800d27:	89 d3                	mov    %edx,%ebx
  800d29:	89 d7                	mov    %edx,%edi
  800d2b:	89 d6                	mov    %edx,%esi
  800d2d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_yield>:

void
sys_yield(void)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d44:	89 d1                	mov    %edx,%ecx
  800d46:	89 d3                	mov    %edx,%ebx
  800d48:	89 d7                	mov    %edx,%edi
  800d4a:	89 d6                	mov    %edx,%esi
  800d4c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d5c:	be 00 00 00 00       	mov    $0x0,%esi
  800d61:	b8 04 00 00 00       	mov    $0x4,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6f:	89 f7                	mov    %esi,%edi
  800d71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 28                	jle    800d9f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d82:	00 
  800d83:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800d8a:	00 
  800d8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d92:	00 
  800d93:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800d9a:	e8 79 f4 ff ff       	call   800218 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d9f:	83 c4 2c             	add    $0x2c,%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800db0:	b8 05 00 00 00       	mov    $0x5,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800dc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 28                	jle    800df2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800ddd:	00 
  800dde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de5:	00 
  800de6:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800ded:	e8 26 f4 ff ff       	call   800218 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df2:	83 c4 2c             	add    $0x2c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 df                	mov    %ebx,%edi
  800e15:	89 de                	mov    %ebx,%esi
  800e17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 28                	jle    800e45 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e21:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e28:	00 
  800e29:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800e30:	00 
  800e31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e38:	00 
  800e39:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800e40:	e8 d3 f3 ff ff       	call   800218 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e45:	83 c4 2c             	add    $0x2c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	89 df                	mov    %ebx,%edi
  800e68:	89 de                	mov    %ebx,%esi
  800e6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7e 28                	jle    800e98 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e74:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800e93:	e8 80 f3 ff ff       	call   800218 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e98:	83 c4 2c             	add    $0x2c,%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eae:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 de                	mov    %ebx,%esi
  800ebd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7e 28                	jle    800eeb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ece:	00 
  800ecf:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800ee6:	e8 2d f3 ff ff       	call   800218 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eeb:	83 c4 2c             	add    $0x2c,%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800efc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	89 df                	mov    %ebx,%edi
  800f0e:	89 de                	mov    %ebx,%esi
  800f10:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f12:	85 c0                	test   %eax,%eax
  800f14:	7e 28                	jle    800f3e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f21:	00 
  800f22:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800f39:	e8 da f2 ff ff       	call   800218 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f3e:	83 c4 2c             	add    $0x2c,%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f4c:	be 00 00 00 00       	mov    $0x0,%esi
  800f51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f62:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	89 cb                	mov    %ecx,%ebx
  800f81:	89 cf                	mov    %ecx,%edi
  800f83:	89 ce                	mov    %ecx,%esi
  800f85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	7e 28                	jle    800fb3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f96:	00 
  800f97:	c7 44 24 08 ff 2e 80 	movl   $0x802eff,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  800fae:	e8 65 f2 ff ff       	call   800218 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb3:	83 c4 2c             	add    $0x2c,%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
  800fbb:	66 90                	xchg   %ax,%ax
  800fbd:	66 90                	xchg   %ax,%ax
  800fbf:	90                   	nop

00800fc0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 24             	sub    $0x24,%esp
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  800fca:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  800fcc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fd0:	74 18                	je     800fea <pgfault+0x2a>
  800fd2:	89 d8                	mov    %ebx,%eax
  800fd4:	c1 e8 0c             	shr    $0xc,%eax
  800fd7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fde:	25 05 08 00 00       	and    $0x805,%eax
  800fe3:	3d 05 08 00 00       	cmp    $0x805,%eax
  800fe8:	74 1c                	je     801006 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  800fea:	c7 44 24 08 2c 2f 80 	movl   $0x802f2c,0x8(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800ff9:	00 
  800ffa:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  801001:	e8 12 f2 ff ff       	call   800218 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  801006:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80100d:	00 
  80100e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801015:	00 
  801016:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101d:	e8 31 fd ff ff       	call   800d53 <sys_page_alloc>
	if(r < 0){
  801022:	85 c0                	test   %eax,%eax
  801024:	79 1c                	jns    801042 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  801026:	c7 44 24 08 5c 2f 80 	movl   $0x802f5c,0x8(%esp)
  80102d:	00 
  80102e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  80103d:	e8 d6 f1 ff ff       	call   800218 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801042:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801048:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80104f:	00 
  801050:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801054:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80105b:	e8 dc fa ff ff       	call   800b3c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  801060:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801067:	00 
  801068:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80106c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801073:	00 
  801074:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80107b:	00 
  80107c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801083:	e8 1f fd ff ff       	call   800da7 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  801088:	85 c0                	test   %eax,%eax
  80108a:	79 1c                	jns    8010a8 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  80108c:	c7 44 24 08 28 30 80 	movl   $0x803028,0x8(%esp)
  801093:	00 
  801094:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80109b:	00 
  80109c:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8010a3:	e8 70 f1 ff ff       	call   800218 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  8010a8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010af:	00 
  8010b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b7:	e8 3e fd ff ff       	call   800dfa <sys_page_unmap>
    if(r < 0){
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	79 1c                	jns    8010dc <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  8010c0:	c7 44 24 08 3f 30 80 	movl   $0x80303f,0x8(%esp)
  8010c7:	00 
  8010c8:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8010cf:	00 
  8010d0:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8010d7:	e8 3c f1 ff ff       	call   800218 <_panic>
    }
    // LAB 4
}
  8010dc:	83 c4 24             	add    $0x24,%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  8010eb:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  8010f2:	e8 7f 15 00 00       	call   802676 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010f7:	b8 07 00 00 00       	mov    $0x7,%eax
  8010fc:	cd 30                	int    $0x30
  8010fe:	89 c7                	mov    %eax,%edi
  801100:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801103:	85 c0                	test   %eax,%eax
  801105:	79 1c                	jns    801123 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801107:	c7 44 24 08 58 30 80 	movl   $0x803058,0x8(%esp)
  80110e:	00 
  80110f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801116:	00 
  801117:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  80111e:	e8 f5 f0 ff ff       	call   800218 <_panic>
    }
    if(child == 0){
  801123:	bb 00 00 00 00       	mov    $0x0,%ebx
  801128:	85 c0                	test   %eax,%eax
  80112a:	75 21                	jne    80114d <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80112c:	e8 e4 fb ff ff       	call   800d15 <sys_getenvid>
  801131:	25 ff 03 00 00       	and    $0x3ff,%eax
  801136:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801139:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80113e:	a3 08 50 80 00       	mov    %eax,0x805008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
  801148:	e9 67 01 00 00       	jmp    8012b4 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  80114d:	89 d8                	mov    %ebx,%eax
  80114f:	c1 e8 16             	shr    $0x16,%eax
  801152:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801159:	a8 01                	test   $0x1,%al
  80115b:	74 4b                	je     8011a8 <fork+0xc6>
  80115d:	89 de                	mov    %ebx,%esi
  80115f:	c1 ee 0c             	shr    $0xc,%esi
  801162:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801169:	a8 01                	test   $0x1,%al
  80116b:	74 3b                	je     8011a8 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  80116d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801174:	a9 02 08 00 00       	test   $0x802,%eax
  801179:	0f 85 02 01 00 00    	jne    801281 <fork+0x19f>
  80117f:	e9 d2 00 00 00       	jmp    801256 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  801184:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80118b:	00 
  80118c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801190:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801197:	00 
  801198:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a3:	e8 ff fb ff ff       	call   800da7 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  8011a8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011ae:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011b4:	75 97                	jne    80114d <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  8011b6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011c5:	ee 
  8011c6:	89 3c 24             	mov    %edi,(%esp)
  8011c9:	e8 85 fb ff ff       	call   800d53 <sys_page_alloc>

    if(r < 0){
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	79 1c                	jns    8011ee <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  8011d2:	c7 44 24 08 90 2f 80 	movl   $0x802f90,0x8(%esp)
  8011d9:	00 
  8011da:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  8011e1:	00 
  8011e2:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8011e9:	e8 2a f0 ff ff       	call   800218 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  8011ee:	a1 08 50 80 00       	mov    0x805008,%eax
  8011f3:	8b 40 64             	mov    0x64(%eax),%eax
  8011f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fa:	89 3c 24             	mov    %edi,(%esp)
  8011fd:	e8 f1 fc ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801202:	85 c0                	test   %eax,%eax
  801204:	79 1c                	jns    801222 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801206:	c7 44 24 08 b0 2f 80 	movl   $0x802fb0,0x8(%esp)
  80120d:	00 
  80120e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801215:	00 
  801216:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  80121d:	e8 f6 ef ff ff       	call   800218 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801222:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801229:	00 
  80122a:	89 3c 24             	mov    %edi,(%esp)
  80122d:	e8 1b fc ff ff       	call   800e4d <sys_env_set_status>
    if(r < 0){
  801232:	85 c0                	test   %eax,%eax
  801234:	79 1c                	jns    801252 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801236:	c7 44 24 08 d8 2f 80 	movl   $0x802fd8,0x8(%esp)
  80123d:	00 
  80123e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  801245:	00 
  801246:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  80124d:	e8 c6 ef ff ff       	call   800218 <_panic>
    }
    return child;
  801252:	89 f8                	mov    %edi,%eax
  801254:	eb 5e                	jmp    8012b4 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  801256:	c1 e6 0c             	shl    $0xc,%esi
  801259:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801260:	00 
  801261:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801268:	89 44 24 08          	mov    %eax,0x8(%esp)
  80126c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801270:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801277:	e8 2b fb ff ff       	call   800da7 <sys_page_map>
  80127c:	e9 27 ff ff ff       	jmp    8011a8 <fork+0xc6>
  801281:	c1 e6 0c             	shl    $0xc,%esi
  801284:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80128b:	00 
  80128c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801293:	89 44 24 08          	mov    %eax,0x8(%esp)
  801297:	89 74 24 04          	mov    %esi,0x4(%esp)
  80129b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a2:	e8 00 fb ff ff       	call   800da7 <sys_page_map>
    if( r < 0 ){
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	0f 89 d5 fe ff ff    	jns    801184 <fork+0xa2>
  8012af:	e9 f4 fe ff ff       	jmp    8011a8 <fork+0xc6>
//	panic("fork not implemented");
}
  8012b4:	83 c4 2c             	add    $0x2c,%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5f                   	pop    %edi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <sfork>:

// Challenge!
int
sfork(void)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012c2:	c7 44 24 08 75 30 80 	movl   $0x803075,0x8(%esp)
  8012c9:	00 
  8012ca:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  8012d1:	00 
  8012d2:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8012d9:	e8 3a ef ff ff       	call   800218 <_panic>
  8012de:	66 90                	xchg   %ax,%ax

008012e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801300:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801312:	89 c2                	mov    %eax,%edx
  801314:	c1 ea 16             	shr    $0x16,%edx
  801317:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80131e:	f6 c2 01             	test   $0x1,%dl
  801321:	74 11                	je     801334 <fd_alloc+0x2d>
  801323:	89 c2                	mov    %eax,%edx
  801325:	c1 ea 0c             	shr    $0xc,%edx
  801328:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132f:	f6 c2 01             	test   $0x1,%dl
  801332:	75 09                	jne    80133d <fd_alloc+0x36>
			*fd_store = fd;
  801334:	89 01                	mov    %eax,(%ecx)
			return 0;
  801336:	b8 00 00 00 00       	mov    $0x0,%eax
  80133b:	eb 17                	jmp    801354 <fd_alloc+0x4d>
  80133d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801342:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801347:	75 c9                	jne    801312 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801349:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80134f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80135c:	83 f8 1f             	cmp    $0x1f,%eax
  80135f:	77 36                	ja     801397 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801361:	c1 e0 0c             	shl    $0xc,%eax
  801364:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801369:	89 c2                	mov    %eax,%edx
  80136b:	c1 ea 16             	shr    $0x16,%edx
  80136e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801375:	f6 c2 01             	test   $0x1,%dl
  801378:	74 24                	je     80139e <fd_lookup+0x48>
  80137a:	89 c2                	mov    %eax,%edx
  80137c:	c1 ea 0c             	shr    $0xc,%edx
  80137f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801386:	f6 c2 01             	test   $0x1,%dl
  801389:	74 1a                	je     8013a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80138b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138e:	89 02                	mov    %eax,(%edx)
	return 0;
  801390:	b8 00 00 00 00       	mov    $0x0,%eax
  801395:	eb 13                	jmp    8013aa <fd_lookup+0x54>
		return -E_INVAL;
  801397:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139c:	eb 0c                	jmp    8013aa <fd_lookup+0x54>
		return -E_INVAL;
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a3:	eb 05                	jmp    8013aa <fd_lookup+0x54>
  8013a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 18             	sub    $0x18,%esp
  8013b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b5:	ba 08 31 80 00       	mov    $0x803108,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ba:	eb 13                	jmp    8013cf <dev_lookup+0x23>
  8013bc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013bf:	39 08                	cmp    %ecx,(%eax)
  8013c1:	75 0c                	jne    8013cf <dev_lookup+0x23>
			*dev = devtab[i];
  8013c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cd:	eb 30                	jmp    8013ff <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8013cf:	8b 02                	mov    (%edx),%eax
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	75 e7                	jne    8013bc <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d5:	a1 08 50 80 00       	mov    0x805008,%eax
  8013da:	8b 40 48             	mov    0x48(%eax),%eax
  8013dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e5:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  8013ec:	e8 20 ef ff ff       	call   800311 <cprintf>
	*dev = 0;
  8013f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <fd_close>:
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	56                   	push   %esi
  801405:	53                   	push   %ebx
  801406:	83 ec 20             	sub    $0x20,%esp
  801409:	8b 75 08             	mov    0x8(%ebp),%esi
  80140c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80140f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801412:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801416:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80141c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 2f ff ff ff       	call   801356 <fd_lookup>
  801427:	85 c0                	test   %eax,%eax
  801429:	78 05                	js     801430 <fd_close+0x2f>
	    || fd != fd2)
  80142b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80142e:	74 0c                	je     80143c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801430:	84 db                	test   %bl,%bl
  801432:	ba 00 00 00 00       	mov    $0x0,%edx
  801437:	0f 44 c2             	cmove  %edx,%eax
  80143a:	eb 3f                	jmp    80147b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80143c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801443:	8b 06                	mov    (%esi),%eax
  801445:	89 04 24             	mov    %eax,(%esp)
  801448:	e8 5f ff ff ff       	call   8013ac <dev_lookup>
  80144d:	89 c3                	mov    %eax,%ebx
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 16                	js     801469 <fd_close+0x68>
		if (dev->dev_close)
  801453:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801456:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801459:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80145e:	85 c0                	test   %eax,%eax
  801460:	74 07                	je     801469 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801462:	89 34 24             	mov    %esi,(%esp)
  801465:	ff d0                	call   *%eax
  801467:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801469:	89 74 24 04          	mov    %esi,0x4(%esp)
  80146d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801474:	e8 81 f9 ff ff       	call   800dfa <sys_page_unmap>
	return r;
  801479:	89 d8                	mov    %ebx,%eax
}
  80147b:	83 c4 20             	add    $0x20,%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <close>:

int
close(int fdnum)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	e8 bc fe ff ff       	call   801356 <fd_lookup>
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	85 d2                	test   %edx,%edx
  80149e:	78 13                	js     8014b3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8014a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014a7:	00 
  8014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ab:	89 04 24             	mov    %eax,(%esp)
  8014ae:	e8 4e ff ff ff       	call   801401 <fd_close>
}
  8014b3:	c9                   	leave  
  8014b4:	c3                   	ret    

008014b5 <close_all>:

void
close_all(void)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014c1:	89 1c 24             	mov    %ebx,(%esp)
  8014c4:	e8 b9 ff ff ff       	call   801482 <close>
	for (i = 0; i < MAXFD; i++)
  8014c9:	83 c3 01             	add    $0x1,%ebx
  8014cc:	83 fb 20             	cmp    $0x20,%ebx
  8014cf:	75 f0                	jne    8014c1 <close_all+0xc>
}
  8014d1:	83 c4 14             	add    $0x14,%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	57                   	push   %edi
  8014db:	56                   	push   %esi
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ea:	89 04 24             	mov    %eax,(%esp)
  8014ed:	e8 64 fe ff ff       	call   801356 <fd_lookup>
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	85 d2                	test   %edx,%edx
  8014f6:	0f 88 e1 00 00 00    	js     8015dd <dup+0x106>
		return r;
	close(newfdnum);
  8014fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ff:	89 04 24             	mov    %eax,(%esp)
  801502:	e8 7b ff ff ff       	call   801482 <close>

	newfd = INDEX2FD(newfdnum);
  801507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80150a:	c1 e3 0c             	shl    $0xc,%ebx
  80150d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801516:	89 04 24             	mov    %eax,(%esp)
  801519:	e8 d2 fd ff ff       	call   8012f0 <fd2data>
  80151e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801520:	89 1c 24             	mov    %ebx,(%esp)
  801523:	e8 c8 fd ff ff       	call   8012f0 <fd2data>
  801528:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80152a:	89 f0                	mov    %esi,%eax
  80152c:	c1 e8 16             	shr    $0x16,%eax
  80152f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801536:	a8 01                	test   $0x1,%al
  801538:	74 43                	je     80157d <dup+0xa6>
  80153a:	89 f0                	mov    %esi,%eax
  80153c:	c1 e8 0c             	shr    $0xc,%eax
  80153f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801546:	f6 c2 01             	test   $0x1,%dl
  801549:	74 32                	je     80157d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80154b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801552:	25 07 0e 00 00       	and    $0xe07,%eax
  801557:	89 44 24 10          	mov    %eax,0x10(%esp)
  80155b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80155f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801566:	00 
  801567:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801572:	e8 30 f8 ff ff       	call   800da7 <sys_page_map>
  801577:	89 c6                	mov    %eax,%esi
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 3e                	js     8015bb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801580:	89 c2                	mov    %eax,%edx
  801582:	c1 ea 0c             	shr    $0xc,%edx
  801585:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801592:	89 54 24 10          	mov    %edx,0x10(%esp)
  801596:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80159a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a1:	00 
  8015a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ad:	e8 f5 f7 ff ff       	call   800da7 <sys_page_map>
  8015b2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8015b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b7:	85 f6                	test   %esi,%esi
  8015b9:	79 22                	jns    8015dd <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8015bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c6:	e8 2f f8 ff ff       	call   800dfa <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d6:	e8 1f f8 ff ff       	call   800dfa <sys_page_unmap>
	return r;
  8015db:	89 f0                	mov    %esi,%eax
}
  8015dd:	83 c4 3c             	add    $0x3c,%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5f                   	pop    %edi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 24             	sub    $0x24,%esp
  8015ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f6:	89 1c 24             	mov    %ebx,(%esp)
  8015f9:	e8 58 fd ff ff       	call   801356 <fd_lookup>
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	85 d2                	test   %edx,%edx
  801602:	78 6d                	js     801671 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160e:	8b 00                	mov    (%eax),%eax
  801610:	89 04 24             	mov    %eax,(%esp)
  801613:	e8 94 fd ff ff       	call   8013ac <dev_lookup>
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 55                	js     801671 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	8b 50 08             	mov    0x8(%eax),%edx
  801622:	83 e2 03             	and    $0x3,%edx
  801625:	83 fa 01             	cmp    $0x1,%edx
  801628:	75 23                	jne    80164d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80162a:	a1 08 50 80 00       	mov    0x805008,%eax
  80162f:	8b 40 48             	mov    0x48(%eax),%eax
  801632:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	c7 04 24 cd 30 80 00 	movl   $0x8030cd,(%esp)
  801641:	e8 cb ec ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  801646:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164b:	eb 24                	jmp    801671 <read+0x8c>
	}
	if (!dev->dev_read)
  80164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801650:	8b 52 08             	mov    0x8(%edx),%edx
  801653:	85 d2                	test   %edx,%edx
  801655:	74 15                	je     80166c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801657:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80165a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80165e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801661:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	ff d2                	call   *%edx
  80166a:	eb 05                	jmp    801671 <read+0x8c>
		return -E_NOT_SUPP;
  80166c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801671:	83 c4 24             	add    $0x24,%esp
  801674:	5b                   	pop    %ebx
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	57                   	push   %edi
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	83 ec 1c             	sub    $0x1c,%esp
  801680:	8b 7d 08             	mov    0x8(%ebp),%edi
  801683:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801686:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168b:	eb 23                	jmp    8016b0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80168d:	89 f0                	mov    %esi,%eax
  80168f:	29 d8                	sub    %ebx,%eax
  801691:	89 44 24 08          	mov    %eax,0x8(%esp)
  801695:	89 d8                	mov    %ebx,%eax
  801697:	03 45 0c             	add    0xc(%ebp),%eax
  80169a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169e:	89 3c 24             	mov    %edi,(%esp)
  8016a1:	e8 3f ff ff ff       	call   8015e5 <read>
		if (m < 0)
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 10                	js     8016ba <readn+0x43>
			return m;
		if (m == 0)
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	74 0a                	je     8016b8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8016ae:	01 c3                	add    %eax,%ebx
  8016b0:	39 f3                	cmp    %esi,%ebx
  8016b2:	72 d9                	jb     80168d <readn+0x16>
  8016b4:	89 d8                	mov    %ebx,%eax
  8016b6:	eb 02                	jmp    8016ba <readn+0x43>
  8016b8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016ba:	83 c4 1c             	add    $0x1c,%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5f                   	pop    %edi
  8016c0:	5d                   	pop    %ebp
  8016c1:	c3                   	ret    

008016c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 24             	sub    $0x24,%esp
  8016c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d3:	89 1c 24             	mov    %ebx,(%esp)
  8016d6:	e8 7b fc ff ff       	call   801356 <fd_lookup>
  8016db:	89 c2                	mov    %eax,%edx
  8016dd:	85 d2                	test   %edx,%edx
  8016df:	78 68                	js     801749 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016eb:	8b 00                	mov    (%eax),%eax
  8016ed:	89 04 24             	mov    %eax,(%esp)
  8016f0:	e8 b7 fc ff ff       	call   8013ac <dev_lookup>
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 50                	js     801749 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801700:	75 23                	jne    801725 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801702:	a1 08 50 80 00       	mov    0x805008,%eax
  801707:	8b 40 48             	mov    0x48(%eax),%eax
  80170a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80170e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801712:	c7 04 24 e9 30 80 00 	movl   $0x8030e9,(%esp)
  801719:	e8 f3 eb ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  80171e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801723:	eb 24                	jmp    801749 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801725:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801728:	8b 52 0c             	mov    0xc(%edx),%edx
  80172b:	85 d2                	test   %edx,%edx
  80172d:	74 15                	je     801744 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80172f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801732:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801739:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80173d:	89 04 24             	mov    %eax,(%esp)
  801740:	ff d2                	call   *%edx
  801742:	eb 05                	jmp    801749 <write+0x87>
		return -E_NOT_SUPP;
  801744:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801749:	83 c4 24             	add    $0x24,%esp
  80174c:	5b                   	pop    %ebx
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <seek>:

int
seek(int fdnum, off_t offset)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801755:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
  80175f:	89 04 24             	mov    %eax,(%esp)
  801762:	e8 ef fb ff ff       	call   801356 <fd_lookup>
  801767:	85 c0                	test   %eax,%eax
  801769:	78 0e                	js     801779 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80176b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80176e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801771:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801774:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 24             	sub    $0x24,%esp
  801782:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801785:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178c:	89 1c 24             	mov    %ebx,(%esp)
  80178f:	e8 c2 fb ff ff       	call   801356 <fd_lookup>
  801794:	89 c2                	mov    %eax,%edx
  801796:	85 d2                	test   %edx,%edx
  801798:	78 61                	js     8017fb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a4:	8b 00                	mov    (%eax),%eax
  8017a6:	89 04 24             	mov    %eax,(%esp)
  8017a9:	e8 fe fb ff ff       	call   8013ac <dev_lookup>
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 49                	js     8017fb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b9:	75 23                	jne    8017de <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017bb:	a1 08 50 80 00       	mov    0x805008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c0:	8b 40 48             	mov    0x48(%eax),%eax
  8017c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cb:	c7 04 24 ac 30 80 00 	movl   $0x8030ac,(%esp)
  8017d2:	e8 3a eb ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  8017d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017dc:	eb 1d                	jmp    8017fb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8017de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e1:	8b 52 18             	mov    0x18(%edx),%edx
  8017e4:	85 d2                	test   %edx,%edx
  8017e6:	74 0e                	je     8017f6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	ff d2                	call   *%edx
  8017f4:	eb 05                	jmp    8017fb <ftruncate+0x80>
		return -E_NOT_SUPP;
  8017f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017fb:	83 c4 24             	add    $0x24,%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	53                   	push   %ebx
  801805:	83 ec 24             	sub    $0x24,%esp
  801808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	89 04 24             	mov    %eax,(%esp)
  801818:	e8 39 fb ff ff       	call   801356 <fd_lookup>
  80181d:	89 c2                	mov    %eax,%edx
  80181f:	85 d2                	test   %edx,%edx
  801821:	78 52                	js     801875 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182d:	8b 00                	mov    (%eax),%eax
  80182f:	89 04 24             	mov    %eax,(%esp)
  801832:	e8 75 fb ff ff       	call   8013ac <dev_lookup>
  801837:	85 c0                	test   %eax,%eax
  801839:	78 3a                	js     801875 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801842:	74 2c                	je     801870 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801844:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801847:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80184e:	00 00 00 
	stat->st_isdir = 0;
  801851:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801858:	00 00 00 
	stat->st_dev = dev;
  80185b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801861:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801865:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801868:	89 14 24             	mov    %edx,(%esp)
  80186b:	ff 50 14             	call   *0x14(%eax)
  80186e:	eb 05                	jmp    801875 <fstat+0x74>
		return -E_NOT_SUPP;
  801870:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801875:	83 c4 24             	add    $0x24,%esp
  801878:	5b                   	pop    %ebx
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	56                   	push   %esi
  80187f:	53                   	push   %ebx
  801880:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801883:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80188a:	00 
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	89 04 24             	mov    %eax,(%esp)
  801891:	e8 fb 01 00 00       	call   801a91 <open>
  801896:	89 c3                	mov    %eax,%ebx
  801898:	85 db                	test   %ebx,%ebx
  80189a:	78 1b                	js     8018b7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80189c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	89 1c 24             	mov    %ebx,(%esp)
  8018a6:	e8 56 ff ff ff       	call   801801 <fstat>
  8018ab:	89 c6                	mov    %eax,%esi
	close(fd);
  8018ad:	89 1c 24             	mov    %ebx,(%esp)
  8018b0:	e8 cd fb ff ff       	call   801482 <close>
	return r;
  8018b5:	89 f0                	mov    %esi,%eax
}
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 10             	sub    $0x10,%esp
  8018c6:	89 c6                	mov    %eax,%esi
  8018c8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018ca:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8018d1:	75 11                	jne    8018e4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018da:	e8 20 0f 00 00       	call   8027ff <ipc_find_env>
  8018df:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018eb:	00 
  8018ec:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8018f3:	00 
  8018f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f8:	a1 04 50 80 00       	mov    0x805004,%eax
  8018fd:	89 04 24             	mov    %eax,(%esp)
  801900:	e8 93 0e 00 00       	call   802798 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801905:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80190c:	00 
  80190d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801911:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801918:	e8 13 0e 00 00       	call   802730 <ipc_recv>
}
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 40 0c             	mov    0xc(%eax),%eax
  801930:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801935:	8b 45 0c             	mov    0xc(%ebp),%eax
  801938:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80193d:	ba 00 00 00 00       	mov    $0x0,%edx
  801942:	b8 02 00 00 00       	mov    $0x2,%eax
  801947:	e8 72 ff ff ff       	call   8018be <fsipc>
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <devfile_flush>:
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	8b 40 0c             	mov    0xc(%eax),%eax
  80195a:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80195f:	ba 00 00 00 00       	mov    $0x0,%edx
  801964:	b8 06 00 00 00       	mov    $0x6,%eax
  801969:	e8 50 ff ff ff       	call   8018be <fsipc>
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devfile_stat>:
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	53                   	push   %ebx
  801974:	83 ec 14             	sub    $0x14,%esp
  801977:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	8b 40 0c             	mov    0xc(%eax),%eax
  801980:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801985:	ba 00 00 00 00       	mov    $0x0,%edx
  80198a:	b8 05 00 00 00       	mov    $0x5,%eax
  80198f:	e8 2a ff ff ff       	call   8018be <fsipc>
  801994:	89 c2                	mov    %eax,%edx
  801996:	85 d2                	test   %edx,%edx
  801998:	78 2b                	js     8019c5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80199a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8019a1:	00 
  8019a2:	89 1c 24             	mov    %ebx,(%esp)
  8019a5:	e8 8d ef ff ff       	call   800937 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019aa:	a1 80 60 80 00       	mov    0x806080,%eax
  8019af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019b5:	a1 84 60 80 00       	mov    0x806084,%eax
  8019ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c5:	83 c4 14             	add    $0x14,%esp
  8019c8:	5b                   	pop    %ebx
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <devfile_write>:
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  8019d1:	c7 44 24 08 18 31 80 	movl   $0x803118,0x8(%esp)
  8019d8:	00 
  8019d9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8019e0:	00 
  8019e1:	c7 04 24 36 31 80 00 	movl   $0x803136,(%esp)
  8019e8:	e8 2b e8 ff ff       	call   800218 <_panic>

008019ed <devfile_read>:
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 10             	sub    $0x10,%esp
  8019f5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a03:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a09:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a13:	e8 a6 fe ff ff       	call   8018be <fsipc>
  801a18:	89 c3                	mov    %eax,%ebx
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 6a                	js     801a88 <devfile_read+0x9b>
	assert(r <= n);
  801a1e:	39 c6                	cmp    %eax,%esi
  801a20:	73 24                	jae    801a46 <devfile_read+0x59>
  801a22:	c7 44 24 0c 41 31 80 	movl   $0x803141,0xc(%esp)
  801a29:	00 
  801a2a:	c7 44 24 08 48 31 80 	movl   $0x803148,0x8(%esp)
  801a31:	00 
  801a32:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a39:	00 
  801a3a:	c7 04 24 36 31 80 00 	movl   $0x803136,(%esp)
  801a41:	e8 d2 e7 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801a46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4b:	7e 24                	jle    801a71 <devfile_read+0x84>
  801a4d:	c7 44 24 0c 5d 31 80 	movl   $0x80315d,0xc(%esp)
  801a54:	00 
  801a55:	c7 44 24 08 48 31 80 	movl   $0x803148,0x8(%esp)
  801a5c:	00 
  801a5d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a64:	00 
  801a65:	c7 04 24 36 31 80 00 	movl   $0x803136,(%esp)
  801a6c:	e8 a7 e7 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a75:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a7c:	00 
  801a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a80:	89 04 24             	mov    %eax,(%esp)
  801a83:	e8 4c f0 ff ff       	call   800ad4 <memmove>
}
  801a88:	89 d8                	mov    %ebx,%eax
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <open>:
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	53                   	push   %ebx
  801a95:	83 ec 24             	sub    $0x24,%esp
  801a98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a9b:	89 1c 24             	mov    %ebx,(%esp)
  801a9e:	e8 5d ee ff ff       	call   800900 <strlen>
  801aa3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aa8:	7f 60                	jg     801b0a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801aaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aad:	89 04 24             	mov    %eax,(%esp)
  801ab0:	e8 52 f8 ff ff       	call   801307 <fd_alloc>
  801ab5:	89 c2                	mov    %eax,%edx
  801ab7:	85 d2                	test   %edx,%edx
  801ab9:	78 54                	js     801b0f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801abb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801abf:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801ac6:	e8 6c ee ff ff       	call   800937 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ace:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ad3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad6:	b8 01 00 00 00       	mov    $0x1,%eax
  801adb:	e8 de fd ff ff       	call   8018be <fsipc>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	79 17                	jns    801afd <open+0x6c>
		fd_close(fd, 0);
  801ae6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aed:	00 
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	89 04 24             	mov    %eax,(%esp)
  801af4:	e8 08 f9 ff ff       	call   801401 <fd_close>
		return r;
  801af9:	89 d8                	mov    %ebx,%eax
  801afb:	eb 12                	jmp    801b0f <open+0x7e>
	return fd2num(fd);
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	89 04 24             	mov    %eax,(%esp)
  801b03:	e8 d8 f7 ff ff       	call   8012e0 <fd2num>
  801b08:	eb 05                	jmp    801b0f <open+0x7e>
		return -E_BAD_PATH;
  801b0a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801b0f:	83 c4 24             	add    $0x24,%esp
  801b12:	5b                   	pop    %ebx
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b20:	b8 08 00 00 00       	mov    $0x8,%eax
  801b25:	e8 94 fd ff ff       	call   8018be <fsipc>
}
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    
  801b2c:	66 90                	xchg   %ax,%ax
  801b2e:	66 90                	xchg   %ax,%ax

00801b30 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	57                   	push   %edi
  801b34:	56                   	push   %esi
  801b35:	53                   	push   %ebx
  801b36:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801b3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b43:	00 
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	89 04 24             	mov    %eax,(%esp)
  801b4a:	e8 42 ff ff ff       	call   801a91 <open>
  801b4f:	89 c1                	mov    %eax,%ecx
  801b51:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801b57:	85 c0                	test   %eax,%eax
  801b59:	0f 88 a8 04 00 00    	js     802007 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801b5f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801b66:	00 
  801b67:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b71:	89 0c 24             	mov    %ecx,(%esp)
  801b74:	e8 fe fa ff ff       	call   801677 <readn>
  801b79:	3d 00 02 00 00       	cmp    $0x200,%eax
  801b7e:	75 0c                	jne    801b8c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801b80:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801b87:	45 4c 46 
  801b8a:	74 36                	je     801bc2 <spawn+0x92>
		close(fd);
  801b8c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 e8 f8 ff ff       	call   801482 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801b9a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ba1:	46 
  801ba2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bac:	c7 04 24 69 31 80 00 	movl   $0x803169,(%esp)
  801bb3:	e8 59 e7 ff ff       	call   800311 <cprintf>
		return -E_NOT_EXEC;
  801bb8:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801bbd:	e9 a4 04 00 00       	jmp    802066 <spawn+0x536>
  801bc2:	b8 07 00 00 00       	mov    $0x7,%eax
  801bc7:	cd 30                	int    $0x30
  801bc9:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801bcf:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 32 04 00 00    	js     80200f <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801bdd:	89 c6                	mov    %eax,%esi
  801bdf:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801be5:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801be8:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801bee:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801bf4:	b9 11 00 00 00       	mov    $0x11,%ecx
  801bf9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801bfb:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c01:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c07:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801c0c:	be 00 00 00 00       	mov    $0x0,%esi
  801c11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c14:	eb 0f                	jmp    801c25 <spawn+0xf5>
		string_size += strlen(argv[argc]) + 1;
  801c16:	89 04 24             	mov    %eax,(%esp)
  801c19:	e8 e2 ec ff ff       	call   800900 <strlen>
  801c1e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801c22:	83 c3 01             	add    $0x1,%ebx
  801c25:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801c2c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	75 e3                	jne    801c16 <spawn+0xe6>
  801c33:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801c39:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801c3f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801c44:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801c46:	89 fa                	mov    %edi,%edx
  801c48:	83 e2 fc             	and    $0xfffffffc,%edx
  801c4b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801c52:	29 c2                	sub    %eax,%edx
  801c54:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801c5a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801c5d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801c62:	0f 86 b7 03 00 00    	jbe    80201f <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c68:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c6f:	00 
  801c70:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c77:	00 
  801c78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7f:	e8 cf f0 ff ff       	call   800d53 <sys_page_alloc>
  801c84:	85 c0                	test   %eax,%eax
  801c86:	0f 88 da 03 00 00    	js     802066 <spawn+0x536>
  801c8c:	be 00 00 00 00       	mov    $0x0,%esi
  801c91:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801c97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c9a:	eb 30                	jmp    801ccc <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801c9c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ca2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801ca8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801cab:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801cae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb2:	89 3c 24             	mov    %edi,(%esp)
  801cb5:	e8 7d ec ff ff       	call   800937 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801cba:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801cbd:	89 04 24             	mov    %eax,(%esp)
  801cc0:	e8 3b ec ff ff       	call   800900 <strlen>
  801cc5:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801cc9:	83 c6 01             	add    $0x1,%esi
  801ccc:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801cd2:	7f c8                	jg     801c9c <spawn+0x16c>
	}
	argv_store[argc] = 0;
  801cd4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801cda:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801ce0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ce7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ced:	74 24                	je     801d13 <spawn+0x1e3>
  801cef:	c7 44 24 0c e0 31 80 	movl   $0x8031e0,0xc(%esp)
  801cf6:	00 
  801cf7:	c7 44 24 08 48 31 80 	movl   $0x803148,0x8(%esp)
  801cfe:	00 
  801cff:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801d06:	00 
  801d07:	c7 04 24 83 31 80 00 	movl   $0x803183,(%esp)
  801d0e:	e8 05 e5 ff ff       	call   800218 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d13:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d19:	89 c8                	mov    %ecx,%eax
  801d1b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d20:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801d23:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d29:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d2c:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801d32:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801d38:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801d3f:	00 
  801d40:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801d47:	ee 
  801d48:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d52:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d59:	00 
  801d5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d61:	e8 41 f0 ff ff       	call   800da7 <sys_page_map>
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	0f 88 e0 02 00 00    	js     802050 <spawn+0x520>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801d70:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d77:	00 
  801d78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7f:	e8 76 f0 ff ff       	call   800dfa <sys_page_unmap>
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	85 c0                	test   %eax,%eax
  801d88:	0f 88 c2 02 00 00    	js     802050 <spawn+0x520>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d8e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801d94:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801d9b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801da1:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801da8:	00 00 00 
  801dab:	e9 b6 01 00 00       	jmp    801f66 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801db0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801db6:	83 38 01             	cmpl   $0x1,(%eax)
  801db9:	0f 85 99 01 00 00    	jne    801f58 <spawn+0x428>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801dbf:	89 c1                	mov    %eax,%ecx
  801dc1:	8b 40 18             	mov    0x18(%eax),%eax
  801dc4:	83 e0 02             	and    $0x2,%eax
		perm = PTE_P | PTE_U;
  801dc7:	83 f8 01             	cmp    $0x1,%eax
  801dca:	19 c0                	sbb    %eax,%eax
  801dcc:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801dd2:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801dd9:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	8b 51 04             	mov    0x4(%ecx),%edx
  801de5:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801deb:	8b 49 10             	mov    0x10(%ecx),%ecx
  801dee:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801df4:	8b 50 14             	mov    0x14(%eax),%edx
  801df7:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801dfd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e00:	89 f0                	mov    %esi,%eax
  801e02:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e07:	74 14                	je     801e1d <spawn+0x2ed>
		va -= i;
  801e09:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e0b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801e11:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801e17:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e22:	e9 23 01 00 00       	jmp    801f4a <spawn+0x41a>
		if (i >= filesz) {
  801e27:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801e2d:	77 2b                	ja     801e5a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e2f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801e35:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e39:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e43:	89 04 24             	mov    %eax,(%esp)
  801e46:	e8 08 ef ff ff       	call   800d53 <sys_page_alloc>
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	0f 89 eb 00 00 00    	jns    801f3e <spawn+0x40e>
  801e53:	89 c3                	mov    %eax,%ebx
  801e55:	e9 d6 01 00 00       	jmp    802030 <spawn+0x500>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e5a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e61:	00 
  801e62:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e69:	00 
  801e6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e71:	e8 dd ee ff ff       	call   800d53 <sys_page_alloc>
  801e76:	85 c0                	test   %eax,%eax
  801e78:	0f 88 a8 01 00 00    	js     802026 <spawn+0x4f6>
  801e7e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e84:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e90:	89 04 24             	mov    %eax,(%esp)
  801e93:	e8 b7 f8 ff ff       	call   80174f <seek>
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	0f 88 8a 01 00 00    	js     80202a <spawn+0x4fa>
  801ea0:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801ea6:	29 fa                	sub    %edi,%edx
  801ea8:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801eaa:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801eb0:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801eb5:	0f 47 c1             	cmova  %ecx,%eax
  801eb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ebc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ec3:	00 
  801ec4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801eca:	89 04 24             	mov    %eax,(%esp)
  801ecd:	e8 a5 f7 ff ff       	call   801677 <readn>
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	0f 88 54 01 00 00    	js     80202e <spawn+0x4fe>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801eda:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801ee0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ee4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ee8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801eee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ef9:	00 
  801efa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f01:	e8 a1 ee ff ff       	call   800da7 <sys_page_map>
  801f06:	85 c0                	test   %eax,%eax
  801f08:	79 20                	jns    801f2a <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801f0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0e:	c7 44 24 08 8f 31 80 	movl   $0x80318f,0x8(%esp)
  801f15:	00 
  801f16:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801f1d:	00 
  801f1e:	c7 04 24 83 31 80 00 	movl   $0x803183,(%esp)
  801f25:	e8 ee e2 ff ff       	call   800218 <_panic>
			sys_page_unmap(0, UTEMP);
  801f2a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f31:	00 
  801f32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f39:	e8 bc ee ff ff       	call   800dfa <sys_page_unmap>
	for (i = 0; i < memsz; i += PGSIZE) {
  801f3e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f44:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f4a:	89 df                	mov    %ebx,%edi
  801f4c:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801f52:	0f 87 cf fe ff ff    	ja     801e27 <spawn+0x2f7>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f58:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f5f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801f66:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f6d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801f73:	0f 8c 37 fe ff ff    	jl     801db0 <spawn+0x280>
	close(fd);
  801f79:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f7f:	89 04 24             	mov    %eax,(%esp)
  801f82:	e8 fb f4 ff ff       	call   801482 <close>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801f87:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801f8e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f91:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fa1:	89 04 24             	mov    %eax,(%esp)
  801fa4:	e8 f7 ee ff ff       	call   800ea0 <sys_env_set_trapframe>
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	79 20                	jns    801fcd <spawn+0x49d>
		panic("sys_env_set_trapframe: %e", r);
  801fad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb1:	c7 44 24 08 ac 31 80 	movl   $0x8031ac,0x8(%esp)
  801fb8:	00 
  801fb9:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801fc0:	00 
  801fc1:	c7 04 24 83 31 80 00 	movl   $0x803183,(%esp)
  801fc8:	e8 4b e2 ff ff       	call   800218 <_panic>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801fcd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801fd4:	00 
  801fd5:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fdb:	89 04 24             	mov    %eax,(%esp)
  801fde:	e8 6a ee ff ff       	call   800e4d <sys_env_set_status>
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	79 30                	jns    802017 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801fe7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801feb:	c7 44 24 08 c6 31 80 	movl   $0x8031c6,0x8(%esp)
  801ff2:	00 
  801ff3:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801ffa:	00 
  801ffb:	c7 04 24 83 31 80 00 	movl   $0x803183,(%esp)
  802002:	e8 11 e2 ff ff       	call   800218 <_panic>
		return r;
  802007:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80200d:	eb 57                	jmp    802066 <spawn+0x536>
		return r;
  80200f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802015:	eb 4f                	jmp    802066 <spawn+0x536>
	return child;
  802017:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80201d:	eb 47                	jmp    802066 <spawn+0x536>
		return -E_NO_MEM;
  80201f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  802024:	eb 40                	jmp    802066 <spawn+0x536>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802026:	89 c3                	mov    %eax,%ebx
  802028:	eb 06                	jmp    802030 <spawn+0x500>
			if ((r = seek(fd, fileoffset + i)) < 0)
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	eb 02                	jmp    802030 <spawn+0x500>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80202e:	89 c3                	mov    %eax,%ebx
	sys_env_destroy(child);
  802030:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802036:	89 04 24             	mov    %eax,(%esp)
  802039:	e8 85 ec ff ff       	call   800cc3 <sys_env_destroy>
	close(fd);
  80203e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802044:	89 04 24             	mov    %eax,(%esp)
  802047:	e8 36 f4 ff ff       	call   801482 <close>
	return r;
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	eb 16                	jmp    802066 <spawn+0x536>
	sys_page_unmap(0, UTEMP);
  802050:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802057:	00 
  802058:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80205f:	e8 96 ed ff ff       	call   800dfa <sys_page_unmap>
  802064:	89 d8                	mov    %ebx,%eax
}
  802066:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  80206c:	5b                   	pop    %ebx
  80206d:	5e                   	pop    %esi
  80206e:	5f                   	pop    %edi
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    

00802071 <spawnl>:
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	56                   	push   %esi
  802075:	53                   	push   %ebx
  802076:	83 ec 10             	sub    $0x10,%esp
	while(va_arg(vl, void *) != NULL)
  802079:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  80207c:	ba 00 00 00 00       	mov    $0x0,%edx
	while(va_arg(vl, void *) != NULL)
  802081:	eb 03                	jmp    802086 <spawnl+0x15>
		argc++;
  802083:	83 c2 01             	add    $0x1,%edx
	while(va_arg(vl, void *) != NULL)
  802086:	83 c0 04             	add    $0x4,%eax
  802089:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  80208d:	75 f4                	jne    802083 <spawnl+0x12>
	const char *argv[argc+2];
  80208f:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  802096:	83 e0 f0             	and    $0xfffffff0,%eax
  802099:	29 c4                	sub    %eax,%esp
  80209b:	8d 44 24 0b          	lea    0xb(%esp),%eax
  80209f:	c1 e8 02             	shr    $0x2,%eax
  8020a2:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  8020a9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8020ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020ae:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  8020b5:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  8020bc:	00 
	for(i=0;i<argc;i++)
  8020bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c2:	eb 0a                	jmp    8020ce <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  8020c4:	83 c0 01             	add    $0x1,%eax
  8020c7:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8020cb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	for(i=0;i<argc;i++)
  8020ce:	39 d0                	cmp    %edx,%eax
  8020d0:	75 f2                	jne    8020c4 <spawnl+0x53>
	return spawn(prog, argv);
  8020d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d9:	89 04 24             	mov    %eax,(%esp)
  8020dc:	e8 4f fa ff ff       	call   801b30 <spawn>
}
  8020e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    

008020e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	56                   	push   %esi
  8020ec:	53                   	push   %ebx
  8020ed:	83 ec 10             	sub    $0x10,%esp
  8020f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f6:	89 04 24             	mov    %eax,(%esp)
  8020f9:	e8 f2 f1 ff ff       	call   8012f0 <fd2data>
  8020fe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802100:	c7 44 24 04 06 32 80 	movl   $0x803206,0x4(%esp)
  802107:	00 
  802108:	89 1c 24             	mov    %ebx,(%esp)
  80210b:	e8 27 e8 ff ff       	call   800937 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802110:	8b 46 04             	mov    0x4(%esi),%eax
  802113:	2b 06                	sub    (%esi),%eax
  802115:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80211b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802122:	00 00 00 
	stat->st_dev = &devpipe;
  802125:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  80212c:	40 80 00 
	return 0;
}
  80212f:	b8 00 00 00 00       	mov    $0x0,%eax
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5d                   	pop    %ebp
  80213a:	c3                   	ret    

0080213b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	53                   	push   %ebx
  80213f:	83 ec 14             	sub    $0x14,%esp
  802142:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802145:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802150:	e8 a5 ec ff ff       	call   800dfa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802155:	89 1c 24             	mov    %ebx,(%esp)
  802158:	e8 93 f1 ff ff       	call   8012f0 <fd2data>
  80215d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802168:	e8 8d ec ff ff       	call   800dfa <sys_page_unmap>
}
  80216d:	83 c4 14             	add    $0x14,%esp
  802170:	5b                   	pop    %ebx
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    

00802173 <_pipeisclosed>:
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	57                   	push   %edi
  802177:	56                   	push   %esi
  802178:	53                   	push   %ebx
  802179:	83 ec 2c             	sub    $0x2c,%esp
  80217c:	89 c6                	mov    %eax,%esi
  80217e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  802181:	a1 08 50 80 00       	mov    0x805008,%eax
  802186:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802189:	89 34 24             	mov    %esi,(%esp)
  80218c:	e8 a6 06 00 00       	call   802837 <pageref>
  802191:	89 c7                	mov    %eax,%edi
  802193:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802196:	89 04 24             	mov    %eax,(%esp)
  802199:	e8 99 06 00 00       	call   802837 <pageref>
  80219e:	39 c7                	cmp    %eax,%edi
  8021a0:	0f 94 c2             	sete   %dl
  8021a3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8021a6:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8021ac:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8021af:	39 fb                	cmp    %edi,%ebx
  8021b1:	74 21                	je     8021d4 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  8021b3:	84 d2                	test   %dl,%dl
  8021b5:	74 ca                	je     802181 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021b7:	8b 51 58             	mov    0x58(%ecx),%edx
  8021ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021be:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021c6:	c7 04 24 0d 32 80 00 	movl   $0x80320d,(%esp)
  8021cd:	e8 3f e1 ff ff       	call   800311 <cprintf>
  8021d2:	eb ad                	jmp    802181 <_pipeisclosed+0xe>
}
  8021d4:	83 c4 2c             	add    $0x2c,%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5f                   	pop    %edi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    

008021dc <devpipe_write>:
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	57                   	push   %edi
  8021e0:	56                   	push   %esi
  8021e1:	53                   	push   %ebx
  8021e2:	83 ec 1c             	sub    $0x1c,%esp
  8021e5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8021e8:	89 34 24             	mov    %esi,(%esp)
  8021eb:	e8 00 f1 ff ff       	call   8012f0 <fd2data>
  8021f0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8021f7:	eb 45                	jmp    80223e <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  8021f9:	89 da                	mov    %ebx,%edx
  8021fb:	89 f0                	mov    %esi,%eax
  8021fd:	e8 71 ff ff ff       	call   802173 <_pipeisclosed>
  802202:	85 c0                	test   %eax,%eax
  802204:	75 41                	jne    802247 <devpipe_write+0x6b>
			sys_yield();
  802206:	e8 29 eb ff ff       	call   800d34 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80220b:	8b 43 04             	mov    0x4(%ebx),%eax
  80220e:	8b 0b                	mov    (%ebx),%ecx
  802210:	8d 51 20             	lea    0x20(%ecx),%edx
  802213:	39 d0                	cmp    %edx,%eax
  802215:	73 e2                	jae    8021f9 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80221a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80221e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802221:	99                   	cltd   
  802222:	c1 ea 1b             	shr    $0x1b,%edx
  802225:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802228:	83 e1 1f             	and    $0x1f,%ecx
  80222b:	29 d1                	sub    %edx,%ecx
  80222d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802231:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802235:	83 c0 01             	add    $0x1,%eax
  802238:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80223b:	83 c7 01             	add    $0x1,%edi
  80223e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802241:	75 c8                	jne    80220b <devpipe_write+0x2f>
	return i;
  802243:	89 f8                	mov    %edi,%eax
  802245:	eb 05                	jmp    80224c <devpipe_write+0x70>
				return 0;
  802247:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80224c:	83 c4 1c             	add    $0x1c,%esp
  80224f:	5b                   	pop    %ebx
  802250:	5e                   	pop    %esi
  802251:	5f                   	pop    %edi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <devpipe_read>:
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	57                   	push   %edi
  802258:	56                   	push   %esi
  802259:	53                   	push   %ebx
  80225a:	83 ec 1c             	sub    $0x1c,%esp
  80225d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802260:	89 3c 24             	mov    %edi,(%esp)
  802263:	e8 88 f0 ff ff       	call   8012f0 <fd2data>
  802268:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80226a:	be 00 00 00 00       	mov    $0x0,%esi
  80226f:	eb 3d                	jmp    8022ae <devpipe_read+0x5a>
			if (i > 0)
  802271:	85 f6                	test   %esi,%esi
  802273:	74 04                	je     802279 <devpipe_read+0x25>
				return i;
  802275:	89 f0                	mov    %esi,%eax
  802277:	eb 43                	jmp    8022bc <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  802279:	89 da                	mov    %ebx,%edx
  80227b:	89 f8                	mov    %edi,%eax
  80227d:	e8 f1 fe ff ff       	call   802173 <_pipeisclosed>
  802282:	85 c0                	test   %eax,%eax
  802284:	75 31                	jne    8022b7 <devpipe_read+0x63>
			sys_yield();
  802286:	e8 a9 ea ff ff       	call   800d34 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80228b:	8b 03                	mov    (%ebx),%eax
  80228d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802290:	74 df                	je     802271 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802292:	99                   	cltd   
  802293:	c1 ea 1b             	shr    $0x1b,%edx
  802296:	01 d0                	add    %edx,%eax
  802298:	83 e0 1f             	and    $0x1f,%eax
  80229b:	29 d0                	sub    %edx,%eax
  80229d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022a5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8022a8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8022ab:	83 c6 01             	add    $0x1,%esi
  8022ae:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022b1:	75 d8                	jne    80228b <devpipe_read+0x37>
	return i;
  8022b3:	89 f0                	mov    %esi,%eax
  8022b5:	eb 05                	jmp    8022bc <devpipe_read+0x68>
				return 0;
  8022b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022bc:	83 c4 1c             	add    $0x1c,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    

008022c4 <pipe>:
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	56                   	push   %esi
  8022c8:	53                   	push   %ebx
  8022c9:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8022cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022cf:	89 04 24             	mov    %eax,(%esp)
  8022d2:	e8 30 f0 ff ff       	call   801307 <fd_alloc>
  8022d7:	89 c2                	mov    %eax,%edx
  8022d9:	85 d2                	test   %edx,%edx
  8022db:	0f 88 4d 01 00 00    	js     80242e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022e8:	00 
  8022e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f7:	e8 57 ea ff ff       	call   800d53 <sys_page_alloc>
  8022fc:	89 c2                	mov    %eax,%edx
  8022fe:	85 d2                	test   %edx,%edx
  802300:	0f 88 28 01 00 00    	js     80242e <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  802306:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802309:	89 04 24             	mov    %eax,(%esp)
  80230c:	e8 f6 ef ff ff       	call   801307 <fd_alloc>
  802311:	89 c3                	mov    %eax,%ebx
  802313:	85 c0                	test   %eax,%eax
  802315:	0f 88 fe 00 00 00    	js     802419 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80231b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802322:	00 
  802323:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80232a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802331:	e8 1d ea ff ff       	call   800d53 <sys_page_alloc>
  802336:	89 c3                	mov    %eax,%ebx
  802338:	85 c0                	test   %eax,%eax
  80233a:	0f 88 d9 00 00 00    	js     802419 <pipe+0x155>
	va = fd2data(fd0);
  802340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802343:	89 04 24             	mov    %eax,(%esp)
  802346:	e8 a5 ef ff ff       	call   8012f0 <fd2data>
  80234b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80234d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802354:	00 
  802355:	89 44 24 04          	mov    %eax,0x4(%esp)
  802359:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802360:	e8 ee e9 ff ff       	call   800d53 <sys_page_alloc>
  802365:	89 c3                	mov    %eax,%ebx
  802367:	85 c0                	test   %eax,%eax
  802369:	0f 88 97 00 00 00    	js     802406 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802372:	89 04 24             	mov    %eax,(%esp)
  802375:	e8 76 ef ff ff       	call   8012f0 <fd2data>
  80237a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802381:	00 
  802382:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802386:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80238d:	00 
  80238e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802392:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802399:	e8 09 ea ff ff       	call   800da7 <sys_page_map>
  80239e:	89 c3                	mov    %eax,%ebx
  8023a0:	85 c0                	test   %eax,%eax
  8023a2:	78 52                	js     8023f6 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  8023a4:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8023aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8023b9:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8023bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023c2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023c7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8023ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d1:	89 04 24             	mov    %eax,(%esp)
  8023d4:	e8 07 ef ff ff       	call   8012e0 <fd2num>
  8023d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023dc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023e1:	89 04 24             	mov    %eax,(%esp)
  8023e4:	e8 f7 ee ff ff       	call   8012e0 <fd2num>
  8023e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8023f4:	eb 38                	jmp    80242e <pipe+0x16a>
	sys_page_unmap(0, va);
  8023f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802401:	e8 f4 e9 ff ff       	call   800dfa <sys_page_unmap>
	sys_page_unmap(0, fd1);
  802406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802414:	e8 e1 e9 ff ff       	call   800dfa <sys_page_unmap>
	sys_page_unmap(0, fd0);
  802419:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802420:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802427:	e8 ce e9 ff ff       	call   800dfa <sys_page_unmap>
  80242c:	89 d8                	mov    %ebx,%eax
}
  80242e:	83 c4 30             	add    $0x30,%esp
  802431:	5b                   	pop    %ebx
  802432:	5e                   	pop    %esi
  802433:	5d                   	pop    %ebp
  802434:	c3                   	ret    

00802435 <pipeisclosed>:
{
  802435:	55                   	push   %ebp
  802436:	89 e5                	mov    %esp,%ebp
  802438:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80243b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80243e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802442:	8b 45 08             	mov    0x8(%ebp),%eax
  802445:	89 04 24             	mov    %eax,(%esp)
  802448:	e8 09 ef ff ff       	call   801356 <fd_lookup>
  80244d:	89 c2                	mov    %eax,%edx
  80244f:	85 d2                	test   %edx,%edx
  802451:	78 15                	js     802468 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  802453:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802456:	89 04 24             	mov    %eax,(%esp)
  802459:	e8 92 ee ff ff       	call   8012f0 <fd2data>
	return _pipeisclosed(fd, p);
  80245e:	89 c2                	mov    %eax,%edx
  802460:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802463:	e8 0b fd ff ff       	call   802173 <_pipeisclosed>
}
  802468:	c9                   	leave  
  802469:	c3                   	ret    

0080246a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80246a:	55                   	push   %ebp
  80246b:	89 e5                	mov    %esp,%ebp
  80246d:	56                   	push   %esi
  80246e:	53                   	push   %ebx
  80246f:	83 ec 10             	sub    $0x10,%esp
  802472:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802475:	85 f6                	test   %esi,%esi
  802477:	75 24                	jne    80249d <wait+0x33>
  802479:	c7 44 24 0c 25 32 80 	movl   $0x803225,0xc(%esp)
  802480:	00 
  802481:	c7 44 24 08 48 31 80 	movl   $0x803148,0x8(%esp)
  802488:	00 
  802489:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802490:	00 
  802491:	c7 04 24 30 32 80 00 	movl   $0x803230,(%esp)
  802498:	e8 7b dd ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  80249d:	89 f3                	mov    %esi,%ebx
  80249f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8024a5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8024a8:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024ae:	eb 05                	jmp    8024b5 <wait+0x4b>
		sys_yield();
  8024b0:	e8 7f e8 ff ff       	call   800d34 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024b5:	8b 43 48             	mov    0x48(%ebx),%eax
  8024b8:	39 f0                	cmp    %esi,%eax
  8024ba:	75 07                	jne    8024c3 <wait+0x59>
  8024bc:	8b 43 54             	mov    0x54(%ebx),%eax
  8024bf:	85 c0                	test   %eax,%eax
  8024c1:	75 ed                	jne    8024b0 <wait+0x46>
}
  8024c3:	83 c4 10             	add    $0x10,%esp
  8024c6:	5b                   	pop    %ebx
  8024c7:	5e                   	pop    %esi
  8024c8:	5d                   	pop    %ebp
  8024c9:	c3                   	ret    
  8024ca:	66 90                	xchg   %ax,%ax
  8024cc:	66 90                	xchg   %ax,%ax
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d8:	5d                   	pop    %ebp
  8024d9:	c3                   	ret    

008024da <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024e0:	c7 44 24 04 3b 32 80 	movl   $0x80323b,0x4(%esp)
  8024e7:	00 
  8024e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024eb:	89 04 24             	mov    %eax,(%esp)
  8024ee:	e8 44 e4 ff ff       	call   800937 <strcpy>
	return 0;
}
  8024f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f8:	c9                   	leave  
  8024f9:	c3                   	ret    

008024fa <devcons_write>:
{
  8024fa:	55                   	push   %ebp
  8024fb:	89 e5                	mov    %esp,%ebp
  8024fd:	57                   	push   %edi
  8024fe:	56                   	push   %esi
  8024ff:	53                   	push   %ebx
  802500:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  802506:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80250b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802511:	eb 31                	jmp    802544 <devcons_write+0x4a>
		m = n - tot;
  802513:	8b 75 10             	mov    0x10(%ebp),%esi
  802516:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802518:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80251b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802520:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802523:	89 74 24 08          	mov    %esi,0x8(%esp)
  802527:	03 45 0c             	add    0xc(%ebp),%eax
  80252a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80252e:	89 3c 24             	mov    %edi,(%esp)
  802531:	e8 9e e5 ff ff       	call   800ad4 <memmove>
		sys_cputs(buf, m);
  802536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80253a:	89 3c 24             	mov    %edi,(%esp)
  80253d:	e8 44 e7 ff ff       	call   800c86 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802542:	01 f3                	add    %esi,%ebx
  802544:	89 d8                	mov    %ebx,%eax
  802546:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802549:	72 c8                	jb     802513 <devcons_write+0x19>
}
  80254b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802551:	5b                   	pop    %ebx
  802552:	5e                   	pop    %esi
  802553:	5f                   	pop    %edi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    

00802556 <devcons_read>:
{
  802556:	55                   	push   %ebp
  802557:	89 e5                	mov    %esp,%ebp
  802559:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80255c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802561:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802565:	75 07                	jne    80256e <devcons_read+0x18>
  802567:	eb 2a                	jmp    802593 <devcons_read+0x3d>
		sys_yield();
  802569:	e8 c6 e7 ff ff       	call   800d34 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80256e:	66 90                	xchg   %ax,%ax
  802570:	e8 2f e7 ff ff       	call   800ca4 <sys_cgetc>
  802575:	85 c0                	test   %eax,%eax
  802577:	74 f0                	je     802569 <devcons_read+0x13>
	if (c < 0)
  802579:	85 c0                	test   %eax,%eax
  80257b:	78 16                	js     802593 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80257d:	83 f8 04             	cmp    $0x4,%eax
  802580:	74 0c                	je     80258e <devcons_read+0x38>
	*(char*)vbuf = c;
  802582:	8b 55 0c             	mov    0xc(%ebp),%edx
  802585:	88 02                	mov    %al,(%edx)
	return 1;
  802587:	b8 01 00 00 00       	mov    $0x1,%eax
  80258c:	eb 05                	jmp    802593 <devcons_read+0x3d>
		return 0;
  80258e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802593:	c9                   	leave  
  802594:	c3                   	ret    

00802595 <cputchar>:
{
  802595:	55                   	push   %ebp
  802596:	89 e5                	mov    %esp,%ebp
  802598:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80259b:	8b 45 08             	mov    0x8(%ebp),%eax
  80259e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8025a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8025a8:	00 
  8025a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025ac:	89 04 24             	mov    %eax,(%esp)
  8025af:	e8 d2 e6 ff ff       	call   800c86 <sys_cputs>
}
  8025b4:	c9                   	leave  
  8025b5:	c3                   	ret    

008025b6 <getchar>:
{
  8025b6:	55                   	push   %ebp
  8025b7:	89 e5                	mov    %esp,%ebp
  8025b9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8025bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8025c3:	00 
  8025c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025d2:	e8 0e f0 ff ff       	call   8015e5 <read>
	if (r < 0)
  8025d7:	85 c0                	test   %eax,%eax
  8025d9:	78 0f                	js     8025ea <getchar+0x34>
	if (r < 1)
  8025db:	85 c0                	test   %eax,%eax
  8025dd:	7e 06                	jle    8025e5 <getchar+0x2f>
	return c;
  8025df:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025e3:	eb 05                	jmp    8025ea <getchar+0x34>
		return -E_EOF;
  8025e5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8025ea:	c9                   	leave  
  8025eb:	c3                   	ret    

008025ec <iscons>:
{
  8025ec:	55                   	push   %ebp
  8025ed:	89 e5                	mov    %esp,%ebp
  8025ef:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025fc:	89 04 24             	mov    %eax,(%esp)
  8025ff:	e8 52 ed ff ff       	call   801356 <fd_lookup>
  802604:	85 c0                	test   %eax,%eax
  802606:	78 11                	js     802619 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802608:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260b:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802611:	39 10                	cmp    %edx,(%eax)
  802613:	0f 94 c0             	sete   %al
  802616:	0f b6 c0             	movzbl %al,%eax
}
  802619:	c9                   	leave  
  80261a:	c3                   	ret    

0080261b <opencons>:
{
  80261b:	55                   	push   %ebp
  80261c:	89 e5                	mov    %esp,%ebp
  80261e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802624:	89 04 24             	mov    %eax,(%esp)
  802627:	e8 db ec ff ff       	call   801307 <fd_alloc>
		return r;
  80262c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80262e:	85 c0                	test   %eax,%eax
  802630:	78 40                	js     802672 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802632:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802639:	00 
  80263a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80263d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802641:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802648:	e8 06 e7 ff ff       	call   800d53 <sys_page_alloc>
		return r;
  80264d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80264f:	85 c0                	test   %eax,%eax
  802651:	78 1f                	js     802672 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802653:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80265c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80265e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802661:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802668:	89 04 24             	mov    %eax,(%esp)
  80266b:	e8 70 ec ff ff       	call   8012e0 <fd2num>
  802670:	89 c2                	mov    %eax,%edx
}
  802672:	89 d0                	mov    %edx,%eax
  802674:	c9                   	leave  
  802675:	c3                   	ret    

00802676 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802676:	55                   	push   %ebp
  802677:	89 e5                	mov    %esp,%ebp
  802679:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  80267c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802683:	75 70                	jne    8026f5 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802685:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80268c:	00 
  80268d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802694:	ee 
  802695:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80269c:	e8 b2 e6 ff ff       	call   800d53 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  8026a1:	85 c0                	test   %eax,%eax
  8026a3:	79 1c                	jns    8026c1 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  8026a5:	c7 44 24 08 48 32 80 	movl   $0x803248,0x8(%esp)
  8026ac:	00 
  8026ad:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8026b4:	00 
  8026b5:	c7 04 24 a4 32 80 00 	movl   $0x8032a4,(%esp)
  8026bc:	e8 57 db ff ff       	call   800218 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  8026c1:	c7 44 24 04 ff 26 80 	movl   $0x8026ff,0x4(%esp)
  8026c8:	00 
  8026c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d0:	e8 1e e8 ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8026d5:	85 c0                	test   %eax,%eax
  8026d7:	79 1c                	jns    8026f5 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  8026d9:	c7 44 24 08 70 32 80 	movl   $0x803270,0x8(%esp)
  8026e0:	00 
  8026e1:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8026e8:	00 
  8026e9:	c7 04 24 a4 32 80 00 	movl   $0x8032a4,(%esp)
  8026f0:	e8 23 db ff ff       	call   800218 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f8:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8026fd:	c9                   	leave  
  8026fe:	c3                   	ret    

008026ff <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026ff:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802700:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802705:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802707:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  80270a:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  80270e:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802712:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  802714:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  802716:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  802717:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  80271a:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  80271c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  80271f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802720:	83 c4 04             	add    $0x4,%esp
    popf;
  802723:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  802724:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  802725:	c3                   	ret    
  802726:	66 90                	xchg   %ax,%ax
  802728:	66 90                	xchg   %ax,%ax
  80272a:	66 90                	xchg   %ax,%ax
  80272c:	66 90                	xchg   %ax,%ax
  80272e:	66 90                	xchg   %ax,%ax

00802730 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802730:	55                   	push   %ebp
  802731:	89 e5                	mov    %esp,%ebp
  802733:	56                   	push   %esi
  802734:	53                   	push   %ebx
  802735:	83 ec 10             	sub    $0x10,%esp
  802738:	8b 75 08             	mov    0x8(%ebp),%esi
  80273b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80273e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802741:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802743:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802748:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80274b:	89 04 24             	mov    %eax,(%esp)
  80274e:	e8 16 e8 ff ff       	call   800f69 <sys_ipc_recv>
    if(r < 0){
  802753:	85 c0                	test   %eax,%eax
  802755:	79 16                	jns    80276d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802757:	85 f6                	test   %esi,%esi
  802759:	74 06                	je     802761 <ipc_recv+0x31>
            *from_env_store = 0;
  80275b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802761:	85 db                	test   %ebx,%ebx
  802763:	74 2c                	je     802791 <ipc_recv+0x61>
            *perm_store = 0;
  802765:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80276b:	eb 24                	jmp    802791 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80276d:	85 f6                	test   %esi,%esi
  80276f:	74 0a                	je     80277b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802771:	a1 08 50 80 00       	mov    0x805008,%eax
  802776:	8b 40 74             	mov    0x74(%eax),%eax
  802779:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80277b:	85 db                	test   %ebx,%ebx
  80277d:	74 0a                	je     802789 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80277f:	a1 08 50 80 00       	mov    0x805008,%eax
  802784:	8b 40 78             	mov    0x78(%eax),%eax
  802787:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802789:	a1 08 50 80 00       	mov    0x805008,%eax
  80278e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802791:	83 c4 10             	add    $0x10,%esp
  802794:	5b                   	pop    %ebx
  802795:	5e                   	pop    %esi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    

00802798 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802798:	55                   	push   %ebp
  802799:	89 e5                	mov    %esp,%ebp
  80279b:	57                   	push   %edi
  80279c:	56                   	push   %esi
  80279d:	53                   	push   %ebx
  80279e:	83 ec 1c             	sub    $0x1c,%esp
  8027a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  8027aa:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  8027ac:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8027b1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8027b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8027b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027c3:	89 3c 24             	mov    %edi,(%esp)
  8027c6:	e8 7b e7 ff ff       	call   800f46 <sys_ipc_try_send>
        if(r == 0){
  8027cb:	85 c0                	test   %eax,%eax
  8027cd:	74 28                	je     8027f7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8027cf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8027d2:	74 1c                	je     8027f0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8027d4:	c7 44 24 08 b2 32 80 	movl   $0x8032b2,0x8(%esp)
  8027db:	00 
  8027dc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8027e3:	00 
  8027e4:	c7 04 24 c9 32 80 00 	movl   $0x8032c9,(%esp)
  8027eb:	e8 28 da ff ff       	call   800218 <_panic>
        }
        sys_yield();
  8027f0:	e8 3f e5 ff ff       	call   800d34 <sys_yield>
    }
  8027f5:	eb bd                	jmp    8027b4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8027f7:	83 c4 1c             	add    $0x1c,%esp
  8027fa:	5b                   	pop    %ebx
  8027fb:	5e                   	pop    %esi
  8027fc:	5f                   	pop    %edi
  8027fd:	5d                   	pop    %ebp
  8027fe:	c3                   	ret    

008027ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027ff:	55                   	push   %ebp
  802800:	89 e5                	mov    %esp,%ebp
  802802:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802805:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80280a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80280d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802813:	8b 52 50             	mov    0x50(%edx),%edx
  802816:	39 ca                	cmp    %ecx,%edx
  802818:	75 0d                	jne    802827 <ipc_find_env+0x28>
			return envs[i].env_id;
  80281a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80281d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802822:	8b 40 40             	mov    0x40(%eax),%eax
  802825:	eb 0e                	jmp    802835 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802827:	83 c0 01             	add    $0x1,%eax
  80282a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80282f:	75 d9                	jne    80280a <ipc_find_env+0xb>
	return 0;
  802831:	66 b8 00 00          	mov    $0x0,%ax
}
  802835:	5d                   	pop    %ebp
  802836:	c3                   	ret    

00802837 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802837:	55                   	push   %ebp
  802838:	89 e5                	mov    %esp,%ebp
  80283a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80283d:	89 d0                	mov    %edx,%eax
  80283f:	c1 e8 16             	shr    $0x16,%eax
  802842:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802849:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80284e:	f6 c1 01             	test   $0x1,%cl
  802851:	74 1d                	je     802870 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802853:	c1 ea 0c             	shr    $0xc,%edx
  802856:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80285d:	f6 c2 01             	test   $0x1,%dl
  802860:	74 0e                	je     802870 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802862:	c1 ea 0c             	shr    $0xc,%edx
  802865:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80286c:	ef 
  80286d:	0f b7 c0             	movzwl %ax,%eax
}
  802870:	5d                   	pop    %ebp
  802871:	c3                   	ret    
  802872:	66 90                	xchg   %ax,%ax
  802874:	66 90                	xchg   %ax,%ax
  802876:	66 90                	xchg   %ax,%ax
  802878:	66 90                	xchg   %ax,%ax
  80287a:	66 90                	xchg   %ax,%ax
  80287c:	66 90                	xchg   %ax,%ax
  80287e:	66 90                	xchg   %ax,%ax

00802880 <__udivdi3>:
  802880:	55                   	push   %ebp
  802881:	57                   	push   %edi
  802882:	56                   	push   %esi
  802883:	83 ec 0c             	sub    $0xc,%esp
  802886:	8b 44 24 28          	mov    0x28(%esp),%eax
  80288a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80288e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802892:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802896:	85 c0                	test   %eax,%eax
  802898:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80289c:	89 ea                	mov    %ebp,%edx
  80289e:	89 0c 24             	mov    %ecx,(%esp)
  8028a1:	75 2d                	jne    8028d0 <__udivdi3+0x50>
  8028a3:	39 e9                	cmp    %ebp,%ecx
  8028a5:	77 61                	ja     802908 <__udivdi3+0x88>
  8028a7:	85 c9                	test   %ecx,%ecx
  8028a9:	89 ce                	mov    %ecx,%esi
  8028ab:	75 0b                	jne    8028b8 <__udivdi3+0x38>
  8028ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8028b2:	31 d2                	xor    %edx,%edx
  8028b4:	f7 f1                	div    %ecx
  8028b6:	89 c6                	mov    %eax,%esi
  8028b8:	31 d2                	xor    %edx,%edx
  8028ba:	89 e8                	mov    %ebp,%eax
  8028bc:	f7 f6                	div    %esi
  8028be:	89 c5                	mov    %eax,%ebp
  8028c0:	89 f8                	mov    %edi,%eax
  8028c2:	f7 f6                	div    %esi
  8028c4:	89 ea                	mov    %ebp,%edx
  8028c6:	83 c4 0c             	add    $0xc,%esp
  8028c9:	5e                   	pop    %esi
  8028ca:	5f                   	pop    %edi
  8028cb:	5d                   	pop    %ebp
  8028cc:	c3                   	ret    
  8028cd:	8d 76 00             	lea    0x0(%esi),%esi
  8028d0:	39 e8                	cmp    %ebp,%eax
  8028d2:	77 24                	ja     8028f8 <__udivdi3+0x78>
  8028d4:	0f bd e8             	bsr    %eax,%ebp
  8028d7:	83 f5 1f             	xor    $0x1f,%ebp
  8028da:	75 3c                	jne    802918 <__udivdi3+0x98>
  8028dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8028e0:	39 34 24             	cmp    %esi,(%esp)
  8028e3:	0f 86 9f 00 00 00    	jbe    802988 <__udivdi3+0x108>
  8028e9:	39 d0                	cmp    %edx,%eax
  8028eb:	0f 82 97 00 00 00    	jb     802988 <__udivdi3+0x108>
  8028f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028f8:	31 d2                	xor    %edx,%edx
  8028fa:	31 c0                	xor    %eax,%eax
  8028fc:	83 c4 0c             	add    $0xc,%esp
  8028ff:	5e                   	pop    %esi
  802900:	5f                   	pop    %edi
  802901:	5d                   	pop    %ebp
  802902:	c3                   	ret    
  802903:	90                   	nop
  802904:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802908:	89 f8                	mov    %edi,%eax
  80290a:	f7 f1                	div    %ecx
  80290c:	31 d2                	xor    %edx,%edx
  80290e:	83 c4 0c             	add    $0xc,%esp
  802911:	5e                   	pop    %esi
  802912:	5f                   	pop    %edi
  802913:	5d                   	pop    %ebp
  802914:	c3                   	ret    
  802915:	8d 76 00             	lea    0x0(%esi),%esi
  802918:	89 e9                	mov    %ebp,%ecx
  80291a:	8b 3c 24             	mov    (%esp),%edi
  80291d:	d3 e0                	shl    %cl,%eax
  80291f:	89 c6                	mov    %eax,%esi
  802921:	b8 20 00 00 00       	mov    $0x20,%eax
  802926:	29 e8                	sub    %ebp,%eax
  802928:	89 c1                	mov    %eax,%ecx
  80292a:	d3 ef                	shr    %cl,%edi
  80292c:	89 e9                	mov    %ebp,%ecx
  80292e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802932:	8b 3c 24             	mov    (%esp),%edi
  802935:	09 74 24 08          	or     %esi,0x8(%esp)
  802939:	89 d6                	mov    %edx,%esi
  80293b:	d3 e7                	shl    %cl,%edi
  80293d:	89 c1                	mov    %eax,%ecx
  80293f:	89 3c 24             	mov    %edi,(%esp)
  802942:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802946:	d3 ee                	shr    %cl,%esi
  802948:	89 e9                	mov    %ebp,%ecx
  80294a:	d3 e2                	shl    %cl,%edx
  80294c:	89 c1                	mov    %eax,%ecx
  80294e:	d3 ef                	shr    %cl,%edi
  802950:	09 d7                	or     %edx,%edi
  802952:	89 f2                	mov    %esi,%edx
  802954:	89 f8                	mov    %edi,%eax
  802956:	f7 74 24 08          	divl   0x8(%esp)
  80295a:	89 d6                	mov    %edx,%esi
  80295c:	89 c7                	mov    %eax,%edi
  80295e:	f7 24 24             	mull   (%esp)
  802961:	39 d6                	cmp    %edx,%esi
  802963:	89 14 24             	mov    %edx,(%esp)
  802966:	72 30                	jb     802998 <__udivdi3+0x118>
  802968:	8b 54 24 04          	mov    0x4(%esp),%edx
  80296c:	89 e9                	mov    %ebp,%ecx
  80296e:	d3 e2                	shl    %cl,%edx
  802970:	39 c2                	cmp    %eax,%edx
  802972:	73 05                	jae    802979 <__udivdi3+0xf9>
  802974:	3b 34 24             	cmp    (%esp),%esi
  802977:	74 1f                	je     802998 <__udivdi3+0x118>
  802979:	89 f8                	mov    %edi,%eax
  80297b:	31 d2                	xor    %edx,%edx
  80297d:	e9 7a ff ff ff       	jmp    8028fc <__udivdi3+0x7c>
  802982:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802988:	31 d2                	xor    %edx,%edx
  80298a:	b8 01 00 00 00       	mov    $0x1,%eax
  80298f:	e9 68 ff ff ff       	jmp    8028fc <__udivdi3+0x7c>
  802994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802998:	8d 47 ff             	lea    -0x1(%edi),%eax
  80299b:	31 d2                	xor    %edx,%edx
  80299d:	83 c4 0c             	add    $0xc,%esp
  8029a0:	5e                   	pop    %esi
  8029a1:	5f                   	pop    %edi
  8029a2:	5d                   	pop    %ebp
  8029a3:	c3                   	ret    
  8029a4:	66 90                	xchg   %ax,%ax
  8029a6:	66 90                	xchg   %ax,%ax
  8029a8:	66 90                	xchg   %ax,%ax
  8029aa:	66 90                	xchg   %ax,%ax
  8029ac:	66 90                	xchg   %ax,%ax
  8029ae:	66 90                	xchg   %ax,%ax

008029b0 <__umoddi3>:
  8029b0:	55                   	push   %ebp
  8029b1:	57                   	push   %edi
  8029b2:	56                   	push   %esi
  8029b3:	83 ec 14             	sub    $0x14,%esp
  8029b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8029ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8029be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8029c2:	89 c7                	mov    %eax,%edi
  8029c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8029cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8029d0:	89 34 24             	mov    %esi,(%esp)
  8029d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029d7:	85 c0                	test   %eax,%eax
  8029d9:	89 c2                	mov    %eax,%edx
  8029db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8029df:	75 17                	jne    8029f8 <__umoddi3+0x48>
  8029e1:	39 fe                	cmp    %edi,%esi
  8029e3:	76 4b                	jbe    802a30 <__umoddi3+0x80>
  8029e5:	89 c8                	mov    %ecx,%eax
  8029e7:	89 fa                	mov    %edi,%edx
  8029e9:	f7 f6                	div    %esi
  8029eb:	89 d0                	mov    %edx,%eax
  8029ed:	31 d2                	xor    %edx,%edx
  8029ef:	83 c4 14             	add    $0x14,%esp
  8029f2:	5e                   	pop    %esi
  8029f3:	5f                   	pop    %edi
  8029f4:	5d                   	pop    %ebp
  8029f5:	c3                   	ret    
  8029f6:	66 90                	xchg   %ax,%ax
  8029f8:	39 f8                	cmp    %edi,%eax
  8029fa:	77 54                	ja     802a50 <__umoddi3+0xa0>
  8029fc:	0f bd e8             	bsr    %eax,%ebp
  8029ff:	83 f5 1f             	xor    $0x1f,%ebp
  802a02:	75 5c                	jne    802a60 <__umoddi3+0xb0>
  802a04:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802a08:	39 3c 24             	cmp    %edi,(%esp)
  802a0b:	0f 87 e7 00 00 00    	ja     802af8 <__umoddi3+0x148>
  802a11:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a15:	29 f1                	sub    %esi,%ecx
  802a17:	19 c7                	sbb    %eax,%edi
  802a19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a21:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a25:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802a29:	83 c4 14             	add    $0x14,%esp
  802a2c:	5e                   	pop    %esi
  802a2d:	5f                   	pop    %edi
  802a2e:	5d                   	pop    %ebp
  802a2f:	c3                   	ret    
  802a30:	85 f6                	test   %esi,%esi
  802a32:	89 f5                	mov    %esi,%ebp
  802a34:	75 0b                	jne    802a41 <__umoddi3+0x91>
  802a36:	b8 01 00 00 00       	mov    $0x1,%eax
  802a3b:	31 d2                	xor    %edx,%edx
  802a3d:	f7 f6                	div    %esi
  802a3f:	89 c5                	mov    %eax,%ebp
  802a41:	8b 44 24 04          	mov    0x4(%esp),%eax
  802a45:	31 d2                	xor    %edx,%edx
  802a47:	f7 f5                	div    %ebp
  802a49:	89 c8                	mov    %ecx,%eax
  802a4b:	f7 f5                	div    %ebp
  802a4d:	eb 9c                	jmp    8029eb <__umoddi3+0x3b>
  802a4f:	90                   	nop
  802a50:	89 c8                	mov    %ecx,%eax
  802a52:	89 fa                	mov    %edi,%edx
  802a54:	83 c4 14             	add    $0x14,%esp
  802a57:	5e                   	pop    %esi
  802a58:	5f                   	pop    %edi
  802a59:	5d                   	pop    %ebp
  802a5a:	c3                   	ret    
  802a5b:	90                   	nop
  802a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a60:	8b 04 24             	mov    (%esp),%eax
  802a63:	be 20 00 00 00       	mov    $0x20,%esi
  802a68:	89 e9                	mov    %ebp,%ecx
  802a6a:	29 ee                	sub    %ebp,%esi
  802a6c:	d3 e2                	shl    %cl,%edx
  802a6e:	89 f1                	mov    %esi,%ecx
  802a70:	d3 e8                	shr    %cl,%eax
  802a72:	89 e9                	mov    %ebp,%ecx
  802a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a78:	8b 04 24             	mov    (%esp),%eax
  802a7b:	09 54 24 04          	or     %edx,0x4(%esp)
  802a7f:	89 fa                	mov    %edi,%edx
  802a81:	d3 e0                	shl    %cl,%eax
  802a83:	89 f1                	mov    %esi,%ecx
  802a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a89:	8b 44 24 10          	mov    0x10(%esp),%eax
  802a8d:	d3 ea                	shr    %cl,%edx
  802a8f:	89 e9                	mov    %ebp,%ecx
  802a91:	d3 e7                	shl    %cl,%edi
  802a93:	89 f1                	mov    %esi,%ecx
  802a95:	d3 e8                	shr    %cl,%eax
  802a97:	89 e9                	mov    %ebp,%ecx
  802a99:	09 f8                	or     %edi,%eax
  802a9b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802a9f:	f7 74 24 04          	divl   0x4(%esp)
  802aa3:	d3 e7                	shl    %cl,%edi
  802aa5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802aa9:	89 d7                	mov    %edx,%edi
  802aab:	f7 64 24 08          	mull   0x8(%esp)
  802aaf:	39 d7                	cmp    %edx,%edi
  802ab1:	89 c1                	mov    %eax,%ecx
  802ab3:	89 14 24             	mov    %edx,(%esp)
  802ab6:	72 2c                	jb     802ae4 <__umoddi3+0x134>
  802ab8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802abc:	72 22                	jb     802ae0 <__umoddi3+0x130>
  802abe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ac2:	29 c8                	sub    %ecx,%eax
  802ac4:	19 d7                	sbb    %edx,%edi
  802ac6:	89 e9                	mov    %ebp,%ecx
  802ac8:	89 fa                	mov    %edi,%edx
  802aca:	d3 e8                	shr    %cl,%eax
  802acc:	89 f1                	mov    %esi,%ecx
  802ace:	d3 e2                	shl    %cl,%edx
  802ad0:	89 e9                	mov    %ebp,%ecx
  802ad2:	d3 ef                	shr    %cl,%edi
  802ad4:	09 d0                	or     %edx,%eax
  802ad6:	89 fa                	mov    %edi,%edx
  802ad8:	83 c4 14             	add    $0x14,%esp
  802adb:	5e                   	pop    %esi
  802adc:	5f                   	pop    %edi
  802add:	5d                   	pop    %ebp
  802ade:	c3                   	ret    
  802adf:	90                   	nop
  802ae0:	39 d7                	cmp    %edx,%edi
  802ae2:	75 da                	jne    802abe <__umoddi3+0x10e>
  802ae4:	8b 14 24             	mov    (%esp),%edx
  802ae7:	89 c1                	mov    %eax,%ecx
  802ae9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802aed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802af1:	eb cb                	jmp    802abe <__umoddi3+0x10e>
  802af3:	90                   	nop
  802af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802af8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802afc:	0f 82 0f ff ff ff    	jb     802a11 <__umoddi3+0x61>
  802b02:	e9 1a ff ff ff       	jmp    802a21 <__umoddi3+0x71>
