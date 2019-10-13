
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 e4 02 00 00       	call   800315 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 c0 	movl   $0x8026c0,0x803004
  800042:	26 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 18 1e 00 00       	call   801e68 <pipe>
  800050:	89 c6                	mov    %eax,%esi
  800052:	85 c0                	test   %eax,%eax
  800054:	79 20                	jns    800076 <umain+0x43>
		panic("pipe: %e", i);
  800056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005a:	c7 44 24 08 cc 26 80 	movl   $0x8026cc,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 d5 26 80 00 	movl   $0x8026d5,(%esp)
  800071:	e8 00 03 00 00       	call   800376 <_panic>

	if ((pid = fork()) < 0)
  800076:	e8 c7 11 00 00       	call   801242 <fork>
  80007b:	89 c3                	mov    %eax,%ebx
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <umain+0x6e>
		panic("fork: %e", i);
  800081:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800085:	c7 44 24 08 e5 26 80 	movl   $0x8026e5,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 d5 26 80 00 	movl   $0x8026d5,(%esp)
  80009c:	e8 d5 02 00 00       	call   800376 <_panic>

	if (pid == 0) {
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	0f 85 d5 00 00 00    	jne    80017e <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ae:	8b 40 48             	mov    0x48(%eax),%eax
  8000b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bc:	c7 04 24 ee 26 80 00 	movl   $0x8026ee,(%esp)
  8000c3:	e8 a7 03 00 00       	call   80046f <cprintf>
		close(p[1]);
  8000c8:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cb:	89 04 24             	mov    %eax,(%esp)
  8000ce:	e8 0f 15 00 00       	call   8015e2 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d8:	8b 40 48             	mov    0x48(%eax),%eax
  8000db:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000de:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e6:	c7 04 24 0b 27 80 00 	movl   $0x80270b,(%esp)
  8000ed:	e8 7d 03 00 00       	call   80046f <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f2:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000f9:	00 
  8000fa:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800104:	89 04 24             	mov    %eax,(%esp)
  800107:	e8 cb 16 00 00       	call   8017d7 <readn>
  80010c:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	79 20                	jns    800132 <umain+0xff>
			panic("read: %e", i);
  800112:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800116:	c7 44 24 08 28 27 80 	movl   $0x802728,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 d5 26 80 00 	movl   $0x8026d5,(%esp)
  80012d:	e8 44 02 00 00       	call   800376 <_panic>
		buf[i] = 0;
  800132:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800137:	a1 00 30 80 00       	mov    0x803000,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 01 0a 00 00       	call   800b4c <strcmp>
  80014b:	85 c0                	test   %eax,%eax
  80014d:	75 0e                	jne    80015d <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  80014f:	c7 04 24 31 27 80 00 	movl   $0x802731,(%esp)
  800156:	e8 14 03 00 00       	call   80046f <cprintf>
  80015b:	eb 17                	jmp    800174 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800160:	89 44 24 08          	mov    %eax,0x8(%esp)
  800164:	89 74 24 04          	mov    %esi,0x4(%esp)
  800168:	c7 04 24 4d 27 80 00 	movl   $0x80274d,(%esp)
  80016f:	e8 fb 02 00 00       	call   80046f <cprintf>
		exit();
  800174:	e8 e4 01 00 00       	call   80035d <exit>
  800179:	e9 ac 00 00 00       	jmp    80022a <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017e:	a1 08 40 80 00       	mov    0x804008,%eax
  800183:	8b 40 48             	mov    0x48(%eax),%eax
  800186:	8b 55 8c             	mov    -0x74(%ebp),%edx
  800189:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	c7 04 24 ee 26 80 00 	movl   $0x8026ee,(%esp)
  800198:	e8 d2 02 00 00       	call   80046f <cprintf>
		close(p[0]);
  80019d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 3a 14 00 00       	call   8015e2 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8001ad:	8b 40 48             	mov    0x48(%eax),%eax
  8001b0:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  8001c2:	e8 a8 02 00 00       	call   80046f <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c7:	a1 00 30 80 00       	mov    0x803000,%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 8c 08 00 00       	call   800a60 <strlen>
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	a1 00 30 80 00       	mov    0x803000,%eax
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 36 16 00 00       	call   801822 <write>
  8001ec:	89 c6                	mov    %eax,%esi
  8001ee:	a1 00 30 80 00       	mov    0x803000,%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 65 08 00 00       	call   800a60 <strlen>
  8001fb:	39 c6                	cmp    %eax,%esi
  8001fd:	74 20                	je     80021f <umain+0x1ec>
			panic("write: %e", i);
  8001ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800203:	c7 44 24 08 7d 27 80 	movl   $0x80277d,0x8(%esp)
  80020a:	00 
  80020b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800212:	00 
  800213:	c7 04 24 d5 26 80 00 	movl   $0x8026d5,(%esp)
  80021a:	e8 57 01 00 00       	call   800376 <_panic>
		close(p[1]);
  80021f:	8b 45 90             	mov    -0x70(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	e8 b8 13 00 00       	call   8015e2 <close>
	}
	wait(pid);
  80022a:	89 1c 24             	mov    %ebx,(%esp)
  80022d:	e8 dc 1d 00 00       	call   80200e <wait>

	binaryname = "pipewriteeof";
  800232:	c7 05 04 30 80 00 87 	movl   $0x802787,0x803004
  800239:	27 80 00 
	if ((i = pipe(p)) < 0)
  80023c:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	e8 21 1c 00 00       	call   801e68 <pipe>
  800247:	89 c6                	mov    %eax,%esi
  800249:	85 c0                	test   %eax,%eax
  80024b:	79 20                	jns    80026d <umain+0x23a>
		panic("pipe: %e", i);
  80024d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800251:	c7 44 24 08 cc 26 80 	movl   $0x8026cc,0x8(%esp)
  800258:	00 
  800259:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800260:	00 
  800261:	c7 04 24 d5 26 80 00 	movl   $0x8026d5,(%esp)
  800268:	e8 09 01 00 00       	call   800376 <_panic>

	if ((pid = fork()) < 0)
  80026d:	e8 d0 0f 00 00       	call   801242 <fork>
  800272:	89 c3                	mov    %eax,%ebx
  800274:	85 c0                	test   %eax,%eax
  800276:	79 20                	jns    800298 <umain+0x265>
		panic("fork: %e", i);
  800278:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027c:	c7 44 24 08 e5 26 80 	movl   $0x8026e5,0x8(%esp)
  800283:	00 
  800284:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028b:	00 
  80028c:	c7 04 24 d5 26 80 00 	movl   $0x8026d5,(%esp)
  800293:	e8 de 00 00 00       	call   800376 <_panic>

	if (pid == 0) {
  800298:	85 c0                	test   %eax,%eax
  80029a:	75 48                	jne    8002e4 <umain+0x2b1>
		close(p[0]);
  80029c:	8b 45 8c             	mov    -0x74(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 3b 13 00 00       	call   8015e2 <close>
		while (1) {
			cprintf(".");
  8002a7:	c7 04 24 94 27 80 00 	movl   $0x802794,(%esp)
  8002ae:	e8 bc 01 00 00       	call   80046f <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002ba:	00 
  8002bb:	c7 44 24 04 96 27 80 	movl   $0x802796,0x4(%esp)
  8002c2:	00 
  8002c3:	8b 55 90             	mov    -0x70(%ebp),%edx
  8002c6:	89 14 24             	mov    %edx,(%esp)
  8002c9:	e8 54 15 00 00       	call   801822 <write>
  8002ce:	83 f8 01             	cmp    $0x1,%eax
  8002d1:	74 d4                	je     8002a7 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d3:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  8002da:	e8 90 01 00 00       	call   80046f <cprintf>
		exit();
  8002df:	e8 79 00 00 00       	call   80035d <exit>
	}
	close(p[0]);
  8002e4:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	e8 f3 12 00 00       	call   8015e2 <close>
	close(p[1]);
  8002ef:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	e8 e8 12 00 00       	call   8015e2 <close>
	wait(pid);
  8002fa:	89 1c 24             	mov    %ebx,(%esp)
  8002fd:	e8 0c 1d 00 00       	call   80200e <wait>

	cprintf("pipe tests passed\n");
  800302:	c7 04 24 b5 27 80 00 	movl   $0x8027b5,(%esp)
  800309:	e8 61 01 00 00       	call   80046f <cprintf>
}
  80030e:	83 ec 80             	sub    $0xffffff80,%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 10             	sub    $0x10,%esp
  80031d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800320:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800323:	e8 4d 0b 00 00       	call   800e75 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800328:	25 ff 03 00 00       	and    $0x3ff,%eax
  80032d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800330:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800335:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80033a:	85 db                	test   %ebx,%ebx
  80033c:	7e 07                	jle    800345 <libmain+0x30>
		binaryname = argv[0];
  80033e:	8b 06                	mov    (%esi),%eax
  800340:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800345:	89 74 24 04          	mov    %esi,0x4(%esp)
  800349:	89 1c 24             	mov    %ebx,(%esp)
  80034c:	e8 e2 fc ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800351:	e8 07 00 00 00       	call   80035d <exit>
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800363:	e8 ad 12 00 00       	call   801615 <close_all>
	sys_env_destroy(0);
  800368:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80036f:	e8 af 0a 00 00       	call   800e23 <sys_env_destroy>
}
  800374:	c9                   	leave  
  800375:	c3                   	ret    

00800376 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
  80037b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80037e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800381:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800387:	e8 e9 0a 00 00       	call   800e75 <sys_getenvid>
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800393:	8b 55 08             	mov    0x8(%ebp),%edx
  800396:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80039a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80039e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a2:	c7 04 24 18 28 80 00 	movl   $0x802818,(%esp)
  8003a9:	e8 c1 00 00 00       	call   80046f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b5:	89 04 24             	mov    %eax,(%esp)
  8003b8:	e8 51 00 00 00       	call   80040e <vcprintf>
	cprintf("\n");
  8003bd:	c7 04 24 09 27 80 00 	movl   $0x802709,(%esp)
  8003c4:	e8 a6 00 00 00       	call   80046f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c9:	cc                   	int3   
  8003ca:	eb fd                	jmp    8003c9 <_panic+0x53>

008003cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 14             	sub    $0x14,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d6:	8b 13                	mov    (%ebx),%edx
  8003d8:	8d 42 01             	lea    0x1(%edx),%eax
  8003db:	89 03                	mov    %eax,(%ebx)
  8003dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e9:	75 19                	jne    800404 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003f2:	00 
  8003f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f6:	89 04 24             	mov    %eax,(%esp)
  8003f9:	e8 e8 09 00 00       	call   800de6 <sys_cputs>
		b->idx = 0;
  8003fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800404:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800408:	83 c4 14             	add    $0x14,%esp
  80040b:	5b                   	pop    %ebx
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800417:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80041e:	00 00 00 
	b.cnt = 0;
  800421:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800428:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	89 44 24 08          	mov    %eax,0x8(%esp)
  800439:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80043f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800443:	c7 04 24 cc 03 80 00 	movl   $0x8003cc,(%esp)
  80044a:	e8 af 01 00 00       	call   8005fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80044f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800455:	89 44 24 04          	mov    %eax,0x4(%esp)
  800459:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80045f:	89 04 24             	mov    %eax,(%esp)
  800462:	e8 7f 09 00 00       	call   800de6 <sys_cputs>

	return b.cnt;
}
  800467:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80046d:	c9                   	leave  
  80046e:	c3                   	ret    

0080046f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800475:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047c:	8b 45 08             	mov    0x8(%ebp),%eax
  80047f:	89 04 24             	mov    %eax,(%esp)
  800482:	e8 87 ff ff ff       	call   80040e <vcprintf>
	va_end(ap);

	return cnt;
}
  800487:	c9                   	leave  
  800488:	c3                   	ret    
  800489:	66 90                	xchg   %ax,%ax
  80048b:	66 90                	xchg   %ax,%ax
  80048d:	66 90                	xchg   %ax,%ax
  80048f:	90                   	nop

00800490 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 3c             	sub    $0x3c,%esp
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049c:	89 d7                	mov    %edx,%edi
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 c3                	mov    %eax,%ebx
  8004a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8004af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004bd:	39 d9                	cmp    %ebx,%ecx
  8004bf:	72 05                	jb     8004c6 <printnum+0x36>
  8004c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004c4:	77 69                	ja     80052f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	89 d6                	mov    %edx,%esi
  8004e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	e8 1c 1f 00 00       	call   802420 <__udivdi3>
  800504:	89 d9                	mov    %ebx,%ecx
  800506:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80050a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	89 54 24 04          	mov    %edx,0x4(%esp)
  800515:	89 fa                	mov    %edi,%edx
  800517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051a:	e8 71 ff ff ff       	call   800490 <printnum>
  80051f:	eb 1b                	jmp    80053c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800521:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800525:	8b 45 18             	mov    0x18(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	ff d3                	call   *%ebx
  80052d:	eb 03                	jmp    800532 <printnum+0xa2>
  80052f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800532:	83 ee 01             	sub    $0x1,%esi
  800535:	85 f6                	test   %esi,%esi
  800537:	7f e8                	jg     800521 <printnum+0x91>
  800539:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80053c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800540:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800544:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800547:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80054a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	e8 ec 1f 00 00       	call   802550 <__umoddi3>
  800564:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800568:	0f be 80 3b 28 80 00 	movsbl 0x80283b(%eax),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800575:	ff d0                	call   *%eax
}
  800577:	83 c4 3c             	add    $0x3c,%esp
  80057a:	5b                   	pop    %ebx
  80057b:	5e                   	pop    %esi
  80057c:	5f                   	pop    %edi
  80057d:	5d                   	pop    %ebp
  80057e:	c3                   	ret    

