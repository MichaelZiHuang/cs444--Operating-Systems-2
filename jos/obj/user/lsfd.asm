
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 01 01 00 00       	call   800132 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	c7 04 24 40 23 80 00 	movl   $0x802340,(%esp)
  800040:	e8 f1 01 00 00       	call   800236 <cprintf>
	exit();
  800045:	e8 30 01 00 00       	call   80017a <exit>
}
  80004a:	c9                   	leave  
  80004b:	c3                   	ret    

0080004c <umain>:

void
umain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	57                   	push   %edi
  800050:	56                   	push   %esi
  800051:	53                   	push   %ebx
  800052:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800058:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800062:	8b 45 0c             	mov    0xc(%ebp),%eax
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	8d 45 08             	lea    0x8(%ebp),%eax
  80006c:	89 04 24             	mov    %eax,(%esp)
  80006f:	e8 67 0e 00 00       	call   800edb <argstart>
	int i, usefprint = 0;
  800074:	be 00 00 00 00       	mov    $0x0,%esi
	while ((i = argnext(&args)) >= 0)
  800079:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007f:	eb 11                	jmp    800092 <umain+0x46>
		if (i == '1')
  800081:	83 f8 31             	cmp    $0x31,%eax
  800084:	75 07                	jne    80008d <umain+0x41>
			usefprint = 1;
  800086:	be 01 00 00 00       	mov    $0x1,%esi
  80008b:	eb 05                	jmp    800092 <umain+0x46>
		else
			usage();
  80008d:	e8 a1 ff ff ff       	call   800033 <usage>
	while ((i = argnext(&args)) >= 0)
  800092:	89 1c 24             	mov    %ebx,(%esp)
  800095:	e8 79 0e 00 00       	call   800f13 <argnext>
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 e3                	jns    800081 <umain+0x35>
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a3:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000ad:	89 1c 24             	mov    %ebx,(%esp)
  8000b0:	e8 ac 14 00 00       	call   801561 <fstat>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 66                	js     80011f <umain+0xd3>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 36                	je     8000f3 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c0:	8b 40 04             	mov    0x4(%eax),%eax
  8000c3:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000ca:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000dd:	c7 44 24 04 54 23 80 	movl   $0x802354,0x4(%esp)
  8000e4:	00 
  8000e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ec:	e8 8f 18 00 00       	call   801980 <fprintf>
  8000f1:	eb 2c                	jmp    80011f <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000f6:	8b 40 04             	mov    0x4(%eax),%eax
  8000f9:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800100:	89 44 24 10          	mov    %eax,0x10(%esp)
  800104:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800107:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80010b:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80010f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800113:	c7 04 24 54 23 80 00 	movl   $0x802354,(%esp)
  80011a:	e8 17 01 00 00       	call   800236 <cprintf>
	for (i = 0; i < 32; i++)
  80011f:	83 c3 01             	add    $0x1,%ebx
  800122:	83 fb 20             	cmp    $0x20,%ebx
  800125:	75 82                	jne    8000a9 <umain+0x5d>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800127:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
  800137:	83 ec 10             	sub    $0x10,%esp
  80013a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800140:	e8 f0 0a 00 00       	call   800c35 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800145:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800152:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800157:	85 db                	test   %ebx,%ebx
  800159:	7e 07                	jle    800162 <libmain+0x30>
		binaryname = argv[0];
  80015b:	8b 06                	mov    (%esi),%eax
  80015d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800162:	89 74 24 04          	mov    %esi,0x4(%esp)
  800166:	89 1c 24             	mov    %ebx,(%esp)
  800169:	e8 de fe ff ff       	call   80004c <umain>

	// exit gracefully
	exit();
  80016e:	e8 07 00 00 00       	call   80017a <exit>
}
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800180:	e8 90 10 00 00       	call   801215 <close_all>
	sys_env_destroy(0);
  800185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018c:	e8 52 0a 00 00       	call   800be3 <sys_env_destroy>
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 14             	sub    $0x14,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 19                	jne    8001cb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b9:	00 
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 e1 09 00 00       	call   800ba6 <sys_cputs>
		b->idx = 0;
  8001c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cf:	83 c4 14             	add    $0x14,%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800200:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020a:	c7 04 24 93 01 80 00 	movl   $0x800193,(%esp)
  800211:	e8 a8 01 00 00       	call   8003be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800216:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 78 09 00 00       	call   800ba6 <sys_cputs>

	return b.cnt;
}
  80022e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	89 04 24             	mov    %eax,(%esp)
  800249:	e8 87 ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 3c             	sub    $0x3c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d7                	mov    %edx,%edi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 c3                	mov    %eax,%ebx
  800269:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800272:	b9 00 00 00 00       	mov    $0x0,%ecx
  800277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80027d:	39 d9                	cmp    %ebx,%ecx
  80027f:	72 05                	jb     800286 <printnum+0x36>
  800281:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800284:	77 69                	ja     8002ef <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800289:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80028d:	83 ee 01             	sub    $0x1,%esi
  800290:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 44 24 08          	mov    0x8(%esp),%eax
  80029c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002a0:	89 c3                	mov    %eax,%ebx
  8002a2:	89 d6                	mov    %edx,%esi
  8002a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	e8 dc 1d 00 00       	call   8020a0 <__udivdi3>
  8002c4:	89 d9                	mov    %ebx,%ecx
  8002c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 71 ff ff ff       	call   800250 <printnum>
  8002df:	eb 1b                	jmp    8002fc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff d3                	call   *%ebx
  8002ed:	eb 03                	jmp    8002f2 <printnum+0xa2>
  8002ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8002f2:	83 ee 01             	sub    $0x1,%esi
  8002f5:	85 f6                	test   %esi,%esi
  8002f7:	7f e8                	jg     8002e1 <printnum+0x91>
  8002f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800307:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80031b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031f:	e8 ac 1e 00 00       	call   8021d0 <__umoddi3>
  800324:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800328:	0f be 80 86 23 80 00 	movsbl 0x802386(%eax),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800335:	ff d0                	call   *%eax
}
  800337:	83 c4 3c             	add    $0x3c,%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800342:	83 fa 01             	cmp    $0x1,%edx
  800345:	7e 0e                	jle    800355 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800347:	8b 10                	mov    (%eax),%edx
  800349:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034c:	89 08                	mov    %ecx,(%eax)
  80034e:	8b 02                	mov    (%edx),%eax
  800350:	8b 52 04             	mov    0x4(%edx),%edx
  800353:	eb 22                	jmp    800377 <getuint+0x38>
	else if (lflag)
  800355:	85 d2                	test   %edx,%edx
  800357:	74 10                	je     800369 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
  800367:	eb 0e                	jmp    800377 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800383:	8b 10                	mov    (%eax),%edx
  800385:	3b 50 04             	cmp    0x4(%eax),%edx
  800388:	73 0a                	jae    800394 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038d:	89 08                	mov    %ecx,(%eax)
  80038f:	8b 45 08             	mov    0x8(%ebp),%eax
  800392:	88 02                	mov    %al,(%edx)
}
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <printfmt>:
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80039c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 02 00 00 00       	call   8003be <vprintfmt>
}
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <vprintfmt>:
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	83 ec 3c             	sub    $0x3c,%esp
  8003c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003cd:	eb 1f                	jmp    8003ee <vprintfmt+0x30>
			if (ch == '\0'){
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	75 0f                	jne    8003e2 <vprintfmt+0x24>
				color = 0x0100;
  8003d3:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  8003da:	01 00 00 
  8003dd:	e9 b3 03 00 00       	jmp    800795 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8003e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ec:	89 f3                	mov    %esi,%ebx
  8003ee:	8d 73 01             	lea    0x1(%ebx),%esi
  8003f1:	0f b6 03             	movzbl (%ebx),%eax
  8003f4:	83 f8 25             	cmp    $0x25,%eax
  8003f7:	75 d6                	jne    8003cf <vprintfmt+0x11>
  8003f9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003fd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800404:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80040b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800412:	ba 00 00 00 00       	mov    $0x0,%edx
  800417:	eb 1d                	jmp    800436 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800419:	89 de                	mov    %ebx,%esi
			padc = '-';
  80041b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041f:	eb 15                	jmp    800436 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800421:	89 de                	mov    %ebx,%esi
			padc = '0';
  800423:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800427:	eb 0d                	jmp    800436 <vprintfmt+0x78>
				width = precision, precision = -1;
  800429:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80042f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8d 5e 01             	lea    0x1(%esi),%ebx
  800439:	0f b6 0e             	movzbl (%esi),%ecx
  80043c:	0f b6 c1             	movzbl %cl,%eax
  80043f:	83 e9 23             	sub    $0x23,%ecx
  800442:	80 f9 55             	cmp    $0x55,%cl
  800445:	0f 87 2a 03 00 00    	ja     800775 <vprintfmt+0x3b7>
  80044b:	0f b6 c9             	movzbl %cl,%ecx
  80044e:	ff 24 8d c0 24 80 00 	jmp    *0x8024c0(,%ecx,4)
  800455:	89 de                	mov    %ebx,%esi
  800457:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80045c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80045f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800463:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800466:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800469:	83 fb 09             	cmp    $0x9,%ebx
  80046c:	77 36                	ja     8004a4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80046e:	83 c6 01             	add    $0x1,%esi
			}
  800471:	eb e9                	jmp    80045c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 48 04             	lea    0x4(%eax),%ecx
  800479:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80047c:	8b 00                	mov    (%eax),%eax
  80047e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800481:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800483:	eb 22                	jmp    8004a7 <vprintfmt+0xe9>
  800485:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800488:	85 c9                	test   %ecx,%ecx
  80048a:	b8 00 00 00 00       	mov    $0x0,%eax
  80048f:	0f 49 c1             	cmovns %ecx,%eax
  800492:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800495:	89 de                	mov    %ebx,%esi
  800497:	eb 9d                	jmp    800436 <vprintfmt+0x78>
  800499:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80049b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004a2:	eb 92                	jmp    800436 <vprintfmt+0x78>
  8004a4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8004a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ab:	79 89                	jns    800436 <vprintfmt+0x78>
  8004ad:	e9 77 ff ff ff       	jmp    800429 <vprintfmt+0x6b>
			lflag++;
  8004b2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004b7:	e9 7a ff ff ff       	jmp    800436 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	89 04 24             	mov    %eax,(%esp)
  8004ce:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004d1:	e9 18 ff ff ff       	jmp    8003ee <vprintfmt+0x30>
			err = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 50 04             	lea    0x4(%eax),%edx
  8004dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	99                   	cltd   
  8004e2:	31 d0                	xor    %edx,%eax
  8004e4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e6:	83 f8 0f             	cmp    $0xf,%eax
  8004e9:	7f 0b                	jg     8004f6 <vprintfmt+0x138>
  8004eb:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8004f2:	85 d2                	test   %edx,%edx
  8004f4:	75 20                	jne    800516 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  8004f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fa:	c7 44 24 08 9e 23 80 	movl   $0x80239e,0x8(%esp)
  800501:	00 
  800502:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800506:	8b 45 08             	mov    0x8(%ebp),%eax
  800509:	89 04 24             	mov    %eax,(%esp)
  80050c:	e8 85 fe ff ff       	call   800396 <printfmt>
  800511:	e9 d8 fe ff ff       	jmp    8003ee <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800516:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051a:	c7 44 24 08 7a 27 80 	movl   $0x80277a,0x8(%esp)
  800521:	00 
  800522:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 65 fe ff ff       	call   800396 <printfmt>
  800531:	e9 b8 fe ff ff       	jmp    8003ee <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800536:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800539:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80054a:	85 f6                	test   %esi,%esi
  80054c:	b8 97 23 80 00       	mov    $0x802397,%eax
  800551:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800554:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800558:	0f 84 97 00 00 00    	je     8005f5 <vprintfmt+0x237>
  80055e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800562:	0f 8e 9b 00 00 00    	jle    800603 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800568:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056c:	89 34 24             	mov    %esi,(%esp)
  80056f:	e8 c4 02 00 00       	call   800838 <strnlen>
  800574:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800577:	29 c2                	sub    %eax,%edx
  800579:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80057c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800580:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800583:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800586:	8b 75 08             	mov    0x8(%ebp),%esi
  800589:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80058c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80058e:	eb 0f                	jmp    80059f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800590:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800594:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800597:	89 04 24             	mov    %eax,(%esp)
  80059a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80059c:	83 eb 01             	sub    $0x1,%ebx
  80059f:	85 db                	test   %ebx,%ebx
  8005a1:	7f ed                	jg     800590 <vprintfmt+0x1d2>
  8005a3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005a6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b0:	0f 49 c2             	cmovns %edx,%eax
  8005b3:	29 c2                	sub    %eax,%edx
  8005b5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005b8:	89 d7                	mov    %edx,%edi
  8005ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005bd:	eb 50                	jmp    80060f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8005bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c3:	74 1e                	je     8005e3 <vprintfmt+0x225>
  8005c5:	0f be d2             	movsbl %dl,%edx
  8005c8:	83 ea 20             	sub    $0x20,%edx
  8005cb:	83 fa 5e             	cmp    $0x5e,%edx
  8005ce:	76 13                	jbe    8005e3 <vprintfmt+0x225>
					putch('?', putdat);
  8005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005de:	ff 55 08             	call   *0x8(%ebp)
  8005e1:	eb 0d                	jmp    8005f0 <vprintfmt+0x232>
					putch(ch, putdat);
  8005e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f0:	83 ef 01             	sub    $0x1,%edi
  8005f3:	eb 1a                	jmp    80060f <vprintfmt+0x251>
  8005f5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005f8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005fb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800601:	eb 0c                	jmp    80060f <vprintfmt+0x251>
  800603:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800606:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800609:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80060c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80060f:	83 c6 01             	add    $0x1,%esi
  800612:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800616:	0f be c2             	movsbl %dl,%eax
  800619:	85 c0                	test   %eax,%eax
  80061b:	74 27                	je     800644 <vprintfmt+0x286>
  80061d:	85 db                	test   %ebx,%ebx
  80061f:	78 9e                	js     8005bf <vprintfmt+0x201>
  800621:	83 eb 01             	sub    $0x1,%ebx
  800624:	79 99                	jns    8005bf <vprintfmt+0x201>
  800626:	89 f8                	mov    %edi,%eax
  800628:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80062b:	8b 75 08             	mov    0x8(%ebp),%esi
  80062e:	89 c3                	mov    %eax,%ebx
  800630:	eb 1a                	jmp    80064c <vprintfmt+0x28e>
				putch(' ', putdat);
  800632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800636:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80063d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80063f:	83 eb 01             	sub    $0x1,%ebx
  800642:	eb 08                	jmp    80064c <vprintfmt+0x28e>
  800644:	89 fb                	mov    %edi,%ebx
  800646:	8b 75 08             	mov    0x8(%ebp),%esi
  800649:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e2                	jg     800632 <vprintfmt+0x274>
  800650:	89 75 08             	mov    %esi,0x8(%ebp)
  800653:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800656:	e9 93 fd ff ff       	jmp    8003ee <vprintfmt+0x30>
	if (lflag >= 2)
  80065b:	83 fa 01             	cmp    $0x1,%edx
  80065e:	7e 16                	jle    800676 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 08             	lea    0x8(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)
  800669:	8b 50 04             	mov    0x4(%eax),%edx
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800671:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800674:	eb 32                	jmp    8006a8 <vprintfmt+0x2ea>
	else if (lflag)
  800676:	85 d2                	test   %edx,%edx
  800678:	74 18                	je     800692 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 30                	mov    (%eax),%esi
  800685:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800688:	89 f0                	mov    %esi,%eax
  80068a:	c1 f8 1f             	sar    $0x1f,%eax
  80068d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800690:	eb 16                	jmp    8006a8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 30                	mov    (%eax),%esi
  80069d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006a0:	89 f0                	mov    %esi,%eax
  8006a2:	c1 f8 1f             	sar    $0x1f,%eax
  8006a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8006a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8006ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b7:	0f 89 80 00 00 00    	jns    80073d <vprintfmt+0x37f>
				putch('-', putdat);
  8006bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d1:	f7 d8                	neg    %eax
  8006d3:	83 d2 00             	adc    $0x0,%edx
  8006d6:	f7 da                	neg    %edx
			base = 10;
  8006d8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006dd:	eb 5e                	jmp    80073d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 58 fc ff ff       	call   80033f <getuint>
			base = 10;
  8006e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ec:	eb 4f                	jmp    80073d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f1:	e8 49 fc ff ff       	call   80033f <getuint>
            base = 8;
  8006f6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  8006fb:	eb 40                	jmp    80073d <vprintfmt+0x37f>
			putch('0', putdat);
  8006fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800701:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800708:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80070b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800716:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8d 50 04             	lea    0x4(%eax),%edx
  80071f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800722:	8b 00                	mov    (%eax),%eax
  800724:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800729:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072e:	eb 0d                	jmp    80073d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
  800733:	e8 07 fc ff ff       	call   80033f <getuint>
			base = 16;
  800738:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80073d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800741:	89 74 24 10          	mov    %esi,0x10(%esp)
  800745:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800748:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80074c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	89 54 24 04          	mov    %edx,0x4(%esp)
  800757:	89 fa                	mov    %edi,%edx
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	e8 ef fa ff ff       	call   800250 <printnum>
			break;
  800761:	e9 88 fc ff ff       	jmp    8003ee <vprintfmt+0x30>
			putch(ch, putdat);
  800766:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076a:	89 04 24             	mov    %eax,(%esp)
  80076d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800770:	e9 79 fc ff ff       	jmp    8003ee <vprintfmt+0x30>
			putch('%', putdat);
  800775:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800779:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800783:	89 f3                	mov    %esi,%ebx
  800785:	eb 03                	jmp    80078a <vprintfmt+0x3cc>
  800787:	83 eb 01             	sub    $0x1,%ebx
  80078a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80078e:	75 f7                	jne    800787 <vprintfmt+0x3c9>
  800790:	e9 59 fc ff ff       	jmp    8003ee <vprintfmt+0x30>
}
  800795:	83 c4 3c             	add    $0x3c,%esp
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5f                   	pop    %edi
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 28             	sub    $0x28,%esp
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ba:	85 c0                	test   %eax,%eax
  8007bc:	74 30                	je     8007ee <vsnprintf+0x51>
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	7e 2c                	jle    8007ee <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d7:	c7 04 24 79 03 80 00 	movl   $0x800379,(%esp)
  8007de:	e8 db fb ff ff       	call   8003be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ec:	eb 05                	jmp    8007f3 <vsnprintf+0x56>
		return -E_INVAL;
  8007ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    

