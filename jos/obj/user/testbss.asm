
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	c7 04 24 80 20 80 00 	movl   $0x802080,(%esp)
  800040:	e8 13 02 00 00       	call   800258 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800045:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004a:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800051:	00 
  800052:	74 20                	je     800074 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800054:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800058:	c7 44 24 08 fb 20 80 	movl   $0x8020fb,0x8(%esp)
  80005f:	00 
  800060:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800067:	00 
  800068:	c7 04 24 18 21 80 00 	movl   $0x802118,(%esp)
  80006f:	e8 eb 00 00 00       	call   80015f <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
  800074:	83 c0 01             	add    $0x1,%eax
  800077:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007c:	75 cc                	jne    80004a <umain+0x17>
  80007e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800083:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80008a:	83 c0 01             	add    $0x1,%eax
  80008d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800092:	75 ef                	jne    800083 <umain+0x50>
  800094:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800099:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  8000a0:	74 20                	je     8000c2 <umain+0x8f>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 18 21 80 00 	movl   $0x802118,(%esp)
  8000bd:	e8 9d 00 00 00       	call   80015f <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000ca:	75 cd                	jne    800099 <umain+0x66>

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000cc:	c7 04 24 c8 20 80 00 	movl   $0x8020c8,(%esp)
  8000d3:	e8 80 01 00 00       	call   800258 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d8:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000df:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e2:	c7 44 24 08 27 21 80 	movl   $0x802127,0x8(%esp)
  8000e9:	00 
  8000ea:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000f1:	00 
  8000f2:	c7 04 24 18 21 80 00 	movl   $0x802118,(%esp)
  8000f9:	e8 61 00 00 00       	call   80015f <_panic>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 10             	sub    $0x10,%esp
  800106:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800109:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  80010c:	e8 54 0b 00 00       	call   800c65 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800111:	25 ff 03 00 00       	and    $0x3ff,%eax
  800116:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 20 40 c0 00       	mov    %eax,0xc04020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800123:	85 db                	test   %ebx,%ebx
  800125:	7e 07                	jle    80012e <libmain+0x30>
		binaryname = argv[0];
  800127:	8b 06                	mov    (%esi),%eax
  800129:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800132:	89 1c 24             	mov    %ebx,(%esp)
  800135:	e8 f9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013a:	e8 07 00 00 00       	call   800146 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014c:	e8 94 0f 00 00       	call   8010e5 <close_all>
	sys_env_destroy(0);
  800151:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800158:	e8 b6 0a 00 00       	call   800c13 <sys_env_destroy>
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800167:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800170:	e8 f0 0a 00 00       	call   800c65 <sys_getenvid>
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800183:	89 74 24 08          	mov    %esi,0x8(%esp)
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	c7 04 24 48 21 80 00 	movl   $0x802148,(%esp)
  800192:	e8 c1 00 00 00       	call   800258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800197:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019b:	8b 45 10             	mov    0x10(%ebp),%eax
  80019e:	89 04 24             	mov    %eax,(%esp)
  8001a1:	e8 51 00 00 00       	call   8001f7 <vcprintf>
	cprintf("\n");
  8001a6:	c7 04 24 16 21 80 00 	movl   $0x802116,(%esp)
  8001ad:	e8 a6 00 00 00       	call   800258 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b2:	cc                   	int3   
  8001b3:	eb fd                	jmp    8001b2 <_panic+0x53>

