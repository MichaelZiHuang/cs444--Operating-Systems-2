
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 74 10 00 00       	call   8010b2 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 bd 00 00 00    	jne    800106 <umain+0xd3>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800050:	00 
  800051:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800058:	00 
  800059:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005c:	89 04 24             	mov    %eax,(%esp)
  80005f:	e8 4c 12 00 00       	call   8012b0 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800064:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006b:	00 
  80006c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800073:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  80007a:	e8 65 02 00 00       	call   8002e4 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80007f:	a1 04 30 80 00       	mov    0x803004,%eax
  800084:	89 04 24             	mov    %eax,(%esp)
  800087:	e8 44 08 00 00       	call   8008d0 <strlen>
  80008c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800090:	a1 04 30 80 00       	mov    0x803004,%eax
  800095:	89 44 24 04          	mov    %eax,0x4(%esp)
  800099:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a0:	e8 3d 09 00 00       	call   8009e2 <strncmp>
  8000a5:	85 c0                	test   %eax,%eax
  8000a7:	75 0c                	jne    8000b5 <umain+0x82>
			cprintf("child received correct message\n");
  8000a9:	c7 04 24 34 25 80 00 	movl   $0x802534,(%esp)
  8000b0:	e8 2f 02 00 00       	call   8002e4 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b5:	a1 00 30 80 00       	mov    0x803000,%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 0e 08 00 00       	call   8008d0 <strlen>
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c9:	a1 00 30 80 00       	mov    0x803000,%eax
  8000ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d2:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d9:	e8 2e 0a 00 00       	call   800b0c <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000de:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ed:	00 
  8000ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f5:	00 
  8000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f9:	89 04 24             	mov    %eax,(%esp)
  8000fc:	e8 17 12 00 00       	call   801318 <ipc_send>
		return;
  800101:	e9 d8 00 00 00       	jmp    8001de <umain+0x1ab>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800106:	a1 08 40 80 00       	mov    0x804008,%eax
  80010b:	8b 40 48             	mov    0x48(%eax),%eax
  80010e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800115:	00 
  800116:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011d:	00 
  80011e:	89 04 24             	mov    %eax,(%esp)
  800121:	e8 fd 0b 00 00       	call   800d23 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800126:	a1 04 30 80 00       	mov    0x803004,%eax
  80012b:	89 04 24             	mov    %eax,(%esp)
  80012e:	e8 9d 07 00 00       	call   8008d0 <strlen>
  800133:	83 c0 01             	add    $0x1,%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	a1 04 30 80 00       	mov    0x803004,%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  80014a:	e8 bd 09 00 00       	call   800b0c <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800156:	00 
  800157:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015e:	00 
  80015f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800166:	00 
  800167:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80016a:	89 04 24             	mov    %eax,(%esp)
  80016d:	e8 a6 11 00 00       	call   801318 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800172:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800179:	00 
  80017a:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800181:	00 
  800182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 23 11 00 00       	call   8012b0 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018d:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800194:	00 
  800195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  8001a3:	e8 3c 01 00 00       	call   8002e4 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a8:	a1 00 30 80 00       	mov    0x803000,%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 1b 07 00 00       	call   8008d0 <strlen>
  8001b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b9:	a1 00 30 80 00       	mov    0x803000,%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c9:	e8 14 08 00 00       	call   8009e2 <strncmp>
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	75 0c                	jne    8001de <umain+0x1ab>
		cprintf("parent received correct message\n");
  8001d2:	c7 04 24 54 25 80 00 	movl   $0x802554,(%esp)
  8001d9:	e8 06 01 00 00       	call   8002e4 <cprintf>
	return;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8001ee:	e8 f2 0a 00 00       	call   800ce5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800200:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800205:	85 db                	test   %ebx,%ebx
  800207:	7e 07                	jle    800210 <libmain+0x30>
		binaryname = argv[0];
  800209:	8b 06                	mov    (%esi),%eax
  80020b:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	89 1c 24             	mov    %ebx,(%esp)
  800217:	e8 17 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021c:	e8 07 00 00 00       	call   800228 <exit>
}
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80022e:	e8 62 13 00 00       	call   801595 <close_all>
	sys_env_destroy(0);
  800233:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80023a:	e8 54 0a 00 00       	call   800c93 <sys_env_destroy>
}
  80023f:	c9                   	leave  
  800240:	c3                   	ret    

00800241 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	53                   	push   %ebx
  800245:	83 ec 14             	sub    $0x14,%esp
  800248:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024b:	8b 13                	mov    (%ebx),%edx
  80024d:	8d 42 01             	lea    0x1(%edx),%eax
  800250:	89 03                	mov    %eax,(%ebx)
  800252:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800255:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800259:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025e:	75 19                	jne    800279 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800260:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800267:	00 
  800268:	8d 43 08             	lea    0x8(%ebx),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 e3 09 00 00       	call   800c56 <sys_cputs>
		b->idx = 0;
  800273:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800279:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027d:	83 c4 14             	add    $0x14,%esp
  800280:	5b                   	pop    %ebx
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80028c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800293:	00 00 00 
	b.cnt = 0;
  800296:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	c7 04 24 41 02 80 00 	movl   $0x800241,(%esp)
  8002bf:	e8 aa 01 00 00       	call   80046e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 7a 09 00 00       	call   800c56 <sys_cputs>

	return b.cnt;
}
  8002dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	e8 87 ff ff ff       	call   800283 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    
  8002fe:	66 90                	xchg   %ax,%ax