008007f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800802:	8b 45 10             	mov    0x10(%ebp),%eax
  800805:	89 44 24 08          	mov    %eax,0x8(%esp)
  800809:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	89 04 24             	mov    %eax,(%esp)
  800816:	e8 82 ff ff ff       	call   80079d <vsnprintf>
	va_end(ap);

	return rc;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    
  80081d:	66 90                	xchg   %ax,%ax
  80081f:	90                   	nop

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 03                	jmp    800830 <strlen+0x10>
		n++;
  80082d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800830:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800834:	75 f7                	jne    80082d <strlen+0xd>
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
  800846:	eb 03                	jmp    80084b <strnlen+0x13>
		n++;
  800848:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084b:	39 d0                	cmp    %edx,%eax
  80084d:	74 06                	je     800855 <strnlen+0x1d>
  80084f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800853:	75 f3                	jne    800848 <strnlen+0x10>
	return n;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800861:	89 c2                	mov    %eax,%edx
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80086d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800870:	84 db                	test   %bl,%bl
  800872:	75 ef                	jne    800863 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	89 1c 24             	mov    %ebx,(%esp)
  800884:	e8 97 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800890:	01 d8                	add    %ebx,%eax
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	e8 bd ff ff ff       	call   800857 <strcpy>
	return dst;
}
  80089a:	89 d8                	mov    %ebx,%eax
  80089c:	83 c4 08             	add    $0x8,%esp
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ad:	89 f3                	mov    %esi,%ebx
  8008af:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b2:	89 f2                	mov    %esi,%edx
  8008b4:	eb 0f                	jmp    8008c5 <strncpy+0x23>
		*dst++ = *src;
  8008b6:	83 c2 01             	add    $0x1,%edx
  8008b9:	0f b6 01             	movzbl (%ecx),%eax
  8008bc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008c5:	39 da                	cmp    %ebx,%edx
  8008c7:	75 ed                	jne    8008b6 <strncpy+0x14>
	}
	return ret;
}
  8008c9:	89 f0                	mov    %esi,%eax
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008dd:	89 f0                	mov    %esi,%eax
  8008df:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	75 0b                	jne    8008f2 <strlcpy+0x23>
  8008e7:	eb 1d                	jmp    800906 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008f2:	39 d8                	cmp    %ebx,%eax
  8008f4:	74 0b                	je     800901 <strlcpy+0x32>
  8008f6:	0f b6 0a             	movzbl (%edx),%ecx
  8008f9:	84 c9                	test   %cl,%cl
  8008fb:	75 ec                	jne    8008e9 <strlcpy+0x1a>
  8008fd:	89 c2                	mov    %eax,%edx
  8008ff:	eb 02                	jmp    800903 <strlcpy+0x34>
  800901:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800903:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800906:	29 f0                	sub    %esi,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800915:	eb 06                	jmp    80091d <strcmp+0x11>
		p++, q++;
  800917:	83 c1 01             	add    $0x1,%ecx
  80091a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80091d:	0f b6 01             	movzbl (%ecx),%eax
  800920:	84 c0                	test   %al,%al
  800922:	74 04                	je     800928 <strcmp+0x1c>
  800924:	3a 02                	cmp    (%edx),%al
  800926:	74 ef                	je     800917 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 c0             	movzbl %al,%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	53                   	push   %ebx
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 c3                	mov    %eax,%ebx
  80093e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800941:	eb 06                	jmp    800949 <strncmp+0x17>
		n--, p++, q++;
  800943:	83 c0 01             	add    $0x1,%eax
  800946:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800949:	39 d8                	cmp    %ebx,%eax
  80094b:	74 15                	je     800962 <strncmp+0x30>
  80094d:	0f b6 08             	movzbl (%eax),%ecx
  800950:	84 c9                	test   %cl,%cl
  800952:	74 04                	je     800958 <strncmp+0x26>
  800954:	3a 0a                	cmp    (%edx),%cl
  800956:	74 eb                	je     800943 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	0f b6 12             	movzbl (%edx),%edx
  80095e:	29 d0                	sub    %edx,%eax
  800960:	eb 05                	jmp    800967 <strncmp+0x35>
		return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800974:	eb 07                	jmp    80097d <strchr+0x13>
		if (*s == c)
  800976:	38 ca                	cmp    %cl,%dl
  800978:	74 0f                	je     800989 <strchr+0x1f>
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	84 d2                	test   %dl,%dl
  800982:	75 f2                	jne    800976 <strchr+0xc>
			return (char *) s;
	return 0;
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	eb 07                	jmp    80099e <strfind+0x13>
		if (*s == c)
  800997:	38 ca                	cmp    %cl,%dl
  800999:	74 0a                	je     8009a5 <strfind+0x1a>
	for (; *s; s++)
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	0f b6 10             	movzbl (%eax),%edx
  8009a1:	84 d2                	test   %dl,%dl
  8009a3:	75 f2                	jne    800997 <strfind+0xc>
			break;
	return (char *) s;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b3:	85 c9                	test   %ecx,%ecx
  8009b5:	74 36                	je     8009ed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bd:	75 28                	jne    8009e7 <memset+0x40>
  8009bf:	f6 c1 03             	test   $0x3,%cl
  8009c2:	75 23                	jne    8009e7 <memset+0x40>
		c &= 0xFF;
  8009c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c8:	89 d3                	mov    %edx,%ebx
  8009ca:	c1 e3 08             	shl    $0x8,%ebx
  8009cd:	89 d6                	mov    %edx,%esi
  8009cf:	c1 e6 18             	shl    $0x18,%esi
  8009d2:	89 d0                	mov    %edx,%eax
  8009d4:	c1 e0 10             	shl    $0x10,%eax
  8009d7:	09 f0                	or     %esi,%eax
  8009d9:	09 c2                	or     %eax,%edx
  8009db:	89 d0                	mov    %edx,%eax
  8009dd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009df:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e2:	fc                   	cld    
  8009e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e5:	eb 06                	jmp    8009ed <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	fc                   	cld    
  8009eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a02:	39 c6                	cmp    %eax,%esi
  800a04:	73 35                	jae    800a3b <memmove+0x47>
  800a06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a09:	39 d0                	cmp    %edx,%eax
  800a0b:	73 2e                	jae    800a3b <memmove+0x47>
		s += n;
		d += n;
  800a0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a10:	89 d6                	mov    %edx,%esi
  800a12:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1a:	75 13                	jne    800a2f <memmove+0x3b>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 0e                	jne    800a2f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a21:	83 ef 04             	sub    $0x4,%edi
  800a24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a27:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a2a:	fd                   	std    
  800a2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2d:	eb 09                	jmp    800a38 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2f:	83 ef 01             	sub    $0x1,%edi
  800a32:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a35:	fd                   	std    
  800a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a38:	fc                   	cld    
  800a39:	eb 1d                	jmp    800a58 <memmove+0x64>
  800a3b:	89 f2                	mov    %esi,%edx
  800a3d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3f:	f6 c2 03             	test   $0x3,%dl
  800a42:	75 0f                	jne    800a53 <memmove+0x5f>
  800a44:	f6 c1 03             	test   $0x3,%cl
  800a47:	75 0a                	jne    800a53 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a49:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a4c:	89 c7                	mov    %eax,%edi
  800a4e:	fc                   	cld    
  800a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a51:	eb 05                	jmp    800a58 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a53:	89 c7                	mov    %eax,%edi
  800a55:	fc                   	cld    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a58:	5e                   	pop    %esi
  800a59:	5f                   	pop    %edi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a62:	8b 45 10             	mov    0x10(%ebp),%eax
  800a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	e8 79 ff ff ff       	call   8009f4 <memmove>
}
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a88:	89 d6                	mov    %edx,%esi
  800a8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8d:	eb 1a                	jmp    800aa9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a8f:	0f b6 02             	movzbl (%edx),%eax
  800a92:	0f b6 19             	movzbl (%ecx),%ebx
  800a95:	38 d8                	cmp    %bl,%al
  800a97:	74 0a                	je     800aa3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a99:	0f b6 c0             	movzbl %al,%eax
  800a9c:	0f b6 db             	movzbl %bl,%ebx
  800a9f:	29 d8                	sub    %ebx,%eax
  800aa1:	eb 0f                	jmp    800ab2 <memcmp+0x35>
		s1++, s2++;
  800aa3:	83 c2 01             	add    $0x1,%edx
  800aa6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800aa9:	39 f2                	cmp    %esi,%edx
  800aab:	75 e2                	jne    800a8f <memcmp+0x12>
	}

	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abf:	89 c2                	mov    %eax,%edx
  800ac1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac4:	eb 07                	jmp    800acd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac6:	38 08                	cmp    %cl,(%eax)
  800ac8:	74 07                	je     800ad1 <memfind+0x1b>
	for (; s < ends; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	39 d0                	cmp    %edx,%eax
  800acf:	72 f5                	jb     800ac6 <memfind+0x10>
			break;
	return (void *) s;
}
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 55 08             	mov    0x8(%ebp),%edx
  800adc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adf:	eb 03                	jmp    800ae4 <strtol+0x11>
		s++;
  800ae1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ae4:	0f b6 0a             	movzbl (%edx),%ecx
  800ae7:	80 f9 09             	cmp    $0x9,%cl
  800aea:	74 f5                	je     800ae1 <strtol+0xe>
  800aec:	80 f9 20             	cmp    $0x20,%cl
  800aef:	74 f0                	je     800ae1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800af1:	80 f9 2b             	cmp    $0x2b,%cl
  800af4:	75 0a                	jne    800b00 <strtol+0x2d>
		s++;
  800af6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
  800afe:	eb 11                	jmp    800b11 <strtol+0x3e>
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b05:	80 f9 2d             	cmp    $0x2d,%cl
  800b08:	75 07                	jne    800b11 <strtol+0x3e>
		s++, neg = 1;
  800b0a:	8d 52 01             	lea    0x1(%edx),%edx
  800b0d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b11:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b16:	75 15                	jne    800b2d <strtol+0x5a>
  800b18:	80 3a 30             	cmpb   $0x30,(%edx)
  800b1b:	75 10                	jne    800b2d <strtol+0x5a>
  800b1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b21:	75 0a                	jne    800b2d <strtol+0x5a>
		s += 2, base = 16;
  800b23:	83 c2 02             	add    $0x2,%edx
  800b26:	b8 10 00 00 00       	mov    $0x10,%eax
  800b2b:	eb 10                	jmp    800b3d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	75 0c                	jne    800b3d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b31:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b33:	80 3a 30             	cmpb   $0x30,(%edx)
  800b36:	75 05                	jne    800b3d <strtol+0x6a>
		s++, base = 8;
  800b38:	83 c2 01             	add    $0x1,%edx
  800b3b:	b0 08                	mov    $0x8,%al
		base = 10;
  800b3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b42:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b45:	0f b6 0a             	movzbl (%edx),%ecx
  800b48:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b4b:	89 f0                	mov    %esi,%eax
  800b4d:	3c 09                	cmp    $0x9,%al
  800b4f:	77 08                	ja     800b59 <strtol+0x86>
			dig = *s - '0';
  800b51:	0f be c9             	movsbl %cl,%ecx
  800b54:	83 e9 30             	sub    $0x30,%ecx
  800b57:	eb 20                	jmp    800b79 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b59:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b5c:	89 f0                	mov    %esi,%eax
  800b5e:	3c 19                	cmp    $0x19,%al
  800b60:	77 08                	ja     800b6a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b62:	0f be c9             	movsbl %cl,%ecx
  800b65:	83 e9 57             	sub    $0x57,%ecx
  800b68:	eb 0f                	jmp    800b79 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b6a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	3c 19                	cmp    $0x19,%al
  800b71:	77 16                	ja     800b89 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b73:	0f be c9             	movsbl %cl,%ecx
  800b76:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b79:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b7c:	7d 0f                	jge    800b8d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b85:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b87:	eb bc                	jmp    800b45 <strtol+0x72>
  800b89:	89 d8                	mov    %ebx,%eax
  800b8b:	eb 02                	jmp    800b8f <strtol+0xbc>
  800b8d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b93:	74 05                	je     800b9a <strtol+0xc7>
		*endptr = (char *) s;
  800b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b98:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b9a:	f7 d8                	neg    %eax
  800b9c:	85 ff                	test   %edi,%edi
  800b9e:	0f 44 c3             	cmove  %ebx,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 c3                	mov    %eax,%ebx
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	89 c6                	mov    %eax,%esi
  800bbd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 cb                	mov    %ecx,%ebx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	89 ce                	mov    %ecx,%esi
  800bff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 28                	jle    800c2d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c09:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c10:	00 
  800c11:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800c18:	00 
  800c19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c20:	00 
  800c21:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800c28:	e8 c9 12 00 00       	call   801ef6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2d:	83 c4 2c             	add    $0x2c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 02 00 00 00       	mov    $0x2,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_yield>:

