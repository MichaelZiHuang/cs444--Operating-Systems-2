
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 e0 00 00 00       	call   800111 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 28 0c 00 00       	call   800c75 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 e9 0f 00 00       	call   801042 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 16                	jmp    80007d <umain+0x3d>
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 11                	je     80007d <umain+0x3d>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800075:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  80007b:	eb 0c                	jmp    800089 <umain+0x49>
		sys_yield();
  80007d:	e8 12 0c 00 00       	call   800c94 <sys_yield>
		return;
  800082:	e9 83 00 00 00       	jmp    80010a <umain+0xca>
		asm volatile("pause");
  800087:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800089:	8b 42 50             	mov    0x50(%edx),%eax
  80008c:	85 c0                	test   %eax,%eax
  80008e:	66 90                	xchg   %ax,%ax
  800090:	75 f5                	jne    800087 <umain+0x47>
  800092:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800097:	e8 f8 0b 00 00       	call   800c94 <sys_yield>
  80009c:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000a1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8000a7:	83 c2 01             	add    $0x1,%edx
  8000aa:	89 15 08 40 80 00    	mov    %edx,0x804008
		for (j = 0; j < 10000; j++)
  8000b0:	83 e8 01             	sub    $0x1,%eax
  8000b3:	75 ec                	jne    8000a1 <umain+0x61>
	for (i = 0; i < 10; i++) {
  8000b5:	83 eb 01             	sub    $0x1,%ebx
  8000b8:	75 dd                	jne    800097 <umain+0x57>
	}

	if (counter != 10*10000)
  8000ba:	a1 08 40 80 00       	mov    0x804008,%eax
  8000bf:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000c4:	74 25                	je     8000eb <umain+0xab>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000c6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000cf:	c7 44 24 08 60 24 80 	movl   $0x802460,0x8(%esp)
  8000d6:	00 
  8000d7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000de:	00 
  8000df:	c7 04 24 88 24 80 00 	movl   $0x802488,(%esp)
  8000e6:	e8 87 00 00 00       	call   800172 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000eb:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000f0:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000f3:	8b 40 48             	mov    0x48(%eax),%eax
  8000f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fe:	c7 04 24 9b 24 80 00 	movl   $0x80249b,(%esp)
  800105:	e8 61 01 00 00       	call   80026b <cprintf>

}
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	83 ec 10             	sub    $0x10,%esp
  800119:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80011c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  80011f:	e8 51 0b 00 00       	call   800c75 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800124:	25 ff 03 00 00       	and    $0x3ff,%eax
  800129:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 db                	test   %ebx,%ebx
  800138:	7e 07                	jle    800141 <libmain+0x30>
		binaryname = argv[0];
  80013a:	8b 06                	mov    (%esi),%eax
  80013c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	89 1c 24             	mov    %ebx,(%esp)
  800148:	e8 f3 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80014d:	e8 07 00 00 00       	call   800159 <exit>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80015f:	e8 b1 12 00 00       	call   801415 <close_all>
	sys_env_destroy(0);
  800164:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016b:	e8 b3 0a 00 00       	call   800c23 <sys_env_destroy>
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80017a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800183:	e8 ed 0a 00 00       	call   800c75 <sys_getenvid>
  800188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800196:	89 74 24 08          	mov    %esi,0x8(%esp)
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	c7 04 24 c4 24 80 00 	movl   $0x8024c4,(%esp)
  8001a5:	e8 c1 00 00 00       	call   80026b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 51 00 00 00       	call   80020a <vcprintf>
	cprintf("\n");
  8001b9:	c7 04 24 b7 24 80 00 	movl   $0x8024b7,(%esp)
  8001c0:	e8 a6 00 00 00       	call   80026b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c5:	cc                   	int3   
  8001c6:	eb fd                	jmp    8001c5 <_panic+0x53>

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 13                	mov    (%ebx),%edx
  8001d4:	8d 42 01             	lea    0x1(%edx),%eax
  8001d7:	89 03                	mov    %eax,(%ebx)
  8001d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e5:	75 19                	jne    800200 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001e7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ee:	00 
  8001ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	e8 ec 09 00 00       	call   800be6 <sys_cputs>
		b->idx = 0;
  8001fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800200:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800204:	83 c4 14             	add    $0x14,%esp
  800207:	5b                   	pop    %ebx
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800213:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021a:	00 00 00 
	b.cnt = 0;
  80021d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800224:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	c7 04 24 c8 01 80 00 	movl   $0x8001c8,(%esp)
  800246:	e8 b3 01 00 00       	call   8003fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 83 09 00 00       	call   800be6 <sys_cputs>

	return b.cnt;
}
  800263:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800271:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 87 ff ff ff       	call   80020a <vcprintf>
	va_end(ap);

	return cnt;
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    
  800285:	66 90                	xchg   %ax,%ax
  800287:	66 90                	xchg   %ax,%ax
  800289:	66 90                	xchg   %ax,%ax
  80028b:	66 90                	xchg   %ax,%ax
  80028d:	66 90                	xchg   %ax,%ax
  80028f:	90                   	nop

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 3c             	sub    $0x3c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 c3                	mov    %eax,%ebx
  8002a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8002af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002bd:	39 d9                	cmp    %ebx,%ecx
  8002bf:	72 05                	jb     8002c6 <printnum+0x36>
  8002c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002c4:	77 69                	ja     80032f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002cd:	83 ee 01             	sub    $0x1,%esi
  8002d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002e0:	89 c3                	mov    %eax,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ff:	e8 bc 1e 00 00       	call   8021c0 <__udivdi3>
  800304:	89 d9                	mov    %ebx,%ecx
  800306:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	89 54 24 04          	mov    %edx,0x4(%esp)
  800315:	89 fa                	mov    %edi,%edx
  800317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031a:	e8 71 ff ff ff       	call   800290 <printnum>
  80031f:	eb 1b                	jmp    80033c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800325:	8b 45 18             	mov    0x18(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff d3                	call   *%ebx
  80032d:	eb 03                	jmp    800332 <printnum+0xa2>
  80032f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800332:	83 ee 01             	sub    $0x1,%esi
  800335:	85 f6                	test   %esi,%esi
  800337:	7f e8                	jg     800321 <printnum+0x91>
  800339:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800340:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800344:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800347:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035f:	e8 8c 1f 00 00       	call   8022f0 <__umoddi3>
  800364:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800368:	0f be 80 e7 24 80 00 	movsbl 0x8024e7(%eax),%eax
  80036f:	89 04 24             	mov    %eax,(%esp)
  800372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800375:	ff d0                	call   *%eax
}
  800377:	83 c4 3c             	add    $0x3c,%esp
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800382:	83 fa 01             	cmp    $0x1,%edx
  800385:	7e 0e                	jle    800395 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800387:	8b 10                	mov    (%eax),%edx
  800389:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038c:	89 08                	mov    %ecx,(%eax)
  80038e:	8b 02                	mov    (%edx),%eax
  800390:	8b 52 04             	mov    0x4(%edx),%edx
  800393:	eb 22                	jmp    8003b7 <getuint+0x38>
	else if (lflag)
  800395:	85 d2                	test   %edx,%edx
  800397:	74 10                	je     8003a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 02                	mov    (%edx),%eax
  8003a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a7:	eb 0e                	jmp    8003b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 02                	mov    (%edx),%eax
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c8:	73 0a                	jae    8003d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cd:	89 08                	mov    %ecx,(%eax)
  8003cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d2:	88 02                	mov    %al,(%edx)
}
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <printfmt>:
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	e8 02 00 00 00       	call   8003fe <vprintfmt>
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <vprintfmt>:
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 3c             	sub    $0x3c,%esp
  800407:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80040a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80040d:	eb 1f                	jmp    80042e <vprintfmt+0x30>
			if (ch == '\0'){
  80040f:	85 c0                	test   %eax,%eax
  800411:	75 0f                	jne    800422 <vprintfmt+0x24>
				color = 0x0100;
  800413:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80041a:	01 00 00 
  80041d:	e9 b3 03 00 00       	jmp    8007d5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800422:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800426:	89 04 24             	mov    %eax,(%esp)
  800429:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042c:	89 f3                	mov    %esi,%ebx
  80042e:	8d 73 01             	lea    0x1(%ebx),%esi
  800431:	0f b6 03             	movzbl (%ebx),%eax
  800434:	83 f8 25             	cmp    $0x25,%eax
  800437:	75 d6                	jne    80040f <vprintfmt+0x11>
  800439:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80043d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800444:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80044b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
  800457:	eb 1d                	jmp    800476 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800459:	89 de                	mov    %ebx,%esi
			padc = '-';
  80045b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80045f:	eb 15                	jmp    800476 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800461:	89 de                	mov    %ebx,%esi
			padc = '0';
  800463:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800467:	eb 0d                	jmp    800476 <vprintfmt+0x78>
				width = precision, precision = -1;
  800469:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80046c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80046f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8d 5e 01             	lea    0x1(%esi),%ebx
  800479:	0f b6 0e             	movzbl (%esi),%ecx
  80047c:	0f b6 c1             	movzbl %cl,%eax
  80047f:	83 e9 23             	sub    $0x23,%ecx
  800482:	80 f9 55             	cmp    $0x55,%cl
  800485:	0f 87 2a 03 00 00    	ja     8007b5 <vprintfmt+0x3b7>
  80048b:	0f b6 c9             	movzbl %cl,%ecx
  80048e:	ff 24 8d 20 26 80 00 	jmp    *0x802620(,%ecx,4)
  800495:	89 de                	mov    %ebx,%esi
  800497:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80049c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80049f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004a3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004a6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004a9:	83 fb 09             	cmp    $0x9,%ebx
  8004ac:	77 36                	ja     8004e4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8004ae:	83 c6 01             	add    $0x1,%esi
			}
  8004b1:	eb e9                	jmp    80049c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8004b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004bc:	8b 00                	mov    (%eax),%eax
  8004be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004c3:	eb 22                	jmp    8004e7 <vprintfmt+0xe9>
  8004c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004c8:	85 c9                	test   %ecx,%ecx
  8004ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cf:	0f 49 c1             	cmovns %ecx,%eax
  8004d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	89 de                	mov    %ebx,%esi
  8004d7:	eb 9d                	jmp    800476 <vprintfmt+0x78>
  8004d9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004e2:	eb 92                	jmp    800476 <vprintfmt+0x78>
  8004e4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8004e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004eb:	79 89                	jns    800476 <vprintfmt+0x78>
  8004ed:	e9 77 ff ff ff       	jmp    800469 <vprintfmt+0x6b>
			lflag++;
  8004f2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004f7:	e9 7a ff ff ff       	jmp    800476 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 50 04             	lea    0x4(%eax),%edx
  800502:	89 55 14             	mov    %edx,0x14(%ebp)
  800505:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 04 24             	mov    %eax,(%esp)
  80050e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800511:	e9 18 ff ff ff       	jmp    80042e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	99                   	cltd   
  800522:	31 d0                	xor    %edx,%eax
  800524:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800526:	83 f8 0f             	cmp    $0xf,%eax
  800529:	7f 0b                	jg     800536 <vprintfmt+0x138>
  80052b:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800532:	85 d2                	test   %edx,%edx
  800534:	75 20                	jne    800556 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800536:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053a:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  800541:	00 
  800542:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	89 04 24             	mov    %eax,(%esp)
  80054c:	e8 85 fe ff ff       	call   8003d6 <printfmt>
  800551:	e9 d8 fe ff ff       	jmp    80042e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800556:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055a:	c7 44 24 08 3a 2a 80 	movl   $0x802a3a,0x8(%esp)
  800561:	00 
  800562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800566:	8b 45 08             	mov    0x8(%ebp),%eax
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	e8 65 fe ff ff       	call   8003d6 <printfmt>
  800571:	e9 b8 fe ff ff       	jmp    80042e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800579:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80057c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80058a:	85 f6                	test   %esi,%esi
  80058c:	b8 f8 24 80 00       	mov    $0x8024f8,%eax
  800591:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800594:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800598:	0f 84 97 00 00 00    	je     800635 <vprintfmt+0x237>
  80059e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005a2:	0f 8e 9b 00 00 00    	jle    800643 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ac:	89 34 24             	mov    %esi,(%esp)
  8005af:	e8 c4 02 00 00       	call   800878 <strnlen>
  8005b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005b7:	29 c2                	sub    %eax,%edx
  8005b9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005bc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005c3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005cc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ce:	eb 0f                	jmp    8005df <vprintfmt+0x1e1>
					putch(padc, putdat);
  8005d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dc:	83 eb 01             	sub    $0x1,%ebx
  8005df:	85 db                	test   %ebx,%ebx
  8005e1:	7f ed                	jg     8005d0 <vprintfmt+0x1d2>
  8005e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005e6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005e9:	85 d2                	test   %edx,%edx
  8005eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f0:	0f 49 c2             	cmovns %edx,%eax
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005f8:	89 d7                	mov    %edx,%edi
  8005fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005fd:	eb 50                	jmp    80064f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800603:	74 1e                	je     800623 <vprintfmt+0x225>
  800605:	0f be d2             	movsbl %dl,%edx
  800608:	83 ea 20             	sub    $0x20,%edx
  80060b:	83 fa 5e             	cmp    $0x5e,%edx
  80060e:	76 13                	jbe    800623 <vprintfmt+0x225>
					putch('?', putdat);
  800610:	8b 45 0c             	mov    0xc(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061e:	ff 55 08             	call   *0x8(%ebp)
  800621:	eb 0d                	jmp    800630 <vprintfmt+0x232>
					putch(ch, putdat);
  800623:	8b 55 0c             	mov    0xc(%ebp),%edx
  800626:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062a:	89 04 24             	mov    %eax,(%esp)
  80062d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800630:	83 ef 01             	sub    $0x1,%edi
  800633:	eb 1a                	jmp    80064f <vprintfmt+0x251>
  800635:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800638:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80063b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80063e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800641:	eb 0c                	jmp    80064f <vprintfmt+0x251>
  800643:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800646:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800649:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80064c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80064f:	83 c6 01             	add    $0x1,%esi
  800652:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800656:	0f be c2             	movsbl %dl,%eax
  800659:	85 c0                	test   %eax,%eax
  80065b:	74 27                	je     800684 <vprintfmt+0x286>
  80065d:	85 db                	test   %ebx,%ebx
  80065f:	78 9e                	js     8005ff <vprintfmt+0x201>
  800661:	83 eb 01             	sub    $0x1,%ebx
  800664:	79 99                	jns    8005ff <vprintfmt+0x201>
  800666:	89 f8                	mov    %edi,%eax
  800668:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80066b:	8b 75 08             	mov    0x8(%ebp),%esi
  80066e:	89 c3                	mov    %eax,%ebx
  800670:	eb 1a                	jmp    80068c <vprintfmt+0x28e>
				putch(' ', putdat);
  800672:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800676:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80067d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80067f:	83 eb 01             	sub    $0x1,%ebx
  800682:	eb 08                	jmp    80068c <vprintfmt+0x28e>
  800684:	89 fb                	mov    %edi,%ebx
  800686:	8b 75 08             	mov    0x8(%ebp),%esi
  800689:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80068c:	85 db                	test   %ebx,%ebx
  80068e:	7f e2                	jg     800672 <vprintfmt+0x274>
  800690:	89 75 08             	mov    %esi,0x8(%ebp)
  800693:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800696:	e9 93 fd ff ff       	jmp    80042e <vprintfmt+0x30>
	if (lflag >= 2)
  80069b:	83 fa 01             	cmp    $0x1,%edx
  80069e:	7e 16                	jle    8006b6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 08             	lea    0x8(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 50 04             	mov    0x4(%eax),%edx
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006b4:	eb 32                	jmp    8006e8 <vprintfmt+0x2ea>
	else if (lflag)
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	74 18                	je     8006d2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c3:	8b 30                	mov    (%eax),%esi
  8006c5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006c8:	89 f0                	mov    %esi,%eax
  8006ca:	c1 f8 1f             	sar    $0x1f,%eax
  8006cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d0:	eb 16                	jmp    8006e8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006db:	8b 30                	mov    (%eax),%esi
  8006dd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	c1 f8 1f             	sar    $0x1f,%eax
  8006e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8006e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8006ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006f7:	0f 89 80 00 00 00    	jns    80077d <vprintfmt+0x37f>
				putch('-', putdat);
  8006fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800701:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800708:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80070b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80070e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800711:	f7 d8                	neg    %eax
  800713:	83 d2 00             	adc    $0x0,%edx
  800716:	f7 da                	neg    %edx
			base = 10;
  800718:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80071d:	eb 5e                	jmp    80077d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
  800722:	e8 58 fc ff ff       	call   80037f <getuint>
			base = 10;
  800727:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80072c:	eb 4f                	jmp    80077d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
  800731:	e8 49 fc ff ff       	call   80037f <getuint>
            base = 8;
  800736:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80073b:	eb 40                	jmp    80077d <vprintfmt+0x37f>
			putch('0', putdat);
  80073d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800741:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80074b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800756:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8d 50 04             	lea    0x4(%eax),%edx
  80075f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800762:	8b 00                	mov    (%eax),%eax
  800764:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800769:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076e:	eb 0d                	jmp    80077d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
  800773:	e8 07 fc ff ff       	call   80037f <getuint>
			base = 16;
  800778:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80077d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800781:	89 74 24 10          	mov    %esi,0x10(%esp)
  800785:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800788:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80078c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	89 54 24 04          	mov    %edx,0x4(%esp)
  800797:	89 fa                	mov    %edi,%edx
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	e8 ef fa ff ff       	call   800290 <printnum>
			break;
  8007a1:	e9 88 fc ff ff       	jmp    80042e <vprintfmt+0x30>
			putch(ch, putdat);
  8007a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007aa:	89 04 24             	mov    %eax,(%esp)
  8007ad:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007b0:	e9 79 fc ff ff       	jmp    80042e <vprintfmt+0x30>
			putch('%', putdat);
  8007b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c3:	89 f3                	mov    %esi,%ebx
  8007c5:	eb 03                	jmp    8007ca <vprintfmt+0x3cc>
  8007c7:	83 eb 01             	sub    $0x1,%ebx
  8007ca:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007ce:	75 f7                	jne    8007c7 <vprintfmt+0x3c9>
  8007d0:	e9 59 fc ff ff       	jmp    80042e <vprintfmt+0x30>
}
  8007d5:	83 c4 3c             	add    $0x3c,%esp
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5f                   	pop    %edi
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	83 ec 28             	sub    $0x28,%esp
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	74 30                	je     80082e <vsnprintf+0x51>
  8007fe:	85 d2                	test   %edx,%edx
  800800:	7e 2c                	jle    80082e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800809:	8b 45 10             	mov    0x10(%ebp),%eax
  80080c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800810:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800813:	89 44 24 04          	mov    %eax,0x4(%esp)
  800817:	c7 04 24 b9 03 80 00 	movl   $0x8003b9,(%esp)
  80081e:	e8 db fb ff ff       	call   8003fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800823:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800826:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082c:	eb 05                	jmp    800833 <vsnprintf+0x56>
		return -E_INVAL;
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 82 ff ff ff       	call   8007dd <vsnprintf>
	va_end(ap);

	return rc;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    
  80085d:	66 90                	xchg   %ax,%ax
  80085f:	90                   	nop

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	74 06                	je     800895 <strnlen+0x1d>
  80088f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
	return n;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c2 01             	add    $0x1,%edx
  8008a6:	83 c1 01             	add    $0x1,%ecx
  8008a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b0:	84 db                	test   %bl,%bl
  8008b2:	75 ef                	jne    8008a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c1:	89 1c 24             	mov    %ebx,(%esp)
  8008c4:	e8 97 ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d0:	01 d8                	add    %ebx,%eax
  8008d2:	89 04 24             	mov    %eax,(%esp)
  8008d5:	e8 bd ff ff ff       	call   800897 <strcpy>
	return dst;
}
  8008da:	89 d8                	mov    %ebx,%eax
  8008dc:	83 c4 08             	add    $0x8,%esp
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	89 f3                	mov    %esi,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	eb 0f                	jmp    800905 <strncpy+0x23>
		*dst++ = *src;
  8008f6:	83 c2 01             	add    $0x1,%edx
  8008f9:	0f b6 01             	movzbl (%ecx),%eax
  8008fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800902:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800905:	39 da                	cmp    %ebx,%edx
  800907:	75 ed                	jne    8008f6 <strncpy+0x14>
	}
	return ret;
}
  800909:	89 f0                	mov    %esi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 75 08             	mov    0x8(%ebp),%esi
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80091d:	89 f0                	mov    %esi,%eax
  80091f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800923:	85 c9                	test   %ecx,%ecx
  800925:	75 0b                	jne    800932 <strlcpy+0x23>
  800927:	eb 1d                	jmp    800946 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800932:	39 d8                	cmp    %ebx,%eax
  800934:	74 0b                	je     800941 <strlcpy+0x32>
  800936:	0f b6 0a             	movzbl (%edx),%ecx
  800939:	84 c9                	test   %cl,%cl
  80093b:	75 ec                	jne    800929 <strlcpy+0x1a>
  80093d:	89 c2                	mov    %eax,%edx
  80093f:	eb 02                	jmp    800943 <strlcpy+0x34>
  800941:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800943:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 07                	jmp    8009de <strfind+0x13>
		if (*s == c)
  8009d7:	38 ca                	cmp    %cl,%dl
  8009d9:	74 0a                	je     8009e5 <strfind+0x1a>
	for (; *s; s++)
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	0f b6 10             	movzbl (%eax),%edx
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
  800a1b:	89 d0                	mov    %edx,%eax
  800a1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a89:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 79 ff ff ff       	call   800a34 <memmove>
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	eb 1a                	jmp    800ae9 <memcmp+0x2c>
		if (*s1 != *s2)
  800acf:	0f b6 02             	movzbl (%edx),%eax
  800ad2:	0f b6 19             	movzbl (%ecx),%ebx
  800ad5:	38 d8                	cmp    %bl,%al
  800ad7:	74 0a                	je     800ae3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ad9:	0f b6 c0             	movzbl %al,%eax
  800adc:	0f b6 db             	movzbl %bl,%ebx
  800adf:	29 d8                	sub    %ebx,%eax
  800ae1:	eb 0f                	jmp    800af2 <memcmp+0x35>
		s1++, s2++;
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800ae9:	39 f2                	cmp    %esi,%edx
  800aeb:	75 e2                	jne    800acf <memcmp+0x12>
	}

	return 0;
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b04:	eb 07                	jmp    800b0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	38 08                	cmp    %cl,(%eax)
  800b08:	74 07                	je     800b11 <memfind+0x1b>
	for (; s < ends; s++)
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	39 d0                	cmp    %edx,%eax
  800b0f:	72 f5                	jb     800b06 <memfind+0x10>
			break;
	return (void *) s;
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1f:	eb 03                	jmp    800b24 <strtol+0x11>
		s++;
  800b21:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b24:	0f b6 0a             	movzbl (%edx),%ecx
  800b27:	80 f9 09             	cmp    $0x9,%cl
  800b2a:	74 f5                	je     800b21 <strtol+0xe>
  800b2c:	80 f9 20             	cmp    $0x20,%cl
  800b2f:	74 f0                	je     800b21 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b31:	80 f9 2b             	cmp    $0x2b,%cl
  800b34:	75 0a                	jne    800b40 <strtol+0x2d>
		s++;
  800b36:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b39:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3e:	eb 11                	jmp    800b51 <strtol+0x3e>
  800b40:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b45:	80 f9 2d             	cmp    $0x2d,%cl
  800b48:	75 07                	jne    800b51 <strtol+0x3e>
		s++, neg = 1;
  800b4a:	8d 52 01             	lea    0x1(%edx),%edx
  800b4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b56:	75 15                	jne    800b6d <strtol+0x5a>
  800b58:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5b:	75 10                	jne    800b6d <strtol+0x5a>
  800b5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b61:	75 0a                	jne    800b6d <strtol+0x5a>
		s += 2, base = 16;
  800b63:	83 c2 02             	add    $0x2,%edx
  800b66:	b8 10 00 00 00       	mov    $0x10,%eax
  800b6b:	eb 10                	jmp    800b7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	75 0c                	jne    800b7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b71:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b73:	80 3a 30             	cmpb   $0x30,(%edx)
  800b76:	75 05                	jne    800b7d <strtol+0x6a>
		s++, base = 8;
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	b0 08                	mov    $0x8,%al
		base = 10;
  800b7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b85:	0f b6 0a             	movzbl (%edx),%ecx
  800b88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	3c 09                	cmp    $0x9,%al
  800b8f:	77 08                	ja     800b99 <strtol+0x86>
			dig = *s - '0';
  800b91:	0f be c9             	movsbl %cl,%ecx
  800b94:	83 e9 30             	sub    $0x30,%ecx
  800b97:	eb 20                	jmp    800bb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b9c:	89 f0                	mov    %esi,%eax
  800b9e:	3c 19                	cmp    $0x19,%al
  800ba0:	77 08                	ja     800baa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ba2:	0f be c9             	movsbl %cl,%ecx
  800ba5:	83 e9 57             	sub    $0x57,%ecx
  800ba8:	eb 0f                	jmp    800bb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800baa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	3c 19                	cmp    $0x19,%al
  800bb1:	77 16                	ja     800bc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bb3:	0f be c9             	movsbl %cl,%ecx
  800bb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bbc:	7d 0f                	jge    800bcd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bc7:	eb bc                	jmp    800b85 <strtol+0x72>
  800bc9:	89 d8                	mov    %ebx,%eax
  800bcb:	eb 02                	jmp    800bcf <strtol+0xbc>
  800bcd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd3:	74 05                	je     800bda <strtol+0xc7>
		*endptr = (char *) s;
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bda:	f7 d8                	neg    %eax
  800bdc:	85 ff                	test   %edi,%edi
  800bde:	0f 44 c3             	cmove  %ebx,%eax
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	89 c7                	mov    %eax,%edi
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c14:	89 d1                	mov    %edx,%ecx
  800c16:	89 d3                	mov    %edx,%ebx
  800c18:	89 d7                	mov    %edx,%edi
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c31:	b8 03 00 00 00       	mov    $0x3,%eax
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 cb                	mov    %ecx,%ebx
  800c3b:	89 cf                	mov    %ecx,%edi
  800c3d:	89 ce                	mov    %ecx,%esi
  800c3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 28                	jle    800c6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c50:	00 
  800c51:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800c58:	00 
  800c59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c60:	00 
  800c61:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800c68:	e8 05 f5 ff ff       	call   800172 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6d:	83 c4 2c             	add    $0x2c,%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 02 00 00 00       	mov    $0x2,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_yield>:

void
sys_yield(void)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca4:	89 d1                	mov    %edx,%ecx
  800ca6:	89 d3                	mov    %edx,%ebx
  800ca8:	89 d7                	mov    %edx,%edi
  800caa:	89 d6                	mov    %edx,%esi
  800cac:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cbc:	be 00 00 00 00       	mov    $0x0,%esi
  800cc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccf:	89 f7                	mov    %esi,%edi
  800cd1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800cfa:	e8 73 f4 ff ff       	call   800172 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d10:	b8 05 00 00 00       	mov    $0x5,%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d21:	8b 75 18             	mov    0x18(%ebp),%esi
  800d24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800d4d:	e8 20 f4 ff ff       	call   800172 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800da0:	e8 cd f3 ff ff       	call   800172 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800df3:	e8 7a f3 ff ff       	call   800172 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df8:	83 c4 2c             	add    $0x2c,%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 28                	jle    800e4b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e27:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800e46:	e8 27 f3 ff ff       	call   800172 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e4b:	83 c4 2c             	add    $0x2c,%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 df                	mov    %ebx,%edi
  800e6e:	89 de                	mov    %ebx,%esi
  800e70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800e99:	e8 d4 f2 ff ff       	call   800172 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9e:	83 c4 2c             	add    $0x2c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eac:	be 00 00 00 00       	mov    $0x0,%esi
  800eb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ed2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800edc:	8b 55 08             	mov    0x8(%ebp),%edx
  800edf:	89 cb                	mov    %ecx,%ebx
  800ee1:	89 cf                	mov    %ecx,%edi
  800ee3:	89 ce                	mov    %ecx,%esi
  800ee5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 28                	jle    800f13 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eeb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ef6:	00 
  800ef7:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800efe:	00 
  800eff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f06:	00 
  800f07:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800f0e:	e8 5f f2 ff ff       	call   800172 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f13:	83 c4 2c             	add    $0x2c,%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    
  800f1b:	66 90                	xchg   %ax,%ax
  800f1d:	66 90                	xchg   %ax,%ax
  800f1f:	90                   	nop

