
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800043:	c7 04 24 00 21 80 00 	movl   $0x802100,(%esp)
  80004a:	e8 eb 01 00 00       	call   80023a <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 15 0c 00 00       	call   800c83 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 20 21 80 	movl   $0x802120,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 0a 21 80 00 	movl   $0x80210a,(%esp)
  800091:	e8 ab 00 00 00       	call   800141 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 4c 21 80 	movl   $0x80214c,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 53 07 00 00       	call   800805 <snprintf>
}
  8000b2:	83 c4 24             	add    $0x24,%esp
  8000b5:	5b                   	pop    %ebx
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <umain>:

void
umain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000be:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000c5:	e8 21 0e 00 00       	call   800eeb <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000ca:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000d9:	e8 d8 0a 00 00       	call   800bb6 <sys_cputs>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 10             	sub    $0x10,%esp
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8000ee:	e8 52 0b 00 00       	call   800c45 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x30>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	89 74 24 04          	mov    %esi,0x4(%esp)
  800114:	89 1c 24             	mov    %ebx,(%esp)
  800117:	e8 9c ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  80011c:	e8 07 00 00 00       	call   800128 <exit>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80012e:	e8 42 10 00 00       	call   801175 <close_all>
	sys_env_destroy(0);
  800133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013a:	e8 b4 0a 00 00       	call   800bf3 <sys_env_destroy>
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800152:	e8 ee 0a 00 00       	call   800c45 <sys_getenvid>
  800157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80015e:	8b 55 08             	mov    0x8(%ebp),%edx
  800161:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800165:	89 74 24 08          	mov    %esi,0x8(%esp)
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	c7 04 24 78 21 80 00 	movl   $0x802178,(%esp)
  800174:	e8 c1 00 00 00       	call   80023a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800179:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 51 00 00 00       	call   8001d9 <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 31 26 80 00 	movl   $0x802631,(%esp)
  80018f:	e8 a6 00 00 00       	call   80023a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800194:	cc                   	int3   
  800195:	eb fd                	jmp    800194 <_panic+0x53>