void
sys_yield(void)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	89 d3                	mov    %edx,%ebx
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c7c:	be 00 00 00 00       	mov    $0x0,%esi
  800c81:	b8 04 00 00 00       	mov    $0x4,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8f:	89 f7                	mov    %esi,%edi
  800c91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 28                	jle    800cbf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ca2:	00 
  800ca3:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800caa:	00 
  800cab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb2:	00 
  800cb3:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800cba:	e8 37 12 00 00       	call   801ef6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbf:	83 c4 2c             	add    $0x2c,%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cd0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 28                	jle    800d12 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cee:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d05:	00 
  800d06:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800d0d:	e8 e4 11 00 00       	call   801ef6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d12:	83 c4 2c             	add    $0x2c,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800d60:	e8 91 11 00 00       	call   801ef6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d65:	83 c4 2c             	add    $0x2c,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 df                	mov    %ebx,%edi
  800d88:	89 de                	mov    %ebx,%esi
  800d8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 28                	jle    800db8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d94:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800da3:	00 
  800da4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dab:	00 
  800dac:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800db3:	e8 3e 11 00 00       	call   801ef6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db8:	83 c4 2c             	add    $0x2c,%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 28                	jle    800e0b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dee:	00 
  800def:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfe:	00 
  800dff:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800e06:	e8 eb 10 00 00       	call   801ef6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e0b:	83 c4 2c             	add    $0x2c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	89 de                	mov    %ebx,%esi
  800e30:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 28                	jle    800e5e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e41:	00 
  800e42:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e51:	00 
  800e52:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800e59:	e8 98 10 00 00       	call   801ef6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5e:	83 c4 2c             	add    $0x2c,%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e6c:	be 00 00 00 00       	mov    $0x0,%esi
  800e71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e82:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 cb                	mov    %ecx,%ebx
  800ea1:	89 cf                	mov    %ecx,%edi
  800ea3:	89 ce                	mov    %ecx,%esi
  800ea5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	7e 28                	jle    800ed3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eaf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec6:	00 
  800ec7:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800ece:	e8 23 10 00 00       	call   801ef6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed3:	83 c4 2c             	add    $0x2c,%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	53                   	push   %ebx
  800edf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee5:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800ee8:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  800eea:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800eed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef2:	83 39 01             	cmpl   $0x1,(%ecx)
  800ef5:	7e 0f                	jle    800f06 <argstart+0x2b>
  800ef7:	85 d2                	test   %edx,%edx
  800ef9:	ba 00 00 00 00       	mov    $0x0,%edx
  800efe:	bb 51 23 80 00       	mov    $0x802351,%ebx
  800f03:	0f 44 da             	cmove  %edx,%ebx
  800f06:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  800f09:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800f10:	5b                   	pop    %ebx
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <argnext>:

int
argnext(struct Argstate *args)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	53                   	push   %ebx
  800f17:	83 ec 14             	sub    $0x14,%esp
  800f1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800f1d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800f24:	8b 43 08             	mov    0x8(%ebx),%eax
  800f27:	85 c0                	test   %eax,%eax
  800f29:	74 71                	je     800f9c <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  800f2b:	80 38 00             	cmpb   $0x0,(%eax)
  800f2e:	75 50                	jne    800f80 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800f30:	8b 0b                	mov    (%ebx),%ecx
  800f32:	83 39 01             	cmpl   $0x1,(%ecx)
  800f35:	74 57                	je     800f8e <argnext+0x7b>
		    || args->argv[1][0] != '-'
  800f37:	8b 53 04             	mov    0x4(%ebx),%edx
  800f3a:	8b 42 04             	mov    0x4(%edx),%eax
  800f3d:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f40:	75 4c                	jne    800f8e <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  800f42:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f46:	74 46                	je     800f8e <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800f48:	83 c0 01             	add    $0x1,%eax
  800f4b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f4e:	8b 01                	mov    (%ecx),%eax
  800f50:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5b:	8d 42 08             	lea    0x8(%edx),%eax
  800f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f62:	83 c2 04             	add    $0x4,%edx
  800f65:	89 14 24             	mov    %edx,(%esp)
  800f68:	e8 87 fa ff ff       	call   8009f4 <memmove>
		(*args->argc)--;
  800f6d:	8b 03                	mov    (%ebx),%eax
  800f6f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800f72:	8b 43 08             	mov    0x8(%ebx),%eax
  800f75:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f78:	75 06                	jne    800f80 <argnext+0x6d>
  800f7a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f7e:	74 0e                	je     800f8e <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800f80:	8b 53 08             	mov    0x8(%ebx),%edx
  800f83:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800f86:	83 c2 01             	add    $0x1,%edx
  800f89:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800f8c:	eb 13                	jmp    800fa1 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  800f8e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800f95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800f9a:	eb 05                	jmp    800fa1 <argnext+0x8e>
		return -1;
  800f9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800fa1:	83 c4 14             	add    $0x14,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	53                   	push   %ebx
  800fab:	83 ec 14             	sub    $0x14,%esp
  800fae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800fb1:	8b 43 08             	mov    0x8(%ebx),%eax
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	74 5a                	je     801012 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  800fb8:	80 38 00             	cmpb   $0x0,(%eax)
  800fbb:	74 0c                	je     800fc9 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800fbd:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800fc0:	c7 43 08 51 23 80 00 	movl   $0x802351,0x8(%ebx)
  800fc7:	eb 44                	jmp    80100d <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  800fc9:	8b 03                	mov    (%ebx),%eax
  800fcb:	83 38 01             	cmpl   $0x1,(%eax)
  800fce:	7e 2f                	jle    800fff <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  800fd0:	8b 53 04             	mov    0x4(%ebx),%edx
  800fd3:	8b 4a 04             	mov    0x4(%edx),%ecx
  800fd6:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800fd9:	8b 00                	mov    (%eax),%eax
  800fdb:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800fe2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe6:	8d 42 08             	lea    0x8(%edx),%eax
  800fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fed:	83 c2 04             	add    $0x4,%edx
  800ff0:	89 14 24             	mov    %edx,(%esp)
  800ff3:	e8 fc f9 ff ff       	call   8009f4 <memmove>
		(*args->argc)--;
  800ff8:	8b 03                	mov    (%ebx),%eax
  800ffa:	83 28 01             	subl   $0x1,(%eax)
  800ffd:	eb 0e                	jmp    80100d <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  800fff:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801006:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80100d:	8b 43 0c             	mov    0xc(%ebx),%eax
  801010:	eb 05                	jmp    801017 <argnextvalue+0x70>
		return 0;
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801017:	83 c4 14             	add    $0x14,%esp
  80101a:	5b                   	pop    %ebx
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    

0080101d <argvalue>:
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 18             	sub    $0x18,%esp
  801023:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801026:	8b 51 0c             	mov    0xc(%ecx),%edx
  801029:	89 d0                	mov    %edx,%eax
  80102b:	85 d2                	test   %edx,%edx
  80102d:	75 08                	jne    801037 <argvalue+0x1a>
  80102f:	89 0c 24             	mov    %ecx,(%esp)
  801032:	e8 70 ff ff ff       	call   800fa7 <argnextvalue>
}
  801037:	c9                   	leave  
  801038:	c3                   	ret    
  801039:	66 90                	xchg   %ax,%ax
  80103b:	66 90                	xchg   %ax,%ax
  80103d:	66 90                	xchg   %ax,%ax
  80103f:	90                   	nop

00801040 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	05 00 00 00 30       	add    $0x30000000,%eax
  80104b:	c1 e8 0c             	shr    $0xc,%eax
}
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80105b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801060:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801072:	89 c2                	mov    %eax,%edx
  801074:	c1 ea 16             	shr    $0x16,%edx
  801077:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80107e:	f6 c2 01             	test   $0x1,%dl
  801081:	74 11                	je     801094 <fd_alloc+0x2d>
  801083:	89 c2                	mov    %eax,%edx
  801085:	c1 ea 0c             	shr    $0xc,%edx
  801088:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	75 09                	jne    80109d <fd_alloc+0x36>
			*fd_store = fd;
  801094:	89 01                	mov    %eax,(%ecx)
			return 0;
  801096:	b8 00 00 00 00       	mov    $0x0,%eax
  80109b:	eb 17                	jmp    8010b4 <fd_alloc+0x4d>
  80109d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010a7:	75 c9                	jne    801072 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8010a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010bc:	83 f8 1f             	cmp    $0x1f,%eax
  8010bf:	77 36                	ja     8010f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010c1:	c1 e0 0c             	shl    $0xc,%eax
  8010c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	c1 ea 16             	shr    $0x16,%edx
  8010ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d5:	f6 c2 01             	test   $0x1,%dl
  8010d8:	74 24                	je     8010fe <fd_lookup+0x48>
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	c1 ea 0c             	shr    $0xc,%edx
  8010df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e6:	f6 c2 01             	test   $0x1,%dl
  8010e9:	74 1a                	je     801105 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8010f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f5:	eb 13                	jmp    80110a <fd_lookup+0x54>
		return -E_INVAL;
  8010f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fc:	eb 0c                	jmp    80110a <fd_lookup+0x54>
		return -E_INVAL;
  8010fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801103:	eb 05                	jmp    80110a <fd_lookup+0x54>
  801105:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 18             	sub    $0x18,%esp
  801112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801115:	ba 28 27 80 00       	mov    $0x802728,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80111a:	eb 13                	jmp    80112f <dev_lookup+0x23>
  80111c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80111f:	39 08                	cmp    %ecx,(%eax)
  801121:	75 0c                	jne    80112f <dev_lookup+0x23>
			*dev = devtab[i];
  801123:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801126:	89 01                	mov    %eax,(%ecx)
			return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
  80112d:	eb 30                	jmp    80115f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80112f:	8b 02                	mov    (%edx),%eax
  801131:	85 c0                	test   %eax,%eax
  801133:	75 e7                	jne    80111c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801135:	a1 08 40 80 00       	mov    0x804008,%eax
  80113a:	8b 40 48             	mov    0x48(%eax),%eax
  80113d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801141:	89 44 24 04          	mov    %eax,0x4(%esp)
  801145:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  80114c:	e8 e5 f0 ff ff       	call   800236 <cprintf>
	*dev = 0;
  801151:	8b 45 0c             	mov    0xc(%ebp),%eax
  801154:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80115a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80115f:	c9                   	leave  
  801160:	c3                   	ret    

00801161 <fd_close>:
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 20             	sub    $0x20,%esp
  801169:	8b 75 08             	mov    0x8(%ebp),%esi
  80116c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80116f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801172:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801176:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80117c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117f:	89 04 24             	mov    %eax,(%esp)
  801182:	e8 2f ff ff ff       	call   8010b6 <fd_lookup>
  801187:	85 c0                	test   %eax,%eax
  801189:	78 05                	js     801190 <fd_close+0x2f>
	    || fd != fd2)
  80118b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80118e:	74 0c                	je     80119c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801190:	84 db                	test   %bl,%bl
  801192:	ba 00 00 00 00       	mov    $0x0,%edx
  801197:	0f 44 c2             	cmove  %edx,%eax
  80119a:	eb 3f                	jmp    8011db <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80119c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a3:	8b 06                	mov    (%esi),%eax
  8011a5:	89 04 24             	mov    %eax,(%esp)
  8011a8:	e8 5f ff ff ff       	call   80110c <dev_lookup>
  8011ad:	89 c3                	mov    %eax,%ebx
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 16                	js     8011c9 <fd_close+0x68>
		if (dev->dev_close)
  8011b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	74 07                	je     8011c9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011c2:	89 34 24             	mov    %esi,(%esp)
  8011c5:	ff d0                	call   *%eax
  8011c7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8011c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d4:	e8 41 fb ff ff       	call   800d1a <sys_page_unmap>
	return r;
  8011d9:	89 d8                	mov    %ebx,%eax
}
  8011db:	83 c4 20             	add    $0x20,%esp
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <close>:

int
close(int fdnum)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	89 04 24             	mov    %eax,(%esp)
  8011f5:	e8 bc fe ff ff       	call   8010b6 <fd_lookup>
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	85 d2                	test   %edx,%edx
  8011fe:	78 13                	js     801213 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801200:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801207:	00 
  801208:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120b:	89 04 24             	mov    %eax,(%esp)
  80120e:	e8 4e ff ff ff       	call   801161 <fd_close>
}
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <close_all>:

void
close_all(void)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	53                   	push   %ebx
  801219:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80121c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801221:	89 1c 24             	mov    %ebx,(%esp)
  801224:	e8 b9 ff ff ff       	call   8011e2 <close>
	for (i = 0; i < MAXFD; i++)
  801229:	83 c3 01             	add    $0x1,%ebx
  80122c:	83 fb 20             	cmp    $0x20,%ebx
  80122f:	75 f0                	jne    801221 <close_all+0xc>
}
  801231:	83 c4 14             	add    $0x14,%esp
  801234:	5b                   	pop    %ebx
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801240:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801243:	89 44 24 04          	mov    %eax,0x4(%esp)
  801247:	8b 45 08             	mov    0x8(%ebp),%eax
  80124a:	89 04 24             	mov    %eax,(%esp)
  80124d:	e8 64 fe ff ff       	call   8010b6 <fd_lookup>
  801252:	89 c2                	mov    %eax,%edx
  801254:	85 d2                	test   %edx,%edx
  801256:	0f 88 e1 00 00 00    	js     80133d <dup+0x106>
		return r;
	close(newfdnum);
  80125c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125f:	89 04 24             	mov    %eax,(%esp)
  801262:	e8 7b ff ff ff       	call   8011e2 <close>

	newfd = INDEX2FD(newfdnum);
  801267:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126a:	c1 e3 0c             	shl    $0xc,%ebx
  80126d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801273:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 d2 fd ff ff       	call   801050 <fd2data>
  80127e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801280:	89 1c 24             	mov    %ebx,(%esp)
  801283:	e8 c8 fd ff ff       	call   801050 <fd2data>
  801288:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80128a:	89 f0                	mov    %esi,%eax
  80128c:	c1 e8 16             	shr    $0x16,%eax
  80128f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801296:	a8 01                	test   $0x1,%al
  801298:	74 43                	je     8012dd <dup+0xa6>
  80129a:	89 f0                	mov    %esi,%eax
  80129c:	c1 e8 0c             	shr    $0xc,%eax
  80129f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012a6:	f6 c2 01             	test   $0x1,%dl
  8012a9:	74 32                	je     8012dd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012c6:	00 
  8012c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d2:	e8 f0 f9 ff ff       	call   800cc7 <sys_page_map>
  8012d7:	89 c6                	mov    %eax,%esi
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 3e                	js     80131b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	c1 ea 0c             	shr    $0xc,%edx
  8012e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012f2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012f6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801301:	00 
  801302:	89 44 24 04          	mov    %eax,0x4(%esp)
  801306:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80130d:	e8 b5 f9 ff ff       	call   800cc7 <sys_page_map>
  801312:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801314:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801317:	85 f6                	test   %esi,%esi
  801319:	79 22                	jns    80133d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80131b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80131f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801326:	e8 ef f9 ff ff       	call   800d1a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80132b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80132f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801336:	e8 df f9 ff ff       	call   800d1a <sys_page_unmap>
	return r;
  80133b:	89 f0                	mov    %esi,%eax
}
  80133d:	83 c4 3c             	add    $0x3c,%esp
  801340:	5b                   	pop    %ebx
  801341:	5e                   	pop    %esi
  801342:	5f                   	pop    %edi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 24             	sub    $0x24,%esp
  80134c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	89 1c 24             	mov    %ebx,(%esp)
  801359:	e8 58 fd ff ff       	call   8010b6 <fd_lookup>
  80135e:	89 c2                	mov    %eax,%edx
  801360:	85 d2                	test   %edx,%edx
  801362:	78 6d                	js     8013d1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	8b 00                	mov    (%eax),%eax
  801370:	89 04 24             	mov    %eax,(%esp)
  801373:	e8 94 fd ff ff       	call   80110c <dev_lookup>
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 55                	js     8013d1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80137c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137f:	8b 50 08             	mov    0x8(%eax),%edx
  801382:	83 e2 03             	and    $0x3,%edx
  801385:	83 fa 01             	cmp    $0x1,%edx
  801388:	75 23                	jne    8013ad <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138a:	a1 08 40 80 00       	mov    0x804008,%eax
  80138f:	8b 40 48             	mov    0x48(%eax),%eax
  801392:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139a:	c7 04 24 ed 26 80 00 	movl   $0x8026ed,(%esp)
  8013a1:	e8 90 ee ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  8013a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ab:	eb 24                	jmp    8013d1 <read+0x8c>
	}
	if (!dev->dev_read)
  8013ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b0:	8b 52 08             	mov    0x8(%edx),%edx
  8013b3:	85 d2                	test   %edx,%edx
  8013b5:	74 15                	je     8013cc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013c5:	89 04 24             	mov    %eax,(%esp)
  8013c8:	ff d2                	call   *%edx
  8013ca:	eb 05                	jmp    8013d1 <read+0x8c>
		return -E_NOT_SUPP;
  8013cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013d1:	83 c4 24             	add    $0x24,%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    