0080057f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800582:	83 fa 01             	cmp    $0x1,%edx
  800585:	7e 0e                	jle    800595 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800587:	8b 10                	mov    (%eax),%edx
  800589:	8d 4a 08             	lea    0x8(%edx),%ecx
  80058c:	89 08                	mov    %ecx,(%eax)
  80058e:	8b 02                	mov    (%edx),%eax
  800590:	8b 52 04             	mov    0x4(%edx),%edx
  800593:	eb 22                	jmp    8005b7 <getuint+0x38>
	else if (lflag)
  800595:	85 d2                	test   %edx,%edx
  800597:	74 10                	je     8005a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80059e:	89 08                	mov    %ecx,(%eax)
  8005a0:	8b 02                	mov    (%edx),%eax
  8005a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a7:	eb 0e                	jmp    8005b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ae:	89 08                	mov    %ecx,(%eax)
  8005b0:	8b 02                	mov    (%edx),%eax
  8005b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005b7:	5d                   	pop    %ebp
  8005b8:	c3                   	ret    

008005b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b9:	55                   	push   %ebp
  8005ba:	89 e5                	mov    %esp,%ebp
  8005bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005c3:	8b 10                	mov    (%eax),%edx
  8005c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8005c8:	73 0a                	jae    8005d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005cd:	89 08                	mov    %ecx,(%eax)
  8005cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d2:	88 02                	mov    %al,(%edx)
}
  8005d4:	5d                   	pop    %ebp
  8005d5:	c3                   	ret    

008005d6 <printfmt>:
{
  8005d6:	55                   	push   %ebp
  8005d7:	89 e5                	mov    %esp,%ebp
  8005d9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8005dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	e8 02 00 00 00       	call   8005fe <vprintfmt>
}
  8005fc:	c9                   	leave  
  8005fd:	c3                   	ret    

008005fe <vprintfmt>:
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	57                   	push   %edi
  800602:	56                   	push   %esi
  800603:	53                   	push   %ebx
  800604:	83 ec 3c             	sub    $0x3c,%esp
  800607:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80060a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80060d:	eb 1f                	jmp    80062e <vprintfmt+0x30>
			if (ch == '\0'){
  80060f:	85 c0                	test   %eax,%eax
  800611:	75 0f                	jne    800622 <vprintfmt+0x24>
				color = 0x0100;
  800613:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80061a:	01 00 00 
  80061d:	e9 b3 03 00 00       	jmp    8009d5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800622:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80062c:	89 f3                	mov    %esi,%ebx
  80062e:	8d 73 01             	lea    0x1(%ebx),%esi
  800631:	0f b6 03             	movzbl (%ebx),%eax
  800634:	83 f8 25             	cmp    $0x25,%eax
  800637:	75 d6                	jne    80060f <vprintfmt+0x11>
  800639:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80063d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800644:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80064b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800652:	ba 00 00 00 00       	mov    $0x0,%edx
  800657:	eb 1d                	jmp    800676 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800659:	89 de                	mov    %ebx,%esi
			padc = '-';
  80065b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80065f:	eb 15                	jmp    800676 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800661:	89 de                	mov    %ebx,%esi
			padc = '0';
  800663:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800667:	eb 0d                	jmp    800676 <vprintfmt+0x78>
				width = precision, precision = -1;
  800669:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80066c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80066f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8d 5e 01             	lea    0x1(%esi),%ebx
  800679:	0f b6 0e             	movzbl (%esi),%ecx
  80067c:	0f b6 c1             	movzbl %cl,%eax
  80067f:	83 e9 23             	sub    $0x23,%ecx
  800682:	80 f9 55             	cmp    $0x55,%cl
  800685:	0f 87 2a 03 00 00    	ja     8009b5 <vprintfmt+0x3b7>
  80068b:	0f b6 c9             	movzbl %cl,%ecx
  80068e:	ff 24 8d 80 29 80 00 	jmp    *0x802980(,%ecx,4)
  800695:	89 de                	mov    %ebx,%esi
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80069c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80069f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006a3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006a6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006a9:	83 fb 09             	cmp    $0x9,%ebx
  8006ac:	77 36                	ja     8006e4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8006ae:	83 c6 01             	add    $0x1,%esi
			}
  8006b1:	eb e9                	jmp    80069c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8006b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8006c3:	eb 22                	jmp    8006e7 <vprintfmt+0xe9>
  8006c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cf:	0f 49 c1             	cmovns %ecx,%eax
  8006d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006d5:	89 de                	mov    %ebx,%esi
  8006d7:	eb 9d                	jmp    800676 <vprintfmt+0x78>
  8006d9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8006db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8006e2:	eb 92                	jmp    800676 <vprintfmt+0x78>
  8006e4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8006e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006eb:	79 89                	jns    800676 <vprintfmt+0x78>
  8006ed:	e9 77 ff ff ff       	jmp    800669 <vprintfmt+0x6b>
			lflag++;
  8006f2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8006f7:	e9 7a ff ff ff       	jmp    800676 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800709:	8b 00                	mov    (%eax),%eax
  80070b:	89 04 24             	mov    %eax,(%esp)
  80070e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800711:	e9 18 ff ff ff       	jmp    80062e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 50 04             	lea    0x4(%eax),%edx
  80071c:	89 55 14             	mov    %edx,0x14(%ebp)
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	99                   	cltd   
  800722:	31 d0                	xor    %edx,%eax
  800724:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800726:	83 f8 0f             	cmp    $0xf,%eax
  800729:	7f 0b                	jg     800736 <vprintfmt+0x138>
  80072b:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800732:	85 d2                	test   %edx,%edx
  800734:	75 20                	jne    800756 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800736:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073a:	c7 44 24 08 53 28 80 	movl   $0x802853,0x8(%esp)
  800741:	00 
  800742:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800746:	8b 45 08             	mov    0x8(%ebp),%eax
  800749:	89 04 24             	mov    %eax,(%esp)
  80074c:	e8 85 fe ff ff       	call   8005d6 <printfmt>
  800751:	e9 d8 fe ff ff       	jmp    80062e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800756:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80075a:	c7 44 24 08 9a 2d 80 	movl   $0x802d9a,0x8(%esp)
  800761:	00 
  800762:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	89 04 24             	mov    %eax,(%esp)
  80076c:	e8 65 fe ff ff       	call   8005d6 <printfmt>
  800771:	e9 b8 fe ff ff       	jmp    80062e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800779:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80077c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80078a:	85 f6                	test   %esi,%esi
  80078c:	b8 4c 28 80 00       	mov    $0x80284c,%eax
  800791:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800794:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800798:	0f 84 97 00 00 00    	je     800835 <vprintfmt+0x237>
  80079e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007a2:	0f 8e 9b 00 00 00    	jle    800843 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ac:	89 34 24             	mov    %esi,(%esp)
  8007af:	e8 c4 02 00 00       	call   800a78 <strnlen>
  8007b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007b7:	29 c2                	sub    %eax,%edx
  8007b9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8007bc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007c3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007cc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ce:	eb 0f                	jmp    8007df <vprintfmt+0x1e1>
					putch(padc, putdat);
  8007d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8007dc:	83 eb 01             	sub    $0x1,%ebx
  8007df:	85 db                	test   %ebx,%ebx
  8007e1:	7f ed                	jg     8007d0 <vprintfmt+0x1d2>
  8007e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007e6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f0:	0f 49 c2             	cmovns %edx,%eax
  8007f3:	29 c2                	sub    %eax,%edx
  8007f5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007f8:	89 d7                	mov    %edx,%edi
  8007fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007fd:	eb 50                	jmp    80084f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8007ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800803:	74 1e                	je     800823 <vprintfmt+0x225>
  800805:	0f be d2             	movsbl %dl,%edx
  800808:	83 ea 20             	sub    $0x20,%edx
  80080b:	83 fa 5e             	cmp    $0x5e,%edx
  80080e:	76 13                	jbe    800823 <vprintfmt+0x225>
					putch('?', putdat);
  800810:	8b 45 0c             	mov    0xc(%ebp),%eax
  800813:	89 44 24 04          	mov    %eax,0x4(%esp)
  800817:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80081e:	ff 55 08             	call   *0x8(%ebp)
  800821:	eb 0d                	jmp    800830 <vprintfmt+0x232>
					putch(ch, putdat);
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
  800826:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082a:	89 04 24             	mov    %eax,(%esp)
  80082d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800830:	83 ef 01             	sub    $0x1,%edi
  800833:	eb 1a                	jmp    80084f <vprintfmt+0x251>
  800835:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800838:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80083b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80083e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800841:	eb 0c                	jmp    80084f <vprintfmt+0x251>
  800843:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800846:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800849:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80084c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80084f:	83 c6 01             	add    $0x1,%esi
  800852:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800856:	0f be c2             	movsbl %dl,%eax
  800859:	85 c0                	test   %eax,%eax
  80085b:	74 27                	je     800884 <vprintfmt+0x286>
  80085d:	85 db                	test   %ebx,%ebx
  80085f:	78 9e                	js     8007ff <vprintfmt+0x201>
  800861:	83 eb 01             	sub    $0x1,%ebx
  800864:	79 99                	jns    8007ff <vprintfmt+0x201>
  800866:	89 f8                	mov    %edi,%eax
  800868:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	89 c3                	mov    %eax,%ebx
  800870:	eb 1a                	jmp    80088c <vprintfmt+0x28e>
				putch(' ', putdat);
  800872:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800876:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80087d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80087f:	83 eb 01             	sub    $0x1,%ebx
  800882:	eb 08                	jmp    80088c <vprintfmt+0x28e>
  800884:	89 fb                	mov    %edi,%ebx
  800886:	8b 75 08             	mov    0x8(%ebp),%esi
  800889:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80088c:	85 db                	test   %ebx,%ebx
  80088e:	7f e2                	jg     800872 <vprintfmt+0x274>
  800890:	89 75 08             	mov    %esi,0x8(%ebp)
  800893:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800896:	e9 93 fd ff ff       	jmp    80062e <vprintfmt+0x30>
	if (lflag >= 2)
  80089b:	83 fa 01             	cmp    $0x1,%edx
  80089e:	7e 16                	jle    8008b6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8008a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a3:	8d 50 08             	lea    0x8(%eax),%edx
  8008a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a9:	8b 50 04             	mov    0x4(%eax),%edx
  8008ac:	8b 00                	mov    (%eax),%eax
  8008ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008b4:	eb 32                	jmp    8008e8 <vprintfmt+0x2ea>
	else if (lflag)
  8008b6:	85 d2                	test   %edx,%edx
  8008b8:	74 18                	je     8008d2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	8d 50 04             	lea    0x4(%eax),%edx
  8008c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c3:	8b 30                	mov    (%eax),%esi
  8008c5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008c8:	89 f0                	mov    %esi,%eax
  8008ca:	c1 f8 1f             	sar    $0x1f,%eax
  8008cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008d0:	eb 16                	jmp    8008e8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8d 50 04             	lea    0x4(%eax),%edx
  8008d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008db:	8b 30                	mov    (%eax),%esi
  8008dd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008e0:	89 f0                	mov    %esi,%eax
  8008e2:	c1 f8 1f             	sar    $0x1f,%eax
  8008e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8008e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8008ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8008f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008f7:	0f 89 80 00 00 00    	jns    80097d <vprintfmt+0x37f>
				putch('-', putdat);
  8008fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800901:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800908:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80090b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80090e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800911:	f7 d8                	neg    %eax
  800913:	83 d2 00             	adc    $0x0,%edx
  800916:	f7 da                	neg    %edx
			base = 10;
  800918:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80091d:	eb 5e                	jmp    80097d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 58 fc ff ff       	call   80057f <getuint>
			base = 10;
  800927:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80092c:	eb 4f                	jmp    80097d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80092e:	8d 45 14             	lea    0x14(%ebp),%eax
  800931:	e8 49 fc ff ff       	call   80057f <getuint>
            base = 8;
  800936:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80093b:	eb 40                	jmp    80097d <vprintfmt+0x37f>
			putch('0', putdat);
  80093d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800941:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800948:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80094b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80094f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800956:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800959:	8b 45 14             	mov    0x14(%ebp),%eax
  80095c:	8d 50 04             	lea    0x4(%eax),%edx
  80095f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800962:	8b 00                	mov    (%eax),%eax
  800964:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800969:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80096e:	eb 0d                	jmp    80097d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800970:	8d 45 14             	lea    0x14(%ebp),%eax
  800973:	e8 07 fc ff ff       	call   80057f <getuint>
			base = 16;
  800978:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80097d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800981:	89 74 24 10          	mov    %esi,0x10(%esp)
  800985:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800988:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80098c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800990:	89 04 24             	mov    %eax,(%esp)
  800993:	89 54 24 04          	mov    %edx,0x4(%esp)
  800997:	89 fa                	mov    %edi,%edx
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	e8 ef fa ff ff       	call   800490 <printnum>
			break;
  8009a1:	e9 88 fc ff ff       	jmp    80062e <vprintfmt+0x30>
			putch(ch, putdat);
  8009a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009aa:	89 04 24             	mov    %eax,(%esp)
  8009ad:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009b0:	e9 79 fc ff ff       	jmp    80062e <vprintfmt+0x30>
			putch('%', putdat);
  8009b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c3:	89 f3                	mov    %esi,%ebx
  8009c5:	eb 03                	jmp    8009ca <vprintfmt+0x3cc>
  8009c7:	83 eb 01             	sub    $0x1,%ebx
  8009ca:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009ce:	75 f7                	jne    8009c7 <vprintfmt+0x3c9>
  8009d0:	e9 59 fc ff ff       	jmp    80062e <vprintfmt+0x30>
}
  8009d5:	83 c4 3c             	add    $0x3c,%esp
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5f                   	pop    %edi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 28             	sub    $0x28,%esp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009fa:	85 c0                	test   %eax,%eax
  8009fc:	74 30                	je     800a2e <vsnprintf+0x51>
  8009fe:	85 d2                	test   %edx,%edx
  800a00:	7e 2c                	jle    800a2e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a02:	8b 45 14             	mov    0x14(%ebp),%eax
  800a05:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a09:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a10:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a17:	c7 04 24 b9 05 80 00 	movl   $0x8005b9,(%esp)
  800a1e:	e8 db fb ff ff       	call   8005fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a23:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a26:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a2c:	eb 05                	jmp    800a33 <vsnprintf+0x56>
		return -E_INVAL;
  800a2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a3b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a42:	8b 45 10             	mov    0x10(%ebp),%eax
  800a45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	89 04 24             	mov    %eax,(%esp)
  800a56:	e8 82 ff ff ff       	call   8009dd <vsnprintf>
	va_end(ap);

	return rc;
}
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    
  800a5d:	66 90                	xchg   %ax,%ax
  800a5f:	90                   	nop