008001b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 14             	sub    $0x14,%esp
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001bf:	8b 13                	mov    (%ebx),%edx
  8001c1:	8d 42 01             	lea    0x1(%edx),%eax
  8001c4:	89 03                	mov    %eax,(%ebx)
  8001c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001cd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d2:	75 19                	jne    8001ed <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001db:	00 
  8001dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	e8 ef 09 00 00       	call   800bd6 <sys_cputs>
		b->idx = 0;
  8001e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ed:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800222:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	c7 04 24 b5 01 80 00 	movl   $0x8001b5,(%esp)
  800233:	e8 b6 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800238:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 86 09 00 00       	call   800bd6 <sys_cputs>

	return b.cnt;
}
  800250:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 87 ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    
  800272:	66 90                	xchg   %ax,%ax
  800274:	66 90                	xchg   %ax,%ax
  800276:	66 90                	xchg   %ax,%ax
  800278:	66 90                	xchg   %ax,%ax
  80027a:	66 90                	xchg   %ax,%ax
  80027c:	66 90                	xchg   %ax,%ax
  80027e:	66 90                	xchg   %ax,%ax

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 c3                	mov    %eax,%ebx
  800299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ad:	39 d9                	cmp    %ebx,%ecx
  8002af:	72 05                	jb     8002b6 <printnum+0x36>
  8002b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002b4:	77 69                	ja     80031f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002bd:	83 ee 01             	sub    $0x1,%esi
  8002c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d0:	89 c3                	mov    %eax,%ebx
  8002d2:	89 d6                	mov    %edx,%esi
  8002d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 ec 1a 00 00       	call   801de0 <__udivdi3>
  8002f4:	89 d9                	mov    %ebx,%ecx
  8002f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	89 54 24 04          	mov    %edx,0x4(%esp)
  800305:	89 fa                	mov    %edi,%edx
  800307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030a:	e8 71 ff ff ff       	call   800280 <printnum>
  80030f:	eb 1b                	jmp    80032c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	8b 45 18             	mov    0x18(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff d3                	call   *%ebx
  80031d:	eb 03                	jmp    800322 <printnum+0xa2>
  80031f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800322:	83 ee 01             	sub    $0x1,%esi
  800325:	85 f6                	test   %esi,%esi
  800327:	7f e8                	jg     800311 <printnum+0x91>
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800330:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800337:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80033a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 bc 1b 00 00       	call   801f10 <__umoddi3>
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	0f be 80 6b 21 80 00 	movsbl 0x80216b(%eax),%eax
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800365:	ff d0                	call   *%eax
}
  800367:	83 c4 3c             	add    $0x3c,%esp
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800372:	83 fa 01             	cmp    $0x1,%edx
  800375:	7e 0e                	jle    800385 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800377:	8b 10                	mov    (%eax),%edx
  800379:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037c:	89 08                	mov    %ecx,(%eax)
  80037e:	8b 02                	mov    (%edx),%eax
  800380:	8b 52 04             	mov    0x4(%edx),%edx
  800383:	eb 22                	jmp    8003a7 <getuint+0x38>
	else if (lflag)
  800385:	85 d2                	test   %edx,%edx
  800387:	74 10                	je     800399 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	eb 0e                	jmp    8003a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 02                	mov    (%edx),%eax
  8003a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b8:	73 0a                	jae    8003c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	88 02                	mov    %al,(%edx)
}
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <printfmt>:
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	e8 02 00 00 00       	call   8003ee <vprintfmt>
}
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 3c             	sub    $0x3c,%esp
  8003f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003fd:	eb 1f                	jmp    80041e <vprintfmt+0x30>
			if (ch == '\0'){
  8003ff:	85 c0                	test   %eax,%eax
  800401:	75 0f                	jne    800412 <vprintfmt+0x24>
				color = 0x0100;
  800403:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80040a:	01 00 00 
  80040d:	e9 b3 03 00 00       	jmp    8007c5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800412:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800416:	89 04 24             	mov    %eax,(%esp)
  800419:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041c:	89 f3                	mov    %esi,%ebx
  80041e:	8d 73 01             	lea    0x1(%ebx),%esi
  800421:	0f b6 03             	movzbl (%ebx),%eax
  800424:	83 f8 25             	cmp    $0x25,%eax
  800427:	75 d6                	jne    8003ff <vprintfmt+0x11>
  800429:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80042d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800434:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80043b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800442:	ba 00 00 00 00       	mov    $0x0,%edx
  800447:	eb 1d                	jmp    800466 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800449:	89 de                	mov    %ebx,%esi
			padc = '-';
  80044b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80044f:	eb 15                	jmp    800466 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800451:	89 de                	mov    %ebx,%esi
			padc = '0';
  800453:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800457:	eb 0d                	jmp    800466 <vprintfmt+0x78>
				width = precision, precision = -1;
  800459:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80045c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80045f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8d 5e 01             	lea    0x1(%esi),%ebx
  800469:	0f b6 0e             	movzbl (%esi),%ecx
  80046c:	0f b6 c1             	movzbl %cl,%eax
  80046f:	83 e9 23             	sub    $0x23,%ecx
  800472:	80 f9 55             	cmp    $0x55,%cl
  800475:	0f 87 2a 03 00 00    	ja     8007a5 <vprintfmt+0x3b7>
  80047b:	0f b6 c9             	movzbl %cl,%ecx
  80047e:	ff 24 8d a0 22 80 00 	jmp    *0x8022a0(,%ecx,4)
  800485:	89 de                	mov    %ebx,%esi
  800487:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80048c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80048f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800493:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800496:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800499:	83 fb 09             	cmp    $0x9,%ebx
  80049c:	77 36                	ja     8004d4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80049e:	83 c6 01             	add    $0x1,%esi
			}
  8004a1:	eb e9                	jmp    80048c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ac:	8b 00                	mov    (%eax),%eax
  8004ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004b3:	eb 22                	jmp    8004d7 <vprintfmt+0xe9>
  8004b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	0f 49 c1             	cmovns %ecx,%eax
  8004c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	89 de                	mov    %ebx,%esi
  8004c7:	eb 9d                	jmp    800466 <vprintfmt+0x78>
  8004c9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004d2:	eb 92                	jmp    800466 <vprintfmt+0x78>
  8004d4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8004d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004db:	79 89                	jns    800466 <vprintfmt+0x78>
  8004dd:	e9 77 ff ff ff       	jmp    800459 <vprintfmt+0x6b>
			lflag++;
  8004e2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004e7:	e9 7a ff ff ff       	jmp    800466 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800501:	e9 18 ff ff ff       	jmp    80041e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	99                   	cltd   
  800512:	31 d0                	xor    %edx,%eax
  800514:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800516:	83 f8 0f             	cmp    $0xf,%eax
  800519:	7f 0b                	jg     800526 <vprintfmt+0x138>
  80051b:	8b 14 85 00 24 80 00 	mov    0x802400(,%eax,4),%edx
  800522:	85 d2                	test   %edx,%edx
  800524:	75 20                	jne    800546 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800526:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052a:	c7 44 24 08 83 21 80 	movl   $0x802183,0x8(%esp)
  800531:	00 
  800532:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800536:	8b 45 08             	mov    0x8(%ebp),%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	e8 85 fe ff ff       	call   8003c6 <printfmt>
  800541:	e9 d8 fe ff ff       	jmp    80041e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800546:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054a:	c7 44 24 08 5e 25 80 	movl   $0x80255e,0x8(%esp)
  800551:	00 
  800552:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800556:	8b 45 08             	mov    0x8(%ebp),%eax
  800559:	89 04 24             	mov    %eax,(%esp)
  80055c:	e8 65 fe ff ff       	call   8003c6 <printfmt>
  800561:	e9 b8 fe ff ff       	jmp    80041e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800569:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80056c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80057a:	85 f6                	test   %esi,%esi
  80057c:	b8 7c 21 80 00       	mov    $0x80217c,%eax
  800581:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800584:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800588:	0f 84 97 00 00 00    	je     800625 <vprintfmt+0x237>
  80058e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800592:	0f 8e 9b 00 00 00    	jle    800633 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800598:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80059c:	89 34 24             	mov    %esi,(%esp)
  80059f:	e8 c4 02 00 00       	call   800868 <strnlen>
  8005a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a7:	29 c2                	sub    %eax,%edx
  8005a9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005ac:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005b3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005bc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	eb 0f                	jmp    8005cf <vprintfmt+0x1e1>
					putch(padc, putdat);
  8005c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cc:	83 eb 01             	sub    $0x1,%ebx
  8005cf:	85 db                	test   %ebx,%ebx
  8005d1:	7f ed                	jg     8005c0 <vprintfmt+0x1d2>
  8005d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e0:	0f 49 c2             	cmovns %edx,%eax
  8005e3:	29 c2                	sub    %eax,%edx
  8005e5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005e8:	89 d7                	mov    %edx,%edi
  8005ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005ed:	eb 50                	jmp    80063f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f3:	74 1e                	je     800613 <vprintfmt+0x225>
  8005f5:	0f be d2             	movsbl %dl,%edx
  8005f8:	83 ea 20             	sub    $0x20,%edx
  8005fb:	83 fa 5e             	cmp    $0x5e,%edx
  8005fe:	76 13                	jbe    800613 <vprintfmt+0x225>
					putch('?', putdat);
  800600:	8b 45 0c             	mov    0xc(%ebp),%eax
  800603:	89 44 24 04          	mov    %eax,0x4(%esp)
  800607:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060e:	ff 55 08             	call   *0x8(%ebp)
  800611:	eb 0d                	jmp    800620 <vprintfmt+0x232>
					putch(ch, putdat);
  800613:	8b 55 0c             	mov    0xc(%ebp),%edx
  800616:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800620:	83 ef 01             	sub    $0x1,%edi
  800623:	eb 1a                	jmp    80063f <vprintfmt+0x251>
  800625:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800628:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80062b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80062e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800631:	eb 0c                	jmp    80063f <vprintfmt+0x251>
  800633:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800636:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800639:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80063c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80063f:	83 c6 01             	add    $0x1,%esi
  800642:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800646:	0f be c2             	movsbl %dl,%eax
  800649:	85 c0                	test   %eax,%eax
  80064b:	74 27                	je     800674 <vprintfmt+0x286>
  80064d:	85 db                	test   %ebx,%ebx
  80064f:	78 9e                	js     8005ef <vprintfmt+0x201>
  800651:	83 eb 01             	sub    $0x1,%ebx
  800654:	79 99                	jns    8005ef <vprintfmt+0x201>
  800656:	89 f8                	mov    %edi,%eax
  800658:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80065b:	8b 75 08             	mov    0x8(%ebp),%esi
  80065e:	89 c3                	mov    %eax,%ebx
  800660:	eb 1a                	jmp    80067c <vprintfmt+0x28e>
				putch(' ', putdat);
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80066d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80066f:	83 eb 01             	sub    $0x1,%ebx
  800672:	eb 08                	jmp    80067c <vprintfmt+0x28e>
  800674:	89 fb                	mov    %edi,%ebx
  800676:	8b 75 08             	mov    0x8(%ebp),%esi
  800679:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80067c:	85 db                	test   %ebx,%ebx
  80067e:	7f e2                	jg     800662 <vprintfmt+0x274>
  800680:	89 75 08             	mov    %esi,0x8(%ebp)
  800683:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800686:	e9 93 fd ff ff       	jmp    80041e <vprintfmt+0x30>
	if (lflag >= 2)
  80068b:	83 fa 01             	cmp    $0x1,%edx
  80068e:	7e 16                	jle    8006a6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 08             	lea    0x8(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 50 04             	mov    0x4(%eax),%edx
  80069c:	8b 00                	mov    (%eax),%eax
  80069e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006a4:	eb 32                	jmp    8006d8 <vprintfmt+0x2ea>
	else if (lflag)
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	74 18                	je     8006c2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 04             	lea    0x4(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b3:	8b 30                	mov    (%eax),%esi
  8006b5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006b8:	89 f0                	mov    %esi,%eax
  8006ba:	c1 f8 1f             	sar    $0x1f,%eax
  8006bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c0:	eb 16                	jmp    8006d8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 04             	lea    0x4(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cb:	8b 30                	mov    (%eax),%esi
  8006cd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	c1 f8 1f             	sar    $0x1f,%eax
  8006d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8006d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8006de:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e7:	0f 89 80 00 00 00    	jns    80076d <vprintfmt+0x37f>
				putch('-', putdat);
  8006ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800701:	f7 d8                	neg    %eax
  800703:	83 d2 00             	adc    $0x0,%edx
  800706:	f7 da                	neg    %edx
			base = 10;
  800708:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80070d:	eb 5e                	jmp    80076d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
  800712:	e8 58 fc ff ff       	call   80036f <getuint>
			base = 10;
  800717:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80071c:	eb 4f                	jmp    80076d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
  800721:	e8 49 fc ff ff       	call   80036f <getuint>
            base = 8;
  800726:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80072b:	eb 40                	jmp    80076d <vprintfmt+0x37f>
			putch('0', putdat);
  80072d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800731:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800738:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80073b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800746:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8d 50 04             	lea    0x4(%eax),%edx
  80074f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800752:	8b 00                	mov    (%eax),%eax
  800754:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800759:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80075e:	eb 0d                	jmp    80076d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
  800763:	e8 07 fc ff ff       	call   80036f <getuint>
			base = 16;
  800768:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80076d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800771:	89 74 24 10          	mov    %esi,0x10(%esp)
  800775:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800778:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80077c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	89 54 24 04          	mov    %edx,0x4(%esp)
  800787:	89 fa                	mov    %edi,%edx
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	e8 ef fa ff ff       	call   800280 <printnum>
			break;
  800791:	e9 88 fc ff ff       	jmp    80041e <vprintfmt+0x30>
			putch(ch, putdat);
  800796:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079a:	89 04 24             	mov    %eax,(%esp)
  80079d:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007a0:	e9 79 fc ff ff       	jmp    80041e <vprintfmt+0x30>
			putch('%', putdat);
  8007a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b3:	89 f3                	mov    %esi,%ebx
  8007b5:	eb 03                	jmp    8007ba <vprintfmt+0x3cc>
  8007b7:	83 eb 01             	sub    $0x1,%ebx
  8007ba:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007be:	75 f7                	jne    8007b7 <vprintfmt+0x3c9>
  8007c0:	e9 59 fc ff ff       	jmp    80041e <vprintfmt+0x30>
}
  8007c5:	83 c4 3c             	add    $0x3c,%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5f                   	pop    %edi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 28             	sub    $0x28,%esp
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	74 30                	je     80081e <vsnprintf+0x51>
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	7e 2c                	jle    80081e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	89 44 24 04          	mov    %eax,0x4(%esp)
  800807:	c7 04 24 a9 03 80 00 	movl   $0x8003a9,(%esp)
  80080e:	e8 db fb ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800813:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800816:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081c:	eb 05                	jmp    800823 <vsnprintf+0x56>
		return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800832:	8b 45 10             	mov    0x10(%ebp),%eax
  800835:	89 44 24 08          	mov    %eax,0x8(%esp)
  800839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 82 ff ff ff       	call   8007cd <vsnprintf>
	va_end(ap);

	return rc;
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    
  80084d:	66 90                	xchg   %ax,%ax
  80084f:	90                   	nop

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	eb 03                	jmp    800860 <strlen+0x10>
		n++;
  80085d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800860:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800864:	75 f7                	jne    80085d <strlen+0xd>
	return n;
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
  800876:	eb 03                	jmp    80087b <strnlen+0x13>
		n++;
  800878:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	39 d0                	cmp    %edx,%eax
  80087d:	74 06                	je     800885 <strnlen+0x1d>
  80087f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800883:	75 f3                	jne    800878 <strnlen+0x10>
	return n;
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800891:	89 c2                	mov    %eax,%edx
  800893:	83 c2 01             	add    $0x1,%edx
  800896:	83 c1 01             	add    $0x1,%ecx
  800899:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80089d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a0:	84 db                	test   %bl,%bl
  8008a2:	75 ef                	jne    800893 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b1:	89 1c 24             	mov    %ebx,(%esp)
  8008b4:	e8 97 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c0:	01 d8                	add    %ebx,%eax
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	e8 bd ff ff ff       	call   800887 <strcpy>
	return dst;
}
  8008ca:	89 d8                	mov    %ebx,%eax
  8008cc:	83 c4 08             	add    $0x8,%esp
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	89 f3                	mov    %esi,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	eb 0f                	jmp    8008f5 <strncpy+0x23>
		*dst++ = *src;
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	0f b6 01             	movzbl (%ecx),%eax
  8008ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008f5:	39 da                	cmp    %ebx,%edx
  8008f7:	75 ed                	jne    8008e6 <strncpy+0x14>
	}
	return ret;
}
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80090d:	89 f0                	mov    %esi,%eax
  80090f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 c9                	test   %ecx,%ecx
  800915:	75 0b                	jne    800922 <strlcpy+0x23>
  800917:	eb 1d                	jmp    800936 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800922:	39 d8                	cmp    %ebx,%eax
  800924:	74 0b                	je     800931 <strlcpy+0x32>
  800926:	0f b6 0a             	movzbl (%edx),%ecx
  800929:	84 c9                	test   %cl,%cl
  80092b:	75 ec                	jne    800919 <strlcpy+0x1a>
  80092d:	89 c2                	mov    %eax,%edx
  80092f:	eb 02                	jmp    800933 <strlcpy+0x34>
  800931:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800933:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800936:	29 f0                	sub    %esi,%eax
}
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800945:	eb 06                	jmp    80094d <strcmp+0x11>
		p++, q++;
  800947:	83 c1 01             	add    $0x1,%ecx
  80094a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80094d:	0f b6 01             	movzbl (%ecx),%eax
  800950:	84 c0                	test   %al,%al
  800952:	74 04                	je     800958 <strcmp+0x1c>
  800954:	3a 02                	cmp    (%edx),%al
  800956:	74 ef                	je     800947 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800958:	0f b6 c0             	movzbl %al,%eax
  80095b:	0f b6 12             	movzbl (%edx),%edx
  80095e:	29 d0                	sub    %edx,%eax
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 c3                	mov    %eax,%ebx
  80096e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800971:	eb 06                	jmp    800979 <strncmp+0x17>
		n--, p++, q++;
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800979:	39 d8                	cmp    %ebx,%eax
  80097b:	74 15                	je     800992 <strncmp+0x30>
  80097d:	0f b6 08             	movzbl (%eax),%ecx
  800980:	84 c9                	test   %cl,%cl
  800982:	74 04                	je     800988 <strncmp+0x26>
  800984:	3a 0a                	cmp    (%edx),%cl
  800986:	74 eb                	je     800973 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 00             	movzbl (%eax),%eax
  80098b:	0f b6 12             	movzbl (%edx),%edx
  80098e:	29 d0                	sub    %edx,%eax
  800990:	eb 05                	jmp    800997 <strncmp+0x35>
		return 0;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a4:	eb 07                	jmp    8009ad <strchr+0x13>
		if (*s == c)
  8009a6:	38 ca                	cmp    %cl,%dl
  8009a8:	74 0f                	je     8009b9 <strchr+0x1f>
	for (; *s; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f2                	jne    8009a6 <strchr+0xc>
			return (char *) s;
	return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c5:	eb 07                	jmp    8009ce <strfind+0x13>
		if (*s == c)
  8009c7:	38 ca                	cmp    %cl,%dl
  8009c9:	74 0a                	je     8009d5 <strfind+0x1a>
	for (; *s; s++)
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	84 d2                	test   %dl,%dl
  8009d3:	75 f2                	jne    8009c7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e3:	85 c9                	test   %ecx,%ecx
  8009e5:	74 36                	je     800a1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ed:	75 28                	jne    800a17 <memset+0x40>
  8009ef:	f6 c1 03             	test   $0x3,%cl
  8009f2:	75 23                	jne    800a17 <memset+0x40>
		c &= 0xFF;
  8009f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f8:	89 d3                	mov    %edx,%ebx
  8009fa:	c1 e3 08             	shl    $0x8,%ebx
  8009fd:	89 d6                	mov    %edx,%esi
  8009ff:	c1 e6 18             	shl    $0x18,%esi
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	c1 e0 10             	shl    $0x10,%eax
  800a07:	09 f0                	or     %esi,%eax
  800a09:	09 c2                	or     %eax,%edx
  800a0b:	89 d0                	mov    %edx,%eax
  800a0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a12:	fc                   	cld    
  800a13:	f3 ab                	rep stos %eax,%es:(%edi)
  800a15:	eb 06                	jmp    800a1d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	fc                   	cld    
  800a1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1d:	89 f8                	mov    %edi,%eax
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5f                   	pop    %edi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a32:	39 c6                	cmp    %eax,%esi
  800a34:	73 35                	jae    800a6b <memmove+0x47>
  800a36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a39:	39 d0                	cmp    %edx,%eax
  800a3b:	73 2e                	jae    800a6b <memmove+0x47>
		s += n;
		d += n;
  800a3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a40:	89 d6                	mov    %edx,%esi
  800a42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4a:	75 13                	jne    800a5f <memmove+0x3b>
  800a4c:	f6 c1 03             	test   $0x3,%cl
  800a4f:	75 0e                	jne    800a5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a51:	83 ef 04             	sub    $0x4,%edi
  800a54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a57:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5a:	fd                   	std    
  800a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5d:	eb 09                	jmp    800a68 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5f:	83 ef 01             	sub    $0x1,%edi
  800a62:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a65:	fd                   	std    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a68:	fc                   	cld    
  800a69:	eb 1d                	jmp    800a88 <memmove+0x64>
  800a6b:	89 f2                	mov    %esi,%edx
  800a6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6f:	f6 c2 03             	test   $0x3,%dl
  800a72:	75 0f                	jne    800a83 <memmove+0x5f>
  800a74:	f6 c1 03             	test   $0x3,%cl
  800a77:	75 0a                	jne    800a83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	fc                   	cld    
  800a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a81:	eb 05                	jmp    800a88 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a92:	8b 45 10             	mov    0x10(%ebp),%eax
  800a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 79 ff ff ff       	call   800a24 <memmove>
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab8:	89 d6                	mov    %edx,%esi
  800aba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abd:	eb 1a                	jmp    800ad9 <memcmp+0x2c>
		if (*s1 != *s2)
  800abf:	0f b6 02             	movzbl (%edx),%eax
  800ac2:	0f b6 19             	movzbl (%ecx),%ebx
  800ac5:	38 d8                	cmp    %bl,%al
  800ac7:	74 0a                	je     800ad3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac9:	0f b6 c0             	movzbl %al,%eax
  800acc:	0f b6 db             	movzbl %bl,%ebx
  800acf:	29 d8                	sub    %ebx,%eax
  800ad1:	eb 0f                	jmp    800ae2 <memcmp+0x35>
		s1++, s2++;
  800ad3:	83 c2 01             	add    $0x1,%edx
  800ad6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800ad9:	39 f2                	cmp    %esi,%edx
  800adb:	75 e2                	jne    800abf <memcmp+0x12>
	}

	return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af4:	eb 07                	jmp    800afd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	38 08                	cmp    %cl,(%eax)
  800af8:	74 07                	je     800b01 <memfind+0x1b>
	for (; s < ends; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	39 d0                	cmp    %edx,%eax
  800aff:	72 f5                	jb     800af6 <memfind+0x10>
			break;
	return (void *) s;
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0f:	eb 03                	jmp    800b14 <strtol+0x11>
		s++;
  800b11:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b14:	0f b6 0a             	movzbl (%edx),%ecx
  800b17:	80 f9 09             	cmp    $0x9,%cl
  800b1a:	74 f5                	je     800b11 <strtol+0xe>
  800b1c:	80 f9 20             	cmp    $0x20,%cl
  800b1f:	74 f0                	je     800b11 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b21:	80 f9 2b             	cmp    $0x2b,%cl
  800b24:	75 0a                	jne    800b30 <strtol+0x2d>
		s++;
  800b26:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2e:	eb 11                	jmp    800b41 <strtol+0x3e>
  800b30:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b35:	80 f9 2d             	cmp    $0x2d,%cl
  800b38:	75 07                	jne    800b41 <strtol+0x3e>
		s++, neg = 1;
  800b3a:	8d 52 01             	lea    0x1(%edx),%edx
  800b3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b46:	75 15                	jne    800b5d <strtol+0x5a>
  800b48:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4b:	75 10                	jne    800b5d <strtol+0x5a>
  800b4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b51:	75 0a                	jne    800b5d <strtol+0x5a>
		s += 2, base = 16;
  800b53:	83 c2 02             	add    $0x2,%edx
  800b56:	b8 10 00 00 00       	mov    $0x10,%eax
  800b5b:	eb 10                	jmp    800b6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	75 0c                	jne    800b6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b61:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b63:	80 3a 30             	cmpb   $0x30,(%edx)
  800b66:	75 05                	jne    800b6d <strtol+0x6a>
		s++, base = 8;
  800b68:	83 c2 01             	add    $0x1,%edx
  800b6b:	b0 08                	mov    $0x8,%al
		base = 10;
  800b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b75:	0f b6 0a             	movzbl (%edx),%ecx
  800b78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b7b:	89 f0                	mov    %esi,%eax
  800b7d:	3c 09                	cmp    $0x9,%al
  800b7f:	77 08                	ja     800b89 <strtol+0x86>
			dig = *s - '0';
  800b81:	0f be c9             	movsbl %cl,%ecx
  800b84:	83 e9 30             	sub    $0x30,%ecx
  800b87:	eb 20                	jmp    800ba9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b8c:	89 f0                	mov    %esi,%eax
  800b8e:	3c 19                	cmp    $0x19,%al
  800b90:	77 08                	ja     800b9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b92:	0f be c9             	movsbl %cl,%ecx
  800b95:	83 e9 57             	sub    $0x57,%ecx
  800b98:	eb 0f                	jmp    800ba9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b9d:	89 f0                	mov    %esi,%eax
  800b9f:	3c 19                	cmp    $0x19,%al
  800ba1:	77 16                	ja     800bb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ba3:	0f be c9             	movsbl %cl,%ecx
  800ba6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ba9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bac:	7d 0f                	jge    800bbd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bb7:	eb bc                	jmp    800b75 <strtol+0x72>
  800bb9:	89 d8                	mov    %ebx,%eax
  800bbb:	eb 02                	jmp    800bbf <strtol+0xbc>
  800bbd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc3:	74 05                	je     800bca <strtol+0xc7>
		*endptr = (char *) s;
  800bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bca:	f7 d8                	neg    %eax
  800bcc:	85 ff                	test   %edi,%edi
  800bce:	0f 44 c3             	cmove  %ebx,%eax
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 c3                	mov    %eax,%ebx
  800be9:	89 c7                	mov    %eax,%edi
  800beb:	89 c6                	mov    %eax,%esi
  800bed:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 01 00 00 00       	mov    $0x1,%eax
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	89 d3                	mov    %edx,%ebx
  800c08:	89 d7                	mov    %edx,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c21:	b8 03 00 00 00       	mov    $0x3,%eax
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 cb                	mov    %ecx,%ebx
  800c2b:	89 cf                	mov    %ecx,%edi
  800c2d:	89 ce                	mov    %ecx,%esi
  800c2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7e 28                	jle    800c5d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c40:	00 
  800c41:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800c48:	00 
  800c49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c50:	00 
  800c51:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800c58:	e8 02 f5 ff ff       	call   80015f <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5d:	83 c4 2c             	add    $0x2c,%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c70:	b8 02 00 00 00       	mov    $0x2,%eax
  800c75:	89 d1                	mov    %edx,%ecx
  800c77:	89 d3                	mov    %edx,%ebx
  800c79:	89 d7                	mov    %edx,%edi
  800c7b:	89 d6                	mov    %edx,%esi
  800c7d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_yield>:

void
sys_yield(void)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c94:	89 d1                	mov    %edx,%ecx
  800c96:	89 d3                	mov    %edx,%ebx
  800c98:	89 d7                	mov    %edx,%edi
  800c9a:	89 d6                	mov    %edx,%esi
  800c9c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cac:	be 00 00 00 00       	mov    $0x0,%esi
  800cb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbf:	89 f7                	mov    %esi,%edi
  800cc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 28                	jle    800cef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800cda:	00 
  800cdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce2:	00 
  800ce3:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800cea:	e8 70 f4 ff ff       	call   80015f <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cef:	83 c4 2c             	add    $0x2c,%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d00:	b8 05 00 00 00       	mov    $0x5,%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d11:	8b 75 18             	mov    0x18(%ebp),%esi
  800d14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 28                	jle    800d42 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d25:	00 
  800d26:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800d2d:	00 
  800d2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d35:	00 
  800d36:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800d3d:	e8 1d f4 ff ff       	call   80015f <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d42:	83 c4 2c             	add    $0x2c,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800d90:	e8 ca f3 ff ff       	call   80015f <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d95:	83 c4 2c             	add    $0x2c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	b8 08 00 00 00       	mov    $0x8,%eax
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 28                	jle    800de8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddb:	00 
  800ddc:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800de3:	e8 77 f3 ff ff       	call   80015f <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de8:	83 c4 2c             	add    $0x2c,%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 28                	jle    800e3b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e17:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2e:	00 
  800e2f:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800e36:	e8 24 f3 ff ff       	call   80015f <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3b:	83 c4 2c             	add    $0x2c,%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 28                	jle    800e8e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e71:	00 
  800e72:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800e79:	00 
  800e7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e81:	00 
  800e82:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800e89:	e8 d1 f2 ff ff       	call   80015f <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e8e:	83 c4 2c             	add    $0x2c,%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ea1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eaf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ec2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	89 cb                	mov    %ecx,%ebx
  800ed1:	89 cf                	mov    %ecx,%edi
  800ed3:	89 ce                	mov    %ecx,%esi
  800ed5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	7e 28                	jle    800f03 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef6:	00 
  800ef7:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800efe:	e8 5c f2 ff ff       	call   80015f <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f03:	83 c4 2c             	add    $0x2c,%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    
  800f0b:	66 90                	xchg   %ax,%ax
  800f0d:	66 90                	xchg   %ax,%ax
  800f0f:	90                   	nop

00800f10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	05 00 00 00 30       	add    $0x30000000,%eax
  800f1b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f30:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f42:	89 c2                	mov    %eax,%edx
  800f44:	c1 ea 16             	shr    $0x16,%edx
  800f47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4e:	f6 c2 01             	test   $0x1,%dl
  800f51:	74 11                	je     800f64 <fd_alloc+0x2d>
  800f53:	89 c2                	mov    %eax,%edx
  800f55:	c1 ea 0c             	shr    $0xc,%edx
  800f58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5f:	f6 c2 01             	test   $0x1,%dl
  800f62:	75 09                	jne    800f6d <fd_alloc+0x36>
			*fd_store = fd;
  800f64:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	eb 17                	jmp    800f84 <fd_alloc+0x4d>
  800f6d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f72:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f77:	75 c9                	jne    800f42 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800f79:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f7f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f8c:	83 f8 1f             	cmp    $0x1f,%eax
  800f8f:	77 36                	ja     800fc7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f91:	c1 e0 0c             	shl    $0xc,%eax
  800f94:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f99:	89 c2                	mov    %eax,%edx
  800f9b:	c1 ea 16             	shr    $0x16,%edx
  800f9e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fa5:	f6 c2 01             	test   $0x1,%dl
  800fa8:	74 24                	je     800fce <fd_lookup+0x48>
  800faa:	89 c2                	mov    %eax,%edx
  800fac:	c1 ea 0c             	shr    $0xc,%edx
  800faf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fb6:	f6 c2 01             	test   $0x1,%dl
  800fb9:	74 1a                	je     800fd5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbe:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc5:	eb 13                	jmp    800fda <fd_lookup+0x54>
		return -E_INVAL;
  800fc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fcc:	eb 0c                	jmp    800fda <fd_lookup+0x54>
		return -E_INVAL;
  800fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd3:	eb 05                	jmp    800fda <fd_lookup+0x54>
  800fd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
  800fe2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe5:	ba 0c 25 80 00       	mov    $0x80250c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fea:	eb 13                	jmp    800fff <dev_lookup+0x23>
  800fec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fef:	39 08                	cmp    %ecx,(%eax)
  800ff1:	75 0c                	jne    800fff <dev_lookup+0x23>
			*dev = devtab[i];
  800ff3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffd:	eb 30                	jmp    80102f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800fff:	8b 02                	mov    (%edx),%eax
  801001:	85 c0                	test   %eax,%eax
  801003:	75 e7                	jne    800fec <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801005:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80100a:	8b 40 48             	mov    0x48(%eax),%eax
  80100d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801011:	89 44 24 04          	mov    %eax,0x4(%esp)
  801015:	c7 04 24 8c 24 80 00 	movl   $0x80248c,(%esp)
  80101c:	e8 37 f2 ff ff       	call   800258 <cprintf>
	*dev = 0;
  801021:	8b 45 0c             	mov    0xc(%ebp),%eax
  801024:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80102a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <fd_close>:
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
  801036:	83 ec 20             	sub    $0x20,%esp
  801039:	8b 75 08             	mov    0x8(%ebp),%esi
  80103c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80103f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801042:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801046:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80104c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80104f:	89 04 24             	mov    %eax,(%esp)
  801052:	e8 2f ff ff ff       	call   800f86 <fd_lookup>
  801057:	85 c0                	test   %eax,%eax
  801059:	78 05                	js     801060 <fd_close+0x2f>
	    || fd != fd2)
  80105b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80105e:	74 0c                	je     80106c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801060:	84 db                	test   %bl,%bl
  801062:	ba 00 00 00 00       	mov    $0x0,%edx
  801067:	0f 44 c2             	cmove  %edx,%eax
  80106a:	eb 3f                	jmp    8010ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80106c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801073:	8b 06                	mov    (%esi),%eax
  801075:	89 04 24             	mov    %eax,(%esp)
  801078:	e8 5f ff ff ff       	call   800fdc <dev_lookup>
  80107d:	89 c3                	mov    %eax,%ebx
  80107f:	85 c0                	test   %eax,%eax
  801081:	78 16                	js     801099 <fd_close+0x68>
		if (dev->dev_close)
  801083:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801086:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801089:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80108e:	85 c0                	test   %eax,%eax
  801090:	74 07                	je     801099 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801092:	89 34 24             	mov    %esi,(%esp)
  801095:	ff d0                	call   *%eax
  801097:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801099:	89 74 24 04          	mov    %esi,0x4(%esp)
  80109d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a4:	e8 a1 fc ff ff       	call   800d4a <sys_page_unmap>
	return r;
  8010a9:	89 d8                	mov    %ebx,%eax
}
  8010ab:	83 c4 20             	add    $0x20,%esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <close>:

int
close(int fdnum)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c2:	89 04 24             	mov    %eax,(%esp)
  8010c5:	e8 bc fe ff ff       	call   800f86 <fd_lookup>
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	85 d2                	test   %edx,%edx
  8010ce:	78 13                	js     8010e3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8010d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d7:	00 
  8010d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010db:	89 04 24             	mov    %eax,(%esp)
  8010de:	e8 4e ff ff ff       	call   801031 <fd_close>
}
  8010e3:	c9                   	leave  
  8010e4:	c3                   	ret    

008010e5 <close_all>:

void
close_all(void)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f1:	89 1c 24             	mov    %ebx,(%esp)
  8010f4:	e8 b9 ff ff ff       	call   8010b2 <close>
	for (i = 0; i < MAXFD; i++)
  8010f9:	83 c3 01             	add    $0x1,%ebx
  8010fc:	83 fb 20             	cmp    $0x20,%ebx
  8010ff:	75 f0                	jne    8010f1 <close_all+0xc>
}
  801101:	83 c4 14             	add    $0x14,%esp
  801104:	5b                   	pop    %ebx
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801110:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801113:	89 44 24 04          	mov    %eax,0x4(%esp)
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
  80111a:	89 04 24             	mov    %eax,(%esp)
  80111d:	e8 64 fe ff ff       	call   800f86 <fd_lookup>
  801122:	89 c2                	mov    %eax,%edx
  801124:	85 d2                	test   %edx,%edx
  801126:	0f 88 e1 00 00 00    	js     80120d <dup+0x106>
		return r;
	close(newfdnum);
  80112c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112f:	89 04 24             	mov    %eax,(%esp)
  801132:	e8 7b ff ff ff       	call   8010b2 <close>

	newfd = INDEX2FD(newfdnum);
  801137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80113a:	c1 e3 0c             	shl    $0xc,%ebx
  80113d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801146:	89 04 24             	mov    %eax,(%esp)
  801149:	e8 d2 fd ff ff       	call   800f20 <fd2data>
  80114e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801150:	89 1c 24             	mov    %ebx,(%esp)
  801153:	e8 c8 fd ff ff       	call   800f20 <fd2data>
  801158:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115a:	89 f0                	mov    %esi,%eax
  80115c:	c1 e8 16             	shr    $0x16,%eax
  80115f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801166:	a8 01                	test   $0x1,%al
  801168:	74 43                	je     8011ad <dup+0xa6>
  80116a:	89 f0                	mov    %esi,%eax
  80116c:	c1 e8 0c             	shr    $0xc,%eax
  80116f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801176:	f6 c2 01             	test   $0x1,%dl
  801179:	74 32                	je     8011ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801182:	25 07 0e 00 00       	and    $0xe07,%eax
  801187:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80118f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801196:	00 
  801197:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a2:	e8 50 fb ff ff       	call   800cf7 <sys_page_map>
  8011a7:	89 c6                	mov    %eax,%esi
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	78 3e                	js     8011eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 0c             	shr    $0xc,%edx
  8011b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d1:	00 
  8011d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011dd:	e8 15 fb ff ff       	call   800cf7 <sys_page_map>
  8011e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8011e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e7:	85 f6                	test   %esi,%esi
  8011e9:	79 22                	jns    80120d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8011eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f6:	e8 4f fb ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801206:	e8 3f fb ff ff       	call   800d4a <sys_page_unmap>
	return r;
  80120b:	89 f0                	mov    %esi,%eax
}
  80120d:	83 c4 3c             	add    $0x3c,%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	53                   	push   %ebx
  801219:	83 ec 24             	sub    $0x24,%esp
  80121c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801222:	89 44 24 04          	mov    %eax,0x4(%esp)
  801226:	89 1c 24             	mov    %ebx,(%esp)
  801229:	e8 58 fd ff ff       	call   800f86 <fd_lookup>
  80122e:	89 c2                	mov    %eax,%edx
  801230:	85 d2                	test   %edx,%edx
  801232:	78 6d                	js     8012a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801234:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123e:	8b 00                	mov    (%eax),%eax
  801240:	89 04 24             	mov    %eax,(%esp)
  801243:	e8 94 fd ff ff       	call   800fdc <dev_lookup>
  801248:	85 c0                	test   %eax,%eax
  80124a:	78 55                	js     8012a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124f:	8b 50 08             	mov    0x8(%eax),%edx
  801252:	83 e2 03             	and    $0x3,%edx
  801255:	83 fa 01             	cmp    $0x1,%edx
  801258:	75 23                	jne    80127d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80125a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80125f:	8b 40 48             	mov    0x48(%eax),%eax
  801262:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801266:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126a:	c7 04 24 d0 24 80 00 	movl   $0x8024d0,(%esp)
  801271:	e8 e2 ef ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  801276:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127b:	eb 24                	jmp    8012a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80127d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801280:	8b 52 08             	mov    0x8(%edx),%edx
  801283:	85 d2                	test   %edx,%edx
  801285:	74 15                	je     80129c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801287:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80128a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80128e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801291:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801295:	89 04 24             	mov    %eax,(%esp)
  801298:	ff d2                	call   *%edx
  80129a:	eb 05                	jmp    8012a1 <read+0x8c>
		return -E_NOT_SUPP;
  80129c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8012a1:	83 c4 24             	add    $0x24,%esp
  8012a4:	5b                   	pop    %ebx
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	57                   	push   %edi
  8012ab:	56                   	push   %esi
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 1c             	sub    $0x1c,%esp
  8012b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012bb:	eb 23                	jmp    8012e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012bd:	89 f0                	mov    %esi,%eax
  8012bf:	29 d8                	sub    %ebx,%eax
  8012c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c5:	89 d8                	mov    %ebx,%eax
  8012c7:	03 45 0c             	add    0xc(%ebp),%eax
  8012ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ce:	89 3c 24             	mov    %edi,(%esp)
  8012d1:	e8 3f ff ff ff       	call   801215 <read>
		if (m < 0)
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 10                	js     8012ea <readn+0x43>
			return m;
		if (m == 0)
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	74 0a                	je     8012e8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8012de:	01 c3                	add    %eax,%ebx
  8012e0:	39 f3                	cmp    %esi,%ebx
  8012e2:	72 d9                	jb     8012bd <readn+0x16>
  8012e4:	89 d8                	mov    %ebx,%eax
  8012e6:	eb 02                	jmp    8012ea <readn+0x43>
  8012e8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012ea:	83 c4 1c             	add    $0x1c,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 24             	sub    $0x24,%esp
  8012f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801303:	89 1c 24             	mov    %ebx,(%esp)
  801306:	e8 7b fc ff ff       	call   800f86 <fd_lookup>
  80130b:	89 c2                	mov    %eax,%edx
  80130d:	85 d2                	test   %edx,%edx
  80130f:	78 68                	js     801379 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	89 44 24 04          	mov    %eax,0x4(%esp)
  801318:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131b:	8b 00                	mov    (%eax),%eax
  80131d:	89 04 24             	mov    %eax,(%esp)
  801320:	e8 b7 fc ff ff       	call   800fdc <dev_lookup>
  801325:	85 c0                	test   %eax,%eax
  801327:	78 50                	js     801379 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801329:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801330:	75 23                	jne    801355 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801332:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801337:	8b 40 48             	mov    0x48(%eax),%eax
  80133a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80133e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801342:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  801349:	e8 0a ef ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  80134e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801353:	eb 24                	jmp    801379 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801355:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801358:	8b 52 0c             	mov    0xc(%edx),%edx
  80135b:	85 d2                	test   %edx,%edx
  80135d:	74 15                	je     801374 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80135f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801362:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801369:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80136d:	89 04 24             	mov    %eax,(%esp)
  801370:	ff d2                	call   *%edx
  801372:	eb 05                	jmp    801379 <write+0x87>
		return -E_NOT_SUPP;
  801374:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801379:	83 c4 24             	add    $0x24,%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <seek>:

int
seek(int fdnum, off_t offset)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801385:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138c:	8b 45 08             	mov    0x8(%ebp),%eax
  80138f:	89 04 24             	mov    %eax,(%esp)
  801392:	e8 ef fb ff ff       	call   800f86 <fd_lookup>
  801397:	85 c0                	test   %eax,%eax
  801399:	78 0e                	js     8013a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80139b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80139e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 24             	sub    $0x24,%esp
  8013b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bc:	89 1c 24             	mov    %ebx,(%esp)
  8013bf:	e8 c2 fb ff ff       	call   800f86 <fd_lookup>
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	85 d2                	test   %edx,%edx
  8013c8:	78 61                	js     80142b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	8b 00                	mov    (%eax),%eax
  8013d6:	89 04 24             	mov    %eax,(%esp)
  8013d9:	e8 fe fb ff ff       	call   800fdc <dev_lookup>
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 49                	js     80142b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e9:	75 23                	jne    80140e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013eb:	a1 20 40 c0 00       	mov    0xc04020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013f0:	8b 40 48             	mov    0x48(%eax),%eax
  8013f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fb:	c7 04 24 ac 24 80 00 	movl   $0x8024ac,(%esp)
  801402:	e8 51 ee ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  801407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140c:	eb 1d                	jmp    80142b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80140e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801411:	8b 52 18             	mov    0x18(%edx),%edx
  801414:	85 d2                	test   %edx,%edx
  801416:	74 0e                	je     801426 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801418:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	ff d2                	call   *%edx
  801424:	eb 05                	jmp    80142b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801426:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80142b:	83 c4 24             	add    $0x24,%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 24             	sub    $0x24,%esp
  801438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	89 04 24             	mov    %eax,(%esp)
  801448:	e8 39 fb ff ff       	call   800f86 <fd_lookup>
  80144d:	89 c2                	mov    %eax,%edx
  80144f:	85 d2                	test   %edx,%edx
  801451:	78 52                	js     8014a5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801453:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145d:	8b 00                	mov    (%eax),%eax
  80145f:	89 04 24             	mov    %eax,(%esp)
  801462:	e8 75 fb ff ff       	call   800fdc <dev_lookup>
  801467:	85 c0                	test   %eax,%eax
  801469:	78 3a                	js     8014a5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80146b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801472:	74 2c                	je     8014a0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801474:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801477:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80147e:	00 00 00 
	stat->st_isdir = 0;
  801481:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801488:	00 00 00 
	stat->st_dev = dev;
  80148b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801491:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801495:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801498:	89 14 24             	mov    %edx,(%esp)
  80149b:	ff 50 14             	call   *0x14(%eax)
  80149e:	eb 05                	jmp    8014a5 <fstat+0x74>
		return -E_NOT_SUPP;
  8014a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014a5:	83 c4 24             	add    $0x24,%esp
  8014a8:	5b                   	pop    %ebx
  8014a9:	5d                   	pop    %ebp
  8014aa:	c3                   	ret    