00800300 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 3c             	sub    $0x3c,%esp
  800309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030c:	89 d7                	mov    %edx,%edi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
  800317:	89 c3                	mov    %eax,%ebx
  800319:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80032d:	39 d9                	cmp    %ebx,%ecx
  80032f:	72 05                	jb     800336 <printnum+0x36>
  800331:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800334:	77 69                	ja     80039f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800336:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800339:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80033d:	83 ee 01             	sub    $0x1,%esi
  800340:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 44 24 08          	mov    0x8(%esp),%eax
  80034c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800350:	89 c3                	mov    %eax,%ebx
  800352:	89 d6                	mov    %edx,%esi
  800354:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800357:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80035a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80035e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036f:	e8 0c 1f 00 00       	call   802280 <__udivdi3>
  800374:	89 d9                	mov    %ebx,%ecx
  800376:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80037a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	89 54 24 04          	mov    %edx,0x4(%esp)
  800385:	89 fa                	mov    %edi,%edx
  800387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038a:	e8 71 ff ff ff       	call   800300 <printnum>
  80038f:	eb 1b                	jmp    8003ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800395:	8b 45 18             	mov    0x18(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff d3                	call   *%ebx
  80039d:	eb 03                	jmp    8003a2 <printnum+0xa2>
  80039f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8003a2:	83 ee 01             	sub    $0x1,%esi
  8003a5:	85 f6                	test   %esi,%esi
  8003a7:	7f e8                	jg     800391 <printnum+0x91>
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	e8 dc 1f 00 00       	call   8023b0 <__umoddi3>
  8003d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d8:	0f be 80 cc 25 80 00 	movsbl 0x8025cc(%eax),%eax
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003e5:	ff d0                	call   *%eax
}
  8003e7:	83 c4 3c             	add    $0x3c,%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f2:	83 fa 01             	cmp    $0x1,%edx
  8003f5:	7e 0e                	jle    800405 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003f7:	8b 10                	mov    (%eax),%edx
  8003f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003fc:	89 08                	mov    %ecx,(%eax)
  8003fe:	8b 02                	mov    (%edx),%eax
  800400:	8b 52 04             	mov    0x4(%edx),%edx
  800403:	eb 22                	jmp    800427 <getuint+0x38>
	else if (lflag)
  800405:	85 d2                	test   %edx,%edx
  800407:	74 10                	je     800419 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800409:	8b 10                	mov    (%eax),%edx
  80040b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040e:	89 08                	mov    %ecx,(%eax)
  800410:	8b 02                	mov    (%edx),%eax
  800412:	ba 00 00 00 00       	mov    $0x0,%edx
  800417:	eb 0e                	jmp    800427 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041e:	89 08                	mov    %ecx,(%eax)
  800420:	8b 02                	mov    (%edx),%eax
  800422:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80042f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800433:	8b 10                	mov    (%eax),%edx
  800435:	3b 50 04             	cmp    0x4(%eax),%edx
  800438:	73 0a                	jae    800444 <sprintputch+0x1b>
		*b->buf++ = ch;
  80043a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80043d:	89 08                	mov    %ecx,(%eax)
  80043f:	8b 45 08             	mov    0x8(%ebp),%eax
  800442:	88 02                	mov    %al,(%edx)
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <printfmt>:
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80044c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80044f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800453:	8b 45 10             	mov    0x10(%ebp),%eax
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800461:	8b 45 08             	mov    0x8(%ebp),%eax
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	e8 02 00 00 00       	call   80046e <vprintfmt>
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <vprintfmt>:
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	57                   	push   %edi
  800472:	56                   	push   %esi
  800473:	53                   	push   %ebx
  800474:	83 ec 3c             	sub    $0x3c,%esp
  800477:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80047a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80047d:	eb 1f                	jmp    80049e <vprintfmt+0x30>
			if (ch == '\0'){
  80047f:	85 c0                	test   %eax,%eax
  800481:	75 0f                	jne    800492 <vprintfmt+0x24>
				color = 0x0100;
  800483:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80048a:	01 00 00 
  80048d:	e9 b3 03 00 00       	jmp    800845 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800496:	89 04 24             	mov    %eax,(%esp)
  800499:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80049c:	89 f3                	mov    %esi,%ebx
  80049e:	8d 73 01             	lea    0x1(%ebx),%esi
  8004a1:	0f b6 03             	movzbl (%ebx),%eax
  8004a4:	83 f8 25             	cmp    $0x25,%eax
  8004a7:	75 d6                	jne    80047f <vprintfmt+0x11>
  8004a9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004b4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004bb:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c7:	eb 1d                	jmp    8004e6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	89 de                	mov    %ebx,%esi
			padc = '-';
  8004cb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004cf:	eb 15                	jmp    8004e6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	89 de                	mov    %ebx,%esi
			padc = '0';
  8004d3:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004d7:	eb 0d                	jmp    8004e6 <vprintfmt+0x78>
				width = precision, precision = -1;
  8004d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004df:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004e9:	0f b6 0e             	movzbl (%esi),%ecx
  8004ec:	0f b6 c1             	movzbl %cl,%eax
  8004ef:	83 e9 23             	sub    $0x23,%ecx
  8004f2:	80 f9 55             	cmp    $0x55,%cl
  8004f5:	0f 87 2a 03 00 00    	ja     800825 <vprintfmt+0x3b7>
  8004fb:	0f b6 c9             	movzbl %cl,%ecx
  8004fe:	ff 24 8d 00 27 80 00 	jmp    *0x802700(,%ecx,4)
  800505:	89 de                	mov    %ebx,%esi
  800507:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80050c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80050f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800513:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800516:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800519:	83 fb 09             	cmp    $0x9,%ebx
  80051c:	77 36                	ja     800554 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80051e:	83 c6 01             	add    $0x1,%esi
			}
  800521:	eb e9                	jmp    80050c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 48 04             	lea    0x4(%eax),%ecx
  800529:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800531:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800533:	eb 22                	jmp    800557 <vprintfmt+0xe9>
  800535:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800538:	85 c9                	test   %ecx,%ecx
  80053a:	b8 00 00 00 00       	mov    $0x0,%eax
  80053f:	0f 49 c1             	cmovns %ecx,%eax
  800542:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800545:	89 de                	mov    %ebx,%esi
  800547:	eb 9d                	jmp    8004e6 <vprintfmt+0x78>
  800549:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80054b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800552:	eb 92                	jmp    8004e6 <vprintfmt+0x78>
  800554:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800557:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055b:	79 89                	jns    8004e6 <vprintfmt+0x78>
  80055d:	e9 77 ff ff ff       	jmp    8004d9 <vprintfmt+0x6b>
			lflag++;
  800562:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800565:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800567:	e9 7a ff ff ff       	jmp    8004e6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 04             	lea    0x4(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 04 24             	mov    %eax,(%esp)
  80057e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800581:	e9 18 ff ff ff       	jmp    80049e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	99                   	cltd   
  800592:	31 d0                	xor    %edx,%eax
  800594:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800596:	83 f8 0f             	cmp    $0xf,%eax
  800599:	7f 0b                	jg     8005a6 <vprintfmt+0x138>
  80059b:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	75 20                	jne    8005c6 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  8005a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005aa:	c7 44 24 08 e4 25 80 	movl   $0x8025e4,0x8(%esp)
  8005b1:	00 
  8005b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 85 fe ff ff       	call   800446 <printfmt>
  8005c1:	e9 d8 fe ff ff       	jmp    80049e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  8005c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ca:	c7 44 24 08 3a 2b 80 	movl   $0x802b3a,0x8(%esp)
  8005d1:	00 
  8005d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d9:	89 04 24             	mov    %eax,(%esp)
  8005dc:	e8 65 fe ff ff       	call   800446 <printfmt>
  8005e1:	e9 b8 fe ff ff       	jmp    80049e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005fa:	85 f6                	test   %esi,%esi
  8005fc:	b8 dd 25 80 00       	mov    $0x8025dd,%eax
  800601:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800604:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800608:	0f 84 97 00 00 00    	je     8006a5 <vprintfmt+0x237>
  80060e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800612:	0f 8e 9b 00 00 00    	jle    8006b3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800618:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80061c:	89 34 24             	mov    %esi,(%esp)
  80061f:	e8 c4 02 00 00       	call   8008e8 <strnlen>
  800624:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800627:	29 c2                	sub    %eax,%edx
  800629:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80062c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800630:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800633:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800636:	8b 75 08             	mov    0x8(%ebp),%esi
  800639:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80063c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80063e:	eb 0f                	jmp    80064f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800640:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800644:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80064c:	83 eb 01             	sub    $0x1,%ebx
  80064f:	85 db                	test   %ebx,%ebx
  800651:	7f ed                	jg     800640 <vprintfmt+0x1d2>
  800653:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800656:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800659:	85 d2                	test   %edx,%edx
  80065b:	b8 00 00 00 00       	mov    $0x0,%eax
  800660:	0f 49 c2             	cmovns %edx,%eax
  800663:	29 c2                	sub    %eax,%edx
  800665:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800668:	89 d7                	mov    %edx,%edi
  80066a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80066d:	eb 50                	jmp    8006bf <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80066f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800673:	74 1e                	je     800693 <vprintfmt+0x225>
  800675:	0f be d2             	movsbl %dl,%edx
  800678:	83 ea 20             	sub    $0x20,%edx
  80067b:	83 fa 5e             	cmp    $0x5e,%edx
  80067e:	76 13                	jbe    800693 <vprintfmt+0x225>
					putch('?', putdat);
  800680:	8b 45 0c             	mov    0xc(%ebp),%eax
  800683:	89 44 24 04          	mov    %eax,0x4(%esp)
  800687:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80068e:	ff 55 08             	call   *0x8(%ebp)
  800691:	eb 0d                	jmp    8006a0 <vprintfmt+0x232>
					putch(ch, putdat);
  800693:	8b 55 0c             	mov    0xc(%ebp),%edx
  800696:	89 54 24 04          	mov    %edx,0x4(%esp)
  80069a:	89 04 24             	mov    %eax,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a0:	83 ef 01             	sub    $0x1,%edi
  8006a3:	eb 1a                	jmp    8006bf <vprintfmt+0x251>
  8006a5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006a8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006ab:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006ae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006b1:	eb 0c                	jmp    8006bf <vprintfmt+0x251>
  8006b3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006b6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006b9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006bc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006bf:	83 c6 01             	add    $0x1,%esi
  8006c2:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006c6:	0f be c2             	movsbl %dl,%eax
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	74 27                	je     8006f4 <vprintfmt+0x286>
  8006cd:	85 db                	test   %ebx,%ebx
  8006cf:	78 9e                	js     80066f <vprintfmt+0x201>
  8006d1:	83 eb 01             	sub    $0x1,%ebx
  8006d4:	79 99                	jns    80066f <vprintfmt+0x201>
  8006d6:	89 f8                	mov    %edi,%eax
  8006d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006db:	8b 75 08             	mov    0x8(%ebp),%esi
  8006de:	89 c3                	mov    %eax,%ebx
  8006e0:	eb 1a                	jmp    8006fc <vprintfmt+0x28e>
				putch(' ', putdat);
  8006e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ed:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006ef:	83 eb 01             	sub    $0x1,%ebx
  8006f2:	eb 08                	jmp    8006fc <vprintfmt+0x28e>
  8006f4:	89 fb                	mov    %edi,%ebx
  8006f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006fc:	85 db                	test   %ebx,%ebx
  8006fe:	7f e2                	jg     8006e2 <vprintfmt+0x274>
  800700:	89 75 08             	mov    %esi,0x8(%ebp)
  800703:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800706:	e9 93 fd ff ff       	jmp    80049e <vprintfmt+0x30>
	if (lflag >= 2)
  80070b:	83 fa 01             	cmp    $0x1,%edx
  80070e:	7e 16                	jle    800726 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8d 50 08             	lea    0x8(%eax),%edx
  800716:	89 55 14             	mov    %edx,0x14(%ebp)
  800719:	8b 50 04             	mov    0x4(%eax),%edx
  80071c:	8b 00                	mov    (%eax),%eax
  80071e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800721:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800724:	eb 32                	jmp    800758 <vprintfmt+0x2ea>
	else if (lflag)
  800726:	85 d2                	test   %edx,%edx
  800728:	74 18                	je     800742 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)
  800733:	8b 30                	mov    (%eax),%esi
  800735:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800738:	89 f0                	mov    %esi,%eax
  80073a:	c1 f8 1f             	sar    $0x1f,%eax
  80073d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800740:	eb 16                	jmp    800758 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 50 04             	lea    0x4(%eax),%edx
  800748:	89 55 14             	mov    %edx,0x14(%ebp)
  80074b:	8b 30                	mov    (%eax),%esi
  80074d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800750:	89 f0                	mov    %esi,%eax
  800752:	c1 f8 1f             	sar    $0x1f,%eax
  800755:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800758:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80075b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80075e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800763:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800767:	0f 89 80 00 00 00    	jns    8007ed <vprintfmt+0x37f>
				putch('-', putdat);
  80076d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800771:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800778:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80077b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80077e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800781:	f7 d8                	neg    %eax
  800783:	83 d2 00             	adc    $0x0,%edx
  800786:	f7 da                	neg    %edx
			base = 10;
  800788:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80078d:	eb 5e                	jmp    8007ed <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 58 fc ff ff       	call   8003ef <getuint>
			base = 10;
  800797:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80079c:	eb 4f                	jmp    8007ed <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a1:	e8 49 fc ff ff       	call   8003ef <getuint>
            base = 8;
  8007a6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  8007ab:	eb 40                	jmp    8007ed <vprintfmt+0x37f>
			putch('0', putdat);
  8007ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007c6:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 50 04             	lea    0x4(%eax),%edx
  8007cf:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8007d9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007de:	eb 0d                	jmp    8007ed <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8007e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e3:	e8 07 fc ff ff       	call   8003ef <getuint>
			base = 16;
  8007e8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8007ed:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007f1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007f5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007f8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007fc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800800:	89 04 24             	mov    %eax,(%esp)
  800803:	89 54 24 04          	mov    %edx,0x4(%esp)
  800807:	89 fa                	mov    %edi,%edx
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	e8 ef fa ff ff       	call   800300 <printnum>
			break;
  800811:	e9 88 fc ff ff       	jmp    80049e <vprintfmt+0x30>
			putch(ch, putdat);
  800816:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80081a:	89 04 24             	mov    %eax,(%esp)
  80081d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800820:	e9 79 fc ff ff       	jmp    80049e <vprintfmt+0x30>
			putch('%', putdat);
  800825:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800829:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800830:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800833:	89 f3                	mov    %esi,%ebx
  800835:	eb 03                	jmp    80083a <vprintfmt+0x3cc>
  800837:	83 eb 01             	sub    $0x1,%ebx
  80083a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80083e:	75 f7                	jne    800837 <vprintfmt+0x3c9>
  800840:	e9 59 fc ff ff       	jmp    80049e <vprintfmt+0x30>
}
  800845:	83 c4 3c             	add    $0x3c,%esp
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5f                   	pop    %edi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	83 ec 28             	sub    $0x28,%esp
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800859:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800860:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800863:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086a:	85 c0                	test   %eax,%eax
  80086c:	74 30                	je     80089e <vsnprintf+0x51>
  80086e:	85 d2                	test   %edx,%edx
  800870:	7e 2c                	jle    80089e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800879:	8b 45 10             	mov    0x10(%ebp),%eax
  80087c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800880:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800883:	89 44 24 04          	mov    %eax,0x4(%esp)
  800887:	c7 04 24 29 04 80 00 	movl   $0x800429,(%esp)
  80088e:	e8 db fb ff ff       	call   80046e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800893:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800896:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089c:	eb 05                	jmp    8008a3 <vsnprintf+0x56>
		return -E_INVAL;
  80089e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	89 04 24             	mov    %eax,(%esp)
  8008c6:	e8 82 ff ff ff       	call   80084d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    
  8008cd:	66 90                	xchg   %ax,%ax
  8008cf:	90                   	nop