00800a60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	eb 03                	jmp    800a70 <strlen+0x10>
		n++;
  800a6d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a74:	75 f7                	jne    800a6d <strlen+0xd>
	return n;
}
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
  800a86:	eb 03                	jmp    800a8b <strnlen+0x13>
		n++;
  800a88:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8b:	39 d0                	cmp    %edx,%eax
  800a8d:	74 06                	je     800a95 <strnlen+0x1d>
  800a8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a93:	75 f3                	jne    800a88 <strnlen+0x10>
	return n;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	53                   	push   %ebx
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	83 c2 01             	add    $0x1,%edx
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800aad:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ab0:	84 db                	test   %bl,%bl
  800ab2:	75 ef                	jne    800aa3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	83 ec 08             	sub    $0x8,%esp
  800abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac1:	89 1c 24             	mov    %ebx,(%esp)
  800ac4:	e8 97 ff ff ff       	call   800a60 <strlen>
	strcpy(dst + len, src);
  800ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad0:	01 d8                	add    %ebx,%eax
  800ad2:	89 04 24             	mov    %eax,(%esp)
  800ad5:	e8 bd ff ff ff       	call   800a97 <strcpy>
	return dst;
}
  800ada:	89 d8                	mov    %ebx,%eax
  800adc:	83 c4 08             	add    $0x8,%esp
  800adf:	5b                   	pop    %ebx
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	8b 75 08             	mov    0x8(%ebp),%esi
  800aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af2:	89 f2                	mov    %esi,%edx
  800af4:	eb 0f                	jmp    800b05 <strncpy+0x23>
		*dst++ = *src;
  800af6:	83 c2 01             	add    $0x1,%edx
  800af9:	0f b6 01             	movzbl (%ecx),%eax
  800afc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aff:	80 39 01             	cmpb   $0x1,(%ecx)
  800b02:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b05:	39 da                	cmp    %ebx,%edx
  800b07:	75 ed                	jne    800af6 <strncpy+0x14>
	}
	return ret;
}
  800b09:	89 f0                	mov    %esi,%eax
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	8b 75 08             	mov    0x8(%ebp),%esi
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1d:	89 f0                	mov    %esi,%eax
  800b1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b23:	85 c9                	test   %ecx,%ecx
  800b25:	75 0b                	jne    800b32 <strlcpy+0x23>
  800b27:	eb 1d                	jmp    800b46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
  800b2f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b32:	39 d8                	cmp    %ebx,%eax
  800b34:	74 0b                	je     800b41 <strlcpy+0x32>
  800b36:	0f b6 0a             	movzbl (%edx),%ecx
  800b39:	84 c9                	test   %cl,%cl
  800b3b:	75 ec                	jne    800b29 <strlcpy+0x1a>
  800b3d:	89 c2                	mov    %eax,%edx
  800b3f:	eb 02                	jmp    800b43 <strlcpy+0x34>
  800b41:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800b43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b46:	29 f0                	sub    %esi,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b55:	eb 06                	jmp    800b5d <strcmp+0x11>
		p++, q++;
  800b57:	83 c1 01             	add    $0x1,%ecx
  800b5a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b5d:	0f b6 01             	movzbl (%ecx),%eax
  800b60:	84 c0                	test   %al,%al
  800b62:	74 04                	je     800b68 <strcmp+0x1c>
  800b64:	3a 02                	cmp    (%edx),%al
  800b66:	74 ef                	je     800b57 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b68:	0f b6 c0             	movzbl %al,%eax
  800b6b:	0f b6 12             	movzbl (%edx),%edx
  800b6e:	29 d0                	sub    %edx,%eax
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	53                   	push   %ebx
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7c:	89 c3                	mov    %eax,%ebx
  800b7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b81:	eb 06                	jmp    800b89 <strncmp+0x17>
		n--, p++, q++;
  800b83:	83 c0 01             	add    $0x1,%eax
  800b86:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b89:	39 d8                	cmp    %ebx,%eax
  800b8b:	74 15                	je     800ba2 <strncmp+0x30>
  800b8d:	0f b6 08             	movzbl (%eax),%ecx
  800b90:	84 c9                	test   %cl,%cl
  800b92:	74 04                	je     800b98 <strncmp+0x26>
  800b94:	3a 0a                	cmp    (%edx),%cl
  800b96:	74 eb                	je     800b83 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b98:	0f b6 00             	movzbl (%eax),%eax
  800b9b:	0f b6 12             	movzbl (%edx),%edx
  800b9e:	29 d0                	sub    %edx,%eax
  800ba0:	eb 05                	jmp    800ba7 <strncmp+0x35>
		return 0;
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb4:	eb 07                	jmp    800bbd <strchr+0x13>
		if (*s == c)
  800bb6:	38 ca                	cmp    %cl,%dl
  800bb8:	74 0f                	je     800bc9 <strchr+0x1f>
	for (; *s; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	0f b6 10             	movzbl (%eax),%edx
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 f2                	jne    800bb6 <strchr+0xc>
			return (char *) s;
	return 0;
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd5:	eb 07                	jmp    800bde <strfind+0x13>
		if (*s == c)
  800bd7:	38 ca                	cmp    %cl,%dl
  800bd9:	74 0a                	je     800be5 <strfind+0x1a>
	for (; *s; s++)
  800bdb:	83 c0 01             	add    $0x1,%eax
  800bde:	0f b6 10             	movzbl (%eax),%edx
  800be1:	84 d2                	test   %dl,%dl
  800be3:	75 f2                	jne    800bd7 <strfind+0xc>
			break;
	return (char *) s;
}
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf3:	85 c9                	test   %ecx,%ecx
  800bf5:	74 36                	je     800c2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfd:	75 28                	jne    800c27 <memset+0x40>
  800bff:	f6 c1 03             	test   $0x3,%cl
  800c02:	75 23                	jne    800c27 <memset+0x40>
		c &= 0xFF;
  800c04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	c1 e3 08             	shl    $0x8,%ebx
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	c1 e6 18             	shl    $0x18,%esi
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	c1 e0 10             	shl    $0x10,%eax
  800c17:	09 f0                	or     %esi,%eax
  800c19:	09 c2                	or     %eax,%edx
  800c1b:	89 d0                	mov    %edx,%eax
  800c1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c1f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c22:	fc                   	cld    
  800c23:	f3 ab                	rep stos %eax,%es:(%edi)
  800c25:	eb 06                	jmp    800c2d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2a:	fc                   	cld    
  800c2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c2d:	89 f8                	mov    %edi,%eax
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c42:	39 c6                	cmp    %eax,%esi
  800c44:	73 35                	jae    800c7b <memmove+0x47>
  800c46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c49:	39 d0                	cmp    %edx,%eax
  800c4b:	73 2e                	jae    800c7b <memmove+0x47>
		s += n;
		d += n;
  800c4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5a:	75 13                	jne    800c6f <memmove+0x3b>
  800c5c:	f6 c1 03             	test   $0x3,%cl
  800c5f:	75 0e                	jne    800c6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c61:	83 ef 04             	sub    $0x4,%edi
  800c64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c6a:	fd                   	std    
  800c6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6d:	eb 09                	jmp    800c78 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c6f:	83 ef 01             	sub    $0x1,%edi
  800c72:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c75:	fd                   	std    
  800c76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c78:	fc                   	cld    
  800c79:	eb 1d                	jmp    800c98 <memmove+0x64>
  800c7b:	89 f2                	mov    %esi,%edx
  800c7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7f:	f6 c2 03             	test   $0x3,%dl
  800c82:	75 0f                	jne    800c93 <memmove+0x5f>
  800c84:	f6 c1 03             	test   $0x3,%cl
  800c87:	75 0a                	jne    800c93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c89:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	fc                   	cld    
  800c8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c91:	eb 05                	jmp    800c98 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800c93:	89 c7                	mov    %eax,%edi
  800c95:	fc                   	cld    
  800c96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb3:	89 04 24             	mov    %eax,(%esp)
  800cb6:	e8 79 ff ff ff       	call   800c34 <memmove>
}
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	89 d6                	mov    %edx,%esi
  800cca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccd:	eb 1a                	jmp    800ce9 <memcmp+0x2c>
		if (*s1 != *s2)
  800ccf:	0f b6 02             	movzbl (%edx),%eax
  800cd2:	0f b6 19             	movzbl (%ecx),%ebx
  800cd5:	38 d8                	cmp    %bl,%al
  800cd7:	74 0a                	je     800ce3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cd9:	0f b6 c0             	movzbl %al,%eax
  800cdc:	0f b6 db             	movzbl %bl,%ebx
  800cdf:	29 d8                	sub    %ebx,%eax
  800ce1:	eb 0f                	jmp    800cf2 <memcmp+0x35>
		s1++, s2++;
  800ce3:	83 c2 01             	add    $0x1,%edx
  800ce6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800ce9:	39 f2                	cmp    %esi,%edx
  800ceb:	75 e2                	jne    800ccf <memcmp+0x12>
	}

	return 0;
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cff:	89 c2                	mov    %eax,%edx
  800d01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d04:	eb 07                	jmp    800d0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d06:	38 08                	cmp    %cl,(%eax)
  800d08:	74 07                	je     800d11 <memfind+0x1b>
	for (; s < ends; s++)
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	39 d0                	cmp    %edx,%eax
  800d0f:	72 f5                	jb     800d06 <memfind+0x10>
			break;
	return (void *) s;
}
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1f:	eb 03                	jmp    800d24 <strtol+0x11>
		s++;
  800d21:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d24:	0f b6 0a             	movzbl (%edx),%ecx
  800d27:	80 f9 09             	cmp    $0x9,%cl
  800d2a:	74 f5                	je     800d21 <strtol+0xe>
  800d2c:	80 f9 20             	cmp    $0x20,%cl
  800d2f:	74 f0                	je     800d21 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d31:	80 f9 2b             	cmp    $0x2b,%cl
  800d34:	75 0a                	jne    800d40 <strtol+0x2d>
		s++;
  800d36:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d39:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3e:	eb 11                	jmp    800d51 <strtol+0x3e>
  800d40:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800d45:	80 f9 2d             	cmp    $0x2d,%cl
  800d48:	75 07                	jne    800d51 <strtol+0x3e>
		s++, neg = 1;
  800d4a:	8d 52 01             	lea    0x1(%edx),%edx
  800d4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d56:	75 15                	jne    800d6d <strtol+0x5a>
  800d58:	80 3a 30             	cmpb   $0x30,(%edx)
  800d5b:	75 10                	jne    800d6d <strtol+0x5a>
  800d5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d61:	75 0a                	jne    800d6d <strtol+0x5a>
		s += 2, base = 16;
  800d63:	83 c2 02             	add    $0x2,%edx
  800d66:	b8 10 00 00 00       	mov    $0x10,%eax
  800d6b:	eb 10                	jmp    800d7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	75 0c                	jne    800d7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d71:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800d73:	80 3a 30             	cmpb   $0x30,(%edx)
  800d76:	75 05                	jne    800d7d <strtol+0x6a>
		s++, base = 8;
  800d78:	83 c2 01             	add    $0x1,%edx
  800d7b:	b0 08                	mov    $0x8,%al
		base = 10;
  800d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d85:	0f b6 0a             	movzbl (%edx),%ecx
  800d88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	3c 09                	cmp    $0x9,%al
  800d8f:	77 08                	ja     800d99 <strtol+0x86>
			dig = *s - '0';
  800d91:	0f be c9             	movsbl %cl,%ecx
  800d94:	83 e9 30             	sub    $0x30,%ecx
  800d97:	eb 20                	jmp    800db9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800d99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800d9c:	89 f0                	mov    %esi,%eax
  800d9e:	3c 19                	cmp    $0x19,%al
  800da0:	77 08                	ja     800daa <strtol+0x97>
			dig = *s - 'a' + 10;
  800da2:	0f be c9             	movsbl %cl,%ecx
  800da5:	83 e9 57             	sub    $0x57,%ecx
  800da8:	eb 0f                	jmp    800db9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800daa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800dad:	89 f0                	mov    %esi,%eax
  800daf:	3c 19                	cmp    $0x19,%al
  800db1:	77 16                	ja     800dc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800db3:	0f be c9             	movsbl %cl,%ecx
  800db6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800db9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dbc:	7d 0f                	jge    800dcd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800dbe:	83 c2 01             	add    $0x1,%edx
  800dc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800dc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800dc7:	eb bc                	jmp    800d85 <strtol+0x72>
  800dc9:	89 d8                	mov    %ebx,%eax
  800dcb:	eb 02                	jmp    800dcf <strtol+0xbc>
  800dcd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800dcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd3:	74 05                	je     800dda <strtol+0xc7>
		*endptr = (char *) s;
  800dd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800dda:	f7 d8                	neg    %eax
  800ddc:	85 ff                	test   %edi,%edi
  800dde:	0f 44 c3             	cmove  %ebx,%eax
}
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	89 c7                	mov    %eax,%edi
  800dfb:	89 c6                	mov    %eax,%esi
  800dfd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e14:	89 d1                	mov    %edx,%ecx
  800e16:	89 d3                	mov    %edx,%ebx
  800e18:	89 d7                	mov    %edx,%edi
  800e1a:	89 d6                	mov    %edx,%esi
  800e1c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e31:	b8 03 00 00 00       	mov    $0x3,%eax
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 cb                	mov    %ecx,%ebx
  800e3b:	89 cf                	mov    %ecx,%edi
  800e3d:	89 ce                	mov    %ecx,%esi
  800e3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 28                	jle    800e6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e50:	00 
  800e51:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800e58:	00 
  800e59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e60:	00 
  800e61:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800e68:	e8 09 f5 ff ff       	call   800376 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e6d:	83 c4 2c             	add    $0x2c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 02 00 00 00       	mov    $0x2,%eax
  800e85:	89 d1                	mov    %edx,%ecx
  800e87:	89 d3                	mov    %edx,%ebx
  800e89:	89 d7                	mov    %edx,%edi
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_yield>:

void
sys_yield(void)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea4:	89 d1                	mov    %edx,%ecx
  800ea6:	89 d3                	mov    %edx,%ebx
  800ea8:	89 d7                	mov    %edx,%edi
  800eaa:	89 d6                	mov    %edx,%esi
  800eac:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ebc:	be 00 00 00 00       	mov    $0x0,%esi
  800ec1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecf:	89 f7                	mov    %esi,%edi
  800ed1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	7e 28                	jle    800eff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800efa:	e8 77 f4 ff ff       	call   800376 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eff:	83 c4 2c             	add    $0x2c,%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f10:	b8 05 00 00 00       	mov    $0x5,%eax
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f21:	8b 75 18             	mov    0x18(%ebp),%esi
  800f24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	7e 28                	jle    800f52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f35:	00 
  800f36:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f45:	00 
  800f46:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800f4d:	e8 24 f4 ff ff       	call   800376 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f52:	83 c4 2c             	add    $0x2c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f68:	b8 06 00 00 00       	mov    $0x6,%eax
  800f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f70:	8b 55 08             	mov    0x8(%ebp),%edx
  800f73:	89 df                	mov    %ebx,%edi
  800f75:	89 de                	mov    %ebx,%esi
  800f77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	7e 28                	jle    800fa5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f88:	00 
  800f89:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800f90:	00 
  800f91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f98:	00 
  800f99:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800fa0:	e8 d1 f3 ff ff       	call   800376 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fa5:	83 c4 2c             	add    $0x2c,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc6:	89 df                	mov    %ebx,%edi
  800fc8:	89 de                	mov    %ebx,%esi
  800fca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	7e 28                	jle    800ff8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800feb:	00 
  800fec:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800ff3:	e8 7e f3 ff ff       	call   800376 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ff8:	83 c4 2c             	add    $0x2c,%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5e                   	pop    %esi
  800ffd:	5f                   	pop    %edi
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100e:	b8 09 00 00 00       	mov    $0x9,%eax
  801013:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	89 df                	mov    %ebx,%edi
  80101b:	89 de                	mov    %ebx,%esi
  80101d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80101f:	85 c0                	test   %eax,%eax
  801021:	7e 28                	jle    80104b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801023:	89 44 24 10          	mov    %eax,0x10(%esp)
  801027:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80102e:	00 
  80102f:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  801036:	00 
  801037:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103e:	00 
  80103f:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  801046:	e8 2b f3 ff ff       	call   800376 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80104b:	83 c4 2c             	add    $0x2c,%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80105c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801061:	b8 0a 00 00 00       	mov    $0xa,%eax
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	8b 55 08             	mov    0x8(%ebp),%edx
  80106c:	89 df                	mov    %ebx,%edi
  80106e:	89 de                	mov    %ebx,%esi
  801070:	cd 30                	int    $0x30
	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 28                	jle    80109e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801076:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801081:	00 
  801082:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  801089:	00 
  80108a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801091:	00 
  801092:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  801099:	e8 d8 f2 ff ff       	call   800376 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80109e:	83 c4 2c             	add    $0x2c,%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010ac:	be 00 00 00 00       	mov    $0x0,%esi
  8010b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010c4:	5b                   	pop    %ebx
  8010c5:	5e                   	pop    %esi
  8010c6:	5f                   	pop    %edi
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	57                   	push   %edi
  8010cd:	56                   	push   %esi
  8010ce:	53                   	push   %ebx
  8010cf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8010d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010df:	89 cb                	mov    %ecx,%ebx
  8010e1:	89 cf                	mov    %ecx,%edi
  8010e3:	89 ce                	mov    %ecx,%esi
  8010e5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	7e 28                	jle    801113 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010f6:	00 
  8010f7:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  8010fe:	00 
  8010ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801106:	00 
  801107:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  80110e:	e8 63 f2 ff ff       	call   800376 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801113:	83 c4 2c             	add    $0x2c,%esp
  801116:	5b                   	pop    %ebx
  801117:	5e                   	pop    %esi
  801118:	5f                   	pop    %edi
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    
  80111b:	66 90                	xchg   %ax,%ax
  80111d:	66 90                	xchg   %ax,%ax
  80111f:	90                   	nop

00801120 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	53                   	push   %ebx
  801124:	83 ec 24             	sub    $0x24,%esp
  801127:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  80112a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  80112c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801130:	74 18                	je     80114a <pgfault+0x2a>
  801132:	89 d8                	mov    %ebx,%eax
  801134:	c1 e8 0c             	shr    $0xc,%eax
  801137:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113e:	25 05 08 00 00       	and    $0x805,%eax
  801143:	3d 05 08 00 00       	cmp    $0x805,%eax
  801148:	74 1c                	je     801166 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  80114a:	c7 44 24 08 6c 2b 80 	movl   $0x802b6c,0x8(%esp)
  801151:	00 
  801152:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801159:	00 
  80115a:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  801161:	e8 10 f2 ff ff       	call   800376 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  801166:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117d:	e8 31 fd ff ff       	call   800eb3 <sys_page_alloc>
	if(r < 0){
  801182:	85 c0                	test   %eax,%eax
  801184:	79 1c                	jns    8011a2 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  801186:	c7 44 24 08 9c 2b 80 	movl   $0x802b9c,0x8(%esp)
  80118d:	00 
  80118e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801195:	00 
  801196:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  80119d:	e8 d4 f1 ff ff       	call   800376 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8011a2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8011a8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011af:	00 
  8011b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011bb:	e8 dc fa ff ff       	call   800c9c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  8011c0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011c7:	00 
  8011c8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d3:	00 
  8011d4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011db:	00 
  8011dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e3:	e8 1f fd ff ff       	call   800f07 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	79 1c                	jns    801208 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  8011ec:	c7 44 24 08 68 2c 80 	movl   $0x802c68,0x8(%esp)
  8011f3:	00 
  8011f4:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8011fb:	00 
  8011fc:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  801203:	e8 6e f1 ff ff       	call   800376 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  801208:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80120f:	00 
  801210:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801217:	e8 3e fd ff ff       	call   800f5a <sys_page_unmap>
    if(r < 0){
  80121c:	85 c0                	test   %eax,%eax
  80121e:	79 1c                	jns    80123c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  801220:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  801227:	00 
  801228:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80122f:	00 
  801230:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  801237:	e8 3a f1 ff ff       	call   800376 <_panic>
    }
    // LAB 4
}
  80123c:	83 c4 24             	add    $0x24,%esp
  80123f:	5b                   	pop    %ebx
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	57                   	push   %edi
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  80124b:	c7 04 24 20 11 80 00 	movl   $0x801120,(%esp)
  801252:	e8 bf 0f 00 00       	call   802216 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801257:	b8 07 00 00 00       	mov    $0x7,%eax
  80125c:	cd 30                	int    $0x30
  80125e:	89 c7                	mov    %eax,%edi
  801260:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801263:	85 c0                	test   %eax,%eax
  801265:	79 1c                	jns    801283 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801267:	c7 44 24 08 98 2c 80 	movl   $0x802c98,0x8(%esp)
  80126e:	00 
  80126f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801276:	00 
  801277:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  80127e:	e8 f3 f0 ff ff       	call   800376 <_panic>
    }
    if(child == 0){
  801283:	bb 00 00 00 00       	mov    $0x0,%ebx
  801288:	85 c0                	test   %eax,%eax
  80128a:	75 21                	jne    8012ad <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80128c:	e8 e4 fb ff ff       	call   800e75 <sys_getenvid>
  801291:	25 ff 03 00 00       	and    $0x3ff,%eax
  801296:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801299:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80129e:	a3 08 40 80 00       	mov    %eax,0x804008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a8:	e9 67 01 00 00       	jmp    801414 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  8012ad:	89 d8                	mov    %ebx,%eax
  8012af:	c1 e8 16             	shr    $0x16,%eax
  8012b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b9:	a8 01                	test   $0x1,%al
  8012bb:	74 4b                	je     801308 <fork+0xc6>
  8012bd:	89 de                	mov    %ebx,%esi
  8012bf:	c1 ee 0c             	shr    $0xc,%esi
  8012c2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012c9:	a8 01                	test   $0x1,%al
  8012cb:	74 3b                	je     801308 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  8012cd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012d4:	a9 02 08 00 00       	test   $0x802,%eax
  8012d9:	0f 85 02 01 00 00    	jne    8013e1 <fork+0x19f>
  8012df:	e9 d2 00 00 00       	jmp    8013b6 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  8012e4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012eb:	00 
  8012ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012f7:	00 
  8012f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801303:	e8 ff fb ff ff       	call   800f07 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801308:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80130e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801314:	75 97                	jne    8012ad <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801316:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80131d:	00 
  80131e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801325:	ee 
  801326:	89 3c 24             	mov    %edi,(%esp)
  801329:	e8 85 fb ff ff       	call   800eb3 <sys_page_alloc>

    if(r < 0){
  80132e:	85 c0                	test   %eax,%eax
  801330:	79 1c                	jns    80134e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801332:	c7 44 24 08 d0 2b 80 	movl   $0x802bd0,0x8(%esp)
  801339:	00 
  80133a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801341:	00 
  801342:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  801349:	e8 28 f0 ff ff       	call   800376 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80134e:	a1 08 40 80 00       	mov    0x804008,%eax
  801353:	8b 40 64             	mov    0x64(%eax),%eax
  801356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135a:	89 3c 24             	mov    %edi,(%esp)
  80135d:	e8 f1 fc ff ff       	call   801053 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801362:	85 c0                	test   %eax,%eax
  801364:	79 1c                	jns    801382 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801366:	c7 44 24 08 f0 2b 80 	movl   $0x802bf0,0x8(%esp)
  80136d:	00 
  80136e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801375:	00 
  801376:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  80137d:	e8 f4 ef ff ff       	call   800376 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801382:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801389:	00 
  80138a:	89 3c 24             	mov    %edi,(%esp)
  80138d:	e8 1b fc ff ff       	call   800fad <sys_env_set_status>
    if(r < 0){
  801392:	85 c0                	test   %eax,%eax
  801394:	79 1c                	jns    8013b2 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801396:	c7 44 24 08 18 2c 80 	movl   $0x802c18,0x8(%esp)
  80139d:	00 
  80139e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  8013a5:	00 
  8013a6:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  8013ad:	e8 c4 ef ff ff       	call   800376 <_panic>
    }
    return child;
  8013b2:	89 f8                	mov    %edi,%eax
  8013b4:	eb 5e                	jmp    801414 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  8013b6:	c1 e6 0c             	shl    $0xc,%esi
  8013b9:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8013c0:	00 
  8013c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d7:	e8 2b fb ff ff       	call   800f07 <sys_page_map>
  8013dc:	e9 27 ff ff ff       	jmp    801308 <fork+0xc6>
  8013e1:	c1 e6 0c             	shl    $0xc,%esi
  8013e4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013eb:	00 
  8013ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801402:	e8 00 fb ff ff       	call   800f07 <sys_page_map>
    if( r < 0 ){
  801407:	85 c0                	test   %eax,%eax
  801409:	0f 89 d5 fe ff ff    	jns    8012e4 <fork+0xa2>
  80140f:	e9 f4 fe ff ff       	jmp    801308 <fork+0xc6>
//	panic("fork not implemented");
}
  801414:	83 c4 2c             	add    $0x2c,%esp
  801417:	5b                   	pop    %ebx
  801418:	5e                   	pop    %esi
  801419:	5f                   	pop    %edi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <sfork>:

// Challenge!
int
sfork(void)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801422:	c7 44 24 08 b5 2c 80 	movl   $0x802cb5,0x8(%esp)
  801429:	00 
  80142a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801431:	00 
  801432:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  801439:	e8 38 ef ff ff       	call   800376 <_panic>
  80143e:	66 90                	xchg   %ax,%ax

00801440 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801443:	8b 45 08             	mov    0x8(%ebp),%eax
  801446:	05 00 00 00 30       	add    $0x30000000,%eax
  80144b:	c1 e8 0c             	shr    $0xc,%eax
}
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80145b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801460:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    

00801467 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801472:	89 c2                	mov    %eax,%edx
  801474:	c1 ea 16             	shr    $0x16,%edx
  801477:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147e:	f6 c2 01             	test   $0x1,%dl
  801481:	74 11                	je     801494 <fd_alloc+0x2d>
  801483:	89 c2                	mov    %eax,%edx
  801485:	c1 ea 0c             	shr    $0xc,%edx
  801488:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148f:	f6 c2 01             	test   $0x1,%dl
  801492:	75 09                	jne    80149d <fd_alloc+0x36>
			*fd_store = fd;
  801494:	89 01                	mov    %eax,(%ecx)
			return 0;
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
  80149b:	eb 17                	jmp    8014b4 <fd_alloc+0x4d>
  80149d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8014a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014a7:	75 c9                	jne    801472 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8014a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014bc:	83 f8 1f             	cmp    $0x1f,%eax
  8014bf:	77 36                	ja     8014f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014c1:	c1 e0 0c             	shl    $0xc,%eax
  8014c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	c1 ea 16             	shr    $0x16,%edx
  8014ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014d5:	f6 c2 01             	test   $0x1,%dl
  8014d8:	74 24                	je     8014fe <fd_lookup+0x48>
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	c1 ea 0c             	shr    $0xc,%edx
  8014df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e6:	f6 c2 01             	test   $0x1,%dl
  8014e9:	74 1a                	je     801505 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f5:	eb 13                	jmp    80150a <fd_lookup+0x54>
		return -E_INVAL;
  8014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fc:	eb 0c                	jmp    80150a <fd_lookup+0x54>
		return -E_INVAL;
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801503:	eb 05                	jmp    80150a <fd_lookup+0x54>
  801505:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	83 ec 18             	sub    $0x18,%esp
  801512:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801515:	ba 48 2d 80 00       	mov    $0x802d48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80151a:	eb 13                	jmp    80152f <dev_lookup+0x23>
  80151c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80151f:	39 08                	cmp    %ecx,(%eax)
  801521:	75 0c                	jne    80152f <dev_lookup+0x23>
			*dev = devtab[i];
  801523:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801526:	89 01                	mov    %eax,(%ecx)
			return 0;
  801528:	b8 00 00 00 00       	mov    $0x0,%eax
  80152d:	eb 30                	jmp    80155f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80152f:	8b 02                	mov    (%edx),%eax
  801531:	85 c0                	test   %eax,%eax
  801533:	75 e7                	jne    80151c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801535:	a1 08 40 80 00       	mov    0x804008,%eax
  80153a:	8b 40 48             	mov    0x48(%eax),%eax
  80153d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801541:	89 44 24 04          	mov    %eax,0x4(%esp)
  801545:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  80154c:	e8 1e ef ff ff       	call   80046f <cprintf>
	*dev = 0;
  801551:	8b 45 0c             	mov    0xc(%ebp),%eax
  801554:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80155a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <fd_close>:
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	83 ec 20             	sub    $0x20,%esp
  801569:	8b 75 08             	mov    0x8(%ebp),%esi
  80156c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801576:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80157c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80157f:	89 04 24             	mov    %eax,(%esp)
  801582:	e8 2f ff ff ff       	call   8014b6 <fd_lookup>
  801587:	85 c0                	test   %eax,%eax
  801589:	78 05                	js     801590 <fd_close+0x2f>
	    || fd != fd2)
  80158b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80158e:	74 0c                	je     80159c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801590:	84 db                	test   %bl,%bl
  801592:	ba 00 00 00 00       	mov    $0x0,%edx
  801597:	0f 44 c2             	cmove  %edx,%eax
  80159a:	eb 3f                	jmp    8015db <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80159c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a3:	8b 06                	mov    (%esi),%eax
  8015a5:	89 04 24             	mov    %eax,(%esp)
  8015a8:	e8 5f ff ff ff       	call   80150c <dev_lookup>
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 16                	js     8015c9 <fd_close+0x68>
		if (dev->dev_close)
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	74 07                	je     8015c9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8015c2:	89 34 24             	mov    %esi,(%esp)
  8015c5:	ff d0                	call   *%eax
  8015c7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8015c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d4:	e8 81 f9 ff ff       	call   800f5a <sys_page_unmap>
	return r;
  8015d9:	89 d8                	mov    %ebx,%eax
}
  8015db:	83 c4 20             	add    $0x20,%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <close>:

int
close(int fdnum)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 bc fe ff ff       	call   8014b6 <fd_lookup>
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	85 d2                	test   %edx,%edx
  8015fe:	78 13                	js     801613 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801600:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801607:	00 
  801608:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160b:	89 04 24             	mov    %eax,(%esp)
  80160e:	e8 4e ff ff ff       	call   801561 <fd_close>
}
  801613:	c9                   	leave  
  801614:	c3                   	ret    

00801615 <close_all>:

void
close_all(void)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	53                   	push   %ebx
  801619:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80161c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801621:	89 1c 24             	mov    %ebx,(%esp)
  801624:	e8 b9 ff ff ff       	call   8015e2 <close>
	for (i = 0; i < MAXFD; i++)
  801629:	83 c3 01             	add    $0x1,%ebx
  80162c:	83 fb 20             	cmp    $0x20,%ebx
  80162f:	75 f0                	jne    801621 <close_all+0xc>
}
  801631:	83 c4 14             	add    $0x14,%esp
  801634:	5b                   	pop    %ebx
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	57                   	push   %edi
  80163b:	56                   	push   %esi
  80163c:	53                   	push   %ebx
  80163d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801640:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801643:	89 44 24 04          	mov    %eax,0x4(%esp)
  801647:	8b 45 08             	mov    0x8(%ebp),%eax
  80164a:	89 04 24             	mov    %eax,(%esp)
  80164d:	e8 64 fe ff ff       	call   8014b6 <fd_lookup>
  801652:	89 c2                	mov    %eax,%edx
  801654:	85 d2                	test   %edx,%edx
  801656:	0f 88 e1 00 00 00    	js     80173d <dup+0x106>
		return r;
	close(newfdnum);
  80165c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165f:	89 04 24             	mov    %eax,(%esp)
  801662:	e8 7b ff ff ff       	call   8015e2 <close>

	newfd = INDEX2FD(newfdnum);
  801667:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80166a:	c1 e3 0c             	shl    $0xc,%ebx
  80166d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801673:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801676:	89 04 24             	mov    %eax,(%esp)
  801679:	e8 d2 fd ff ff       	call   801450 <fd2data>
  80167e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801680:	89 1c 24             	mov    %ebx,(%esp)
  801683:	e8 c8 fd ff ff       	call   801450 <fd2data>
  801688:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80168a:	89 f0                	mov    %esi,%eax
  80168c:	c1 e8 16             	shr    $0x16,%eax
  80168f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801696:	a8 01                	test   $0x1,%al
  801698:	74 43                	je     8016dd <dup+0xa6>
  80169a:	89 f0                	mov    %esi,%eax
  80169c:	c1 e8 0c             	shr    $0xc,%eax
  80169f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016a6:	f6 c2 01             	test   $0x1,%dl
  8016a9:	74 32                	je     8016dd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016c6:	00 
  8016c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d2:	e8 30 f8 ff ff       	call   800f07 <sys_page_map>
  8016d7:	89 c6                	mov    %eax,%esi
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 3e                	js     80171b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	c1 ea 0c             	shr    $0xc,%edx
  8016e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016f2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016f6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801701:	00 
  801702:	89 44 24 04          	mov    %eax,0x4(%esp)
  801706:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80170d:	e8 f5 f7 ff ff       	call   800f07 <sys_page_map>
  801712:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801714:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801717:	85 f6                	test   %esi,%esi
  801719:	79 22                	jns    80173d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80171b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80171f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801726:	e8 2f f8 ff ff       	call   800f5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80172b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80172f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801736:	e8 1f f8 ff ff       	call   800f5a <sys_page_unmap>
	return r;
  80173b:	89 f0                	mov    %esi,%eax
}
  80173d:	83 c4 3c             	add    $0x3c,%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 24             	sub    $0x24,%esp
  80174c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	89 1c 24             	mov    %ebx,(%esp)
  801759:	e8 58 fd ff ff       	call   8014b6 <fd_lookup>
  80175e:	89 c2                	mov    %eax,%edx
  801760:	85 d2                	test   %edx,%edx
  801762:	78 6d                	js     8017d1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801764:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176e:	8b 00                	mov    (%eax),%eax
  801770:	89 04 24             	mov    %eax,(%esp)
  801773:	e8 94 fd ff ff       	call   80150c <dev_lookup>
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 55                	js     8017d1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80177c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177f:	8b 50 08             	mov    0x8(%eax),%edx
  801782:	83 e2 03             	and    $0x3,%edx
  801785:	83 fa 01             	cmp    $0x1,%edx
  801788:	75 23                	jne    8017ad <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80178a:	a1 08 40 80 00       	mov    0x804008,%eax
  80178f:	8b 40 48             	mov    0x48(%eax),%eax
  801792:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801796:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179a:	c7 04 24 0d 2d 80 00 	movl   $0x802d0d,(%esp)
  8017a1:	e8 c9 ec ff ff       	call   80046f <cprintf>
		return -E_INVAL;
  8017a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ab:	eb 24                	jmp    8017d1 <read+0x8c>
	}
	if (!dev->dev_read)
  8017ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b0:	8b 52 08             	mov    0x8(%edx),%edx
  8017b3:	85 d2                	test   %edx,%edx
  8017b5:	74 15                	je     8017cc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017c5:	89 04 24             	mov    %eax,(%esp)
  8017c8:	ff d2                	call   *%edx
  8017ca:	eb 05                	jmp    8017d1 <read+0x8c>
		return -E_NOT_SUPP;
  8017cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017d1:	83 c4 24             	add    $0x24,%esp
  8017d4:	5b                   	pop    %ebx
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	57                   	push   %edi
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 1c             	sub    $0x1c,%esp
  8017e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017eb:	eb 23                	jmp    801810 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017ed:	89 f0                	mov    %esi,%eax
  8017ef:	29 d8                	sub    %ebx,%eax
  8017f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f5:	89 d8                	mov    %ebx,%eax
  8017f7:	03 45 0c             	add    0xc(%ebp),%eax
  8017fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fe:	89 3c 24             	mov    %edi,(%esp)
  801801:	e8 3f ff ff ff       	call   801745 <read>
		if (m < 0)
  801806:	85 c0                	test   %eax,%eax
  801808:	78 10                	js     80181a <readn+0x43>
			return m;
		if (m == 0)
  80180a:	85 c0                	test   %eax,%eax
  80180c:	74 0a                	je     801818 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80180e:	01 c3                	add    %eax,%ebx
  801810:	39 f3                	cmp    %esi,%ebx
  801812:	72 d9                	jb     8017ed <readn+0x16>
  801814:	89 d8                	mov    %ebx,%eax
  801816:	eb 02                	jmp    80181a <readn+0x43>
  801818:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80181a:	83 c4 1c             	add    $0x1c,%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5e                   	pop    %esi
  80181f:	5f                   	pop    %edi
  801820:	5d                   	pop    %ebp
  801821:	c3                   	ret    

00801822 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	53                   	push   %ebx
  801826:	83 ec 24             	sub    $0x24,%esp
  801829:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	89 1c 24             	mov    %ebx,(%esp)
  801836:	e8 7b fc ff ff       	call   8014b6 <fd_lookup>
  80183b:	89 c2                	mov    %eax,%edx
  80183d:	85 d2                	test   %edx,%edx
  80183f:	78 68                	js     8018a9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801841:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801844:	89 44 24 04          	mov    %eax,0x4(%esp)
  801848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184b:	8b 00                	mov    (%eax),%eax
  80184d:	89 04 24             	mov    %eax,(%esp)
  801850:	e8 b7 fc ff ff       	call   80150c <dev_lookup>
  801855:	85 c0                	test   %eax,%eax
  801857:	78 50                	js     8018a9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801859:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801860:	75 23                	jne    801885 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801862:	a1 08 40 80 00       	mov    0x804008,%eax
  801867:	8b 40 48             	mov    0x48(%eax),%eax
  80186a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801872:	c7 04 24 29 2d 80 00 	movl   $0x802d29,(%esp)
  801879:	e8 f1 eb ff ff       	call   80046f <cprintf>
		return -E_INVAL;
  80187e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801883:	eb 24                	jmp    8018a9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801885:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801888:	8b 52 0c             	mov    0xc(%edx),%edx
  80188b:	85 d2                	test   %edx,%edx
  80188d:	74 15                	je     8018a4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80188f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801892:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801896:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801899:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80189d:	89 04 24             	mov    %eax,(%esp)
  8018a0:	ff d2                	call   *%edx
  8018a2:	eb 05                	jmp    8018a9 <write+0x87>
		return -E_NOT_SUPP;
  8018a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018a9:	83 c4 24             	add    $0x24,%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <seek>:

int
seek(int fdnum, off_t offset)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	89 04 24             	mov    %eax,(%esp)
  8018c2:	e8 ef fb ff ff       	call   8014b6 <fd_lookup>
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 0e                	js     8018d9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 24             	sub    $0x24,%esp
  8018e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ec:	89 1c 24             	mov    %ebx,(%esp)
  8018ef:	e8 c2 fb ff ff       	call   8014b6 <fd_lookup>
  8018f4:	89 c2                	mov    %eax,%edx
  8018f6:	85 d2                	test   %edx,%edx
  8018f8:	78 61                	js     80195b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801901:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801904:	8b 00                	mov    (%eax),%eax
  801906:	89 04 24             	mov    %eax,(%esp)
  801909:	e8 fe fb ff ff       	call   80150c <dev_lookup>
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 49                	js     80195b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801912:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801915:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801919:	75 23                	jne    80193e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80191b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801920:	8b 40 48             	mov    0x48(%eax),%eax
  801923:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	c7 04 24 ec 2c 80 00 	movl   $0x802cec,(%esp)
  801932:	e8 38 eb ff ff       	call   80046f <cprintf>
		return -E_INVAL;
  801937:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80193c:	eb 1d                	jmp    80195b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80193e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801941:	8b 52 18             	mov    0x18(%edx),%edx
  801944:	85 d2                	test   %edx,%edx
  801946:	74 0e                	je     801956 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801948:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80194f:	89 04 24             	mov    %eax,(%esp)
  801952:	ff d2                	call   *%edx
  801954:	eb 05                	jmp    80195b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801956:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80195b:	83 c4 24             	add    $0x24,%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    