008014ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	56                   	push   %esi
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014ba:	00 
  8014bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014be:	89 04 24             	mov    %eax,(%esp)
  8014c1:	e8 fb 01 00 00       	call   8016c1 <open>
  8014c6:	89 c3                	mov    %eax,%ebx
  8014c8:	85 db                	test   %ebx,%ebx
  8014ca:	78 1b                	js     8014e7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d3:	89 1c 24             	mov    %ebx,(%esp)
  8014d6:	e8 56 ff ff ff       	call   801431 <fstat>
  8014db:	89 c6                	mov    %eax,%esi
	close(fd);
  8014dd:	89 1c 24             	mov    %ebx,(%esp)
  8014e0:	e8 cd fb ff ff       	call   8010b2 <close>
	return r;
  8014e5:	89 f0                	mov    %esi,%eax
}
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5e                   	pop    %esi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	56                   	push   %esi
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 10             	sub    $0x10,%esp
  8014f6:	89 c6                	mov    %eax,%esi
  8014f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014fa:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801501:	75 11                	jne    801514 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801503:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80150a:	e8 50 08 00 00       	call   801d5f <ipc_find_env>
  80150f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801514:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80151b:	00 
  80151c:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  801523:	00 
  801524:	89 74 24 04          	mov    %esi,0x4(%esp)
  801528:	a1 04 40 80 00       	mov    0x804004,%eax
  80152d:	89 04 24             	mov    %eax,(%esp)
  801530:	e8 c3 07 00 00       	call   801cf8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801535:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80153c:	00 
  80153d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801541:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801548:	e8 43 07 00 00       	call   801c90 <ipc_recv>
}
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	5b                   	pop    %ebx
  801551:	5e                   	pop    %esi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    

00801554 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80155a:	8b 45 08             	mov    0x8(%ebp),%eax
  80155d:	8b 40 0c             	mov    0xc(%eax),%eax
  801560:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801565:	8b 45 0c             	mov    0xc(%ebp),%eax
  801568:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80156d:	ba 00 00 00 00       	mov    $0x0,%edx
  801572:	b8 02 00 00 00       	mov    $0x2,%eax
  801577:	e8 72 ff ff ff       	call   8014ee <fsipc>
}
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <devfile_flush>:
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	8b 40 0c             	mov    0xc(%eax),%eax
  80158a:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80158f:	ba 00 00 00 00       	mov    $0x0,%edx
  801594:	b8 06 00 00 00       	mov    $0x6,%eax
  801599:	e8 50 ff ff ff       	call   8014ee <fsipc>
}
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <devfile_stat>:
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	53                   	push   %ebx
  8015a4:	83 ec 14             	sub    $0x14,%esp
  8015a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b0:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8015bf:	e8 2a ff ff ff       	call   8014ee <fsipc>
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	85 d2                	test   %edx,%edx
  8015c8:	78 2b                	js     8015f5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015ca:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  8015d1:	00 
  8015d2:	89 1c 24             	mov    %ebx,(%esp)
  8015d5:	e8 ad f2 ff ff       	call   800887 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015da:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8015df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015e5:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8015ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f5:	83 c4 14             	add    $0x14,%esp
  8015f8:	5b                   	pop    %ebx
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    

008015fb <devfile_write>:
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801601:	c7 44 24 08 1c 25 80 	movl   $0x80251c,0x8(%esp)
  801608:	00 
  801609:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801610:	00 
  801611:	c7 04 24 3a 25 80 00 	movl   $0x80253a,(%esp)
  801618:	e8 42 eb ff ff       	call   80015f <_panic>