00800f20 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	53                   	push   %ebx
  800f24:	83 ec 24             	sub    $0x24,%esp
  800f27:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  800f2a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  800f2c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f30:	74 18                	je     800f4a <pgfault+0x2a>
  800f32:	89 d8                	mov    %ebx,%eax
  800f34:	c1 e8 0c             	shr    $0xc,%eax
  800f37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3e:	25 05 08 00 00       	and    $0x805,%eax
  800f43:	3d 05 08 00 00       	cmp    $0x805,%eax
  800f48:	74 1c                	je     800f66 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  800f4a:	c7 44 24 08 0c 28 80 	movl   $0x80280c,0x8(%esp)
  800f51:	00 
  800f52:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f59:	00 
  800f5a:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  800f61:	e8 0c f2 ff ff       	call   800172 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  800f66:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f6d:	00 
  800f6e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f75:	00 
  800f76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f7d:	e8 31 fd ff ff       	call   800cb3 <sys_page_alloc>
	if(r < 0){
  800f82:	85 c0                	test   %eax,%eax
  800f84:	79 1c                	jns    800fa2 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  800f86:	c7 44 24 08 3c 28 80 	movl   $0x80283c,0x8(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800f95:	00 
  800f96:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  800f9d:	e8 d0 f1 ff ff       	call   800172 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800fa2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800fa8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800faf:	00 
  800fb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fb4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fbb:	e8 dc fa ff ff       	call   800a9c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  800fc0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fc7:	00 
  800fc8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fcc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fdb:	00 
  800fdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe3:	e8 1f fd ff ff       	call   800d07 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	79 1c                	jns    801008 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  800fec:	c7 44 24 08 08 29 80 	movl   $0x802908,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801003:	e8 6a f1 ff ff       	call   800172 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  801008:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80100f:	00 
  801010:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801017:	e8 3e fd ff ff       	call   800d5a <sys_page_unmap>
    if(r < 0){
  80101c:	85 c0                	test   %eax,%eax
  80101e:	79 1c                	jns    80103c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  801020:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  801027:	00 
  801028:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80102f:	00 
  801030:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801037:	e8 36 f1 ff ff       	call   800172 <_panic>
    }
    // LAB 4
}
  80103c:	83 c4 24             	add    $0x24,%esp
  80103f:	5b                   	pop    %ebx
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  80104b:	c7 04 24 20 0f 80 00 	movl   $0x800f20,(%esp)
  801052:	e8 5f 0f 00 00       	call   801fb6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801057:	b8 07 00 00 00       	mov    $0x7,%eax
  80105c:	cd 30                	int    $0x30
  80105e:	89 c7                	mov    %eax,%edi
  801060:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801063:	85 c0                	test   %eax,%eax
  801065:	79 1c                	jns    801083 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801067:	c7 44 24 08 38 29 80 	movl   $0x802938,0x8(%esp)
  80106e:	00 
  80106f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801076:	00 
  801077:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  80107e:	e8 ef f0 ff ff       	call   800172 <_panic>
    }
    if(child == 0){
  801083:	bb 00 00 00 00       	mov    $0x0,%ebx
  801088:	85 c0                	test   %eax,%eax
  80108a:	75 21                	jne    8010ad <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80108c:	e8 e4 fb ff ff       	call   800c75 <sys_getenvid>
  801091:	25 ff 03 00 00       	and    $0x3ff,%eax
  801096:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801099:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109e:	a3 0c 40 80 00       	mov    %eax,0x80400c
        // It's a whole lot like lab3 with the env stuff
        return 0;
  8010a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a8:	e9 67 01 00 00       	jmp    801214 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  8010ad:	89 d8                	mov    %ebx,%eax
  8010af:	c1 e8 16             	shr    $0x16,%eax
  8010b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b9:	a8 01                	test   $0x1,%al
  8010bb:	74 4b                	je     801108 <fork+0xc6>
  8010bd:	89 de                	mov    %ebx,%esi
  8010bf:	c1 ee 0c             	shr    $0xc,%esi
  8010c2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010c9:	a8 01                	test   $0x1,%al
  8010cb:	74 3b                	je     801108 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  8010cd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d4:	a9 02 08 00 00       	test   $0x802,%eax
  8010d9:	0f 85 02 01 00 00    	jne    8011e1 <fork+0x19f>
  8010df:	e9 d2 00 00 00       	jmp    8011b6 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  8010e4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010eb:	00 
  8010ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010f7:	00 
  8010f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801103:	e8 ff fb ff ff       	call   800d07 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801108:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80110e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801114:	75 97                	jne    8010ad <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801116:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80111d:	00 
  80111e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801125:	ee 
  801126:	89 3c 24             	mov    %edi,(%esp)
  801129:	e8 85 fb ff ff       	call   800cb3 <sys_page_alloc>

    if(r < 0){
  80112e:	85 c0                	test   %eax,%eax
  801130:	79 1c                	jns    80114e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801132:	c7 44 24 08 70 28 80 	movl   $0x802870,0x8(%esp)
  801139:	00 
  80113a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801141:	00 
  801142:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801149:	e8 24 f0 ff ff       	call   800172 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80114e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801153:	8b 40 64             	mov    0x64(%eax),%eax
  801156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115a:	89 3c 24             	mov    %edi,(%esp)
  80115d:	e8 f1 fc ff ff       	call   800e53 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801162:	85 c0                	test   %eax,%eax
  801164:	79 1c                	jns    801182 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801166:	c7 44 24 08 90 28 80 	movl   $0x802890,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  80117d:	e8 f0 ef ff ff       	call   800172 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801182:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801189:	00 
  80118a:	89 3c 24             	mov    %edi,(%esp)
  80118d:	e8 1b fc ff ff       	call   800dad <sys_env_set_status>
    if(r < 0){
  801192:	85 c0                	test   %eax,%eax
  801194:	79 1c                	jns    8011b2 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801196:	c7 44 24 08 b8 28 80 	movl   $0x8028b8,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  8011ad:	e8 c0 ef ff ff       	call   800172 <_panic>
    }
    return child;
  8011b2:	89 f8                	mov    %edi,%eax
  8011b4:	eb 5e                	jmp    801214 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  8011b6:	c1 e6 0c             	shl    $0xc,%esi
  8011b9:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011c0:	00 
  8011c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d7:	e8 2b fb ff ff       	call   800d07 <sys_page_map>
  8011dc:	e9 27 ff ff ff       	jmp    801108 <fork+0xc6>
  8011e1:	c1 e6 0c             	shl    $0xc,%esi
  8011e4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011eb:	00 
  8011ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801202:	e8 00 fb ff ff       	call   800d07 <sys_page_map>
    if( r < 0 ){
  801207:	85 c0                	test   %eax,%eax
  801209:	0f 89 d5 fe ff ff    	jns    8010e4 <fork+0xa2>
  80120f:	e9 f4 fe ff ff       	jmp    801108 <fork+0xc6>
//	panic("fork not implemented");
}
  801214:	83 c4 2c             	add    $0x2c,%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <sfork>:

// Challenge!
int
sfork(void)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801222:	c7 44 24 08 55 29 80 	movl   $0x802955,0x8(%esp)
  801229:	00 
  80122a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801231:	00 
  801232:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801239:	e8 34 ef ff ff       	call   800172 <_panic>
  80123e:	66 90                	xchg   %ax,%ax

00801240 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
  801246:	05 00 00 00 30       	add    $0x30000000,%eax
  80124b:	c1 e8 0c             	shr    $0xc,%eax
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80125b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801260:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    

00801267 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801272:	89 c2                	mov    %eax,%edx
  801274:	c1 ea 16             	shr    $0x16,%edx
  801277:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127e:	f6 c2 01             	test   $0x1,%dl
  801281:	74 11                	je     801294 <fd_alloc+0x2d>
  801283:	89 c2                	mov    %eax,%edx
  801285:	c1 ea 0c             	shr    $0xc,%edx
  801288:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	75 09                	jne    80129d <fd_alloc+0x36>
			*fd_store = fd;
  801294:	89 01                	mov    %eax,(%ecx)
			return 0;
  801296:	b8 00 00 00 00       	mov    $0x0,%eax
  80129b:	eb 17                	jmp    8012b4 <fd_alloc+0x4d>
  80129d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a7:	75 c9                	jne    801272 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8012a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012bc:	83 f8 1f             	cmp    $0x1f,%eax
  8012bf:	77 36                	ja     8012f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c1:	c1 e0 0c             	shl    $0xc,%eax
  8012c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	c1 ea 16             	shr    $0x16,%edx
  8012ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 24                	je     8012fe <fd_lookup+0x48>
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	c1 ea 0c             	shr    $0xc,%edx
  8012df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	74 1a                	je     801305 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f5:	eb 13                	jmp    80130a <fd_lookup+0x54>
		return -E_INVAL;
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb 0c                	jmp    80130a <fd_lookup+0x54>
		return -E_INVAL;
  8012fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801303:	eb 05                	jmp    80130a <fd_lookup+0x54>
  801305:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 18             	sub    $0x18,%esp
  801312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801315:	ba e8 29 80 00       	mov    $0x8029e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80131a:	eb 13                	jmp    80132f <dev_lookup+0x23>
  80131c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80131f:	39 08                	cmp    %ecx,(%eax)
  801321:	75 0c                	jne    80132f <dev_lookup+0x23>
			*dev = devtab[i];
  801323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801326:	89 01                	mov    %eax,(%ecx)
			return 0;
  801328:	b8 00 00 00 00       	mov    $0x0,%eax
  80132d:	eb 30                	jmp    80135f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80132f:	8b 02                	mov    (%edx),%eax
  801331:	85 c0                	test   %eax,%eax
  801333:	75 e7                	jne    80131c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801335:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80133a:	8b 40 48             	mov    0x48(%eax),%eax
  80133d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801341:	89 44 24 04          	mov    %eax,0x4(%esp)
  801345:	c7 04 24 6c 29 80 00 	movl   $0x80296c,(%esp)
  80134c:	e8 1a ef ff ff       	call   80026b <cprintf>
	*dev = 0;
  801351:	8b 45 0c             	mov    0xc(%ebp),%eax
  801354:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80135a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <fd_close>:
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	56                   	push   %esi
  801365:	53                   	push   %ebx
  801366:	83 ec 20             	sub    $0x20,%esp
  801369:	8b 75 08             	mov    0x8(%ebp),%esi
  80136c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80136f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801372:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801376:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80137c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80137f:	89 04 24             	mov    %eax,(%esp)
  801382:	e8 2f ff ff ff       	call   8012b6 <fd_lookup>
  801387:	85 c0                	test   %eax,%eax
  801389:	78 05                	js     801390 <fd_close+0x2f>
	    || fd != fd2)
  80138b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80138e:	74 0c                	je     80139c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801390:	84 db                	test   %bl,%bl
  801392:	ba 00 00 00 00       	mov    $0x0,%edx
  801397:	0f 44 c2             	cmove  %edx,%eax
  80139a:	eb 3f                	jmp    8013db <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80139c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a3:	8b 06                	mov    (%esi),%eax
  8013a5:	89 04 24             	mov    %eax,(%esp)
  8013a8:	e8 5f ff ff ff       	call   80130c <dev_lookup>
  8013ad:	89 c3                	mov    %eax,%ebx
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 16                	js     8013c9 <fd_close+0x68>
		if (dev->dev_close)
  8013b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	74 07                	je     8013c9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8013c2:	89 34 24             	mov    %esi,(%esp)
  8013c5:	ff d0                	call   *%eax
  8013c7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8013c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d4:	e8 81 f9 ff ff       	call   800d5a <sys_page_unmap>
	return r;
  8013d9:	89 d8                	mov    %ebx,%eax
}
  8013db:	83 c4 20             	add    $0x20,%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <close>:

int
close(int fdnum)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	89 04 24             	mov    %eax,(%esp)
  8013f5:	e8 bc fe ff ff       	call   8012b6 <fd_lookup>
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	85 d2                	test   %edx,%edx
  8013fe:	78 13                	js     801413 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801400:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801407:	00 
  801408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	e8 4e ff ff ff       	call   801361 <fd_close>
}
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <close_all>:

void
close_all(void)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	53                   	push   %ebx
  801419:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80141c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801421:	89 1c 24             	mov    %ebx,(%esp)
  801424:	e8 b9 ff ff ff       	call   8013e2 <close>
	for (i = 0; i < MAXFD; i++)
  801429:	83 c3 01             	add    $0x1,%ebx
  80142c:	83 fb 20             	cmp    $0x20,%ebx
  80142f:	75 f0                	jne    801421 <close_all+0xc>
}
  801431:	83 c4 14             	add    $0x14,%esp
  801434:	5b                   	pop    %ebx
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	57                   	push   %edi
  80143b:	56                   	push   %esi
  80143c:	53                   	push   %ebx
  80143d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801440:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801443:	89 44 24 04          	mov    %eax,0x4(%esp)
  801447:	8b 45 08             	mov    0x8(%ebp),%eax
  80144a:	89 04 24             	mov    %eax,(%esp)
  80144d:	e8 64 fe ff ff       	call   8012b6 <fd_lookup>
  801452:	89 c2                	mov    %eax,%edx
  801454:	85 d2                	test   %edx,%edx
  801456:	0f 88 e1 00 00 00    	js     80153d <dup+0x106>
		return r;
	close(newfdnum);
  80145c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145f:	89 04 24             	mov    %eax,(%esp)
  801462:	e8 7b ff ff ff       	call   8013e2 <close>

	newfd = INDEX2FD(newfdnum);
  801467:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146a:	c1 e3 0c             	shl    $0xc,%ebx
  80146d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801476:	89 04 24             	mov    %eax,(%esp)
  801479:	e8 d2 fd ff ff       	call   801250 <fd2data>
  80147e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801480:	89 1c 24             	mov    %ebx,(%esp)
  801483:	e8 c8 fd ff ff       	call   801250 <fd2data>
  801488:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148a:	89 f0                	mov    %esi,%eax
  80148c:	c1 e8 16             	shr    $0x16,%eax
  80148f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801496:	a8 01                	test   $0x1,%al
  801498:	74 43                	je     8014dd <dup+0xa6>
  80149a:	89 f0                	mov    %esi,%eax
  80149c:	c1 e8 0c             	shr    $0xc,%eax
  80149f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014a6:	f6 c2 01             	test   $0x1,%dl
  8014a9:	74 32                	je     8014dd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014c6:	00 
  8014c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d2:	e8 30 f8 ff ff       	call   800d07 <sys_page_map>
  8014d7:	89 c6                	mov    %eax,%esi
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 3e                	js     80151b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e0:	89 c2                	mov    %eax,%edx
  8014e2:	c1 ea 0c             	shr    $0xc,%edx
  8014e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014f2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014f6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801501:	00 
  801502:	89 44 24 04          	mov    %eax,0x4(%esp)
  801506:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80150d:	e8 f5 f7 ff ff       	call   800d07 <sys_page_map>
  801512:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801514:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801517:	85 f6                	test   %esi,%esi
  801519:	79 22                	jns    80153d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80151b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80151f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801526:	e8 2f f8 ff ff       	call   800d5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80152f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801536:	e8 1f f8 ff ff       	call   800d5a <sys_page_unmap>
	return r;
  80153b:	89 f0                	mov    %esi,%eax
}
  80153d:	83 c4 3c             	add    $0x3c,%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5f                   	pop    %edi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 24             	sub    $0x24,%esp
  80154c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801552:	89 44 24 04          	mov    %eax,0x4(%esp)
  801556:	89 1c 24             	mov    %ebx,(%esp)
  801559:	e8 58 fd ff ff       	call   8012b6 <fd_lookup>
  80155e:	89 c2                	mov    %eax,%edx
  801560:	85 d2                	test   %edx,%edx
  801562:	78 6d                	js     8015d1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801564:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156e:	8b 00                	mov    (%eax),%eax
  801570:	89 04 24             	mov    %eax,(%esp)
  801573:	e8 94 fd ff ff       	call   80130c <dev_lookup>
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 55                	js     8015d1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80157c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157f:	8b 50 08             	mov    0x8(%eax),%edx
  801582:	83 e2 03             	and    $0x3,%edx
  801585:	83 fa 01             	cmp    $0x1,%edx
  801588:	75 23                	jne    8015ad <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80158f:	8b 40 48             	mov    0x48(%eax),%eax
  801592:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801596:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159a:	c7 04 24 ad 29 80 00 	movl   $0x8029ad,(%esp)
  8015a1:	e8 c5 ec ff ff       	call   80026b <cprintf>
		return -E_INVAL;
  8015a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ab:	eb 24                	jmp    8015d1 <read+0x8c>
	}
	if (!dev->dev_read)
  8015ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b0:	8b 52 08             	mov    0x8(%edx),%edx
  8015b3:	85 d2                	test   %edx,%edx
  8015b5:	74 15                	je     8015cc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	ff d2                	call   *%edx
  8015ca:	eb 05                	jmp    8015d1 <read+0x8c>
		return -E_NOT_SUPP;
  8015cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015d1:	83 c4 24             	add    $0x24,%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 1c             	sub    $0x1c,%esp
  8015e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015eb:	eb 23                	jmp    801610 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ed:	89 f0                	mov    %esi,%eax
  8015ef:	29 d8                	sub    %ebx,%eax
  8015f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015f5:	89 d8                	mov    %ebx,%eax
  8015f7:	03 45 0c             	add    0xc(%ebp),%eax
  8015fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fe:	89 3c 24             	mov    %edi,(%esp)
  801601:	e8 3f ff ff ff       	call   801545 <read>
		if (m < 0)
  801606:	85 c0                	test   %eax,%eax
  801608:	78 10                	js     80161a <readn+0x43>
			return m;
		if (m == 0)
  80160a:	85 c0                	test   %eax,%eax
  80160c:	74 0a                	je     801618 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80160e:	01 c3                	add    %eax,%ebx
  801610:	39 f3                	cmp    %esi,%ebx
  801612:	72 d9                	jb     8015ed <readn+0x16>
  801614:	89 d8                	mov    %ebx,%eax
  801616:	eb 02                	jmp    80161a <readn+0x43>
  801618:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80161a:	83 c4 1c             	add    $0x1c,%esp
  80161d:	5b                   	pop    %ebx
  80161e:	5e                   	pop    %esi
  80161f:	5f                   	pop    %edi
  801620:	5d                   	pop    %ebp
  801621:	c3                   	ret    