008008d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	eb 03                	jmp    8008e0 <strlen+0x10>
		n++;
  8008dd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e4:	75 f7                	jne    8008dd <strlen+0xd>
	return n;
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	eb 03                	jmp    8008fb <strnlen+0x13>
		n++;
  8008f8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	74 06                	je     800905 <strnlen+0x1d>
  8008ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800903:	75 f3                	jne    8008f8 <strnlen+0x10>
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800911:	89 c2                	mov    %eax,%edx
  800913:	83 c2 01             	add    $0x1,%edx
  800916:	83 c1 01             	add    $0x1,%ecx
  800919:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80091d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800920:	84 db                	test   %bl,%bl
  800922:	75 ef                	jne    800913 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800924:	5b                   	pop    %ebx
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800931:	89 1c 24             	mov    %ebx,(%esp)
  800934:	e8 97 ff ff ff       	call   8008d0 <strlen>
	strcpy(dst + len, src);
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800940:	01 d8                	add    %ebx,%eax
  800942:	89 04 24             	mov    %eax,(%esp)
  800945:	e8 bd ff ff ff       	call   800907 <strcpy>
	return dst;
}
  80094a:	89 d8                	mov    %ebx,%eax
  80094c:	83 c4 08             	add    $0x8,%esp
  80094f:	5b                   	pop    %ebx
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 75 08             	mov    0x8(%ebp),%esi
  80095a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095d:	89 f3                	mov    %esi,%ebx
  80095f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800962:	89 f2                	mov    %esi,%edx
  800964:	eb 0f                	jmp    800975 <strncpy+0x23>
		*dst++ = *src;
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	0f b6 01             	movzbl (%ecx),%eax
  80096c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80096f:	80 39 01             	cmpb   $0x1,(%ecx)
  800972:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800975:	39 da                	cmp    %ebx,%edx
  800977:	75 ed                	jne    800966 <strncpy+0x14>
	}
	return ret;
}
  800979:	89 f0                	mov    %esi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 75 08             	mov    0x8(%ebp),%esi
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80098d:	89 f0                	mov    %esi,%eax
  80098f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800993:	85 c9                	test   %ecx,%ecx
  800995:	75 0b                	jne    8009a2 <strlcpy+0x23>
  800997:	eb 1d                	jmp    8009b6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009a2:	39 d8                	cmp    %ebx,%eax
  8009a4:	74 0b                	je     8009b1 <strlcpy+0x32>
  8009a6:	0f b6 0a             	movzbl (%edx),%ecx
  8009a9:	84 c9                	test   %cl,%cl
  8009ab:	75 ec                	jne    800999 <strlcpy+0x1a>
  8009ad:	89 c2                	mov    %eax,%edx
  8009af:	eb 02                	jmp    8009b3 <strlcpy+0x34>
  8009b1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  8009b3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009b6:	29 f0                	sub    %esi,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c5:	eb 06                	jmp    8009cd <strcmp+0x11>
		p++, q++;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009cd:	0f b6 01             	movzbl (%ecx),%eax
  8009d0:	84 c0                	test   %al,%al
  8009d2:	74 04                	je     8009d8 <strcmp+0x1c>
  8009d4:	3a 02                	cmp    (%edx),%al
  8009d6:	74 ef                	je     8009c7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d8:	0f b6 c0             	movzbl %al,%eax
  8009db:	0f b6 12             	movzbl (%edx),%edx
  8009de:	29 d0                	sub    %edx,%eax
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f1:	eb 06                	jmp    8009f9 <strncmp+0x17>
		n--, p++, q++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009f9:	39 d8                	cmp    %ebx,%eax
  8009fb:	74 15                	je     800a12 <strncmp+0x30>
  8009fd:	0f b6 08             	movzbl (%eax),%ecx
  800a00:	84 c9                	test   %cl,%cl
  800a02:	74 04                	je     800a08 <strncmp+0x26>
  800a04:	3a 0a                	cmp    (%edx),%cl
  800a06:	74 eb                	je     8009f3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 00             	movzbl (%eax),%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
  800a10:	eb 05                	jmp    800a17 <strncmp+0x35>
		return 0;
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a24:	eb 07                	jmp    800a2d <strchr+0x13>
		if (*s == c)
  800a26:	38 ca                	cmp    %cl,%dl
  800a28:	74 0f                	je     800a39 <strchr+0x1f>
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 f2                	jne    800a26 <strchr+0xc>
			return (char *) s;
	return 0;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a45:	eb 07                	jmp    800a4e <strfind+0x13>
		if (*s == c)
  800a47:	38 ca                	cmp    %cl,%dl
  800a49:	74 0a                	je     800a55 <strfind+0x1a>
	for (; *s; s++)
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	0f b6 10             	movzbl (%eax),%edx
  800a51:	84 d2                	test   %dl,%dl
  800a53:	75 f2                	jne    800a47 <strfind+0xc>
			break;
	return (char *) s;
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a63:	85 c9                	test   %ecx,%ecx
  800a65:	74 36                	je     800a9d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a67:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6d:	75 28                	jne    800a97 <memset+0x40>
  800a6f:	f6 c1 03             	test   $0x3,%cl
  800a72:	75 23                	jne    800a97 <memset+0x40>
		c &= 0xFF;
  800a74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a78:	89 d3                	mov    %edx,%ebx
  800a7a:	c1 e3 08             	shl    $0x8,%ebx
  800a7d:	89 d6                	mov    %edx,%esi
  800a7f:	c1 e6 18             	shl    $0x18,%esi
  800a82:	89 d0                	mov    %edx,%eax
  800a84:	c1 e0 10             	shl    $0x10,%eax
  800a87:	09 f0                	or     %esi,%eax
  800a89:	09 c2                	or     %eax,%edx
  800a8b:	89 d0                	mov    %edx,%eax
  800a8d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a8f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a92:	fc                   	cld    
  800a93:	f3 ab                	rep stos %eax,%es:(%edi)
  800a95:	eb 06                	jmp    800a9d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	fc                   	cld    
  800a9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9d:	89 f8                	mov    %edi,%eax
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab2:	39 c6                	cmp    %eax,%esi
  800ab4:	73 35                	jae    800aeb <memmove+0x47>
  800ab6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab9:	39 d0                	cmp    %edx,%eax
  800abb:	73 2e                	jae    800aeb <memmove+0x47>
		s += n;
		d += n;
  800abd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aca:	75 13                	jne    800adf <memmove+0x3b>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 0e                	jne    800adf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad1:	83 ef 04             	sub    $0x4,%edi
  800ad4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ada:	fd                   	std    
  800adb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800add:	eb 09                	jmp    800ae8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adf:	83 ef 01             	sub    $0x1,%edi
  800ae2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae5:	fd                   	std    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae8:	fc                   	cld    
  800ae9:	eb 1d                	jmp    800b08 <memmove+0x64>
  800aeb:	89 f2                	mov    %esi,%edx
  800aed:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aef:	f6 c2 03             	test   $0x3,%dl
  800af2:	75 0f                	jne    800b03 <memmove+0x5f>
  800af4:	f6 c1 03             	test   $0x3,%cl
  800af7:	75 0a                	jne    800b03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800afc:	89 c7                	mov    %eax,%edi
  800afe:	fc                   	cld    
  800aff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b01:	eb 05                	jmp    800b08 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	fc                   	cld    
  800b06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b12:	8b 45 10             	mov    0x10(%ebp),%eax
  800b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 79 ff ff ff       	call   800aa4 <memmove>
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3d:	eb 1a                	jmp    800b59 <memcmp+0x2c>
		if (*s1 != *s2)
  800b3f:	0f b6 02             	movzbl (%edx),%eax
  800b42:	0f b6 19             	movzbl (%ecx),%ebx
  800b45:	38 d8                	cmp    %bl,%al
  800b47:	74 0a                	je     800b53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b49:	0f b6 c0             	movzbl %al,%eax
  800b4c:	0f b6 db             	movzbl %bl,%ebx
  800b4f:	29 d8                	sub    %ebx,%eax
  800b51:	eb 0f                	jmp    800b62 <memcmp+0x35>
		s1++, s2++;
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800b59:	39 f2                	cmp    %esi,%edx
  800b5b:	75 e2                	jne    800b3f <memcmp+0x12>
	}

	return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b74:	eb 07                	jmp    800b7d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b76:	38 08                	cmp    %cl,(%eax)
  800b78:	74 07                	je     800b81 <memfind+0x1b>
	for (; s < ends; s++)
  800b7a:	83 c0 01             	add    $0x1,%eax
  800b7d:	39 d0                	cmp    %edx,%eax
  800b7f:	72 f5                	jb     800b76 <memfind+0x10>
			break;
	return (void *) s;
}
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8f:	eb 03                	jmp    800b94 <strtol+0x11>
		s++;
  800b91:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b94:	0f b6 0a             	movzbl (%edx),%ecx
  800b97:	80 f9 09             	cmp    $0x9,%cl
  800b9a:	74 f5                	je     800b91 <strtol+0xe>
  800b9c:	80 f9 20             	cmp    $0x20,%cl
  800b9f:	74 f0                	je     800b91 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba1:	80 f9 2b             	cmp    $0x2b,%cl
  800ba4:	75 0a                	jne    800bb0 <strtol+0x2d>
		s++;
  800ba6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ba9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bae:	eb 11                	jmp    800bc1 <strtol+0x3e>
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800bb5:	80 f9 2d             	cmp    $0x2d,%cl
  800bb8:	75 07                	jne    800bc1 <strtol+0x3e>
		s++, neg = 1;
  800bba:	8d 52 01             	lea    0x1(%edx),%edx
  800bbd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bc6:	75 15                	jne    800bdd <strtol+0x5a>
  800bc8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bcb:	75 10                	jne    800bdd <strtol+0x5a>
  800bcd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd1:	75 0a                	jne    800bdd <strtol+0x5a>
		s += 2, base = 16;
  800bd3:	83 c2 02             	add    $0x2,%edx
  800bd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bdb:	eb 10                	jmp    800bed <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	75 0c                	jne    800bed <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800be3:	80 3a 30             	cmpb   $0x30,(%edx)
  800be6:	75 05                	jne    800bed <strtol+0x6a>
		s++, base = 8;
  800be8:	83 c2 01             	add    $0x1,%edx
  800beb:	b0 08                	mov    $0x8,%al
		base = 10;
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf5:	0f b6 0a             	movzbl (%edx),%ecx
  800bf8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bfb:	89 f0                	mov    %esi,%eax
  800bfd:	3c 09                	cmp    $0x9,%al
  800bff:	77 08                	ja     800c09 <strtol+0x86>
			dig = *s - '0';
  800c01:	0f be c9             	movsbl %cl,%ecx
  800c04:	83 e9 30             	sub    $0x30,%ecx
  800c07:	eb 20                	jmp    800c29 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c09:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c0c:	89 f0                	mov    %esi,%eax
  800c0e:	3c 19                	cmp    $0x19,%al
  800c10:	77 08                	ja     800c1a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c12:	0f be c9             	movsbl %cl,%ecx
  800c15:	83 e9 57             	sub    $0x57,%ecx
  800c18:	eb 0f                	jmp    800c29 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c1a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c1d:	89 f0                	mov    %esi,%eax
  800c1f:	3c 19                	cmp    $0x19,%al
  800c21:	77 16                	ja     800c39 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c23:	0f be c9             	movsbl %cl,%ecx
  800c26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c2c:	7d 0f                	jge    800c3d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c2e:	83 c2 01             	add    $0x1,%edx
  800c31:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c35:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c37:	eb bc                	jmp    800bf5 <strtol+0x72>
  800c39:	89 d8                	mov    %ebx,%eax
  800c3b:	eb 02                	jmp    800c3f <strtol+0xbc>
  800c3d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c43:	74 05                	je     800c4a <strtol+0xc7>
		*endptr = (char *) s;
  800c45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c48:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c4a:	f7 d8                	neg    %eax
  800c4c:	85 ff                	test   %edi,%edi
  800c4e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 c3                	mov    %eax,%ebx
  800c69:	89 c7                	mov    %eax,%edi
  800c6b:	89 c6                	mov    %eax,%esi
  800c6d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 cb                	mov    %ecx,%ebx
  800cab:	89 cf                	mov    %ecx,%edi
  800cad:	89 ce                	mov    %ecx,%esi
  800caf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	7e 28                	jle    800cdd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd0:	00 
  800cd1:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800cd8:	e8 59 14 00 00       	call   802136 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdd:	83 c4 2c             	add    $0x2c,%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	89 d3                	mov    %edx,%ebx
  800cf9:	89 d7                	mov    %edx,%edi
  800cfb:	89 d6                	mov    %edx,%esi
  800cfd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_yield>:

void
sys_yield(void)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	89 d3                	mov    %edx,%ebx
  800d18:	89 d7                	mov    %edx,%edi
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d2c:	be 00 00 00 00       	mov    $0x0,%esi
  800d31:	b8 04 00 00 00       	mov    $0x4,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	89 f7                	mov    %esi,%edi
  800d41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 28                	jle    800d6f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d52:	00 
  800d53:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d62:	00 
  800d63:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800d6a:	e8 c7 13 00 00       	call   802136 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6f:	83 c4 2c             	add    $0x2c,%esp
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d80:	b8 05 00 00 00       	mov    $0x5,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d91:	8b 75 18             	mov    0x18(%ebp),%esi
  800d94:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d96:	85 c0                	test   %eax,%eax
  800d98:	7e 28                	jle    800dc2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800da5:	00 
  800da6:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800dad:	00 
  800dae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db5:	00 
  800db6:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800dbd:	e8 74 13 00 00       	call   802136 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc2:	83 c4 2c             	add    $0x2c,%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 28                	jle    800e15 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800df8:	00 
  800df9:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800e00:	00 
  800e01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e08:	00 
  800e09:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800e10:	e8 21 13 00 00       	call   802136 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e15:	83 c4 2c             	add    $0x2c,%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	89 df                	mov    %ebx,%edi
  800e38:	89 de                	mov    %ebx,%esi
  800e3a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	7e 28                	jle    800e68 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e44:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e4b:	00 
  800e4c:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800e53:	00 
  800e54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5b:	00 
  800e5c:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800e63:	e8 ce 12 00 00       	call   802136 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e68:	83 c4 2c             	add    $0x2c,%esp
  800e6b:	5b                   	pop    %ebx
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	89 df                	mov    %ebx,%edi
  800e8b:	89 de                	mov    %ebx,%esi
  800e8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7e 28                	jle    800ebb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e97:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eae:	00 
  800eaf:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800eb6:	e8 7b 12 00 00       	call   802136 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ebb:	83 c4 2c             	add    $0x2c,%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 df                	mov    %ebx,%edi
  800ede:	89 de                	mov    %ebx,%esi
  800ee0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 28                	jle    800f0e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eea:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800ef9:	00 
  800efa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f01:	00 
  800f02:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800f09:	e8 28 12 00 00       	call   802136 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0e:	83 c4 2c             	add    $0x2c,%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1c:	be 00 00 00 00       	mov    $0x0,%esi
  800f21:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f32:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f47:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4f:	89 cb                	mov    %ecx,%ebx
  800f51:	89 cf                	mov    %ecx,%edi
  800f53:	89 ce                	mov    %ecx,%esi
  800f55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f57:	85 c0                	test   %eax,%eax
  800f59:	7e 28                	jle    800f83 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f66:	00 
  800f67:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f76:	00 
  800f77:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800f7e:	e8 b3 11 00 00       	call   802136 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f83:	83 c4 2c             	add    $0x2c,%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    
  800f8b:	66 90                	xchg   %ax,%ax
  800f8d:	66 90                	xchg   %ax,%ax
  800f8f:	90                   	nop