00800197 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	83 ec 14             	sub    $0x14,%esp
  80019e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a1:	8b 13                	mov    (%ebx),%edx
  8001a3:	8d 42 01             	lea    0x1(%edx),%eax
  8001a6:	89 03                	mov    %eax,(%ebx)
  8001a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b4:	75 19                	jne    8001cf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001bd:	00 
  8001be:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c1:	89 04 24             	mov    %eax,(%esp)
  8001c4:	e8 ed 09 00 00       	call   800bb6 <sys_cputs>
		b->idx = 0;
  8001c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	83 c4 14             	add    $0x14,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e9:	00 00 00 
	b.cnt = 0;
  8001ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	89 44 24 08          	mov    %eax,0x8(%esp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020e:	c7 04 24 97 01 80 00 	movl   $0x800197,(%esp)
  800215:	e8 b4 01 00 00       	call   8003ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	e8 84 09 00 00       	call   800bb6 <sys_cputs>

	return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800240:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 87 ff ff ff       	call   8001d9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    
  800254:	66 90                	xchg   %ax,%ax
  800256:	66 90                	xchg   %ax,%ax
  800258:	66 90                	xchg   %ax,%ax
  80025a:	66 90                	xchg   %ax,%ax
  80025c:	66 90                	xchg   %ax,%ax
  80025e:	66 90                	xchg   %ax,%ax

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 c3                	mov    %eax,%ebx
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	8b 45 10             	mov    0x10(%ebp),%eax
  80027f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
  800287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028d:	39 d9                	cmp    %ebx,%ecx
  80028f:	72 05                	jb     800296 <printnum+0x36>
  800291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800294:	77 69                	ja     8002ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800296:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800299:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029d:	83 ee 01             	sub    $0x1,%esi
  8002a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b0:	89 c3                	mov    %eax,%ebx
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	e8 9c 1b 00 00       	call   801e70 <__udivdi3>
  8002d4:	89 d9                	mov    %ebx,%ecx
  8002d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 71 ff ff ff       	call   800260 <printnum>
  8002ef:	eb 1b                	jmp    80030c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	ff d3                	call   *%ebx
  8002fd:	eb 03                	jmp    800302 <printnum+0xa2>
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800302:	83 ee 01             	sub    $0x1,%esi
  800305:	85 f6                	test   %esi,%esi
  800307:	7f e8                	jg     8002f1 <printnum+0x91>
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800317:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80031a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 6c 1c 00 00       	call   801fa0 <__umoddi3>
  800334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800338:	0f be 80 9b 21 80 00 	movsbl 0x80219b(%eax),%eax
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800345:	ff d0                	call   *%eax
}
  800347:	83 c4 3c             	add    $0x3c,%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 02 00 00 00       	call   8003ce <vprintfmt>
}
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 3c             	sub    $0x3c,%esp
  8003d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003dd:	eb 1f                	jmp    8003fe <vprintfmt+0x30>
			if (ch == '\0'){
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	75 0f                	jne    8003f2 <vprintfmt+0x24>
				color = 0x0100;
  8003e3:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  8003ea:	01 00 00 
  8003ed:	e9 b3 03 00 00       	jmp    8007a5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8003f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f6:	89 04 24             	mov    %eax,(%esp)
  8003f9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003fc:	89 f3                	mov    %esi,%ebx
  8003fe:	8d 73 01             	lea    0x1(%ebx),%esi
  800401:	0f b6 03             	movzbl (%ebx),%eax
  800404:	83 f8 25             	cmp    $0x25,%eax
  800407:	75 d6                	jne    8003df <vprintfmt+0x11>
  800409:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80040d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800414:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80041b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800422:	ba 00 00 00 00       	mov    $0x0,%edx
  800427:	eb 1d                	jmp    800446 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800429:	89 de                	mov    %ebx,%esi
			padc = '-';
  80042b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80042f:	eb 15                	jmp    800446 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800431:	89 de                	mov    %ebx,%esi
			padc = '0';
  800433:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800437:	eb 0d                	jmp    800446 <vprintfmt+0x78>
				width = precision, precision = -1;
  800439:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80043c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80043f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8d 5e 01             	lea    0x1(%esi),%ebx
  800449:	0f b6 0e             	movzbl (%esi),%ecx
  80044c:	0f b6 c1             	movzbl %cl,%eax
  80044f:	83 e9 23             	sub    $0x23,%ecx
  800452:	80 f9 55             	cmp    $0x55,%cl
  800455:	0f 87 2a 03 00 00    	ja     800785 <vprintfmt+0x3b7>
  80045b:	0f b6 c9             	movzbl %cl,%ecx
  80045e:	ff 24 8d e0 22 80 00 	jmp    *0x8022e0(,%ecx,4)
  800465:	89 de                	mov    %ebx,%esi
  800467:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80046c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80046f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800473:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800476:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800479:	83 fb 09             	cmp    $0x9,%ebx
  80047c:	77 36                	ja     8004b4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80047e:	83 c6 01             	add    $0x1,%esi
			}
  800481:	eb e9                	jmp    80046c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 48 04             	lea    0x4(%eax),%ecx
  800489:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80048c:	8b 00                	mov    (%eax),%eax
  80048e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800491:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800493:	eb 22                	jmp    8004b7 <vprintfmt+0xe9>
  800495:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800498:	85 c9                	test   %ecx,%ecx
  80049a:	b8 00 00 00 00       	mov    $0x0,%eax
  80049f:	0f 49 c1             	cmovns %ecx,%eax
  8004a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	89 de                	mov    %ebx,%esi
  8004a7:	eb 9d                	jmp    800446 <vprintfmt+0x78>
  8004a9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004ab:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004b2:	eb 92                	jmp    800446 <vprintfmt+0x78>
  8004b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8004b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004bb:	79 89                	jns    800446 <vprintfmt+0x78>
  8004bd:	e9 77 ff ff ff       	jmp    800439 <vprintfmt+0x6b>
			lflag++;
  8004c2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004c7:	e9 7a ff ff ff       	jmp    800446 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d9:	8b 00                	mov    (%eax),%eax
  8004db:	89 04 24             	mov    %eax,(%esp)
  8004de:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004e1:	e9 18 ff ff ff       	jmp    8003fe <vprintfmt+0x30>
			err = va_arg(ap, int);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	99                   	cltd   
  8004f2:	31 d0                	xor    %edx,%eax
  8004f4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f6:	83 f8 0f             	cmp    $0xf,%eax
  8004f9:	7f 0b                	jg     800506 <vprintfmt+0x138>
  8004fb:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800502:	85 d2                	test   %edx,%edx
  800504:	75 20                	jne    800526 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800506:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050a:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  800511:	00 
  800512:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	e8 85 fe ff ff       	call   8003a6 <printfmt>
  800521:	e9 d8 fe ff ff       	jmp    8003fe <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800526:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80052a:	c7 44 24 08 0a 26 80 	movl   $0x80260a,0x8(%esp)
  800531:	00 
  800532:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800536:	8b 45 08             	mov    0x8(%ebp),%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	e8 65 fe ff ff       	call   8003a6 <printfmt>
  800541:	e9 b8 fe ff ff       	jmp    8003fe <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800549:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80055a:	85 f6                	test   %esi,%esi
  80055c:	b8 ac 21 80 00       	mov    $0x8021ac,%eax
  800561:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800564:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800568:	0f 84 97 00 00 00    	je     800605 <vprintfmt+0x237>
  80056e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800572:	0f 8e 9b 00 00 00    	jle    800613 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80057c:	89 34 24             	mov    %esi,(%esp)
  80057f:	e8 c4 02 00 00       	call   800848 <strnlen>
  800584:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800587:	29 c2                	sub    %eax,%edx
  800589:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80058c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800590:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800593:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800596:	8b 75 08             	mov    0x8(%ebp),%esi
  800599:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80059c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80059e:	eb 0f                	jmp    8005af <vprintfmt+0x1e1>
					putch(padc, putdat);
  8005a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a7:	89 04 24             	mov    %eax,(%esp)
  8005aa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	83 eb 01             	sub    $0x1,%ebx
  8005af:	85 db                	test   %ebx,%ebx
  8005b1:	7f ed                	jg     8005a0 <vprintfmt+0x1d2>
  8005b3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005b6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005b9:	85 d2                	test   %edx,%edx
  8005bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c0:	0f 49 c2             	cmovns %edx,%eax
  8005c3:	29 c2                	sub    %eax,%edx
  8005c5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005c8:	89 d7                	mov    %edx,%edi
  8005ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005cd:	eb 50                	jmp    80061f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d3:	74 1e                	je     8005f3 <vprintfmt+0x225>
  8005d5:	0f be d2             	movsbl %dl,%edx
  8005d8:	83 ea 20             	sub    $0x20,%edx
  8005db:	83 fa 5e             	cmp    $0x5e,%edx
  8005de:	76 13                	jbe    8005f3 <vprintfmt+0x225>
					putch('?', putdat);
  8005e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ee:	ff 55 08             	call   *0x8(%ebp)
  8005f1:	eb 0d                	jmp    800600 <vprintfmt+0x232>
					putch(ch, putdat);
  8005f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800600:	83 ef 01             	sub    $0x1,%edi
  800603:	eb 1a                	jmp    80061f <vprintfmt+0x251>
  800605:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800608:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80060b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80060e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800611:	eb 0c                	jmp    80061f <vprintfmt+0x251>
  800613:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800616:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800619:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80061c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80061f:	83 c6 01             	add    $0x1,%esi
  800622:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800626:	0f be c2             	movsbl %dl,%eax
  800629:	85 c0                	test   %eax,%eax
  80062b:	74 27                	je     800654 <vprintfmt+0x286>
  80062d:	85 db                	test   %ebx,%ebx
  80062f:	78 9e                	js     8005cf <vprintfmt+0x201>
  800631:	83 eb 01             	sub    $0x1,%ebx
  800634:	79 99                	jns    8005cf <vprintfmt+0x201>
  800636:	89 f8                	mov    %edi,%eax
  800638:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80063b:	8b 75 08             	mov    0x8(%ebp),%esi
  80063e:	89 c3                	mov    %eax,%ebx
  800640:	eb 1a                	jmp    80065c <vprintfmt+0x28e>
				putch(' ', putdat);
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80064d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80064f:	83 eb 01             	sub    $0x1,%ebx
  800652:	eb 08                	jmp    80065c <vprintfmt+0x28e>
  800654:	89 fb                	mov    %edi,%ebx
  800656:	8b 75 08             	mov    0x8(%ebp),%esi
  800659:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80065c:	85 db                	test   %ebx,%ebx
  80065e:	7f e2                	jg     800642 <vprintfmt+0x274>
  800660:	89 75 08             	mov    %esi,0x8(%ebp)
  800663:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800666:	e9 93 fd ff ff       	jmp    8003fe <vprintfmt+0x30>
	if (lflag >= 2)
  80066b:	83 fa 01             	cmp    $0x1,%edx
  80066e:	7e 16                	jle    800686 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 08             	lea    0x8(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)
  800679:	8b 50 04             	mov    0x4(%eax),%edx
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800681:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800684:	eb 32                	jmp    8006b8 <vprintfmt+0x2ea>
	else if (lflag)
  800686:	85 d2                	test   %edx,%edx
  800688:	74 18                	je     8006a2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 30                	mov    (%eax),%esi
  800695:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800698:	89 f0                	mov    %esi,%eax
  80069a:	c1 f8 1f             	sar    $0x1f,%eax
  80069d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a0:	eb 16                	jmp    8006b8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 30                	mov    (%eax),%esi
  8006ad:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006b0:	89 f0                	mov    %esi,%eax
  8006b2:	c1 f8 1f             	sar    $0x1f,%eax
  8006b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8006b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8006be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c7:	0f 89 80 00 00 00    	jns    80074d <vprintfmt+0x37f>
				putch('-', putdat);
  8006cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e1:	f7 d8                	neg    %eax
  8006e3:	83 d2 00             	adc    $0x0,%edx
  8006e6:	f7 da                	neg    %edx
			base = 10;
  8006e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ed:	eb 5e                	jmp    80074d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f2:	e8 58 fc ff ff       	call   80034f <getuint>
			base = 10;
  8006f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006fc:	eb 4f                	jmp    80074d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800701:	e8 49 fc ff ff       	call   80034f <getuint>
            base = 8;
  800706:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80070b:	eb 40                	jmp    80074d <vprintfmt+0x37f>
			putch('0', putdat);
  80070d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800711:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800718:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80071b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800726:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8d 50 04             	lea    0x4(%eax),%edx
  80072f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800732:	8b 00                	mov    (%eax),%eax
  800734:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800739:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80073e:	eb 0d                	jmp    80074d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
  800743:	e8 07 fc ff ff       	call   80034f <getuint>
			base = 16;
  800748:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80074d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800751:	89 74 24 10          	mov    %esi,0x10(%esp)
  800755:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800758:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80075c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	89 54 24 04          	mov    %edx,0x4(%esp)
  800767:	89 fa                	mov    %edi,%edx
  800769:	8b 45 08             	mov    0x8(%ebp),%eax
  80076c:	e8 ef fa ff ff       	call   800260 <printnum>
			break;
  800771:	e9 88 fc ff ff       	jmp    8003fe <vprintfmt+0x30>
			putch(ch, putdat);
  800776:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800780:	e9 79 fc ff ff       	jmp    8003fe <vprintfmt+0x30>
			putch('%', putdat);
  800785:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800789:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800790:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800793:	89 f3                	mov    %esi,%ebx
  800795:	eb 03                	jmp    80079a <vprintfmt+0x3cc>
  800797:	83 eb 01             	sub    $0x1,%ebx
  80079a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80079e:	75 f7                	jne    800797 <vprintfmt+0x3c9>
  8007a0:	e9 59 fc ff ff       	jmp    8003fe <vprintfmt+0x30>
}
  8007a5:	83 c4 3c             	add    $0x3c,%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5f                   	pop    %edi
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 28             	sub    $0x28,%esp
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	74 30                	je     8007fe <vsnprintf+0x51>
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	7e 2c                	jle    8007fe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e7:	c7 04 24 89 03 80 00 	movl   $0x800389,(%esp)
  8007ee:	e8 db fb ff ff       	call   8003ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fc:	eb 05                	jmp    800803 <vsnprintf+0x56>
		return -E_INVAL;
  8007fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800812:	8b 45 10             	mov    0x10(%ebp),%eax
  800815:	89 44 24 08          	mov    %eax,0x8(%esp)
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	89 04 24             	mov    %eax,(%esp)
  800826:	e8 82 ff ff ff       	call   8007ad <vsnprintf>
	va_end(ap);

	return rc;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    
  80082d:	66 90                	xchg   %ax,%ax
  80082f:	90                   	nop

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 03                	jmp    800840 <strlen+0x10>
		n++;
  80083d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800844:	75 f7                	jne    80083d <strlen+0xd>
	return n;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 03                	jmp    80085b <strnlen+0x13>
		n++;
  800858:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 06                	je     800865 <strnlen+0x1d>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f3                	jne    800858 <strnlen+0x10>
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	89 c2                	mov    %eax,%edx
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	84 db                	test   %bl,%bl
  800882:	75 ef                	jne    800873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800891:	89 1c 24             	mov    %ebx,(%esp)
  800894:	e8 97 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a0:	01 d8                	add    %ebx,%eax
  8008a2:	89 04 24             	mov    %eax,(%esp)
  8008a5:	e8 bd ff ff ff       	call   800867 <strcpy>
	return dst;
}
  8008aa:	89 d8                	mov    %ebx,%eax
  8008ac:	83 c4 08             	add    $0x8,%esp
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	eb 0f                	jmp    8008d5 <strncpy+0x23>
		*dst++ = *src;
  8008c6:	83 c2 01             	add    $0x1,%edx
  8008c9:	0f b6 01             	movzbl (%ecx),%eax
  8008cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008d5:	39 da                	cmp    %ebx,%edx
  8008d7:	75 ed                	jne    8008c6 <strncpy+0x14>
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	75 0b                	jne    800902 <strlcpy+0x23>
  8008f7:	eb 1d                	jmp    800916 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 0b                	je     800911 <strlcpy+0x32>
  800906:	0f b6 0a             	movzbl (%edx),%ecx
  800909:	84 c9                	test   %cl,%cl
  80090b:	75 ec                	jne    8008f9 <strlcpy+0x1a>
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	eb 02                	jmp    800913 <strlcpy+0x34>
  800911:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800913:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800916:	29 f0                	sub    %esi,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800925:	eb 06                	jmp    80092d <strcmp+0x11>
		p++, q++;
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80092d:	0f b6 01             	movzbl (%ecx),%eax
  800930:	84 c0                	test   %al,%al
  800932:	74 04                	je     800938 <strcmp+0x1c>
  800934:	3a 02                	cmp    (%edx),%al
  800936:	74 ef                	je     800927 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 c0             	movzbl %al,%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 c3                	mov    %eax,%ebx
  80094e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800951:	eb 06                	jmp    800959 <strncmp+0x17>
		n--, p++, q++;
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800959:	39 d8                	cmp    %ebx,%eax
  80095b:	74 15                	je     800972 <strncmp+0x30>
  80095d:	0f b6 08             	movzbl (%eax),%ecx
  800960:	84 c9                	test   %cl,%cl
  800962:	74 04                	je     800968 <strncmp+0x26>
  800964:	3a 0a                	cmp    (%edx),%cl
  800966:	74 eb                	je     800953 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
  800970:	eb 05                	jmp    800977 <strncmp+0x35>
		return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800984:	eb 07                	jmp    80098d <strchr+0x13>
		if (*s == c)
  800986:	38 ca                	cmp    %cl,%dl
  800988:	74 0f                	je     800999 <strchr+0x1f>
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 f2                	jne    800986 <strchr+0xc>
			return (char *) s;
	return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	eb 07                	jmp    8009ae <strfind+0x13>
		if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 0a                	je     8009b5 <strfind+0x1a>
	for (; *s; s++)
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	84 d2                	test   %dl,%dl
  8009b3:	75 f2                	jne    8009a7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	74 36                	je     8009fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cd:	75 28                	jne    8009f7 <memset+0x40>
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 23                	jne    8009f7 <memset+0x40>
		c &= 0xFF;
  8009d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d8:	89 d3                	mov    %edx,%ebx
  8009da:	c1 e3 08             	shl    $0x8,%ebx
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	c1 e6 18             	shl    $0x18,%esi
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	c1 e0 10             	shl    $0x10,%eax
  8009e7:	09 f0                	or     %esi,%eax
  8009e9:	09 c2                	or     %eax,%edx
  8009eb:	89 d0                	mov    %edx,%eax
  8009ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009f2:	fc                   	cld    
  8009f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f5:	eb 06                	jmp    8009fd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	fc                   	cld    
  8009fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fd:	89 f8                	mov    %edi,%eax
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a12:	39 c6                	cmp    %eax,%esi
  800a14:	73 35                	jae    800a4b <memmove+0x47>
  800a16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	73 2e                	jae    800a4b <memmove+0x47>
		s += n;
		d += n;
  800a1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2a:	75 13                	jne    800a3f <memmove+0x3b>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 0e                	jne    800a3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a31:	83 ef 04             	sub    $0x4,%edi
  800a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a37:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 09                	jmp    800a48 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	83 ef 01             	sub    $0x1,%edi
  800a42:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a45:	fd                   	std    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a48:	fc                   	cld    
  800a49:	eb 1d                	jmp    800a68 <memmove+0x64>
  800a4b:	89 f2                	mov    %esi,%edx
  800a4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	f6 c2 03             	test   $0x3,%dl
  800a52:	75 0f                	jne    800a63 <memmove+0x5f>
  800a54:	f6 c1 03             	test   $0x3,%cl
  800a57:	75 0a                	jne    800a63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a59:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 05                	jmp    800a68 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a63:	89 c7                	mov    %eax,%edi
  800a65:	fc                   	cld    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 79 ff ff ff       	call   800a04 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9d:	eb 1a                	jmp    800ab9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a9f:	0f b6 02             	movzbl (%edx),%eax
  800aa2:	0f b6 19             	movzbl (%ecx),%ebx
  800aa5:	38 d8                	cmp    %bl,%al
  800aa7:	74 0a                	je     800ab3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa9:	0f b6 c0             	movzbl %al,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 0f                	jmp    800ac2 <memcmp+0x35>
		s1++, s2++;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800ab9:	39 f2                	cmp    %esi,%edx
  800abb:	75 e2                	jne    800a9f <memcmp+0x12>
	}

	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad4:	eb 07                	jmp    800add <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	38 08                	cmp    %cl,(%eax)
  800ad8:	74 07                	je     800ae1 <memfind+0x1b>
	for (; s < ends; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	72 f5                	jb     800ad6 <memfind+0x10>
			break;
	return (void *) s;
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aef:	eb 03                	jmp    800af4 <strtol+0x11>
		s++;
  800af1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800af4:	0f b6 0a             	movzbl (%edx),%ecx
  800af7:	80 f9 09             	cmp    $0x9,%cl
  800afa:	74 f5                	je     800af1 <strtol+0xe>
  800afc:	80 f9 20             	cmp    $0x20,%cl
  800aff:	74 f0                	je     800af1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b01:	80 f9 2b             	cmp    $0x2b,%cl
  800b04:	75 0a                	jne    800b10 <strtol+0x2d>
		s++;
  800b06:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0e:	eb 11                	jmp    800b21 <strtol+0x3e>
  800b10:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b15:	80 f9 2d             	cmp    $0x2d,%cl
  800b18:	75 07                	jne    800b21 <strtol+0x3e>
		s++, neg = 1;
  800b1a:	8d 52 01             	lea    0x1(%edx),%edx
  800b1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b26:	75 15                	jne    800b3d <strtol+0x5a>
  800b28:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2b:	75 10                	jne    800b3d <strtol+0x5a>
  800b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b31:	75 0a                	jne    800b3d <strtol+0x5a>
		s += 2, base = 16;
  800b33:	83 c2 02             	add    $0x2,%edx
  800b36:	b8 10 00 00 00       	mov    $0x10,%eax
  800b3b:	eb 10                	jmp    800b4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 0c                	jne    800b4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b41:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b43:	80 3a 30             	cmpb   $0x30,(%edx)
  800b46:	75 05                	jne    800b4d <strtol+0x6a>
		s++, base = 8;
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	b0 08                	mov    $0x8,%al
		base = 10;
  800b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 0a             	movzbl (%edx),%ecx
  800b58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b5b:	89 f0                	mov    %esi,%eax
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	77 08                	ja     800b69 <strtol+0x86>
			dig = *s - '0';
  800b61:	0f be c9             	movsbl %cl,%ecx
  800b64:	83 e9 30             	sub    $0x30,%ecx
  800b67:	eb 20                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b6c:	89 f0                	mov    %esi,%eax
  800b6e:	3c 19                	cmp    $0x19,%al
  800b70:	77 08                	ja     800b7a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b72:	0f be c9             	movsbl %cl,%ecx
  800b75:	83 e9 57             	sub    $0x57,%ecx
  800b78:	eb 0f                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	3c 19                	cmp    $0x19,%al
  800b81:	77 16                	ja     800b99 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b83:	0f be c9             	movsbl %cl,%ecx
  800b86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b8c:	7d 0f                	jge    800b9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b97:	eb bc                	jmp    800b55 <strtol+0x72>
  800b99:	89 d8                	mov    %ebx,%eax
  800b9b:	eb 02                	jmp    800b9f <strtol+0xbc>
  800b9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba3:	74 05                	je     800baa <strtol+0xc7>
		*endptr = (char *) s;
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800baa:	f7 d8                	neg    %eax
  800bac:	85 ff                	test   %edi,%edi
  800bae:	0f 44 c3             	cmove  %ebx,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 c6                	mov    %eax,%esi
  800bcd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c01:	b8 03 00 00 00       	mov    $0x3,%eax
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 cb                	mov    %ecx,%ebx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	89 ce                	mov    %ecx,%esi
  800c0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 28                	jle    800c3d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c19:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c20:	00 
  800c21:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800c28:	00 
  800c29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c30:	00 
  800c31:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800c38:	e8 04 f5 ff ff       	call   800141 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3d:	83 c4 2c             	add    $0x2c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 02 00 00 00       	mov    $0x2,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_yield>:

void
sys_yield(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 04 00 00 00       	mov    $0x4,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	89 f7                	mov    %esi,%edi
  800ca1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 28                	jle    800ccf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800cba:	00 
  800cbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc2:	00 
  800cc3:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800cca:	e8 72 f4 ff ff       	call   800141 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccf:	83 c4 2c             	add    $0x2c,%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ce0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 28                	jle    800d22 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d05:	00 
  800d06:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d15:	00 
  800d16:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d1d:	e8 1f f4 ff ff       	call   800141 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	83 c4 2c             	add    $0x2c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 28                	jle    800d75 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d51:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d58:	00 
  800d59:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d60:	00 
  800d61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d68:	00 
  800d69:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d70:	e8 cc f3 ff ff       	call   800141 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d75:	83 c4 2c             	add    $0x2c,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 28                	jle    800dc8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dab:	00 
  800dac:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800db3:	00 
  800db4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbb:	00 
  800dbc:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800dc3:	e8 79 f3 ff ff       	call   800141 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc8:	83 c4 2c             	add    $0x2c,%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 09 00 00 00       	mov    $0x9,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 28                	jle    800e1b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dfe:	00 
  800dff:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0e:	00 
  800e0f:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e16:	e8 26 f3 ff ff       	call   800141 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e1b:	83 c4 2c             	add    $0x2c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 df                	mov    %ebx,%edi
  800e3e:	89 de                	mov    %ebx,%esi
  800e40:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 28                	jle    800e6e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e51:	00 
  800e52:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e69:	e8 d3 f2 ff ff       	call   800141 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e6e:	83 c4 2c             	add    $0x2c,%esp
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7c:	be 00 00 00 00       	mov    $0x0,%esi
  800e81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e92:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	89 ce                	mov    %ecx,%esi
  800eb5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 28                	jle    800ee3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800ece:	00 
  800ecf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed6:	00 
  800ed7:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800ede:	e8 5e f2 ff ff       	call   800141 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee3:	83 c4 2c             	add    $0x2c,%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  800ef1:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800ef8:	75 70                	jne    800f6a <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  800efa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f01:	00 
  800f02:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f09:	ee 
  800f0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f11:	e8 6d fd ff ff       	call   800c83 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	79 1c                	jns    800f36 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  800f1a:	c7 44 24 08 cc 24 80 	movl   $0x8024cc,0x8(%esp)
  800f21:	00 
  800f22:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800f29:	00 
  800f2a:	c7 04 24 27 25 80 00 	movl   $0x802527,(%esp)
  800f31:	e8 0b f2 ff ff       	call   800141 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  800f36:	c7 44 24 04 74 0f 80 	movl   $0x800f74,0x4(%esp)
  800f3d:	00 
  800f3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f45:	e8 d9 fe ff ff       	call   800e23 <sys_env_set_pgfault_upcall>
        if(r < 0)
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	79 1c                	jns    800f6a <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  800f4e:	c7 44 24 08 f4 24 80 	movl   $0x8024f4,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 27 25 80 00 	movl   $0x802527,(%esp)
  800f65:	e8 d7 f1 ff ff       	call   800141 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6d:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f74:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f75:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800f7a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f7c:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  800f7f:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  800f83:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  800f87:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  800f89:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  800f8b:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  800f8c:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  800f8f:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  800f91:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  800f94:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  800f95:	83 c4 04             	add    $0x4,%esp
    popf;
  800f98:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  800f99:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  800f9a:	c3                   	ret    
  800f9b:	66 90                	xchg   %ax,%ax
  800f9d:	66 90                	xchg   %ax,%ax
  800f9f:	90                   	nop

00800fa0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fab:	c1 e8 0c             	shr    $0xc,%eax
}
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800fbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fc0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fcd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fd2:	89 c2                	mov    %eax,%edx
  800fd4:	c1 ea 16             	shr    $0x16,%edx
  800fd7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fde:	f6 c2 01             	test   $0x1,%dl
  800fe1:	74 11                	je     800ff4 <fd_alloc+0x2d>
  800fe3:	89 c2                	mov    %eax,%edx
  800fe5:	c1 ea 0c             	shr    $0xc,%edx
  800fe8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fef:	f6 c2 01             	test   $0x1,%dl
  800ff2:	75 09                	jne    800ffd <fd_alloc+0x36>
			*fd_store = fd;
  800ff4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffb:	eb 17                	jmp    801014 <fd_alloc+0x4d>
  800ffd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801002:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801007:	75 c9                	jne    800fd2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801009:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80100f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80101c:	83 f8 1f             	cmp    $0x1f,%eax
  80101f:	77 36                	ja     801057 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801021:	c1 e0 0c             	shl    $0xc,%eax
  801024:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801029:	89 c2                	mov    %eax,%edx
  80102b:	c1 ea 16             	shr    $0x16,%edx
  80102e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801035:	f6 c2 01             	test   $0x1,%dl
  801038:	74 24                	je     80105e <fd_lookup+0x48>
  80103a:	89 c2                	mov    %eax,%edx
  80103c:	c1 ea 0c             	shr    $0xc,%edx
  80103f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801046:	f6 c2 01             	test   $0x1,%dl
  801049:	74 1a                	je     801065 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80104b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104e:	89 02                	mov    %eax,(%edx)
	return 0;
  801050:	b8 00 00 00 00       	mov    $0x0,%eax
  801055:	eb 13                	jmp    80106a <fd_lookup+0x54>
		return -E_INVAL;
  801057:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80105c:	eb 0c                	jmp    80106a <fd_lookup+0x54>
		return -E_INVAL;
  80105e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801063:	eb 05                	jmp    80106a <fd_lookup+0x54>
  801065:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 18             	sub    $0x18,%esp
  801072:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801075:	ba b8 25 80 00       	mov    $0x8025b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80107a:	eb 13                	jmp    80108f <dev_lookup+0x23>
  80107c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80107f:	39 08                	cmp    %ecx,(%eax)
  801081:	75 0c                	jne    80108f <dev_lookup+0x23>
			*dev = devtab[i];
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	89 01                	mov    %eax,(%ecx)
			return 0;
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
  80108d:	eb 30                	jmp    8010bf <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80108f:	8b 02                	mov    (%edx),%eax
  801091:	85 c0                	test   %eax,%eax
  801093:	75 e7                	jne    80107c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801095:	a1 08 40 80 00       	mov    0x804008,%eax
  80109a:	8b 40 48             	mov    0x48(%eax),%eax
  80109d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a5:	c7 04 24 38 25 80 00 	movl   $0x802538,(%esp)
  8010ac:	e8 89 f1 ff ff       	call   80023a <cprintf>
	*dev = 0;
  8010b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010bf:	c9                   	leave  
  8010c0:	c3                   	ret    

008010c1 <fd_close>:
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	56                   	push   %esi
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 20             	sub    $0x20,%esp
  8010c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010df:	89 04 24             	mov    %eax,(%esp)
  8010e2:	e8 2f ff ff ff       	call   801016 <fd_lookup>
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 05                	js     8010f0 <fd_close+0x2f>
	    || fd != fd2)
  8010eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010ee:	74 0c                	je     8010fc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8010f0:	84 db                	test   %bl,%bl
  8010f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f7:	0f 44 c2             	cmove  %edx,%eax
  8010fa:	eb 3f                	jmp    80113b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801103:	8b 06                	mov    (%esi),%eax
  801105:	89 04 24             	mov    %eax,(%esp)
  801108:	e8 5f ff ff ff       	call   80106c <dev_lookup>
  80110d:	89 c3                	mov    %eax,%ebx
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 16                	js     801129 <fd_close+0x68>
		if (dev->dev_close)
  801113:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801116:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801119:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80111e:	85 c0                	test   %eax,%eax
  801120:	74 07                	je     801129 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801122:	89 34 24             	mov    %esi,(%esp)
  801125:	ff d0                	call   *%eax
  801127:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801129:	89 74 24 04          	mov    %esi,0x4(%esp)
  80112d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801134:	e8 f1 fb ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801139:	89 d8                	mov    %ebx,%eax
}
  80113b:	83 c4 20             	add    $0x20,%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <close>:

int
close(int fdnum)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801148:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	89 04 24             	mov    %eax,(%esp)
  801155:	e8 bc fe ff ff       	call   801016 <fd_lookup>
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	85 d2                	test   %edx,%edx
  80115e:	78 13                	js     801173 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801160:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801167:	00 
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	89 04 24             	mov    %eax,(%esp)
  80116e:	e8 4e ff ff ff       	call   8010c1 <fd_close>
}
  801173:	c9                   	leave  
  801174:	c3                   	ret    

00801175 <close_all>:

void
close_all(void)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	53                   	push   %ebx
  801179:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80117c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801181:	89 1c 24             	mov    %ebx,(%esp)
  801184:	e8 b9 ff ff ff       	call   801142 <close>
	for (i = 0; i < MAXFD; i++)
  801189:	83 c3 01             	add    $0x1,%ebx
  80118c:	83 fb 20             	cmp    $0x20,%ebx
  80118f:	75 f0                	jne    801181 <close_all+0xc>
}
  801191:	83 c4 14             	add    $0x14,%esp
  801194:	5b                   	pop    %ebx
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	e8 64 fe ff ff       	call   801016 <fd_lookup>
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	85 d2                	test   %edx,%edx
  8011b6:	0f 88 e1 00 00 00    	js     80129d <dup+0x106>
		return r;
	close(newfdnum);
  8011bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bf:	89 04 24             	mov    %eax,(%esp)
  8011c2:	e8 7b ff ff ff       	call   801142 <close>

	newfd = INDEX2FD(newfdnum);
  8011c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ca:	c1 e3 0c             	shl    $0xc,%ebx
  8011cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d6:	89 04 24             	mov    %eax,(%esp)
  8011d9:	e8 d2 fd ff ff       	call   800fb0 <fd2data>
  8011de:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8011e0:	89 1c 24             	mov    %ebx,(%esp)
  8011e3:	e8 c8 fd ff ff       	call   800fb0 <fd2data>
  8011e8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ea:	89 f0                	mov    %esi,%eax
  8011ec:	c1 e8 16             	shr    $0x16,%eax
  8011ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f6:	a8 01                	test   $0x1,%al
  8011f8:	74 43                	je     80123d <dup+0xa6>
  8011fa:	89 f0                	mov    %esi,%eax
  8011fc:	c1 e8 0c             	shr    $0xc,%eax
  8011ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 32                	je     80123d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80120b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801212:	25 07 0e 00 00       	and    $0xe07,%eax
  801217:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80121f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801226:	00 
  801227:	89 74 24 04          	mov    %esi,0x4(%esp)
  80122b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801232:	e8 a0 fa ff ff       	call   800cd7 <sys_page_map>
  801237:	89 c6                	mov    %eax,%esi
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 3e                	js     80127b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80123d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801240:	89 c2                	mov    %eax,%edx
  801242:	c1 ea 0c             	shr    $0xc,%edx
  801245:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801252:	89 54 24 10          	mov    %edx,0x10(%esp)
  801256:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80125a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801261:	00 
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80126d:	e8 65 fa ff ff       	call   800cd7 <sys_page_map>
  801272:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801274:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801277:	85 f6                	test   %esi,%esi
  801279:	79 22                	jns    80129d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80127b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80127f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801286:	e8 9f fa ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80128b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801296:	e8 8f fa ff ff       	call   800d2a <sys_page_unmap>
	return r;
  80129b:	89 f0                	mov    %esi,%eax
}
  80129d:	83 c4 3c             	add    $0x3c,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 24             	sub    $0x24,%esp
  8012ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b6:	89 1c 24             	mov    %ebx,(%esp)
  8012b9:	e8 58 fd ff ff       	call   801016 <fd_lookup>
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	85 d2                	test   %edx,%edx
  8012c2:	78 6d                	js     801331 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	8b 00                	mov    (%eax),%eax
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	e8 94 fd ff ff       	call   80106c <dev_lookup>
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 55                	js     801331 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	8b 50 08             	mov    0x8(%eax),%edx
  8012e2:	83 e2 03             	and    $0x3,%edx
  8012e5:	83 fa 01             	cmp    $0x1,%edx
  8012e8:	75 23                	jne    80130d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ea:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ef:	8b 40 48             	mov    0x48(%eax),%eax
  8012f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  801301:	e8 34 ef ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801306:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130b:	eb 24                	jmp    801331 <read+0x8c>
	}
	if (!dev->dev_read)
  80130d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801310:	8b 52 08             	mov    0x8(%edx),%edx
  801313:	85 d2                	test   %edx,%edx
  801315:	74 15                	je     80132c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801317:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80131a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80131e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801321:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	ff d2                	call   *%edx
  80132a:	eb 05                	jmp    801331 <read+0x8c>
		return -E_NOT_SUPP;
  80132c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801331:	83 c4 24             	add    $0x24,%esp
  801334:	5b                   	pop    %ebx
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	57                   	push   %edi
  80133b:	56                   	push   %esi
  80133c:	53                   	push   %ebx
  80133d:	83 ec 1c             	sub    $0x1c,%esp
  801340:	8b 7d 08             	mov    0x8(%ebp),%edi
  801343:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801346:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134b:	eb 23                	jmp    801370 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80134d:	89 f0                	mov    %esi,%eax
  80134f:	29 d8                	sub    %ebx,%eax
  801351:	89 44 24 08          	mov    %eax,0x8(%esp)
  801355:	89 d8                	mov    %ebx,%eax
  801357:	03 45 0c             	add    0xc(%ebp),%eax
  80135a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135e:	89 3c 24             	mov    %edi,(%esp)
  801361:	e8 3f ff ff ff       	call   8012a5 <read>
		if (m < 0)
  801366:	85 c0                	test   %eax,%eax
  801368:	78 10                	js     80137a <readn+0x43>
			return m;
		if (m == 0)
  80136a:	85 c0                	test   %eax,%eax
  80136c:	74 0a                	je     801378 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80136e:	01 c3                	add    %eax,%ebx
  801370:	39 f3                	cmp    %esi,%ebx
  801372:	72 d9                	jb     80134d <readn+0x16>
  801374:	89 d8                	mov    %ebx,%eax
  801376:	eb 02                	jmp    80137a <readn+0x43>
  801378:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80137a:	83 c4 1c             	add    $0x1c,%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5f                   	pop    %edi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 24             	sub    $0x24,%esp
  801389:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801393:	89 1c 24             	mov    %ebx,(%esp)
  801396:	e8 7b fc ff ff       	call   801016 <fd_lookup>
  80139b:	89 c2                	mov    %eax,%edx
  80139d:	85 d2                	test   %edx,%edx
  80139f:	78 68                	js     801409 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ab:	8b 00                	mov    (%eax),%eax
  8013ad:	89 04 24             	mov    %eax,(%esp)
  8013b0:	e8 b7 fc ff ff       	call   80106c <dev_lookup>
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 50                	js     801409 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c0:	75 23                	jne    8013e5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c2:	a1 08 40 80 00       	mov    0x804008,%eax
  8013c7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d2:	c7 04 24 98 25 80 00 	movl   $0x802598,(%esp)
  8013d9:	e8 5c ee ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  8013de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e3:	eb 24                	jmp    801409 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	74 15                	je     801404 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013fd:	89 04 24             	mov    %eax,(%esp)
  801400:	ff d2                	call   *%edx
  801402:	eb 05                	jmp    801409 <write+0x87>
		return -E_NOT_SUPP;
  801404:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801409:	83 c4 24             	add    $0x24,%esp
  80140c:	5b                   	pop    %ebx
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <seek>:

int
seek(int fdnum, off_t offset)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801415:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 ef fb ff ff       	call   801016 <fd_lookup>
  801427:	85 c0                	test   %eax,%eax
  801429:	78 0e                	js     801439 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80142b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80142e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801431:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	53                   	push   %ebx
  80143f:	83 ec 24             	sub    $0x24,%esp
  801442:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801445:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144c:	89 1c 24             	mov    %ebx,(%esp)
  80144f:	e8 c2 fb ff ff       	call   801016 <fd_lookup>
  801454:	89 c2                	mov    %eax,%edx
  801456:	85 d2                	test   %edx,%edx
  801458:	78 61                	js     8014bb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801464:	8b 00                	mov    (%eax),%eax
  801466:	89 04 24             	mov    %eax,(%esp)
  801469:	e8 fe fb ff ff       	call   80106c <dev_lookup>
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 49                	js     8014bb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801472:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801475:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801479:	75 23                	jne    80149e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80147b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801480:	8b 40 48             	mov    0x48(%eax),%eax
  801483:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148b:	c7 04 24 58 25 80 00 	movl   $0x802558,(%esp)
  801492:	e8 a3 ed ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149c:	eb 1d                	jmp    8014bb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80149e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a1:	8b 52 18             	mov    0x18(%edx),%edx
  8014a4:	85 d2                	test   %edx,%edx
  8014a6:	74 0e                	je     8014b6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014af:	89 04 24             	mov    %eax,(%esp)
  8014b2:	ff d2                	call   *%edx
  8014b4:	eb 05                	jmp    8014bb <ftruncate+0x80>
		return -E_NOT_SUPP;
  8014b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014bb:	83 c4 24             	add    $0x24,%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 24             	sub    $0x24,%esp
  8014c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	89 04 24             	mov    %eax,(%esp)
  8014d8:	e8 39 fb ff ff       	call   801016 <fd_lookup>
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	85 d2                	test   %edx,%edx
  8014e1:	78 52                	js     801535 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	8b 00                	mov    (%eax),%eax
  8014ef:	89 04 24             	mov    %eax,(%esp)
  8014f2:	e8 75 fb ff ff       	call   80106c <dev_lookup>
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 3a                	js     801535 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801502:	74 2c                	je     801530 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801504:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801507:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80150e:	00 00 00 
	stat->st_isdir = 0;
  801511:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801518:	00 00 00 
	stat->st_dev = dev;
  80151b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801521:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801525:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801528:	89 14 24             	mov    %edx,(%esp)
  80152b:	ff 50 14             	call   *0x14(%eax)
  80152e:	eb 05                	jmp    801535 <fstat+0x74>
		return -E_NOT_SUPP;
  801530:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801535:	83 c4 24             	add    $0x24,%esp
  801538:	5b                   	pop    %ebx
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	56                   	push   %esi
  80153f:	53                   	push   %ebx
  801540:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801543:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80154a:	00 
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	89 04 24             	mov    %eax,(%esp)
  801551:	e8 fb 01 00 00       	call   801751 <open>
  801556:	89 c3                	mov    %eax,%ebx
  801558:	85 db                	test   %ebx,%ebx
  80155a:	78 1b                	js     801577 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80155c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801563:	89 1c 24             	mov    %ebx,(%esp)
  801566:	e8 56 ff ff ff       	call   8014c1 <fstat>
  80156b:	89 c6                	mov    %eax,%esi
	close(fd);
  80156d:	89 1c 24             	mov    %ebx,(%esp)
  801570:	e8 cd fb ff ff       	call   801142 <close>
	return r;
  801575:	89 f0                	mov    %esi,%eax
}
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	56                   	push   %esi
  801582:	53                   	push   %ebx
  801583:	83 ec 10             	sub    $0x10,%esp
  801586:	89 c6                	mov    %eax,%esi
  801588:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80158a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801591:	75 11                	jne    8015a4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801593:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80159a:	e8 50 08 00 00       	call   801def <ipc_find_env>
  80159f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015a4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015ab:	00 
  8015ac:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015b3:	00 
  8015b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8015bd:	89 04 24             	mov    %eax,(%esp)
  8015c0:	e8 c3 07 00 00       	call   801d88 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015cc:	00 
  8015cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d8:	e8 43 07 00 00       	call   801d20 <ipc_recv>
}
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801602:	b8 02 00 00 00       	mov    $0x2,%eax
  801607:	e8 72 ff ff ff       	call   80157e <fsipc>
}
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <devfile_flush>:
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801614:	8b 45 08             	mov    0x8(%ebp),%eax
  801617:	8b 40 0c             	mov    0xc(%eax),%eax
  80161a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80161f:	ba 00 00 00 00       	mov    $0x0,%edx
  801624:	b8 06 00 00 00       	mov    $0x6,%eax
  801629:	e8 50 ff ff ff       	call   80157e <fsipc>
}
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <devfile_stat>:
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 14             	sub    $0x14,%esp
  801637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80163a:	8b 45 08             	mov    0x8(%ebp),%eax
  80163d:	8b 40 0c             	mov    0xc(%eax),%eax
  801640:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801645:	ba 00 00 00 00       	mov    $0x0,%edx
  80164a:	b8 05 00 00 00       	mov    $0x5,%eax
  80164f:	e8 2a ff ff ff       	call   80157e <fsipc>
  801654:	89 c2                	mov    %eax,%edx
  801656:	85 d2                	test   %edx,%edx
  801658:	78 2b                	js     801685 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80165a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801661:	00 
  801662:	89 1c 24             	mov    %ebx,(%esp)
  801665:	e8 fd f1 ff ff       	call   800867 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80166a:	a1 80 50 80 00       	mov    0x805080,%eax
  80166f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801675:	a1 84 50 80 00       	mov    0x805084,%eax
  80167a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801685:	83 c4 14             	add    $0x14,%esp
  801688:	5b                   	pop    %ebx
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <devfile_write>:
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801691:	c7 44 24 08 c8 25 80 	movl   $0x8025c8,0x8(%esp)
  801698:	00 
  801699:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016a0:	00 
  8016a1:	c7 04 24 e6 25 80 00 	movl   $0x8025e6,(%esp)
  8016a8:	e8 94 ea ff ff       	call   800141 <_panic>