00801961 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	53                   	push   %ebx
  801965:	83 ec 24             	sub    $0x24,%esp
  801968:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	89 04 24             	mov    %eax,(%esp)
  801978:	e8 39 fb ff ff       	call   8014b6 <fd_lookup>
  80197d:	89 c2                	mov    %eax,%edx
  80197f:	85 d2                	test   %edx,%edx
  801981:	78 52                	js     8019d5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801983:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801986:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198d:	8b 00                	mov    (%eax),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 75 fb ff ff       	call   80150c <dev_lookup>
  801997:	85 c0                	test   %eax,%eax
  801999:	78 3a                	js     8019d5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80199b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a2:	74 2c                	je     8019d0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019ae:	00 00 00 
	stat->st_isdir = 0;
  8019b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b8:	00 00 00 
	stat->st_dev = dev;
  8019bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019c8:	89 14 24             	mov    %edx,(%esp)
  8019cb:	ff 50 14             	call   *0x14(%eax)
  8019ce:	eb 05                	jmp    8019d5 <fstat+0x74>
		return -E_NOT_SUPP;
  8019d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8019d5:	83 c4 24             	add    $0x24,%esp
  8019d8:	5b                   	pop    %ebx
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ea:	00 
  8019eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	e8 fb 01 00 00       	call   801bf1 <open>
  8019f6:	89 c3                	mov    %eax,%ebx
  8019f8:	85 db                	test   %ebx,%ebx
  8019fa:	78 1b                	js     801a17 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a03:	89 1c 24             	mov    %ebx,(%esp)
  801a06:	e8 56 ff ff ff       	call   801961 <fstat>
  801a0b:	89 c6                	mov    %eax,%esi
	close(fd);
  801a0d:	89 1c 24             	mov    %ebx,(%esp)
  801a10:	e8 cd fb ff ff       	call   8015e2 <close>
	return r;
  801a15:	89 f0                	mov    %esi,%eax
}
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	5b                   	pop    %ebx
  801a1b:	5e                   	pop    %esi
  801a1c:	5d                   	pop    %ebp
  801a1d:	c3                   	ret    

00801a1e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	56                   	push   %esi
  801a22:	53                   	push   %ebx
  801a23:	83 ec 10             	sub    $0x10,%esp
  801a26:	89 c6                	mov    %eax,%esi
  801a28:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a2a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a31:	75 11                	jne    801a44 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a3a:	e8 60 09 00 00       	call   80239f <ipc_find_env>
  801a3f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a44:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a4b:	00 
  801a4c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a53:	00 
  801a54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a58:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5d:	89 04 24             	mov    %eax,(%esp)
  801a60:	e8 d3 08 00 00       	call   802338 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a65:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a6c:	00 
  801a6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a78:	e8 53 08 00 00       	call   8022d0 <ipc_recv>
}
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a90:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a98:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa2:	b8 02 00 00 00       	mov    $0x2,%eax
  801aa7:	e8 72 ff ff ff       	call   801a1e <fsipc>
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <devfile_flush>:
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801abf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ac9:	e8 50 ff ff ff       	call   801a1e <fsipc>
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <devfile_stat>:
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 14             	sub    $0x14,%esp
  801ad7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aea:	b8 05 00 00 00       	mov    $0x5,%eax
  801aef:	e8 2a ff ff ff       	call   801a1e <fsipc>
  801af4:	89 c2                	mov    %eax,%edx
  801af6:	85 d2                	test   %edx,%edx
  801af8:	78 2b                	js     801b25 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801afa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b01:	00 
  801b02:	89 1c 24             	mov    %ebx,(%esp)
  801b05:	e8 8d ef ff ff       	call   800a97 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b0a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b15:	a1 84 50 80 00       	mov    0x805084,%eax
  801b1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b25:	83 c4 14             	add    $0x14,%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <devfile_write>:
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801b31:	c7 44 24 08 58 2d 80 	movl   $0x802d58,0x8(%esp)
  801b38:	00 
  801b39:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801b40:	00 
  801b41:	c7 04 24 76 2d 80 00 	movl   $0x802d76,(%esp)
  801b48:	e8 29 e8 ff ff       	call   800376 <_panic>

00801b4d <devfile_read>:
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	83 ec 10             	sub    $0x10,%esp
  801b55:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b58:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b63:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b69:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b73:	e8 a6 fe ff ff       	call   801a1e <fsipc>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 6a                	js     801be8 <devfile_read+0x9b>
	assert(r <= n);
  801b7e:	39 c6                	cmp    %eax,%esi
  801b80:	73 24                	jae    801ba6 <devfile_read+0x59>
  801b82:	c7 44 24 0c 81 2d 80 	movl   $0x802d81,0xc(%esp)
  801b89:	00 
  801b8a:	c7 44 24 08 88 2d 80 	movl   $0x802d88,0x8(%esp)
  801b91:	00 
  801b92:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b99:	00 
  801b9a:	c7 04 24 76 2d 80 00 	movl   $0x802d76,(%esp)
  801ba1:	e8 d0 e7 ff ff       	call   800376 <_panic>
	assert(r <= PGSIZE);
  801ba6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bab:	7e 24                	jle    801bd1 <devfile_read+0x84>
  801bad:	c7 44 24 0c 9d 2d 80 	movl   $0x802d9d,0xc(%esp)
  801bb4:	00 
  801bb5:	c7 44 24 08 88 2d 80 	movl   $0x802d88,0x8(%esp)
  801bbc:	00 
  801bbd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bc4:	00 
  801bc5:	c7 04 24 76 2d 80 00 	movl   $0x802d76,(%esp)
  801bcc:	e8 a5 e7 ff ff       	call   800376 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bdc:	00 
  801bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be0:	89 04 24             	mov    %eax,(%esp)
  801be3:	e8 4c f0 ff ff       	call   800c34 <memmove>
}
  801be8:	89 d8                	mov    %ebx,%eax
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <open>:
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	53                   	push   %ebx
  801bf5:	83 ec 24             	sub    $0x24,%esp
  801bf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801bfb:	89 1c 24             	mov    %ebx,(%esp)
  801bfe:	e8 5d ee ff ff       	call   800a60 <strlen>
  801c03:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c08:	7f 60                	jg     801c6a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801c0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0d:	89 04 24             	mov    %eax,(%esp)
  801c10:	e8 52 f8 ff ff       	call   801467 <fd_alloc>
  801c15:	89 c2                	mov    %eax,%edx
  801c17:	85 d2                	test   %edx,%edx
  801c19:	78 54                	js     801c6f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801c1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c1f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c26:	e8 6c ee ff ff       	call   800a97 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c36:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3b:	e8 de fd ff ff       	call   801a1e <fsipc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	85 c0                	test   %eax,%eax
  801c44:	79 17                	jns    801c5d <open+0x6c>
		fd_close(fd, 0);
  801c46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c4d:	00 
  801c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c51:	89 04 24             	mov    %eax,(%esp)
  801c54:	e8 08 f9 ff ff       	call   801561 <fd_close>
		return r;
  801c59:	89 d8                	mov    %ebx,%eax
  801c5b:	eb 12                	jmp    801c6f <open+0x7e>
	return fd2num(fd);
  801c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c60:	89 04 24             	mov    %eax,(%esp)
  801c63:	e8 d8 f7 ff ff       	call   801440 <fd2num>
  801c68:	eb 05                	jmp    801c6f <open+0x7e>
		return -E_BAD_PATH;
  801c6a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801c6f:	83 c4 24             	add    $0x24,%esp
  801c72:	5b                   	pop    %ebx
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c80:	b8 08 00 00 00       	mov    $0x8,%eax
  801c85:	e8 94 fd ff ff       	call   801a1e <fsipc>
}
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	83 ec 10             	sub    $0x10,%esp
  801c94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c97:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9a:	89 04 24             	mov    %eax,(%esp)
  801c9d:	e8 ae f7 ff ff       	call   801450 <fd2data>
  801ca2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ca4:	c7 44 24 04 a9 2d 80 	movl   $0x802da9,0x4(%esp)
  801cab:	00 
  801cac:	89 1c 24             	mov    %ebx,(%esp)
  801caf:	e8 e3 ed ff ff       	call   800a97 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cb4:	8b 46 04             	mov    0x4(%esi),%eax
  801cb7:	2b 06                	sub    (%esi),%eax
  801cb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cbf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cc6:	00 00 00 
	stat->st_dev = &devpipe;
  801cc9:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801cd0:	30 80 00 
	return 0;
}
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	53                   	push   %ebx
  801ce3:	83 ec 14             	sub    $0x14,%esp
  801ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ce9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ced:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf4:	e8 61 f2 ff ff       	call   800f5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cf9:	89 1c 24             	mov    %ebx,(%esp)
  801cfc:	e8 4f f7 ff ff       	call   801450 <fd2data>
  801d01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0c:	e8 49 f2 ff ff       	call   800f5a <sys_page_unmap>
}
  801d11:	83 c4 14             	add    $0x14,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    

00801d17 <_pipeisclosed>:
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	57                   	push   %edi
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 2c             	sub    $0x2c,%esp
  801d20:	89 c6                	mov    %eax,%esi
  801d22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801d25:	a1 08 40 80 00       	mov    0x804008,%eax
  801d2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d2d:	89 34 24             	mov    %esi,(%esp)
  801d30:	e8 a2 06 00 00       	call   8023d7 <pageref>
  801d35:	89 c7                	mov    %eax,%edi
  801d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3a:	89 04 24             	mov    %eax,(%esp)
  801d3d:	e8 95 06 00 00       	call   8023d7 <pageref>
  801d42:	39 c7                	cmp    %eax,%edi
  801d44:	0f 94 c2             	sete   %dl
  801d47:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d4a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801d50:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d53:	39 fb                	cmp    %edi,%ebx
  801d55:	74 21                	je     801d78 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801d57:	84 d2                	test   %dl,%dl
  801d59:	74 ca                	je     801d25 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d5b:	8b 51 58             	mov    0x58(%ecx),%edx
  801d5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d62:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d6a:	c7 04 24 b0 2d 80 00 	movl   $0x802db0,(%esp)
  801d71:	e8 f9 e6 ff ff       	call   80046f <cprintf>
  801d76:	eb ad                	jmp    801d25 <_pipeisclosed+0xe>
}
  801d78:	83 c4 2c             	add    $0x2c,%esp
  801d7b:	5b                   	pop    %ebx
  801d7c:	5e                   	pop    %esi
  801d7d:	5f                   	pop    %edi
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <devpipe_write>:
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	57                   	push   %edi
  801d84:	56                   	push   %esi
  801d85:	53                   	push   %ebx
  801d86:	83 ec 1c             	sub    $0x1c,%esp
  801d89:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d8c:	89 34 24             	mov    %esi,(%esp)
  801d8f:	e8 bc f6 ff ff       	call   801450 <fd2data>
  801d94:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d96:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9b:	eb 45                	jmp    801de2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801d9d:	89 da                	mov    %ebx,%edx
  801d9f:	89 f0                	mov    %esi,%eax
  801da1:	e8 71 ff ff ff       	call   801d17 <_pipeisclosed>
  801da6:	85 c0                	test   %eax,%eax
  801da8:	75 41                	jne    801deb <devpipe_write+0x6b>
			sys_yield();
  801daa:	e8 e5 f0 ff ff       	call   800e94 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801daf:	8b 43 04             	mov    0x4(%ebx),%eax
  801db2:	8b 0b                	mov    (%ebx),%ecx
  801db4:	8d 51 20             	lea    0x20(%ecx),%edx
  801db7:	39 d0                	cmp    %edx,%eax
  801db9:	73 e2                	jae    801d9d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dbe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dc2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dc5:	99                   	cltd   
  801dc6:	c1 ea 1b             	shr    $0x1b,%edx
  801dc9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801dcc:	83 e1 1f             	and    $0x1f,%ecx
  801dcf:	29 d1                	sub    %edx,%ecx
  801dd1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801dd5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801dd9:	83 c0 01             	add    $0x1,%eax
  801ddc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ddf:	83 c7 01             	add    $0x1,%edi
  801de2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801de5:	75 c8                	jne    801daf <devpipe_write+0x2f>
	return i;
  801de7:	89 f8                	mov    %edi,%eax
  801de9:	eb 05                	jmp    801df0 <devpipe_write+0x70>
				return 0;
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df0:	83 c4 1c             	add    $0x1c,%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <devpipe_read>:
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	57                   	push   %edi
  801dfc:	56                   	push   %esi
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 1c             	sub    $0x1c,%esp
  801e01:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e04:	89 3c 24             	mov    %edi,(%esp)
  801e07:	e8 44 f6 ff ff       	call   801450 <fd2data>
  801e0c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e0e:	be 00 00 00 00       	mov    $0x0,%esi
  801e13:	eb 3d                	jmp    801e52 <devpipe_read+0x5a>
			if (i > 0)
  801e15:	85 f6                	test   %esi,%esi
  801e17:	74 04                	je     801e1d <devpipe_read+0x25>
				return i;
  801e19:	89 f0                	mov    %esi,%eax
  801e1b:	eb 43                	jmp    801e60 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801e1d:	89 da                	mov    %ebx,%edx
  801e1f:	89 f8                	mov    %edi,%eax
  801e21:	e8 f1 fe ff ff       	call   801d17 <_pipeisclosed>
  801e26:	85 c0                	test   %eax,%eax
  801e28:	75 31                	jne    801e5b <devpipe_read+0x63>
			sys_yield();
  801e2a:	e8 65 f0 ff ff       	call   800e94 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e2f:	8b 03                	mov    (%ebx),%eax
  801e31:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e34:	74 df                	je     801e15 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e36:	99                   	cltd   
  801e37:	c1 ea 1b             	shr    $0x1b,%edx
  801e3a:	01 d0                	add    %edx,%eax
  801e3c:	83 e0 1f             	and    $0x1f,%eax
  801e3f:	29 d0                	sub    %edx,%eax
  801e41:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e49:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e4c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e4f:	83 c6 01             	add    $0x1,%esi
  801e52:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e55:	75 d8                	jne    801e2f <devpipe_read+0x37>
	return i;
  801e57:	89 f0                	mov    %esi,%eax
  801e59:	eb 05                	jmp    801e60 <devpipe_read+0x68>
				return 0;
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e60:	83 c4 1c             	add    $0x1c,%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5f                   	pop    %edi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <pipe>:
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e73:	89 04 24             	mov    %eax,(%esp)
  801e76:	e8 ec f5 ff ff       	call   801467 <fd_alloc>
  801e7b:	89 c2                	mov    %eax,%edx
  801e7d:	85 d2                	test   %edx,%edx
  801e7f:	0f 88 4d 01 00 00    	js     801fd2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e85:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e8c:	00 
  801e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9b:	e8 13 f0 ff ff       	call   800eb3 <sys_page_alloc>
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	85 d2                	test   %edx,%edx
  801ea4:	0f 88 28 01 00 00    	js     801fd2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801eaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ead:	89 04 24             	mov    %eax,(%esp)
  801eb0:	e8 b2 f5 ff ff       	call   801467 <fd_alloc>
  801eb5:	89 c3                	mov    %eax,%ebx
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	0f 88 fe 00 00 00    	js     801fbd <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebf:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec6:	00 
  801ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ece:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed5:	e8 d9 ef ff ff       	call   800eb3 <sys_page_alloc>
  801eda:	89 c3                	mov    %eax,%ebx
  801edc:	85 c0                	test   %eax,%eax
  801ede:	0f 88 d9 00 00 00    	js     801fbd <pipe+0x155>
	va = fd2data(fd0);
  801ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee7:	89 04 24             	mov    %eax,(%esp)
  801eea:	e8 61 f5 ff ff       	call   801450 <fd2data>
  801eef:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ef8:	00 
  801ef9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f04:	e8 aa ef ff ff       	call   800eb3 <sys_page_alloc>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	0f 88 97 00 00 00    	js     801faa <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f16:	89 04 24             	mov    %eax,(%esp)
  801f19:	e8 32 f5 ff ff       	call   801450 <fd2data>
  801f1e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f25:	00 
  801f26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f31:	00 
  801f32:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3d:	e8 c5 ef ff ff       	call   800f07 <sys_page_map>
  801f42:	89 c3                	mov    %eax,%ebx
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 52                	js     801f9a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801f48:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801f5d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f66:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f75:	89 04 24             	mov    %eax,(%esp)
  801f78:	e8 c3 f4 ff ff       	call   801440 <fd2num>
  801f7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f80:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 b3 f4 ff ff       	call   801440 <fd2num>
  801f8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f90:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
  801f98:	eb 38                	jmp    801fd2 <pipe+0x16a>
	sys_page_unmap(0, va);
  801f9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa5:	e8 b0 ef ff ff       	call   800f5a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb8:	e8 9d ef ff ff       	call   800f5a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fcb:	e8 8a ef ff ff       	call   800f5a <sys_page_unmap>
  801fd0:	89 d8                	mov    %ebx,%eax
}
  801fd2:	83 c4 30             	add    $0x30,%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <pipeisclosed>:
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	89 04 24             	mov    %eax,(%esp)
  801fec:	e8 c5 f4 ff ff       	call   8014b6 <fd_lookup>
  801ff1:	89 c2                	mov    %eax,%edx
  801ff3:	85 d2                	test   %edx,%edx
  801ff5:	78 15                	js     80200c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffa:	89 04 24             	mov    %eax,(%esp)
  801ffd:	e8 4e f4 ff ff       	call   801450 <fd2data>
	return _pipeisclosed(fd, p);
  802002:	89 c2                	mov    %eax,%edx
  802004:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802007:	e8 0b fd ff ff       	call   801d17 <_pipeisclosed>
}
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	56                   	push   %esi
  802012:	53                   	push   %ebx
  802013:	83 ec 10             	sub    $0x10,%esp
  802016:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802019:	85 f6                	test   %esi,%esi
  80201b:	75 24                	jne    802041 <wait+0x33>
  80201d:	c7 44 24 0c c8 2d 80 	movl   $0x802dc8,0xc(%esp)
  802024:	00 
  802025:	c7 44 24 08 88 2d 80 	movl   $0x802d88,0x8(%esp)
  80202c:	00 
  80202d:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802034:	00 
  802035:	c7 04 24 d3 2d 80 00 	movl   $0x802dd3,(%esp)
  80203c:	e8 35 e3 ff ff       	call   800376 <_panic>
	e = &envs[ENVX(envid)];
  802041:	89 f3                	mov    %esi,%ebx
  802043:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802049:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80204c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802052:	eb 05                	jmp    802059 <wait+0x4b>
		sys_yield();
  802054:	e8 3b ee ff ff       	call   800e94 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802059:	8b 43 48             	mov    0x48(%ebx),%eax
  80205c:	39 f0                	cmp    %esi,%eax
  80205e:	75 07                	jne    802067 <wait+0x59>
  802060:	8b 43 54             	mov    0x54(%ebx),%eax
  802063:	85 c0                	test   %eax,%eax
  802065:	75 ed                	jne    802054 <wait+0x46>
}
  802067:	83 c4 10             	add    $0x10,%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    
  80206e:	66 90                	xchg   %ax,%ax