00800f90 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	53                   	push   %ebx
  800f94:	83 ec 24             	sub    $0x24,%esp
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  800f9a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  800f9c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa0:	74 18                	je     800fba <pgfault+0x2a>
  800fa2:	89 d8                	mov    %ebx,%eax
  800fa4:	c1 e8 0c             	shr    $0xc,%eax
  800fa7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fae:	25 05 08 00 00       	and    $0x805,%eax
  800fb3:	3d 05 08 00 00       	cmp    $0x805,%eax
  800fb8:	74 1c                	je     800fd6 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  800fba:	c7 44 24 08 ec 28 80 	movl   $0x8028ec,0x8(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800fc9:	00 
  800fca:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  800fd1:	e8 60 11 00 00       	call   802136 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  800fd6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fdd:	00 
  800fde:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe5:	00 
  800fe6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fed:	e8 31 fd ff ff       	call   800d23 <sys_page_alloc>
	if(r < 0){
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 1c                	jns    801012 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  800ff6:	c7 44 24 08 1c 29 80 	movl   $0x80291c,0x8(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801005:	00 
  801006:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  80100d:	e8 24 11 00 00       	call   802136 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801012:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801018:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80101f:	00 
  801020:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801024:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80102b:	e8 dc fa ff ff       	call   800b0c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  801030:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801037:	00 
  801038:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80103c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801043:	00 
  801044:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80104b:	00 
  80104c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801053:	e8 1f fd ff ff       	call   800d77 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  801058:	85 c0                	test   %eax,%eax
  80105a:	79 1c                	jns    801078 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  80105c:	c7 44 24 08 e8 29 80 	movl   $0x8029e8,0x8(%esp)
  801063:	00 
  801064:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80106b:	00 
  80106c:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  801073:	e8 be 10 00 00       	call   802136 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  801078:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80107f:	00 
  801080:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801087:	e8 3e fd ff ff       	call   800dca <sys_page_unmap>
    if(r < 0){
  80108c:	85 c0                	test   %eax,%eax
  80108e:	79 1c                	jns    8010ac <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  801090:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  801097:	00 
  801098:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80109f:	00 
  8010a0:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  8010a7:	e8 8a 10 00 00       	call   802136 <_panic>
    }
    // LAB 4
}
  8010ac:	83 c4 24             	add    $0x24,%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  8010bb:	c7 04 24 90 0f 80 00 	movl   $0x800f90,(%esp)
  8010c2:	e8 c5 10 00 00       	call   80218c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010c7:	b8 07 00 00 00       	mov    $0x7,%eax
  8010cc:	cd 30                	int    $0x30
  8010ce:	89 c7                	mov    %eax,%edi
  8010d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	79 1c                	jns    8010f3 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  8010d7:	c7 44 24 08 18 2a 80 	movl   $0x802a18,0x8(%esp)
  8010de:	00 
  8010df:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  8010e6:	00 
  8010e7:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  8010ee:	e8 43 10 00 00       	call   802136 <_panic>
    }
    if(child == 0){
  8010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	75 21                	jne    80111d <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  8010fc:	e8 e4 fb ff ff       	call   800ce5 <sys_getenvid>
  801101:	25 ff 03 00 00       	and    $0x3ff,%eax
  801106:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801109:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80110e:	a3 08 40 80 00       	mov    %eax,0x804008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
  801118:	e9 67 01 00 00       	jmp    801284 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  80111d:	89 d8                	mov    %ebx,%eax
  80111f:	c1 e8 16             	shr    $0x16,%eax
  801122:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801129:	a8 01                	test   $0x1,%al
  80112b:	74 4b                	je     801178 <fork+0xc6>
  80112d:	89 de                	mov    %ebx,%esi
  80112f:	c1 ee 0c             	shr    $0xc,%esi
  801132:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801139:	a8 01                	test   $0x1,%al
  80113b:	74 3b                	je     801178 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  80113d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801144:	a9 02 08 00 00       	test   $0x802,%eax
  801149:	0f 85 02 01 00 00    	jne    801251 <fork+0x19f>
  80114f:	e9 d2 00 00 00       	jmp    801226 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  801154:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80115b:	00 
  80115c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801160:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801167:	00 
  801168:	89 74 24 04          	mov    %esi,0x4(%esp)
  80116c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801173:	e8 ff fb ff ff       	call   800d77 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801178:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80117e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801184:	75 97                	jne    80111d <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801186:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80118d:	00 
  80118e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801195:	ee 
  801196:	89 3c 24             	mov    %edi,(%esp)
  801199:	e8 85 fb ff ff       	call   800d23 <sys_page_alloc>

    if(r < 0){
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	79 1c                	jns    8011be <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  8011a2:	c7 44 24 08 50 29 80 	movl   $0x802950,0x8(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  8011b1:	00 
  8011b2:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  8011b9:	e8 78 0f 00 00       	call   802136 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  8011be:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c3:	8b 40 64             	mov    0x64(%eax),%eax
  8011c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ca:	89 3c 24             	mov    %edi,(%esp)
  8011cd:	e8 f1 fc ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
    if(r < 0){
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	79 1c                	jns    8011f2 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  8011d6:	c7 44 24 08 70 29 80 	movl   $0x802970,0x8(%esp)
  8011dd:	00 
  8011de:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  8011e5:	00 
  8011e6:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  8011ed:	e8 44 0f 00 00       	call   802136 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  8011f2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011f9:	00 
  8011fa:	89 3c 24             	mov    %edi,(%esp)
  8011fd:	e8 1b fc ff ff       	call   800e1d <sys_env_set_status>
    if(r < 0){
  801202:	85 c0                	test   %eax,%eax
  801204:	79 1c                	jns    801222 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801206:	c7 44 24 08 98 29 80 	movl   $0x802998,0x8(%esp)
  80120d:	00 
  80120e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  801215:	00 
  801216:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  80121d:	e8 14 0f 00 00       	call   802136 <_panic>
    }
    return child;
  801222:	89 f8                	mov    %edi,%eax
  801224:	eb 5e                	jmp    801284 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  801226:	c1 e6 0c             	shl    $0xc,%esi
  801229:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801230:	00 
  801231:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801235:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801238:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801247:	e8 2b fb ff ff       	call   800d77 <sys_page_map>
  80124c:	e9 27 ff ff ff       	jmp    801178 <fork+0xc6>
  801251:	c1 e6 0c             	shl    $0xc,%esi
  801254:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80125b:	00 
  80125c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801260:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801263:	89 44 24 08          	mov    %eax,0x8(%esp)
  801267:	89 74 24 04          	mov    %esi,0x4(%esp)
  80126b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801272:	e8 00 fb ff ff       	call   800d77 <sys_page_map>
    if( r < 0 ){
  801277:	85 c0                	test   %eax,%eax
  801279:	0f 89 d5 fe ff ff    	jns    801154 <fork+0xa2>
  80127f:	e9 f4 fe ff ff       	jmp    801178 <fork+0xc6>
//	panic("fork not implemented");
}
  801284:	83 c4 2c             	add    $0x2c,%esp
  801287:	5b                   	pop    %ebx
  801288:	5e                   	pop    %esi
  801289:	5f                   	pop    %edi
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <sfork>:

// Challenge!
int
sfork(void)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801292:	c7 44 24 08 35 2a 80 	movl   $0x802a35,0x8(%esp)
  801299:	00 
  80129a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  8012a1:	00 
  8012a2:	c7 04 24 dd 29 80 00 	movl   $0x8029dd,(%esp)
  8012a9:	e8 88 0e 00 00       	call   802136 <_panic>
  8012ae:	66 90                	xchg   %ax,%ax

008012b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 10             	sub    $0x10,%esp
  8012b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012be:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  8012c1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  8012c3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8012c8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  8012cb:	89 04 24             	mov    %eax,(%esp)
  8012ce:	e8 66 fc ff ff       	call   800f39 <sys_ipc_recv>
    if(r < 0){
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	79 16                	jns    8012ed <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  8012d7:	85 f6                	test   %esi,%esi
  8012d9:	74 06                	je     8012e1 <ipc_recv+0x31>
            *from_env_store = 0;
  8012db:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  8012e1:	85 db                	test   %ebx,%ebx
  8012e3:	74 2c                	je     801311 <ipc_recv+0x61>
            *perm_store = 0;
  8012e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012eb:	eb 24                	jmp    801311 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  8012ed:	85 f6                	test   %esi,%esi
  8012ef:	74 0a                	je     8012fb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  8012f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012f6:	8b 40 74             	mov    0x74(%eax),%eax
  8012f9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  8012fb:	85 db                	test   %ebx,%ebx
  8012fd:	74 0a                	je     801309 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  8012ff:	a1 08 40 80 00       	mov    0x804008,%eax
  801304:	8b 40 78             	mov    0x78(%eax),%eax
  801307:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801309:	a1 08 40 80 00       	mov    0x804008,%eax
  80130e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 1c             	sub    $0x1c,%esp
  801321:	8b 7d 08             	mov    0x8(%ebp),%edi
  801324:	8b 75 0c             	mov    0xc(%ebp),%esi
  801327:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80132a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80132c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801331:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801334:	8b 45 14             	mov    0x14(%ebp),%eax
  801337:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80133b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80133f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801343:	89 3c 24             	mov    %edi,(%esp)
  801346:	e8 cb fb ff ff       	call   800f16 <sys_ipc_try_send>
        if(r == 0){
  80134b:	85 c0                	test   %eax,%eax
  80134d:	74 28                	je     801377 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80134f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801352:	74 1c                	je     801370 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801354:	c7 44 24 08 4b 2a 80 	movl   $0x802a4b,0x8(%esp)
  80135b:	00 
  80135c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801363:	00 
  801364:	c7 04 24 62 2a 80 00 	movl   $0x802a62,(%esp)
  80136b:	e8 c6 0d 00 00       	call   802136 <_panic>
        }
        sys_yield();
  801370:	e8 8f f9 ff ff       	call   800d04 <sys_yield>
    }
  801375:	eb bd                	jmp    801334 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801377:	83 c4 1c             	add    $0x1c,%esp
  80137a:	5b                   	pop    %ebx
  80137b:	5e                   	pop    %esi
  80137c:	5f                   	pop    %edi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801385:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80138a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80138d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801393:	8b 52 50             	mov    0x50(%edx),%edx
  801396:	39 ca                	cmp    %ecx,%edx
  801398:	75 0d                	jne    8013a7 <ipc_find_env+0x28>
			return envs[i].env_id;
  80139a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80139d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013a2:	8b 40 40             	mov    0x40(%eax),%eax
  8013a5:	eb 0e                	jmp    8013b5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  8013a7:	83 c0 01             	add    $0x1,%eax
  8013aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013af:	75 d9                	jne    80138a <ipc_find_env+0xb>
	return 0;
  8013b1:	66 b8 00 00          	mov    $0x0,%ax
}
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    
  8013b7:	66 90                	xchg   %ax,%ax
  8013b9:	66 90                	xchg   %ax,%ax
  8013bb:	66 90                	xchg   %ax,%ax
  8013bd:	66 90                	xchg   %ax,%ax
  8013bf:	90                   	nop

008013c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013e0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ed:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	c1 ea 16             	shr    $0x16,%edx
  8013f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fe:	f6 c2 01             	test   $0x1,%dl
  801401:	74 11                	je     801414 <fd_alloc+0x2d>
  801403:	89 c2                	mov    %eax,%edx
  801405:	c1 ea 0c             	shr    $0xc,%edx
  801408:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140f:	f6 c2 01             	test   $0x1,%dl
  801412:	75 09                	jne    80141d <fd_alloc+0x36>
			*fd_store = fd;
  801414:	89 01                	mov    %eax,(%ecx)
			return 0;
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
  80141b:	eb 17                	jmp    801434 <fd_alloc+0x4d>
  80141d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801422:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801427:	75 c9                	jne    8013f2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801429:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80142f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80143c:	83 f8 1f             	cmp    $0x1f,%eax
  80143f:	77 36                	ja     801477 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801441:	c1 e0 0c             	shl    $0xc,%eax
  801444:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801449:	89 c2                	mov    %eax,%edx
  80144b:	c1 ea 16             	shr    $0x16,%edx
  80144e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801455:	f6 c2 01             	test   $0x1,%dl
  801458:	74 24                	je     80147e <fd_lookup+0x48>
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	c1 ea 0c             	shr    $0xc,%edx
  80145f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801466:	f6 c2 01             	test   $0x1,%dl
  801469:	74 1a                	je     801485 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80146b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146e:	89 02                	mov    %eax,(%edx)
	return 0;
  801470:	b8 00 00 00 00       	mov    $0x0,%eax
  801475:	eb 13                	jmp    80148a <fd_lookup+0x54>
		return -E_INVAL;
  801477:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147c:	eb 0c                	jmp    80148a <fd_lookup+0x54>
		return -E_INVAL;
  80147e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801483:	eb 05                	jmp    80148a <fd_lookup+0x54>
  801485:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 18             	sub    $0x18,%esp
  801492:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801495:	ba e8 2a 80 00       	mov    $0x802ae8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80149a:	eb 13                	jmp    8014af <dev_lookup+0x23>
  80149c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80149f:	39 08                	cmp    %ecx,(%eax)
  8014a1:	75 0c                	jne    8014af <dev_lookup+0x23>
			*dev = devtab[i];
  8014a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ad:	eb 30                	jmp    8014df <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8014af:	8b 02                	mov    (%edx),%eax
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	75 e7                	jne    80149c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ba:	8b 40 48             	mov    0x48(%eax),%eax
  8014bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c5:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  8014cc:	e8 13 ee ff ff       	call   8002e4 <cprintf>
	*dev = 0;
  8014d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <fd_close>:
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 20             	sub    $0x20,%esp
  8014e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014fc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014ff:	89 04 24             	mov    %eax,(%esp)
  801502:	e8 2f ff ff ff       	call   801436 <fd_lookup>
  801507:	85 c0                	test   %eax,%eax
  801509:	78 05                	js     801510 <fd_close+0x2f>
	    || fd != fd2)
  80150b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80150e:	74 0c                	je     80151c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801510:	84 db                	test   %bl,%bl
  801512:	ba 00 00 00 00       	mov    $0x0,%edx
  801517:	0f 44 c2             	cmove  %edx,%eax
  80151a:	eb 3f                	jmp    80155b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80151c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801523:	8b 06                	mov    (%esi),%eax
  801525:	89 04 24             	mov    %eax,(%esp)
  801528:	e8 5f ff ff ff       	call   80148c <dev_lookup>
  80152d:	89 c3                	mov    %eax,%ebx
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 16                	js     801549 <fd_close+0x68>
		if (dev->dev_close)
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801539:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80153e:	85 c0                	test   %eax,%eax
  801540:	74 07                	je     801549 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801542:	89 34 24             	mov    %esi,(%esp)
  801545:	ff d0                	call   *%eax
  801547:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801549:	89 74 24 04          	mov    %esi,0x4(%esp)
  80154d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801554:	e8 71 f8 ff ff       	call   800dca <sys_page_unmap>
	return r;
  801559:	89 d8                	mov    %ebx,%eax
}
  80155b:	83 c4 20             	add    $0x20,%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    

00801562 <close>:

int
close(int fdnum)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801568:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156f:	8b 45 08             	mov    0x8(%ebp),%eax
  801572:	89 04 24             	mov    %eax,(%esp)
  801575:	e8 bc fe ff ff       	call   801436 <fd_lookup>
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	85 d2                	test   %edx,%edx
  80157e:	78 13                	js     801593 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801580:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801587:	00 
  801588:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158b:	89 04 24             	mov    %eax,(%esp)
  80158e:	e8 4e ff ff ff       	call   8014e1 <fd_close>
}
  801593:	c9                   	leave  
  801594:	c3                   	ret    

00801595 <close_all>:

void
close_all(void)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	53                   	push   %ebx
  801599:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80159c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015a1:	89 1c 24             	mov    %ebx,(%esp)
  8015a4:	e8 b9 ff ff ff       	call   801562 <close>
	for (i = 0; i < MAXFD; i++)
  8015a9:	83 c3 01             	add    $0x1,%ebx
  8015ac:	83 fb 20             	cmp    $0x20,%ebx
  8015af:	75 f0                	jne    8015a1 <close_all+0xc>
}
  8015b1:	83 c4 14             	add    $0x14,%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	57                   	push   %edi
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ca:	89 04 24             	mov    %eax,(%esp)
  8015cd:	e8 64 fe ff ff       	call   801436 <fd_lookup>
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	85 d2                	test   %edx,%edx
  8015d6:	0f 88 e1 00 00 00    	js     8016bd <dup+0x106>
		return r;
	close(newfdnum);
  8015dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015df:	89 04 24             	mov    %eax,(%esp)
  8015e2:	e8 7b ff ff ff       	call   801562 <close>

	newfd = INDEX2FD(newfdnum);
  8015e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015ea:	c1 e3 0c             	shl    $0xc,%ebx
  8015ed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f6:	89 04 24             	mov    %eax,(%esp)
  8015f9:	e8 d2 fd ff ff       	call   8013d0 <fd2data>
  8015fe:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801600:	89 1c 24             	mov    %ebx,(%esp)
  801603:	e8 c8 fd ff ff       	call   8013d0 <fd2data>
  801608:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80160a:	89 f0                	mov    %esi,%eax
  80160c:	c1 e8 16             	shr    $0x16,%eax
  80160f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801616:	a8 01                	test   $0x1,%al
  801618:	74 43                	je     80165d <dup+0xa6>
  80161a:	89 f0                	mov    %esi,%eax
  80161c:	c1 e8 0c             	shr    $0xc,%eax
  80161f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801626:	f6 c2 01             	test   $0x1,%dl
  801629:	74 32                	je     80165d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80162b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801632:	25 07 0e 00 00       	and    $0xe07,%eax
  801637:	89 44 24 10          	mov    %eax,0x10(%esp)
  80163b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80163f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801646:	00 
  801647:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801652:	e8 20 f7 ff ff       	call   800d77 <sys_page_map>
  801657:	89 c6                	mov    %eax,%esi
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 3e                	js     80169b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80165d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801660:	89 c2                	mov    %eax,%edx
  801662:	c1 ea 0c             	shr    $0xc,%edx
  801665:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80166c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801672:	89 54 24 10          	mov    %edx,0x10(%esp)
  801676:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80167a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801681:	00 
  801682:	89 44 24 04          	mov    %eax,0x4(%esp)
  801686:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168d:	e8 e5 f6 ff ff       	call   800d77 <sys_page_map>
  801692:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801694:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801697:	85 f6                	test   %esi,%esi
  801699:	79 22                	jns    8016bd <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80169b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80169f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a6:	e8 1f f7 ff ff       	call   800dca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b6:	e8 0f f7 ff ff       	call   800dca <sys_page_unmap>
	return r;
  8016bb:	89 f0                	mov    %esi,%eax
}
  8016bd:	83 c4 3c             	add    $0x3c,%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5e                   	pop    %esi
  8016c2:	5f                   	pop    %edi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 24             	sub    $0x24,%esp
  8016cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d6:	89 1c 24             	mov    %ebx,(%esp)
  8016d9:	e8 58 fd ff ff       	call   801436 <fd_lookup>
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	85 d2                	test   %edx,%edx
  8016e2:	78 6d                	js     801751 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ee:	8b 00                	mov    (%eax),%eax
  8016f0:	89 04 24             	mov    %eax,(%esp)
  8016f3:	e8 94 fd ff ff       	call   80148c <dev_lookup>
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 55                	js     801751 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ff:	8b 50 08             	mov    0x8(%eax),%edx
  801702:	83 e2 03             	and    $0x3,%edx
  801705:	83 fa 01             	cmp    $0x1,%edx
  801708:	75 23                	jne    80172d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80170a:	a1 08 40 80 00       	mov    0x804008,%eax
  80170f:	8b 40 48             	mov    0x48(%eax),%eax
  801712:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171a:	c7 04 24 ad 2a 80 00 	movl   $0x802aad,(%esp)
  801721:	e8 be eb ff ff       	call   8002e4 <cprintf>
		return -E_INVAL;
  801726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172b:	eb 24                	jmp    801751 <read+0x8c>
	}
	if (!dev->dev_read)
  80172d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801730:	8b 52 08             	mov    0x8(%edx),%edx
  801733:	85 d2                	test   %edx,%edx
  801735:	74 15                	je     80174c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801737:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80173a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80173e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801741:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	ff d2                	call   *%edx
  80174a:	eb 05                	jmp    801751 <read+0x8c>
		return -E_NOT_SUPP;
  80174c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801751:	83 c4 24             	add    $0x24,%esp
  801754:	5b                   	pop    %ebx
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	57                   	push   %edi
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	83 ec 1c             	sub    $0x1c,%esp
  801760:	8b 7d 08             	mov    0x8(%ebp),%edi
  801763:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801766:	bb 00 00 00 00       	mov    $0x0,%ebx
  80176b:	eb 23                	jmp    801790 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80176d:	89 f0                	mov    %esi,%eax
  80176f:	29 d8                	sub    %ebx,%eax
  801771:	89 44 24 08          	mov    %eax,0x8(%esp)
  801775:	89 d8                	mov    %ebx,%eax
  801777:	03 45 0c             	add    0xc(%ebp),%eax
  80177a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177e:	89 3c 24             	mov    %edi,(%esp)
  801781:	e8 3f ff ff ff       	call   8016c5 <read>
		if (m < 0)
  801786:	85 c0                	test   %eax,%eax
  801788:	78 10                	js     80179a <readn+0x43>
			return m;
		if (m == 0)
  80178a:	85 c0                	test   %eax,%eax
  80178c:	74 0a                	je     801798 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80178e:	01 c3                	add    %eax,%ebx
  801790:	39 f3                	cmp    %esi,%ebx
  801792:	72 d9                	jb     80176d <readn+0x16>
  801794:	89 d8                	mov    %ebx,%eax
  801796:	eb 02                	jmp    80179a <readn+0x43>
  801798:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80179a:	83 c4 1c             	add    $0x1c,%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5f                   	pop    %edi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 24             	sub    $0x24,%esp
  8017a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b3:	89 1c 24             	mov    %ebx,(%esp)
  8017b6:	e8 7b fc ff ff       	call   801436 <fd_lookup>
  8017bb:	89 c2                	mov    %eax,%edx
  8017bd:	85 d2                	test   %edx,%edx
  8017bf:	78 68                	js     801829 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cb:	8b 00                	mov    (%eax),%eax
  8017cd:	89 04 24             	mov    %eax,(%esp)
  8017d0:	e8 b7 fc ff ff       	call   80148c <dev_lookup>
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 50                	js     801829 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e0:	75 23                	jne    801805 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8017e7:	8b 40 48             	mov    0x48(%eax),%eax
  8017ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f2:	c7 04 24 c9 2a 80 00 	movl   $0x802ac9,(%esp)
  8017f9:	e8 e6 ea ff ff       	call   8002e4 <cprintf>
		return -E_INVAL;
  8017fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801803:	eb 24                	jmp    801829 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801805:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801808:	8b 52 0c             	mov    0xc(%edx),%edx
  80180b:	85 d2                	test   %edx,%edx
  80180d:	74 15                	je     801824 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80180f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801812:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801819:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80181d:	89 04 24             	mov    %eax,(%esp)
  801820:	ff d2                	call   *%edx
  801822:	eb 05                	jmp    801829 <write+0x87>
		return -E_NOT_SUPP;
  801824:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801829:	83 c4 24             	add    $0x24,%esp
  80182c:	5b                   	pop    %ebx
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <seek>:

int
seek(int fdnum, off_t offset)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801835:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 ef fb ff ff       	call   801436 <fd_lookup>
  801847:	85 c0                	test   %eax,%eax
  801849:	78 0e                	js     801859 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80184b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80184e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801851:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801854:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	53                   	push   %ebx
  80185f:	83 ec 24             	sub    $0x24,%esp
  801862:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801865:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186c:	89 1c 24             	mov    %ebx,(%esp)
  80186f:	e8 c2 fb ff ff       	call   801436 <fd_lookup>
  801874:	89 c2                	mov    %eax,%edx
  801876:	85 d2                	test   %edx,%edx
  801878:	78 61                	js     8018db <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801884:	8b 00                	mov    (%eax),%eax
  801886:	89 04 24             	mov    %eax,(%esp)
  801889:	e8 fe fb ff ff       	call   80148c <dev_lookup>
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 49                	js     8018db <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801892:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801895:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801899:	75 23                	jne    8018be <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80189b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018a0:	8b 40 48             	mov    0x48(%eax),%eax
  8018a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ab:	c7 04 24 8c 2a 80 00 	movl   $0x802a8c,(%esp)
  8018b2:	e8 2d ea ff ff       	call   8002e4 <cprintf>
		return -E_INVAL;
  8018b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018bc:	eb 1d                	jmp    8018db <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c1:	8b 52 18             	mov    0x18(%edx),%edx
  8018c4:	85 d2                	test   %edx,%edx
  8018c6:	74 0e                	je     8018d6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018cf:	89 04 24             	mov    %eax,(%esp)
  8018d2:	ff d2                	call   *%edx
  8018d4:	eb 05                	jmp    8018db <ftruncate+0x80>
		return -E_NOT_SUPP;
  8018d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018db:	83 c4 24             	add    $0x24,%esp
  8018de:	5b                   	pop    %ebx
  8018df:	5d                   	pop    %ebp
  8018e0:	c3                   	ret    