008016ad <devfile_read>:
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 10             	sub    $0x10,%esp
  8016b5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016c3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8016d3:	e8 a6 fe ff ff       	call   80157e <fsipc>
  8016d8:	89 c3                	mov    %eax,%ebx
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 6a                	js     801748 <devfile_read+0x9b>
	assert(r <= n);
  8016de:	39 c6                	cmp    %eax,%esi
  8016e0:	73 24                	jae    801706 <devfile_read+0x59>
  8016e2:	c7 44 24 0c f1 25 80 	movl   $0x8025f1,0xc(%esp)
  8016e9:	00 
  8016ea:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  8016f1:	00 
  8016f2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016f9:	00 
  8016fa:	c7 04 24 e6 25 80 00 	movl   $0x8025e6,(%esp)
  801701:	e8 3b ea ff ff       	call   800141 <_panic>
	assert(r <= PGSIZE);
  801706:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80170b:	7e 24                	jle    801731 <devfile_read+0x84>
  80170d:	c7 44 24 0c 0d 26 80 	movl   $0x80260d,0xc(%esp)
  801714:	00 
  801715:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  80171c:	00 
  80171d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801724:	00 
  801725:	c7 04 24 e6 25 80 00 	movl   $0x8025e6,(%esp)
  80172c:	e8 10 ea ff ff       	call   800141 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801731:	89 44 24 08          	mov    %eax,0x8(%esp)
  801735:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80173c:	00 
  80173d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801740:	89 04 24             	mov    %eax,(%esp)
  801743:	e8 bc f2 ff ff       	call   800a04 <memmove>
}
  801748:	89 d8                	mov    %ebx,%eax
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <open>:
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	83 ec 24             	sub    $0x24,%esp
  801758:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80175b:	89 1c 24             	mov    %ebx,(%esp)
  80175e:	e8 cd f0 ff ff       	call   800830 <strlen>
  801763:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801768:	7f 60                	jg     8017ca <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80176a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176d:	89 04 24             	mov    %eax,(%esp)
  801770:	e8 52 f8 ff ff       	call   800fc7 <fd_alloc>
  801775:	89 c2                	mov    %eax,%edx
  801777:	85 d2                	test   %edx,%edx
  801779:	78 54                	js     8017cf <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80177b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801786:	e8 dc f0 ff ff       	call   800867 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80178b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801793:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801796:	b8 01 00 00 00       	mov    $0x1,%eax
  80179b:	e8 de fd ff ff       	call   80157e <fsipc>
  8017a0:	89 c3                	mov    %eax,%ebx
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	79 17                	jns    8017bd <open+0x6c>
		fd_close(fd, 0);
  8017a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017ad:	00 
  8017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b1:	89 04 24             	mov    %eax,(%esp)
  8017b4:	e8 08 f9 ff ff       	call   8010c1 <fd_close>
		return r;
  8017b9:	89 d8                	mov    %ebx,%eax
  8017bb:	eb 12                	jmp    8017cf <open+0x7e>
	return fd2num(fd);
  8017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c0:	89 04 24             	mov    %eax,(%esp)
  8017c3:	e8 d8 f7 ff ff       	call   800fa0 <fd2num>
  8017c8:	eb 05                	jmp    8017cf <open+0x7e>
		return -E_BAD_PATH;
  8017ca:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8017cf:	83 c4 24             	add    $0x24,%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8017e5:	e8 94 fd ff ff       	call   80157e <fsipc>
}
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 10             	sub    $0x10,%esp
  8017f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	e8 ae f7 ff ff       	call   800fb0 <fd2data>
  801802:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801804:	c7 44 24 04 19 26 80 	movl   $0x802619,0x4(%esp)
  80180b:	00 
  80180c:	89 1c 24             	mov    %ebx,(%esp)
  80180f:	e8 53 f0 ff ff       	call   800867 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801814:	8b 46 04             	mov    0x4(%esi),%eax
  801817:	2b 06                	sub    (%esi),%eax
  801819:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80181f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801826:	00 00 00 
	stat->st_dev = &devpipe;
  801829:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801830:	30 80 00 
	return 0;
}
  801833:	b8 00 00 00 00       	mov    $0x0,%eax
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5e                   	pop    %esi
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	53                   	push   %ebx
  801843:	83 ec 14             	sub    $0x14,%esp
  801846:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801849:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80184d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801854:	e8 d1 f4 ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801859:	89 1c 24             	mov    %ebx,(%esp)
  80185c:	e8 4f f7 ff ff       	call   800fb0 <fd2data>
  801861:	89 44 24 04          	mov    %eax,0x4(%esp)
  801865:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186c:	e8 b9 f4 ff ff       	call   800d2a <sys_page_unmap>
}
  801871:	83 c4 14             	add    $0x14,%esp
  801874:	5b                   	pop    %ebx
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <_pipeisclosed>:
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	57                   	push   %edi
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	83 ec 2c             	sub    $0x2c,%esp
  801880:	89 c6                	mov    %eax,%esi
  801882:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801885:	a1 08 40 80 00       	mov    0x804008,%eax
  80188a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80188d:	89 34 24             	mov    %esi,(%esp)
  801890:	e8 92 05 00 00       	call   801e27 <pageref>
  801895:	89 c7                	mov    %eax,%edi
  801897:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80189a:	89 04 24             	mov    %eax,(%esp)
  80189d:	e8 85 05 00 00       	call   801e27 <pageref>
  8018a2:	39 c7                	cmp    %eax,%edi
  8018a4:	0f 94 c2             	sete   %dl
  8018a7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8018aa:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8018b0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8018b3:	39 fb                	cmp    %edi,%ebx
  8018b5:	74 21                	je     8018d8 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  8018b7:	84 d2                	test   %dl,%dl
  8018b9:	74 ca                	je     801885 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018bb:	8b 51 58             	mov    0x58(%ecx),%edx
  8018be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ca:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  8018d1:	e8 64 e9 ff ff       	call   80023a <cprintf>
  8018d6:	eb ad                	jmp    801885 <_pipeisclosed+0xe>
}
  8018d8:	83 c4 2c             	add    $0x2c,%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5e                   	pop    %esi
  8018dd:	5f                   	pop    %edi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <devpipe_write>:
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	57                   	push   %edi
  8018e4:	56                   	push   %esi
  8018e5:	53                   	push   %ebx
  8018e6:	83 ec 1c             	sub    $0x1c,%esp
  8018e9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8018ec:	89 34 24             	mov    %esi,(%esp)
  8018ef:	e8 bc f6 ff ff       	call   800fb0 <fd2data>
  8018f4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8018fb:	eb 45                	jmp    801942 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  8018fd:	89 da                	mov    %ebx,%edx
  8018ff:	89 f0                	mov    %esi,%eax
  801901:	e8 71 ff ff ff       	call   801877 <_pipeisclosed>
  801906:	85 c0                	test   %eax,%eax
  801908:	75 41                	jne    80194b <devpipe_write+0x6b>
			sys_yield();
  80190a:	e8 55 f3 ff ff       	call   800c64 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80190f:	8b 43 04             	mov    0x4(%ebx),%eax
  801912:	8b 0b                	mov    (%ebx),%ecx
  801914:	8d 51 20             	lea    0x20(%ecx),%edx
  801917:	39 d0                	cmp    %edx,%eax
  801919:	73 e2                	jae    8018fd <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80191b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80191e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801922:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801925:	99                   	cltd   
  801926:	c1 ea 1b             	shr    $0x1b,%edx
  801929:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80192c:	83 e1 1f             	and    $0x1f,%ecx
  80192f:	29 d1                	sub    %edx,%ecx
  801931:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801935:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801939:	83 c0 01             	add    $0x1,%eax
  80193c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80193f:	83 c7 01             	add    $0x1,%edi
  801942:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801945:	75 c8                	jne    80190f <devpipe_write+0x2f>
	return i;
  801947:	89 f8                	mov    %edi,%eax
  801949:	eb 05                	jmp    801950 <devpipe_write+0x70>
				return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801950:	83 c4 1c             	add    $0x1c,%esp
  801953:	5b                   	pop    %ebx
  801954:	5e                   	pop    %esi
  801955:	5f                   	pop    %edi
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    

