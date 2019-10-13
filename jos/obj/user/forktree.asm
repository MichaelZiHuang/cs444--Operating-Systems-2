
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 c2 00 00 00       	call   8000f3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 c3 0b 00 00       	call   800c05 <sys_getenvid>
  800042:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 40 24 80 00 	movl   $0x802440,(%esp)
  800051:	e8 a1 01 00 00       	call   8001f7 <cprintf>

	forkchild(cur, '0');
  800056:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005d:	00 
  80005e:	89 1c 24             	mov    %ebx,(%esp)
  800061:	e8 16 00 00 00       	call   80007c <forkchild>
	forkchild(cur, '1');
  800066:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006d:	00 
  80006e:	89 1c 24             	mov    %ebx,(%esp)
  800071:	e8 06 00 00 00       	call   80007c <forkchild>
}
  800076:	83 c4 14             	add    $0x14,%esp
  800079:	5b                   	pop    %ebx
  80007a:	5d                   	pop    %ebp
  80007b:	c3                   	ret    

0080007c <forkchild>:
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	83 ec 30             	sub    $0x30,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80008a:	89 1c 24             	mov    %ebx,(%esp)
  80008d:	e8 5e 07 00 00       	call   8007f0 <strlen>
  800092:	83 f8 02             	cmp    $0x2,%eax
  800095:	7f 41                	jg     8000d8 <forkchild+0x5c>
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800097:	89 f0                	mov    %esi,%eax
  800099:	0f be f0             	movsbl %al,%esi
  80009c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a4:	c7 44 24 08 51 24 80 	movl   $0x802451,0x8(%esp)
  8000ab:	00 
  8000ac:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b3:	00 
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	89 04 24             	mov    %eax,(%esp)
  8000ba:	e8 06 07 00 00       	call   8007c5 <snprintf>
	if (fork() == 0) {
  8000bf:	e8 0e 0f 00 00       	call   800fd2 <fork>
  8000c4:	85 c0                	test   %eax,%eax
  8000c6:	75 10                	jne    8000d8 <forkchild+0x5c>
		forktree(nxt);
  8000c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cb:	89 04 24             	mov    %eax,(%esp)
  8000ce:	e8 60 ff ff ff       	call   800033 <forktree>
		exit();
  8000d3:	e8 63 00 00 00       	call   80013b <exit>
}
  8000d8:	83 c4 30             	add    $0x30,%esp
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <umain>:

void
umain(int argc, char **argv)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e5:	c7 04 24 50 24 80 00 	movl   $0x802450,(%esp)
  8000ec:	e8 42 ff ff ff       	call   800033 <forktree>
}
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 10             	sub    $0x10,%esp
  8000fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800101:	e8 ff 0a 00 00       	call   800c05 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	85 db                	test   %ebx,%ebx
  80011a:	7e 07                	jle    800123 <libmain+0x30>
		binaryname = argv[0];
  80011c:	8b 06                	mov    (%esi),%eax
  80011e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800123:	89 74 24 04          	mov    %esi,0x4(%esp)
  800127:	89 1c 24             	mov    %ebx,(%esp)
  80012a:	e8 b0 ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  80012f:	e8 07 00 00 00       	call   80013b <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800141:	e8 5f 12 00 00       	call   8013a5 <close_all>
	sys_env_destroy(0);
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 61 0a 00 00       	call   800bb3 <sys_env_destroy>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	53                   	push   %ebx
  800158:	83 ec 14             	sub    $0x14,%esp
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015e:	8b 13                	mov    (%ebx),%edx
  800160:	8d 42 01             	lea    0x1(%edx),%eax
  800163:	89 03                	mov    %eax,(%ebx)
  800165:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800168:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800171:	75 19                	jne    80018c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800173:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017a:	00 
  80017b:	8d 43 08             	lea    0x8(%ebx),%eax
  80017e:	89 04 24             	mov    %eax,(%esp)
  800181:	e8 f0 09 00 00       	call   800b76 <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80018c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800190:	83 c4 14             	add    $0x14,%esp
  800193:	5b                   	pop    %ebx
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    