00801622 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	53                   	push   %ebx
  801626:	83 ec 24             	sub    $0x24,%esp
  801629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801633:	89 1c 24             	mov    %ebx,(%esp)
  801636:	e8 7b fc ff ff       	call   8012b6 <fd_lookup>
  80163b:	89 c2                	mov    %eax,%edx
  80163d:	85 d2                	test   %edx,%edx
  80163f:	78 68                	js     8016a9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801644:	89 44 24 04          	mov    %eax,0x4(%esp)
  801648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164b:	8b 00                	mov    (%eax),%eax
  80164d:	89 04 24             	mov    %eax,(%esp)
  801650:	e8 b7 fc ff ff       	call   80130c <dev_lookup>
  801655:	85 c0                	test   %eax,%eax
  801657:	78 50                	js     8016a9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801659:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801660:	75 23                	jne    801685 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801662:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801667:	8b 40 48             	mov    0x48(%eax),%eax
  80166a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80166e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801672:	c7 04 24 c9 29 80 00 	movl   $0x8029c9,(%esp)
  801679:	e8 ed eb ff ff       	call   80026b <cprintf>
		return -E_INVAL;
  80167e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801683:	eb 24                	jmp    8016a9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801685:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801688:	8b 52 0c             	mov    0xc(%edx),%edx
  80168b:	85 d2                	test   %edx,%edx
  80168d:	74 15                	je     8016a4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80168f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801692:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801699:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80169d:	89 04 24             	mov    %eax,(%esp)
  8016a0:	ff d2                	call   *%edx
  8016a2:	eb 05                	jmp    8016a9 <write+0x87>
		return -E_NOT_SUPP;
  8016a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016a9:	83 c4 24             	add    $0x24,%esp
  8016ac:	5b                   	pop    %ebx
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <seek>:

int
seek(int fdnum, off_t offset)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	89 04 24             	mov    %eax,(%esp)
  8016c2:	e8 ef fb ff ff       	call   8012b6 <fd_lookup>
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 0e                	js     8016d9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	83 ec 24             	sub    $0x24,%esp
  8016e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ec:	89 1c 24             	mov    %ebx,(%esp)
  8016ef:	e8 c2 fb ff ff       	call   8012b6 <fd_lookup>
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	85 d2                	test   %edx,%edx
  8016f8:	78 61                	js     80175b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	8b 00                	mov    (%eax),%eax
  801706:	89 04 24             	mov    %eax,(%esp)
  801709:	e8 fe fb ff ff       	call   80130c <dev_lookup>
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 49                	js     80175b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801712:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801715:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801719:	75 23                	jne    80173e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80171b:	a1 0c 40 80 00       	mov    0x80400c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801720:	8b 40 48             	mov    0x48(%eax),%eax
  801723:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172b:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  801732:	e8 34 eb ff ff       	call   80026b <cprintf>
		return -E_INVAL;
  801737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173c:	eb 1d                	jmp    80175b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80173e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801741:	8b 52 18             	mov    0x18(%edx),%edx
  801744:	85 d2                	test   %edx,%edx
  801746:	74 0e                	je     801756 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801748:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80174f:	89 04 24             	mov    %eax,(%esp)
  801752:	ff d2                	call   *%edx
  801754:	eb 05                	jmp    80175b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801756:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80175b:	83 c4 24             	add    $0x24,%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	53                   	push   %ebx
  801765:	83 ec 24             	sub    $0x24,%esp
  801768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	e8 39 fb ff ff       	call   8012b6 <fd_lookup>
  80177d:	89 c2                	mov    %eax,%edx
  80177f:	85 d2                	test   %edx,%edx
  801781:	78 52                	js     8017d5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801783:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801786:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178d:	8b 00                	mov    (%eax),%eax
  80178f:	89 04 24             	mov    %eax,(%esp)
  801792:	e8 75 fb ff ff       	call   80130c <dev_lookup>
  801797:	85 c0                	test   %eax,%eax
  801799:	78 3a                	js     8017d5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a2:	74 2c                	je     8017d0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ae:	00 00 00 
	stat->st_isdir = 0;
  8017b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b8:	00 00 00 
	stat->st_dev = dev;
  8017bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017c8:	89 14 24             	mov    %edx,(%esp)
  8017cb:	ff 50 14             	call   *0x14(%eax)
  8017ce:	eb 05                	jmp    8017d5 <fstat+0x74>
		return -E_NOT_SUPP;
  8017d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017d5:	83 c4 24             	add    $0x24,%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017ea:	00 
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	89 04 24             	mov    %eax,(%esp)
  8017f1:	e8 fb 01 00 00       	call   8019f1 <open>
  8017f6:	89 c3                	mov    %eax,%ebx
  8017f8:	85 db                	test   %ebx,%ebx
  8017fa:	78 1b                	js     801817 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	89 1c 24             	mov    %ebx,(%esp)
  801806:	e8 56 ff ff ff       	call   801761 <fstat>
  80180b:	89 c6                	mov    %eax,%esi
	close(fd);
  80180d:	89 1c 24             	mov    %ebx,(%esp)
  801810:	e8 cd fb ff ff       	call   8013e2 <close>
	return r;
  801815:	89 f0                	mov    %esi,%eax
}
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	83 ec 10             	sub    $0x10,%esp
  801826:	89 c6                	mov    %eax,%esi
  801828:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80182a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801831:	75 11                	jne    801844 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801833:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80183a:	e8 00 09 00 00       	call   80213f <ipc_find_env>
  80183f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801844:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80184b:	00 
  80184c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801853:	00 
  801854:	89 74 24 04          	mov    %esi,0x4(%esp)
  801858:	a1 04 40 80 00       	mov    0x804004,%eax
  80185d:	89 04 24             	mov    %eax,(%esp)
  801860:	e8 73 08 00 00       	call   8020d8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801865:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80186c:	00 
  80186d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801871:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801878:	e8 f3 07 00 00       	call   802070 <ipc_recv>
}
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80188a:	8b 45 08             	mov    0x8(%ebp),%eax
  80188d:	8b 40 0c             	mov    0xc(%eax),%eax
  801890:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801895:	8b 45 0c             	mov    0xc(%ebp),%eax
  801898:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a7:	e8 72 ff ff ff       	call   80181e <fsipc>
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <devfile_flush>:
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c9:	e8 50 ff ff ff       	call   80181e <fsipc>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devfile_stat>:
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 14             	sub    $0x14,%esp
  8018d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ef:	e8 2a ff ff ff       	call   80181e <fsipc>
  8018f4:	89 c2                	mov    %eax,%edx
  8018f6:	85 d2                	test   %edx,%edx
  8018f8:	78 2b                	js     801925 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018fa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801901:	00 
  801902:	89 1c 24             	mov    %ebx,(%esp)
  801905:	e8 8d ef ff ff       	call   800897 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80190a:	a1 80 50 80 00       	mov    0x805080,%eax
  80190f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801915:	a1 84 50 80 00       	mov    0x805084,%eax
  80191a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801925:	83 c4 14             	add    $0x14,%esp
  801928:	5b                   	pop    %ebx
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <devfile_write>:
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801931:	c7 44 24 08 f8 29 80 	movl   $0x8029f8,0x8(%esp)
  801938:	00 
  801939:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801940:	00 
  801941:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  801948:	e8 25 e8 ff ff       	call   800172 <_panic>

