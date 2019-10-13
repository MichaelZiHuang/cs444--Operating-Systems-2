
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800046:	00 
  800047:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004e:	00 
  80004f:	89 34 24             	mov    %esi,(%esp)
  800052:	e8 19 12 00 00       	call   801270 <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 08 40 80 00       	mov    0x804008,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  800070:	e8 2d 02 00 00       	call   8002a2 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 f8 0f 00 00       	call   801072 <fork>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 20                	jns    8000a0 <primeproc+0x6d>
		panic("fork: %e", id);
  800080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800084:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 95 24 80 00 	movl   $0x802495,(%esp)
  80009b:	e8 09 01 00 00       	call   8001a9 <_panic>
	if (id == 0)
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	74 9b                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
        //cprintf("AM I stuck here\n");
		i = ipc_recv(&envid, 0, 0);
  8000a4:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 b1 11 00 00       	call   801270 <ipc_recv>
  8000bf:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c1:	99                   	cltd   
  8000c2:	f7 fb                	idiv   %ebx
  8000c4:	85 d2                	test   %edx,%edx
  8000c6:	74 df                	je     8000a7 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000cf:	00 
  8000d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d7:	00 
  8000d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dc:	89 3c 24             	mov    %edi,(%esp)
  8000df:	e8 f4 11 00 00       	call   8012d8 <ipc_send>
  8000e4:	eb c1                	jmp    8000a7 <primeproc+0x74>

008000e6 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ee:	e8 7f 0f 00 00       	call   801072 <fork>
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	79 20                	jns    800119 <umain+0x33>
		panic("fork: %e", id);
  8000f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fd:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 95 24 80 00 	movl   $0x802495,(%esp)
  800114:	e8 90 00 00 00       	call   8001a9 <_panic>
	if (id == 0)
  800119:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011e:	85 c0                	test   %eax,%eax
  800120:	75 05                	jne    800127 <umain+0x41>
		primeproc();
  800122:	e8 0c ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800127:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800136:	00 
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 95 11 00 00       	call   8012d8 <ipc_send>
	for (i = 2; ; i++)
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	eb df                	jmp    800127 <umain+0x41>

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800153:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800156:	e8 4a 0b 00 00       	call   800ca5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 db                	test   %ebx,%ebx
  80016f:	7e 07                	jle    800178 <libmain+0x30>
		binaryname = argv[0];
  800171:	8b 06                	mov    (%esi),%eax
  800173:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800178:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 62 ff ff ff       	call   8000e6 <umain>

	// exit gracefully
	exit();
  800184:	e8 07 00 00 00       	call   800190 <exit>
}
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800196:	e8 ba 13 00 00       	call   801555 <close_all>
	sys_env_destroy(0);
  80019b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a2:	e8 ac 0a 00 00       	call   800c53 <sys_env_destroy>
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001b1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ba:	e8 e6 0a 00 00       	call   800ca5 <sys_getenvid>
  8001bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001cd:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	c7 04 24 b0 24 80 00 	movl   $0x8024b0,(%esp)
  8001dc:	e8 c1 00 00 00       	call   8002a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 51 00 00 00       	call   800241 <vcprintf>
	cprintf("\n");
  8001f0:	c7 04 24 81 2a 80 00 	movl   $0x802a81,(%esp)
  8001f7:	e8 a6 00 00 00       	call   8002a2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fc:	cc                   	int3   
  8001fd:	eb fd                	jmp    8001fc <_panic+0x53>