00800196 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80019f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a6:	00 00 00 
	b.cnt = 0;
  8001a9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cb:	c7 04 24 54 01 80 00 	movl   $0x800154,(%esp)
  8001d2:	e8 b7 01 00 00       	call   80038e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e7:	89 04 24             	mov    %eax,(%esp)
  8001ea:	e8 87 09 00 00       	call   800b76 <sys_cputs>

	return b.cnt;
}
  8001ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	8b 45 08             	mov    0x8(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	e8 87 ff ff ff       	call   800196 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    
  800211:	66 90                	xchg   %ax,%ax
  800213:	66 90                	xchg   %ax,%ax
  800215:	66 90                	xchg   %ax,%ax
  800217:	66 90                	xchg   %ax,%ax
  800219:	66 90                	xchg   %ax,%ax
  80021b:	66 90                	xchg   %ax,%ax
  80021d:	66 90                	xchg   %ax,%ax
  80021f:	90                   	nop

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 c3                	mov    %eax,%ebx
  800239:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80023c:	8b 45 10             	mov    0x10(%ebp),%eax
  80023f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	b9 00 00 00 00       	mov    $0x0,%ecx
  800247:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024d:	39 d9                	cmp    %ebx,%ecx
  80024f:	72 05                	jb     800256 <printnum+0x36>
  800251:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800254:	77 69                	ja     8002bf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800259:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80025d:	83 ee 01             	sub    $0x1,%esi
  800260:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	8b 44 24 08          	mov    0x8(%esp),%eax
  80026c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800270:	89 c3                	mov    %eax,%ebx
  800272:	89 d6                	mov    %edx,%esi
  800274:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800277:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80027a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80027e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	e8 0c 1f 00 00       	call   8021a0 <__udivdi3>
  800294:	89 d9                	mov    %ebx,%ecx
  800296:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80029a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80029e:	89 04 24             	mov    %eax,(%esp)
  8002a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a5:	89 fa                	mov    %edi,%edx
  8002a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002aa:	e8 71 ff ff ff       	call   800220 <printnum>
  8002af:	eb 1b                	jmp    8002cc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff d3                	call   *%ebx
  8002bd:	eb 03                	jmp    8002c2 <printnum+0xa2>
  8002bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8002c2:	83 ee 01             	sub    $0x1,%esi
  8002c5:	85 f6                	test   %esi,%esi
  8002c7:	7f e8                	jg     8002b1 <printnum+0x91>
  8002c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 dc 1f 00 00       	call   8022d0 <__umoddi3>
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	0f be 80 60 24 80 00 	movsbl 0x802460(%eax),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800305:	ff d0                	call   *%eax
}
  800307:	83 c4 3c             	add    $0x3c,%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800312:	83 fa 01             	cmp    $0x1,%edx
  800315:	7e 0e                	jle    800325 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800317:	8b 10                	mov    (%eax),%edx
  800319:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031c:	89 08                	mov    %ecx,(%eax)
  80031e:	8b 02                	mov    (%edx),%eax
  800320:	8b 52 04             	mov    0x4(%edx),%edx
  800323:	eb 22                	jmp    800347 <getuint+0x38>
	else if (lflag)
  800325:	85 d2                	test   %edx,%edx
  800327:	74 10                	je     800339 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032e:	89 08                	mov    %ecx,(%eax)
  800330:	8b 02                	mov    (%edx),%eax
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
  800337:	eb 0e                	jmp    800347 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033e:	89 08                	mov    %ecx,(%eax)
  800340:	8b 02                	mov    (%edx),%eax
  800342:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 0a                	jae    800364 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	88 02                	mov    %al,(%edx)
}
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <printfmt>:
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80036c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800373:	8b 45 10             	mov    0x10(%ebp),%eax
  800376:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	89 04 24             	mov    %eax,(%esp)
  800387:	e8 02 00 00 00       	call   80038e <vprintfmt>
}
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <vprintfmt>:
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
  800394:	83 ec 3c             	sub    $0x3c,%esp
  800397:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80039a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039d:	eb 1f                	jmp    8003be <vprintfmt+0x30>
			if (ch == '\0'){
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	75 0f                	jne    8003b2 <vprintfmt+0x24>
				color = 0x0100;
  8003a3:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  8003aa:	01 00 00 
  8003ad:	e9 b3 03 00 00       	jmp    800765 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8003b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b6:	89 04 24             	mov    %eax,(%esp)
  8003b9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bc:	89 f3                	mov    %esi,%ebx
  8003be:	8d 73 01             	lea    0x1(%ebx),%esi
  8003c1:	0f b6 03             	movzbl (%ebx),%eax
  8003c4:	83 f8 25             	cmp    $0x25,%eax
  8003c7:	75 d6                	jne    80039f <vprintfmt+0x11>
  8003c9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003cd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003db:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e7:	eb 1d                	jmp    800406 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	89 de                	mov    %ebx,%esi
			padc = '-';
  8003eb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ef:	eb 15                	jmp    800406 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	89 de                	mov    %ebx,%esi
			padc = '0';
  8003f3:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003f7:	eb 0d                	jmp    800406 <vprintfmt+0x78>
				width = precision, precision = -1;
  8003f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003ff:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8d 5e 01             	lea    0x1(%esi),%ebx
  800409:	0f b6 0e             	movzbl (%esi),%ecx
  80040c:	0f b6 c1             	movzbl %cl,%eax
  80040f:	83 e9 23             	sub    $0x23,%ecx
  800412:	80 f9 55             	cmp    $0x55,%cl
  800415:	0f 87 2a 03 00 00    	ja     800745 <vprintfmt+0x3b7>
  80041b:	0f b6 c9             	movzbl %cl,%ecx
  80041e:	ff 24 8d a0 25 80 00 	jmp    *0x8025a0(,%ecx,4)
  800425:	89 de                	mov    %ebx,%esi
  800427:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80042c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80042f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800433:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800436:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800439:	83 fb 09             	cmp    $0x9,%ebx
  80043c:	77 36                	ja     800474 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80043e:	83 c6 01             	add    $0x1,%esi
			}
  800441:	eb e9                	jmp    80042c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 48 04             	lea    0x4(%eax),%ecx
  800449:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800451:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800453:	eb 22                	jmp    800477 <vprintfmt+0xe9>
  800455:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800458:	85 c9                	test   %ecx,%ecx
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	0f 49 c1             	cmovns %ecx,%eax
  800462:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800465:	89 de                	mov    %ebx,%esi
  800467:	eb 9d                	jmp    800406 <vprintfmt+0x78>
  800469:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80046b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800472:	eb 92                	jmp    800406 <vprintfmt+0x78>
  800474:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800477:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80047b:	79 89                	jns    800406 <vprintfmt+0x78>
  80047d:	e9 77 ff ff ff       	jmp    8003f9 <vprintfmt+0x6b>
			lflag++;
  800482:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800485:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800487:	e9 7a ff ff ff       	jmp    800406 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a1:	e9 18 ff ff ff       	jmp    8003be <vprintfmt+0x30>
			err = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	99                   	cltd   
  8004b2:	31 d0                	xor    %edx,%eax
  8004b4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b6:	83 f8 0f             	cmp    $0xf,%eax
  8004b9:	7f 0b                	jg     8004c6 <vprintfmt+0x138>
  8004bb:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8004c2:	85 d2                	test   %edx,%edx
  8004c4:	75 20                	jne    8004e6 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  8004c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ca:	c7 44 24 08 78 24 80 	movl   $0x802478,0x8(%esp)
  8004d1:	00 
  8004d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	e8 85 fe ff ff       	call   800366 <printfmt>
  8004e1:	e9 d8 fe ff ff       	jmp    8003be <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  8004e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ea:	c7 44 24 08 ba 29 80 	movl   $0x8029ba,0x8(%esp)
  8004f1:	00 
  8004f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	89 04 24             	mov    %eax,(%esp)
  8004fc:	e8 65 fe ff ff       	call   800366 <printfmt>
  800501:	e9 b8 fe ff ff       	jmp    8003be <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800509:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80050c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 50 04             	lea    0x4(%eax),%edx
  800515:	89 55 14             	mov    %edx,0x14(%ebp)
  800518:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80051a:	85 f6                	test   %esi,%esi
  80051c:	b8 71 24 80 00       	mov    $0x802471,%eax
  800521:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800524:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800528:	0f 84 97 00 00 00    	je     8005c5 <vprintfmt+0x237>
  80052e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800532:	0f 8e 9b 00 00 00    	jle    8005d3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053c:	89 34 24             	mov    %esi,(%esp)
  80053f:	e8 c4 02 00 00       	call   800808 <strnlen>
  800544:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800547:	29 c2                	sub    %eax,%edx
  800549:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80054c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800550:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800553:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800556:	8b 75 08             	mov    0x8(%ebp),%esi
  800559:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80055c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	eb 0f                	jmp    80056f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800560:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800564:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800567:	89 04 24             	mov    %eax,(%esp)
  80056a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	83 eb 01             	sub    $0x1,%ebx
  80056f:	85 db                	test   %ebx,%ebx
  800571:	7f ed                	jg     800560 <vprintfmt+0x1d2>
  800573:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800576:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800579:	85 d2                	test   %edx,%edx
  80057b:	b8 00 00 00 00       	mov    $0x0,%eax
  800580:	0f 49 c2             	cmovns %edx,%eax
  800583:	29 c2                	sub    %eax,%edx
  800585:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800588:	89 d7                	mov    %edx,%edi
  80058a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80058d:	eb 50                	jmp    8005df <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80058f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800593:	74 1e                	je     8005b3 <vprintfmt+0x225>
  800595:	0f be d2             	movsbl %dl,%edx
  800598:	83 ea 20             	sub    $0x20,%edx
  80059b:	83 fa 5e             	cmp    $0x5e,%edx
  80059e:	76 13                	jbe    8005b3 <vprintfmt+0x225>
					putch('?', putdat);
  8005a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	eb 0d                	jmp    8005c0 <vprintfmt+0x232>
					putch(ch, putdat);
  8005b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c0:	83 ef 01             	sub    $0x1,%edi
  8005c3:	eb 1a                	jmp    8005df <vprintfmt+0x251>
  8005c5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005c8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005cb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005ce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005d1:	eb 0c                	jmp    8005df <vprintfmt+0x251>
  8005d3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005d6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005df:	83 c6 01             	add    $0x1,%esi
  8005e2:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005e6:	0f be c2             	movsbl %dl,%eax
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	74 27                	je     800614 <vprintfmt+0x286>
  8005ed:	85 db                	test   %ebx,%ebx
  8005ef:	78 9e                	js     80058f <vprintfmt+0x201>
  8005f1:	83 eb 01             	sub    $0x1,%ebx
  8005f4:	79 99                	jns    80058f <vprintfmt+0x201>
  8005f6:	89 f8                	mov    %edi,%eax
  8005f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	89 c3                	mov    %eax,%ebx
  800600:	eb 1a                	jmp    80061c <vprintfmt+0x28e>
				putch(' ', putdat);
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80060f:	83 eb 01             	sub    $0x1,%ebx
  800612:	eb 08                	jmp    80061c <vprintfmt+0x28e>
  800614:	89 fb                	mov    %edi,%ebx
  800616:	8b 75 08             	mov    0x8(%ebp),%esi
  800619:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80061c:	85 db                	test   %ebx,%ebx
  80061e:	7f e2                	jg     800602 <vprintfmt+0x274>
  800620:	89 75 08             	mov    %esi,0x8(%ebp)
  800623:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800626:	e9 93 fd ff ff       	jmp    8003be <vprintfmt+0x30>
	if (lflag >= 2)
  80062b:	83 fa 01             	cmp    $0x1,%edx
  80062e:	7e 16                	jle    800646 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 08             	lea    0x8(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	8b 50 04             	mov    0x4(%eax),%edx
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800641:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800644:	eb 32                	jmp    800678 <vprintfmt+0x2ea>
	else if (lflag)
  800646:	85 d2                	test   %edx,%edx
  800648:	74 18                	je     800662 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 30                	mov    (%eax),%esi
  800655:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800658:	89 f0                	mov    %esi,%eax
  80065a:	c1 f8 1f             	sar    $0x1f,%eax
  80065d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800660:	eb 16                	jmp    800678 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	8b 30                	mov    (%eax),%esi
  80066d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800670:	89 f0                	mov    %esi,%eax
  800672:	c1 f8 1f             	sar    $0x1f,%eax
  800675:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800678:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80067e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800683:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800687:	0f 89 80 00 00 00    	jns    80070d <vprintfmt+0x37f>
				putch('-', putdat);
  80068d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800691:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80069b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a1:	f7 d8                	neg    %eax
  8006a3:	83 d2 00             	adc    $0x0,%edx
  8006a6:	f7 da                	neg    %edx
			base = 10;
  8006a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ad:	eb 5e                	jmp    80070d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b2:	e8 58 fc ff ff       	call   80030f <getuint>
			base = 10;
  8006b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006bc:	eb 4f                	jmp    80070d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c1:	e8 49 fc ff ff       	call   80030f <getuint>
            base = 8;
  8006c6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  8006cb:	eb 40                	jmp    80070d <vprintfmt+0x37f>
			putch('0', putdat);
  8006cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006df:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e6:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8006f9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006fe:	eb 0d                	jmp    80070d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800700:	8d 45 14             	lea    0x14(%ebp),%eax
  800703:	e8 07 fc ff ff       	call   80030f <getuint>
			base = 16;
  800708:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80070d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800711:	89 74 24 10          	mov    %esi,0x10(%esp)
  800715:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800718:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	89 54 24 04          	mov    %edx,0x4(%esp)
  800727:	89 fa                	mov    %edi,%edx
  800729:	8b 45 08             	mov    0x8(%ebp),%eax
  80072c:	e8 ef fa ff ff       	call   800220 <printnum>
			break;
  800731:	e9 88 fc ff ff       	jmp    8003be <vprintfmt+0x30>
			putch(ch, putdat);
  800736:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073a:	89 04 24             	mov    %eax,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800740:	e9 79 fc ff ff       	jmp    8003be <vprintfmt+0x30>
			putch('%', putdat);
  800745:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800749:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800750:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800753:	89 f3                	mov    %esi,%ebx
  800755:	eb 03                	jmp    80075a <vprintfmt+0x3cc>
  800757:	83 eb 01             	sub    $0x1,%ebx
  80075a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80075e:	75 f7                	jne    800757 <vprintfmt+0x3c9>
  800760:	e9 59 fc ff ff       	jmp    8003be <vprintfmt+0x30>
}
  800765:	83 c4 3c             	add    $0x3c,%esp
  800768:	5b                   	pop    %ebx
  800769:	5e                   	pop    %esi
  80076a:	5f                   	pop    %edi
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 28             	sub    $0x28,%esp
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800779:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800780:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800783:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078a:	85 c0                	test   %eax,%eax
  80078c:	74 30                	je     8007be <vsnprintf+0x51>
  80078e:	85 d2                	test   %edx,%edx
  800790:	7e 2c                	jle    8007be <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800799:	8b 45 10             	mov    0x10(%ebp),%eax
  80079c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a7:	c7 04 24 49 03 80 00 	movl   $0x800349,(%esp)
  8007ae:	e8 db fb ff ff       	call   80038e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bc:	eb 05                	jmp    8007c3 <vsnprintf+0x56>
		return -E_INVAL;
  8007be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	89 04 24             	mov    %eax,(%esp)
  8007e6:	e8 82 ff ff ff       	call   80076d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
  8007ed:	66 90                	xchg   %ax,%ax
  8007ef:	90                   	nop

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	eb 03                	jmp    800800 <strlen+0x10>
		n++;
  8007fd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800800:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800804:	75 f7                	jne    8007fd <strlen+0xd>
	return n;
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	eb 03                	jmp    80081b <strnlen+0x13>
		n++;
  800818:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	39 d0                	cmp    %edx,%eax
  80081d:	74 06                	je     800825 <strnlen+0x1d>
  80081f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800823:	75 f3                	jne    800818 <strnlen+0x10>
	return n;
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	83 c1 01             	add    $0x1,%ecx
  800839:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800840:	84 db                	test   %bl,%bl
  800842:	75 ef                	jne    800833 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800844:	5b                   	pop    %ebx
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800851:	89 1c 24             	mov    %ebx,(%esp)
  800854:	e8 97 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800860:	01 d8                	add    %ebx,%eax
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	e8 bd ff ff ff       	call   800827 <strcpy>
	return dst;
}
  80086a:	89 d8                	mov    %ebx,%eax
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 75 08             	mov    0x8(%ebp),%esi
  80087a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087d:	89 f3                	mov    %esi,%ebx
  80087f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	89 f2                	mov    %esi,%edx
  800884:	eb 0f                	jmp    800895 <strncpy+0x23>
		*dst++ = *src;
  800886:	83 c2 01             	add    $0x1,%edx
  800889:	0f b6 01             	movzbl (%ecx),%eax
  80088c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088f:	80 39 01             	cmpb   $0x1,(%ecx)
  800892:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800895:	39 da                	cmp    %ebx,%edx
  800897:	75 ed                	jne    800886 <strncpy+0x14>
	}
	return ret;
}
  800899:	89 f0                	mov    %esi,%eax
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ad:	89 f0                	mov    %esi,%eax
  8008af:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	85 c9                	test   %ecx,%ecx
  8008b5:	75 0b                	jne    8008c2 <strlcpy+0x23>
  8008b7:	eb 1d                	jmp    8008d6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
  8008bf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008c2:	39 d8                	cmp    %ebx,%eax
  8008c4:	74 0b                	je     8008d1 <strlcpy+0x32>
  8008c6:	0f b6 0a             	movzbl (%edx),%ecx
  8008c9:	84 c9                	test   %cl,%cl
  8008cb:	75 ec                	jne    8008b9 <strlcpy+0x1a>
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	eb 02                	jmp    8008d3 <strlcpy+0x34>
  8008d1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  8008d3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008d6:	29 f0                	sub    %esi,%eax
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e5:	eb 06                	jmp    8008ed <strcmp+0x11>
		p++, q++;
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	84 c0                	test   %al,%al
  8008f2:	74 04                	je     8008f8 <strcmp+0x1c>
  8008f4:	3a 02                	cmp    (%edx),%al
  8008f6:	74 ef                	je     8008e7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 c0             	movzbl %al,%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 c3                	mov    %eax,%ebx
  80090e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800911:	eb 06                	jmp    800919 <strncmp+0x17>
		n--, p++, q++;
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800919:	39 d8                	cmp    %ebx,%eax
  80091b:	74 15                	je     800932 <strncmp+0x30>
  80091d:	0f b6 08             	movzbl (%eax),%ecx
  800920:	84 c9                	test   %cl,%cl
  800922:	74 04                	je     800928 <strncmp+0x26>
  800924:	3a 0a                	cmp    (%edx),%cl
  800926:	74 eb                	je     800913 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 00             	movzbl (%eax),%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
  800930:	eb 05                	jmp    800937 <strncmp+0x35>
		return 0;
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	eb 07                	jmp    80094d <strchr+0x13>
		if (*s == c)
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 0f                	je     800959 <strchr+0x1f>
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strchr+0xc>
			return (char *) s;
	return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	eb 07                	jmp    80096e <strfind+0x13>
		if (*s == c)
  800967:	38 ca                	cmp    %cl,%dl
  800969:	74 0a                	je     800975 <strfind+0x1a>
	for (; *s; s++)
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
  800971:	84 d2                	test   %dl,%dl
  800973:	75 f2                	jne    800967 <strfind+0xc>
			break;
	return (char *) s;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800983:	85 c9                	test   %ecx,%ecx
  800985:	74 36                	je     8009bd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800987:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098d:	75 28                	jne    8009b7 <memset+0x40>
  80098f:	f6 c1 03             	test   $0x3,%cl
  800992:	75 23                	jne    8009b7 <memset+0x40>
		c &= 0xFF;
  800994:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800998:	89 d3                	mov    %edx,%ebx
  80099a:	c1 e3 08             	shl    $0x8,%ebx
  80099d:	89 d6                	mov    %edx,%esi
  80099f:	c1 e6 18             	shl    $0x18,%esi
  8009a2:	89 d0                	mov    %edx,%eax
  8009a4:	c1 e0 10             	shl    $0x10,%eax
  8009a7:	09 f0                	or     %esi,%eax
  8009a9:	09 c2                	or     %eax,%edx
  8009ab:	89 d0                	mov    %edx,%eax
  8009ad:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009af:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009b2:	fc                   	cld    
  8009b3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b5:	eb 06                	jmp    8009bd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ba:	fc                   	cld    
  8009bb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5f                   	pop    %edi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d2:	39 c6                	cmp    %eax,%esi
  8009d4:	73 35                	jae    800a0b <memmove+0x47>
  8009d6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d9:	39 d0                	cmp    %edx,%eax
  8009db:	73 2e                	jae    800a0b <memmove+0x47>
		s += n;
		d += n;
  8009dd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009e0:	89 d6                	mov    %edx,%esi
  8009e2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ea:	75 13                	jne    8009ff <memmove+0x3b>
  8009ec:	f6 c1 03             	test   $0x3,%cl
  8009ef:	75 0e                	jne    8009ff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f1:	83 ef 04             	sub    $0x4,%edi
  8009f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009fa:	fd                   	std    
  8009fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fd:	eb 09                	jmp    800a08 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ff:	83 ef 01             	sub    $0x1,%edi
  800a02:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a05:	fd                   	std    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a08:	fc                   	cld    
  800a09:	eb 1d                	jmp    800a28 <memmove+0x64>
  800a0b:	89 f2                	mov    %esi,%edx
  800a0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	f6 c2 03             	test   $0x3,%dl
  800a12:	75 0f                	jne    800a23 <memmove+0x5f>
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 0a                	jne    800a23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a19:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a1c:	89 c7                	mov    %eax,%edi
  800a1e:	fc                   	cld    
  800a1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a21:	eb 05                	jmp    800a28 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	fc                   	cld    
  800a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a32:	8b 45 10             	mov    0x10(%ebp),%eax
  800a35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	89 04 24             	mov    %eax,(%esp)
  800a46:	e8 79 ff ff ff       	call   8009c4 <memmove>
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 55 08             	mov    0x8(%ebp),%edx
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a58:	89 d6                	mov    %edx,%esi
  800a5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5d:	eb 1a                	jmp    800a79 <memcmp+0x2c>
		if (*s1 != *s2)
  800a5f:	0f b6 02             	movzbl (%edx),%eax
  800a62:	0f b6 19             	movzbl (%ecx),%ebx
  800a65:	38 d8                	cmp    %bl,%al
  800a67:	74 0a                	je     800a73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a69:	0f b6 c0             	movzbl %al,%eax
  800a6c:	0f b6 db             	movzbl %bl,%ebx
  800a6f:	29 d8                	sub    %ebx,%eax
  800a71:	eb 0f                	jmp    800a82 <memcmp+0x35>
		s1++, s2++;
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800a79:	39 f2                	cmp    %esi,%edx
  800a7b:	75 e2                	jne    800a5f <memcmp+0x12>
	}

	return 0;
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8f:	89 c2                	mov    %eax,%edx
  800a91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a94:	eb 07                	jmp    800a9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 07                	je     800aa1 <memfind+0x1b>
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	72 f5                	jb     800a96 <memfind+0x10>
			break;
	return (void *) s;
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	eb 03                	jmp    800ab4 <strtol+0x11>
		s++;
  800ab1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ab4:	0f b6 0a             	movzbl (%edx),%ecx
  800ab7:	80 f9 09             	cmp    $0x9,%cl
  800aba:	74 f5                	je     800ab1 <strtol+0xe>
  800abc:	80 f9 20             	cmp    $0x20,%cl
  800abf:	74 f0                	je     800ab1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ac1:	80 f9 2b             	cmp    $0x2b,%cl
  800ac4:	75 0a                	jne    800ad0 <strtol+0x2d>
		s++;
  800ac6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ace:	eb 11                	jmp    800ae1 <strtol+0x3e>
  800ad0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800ad5:	80 f9 2d             	cmp    $0x2d,%cl
  800ad8:	75 07                	jne    800ae1 <strtol+0x3e>
		s++, neg = 1;
  800ada:	8d 52 01             	lea    0x1(%edx),%edx
  800add:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ae6:	75 15                	jne    800afd <strtol+0x5a>
  800ae8:	80 3a 30             	cmpb   $0x30,(%edx)
  800aeb:	75 10                	jne    800afd <strtol+0x5a>
  800aed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800af1:	75 0a                	jne    800afd <strtol+0x5a>
		s += 2, base = 16;
  800af3:	83 c2 02             	add    $0x2,%edx
  800af6:	b8 10 00 00 00       	mov    $0x10,%eax
  800afb:	eb 10                	jmp    800b0d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800afd:	85 c0                	test   %eax,%eax
  800aff:	75 0c                	jne    800b0d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b01:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b03:	80 3a 30             	cmpb   $0x30,(%edx)
  800b06:	75 05                	jne    800b0d <strtol+0x6a>
		s++, base = 8;
  800b08:	83 c2 01             	add    $0x1,%edx
  800b0b:	b0 08                	mov    $0x8,%al
		base = 10;
  800b0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b12:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 0a             	movzbl (%edx),%ecx
  800b18:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b1b:	89 f0                	mov    %esi,%eax
  800b1d:	3c 09                	cmp    $0x9,%al
  800b1f:	77 08                	ja     800b29 <strtol+0x86>
			dig = *s - '0';
  800b21:	0f be c9             	movsbl %cl,%ecx
  800b24:	83 e9 30             	sub    $0x30,%ecx
  800b27:	eb 20                	jmp    800b49 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b29:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b2c:	89 f0                	mov    %esi,%eax
  800b2e:	3c 19                	cmp    $0x19,%al
  800b30:	77 08                	ja     800b3a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b32:	0f be c9             	movsbl %cl,%ecx
  800b35:	83 e9 57             	sub    $0x57,%ecx
  800b38:	eb 0f                	jmp    800b49 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b3a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b3d:	89 f0                	mov    %esi,%eax
  800b3f:	3c 19                	cmp    $0x19,%al
  800b41:	77 16                	ja     800b59 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b43:	0f be c9             	movsbl %cl,%ecx
  800b46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b49:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b4c:	7d 0f                	jge    800b5d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b55:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b57:	eb bc                	jmp    800b15 <strtol+0x72>
  800b59:	89 d8                	mov    %ebx,%eax
  800b5b:	eb 02                	jmp    800b5f <strtol+0xbc>
  800b5d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b63:	74 05                	je     800b6a <strtol+0xc7>
		*endptr = (char *) s;
  800b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b68:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b6a:	f7 d8                	neg    %eax
  800b6c:	85 ff                	test   %edi,%edi
  800b6e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 c3                	mov    %eax,%ebx
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	89 c6                	mov    %eax,%esi
  800b8d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 cb                	mov    %ecx,%ebx
  800bcb:	89 cf                	mov    %ecx,%edi
  800bcd:	89 ce                	mov    %ecx,%esi
  800bcf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7e 28                	jle    800bfd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800be0:	00 
  800be1:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800be8:	00 
  800be9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf0:	00 
  800bf1:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800bf8:	e8 49 13 00 00       	call   801f46 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfd:	83 c4 2c             	add    $0x2c,%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 02 00 00 00       	mov    $0x2,%eax
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 d3                	mov    %edx,%ebx
  800c19:	89 d7                	mov    %edx,%edi
  800c1b:	89 d6                	mov    %edx,%esi
  800c1d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_yield>:

void
sys_yield(void)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c4c:	be 00 00 00 00       	mov    $0x0,%esi
  800c51:	b8 04 00 00 00       	mov    $0x4,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	89 f7                	mov    %esi,%edi
  800c61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 28                	jle    800c8f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c72:	00 
  800c73:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c82:	00 
  800c83:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800c8a:	e8 b7 12 00 00       	call   801f46 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c8f:	83 c4 2c             	add    $0x2c,%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ca0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 28                	jle    800ce2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cc5:	00 
  800cc6:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800ccd:	00 
  800cce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd5:	00 
  800cd6:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800cdd:	e8 64 12 00 00       	call   801f46 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce2:	83 c4 2c             	add    $0x2c,%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 28                	jle    800d35 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d11:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d18:	00 
  800d19:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800d20:	00 
  800d21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d28:	00 
  800d29:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800d30:	e8 11 12 00 00       	call   801f46 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d35:	83 c4 2c             	add    $0x2c,%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 28                	jle    800d88 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d64:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d6b:	00 
  800d6c:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800d73:	00 
  800d74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7b:	00 
  800d7c:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800d83:	e8 be 11 00 00       	call   801f46 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d88:	83 c4 2c             	add    $0x2c,%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	b8 09 00 00 00       	mov    $0x9,%eax
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 28                	jle    800ddb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800dc6:	00 
  800dc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dce:	00 
  800dcf:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800dd6:	e8 6b 11 00 00       	call   801f46 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddb:	83 c4 2c             	add    $0x2c,%esp
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	89 df                	mov    %ebx,%edi
  800dfe:	89 de                	mov    %ebx,%esi
  800e00:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 28                	jle    800e2e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e11:	00 
  800e12:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800e19:	00 
  800e1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e21:	00 
  800e22:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800e29:	e8 18 11 00 00       	call   801f46 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2e:	83 c4 2c             	add    $0x2c,%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3c:	be 00 00 00 00       	mov    $0x0,%esi
  800e41:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e52:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	57                   	push   %edi
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e67:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 cb                	mov    %ecx,%ebx
  800e71:	89 cf                	mov    %ecx,%edi
  800e73:	89 ce                	mov    %ecx,%esi
  800e75:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e77:	85 c0                	test   %eax,%eax
  800e79:	7e 28                	jle    800ea3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e86:	00 
  800e87:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e96:	00 
  800e97:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800e9e:	e8 a3 10 00 00       	call   801f46 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea3:	83 c4 2c             	add    $0x2c,%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    
  800eab:	66 90                	xchg   %ax,%ax
  800ead:	66 90                	xchg   %ax,%ax
  800eaf:	90                   	nop