0080161d <devfile_read>:
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
  801622:	83 ec 10             	sub    $0x10,%esp
  801625:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801628:	8b 45 08             	mov    0x8(%ebp),%eax
  80162b:	8b 40 0c             	mov    0xc(%eax),%eax
  80162e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801633:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801639:	ba 00 00 00 00       	mov    $0x0,%edx
  80163e:	b8 03 00 00 00       	mov    $0x3,%eax
  801643:	e8 a6 fe ff ff       	call   8014ee <fsipc>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 6a                	js     8016b8 <devfile_read+0x9b>
	assert(r <= n);
  80164e:	39 c6                	cmp    %eax,%esi
  801650:	73 24                	jae    801676 <devfile_read+0x59>
  801652:	c7 44 24 0c 45 25 80 	movl   $0x802545,0xc(%esp)
  801659:	00 
  80165a:	c7 44 24 08 4c 25 80 	movl   $0x80254c,0x8(%esp)
  801661:	00 
  801662:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801669:	00 
  80166a:	c7 04 24 3a 25 80 00 	movl   $0x80253a,(%esp)
  801671:	e8 e9 ea ff ff       	call   80015f <_panic>
	assert(r <= PGSIZE);
  801676:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80167b:	7e 24                	jle    8016a1 <devfile_read+0x84>
  80167d:	c7 44 24 0c 61 25 80 	movl   $0x802561,0xc(%esp)
  801684:	00 
  801685:	c7 44 24 08 4c 25 80 	movl   $0x80254c,0x8(%esp)
  80168c:	00 
  80168d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801694:	00 
  801695:	c7 04 24 3a 25 80 00 	movl   $0x80253a,(%esp)
  80169c:	e8 be ea ff ff       	call   80015f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016a5:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  8016ac:	00 
  8016ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 6c f3 ff ff       	call   800a24 <memmove>
}
  8016b8:	89 d8                	mov    %ebx,%eax
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <open>:
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 24             	sub    $0x24,%esp
  8016c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8016cb:	89 1c 24             	mov    %ebx,(%esp)
  8016ce:	e8 7d f1 ff ff       	call   800850 <strlen>
  8016d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d8:	7f 60                	jg     80173a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8016da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dd:	89 04 24             	mov    %eax,(%esp)
  8016e0:	e8 52 f8 ff ff       	call   800f37 <fd_alloc>
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	85 d2                	test   %edx,%edx
  8016e9:	78 54                	js     80173f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8016eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ef:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  8016f6:	e8 8c f1 ff ff       	call   800887 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fe:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801703:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801706:	b8 01 00 00 00       	mov    $0x1,%eax
  80170b:	e8 de fd ff ff       	call   8014ee <fsipc>
  801710:	89 c3                	mov    %eax,%ebx
  801712:	85 c0                	test   %eax,%eax
  801714:	79 17                	jns    80172d <open+0x6c>
		fd_close(fd, 0);
  801716:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80171d:	00 
  80171e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801721:	89 04 24             	mov    %eax,(%esp)
  801724:	e8 08 f9 ff ff       	call   801031 <fd_close>
		return r;
  801729:	89 d8                	mov    %ebx,%eax
  80172b:	eb 12                	jmp    80173f <open+0x7e>
	return fd2num(fd);
  80172d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801730:	89 04 24             	mov    %eax,(%esp)
  801733:	e8 d8 f7 ff ff       	call   800f10 <fd2num>
  801738:	eb 05                	jmp    80173f <open+0x7e>
		return -E_BAD_PATH;
  80173a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80173f:	83 c4 24             	add    $0x24,%esp
  801742:	5b                   	pop    %ebx
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80174b:	ba 00 00 00 00       	mov    $0x0,%edx
  801750:	b8 08 00 00 00       	mov    $0x8,%eax
  801755:	e8 94 fd ff ff       	call   8014ee <fsipc>
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	83 ec 10             	sub    $0x10,%esp
  801764:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801767:	8b 45 08             	mov    0x8(%ebp),%eax
  80176a:	89 04 24             	mov    %eax,(%esp)
  80176d:	e8 ae f7 ff ff       	call   800f20 <fd2data>
  801772:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801774:	c7 44 24 04 6d 25 80 	movl   $0x80256d,0x4(%esp)
  80177b:	00 
  80177c:	89 1c 24             	mov    %ebx,(%esp)
  80177f:	e8 03 f1 ff ff       	call   800887 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801784:	8b 46 04             	mov    0x4(%esi),%eax
  801787:	2b 06                	sub    (%esi),%eax
  801789:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80178f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801796:	00 00 00 
	stat->st_dev = &devpipe;
  801799:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017a0:	30 80 00 
	return 0;
}
  8017a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	5b                   	pop    %ebx
  8017ac:	5e                   	pop    %esi
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	53                   	push   %ebx
  8017b3:	83 ec 14             	sub    $0x14,%esp
  8017b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c4:	e8 81 f5 ff ff       	call   800d4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017c9:	89 1c 24             	mov    %ebx,(%esp)
  8017cc:	e8 4f f7 ff ff       	call   800f20 <fd2data>
  8017d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017dc:	e8 69 f5 ff ff       	call   800d4a <sys_page_unmap>
}
  8017e1:	83 c4 14             	add    $0x14,%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <_pipeisclosed>:
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	57                   	push   %edi
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 2c             	sub    $0x2c,%esp
  8017f0:	89 c6                	mov    %eax,%esi
  8017f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8017f5:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8017fa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017fd:	89 34 24             	mov    %esi,(%esp)
  801800:	e8 92 05 00 00       	call   801d97 <pageref>
  801805:	89 c7                	mov    %eax,%edi
  801807:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80180a:	89 04 24             	mov    %eax,(%esp)
  80180d:	e8 85 05 00 00       	call   801d97 <pageref>
  801812:	39 c7                	cmp    %eax,%edi
  801814:	0f 94 c2             	sete   %dl
  801817:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80181a:	8b 0d 20 40 c0 00    	mov    0xc04020,%ecx
  801820:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801823:	39 fb                	cmp    %edi,%ebx
  801825:	74 21                	je     801848 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801827:	84 d2                	test   %dl,%dl
  801829:	74 ca                	je     8017f5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80182b:	8b 51 58             	mov    0x58(%ecx),%edx
  80182e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801832:	89 54 24 08          	mov    %edx,0x8(%esp)
  801836:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183a:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  801841:	e8 12 ea ff ff       	call   800258 <cprintf>
  801846:	eb ad                	jmp    8017f5 <_pipeisclosed+0xe>
}
  801848:	83 c4 2c             	add    $0x2c,%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5e                   	pop    %esi
  80184d:	5f                   	pop    %edi
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <devpipe_write>:
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	57                   	push   %edi
  801854:	56                   	push   %esi
  801855:	53                   	push   %ebx
  801856:	83 ec 1c             	sub    $0x1c,%esp
  801859:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80185c:	89 34 24             	mov    %esi,(%esp)
  80185f:	e8 bc f6 ff ff       	call   800f20 <fd2data>
  801864:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801866:	bf 00 00 00 00       	mov    $0x0,%edi
  80186b:	eb 45                	jmp    8018b2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  80186d:	89 da                	mov    %ebx,%edx
  80186f:	89 f0                	mov    %esi,%eax
  801871:	e8 71 ff ff ff       	call   8017e7 <_pipeisclosed>
  801876:	85 c0                	test   %eax,%eax
  801878:	75 41                	jne    8018bb <devpipe_write+0x6b>
			sys_yield();
  80187a:	e8 05 f4 ff ff       	call   800c84 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80187f:	8b 43 04             	mov    0x4(%ebx),%eax
  801882:	8b 0b                	mov    (%ebx),%ecx
  801884:	8d 51 20             	lea    0x20(%ecx),%edx
  801887:	39 d0                	cmp    %edx,%eax
  801889:	73 e2                	jae    80186d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80188b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80188e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801892:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801895:	99                   	cltd   
  801896:	c1 ea 1b             	shr    $0x1b,%edx
  801899:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80189c:	83 e1 1f             	and    $0x1f,%ecx
  80189f:	29 d1                	sub    %edx,%ecx
  8018a1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8018a5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8018a9:	83 c0 01             	add    $0x1,%eax
  8018ac:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8018af:	83 c7 01             	add    $0x1,%edi
  8018b2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018b5:	75 c8                	jne    80187f <devpipe_write+0x2f>
	return i;
  8018b7:	89 f8                	mov    %edi,%eax
  8018b9:	eb 05                	jmp    8018c0 <devpipe_write+0x70>
				return 0;
  8018bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c0:	83 c4 1c             	add    $0x1c,%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5f                   	pop    %edi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <devpipe_read>:
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	57                   	push   %edi
  8018cc:	56                   	push   %esi
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 1c             	sub    $0x1c,%esp
  8018d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018d4:	89 3c 24             	mov    %edi,(%esp)
  8018d7:	e8 44 f6 ff ff       	call   800f20 <fd2data>
  8018dc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018de:	be 00 00 00 00       	mov    $0x0,%esi
  8018e3:	eb 3d                	jmp    801922 <devpipe_read+0x5a>
			if (i > 0)
  8018e5:	85 f6                	test   %esi,%esi
  8018e7:	74 04                	je     8018ed <devpipe_read+0x25>
				return i;
  8018e9:	89 f0                	mov    %esi,%eax
  8018eb:	eb 43                	jmp    801930 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  8018ed:	89 da                	mov    %ebx,%edx
  8018ef:	89 f8                	mov    %edi,%eax
  8018f1:	e8 f1 fe ff ff       	call   8017e7 <_pipeisclosed>
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	75 31                	jne    80192b <devpipe_read+0x63>
			sys_yield();
  8018fa:	e8 85 f3 ff ff       	call   800c84 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8018ff:	8b 03                	mov    (%ebx),%eax
  801901:	3b 43 04             	cmp    0x4(%ebx),%eax
  801904:	74 df                	je     8018e5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801906:	99                   	cltd   
  801907:	c1 ea 1b             	shr    $0x1b,%edx
  80190a:	01 d0                	add    %edx,%eax
  80190c:	83 e0 1f             	and    $0x1f,%eax
  80190f:	29 d0                	sub    %edx,%eax
  801911:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801916:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801919:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80191c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80191f:	83 c6 01             	add    $0x1,%esi
  801922:	3b 75 10             	cmp    0x10(%ebp),%esi
  801925:	75 d8                	jne    8018ff <devpipe_read+0x37>
	return i;
  801927:	89 f0                	mov    %esi,%eax
  801929:	eb 05                	jmp    801930 <devpipe_read+0x68>
				return 0;
  80192b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801930:	83 c4 1c             	add    $0x1c,%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	5f                   	pop    %edi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    