008001ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	83 ec 14             	sub    $0x14,%esp
  800206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800209:	8b 13                	mov    (%ebx),%edx
  80020b:	8d 42 01             	lea    0x1(%edx),%eax
  80020e:	89 03                	mov    %eax,(%ebx)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800217:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021c:	75 19                	jne    800237 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80021e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800225:	00 
  800226:	8d 43 08             	lea    0x8(%ebx),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 e5 09 00 00       	call   800c16 <sys_cputs>
		b->idx = 0;
  800231:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800237:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023b:	83 c4 14             	add    $0x14,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80024a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800251:	00 00 00 
	b.cnt = 0;
  800254:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800261:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800272:	89 44 24 04          	mov    %eax,0x4(%esp)
  800276:	c7 04 24 ff 01 80 00 	movl   $0x8001ff,(%esp)
  80027d:	e8 ac 01 00 00       	call   80042e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800282:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	e8 7c 09 00 00       	call   800c16 <sys_cputs>

	return b.cnt;
}
  80029a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	e8 87 ff ff ff       	call   800241 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    
  8002bc:	66 90                	xchg   %ax,%ax
  8002be:	66 90                	xchg   %ax,%ax

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d7:	89 c3                	mov    %eax,%ebx
  8002d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ed:	39 d9                	cmp    %ebx,%ecx
  8002ef:	72 05                	jb     8002f6 <printnum+0x36>
  8002f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002f4:	77 69                	ja     80035f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002fd:	83 ee 01             	sub    $0x1,%esi
  800300:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 44 24 08          	mov    0x8(%esp),%eax
  80030c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800310:	89 c3                	mov    %eax,%ebx
  800312:	89 d6                	mov    %edx,%esi
  800314:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800317:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80031a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80031e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 bc 1e 00 00       	call   8021f0 <__udivdi3>
  800334:	89 d9                	mov    %ebx,%ecx
  800336:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	89 54 24 04          	mov    %edx,0x4(%esp)
  800345:	89 fa                	mov    %edi,%edx
  800347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034a:	e8 71 ff ff ff       	call   8002c0 <printnum>
  80034f:	eb 1b                	jmp    80036c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800351:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800355:	8b 45 18             	mov    0x18(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff d3                	call   *%ebx
  80035d:	eb 03                	jmp    800362 <printnum+0xa2>
  80035f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800362:	83 ee 01             	sub    $0x1,%esi
  800365:	85 f6                	test   %esi,%esi
  800367:	7f e8                	jg     800351 <printnum+0x91>
  800369:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800370:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800374:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800377:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	e8 8c 1f 00 00       	call   802320 <__umoddi3>
  800394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800398:	0f be 80 d3 24 80 00 	movsbl 0x8024d3(%eax),%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003a5:	ff d0                	call   *%eax
}
  8003a7:	83 c4 3c             	add    $0x3c,%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7e 0e                	jle    8003c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bc:	89 08                	mov    %ecx,(%eax)
  8003be:	8b 02                	mov    (%edx),%eax
  8003c0:	8b 52 04             	mov    0x4(%edx),%edx
  8003c3:	eb 22                	jmp    8003e7 <getuint+0x38>
	else if (lflag)
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 10                	je     8003d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ce:	89 08                	mov    %ecx,(%eax)
  8003d0:	8b 02                	mov    (%edx),%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	eb 0e                	jmp    8003e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 02                	mov    (%edx),%eax
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f8:	73 0a                	jae    800404 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	88 02                	mov    %al,(%edx)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800413:	8b 45 10             	mov    0x10(%ebp),%eax
  800416:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	e8 02 00 00 00       	call   80042e <vprintfmt>
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <vprintfmt>:
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	83 ec 3c             	sub    $0x3c,%esp
  800437:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80043a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80043d:	eb 1f                	jmp    80045e <vprintfmt+0x30>
			if (ch == '\0'){
  80043f:	85 c0                	test   %eax,%eax
  800441:	75 0f                	jne    800452 <vprintfmt+0x24>
				color = 0x0100;
  800443:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80044a:	01 00 00 
  80044d:	e9 b3 03 00 00       	jmp    800805 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800452:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800456:	89 04 24             	mov    %eax,(%esp)
  800459:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	8d 73 01             	lea    0x1(%ebx),%esi
  800461:	0f b6 03             	movzbl (%ebx),%eax
  800464:	83 f8 25             	cmp    $0x25,%eax
  800467:	75 d6                	jne    80043f <vprintfmt+0x11>
  800469:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80046d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800474:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80047b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800482:	ba 00 00 00 00       	mov    $0x0,%edx
  800487:	eb 1d                	jmp    8004a6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800489:	89 de                	mov    %ebx,%esi
			padc = '-';
  80048b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80048f:	eb 15                	jmp    8004a6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800491:	89 de                	mov    %ebx,%esi
			padc = '0';
  800493:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800497:	eb 0d                	jmp    8004a6 <vprintfmt+0x78>
				width = precision, precision = -1;
  800499:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80049c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80049f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004a9:	0f b6 0e             	movzbl (%esi),%ecx
  8004ac:	0f b6 c1             	movzbl %cl,%eax
  8004af:	83 e9 23             	sub    $0x23,%ecx
  8004b2:	80 f9 55             	cmp    $0x55,%cl
  8004b5:	0f 87 2a 03 00 00    	ja     8007e5 <vprintfmt+0x3b7>
  8004bb:	0f b6 c9             	movzbl %cl,%ecx
  8004be:	ff 24 8d 20 26 80 00 	jmp    *0x802620(,%ecx,4)
  8004c5:	89 de                	mov    %ebx,%esi
  8004c7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8004cc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004cf:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004d3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004d9:	83 fb 09             	cmp    $0x9,%ebx
  8004dc:	77 36                	ja     800514 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8004de:	83 c6 01             	add    $0x1,%esi
			}
  8004e1:	eb e9                	jmp    8004cc <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004f3:	eb 22                	jmp    800517 <vprintfmt+0xe9>
  8004f5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f8:	85 c9                	test   %ecx,%ecx
  8004fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ff:	0f 49 c1             	cmovns %ecx,%eax
  800502:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800505:	89 de                	mov    %ebx,%esi
  800507:	eb 9d                	jmp    8004a6 <vprintfmt+0x78>
  800509:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80050b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800512:	eb 92                	jmp    8004a6 <vprintfmt+0x78>
  800514:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800517:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051b:	79 89                	jns    8004a6 <vprintfmt+0x78>
  80051d:	e9 77 ff ff ff       	jmp    800499 <vprintfmt+0x6b>
			lflag++;
  800522:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800525:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800527:	e9 7a ff ff ff       	jmp    8004a6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800541:	e9 18 ff ff ff       	jmp    80045e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	99                   	cltd   
  800552:	31 d0                	xor    %edx,%eax
  800554:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800556:	83 f8 0f             	cmp    $0xf,%eax
  800559:	7f 0b                	jg     800566 <vprintfmt+0x138>
  80055b:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800562:	85 d2                	test   %edx,%edx
  800564:	75 20                	jne    800586 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800566:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056a:	c7 44 24 08 eb 24 80 	movl   $0x8024eb,0x8(%esp)
  800571:	00 
  800572:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
  800579:	89 04 24             	mov    %eax,(%esp)
  80057c:	e8 85 fe ff ff       	call   800406 <printfmt>
  800581:	e9 d8 fe ff ff       	jmp    80045e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800586:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058a:	c7 44 24 08 5a 2a 80 	movl   $0x802a5a,0x8(%esp)
  800591:	00 
  800592:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800596:	8b 45 08             	mov    0x8(%ebp),%eax
  800599:	89 04 24             	mov    %eax,(%esp)
  80059c:	e8 65 fe ff ff       	call   800406 <printfmt>
  8005a1:	e9 b8 fe ff ff       	jmp    80045e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005ba:	85 f6                	test   %esi,%esi
  8005bc:	b8 e4 24 80 00       	mov    $0x8024e4,%eax
  8005c1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005c4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005c8:	0f 84 97 00 00 00    	je     800665 <vprintfmt+0x237>
  8005ce:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005d2:	0f 8e 9b 00 00 00    	jle    800673 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005dc:	89 34 24             	mov    %esi,(%esp)
  8005df:	e8 c4 02 00 00       	call   8008a8 <strnlen>
  8005e4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005e7:	29 c2                	sub    %eax,%edx
  8005e9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005ec:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005f3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005fc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fe:	eb 0f                	jmp    80060f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800600:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800604:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	83 eb 01             	sub    $0x1,%ebx
  80060f:	85 db                	test   %ebx,%ebx
  800611:	7f ed                	jg     800600 <vprintfmt+0x1d2>
  800613:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800616:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800619:	85 d2                	test   %edx,%edx
  80061b:	b8 00 00 00 00       	mov    $0x0,%eax
  800620:	0f 49 c2             	cmovns %edx,%eax
  800623:	29 c2                	sub    %eax,%edx
  800625:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800628:	89 d7                	mov    %edx,%edi
  80062a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80062d:	eb 50                	jmp    80067f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	74 1e                	je     800653 <vprintfmt+0x225>
  800635:	0f be d2             	movsbl %dl,%edx
  800638:	83 ea 20             	sub    $0x20,%edx
  80063b:	83 fa 5e             	cmp    $0x5e,%edx
  80063e:	76 13                	jbe    800653 <vprintfmt+0x225>
					putch('?', putdat);
  800640:	8b 45 0c             	mov    0xc(%ebp),%eax
  800643:	89 44 24 04          	mov    %eax,0x4(%esp)
  800647:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064e:	ff 55 08             	call   *0x8(%ebp)
  800651:	eb 0d                	jmp    800660 <vprintfmt+0x232>
					putch(ch, putdat);
  800653:	8b 55 0c             	mov    0xc(%ebp),%edx
  800656:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065a:	89 04 24             	mov    %eax,(%esp)
  80065d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800660:	83 ef 01             	sub    $0x1,%edi
  800663:	eb 1a                	jmp    80067f <vprintfmt+0x251>
  800665:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800668:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80066b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80066e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800671:	eb 0c                	jmp    80067f <vprintfmt+0x251>
  800673:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800676:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800679:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80067c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80067f:	83 c6 01             	add    $0x1,%esi
  800682:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800686:	0f be c2             	movsbl %dl,%eax
  800689:	85 c0                	test   %eax,%eax
  80068b:	74 27                	je     8006b4 <vprintfmt+0x286>
  80068d:	85 db                	test   %ebx,%ebx
  80068f:	78 9e                	js     80062f <vprintfmt+0x201>
  800691:	83 eb 01             	sub    $0x1,%ebx
  800694:	79 99                	jns    80062f <vprintfmt+0x201>
  800696:	89 f8                	mov    %edi,%eax
  800698:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80069b:	8b 75 08             	mov    0x8(%ebp),%esi
  80069e:	89 c3                	mov    %eax,%ebx
  8006a0:	eb 1a                	jmp    8006bc <vprintfmt+0x28e>
				putch(' ', putdat);
  8006a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ad:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006af:	83 eb 01             	sub    $0x1,%ebx
  8006b2:	eb 08                	jmp    8006bc <vprintfmt+0x28e>
  8006b4:	89 fb                	mov    %edi,%ebx
  8006b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006bc:	85 db                	test   %ebx,%ebx
  8006be:	7f e2                	jg     8006a2 <vprintfmt+0x274>
  8006c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006c6:	e9 93 fd ff ff       	jmp    80045e <vprintfmt+0x30>
	if (lflag >= 2)
  8006cb:	83 fa 01             	cmp    $0x1,%edx
  8006ce:	7e 16                	jle    8006e6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 08             	lea    0x8(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d9:	8b 50 04             	mov    0x4(%eax),%edx
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006e4:	eb 32                	jmp    800718 <vprintfmt+0x2ea>
	else if (lflag)
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	74 18                	je     800702 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 30                	mov    (%eax),%esi
  8006f5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	c1 f8 1f             	sar    $0x1f,%eax
  8006fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800700:	eb 16                	jmp    800718 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 50 04             	lea    0x4(%eax),%edx
  800708:	89 55 14             	mov    %edx,0x14(%ebp)
  80070b:	8b 30                	mov    (%eax),%esi
  80070d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800710:	89 f0                	mov    %esi,%eax
  800712:	c1 f8 1f             	sar    $0x1f,%eax
  800715:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800718:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80071b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80071e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800723:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800727:	0f 89 80 00 00 00    	jns    8007ad <vprintfmt+0x37f>
				putch('-', putdat);
  80072d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800731:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800738:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80073b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80073e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800741:	f7 d8                	neg    %eax
  800743:	83 d2 00             	adc    $0x0,%edx
  800746:	f7 da                	neg    %edx
			base = 10;
  800748:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074d:	eb 5e                	jmp    8007ad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
  800752:	e8 58 fc ff ff       	call   8003af <getuint>
			base = 10;
  800757:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80075c:	eb 4f                	jmp    8007ad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 49 fc ff ff       	call   8003af <getuint>
            base = 8;
  800766:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80076b:	eb 40                	jmp    8007ad <vprintfmt+0x37f>
			putch('0', putdat);
  80076d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800771:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800778:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80077b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800786:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8d 50 04             	lea    0x4(%eax),%edx
  80078f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800792:	8b 00                	mov    (%eax),%eax
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800799:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079e:	eb 0d                	jmp    8007ad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a3:	e8 07 fc ff ff       	call   8003af <getuint>
			base = 16;
  8007a8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8007ad:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007b1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007b5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007b8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007bc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c7:	89 fa                	mov    %edi,%edx
  8007c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cc:	e8 ef fa ff ff       	call   8002c0 <printnum>
			break;
  8007d1:	e9 88 fc ff ff       	jmp    80045e <vprintfmt+0x30>
			putch(ch, putdat);
  8007d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007da:	89 04 24             	mov    %eax,(%esp)
  8007dd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007e0:	e9 79 fc ff ff       	jmp    80045e <vprintfmt+0x30>
			putch('%', putdat);
  8007e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f3:	89 f3                	mov    %esi,%ebx
  8007f5:	eb 03                	jmp    8007fa <vprintfmt+0x3cc>
  8007f7:	83 eb 01             	sub    $0x1,%ebx
  8007fa:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007fe:	75 f7                	jne    8007f7 <vprintfmt+0x3c9>
  800800:	e9 59 fc ff ff       	jmp    80045e <vprintfmt+0x30>
}
  800805:	83 c4 3c             	add    $0x3c,%esp
  800808:	5b                   	pop    %ebx
  800809:	5e                   	pop    %esi
  80080a:	5f                   	pop    %edi
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 28             	sub    $0x28,%esp
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800819:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800820:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800823:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082a:	85 c0                	test   %eax,%eax
  80082c:	74 30                	je     80085e <vsnprintf+0x51>
  80082e:	85 d2                	test   %edx,%edx
  800830:	7e 2c                	jle    80085e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800839:	8b 45 10             	mov    0x10(%ebp),%eax
  80083c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800840:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800843:	89 44 24 04          	mov    %eax,0x4(%esp)
  800847:	c7 04 24 e9 03 80 00 	movl   $0x8003e9,(%esp)
  80084e:	e8 db fb ff ff       	call   80042e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800853:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800856:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800859:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085c:	eb 05                	jmp    800863 <vsnprintf+0x56>
		return -E_INVAL;
  80085e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800872:	8b 45 10             	mov    0x10(%ebp),%eax
  800875:	89 44 24 08          	mov    %eax,0x8(%esp)
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	89 04 24             	mov    %eax,(%esp)
  800886:	e8 82 ff ff ff       	call   80080d <vsnprintf>
	va_end(ap);

	return rc;
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    
  80088d:	66 90                	xchg   %ax,%ax
  80088f:	90                   	nop