00801958 <devpipe_read>:
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	57                   	push   %edi
  80195c:	56                   	push   %esi
  80195d:	53                   	push   %ebx
  80195e:	83 ec 1c             	sub    $0x1c,%esp
  801961:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801964:	89 3c 24             	mov    %edi,(%esp)
  801967:	e8 44 f6 ff ff       	call   800fb0 <fd2data>
  80196c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80196e:	be 00 00 00 00       	mov    $0x0,%esi
  801973:	eb 3d                	jmp    8019b2 <devpipe_read+0x5a>
			if (i > 0)
  801975:	85 f6                	test   %esi,%esi
  801977:	74 04                	je     80197d <devpipe_read+0x25>
				return i;
  801979:	89 f0                	mov    %esi,%eax
  80197b:	eb 43                	jmp    8019c0 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  80197d:	89 da                	mov    %ebx,%edx
  80197f:	89 f8                	mov    %edi,%eax
  801981:	e8 f1 fe ff ff       	call   801877 <_pipeisclosed>
  801986:	85 c0                	test   %eax,%eax
  801988:	75 31                	jne    8019bb <devpipe_read+0x63>
			sys_yield();
  80198a:	e8 d5 f2 ff ff       	call   800c64 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80198f:	8b 03                	mov    (%ebx),%eax
  801991:	3b 43 04             	cmp    0x4(%ebx),%eax
  801994:	74 df                	je     801975 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801996:	99                   	cltd   
  801997:	c1 ea 1b             	shr    $0x1b,%edx
  80199a:	01 d0                	add    %edx,%eax
  80199c:	83 e0 1f             	and    $0x1f,%eax
  80199f:	29 d0                	sub    %edx,%eax
  8019a1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8019a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8019ac:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8019af:	83 c6 01             	add    $0x1,%esi
  8019b2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019b5:	75 d8                	jne    80198f <devpipe_read+0x37>
	return i;
  8019b7:	89 f0                	mov    %esi,%eax
  8019b9:	eb 05                	jmp    8019c0 <devpipe_read+0x68>
				return 0;
  8019bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c0:	83 c4 1c             	add    $0x1c,%esp
  8019c3:	5b                   	pop    %ebx
  8019c4:	5e                   	pop    %esi
  8019c5:	5f                   	pop    %edi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <pipe>:
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	56                   	push   %esi
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8019d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d3:	89 04 24             	mov    %eax,(%esp)
  8019d6:	e8 ec f5 ff ff       	call   800fc7 <fd_alloc>
  8019db:	89 c2                	mov    %eax,%edx
  8019dd:	85 d2                	test   %edx,%edx
  8019df:	0f 88 4d 01 00 00    	js     801b32 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019ec:	00 
  8019ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fb:	e8 83 f2 ff ff       	call   800c83 <sys_page_alloc>
  801a00:	89 c2                	mov    %eax,%edx
  801a02:	85 d2                	test   %edx,%edx
  801a04:	0f 88 28 01 00 00    	js     801b32 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801a0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a0d:	89 04 24             	mov    %eax,(%esp)
  801a10:	e8 b2 f5 ff ff       	call   800fc7 <fd_alloc>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	85 c0                	test   %eax,%eax
  801a19:	0f 88 fe 00 00 00    	js     801b1d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a1f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a26:	00 
  801a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a35:	e8 49 f2 ff ff       	call   800c83 <sys_page_alloc>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	0f 88 d9 00 00 00    	js     801b1d <pipe+0x155>
	va = fd2data(fd0);
  801a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a47:	89 04 24             	mov    %eax,(%esp)
  801a4a:	e8 61 f5 ff ff       	call   800fb0 <fd2data>
  801a4f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a51:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a58:	00 
  801a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a64:	e8 1a f2 ff ff       	call   800c83 <sys_page_alloc>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	0f 88 97 00 00 00    	js     801b0a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a76:	89 04 24             	mov    %eax,(%esp)
  801a79:	e8 32 f5 ff ff       	call   800fb0 <fd2data>
  801a7e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a85:	00 
  801a86:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a8a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a91:	00 
  801a92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9d:	e8 35 f2 ff ff       	call   800cd7 <sys_page_map>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	78 52                	js     801afa <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801aa8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801abd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801acb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad5:	89 04 24             	mov    %eax,(%esp)
  801ad8:	e8 c3 f4 ff ff       	call   800fa0 <fd2num>
  801add:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae5:	89 04 24             	mov    %eax,(%esp)
  801ae8:	e8 b3 f4 ff ff       	call   800fa0 <fd2num>
  801aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
  801af8:	eb 38                	jmp    801b32 <pipe+0x16a>
	sys_page_unmap(0, va);
  801afa:	89 74 24 04          	mov    %esi,0x4(%esp)
  801afe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b05:	e8 20 f2 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b18:	e8 0d f2 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2b:	e8 fa f1 ff ff       	call   800d2a <sys_page_unmap>
  801b30:	89 d8                	mov    %ebx,%eax
}
  801b32:	83 c4 30             	add    $0x30,%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <pipeisclosed>:
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b46:	8b 45 08             	mov    0x8(%ebp),%eax
  801b49:	89 04 24             	mov    %eax,(%esp)
  801b4c:	e8 c5 f4 ff ff       	call   801016 <fd_lookup>
  801b51:	89 c2                	mov    %eax,%edx
  801b53:	85 d2                	test   %edx,%edx
  801b55:	78 15                	js     801b6c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5a:	89 04 24             	mov    %eax,(%esp)
  801b5d:	e8 4e f4 ff ff       	call   800fb0 <fd2data>
	return _pipeisclosed(fd, p);
  801b62:	89 c2                	mov    %eax,%edx
  801b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b67:	e8 0b fd ff ff       	call   801877 <_pipeisclosed>
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    
  801b6e:	66 90                	xchg   %ax,%ax