008018e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 24             	sub    $0x24,%esp
  8018e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	89 04 24             	mov    %eax,(%esp)
  8018f8:	e8 39 fb ff ff       	call   801436 <fd_lookup>
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	85 d2                	test   %edx,%edx
  801901:	78 52                	js     801955 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801903:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801906:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190d:	8b 00                	mov    (%eax),%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 75 fb ff ff       	call   80148c <dev_lookup>
  801917:	85 c0                	test   %eax,%eax
  801919:	78 3a                	js     801955 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801922:	74 2c                	je     801950 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801924:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801927:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80192e:	00 00 00 
	stat->st_isdir = 0;
  801931:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801938:	00 00 00 
	stat->st_dev = dev;
  80193b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801941:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801945:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801948:	89 14 24             	mov    %edx,(%esp)
  80194b:	ff 50 14             	call   *0x14(%eax)
  80194e:	eb 05                	jmp    801955 <fstat+0x74>
		return -E_NOT_SUPP;
  801950:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801955:	83 c4 24             	add    $0x24,%esp
  801958:	5b                   	pop    %ebx
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801963:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80196a:	00 
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
  80196e:	89 04 24             	mov    %eax,(%esp)
  801971:	e8 fb 01 00 00       	call   801b71 <open>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	85 db                	test   %ebx,%ebx
  80197a:	78 1b                	js     801997 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80197c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801983:	89 1c 24             	mov    %ebx,(%esp)
  801986:	e8 56 ff ff ff       	call   8018e1 <fstat>
  80198b:	89 c6                	mov    %eax,%esi
	close(fd);
  80198d:	89 1c 24             	mov    %ebx,(%esp)
  801990:	e8 cd fb ff ff       	call   801562 <close>
	return r;
  801995:	89 f0                	mov    %esi,%eax
}
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	56                   	push   %esi
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 10             	sub    $0x10,%esp
  8019a6:	89 c6                	mov    %eax,%esi
  8019a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019aa:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019b1:	75 11                	jne    8019c4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019ba:	e8 c0 f9 ff ff       	call   80137f <ipc_find_env>
  8019bf:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019c4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019cb:	00 
  8019cc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019d3:	00 
  8019d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8019dd:	89 04 24             	mov    %eax,(%esp)
  8019e0:	e8 33 f9 ff ff       	call   801318 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019ec:	00 
  8019ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f8:	e8 b3 f8 ff ff       	call   8012b0 <ipc_recv>
}
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	5b                   	pop    %ebx
  801a01:	5e                   	pop    %esi
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    

00801a04 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a10:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a18:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a22:	b8 02 00 00 00       	mov    $0x2,%eax
  801a27:	e8 72 ff ff ff       	call   80199e <fsipc>
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <devfile_flush>:
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a34:	8b 45 08             	mov    0x8(%ebp),%eax
  801a37:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a44:	b8 06 00 00 00       	mov    $0x6,%eax
  801a49:	e8 50 ff ff ff       	call   80199e <fsipc>
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <devfile_stat>:
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	53                   	push   %ebx
  801a54:	83 ec 14             	sub    $0x14,%esp
  801a57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a60:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a65:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a6f:	e8 2a ff ff ff       	call   80199e <fsipc>
  801a74:	89 c2                	mov    %eax,%edx
  801a76:	85 d2                	test   %edx,%edx
  801a78:	78 2b                	js     801aa5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a7a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a81:	00 
  801a82:	89 1c 24             	mov    %ebx,(%esp)
  801a85:	e8 7d ee ff ff       	call   800907 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a8a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a8f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a95:	a1 84 50 80 00       	mov    0x805084,%eax
  801a9a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa5:	83 c4 14             	add    $0x14,%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <devfile_write>:
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801ab1:	c7 44 24 08 f8 2a 80 	movl   $0x802af8,0x8(%esp)
  801ab8:	00 
  801ab9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801ac0:	00 
  801ac1:	c7 04 24 16 2b 80 00 	movl   $0x802b16,(%esp)
  801ac8:	e8 69 06 00 00       	call   802136 <_panic>

00801acd <devfile_read>:
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 10             	sub    $0x10,%esp
  801ad5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  801adb:	8b 40 0c             	mov    0xc(%eax),%eax
  801ade:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ae3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aee:	b8 03 00 00 00       	mov    $0x3,%eax
  801af3:	e8 a6 fe ff ff       	call   80199e <fsipc>
  801af8:	89 c3                	mov    %eax,%ebx
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 6a                	js     801b68 <devfile_read+0x9b>
	assert(r <= n);
  801afe:	39 c6                	cmp    %eax,%esi
  801b00:	73 24                	jae    801b26 <devfile_read+0x59>
  801b02:	c7 44 24 0c 21 2b 80 	movl   $0x802b21,0xc(%esp)
  801b09:	00 
  801b0a:	c7 44 24 08 28 2b 80 	movl   $0x802b28,0x8(%esp)
  801b11:	00 
  801b12:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b19:	00 
  801b1a:	c7 04 24 16 2b 80 00 	movl   $0x802b16,(%esp)
  801b21:	e8 10 06 00 00       	call   802136 <_panic>
	assert(r <= PGSIZE);
  801b26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b2b:	7e 24                	jle    801b51 <devfile_read+0x84>
  801b2d:	c7 44 24 0c 3d 2b 80 	movl   $0x802b3d,0xc(%esp)
  801b34:	00 
  801b35:	c7 44 24 08 28 2b 80 	movl   $0x802b28,0x8(%esp)
  801b3c:	00 
  801b3d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b44:	00 
  801b45:	c7 04 24 16 2b 80 00 	movl   $0x802b16,(%esp)
  801b4c:	e8 e5 05 00 00       	call   802136 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b51:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b55:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b5c:	00 
  801b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b60:	89 04 24             	mov    %eax,(%esp)
  801b63:	e8 3c ef ff ff       	call   800aa4 <memmove>
}
  801b68:	89 d8                	mov    %ebx,%eax
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	5b                   	pop    %ebx
  801b6e:	5e                   	pop    %esi
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <open>:
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	53                   	push   %ebx
  801b75:	83 ec 24             	sub    $0x24,%esp
  801b78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801b7b:	89 1c 24             	mov    %ebx,(%esp)
  801b7e:	e8 4d ed ff ff       	call   8008d0 <strlen>
  801b83:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b88:	7f 60                	jg     801bea <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801b8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8d:	89 04 24             	mov    %eax,(%esp)
  801b90:	e8 52 f8 ff ff       	call   8013e7 <fd_alloc>
  801b95:	89 c2                	mov    %eax,%edx
  801b97:	85 d2                	test   %edx,%edx
  801b99:	78 54                	js     801bef <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801b9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b9f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ba6:	e8 5c ed ff ff       	call   800907 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bae:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbb:	e8 de fd ff ff       	call   80199e <fsipc>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	79 17                	jns    801bdd <open+0x6c>
		fd_close(fd, 0);
  801bc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bcd:	00 
  801bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd1:	89 04 24             	mov    %eax,(%esp)
  801bd4:	e8 08 f9 ff ff       	call   8014e1 <fd_close>
		return r;
  801bd9:	89 d8                	mov    %ebx,%eax
  801bdb:	eb 12                	jmp    801bef <open+0x7e>
	return fd2num(fd);
  801bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be0:	89 04 24             	mov    %eax,(%esp)
  801be3:	e8 d8 f7 ff ff       	call   8013c0 <fd2num>
  801be8:	eb 05                	jmp    801bef <open+0x7e>
		return -E_BAD_PATH;
  801bea:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801bef:	83 c4 24             	add    $0x24,%esp
  801bf2:	5b                   	pop    %ebx
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  801c00:	b8 08 00 00 00       	mov    $0x8,%eax
  801c05:	e8 94 fd ff ff       	call   80199e <fsipc>
}
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	83 ec 10             	sub    $0x10,%esp
  801c14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c17:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1a:	89 04 24             	mov    %eax,(%esp)
  801c1d:	e8 ae f7 ff ff       	call   8013d0 <fd2data>
  801c22:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c24:	c7 44 24 04 49 2b 80 	movl   $0x802b49,0x4(%esp)
  801c2b:	00 
  801c2c:	89 1c 24             	mov    %ebx,(%esp)
  801c2f:	e8 d3 ec ff ff       	call   800907 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c34:	8b 46 04             	mov    0x4(%esi),%eax
  801c37:	2b 06                	sub    (%esi),%eax
  801c39:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c3f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c46:	00 00 00 
	stat->st_dev = &devpipe;
  801c49:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801c50:	30 80 00 
	return 0;
}
  801c53:	b8 00 00 00 00       	mov    $0x0,%eax
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	5b                   	pop    %ebx
  801c5c:	5e                   	pop    %esi
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	53                   	push   %ebx
  801c63:	83 ec 14             	sub    $0x14,%esp
  801c66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c74:	e8 51 f1 ff ff       	call   800dca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c79:	89 1c 24             	mov    %ebx,(%esp)
  801c7c:	e8 4f f7 ff ff       	call   8013d0 <fd2data>
  801c81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8c:	e8 39 f1 ff ff       	call   800dca <sys_page_unmap>
}
  801c91:	83 c4 14             	add    $0x14,%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <_pipeisclosed>:
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 2c             	sub    $0x2c,%esp
  801ca0:	89 c6                	mov    %eax,%esi
  801ca2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801ca5:	a1 08 40 80 00       	mov    0x804008,%eax
  801caa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cad:	89 34 24             	mov    %esi,(%esp)
  801cb0:	e8 87 05 00 00       	call   80223c <pageref>
  801cb5:	89 c7                	mov    %eax,%edi
  801cb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cba:	89 04 24             	mov    %eax,(%esp)
  801cbd:	e8 7a 05 00 00       	call   80223c <pageref>
  801cc2:	39 c7                	cmp    %eax,%edi
  801cc4:	0f 94 c2             	sete   %dl
  801cc7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801cca:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801cd0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801cd3:	39 fb                	cmp    %edi,%ebx
  801cd5:	74 21                	je     801cf8 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801cd7:	84 d2                	test   %dl,%dl
  801cd9:	74 ca                	je     801ca5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cdb:	8b 51 58             	mov    0x58(%ecx),%edx
  801cde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ce2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ce6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cea:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  801cf1:	e8 ee e5 ff ff       	call   8002e4 <cprintf>
  801cf6:	eb ad                	jmp    801ca5 <_pipeisclosed+0xe>
}
  801cf8:	83 c4 2c             	add    $0x2c,%esp
  801cfb:	5b                   	pop    %ebx
  801cfc:	5e                   	pop    %esi
  801cfd:	5f                   	pop    %edi
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    

00801d00 <devpipe_write>:
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	57                   	push   %edi
  801d04:	56                   	push   %esi
  801d05:	53                   	push   %ebx
  801d06:	83 ec 1c             	sub    $0x1c,%esp
  801d09:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d0c:	89 34 24             	mov    %esi,(%esp)
  801d0f:	e8 bc f6 ff ff       	call   8013d0 <fd2data>
  801d14:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d16:	bf 00 00 00 00       	mov    $0x0,%edi
  801d1b:	eb 45                	jmp    801d62 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801d1d:	89 da                	mov    %ebx,%edx
  801d1f:	89 f0                	mov    %esi,%eax
  801d21:	e8 71 ff ff ff       	call   801c97 <_pipeisclosed>
  801d26:	85 c0                	test   %eax,%eax
  801d28:	75 41                	jne    801d6b <devpipe_write+0x6b>
			sys_yield();
  801d2a:	e8 d5 ef ff ff       	call   800d04 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d2f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d32:	8b 0b                	mov    (%ebx),%ecx
  801d34:	8d 51 20             	lea    0x20(%ecx),%edx
  801d37:	39 d0                	cmp    %edx,%eax
  801d39:	73 e2                	jae    801d1d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d3e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d42:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d45:	99                   	cltd   
  801d46:	c1 ea 1b             	shr    $0x1b,%edx
  801d49:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d4c:	83 e1 1f             	and    $0x1f,%ecx
  801d4f:	29 d1                	sub    %edx,%ecx
  801d51:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d55:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d59:	83 c0 01             	add    $0x1,%eax
  801d5c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d5f:	83 c7 01             	add    $0x1,%edi
  801d62:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d65:	75 c8                	jne    801d2f <devpipe_write+0x2f>
	return i;
  801d67:	89 f8                	mov    %edi,%eax
  801d69:	eb 05                	jmp    801d70 <devpipe_write+0x70>
				return 0;
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    