00800890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	eb 03                	jmp    8008a0 <strlen+0x10>
		n++;
  80089d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a4:	75 f7                	jne    80089d <strlen+0xd>
	return n;
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb 03                	jmp    8008bb <strnlen+0x13>
		n++;
  8008b8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bb:	39 d0                	cmp    %edx,%eax
  8008bd:	74 06                	je     8008c5 <strnlen+0x1d>
  8008bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c3:	75 f3                	jne    8008b8 <strnlen+0x10>
	return n;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d1:	89 c2                	mov    %eax,%edx
  8008d3:	83 c2 01             	add    $0x1,%edx
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008dd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e0:	84 db                	test   %bl,%bl
  8008e2:	75 ef                	jne    8008d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f1:	89 1c 24             	mov    %ebx,(%esp)
  8008f4:	e8 97 ff ff ff       	call   800890 <strlen>
	strcpy(dst + len, src);
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800900:	01 d8                	add    %ebx,%eax
  800902:	89 04 24             	mov    %eax,(%esp)
  800905:	e8 bd ff ff ff       	call   8008c7 <strcpy>
	return dst;
}
  80090a:	89 d8                	mov    %ebx,%eax
  80090c:	83 c4 08             	add    $0x8,%esp
  80090f:	5b                   	pop    %ebx
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	89 f3                	mov    %esi,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	89 f2                	mov    %esi,%edx
  800924:	eb 0f                	jmp    800935 <strncpy+0x23>
		*dst++ = *src;
  800926:	83 c2 01             	add    $0x1,%edx
  800929:	0f b6 01             	movzbl (%ecx),%eax
  80092c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092f:	80 39 01             	cmpb   $0x1,(%ecx)
  800932:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800935:	39 da                	cmp    %ebx,%edx
  800937:	75 ed                	jne    800926 <strncpy+0x14>
	}
	return ret;
}
  800939:	89 f0                	mov    %esi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80094d:	89 f0                	mov    %esi,%eax
  80094f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800953:	85 c9                	test   %ecx,%ecx
  800955:	75 0b                	jne    800962 <strlcpy+0x23>
  800957:	eb 1d                	jmp    800976 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800959:	83 c0 01             	add    $0x1,%eax
  80095c:	83 c2 01             	add    $0x1,%edx
  80095f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800962:	39 d8                	cmp    %ebx,%eax
  800964:	74 0b                	je     800971 <strlcpy+0x32>
  800966:	0f b6 0a             	movzbl (%edx),%ecx
  800969:	84 c9                	test   %cl,%cl
  80096b:	75 ec                	jne    800959 <strlcpy+0x1a>
  80096d:	89 c2                	mov    %eax,%edx
  80096f:	eb 02                	jmp    800973 <strlcpy+0x34>
  800971:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800973:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800976:	29 f0                	sub    %esi,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800985:	eb 06                	jmp    80098d <strcmp+0x11>
		p++, q++;
  800987:	83 c1 01             	add    $0x1,%ecx
  80098a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80098d:	0f b6 01             	movzbl (%ecx),%eax
  800990:	84 c0                	test   %al,%al
  800992:	74 04                	je     800998 <strcmp+0x1c>
  800994:	3a 02                	cmp    (%edx),%al
  800996:	74 ef                	je     800987 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 c0             	movzbl %al,%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c3                	mov    %eax,%ebx
  8009ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b1:	eb 06                	jmp    8009b9 <strncmp+0x17>
		n--, p++, q++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b9:	39 d8                	cmp    %ebx,%eax
  8009bb:	74 15                	je     8009d2 <strncmp+0x30>
  8009bd:	0f b6 08             	movzbl (%eax),%ecx
  8009c0:	84 c9                	test   %cl,%cl
  8009c2:	74 04                	je     8009c8 <strncmp+0x26>
  8009c4:	3a 0a                	cmp    (%edx),%cl
  8009c6:	74 eb                	je     8009b3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c8:	0f b6 00             	movzbl (%eax),%eax
  8009cb:	0f b6 12             	movzbl (%edx),%edx
  8009ce:	29 d0                	sub    %edx,%eax
  8009d0:	eb 05                	jmp    8009d7 <strncmp+0x35>
		return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e4:	eb 07                	jmp    8009ed <strchr+0x13>
		if (*s == c)
  8009e6:	38 ca                	cmp    %cl,%dl
  8009e8:	74 0f                	je     8009f9 <strchr+0x1f>
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 f2                	jne    8009e6 <strchr+0xc>
			return (char *) s;
	return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	eb 07                	jmp    800a0e <strfind+0x13>
		if (*s == c)
  800a07:	38 ca                	cmp    %cl,%dl
  800a09:	74 0a                	je     800a15 <strfind+0x1a>
	for (; *s; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	84 d2                	test   %dl,%dl
  800a13:	75 f2                	jne    800a07 <strfind+0xc>
			break;
	return (char *) s;
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a23:	85 c9                	test   %ecx,%ecx
  800a25:	74 36                	je     800a5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2d:	75 28                	jne    800a57 <memset+0x40>
  800a2f:	f6 c1 03             	test   $0x3,%cl
  800a32:	75 23                	jne    800a57 <memset+0x40>
		c &= 0xFF;
  800a34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a38:	89 d3                	mov    %edx,%ebx
  800a3a:	c1 e3 08             	shl    $0x8,%ebx
  800a3d:	89 d6                	mov    %edx,%esi
  800a3f:	c1 e6 18             	shl    $0x18,%esi
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	c1 e0 10             	shl    $0x10,%eax
  800a47:	09 f0                	or     %esi,%eax
  800a49:	09 c2                	or     %eax,%edx
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a4f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a52:	fc                   	cld    
  800a53:	f3 ab                	rep stos %eax,%es:(%edi)
  800a55:	eb 06                	jmp    800a5d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	fc                   	cld    
  800a5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a5d:	89 f8                	mov    %edi,%eax
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a72:	39 c6                	cmp    %eax,%esi
  800a74:	73 35                	jae    800aab <memmove+0x47>
  800a76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a79:	39 d0                	cmp    %edx,%eax
  800a7b:	73 2e                	jae    800aab <memmove+0x47>
		s += n;
		d += n;
  800a7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a80:	89 d6                	mov    %edx,%esi
  800a82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8a:	75 13                	jne    800a9f <memmove+0x3b>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 0e                	jne    800a9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a91:	83 ef 04             	sub    $0x4,%edi
  800a94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9a:	fd                   	std    
  800a9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9d:	eb 09                	jmp    800aa8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9f:	83 ef 01             	sub    $0x1,%edi
  800aa2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa5:	fd                   	std    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa8:	fc                   	cld    
  800aa9:	eb 1d                	jmp    800ac8 <memmove+0x64>
  800aab:	89 f2                	mov    %esi,%edx
  800aad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	f6 c2 03             	test   $0x3,%dl
  800ab2:	75 0f                	jne    800ac3 <memmove+0x5f>
  800ab4:	f6 c1 03             	test   $0x3,%cl
  800ab7:	75 0a                	jne    800ac3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800abc:	89 c7                	mov    %eax,%edi
  800abe:	fc                   	cld    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 05                	jmp    800ac8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	fc                   	cld    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	89 04 24             	mov    %eax,(%esp)
  800ae6:	e8 79 ff ff ff       	call   800a64 <memmove>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afd:	eb 1a                	jmp    800b19 <memcmp+0x2c>
		if (*s1 != *s2)
  800aff:	0f b6 02             	movzbl (%edx),%eax
  800b02:	0f b6 19             	movzbl (%ecx),%ebx
  800b05:	38 d8                	cmp    %bl,%al
  800b07:	74 0a                	je     800b13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b09:	0f b6 c0             	movzbl %al,%eax
  800b0c:	0f b6 db             	movzbl %bl,%ebx
  800b0f:	29 d8                	sub    %ebx,%eax
  800b11:	eb 0f                	jmp    800b22 <memcmp+0x35>
		s1++, s2++;
  800b13:	83 c2 01             	add    $0x1,%edx
  800b16:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800b19:	39 f2                	cmp    %esi,%edx
  800b1b:	75 e2                	jne    800aff <memcmp+0x12>
	}

	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b34:	eb 07                	jmp    800b3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	38 08                	cmp    %cl,(%eax)
  800b38:	74 07                	je     800b41 <memfind+0x1b>
	for (; s < ends; s++)
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	39 d0                	cmp    %edx,%eax
  800b3f:	72 f5                	jb     800b36 <memfind+0x10>
			break;
	return (void *) s;
}
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4f:	eb 03                	jmp    800b54 <strtol+0x11>
		s++;
  800b51:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b54:	0f b6 0a             	movzbl (%edx),%ecx
  800b57:	80 f9 09             	cmp    $0x9,%cl
  800b5a:	74 f5                	je     800b51 <strtol+0xe>
  800b5c:	80 f9 20             	cmp    $0x20,%cl
  800b5f:	74 f0                	je     800b51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b61:	80 f9 2b             	cmp    $0x2b,%cl
  800b64:	75 0a                	jne    800b70 <strtol+0x2d>
		s++;
  800b66:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6e:	eb 11                	jmp    800b81 <strtol+0x3e>
  800b70:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b75:	80 f9 2d             	cmp    $0x2d,%cl
  800b78:	75 07                	jne    800b81 <strtol+0x3e>
		s++, neg = 1;
  800b7a:	8d 52 01             	lea    0x1(%edx),%edx
  800b7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b86:	75 15                	jne    800b9d <strtol+0x5a>
  800b88:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8b:	75 10                	jne    800b9d <strtol+0x5a>
  800b8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b91:	75 0a                	jne    800b9d <strtol+0x5a>
		s += 2, base = 16;
  800b93:	83 c2 02             	add    $0x2,%edx
  800b96:	b8 10 00 00 00       	mov    $0x10,%eax
  800b9b:	eb 10                	jmp    800bad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	75 0c                	jne    800bad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800ba3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba6:	75 05                	jne    800bad <strtol+0x6a>
		s++, base = 8;
  800ba8:	83 c2 01             	add    $0x1,%edx
  800bab:	b0 08                	mov    $0x8,%al
		base = 10;
  800bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb5:	0f b6 0a             	movzbl (%edx),%ecx
  800bb8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bbb:	89 f0                	mov    %esi,%eax
  800bbd:	3c 09                	cmp    $0x9,%al
  800bbf:	77 08                	ja     800bc9 <strtol+0x86>
			dig = *s - '0';
  800bc1:	0f be c9             	movsbl %cl,%ecx
  800bc4:	83 e9 30             	sub    $0x30,%ecx
  800bc7:	eb 20                	jmp    800be9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bcc:	89 f0                	mov    %esi,%eax
  800bce:	3c 19                	cmp    $0x19,%al
  800bd0:	77 08                	ja     800bda <strtol+0x97>
			dig = *s - 'a' + 10;
  800bd2:	0f be c9             	movsbl %cl,%ecx
  800bd5:	83 e9 57             	sub    $0x57,%ecx
  800bd8:	eb 0f                	jmp    800be9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bdd:	89 f0                	mov    %esi,%eax
  800bdf:	3c 19                	cmp    $0x19,%al
  800be1:	77 16                	ja     800bf9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800be3:	0f be c9             	movsbl %cl,%ecx
  800be6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800be9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bec:	7d 0f                	jge    800bfd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bee:	83 c2 01             	add    $0x1,%edx
  800bf1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bf5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bf7:	eb bc                	jmp    800bb5 <strtol+0x72>
  800bf9:	89 d8                	mov    %ebx,%eax
  800bfb:	eb 02                	jmp    800bff <strtol+0xbc>
  800bfd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c03:	74 05                	je     800c0a <strtol+0xc7>
		*endptr = (char *) s;
  800c05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c08:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c0a:	f7 d8                	neg    %eax
  800c0c:	85 ff                	test   %edi,%edi
  800c0e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	89 c3                	mov    %eax,%ebx
  800c29:	89 c7                	mov    %eax,%edi
  800c2b:	89 c6                	mov    %eax,%esi
  800c2d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c61:	b8 03 00 00 00       	mov    $0x3,%eax
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 cb                	mov    %ecx,%ebx
  800c6b:	89 cf                	mov    %ecx,%edi
  800c6d:	89 ce                	mov    %ecx,%esi
  800c6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 28                	jle    800c9d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c79:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c80:	00 
  800c81:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800c88:	00 
  800c89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c90:	00 
  800c91:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800c98:	e8 0c f5 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9d:	83 c4 2c             	add    $0x2c,%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_yield>:

void
sys_yield(void)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cca:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd4:	89 d1                	mov    %edx,%ecx
  800cd6:	89 d3                	mov    %edx,%ebx
  800cd8:	89 d7                	mov    %edx,%edi
  800cda:	89 d6                	mov    %edx,%esi
  800cdc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cec:	be 00 00 00 00       	mov    $0x0,%esi
  800cf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	89 f7                	mov    %esi,%edi
  800d01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 28                	jle    800d2f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d12:	00 
  800d13:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d22:	00 
  800d23:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800d2a:	e8 7a f4 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2f:	83 c4 2c             	add    $0x2c,%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d40:	b8 05 00 00 00       	mov    $0x5,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d51:	8b 75 18             	mov    0x18(%ebp),%esi
  800d54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 28                	jle    800d82 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d65:	00 
  800d66:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800d6d:	00 
  800d6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d75:	00 
  800d76:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800d7d:	e8 27 f4 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d82:	83 c4 2c             	add    $0x2c,%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 28                	jle    800dd5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800db8:	00 
  800db9:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc8:	00 
  800dc9:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800dd0:	e8 d4 f3 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd5:	83 c4 2c             	add    $0x2c,%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	b8 08 00 00 00       	mov    $0x8,%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 28                	jle    800e28 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e0b:	00 
  800e0c:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800e13:	00 
  800e14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1b:	00 
  800e1c:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800e23:	e8 81 f3 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e28:	83 c4 2c             	add    $0x2c,%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 df                	mov    %ebx,%edi
  800e4b:	89 de                	mov    %ebx,%esi
  800e4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 28                	jle    800e7b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e57:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6e:	00 
  800e6f:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800e76:	e8 2e f3 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e7b:	83 c4 2c             	add    $0x2c,%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	89 df                	mov    %ebx,%edi
  800e9e:	89 de                	mov    %ebx,%esi
  800ea0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	7e 28                	jle    800ece <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eaa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800eb9:	00 
  800eba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec1:	00 
  800ec2:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800ec9:	e8 db f2 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ece:	83 c4 2c             	add    $0x2c,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800edc:	be 00 00 00 00       	mov    $0x0,%esi
  800ee1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eef:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f07:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0f:	89 cb                	mov    %ecx,%ebx
  800f11:	89 cf                	mov    %ecx,%edi
  800f13:	89 ce                	mov    %ecx,%esi
  800f15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f17:	85 c0                	test   %eax,%eax
  800f19:	7e 28                	jle    800f43 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f26:	00 
  800f27:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f36:	00 
  800f37:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800f3e:	e8 66 f2 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f43:	83 c4 2c             	add    $0x2c,%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    
  800f4b:	66 90                	xchg   %ax,%ax
  800f4d:	66 90                	xchg   %ax,%ax
  800f4f:	90                   	nop

00800f50 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	53                   	push   %ebx
  800f54:	83 ec 24             	sub    $0x24,%esp
  800f57:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  800f5a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  800f5c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f60:	74 18                	je     800f7a <pgfault+0x2a>
  800f62:	89 d8                	mov    %ebx,%eax
  800f64:	c1 e8 0c             	shr    $0xc,%eax
  800f67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6e:	25 05 08 00 00       	and    $0x805,%eax
  800f73:	3d 05 08 00 00       	cmp    $0x805,%eax
  800f78:	74 1c                	je     800f96 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  800f7a:	c7 44 24 08 0c 28 80 	movl   $0x80280c,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f89:	00 
  800f8a:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  800f91:	e8 13 f2 ff ff       	call   8001a9 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  800f96:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa5:	00 
  800fa6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fad:	e8 31 fd ff ff       	call   800ce3 <sys_page_alloc>
	if(r < 0){
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	79 1c                	jns    800fd2 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  800fb6:	c7 44 24 08 3c 28 80 	movl   $0x80283c,0x8(%esp)
  800fbd:	00 
  800fbe:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800fc5:	00 
  800fc6:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  800fcd:	e8 d7 f1 ff ff       	call   8001a9 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800fd2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800fd8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fdf:	00 
  800fe0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fe4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800feb:	e8 dc fa ff ff       	call   800acc <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  800ff0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ff7:	00 
  800ff8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ffc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801003:	00 
  801004:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80100b:	00 
  80100c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801013:	e8 1f fd ff ff       	call   800d37 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 1c                	jns    801038 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  80101c:	c7 44 24 08 08 29 80 	movl   $0x802908,0x8(%esp)
  801023:	00 
  801024:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80102b:	00 
  80102c:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801033:	e8 71 f1 ff ff       	call   8001a9 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  801038:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80103f:	00 
  801040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801047:	e8 3e fd ff ff       	call   800d8a <sys_page_unmap>
    if(r < 0){
  80104c:	85 c0                	test   %eax,%eax
  80104e:	79 1c                	jns    80106c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  801050:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  801057:	00 
  801058:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80105f:	00 
  801060:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801067:	e8 3d f1 ff ff       	call   8001a9 <_panic>
    }
    // LAB 4
}
  80106c:	83 c4 24             	add    $0x24,%esp
  80106f:	5b                   	pop    %ebx
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  80107b:	c7 04 24 50 0f 80 00 	movl   $0x800f50,(%esp)
  801082:	e8 6f 10 00 00       	call   8020f6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801087:	b8 07 00 00 00       	mov    $0x7,%eax
  80108c:	cd 30                	int    $0x30
  80108e:	89 c7                	mov    %eax,%edi
  801090:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801093:	85 c0                	test   %eax,%eax
  801095:	79 1c                	jns    8010b3 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801097:	c7 44 24 08 38 29 80 	movl   $0x802938,0x8(%esp)
  80109e:	00 
  80109f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  8010a6:	00 
  8010a7:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  8010ae:	e8 f6 f0 ff ff       	call   8001a9 <_panic>
    }
    if(child == 0){
  8010b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	75 21                	jne    8010dd <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  8010bc:	e8 e4 fb ff ff       	call   800ca5 <sys_getenvid>
  8010c1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010ce:	a3 08 40 80 00       	mov    %eax,0x804008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d8:	e9 67 01 00 00       	jmp    801244 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  8010dd:	89 d8                	mov    %ebx,%eax
  8010df:	c1 e8 16             	shr    $0x16,%eax
  8010e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e9:	a8 01                	test   $0x1,%al
  8010eb:	74 4b                	je     801138 <fork+0xc6>
  8010ed:	89 de                	mov    %ebx,%esi
  8010ef:	c1 ee 0c             	shr    $0xc,%esi
  8010f2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f9:	a8 01                	test   $0x1,%al
  8010fb:	74 3b                	je     801138 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  8010fd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801104:	a9 02 08 00 00       	test   $0x802,%eax
  801109:	0f 85 02 01 00 00    	jne    801211 <fork+0x19f>
  80110f:	e9 d2 00 00 00       	jmp    8011e6 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  801114:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80111b:	00 
  80111c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801120:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801127:	00 
  801128:	89 74 24 04          	mov    %esi,0x4(%esp)
  80112c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801133:	e8 ff fb ff ff       	call   800d37 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801138:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80113e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801144:	75 97                	jne    8010dd <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801146:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80114d:	00 
  80114e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801155:	ee 
  801156:	89 3c 24             	mov    %edi,(%esp)
  801159:	e8 85 fb ff ff       	call   800ce3 <sys_page_alloc>

    if(r < 0){
  80115e:	85 c0                	test   %eax,%eax
  801160:	79 1c                	jns    80117e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801162:	c7 44 24 08 70 28 80 	movl   $0x802870,0x8(%esp)
  801169:	00 
  80116a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801171:	00 
  801172:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801179:	e8 2b f0 ff ff       	call   8001a9 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80117e:	a1 08 40 80 00       	mov    0x804008,%eax
  801183:	8b 40 64             	mov    0x64(%eax),%eax
  801186:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118a:	89 3c 24             	mov    %edi,(%esp)
  80118d:	e8 f1 fc ff ff       	call   800e83 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801192:	85 c0                	test   %eax,%eax
  801194:	79 1c                	jns    8011b2 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801196:	c7 44 24 08 90 28 80 	movl   $0x802890,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  8011ad:	e8 f7 ef ff ff       	call   8001a9 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  8011b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011b9:	00 
  8011ba:	89 3c 24             	mov    %edi,(%esp)
  8011bd:	e8 1b fc ff ff       	call   800ddd <sys_env_set_status>
    if(r < 0){
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	79 1c                	jns    8011e2 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  8011c6:	c7 44 24 08 b8 28 80 	movl   $0x8028b8,0x8(%esp)
  8011cd:	00 
  8011ce:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  8011d5:	00 
  8011d6:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  8011dd:	e8 c7 ef ff ff       	call   8001a9 <_panic>
    }
    return child;
  8011e2:	89 f8                	mov    %edi,%eax
  8011e4:	eb 5e                	jmp    801244 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  8011e6:	c1 e6 0c             	shl    $0xc,%esi
  8011e9:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011f0:	00 
  8011f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801200:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801207:	e8 2b fb ff ff       	call   800d37 <sys_page_map>
  80120c:	e9 27 ff ff ff       	jmp    801138 <fork+0xc6>
  801211:	c1 e6 0c             	shl    $0xc,%esi
  801214:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80121b:	00 
  80121c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801223:	89 44 24 08          	mov    %eax,0x8(%esp)
  801227:	89 74 24 04          	mov    %esi,0x4(%esp)
  80122b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801232:	e8 00 fb ff ff       	call   800d37 <sys_page_map>
    if( r < 0 ){
  801237:	85 c0                	test   %eax,%eax
  801239:	0f 89 d5 fe ff ff    	jns    801114 <fork+0xa2>
  80123f:	e9 f4 fe ff ff       	jmp    801138 <fork+0xc6>
//	panic("fork not implemented");
}
  801244:	83 c4 2c             	add    $0x2c,%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <sfork>:

// Challenge!
int
sfork(void)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801252:	c7 44 24 08 55 29 80 	movl   $0x802955,0x8(%esp)
  801259:	00 
  80125a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801261:	00 
  801262:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801269:	e8 3b ef ff ff       	call   8001a9 <_panic>
  80126e:	66 90                	xchg   %ax,%ax

00801270 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	56                   	push   %esi
  801274:	53                   	push   %ebx
  801275:	83 ec 10             	sub    $0x10,%esp
  801278:	8b 75 08             	mov    0x8(%ebp),%esi
  80127b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801281:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801283:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801288:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80128b:	89 04 24             	mov    %eax,(%esp)
  80128e:	e8 66 fc ff ff       	call   800ef9 <sys_ipc_recv>
    if(r < 0){
  801293:	85 c0                	test   %eax,%eax
  801295:	79 16                	jns    8012ad <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801297:	85 f6                	test   %esi,%esi
  801299:	74 06                	je     8012a1 <ipc_recv+0x31>
            *from_env_store = 0;
  80129b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  8012a1:	85 db                	test   %ebx,%ebx
  8012a3:	74 2c                	je     8012d1 <ipc_recv+0x61>
            *perm_store = 0;
  8012a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012ab:	eb 24                	jmp    8012d1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  8012ad:	85 f6                	test   %esi,%esi
  8012af:	74 0a                	je     8012bb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  8012b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012b6:	8b 40 74             	mov    0x74(%eax),%eax
  8012b9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  8012bb:	85 db                	test   %ebx,%ebx
  8012bd:	74 0a                	je     8012c9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  8012bf:	a1 08 40 80 00       	mov    0x804008,%eax
  8012c4:	8b 40 78             	mov    0x78(%eax),%eax
  8012c7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8012c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ce:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 1c             	sub    $0x1c,%esp
  8012e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  8012ea:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  8012ec:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8012f1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8012f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801303:	89 3c 24             	mov    %edi,(%esp)
  801306:	e8 cb fb ff ff       	call   800ed6 <sys_ipc_try_send>
        if(r == 0){
  80130b:	85 c0                	test   %eax,%eax
  80130d:	74 28                	je     801337 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80130f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801312:	74 1c                	je     801330 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801314:	c7 44 24 08 6b 29 80 	movl   $0x80296b,0x8(%esp)
  80131b:	00 
  80131c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801323:	00 
  801324:	c7 04 24 82 29 80 00 	movl   $0x802982,(%esp)
  80132b:	e8 79 ee ff ff       	call   8001a9 <_panic>
        }
        sys_yield();
  801330:	e8 8f f9 ff ff       	call   800cc4 <sys_yield>
    }
  801335:	eb bd                	jmp    8012f4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801337:	83 c4 1c             	add    $0x1c,%esp
  80133a:	5b                   	pop    %ebx
  80133b:	5e                   	pop    %esi
  80133c:	5f                   	pop    %edi
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    

0080133f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80134a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80134d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801353:	8b 52 50             	mov    0x50(%edx),%edx
  801356:	39 ca                	cmp    %ecx,%edx
  801358:	75 0d                	jne    801367 <ipc_find_env+0x28>
			return envs[i].env_id;
  80135a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80135d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801362:	8b 40 40             	mov    0x40(%eax),%eax
  801365:	eb 0e                	jmp    801375 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801367:	83 c0 01             	add    $0x1,%eax
  80136a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80136f:	75 d9                	jne    80134a <ipc_find_env+0xb>
	return 0;
  801371:	66 b8 00 00          	mov    $0x0,%ax
}
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    
  801377:	66 90                	xchg   %ax,%ax
  801379:	66 90                	xchg   %ax,%ax
  80137b:	66 90                	xchg   %ax,%ax
  80137d:	66 90                	xchg   %ax,%ax
  80137f:	90                   	nop

00801380 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	05 00 00 00 30       	add    $0x30000000,%eax
  80138b:	c1 e8 0c             	shr    $0xc,%eax
}
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801393:	8b 45 08             	mov    0x8(%ebp),%eax
  801396:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80139b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013a0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ad:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013b2:	89 c2                	mov    %eax,%edx
  8013b4:	c1 ea 16             	shr    $0x16,%edx
  8013b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013be:	f6 c2 01             	test   $0x1,%dl
  8013c1:	74 11                	je     8013d4 <fd_alloc+0x2d>
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	c1 ea 0c             	shr    $0xc,%edx
  8013c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cf:	f6 c2 01             	test   $0x1,%dl
  8013d2:	75 09                	jne    8013dd <fd_alloc+0x36>
			*fd_store = fd;
  8013d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013db:	eb 17                	jmp    8013f4 <fd_alloc+0x4d>
  8013dd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013e2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013e7:	75 c9                	jne    8013b2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8013e9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013fc:	83 f8 1f             	cmp    $0x1f,%eax
  8013ff:	77 36                	ja     801437 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801401:	c1 e0 0c             	shl    $0xc,%eax
  801404:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801409:	89 c2                	mov    %eax,%edx
  80140b:	c1 ea 16             	shr    $0x16,%edx
  80140e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801415:	f6 c2 01             	test   $0x1,%dl
  801418:	74 24                	je     80143e <fd_lookup+0x48>
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	c1 ea 0c             	shr    $0xc,%edx
  80141f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801426:	f6 c2 01             	test   $0x1,%dl
  801429:	74 1a                	je     801445 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80142b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142e:	89 02                	mov    %eax,(%edx)
	return 0;
  801430:	b8 00 00 00 00       	mov    $0x0,%eax
  801435:	eb 13                	jmp    80144a <fd_lookup+0x54>
		return -E_INVAL;
  801437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143c:	eb 0c                	jmp    80144a <fd_lookup+0x54>
		return -E_INVAL;
  80143e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801443:	eb 05                	jmp    80144a <fd_lookup+0x54>
  801445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 18             	sub    $0x18,%esp
  801452:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801455:	ba 08 2a 80 00       	mov    $0x802a08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80145a:	eb 13                	jmp    80146f <dev_lookup+0x23>
  80145c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80145f:	39 08                	cmp    %ecx,(%eax)
  801461:	75 0c                	jne    80146f <dev_lookup+0x23>
			*dev = devtab[i];
  801463:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801466:	89 01                	mov    %eax,(%ecx)
			return 0;
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
  80146d:	eb 30                	jmp    80149f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80146f:	8b 02                	mov    (%edx),%eax
  801471:	85 c0                	test   %eax,%eax
  801473:	75 e7                	jne    80145c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801475:	a1 08 40 80 00       	mov    0x804008,%eax
  80147a:	8b 40 48             	mov    0x48(%eax),%eax
  80147d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801481:	89 44 24 04          	mov    %eax,0x4(%esp)
  801485:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  80148c:	e8 11 ee ff ff       	call   8002a2 <cprintf>
	*dev = 0;
  801491:	8b 45 0c             	mov    0xc(%ebp),%eax
  801494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80149a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80149f:	c9                   	leave  
  8014a0:	c3                   	ret    