00802070 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802080:	c7 44 24 04 de 2d 80 	movl   $0x802dde,0x4(%esp)
  802087:	00 
  802088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 04 ea ff ff       	call   800a97 <strcpy>
	return 0;
}
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
  802098:	c9                   	leave  
  802099:	c3                   	ret    

0080209a <devcons_write>:
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	57                   	push   %edi
  80209e:	56                   	push   %esi
  80209f:	53                   	push   %ebx
  8020a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  8020a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8020b1:	eb 31                	jmp    8020e4 <devcons_write+0x4a>
		m = n - tot;
  8020b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8020b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020b8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  8020bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020c0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020c3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020c7:	03 45 0c             	add    0xc(%ebp),%eax
  8020ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ce:	89 3c 24             	mov    %edi,(%esp)
  8020d1:	e8 5e eb ff ff       	call   800c34 <memmove>
		sys_cputs(buf, m);
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	89 3c 24             	mov    %edi,(%esp)
  8020dd:	e8 04 ed ff ff       	call   800de6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020e2:	01 f3                	add    %esi,%ebx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020e9:	72 c8                	jb     8020b3 <devcons_write+0x19>
}
  8020eb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020f1:	5b                   	pop    %ebx
  8020f2:	5e                   	pop    %esi
  8020f3:	5f                   	pop    %edi
  8020f4:	5d                   	pop    %ebp
  8020f5:	c3                   	ret    

008020f6 <devcons_read>:
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  8020fc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802101:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802105:	75 07                	jne    80210e <devcons_read+0x18>
  802107:	eb 2a                	jmp    802133 <devcons_read+0x3d>
		sys_yield();
  802109:	e8 86 ed ff ff       	call   800e94 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80210e:	66 90                	xchg   %ax,%ax
  802110:	e8 ef ec ff ff       	call   800e04 <sys_cgetc>
  802115:	85 c0                	test   %eax,%eax
  802117:	74 f0                	je     802109 <devcons_read+0x13>
	if (c < 0)
  802119:	85 c0                	test   %eax,%eax
  80211b:	78 16                	js     802133 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80211d:	83 f8 04             	cmp    $0x4,%eax
  802120:	74 0c                	je     80212e <devcons_read+0x38>
	*(char*)vbuf = c;
  802122:	8b 55 0c             	mov    0xc(%ebp),%edx
  802125:	88 02                	mov    %al,(%edx)
	return 1;
  802127:	b8 01 00 00 00       	mov    $0x1,%eax
  80212c:	eb 05                	jmp    802133 <devcons_read+0x3d>
		return 0;
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802133:	c9                   	leave  
  802134:	c3                   	ret    

00802135 <cputchar>:
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80213b:	8b 45 08             	mov    0x8(%ebp),%eax
  80213e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802141:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802148:	00 
  802149:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80214c:	89 04 24             	mov    %eax,(%esp)
  80214f:	e8 92 ec ff ff       	call   800de6 <sys_cputs>
}
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <getchar>:
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80215c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802163:	00 
  802164:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802167:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802172:	e8 ce f5 ff ff       	call   801745 <read>
	if (r < 0)
  802177:	85 c0                	test   %eax,%eax
  802179:	78 0f                	js     80218a <getchar+0x34>
	if (r < 1)
  80217b:	85 c0                	test   %eax,%eax
  80217d:	7e 06                	jle    802185 <getchar+0x2f>
	return c;
  80217f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802183:	eb 05                	jmp    80218a <getchar+0x34>
		return -E_EOF;
  802185:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80218a:	c9                   	leave  
  80218b:	c3                   	ret    

0080218c <iscons>:
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802195:	89 44 24 04          	mov    %eax,0x4(%esp)
  802199:	8b 45 08             	mov    0x8(%ebp),%eax
  80219c:	89 04 24             	mov    %eax,(%esp)
  80219f:	e8 12 f3 ff ff       	call   8014b6 <fd_lookup>
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 11                	js     8021b9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021b1:	39 10                	cmp    %edx,(%eax)
  8021b3:	0f 94 c0             	sete   %al
  8021b6:	0f b6 c0             	movzbl %al,%eax
}
  8021b9:	c9                   	leave  
  8021ba:	c3                   	ret    

008021bb <opencons>:
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8021c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c4:	89 04 24             	mov    %eax,(%esp)
  8021c7:	e8 9b f2 ff ff       	call   801467 <fd_alloc>
		return r;
  8021cc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	78 40                	js     802212 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021d9:	00 
  8021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e8:	e8 c6 ec ff ff       	call   800eb3 <sys_page_alloc>
		return r;
  8021ed:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	78 1f                	js     802212 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8021f3:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802201:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802208:	89 04 24             	mov    %eax,(%esp)
  80220b:	e8 30 f2 ff ff       	call   801440 <fd2num>
  802210:	89 c2                	mov    %eax,%edx
}
  802212:	89 d0                	mov    %edx,%eax
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  80221c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802223:	75 70                	jne    802295 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802225:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80222c:	00 
  80222d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802234:	ee 
  802235:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80223c:	e8 72 ec ff ff       	call   800eb3 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  802241:	85 c0                	test   %eax,%eax
  802243:	79 1c                	jns    802261 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  802245:	c7 44 24 08 ec 2d 80 	movl   $0x802dec,0x8(%esp)
  80224c:	00 
  80224d:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  802254:	00 
  802255:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  80225c:	e8 15 e1 ff ff       	call   800376 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  802261:	c7 44 24 04 9f 22 80 	movl   $0x80229f,0x4(%esp)
  802268:	00 
  802269:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802270:	e8 de ed ff ff       	call   801053 <sys_env_set_pgfault_upcall>
        if(r < 0)
  802275:	85 c0                	test   %eax,%eax
  802277:	79 1c                	jns    802295 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  802279:	c7 44 24 08 14 2e 80 	movl   $0x802e14,0x8(%esp)
  802280:	00 
  802281:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  802288:	00 
  802289:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  802290:	e8 e1 e0 ff ff       	call   800376 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802295:	8b 45 08             	mov    0x8(%ebp),%eax
  802298:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80229d:	c9                   	leave  
  80229e:	c3                   	ret    

0080229f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80229f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022a0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022a5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022a7:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  8022aa:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  8022ae:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  8022b2:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  8022b4:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  8022b6:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  8022b7:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  8022ba:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  8022bc:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  8022bf:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  8022c0:	83 c4 04             	add    $0x4,%esp
    popf;
  8022c3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  8022c4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  8022c5:	c3                   	ret    
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	56                   	push   %esi
  8022d4:	53                   	push   %ebx
  8022d5:	83 ec 10             	sub    $0x10,%esp
  8022d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8022db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022de:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  8022e1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  8022e3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8022e8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  8022eb:	89 04 24             	mov    %eax,(%esp)
  8022ee:	e8 d6 ed ff ff       	call   8010c9 <sys_ipc_recv>
    if(r < 0){
  8022f3:	85 c0                	test   %eax,%eax
  8022f5:	79 16                	jns    80230d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  8022f7:	85 f6                	test   %esi,%esi
  8022f9:	74 06                	je     802301 <ipc_recv+0x31>
            *from_env_store = 0;
  8022fb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802301:	85 db                	test   %ebx,%ebx
  802303:	74 2c                	je     802331 <ipc_recv+0x61>
            *perm_store = 0;
  802305:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80230b:	eb 24                	jmp    802331 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80230d:	85 f6                	test   %esi,%esi
  80230f:	74 0a                	je     80231b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802311:	a1 08 40 80 00       	mov    0x804008,%eax
  802316:	8b 40 74             	mov    0x74(%eax),%eax
  802319:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80231b:	85 db                	test   %ebx,%ebx
  80231d:	74 0a                	je     802329 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80231f:	a1 08 40 80 00       	mov    0x804008,%eax
  802324:	8b 40 78             	mov    0x78(%eax),%eax
  802327:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802329:	a1 08 40 80 00       	mov    0x804008,%eax
  80232e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802331:	83 c4 10             	add    $0x10,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    

00802338 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	57                   	push   %edi
  80233c:	56                   	push   %esi
  80233d:	53                   	push   %ebx
  80233e:	83 ec 1c             	sub    $0x1c,%esp
  802341:	8b 7d 08             	mov    0x8(%ebp),%edi
  802344:	8b 75 0c             	mov    0xc(%ebp),%esi
  802347:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80234a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80234c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802351:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802354:	8b 45 14             	mov    0x14(%ebp),%eax
  802357:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80235b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80235f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802363:	89 3c 24             	mov    %edi,(%esp)
  802366:	e8 3b ed ff ff       	call   8010a6 <sys_ipc_try_send>
        if(r == 0){
  80236b:	85 c0                	test   %eax,%eax
  80236d:	74 28                	je     802397 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80236f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802372:	74 1c                	je     802390 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  802374:	c7 44 24 08 56 2e 80 	movl   $0x802e56,0x8(%esp)
  80237b:	00 
  80237c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802383:	00 
  802384:	c7 04 24 6d 2e 80 00 	movl   $0x802e6d,(%esp)
  80238b:	e8 e6 df ff ff       	call   800376 <_panic>
        }
        sys_yield();
  802390:	e8 ff ea ff ff       	call   800e94 <sys_yield>
    }
  802395:	eb bd                	jmp    802354 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802397:	83 c4 1c             	add    $0x1c,%esp
  80239a:	5b                   	pop    %ebx
  80239b:	5e                   	pop    %esi
  80239c:	5f                   	pop    %edi
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    