00801938 <pipe>:
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801940:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801943:	89 04 24             	mov    %eax,(%esp)
  801946:	e8 ec f5 ff ff       	call   800f37 <fd_alloc>
  80194b:	89 c2                	mov    %eax,%edx
  80194d:	85 d2                	test   %edx,%edx
  80194f:	0f 88 4d 01 00 00    	js     801aa2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801955:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80195c:	00 
  80195d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801960:	89 44 24 04          	mov    %eax,0x4(%esp)
  801964:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196b:	e8 33 f3 ff ff       	call   800ca3 <sys_page_alloc>
  801970:	89 c2                	mov    %eax,%edx
  801972:	85 d2                	test   %edx,%edx
  801974:	0f 88 28 01 00 00    	js     801aa2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  80197a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80197d:	89 04 24             	mov    %eax,(%esp)
  801980:	e8 b2 f5 ff ff       	call   800f37 <fd_alloc>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	85 c0                	test   %eax,%eax
  801989:	0f 88 fe 00 00 00    	js     801a8d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80198f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801996:	00 
  801997:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a5:	e8 f9 f2 ff ff       	call   800ca3 <sys_page_alloc>
  8019aa:	89 c3                	mov    %eax,%ebx
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	0f 88 d9 00 00 00    	js     801a8d <pipe+0x155>
	va = fd2data(fd0);
  8019b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b7:	89 04 24             	mov    %eax,(%esp)
  8019ba:	e8 61 f5 ff ff       	call   800f20 <fd2data>
  8019bf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019c8:	00 
  8019c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d4:	e8 ca f2 ff ff       	call   800ca3 <sys_page_alloc>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	0f 88 97 00 00 00    	js     801a7a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e6:	89 04 24             	mov    %eax,(%esp)
  8019e9:	e8 32 f5 ff ff       	call   800f20 <fd2data>
  8019ee:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019f5:	00 
  8019f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a01:	00 
  801a02:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0d:	e8 e5 f2 ff ff       	call   800cf7 <sys_page_map>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 52                	js     801a6a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801a18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801a2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a45:	89 04 24             	mov    %eax,(%esp)
  801a48:	e8 c3 f4 ff ff       	call   800f10 <fd2num>
  801a4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a55:	89 04 24             	mov    %eax,(%esp)
  801a58:	e8 b3 f4 ff ff       	call   800f10 <fd2num>
  801a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a63:	b8 00 00 00 00       	mov    $0x0,%eax
  801a68:	eb 38                	jmp    801aa2 <pipe+0x16a>
	sys_page_unmap(0, va);
  801a6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a75:	e8 d0 f2 ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a88:	e8 bd f2 ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9b:	e8 aa f2 ff ff       	call   800d4a <sys_page_unmap>
  801aa0:	89 d8                	mov    %ebx,%eax
}
  801aa2:	83 c4 30             	add    $0x30,%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <pipeisclosed>:
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	89 04 24             	mov    %eax,(%esp)
  801abc:	e8 c5 f4 ff ff       	call   800f86 <fd_lookup>
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	85 d2                	test   %edx,%edx
  801ac5:	78 15                	js     801adc <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aca:	89 04 24             	mov    %eax,(%esp)
  801acd:	e8 4e f4 ff ff       	call   800f20 <fd2data>
	return _pipeisclosed(fd, p);
  801ad2:	89 c2                	mov    %eax,%edx
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	e8 0b fd ff ff       	call   8017e7 <_pipeisclosed>
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    
  801ade:	66 90                	xchg   %ax,%ax

00801ae0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801af0:	c7 44 24 04 8c 25 80 	movl   $0x80258c,0x4(%esp)
  801af7:	00 
  801af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afb:	89 04 24             	mov    %eax,(%esp)
  801afe:	e8 84 ed ff ff       	call   800887 <strcpy>
	return 0;
}
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <devcons_write>:
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	57                   	push   %edi
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b16:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b21:	eb 31                	jmp    801b54 <devcons_write+0x4a>
		m = n - tot;
  801b23:	8b 75 10             	mov    0x10(%ebp),%esi
  801b26:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b28:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801b2b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b30:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b33:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b37:	03 45 0c             	add    0xc(%ebp),%eax
  801b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3e:	89 3c 24             	mov    %edi,(%esp)
  801b41:	e8 de ee ff ff       	call   800a24 <memmove>
		sys_cputs(buf, m);
  801b46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b4a:	89 3c 24             	mov    %edi,(%esp)
  801b4d:	e8 84 f0 ff ff       	call   800bd6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b52:	01 f3                	add    %esi,%ebx
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b59:	72 c8                	jb     801b23 <devcons_write+0x19>
}
  801b5b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <devcons_read>:
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b75:	75 07                	jne    801b7e <devcons_read+0x18>
  801b77:	eb 2a                	jmp    801ba3 <devcons_read+0x3d>
		sys_yield();
  801b79:	e8 06 f1 ff ff       	call   800c84 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801b7e:	66 90                	xchg   %ax,%ax
  801b80:	e8 6f f0 ff ff       	call   800bf4 <sys_cgetc>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	74 f0                	je     801b79 <devcons_read+0x13>
	if (c < 0)
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	78 16                	js     801ba3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801b8d:	83 f8 04             	cmp    $0x4,%eax
  801b90:	74 0c                	je     801b9e <devcons_read+0x38>
	*(char*)vbuf = c;
  801b92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b95:	88 02                	mov    %al,(%edx)
	return 1;
  801b97:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9c:	eb 05                	jmp    801ba3 <devcons_read+0x3d>
		return 0;
  801b9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <cputchar>:
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801bb1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bb8:	00 
  801bb9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 12 f0 ff ff       	call   800bd6 <sys_cputs>
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <getchar>:
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801bcc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801bd3:	00 
  801bd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be2:	e8 2e f6 ff ff       	call   801215 <read>
	if (r < 0)
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 0f                	js     801bfa <getchar+0x34>
	if (r < 1)
  801beb:	85 c0                	test   %eax,%eax
  801bed:	7e 06                	jle    801bf5 <getchar+0x2f>
	return c;
  801bef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bf3:	eb 05                	jmp    801bfa <getchar+0x34>
		return -E_EOF;
  801bf5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <iscons>:
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0c:	89 04 24             	mov    %eax,(%esp)
  801c0f:	e8 72 f3 ff ff       	call   800f86 <fd_lookup>
  801c14:	85 c0                	test   %eax,%eax
  801c16:	78 11                	js     801c29 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c21:	39 10                	cmp    %edx,(%eax)
  801c23:	0f 94 c0             	sete   %al
  801c26:	0f b6 c0             	movzbl %al,%eax
}
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <opencons>:
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c34:	89 04 24             	mov    %eax,(%esp)
  801c37:	e8 fb f2 ff ff       	call   800f37 <fd_alloc>
		return r;
  801c3c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 40                	js     801c82 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c42:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c49:	00 
  801c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c58:	e8 46 f0 ff ff       	call   800ca3 <sys_page_alloc>
		return r;
  801c5d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 1f                	js     801c82 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801c63:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c71:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c78:	89 04 24             	mov    %eax,(%esp)
  801c7b:	e8 90 f2 ff ff       	call   800f10 <fd2num>
  801c80:	89 c2                	mov    %eax,%edx
}
  801c82:	89 d0                	mov    %edx,%eax
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	83 ec 10             	sub    $0x10,%esp
  801c98:	8b 75 08             	mov    0x8(%ebp),%esi
  801c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801ca1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801ca3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ca8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801cab:	89 04 24             	mov    %eax,(%esp)
  801cae:	e8 06 f2 ff ff       	call   800eb9 <sys_ipc_recv>
    if(r < 0){
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	79 16                	jns    801ccd <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801cb7:	85 f6                	test   %esi,%esi
  801cb9:	74 06                	je     801cc1 <ipc_recv+0x31>
            *from_env_store = 0;
  801cbb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801cc1:	85 db                	test   %ebx,%ebx
  801cc3:	74 2c                	je     801cf1 <ipc_recv+0x61>
            *perm_store = 0;
  801cc5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ccb:	eb 24                	jmp    801cf1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801ccd:	85 f6                	test   %esi,%esi
  801ccf:	74 0a                	je     801cdb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801cd1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801cd6:	8b 40 74             	mov    0x74(%eax),%eax
  801cd9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801cdb:	85 db                	test   %ebx,%ebx
  801cdd:	74 0a                	je     801ce9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801cdf:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ce4:	8b 40 78             	mov    0x78(%eax),%eax
  801ce7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ce9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801cee:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	57                   	push   %edi
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 1c             	sub    $0x1c,%esp
  801d01:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801d0a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801d0c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801d11:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801d14:	8b 45 14             	mov    0x14(%ebp),%eax
  801d17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	e8 6b f1 ff ff       	call   800e96 <sys_ipc_try_send>
        if(r == 0){
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	74 28                	je     801d57 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801d2f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d32:	74 1c                	je     801d50 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801d34:	c7 44 24 08 98 25 80 	movl   $0x802598,0x8(%esp)
  801d3b:	00 
  801d3c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801d43:	00 
  801d44:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  801d4b:	e8 0f e4 ff ff       	call   80015f <_panic>
        }
        sys_yield();
  801d50:	e8 2f ef ff ff       	call   800c84 <sys_yield>
    }
  801d55:	eb bd                	jmp    801d14 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801d57:	83 c4 1c             	add    $0x1c,%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d65:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d6a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d6d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d73:	8b 52 50             	mov    0x50(%edx),%edx
  801d76:	39 ca                	cmp    %ecx,%edx
  801d78:	75 0d                	jne    801d87 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d7a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d7d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d82:	8b 40 40             	mov    0x40(%eax),%eax
  801d85:	eb 0e                	jmp    801d95 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801d87:	83 c0 01             	add    $0x1,%eax
  801d8a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d8f:	75 d9                	jne    801d6a <ipc_find_env+0xb>
	return 0;
  801d91:	66 b8 00 00          	mov    $0x0,%ax
}
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d9d:	89 d0                	mov    %edx,%eax
  801d9f:	c1 e8 16             	shr    $0x16,%eax
  801da2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801dae:	f6 c1 01             	test   $0x1,%cl
  801db1:	74 1d                	je     801dd0 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801db3:	c1 ea 0c             	shr    $0xc,%edx
  801db6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dbd:	f6 c2 01             	test   $0x1,%dl
  801dc0:	74 0e                	je     801dd0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dc2:	c1 ea 0c             	shr    $0xc,%edx
  801dc5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dcc:	ef 
  801dcd:	0f b7 c0             	movzwl %ax,%eax
}
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    
  801dd2:	66 90                	xchg   %ax,%ax
  801dd4:	66 90                	xchg   %ax,%ax
  801dd6:	66 90                	xchg   %ax,%ax
  801dd8:	66 90                	xchg   %ax,%ax
  801dda:	66 90                	xchg   %ax,%ax
  801ddc:	66 90                	xchg   %ax,%ax
  801dde:	66 90                	xchg   %ax,%ax