008013d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	57                   	push   %edi
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	83 ec 1c             	sub    $0x1c,%esp
  8013e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013eb:	eb 23                	jmp    801410 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013ed:	89 f0                	mov    %esi,%eax
  8013ef:	29 d8                	sub    %ebx,%eax
  8013f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f5:	89 d8                	mov    %ebx,%eax
  8013f7:	03 45 0c             	add    0xc(%ebp),%eax
  8013fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fe:	89 3c 24             	mov    %edi,(%esp)
  801401:	e8 3f ff ff ff       	call   801345 <read>
		if (m < 0)
  801406:	85 c0                	test   %eax,%eax
  801408:	78 10                	js     80141a <readn+0x43>
			return m;
		if (m == 0)
  80140a:	85 c0                	test   %eax,%eax
  80140c:	74 0a                	je     801418 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80140e:	01 c3                	add    %eax,%ebx
  801410:	39 f3                	cmp    %esi,%ebx
  801412:	72 d9                	jb     8013ed <readn+0x16>
  801414:	89 d8                	mov    %ebx,%eax
  801416:	eb 02                	jmp    80141a <readn+0x43>
  801418:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80141a:	83 c4 1c             	add    $0x1c,%esp
  80141d:	5b                   	pop    %ebx
  80141e:	5e                   	pop    %esi
  80141f:	5f                   	pop    %edi
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	53                   	push   %ebx
  801426:	83 ec 24             	sub    $0x24,%esp
  801429:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801433:	89 1c 24             	mov    %ebx,(%esp)
  801436:	e8 7b fc ff ff       	call   8010b6 <fd_lookup>
  80143b:	89 c2                	mov    %eax,%edx
  80143d:	85 d2                	test   %edx,%edx
  80143f:	78 68                	js     8014a9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801441:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801444:	89 44 24 04          	mov    %eax,0x4(%esp)
  801448:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144b:	8b 00                	mov    (%eax),%eax
  80144d:	89 04 24             	mov    %eax,(%esp)
  801450:	e8 b7 fc ff ff       	call   80110c <dev_lookup>
  801455:	85 c0                	test   %eax,%eax
  801457:	78 50                	js     8014a9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801459:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801460:	75 23                	jne    801485 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801462:	a1 08 40 80 00       	mov    0x804008,%eax
  801467:	8b 40 48             	mov    0x48(%eax),%eax
  80146a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80146e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801472:	c7 04 24 09 27 80 00 	movl   $0x802709,(%esp)
  801479:	e8 b8 ed ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  80147e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801483:	eb 24                	jmp    8014a9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801485:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801488:	8b 52 0c             	mov    0xc(%edx),%edx
  80148b:	85 d2                	test   %edx,%edx
  80148d:	74 15                	je     8014a4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80148f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801492:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801496:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801499:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80149d:	89 04 24             	mov    %eax,(%esp)
  8014a0:	ff d2                	call   *%edx
  8014a2:	eb 05                	jmp    8014a9 <write+0x87>
		return -E_NOT_SUPP;
  8014a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014a9:	83 c4 24             	add    $0x24,%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <seek>:

int
seek(int fdnum, off_t offset)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bf:	89 04 24             	mov    %eax,(%esp)
  8014c2:	e8 ef fb ff ff       	call   8010b6 <fd_lookup>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 0e                	js     8014d9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 24             	sub    $0x24,%esp
  8014e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ec:	89 1c 24             	mov    %ebx,(%esp)
  8014ef:	e8 c2 fb ff ff       	call   8010b6 <fd_lookup>
  8014f4:	89 c2                	mov    %eax,%edx
  8014f6:	85 d2                	test   %edx,%edx
  8014f8:	78 61                	js     80155b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801501:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801504:	8b 00                	mov    (%eax),%eax
  801506:	89 04 24             	mov    %eax,(%esp)
  801509:	e8 fe fb ff ff       	call   80110c <dev_lookup>
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 49                	js     80155b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801512:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801515:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801519:	75 23                	jne    80153e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80151b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801520:	8b 40 48             	mov    0x48(%eax),%eax
  801523:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152b:	c7 04 24 cc 26 80 00 	movl   $0x8026cc,(%esp)
  801532:	e8 ff ec ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  801537:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153c:	eb 1d                	jmp    80155b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80153e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801541:	8b 52 18             	mov    0x18(%edx),%edx
  801544:	85 d2                	test   %edx,%edx
  801546:	74 0e                	je     801556 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801548:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80154f:	89 04 24             	mov    %eax,(%esp)
  801552:	ff d2                	call   *%edx
  801554:	eb 05                	jmp    80155b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801556:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80155b:	83 c4 24             	add    $0x24,%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    

00801561 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	53                   	push   %ebx
  801565:	83 ec 24             	sub    $0x24,%esp
  801568:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801572:	8b 45 08             	mov    0x8(%ebp),%eax
  801575:	89 04 24             	mov    %eax,(%esp)
  801578:	e8 39 fb ff ff       	call   8010b6 <fd_lookup>
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	85 d2                	test   %edx,%edx
  801581:	78 52                	js     8015d5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	8b 00                	mov    (%eax),%eax
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 75 fb ff ff       	call   80110c <dev_lookup>
  801597:	85 c0                	test   %eax,%eax
  801599:	78 3a                	js     8015d5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80159b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a2:	74 2c                	je     8015d0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ae:	00 00 00 
	stat->st_isdir = 0;
  8015b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b8:	00 00 00 
	stat->st_dev = dev;
  8015bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015c8:	89 14 24             	mov    %edx,(%esp)
  8015cb:	ff 50 14             	call   *0x14(%eax)
  8015ce:	eb 05                	jmp    8015d5 <fstat+0x74>
		return -E_NOT_SUPP;
  8015d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015d5:	83 c4 24             	add    $0x24,%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	56                   	push   %esi
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015ea:	00 
  8015eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ee:	89 04 24             	mov    %eax,(%esp)
  8015f1:	e8 fb 01 00 00       	call   8017f1 <open>
  8015f6:	89 c3                	mov    %eax,%ebx
  8015f8:	85 db                	test   %ebx,%ebx
  8015fa:	78 1b                	js     801617 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801603:	89 1c 24             	mov    %ebx,(%esp)
  801606:	e8 56 ff ff ff       	call   801561 <fstat>
  80160b:	89 c6                	mov    %eax,%esi
	close(fd);
  80160d:	89 1c 24             	mov    %ebx,(%esp)
  801610:	e8 cd fb ff ff       	call   8011e2 <close>
	return r;
  801615:	89 f0                	mov    %esi,%eax
}
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	56                   	push   %esi
  801622:	53                   	push   %ebx
  801623:	83 ec 10             	sub    $0x10,%esp
  801626:	89 c6                	mov    %eax,%esi
  801628:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80162a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801631:	75 11                	jne    801644 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80163a:	e8 e0 09 00 00       	call   80201f <ipc_find_env>
  80163f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801644:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80164b:	00 
  80164c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801653:	00 
  801654:	89 74 24 04          	mov    %esi,0x4(%esp)
  801658:	a1 04 40 80 00       	mov    0x804004,%eax
  80165d:	89 04 24             	mov    %eax,(%esp)
  801660:	e8 53 09 00 00       	call   801fb8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801665:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80166c:	00 
  80166d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801671:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801678:	e8 d3 08 00 00       	call   801f50 <ipc_recv>
}
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	5b                   	pop    %ebx
  801681:	5e                   	pop    %esi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	8b 40 0c             	mov    0xc(%eax),%eax
  801690:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801695:	8b 45 0c             	mov    0xc(%ebp),%eax
  801698:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80169d:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a7:	e8 72 ff ff ff       	call   80161e <fsipc>
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <devfile_flush>:
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c9:	e8 50 ff ff ff       	call   80161e <fsipc>
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <devfile_stat>:
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 14             	sub    $0x14,%esp
  8016d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ef:	e8 2a ff ff ff       	call   80161e <fsipc>
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	85 d2                	test   %edx,%edx
  8016f8:	78 2b                	js     801725 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016fa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801701:	00 
  801702:	89 1c 24             	mov    %ebx,(%esp)
  801705:	e8 4d f1 ff ff       	call   800857 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170a:	a1 80 50 80 00       	mov    0x805080,%eax
  80170f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801715:	a1 84 50 80 00       	mov    0x805084,%eax
  80171a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801720:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801725:	83 c4 14             	add    $0x14,%esp
  801728:	5b                   	pop    %ebx
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <devfile_write>:
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801731:	c7 44 24 08 38 27 80 	movl   $0x802738,0x8(%esp)
  801738:	00 
  801739:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801740:	00 
  801741:	c7 04 24 56 27 80 00 	movl   $0x802756,(%esp)
  801748:	e8 a9 07 00 00       	call   801ef6 <_panic>