00801b70 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801b80:	c7 44 24 04 38 26 80 	movl   $0x802638,0x4(%esp)
  801b87:	00 
  801b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8b:	89 04 24             	mov    %eax,(%esp)
  801b8e:	e8 d4 ec ff ff       	call   800867 <strcpy>
	return 0;
}
  801b93:	b8 00 00 00 00       	mov    $0x0,%eax
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <devcons_write>:
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	57                   	push   %edi
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ba6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801bab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801bb1:	eb 31                	jmp    801be4 <devcons_write+0x4a>
		m = n - tot;
  801bb3:	8b 75 10             	mov    0x10(%ebp),%esi
  801bb6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801bb8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801bbb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bc0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801bc3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bc7:	03 45 0c             	add    0xc(%ebp),%eax
  801bca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bce:	89 3c 24             	mov    %edi,(%esp)
  801bd1:	e8 2e ee ff ff       	call   800a04 <memmove>
		sys_cputs(buf, m);
  801bd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bda:	89 3c 24             	mov    %edi,(%esp)
  801bdd:	e8 d4 ef ff ff       	call   800bb6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801be2:	01 f3                	add    %esi,%ebx
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be9:	72 c8                	jb     801bb3 <devcons_write+0x19>
}
  801beb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5f                   	pop    %edi
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <devcons_read>:
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801bfc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c05:	75 07                	jne    801c0e <devcons_read+0x18>
  801c07:	eb 2a                	jmp    801c33 <devcons_read+0x3d>
		sys_yield();
  801c09:	e8 56 f0 ff ff       	call   800c64 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801c0e:	66 90                	xchg   %ax,%ax
  801c10:	e8 bf ef ff ff       	call   800bd4 <sys_cgetc>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	74 f0                	je     801c09 <devcons_read+0x13>
	if (c < 0)
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 16                	js     801c33 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801c1d:	83 f8 04             	cmp    $0x4,%eax
  801c20:	74 0c                	je     801c2e <devcons_read+0x38>
	*(char*)vbuf = c;
  801c22:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c25:	88 02                	mov    %al,(%edx)
	return 1;
  801c27:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2c:	eb 05                	jmp    801c33 <devcons_read+0x3d>
		return 0;
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <cputchar>:
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c48:	00 
  801c49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 62 ef ff ff       	call   800bb6 <sys_cputs>
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <getchar>:
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801c5c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c63:	00 
  801c64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c72:	e8 2e f6 ff ff       	call   8012a5 <read>
	if (r < 0)
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 0f                	js     801c8a <getchar+0x34>
	if (r < 1)
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	7e 06                	jle    801c85 <getchar+0x2f>
	return c;
  801c7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c83:	eb 05                	jmp    801c8a <getchar+0x34>
		return -E_EOF;
  801c85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <iscons>:
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c99:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9c:	89 04 24             	mov    %eax,(%esp)
  801c9f:	e8 72 f3 ff ff       	call   801016 <fd_lookup>
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 11                	js     801cb9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb1:	39 10                	cmp    %edx,(%eax)
  801cb3:	0f 94 c0             	sete   %al
  801cb6:	0f b6 c0             	movzbl %al,%eax
}
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <opencons>:
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801cc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc4:	89 04 24             	mov    %eax,(%esp)
  801cc7:	e8 fb f2 ff ff       	call   800fc7 <fd_alloc>
		return r;
  801ccc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 40                	js     801d12 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cd2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cd9:	00 
  801cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce8:	e8 96 ef ff ff       	call   800c83 <sys_page_alloc>
		return r;
  801ced:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	78 1f                	js     801d12 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801cf3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d01:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d08:	89 04 24             	mov    %eax,(%esp)
  801d0b:	e8 90 f2 ff ff       	call   800fa0 <fd2num>
  801d10:	89 c2                	mov    %eax,%edx
}
  801d12:	89 d0                	mov    %edx,%eax
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	56                   	push   %esi
  801d24:	53                   	push   %ebx
  801d25:	83 ec 10             	sub    $0x10,%esp
  801d28:	8b 75 08             	mov    0x8(%ebp),%esi
  801d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801d31:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801d33:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801d38:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801d3b:	89 04 24             	mov    %eax,(%esp)
  801d3e:	e8 56 f1 ff ff       	call   800e99 <sys_ipc_recv>
    if(r < 0){
  801d43:	85 c0                	test   %eax,%eax
  801d45:	79 16                	jns    801d5d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801d47:	85 f6                	test   %esi,%esi
  801d49:	74 06                	je     801d51 <ipc_recv+0x31>
            *from_env_store = 0;
  801d4b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801d51:	85 db                	test   %ebx,%ebx
  801d53:	74 2c                	je     801d81 <ipc_recv+0x61>
            *perm_store = 0;
  801d55:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d5b:	eb 24                	jmp    801d81 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801d5d:	85 f6                	test   %esi,%esi
  801d5f:	74 0a                	je     801d6b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801d61:	a1 08 40 80 00       	mov    0x804008,%eax
  801d66:	8b 40 74             	mov    0x74(%eax),%eax
  801d69:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801d6b:	85 db                	test   %ebx,%ebx
  801d6d:	74 0a                	je     801d79 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801d6f:	a1 08 40 80 00       	mov    0x804008,%eax
  801d74:	8b 40 78             	mov    0x78(%eax),%eax
  801d77:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d79:	a1 08 40 80 00       	mov    0x804008,%eax
  801d7e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	57                   	push   %edi
  801d8c:	56                   	push   %esi
  801d8d:	53                   	push   %ebx
  801d8e:	83 ec 1c             	sub    $0x1c,%esp
  801d91:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d94:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801d9a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801d9c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801da1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801da4:	8b 45 14             	mov    0x14(%ebp),%eax
  801da7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801daf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db3:	89 3c 24             	mov    %edi,(%esp)
  801db6:	e8 bb f0 ff ff       	call   800e76 <sys_ipc_try_send>
        if(r == 0){
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	74 28                	je     801de7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801dbf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dc2:	74 1c                	je     801de0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801dc4:	c7 44 24 08 44 26 80 	movl   $0x802644,0x8(%esp)
  801dcb:	00 
  801dcc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801dd3:	00 
  801dd4:	c7 04 24 5b 26 80 00 	movl   $0x80265b,(%esp)
  801ddb:	e8 61 e3 ff ff       	call   800141 <_panic>
        }
        sys_yield();
  801de0:	e8 7f ee ff ff       	call   800c64 <sys_yield>
    }
  801de5:	eb bd                	jmp    801da4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801de7:	83 c4 1c             	add    $0x1c,%esp
  801dea:	5b                   	pop    %ebx
  801deb:	5e                   	pop    %esi
  801dec:	5f                   	pop    %edi
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    

00801def <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dfa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801dfd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e03:	8b 52 50             	mov    0x50(%edx),%edx
  801e06:	39 ca                	cmp    %ecx,%edx
  801e08:	75 0d                	jne    801e17 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e0a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e0d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e12:	8b 40 40             	mov    0x40(%eax),%eax
  801e15:	eb 0e                	jmp    801e25 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801e17:	83 c0 01             	add    $0x1,%eax
  801e1a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e1f:	75 d9                	jne    801dfa <ipc_find_env+0xb>
	return 0;
  801e21:	66 b8 00 00          	mov    $0x0,%ax
}
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e2d:	89 d0                	mov    %edx,%eax
  801e2f:	c1 e8 16             	shr    $0x16,%eax
  801e32:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e39:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801e3e:	f6 c1 01             	test   $0x1,%cl
  801e41:	74 1d                	je     801e60 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801e43:	c1 ea 0c             	shr    $0xc,%edx
  801e46:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e4d:	f6 c2 01             	test   $0x1,%dl
  801e50:	74 0e                	je     801e60 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e52:	c1 ea 0c             	shr    $0xc,%edx
  801e55:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e5c:	ef 
  801e5d:	0f b7 c0             	movzwl %ax,%eax
}
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    
  801e62:	66 90                	xchg   %ax,%ax
  801e64:	66 90                	xchg   %ax,%ax
  801e66:	66 90                	xchg   %ax,%ax
  801e68:	66 90                	xchg   %ax,%ax
  801e6a:	66 90                	xchg   %ax,%ax
  801e6c:	66 90                	xchg   %ax,%ax
  801e6e:	66 90                	xchg   %ax,%ax