00801de0 <__udivdi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801dea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801dee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801df2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801df6:	85 c0                	test   %eax,%eax
  801df8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dfc:	89 ea                	mov    %ebp,%edx
  801dfe:	89 0c 24             	mov    %ecx,(%esp)
  801e01:	75 2d                	jne    801e30 <__udivdi3+0x50>
  801e03:	39 e9                	cmp    %ebp,%ecx
  801e05:	77 61                	ja     801e68 <__udivdi3+0x88>
  801e07:	85 c9                	test   %ecx,%ecx
  801e09:	89 ce                	mov    %ecx,%esi
  801e0b:	75 0b                	jne    801e18 <__udivdi3+0x38>
  801e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e12:	31 d2                	xor    %edx,%edx
  801e14:	f7 f1                	div    %ecx
  801e16:	89 c6                	mov    %eax,%esi
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	89 e8                	mov    %ebp,%eax
  801e1c:	f7 f6                	div    %esi
  801e1e:	89 c5                	mov    %eax,%ebp
  801e20:	89 f8                	mov    %edi,%eax
  801e22:	f7 f6                	div    %esi
  801e24:	89 ea                	mov    %ebp,%edx
  801e26:	83 c4 0c             	add    $0xc,%esp
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	39 e8                	cmp    %ebp,%eax
  801e32:	77 24                	ja     801e58 <__udivdi3+0x78>
  801e34:	0f bd e8             	bsr    %eax,%ebp
  801e37:	83 f5 1f             	xor    $0x1f,%ebp
  801e3a:	75 3c                	jne    801e78 <__udivdi3+0x98>
  801e3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e40:	39 34 24             	cmp    %esi,(%esp)
  801e43:	0f 86 9f 00 00 00    	jbe    801ee8 <__udivdi3+0x108>
  801e49:	39 d0                	cmp    %edx,%eax
  801e4b:	0f 82 97 00 00 00    	jb     801ee8 <__udivdi3+0x108>
  801e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e58:	31 d2                	xor    %edx,%edx
  801e5a:	31 c0                	xor    %eax,%eax
  801e5c:	83 c4 0c             	add    $0xc,%esp
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    
  801e63:	90                   	nop
  801e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e68:	89 f8                	mov    %edi,%eax
  801e6a:	f7 f1                	div    %ecx
  801e6c:	31 d2                	xor    %edx,%edx
  801e6e:	83 c4 0c             	add    $0xc,%esp
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	8b 3c 24             	mov    (%esp),%edi
  801e7d:	d3 e0                	shl    %cl,%eax
  801e7f:	89 c6                	mov    %eax,%esi
  801e81:	b8 20 00 00 00       	mov    $0x20,%eax
  801e86:	29 e8                	sub    %ebp,%eax
  801e88:	89 c1                	mov    %eax,%ecx
  801e8a:	d3 ef                	shr    %cl,%edi
  801e8c:	89 e9                	mov    %ebp,%ecx
  801e8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e92:	8b 3c 24             	mov    (%esp),%edi
  801e95:	09 74 24 08          	or     %esi,0x8(%esp)
  801e99:	89 d6                	mov    %edx,%esi
  801e9b:	d3 e7                	shl    %cl,%edi
  801e9d:	89 c1                	mov    %eax,%ecx
  801e9f:	89 3c 24             	mov    %edi,(%esp)
  801ea2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ea6:	d3 ee                	shr    %cl,%esi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	d3 e2                	shl    %cl,%edx
  801eac:	89 c1                	mov    %eax,%ecx
  801eae:	d3 ef                	shr    %cl,%edi
  801eb0:	09 d7                	or     %edx,%edi
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	89 f8                	mov    %edi,%eax
  801eb6:	f7 74 24 08          	divl   0x8(%esp)
  801eba:	89 d6                	mov    %edx,%esi
  801ebc:	89 c7                	mov    %eax,%edi
  801ebe:	f7 24 24             	mull   (%esp)
  801ec1:	39 d6                	cmp    %edx,%esi
  801ec3:	89 14 24             	mov    %edx,(%esp)
  801ec6:	72 30                	jb     801ef8 <__udivdi3+0x118>
  801ec8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ecc:	89 e9                	mov    %ebp,%ecx
  801ece:	d3 e2                	shl    %cl,%edx
  801ed0:	39 c2                	cmp    %eax,%edx
  801ed2:	73 05                	jae    801ed9 <__udivdi3+0xf9>
  801ed4:	3b 34 24             	cmp    (%esp),%esi
  801ed7:	74 1f                	je     801ef8 <__udivdi3+0x118>
  801ed9:	89 f8                	mov    %edi,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	e9 7a ff ff ff       	jmp    801e5c <__udivdi3+0x7c>
  801ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee8:	31 d2                	xor    %edx,%edx
  801eea:	b8 01 00 00 00       	mov    $0x1,%eax
  801eef:	e9 68 ff ff ff       	jmp    801e5c <__udivdi3+0x7c>
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	83 c4 0c             	add    $0xc,%esp
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    
  801f04:	66 90                	xchg   %ax,%ax
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	66 90                	xchg   %ax,%ax
  801f0a:	66 90                	xchg   %ax,%ax
  801f0c:	66 90                	xchg   %ax,%ax
  801f0e:	66 90                	xchg   %ax,%ax

00801f10 <__umoddi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	83 ec 14             	sub    $0x14,%esp
  801f16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f22:	89 c7                	mov    %eax,%edi
  801f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f28:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f30:	89 34 24             	mov    %esi,(%esp)
  801f33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	89 c2                	mov    %eax,%edx
  801f3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f3f:	75 17                	jne    801f58 <__umoddi3+0x48>
  801f41:	39 fe                	cmp    %edi,%esi
  801f43:	76 4b                	jbe    801f90 <__umoddi3+0x80>
  801f45:	89 c8                	mov    %ecx,%eax
  801f47:	89 fa                	mov    %edi,%edx
  801f49:	f7 f6                	div    %esi
  801f4b:	89 d0                	mov    %edx,%eax
  801f4d:	31 d2                	xor    %edx,%edx
  801f4f:	83 c4 14             	add    $0x14,%esp
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	39 f8                	cmp    %edi,%eax
  801f5a:	77 54                	ja     801fb0 <__umoddi3+0xa0>
  801f5c:	0f bd e8             	bsr    %eax,%ebp
  801f5f:	83 f5 1f             	xor    $0x1f,%ebp
  801f62:	75 5c                	jne    801fc0 <__umoddi3+0xb0>
  801f64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f68:	39 3c 24             	cmp    %edi,(%esp)
  801f6b:	0f 87 e7 00 00 00    	ja     802058 <__umoddi3+0x148>
  801f71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f75:	29 f1                	sub    %esi,%ecx
  801f77:	19 c7                	sbb    %eax,%edi
  801f79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f81:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f89:	83 c4 14             	add    $0x14,%esp
  801f8c:	5e                   	pop    %esi
  801f8d:	5f                   	pop    %edi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    
  801f90:	85 f6                	test   %esi,%esi
  801f92:	89 f5                	mov    %esi,%ebp
  801f94:	75 0b                	jne    801fa1 <__umoddi3+0x91>
  801f96:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	f7 f6                	div    %esi
  801f9f:	89 c5                	mov    %eax,%ebp
  801fa1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fa5:	31 d2                	xor    %edx,%edx
  801fa7:	f7 f5                	div    %ebp
  801fa9:	89 c8                	mov    %ecx,%eax
  801fab:	f7 f5                	div    %ebp
  801fad:	eb 9c                	jmp    801f4b <__umoddi3+0x3b>
  801faf:	90                   	nop
  801fb0:	89 c8                	mov    %ecx,%eax
  801fb2:	89 fa                	mov    %edi,%edx
  801fb4:	83 c4 14             	add    $0x14,%esp
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    
  801fbb:	90                   	nop
  801fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	8b 04 24             	mov    (%esp),%eax
  801fc3:	be 20 00 00 00       	mov    $0x20,%esi
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	29 ee                	sub    %ebp,%esi
  801fcc:	d3 e2                	shl    %cl,%edx
  801fce:	89 f1                	mov    %esi,%ecx
  801fd0:	d3 e8                	shr    %cl,%eax
  801fd2:	89 e9                	mov    %ebp,%ecx
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	8b 04 24             	mov    (%esp),%eax
  801fdb:	09 54 24 04          	or     %edx,0x4(%esp)
  801fdf:	89 fa                	mov    %edi,%edx
  801fe1:	d3 e0                	shl    %cl,%eax
  801fe3:	89 f1                	mov    %esi,%ecx
  801fe5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fed:	d3 ea                	shr    %cl,%edx
  801fef:	89 e9                	mov    %ebp,%ecx
  801ff1:	d3 e7                	shl    %cl,%edi
  801ff3:	89 f1                	mov    %esi,%ecx
  801ff5:	d3 e8                	shr    %cl,%eax
  801ff7:	89 e9                	mov    %ebp,%ecx
  801ff9:	09 f8                	or     %edi,%eax
  801ffb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801fff:	f7 74 24 04          	divl   0x4(%esp)
  802003:	d3 e7                	shl    %cl,%edi
  802005:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802009:	89 d7                	mov    %edx,%edi
  80200b:	f7 64 24 08          	mull   0x8(%esp)
  80200f:	39 d7                	cmp    %edx,%edi
  802011:	89 c1                	mov    %eax,%ecx
  802013:	89 14 24             	mov    %edx,(%esp)
  802016:	72 2c                	jb     802044 <__umoddi3+0x134>
  802018:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80201c:	72 22                	jb     802040 <__umoddi3+0x130>
  80201e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802022:	29 c8                	sub    %ecx,%eax
  802024:	19 d7                	sbb    %edx,%edi
  802026:	89 e9                	mov    %ebp,%ecx
  802028:	89 fa                	mov    %edi,%edx
  80202a:	d3 e8                	shr    %cl,%eax
  80202c:	89 f1                	mov    %esi,%ecx
  80202e:	d3 e2                	shl    %cl,%edx
  802030:	89 e9                	mov    %ebp,%ecx
  802032:	d3 ef                	shr    %cl,%edi
  802034:	09 d0                	or     %edx,%eax
  802036:	89 fa                	mov    %edi,%edx
  802038:	83 c4 14             	add    $0x14,%esp
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    
  80203f:	90                   	nop
  802040:	39 d7                	cmp    %edx,%edi
  802042:	75 da                	jne    80201e <__umoddi3+0x10e>
  802044:	8b 14 24             	mov    (%esp),%edx
  802047:	89 c1                	mov    %eax,%ecx
  802049:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80204d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802051:	eb cb                	jmp    80201e <__umoddi3+0x10e>
  802053:	90                   	nop
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80205c:	0f 82 0f ff ff ff    	jb     801f71 <__umoddi3+0x61>
  802062:	e9 1a ff ff ff       	jmp    801f81 <__umoddi3+0x71>