0080174d <devfile_read>:
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	83 ec 10             	sub    $0x10,%esp
  801755:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	8b 40 0c             	mov    0xc(%eax),%eax
  80175e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801763:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801769:	ba 00 00 00 00       	mov    $0x0,%edx
  80176e:	b8 03 00 00 00       	mov    $0x3,%eax
  801773:	e8 a6 fe ff ff       	call   80161e <fsipc>
  801778:	89 c3                	mov    %eax,%ebx
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 6a                	js     8017e8 <devfile_read+0x9b>
	assert(r <= n);
  80177e:	39 c6                	cmp    %eax,%esi
  801780:	73 24                	jae    8017a6 <devfile_read+0x59>
  801782:	c7 44 24 0c 61 27 80 	movl   $0x802761,0xc(%esp)
  801789:	00 
  80178a:	c7 44 24 08 68 27 80 	movl   $0x802768,0x8(%esp)
  801791:	00 
  801792:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801799:	00 
  80179a:	c7 04 24 56 27 80 00 	movl   $0x802756,(%esp)
  8017a1:	e8 50 07 00 00       	call   801ef6 <_panic>
	assert(r <= PGSIZE);
  8017a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ab:	7e 24                	jle    8017d1 <devfile_read+0x84>
  8017ad:	c7 44 24 0c 7d 27 80 	movl   $0x80277d,0xc(%esp)
  8017b4:	00 
  8017b5:	c7 44 24 08 68 27 80 	movl   $0x802768,0x8(%esp)
  8017bc:	00 
  8017bd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017c4:	00 
  8017c5:	c7 04 24 56 27 80 00 	movl   $0x802756,(%esp)
  8017cc:	e8 25 07 00 00       	call   801ef6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017dc:	00 
  8017dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e0:	89 04 24             	mov    %eax,(%esp)
  8017e3:	e8 0c f2 ff ff       	call   8009f4 <memmove>
}
  8017e8:	89 d8                	mov    %ebx,%eax
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <open>:
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	53                   	push   %ebx
  8017f5:	83 ec 24             	sub    $0x24,%esp
  8017f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017fb:	89 1c 24             	mov    %ebx,(%esp)
  8017fe:	e8 1d f0 ff ff       	call   800820 <strlen>
  801803:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801808:	7f 60                	jg     80186a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80180a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180d:	89 04 24             	mov    %eax,(%esp)
  801810:	e8 52 f8 ff ff       	call   801067 <fd_alloc>
  801815:	89 c2                	mov    %eax,%edx
  801817:	85 d2                	test   %edx,%edx
  801819:	78 54                	js     80186f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80181b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80181f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801826:	e8 2c f0 ff ff       	call   800857 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80182b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801833:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801836:	b8 01 00 00 00       	mov    $0x1,%eax
  80183b:	e8 de fd ff ff       	call   80161e <fsipc>
  801840:	89 c3                	mov    %eax,%ebx
  801842:	85 c0                	test   %eax,%eax
  801844:	79 17                	jns    80185d <open+0x6c>
		fd_close(fd, 0);
  801846:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80184d:	00 
  80184e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801851:	89 04 24             	mov    %eax,(%esp)
  801854:	e8 08 f9 ff ff       	call   801161 <fd_close>
		return r;
  801859:	89 d8                	mov    %ebx,%eax
  80185b:	eb 12                	jmp    80186f <open+0x7e>
	return fd2num(fd);
  80185d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801860:	89 04 24             	mov    %eax,(%esp)
  801863:	e8 d8 f7 ff ff       	call   801040 <fd2num>
  801868:	eb 05                	jmp    80186f <open+0x7e>
		return -E_BAD_PATH;
  80186a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80186f:	83 c4 24             	add    $0x24,%esp
  801872:	5b                   	pop    %ebx
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80187b:	ba 00 00 00 00       	mov    $0x0,%edx
  801880:	b8 08 00 00 00       	mov    $0x8,%eax
  801885:	e8 94 fd ff ff       	call   80161e <fsipc>
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	53                   	push   %ebx
  801890:	83 ec 14             	sub    $0x14,%esp
  801893:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801895:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801899:	7e 31                	jle    8018cc <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80189b:	8b 40 04             	mov    0x4(%eax),%eax
  80189e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a2:	8d 43 10             	lea    0x10(%ebx),%eax
  8018a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a9:	8b 03                	mov    (%ebx),%eax
  8018ab:	89 04 24             	mov    %eax,(%esp)
  8018ae:	e8 6f fb ff ff       	call   801422 <write>
		if (result > 0)
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	7e 03                	jle    8018ba <writebuf+0x2e>
			b->result += result;
  8018b7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018ba:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018bd:	74 0d                	je     8018cc <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c6:	0f 4f c2             	cmovg  %edx,%eax
  8018c9:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018cc:	83 c4 14             	add    $0x14,%esp
  8018cf:	5b                   	pop    %ebx
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <putch>:

static void
putch(int ch, void *thunk)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 04             	sub    $0x4,%esp
  8018d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018dc:	8b 53 04             	mov    0x4(%ebx),%edx
  8018df:	8d 42 01             	lea    0x1(%edx),%eax
  8018e2:	89 43 04             	mov    %eax,0x4(%ebx)
  8018e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e8:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018ec:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018f1:	75 0e                	jne    801901 <putch+0x2f>
		writebuf(b);
  8018f3:	89 d8                	mov    %ebx,%eax
  8018f5:	e8 92 ff ff ff       	call   80188c <writebuf>
		b->idx = 0;
  8018fa:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801901:	83 c4 04             	add    $0x4,%esp
  801904:	5b                   	pop    %ebx
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801910:	8b 45 08             	mov    0x8(%ebp),%eax
  801913:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801919:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801920:	00 00 00 
	b.result = 0;
  801923:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80192a:	00 00 00 
	b.error = 1;
  80192d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801934:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801937:	8b 45 10             	mov    0x10(%ebp),%eax
  80193a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801941:	89 44 24 08          	mov    %eax,0x8(%esp)
  801945:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80194b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194f:	c7 04 24 d2 18 80 00 	movl   $0x8018d2,(%esp)
  801956:	e8 63 ea ff ff       	call   8003be <vprintfmt>
	if (b.idx > 0)
  80195b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801962:	7e 0b                	jle    80196f <vfprintf+0x68>
		writebuf(&b);
  801964:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80196a:	e8 1d ff ff ff       	call   80188c <writebuf>

	return (b.result ? b.result : b.error);
  80196f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801975:	85 c0                	test   %eax,%eax
  801977:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801986:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801989:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801990:	89 44 24 04          	mov    %eax,0x4(%esp)
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	89 04 24             	mov    %eax,(%esp)
  80199a:	e8 68 ff ff ff       	call   801907 <vfprintf>
	va_end(ap);

	return cnt;
}
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <printf>:

int
printf(const char *fmt, ...)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019bc:	e8 46 ff ff ff       	call   801907 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	56                   	push   %esi
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 10             	sub    $0x10,%esp
  8019cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	89 04 24             	mov    %eax,(%esp)
  8019d4:	e8 77 f6 ff ff       	call   801050 <fd2data>
  8019d9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019db:	c7 44 24 04 89 27 80 	movl   $0x802789,0x4(%esp)
  8019e2:	00 
  8019e3:	89 1c 24             	mov    %ebx,(%esp)
  8019e6:	e8 6c ee ff ff       	call   800857 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019eb:	8b 46 04             	mov    0x4(%esi),%eax
  8019ee:	2b 06                	sub    (%esi),%eax
  8019f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fd:	00 00 00 
	stat->st_dev = &devpipe;
  801a00:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a07:	30 80 00 
	return 0;
}
  801a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	5b                   	pop    %ebx
  801a13:	5e                   	pop    %esi
  801a14:	5d                   	pop    %ebp
  801a15:	c3                   	ret    

00801a16 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	53                   	push   %ebx
  801a1a:	83 ec 14             	sub    $0x14,%esp
  801a1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a2b:	e8 ea f2 ff ff       	call   800d1a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a30:	89 1c 24             	mov    %ebx,(%esp)
  801a33:	e8 18 f6 ff ff       	call   801050 <fd2data>
  801a38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a43:	e8 d2 f2 ff ff       	call   800d1a <sys_page_unmap>
}
  801a48:	83 c4 14             	add    $0x14,%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <_pipeisclosed>:
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	57                   	push   %edi
  801a52:	56                   	push   %esi
  801a53:	53                   	push   %ebx
  801a54:	83 ec 2c             	sub    $0x2c,%esp
  801a57:	89 c6                	mov    %eax,%esi
  801a59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801a5c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a61:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a64:	89 34 24             	mov    %esi,(%esp)
  801a67:	e8 eb 05 00 00       	call   802057 <pageref>
  801a6c:	89 c7                	mov    %eax,%edi
  801a6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a71:	89 04 24             	mov    %eax,(%esp)
  801a74:	e8 de 05 00 00       	call   802057 <pageref>
  801a79:	39 c7                	cmp    %eax,%edi
  801a7b:	0f 94 c2             	sete   %dl
  801a7e:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a81:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801a87:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a8a:	39 fb                	cmp    %edi,%ebx
  801a8c:	74 21                	je     801aaf <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801a8e:	84 d2                	test   %dl,%dl
  801a90:	74 ca                	je     801a5c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a92:	8b 51 58             	mov    0x58(%ecx),%edx
  801a95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a99:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aa1:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  801aa8:	e8 89 e7 ff ff       	call   800236 <cprintf>
  801aad:	eb ad                	jmp    801a5c <_pipeisclosed+0xe>
}
  801aaf:	83 c4 2c             	add    $0x2c,%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5f                   	pop    %edi
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <devpipe_write>:
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	57                   	push   %edi
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	83 ec 1c             	sub    $0x1c,%esp
  801ac0:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ac3:	89 34 24             	mov    %esi,(%esp)
  801ac6:	e8 85 f5 ff ff       	call   801050 <fd2data>
  801acb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801acd:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad2:	eb 45                	jmp    801b19 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	89 f0                	mov    %esi,%eax
  801ad8:	e8 71 ff ff ff       	call   801a4e <_pipeisclosed>
  801add:	85 c0                	test   %eax,%eax
  801adf:	75 41                	jne    801b22 <devpipe_write+0x6b>
			sys_yield();
  801ae1:	e8 6e f1 ff ff       	call   800c54 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae9:	8b 0b                	mov    (%ebx),%ecx
  801aeb:	8d 51 20             	lea    0x20(%ecx),%edx
  801aee:	39 d0                	cmp    %edx,%eax
  801af0:	73 e2                	jae    801ad4 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801afc:	99                   	cltd   
  801afd:	c1 ea 1b             	shr    $0x1b,%edx
  801b00:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801b03:	83 e1 1f             	and    $0x1f,%ecx
  801b06:	29 d1                	sub    %edx,%ecx
  801b08:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801b0c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801b10:	83 c0 01             	add    $0x1,%eax
  801b13:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b16:	83 c7 01             	add    $0x1,%edi
  801b19:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b1c:	75 c8                	jne    801ae6 <devpipe_write+0x2f>
	return i;
  801b1e:	89 f8                	mov    %edi,%eax
  801b20:	eb 05                	jmp    801b27 <devpipe_write+0x70>
				return 0;
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b27:	83 c4 1c             	add    $0x1c,%esp
  801b2a:	5b                   	pop    %ebx
  801b2b:	5e                   	pop    %esi
  801b2c:	5f                   	pop    %edi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devpipe_read>:
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	57                   	push   %edi
  801b33:	56                   	push   %esi
  801b34:	53                   	push   %ebx
  801b35:	83 ec 1c             	sub    $0x1c,%esp
  801b38:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b3b:	89 3c 24             	mov    %edi,(%esp)
  801b3e:	e8 0d f5 ff ff       	call   801050 <fd2data>
  801b43:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b45:	be 00 00 00 00       	mov    $0x0,%esi
  801b4a:	eb 3d                	jmp    801b89 <devpipe_read+0x5a>
			if (i > 0)
  801b4c:	85 f6                	test   %esi,%esi
  801b4e:	74 04                	je     801b54 <devpipe_read+0x25>
				return i;
  801b50:	89 f0                	mov    %esi,%eax
  801b52:	eb 43                	jmp    801b97 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801b54:	89 da                	mov    %ebx,%edx
  801b56:	89 f8                	mov    %edi,%eax
  801b58:	e8 f1 fe ff ff       	call   801a4e <_pipeisclosed>
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	75 31                	jne    801b92 <devpipe_read+0x63>
			sys_yield();
  801b61:	e8 ee f0 ff ff       	call   800c54 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b66:	8b 03                	mov    (%ebx),%eax
  801b68:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b6b:	74 df                	je     801b4c <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6d:	99                   	cltd   
  801b6e:	c1 ea 1b             	shr    $0x1b,%edx
  801b71:	01 d0                	add    %edx,%eax
  801b73:	83 e0 1f             	and    $0x1f,%eax
  801b76:	29 d0                	sub    %edx,%eax
  801b78:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b80:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b83:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b86:	83 c6 01             	add    $0x1,%esi
  801b89:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b8c:	75 d8                	jne    801b66 <devpipe_read+0x37>
	return i;
  801b8e:	89 f0                	mov    %esi,%eax
  801b90:	eb 05                	jmp    801b97 <devpipe_read+0x68>
				return 0;
  801b92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b97:	83 c4 1c             	add    $0x1c,%esp
  801b9a:	5b                   	pop    %ebx
  801b9b:	5e                   	pop    %esi
  801b9c:	5f                   	pop    %edi
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <pipe>:
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baa:	89 04 24             	mov    %eax,(%esp)
  801bad:	e8 b5 f4 ff ff       	call   801067 <fd_alloc>
  801bb2:	89 c2                	mov    %eax,%edx
  801bb4:	85 d2                	test   %edx,%edx
  801bb6:	0f 88 4d 01 00 00    	js     801d09 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bc3:	00 
  801bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd2:	e8 9c f0 ff ff       	call   800c73 <sys_page_alloc>
  801bd7:	89 c2                	mov    %eax,%edx
  801bd9:	85 d2                	test   %edx,%edx
  801bdb:	0f 88 28 01 00 00    	js     801d09 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be4:	89 04 24             	mov    %eax,(%esp)
  801be7:	e8 7b f4 ff ff       	call   801067 <fd_alloc>
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	0f 88 fe 00 00 00    	js     801cf4 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bfd:	00 
  801bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0c:	e8 62 f0 ff ff       	call   800c73 <sys_page_alloc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	85 c0                	test   %eax,%eax
  801c15:	0f 88 d9 00 00 00    	js     801cf4 <pipe+0x155>
	va = fd2data(fd0);
  801c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1e:	89 04 24             	mov    %eax,(%esp)
  801c21:	e8 2a f4 ff ff       	call   801050 <fd2data>
  801c26:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c28:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c2f:	00 
  801c30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c3b:	e8 33 f0 ff ff       	call   800c73 <sys_page_alloc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	85 c0                	test   %eax,%eax
  801c44:	0f 88 97 00 00 00    	js     801ce1 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4d:	89 04 24             	mov    %eax,(%esp)
  801c50:	e8 fb f3 ff ff       	call   801050 <fd2data>
  801c55:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c5c:	00 
  801c5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c68:	00 
  801c69:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c74:	e8 4e f0 ff ff       	call   800cc7 <sys_page_map>
  801c79:	89 c3                	mov    %eax,%ebx
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	78 52                	js     801cd1 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801c7f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c88:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cac:	89 04 24             	mov    %eax,(%esp)
  801caf:	e8 8c f3 ff ff       	call   801040 <fd2num>
  801cb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbc:	89 04 24             	mov    %eax,(%esp)
  801cbf:	e8 7c f3 ff ff       	call   801040 <fd2num>
  801cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccf:	eb 38                	jmp    801d09 <pipe+0x16a>
	sys_page_unmap(0, va);
  801cd1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdc:	e8 39 f0 ff ff       	call   800d1a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cef:	e8 26 f0 ff ff       	call   800d1a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d02:	e8 13 f0 ff ff       	call   800d1a <sys_page_unmap>
  801d07:	89 d8                	mov    %ebx,%eax
}
  801d09:	83 c4 30             	add    $0x30,%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    