00800eb0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 24             	sub    $0x24,%esp
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  800eba:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  800ebc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ec0:	74 18                	je     800eda <pgfault+0x2a>
  800ec2:	89 d8                	mov    %ebx,%eax
  800ec4:	c1 e8 0c             	shr    $0xc,%eax
  800ec7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ece:	25 05 08 00 00       	and    $0x805,%eax
  800ed3:	3d 05 08 00 00       	cmp    $0x805,%eax
  800ed8:	74 1c                	je     800ef6 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  800eda:	c7 44 24 08 8c 27 80 	movl   $0x80278c,0x8(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800ee9:	00 
  800eea:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  800ef1:	e8 50 10 00 00       	call   801f46 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  800ef6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800efd:	00 
  800efe:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f05:	00 
  800f06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0d:	e8 31 fd ff ff       	call   800c43 <sys_page_alloc>
	if(r < 0){
  800f12:	85 c0                	test   %eax,%eax
  800f14:	79 1c                	jns    800f32 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  800f16:	c7 44 24 08 bc 27 80 	movl   $0x8027bc,0x8(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800f25:	00 
  800f26:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  800f2d:	e8 14 10 00 00       	call   801f46 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f32:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f38:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f3f:	00 
  800f40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f44:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f4b:	e8 dc fa ff ff       	call   800a2c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  800f50:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f57:	00 
  800f58:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f63:	00 
  800f64:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f6b:	00 
  800f6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f73:	e8 1f fd ff ff       	call   800c97 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	79 1c                	jns    800f98 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  800f7c:	c7 44 24 08 88 28 80 	movl   $0x802888,0x8(%esp)
  800f83:	00 
  800f84:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800f8b:	00 
  800f8c:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  800f93:	e8 ae 0f 00 00       	call   801f46 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  800f98:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f9f:	00 
  800fa0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa7:	e8 3e fd ff ff       	call   800cea <sys_page_unmap>
    if(r < 0){
  800fac:	85 c0                	test   %eax,%eax
  800fae:	79 1c                	jns    800fcc <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  800fb0:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800fbf:	00 
  800fc0:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  800fc7:	e8 7a 0f 00 00       	call   801f46 <_panic>
    }
    // LAB 4
}
  800fcc:	83 c4 24             	add    $0x24,%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  800fdb:	c7 04 24 b0 0e 80 00 	movl   $0x800eb0,(%esp)
  800fe2:	e8 b5 0f 00 00       	call   801f9c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fe7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fec:	cd 30                	int    $0x30
  800fee:	89 c7                	mov    %eax,%edi
  800ff0:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	79 1c                	jns    801013 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  800ff7:	c7 44 24 08 b8 28 80 	movl   $0x8028b8,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  80100e:	e8 33 0f 00 00       	call   801f46 <_panic>
    }
    if(child == 0){
  801013:	bb 00 00 00 00       	mov    $0x0,%ebx
  801018:	85 c0                	test   %eax,%eax
  80101a:	75 21                	jne    80103d <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80101c:	e8 e4 fb ff ff       	call   800c05 <sys_getenvid>
  801021:	25 ff 03 00 00       	and    $0x3ff,%eax
  801026:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801029:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80102e:	a3 08 40 80 00       	mov    %eax,0x804008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  801033:	b8 00 00 00 00       	mov    $0x0,%eax
  801038:	e9 67 01 00 00       	jmp    8011a4 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  80103d:	89 d8                	mov    %ebx,%eax
  80103f:	c1 e8 16             	shr    $0x16,%eax
  801042:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801049:	a8 01                	test   $0x1,%al
  80104b:	74 4b                	je     801098 <fork+0xc6>
  80104d:	89 de                	mov    %ebx,%esi
  80104f:	c1 ee 0c             	shr    $0xc,%esi
  801052:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801059:	a8 01                	test   $0x1,%al
  80105b:	74 3b                	je     801098 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  80105d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801064:	a9 02 08 00 00       	test   $0x802,%eax
  801069:	0f 85 02 01 00 00    	jne    801171 <fork+0x19f>
  80106f:	e9 d2 00 00 00       	jmp    801146 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  801074:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80107b:	00 
  80107c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801080:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801087:	00 
  801088:	89 74 24 04          	mov    %esi,0x4(%esp)
  80108c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801093:	e8 ff fb ff ff       	call   800c97 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801098:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80109e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010a4:	75 97                	jne    80103d <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  8010a6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010ad:	00 
  8010ae:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010b5:	ee 
  8010b6:	89 3c 24             	mov    %edi,(%esp)
  8010b9:	e8 85 fb ff ff       	call   800c43 <sys_page_alloc>

    if(r < 0){
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	79 1c                	jns    8010de <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  8010c2:	c7 44 24 08 f0 27 80 	movl   $0x8027f0,0x8(%esp)
  8010c9:	00 
  8010ca:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  8010d1:	00 
  8010d2:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  8010d9:	e8 68 0e 00 00       	call   801f46 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  8010de:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e3:	8b 40 64             	mov    0x64(%eax),%eax
  8010e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ea:	89 3c 24             	mov    %edi,(%esp)
  8010ed:	e8 f1 fc ff ff       	call   800de3 <sys_env_set_pgfault_upcall>
    if(r < 0){
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 1c                	jns    801112 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  8010f6:	c7 44 24 08 10 28 80 	movl   $0x802810,0x8(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801105:	00 
  801106:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  80110d:	e8 34 0e 00 00       	call   801f46 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801112:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801119:	00 
  80111a:	89 3c 24             	mov    %edi,(%esp)
  80111d:	e8 1b fc ff ff       	call   800d3d <sys_env_set_status>
    if(r < 0){
  801122:	85 c0                	test   %eax,%eax
  801124:	79 1c                	jns    801142 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801126:	c7 44 24 08 38 28 80 	movl   $0x802838,0x8(%esp)
  80112d:	00 
  80112e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  801135:	00 
  801136:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  80113d:	e8 04 0e 00 00       	call   801f46 <_panic>
    }
    return child;
  801142:	89 f8                	mov    %edi,%eax
  801144:	eb 5e                	jmp    8011a4 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  801146:	c1 e6 0c             	shl    $0xc,%esi
  801149:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801150:	00 
  801151:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801155:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801158:	89 44 24 08          	mov    %eax,0x8(%esp)
  80115c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801160:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801167:	e8 2b fb ff ff       	call   800c97 <sys_page_map>
  80116c:	e9 27 ff ff ff       	jmp    801098 <fork+0xc6>
  801171:	c1 e6 0c             	shl    $0xc,%esi
  801174:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80117b:	00 
  80117c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801180:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801183:	89 44 24 08          	mov    %eax,0x8(%esp)
  801187:	89 74 24 04          	mov    %esi,0x4(%esp)
  80118b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801192:	e8 00 fb ff ff       	call   800c97 <sys_page_map>
    if( r < 0 ){
  801197:	85 c0                	test   %eax,%eax
  801199:	0f 89 d5 fe ff ff    	jns    801074 <fork+0xa2>
  80119f:	e9 f4 fe ff ff       	jmp    801098 <fork+0xc6>
//	panic("fork not implemented");
}
  8011a4:	83 c4 2c             	add    $0x2c,%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <sfork>:

// Challenge!
int
sfork(void)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011b2:	c7 44 24 08 d5 28 80 	movl   $0x8028d5,0x8(%esp)
  8011b9:	00 
  8011ba:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  8011c1:	00 
  8011c2:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  8011c9:	e8 78 0d 00 00       	call   801f46 <_panic>
  8011ce:	66 90                	xchg   %ax,%ax

008011d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011db:	c1 e8 0c             	shr    $0xc,%eax
}
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801202:	89 c2                	mov    %eax,%edx
  801204:	c1 ea 16             	shr    $0x16,%edx
  801207:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120e:	f6 c2 01             	test   $0x1,%dl
  801211:	74 11                	je     801224 <fd_alloc+0x2d>
  801213:	89 c2                	mov    %eax,%edx
  801215:	c1 ea 0c             	shr    $0xc,%edx
  801218:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121f:	f6 c2 01             	test   $0x1,%dl
  801222:	75 09                	jne    80122d <fd_alloc+0x36>
			*fd_store = fd;
  801224:	89 01                	mov    %eax,(%ecx)
			return 0;
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
  80122b:	eb 17                	jmp    801244 <fd_alloc+0x4d>
  80122d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801232:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801237:	75 c9                	jne    801202 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801239:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80123f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124c:	83 f8 1f             	cmp    $0x1f,%eax
  80124f:	77 36                	ja     801287 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801251:	c1 e0 0c             	shl    $0xc,%eax
  801254:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801259:	89 c2                	mov    %eax,%edx
  80125b:	c1 ea 16             	shr    $0x16,%edx
  80125e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801265:	f6 c2 01             	test   $0x1,%dl
  801268:	74 24                	je     80128e <fd_lookup+0x48>
  80126a:	89 c2                	mov    %eax,%edx
  80126c:	c1 ea 0c             	shr    $0xc,%edx
  80126f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801276:	f6 c2 01             	test   $0x1,%dl
  801279:	74 1a                	je     801295 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127e:	89 02                	mov    %eax,(%edx)
	return 0;
  801280:	b8 00 00 00 00       	mov    $0x0,%eax
  801285:	eb 13                	jmp    80129a <fd_lookup+0x54>
		return -E_INVAL;
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128c:	eb 0c                	jmp    80129a <fd_lookup+0x54>
		return -E_INVAL;
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801293:	eb 05                	jmp    80129a <fd_lookup+0x54>
  801295:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 18             	sub    $0x18,%esp
  8012a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a5:	ba 68 29 80 00       	mov    $0x802968,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012aa:	eb 13                	jmp    8012bf <dev_lookup+0x23>
  8012ac:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012af:	39 08                	cmp    %ecx,(%eax)
  8012b1:	75 0c                	jne    8012bf <dev_lookup+0x23>
			*dev = devtab[i];
  8012b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bd:	eb 30                	jmp    8012ef <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8012bf:	8b 02                	mov    (%edx),%eax
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	75 e7                	jne    8012ac <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ca:	8b 40 48             	mov    0x48(%eax),%eax
  8012cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d5:	c7 04 24 ec 28 80 00 	movl   $0x8028ec,(%esp)
  8012dc:	e8 16 ef ff ff       	call   8001f7 <cprintf>
	*dev = 0;
  8012e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    

008012f1 <fd_close>:
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 20             	sub    $0x20,%esp
  8012f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801302:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801306:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130f:	89 04 24             	mov    %eax,(%esp)
  801312:	e8 2f ff ff ff       	call   801246 <fd_lookup>
  801317:	85 c0                	test   %eax,%eax
  801319:	78 05                	js     801320 <fd_close+0x2f>
	    || fd != fd2)
  80131b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131e:	74 0c                	je     80132c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801320:	84 db                	test   %bl,%bl
  801322:	ba 00 00 00 00       	mov    $0x0,%edx
  801327:	0f 44 c2             	cmove  %edx,%eax
  80132a:	eb 3f                	jmp    80136b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801333:	8b 06                	mov    (%esi),%eax
  801335:	89 04 24             	mov    %eax,(%esp)
  801338:	e8 5f ff ff ff       	call   80129c <dev_lookup>
  80133d:	89 c3                	mov    %eax,%ebx
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 16                	js     801359 <fd_close+0x68>
		if (dev->dev_close)
  801343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801346:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801349:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80134e:	85 c0                	test   %eax,%eax
  801350:	74 07                	je     801359 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801352:	89 34 24             	mov    %esi,(%esp)
  801355:	ff d0                	call   *%eax
  801357:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801359:	89 74 24 04          	mov    %esi,0x4(%esp)
  80135d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801364:	e8 81 f9 ff ff       	call   800cea <sys_page_unmap>
	return r;
  801369:	89 d8                	mov    %ebx,%eax
}
  80136b:	83 c4 20             	add    $0x20,%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <close>:

int
close(int fdnum)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137f:	8b 45 08             	mov    0x8(%ebp),%eax
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	e8 bc fe ff ff       	call   801246 <fd_lookup>
  80138a:	89 c2                	mov    %eax,%edx
  80138c:	85 d2                	test   %edx,%edx
  80138e:	78 13                	js     8013a3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801390:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801397:	00 
  801398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139b:	89 04 24             	mov    %eax,(%esp)
  80139e:	e8 4e ff ff ff       	call   8012f1 <fd_close>
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <close_all>:

void
close_all(void)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b1:	89 1c 24             	mov    %ebx,(%esp)
  8013b4:	e8 b9 ff ff ff       	call   801372 <close>
	for (i = 0; i < MAXFD; i++)
  8013b9:	83 c3 01             	add    $0x1,%ebx
  8013bc:	83 fb 20             	cmp    $0x20,%ebx
  8013bf:	75 f0                	jne    8013b1 <close_all+0xc>
}
  8013c1:	83 c4 14             	add    $0x14,%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	57                   	push   %edi
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013da:	89 04 24             	mov    %eax,(%esp)
  8013dd:	e8 64 fe ff ff       	call   801246 <fd_lookup>
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	85 d2                	test   %edx,%edx
  8013e6:	0f 88 e1 00 00 00    	js     8014cd <dup+0x106>
		return r;
	close(newfdnum);
  8013ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ef:	89 04 24             	mov    %eax,(%esp)
  8013f2:	e8 7b ff ff ff       	call   801372 <close>

	newfd = INDEX2FD(newfdnum);
  8013f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013fa:	c1 e3 0c             	shl    $0xc,%ebx
  8013fd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801403:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801406:	89 04 24             	mov    %eax,(%esp)
  801409:	e8 d2 fd ff ff       	call   8011e0 <fd2data>
  80140e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801410:	89 1c 24             	mov    %ebx,(%esp)
  801413:	e8 c8 fd ff ff       	call   8011e0 <fd2data>
  801418:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141a:	89 f0                	mov    %esi,%eax
  80141c:	c1 e8 16             	shr    $0x16,%eax
  80141f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801426:	a8 01                	test   $0x1,%al
  801428:	74 43                	je     80146d <dup+0xa6>
  80142a:	89 f0                	mov    %esi,%eax
  80142c:	c1 e8 0c             	shr    $0xc,%eax
  80142f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801436:	f6 c2 01             	test   $0x1,%dl
  801439:	74 32                	je     80146d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801442:	25 07 0e 00 00       	and    $0xe07,%eax
  801447:	89 44 24 10          	mov    %eax,0x10(%esp)
  80144b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80144f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801456:	00 
  801457:	89 74 24 04          	mov    %esi,0x4(%esp)
  80145b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801462:	e8 30 f8 ff ff       	call   800c97 <sys_page_map>
  801467:	89 c6                	mov    %eax,%esi
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 3e                	js     8014ab <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801470:	89 c2                	mov    %eax,%edx
  801472:	c1 ea 0c             	shr    $0xc,%edx
  801475:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801482:	89 54 24 10          	mov    %edx,0x10(%esp)
  801486:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80148a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801491:	00 
  801492:	89 44 24 04          	mov    %eax,0x4(%esp)
  801496:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80149d:	e8 f5 f7 ff ff       	call   800c97 <sys_page_map>
  8014a2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8014a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a7:	85 f6                	test   %esi,%esi
  8014a9:	79 22                	jns    8014cd <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8014ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b6:	e8 2f f8 ff ff       	call   800cea <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c6:	e8 1f f8 ff ff       	call   800cea <sys_page_unmap>
	return r;
  8014cb:	89 f0                	mov    %esi,%eax
}
  8014cd:	83 c4 3c             	add    $0x3c,%esp
  8014d0:	5b                   	pop    %ebx
  8014d1:	5e                   	pop    %esi
  8014d2:	5f                   	pop    %edi
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    