008014a1 <fd_close>:
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	56                   	push   %esi
  8014a5:	53                   	push   %ebx
  8014a6:	83 ec 20             	sub    $0x20,%esp
  8014a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014b6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014bc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014bf:	89 04 24             	mov    %eax,(%esp)
  8014c2:	e8 2f ff ff ff       	call   8013f6 <fd_lookup>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 05                	js     8014d0 <fd_close+0x2f>
	    || fd != fd2)
  8014cb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014ce:	74 0c                	je     8014dc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8014d0:	84 db                	test   %bl,%bl
  8014d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d7:	0f 44 c2             	cmove  %edx,%eax
  8014da:	eb 3f                	jmp    80151b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e3:	8b 06                	mov    (%esi),%eax
  8014e5:	89 04 24             	mov    %eax,(%esp)
  8014e8:	e8 5f ff ff ff       	call   80144c <dev_lookup>
  8014ed:	89 c3                	mov    %eax,%ebx
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 16                	js     801509 <fd_close+0x68>
		if (dev->dev_close)
  8014f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014fe:	85 c0                	test   %eax,%eax
  801500:	74 07                	je     801509 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801502:	89 34 24             	mov    %esi,(%esp)
  801505:	ff d0                	call   *%eax
  801507:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801509:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801514:	e8 71 f8 ff ff       	call   800d8a <sys_page_unmap>
	return r;
  801519:	89 d8                	mov    %ebx,%eax
}
  80151b:	83 c4 20             	add    $0x20,%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <close>:

int
close(int fdnum)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801528:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152f:	8b 45 08             	mov    0x8(%ebp),%eax
  801532:	89 04 24             	mov    %eax,(%esp)
  801535:	e8 bc fe ff ff       	call   8013f6 <fd_lookup>
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	85 d2                	test   %edx,%edx
  80153e:	78 13                	js     801553 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801540:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801547:	00 
  801548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154b:	89 04 24             	mov    %eax,(%esp)
  80154e:	e8 4e ff ff ff       	call   8014a1 <fd_close>
}
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <close_all>:

void
close_all(void)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	53                   	push   %ebx
  801559:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80155c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801561:	89 1c 24             	mov    %ebx,(%esp)
  801564:	e8 b9 ff ff ff       	call   801522 <close>
	for (i = 0; i < MAXFD; i++)
  801569:	83 c3 01             	add    $0x1,%ebx
  80156c:	83 fb 20             	cmp    $0x20,%ebx
  80156f:	75 f0                	jne    801561 <close_all+0xc>
}
  801571:	83 c4 14             	add    $0x14,%esp
  801574:	5b                   	pop    %ebx
  801575:	5d                   	pop    %ebp
  801576:	c3                   	ret    