00801d10 <pipeisclosed>:
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	89 04 24             	mov    %eax,(%esp)
  801d23:	e8 8e f3 ff ff       	call   8010b6 <fd_lookup>
  801d28:	89 c2                	mov    %eax,%edx
  801d2a:	85 d2                	test   %edx,%edx
  801d2c:	78 15                	js     801d43 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d31:	89 04 24             	mov    %eax,(%esp)
  801d34:	e8 17 f3 ff ff       	call   801050 <fd2data>
	return _pipeisclosed(fd, p);
  801d39:	89 c2                	mov    %eax,%edx
  801d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3e:	e8 0b fd ff ff       	call   801a4e <_pipeisclosed>
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    
  801d45:	66 90                	xchg   %ax,%ax
  801d47:	66 90                	xchg   %ax,%ax
  801d49:	66 90                	xchg   %ax,%ax
  801d4b:	66 90                	xchg   %ax,%ax
  801d4d:	66 90                	xchg   %ax,%ax
  801d4f:	90                   	nop

00801d50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d60:	c7 44 24 04 a8 27 80 	movl   $0x8027a8,0x4(%esp)
  801d67:	00 
  801d68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6b:	89 04 24             	mov    %eax,(%esp)
  801d6e:	e8 e4 ea ff ff       	call   800857 <strcpy>
	return 0;
}
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <devcons_write>:
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	57                   	push   %edi
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d86:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d91:	eb 31                	jmp    801dc4 <devcons_write+0x4a>
		m = n - tot;
  801d93:	8b 75 10             	mov    0x10(%ebp),%esi
  801d96:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d98:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801d9b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801da3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801da7:	03 45 0c             	add    0xc(%ebp),%eax
  801daa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dae:	89 3c 24             	mov    %edi,(%esp)
  801db1:	e8 3e ec ff ff       	call   8009f4 <memmove>
		sys_cputs(buf, m);
  801db6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dba:	89 3c 24             	mov    %edi,(%esp)
  801dbd:	e8 e4 ed ff ff       	call   800ba6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801dc2:	01 f3                	add    %esi,%ebx
  801dc4:	89 d8                	mov    %ebx,%eax
  801dc6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dc9:	72 c8                	jb     801d93 <devcons_write+0x19>
}
  801dcb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5f                   	pop    %edi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <devcons_read>:
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801ddc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801de1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de5:	75 07                	jne    801dee <devcons_read+0x18>
  801de7:	eb 2a                	jmp    801e13 <devcons_read+0x3d>
		sys_yield();
  801de9:	e8 66 ee ff ff       	call   800c54 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801dee:	66 90                	xchg   %ax,%ax
  801df0:	e8 cf ed ff ff       	call   800bc4 <sys_cgetc>
  801df5:	85 c0                	test   %eax,%eax
  801df7:	74 f0                	je     801de9 <devcons_read+0x13>
	if (c < 0)
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 16                	js     801e13 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  801dfd:	83 f8 04             	cmp    $0x4,%eax
  801e00:	74 0c                	je     801e0e <devcons_read+0x38>
	*(char*)vbuf = c;
  801e02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e05:	88 02                	mov    %al,(%edx)
	return 1;
  801e07:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0c:	eb 05                	jmp    801e13 <devcons_read+0x3d>
		return 0;
  801e0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <cputchar>:
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e28:	00 
  801e29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2c:	89 04 24             	mov    %eax,(%esp)
  801e2f:	e8 72 ed ff ff       	call   800ba6 <sys_cputs>
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <getchar>:
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801e3c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e43:	00 
  801e44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e52:	e8 ee f4 ff ff       	call   801345 <read>
	if (r < 0)
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 0f                	js     801e6a <getchar+0x34>
	if (r < 1)
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	7e 06                	jle    801e65 <getchar+0x2f>
	return c;
  801e5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e63:	eb 05                	jmp    801e6a <getchar+0x34>
		return -E_EOF;
  801e65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <iscons>:
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e79:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 32 f2 ff ff       	call   8010b6 <fd_lookup>
  801e84:	85 c0                	test   %eax,%eax
  801e86:	78 11                	js     801e99 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e91:	39 10                	cmp    %edx,(%eax)
  801e93:	0f 94 c0             	sete   %al
  801e96:	0f b6 c0             	movzbl %al,%eax
}
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <opencons>:
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ea1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea4:	89 04 24             	mov    %eax,(%esp)
  801ea7:	e8 bb f1 ff ff       	call   801067 <fd_alloc>
		return r;
  801eac:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 40                	js     801ef2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb9:	00 
  801eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec8:	e8 a6 ed ff ff       	call   800c73 <sys_page_alloc>
		return r;
  801ecd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 1f                	js     801ef2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801ed3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee8:	89 04 24             	mov    %eax,(%esp)
  801eeb:	e8 50 f1 ff ff       	call   801040 <fd2num>
  801ef0:	89 c2                	mov    %eax,%edx
}
  801ef2:	89 d0                	mov    %edx,%eax
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	56                   	push   %esi
  801efa:	53                   	push   %ebx
  801efb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801efe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f01:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f07:	e8 29 ed ff ff       	call   800c35 <sys_getenvid>
  801f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f13:	8b 55 08             	mov    0x8(%ebp),%edx
  801f16:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f1a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f22:	c7 04 24 b4 27 80 00 	movl   $0x8027b4,(%esp)
  801f29:	e8 08 e3 ff ff       	call   800236 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f32:	8b 45 10             	mov    0x10(%ebp),%eax
  801f35:	89 04 24             	mov    %eax,(%esp)
  801f38:	e8 98 e2 ff ff       	call   8001d5 <vcprintf>
	cprintf("\n");
  801f3d:	c7 04 24 50 23 80 00 	movl   $0x802350,(%esp)
  801f44:	e8 ed e2 ff ff       	call   800236 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f49:	cc                   	int3   
  801f4a:	eb fd                	jmp    801f49 <_panic+0x53>
  801f4c:	66 90                	xchg   %ax,%ax
  801f4e:	66 90                	xchg   %ax,%ax

00801f50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	56                   	push   %esi
  801f54:	53                   	push   %ebx
  801f55:	83 ec 10             	sub    $0x10,%esp
  801f58:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801f61:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801f63:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f68:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801f6b:	89 04 24             	mov    %eax,(%esp)
  801f6e:	e8 16 ef ff ff       	call   800e89 <sys_ipc_recv>
    if(r < 0){
  801f73:	85 c0                	test   %eax,%eax
  801f75:	79 16                	jns    801f8d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801f77:	85 f6                	test   %esi,%esi
  801f79:	74 06                	je     801f81 <ipc_recv+0x31>
            *from_env_store = 0;
  801f7b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801f81:	85 db                	test   %ebx,%ebx
  801f83:	74 2c                	je     801fb1 <ipc_recv+0x61>
            *perm_store = 0;
  801f85:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f8b:	eb 24                	jmp    801fb1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801f8d:	85 f6                	test   %esi,%esi
  801f8f:	74 0a                	je     801f9b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801f91:	a1 08 40 80 00       	mov    0x804008,%eax
  801f96:	8b 40 74             	mov    0x74(%eax),%eax
  801f99:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801f9b:	85 db                	test   %ebx,%ebx
  801f9d:	74 0a                	je     801fa9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801f9f:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa4:	8b 40 78             	mov    0x78(%eax),%eax
  801fa7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fa9:	a1 08 40 80 00       	mov    0x804008,%eax
  801fae:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	5b                   	pop    %ebx
  801fb5:	5e                   	pop    %esi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	57                   	push   %edi
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
  801fbe:	83 ec 1c             	sub    $0x1c,%esp
  801fc1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801fca:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801fcc:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801fd1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801fd4:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fdb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe3:	89 3c 24             	mov    %edi,(%esp)
  801fe6:	e8 7b ee ff ff       	call   800e66 <sys_ipc_try_send>
        if(r == 0){
  801feb:	85 c0                	test   %eax,%eax
  801fed:	74 28                	je     802017 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801fef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff2:	74 1c                	je     802010 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801ff4:	c7 44 24 08 d8 27 80 	movl   $0x8027d8,0x8(%esp)
  801ffb:	00 
  801ffc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802003:	00 
  802004:	c7 04 24 ef 27 80 00 	movl   $0x8027ef,(%esp)
  80200b:	e8 e6 fe ff ff       	call   801ef6 <_panic>
        }
        sys_yield();
  802010:	e8 3f ec ff ff       	call   800c54 <sys_yield>
    }
  802015:	eb bd                	jmp    801fd4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802017:	83 c4 1c             	add    $0x1c,%esp
  80201a:	5b                   	pop    %ebx
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80202a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80202d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802033:	8b 52 50             	mov    0x50(%edx),%edx
  802036:	39 ca                	cmp    %ecx,%edx
  802038:	75 0d                	jne    802047 <ipc_find_env+0x28>
			return envs[i].env_id;
  80203a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80203d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802042:	8b 40 40             	mov    0x40(%eax),%eax
  802045:	eb 0e                	jmp    802055 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802047:	83 c0 01             	add    $0x1,%eax
  80204a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80204f:	75 d9                	jne    80202a <ipc_find_env+0xb>
	return 0;
  802051:	66 b8 00 00          	mov    $0x0,%ax
}
  802055:	5d                   	pop    %ebp
  802056:	c3                   	ret    