008014d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	53                   	push   %ebx
  8014d9:	83 ec 24             	sub    $0x24,%esp
  8014dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e6:	89 1c 24             	mov    %ebx,(%esp)
  8014e9:	e8 58 fd ff ff       	call   801246 <fd_lookup>
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	85 d2                	test   %edx,%edx
  8014f2:	78 6d                	js     801561 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fe:	8b 00                	mov    (%eax),%eax
  801500:	89 04 24             	mov    %eax,(%esp)
  801503:	e8 94 fd ff ff       	call   80129c <dev_lookup>
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 55                	js     801561 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80150c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150f:	8b 50 08             	mov    0x8(%eax),%edx
  801512:	83 e2 03             	and    $0x3,%edx
  801515:	83 fa 01             	cmp    $0x1,%edx
  801518:	75 23                	jne    80153d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80151a:	a1 08 40 80 00       	mov    0x804008,%eax
  80151f:	8b 40 48             	mov    0x48(%eax),%eax
  801522:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152a:	c7 04 24 2d 29 80 00 	movl   $0x80292d,(%esp)
  801531:	e8 c1 ec ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  801536:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153b:	eb 24                	jmp    801561 <read+0x8c>
	}
	if (!dev->dev_read)
  80153d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801540:	8b 52 08             	mov    0x8(%edx),%edx
  801543:	85 d2                	test   %edx,%edx
  801545:	74 15                	je     80155c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801547:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80154a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80154e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801551:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	ff d2                	call   *%edx
  80155a:	eb 05                	jmp    801561 <read+0x8c>
		return -E_NOT_SUPP;
  80155c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801561:	83 c4 24             	add    $0x24,%esp
  801564:	5b                   	pop    %ebx
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	57                   	push   %edi
  80156b:	56                   	push   %esi
  80156c:	53                   	push   %ebx
  80156d:	83 ec 1c             	sub    $0x1c,%esp
  801570:	8b 7d 08             	mov    0x8(%ebp),%edi
  801573:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801576:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157b:	eb 23                	jmp    8015a0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80157d:	89 f0                	mov    %esi,%eax
  80157f:	29 d8                	sub    %ebx,%eax
  801581:	89 44 24 08          	mov    %eax,0x8(%esp)
  801585:	89 d8                	mov    %ebx,%eax
  801587:	03 45 0c             	add    0xc(%ebp),%eax
  80158a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158e:	89 3c 24             	mov    %edi,(%esp)
  801591:	e8 3f ff ff ff       	call   8014d5 <read>
		if (m < 0)
  801596:	85 c0                	test   %eax,%eax
  801598:	78 10                	js     8015aa <readn+0x43>
			return m;
		if (m == 0)
  80159a:	85 c0                	test   %eax,%eax
  80159c:	74 0a                	je     8015a8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80159e:	01 c3                	add    %eax,%ebx
  8015a0:	39 f3                	cmp    %esi,%ebx
  8015a2:	72 d9                	jb     80157d <readn+0x16>
  8015a4:	89 d8                	mov    %ebx,%eax
  8015a6:	eb 02                	jmp    8015aa <readn+0x43>
  8015a8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015aa:	83 c4 1c             	add    $0x1c,%esp
  8015ad:	5b                   	pop    %ebx
  8015ae:	5e                   	pop    %esi
  8015af:	5f                   	pop    %edi
  8015b0:	5d                   	pop    %ebp
  8015b1:	c3                   	ret    

008015b2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 24             	sub    $0x24,%esp
  8015b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c3:	89 1c 24             	mov    %ebx,(%esp)
  8015c6:	e8 7b fc ff ff       	call   801246 <fd_lookup>
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	85 d2                	test   %edx,%edx
  8015cf:	78 68                	js     801639 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015db:	8b 00                	mov    (%eax),%eax
  8015dd:	89 04 24             	mov    %eax,(%esp)
  8015e0:	e8 b7 fc ff ff       	call   80129c <dev_lookup>
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 50                	js     801639 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f0:	75 23                	jne    801615 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f7:	8b 40 48             	mov    0x48(%eax),%eax
  8015fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801602:	c7 04 24 49 29 80 00 	movl   $0x802949,(%esp)
  801609:	e8 e9 eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  80160e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801613:	eb 24                	jmp    801639 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801615:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801618:	8b 52 0c             	mov    0xc(%edx),%edx
  80161b:	85 d2                	test   %edx,%edx
  80161d:	74 15                	je     801634 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801622:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801626:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801629:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	ff d2                	call   *%edx
  801632:	eb 05                	jmp    801639 <write+0x87>
		return -E_NOT_SUPP;
  801634:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801639:	83 c4 24             	add    $0x24,%esp
  80163c:	5b                   	pop    %ebx
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <seek>:

int
seek(int fdnum, off_t offset)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801645:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164c:	8b 45 08             	mov    0x8(%ebp),%eax
  80164f:	89 04 24             	mov    %eax,(%esp)
  801652:	e8 ef fb ff ff       	call   801246 <fd_lookup>
  801657:	85 c0                	test   %eax,%eax
  801659:	78 0e                	js     801669 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80165b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80165e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801661:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801664:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	53                   	push   %ebx
  80166f:	83 ec 24             	sub    $0x24,%esp
  801672:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801675:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801678:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167c:	89 1c 24             	mov    %ebx,(%esp)
  80167f:	e8 c2 fb ff ff       	call   801246 <fd_lookup>
  801684:	89 c2                	mov    %eax,%edx
  801686:	85 d2                	test   %edx,%edx
  801688:	78 61                	js     8016eb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801694:	8b 00                	mov    (%eax),%eax
  801696:	89 04 24             	mov    %eax,(%esp)
  801699:	e8 fe fb ff ff       	call   80129c <dev_lookup>
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 49                	js     8016eb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a9:	75 23                	jne    8016ce <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ab:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016b0:	8b 40 48             	mov    0x48(%eax),%eax
  8016b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	c7 04 24 0c 29 80 00 	movl   $0x80290c,(%esp)
  8016c2:	e8 30 eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  8016c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016cc:	eb 1d                	jmp    8016eb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8016ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d1:	8b 52 18             	mov    0x18(%edx),%edx
  8016d4:	85 d2                	test   %edx,%edx
  8016d6:	74 0e                	je     8016e6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016df:	89 04 24             	mov    %eax,(%esp)
  8016e2:	ff d2                	call   *%edx
  8016e4:	eb 05                	jmp    8016eb <ftruncate+0x80>
		return -E_NOT_SUPP;
  8016e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016eb:	83 c4 24             	add    $0x24,%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 24             	sub    $0x24,%esp
  8016f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801702:	8b 45 08             	mov    0x8(%ebp),%eax
  801705:	89 04 24             	mov    %eax,(%esp)
  801708:	e8 39 fb ff ff       	call   801246 <fd_lookup>
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	85 d2                	test   %edx,%edx
  801711:	78 52                	js     801765 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171d:	8b 00                	mov    (%eax),%eax
  80171f:	89 04 24             	mov    %eax,(%esp)
  801722:	e8 75 fb ff ff       	call   80129c <dev_lookup>
  801727:	85 c0                	test   %eax,%eax
  801729:	78 3a                	js     801765 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801732:	74 2c                	je     801760 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801734:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801737:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173e:	00 00 00 
	stat->st_isdir = 0;
  801741:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801748:	00 00 00 
	stat->st_dev = dev;
  80174b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801751:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801755:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801758:	89 14 24             	mov    %edx,(%esp)
  80175b:	ff 50 14             	call   *0x14(%eax)
  80175e:	eb 05                	jmp    801765 <fstat+0x74>
		return -E_NOT_SUPP;
  801760:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801765:	83 c4 24             	add    $0x24,%esp
  801768:	5b                   	pop    %ebx
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801773:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80177a:	00 
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
  80177e:	89 04 24             	mov    %eax,(%esp)
  801781:	e8 fb 01 00 00       	call   801981 <open>
  801786:	89 c3                	mov    %eax,%ebx
  801788:	85 db                	test   %ebx,%ebx
  80178a:	78 1b                	js     8017a7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80178c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801793:	89 1c 24             	mov    %ebx,(%esp)
  801796:	e8 56 ff ff ff       	call   8016f1 <fstat>
  80179b:	89 c6                	mov    %eax,%esi
	close(fd);
  80179d:	89 1c 24             	mov    %ebx,(%esp)
  8017a0:	e8 cd fb ff ff       	call   801372 <close>
	return r;
  8017a5:	89 f0                	mov    %esi,%eax
}
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	5b                   	pop    %ebx
  8017ab:	5e                   	pop    %esi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	83 ec 10             	sub    $0x10,%esp
  8017b6:	89 c6                	mov    %eax,%esi
  8017b8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017ba:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017c1:	75 11                	jne    8017d4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017ca:	e8 50 09 00 00       	call   80211f <ipc_find_env>
  8017cf:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017db:	00 
  8017dc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017e3:	00 
  8017e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 c3 08 00 00       	call   8020b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017fc:	00 
  8017fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801808:	e8 43 08 00 00       	call   802050 <ipc_recv>
}
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	8b 40 0c             	mov    0xc(%eax),%eax
  801820:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801825:	8b 45 0c             	mov    0xc(%ebp),%eax
  801828:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 02 00 00 00       	mov    $0x2,%eax
  801837:	e8 72 ff ff ff       	call   8017ae <fsipc>
}
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <devfile_flush>:
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 40 0c             	mov    0xc(%eax),%eax
  80184a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 06 00 00 00       	mov    $0x6,%eax
  801859:	e8 50 ff ff ff       	call   8017ae <fsipc>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <devfile_stat>:
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 14             	sub    $0x14,%esp
  801867:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 05 00 00 00       	mov    $0x5,%eax
  80187f:	e8 2a ff ff ff       	call   8017ae <fsipc>
  801884:	89 c2                	mov    %eax,%edx
  801886:	85 d2                	test   %edx,%edx
  801888:	78 2b                	js     8018b5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801891:	00 
  801892:	89 1c 24             	mov    %ebx,(%esp)
  801895:	e8 8d ef ff ff       	call   800827 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189a:	a1 80 50 80 00       	mov    0x805080,%eax
  80189f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a5:	a1 84 50 80 00       	mov    0x805084,%eax
  8018aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b5:	83 c4 14             	add    $0x14,%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <devfile_write>:
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  8018c1:	c7 44 24 08 78 29 80 	movl   $0x802978,0x8(%esp)
  8018c8:	00 
  8018c9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8018d0:	00 
  8018d1:	c7 04 24 96 29 80 00 	movl   $0x802996,(%esp)
  8018d8:	e8 69 06 00 00       	call   801f46 <_panic>