00801e70 <__udivdi3>:
  801e70:	55                   	push   %ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	83 ec 0c             	sub    $0xc,%esp
  801e76:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e7a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e7e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e82:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e86:	85 c0                	test   %eax,%eax
  801e88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e8c:	89 ea                	mov    %ebp,%edx
  801e8e:	89 0c 24             	mov    %ecx,(%esp)
  801e91:	75 2d                	jne    801ec0 <__udivdi3+0x50>
  801e93:	39 e9                	cmp    %ebp,%ecx
  801e95:	77 61                	ja     801ef8 <__udivdi3+0x88>
  801e97:	85 c9                	test   %ecx,%ecx
  801e99:	89 ce                	mov    %ecx,%esi
  801e9b:	75 0b                	jne    801ea8 <__udivdi3+0x38>
  801e9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea2:	31 d2                	xor    %edx,%edx
  801ea4:	f7 f1                	div    %ecx
  801ea6:	89 c6                	mov    %eax,%esi
  801ea8:	31 d2                	xor    %edx,%edx
  801eaa:	89 e8                	mov    %ebp,%eax
  801eac:	f7 f6                	div    %esi
  801eae:	89 c5                	mov    %eax,%ebp
  801eb0:	89 f8                	mov    %edi,%eax
  801eb2:	f7 f6                	div    %esi
  801eb4:	89 ea                	mov    %ebp,%edx
  801eb6:	83 c4 0c             	add    $0xc,%esp
  801eb9:	5e                   	pop    %esi
  801eba:	5f                   	pop    %edi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	39 e8                	cmp    %ebp,%eax
  801ec2:	77 24                	ja     801ee8 <__udivdi3+0x78>
  801ec4:	0f bd e8             	bsr    %eax,%ebp
  801ec7:	83 f5 1f             	xor    $0x1f,%ebp
  801eca:	75 3c                	jne    801f08 <__udivdi3+0x98>
  801ecc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ed0:	39 34 24             	cmp    %esi,(%esp)
  801ed3:	0f 86 9f 00 00 00    	jbe    801f78 <__udivdi3+0x108>
  801ed9:	39 d0                	cmp    %edx,%eax
  801edb:	0f 82 97 00 00 00    	jb     801f78 <__udivdi3+0x108>
  801ee1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ee8:	31 d2                	xor    %edx,%edx
  801eea:	31 c0                	xor    %eax,%eax
  801eec:	83 c4 0c             	add    $0xc,%esp
  801eef:	5e                   	pop    %esi
  801ef0:	5f                   	pop    %edi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    
  801ef3:	90                   	nop
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	89 f8                	mov    %edi,%eax
  801efa:	f7 f1                	div    %ecx
  801efc:	31 d2                	xor    %edx,%edx
  801efe:	83 c4 0c             	add    $0xc,%esp
  801f01:	5e                   	pop    %esi
  801f02:	5f                   	pop    %edi
  801f03:	5d                   	pop    %ebp
  801f04:	c3                   	ret    
  801f05:	8d 76 00             	lea    0x0(%esi),%esi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	8b 3c 24             	mov    (%esp),%edi
  801f0d:	d3 e0                	shl    %cl,%eax
  801f0f:	89 c6                	mov    %eax,%esi
  801f11:	b8 20 00 00 00       	mov    $0x20,%eax
  801f16:	29 e8                	sub    %ebp,%eax
  801f18:	89 c1                	mov    %eax,%ecx
  801f1a:	d3 ef                	shr    %cl,%edi
  801f1c:	89 e9                	mov    %ebp,%ecx
  801f1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f22:	8b 3c 24             	mov    (%esp),%edi
  801f25:	09 74 24 08          	or     %esi,0x8(%esp)
  801f29:	89 d6                	mov    %edx,%esi
  801f2b:	d3 e7                	shl    %cl,%edi
  801f2d:	89 c1                	mov    %eax,%ecx
  801f2f:	89 3c 24             	mov    %edi,(%esp)
  801f32:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f36:	d3 ee                	shr    %cl,%esi
  801f38:	89 e9                	mov    %ebp,%ecx
  801f3a:	d3 e2                	shl    %cl,%edx
  801f3c:	89 c1                	mov    %eax,%ecx
  801f3e:	d3 ef                	shr    %cl,%edi
  801f40:	09 d7                	or     %edx,%edi
  801f42:	89 f2                	mov    %esi,%edx
  801f44:	89 f8                	mov    %edi,%eax
  801f46:	f7 74 24 08          	divl   0x8(%esp)
  801f4a:	89 d6                	mov    %edx,%esi
  801f4c:	89 c7                	mov    %eax,%edi
  801f4e:	f7 24 24             	mull   (%esp)
  801f51:	39 d6                	cmp    %edx,%esi
  801f53:	89 14 24             	mov    %edx,(%esp)
  801f56:	72 30                	jb     801f88 <__udivdi3+0x118>
  801f58:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f5c:	89 e9                	mov    %ebp,%ecx
  801f5e:	d3 e2                	shl    %cl,%edx
  801f60:	39 c2                	cmp    %eax,%edx
  801f62:	73 05                	jae    801f69 <__udivdi3+0xf9>
  801f64:	3b 34 24             	cmp    (%esp),%esi
  801f67:	74 1f                	je     801f88 <__udivdi3+0x118>
  801f69:	89 f8                	mov    %edi,%eax
  801f6b:	31 d2                	xor    %edx,%edx
  801f6d:	e9 7a ff ff ff       	jmp    801eec <__udivdi3+0x7c>
  801f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f78:	31 d2                	xor    %edx,%edx
  801f7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7f:	e9 68 ff ff ff       	jmp    801eec <__udivdi3+0x7c>
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f8b:	31 d2                	xor    %edx,%edx
  801f8d:	83 c4 0c             	add    $0xc,%esp
  801f90:	5e                   	pop    %esi
  801f91:	5f                   	pop    %edi
  801f92:	5d                   	pop    %ebp
  801f93:	c3                   	ret    
  801f94:	66 90                	xchg   %ax,%ax
  801f96:	66 90                	xchg   %ax,%ax
  801f98:	66 90                	xchg   %ax,%ax
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__umoddi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	83 ec 14             	sub    $0x14,%esp
  801fa6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801faa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801fae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801fb2:	89 c7                	mov    %eax,%edi
  801fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fbc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801fc0:	89 34 24             	mov    %esi,(%esp)
  801fc3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	89 c2                	mov    %eax,%edx
  801fcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fcf:	75 17                	jne    801fe8 <__umoddi3+0x48>
  801fd1:	39 fe                	cmp    %edi,%esi
  801fd3:	76 4b                	jbe    802020 <__umoddi3+0x80>
  801fd5:	89 c8                	mov    %ecx,%eax
  801fd7:	89 fa                	mov    %edi,%edx
  801fd9:	f7 f6                	div    %esi
  801fdb:	89 d0                	mov    %edx,%eax
  801fdd:	31 d2                	xor    %edx,%edx
  801fdf:	83 c4 14             	add    $0x14,%esp
  801fe2:	5e                   	pop    %esi
  801fe3:	5f                   	pop    %edi
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    
  801fe6:	66 90                	xchg   %ax,%ax
  801fe8:	39 f8                	cmp    %edi,%eax
  801fea:	77 54                	ja     802040 <__umoddi3+0xa0>
  801fec:	0f bd e8             	bsr    %eax,%ebp
  801fef:	83 f5 1f             	xor    $0x1f,%ebp
  801ff2:	75 5c                	jne    802050 <__umoddi3+0xb0>
  801ff4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ff8:	39 3c 24             	cmp    %edi,(%esp)
  801ffb:	0f 87 e7 00 00 00    	ja     8020e8 <__umoddi3+0x148>
  802001:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802005:	29 f1                	sub    %esi,%ecx
  802007:	19 c7                	sbb    %eax,%edi
  802009:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80200d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802011:	8b 44 24 08          	mov    0x8(%esp),%eax
  802015:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802019:	83 c4 14             	add    $0x14,%esp
  80201c:	5e                   	pop    %esi
  80201d:	5f                   	pop    %edi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    
  802020:	85 f6                	test   %esi,%esi
  802022:	89 f5                	mov    %esi,%ebp
  802024:	75 0b                	jne    802031 <__umoddi3+0x91>
  802026:	b8 01 00 00 00       	mov    $0x1,%eax
  80202b:	31 d2                	xor    %edx,%edx
  80202d:	f7 f6                	div    %esi
  80202f:	89 c5                	mov    %eax,%ebp
  802031:	8b 44 24 04          	mov    0x4(%esp),%eax
  802035:	31 d2                	xor    %edx,%edx
  802037:	f7 f5                	div    %ebp
  802039:	89 c8                	mov    %ecx,%eax
  80203b:	f7 f5                	div    %ebp
  80203d:	eb 9c                	jmp    801fdb <__umoddi3+0x3b>
  80203f:	90                   	nop
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 fa                	mov    %edi,%edx
  802044:	83 c4 14             	add    $0x14,%esp
  802047:	5e                   	pop    %esi
  802048:	5f                   	pop    %edi
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    
  80204b:	90                   	nop
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	8b 04 24             	mov    (%esp),%eax
  802053:	be 20 00 00 00       	mov    $0x20,%esi
  802058:	89 e9                	mov    %ebp,%ecx
  80205a:	29 ee                	sub    %ebp,%esi
  80205c:	d3 e2                	shl    %cl,%edx
  80205e:	89 f1                	mov    %esi,%ecx
  802060:	d3 e8                	shr    %cl,%eax
  802062:	89 e9                	mov    %ebp,%ecx
  802064:	89 44 24 04          	mov    %eax,0x4(%esp)
  802068:	8b 04 24             	mov    (%esp),%eax
  80206b:	09 54 24 04          	or     %edx,0x4(%esp)
  80206f:	89 fa                	mov    %edi,%edx
  802071:	d3 e0                	shl    %cl,%eax
  802073:	89 f1                	mov    %esi,%ecx
  802075:	89 44 24 08          	mov    %eax,0x8(%esp)
  802079:	8b 44 24 10          	mov    0x10(%esp),%eax
  80207d:	d3 ea                	shr    %cl,%edx
  80207f:	89 e9                	mov    %ebp,%ecx
  802081:	d3 e7                	shl    %cl,%edi
  802083:	89 f1                	mov    %esi,%ecx
  802085:	d3 e8                	shr    %cl,%eax
  802087:	89 e9                	mov    %ebp,%ecx
  802089:	09 f8                	or     %edi,%eax
  80208b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80208f:	f7 74 24 04          	divl   0x4(%esp)
  802093:	d3 e7                	shl    %cl,%edi
  802095:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802099:	89 d7                	mov    %edx,%edi
  80209b:	f7 64 24 08          	mull   0x8(%esp)
  80209f:	39 d7                	cmp    %edx,%edi
  8020a1:	89 c1                	mov    %eax,%ecx
  8020a3:	89 14 24             	mov    %edx,(%esp)
  8020a6:	72 2c                	jb     8020d4 <__umoddi3+0x134>
  8020a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8020ac:	72 22                	jb     8020d0 <__umoddi3+0x130>
  8020ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020b2:	29 c8                	sub    %ecx,%eax
  8020b4:	19 d7                	sbb    %edx,%edi
  8020b6:	89 e9                	mov    %ebp,%ecx
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	d3 e8                	shr    %cl,%eax
  8020bc:	89 f1                	mov    %esi,%ecx
  8020be:	d3 e2                	shl    %cl,%edx
  8020c0:	89 e9                	mov    %ebp,%ecx
  8020c2:	d3 ef                	shr    %cl,%edi
  8020c4:	09 d0                	or     %edx,%eax
  8020c6:	89 fa                	mov    %edi,%edx
  8020c8:	83 c4 14             	add    $0x14,%esp
  8020cb:	5e                   	pop    %esi
  8020cc:	5f                   	pop    %edi
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    
  8020cf:	90                   	nop
  8020d0:	39 d7                	cmp    %edx,%edi
  8020d2:	75 da                	jne    8020ae <__umoddi3+0x10e>
  8020d4:	8b 14 24             	mov    (%esp),%edx
  8020d7:	89 c1                	mov    %eax,%ecx
  8020d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8020dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8020e1:	eb cb                	jmp    8020ae <__umoddi3+0x10e>
  8020e3:	90                   	nop
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8020ec:	0f 82 0f ff ff ff    	jb     802001 <__umoddi3+0x61>
  8020f2:	e9 1a ff ff ff       	jmp    802011 <__umoddi3+0x71>