00802057 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205d:	89 d0                	mov    %edx,%eax
  80205f:	c1 e8 16             	shr    $0x16,%eax
  802062:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80206e:	f6 c1 01             	test   $0x1,%cl
  802071:	74 1d                	je     802090 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802073:	c1 ea 0c             	shr    $0xc,%edx
  802076:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80207d:	f6 c2 01             	test   $0x1,%dl
  802080:	74 0e                	je     802090 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802082:	c1 ea 0c             	shr    $0xc,%edx
  802085:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80208c:	ef 
  80208d:	0f b7 c0             	movzwl %ax,%eax
}
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8020aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8020ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8020b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020bc:	89 ea                	mov    %ebp,%edx
  8020be:	89 0c 24             	mov    %ecx,(%esp)
  8020c1:	75 2d                	jne    8020f0 <__udivdi3+0x50>
  8020c3:	39 e9                	cmp    %ebp,%ecx
  8020c5:	77 61                	ja     802128 <__udivdi3+0x88>
  8020c7:	85 c9                	test   %ecx,%ecx
  8020c9:	89 ce                	mov    %ecx,%esi
  8020cb:	75 0b                	jne    8020d8 <__udivdi3+0x38>
  8020cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d2:	31 d2                	xor    %edx,%edx
  8020d4:	f7 f1                	div    %ecx
  8020d6:	89 c6                	mov    %eax,%esi
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	89 e8                	mov    %ebp,%eax
  8020dc:	f7 f6                	div    %esi
  8020de:	89 c5                	mov    %eax,%ebp
  8020e0:	89 f8                	mov    %edi,%eax
  8020e2:	f7 f6                	div    %esi
  8020e4:	89 ea                	mov    %ebp,%edx
  8020e6:	83 c4 0c             	add    $0xc,%esp
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
  8020f0:	39 e8                	cmp    %ebp,%eax
  8020f2:	77 24                	ja     802118 <__udivdi3+0x78>
  8020f4:	0f bd e8             	bsr    %eax,%ebp
  8020f7:	83 f5 1f             	xor    $0x1f,%ebp
  8020fa:	75 3c                	jne    802138 <__udivdi3+0x98>
  8020fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  802100:	39 34 24             	cmp    %esi,(%esp)
  802103:	0f 86 9f 00 00 00    	jbe    8021a8 <__udivdi3+0x108>
  802109:	39 d0                	cmp    %edx,%eax
  80210b:	0f 82 97 00 00 00    	jb     8021a8 <__udivdi3+0x108>
  802111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802118:	31 d2                	xor    %edx,%edx
  80211a:	31 c0                	xor    %eax,%eax
  80211c:	83 c4 0c             	add    $0xc,%esp
  80211f:	5e                   	pop    %esi
  802120:	5f                   	pop    %edi
  802121:	5d                   	pop    %ebp
  802122:	c3                   	ret    
  802123:	90                   	nop
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	89 f8                	mov    %edi,%eax
  80212a:	f7 f1                	div    %ecx
  80212c:	31 d2                	xor    %edx,%edx
  80212e:	83 c4 0c             	add    $0xc,%esp
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	89 e9                	mov    %ebp,%ecx
  80213a:	8b 3c 24             	mov    (%esp),%edi
  80213d:	d3 e0                	shl    %cl,%eax
  80213f:	89 c6                	mov    %eax,%esi
  802141:	b8 20 00 00 00       	mov    $0x20,%eax
  802146:	29 e8                	sub    %ebp,%eax
  802148:	89 c1                	mov    %eax,%ecx
  80214a:	d3 ef                	shr    %cl,%edi
  80214c:	89 e9                	mov    %ebp,%ecx
  80214e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802152:	8b 3c 24             	mov    (%esp),%edi
  802155:	09 74 24 08          	or     %esi,0x8(%esp)
  802159:	89 d6                	mov    %edx,%esi
  80215b:	d3 e7                	shl    %cl,%edi
  80215d:	89 c1                	mov    %eax,%ecx
  80215f:	89 3c 24             	mov    %edi,(%esp)
  802162:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802166:	d3 ee                	shr    %cl,%esi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	d3 e2                	shl    %cl,%edx
  80216c:	89 c1                	mov    %eax,%ecx
  80216e:	d3 ef                	shr    %cl,%edi
  802170:	09 d7                	or     %edx,%edi
  802172:	89 f2                	mov    %esi,%edx
  802174:	89 f8                	mov    %edi,%eax
  802176:	f7 74 24 08          	divl   0x8(%esp)
  80217a:	89 d6                	mov    %edx,%esi
  80217c:	89 c7                	mov    %eax,%edi
  80217e:	f7 24 24             	mull   (%esp)
  802181:	39 d6                	cmp    %edx,%esi
  802183:	89 14 24             	mov    %edx,(%esp)
  802186:	72 30                	jb     8021b8 <__udivdi3+0x118>
  802188:	8b 54 24 04          	mov    0x4(%esp),%edx
  80218c:	89 e9                	mov    %ebp,%ecx
  80218e:	d3 e2                	shl    %cl,%edx
  802190:	39 c2                	cmp    %eax,%edx
  802192:	73 05                	jae    802199 <__udivdi3+0xf9>
  802194:	3b 34 24             	cmp    (%esp),%esi
  802197:	74 1f                	je     8021b8 <__udivdi3+0x118>
  802199:	89 f8                	mov    %edi,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	e9 7a ff ff ff       	jmp    80211c <__udivdi3+0x7c>
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8021af:	e9 68 ff ff ff       	jmp    80211c <__udivdi3+0x7c>
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	83 c4 0c             	add    $0xc,%esp
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	83 ec 14             	sub    $0x14,%esp
  8021d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8021da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8021de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8021e2:	89 c7                	mov    %eax,%edi
  8021e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8021ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8021f0:	89 34 24             	mov    %esi,(%esp)
  8021f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	89 c2                	mov    %eax,%edx
  8021fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021ff:	75 17                	jne    802218 <__umoddi3+0x48>
  802201:	39 fe                	cmp    %edi,%esi
  802203:	76 4b                	jbe    802250 <__umoddi3+0x80>
  802205:	89 c8                	mov    %ecx,%eax
  802207:	89 fa                	mov    %edi,%edx
  802209:	f7 f6                	div    %esi
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	31 d2                	xor    %edx,%edx
  80220f:	83 c4 14             	add    $0x14,%esp
  802212:	5e                   	pop    %esi
  802213:	5f                   	pop    %edi
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    
  802216:	66 90                	xchg   %ax,%ax
  802218:	39 f8                	cmp    %edi,%eax
  80221a:	77 54                	ja     802270 <__umoddi3+0xa0>
  80221c:	0f bd e8             	bsr    %eax,%ebp
  80221f:	83 f5 1f             	xor    $0x1f,%ebp
  802222:	75 5c                	jne    802280 <__umoddi3+0xb0>
  802224:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802228:	39 3c 24             	cmp    %edi,(%esp)
  80222b:	0f 87 e7 00 00 00    	ja     802318 <__umoddi3+0x148>
  802231:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802235:	29 f1                	sub    %esi,%ecx
  802237:	19 c7                	sbb    %eax,%edi
  802239:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802241:	8b 44 24 08          	mov    0x8(%esp),%eax
  802245:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802249:	83 c4 14             	add    $0x14,%esp
  80224c:	5e                   	pop    %esi
  80224d:	5f                   	pop    %edi
  80224e:	5d                   	pop    %ebp
  80224f:	c3                   	ret    
  802250:	85 f6                	test   %esi,%esi
  802252:	89 f5                	mov    %esi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f6                	div    %esi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	8b 44 24 04          	mov    0x4(%esp),%eax
  802265:	31 d2                	xor    %edx,%edx
  802267:	f7 f5                	div    %ebp
  802269:	89 c8                	mov    %ecx,%eax
  80226b:	f7 f5                	div    %ebp
  80226d:	eb 9c                	jmp    80220b <__umoddi3+0x3b>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 fa                	mov    %edi,%edx
  802274:	83 c4 14             	add    $0x14,%esp
  802277:	5e                   	pop    %esi
  802278:	5f                   	pop    %edi
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    
  80227b:	90                   	nop
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 04 24             	mov    (%esp),%eax
  802283:	be 20 00 00 00       	mov    $0x20,%esi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ee                	sub    %ebp,%esi
  80228c:	d3 e2                	shl    %cl,%edx
  80228e:	89 f1                	mov    %esi,%ecx
  802290:	d3 e8                	shr    %cl,%eax
  802292:	89 e9                	mov    %ebp,%ecx
  802294:	89 44 24 04          	mov    %eax,0x4(%esp)
  802298:	8b 04 24             	mov    (%esp),%eax
  80229b:	09 54 24 04          	or     %edx,0x4(%esp)
  80229f:	89 fa                	mov    %edi,%edx
  8022a1:	d3 e0                	shl    %cl,%eax
  8022a3:	89 f1                	mov    %esi,%ecx
  8022a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022ad:	d3 ea                	shr    %cl,%edx
  8022af:	89 e9                	mov    %ebp,%ecx
  8022b1:	d3 e7                	shl    %cl,%edi
  8022b3:	89 f1                	mov    %esi,%ecx
  8022b5:	d3 e8                	shr    %cl,%eax
  8022b7:	89 e9                	mov    %ebp,%ecx
  8022b9:	09 f8                	or     %edi,%eax
  8022bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8022bf:	f7 74 24 04          	divl   0x4(%esp)
  8022c3:	d3 e7                	shl    %cl,%edi
  8022c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022c9:	89 d7                	mov    %edx,%edi
  8022cb:	f7 64 24 08          	mull   0x8(%esp)
  8022cf:	39 d7                	cmp    %edx,%edi
  8022d1:	89 c1                	mov    %eax,%ecx
  8022d3:	89 14 24             	mov    %edx,(%esp)
  8022d6:	72 2c                	jb     802304 <__umoddi3+0x134>
  8022d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8022dc:	72 22                	jb     802300 <__umoddi3+0x130>
  8022de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022e2:	29 c8                	sub    %ecx,%eax
  8022e4:	19 d7                	sbb    %edx,%edi
  8022e6:	89 e9                	mov    %ebp,%ecx
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	d3 e8                	shr    %cl,%eax
  8022ec:	89 f1                	mov    %esi,%ecx
  8022ee:	d3 e2                	shl    %cl,%edx
  8022f0:	89 e9                	mov    %ebp,%ecx
  8022f2:	d3 ef                	shr    %cl,%edi
  8022f4:	09 d0                	or     %edx,%eax
  8022f6:	89 fa                	mov    %edi,%edx
  8022f8:	83 c4 14             	add    $0x14,%esp
  8022fb:	5e                   	pop    %esi
  8022fc:	5f                   	pop    %edi
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    
  8022ff:	90                   	nop
  802300:	39 d7                	cmp    %edx,%edi
  802302:	75 da                	jne    8022de <__umoddi3+0x10e>
  802304:	8b 14 24             	mov    (%esp),%edx
  802307:	89 c1                	mov    %eax,%ecx
  802309:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80230d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802311:	eb cb                	jmp    8022de <__umoddi3+0x10e>
  802313:	90                   	nop
  802314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802318:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80231c:	0f 82 0f ff ff ff    	jb     802231 <__umoddi3+0x61>
  802322:	e9 1a ff ff ff       	jmp    802241 <__umoddi3+0x71>