008018dd <devfile_read>:
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 10             	sub    $0x10,%esp
  8018e5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fe:	b8 03 00 00 00       	mov    $0x3,%eax
  801903:	e8 a6 fe ff ff       	call   8017ae <fsipc>
  801908:	89 c3                	mov    %eax,%ebx
  80190a:	85 c0                	test   %eax,%eax
  80190c:	78 6a                	js     801978 <devfile_read+0x9b>
	assert(r <= n);
  80190e:	39 c6                	cmp    %eax,%esi
  801910:	73 24                	jae    801936 <devfile_read+0x59>
  801912:	c7 44 24 0c a1 29 80 	movl   $0x8029a1,0xc(%esp)
  801919:	00 
  80191a:	c7 44 24 08 a8 29 80 	movl   $0x8029a8,0x8(%esp)
  801921:	00 
  801922:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801929:	00 
  80192a:	c7 04 24 96 29 80 00 	movl   $0x802996,(%esp)
  801931:	e8 10 06 00 00       	call   801f46 <_panic>
	assert(r <= PGSIZE);
  801936:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80193b:	7e 24                	jle    801961 <devfile_read+0x84>
  80193d:	c7 44 24 0c bd 29 80 	movl   $0x8029bd,0xc(%esp)
  801944:	00 
  801945:	c7 44 24 08 a8 29 80 	movl   $0x8029a8,0x8(%esp)
  80194c:	00 
  80194d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801954:	00 
  801955:	c7 04 24 96 29 80 00 	movl   $0x802996,(%esp)
  80195c:	e8 e5 05 00 00       	call   801f46 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801961:	89 44 24 08          	mov    %eax,0x8(%esp)
  801965:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80196c:	00 
  80196d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801970:	89 04 24             	mov    %eax,(%esp)
  801973:	e8 4c f0 ff ff       	call   8009c4 <memmove>
}
  801978:	89 d8                	mov    %ebx,%eax
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <open>:
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	53                   	push   %ebx
  801985:	83 ec 24             	sub    $0x24,%esp
  801988:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80198b:	89 1c 24             	mov    %ebx,(%esp)
  80198e:	e8 5d ee ff ff       	call   8007f0 <strlen>
  801993:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801998:	7f 60                	jg     8019fa <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80199a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199d:	89 04 24             	mov    %eax,(%esp)
  8019a0:	e8 52 f8 ff ff       	call   8011f7 <fd_alloc>
  8019a5:	89 c2                	mov    %eax,%edx
  8019a7:	85 d2                	test   %edx,%edx
  8019a9:	78 54                	js     8019ff <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8019ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019af:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019b6:	e8 6c ee ff ff       	call   800827 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019be:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cb:	e8 de fd ff ff       	call   8017ae <fsipc>
  8019d0:	89 c3                	mov    %eax,%ebx
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	79 17                	jns    8019ed <open+0x6c>
		fd_close(fd, 0);
  8019d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019dd:	00 
  8019de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e1:	89 04 24             	mov    %eax,(%esp)
  8019e4:	e8 08 f9 ff ff       	call   8012f1 <fd_close>
		return r;
  8019e9:	89 d8                	mov    %ebx,%eax
  8019eb:	eb 12                	jmp    8019ff <open+0x7e>
	return fd2num(fd);
  8019ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f0:	89 04 24             	mov    %eax,(%esp)
  8019f3:	e8 d8 f7 ff ff       	call   8011d0 <fd2num>
  8019f8:	eb 05                	jmp    8019ff <open+0x7e>
		return -E_BAD_PATH;
  8019fa:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8019ff:	83 c4 24             	add    $0x24,%esp
  801a02:	5b                   	pop    %ebx
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a10:	b8 08 00 00 00       	mov    $0x8,%eax
  801a15:	e8 94 fd ff ff       	call   8017ae <fsipc>
}
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	83 ec 10             	sub    $0x10,%esp
  801a24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a27:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2a:	89 04 24             	mov    %eax,(%esp)
  801a2d:	e8 ae f7 ff ff       	call   8011e0 <fd2data>
  801a32:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a34:	c7 44 24 04 c9 29 80 	movl   $0x8029c9,0x4(%esp)
  801a3b:	00 
  801a3c:	89 1c 24             	mov    %ebx,(%esp)
  801a3f:	e8 e3 ed ff ff       	call   800827 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a44:	8b 46 04             	mov    0x4(%esi),%eax
  801a47:	2b 06                	sub    (%esi),%eax
  801a49:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a56:	00 00 00 
	stat->st_dev = &devpipe;
  801a59:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a60:	30 80 00 
	return 0;
}
  801a63:	b8 00 00 00 00       	mov    $0x0,%eax
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	53                   	push   %ebx
  801a73:	83 ec 14             	sub    $0x14,%esp
  801a76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a84:	e8 61 f2 ff ff       	call   800cea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a89:	89 1c 24             	mov    %ebx,(%esp)
  801a8c:	e8 4f f7 ff ff       	call   8011e0 <fd2data>
  801a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9c:	e8 49 f2 ff ff       	call   800cea <sys_page_unmap>
}
  801aa1:	83 c4 14             	add    $0x14,%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <_pipeisclosed>:
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	57                   	push   %edi
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	83 ec 2c             	sub    $0x2c,%esp
  801ab0:	89 c6                	mov    %eax,%esi
  801ab2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801ab5:	a1 08 40 80 00       	mov    0x804008,%eax
  801aba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801abd:	89 34 24             	mov    %esi,(%esp)
  801ac0:	e8 92 06 00 00       	call   802157 <pageref>
  801ac5:	89 c7                	mov    %eax,%edi
  801ac7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aca:	89 04 24             	mov    %eax,(%esp)
  801acd:	e8 85 06 00 00       	call   802157 <pageref>
  801ad2:	39 c7                	cmp    %eax,%edi
  801ad4:	0f 94 c2             	sete   %dl
  801ad7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801ada:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801ae0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801ae3:	39 fb                	cmp    %edi,%ebx
  801ae5:	74 21                	je     801b08 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801ae7:	84 d2                	test   %dl,%dl
  801ae9:	74 ca                	je     801ab5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aeb:	8b 51 58             	mov    0x58(%ecx),%edx
  801aee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801af2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801af6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801afa:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  801b01:	e8 f1 e6 ff ff       	call   8001f7 <cprintf>
  801b06:	eb ad                	jmp    801ab5 <_pipeisclosed+0xe>
}
  801b08:	83 c4 2c             	add    $0x2c,%esp
  801b0b:	5b                   	pop    %ebx
  801b0c:	5e                   	pop    %esi
  801b0d:	5f                   	pop    %edi
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <devpipe_write>:
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	57                   	push   %edi
  801b14:	56                   	push   %esi
  801b15:	53                   	push   %ebx
  801b16:	83 ec 1c             	sub    $0x1c,%esp
  801b19:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b1c:	89 34 24             	mov    %esi,(%esp)
  801b1f:	e8 bc f6 ff ff       	call   8011e0 <fd2data>
  801b24:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b26:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2b:	eb 45                	jmp    801b72 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801b2d:	89 da                	mov    %ebx,%edx
  801b2f:	89 f0                	mov    %esi,%eax
  801b31:	e8 71 ff ff ff       	call   801aa7 <_pipeisclosed>
  801b36:	85 c0                	test   %eax,%eax
  801b38:	75 41                	jne    801b7b <devpipe_write+0x6b>
			sys_yield();
  801b3a:	e8 e5 f0 ff ff       	call   800c24 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b3f:	8b 43 04             	mov    0x4(%ebx),%eax
  801b42:	8b 0b                	mov    (%ebx),%ecx
  801b44:	8d 51 20             	lea    0x20(%ecx),%edx
  801b47:	39 d0                	cmp    %edx,%eax
  801b49:	73 e2                	jae    801b2d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b52:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b55:	99                   	cltd   
  801b56:	c1 ea 1b             	shr    $0x1b,%edx
  801b59:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801b5c:	83 e1 1f             	and    $0x1f,%ecx
  801b5f:	29 d1                	sub    %edx,%ecx
  801b61:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801b65:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801b69:	83 c0 01             	add    $0x1,%eax
  801b6c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b6f:	83 c7 01             	add    $0x1,%edi
  801b72:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b75:	75 c8                	jne    801b3f <devpipe_write+0x2f>
	return i;
  801b77:	89 f8                	mov    %edi,%eax
  801b79:	eb 05                	jmp    801b80 <devpipe_write+0x70>
				return 0;
  801b7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b80:	83 c4 1c             	add    $0x1c,%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5f                   	pop    %edi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <devpipe_read>:
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	57                   	push   %edi
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 1c             	sub    $0x1c,%esp
  801b91:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b94:	89 3c 24             	mov    %edi,(%esp)
  801b97:	e8 44 f6 ff ff       	call   8011e0 <fd2data>
  801b9c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b9e:	be 00 00 00 00       	mov    $0x0,%esi
  801ba3:	eb 3d                	jmp    801be2 <devpipe_read+0x5a>
			if (i > 0)
  801ba5:	85 f6                	test   %esi,%esi
  801ba7:	74 04                	je     801bad <devpipe_read+0x25>
				return i;
  801ba9:	89 f0                	mov    %esi,%eax
  801bab:	eb 43                	jmp    801bf0 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801bad:	89 da                	mov    %ebx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	e8 f1 fe ff ff       	call   801aa7 <_pipeisclosed>
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	75 31                	jne    801beb <devpipe_read+0x63>
			sys_yield();
  801bba:	e8 65 f0 ff ff       	call   800c24 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801bbf:	8b 03                	mov    (%ebx),%eax
  801bc1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bc4:	74 df                	je     801ba5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc6:	99                   	cltd   
  801bc7:	c1 ea 1b             	shr    $0x1b,%edx
  801bca:	01 d0                	add    %edx,%eax
  801bcc:	83 e0 1f             	and    $0x1f,%eax
  801bcf:	29 d0                	sub    %edx,%eax
  801bd1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bdc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bdf:	83 c6 01             	add    $0x1,%esi
  801be2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801be5:	75 d8                	jne    801bbf <devpipe_read+0x37>
	return i;
  801be7:	89 f0                	mov    %esi,%eax
  801be9:	eb 05                	jmp    801bf0 <devpipe_read+0x68>
				return 0;
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <pipe>:
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c03:	89 04 24             	mov    %eax,(%esp)
  801c06:	e8 ec f5 ff ff       	call   8011f7 <fd_alloc>
  801c0b:	89 c2                	mov    %eax,%edx
  801c0d:	85 d2                	test   %edx,%edx
  801c0f:	0f 88 4d 01 00 00    	js     801d62 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c15:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c1c:	00 
  801c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2b:	e8 13 f0 ff ff       	call   800c43 <sys_page_alloc>
  801c30:	89 c2                	mov    %eax,%edx
  801c32:	85 d2                	test   %edx,%edx
  801c34:	0f 88 28 01 00 00    	js     801d62 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801c3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c3d:	89 04 24             	mov    %eax,(%esp)
  801c40:	e8 b2 f5 ff ff       	call   8011f7 <fd_alloc>
  801c45:	89 c3                	mov    %eax,%ebx
  801c47:	85 c0                	test   %eax,%eax
  801c49:	0f 88 fe 00 00 00    	js     801d4d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c56:	00 
  801c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c65:	e8 d9 ef ff ff       	call   800c43 <sys_page_alloc>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	0f 88 d9 00 00 00    	js     801d4d <pipe+0x155>
	va = fd2data(fd0);
  801c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c77:	89 04 24             	mov    %eax,(%esp)
  801c7a:	e8 61 f5 ff ff       	call   8011e0 <fd2data>
  801c7f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c81:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c88:	00 
  801c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c94:	e8 aa ef ff ff       	call   800c43 <sys_page_alloc>
  801c99:	89 c3                	mov    %eax,%ebx
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	0f 88 97 00 00 00    	js     801d3a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca6:	89 04 24             	mov    %eax,(%esp)
  801ca9:	e8 32 f5 ff ff       	call   8011e0 <fd2data>
  801cae:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801cb5:	00 
  801cb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cc1:	00 
  801cc2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ccd:	e8 c5 ef ff ff       	call   800c97 <sys_page_map>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	78 52                	js     801d2a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801cd8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801ced:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d05:	89 04 24             	mov    %eax,(%esp)
  801d08:	e8 c3 f4 ff ff       	call   8011d0 <fd2num>
  801d0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d10:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d15:	89 04 24             	mov    %eax,(%esp)
  801d18:	e8 b3 f4 ff ff       	call   8011d0 <fd2num>
  801d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d20:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
  801d28:	eb 38                	jmp    801d62 <pipe+0x16a>
	sys_page_unmap(0, va);
  801d2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d35:	e8 b0 ef ff ff       	call   800cea <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801d3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d48:	e8 9d ef ff ff       	call   800cea <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5b:	e8 8a ef ff ff       	call   800cea <sys_page_unmap>
  801d60:	89 d8                	mov    %ebx,%eax
}
  801d62:	83 c4 30             	add    $0x30,%esp
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <pipeisclosed>:
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	89 04 24             	mov    %eax,(%esp)
  801d7c:	e8 c5 f4 ff ff       	call   801246 <fd_lookup>
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	85 d2                	test   %edx,%edx
  801d85:	78 15                	js     801d9c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8a:	89 04 24             	mov    %eax,(%esp)
  801d8d:	e8 4e f4 ff ff       	call   8011e0 <fd2data>
	return _pipeisclosed(fd, p);
  801d92:	89 c2                	mov    %eax,%edx
  801d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d97:	e8 0b fd ff ff       	call   801aa7 <_pipeisclosed>
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    
  801d9e:	66 90                	xchg   %ax,%ax