00801577 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	57                   	push   %edi
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
  80157d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801580:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801583:	89 44 24 04          	mov    %eax,0x4(%esp)
  801587:	8b 45 08             	mov    0x8(%ebp),%eax
  80158a:	89 04 24             	mov    %eax,(%esp)
  80158d:	e8 64 fe ff ff       	call   8013f6 <fd_lookup>
  801592:	89 c2                	mov    %eax,%edx
  801594:	85 d2                	test   %edx,%edx
  801596:	0f 88 e1 00 00 00    	js     80167d <dup+0x106>
		return r;
	close(newfdnum);
  80159c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159f:	89 04 24             	mov    %eax,(%esp)
  8015a2:	e8 7b ff ff ff       	call   801522 <close>

	newfd = INDEX2FD(newfdnum);
  8015a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015aa:	c1 e3 0c             	shl    $0xc,%ebx
  8015ad:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015b6:	89 04 24             	mov    %eax,(%esp)
  8015b9:	e8 d2 fd ff ff       	call   801390 <fd2data>
  8015be:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8015c0:	89 1c 24             	mov    %ebx,(%esp)
  8015c3:	e8 c8 fd ff ff       	call   801390 <fd2data>
  8015c8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ca:	89 f0                	mov    %esi,%eax
  8015cc:	c1 e8 16             	shr    $0x16,%eax
  8015cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015d6:	a8 01                	test   $0x1,%al
  8015d8:	74 43                	je     80161d <dup+0xa6>
  8015da:	89 f0                	mov    %esi,%eax
  8015dc:	c1 e8 0c             	shr    $0xc,%eax
  8015df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015e6:	f6 c2 01             	test   $0x1,%dl
  8015e9:	74 32                	je     80161d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801606:	00 
  801607:	89 74 24 04          	mov    %esi,0x4(%esp)
  80160b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801612:	e8 20 f7 ff ff       	call   800d37 <sys_page_map>
  801617:	89 c6                	mov    %eax,%esi
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 3e                	js     80165b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80161d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801620:	89 c2                	mov    %eax,%edx
  801622:	c1 ea 0c             	shr    $0xc,%edx
  801625:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80162c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801632:	89 54 24 10          	mov    %edx,0x10(%esp)
  801636:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80163a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801641:	00 
  801642:	89 44 24 04          	mov    %eax,0x4(%esp)
  801646:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164d:	e8 e5 f6 ff ff       	call   800d37 <sys_page_map>
  801652:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801654:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801657:	85 f6                	test   %esi,%esi
  801659:	79 22                	jns    80167d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80165b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80165f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801666:	e8 1f f7 ff ff       	call   800d8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80166b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80166f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801676:	e8 0f f7 ff ff       	call   800d8a <sys_page_unmap>
	return r;
  80167b:	89 f0                	mov    %esi,%eax
}
  80167d:	83 c4 3c             	add    $0x3c,%esp
  801680:	5b                   	pop    %ebx
  801681:	5e                   	pop    %esi
  801682:	5f                   	pop    %edi
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	53                   	push   %ebx
  801689:	83 ec 24             	sub    $0x24,%esp
  80168c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801692:	89 44 24 04          	mov    %eax,0x4(%esp)
  801696:	89 1c 24             	mov    %ebx,(%esp)
  801699:	e8 58 fd ff ff       	call   8013f6 <fd_lookup>
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	85 d2                	test   %edx,%edx
  8016a2:	78 6d                	js     801711 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ae:	8b 00                	mov    (%eax),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 94 fd ff ff       	call   80144c <dev_lookup>
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 55                	js     801711 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bf:	8b 50 08             	mov    0x8(%eax),%edx
  8016c2:	83 e2 03             	and    $0x3,%edx
  8016c5:	83 fa 01             	cmp    $0x1,%edx
  8016c8:	75 23                	jne    8016ed <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8016cf:	8b 40 48             	mov    0x48(%eax),%eax
  8016d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016da:	c7 04 24 cd 29 80 00 	movl   $0x8029cd,(%esp)
  8016e1:	e8 bc eb ff ff       	call   8002a2 <cprintf>
		return -E_INVAL;
  8016e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016eb:	eb 24                	jmp    801711 <read+0x8c>
	}
	if (!dev->dev_read)
  8016ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f0:	8b 52 08             	mov    0x8(%edx),%edx
  8016f3:	85 d2                	test   %edx,%edx
  8016f5:	74 15                	je     80170c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801701:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801705:	89 04 24             	mov    %eax,(%esp)
  801708:	ff d2                	call   *%edx
  80170a:	eb 05                	jmp    801711 <read+0x8c>
		return -E_NOT_SUPP;
  80170c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801711:	83 c4 24             	add    $0x24,%esp
  801714:	5b                   	pop    %ebx
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	57                   	push   %edi
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	83 ec 1c             	sub    $0x1c,%esp
  801720:	8b 7d 08             	mov    0x8(%ebp),%edi
  801723:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801726:	bb 00 00 00 00       	mov    $0x0,%ebx
  80172b:	eb 23                	jmp    801750 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80172d:	89 f0                	mov    %esi,%eax
  80172f:	29 d8                	sub    %ebx,%eax
  801731:	89 44 24 08          	mov    %eax,0x8(%esp)
  801735:	89 d8                	mov    %ebx,%eax
  801737:	03 45 0c             	add    0xc(%ebp),%eax
  80173a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173e:	89 3c 24             	mov    %edi,(%esp)
  801741:	e8 3f ff ff ff       	call   801685 <read>
		if (m < 0)
  801746:	85 c0                	test   %eax,%eax
  801748:	78 10                	js     80175a <readn+0x43>
			return m;
		if (m == 0)
  80174a:	85 c0                	test   %eax,%eax
  80174c:	74 0a                	je     801758 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80174e:	01 c3                	add    %eax,%ebx
  801750:	39 f3                	cmp    %esi,%ebx
  801752:	72 d9                	jb     80172d <readn+0x16>
  801754:	89 d8                	mov    %ebx,%eax
  801756:	eb 02                	jmp    80175a <readn+0x43>
  801758:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80175a:	83 c4 1c             	add    $0x1c,%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5f                   	pop    %edi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	53                   	push   %ebx
  801766:	83 ec 24             	sub    $0x24,%esp
  801769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801773:	89 1c 24             	mov    %ebx,(%esp)
  801776:	e8 7b fc ff ff       	call   8013f6 <fd_lookup>
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	85 d2                	test   %edx,%edx
  80177f:	78 68                	js     8017e9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801781:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801784:	89 44 24 04          	mov    %eax,0x4(%esp)
  801788:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178b:	8b 00                	mov    (%eax),%eax
  80178d:	89 04 24             	mov    %eax,(%esp)
  801790:	e8 b7 fc ff ff       	call   80144c <dev_lookup>
  801795:	85 c0                	test   %eax,%eax
  801797:	78 50                	js     8017e9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a0:	75 23                	jne    8017c5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a2:	a1 08 40 80 00       	mov    0x804008,%eax
  8017a7:	8b 40 48             	mov    0x48(%eax),%eax
  8017aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b2:	c7 04 24 e9 29 80 00 	movl   $0x8029e9,(%esp)
  8017b9:	e8 e4 ea ff ff       	call   8002a2 <cprintf>
		return -E_INVAL;
  8017be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c3:	eb 24                	jmp    8017e9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017cb:	85 d2                	test   %edx,%edx
  8017cd:	74 15                	je     8017e4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017d2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017dd:	89 04 24             	mov    %eax,(%esp)
  8017e0:	ff d2                	call   *%edx
  8017e2:	eb 05                	jmp    8017e9 <write+0x87>
		return -E_NOT_SUPP;
  8017e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017e9:	83 c4 24             	add    $0x24,%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <seek>:

int
seek(int fdnum, off_t offset)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	89 04 24             	mov    %eax,(%esp)
  801802:	e8 ef fb ff ff       	call   8013f6 <fd_lookup>
  801807:	85 c0                	test   %eax,%eax
  801809:	78 0e                	js     801819 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80180b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80180e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801811:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	83 ec 24             	sub    $0x24,%esp
  801822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801825:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182c:	89 1c 24             	mov    %ebx,(%esp)
  80182f:	e8 c2 fb ff ff       	call   8013f6 <fd_lookup>
  801834:	89 c2                	mov    %eax,%edx
  801836:	85 d2                	test   %edx,%edx
  801838:	78 61                	js     80189b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801844:	8b 00                	mov    (%eax),%eax
  801846:	89 04 24             	mov    %eax,(%esp)
  801849:	e8 fe fb ff ff       	call   80144c <dev_lookup>
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 49                	js     80189b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801855:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801859:	75 23                	jne    80187e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80185b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801860:	8b 40 48             	mov    0x48(%eax),%eax
  801863:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	c7 04 24 ac 29 80 00 	movl   $0x8029ac,(%esp)
  801872:	e8 2b ea ff ff       	call   8002a2 <cprintf>
		return -E_INVAL;
  801877:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80187c:	eb 1d                	jmp    80189b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80187e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801881:	8b 52 18             	mov    0x18(%edx),%edx
  801884:	85 d2                	test   %edx,%edx
  801886:	74 0e                	je     801896 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80188b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	ff d2                	call   *%edx
  801894:	eb 05                	jmp    80189b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801896:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80189b:	83 c4 24             	add    $0x24,%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5d                   	pop    %ebp
  8018a0:	c3                   	ret    

008018a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	53                   	push   %ebx
  8018a5:	83 ec 24             	sub    $0x24,%esp
  8018a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	89 04 24             	mov    %eax,(%esp)
  8018b8:	e8 39 fb ff ff       	call   8013f6 <fd_lookup>
  8018bd:	89 c2                	mov    %eax,%edx
  8018bf:	85 d2                	test   %edx,%edx
  8018c1:	78 52                	js     801915 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cd:	8b 00                	mov    (%eax),%eax
  8018cf:	89 04 24             	mov    %eax,(%esp)
  8018d2:	e8 75 fb ff ff       	call   80144c <dev_lookup>
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 3a                	js     801915 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8018db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018e2:	74 2c                	je     801910 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ee:	00 00 00 
	stat->st_isdir = 0;
  8018f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f8:	00 00 00 
	stat->st_dev = dev;
  8018fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801901:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801905:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801908:	89 14 24             	mov    %edx,(%esp)
  80190b:	ff 50 14             	call   *0x14(%eax)
  80190e:	eb 05                	jmp    801915 <fstat+0x74>
		return -E_NOT_SUPP;
  801910:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801915:	83 c4 24             	add    $0x24,%esp
  801918:	5b                   	pop    %ebx
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	56                   	push   %esi
  80191f:	53                   	push   %ebx
  801920:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801923:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80192a:	00 
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	89 04 24             	mov    %eax,(%esp)
  801931:	e8 fb 01 00 00       	call   801b31 <open>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	85 db                	test   %ebx,%ebx
  80193a:	78 1b                	js     801957 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80193c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801943:	89 1c 24             	mov    %ebx,(%esp)
  801946:	e8 56 ff ff ff       	call   8018a1 <fstat>
  80194b:	89 c6                	mov    %eax,%esi
	close(fd);
  80194d:	89 1c 24             	mov    %ebx,(%esp)
  801950:	e8 cd fb ff ff       	call   801522 <close>
	return r;
  801955:	89 f0                	mov    %esi,%eax
}
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	56                   	push   %esi
  801962:	53                   	push   %ebx
  801963:	83 ec 10             	sub    $0x10,%esp
  801966:	89 c6                	mov    %eax,%esi
  801968:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80196a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801971:	75 11                	jne    801984 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801973:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80197a:	e8 c0 f9 ff ff       	call   80133f <ipc_find_env>
  80197f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801984:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80198b:	00 
  80198c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801993:	00 
  801994:	89 74 24 04          	mov    %esi,0x4(%esp)
  801998:	a1 04 40 80 00       	mov    0x804004,%eax
  80199d:	89 04 24             	mov    %eax,(%esp)
  8019a0:	e8 33 f9 ff ff       	call   8012d8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019ac:	00 
  8019ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b8:	e8 b3 f8 ff ff       	call   801270 <ipc_recv>
}
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	5b                   	pop    %ebx
  8019c1:	5e                   	pop    %esi
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8019e7:	e8 72 ff ff ff       	call   80195e <fsipc>
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devfile_flush>:
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801a04:	b8 06 00 00 00       	mov    $0x6,%eax
  801a09:	e8 50 ff ff ff       	call   80195e <fsipc>
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devfile_stat>:
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	83 ec 14             	sub    $0x14,%esp
  801a17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a20:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a25:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a2f:	e8 2a ff ff ff       	call   80195e <fsipc>
  801a34:	89 c2                	mov    %eax,%edx
  801a36:	85 d2                	test   %edx,%edx
  801a38:	78 2b                	js     801a65 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a3a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a41:	00 
  801a42:	89 1c 24             	mov    %ebx,(%esp)
  801a45:	e8 7d ee ff ff       	call   8008c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a4a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a4f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a55:	a1 84 50 80 00       	mov    0x805084,%eax
  801a5a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a65:	83 c4 14             	add    $0x14,%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <devfile_write>:
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801a71:	c7 44 24 08 18 2a 80 	movl   $0x802a18,0x8(%esp)
  801a78:	00 
  801a79:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a80:	00 
  801a81:	c7 04 24 36 2a 80 00 	movl   $0x802a36,(%esp)
  801a88:	e8 1c e7 ff ff       	call   8001a9 <_panic>