00801d78 <devpipe_read>:
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	57                   	push   %edi
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	83 ec 1c             	sub    $0x1c,%esp
  801d81:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d84:	89 3c 24             	mov    %edi,(%esp)
  801d87:	e8 44 f6 ff ff       	call   8013d0 <fd2data>
  801d8c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d8e:	be 00 00 00 00       	mov    $0x0,%esi
  801d93:	eb 3d                	jmp    801dd2 <devpipe_read+0x5a>
			if (i > 0)
  801d95:	85 f6                	test   %esi,%esi
  801d97:	74 04                	je     801d9d <devpipe_read+0x25>
				return i;
  801d99:	89 f0                	mov    %esi,%eax
  801d9b:	eb 43                	jmp    801de0 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801d9d:	89 da                	mov    %ebx,%edx
  801d9f:	89 f8                	mov    %edi,%eax
  801da1:	e8 f1 fe ff ff       	call   801c97 <_pipeisclosed>
  801da6:	85 c0                	test   %eax,%eax
  801da8:	75 31                	jne    801ddb <devpipe_read+0x63>
			sys_yield();
  801daa:	e8 55 ef ff ff       	call   800d04 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801daf:	8b 03                	mov    (%ebx),%eax
  801db1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801db4:	74 df                	je     801d95 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801db6:	99                   	cltd   
  801db7:	c1 ea 1b             	shr    $0x1b,%edx
  801dba:	01 d0                	add    %edx,%eax
  801dbc:	83 e0 1f             	and    $0x1f,%eax
  801dbf:	29 d0                	sub    %edx,%eax
  801dc1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dcc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dcf:	83 c6 01             	add    $0x1,%esi
  801dd2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd5:	75 d8                	jne    801daf <devpipe_read+0x37>
	return i;
  801dd7:	89 f0                	mov    %esi,%eax
  801dd9:	eb 05                	jmp    801de0 <devpipe_read+0x68>
				return 0;
  801ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801de0:	83 c4 1c             	add    $0x1c,%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <pipe>:
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	56                   	push   %esi
  801dec:	53                   	push   %ebx
  801ded:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801df0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df3:	89 04 24             	mov    %eax,(%esp)
  801df6:	e8 ec f5 ff ff       	call   8013e7 <fd_alloc>
  801dfb:	89 c2                	mov    %eax,%edx
  801dfd:	85 d2                	test   %edx,%edx
  801dff:	0f 88 4d 01 00 00    	js     801f52 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e05:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e0c:	00 
  801e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1b:	e8 03 ef ff ff       	call   800d23 <sys_page_alloc>
  801e20:	89 c2                	mov    %eax,%edx
  801e22:	85 d2                	test   %edx,%edx
  801e24:	0f 88 28 01 00 00    	js     801f52 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801e2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e2d:	89 04 24             	mov    %eax,(%esp)
  801e30:	e8 b2 f5 ff ff       	call   8013e7 <fd_alloc>
  801e35:	89 c3                	mov    %eax,%ebx
  801e37:	85 c0                	test   %eax,%eax
  801e39:	0f 88 fe 00 00 00    	js     801f3d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e46:	00 
  801e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e55:	e8 c9 ee ff ff       	call   800d23 <sys_page_alloc>
  801e5a:	89 c3                	mov    %eax,%ebx
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	0f 88 d9 00 00 00    	js     801f3d <pipe+0x155>
	va = fd2data(fd0);
  801e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e67:	89 04 24             	mov    %eax,(%esp)
  801e6a:	e8 61 f5 ff ff       	call   8013d0 <fd2data>
  801e6f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e71:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e78:	00 
  801e79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e84:	e8 9a ee ff ff       	call   800d23 <sys_page_alloc>
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	0f 88 97 00 00 00    	js     801f2a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e96:	89 04 24             	mov    %eax,(%esp)
  801e99:	e8 32 f5 ff ff       	call   8013d0 <fd2data>
  801e9e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ea5:	00 
  801ea6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eaa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eb1:	00 
  801eb2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebd:	e8 b5 ee ff ff       	call   800d77 <sys_page_map>
  801ec2:	89 c3                	mov    %eax,%ebx
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 52                	js     801f1a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801ec8:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801edd:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eeb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	89 04 24             	mov    %eax,(%esp)
  801ef8:	e8 c3 f4 ff ff       	call   8013c0 <fd2num>
  801efd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f00:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f05:	89 04 24             	mov    %eax,(%esp)
  801f08:	e8 b3 f4 ff ff       	call   8013c0 <fd2num>
  801f0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f10:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f13:	b8 00 00 00 00       	mov    $0x0,%eax
  801f18:	eb 38                	jmp    801f52 <pipe+0x16a>
	sys_page_unmap(0, va);
  801f1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f25:	e8 a0 ee ff ff       	call   800dca <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801f2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f38:	e8 8d ee ff ff       	call   800dca <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4b:	e8 7a ee ff ff       	call   800dca <sys_page_unmap>
  801f50:	89 d8                	mov    %ebx,%eax
}
  801f52:	83 c4 30             	add    $0x30,%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <pipeisclosed>:
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f66:	8b 45 08             	mov    0x8(%ebp),%eax
  801f69:	89 04 24             	mov    %eax,(%esp)
  801f6c:	e8 c5 f4 ff ff       	call   801436 <fd_lookup>
  801f71:	89 c2                	mov    %eax,%edx
  801f73:	85 d2                	test   %edx,%edx
  801f75:	78 15                	js     801f8c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7a:	89 04 24             	mov    %eax,(%esp)
  801f7d:	e8 4e f4 ff ff       	call   8013d0 <fd2data>
	return _pipeisclosed(fd, p);
  801f82:	89 c2                	mov    %eax,%edx
  801f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f87:	e8 0b fd ff ff       	call   801c97 <_pipeisclosed>
}
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fa0:	c7 44 24 04 68 2b 80 	movl   $0x802b68,0x4(%esp)
  801fa7:	00 
  801fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fab:	89 04 24             	mov    %eax,(%esp)
  801fae:	e8 54 e9 ff ff       	call   800907 <strcpy>
	return 0;
}
  801fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <devcons_write>:
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	57                   	push   %edi
  801fbe:	56                   	push   %esi
  801fbf:	53                   	push   %ebx
  801fc0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fcb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fd1:	eb 31                	jmp    802004 <devcons_write+0x4a>
		m = n - tot;
  801fd3:	8b 75 10             	mov    0x10(%ebp),%esi
  801fd6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fd8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801fdb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fe0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fe3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fe7:	03 45 0c             	add    0xc(%ebp),%eax
  801fea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fee:	89 3c 24             	mov    %edi,(%esp)
  801ff1:	e8 ae ea ff ff       	call   800aa4 <memmove>
		sys_cputs(buf, m);
  801ff6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ffa:	89 3c 24             	mov    %edi,(%esp)
  801ffd:	e8 54 ec ff ff       	call   800c56 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802002:	01 f3                	add    %esi,%ebx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802009:	72 c8                	jb     801fd3 <devcons_write+0x19>
}
  80200b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5f                   	pop    %edi
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    

00802016 <devcons_read>:
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80201c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802021:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802025:	75 07                	jne    80202e <devcons_read+0x18>
  802027:	eb 2a                	jmp    802053 <devcons_read+0x3d>
		sys_yield();
  802029:	e8 d6 ec ff ff       	call   800d04 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80202e:	66 90                	xchg   %ax,%ax
  802030:	e8 3f ec ff ff       	call   800c74 <sys_cgetc>
  802035:	85 c0                	test   %eax,%eax
  802037:	74 f0                	je     802029 <devcons_read+0x13>
	if (c < 0)
  802039:	85 c0                	test   %eax,%eax
  80203b:	78 16                	js     802053 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80203d:	83 f8 04             	cmp    $0x4,%eax
  802040:	74 0c                	je     80204e <devcons_read+0x38>
	*(char*)vbuf = c;
  802042:	8b 55 0c             	mov    0xc(%ebp),%edx
  802045:	88 02                	mov    %al,(%edx)
	return 1;
  802047:	b8 01 00 00 00       	mov    $0x1,%eax
  80204c:	eb 05                	jmp    802053 <devcons_read+0x3d>
		return 0;
  80204e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802053:	c9                   	leave  
  802054:	c3                   	ret    

00802055 <cputchar>:
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80205b:	8b 45 08             	mov    0x8(%ebp),%eax
  80205e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802061:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802068:	00 
  802069:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80206c:	89 04 24             	mov    %eax,(%esp)
  80206f:	e8 e2 eb ff ff       	call   800c56 <sys_cputs>
}
  802074:	c9                   	leave  
  802075:	c3                   	ret    

00802076 <getchar>:
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80207c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802083:	00 
  802084:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802092:	e8 2e f6 ff ff       	call   8016c5 <read>
	if (r < 0)
  802097:	85 c0                	test   %eax,%eax
  802099:	78 0f                	js     8020aa <getchar+0x34>
	if (r < 1)
  80209b:	85 c0                	test   %eax,%eax
  80209d:	7e 06                	jle    8020a5 <getchar+0x2f>
	return c;
  80209f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020a3:	eb 05                	jmp    8020aa <getchar+0x34>
		return -E_EOF;
  8020a5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8020aa:	c9                   	leave  
  8020ab:	c3                   	ret    

008020ac <iscons>:
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bc:	89 04 24             	mov    %eax,(%esp)
  8020bf:	e8 72 f3 ff ff       	call   801436 <fd_lookup>
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	78 11                	js     8020d9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8020c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cb:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8020d1:	39 10                	cmp    %edx,(%eax)
  8020d3:	0f 94 c0             	sete   %al
  8020d6:	0f b6 c0             	movzbl %al,%eax
}
  8020d9:	c9                   	leave  
  8020da:	c3                   	ret    

008020db <opencons>:
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e4:	89 04 24             	mov    %eax,(%esp)
  8020e7:	e8 fb f2 ff ff       	call   8013e7 <fd_alloc>
		return r;
  8020ec:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	78 40                	js     802132 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020f9:	00 
  8020fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802108:	e8 16 ec ff ff       	call   800d23 <sys_page_alloc>
		return r;
  80210d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80210f:	85 c0                	test   %eax,%eax
  802111:	78 1f                	js     802132 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802113:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802119:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80211e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802121:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802128:	89 04 24             	mov    %eax,(%esp)
  80212b:	e8 90 f2 ff ff       	call   8013c0 <fd2num>
  802130:	89 c2                	mov    %eax,%edx
}
  802132:	89 d0                	mov    %edx,%eax
  802134:	c9                   	leave  
  802135:	c3                   	ret    

00802136 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802136:	55                   	push   %ebp
  802137:	89 e5                	mov    %esp,%ebp
  802139:	56                   	push   %esi
  80213a:	53                   	push   %ebx
  80213b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80213e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802141:	8b 35 08 30 80 00    	mov    0x803008,%esi
  802147:	e8 99 eb ff ff       	call   800ce5 <sys_getenvid>
  80214c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80214f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802153:	8b 55 08             	mov    0x8(%ebp),%edx
  802156:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80215a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80215e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802162:	c7 04 24 74 2b 80 00 	movl   $0x802b74,(%esp)
  802169:	e8 76 e1 ff ff       	call   8002e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80216e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802172:	8b 45 10             	mov    0x10(%ebp),%eax
  802175:	89 04 24             	mov    %eax,(%esp)
  802178:	e8 06 e1 ff ff       	call   800283 <vcprintf>
	cprintf("\n");
  80217d:	c7 04 24 61 2b 80 00 	movl   $0x802b61,(%esp)
  802184:	e8 5b e1 ff ff       	call   8002e4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802189:	cc                   	int3   
  80218a:	eb fd                	jmp    802189 <_panic+0x53>

0080218c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  802192:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802199:	75 70                	jne    80220b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  80219b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021a2:	00 
  8021a3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021aa:	ee 
  8021ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b2:	e8 6c eb ff ff       	call   800d23 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  8021b7:	85 c0                	test   %eax,%eax
  8021b9:	79 1c                	jns    8021d7 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  8021bb:	c7 44 24 08 98 2b 80 	movl   $0x802b98,0x8(%esp)
  8021c2:	00 
  8021c3:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8021ca:	00 
  8021cb:	c7 04 24 f4 2b 80 00 	movl   $0x802bf4,(%esp)
  8021d2:	e8 5f ff ff ff       	call   802136 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  8021d7:	c7 44 24 04 15 22 80 	movl   $0x802215,0x4(%esp)
  8021de:	00 
  8021df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e6:	e8 d8 ec ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8021eb:	85 c0                	test   %eax,%eax
  8021ed:	79 1c                	jns    80220b <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  8021ef:	c7 44 24 08 c0 2b 80 	movl   $0x802bc0,0x8(%esp)
  8021f6:	00 
  8021f7:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8021fe:	00 
  8021ff:	c7 04 24 f4 2b 80 00 	movl   $0x802bf4,(%esp)
  802206:	e8 2b ff ff ff       	call   802136 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802215:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802216:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80221b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80221d:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  802220:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  802224:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802228:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  80222a:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  80222c:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  80222d:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  802230:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  802232:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  802235:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802236:	83 c4 04             	add    $0x4,%esp
    popf;
  802239:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  80223a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  80223b:	c3                   	ret    