00801da0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801db0:	c7 44 24 04 e8 29 80 	movl   $0x8029e8,0x4(%esp)
  801db7:	00 
  801db8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbb:	89 04 24             	mov    %eax,(%esp)
  801dbe:	e8 64 ea ff ff       	call   800827 <strcpy>
	return 0;
}
  801dc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <devcons_write>:
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	57                   	push   %edi
  801dce:	56                   	push   %esi
  801dcf:	53                   	push   %ebx
  801dd0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ddb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801de1:	eb 31                	jmp    801e14 <devcons_write+0x4a>
		m = n - tot;
  801de3:	8b 75 10             	mov    0x10(%ebp),%esi
  801de6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801de8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801deb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801df0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801df3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801df7:	03 45 0c             	add    0xc(%ebp),%eax
  801dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfe:	89 3c 24             	mov    %edi,(%esp)
  801e01:	e8 be eb ff ff       	call   8009c4 <memmove>
		sys_cputs(buf, m);
  801e06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e0a:	89 3c 24             	mov    %edi,(%esp)
  801e0d:	e8 64 ed ff ff       	call   800b76 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e12:	01 f3                	add    %esi,%ebx
  801e14:	89 d8                	mov    %ebx,%eax
  801e16:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e19:	72 c8                	jb     801de3 <devcons_write+0x19>
}
  801e1b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5f                   	pop    %edi
  801e24:	5d                   	pop    %ebp
  801e25:	c3                   	ret    

00801e26 <devcons_read>:
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e35:	75 07                	jne    801e3e <devcons_read+0x18>
  801e37:	eb 2a                	jmp    801e63 <devcons_read+0x3d>
		sys_yield();
  801e39:	e8 e6 ed ff ff       	call   800c24 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e3e:	66 90                	xchg   %ax,%ax
  801e40:	e8 4f ed ff ff       	call   800b94 <sys_cgetc>
  801e45:	85 c0                	test   %eax,%eax
  801e47:	74 f0                	je     801e39 <devcons_read+0x13>
	if (c < 0)
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 16                	js     801e63 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801e4d:	83 f8 04             	cmp    $0x4,%eax
  801e50:	74 0c                	je     801e5e <devcons_read+0x38>
	*(char*)vbuf = c;
  801e52:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e55:	88 02                	mov    %al,(%edx)
	return 1;
  801e57:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5c:	eb 05                	jmp    801e63 <devcons_read+0x3d>
		return 0;
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <cputchar>:
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e71:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e78:	00 
  801e79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 f2 ec ff ff       	call   800b76 <sys_cputs>
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <getchar>:
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801e8c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e93:	00 
  801e94:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea2:	e8 2e f6 ff ff       	call   8014d5 <read>
	if (r < 0)
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 0f                	js     801eba <getchar+0x34>
	if (r < 1)
  801eab:	85 c0                	test   %eax,%eax
  801ead:	7e 06                	jle    801eb5 <getchar+0x2f>
	return c;
  801eaf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eb3:	eb 05                	jmp    801eba <getchar+0x34>
		return -E_EOF;
  801eb5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    

00801ebc <iscons>:
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecc:	89 04 24             	mov    %eax,(%esp)
  801ecf:	e8 72 f3 ff ff       	call   801246 <fd_lookup>
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 11                	js     801ee9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee1:	39 10                	cmp    %edx,(%eax)
  801ee3:	0f 94 c0             	sete   %al
  801ee6:	0f b6 c0             	movzbl %al,%eax
}
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <opencons>:
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ef1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef4:	89 04 24             	mov    %eax,(%esp)
  801ef7:	e8 fb f2 ff ff       	call   8011f7 <fd_alloc>
		return r;
  801efc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 40                	js     801f42 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f09:	00 
  801f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f18:	e8 26 ed ff ff       	call   800c43 <sys_page_alloc>
		return r;
  801f1d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 1f                	js     801f42 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801f23:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f31:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f38:	89 04 24             	mov    %eax,(%esp)
  801f3b:	e8 90 f2 ff ff       	call   8011d0 <fd2num>
  801f40:	89 c2                	mov    %eax,%edx
}
  801f42:	89 d0                	mov    %edx,%eax
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	56                   	push   %esi
  801f4a:	53                   	push   %ebx
  801f4b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801f4e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f51:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f57:	e8 a9 ec ff ff       	call   800c05 <sys_getenvid>
  801f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f63:	8b 55 08             	mov    0x8(%ebp),%edx
  801f66:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f6a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f72:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  801f79:	e8 79 e2 ff ff       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f82:	8b 45 10             	mov    0x10(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 09 e2 ff ff       	call   800196 <vcprintf>
	cprintf("\n");
  801f8d:	c7 04 24 4f 24 80 00 	movl   $0x80244f,(%esp)
  801f94:	e8 5e e2 ff ff       	call   8001f7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f99:	cc                   	int3   
  801f9a:	eb fd                	jmp    801f99 <_panic+0x53>

00801f9c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  801fa2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa9:	75 70                	jne    80201b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  801fab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801fb2:	00 
  801fb3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801fba:	ee 
  801fbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc2:	e8 7c ec ff ff       	call   800c43 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	79 1c                	jns    801fe7 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  801fcb:	c7 44 24 08 18 2a 80 	movl   $0x802a18,0x8(%esp)
  801fd2:	00 
  801fd3:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801fda:	00 
  801fdb:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  801fe2:	e8 5f ff ff ff       	call   801f46 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  801fe7:	c7 44 24 04 25 20 80 	movl   $0x802025,0x4(%esp)
  801fee:	00 
  801fef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff6:	e8 e8 ed ff ff       	call   800de3 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	79 1c                	jns    80201b <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  801fff:	c7 44 24 08 40 2a 80 	movl   $0x802a40,0x8(%esp)
  802006:	00 
  802007:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80200e:	00 
  80200f:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  802016:	e8 2b ff ff ff       	call   801f46 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
  80201e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802025:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802026:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80202b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80202d:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  802030:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  802034:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802038:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  80203a:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  80203c:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  80203d:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  802040:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  802042:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  802045:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802046:	83 c4 04             	add    $0x4,%esp
    popf;
  802049:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  80204a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  80204b:	c3                   	ret    
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	56                   	push   %esi
  802054:	53                   	push   %ebx
  802055:	83 ec 10             	sub    $0x10,%esp
  802058:	8b 75 08             	mov    0x8(%ebp),%esi
  80205b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802061:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802063:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802068:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80206b:	89 04 24             	mov    %eax,(%esp)
  80206e:	e8 e6 ed ff ff       	call   800e59 <sys_ipc_recv>
    if(r < 0){
  802073:	85 c0                	test   %eax,%eax
  802075:	79 16                	jns    80208d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802077:	85 f6                	test   %esi,%esi
  802079:	74 06                	je     802081 <ipc_recv+0x31>
            *from_env_store = 0;
  80207b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802081:	85 db                	test   %ebx,%ebx
  802083:	74 2c                	je     8020b1 <ipc_recv+0x61>
            *perm_store = 0;
  802085:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80208b:	eb 24                	jmp    8020b1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80208d:	85 f6                	test   %esi,%esi
  80208f:	74 0a                	je     80209b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802091:	a1 08 40 80 00       	mov    0x804008,%eax
  802096:	8b 40 74             	mov    0x74(%eax),%eax
  802099:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80209b:	85 db                	test   %ebx,%ebx
  80209d:	74 0a                	je     8020a9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80209f:	a1 08 40 80 00       	mov    0x804008,%eax
  8020a4:	8b 40 78             	mov    0x78(%eax),%eax
  8020a7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8020ae:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	57                   	push   %edi
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 1c             	sub    $0x1c,%esp
  8020c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  8020ca:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  8020cc:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8020d1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8020d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8020d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	e8 4b ed ff ff       	call   800e36 <sys_ipc_try_send>
        if(r == 0){
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	74 28                	je     802117 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8020ef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020f2:	74 1c                	je     802110 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8020f4:	c7 44 24 08 82 2a 80 	movl   $0x802a82,0x8(%esp)
  8020fb:	00 
  8020fc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802103:	00 
  802104:	c7 04 24 99 2a 80 00 	movl   $0x802a99,(%esp)
  80210b:	e8 36 fe ff ff       	call   801f46 <_panic>
        }
        sys_yield();
  802110:	e8 0f eb ff ff       	call   800c24 <sys_yield>
    }
  802115:	eb bd                	jmp    8020d4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802117:	83 c4 1c             	add    $0x1c,%esp
  80211a:	5b                   	pop    %ebx
  80211b:	5e                   	pop    %esi
  80211c:	5f                   	pop    %edi
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    

0080211f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802125:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80212a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80212d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802133:	8b 52 50             	mov    0x50(%edx),%edx
  802136:	39 ca                	cmp    %ecx,%edx
  802138:	75 0d                	jne    802147 <ipc_find_env+0x28>
			return envs[i].env_id;
  80213a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80213d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802142:	8b 40 40             	mov    0x40(%eax),%eax
  802145:	eb 0e                	jmp    802155 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802147:	83 c0 01             	add    $0x1,%eax
  80214a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80214f:	75 d9                	jne    80212a <ipc_find_env+0xb>
	return 0;
  802151:	66 b8 00 00          	mov    $0x0,%ax
}
  802155:	5d                   	pop    %ebp
  802156:	c3                   	ret    