0080194d <devfile_read>:
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	56                   	push   %esi
  801951:	53                   	push   %ebx
  801952:	83 ec 10             	sub    $0x10,%esp
  801955:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801958:	8b 45 08             	mov    0x8(%ebp),%eax
  80195b:	8b 40 0c             	mov    0xc(%eax),%eax
  80195e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801963:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801969:	ba 00 00 00 00       	mov    $0x0,%edx
  80196e:	b8 03 00 00 00       	mov    $0x3,%eax
  801973:	e8 a6 fe ff ff       	call   80181e <fsipc>
  801978:	89 c3                	mov    %eax,%ebx
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 6a                	js     8019e8 <devfile_read+0x9b>
	assert(r <= n);
  80197e:	39 c6                	cmp    %eax,%esi
  801980:	73 24                	jae    8019a6 <devfile_read+0x59>
  801982:	c7 44 24 0c 21 2a 80 	movl   $0x802a21,0xc(%esp)
  801989:	00 
  80198a:	c7 44 24 08 28 2a 80 	movl   $0x802a28,0x8(%esp)
  801991:	00 
  801992:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801999:	00 
  80199a:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  8019a1:	e8 cc e7 ff ff       	call   800172 <_panic>
	assert(r <= PGSIZE);
  8019a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ab:	7e 24                	jle    8019d1 <devfile_read+0x84>
  8019ad:	c7 44 24 0c 3d 2a 80 	movl   $0x802a3d,0xc(%esp)
  8019b4:	00 
  8019b5:	c7 44 24 08 28 2a 80 	movl   $0x802a28,0x8(%esp)
  8019bc:	00 
  8019bd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019c4:	00 
  8019c5:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  8019cc:	e8 a1 e7 ff ff       	call   800172 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019dc:	00 
  8019dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e0:	89 04 24             	mov    %eax,(%esp)
  8019e3:	e8 4c f0 ff ff       	call   800a34 <memmove>
}
  8019e8:	89 d8                	mov    %ebx,%eax
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5e                   	pop    %esi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <open>:
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 24             	sub    $0x24,%esp
  8019f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8019fb:	89 1c 24             	mov    %ebx,(%esp)
  8019fe:	e8 5d ee ff ff       	call   800860 <strlen>
  801a03:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a08:	7f 60                	jg     801a6a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801a0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0d:	89 04 24             	mov    %eax,(%esp)
  801a10:	e8 52 f8 ff ff       	call   801267 <fd_alloc>
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	85 d2                	test   %edx,%edx
  801a19:	78 54                	js     801a6f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801a1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a1f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a26:	e8 6c ee ff ff       	call   800897 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a36:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3b:	e8 de fd ff ff       	call   80181e <fsipc>
  801a40:	89 c3                	mov    %eax,%ebx
  801a42:	85 c0                	test   %eax,%eax
  801a44:	79 17                	jns    801a5d <open+0x6c>
		fd_close(fd, 0);
  801a46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a4d:	00 
  801a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a51:	89 04 24             	mov    %eax,(%esp)
  801a54:	e8 08 f9 ff ff       	call   801361 <fd_close>
		return r;
  801a59:	89 d8                	mov    %ebx,%eax
  801a5b:	eb 12                	jmp    801a6f <open+0x7e>
	return fd2num(fd);
  801a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a60:	89 04 24             	mov    %eax,(%esp)
  801a63:	e8 d8 f7 ff ff       	call   801240 <fd2num>
  801a68:	eb 05                	jmp    801a6f <open+0x7e>
		return -E_BAD_PATH;
  801a6a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801a6f:	83 c4 24             	add    $0x24,%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a80:	b8 08 00 00 00       	mov    $0x8,%eax
  801a85:	e8 94 fd ff ff       	call   80181e <fsipc>
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 10             	sub    $0x10,%esp
  801a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	89 04 24             	mov    %eax,(%esp)
  801a9d:	e8 ae f7 ff ff       	call   801250 <fd2data>
  801aa2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa4:	c7 44 24 04 49 2a 80 	movl   $0x802a49,0x4(%esp)
  801aab:	00 
  801aac:	89 1c 24             	mov    %ebx,(%esp)
  801aaf:	e8 e3 ed ff ff       	call   800897 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab4:	8b 46 04             	mov    0x4(%esi),%eax
  801ab7:	2b 06                	sub    (%esi),%eax
  801ab9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801abf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac6:	00 00 00 
	stat->st_dev = &devpipe;
  801ac9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ad0:	30 80 00 
	return 0;
}
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 14             	sub    $0x14,%esp
  801ae6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af4:	e8 61 f2 ff ff       	call   800d5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af9:	89 1c 24             	mov    %ebx,(%esp)
  801afc:	e8 4f f7 ff ff       	call   801250 <fd2data>
  801b01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b0c:	e8 49 f2 ff ff       	call   800d5a <sys_page_unmap>
}
  801b11:	83 c4 14             	add    $0x14,%esp
  801b14:	5b                   	pop    %ebx
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <_pipeisclosed>:
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	57                   	push   %edi
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 2c             	sub    $0x2c,%esp
  801b20:	89 c6                	mov    %eax,%esi
  801b22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801b25:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801b2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b2d:	89 34 24             	mov    %esi,(%esp)
  801b30:	e8 42 06 00 00       	call   802177 <pageref>
  801b35:	89 c7                	mov    %eax,%edi
  801b37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b3a:	89 04 24             	mov    %eax,(%esp)
  801b3d:	e8 35 06 00 00       	call   802177 <pageref>
  801b42:	39 c7                	cmp    %eax,%edi
  801b44:	0f 94 c2             	sete   %dl
  801b47:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801b4a:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  801b50:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801b53:	39 fb                	cmp    %edi,%ebx
  801b55:	74 21                	je     801b78 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801b57:	84 d2                	test   %dl,%dl
  801b59:	74 ca                	je     801b25 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b5b:	8b 51 58             	mov    0x58(%ecx),%edx
  801b5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b62:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b6a:	c7 04 24 50 2a 80 00 	movl   $0x802a50,(%esp)
  801b71:	e8 f5 e6 ff ff       	call   80026b <cprintf>
  801b76:	eb ad                	jmp    801b25 <_pipeisclosed+0xe>
}
  801b78:	83 c4 2c             	add    $0x2c,%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5f                   	pop    %edi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <devpipe_write>:
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	57                   	push   %edi
  801b84:	56                   	push   %esi
  801b85:	53                   	push   %ebx
  801b86:	83 ec 1c             	sub    $0x1c,%esp
  801b89:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b8c:	89 34 24             	mov    %esi,(%esp)
  801b8f:	e8 bc f6 ff ff       	call   801250 <fd2data>
  801b94:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b96:	bf 00 00 00 00       	mov    $0x0,%edi
  801b9b:	eb 45                	jmp    801be2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801b9d:	89 da                	mov    %ebx,%edx
  801b9f:	89 f0                	mov    %esi,%eax
  801ba1:	e8 71 ff ff ff       	call   801b17 <_pipeisclosed>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	75 41                	jne    801beb <devpipe_write+0x6b>
			sys_yield();
  801baa:	e8 e5 f0 ff ff       	call   800c94 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801baf:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb2:	8b 0b                	mov    (%ebx),%ecx
  801bb4:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb7:	39 d0                	cmp    %edx,%eax
  801bb9:	73 e2                	jae    801b9d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc5:	99                   	cltd   
  801bc6:	c1 ea 1b             	shr    $0x1b,%edx
  801bc9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801bcc:	83 e1 1f             	and    $0x1f,%ecx
  801bcf:	29 d1                	sub    %edx,%ecx
  801bd1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801bd5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801bd9:	83 c0 01             	add    $0x1,%eax
  801bdc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bdf:	83 c7 01             	add    $0x1,%edi
  801be2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801be5:	75 c8                	jne    801baf <devpipe_write+0x2f>
	return i;
  801be7:	89 f8                	mov    %edi,%eax
  801be9:	eb 05                	jmp    801bf0 <devpipe_write+0x70>
				return 0;
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <devpipe_read>:
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	57                   	push   %edi
  801bfc:	56                   	push   %esi
  801bfd:	53                   	push   %ebx
  801bfe:	83 ec 1c             	sub    $0x1c,%esp
  801c01:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c04:	89 3c 24             	mov    %edi,(%esp)
  801c07:	e8 44 f6 ff ff       	call   801250 <fd2data>
  801c0c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c0e:	be 00 00 00 00       	mov    $0x0,%esi
  801c13:	eb 3d                	jmp    801c52 <devpipe_read+0x5a>
			if (i > 0)
  801c15:	85 f6                	test   %esi,%esi
  801c17:	74 04                	je     801c1d <devpipe_read+0x25>
				return i;
  801c19:	89 f0                	mov    %esi,%eax
  801c1b:	eb 43                	jmp    801c60 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801c1d:	89 da                	mov    %ebx,%edx
  801c1f:	89 f8                	mov    %edi,%eax
  801c21:	e8 f1 fe ff ff       	call   801b17 <_pipeisclosed>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	75 31                	jne    801c5b <devpipe_read+0x63>
			sys_yield();
  801c2a:	e8 65 f0 ff ff       	call   800c94 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c2f:	8b 03                	mov    (%ebx),%eax
  801c31:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c34:	74 df                	je     801c15 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c36:	99                   	cltd   
  801c37:	c1 ea 1b             	shr    $0x1b,%edx
  801c3a:	01 d0                	add    %edx,%eax
  801c3c:	83 e0 1f             	and    $0x1f,%eax
  801c3f:	29 d0                	sub    %edx,%eax
  801c41:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c49:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c4c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c4f:	83 c6 01             	add    $0x1,%esi
  801c52:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c55:	75 d8                	jne    801c2f <devpipe_read+0x37>
	return i;
  801c57:	89 f0                	mov    %esi,%eax
  801c59:	eb 05                	jmp    801c60 <devpipe_read+0x68>
				return 0;
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <pipe>:
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c73:	89 04 24             	mov    %eax,(%esp)
  801c76:	e8 ec f5 ff ff       	call   801267 <fd_alloc>
  801c7b:	89 c2                	mov    %eax,%edx
  801c7d:	85 d2                	test   %edx,%edx
  801c7f:	0f 88 4d 01 00 00    	js     801dd2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c85:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c8c:	00 
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9b:	e8 13 f0 ff ff       	call   800cb3 <sys_page_alloc>
  801ca0:	89 c2                	mov    %eax,%edx
  801ca2:	85 d2                	test   %edx,%edx
  801ca4:	0f 88 28 01 00 00    	js     801dd2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801caa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cad:	89 04 24             	mov    %eax,(%esp)
  801cb0:	e8 b2 f5 ff ff       	call   801267 <fd_alloc>
  801cb5:	89 c3                	mov    %eax,%ebx
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 88 fe 00 00 00    	js     801dbd <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbf:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cc6:	00 
  801cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd5:	e8 d9 ef ff ff       	call   800cb3 <sys_page_alloc>
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	0f 88 d9 00 00 00    	js     801dbd <pipe+0x155>
	va = fd2data(fd0);
  801ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce7:	89 04 24             	mov    %eax,(%esp)
  801cea:	e8 61 f5 ff ff       	call   801250 <fd2data>
  801cef:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cf8:	00 
  801cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d04:	e8 aa ef ff ff       	call   800cb3 <sys_page_alloc>
  801d09:	89 c3                	mov    %eax,%ebx
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	0f 88 97 00 00 00    	js     801daa <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d16:	89 04 24             	mov    %eax,(%esp)
  801d19:	e8 32 f5 ff ff       	call   801250 <fd2data>
  801d1e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d25:	00 
  801d26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d31:	00 
  801d32:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d3d:	e8 c5 ef ff ff       	call   800d07 <sys_page_map>
  801d42:	89 c3                	mov    %eax,%ebx
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 52                	js     801d9a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801d48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d51:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d5d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d66:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d75:	89 04 24             	mov    %eax,(%esp)
  801d78:	e8 c3 f4 ff ff       	call   801240 <fd2num>
  801d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d80:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d85:	89 04 24             	mov    %eax,(%esp)
  801d88:	e8 b3 f4 ff ff       	call   801240 <fd2num>
  801d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d90:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
  801d98:	eb 38                	jmp    801dd2 <pipe+0x16a>
	sys_page_unmap(0, va);
  801d9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da5:	e8 b0 ef ff ff       	call   800d5a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801daa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db8:	e8 9d ef ff ff       	call   800d5a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dcb:	e8 8a ef ff ff       	call   800d5a <sys_page_unmap>
  801dd0:	89 d8                	mov    %ebx,%eax
}
  801dd2:	83 c4 30             	add    $0x30,%esp
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <pipeisclosed>:
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	89 04 24             	mov    %eax,(%esp)
  801dec:	e8 c5 f4 ff ff       	call   8012b6 <fd_lookup>
  801df1:	89 c2                	mov    %eax,%edx
  801df3:	85 d2                	test   %edx,%edx
  801df5:	78 15                	js     801e0c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfa:	89 04 24             	mov    %eax,(%esp)
  801dfd:	e8 4e f4 ff ff       	call   801250 <fd2data>
	return _pipeisclosed(fd, p);
  801e02:	89 c2                	mov    %eax,%edx
  801e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e07:	e8 0b fd ff ff       	call   801b17 <_pipeisclosed>
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    
  801e0e:	66 90                	xchg   %ax,%ax