0080223c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802242:	89 d0                	mov    %edx,%eax
  802244:	c1 e8 16             	shr    $0x16,%eax
  802247:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80224e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802253:	f6 c1 01             	test   $0x1,%cl
  802256:	74 1d                	je     802275 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802258:	c1 ea 0c             	shr    $0xc,%edx
  80225b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802262:	f6 c2 01             	test   $0x1,%dl
  802265:	74 0e                	je     802275 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802267:	c1 ea 0c             	shr    $0xc,%edx
  80226a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802271:	ef 
  802272:	0f b7 c0             	movzwl %ax,%eax
}
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    
  802277:	66 90                	xchg   %ax,%ax
  802279:	66 90                	xchg   %ax,%ax
  80227b:	66 90                	xchg   %ax,%ax
  80227d:	66 90                	xchg   %ax,%ax
  80227f:	90                   	nop

00802280 <__udivdi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	83 ec 0c             	sub    $0xc,%esp
  802286:	8b 44 24 28          	mov    0x28(%esp),%eax
  80228a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80228e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802292:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802296:	85 c0                	test   %eax,%eax
  802298:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80229c:	89 ea                	mov    %ebp,%edx
  80229e:	89 0c 24             	mov    %ecx,(%esp)
  8022a1:	75 2d                	jne    8022d0 <__udivdi3+0x50>
  8022a3:	39 e9                	cmp    %ebp,%ecx
  8022a5:	77 61                	ja     802308 <__udivdi3+0x88>
  8022a7:	85 c9                	test   %ecx,%ecx
  8022a9:	89 ce                	mov    %ecx,%esi
  8022ab:	75 0b                	jne    8022b8 <__udivdi3+0x38>
  8022ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b2:	31 d2                	xor    %edx,%edx
  8022b4:	f7 f1                	div    %ecx
  8022b6:	89 c6                	mov    %eax,%esi
  8022b8:	31 d2                	xor    %edx,%edx
  8022ba:	89 e8                	mov    %ebp,%eax
  8022bc:	f7 f6                	div    %esi
  8022be:	89 c5                	mov    %eax,%ebp
  8022c0:	89 f8                	mov    %edi,%eax
  8022c2:	f7 f6                	div    %esi
  8022c4:	89 ea                	mov    %ebp,%edx
  8022c6:	83 c4 0c             	add    $0xc,%esp
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	39 e8                	cmp    %ebp,%eax
  8022d2:	77 24                	ja     8022f8 <__udivdi3+0x78>
  8022d4:	0f bd e8             	bsr    %eax,%ebp
  8022d7:	83 f5 1f             	xor    $0x1f,%ebp
  8022da:	75 3c                	jne    802318 <__udivdi3+0x98>
  8022dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022e0:	39 34 24             	cmp    %esi,(%esp)
  8022e3:	0f 86 9f 00 00 00    	jbe    802388 <__udivdi3+0x108>
  8022e9:	39 d0                	cmp    %edx,%eax
  8022eb:	0f 82 97 00 00 00    	jb     802388 <__udivdi3+0x108>
  8022f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	31 d2                	xor    %edx,%edx
  8022fa:	31 c0                	xor    %eax,%eax
  8022fc:	83 c4 0c             	add    $0xc,%esp
  8022ff:	5e                   	pop    %esi
  802300:	5f                   	pop    %edi
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    
  802303:	90                   	nop
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	89 f8                	mov    %edi,%eax
  80230a:	f7 f1                	div    %ecx
  80230c:	31 d2                	xor    %edx,%edx
  80230e:	83 c4 0c             	add    $0xc,%esp
  802311:	5e                   	pop    %esi
  802312:	5f                   	pop    %edi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    
  802315:	8d 76 00             	lea    0x0(%esi),%esi
  802318:	89 e9                	mov    %ebp,%ecx
  80231a:	8b 3c 24             	mov    (%esp),%edi
  80231d:	d3 e0                	shl    %cl,%eax
  80231f:	89 c6                	mov    %eax,%esi
  802321:	b8 20 00 00 00       	mov    $0x20,%eax
  802326:	29 e8                	sub    %ebp,%eax
  802328:	89 c1                	mov    %eax,%ecx
  80232a:	d3 ef                	shr    %cl,%edi
  80232c:	89 e9                	mov    %ebp,%ecx
  80232e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802332:	8b 3c 24             	mov    (%esp),%edi
  802335:	09 74 24 08          	or     %esi,0x8(%esp)
  802339:	89 d6                	mov    %edx,%esi
  80233b:	d3 e7                	shl    %cl,%edi
  80233d:	89 c1                	mov    %eax,%ecx
  80233f:	89 3c 24             	mov    %edi,(%esp)
  802342:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802346:	d3 ee                	shr    %cl,%esi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	d3 e2                	shl    %cl,%edx
  80234c:	89 c1                	mov    %eax,%ecx
  80234e:	d3 ef                	shr    %cl,%edi
  802350:	09 d7                	or     %edx,%edi
  802352:	89 f2                	mov    %esi,%edx
  802354:	89 f8                	mov    %edi,%eax
  802356:	f7 74 24 08          	divl   0x8(%esp)
  80235a:	89 d6                	mov    %edx,%esi
  80235c:	89 c7                	mov    %eax,%edi
  80235e:	f7 24 24             	mull   (%esp)
  802361:	39 d6                	cmp    %edx,%esi
  802363:	89 14 24             	mov    %edx,(%esp)
  802366:	72 30                	jb     802398 <__udivdi3+0x118>
  802368:	8b 54 24 04          	mov    0x4(%esp),%edx
  80236c:	89 e9                	mov    %ebp,%ecx
  80236e:	d3 e2                	shl    %cl,%edx
  802370:	39 c2                	cmp    %eax,%edx
  802372:	73 05                	jae    802379 <__udivdi3+0xf9>
  802374:	3b 34 24             	cmp    (%esp),%esi
  802377:	74 1f                	je     802398 <__udivdi3+0x118>
  802379:	89 f8                	mov    %edi,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	e9 7a ff ff ff       	jmp    8022fc <__udivdi3+0x7c>
  802382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802388:	31 d2                	xor    %edx,%edx
  80238a:	b8 01 00 00 00       	mov    $0x1,%eax
  80238f:	e9 68 ff ff ff       	jmp    8022fc <__udivdi3+0x7c>
  802394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802398:	8d 47 ff             	lea    -0x1(%edi),%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	83 c4 0c             	add    $0xc,%esp
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    
  8023a4:	66 90                	xchg   %ax,%ax
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	66 90                	xchg   %ax,%ax
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	83 ec 14             	sub    $0x14,%esp
  8023b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8023be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8023c2:	89 c7                	mov    %eax,%edi
  8023c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8023d0:	89 34 24             	mov    %esi,(%esp)
  8023d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023d7:	85 c0                	test   %eax,%eax
  8023d9:	89 c2                	mov    %eax,%edx
  8023db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023df:	75 17                	jne    8023f8 <__umoddi3+0x48>
  8023e1:	39 fe                	cmp    %edi,%esi
  8023e3:	76 4b                	jbe    802430 <__umoddi3+0x80>
  8023e5:	89 c8                	mov    %ecx,%eax
  8023e7:	89 fa                	mov    %edi,%edx
  8023e9:	f7 f6                	div    %esi
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	31 d2                	xor    %edx,%edx
  8023ef:	83 c4 14             	add    $0x14,%esp
  8023f2:	5e                   	pop    %esi
  8023f3:	5f                   	pop    %edi
  8023f4:	5d                   	pop    %ebp
  8023f5:	c3                   	ret    
  8023f6:	66 90                	xchg   %ax,%ax
  8023f8:	39 f8                	cmp    %edi,%eax
  8023fa:	77 54                	ja     802450 <__umoddi3+0xa0>
  8023fc:	0f bd e8             	bsr    %eax,%ebp
  8023ff:	83 f5 1f             	xor    $0x1f,%ebp
  802402:	75 5c                	jne    802460 <__umoddi3+0xb0>
  802404:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802408:	39 3c 24             	cmp    %edi,(%esp)
  80240b:	0f 87 e7 00 00 00    	ja     8024f8 <__umoddi3+0x148>
  802411:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802415:	29 f1                	sub    %esi,%ecx
  802417:	19 c7                	sbb    %eax,%edi
  802419:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80241d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802421:	8b 44 24 08          	mov    0x8(%esp),%eax
  802425:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802429:	83 c4 14             	add    $0x14,%esp
  80242c:	5e                   	pop    %esi
  80242d:	5f                   	pop    %edi
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    
  802430:	85 f6                	test   %esi,%esi
  802432:	89 f5                	mov    %esi,%ebp
  802434:	75 0b                	jne    802441 <__umoddi3+0x91>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f6                	div    %esi
  80243f:	89 c5                	mov    %eax,%ebp
  802441:	8b 44 24 04          	mov    0x4(%esp),%eax
  802445:	31 d2                	xor    %edx,%edx
  802447:	f7 f5                	div    %ebp
  802449:	89 c8                	mov    %ecx,%eax
  80244b:	f7 f5                	div    %ebp
  80244d:	eb 9c                	jmp    8023eb <__umoddi3+0x3b>
  80244f:	90                   	nop
  802450:	89 c8                	mov    %ecx,%eax
  802452:	89 fa                	mov    %edi,%edx
  802454:	83 c4 14             	add    $0x14,%esp
  802457:	5e                   	pop    %esi
  802458:	5f                   	pop    %edi
  802459:	5d                   	pop    %ebp
  80245a:	c3                   	ret    
  80245b:	90                   	nop
  80245c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802460:	8b 04 24             	mov    (%esp),%eax
  802463:	be 20 00 00 00       	mov    $0x20,%esi
  802468:	89 e9                	mov    %ebp,%ecx
  80246a:	29 ee                	sub    %ebp,%esi
  80246c:	d3 e2                	shl    %cl,%edx
  80246e:	89 f1                	mov    %esi,%ecx
  802470:	d3 e8                	shr    %cl,%eax
  802472:	89 e9                	mov    %ebp,%ecx
  802474:	89 44 24 04          	mov    %eax,0x4(%esp)
  802478:	8b 04 24             	mov    (%esp),%eax
  80247b:	09 54 24 04          	or     %edx,0x4(%esp)
  80247f:	89 fa                	mov    %edi,%edx
  802481:	d3 e0                	shl    %cl,%eax
  802483:	89 f1                	mov    %esi,%ecx
  802485:	89 44 24 08          	mov    %eax,0x8(%esp)
  802489:	8b 44 24 10          	mov    0x10(%esp),%eax
  80248d:	d3 ea                	shr    %cl,%edx
  80248f:	89 e9                	mov    %ebp,%ecx
  802491:	d3 e7                	shl    %cl,%edi
  802493:	89 f1                	mov    %esi,%ecx
  802495:	d3 e8                	shr    %cl,%eax
  802497:	89 e9                	mov    %ebp,%ecx
  802499:	09 f8                	or     %edi,%eax
  80249b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80249f:	f7 74 24 04          	divl   0x4(%esp)
  8024a3:	d3 e7                	shl    %cl,%edi
  8024a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024a9:	89 d7                	mov    %edx,%edi
  8024ab:	f7 64 24 08          	mull   0x8(%esp)
  8024af:	39 d7                	cmp    %edx,%edi
  8024b1:	89 c1                	mov    %eax,%ecx
  8024b3:	89 14 24             	mov    %edx,(%esp)
  8024b6:	72 2c                	jb     8024e4 <__umoddi3+0x134>
  8024b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8024bc:	72 22                	jb     8024e0 <__umoddi3+0x130>
  8024be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024c2:	29 c8                	sub    %ecx,%eax
  8024c4:	19 d7                	sbb    %edx,%edi
  8024c6:	89 e9                	mov    %ebp,%ecx
  8024c8:	89 fa                	mov    %edi,%edx
  8024ca:	d3 e8                	shr    %cl,%eax
  8024cc:	89 f1                	mov    %esi,%ecx
  8024ce:	d3 e2                	shl    %cl,%edx
  8024d0:	89 e9                	mov    %ebp,%ecx
  8024d2:	d3 ef                	shr    %cl,%edi
  8024d4:	09 d0                	or     %edx,%eax
  8024d6:	89 fa                	mov    %edi,%edx
  8024d8:	83 c4 14             	add    $0x14,%esp
  8024db:	5e                   	pop    %esi
  8024dc:	5f                   	pop    %edi
  8024dd:	5d                   	pop    %ebp
  8024de:	c3                   	ret    
  8024df:	90                   	nop
  8024e0:	39 d7                	cmp    %edx,%edi
  8024e2:	75 da                	jne    8024be <__umoddi3+0x10e>
  8024e4:	8b 14 24             	mov    (%esp),%edx
  8024e7:	89 c1                	mov    %eax,%ecx
  8024e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8024ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8024f1:	eb cb                	jmp    8024be <__umoddi3+0x10e>
  8024f3:	90                   	nop
  8024f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8024fc:	0f 82 0f ff ff ff    	jb     802411 <__umoddi3+0x61>
  802502:	e9 1a ff ff ff       	jmp    802421 <__umoddi3+0x71>