00802157 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802157:	55                   	push   %ebp
  802158:	89 e5                	mov    %esp,%ebp
  80215a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215d:	89 d0                	mov    %edx,%eax
  80215f:	c1 e8 16             	shr    $0x16,%eax
  802162:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802169:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80216e:	f6 c1 01             	test   $0x1,%cl
  802171:	74 1d                	je     802190 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802173:	c1 ea 0c             	shr    $0xc,%edx
  802176:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80217d:	f6 c2 01             	test   $0x1,%dl
  802180:	74 0e                	je     802190 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802182:	c1 ea 0c             	shr    $0xc,%edx
  802185:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80218c:	ef 
  80218d:	0f b7 c0             	movzwl %ax,%eax
}
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__udivdi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	83 ec 0c             	sub    $0xc,%esp
  8021a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8021aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8021ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8021b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021bc:	89 ea                	mov    %ebp,%edx
  8021be:	89 0c 24             	mov    %ecx,(%esp)
  8021c1:	75 2d                	jne    8021f0 <__udivdi3+0x50>
  8021c3:	39 e9                	cmp    %ebp,%ecx
  8021c5:	77 61                	ja     802228 <__udivdi3+0x88>
  8021c7:	85 c9                	test   %ecx,%ecx
  8021c9:	89 ce                	mov    %ecx,%esi
  8021cb:	75 0b                	jne    8021d8 <__udivdi3+0x38>
  8021cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d2:	31 d2                	xor    %edx,%edx
  8021d4:	f7 f1                	div    %ecx
  8021d6:	89 c6                	mov    %eax,%esi
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	89 e8                	mov    %ebp,%eax
  8021dc:	f7 f6                	div    %esi
  8021de:	89 c5                	mov    %eax,%ebp
  8021e0:	89 f8                	mov    %edi,%eax
  8021e2:	f7 f6                	div    %esi
  8021e4:	89 ea                	mov    %ebp,%edx
  8021e6:	83 c4 0c             	add    $0xc,%esp
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	39 e8                	cmp    %ebp,%eax
  8021f2:	77 24                	ja     802218 <__udivdi3+0x78>
  8021f4:	0f bd e8             	bsr    %eax,%ebp
  8021f7:	83 f5 1f             	xor    $0x1f,%ebp
  8021fa:	75 3c                	jne    802238 <__udivdi3+0x98>
  8021fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  802200:	39 34 24             	cmp    %esi,(%esp)
  802203:	0f 86 9f 00 00 00    	jbe    8022a8 <__udivdi3+0x108>
  802209:	39 d0                	cmp    %edx,%eax
  80220b:	0f 82 97 00 00 00    	jb     8022a8 <__udivdi3+0x108>
  802211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802218:	31 d2                	xor    %edx,%edx
  80221a:	31 c0                	xor    %eax,%eax
  80221c:	83 c4 0c             	add    $0xc,%esp
  80221f:	5e                   	pop    %esi
  802220:	5f                   	pop    %edi
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    
  802223:	90                   	nop
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	89 f8                	mov    %edi,%eax
  80222a:	f7 f1                	div    %ecx
  80222c:	31 d2                	xor    %edx,%edx
  80222e:	83 c4 0c             	add    $0xc,%esp
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    
  802235:	8d 76 00             	lea    0x0(%esi),%esi
  802238:	89 e9                	mov    %ebp,%ecx
  80223a:	8b 3c 24             	mov    (%esp),%edi
  80223d:	d3 e0                	shl    %cl,%eax
  80223f:	89 c6                	mov    %eax,%esi
  802241:	b8 20 00 00 00       	mov    $0x20,%eax
  802246:	29 e8                	sub    %ebp,%eax
  802248:	89 c1                	mov    %eax,%ecx
  80224a:	d3 ef                	shr    %cl,%edi
  80224c:	89 e9                	mov    %ebp,%ecx
  80224e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802252:	8b 3c 24             	mov    (%esp),%edi
  802255:	09 74 24 08          	or     %esi,0x8(%esp)
  802259:	89 d6                	mov    %edx,%esi
  80225b:	d3 e7                	shl    %cl,%edi
  80225d:	89 c1                	mov    %eax,%ecx
  80225f:	89 3c 24             	mov    %edi,(%esp)
  802262:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802266:	d3 ee                	shr    %cl,%esi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	d3 e2                	shl    %cl,%edx
  80226c:	89 c1                	mov    %eax,%ecx
  80226e:	d3 ef                	shr    %cl,%edi
  802270:	09 d7                	or     %edx,%edi
  802272:	89 f2                	mov    %esi,%edx
  802274:	89 f8                	mov    %edi,%eax
  802276:	f7 74 24 08          	divl   0x8(%esp)
  80227a:	89 d6                	mov    %edx,%esi
  80227c:	89 c7                	mov    %eax,%edi
  80227e:	f7 24 24             	mull   (%esp)
  802281:	39 d6                	cmp    %edx,%esi
  802283:	89 14 24             	mov    %edx,(%esp)
  802286:	72 30                	jb     8022b8 <__udivdi3+0x118>
  802288:	8b 54 24 04          	mov    0x4(%esp),%edx
  80228c:	89 e9                	mov    %ebp,%ecx
  80228e:	d3 e2                	shl    %cl,%edx
  802290:	39 c2                	cmp    %eax,%edx
  802292:	73 05                	jae    802299 <__udivdi3+0xf9>
  802294:	3b 34 24             	cmp    (%esp),%esi
  802297:	74 1f                	je     8022b8 <__udivdi3+0x118>
  802299:	89 f8                	mov    %edi,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	e9 7a ff ff ff       	jmp    80221c <__udivdi3+0x7c>
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 d2                	xor    %edx,%edx
  8022aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8022af:	e9 68 ff ff ff       	jmp    80221c <__udivdi3+0x7c>
  8022b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	83 c4 0c             	add    $0xc,%esp
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    
  8022c4:	66 90                	xchg   %ax,%ax
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	83 ec 14             	sub    $0x14,%esp
  8022d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8022da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8022de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8022e2:	89 c7                	mov    %eax,%edi
  8022e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8022ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022f0:	89 34 24             	mov    %esi,(%esp)
  8022f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	89 c2                	mov    %eax,%edx
  8022fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022ff:	75 17                	jne    802318 <__umoddi3+0x48>
  802301:	39 fe                	cmp    %edi,%esi
  802303:	76 4b                	jbe    802350 <__umoddi3+0x80>
  802305:	89 c8                	mov    %ecx,%eax
  802307:	89 fa                	mov    %edi,%edx
  802309:	f7 f6                	div    %esi
  80230b:	89 d0                	mov    %edx,%eax
  80230d:	31 d2                	xor    %edx,%edx
  80230f:	83 c4 14             	add    $0x14,%esp
  802312:	5e                   	pop    %esi
  802313:	5f                   	pop    %edi
  802314:	5d                   	pop    %ebp
  802315:	c3                   	ret    
  802316:	66 90                	xchg   %ax,%ax
  802318:	39 f8                	cmp    %edi,%eax
  80231a:	77 54                	ja     802370 <__umoddi3+0xa0>
  80231c:	0f bd e8             	bsr    %eax,%ebp
  80231f:	83 f5 1f             	xor    $0x1f,%ebp
  802322:	75 5c                	jne    802380 <__umoddi3+0xb0>
  802324:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802328:	39 3c 24             	cmp    %edi,(%esp)
  80232b:	0f 87 e7 00 00 00    	ja     802418 <__umoddi3+0x148>
  802331:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802335:	29 f1                	sub    %esi,%ecx
  802337:	19 c7                	sbb    %eax,%edi
  802339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802341:	8b 44 24 08          	mov    0x8(%esp),%eax
  802345:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802349:	83 c4 14             	add    $0x14,%esp
  80234c:	5e                   	pop    %esi
  80234d:	5f                   	pop    %edi
  80234e:	5d                   	pop    %ebp
  80234f:	c3                   	ret    
  802350:	85 f6                	test   %esi,%esi
  802352:	89 f5                	mov    %esi,%ebp
  802354:	75 0b                	jne    802361 <__umoddi3+0x91>
  802356:	b8 01 00 00 00       	mov    $0x1,%eax
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	f7 f6                	div    %esi
  80235f:	89 c5                	mov    %eax,%ebp
  802361:	8b 44 24 04          	mov    0x4(%esp),%eax
  802365:	31 d2                	xor    %edx,%edx
  802367:	f7 f5                	div    %ebp
  802369:	89 c8                	mov    %ecx,%eax
  80236b:	f7 f5                	div    %ebp
  80236d:	eb 9c                	jmp    80230b <__umoddi3+0x3b>
  80236f:	90                   	nop
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 fa                	mov    %edi,%edx
  802374:	83 c4 14             	add    $0x14,%esp
  802377:	5e                   	pop    %esi
  802378:	5f                   	pop    %edi
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    
  80237b:	90                   	nop
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	8b 04 24             	mov    (%esp),%eax
  802383:	be 20 00 00 00       	mov    $0x20,%esi
  802388:	89 e9                	mov    %ebp,%ecx
  80238a:	29 ee                	sub    %ebp,%esi
  80238c:	d3 e2                	shl    %cl,%edx
  80238e:	89 f1                	mov    %esi,%ecx
  802390:	d3 e8                	shr    %cl,%eax
  802392:	89 e9                	mov    %ebp,%ecx
  802394:	89 44 24 04          	mov    %eax,0x4(%esp)
  802398:	8b 04 24             	mov    (%esp),%eax
  80239b:	09 54 24 04          	or     %edx,0x4(%esp)
  80239f:	89 fa                	mov    %edi,%edx
  8023a1:	d3 e0                	shl    %cl,%eax
  8023a3:	89 f1                	mov    %esi,%ecx
  8023a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8023ad:	d3 ea                	shr    %cl,%edx
  8023af:	89 e9                	mov    %ebp,%ecx
  8023b1:	d3 e7                	shl    %cl,%edi
  8023b3:	89 f1                	mov    %esi,%ecx
  8023b5:	d3 e8                	shr    %cl,%eax
  8023b7:	89 e9                	mov    %ebp,%ecx
  8023b9:	09 f8                	or     %edi,%eax
  8023bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8023bf:	f7 74 24 04          	divl   0x4(%esp)
  8023c3:	d3 e7                	shl    %cl,%edi
  8023c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023c9:	89 d7                	mov    %edx,%edi
  8023cb:	f7 64 24 08          	mull   0x8(%esp)
  8023cf:	39 d7                	cmp    %edx,%edi
  8023d1:	89 c1                	mov    %eax,%ecx
  8023d3:	89 14 24             	mov    %edx,(%esp)
  8023d6:	72 2c                	jb     802404 <__umoddi3+0x134>
  8023d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8023dc:	72 22                	jb     802400 <__umoddi3+0x130>
  8023de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023e2:	29 c8                	sub    %ecx,%eax
  8023e4:	19 d7                	sbb    %edx,%edi
  8023e6:	89 e9                	mov    %ebp,%ecx
  8023e8:	89 fa                	mov    %edi,%edx
  8023ea:	d3 e8                	shr    %cl,%eax
  8023ec:	89 f1                	mov    %esi,%ecx
  8023ee:	d3 e2                	shl    %cl,%edx
  8023f0:	89 e9                	mov    %ebp,%ecx
  8023f2:	d3 ef                	shr    %cl,%edi
  8023f4:	09 d0                	or     %edx,%eax
  8023f6:	89 fa                	mov    %edi,%edx
  8023f8:	83 c4 14             	add    $0x14,%esp
  8023fb:	5e                   	pop    %esi
  8023fc:	5f                   	pop    %edi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    
  8023ff:	90                   	nop
  802400:	39 d7                	cmp    %edx,%edi
  802402:	75 da                	jne    8023de <__umoddi3+0x10e>
  802404:	8b 14 24             	mov    (%esp),%edx
  802407:	89 c1                	mov    %eax,%ecx
  802409:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80240d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802411:	eb cb                	jmp    8023de <__umoddi3+0x10e>
  802413:	90                   	nop
  802414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802418:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80241c:	0f 82 0f ff ff ff    	jb     802331 <__umoddi3+0x61>
  802422:	e9 1a ff ff ff       	jmp    802341 <__umoddi3+0x71>