00801e10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e13:	b8 00 00 00 00       	mov    $0x0,%eax
  801e18:	5d                   	pop    %ebp
  801e19:	c3                   	ret    

00801e1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801e20:	c7 44 24 04 68 2a 80 	movl   $0x802a68,0x4(%esp)
  801e27:	00 
  801e28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2b:	89 04 24             	mov    %eax,(%esp)
  801e2e:	e8 64 ea ff ff       	call   800897 <strcpy>
	return 0;
}
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <devcons_write>:
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	57                   	push   %edi
  801e3e:	56                   	push   %esi
  801e3f:	53                   	push   %ebx
  801e40:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e46:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e4b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e51:	eb 31                	jmp    801e84 <devcons_write+0x4a>
		m = n - tot;
  801e53:	8b 75 10             	mov    0x10(%ebp),%esi
  801e56:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801e58:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801e5b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e60:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e63:	89 74 24 08          	mov    %esi,0x8(%esp)
  801e67:	03 45 0c             	add    0xc(%ebp),%eax
  801e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6e:	89 3c 24             	mov    %edi,(%esp)
  801e71:	e8 be eb ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	89 3c 24             	mov    %edi,(%esp)
  801e7d:	e8 64 ed ff ff       	call   800be6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e82:	01 f3                	add    %esi,%ebx
  801e84:	89 d8                	mov    %ebx,%eax
  801e86:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e89:	72 c8                	jb     801e53 <devcons_write+0x19>
}
  801e8b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <devcons_read>:
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ea1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ea5:	75 07                	jne    801eae <devcons_read+0x18>
  801ea7:	eb 2a                	jmp    801ed3 <devcons_read+0x3d>
		sys_yield();
  801ea9:	e8 e6 ed ff ff       	call   800c94 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801eae:	66 90                	xchg   %ax,%ax
  801eb0:	e8 4f ed ff ff       	call   800c04 <sys_cgetc>
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	74 f0                	je     801ea9 <devcons_read+0x13>
	if (c < 0)
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 16                	js     801ed3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801ebd:	83 f8 04             	cmp    $0x4,%eax
  801ec0:	74 0c                	je     801ece <devcons_read+0x38>
	*(char*)vbuf = c;
  801ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec5:	88 02                	mov    %al,(%edx)
	return 1;
  801ec7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecc:	eb 05                	jmp    801ed3 <devcons_read+0x3d>
		return 0;
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ed3:	c9                   	leave  
  801ed4:	c3                   	ret    

00801ed5 <cputchar>:
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ee1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ee8:	00 
  801ee9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eec:	89 04 24             	mov    %eax,(%esp)
  801eef:	e8 f2 ec ff ff       	call   800be6 <sys_cputs>
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <getchar>:
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801efc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801f03:	00 
  801f04:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f12:	e8 2e f6 ff ff       	call   801545 <read>
	if (r < 0)
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 0f                	js     801f2a <getchar+0x34>
	if (r < 1)
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	7e 06                	jle    801f25 <getchar+0x2f>
	return c;
  801f1f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f23:	eb 05                	jmp    801f2a <getchar+0x34>
		return -E_EOF;
  801f25:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    

00801f2c <iscons>:
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	89 04 24             	mov    %eax,(%esp)
  801f3f:	e8 72 f3 ff ff       	call   8012b6 <fd_lookup>
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 11                	js     801f59 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f51:	39 10                	cmp    %edx,(%eax)
  801f53:	0f 94 c0             	sete   %al
  801f56:	0f b6 c0             	movzbl %al,%eax
}
  801f59:	c9                   	leave  
  801f5a:	c3                   	ret    

00801f5b <opencons>:
{
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f64:	89 04 24             	mov    %eax,(%esp)
  801f67:	e8 fb f2 ff ff       	call   801267 <fd_alloc>
		return r;
  801f6c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 40                	js     801fb2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f72:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f79:	00 
  801f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f88:	e8 26 ed ff ff       	call   800cb3 <sys_page_alloc>
		return r;
  801f8d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	78 1f                	js     801fb2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801f93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa8:	89 04 24             	mov    %eax,(%esp)
  801fab:	e8 90 f2 ff ff       	call   801240 <fd2num>
  801fb0:	89 c2                	mov    %eax,%edx
}
  801fb2:	89 d0                	mov    %edx,%eax
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    

00801fb6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  801fbc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fc3:	75 70                	jne    802035 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  801fc5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801fcc:	00 
  801fcd:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801fd4:	ee 
  801fd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fdc:	e8 d2 ec ff ff       	call   800cb3 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	79 1c                	jns    802001 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  801fe5:	c7 44 24 08 74 2a 80 	movl   $0x802a74,0x8(%esp)
  801fec:	00 
  801fed:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801ff4:	00 
  801ff5:	c7 04 24 d0 2a 80 00 	movl   $0x802ad0,(%esp)
  801ffc:	e8 71 e1 ff ff       	call   800172 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  802001:	c7 44 24 04 3f 20 80 	movl   $0x80203f,0x4(%esp)
  802008:	00 
  802009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802010:	e8 3e ee ff ff       	call   800e53 <sys_env_set_pgfault_upcall>
        if(r < 0)
  802015:	85 c0                	test   %eax,%eax
  802017:	79 1c                	jns    802035 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  802019:	c7 44 24 08 9c 2a 80 	movl   $0x802a9c,0x8(%esp)
  802020:	00 
  802021:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  802028:	00 
  802029:	c7 04 24 d0 2a 80 00 	movl   $0x802ad0,(%esp)
  802030:	e8 3d e1 ff ff       	call   800172 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802035:	8b 45 08             	mov    0x8(%ebp),%eax
  802038:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80203d:	c9                   	leave  
  80203e:	c3                   	ret    

0080203f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80203f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802040:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802045:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802047:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  80204a:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  80204e:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802052:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  802054:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  802056:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  802057:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  80205a:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  80205c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  80205f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802060:	83 c4 04             	add    $0x4,%esp
    popf;
  802063:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  802064:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  802065:	c3                   	ret    
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	56                   	push   %esi
  802074:	53                   	push   %ebx
  802075:	83 ec 10             	sub    $0x10,%esp
  802078:	8b 75 08             	mov    0x8(%ebp),%esi
  80207b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802081:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802083:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802088:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 36 ee ff ff       	call   800ec9 <sys_ipc_recv>
    if(r < 0){
  802093:	85 c0                	test   %eax,%eax
  802095:	79 16                	jns    8020ad <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802097:	85 f6                	test   %esi,%esi
  802099:	74 06                	je     8020a1 <ipc_recv+0x31>
            *from_env_store = 0;
  80209b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  8020a1:	85 db                	test   %ebx,%ebx
  8020a3:	74 2c                	je     8020d1 <ipc_recv+0x61>
            *perm_store = 0;
  8020a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020ab:	eb 24                	jmp    8020d1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  8020ad:	85 f6                	test   %esi,%esi
  8020af:	74 0a                	je     8020bb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  8020b1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8020b6:	8b 40 74             	mov    0x74(%eax),%eax
  8020b9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  8020bb:	85 db                	test   %ebx,%ebx
  8020bd:	74 0a                	je     8020c9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  8020bf:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8020c4:	8b 40 78             	mov    0x78(%eax),%eax
  8020c7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8020ce:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    

008020d8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	57                   	push   %edi
  8020dc:	56                   	push   %esi
  8020dd:	53                   	push   %ebx
  8020de:	83 ec 1c             	sub    $0x1c,%esp
  8020e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  8020ea:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  8020ec:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8020f1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8020f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8020f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	e8 9b ed ff ff       	call   800ea6 <sys_ipc_try_send>
        if(r == 0){
  80210b:	85 c0                	test   %eax,%eax
  80210d:	74 28                	je     802137 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80210f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802112:	74 1c                	je     802130 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  802114:	c7 44 24 08 de 2a 80 	movl   $0x802ade,0x8(%esp)
  80211b:	00 
  80211c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802123:	00 
  802124:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  80212b:	e8 42 e0 ff ff       	call   800172 <_panic>
        }
        sys_yield();
  802130:	e8 5f eb ff ff       	call   800c94 <sys_yield>
    }
  802135:	eb bd                	jmp    8020f4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802137:	83 c4 1c             	add    $0x1c,%esp
  80213a:	5b                   	pop    %ebx
  80213b:	5e                   	pop    %esi
  80213c:	5f                   	pop    %edi
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    

0080213f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802145:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80214a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80214d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802153:	8b 52 50             	mov    0x50(%edx),%edx
  802156:	39 ca                	cmp    %ecx,%edx
  802158:	75 0d                	jne    802167 <ipc_find_env+0x28>
			return envs[i].env_id;
  80215a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80215d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802162:	8b 40 40             	mov    0x40(%eax),%eax
  802165:	eb 0e                	jmp    802175 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802167:	83 c0 01             	add    $0x1,%eax
  80216a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80216f:	75 d9                	jne    80214a <ipc_find_env+0xb>
	return 0;
  802171:	66 b8 00 00          	mov    $0x0,%ax
}
  802175:	5d                   	pop    %ebp
  802176:	c3                   	ret    