00801a8d <devfile_read>:
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	83 ec 10             	sub    $0x10,%esp
  801a95:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a98:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aa3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aae:	b8 03 00 00 00       	mov    $0x3,%eax
  801ab3:	e8 a6 fe ff ff       	call   80195e <fsipc>
  801ab8:	89 c3                	mov    %eax,%ebx
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 6a                	js     801b28 <devfile_read+0x9b>
	assert(r <= n);
  801abe:	39 c6                	cmp    %eax,%esi
  801ac0:	73 24                	jae    801ae6 <devfile_read+0x59>
  801ac2:	c7 44 24 0c 41 2a 80 	movl   $0x802a41,0xc(%esp)
  801ac9:	00 
  801aca:	c7 44 24 08 48 2a 80 	movl   $0x802a48,0x8(%esp)
  801ad1:	00 
  801ad2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ad9:	00 
  801ada:	c7 04 24 36 2a 80 00 	movl   $0x802a36,(%esp)
  801ae1:	e8 c3 e6 ff ff       	call   8001a9 <_panic>
	assert(r <= PGSIZE);
  801ae6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aeb:	7e 24                	jle    801b11 <devfile_read+0x84>
  801aed:	c7 44 24 0c 5d 2a 80 	movl   $0x802a5d,0xc(%esp)
  801af4:	00 
  801af5:	c7 44 24 08 48 2a 80 	movl   $0x802a48,0x8(%esp)
  801afc:	00 
  801afd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b04:	00 
  801b05:	c7 04 24 36 2a 80 00 	movl   $0x802a36,(%esp)
  801b0c:	e8 98 e6 ff ff       	call   8001a9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b11:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b15:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b1c:	00 
  801b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b20:	89 04 24             	mov    %eax,(%esp)
  801b23:	e8 3c ef ff ff       	call   800a64 <memmove>
}
  801b28:	89 d8                	mov    %ebx,%eax
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <open>:
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	53                   	push   %ebx
  801b35:	83 ec 24             	sub    $0x24,%esp
  801b38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801b3b:	89 1c 24             	mov    %ebx,(%esp)
  801b3e:	e8 4d ed ff ff       	call   800890 <strlen>
  801b43:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b48:	7f 60                	jg     801baa <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801b4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4d:	89 04 24             	mov    %eax,(%esp)
  801b50:	e8 52 f8 ff ff       	call   8013a7 <fd_alloc>
  801b55:	89 c2                	mov    %eax,%edx
  801b57:	85 d2                	test   %edx,%edx
  801b59:	78 54                	js     801baf <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801b5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b5f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b66:	e8 5c ed ff ff       	call   8008c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b76:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7b:	e8 de fd ff ff       	call   80195e <fsipc>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	85 c0                	test   %eax,%eax
  801b84:	79 17                	jns    801b9d <open+0x6c>
		fd_close(fd, 0);
  801b86:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b8d:	00 
  801b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b91:	89 04 24             	mov    %eax,(%esp)
  801b94:	e8 08 f9 ff ff       	call   8014a1 <fd_close>
		return r;
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	eb 12                	jmp    801baf <open+0x7e>
	return fd2num(fd);
  801b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba0:	89 04 24             	mov    %eax,(%esp)
  801ba3:	e8 d8 f7 ff ff       	call   801380 <fd2num>
  801ba8:	eb 05                	jmp    801baf <open+0x7e>
		return -E_BAD_PATH;
  801baa:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801baf:	83 c4 24             	add    $0x24,%esp
  801bb2:	5b                   	pop    %ebx
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc5:	e8 94 fd ff ff       	call   80195e <fsipc>
}
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	56                   	push   %esi
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 10             	sub    $0x10,%esp
  801bd4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bda:	89 04 24             	mov    %eax,(%esp)
  801bdd:	e8 ae f7 ff ff       	call   801390 <fd2data>
  801be2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801be4:	c7 44 24 04 69 2a 80 	movl   $0x802a69,0x4(%esp)
  801beb:	00 
  801bec:	89 1c 24             	mov    %ebx,(%esp)
  801bef:	e8 d3 ec ff ff       	call   8008c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bf4:	8b 46 04             	mov    0x4(%esi),%eax
  801bf7:	2b 06                	sub    (%esi),%eax
  801bf9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c06:	00 00 00 
	stat->st_dev = &devpipe;
  801c09:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c10:	30 80 00 
	return 0;
}
  801c13:	b8 00 00 00 00       	mov    $0x0,%eax
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	53                   	push   %ebx
  801c23:	83 ec 14             	sub    $0x14,%esp
  801c26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c34:	e8 51 f1 ff ff       	call   800d8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c39:	89 1c 24             	mov    %ebx,(%esp)
  801c3c:	e8 4f f7 ff ff       	call   801390 <fd2data>
  801c41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4c:	e8 39 f1 ff ff       	call   800d8a <sys_page_unmap>
}
  801c51:	83 c4 14             	add    $0x14,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <_pipeisclosed>:
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	57                   	push   %edi
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	83 ec 2c             	sub    $0x2c,%esp
  801c60:	89 c6                	mov    %eax,%esi
  801c62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801c65:	a1 08 40 80 00       	mov    0x804008,%eax
  801c6a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c6d:	89 34 24             	mov    %esi,(%esp)
  801c70:	e8 31 05 00 00       	call   8021a6 <pageref>
  801c75:	89 c7                	mov    %eax,%edi
  801c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c7a:	89 04 24             	mov    %eax,(%esp)
  801c7d:	e8 24 05 00 00       	call   8021a6 <pageref>
  801c82:	39 c7                	cmp    %eax,%edi
  801c84:	0f 94 c2             	sete   %dl
  801c87:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c8a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801c90:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c93:	39 fb                	cmp    %edi,%ebx
  801c95:	74 21                	je     801cb8 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801c97:	84 d2                	test   %dl,%dl
  801c99:	74 ca                	je     801c65 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c9b:	8b 51 58             	mov    0x58(%ecx),%edx
  801c9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ca2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ca6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801caa:	c7 04 24 70 2a 80 00 	movl   $0x802a70,(%esp)
  801cb1:	e8 ec e5 ff ff       	call   8002a2 <cprintf>
  801cb6:	eb ad                	jmp    801c65 <_pipeisclosed+0xe>
}
  801cb8:	83 c4 2c             	add    $0x2c,%esp
  801cbb:	5b                   	pop    %ebx
  801cbc:	5e                   	pop    %esi
  801cbd:	5f                   	pop    %edi
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <devpipe_write>:
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	57                   	push   %edi
  801cc4:	56                   	push   %esi
  801cc5:	53                   	push   %ebx
  801cc6:	83 ec 1c             	sub    $0x1c,%esp
  801cc9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ccc:	89 34 24             	mov    %esi,(%esp)
  801ccf:	e8 bc f6 ff ff       	call   801390 <fd2data>
  801cd4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cd6:	bf 00 00 00 00       	mov    $0x0,%edi
  801cdb:	eb 45                	jmp    801d22 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801cdd:	89 da                	mov    %ebx,%edx
  801cdf:	89 f0                	mov    %esi,%eax
  801ce1:	e8 71 ff ff ff       	call   801c57 <_pipeisclosed>
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	75 41                	jne    801d2b <devpipe_write+0x6b>
			sys_yield();
  801cea:	e8 d5 ef ff ff       	call   800cc4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cef:	8b 43 04             	mov    0x4(%ebx),%eax
  801cf2:	8b 0b                	mov    (%ebx),%ecx
  801cf4:	8d 51 20             	lea    0x20(%ecx),%edx
  801cf7:	39 d0                	cmp    %edx,%eax
  801cf9:	73 e2                	jae    801cdd <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d02:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d05:	99                   	cltd   
  801d06:	c1 ea 1b             	shr    $0x1b,%edx
  801d09:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d0c:	83 e1 1f             	and    $0x1f,%ecx
  801d0f:	29 d1                	sub    %edx,%ecx
  801d11:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d15:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d19:	83 c0 01             	add    $0x1,%eax
  801d1c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d1f:	83 c7 01             	add    $0x1,%edi
  801d22:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d25:	75 c8                	jne    801cef <devpipe_write+0x2f>
	return i;
  801d27:	89 f8                	mov    %edi,%eax
  801d29:	eb 05                	jmp    801d30 <devpipe_write+0x70>
				return 0;
  801d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <devpipe_read>:
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	57                   	push   %edi
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 1c             	sub    $0x1c,%esp
  801d41:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d44:	89 3c 24             	mov    %edi,(%esp)
  801d47:	e8 44 f6 ff ff       	call   801390 <fd2data>
  801d4c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d4e:	be 00 00 00 00       	mov    $0x0,%esi
  801d53:	eb 3d                	jmp    801d92 <devpipe_read+0x5a>
			if (i > 0)
  801d55:	85 f6                	test   %esi,%esi
  801d57:	74 04                	je     801d5d <devpipe_read+0x25>
				return i;
  801d59:	89 f0                	mov    %esi,%eax
  801d5b:	eb 43                	jmp    801da0 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801d5d:	89 da                	mov    %ebx,%edx
  801d5f:	89 f8                	mov    %edi,%eax
  801d61:	e8 f1 fe ff ff       	call   801c57 <_pipeisclosed>
  801d66:	85 c0                	test   %eax,%eax
  801d68:	75 31                	jne    801d9b <devpipe_read+0x63>
			sys_yield();
  801d6a:	e8 55 ef ff ff       	call   800cc4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d6f:	8b 03                	mov    (%ebx),%eax
  801d71:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d74:	74 df                	je     801d55 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d76:	99                   	cltd   
  801d77:	c1 ea 1b             	shr    $0x1b,%edx
  801d7a:	01 d0                	add    %edx,%eax
  801d7c:	83 e0 1f             	and    $0x1f,%eax
  801d7f:	29 d0                	sub    %edx,%eax
  801d81:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d89:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d8c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d8f:	83 c6 01             	add    $0x1,%esi
  801d92:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d95:	75 d8                	jne    801d6f <devpipe_read+0x37>
	return i;
  801d97:	89 f0                	mov    %esi,%eax
  801d99:	eb 05                	jmp    801da0 <devpipe_read+0x68>
				return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da0:	83 c4 1c             	add    $0x1c,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <pipe>:
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801db0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db3:	89 04 24             	mov    %eax,(%esp)
  801db6:	e8 ec f5 ff ff       	call   8013a7 <fd_alloc>
  801dbb:	89 c2                	mov    %eax,%edx
  801dbd:	85 d2                	test   %edx,%edx
  801dbf:	0f 88 4d 01 00 00    	js     801f12 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dcc:	00 
  801dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddb:	e8 03 ef ff ff       	call   800ce3 <sys_page_alloc>
  801de0:	89 c2                	mov    %eax,%edx
  801de2:	85 d2                	test   %edx,%edx
  801de4:	0f 88 28 01 00 00    	js     801f12 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801dea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ded:	89 04 24             	mov    %eax,(%esp)
  801df0:	e8 b2 f5 ff ff       	call   8013a7 <fd_alloc>
  801df5:	89 c3                	mov    %eax,%ebx
  801df7:	85 c0                	test   %eax,%eax
  801df9:	0f 88 fe 00 00 00    	js     801efd <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dff:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e06:	00 
  801e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e15:	e8 c9 ee ff ff       	call   800ce3 <sys_page_alloc>
  801e1a:	89 c3                	mov    %eax,%ebx
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	0f 88 d9 00 00 00    	js     801efd <pipe+0x155>
	va = fd2data(fd0);
  801e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e27:	89 04 24             	mov    %eax,(%esp)
  801e2a:	e8 61 f5 ff ff       	call   801390 <fd2data>
  801e2f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e31:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e38:	00 
  801e39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e44:	e8 9a ee ff ff       	call   800ce3 <sys_page_alloc>
  801e49:	89 c3                	mov    %eax,%ebx
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	0f 88 97 00 00 00    	js     801eea <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e56:	89 04 24             	mov    %eax,(%esp)
  801e59:	e8 32 f5 ff ff       	call   801390 <fd2data>
  801e5e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e65:	00 
  801e66:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e71:	00 
  801e72:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e7d:	e8 b5 ee ff ff       	call   800d37 <sys_page_map>
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	85 c0                	test   %eax,%eax
  801e86:	78 52                	js     801eda <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801e88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e91:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eab:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb5:	89 04 24             	mov    %eax,(%esp)
  801eb8:	e8 c3 f4 ff ff       	call   801380 <fd2num>
  801ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec5:	89 04 24             	mov    %eax,(%esp)
  801ec8:	e8 b3 f4 ff ff       	call   801380 <fd2num>
  801ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed8:	eb 38                	jmp    801f12 <pipe+0x16a>
	sys_page_unmap(0, va);
  801eda:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ede:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee5:	e8 a0 ee ff ff       	call   800d8a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef8:	e8 8d ee ff ff       	call   800d8a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0b:	e8 7a ee ff ff       	call   800d8a <sys_page_unmap>
  801f10:	89 d8                	mov    %ebx,%eax
}
  801f12:	83 c4 30             	add    $0x30,%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <pipeisclosed>:
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f26:	8b 45 08             	mov    0x8(%ebp),%eax
  801f29:	89 04 24             	mov    %eax,(%esp)
  801f2c:	e8 c5 f4 ff ff       	call   8013f6 <fd_lookup>
  801f31:	89 c2                	mov    %eax,%edx
  801f33:	85 d2                	test   %edx,%edx
  801f35:	78 15                	js     801f4c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3a:	89 04 24             	mov    %eax,(%esp)
  801f3d:	e8 4e f4 ff ff       	call   801390 <fd2data>
	return _pipeisclosed(fd, p);
  801f42:	89 c2                	mov    %eax,%edx
  801f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f47:	e8 0b fd ff ff       	call   801c57 <_pipeisclosed>
}
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    
  801f4e:	66 90                	xchg   %ax,%ax