0080239f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023a5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023aa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023ad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023b3:	8b 52 50             	mov    0x50(%edx),%edx
  8023b6:	39 ca                	cmp    %ecx,%edx
  8023b8:	75 0d                	jne    8023c7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8023ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023bd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8023c2:	8b 40 40             	mov    0x40(%eax),%eax
  8023c5:	eb 0e                	jmp    8023d5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  8023c7:	83 c0 01             	add    $0x1,%eax
  8023ca:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023cf:	75 d9                	jne    8023aa <ipc_find_env+0xb>
	return 0;
  8023d1:	66 b8 00 00          	mov    $0x0,%ax
}
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    

008023d7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023d7:	55                   	push   %ebp
  8023d8:	89 e5                	mov    %esp,%ebp
  8023da:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023dd:	89 d0                	mov    %edx,%eax
  8023df:	c1 e8 16             	shr    $0x16,%eax
  8023e2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023e9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8023ee:	f6 c1 01             	test   $0x1,%cl
  8023f1:	74 1d                	je     802410 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8023f3:	c1 ea 0c             	shr    $0xc,%edx
  8023f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023fd:	f6 c2 01             	test   $0x1,%dl
  802400:	74 0e                	je     802410 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802402:	c1 ea 0c             	shr    $0xc,%edx
  802405:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80240c:	ef 
  80240d:	0f b7 c0             	movzwl %ax,%eax
}
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    
  802412:	66 90                	xchg   %ax,%ax
  802414:	66 90                	xchg   %ax,%ax
  802416:	66 90                	xchg   %ax,%ax
  802418:	66 90                	xchg   %ax,%ax
  80241a:	66 90                	xchg   %ax,%ax
  80241c:	66 90                	xchg   %ax,%ax
  80241e:	66 90                	xchg   %ax,%ax

00802420 <__udivdi3>:
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	83 ec 0c             	sub    $0xc,%esp
  802426:	8b 44 24 28          	mov    0x28(%esp),%eax
  80242a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80242e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802432:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802436:	85 c0                	test   %eax,%eax
  802438:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80243c:	89 ea                	mov    %ebp,%edx
  80243e:	89 0c 24             	mov    %ecx,(%esp)
  802441:	75 2d                	jne    802470 <__udivdi3+0x50>
  802443:	39 e9                	cmp    %ebp,%ecx
  802445:	77 61                	ja     8024a8 <__udivdi3+0x88>
  802447:	85 c9                	test   %ecx,%ecx
  802449:	89 ce                	mov    %ecx,%esi
  80244b:	75 0b                	jne    802458 <__udivdi3+0x38>
  80244d:	b8 01 00 00 00       	mov    $0x1,%eax
  802452:	31 d2                	xor    %edx,%edx
  802454:	f7 f1                	div    %ecx
  802456:	89 c6                	mov    %eax,%esi
  802458:	31 d2                	xor    %edx,%edx
  80245a:	89 e8                	mov    %ebp,%eax
  80245c:	f7 f6                	div    %esi
  80245e:	89 c5                	mov    %eax,%ebp
  802460:	89 f8                	mov    %edi,%eax
  802462:	f7 f6                	div    %esi
  802464:	89 ea                	mov    %ebp,%edx
  802466:	83 c4 0c             	add    $0xc,%esp
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	39 e8                	cmp    %ebp,%eax
  802472:	77 24                	ja     802498 <__udivdi3+0x78>
  802474:	0f bd e8             	bsr    %eax,%ebp
  802477:	83 f5 1f             	xor    $0x1f,%ebp
  80247a:	75 3c                	jne    8024b8 <__udivdi3+0x98>
  80247c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802480:	39 34 24             	cmp    %esi,(%esp)
  802483:	0f 86 9f 00 00 00    	jbe    802528 <__udivdi3+0x108>
  802489:	39 d0                	cmp    %edx,%eax
  80248b:	0f 82 97 00 00 00    	jb     802528 <__udivdi3+0x108>
  802491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802498:	31 d2                	xor    %edx,%edx
  80249a:	31 c0                	xor    %eax,%eax
  80249c:	83 c4 0c             	add    $0xc,%esp
  80249f:	5e                   	pop    %esi
  8024a0:	5f                   	pop    %edi
  8024a1:	5d                   	pop    %ebp
  8024a2:	c3                   	ret    
  8024a3:	90                   	nop
  8024a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a8:	89 f8                	mov    %edi,%eax
  8024aa:	f7 f1                	div    %ecx
  8024ac:	31 d2                	xor    %edx,%edx
  8024ae:	83 c4 0c             	add    $0xc,%esp
  8024b1:	5e                   	pop    %esi
  8024b2:	5f                   	pop    %edi
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    
  8024b5:	8d 76 00             	lea    0x0(%esi),%esi
  8024b8:	89 e9                	mov    %ebp,%ecx
  8024ba:	8b 3c 24             	mov    (%esp),%edi
  8024bd:	d3 e0                	shl    %cl,%eax
  8024bf:	89 c6                	mov    %eax,%esi
  8024c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8024c6:	29 e8                	sub    %ebp,%eax
  8024c8:	89 c1                	mov    %eax,%ecx
  8024ca:	d3 ef                	shr    %cl,%edi
  8024cc:	89 e9                	mov    %ebp,%ecx
  8024ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8024d2:	8b 3c 24             	mov    (%esp),%edi
  8024d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8024d9:	89 d6                	mov    %edx,%esi
  8024db:	d3 e7                	shl    %cl,%edi
  8024dd:	89 c1                	mov    %eax,%ecx
  8024df:	89 3c 24             	mov    %edi,(%esp)
  8024e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024e6:	d3 ee                	shr    %cl,%esi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	d3 e2                	shl    %cl,%edx
  8024ec:	89 c1                	mov    %eax,%ecx
  8024ee:	d3 ef                	shr    %cl,%edi
  8024f0:	09 d7                	or     %edx,%edi
  8024f2:	89 f2                	mov    %esi,%edx
  8024f4:	89 f8                	mov    %edi,%eax
  8024f6:	f7 74 24 08          	divl   0x8(%esp)
  8024fa:	89 d6                	mov    %edx,%esi
  8024fc:	89 c7                	mov    %eax,%edi
  8024fe:	f7 24 24             	mull   (%esp)
  802501:	39 d6                	cmp    %edx,%esi
  802503:	89 14 24             	mov    %edx,(%esp)
  802506:	72 30                	jb     802538 <__udivdi3+0x118>
  802508:	8b 54 24 04          	mov    0x4(%esp),%edx
  80250c:	89 e9                	mov    %ebp,%ecx
  80250e:	d3 e2                	shl    %cl,%edx
  802510:	39 c2                	cmp    %eax,%edx
  802512:	73 05                	jae    802519 <__udivdi3+0xf9>
  802514:	3b 34 24             	cmp    (%esp),%esi
  802517:	74 1f                	je     802538 <__udivdi3+0x118>
  802519:	89 f8                	mov    %edi,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	e9 7a ff ff ff       	jmp    80249c <__udivdi3+0x7c>
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	31 d2                	xor    %edx,%edx
  80252a:	b8 01 00 00 00       	mov    $0x1,%eax
  80252f:	e9 68 ff ff ff       	jmp    80249c <__udivdi3+0x7c>
  802534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802538:	8d 47 ff             	lea    -0x1(%edi),%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	83 c4 0c             	add    $0xc,%esp
  802540:	5e                   	pop    %esi
  802541:	5f                   	pop    %edi
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    
  802544:	66 90                	xchg   %ax,%ax
  802546:	66 90                	xchg   %ax,%ax
  802548:	66 90                	xchg   %ax,%ax
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <__umoddi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	83 ec 14             	sub    $0x14,%esp
  802556:	8b 44 24 28          	mov    0x28(%esp),%eax
  80255a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80255e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802562:	89 c7                	mov    %eax,%edi
  802564:	89 44 24 04          	mov    %eax,0x4(%esp)
  802568:	8b 44 24 30          	mov    0x30(%esp),%eax
  80256c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802570:	89 34 24             	mov    %esi,(%esp)
  802573:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802577:	85 c0                	test   %eax,%eax
  802579:	89 c2                	mov    %eax,%edx
  80257b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80257f:	75 17                	jne    802598 <__umoddi3+0x48>
  802581:	39 fe                	cmp    %edi,%esi
  802583:	76 4b                	jbe    8025d0 <__umoddi3+0x80>
  802585:	89 c8                	mov    %ecx,%eax
  802587:	89 fa                	mov    %edi,%edx
  802589:	f7 f6                	div    %esi
  80258b:	89 d0                	mov    %edx,%eax
  80258d:	31 d2                	xor    %edx,%edx
  80258f:	83 c4 14             	add    $0x14,%esp
  802592:	5e                   	pop    %esi
  802593:	5f                   	pop    %edi
  802594:	5d                   	pop    %ebp
  802595:	c3                   	ret    
  802596:	66 90                	xchg   %ax,%ax
  802598:	39 f8                	cmp    %edi,%eax
  80259a:	77 54                	ja     8025f0 <__umoddi3+0xa0>
  80259c:	0f bd e8             	bsr    %eax,%ebp
  80259f:	83 f5 1f             	xor    $0x1f,%ebp
  8025a2:	75 5c                	jne    802600 <__umoddi3+0xb0>
  8025a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8025a8:	39 3c 24             	cmp    %edi,(%esp)
  8025ab:	0f 87 e7 00 00 00    	ja     802698 <__umoddi3+0x148>
  8025b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025b5:	29 f1                	sub    %esi,%ecx
  8025b7:	19 c7                	sbb    %eax,%edi
  8025b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025c9:	83 c4 14             	add    $0x14,%esp
  8025cc:	5e                   	pop    %esi
  8025cd:	5f                   	pop    %edi
  8025ce:	5d                   	pop    %ebp
  8025cf:	c3                   	ret    
  8025d0:	85 f6                	test   %esi,%esi
  8025d2:	89 f5                	mov    %esi,%ebp
  8025d4:	75 0b                	jne    8025e1 <__umoddi3+0x91>
  8025d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	f7 f6                	div    %esi
  8025df:	89 c5                	mov    %eax,%ebp
  8025e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025e5:	31 d2                	xor    %edx,%edx
  8025e7:	f7 f5                	div    %ebp
  8025e9:	89 c8                	mov    %ecx,%eax
  8025eb:	f7 f5                	div    %ebp
  8025ed:	eb 9c                	jmp    80258b <__umoddi3+0x3b>
  8025ef:	90                   	nop
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 fa                	mov    %edi,%edx
  8025f4:	83 c4 14             	add    $0x14,%esp
  8025f7:	5e                   	pop    %esi
  8025f8:	5f                   	pop    %edi
  8025f9:	5d                   	pop    %ebp
  8025fa:	c3                   	ret    
  8025fb:	90                   	nop
  8025fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802600:	8b 04 24             	mov    (%esp),%eax
  802603:	be 20 00 00 00       	mov    $0x20,%esi
  802608:	89 e9                	mov    %ebp,%ecx
  80260a:	29 ee                	sub    %ebp,%esi
  80260c:	d3 e2                	shl    %cl,%edx
  80260e:	89 f1                	mov    %esi,%ecx
  802610:	d3 e8                	shr    %cl,%eax
  802612:	89 e9                	mov    %ebp,%ecx
  802614:	89 44 24 04          	mov    %eax,0x4(%esp)
  802618:	8b 04 24             	mov    (%esp),%eax
  80261b:	09 54 24 04          	or     %edx,0x4(%esp)
  80261f:	89 fa                	mov    %edi,%edx
  802621:	d3 e0                	shl    %cl,%eax
  802623:	89 f1                	mov    %esi,%ecx
  802625:	89 44 24 08          	mov    %eax,0x8(%esp)
  802629:	8b 44 24 10          	mov    0x10(%esp),%eax
  80262d:	d3 ea                	shr    %cl,%edx
  80262f:	89 e9                	mov    %ebp,%ecx
  802631:	d3 e7                	shl    %cl,%edi
  802633:	89 f1                	mov    %esi,%ecx
  802635:	d3 e8                	shr    %cl,%eax
  802637:	89 e9                	mov    %ebp,%ecx
  802639:	09 f8                	or     %edi,%eax
  80263b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80263f:	f7 74 24 04          	divl   0x4(%esp)
  802643:	d3 e7                	shl    %cl,%edi
  802645:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802649:	89 d7                	mov    %edx,%edi
  80264b:	f7 64 24 08          	mull   0x8(%esp)
  80264f:	39 d7                	cmp    %edx,%edi
  802651:	89 c1                	mov    %eax,%ecx
  802653:	89 14 24             	mov    %edx,(%esp)
  802656:	72 2c                	jb     802684 <__umoddi3+0x134>
  802658:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80265c:	72 22                	jb     802680 <__umoddi3+0x130>
  80265e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802662:	29 c8                	sub    %ecx,%eax
  802664:	19 d7                	sbb    %edx,%edi
  802666:	89 e9                	mov    %ebp,%ecx
  802668:	89 fa                	mov    %edi,%edx
  80266a:	d3 e8                	shr    %cl,%eax
  80266c:	89 f1                	mov    %esi,%ecx
  80266e:	d3 e2                	shl    %cl,%edx
  802670:	89 e9                	mov    %ebp,%ecx
  802672:	d3 ef                	shr    %cl,%edi
  802674:	09 d0                	or     %edx,%eax
  802676:	89 fa                	mov    %edi,%edx
  802678:	83 c4 14             	add    $0x14,%esp
  80267b:	5e                   	pop    %esi
  80267c:	5f                   	pop    %edi
  80267d:	5d                   	pop    %ebp
  80267e:	c3                   	ret    
  80267f:	90                   	nop
  802680:	39 d7                	cmp    %edx,%edi
  802682:	75 da                	jne    80265e <__umoddi3+0x10e>
  802684:	8b 14 24             	mov    (%esp),%edx
  802687:	89 c1                	mov    %eax,%ecx
  802689:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80268d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802691:	eb cb                	jmp    80265e <__umoddi3+0x10e>
  802693:	90                   	nop
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80269c:	0f 82 0f ff ff ff    	jb     8025b1 <__umoddi3+0x61>
  8026a2:	e9 1a ff ff ff       	jmp    8025c1 <__umoddi3+0x71>