00802177 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80217d:	89 d0                	mov    %edx,%eax
  80217f:	c1 e8 16             	shr    $0x16,%eax
  802182:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802189:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80218e:	f6 c1 01             	test   $0x1,%cl
  802191:	74 1d                	je     8021b0 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802193:	c1 ea 0c             	shr    $0xc,%edx
  802196:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80219d:	f6 c2 01             	test   $0x1,%dl
  8021a0:	74 0e                	je     8021b0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021a2:	c1 ea 0c             	shr    $0xc,%edx
  8021a5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021ac:	ef 
  8021ad:	0f b7 c0             	movzwl %ax,%eax
}
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__udivdi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	83 ec 0c             	sub    $0xc,%esp
  8021c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8021ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8021ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8021d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8021d6:	85 c0                	test   %eax,%eax
  8021d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021dc:	89 ea                	mov    %ebp,%edx
  8021de:	89 0c 24             	mov    %ecx,(%esp)
  8021e1:	75 2d                	jne    802210 <__udivdi3+0x50>
  8021e3:	39 e9                	cmp    %ebp,%ecx
  8021e5:	77 61                	ja     802248 <__udivdi3+0x88>
  8021e7:	85 c9                	test   %ecx,%ecx
  8021e9:	89 ce                	mov    %ecx,%esi
  8021eb:	75 0b                	jne    8021f8 <__udivdi3+0x38>
  8021ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f2:	31 d2                	xor    %edx,%edx
  8021f4:	f7 f1                	div    %ecx
  8021f6:	89 c6                	mov    %eax,%esi
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	89 e8                	mov    %ebp,%eax
  8021fc:	f7 f6                	div    %esi
  8021fe:	89 c5                	mov    %eax,%ebp
  802200:	89 f8                	mov    %edi,%eax
  802202:	f7 f6                	div    %esi
  802204:	89 ea                	mov    %ebp,%edx
  802206:	83 c4 0c             	add    $0xc,%esp
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	39 e8                	cmp    %ebp,%eax
  802212:	77 24                	ja     802238 <__udivdi3+0x78>
  802214:	0f bd e8             	bsr    %eax,%ebp
  802217:	83 f5 1f             	xor    $0x1f,%ebp
  80221a:	75 3c                	jne    802258 <__udivdi3+0x98>
  80221c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802220:	39 34 24             	cmp    %esi,(%esp)
  802223:	0f 86 9f 00 00 00    	jbe    8022c8 <__udivdi3+0x108>
  802229:	39 d0                	cmp    %edx,%eax
  80222b:	0f 82 97 00 00 00    	jb     8022c8 <__udivdi3+0x108>
  802231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802238:	31 d2                	xor    %edx,%edx
  80223a:	31 c0                	xor    %eax,%eax
  80223c:	83 c4 0c             	add    $0xc,%esp
  80223f:	5e                   	pop    %esi
  802240:	5f                   	pop    %edi
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    
  802243:	90                   	nop
  802244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802248:	89 f8                	mov    %edi,%eax
  80224a:	f7 f1                	div    %ecx
  80224c:	31 d2                	xor    %edx,%edx
  80224e:	83 c4 0c             	add    $0xc,%esp
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    
  802255:	8d 76 00             	lea    0x0(%esi),%esi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	8b 3c 24             	mov    (%esp),%edi
  80225d:	d3 e0                	shl    %cl,%eax
  80225f:	89 c6                	mov    %eax,%esi
  802261:	b8 20 00 00 00       	mov    $0x20,%eax
  802266:	29 e8                	sub    %ebp,%eax
  802268:	89 c1                	mov    %eax,%ecx
  80226a:	d3 ef                	shr    %cl,%edi
  80226c:	89 e9                	mov    %ebp,%ecx
  80226e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802272:	8b 3c 24             	mov    (%esp),%edi
  802275:	09 74 24 08          	or     %esi,0x8(%esp)
  802279:	89 d6                	mov    %edx,%esi
  80227b:	d3 e7                	shl    %cl,%edi
  80227d:	89 c1                	mov    %eax,%ecx
  80227f:	89 3c 24             	mov    %edi,(%esp)
  802282:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802286:	d3 ee                	shr    %cl,%esi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	d3 e2                	shl    %cl,%edx
  80228c:	89 c1                	mov    %eax,%ecx
  80228e:	d3 ef                	shr    %cl,%edi
  802290:	09 d7                	or     %edx,%edi
  802292:	89 f2                	mov    %esi,%edx
  802294:	89 f8                	mov    %edi,%eax
  802296:	f7 74 24 08          	divl   0x8(%esp)
  80229a:	89 d6                	mov    %edx,%esi
  80229c:	89 c7                	mov    %eax,%edi
  80229e:	f7 24 24             	mull   (%esp)
  8022a1:	39 d6                	cmp    %edx,%esi
  8022a3:	89 14 24             	mov    %edx,(%esp)
  8022a6:	72 30                	jb     8022d8 <__udivdi3+0x118>
  8022a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022ac:	89 e9                	mov    %ebp,%ecx
  8022ae:	d3 e2                	shl    %cl,%edx
  8022b0:	39 c2                	cmp    %eax,%edx
  8022b2:	73 05                	jae    8022b9 <__udivdi3+0xf9>
  8022b4:	3b 34 24             	cmp    (%esp),%esi
  8022b7:	74 1f                	je     8022d8 <__udivdi3+0x118>
  8022b9:	89 f8                	mov    %edi,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	e9 7a ff ff ff       	jmp    80223c <__udivdi3+0x7c>
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cf:	e9 68 ff ff ff       	jmp    80223c <__udivdi3+0x7c>
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	83 c4 0c             	add    $0xc,%esp
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	66 90                	xchg   %ax,%ax
  8022e6:	66 90                	xchg   %ax,%ax
  8022e8:	66 90                	xchg   %ax,%ax
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__umoddi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	83 ec 14             	sub    $0x14,%esp
  8022f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8022fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8022fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802302:	89 c7                	mov    %eax,%edi
  802304:	89 44 24 04          	mov    %eax,0x4(%esp)
  802308:	8b 44 24 30          	mov    0x30(%esp),%eax
  80230c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802310:	89 34 24             	mov    %esi,(%esp)
  802313:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802317:	85 c0                	test   %eax,%eax
  802319:	89 c2                	mov    %eax,%edx
  80231b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80231f:	75 17                	jne    802338 <__umoddi3+0x48>
  802321:	39 fe                	cmp    %edi,%esi
  802323:	76 4b                	jbe    802370 <__umoddi3+0x80>
  802325:	89 c8                	mov    %ecx,%eax
  802327:	89 fa                	mov    %edi,%edx
  802329:	f7 f6                	div    %esi
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	31 d2                	xor    %edx,%edx
  80232f:	83 c4 14             	add    $0x14,%esp
  802332:	5e                   	pop    %esi
  802333:	5f                   	pop    %edi
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    
  802336:	66 90                	xchg   %ax,%ax
  802338:	39 f8                	cmp    %edi,%eax
  80233a:	77 54                	ja     802390 <__umoddi3+0xa0>
  80233c:	0f bd e8             	bsr    %eax,%ebp
  80233f:	83 f5 1f             	xor    $0x1f,%ebp
  802342:	75 5c                	jne    8023a0 <__umoddi3+0xb0>
  802344:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802348:	39 3c 24             	cmp    %edi,(%esp)
  80234b:	0f 87 e7 00 00 00    	ja     802438 <__umoddi3+0x148>
  802351:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802355:	29 f1                	sub    %esi,%ecx
  802357:	19 c7                	sbb    %eax,%edi
  802359:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802361:	8b 44 24 08          	mov    0x8(%esp),%eax
  802365:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802369:	83 c4 14             	add    $0x14,%esp
  80236c:	5e                   	pop    %esi
  80236d:	5f                   	pop    %edi
  80236e:	5d                   	pop    %ebp
  80236f:	c3                   	ret    
  802370:	85 f6                	test   %esi,%esi
  802372:	89 f5                	mov    %esi,%ebp
  802374:	75 0b                	jne    802381 <__umoddi3+0x91>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f6                	div    %esi
  80237f:	89 c5                	mov    %eax,%ebp
  802381:	8b 44 24 04          	mov    0x4(%esp),%eax
  802385:	31 d2                	xor    %edx,%edx
  802387:	f7 f5                	div    %ebp
  802389:	89 c8                	mov    %ecx,%eax
  80238b:	f7 f5                	div    %ebp
  80238d:	eb 9c                	jmp    80232b <__umoddi3+0x3b>
  80238f:	90                   	nop
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 fa                	mov    %edi,%edx
  802394:	83 c4 14             	add    $0x14,%esp
  802397:	5e                   	pop    %esi
  802398:	5f                   	pop    %edi
  802399:	5d                   	pop    %ebp
  80239a:	c3                   	ret    
  80239b:	90                   	nop
  80239c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	8b 04 24             	mov    (%esp),%eax
  8023a3:	be 20 00 00 00       	mov    $0x20,%esi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	29 ee                	sub    %ebp,%esi
  8023ac:	d3 e2                	shl    %cl,%edx
  8023ae:	89 f1                	mov    %esi,%ecx
  8023b0:	d3 e8                	shr    %cl,%eax
  8023b2:	89 e9                	mov    %ebp,%ecx
  8023b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b8:	8b 04 24             	mov    (%esp),%eax
  8023bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8023bf:	89 fa                	mov    %edi,%edx
  8023c1:	d3 e0                	shl    %cl,%eax
  8023c3:	89 f1                	mov    %esi,%ecx
  8023c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8023cd:	d3 ea                	shr    %cl,%edx
  8023cf:	89 e9                	mov    %ebp,%ecx
  8023d1:	d3 e7                	shl    %cl,%edi
  8023d3:	89 f1                	mov    %esi,%ecx
  8023d5:	d3 e8                	shr    %cl,%eax
  8023d7:	89 e9                	mov    %ebp,%ecx
  8023d9:	09 f8                	or     %edi,%eax
  8023db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8023df:	f7 74 24 04          	divl   0x4(%esp)
  8023e3:	d3 e7                	shl    %cl,%edi
  8023e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023e9:	89 d7                	mov    %edx,%edi
  8023eb:	f7 64 24 08          	mull   0x8(%esp)
  8023ef:	39 d7                	cmp    %edx,%edi
  8023f1:	89 c1                	mov    %eax,%ecx
  8023f3:	89 14 24             	mov    %edx,(%esp)
  8023f6:	72 2c                	jb     802424 <__umoddi3+0x134>
  8023f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8023fc:	72 22                	jb     802420 <__umoddi3+0x130>
  8023fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802402:	29 c8                	sub    %ecx,%eax
  802404:	19 d7                	sbb    %edx,%edi
  802406:	89 e9                	mov    %ebp,%ecx
  802408:	89 fa                	mov    %edi,%edx
  80240a:	d3 e8                	shr    %cl,%eax
  80240c:	89 f1                	mov    %esi,%ecx
  80240e:	d3 e2                	shl    %cl,%edx
  802410:	89 e9                	mov    %ebp,%ecx
  802412:	d3 ef                	shr    %cl,%edi
  802414:	09 d0                	or     %edx,%eax
  802416:	89 fa                	mov    %edi,%edx
  802418:	83 c4 14             	add    $0x14,%esp
  80241b:	5e                   	pop    %esi
  80241c:	5f                   	pop    %edi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    
  80241f:	90                   	nop
  802420:	39 d7                	cmp    %edx,%edi
  802422:	75 da                	jne    8023fe <__umoddi3+0x10e>
  802424:	8b 14 24             	mov    (%esp),%edx
  802427:	89 c1                	mov    %eax,%ecx
  802429:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80242d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802431:	eb cb                	jmp    8023fe <__umoddi3+0x10e>
  802433:	90                   	nop
  802434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802438:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80243c:	0f 82 0f ff ff ff    	jb     802351 <__umoddi3+0x61>
  802442:	e9 1a ff ff ff       	jmp    802361 <__umoddi3+0x71>