00801f50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f60:	c7 44 24 04 88 2a 80 	movl   $0x802a88,0x4(%esp)
  801f67:	00 
  801f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6b:	89 04 24             	mov    %eax,(%esp)
  801f6e:	e8 54 e9 ff ff       	call   8008c7 <strcpy>
	return 0;
}
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
  801f78:	c9                   	leave  
  801f79:	c3                   	ret    

00801f7a <devcons_write>:
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	57                   	push   %edi
  801f7e:	56                   	push   %esi
  801f7f:	53                   	push   %ebx
  801f80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f86:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f91:	eb 31                	jmp    801fc4 <devcons_write+0x4a>
		m = n - tot;
  801f93:	8b 75 10             	mov    0x10(%ebp),%esi
  801f96:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f98:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801f9b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fa0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fa3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fa7:	03 45 0c             	add    0xc(%ebp),%eax
  801faa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fae:	89 3c 24             	mov    %edi,(%esp)
  801fb1:	e8 ae ea ff ff       	call   800a64 <memmove>
		sys_cputs(buf, m);
  801fb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fba:	89 3c 24             	mov    %edi,(%esp)
  801fbd:	e8 54 ec ff ff       	call   800c16 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fc2:	01 f3                	add    %esi,%ebx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fc9:	72 c8                	jb     801f93 <devcons_write+0x19>
}
  801fcb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fd1:	5b                   	pop    %ebx
  801fd2:	5e                   	pop    %esi
  801fd3:	5f                   	pop    %edi
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    

00801fd6 <devcons_read>:
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801fdc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fe1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe5:	75 07                	jne    801fee <devcons_read+0x18>
  801fe7:	eb 2a                	jmp    802013 <devcons_read+0x3d>
		sys_yield();
  801fe9:	e8 d6 ec ff ff       	call   800cc4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801fee:	66 90                	xchg   %ax,%ax
  801ff0:	e8 3f ec ff ff       	call   800c34 <sys_cgetc>
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	74 f0                	je     801fe9 <devcons_read+0x13>
	if (c < 0)
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	78 16                	js     802013 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801ffd:	83 f8 04             	cmp    $0x4,%eax
  802000:	74 0c                	je     80200e <devcons_read+0x38>
	*(char*)vbuf = c;
  802002:	8b 55 0c             	mov    0xc(%ebp),%edx
  802005:	88 02                	mov    %al,(%edx)
	return 1;
  802007:	b8 01 00 00 00       	mov    $0x1,%eax
  80200c:	eb 05                	jmp    802013 <devcons_read+0x3d>
		return 0;
  80200e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802013:	c9                   	leave  
  802014:	c3                   	ret    

00802015 <cputchar>:
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
  80201e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802021:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802028:	00 
  802029:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 e2 eb ff ff       	call   800c16 <sys_cputs>
}
  802034:	c9                   	leave  
  802035:	c3                   	ret    

00802036 <getchar>:
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80203c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802043:	00 
  802044:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802052:	e8 2e f6 ff ff       	call   801685 <read>
	if (r < 0)
  802057:	85 c0                	test   %eax,%eax
  802059:	78 0f                	js     80206a <getchar+0x34>
	if (r < 1)
  80205b:	85 c0                	test   %eax,%eax
  80205d:	7e 06                	jle    802065 <getchar+0x2f>
	return c;
  80205f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802063:	eb 05                	jmp    80206a <getchar+0x34>
		return -E_EOF;
  802065:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80206a:	c9                   	leave  
  80206b:	c3                   	ret    

0080206c <iscons>:
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802075:	89 44 24 04          	mov    %eax,0x4(%esp)
  802079:	8b 45 08             	mov    0x8(%ebp),%eax
  80207c:	89 04 24             	mov    %eax,(%esp)
  80207f:	e8 72 f3 ff ff       	call   8013f6 <fd_lookup>
  802084:	85 c0                	test   %eax,%eax
  802086:	78 11                	js     802099 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802091:	39 10                	cmp    %edx,(%eax)
  802093:	0f 94 c0             	sete   %al
  802096:	0f b6 c0             	movzbl %al,%eax
}
  802099:	c9                   	leave  
  80209a:	c3                   	ret    

0080209b <opencons>:
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a4:	89 04 24             	mov    %eax,(%esp)
  8020a7:	e8 fb f2 ff ff       	call   8013a7 <fd_alloc>
		return r;
  8020ac:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	78 40                	js     8020f2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020b9:	00 
  8020ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c8:	e8 16 ec ff ff       	call   800ce3 <sys_page_alloc>
		return r;
  8020cd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	78 1f                	js     8020f2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8020d3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e8:	89 04 24             	mov    %eax,(%esp)
  8020eb:	e8 90 f2 ff ff       	call   801380 <fd2num>
  8020f0:	89 c2                	mov    %eax,%edx
}
  8020f2:	89 d0                	mov    %edx,%eax
  8020f4:	c9                   	leave  
  8020f5:	c3                   	ret    

008020f6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  8020fc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802103:	75 70                	jne    802175 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802105:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80210c:	00 
  80210d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802114:	ee 
  802115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211c:	e8 c2 eb ff ff       	call   800ce3 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  802121:	85 c0                	test   %eax,%eax
  802123:	79 1c                	jns    802141 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  802125:	c7 44 24 08 94 2a 80 	movl   $0x802a94,0x8(%esp)
  80212c:	00 
  80212d:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  802134:	00 
  802135:	c7 04 24 f0 2a 80 00 	movl   $0x802af0,(%esp)
  80213c:	e8 68 e0 ff ff       	call   8001a9 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  802141:	c7 44 24 04 7f 21 80 	movl   $0x80217f,0x4(%esp)
  802148:	00 
  802149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802150:	e8 2e ed ff ff       	call   800e83 <sys_env_set_pgfault_upcall>
        if(r < 0)
  802155:	85 c0                	test   %eax,%eax
  802157:	79 1c                	jns    802175 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  802159:	c7 44 24 08 bc 2a 80 	movl   $0x802abc,0x8(%esp)
  802160:	00 
  802161:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  802168:	00 
  802169:	c7 04 24 f0 2a 80 00 	movl   $0x802af0,(%esp)
  802170:	e8 34 e0 ff ff       	call   8001a9 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802175:	8b 45 08             	mov    0x8(%ebp),%eax
  802178:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80217d:	c9                   	leave  
  80217e:	c3                   	ret    

0080217f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80217f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802180:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802185:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802187:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  80218a:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  80218e:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802192:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  802194:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  802196:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  802197:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  80219a:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  80219c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  80219f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  8021a0:	83 c4 04             	add    $0x4,%esp
    popf;
  8021a3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  8021a4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  8021a5:	c3                   	ret    

008021a6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ac:	89 d0                	mov    %edx,%eax
  8021ae:	c1 e8 16             	shr    $0x16,%eax
  8021b1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021b8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8021bd:	f6 c1 01             	test   $0x1,%cl
  8021c0:	74 1d                	je     8021df <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8021c2:	c1 ea 0c             	shr    $0xc,%edx
  8021c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021cc:	f6 c2 01             	test   $0x1,%dl
  8021cf:	74 0e                	je     8021df <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d1:	c1 ea 0c             	shr    $0xc,%edx
  8021d4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021db:	ef 
  8021dc:	0f b7 c0             	movzwl %ax,%eax
}
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    
  8021e1:	66 90                	xchg   %ax,%ax
  8021e3:	66 90                	xchg   %ax,%ax
  8021e5:	66 90                	xchg   %ax,%ax
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
