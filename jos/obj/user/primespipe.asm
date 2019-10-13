
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 8c 02 00 00       	call   8002bd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004c:	00 
  80004d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800051:	89 1c 24             	mov    %ebx,(%esp)
  800054:	e8 2e 17 00 00       	call   801787 <readn>
  800059:	83 f8 04             	cmp    $0x4,%eax
  80005c:	74 2e                	je     80008c <primeproc+0x59>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005e:	85 c0                	test   %eax,%eax
  800060:	ba 00 00 00 00       	mov    $0x0,%edx
  800065:	0f 4e d0             	cmovle %eax,%edx
  800068:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800070:	c7 44 24 08 00 26 80 	movl   $0x802600,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  800087:	e8 92 02 00 00       	call   80031e <_panic>
	cprintf("%d\n", p);
  80008c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80008f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800093:	c7 04 24 41 26 80 00 	movl   $0x802641,(%esp)
  80009a:	e8 78 03 00 00       	call   800417 <cprintf>
	if ((i=pipe(pfd)) < 0)
  80009f:	89 3c 24             	mov    %edi,(%esp)
  8000a2:	e8 71 1d 00 00       	call   801e18 <pipe>
  8000a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <primeproc+0x9b>
		panic("pipe: %e", i);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 45 26 80 	movl   $0x802645,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  8000c9:	e8 50 02 00 00       	call   80031e <_panic>
	if ((id = fork()) < 0)
  8000ce:	e8 1f 11 00 00       	call   8011f2 <fork>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	79 20                	jns    8000f7 <primeproc+0xc4>
		panic("fork: %e", id);
  8000d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000db:	c7 44 24 08 4e 26 80 	movl   $0x80264e,0x8(%esp)
  8000e2:	00 
  8000e3:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ea:	00 
  8000eb:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  8000f2:	e8 27 02 00 00       	call   80031e <_panic>
	if (id == 0) {
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	75 1b                	jne    800116 <primeproc+0xe3>
		close(fd);
  8000fb:	89 1c 24             	mov    %ebx,(%esp)
  8000fe:	e8 8f 14 00 00       	call   801592 <close>
		close(pfd[1]);
  800103:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800106:	89 04 24             	mov    %eax,(%esp)
  800109:	e8 84 14 00 00       	call   801592 <close>
		fd = pfd[0];
  80010e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800111:	e9 2f ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  800116:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800119:	89 04 24             	mov    %eax,(%esp)
  80011c:	e8 71 14 00 00       	call   801592 <close>
	wfd = pfd[1];
  800121:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800124:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800127:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80012e:	00 
  80012f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800133:	89 1c 24             	mov    %ebx,(%esp)
  800136:	e8 4c 16 00 00       	call   801787 <readn>
  80013b:	83 f8 04             	cmp    $0x4,%eax
  80013e:	74 39                	je     800179 <primeproc+0x146>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800140:	85 c0                	test   %eax,%eax
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	0f 4e d0             	cmovle %eax,%edx
  80014a:	89 54 24 18          	mov    %edx,0x18(%esp)
  80014e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800152:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800156:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015d:	c7 44 24 08 57 26 80 	movl   $0x802657,0x8(%esp)
  800164:	00 
  800165:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80016c:	00 
  80016d:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  800174:	e8 a5 01 00 00       	call   80031e <_panic>
		if (i%p)
  800179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80017c:	99                   	cltd   
  80017d:	f7 7d e0             	idivl  -0x20(%ebp)
  800180:	85 d2                	test   %edx,%edx
  800182:	74 a3                	je     800127 <primeproc+0xf4>
			if ((r=write(wfd, &i, 4)) != 4)
  800184:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80018b:	00 
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	89 3c 24             	mov    %edi,(%esp)
  800193:	e8 3a 16 00 00       	call   8017d2 <write>
  800198:	83 f8 04             	cmp    $0x4,%eax
  80019b:	74 8a                	je     800127 <primeproc+0xf4>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  80019d:	85 c0                	test   %eax,%eax
  80019f:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a4:	0f 4e d0             	cmovle %eax,%edx
  8001a7:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 73 26 80 	movl   $0x802673,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  8001cd:	e8 4c 01 00 00       	call   80031e <_panic>

008001d2 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001d9:	c7 05 00 30 80 00 8d 	movl   $0x80268d,0x803000
  8001e0:	26 80 00 

	if ((i=pipe(p)) < 0)
  8001e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	e8 2a 1c 00 00       	call   801e18 <pipe>
  8001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	79 20                	jns    800215 <umain+0x43>
		panic("pipe: %e", i);
  8001f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f9:	c7 44 24 08 45 26 80 	movl   $0x802645,0x8(%esp)
  800200:	00 
  800201:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800208:	00 
  800209:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  800210:	e8 09 01 00 00       	call   80031e <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  800215:	e8 d8 0f 00 00       	call   8011f2 <fork>
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 20                	jns    80023e <umain+0x6c>
		panic("fork: %e", id);
  80021e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800222:	c7 44 24 08 4e 26 80 	movl   $0x80264e,0x8(%esp)
  800229:	00 
  80022a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800231:	00 
  800232:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  800239:	e8 e0 00 00 00       	call   80031e <_panic>

	if (id == 0) {
  80023e:	85 c0                	test   %eax,%eax
  800240:	75 16                	jne    800258 <umain+0x86>
		close(p[1]);
  800242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	e8 45 13 00 00       	call   801592 <close>
		primeproc(p[0]);
  80024d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 db fd ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  800258:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 2f 13 00 00       	call   801592 <close>

	// feed all the integers through
	for (i=2;; i++)
  800263:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  80026a:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  80026d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800274:	00 
  800275:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	e8 4e 15 00 00       	call   8017d2 <write>
  800284:	83 f8 04             	cmp    $0x4,%eax
  800287:	74 2e                	je     8002b7 <umain+0xe5>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800289:	85 c0                	test   %eax,%eax
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
  800290:	0f 4e d0             	cmovle %eax,%edx
  800293:	89 54 24 10          	mov    %edx,0x10(%esp)
  800297:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029b:	c7 44 24 08 98 26 80 	movl   $0x802698,0x8(%esp)
  8002a2:	00 
  8002a3:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002aa:	00 
  8002ab:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  8002b2:	e8 67 00 00 00       	call   80031e <_panic>
	for (i=2;; i++)
  8002b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
}
  8002bb:	eb b0                	jmp    80026d <umain+0x9b>

008002bd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 10             	sub    $0x10,%esp
  8002c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8002cb:	e8 55 0b 00 00       	call   800e25 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8002d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002dd:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e2:	85 db                	test   %ebx,%ebx
  8002e4:	7e 07                	jle    8002ed <libmain+0x30>
		binaryname = argv[0];
  8002e6:	8b 06                	mov    (%esi),%eax
  8002e8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f1:	89 1c 24             	mov    %ebx,(%esp)
  8002f4:	e8 d9 fe ff ff       	call   8001d2 <umain>

	// exit gracefully
	exit();
  8002f9:	e8 07 00 00 00       	call   800305 <exit>
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80030b:	e8 b5 12 00 00       	call   8015c5 <close_all>
	sys_env_destroy(0);
  800310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800317:	e8 b7 0a 00 00       	call   800dd3 <sys_env_destroy>
}
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800326:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800329:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80032f:	e8 f1 0a 00 00       	call   800e25 <sys_getenvid>
  800334:	8b 55 0c             	mov    0xc(%ebp),%edx
  800337:	89 54 24 10          	mov    %edx,0x10(%esp)
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800342:	89 74 24 08          	mov    %esi,0x8(%esp)
  800346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034a:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  800351:	e8 c1 00 00 00       	call   800417 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800356:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035a:	8b 45 10             	mov    0x10(%ebp),%eax
  80035d:	89 04 24             	mov    %eax,(%esp)
  800360:	e8 51 00 00 00       	call   8003b6 <vcprintf>
	cprintf("\n");
  800365:	c7 04 24 43 26 80 00 	movl   $0x802643,(%esp)
  80036c:	e8 a6 00 00 00       	call   800417 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800371:	cc                   	int3   
  800372:	eb fd                	jmp    800371 <_panic+0x53>

00800374 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	53                   	push   %ebx
  800378:	83 ec 14             	sub    $0x14,%esp
  80037b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037e:	8b 13                	mov    (%ebx),%edx
  800380:	8d 42 01             	lea    0x1(%edx),%eax
  800383:	89 03                	mov    %eax,(%ebx)
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80038c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800391:	75 19                	jne    8003ac <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800393:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80039a:	00 
  80039b:	8d 43 08             	lea    0x8(%ebx),%eax
  80039e:	89 04 24             	mov    %eax,(%esp)
  8003a1:	e8 f0 09 00 00       	call   800d96 <sys_cputs>
		b->idx = 0;
  8003a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003ac:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b0:	83 c4 14             	add    $0x14,%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c6:	00 00 00 
	b.cnt = 0;
  8003c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003da:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003eb:	c7 04 24 74 03 80 00 	movl   $0x800374,(%esp)
  8003f2:	e8 b7 01 00 00       	call   8005ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800401:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	e8 87 09 00 00       	call   800d96 <sys_cputs>

	return b.cnt;
}
  80040f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800420:	89 44 24 04          	mov    %eax,0x4(%esp)
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	e8 87 ff ff ff       	call   8003b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042f:	c9                   	leave  
  800430:	c3                   	ret    
  800431:	66 90                	xchg   %ax,%ax
  800433:	66 90                	xchg   %ax,%ax
  800435:	66 90                	xchg   %ax,%ax
  800437:	66 90                	xchg   %ax,%ax
  800439:	66 90                	xchg   %ax,%ax
  80043b:	66 90                	xchg   %ax,%ax
  80043d:	66 90                	xchg   %ax,%ax
  80043f:	90                   	nop

00800440 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
  800446:	83 ec 3c             	sub    $0x3c,%esp
  800449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044c:	89 d7                	mov    %edx,%edi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 c3                	mov    %eax,%ebx
  800459:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800462:	b9 00 00 00 00       	mov    $0x0,%ecx
  800467:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80046d:	39 d9                	cmp    %ebx,%ecx
  80046f:	72 05                	jb     800476 <printnum+0x36>
  800471:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800474:	77 69                	ja     8004df <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800476:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800479:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80047d:	83 ee 01             	sub    $0x1,%esi
  800480:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800484:	89 44 24 08          	mov    %eax,0x8(%esp)
  800488:	8b 44 24 08          	mov    0x8(%esp),%eax
  80048c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800490:	89 c3                	mov    %eax,%ebx
  800492:	89 d6                	mov    %edx,%esi
  800494:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800497:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80049a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80049e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a5:	89 04 24             	mov    %eax,(%esp)
  8004a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004af:	e8 bc 1e 00 00       	call   802370 <__udivdi3>
  8004b4:	89 d9                	mov    %ebx,%ecx
  8004b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c5:	89 fa                	mov    %edi,%edx
  8004c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ca:	e8 71 ff ff ff       	call   800440 <printnum>
  8004cf:	eb 1b                	jmp    8004ec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	ff d3                	call   *%ebx
  8004dd:	eb 03                	jmp    8004e2 <printnum+0xa2>
  8004df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8004e2:	83 ee 01             	sub    $0x1,%esi
  8004e5:	85 f6                	test   %esi,%esi
  8004e7:	7f e8                	jg     8004d1 <printnum+0x91>
  8004e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	e8 8c 1f 00 00       	call   8024a0 <__umoddi3>
  800514:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800518:	0f be 80 df 26 80 00 	movsbl 0x8026df(%eax),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800525:	ff d0                	call   *%eax
}
  800527:	83 c4 3c             	add    $0x3c,%esp
  80052a:	5b                   	pop    %ebx
  80052b:	5e                   	pop    %esi
  80052c:	5f                   	pop    %edi
  80052d:	5d                   	pop    %ebp
  80052e:	c3                   	ret    

0080052f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800532:	83 fa 01             	cmp    $0x1,%edx
  800535:	7e 0e                	jle    800545 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800537:	8b 10                	mov    (%eax),%edx
  800539:	8d 4a 08             	lea    0x8(%edx),%ecx
  80053c:	89 08                	mov    %ecx,(%eax)
  80053e:	8b 02                	mov    (%edx),%eax
  800540:	8b 52 04             	mov    0x4(%edx),%edx
  800543:	eb 22                	jmp    800567 <getuint+0x38>
	else if (lflag)
  800545:	85 d2                	test   %edx,%edx
  800547:	74 10                	je     800559 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800549:	8b 10                	mov    (%eax),%edx
  80054b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80054e:	89 08                	mov    %ecx,(%eax)
  800550:	8b 02                	mov    (%edx),%eax
  800552:	ba 00 00 00 00       	mov    $0x0,%edx
  800557:	eb 0e                	jmp    800567 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800559:	8b 10                	mov    (%eax),%edx
  80055b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80055e:	89 08                	mov    %ecx,(%eax)
  800560:	8b 02                	mov    (%edx),%eax
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    

00800569 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80056f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800573:	8b 10                	mov    (%eax),%edx
  800575:	3b 50 04             	cmp    0x4(%eax),%edx
  800578:	73 0a                	jae    800584 <sprintputch+0x1b>
		*b->buf++ = ch;
  80057a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80057d:	89 08                	mov    %ecx,(%eax)
  80057f:	8b 45 08             	mov    0x8(%ebp),%eax
  800582:	88 02                	mov    %al,(%edx)
}
  800584:	5d                   	pop    %ebp
  800585:	c3                   	ret    

00800586 <printfmt>:
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80058c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80058f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800593:	8b 45 10             	mov    0x10(%ebp),%eax
  800596:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	e8 02 00 00 00       	call   8005ae <vprintfmt>
}
  8005ac:	c9                   	leave  
  8005ad:	c3                   	ret    

008005ae <vprintfmt>:
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
  8005b1:	57                   	push   %edi
  8005b2:	56                   	push   %esi
  8005b3:	53                   	push   %ebx
  8005b4:	83 ec 3c             	sub    $0x3c,%esp
  8005b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005bd:	eb 1f                	jmp    8005de <vprintfmt+0x30>
			if (ch == '\0'){
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	75 0f                	jne    8005d2 <vprintfmt+0x24>
				color = 0x0100;
  8005c3:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  8005ca:	01 00 00 
  8005cd:	e9 b3 03 00 00       	jmp    800985 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8005d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005dc:	89 f3                	mov    %esi,%ebx
  8005de:	8d 73 01             	lea    0x1(%ebx),%esi
  8005e1:	0f b6 03             	movzbl (%ebx),%eax
  8005e4:	83 f8 25             	cmp    $0x25,%eax
  8005e7:	75 d6                	jne    8005bf <vprintfmt+0x11>
  8005e9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005ed:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005f4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8005fb:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800602:	ba 00 00 00 00       	mov    $0x0,%edx
  800607:	eb 1d                	jmp    800626 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800609:	89 de                	mov    %ebx,%esi
			padc = '-';
  80060b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80060f:	eb 15                	jmp    800626 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800611:	89 de                	mov    %ebx,%esi
			padc = '0';
  800613:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800617:	eb 0d                	jmp    800626 <vprintfmt+0x78>
				width = precision, precision = -1;
  800619:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80061c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80061f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8d 5e 01             	lea    0x1(%esi),%ebx
  800629:	0f b6 0e             	movzbl (%esi),%ecx
  80062c:	0f b6 c1             	movzbl %cl,%eax
  80062f:	83 e9 23             	sub    $0x23,%ecx
  800632:	80 f9 55             	cmp    $0x55,%cl
  800635:	0f 87 2a 03 00 00    	ja     800965 <vprintfmt+0x3b7>
  80063b:	0f b6 c9             	movzbl %cl,%ecx
  80063e:	ff 24 8d 20 28 80 00 	jmp    *0x802820(,%ecx,4)
  800645:	89 de                	mov    %ebx,%esi
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80064c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80064f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800653:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800656:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800659:	83 fb 09             	cmp    $0x9,%ebx
  80065c:	77 36                	ja     800694 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80065e:	83 c6 01             	add    $0x1,%esi
			}
  800661:	eb e9                	jmp    80064c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 48 04             	lea    0x4(%eax),%ecx
  800669:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800671:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800673:	eb 22                	jmp    800697 <vprintfmt+0xe9>
  800675:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800678:	85 c9                	test   %ecx,%ecx
  80067a:	b8 00 00 00 00       	mov    $0x0,%eax
  80067f:	0f 49 c1             	cmovns %ecx,%eax
  800682:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800685:	89 de                	mov    %ebx,%esi
  800687:	eb 9d                	jmp    800626 <vprintfmt+0x78>
  800689:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80068b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800692:	eb 92                	jmp    800626 <vprintfmt+0x78>
  800694:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800697:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069b:	79 89                	jns    800626 <vprintfmt+0x78>
  80069d:	e9 77 ff ff ff       	jmp    800619 <vprintfmt+0x6b>
			lflag++;
  8006a2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8006a5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8006a7:	e9 7a ff ff ff       	jmp    800626 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006c1:	e9 18 ff ff ff       	jmp    8005de <vprintfmt+0x30>
			err = va_arg(ap, int);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	99                   	cltd   
  8006d2:	31 d0                	xor    %edx,%eax
  8006d4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006d6:	83 f8 0f             	cmp    $0xf,%eax
  8006d9:	7f 0b                	jg     8006e6 <vprintfmt+0x138>
  8006db:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  8006e2:	85 d2                	test   %edx,%edx
  8006e4:	75 20                	jne    800706 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  8006e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ea:	c7 44 24 08 f7 26 80 	movl   $0x8026f7,0x8(%esp)
  8006f1:	00 
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	89 04 24             	mov    %eax,(%esp)
  8006fc:	e8 85 fe ff ff       	call   800586 <printfmt>
  800701:	e9 d8 fe ff ff       	jmp    8005de <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800706:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070a:	c7 44 24 08 3a 2c 80 	movl   $0x802c3a,0x8(%esp)
  800711:	00 
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	89 04 24             	mov    %eax,(%esp)
  80071c:	e8 65 fe ff ff       	call   800586 <printfmt>
  800721:	e9 b8 fe ff ff       	jmp    8005de <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800729:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80072c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8d 50 04             	lea    0x4(%eax),%edx
  800735:	89 55 14             	mov    %edx,0x14(%ebp)
  800738:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80073a:	85 f6                	test   %esi,%esi
  80073c:	b8 f0 26 80 00       	mov    $0x8026f0,%eax
  800741:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800744:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800748:	0f 84 97 00 00 00    	je     8007e5 <vprintfmt+0x237>
  80074e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800752:	0f 8e 9b 00 00 00    	jle    8007f3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800758:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80075c:	89 34 24             	mov    %esi,(%esp)
  80075f:	e8 c4 02 00 00       	call   800a28 <strnlen>
  800764:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800767:	29 c2                	sub    %eax,%edx
  800769:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80076c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800770:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800773:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800776:	8b 75 08             	mov    0x8(%ebp),%esi
  800779:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80077c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80077e:	eb 0f                	jmp    80078f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800780:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800784:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80078c:	83 eb 01             	sub    $0x1,%ebx
  80078f:	85 db                	test   %ebx,%ebx
  800791:	7f ed                	jg     800780 <vprintfmt+0x1d2>
  800793:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800796:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800799:	85 d2                	test   %edx,%edx
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a0:	0f 49 c2             	cmovns %edx,%eax
  8007a3:	29 c2                	sub    %eax,%edx
  8007a5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007a8:	89 d7                	mov    %edx,%edi
  8007aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007ad:	eb 50                	jmp    8007ff <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8007af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007b3:	74 1e                	je     8007d3 <vprintfmt+0x225>
  8007b5:	0f be d2             	movsbl %dl,%edx
  8007b8:	83 ea 20             	sub    $0x20,%edx
  8007bb:	83 fa 5e             	cmp    $0x5e,%edx
  8007be:	76 13                	jbe    8007d3 <vprintfmt+0x225>
					putch('?', putdat);
  8007c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007ce:	ff 55 08             	call   *0x8(%ebp)
  8007d1:	eb 0d                	jmp    8007e0 <vprintfmt+0x232>
					putch(ch, putdat);
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007da:	89 04 24             	mov    %eax,(%esp)
  8007dd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e0:	83 ef 01             	sub    $0x1,%edi
  8007e3:	eb 1a                	jmp    8007ff <vprintfmt+0x251>
  8007e5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007e8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007eb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007f1:	eb 0c                	jmp    8007ff <vprintfmt+0x251>
  8007f3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007fc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007ff:	83 c6 01             	add    $0x1,%esi
  800802:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800806:	0f be c2             	movsbl %dl,%eax
  800809:	85 c0                	test   %eax,%eax
  80080b:	74 27                	je     800834 <vprintfmt+0x286>
  80080d:	85 db                	test   %ebx,%ebx
  80080f:	78 9e                	js     8007af <vprintfmt+0x201>
  800811:	83 eb 01             	sub    $0x1,%ebx
  800814:	79 99                	jns    8007af <vprintfmt+0x201>
  800816:	89 f8                	mov    %edi,%eax
  800818:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	89 c3                	mov    %eax,%ebx
  800820:	eb 1a                	jmp    80083c <vprintfmt+0x28e>
				putch(' ', putdat);
  800822:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800826:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80082d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80082f:	83 eb 01             	sub    $0x1,%ebx
  800832:	eb 08                	jmp    80083c <vprintfmt+0x28e>
  800834:	89 fb                	mov    %edi,%ebx
  800836:	8b 75 08             	mov    0x8(%ebp),%esi
  800839:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80083c:	85 db                	test   %ebx,%ebx
  80083e:	7f e2                	jg     800822 <vprintfmt+0x274>
  800840:	89 75 08             	mov    %esi,0x8(%ebp)
  800843:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800846:	e9 93 fd ff ff       	jmp    8005de <vprintfmt+0x30>
	if (lflag >= 2)
  80084b:	83 fa 01             	cmp    $0x1,%edx
  80084e:	7e 16                	jle    800866 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 08             	lea    0x8(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 50 04             	mov    0x4(%eax),%edx
  80085c:	8b 00                	mov    (%eax),%eax
  80085e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800861:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800864:	eb 32                	jmp    800898 <vprintfmt+0x2ea>
	else if (lflag)
  800866:	85 d2                	test   %edx,%edx
  800868:	74 18                	je     800882 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8d 50 04             	lea    0x4(%eax),%edx
  800870:	89 55 14             	mov    %edx,0x14(%ebp)
  800873:	8b 30                	mov    (%eax),%esi
  800875:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800878:	89 f0                	mov    %esi,%eax
  80087a:	c1 f8 1f             	sar    $0x1f,%eax
  80087d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800880:	eb 16                	jmp    800898 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8d 50 04             	lea    0x4(%eax),%edx
  800888:	89 55 14             	mov    %edx,0x14(%ebp)
  80088b:	8b 30                	mov    (%eax),%esi
  80088d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800890:	89 f0                	mov    %esi,%eax
  800892:	c1 f8 1f             	sar    $0x1f,%eax
  800895:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800898:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80089b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80089e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8008a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008a7:	0f 89 80 00 00 00    	jns    80092d <vprintfmt+0x37f>
				putch('-', putdat);
  8008ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008b8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008c1:	f7 d8                	neg    %eax
  8008c3:	83 d2 00             	adc    $0x0,%edx
  8008c6:	f7 da                	neg    %edx
			base = 10;
  8008c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008cd:	eb 5e                	jmp    80092d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8008cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d2:	e8 58 fc ff ff       	call   80052f <getuint>
			base = 10;
  8008d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8008dc:	eb 4f                	jmp    80092d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8008de:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e1:	e8 49 fc ff ff       	call   80052f <getuint>
            base = 8;
  8008e6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  8008eb:	eb 40                	jmp    80092d <vprintfmt+0x37f>
			putch('0', putdat);
  8008ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ff:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800906:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800909:	8b 45 14             	mov    0x14(%ebp),%eax
  80090c:	8d 50 04             	lea    0x4(%eax),%edx
  80090f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800912:	8b 00                	mov    (%eax),%eax
  800914:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800919:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80091e:	eb 0d                	jmp    80092d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800920:	8d 45 14             	lea    0x14(%ebp),%eax
  800923:	e8 07 fc ff ff       	call   80052f <getuint>
			base = 16;
  800928:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80092d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800931:	89 74 24 10          	mov    %esi,0x10(%esp)
  800935:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800938:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80093c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	89 54 24 04          	mov    %edx,0x4(%esp)
  800947:	89 fa                	mov    %edi,%edx
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	e8 ef fa ff ff       	call   800440 <printnum>
			break;
  800951:	e9 88 fc ff ff       	jmp    8005de <vprintfmt+0x30>
			putch(ch, putdat);
  800956:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095a:	89 04 24             	mov    %eax,(%esp)
  80095d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800960:	e9 79 fc ff ff       	jmp    8005de <vprintfmt+0x30>
			putch('%', putdat);
  800965:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800969:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800970:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800973:	89 f3                	mov    %esi,%ebx
  800975:	eb 03                	jmp    80097a <vprintfmt+0x3cc>
  800977:	83 eb 01             	sub    $0x1,%ebx
  80097a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80097e:	75 f7                	jne    800977 <vprintfmt+0x3c9>
  800980:	e9 59 fc ff ff       	jmp    8005de <vprintfmt+0x30>
}
  800985:	83 c4 3c             	add    $0x3c,%esp
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	83 ec 28             	sub    $0x28,%esp
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800999:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80099c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	74 30                	je     8009de <vsnprintf+0x51>
  8009ae:	85 d2                	test   %edx,%edx
  8009b0:	7e 2c                	jle    8009de <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c7:	c7 04 24 69 05 80 00 	movl   $0x800569,(%esp)
  8009ce:	e8 db fb ff ff       	call   8005ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009dc:	eb 05                	jmp    8009e3 <vsnprintf+0x56>
		return -E_INVAL;
  8009de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 82 ff ff ff       	call   80098d <vsnprintf>
	va_end(ap);

	return rc;
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    
  800a0d:	66 90                	xchg   %ax,%ax
  800a0f:	90                   	nop

00800a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	eb 03                	jmp    800a20 <strlen+0x10>
		n++;
  800a1d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a24:	75 f7                	jne    800a1d <strlen+0xd>
	return n;
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	eb 03                	jmp    800a3b <strnlen+0x13>
		n++;
  800a38:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	74 06                	je     800a45 <strnlen+0x1d>
  800a3f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a43:	75 f3                	jne    800a38 <strnlen+0x10>
	return n;
}
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	83 c2 01             	add    $0x1,%edx
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a5d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a60:	84 db                	test   %bl,%bl
  800a62:	75 ef                	jne    800a53 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a64:	5b                   	pop    %ebx
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	53                   	push   %ebx
  800a6b:	83 ec 08             	sub    $0x8,%esp
  800a6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a71:	89 1c 24             	mov    %ebx,(%esp)
  800a74:	e8 97 ff ff ff       	call   800a10 <strlen>
	strcpy(dst + len, src);
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a80:	01 d8                	add    %ebx,%eax
  800a82:	89 04 24             	mov    %eax,(%esp)
  800a85:	e8 bd ff ff ff       	call   800a47 <strcpy>
	return dst;
}
  800a8a:	89 d8                	mov    %ebx,%eax
  800a8c:	83 c4 08             	add    $0x8,%esp
  800a8f:	5b                   	pop    %ebx
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa2:	89 f2                	mov    %esi,%edx
  800aa4:	eb 0f                	jmp    800ab5 <strncpy+0x23>
		*dst++ = *src;
  800aa6:	83 c2 01             	add    $0x1,%edx
  800aa9:	0f b6 01             	movzbl (%ecx),%eax
  800aac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aaf:	80 39 01             	cmpb   $0x1,(%ecx)
  800ab2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800ab5:	39 da                	cmp    %ebx,%edx
  800ab7:	75 ed                	jne    800aa6 <strncpy+0x14>
	}
	return ret;
}
  800ab9:	89 f0                	mov    %esi,%eax
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800acd:	89 f0                	mov    %esi,%eax
  800acf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	75 0b                	jne    800ae2 <strlcpy+0x23>
  800ad7:	eb 1d                	jmp    800af6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ad9:	83 c0 01             	add    $0x1,%eax
  800adc:	83 c2 01             	add    $0x1,%edx
  800adf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ae2:	39 d8                	cmp    %ebx,%eax
  800ae4:	74 0b                	je     800af1 <strlcpy+0x32>
  800ae6:	0f b6 0a             	movzbl (%edx),%ecx
  800ae9:	84 c9                	test   %cl,%cl
  800aeb:	75 ec                	jne    800ad9 <strlcpy+0x1a>
  800aed:	89 c2                	mov    %eax,%edx
  800aef:	eb 02                	jmp    800af3 <strlcpy+0x34>
  800af1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800af3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800af6:	29 f0                	sub    %esi,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b05:	eb 06                	jmp    800b0d <strcmp+0x11>
		p++, q++;
  800b07:	83 c1 01             	add    $0x1,%ecx
  800b0a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b0d:	0f b6 01             	movzbl (%ecx),%eax
  800b10:	84 c0                	test   %al,%al
  800b12:	74 04                	je     800b18 <strcmp+0x1c>
  800b14:	3a 02                	cmp    (%edx),%al
  800b16:	74 ef                	je     800b07 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b18:	0f b6 c0             	movzbl %al,%eax
  800b1b:	0f b6 12             	movzbl (%edx),%edx
  800b1e:	29 d0                	sub    %edx,%eax
}
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b31:	eb 06                	jmp    800b39 <strncmp+0x17>
		n--, p++, q++;
  800b33:	83 c0 01             	add    $0x1,%eax
  800b36:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b39:	39 d8                	cmp    %ebx,%eax
  800b3b:	74 15                	je     800b52 <strncmp+0x30>
  800b3d:	0f b6 08             	movzbl (%eax),%ecx
  800b40:	84 c9                	test   %cl,%cl
  800b42:	74 04                	je     800b48 <strncmp+0x26>
  800b44:	3a 0a                	cmp    (%edx),%cl
  800b46:	74 eb                	je     800b33 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b48:	0f b6 00             	movzbl (%eax),%eax
  800b4b:	0f b6 12             	movzbl (%edx),%edx
  800b4e:	29 d0                	sub    %edx,%eax
  800b50:	eb 05                	jmp    800b57 <strncmp+0x35>
		return 0;
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b57:	5b                   	pop    %ebx
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b64:	eb 07                	jmp    800b6d <strchr+0x13>
		if (*s == c)
  800b66:	38 ca                	cmp    %cl,%dl
  800b68:	74 0f                	je     800b79 <strchr+0x1f>
	for (; *s; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	84 d2                	test   %dl,%dl
  800b72:	75 f2                	jne    800b66 <strchr+0xc>
			return (char *) s;
	return 0;
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b85:	eb 07                	jmp    800b8e <strfind+0x13>
		if (*s == c)
  800b87:	38 ca                	cmp    %cl,%dl
  800b89:	74 0a                	je     800b95 <strfind+0x1a>
	for (; *s; s++)
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	0f b6 10             	movzbl (%eax),%edx
  800b91:	84 d2                	test   %dl,%dl
  800b93:	75 f2                	jne    800b87 <strfind+0xc>
			break;
	return (char *) s;
}
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba3:	85 c9                	test   %ecx,%ecx
  800ba5:	74 36                	je     800bdd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bad:	75 28                	jne    800bd7 <memset+0x40>
  800baf:	f6 c1 03             	test   $0x3,%cl
  800bb2:	75 23                	jne    800bd7 <memset+0x40>
		c &= 0xFF;
  800bb4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	c1 e3 08             	shl    $0x8,%ebx
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	c1 e6 18             	shl    $0x18,%esi
  800bc2:	89 d0                	mov    %edx,%eax
  800bc4:	c1 e0 10             	shl    $0x10,%eax
  800bc7:	09 f0                	or     %esi,%eax
  800bc9:	09 c2                	or     %eax,%edx
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bcf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bd2:	fc                   	cld    
  800bd3:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd5:	eb 06                	jmp    800bdd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bda:	fc                   	cld    
  800bdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bdd:	89 f8                	mov    %edi,%eax
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf2:	39 c6                	cmp    %eax,%esi
  800bf4:	73 35                	jae    800c2b <memmove+0x47>
  800bf6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf9:	39 d0                	cmp    %edx,%eax
  800bfb:	73 2e                	jae    800c2b <memmove+0x47>
		s += n;
		d += n;
  800bfd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c0a:	75 13                	jne    800c1f <memmove+0x3b>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 0e                	jne    800c1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c11:	83 ef 04             	sub    $0x4,%edi
  800c14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c1a:	fd                   	std    
  800c1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1d:	eb 09                	jmp    800c28 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1f:	83 ef 01             	sub    $0x1,%edi
  800c22:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c25:	fd                   	std    
  800c26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c28:	fc                   	cld    
  800c29:	eb 1d                	jmp    800c48 <memmove+0x64>
  800c2b:	89 f2                	mov    %esi,%edx
  800c2d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2f:	f6 c2 03             	test   $0x3,%dl
  800c32:	75 0f                	jne    800c43 <memmove+0x5f>
  800c34:	f6 c1 03             	test   $0x3,%cl
  800c37:	75 0a                	jne    800c43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c39:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	fc                   	cld    
  800c3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c41:	eb 05                	jmp    800c48 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800c43:	89 c7                	mov    %eax,%edi
  800c45:	fc                   	cld    
  800c46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c52:	8b 45 10             	mov    0x10(%ebp),%eax
  800c55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c60:	8b 45 08             	mov    0x8(%ebp),%eax
  800c63:	89 04 24             	mov    %eax,(%esp)
  800c66:	e8 79 ff ff ff       	call   800be4 <memmove>
}
  800c6b:	c9                   	leave  
  800c6c:	c3                   	ret    

00800c6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7d:	eb 1a                	jmp    800c99 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7f:	0f b6 02             	movzbl (%edx),%eax
  800c82:	0f b6 19             	movzbl (%ecx),%ebx
  800c85:	38 d8                	cmp    %bl,%al
  800c87:	74 0a                	je     800c93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c89:	0f b6 c0             	movzbl %al,%eax
  800c8c:	0f b6 db             	movzbl %bl,%ebx
  800c8f:	29 d8                	sub    %ebx,%eax
  800c91:	eb 0f                	jmp    800ca2 <memcmp+0x35>
		s1++, s2++;
  800c93:	83 c2 01             	add    $0x1,%edx
  800c96:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800c99:	39 f2                	cmp    %esi,%edx
  800c9b:	75 e2                	jne    800c7f <memcmp+0x12>
	}

	return 0;
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800caf:	89 c2                	mov    %eax,%edx
  800cb1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb4:	eb 07                	jmp    800cbd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb6:	38 08                	cmp    %cl,(%eax)
  800cb8:	74 07                	je     800cc1 <memfind+0x1b>
	for (; s < ends; s++)
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	39 d0                	cmp    %edx,%eax
  800cbf:	72 f5                	jb     800cb6 <memfind+0x10>
			break;
	return (void *) s;
}
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccf:	eb 03                	jmp    800cd4 <strtol+0x11>
		s++;
  800cd1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800cd4:	0f b6 0a             	movzbl (%edx),%ecx
  800cd7:	80 f9 09             	cmp    $0x9,%cl
  800cda:	74 f5                	je     800cd1 <strtol+0xe>
  800cdc:	80 f9 20             	cmp    $0x20,%cl
  800cdf:	74 f0                	je     800cd1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ce1:	80 f9 2b             	cmp    $0x2b,%cl
  800ce4:	75 0a                	jne    800cf0 <strtol+0x2d>
		s++;
  800ce6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ce9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cee:	eb 11                	jmp    800d01 <strtol+0x3e>
  800cf0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800cf5:	80 f9 2d             	cmp    $0x2d,%cl
  800cf8:	75 07                	jne    800d01 <strtol+0x3e>
		s++, neg = 1;
  800cfa:	8d 52 01             	lea    0x1(%edx),%edx
  800cfd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d01:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d06:	75 15                	jne    800d1d <strtol+0x5a>
  800d08:	80 3a 30             	cmpb   $0x30,(%edx)
  800d0b:	75 10                	jne    800d1d <strtol+0x5a>
  800d0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d11:	75 0a                	jne    800d1d <strtol+0x5a>
		s += 2, base = 16;
  800d13:	83 c2 02             	add    $0x2,%edx
  800d16:	b8 10 00 00 00       	mov    $0x10,%eax
  800d1b:	eb 10                	jmp    800d2d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	75 0c                	jne    800d2d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d21:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800d23:	80 3a 30             	cmpb   $0x30,(%edx)
  800d26:	75 05                	jne    800d2d <strtol+0x6a>
		s++, base = 8;
  800d28:	83 c2 01             	add    $0x1,%edx
  800d2b:	b0 08                	mov    $0x8,%al
		base = 10;
  800d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d32:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d35:	0f b6 0a             	movzbl (%edx),%ecx
  800d38:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	3c 09                	cmp    $0x9,%al
  800d3f:	77 08                	ja     800d49 <strtol+0x86>
			dig = *s - '0';
  800d41:	0f be c9             	movsbl %cl,%ecx
  800d44:	83 e9 30             	sub    $0x30,%ecx
  800d47:	eb 20                	jmp    800d69 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800d49:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800d4c:	89 f0                	mov    %esi,%eax
  800d4e:	3c 19                	cmp    $0x19,%al
  800d50:	77 08                	ja     800d5a <strtol+0x97>
			dig = *s - 'a' + 10;
  800d52:	0f be c9             	movsbl %cl,%ecx
  800d55:	83 e9 57             	sub    $0x57,%ecx
  800d58:	eb 0f                	jmp    800d69 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800d5a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800d5d:	89 f0                	mov    %esi,%eax
  800d5f:	3c 19                	cmp    $0x19,%al
  800d61:	77 16                	ja     800d79 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800d63:	0f be c9             	movsbl %cl,%ecx
  800d66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800d6c:	7d 0f                	jge    800d7d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800d6e:	83 c2 01             	add    $0x1,%edx
  800d71:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800d75:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800d77:	eb bc                	jmp    800d35 <strtol+0x72>
  800d79:	89 d8                	mov    %ebx,%eax
  800d7b:	eb 02                	jmp    800d7f <strtol+0xbc>
  800d7d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800d7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d83:	74 05                	je     800d8a <strtol+0xc7>
		*endptr = (char *) s;
  800d85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d88:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d8a:	f7 d8                	neg    %eax
  800d8c:	85 ff                	test   %edi,%edi
  800d8e:	0f 44 c3             	cmove  %ebx,%eax
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	89 c7                	mov    %eax,%edi
  800dab:	89 c6                	mov    %eax,%esi
  800dad:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc4:	89 d1                	mov    %edx,%ecx
  800dc6:	89 d3                	mov    %edx,%ebx
  800dc8:	89 d7                	mov    %edx,%edi
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ddc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de1:	b8 03 00 00 00       	mov    $0x3,%eax
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 cb                	mov    %ecx,%ebx
  800deb:	89 cf                	mov    %ecx,%edi
  800ded:	89 ce                	mov    %ecx,%esi
  800def:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 28                	jle    800e1d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e00:	00 
  800e01:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e08:	00 
  800e09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e10:	00 
  800e11:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800e18:	e8 01 f5 ff ff       	call   80031e <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1d:	83 c4 2c             	add    $0x2c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 02 00 00 00       	mov    $0x2,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_yield>:

void
sys_yield(void)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e54:	89 d1                	mov    %edx,%ecx
  800e56:	89 d3                	mov    %edx,%ebx
  800e58:	89 d7                	mov    %edx,%edi
  800e5a:	89 d6                	mov    %edx,%esi
  800e5c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e6c:	be 00 00 00 00       	mov    $0x0,%esi
  800e71:	b8 04 00 00 00       	mov    $0x4,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7f:	89 f7                	mov    %esi,%edi
  800e81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e83:	85 c0                	test   %eax,%eax
  800e85:	7e 28                	jle    800eaf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e92:	00 
  800e93:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e9a:	00 
  800e9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea2:	00 
  800ea3:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800eaa:	e8 6f f4 ff ff       	call   80031e <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eaf:	83 c4 2c             	add    $0x2c,%esp
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	57                   	push   %edi
  800ebb:	56                   	push   %esi
  800ebc:	53                   	push   %ebx
  800ebd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ec0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ec5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ed4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	7e 28                	jle    800f02 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ede:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800eed:	00 
  800eee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef5:	00 
  800ef6:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800efd:	e8 1c f4 ff ff       	call   80031e <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f02:	83 c4 2c             	add    $0x2c,%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f18:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	89 df                	mov    %ebx,%edi
  800f25:	89 de                	mov    %ebx,%esi
  800f27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	7e 28                	jle    800f55 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f31:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f38:	00 
  800f39:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800f40:	00 
  800f41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f48:	00 
  800f49:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800f50:	e8 c9 f3 ff ff       	call   80031e <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f55:	83 c4 2c             	add    $0x2c,%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
  800f76:	89 df                	mov    %ebx,%edi
  800f78:	89 de                	mov    %ebx,%esi
  800f7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	7e 28                	jle    800fa8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f84:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800f93:	00 
  800f94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9b:	00 
  800f9c:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800fa3:	e8 76 f3 ff ff       	call   80031e <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fa8:	83 c4 2c             	add    $0x2c,%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbe:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc9:	89 df                	mov    %ebx,%edi
  800fcb:	89 de                	mov    %ebx,%esi
  800fcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	7e 28                	jle    800ffb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fde:	00 
  800fdf:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fee:	00 
  800fef:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800ff6:	e8 23 f3 ff ff       	call   80031e <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ffb:	83 c4 2c             	add    $0x2c,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	57                   	push   %edi
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80100c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801011:	b8 0a 00 00 00       	mov    $0xa,%eax
  801016:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801019:	8b 55 08             	mov    0x8(%ebp),%edx
  80101c:	89 df                	mov    %ebx,%edi
  80101e:	89 de                	mov    %ebx,%esi
  801020:	cd 30                	int    $0x30
	if(check && ret > 0)
  801022:	85 c0                	test   %eax,%eax
  801024:	7e 28                	jle    80104e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801026:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801031:	00 
  801032:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  801049:	e8 d0 f2 ff ff       	call   80031e <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80104e:	83 c4 2c             	add    $0x2c,%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80105c:	be 00 00 00 00       	mov    $0x0,%esi
  801061:	b8 0c 00 00 00       	mov    $0xc,%eax
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	8b 55 08             	mov    0x8(%ebp),%edx
  80106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801072:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801082:	b9 00 00 00 00       	mov    $0x0,%ecx
  801087:	b8 0d 00 00 00       	mov    $0xd,%eax
  80108c:	8b 55 08             	mov    0x8(%ebp),%edx
  80108f:	89 cb                	mov    %ecx,%ebx
  801091:	89 cf                	mov    %ecx,%edi
  801093:	89 ce                	mov    %ecx,%esi
  801095:	cd 30                	int    $0x30
	if(check && ret > 0)
  801097:	85 c0                	test   %eax,%eax
  801099:	7e 28                	jle    8010c3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010a6:	00 
  8010a7:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  8010ae:	00 
  8010af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b6:	00 
  8010b7:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8010be:	e8 5b f2 ff ff       	call   80031e <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010c3:	83 c4 2c             	add    $0x2c,%esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    
  8010cb:	66 90                	xchg   %ax,%ax
  8010cd:	66 90                	xchg   %ax,%ax
  8010cf:	90                   	nop

008010d0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 24             	sub    $0x24,%esp
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  8010da:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  8010dc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010e0:	74 18                	je     8010fa <pgfault+0x2a>
  8010e2:	89 d8                	mov    %ebx,%eax
  8010e4:	c1 e8 0c             	shr    $0xc,%eax
  8010e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ee:	25 05 08 00 00       	and    $0x805,%eax
  8010f3:	3d 05 08 00 00       	cmp    $0x805,%eax
  8010f8:	74 1c                	je     801116 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  8010fa:	c7 44 24 08 0c 2a 80 	movl   $0x802a0c,0x8(%esp)
  801101:	00 
  801102:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801109:	00 
  80110a:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  801111:	e8 08 f2 ff ff       	call   80031e <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  801116:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80111d:	00 
  80111e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801125:	00 
  801126:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80112d:	e8 31 fd ff ff       	call   800e63 <sys_page_alloc>
	if(r < 0){
  801132:	85 c0                	test   %eax,%eax
  801134:	79 1c                	jns    801152 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  801136:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  80113d:	00 
  80113e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801145:	00 
  801146:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  80114d:	e8 cc f1 ff ff       	call   80031e <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801152:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801158:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80115f:	00 
  801160:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801164:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80116b:	e8 dc fa ff ff       	call   800c4c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  801170:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801177:	00 
  801178:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80117c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801183:	00 
  801184:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80118b:	00 
  80118c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801193:	e8 1f fd ff ff       	call   800eb7 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  801198:	85 c0                	test   %eax,%eax
  80119a:	79 1c                	jns    8011b8 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  80119c:	c7 44 24 08 08 2b 80 	movl   $0x802b08,0x8(%esp)
  8011a3:	00 
  8011a4:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8011ab:	00 
  8011ac:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  8011b3:	e8 66 f1 ff ff       	call   80031e <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  8011b8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011bf:	00 
  8011c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c7:	e8 3e fd ff ff       	call   800f0a <sys_page_unmap>
    if(r < 0){
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	79 1c                	jns    8011ec <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  8011d0:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8011df:	00 
  8011e0:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  8011e7:	e8 32 f1 ff ff       	call   80031e <_panic>
    }
    // LAB 4
}
  8011ec:	83 c4 24             	add    $0x24,%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  8011fb:	c7 04 24 d0 10 80 00 	movl   $0x8010d0,(%esp)
  801202:	e8 5f 0f 00 00       	call   802166 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801207:	b8 07 00 00 00       	mov    $0x7,%eax
  80120c:	cd 30                	int    $0x30
  80120e:	89 c7                	mov    %eax,%edi
  801210:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801213:	85 c0                	test   %eax,%eax
  801215:	79 1c                	jns    801233 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801217:	c7 44 24 08 38 2b 80 	movl   $0x802b38,0x8(%esp)
  80121e:	00 
  80121f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801226:	00 
  801227:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  80122e:	e8 eb f0 ff ff       	call   80031e <_panic>
    }
    if(child == 0){
  801233:	bb 00 00 00 00       	mov    $0x0,%ebx
  801238:	85 c0                	test   %eax,%eax
  80123a:	75 21                	jne    80125d <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  80123c:	e8 e4 fb ff ff       	call   800e25 <sys_getenvid>
  801241:	25 ff 03 00 00       	and    $0x3ff,%eax
  801246:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801249:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80124e:	a3 08 40 80 00       	mov    %eax,0x804008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	e9 67 01 00 00       	jmp    8013c4 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  80125d:	89 d8                	mov    %ebx,%eax
  80125f:	c1 e8 16             	shr    $0x16,%eax
  801262:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801269:	a8 01                	test   $0x1,%al
  80126b:	74 4b                	je     8012b8 <fork+0xc6>
  80126d:	89 de                	mov    %ebx,%esi
  80126f:	c1 ee 0c             	shr    $0xc,%esi
  801272:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801279:	a8 01                	test   $0x1,%al
  80127b:	74 3b                	je     8012b8 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  80127d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801284:	a9 02 08 00 00       	test   $0x802,%eax
  801289:	0f 85 02 01 00 00    	jne    801391 <fork+0x19f>
  80128f:	e9 d2 00 00 00       	jmp    801366 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  801294:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80129b:	00 
  80129c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012a7:	00 
  8012a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b3:	e8 ff fb ff ff       	call   800eb7 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  8012b8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012be:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8012c4:	75 97                	jne    80125d <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  8012c6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012cd:	00 
  8012ce:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012d5:	ee 
  8012d6:	89 3c 24             	mov    %edi,(%esp)
  8012d9:	e8 85 fb ff ff       	call   800e63 <sys_page_alloc>

    if(r < 0){
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	79 1c                	jns    8012fe <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  8012e2:	c7 44 24 08 70 2a 80 	movl   $0x802a70,0x8(%esp)
  8012e9:	00 
  8012ea:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  8012f1:	00 
  8012f2:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  8012f9:	e8 20 f0 ff ff       	call   80031e <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  8012fe:	a1 08 40 80 00       	mov    0x804008,%eax
  801303:	8b 40 64             	mov    0x64(%eax),%eax
  801306:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130a:	89 3c 24             	mov    %edi,(%esp)
  80130d:	e8 f1 fc ff ff       	call   801003 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801312:	85 c0                	test   %eax,%eax
  801314:	79 1c                	jns    801332 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801316:	c7 44 24 08 90 2a 80 	movl   $0x802a90,0x8(%esp)
  80131d:	00 
  80131e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801325:	00 
  801326:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  80132d:	e8 ec ef ff ff       	call   80031e <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801332:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801339:	00 
  80133a:	89 3c 24             	mov    %edi,(%esp)
  80133d:	e8 1b fc ff ff       	call   800f5d <sys_env_set_status>
    if(r < 0){
  801342:	85 c0                	test   %eax,%eax
  801344:	79 1c                	jns    801362 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801346:	c7 44 24 08 b8 2a 80 	movl   $0x802ab8,0x8(%esp)
  80134d:	00 
  80134e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  801355:	00 
  801356:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  80135d:	e8 bc ef ff ff       	call   80031e <_panic>
    }
    return child;
  801362:	89 f8                	mov    %edi,%eax
  801364:	eb 5e                	jmp    8013c4 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  801366:	c1 e6 0c             	shl    $0xc,%esi
  801369:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801370:	00 
  801371:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801375:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80137c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801380:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801387:	e8 2b fb ff ff       	call   800eb7 <sys_page_map>
  80138c:	e9 27 ff ff ff       	jmp    8012b8 <fork+0xc6>
  801391:	c1 e6 0c             	shl    $0xc,%esi
  801394:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80139b:	00 
  80139c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b2:	e8 00 fb ff ff       	call   800eb7 <sys_page_map>
    if( r < 0 ){
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	0f 89 d5 fe ff ff    	jns    801294 <fork+0xa2>
  8013bf:	e9 f4 fe ff ff       	jmp    8012b8 <fork+0xc6>
//	panic("fork not implemented");
}
  8013c4:	83 c4 2c             	add    $0x2c,%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <sfork>:

// Challenge!
int
sfork(void)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013d2:	c7 44 24 08 55 2b 80 	movl   $0x802b55,0x8(%esp)
  8013d9:	00 
  8013da:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  8013e1:	00 
  8013e2:	c7 04 24 fd 2a 80 00 	movl   $0x802afd,(%esp)
  8013e9:	e8 30 ef ff ff       	call   80031e <_panic>
  8013ee:	66 90                	xchg   %ax,%ax

008013f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80140b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801410:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801422:	89 c2                	mov    %eax,%edx
  801424:	c1 ea 16             	shr    $0x16,%edx
  801427:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80142e:	f6 c2 01             	test   $0x1,%dl
  801431:	74 11                	je     801444 <fd_alloc+0x2d>
  801433:	89 c2                	mov    %eax,%edx
  801435:	c1 ea 0c             	shr    $0xc,%edx
  801438:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	75 09                	jne    80144d <fd_alloc+0x36>
			*fd_store = fd;
  801444:	89 01                	mov    %eax,(%ecx)
			return 0;
  801446:	b8 00 00 00 00       	mov    $0x0,%eax
  80144b:	eb 17                	jmp    801464 <fd_alloc+0x4d>
  80144d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801452:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801457:	75 c9                	jne    801422 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801459:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80145f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80146c:	83 f8 1f             	cmp    $0x1f,%eax
  80146f:	77 36                	ja     8014a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801471:	c1 e0 0c             	shl    $0xc,%eax
  801474:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801479:	89 c2                	mov    %eax,%edx
  80147b:	c1 ea 16             	shr    $0x16,%edx
  80147e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801485:	f6 c2 01             	test   $0x1,%dl
  801488:	74 24                	je     8014ae <fd_lookup+0x48>
  80148a:	89 c2                	mov    %eax,%edx
  80148c:	c1 ea 0c             	shr    $0xc,%edx
  80148f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801496:	f6 c2 01             	test   $0x1,%dl
  801499:	74 1a                	je     8014b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80149b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149e:	89 02                	mov    %eax,(%edx)
	return 0;
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a5:	eb 13                	jmp    8014ba <fd_lookup+0x54>
		return -E_INVAL;
  8014a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ac:	eb 0c                	jmp    8014ba <fd_lookup+0x54>
		return -E_INVAL;
  8014ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b3:	eb 05                	jmp    8014ba <fd_lookup+0x54>
  8014b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 18             	sub    $0x18,%esp
  8014c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014c5:	ba e8 2b 80 00       	mov    $0x802be8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014ca:	eb 13                	jmp    8014df <dev_lookup+0x23>
  8014cc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014cf:	39 08                	cmp    %ecx,(%eax)
  8014d1:	75 0c                	jne    8014df <dev_lookup+0x23>
			*dev = devtab[i];
  8014d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014dd:	eb 30                	jmp    80150f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8014df:	8b 02                	mov    (%edx),%eax
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	75 e7                	jne    8014cc <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ea:	8b 40 48             	mov    0x48(%eax),%eax
  8014ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f5:	c7 04 24 6c 2b 80 00 	movl   $0x802b6c,(%esp)
  8014fc:	e8 16 ef ff ff       	call   800417 <cprintf>
	*dev = 0;
  801501:	8b 45 0c             	mov    0xc(%ebp),%eax
  801504:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80150a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <fd_close>:
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
  801516:	83 ec 20             	sub    $0x20,%esp
  801519:	8b 75 08             	mov    0x8(%ebp),%esi
  80151c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801526:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80152c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	e8 2f ff ff ff       	call   801466 <fd_lookup>
  801537:	85 c0                	test   %eax,%eax
  801539:	78 05                	js     801540 <fd_close+0x2f>
	    || fd != fd2)
  80153b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80153e:	74 0c                	je     80154c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801540:	84 db                	test   %bl,%bl
  801542:	ba 00 00 00 00       	mov    $0x0,%edx
  801547:	0f 44 c2             	cmove  %edx,%eax
  80154a:	eb 3f                	jmp    80158b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80154c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801553:	8b 06                	mov    (%esi),%eax
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	e8 5f ff ff ff       	call   8014bc <dev_lookup>
  80155d:	89 c3                	mov    %eax,%ebx
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 16                	js     801579 <fd_close+0x68>
		if (dev->dev_close)
  801563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801566:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801569:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80156e:	85 c0                	test   %eax,%eax
  801570:	74 07                	je     801579 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801572:	89 34 24             	mov    %esi,(%esp)
  801575:	ff d0                	call   *%eax
  801577:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801579:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801584:	e8 81 f9 ff ff       	call   800f0a <sys_page_unmap>
	return r;
  801589:	89 d8                	mov    %ebx,%eax
}
  80158b:	83 c4 20             	add    $0x20,%esp
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <close>:

int
close(int fdnum)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159f:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a2:	89 04 24             	mov    %eax,(%esp)
  8015a5:	e8 bc fe ff ff       	call   801466 <fd_lookup>
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	85 d2                	test   %edx,%edx
  8015ae:	78 13                	js     8015c3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8015b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015b7:	00 
  8015b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bb:	89 04 24             	mov    %eax,(%esp)
  8015be:	e8 4e ff ff ff       	call   801511 <fd_close>
}
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <close_all>:

void
close_all(void)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015d1:	89 1c 24             	mov    %ebx,(%esp)
  8015d4:	e8 b9 ff ff ff       	call   801592 <close>
	for (i = 0; i < MAXFD; i++)
  8015d9:	83 c3 01             	add    $0x1,%ebx
  8015dc:	83 fb 20             	cmp    $0x20,%ebx
  8015df:	75 f0                	jne    8015d1 <close_all+0xc>
}
  8015e1:	83 c4 14             	add    $0x14,%esp
  8015e4:	5b                   	pop    %ebx
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	57                   	push   %edi
  8015eb:	56                   	push   %esi
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fa:	89 04 24             	mov    %eax,(%esp)
  8015fd:	e8 64 fe ff ff       	call   801466 <fd_lookup>
  801602:	89 c2                	mov    %eax,%edx
  801604:	85 d2                	test   %edx,%edx
  801606:	0f 88 e1 00 00 00    	js     8016ed <dup+0x106>
		return r;
	close(newfdnum);
  80160c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160f:	89 04 24             	mov    %eax,(%esp)
  801612:	e8 7b ff ff ff       	call   801592 <close>

	newfd = INDEX2FD(newfdnum);
  801617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80161a:	c1 e3 0c             	shl    $0xc,%ebx
  80161d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801626:	89 04 24             	mov    %eax,(%esp)
  801629:	e8 d2 fd ff ff       	call   801400 <fd2data>
  80162e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801630:	89 1c 24             	mov    %ebx,(%esp)
  801633:	e8 c8 fd ff ff       	call   801400 <fd2data>
  801638:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80163a:	89 f0                	mov    %esi,%eax
  80163c:	c1 e8 16             	shr    $0x16,%eax
  80163f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801646:	a8 01                	test   $0x1,%al
  801648:	74 43                	je     80168d <dup+0xa6>
  80164a:	89 f0                	mov    %esi,%eax
  80164c:	c1 e8 0c             	shr    $0xc,%eax
  80164f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801656:	f6 c2 01             	test   $0x1,%dl
  801659:	74 32                	je     80168d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80165b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801662:	25 07 0e 00 00       	and    $0xe07,%eax
  801667:	89 44 24 10          	mov    %eax,0x10(%esp)
  80166b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80166f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801676:	00 
  801677:	89 74 24 04          	mov    %esi,0x4(%esp)
  80167b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801682:	e8 30 f8 ff ff       	call   800eb7 <sys_page_map>
  801687:	89 c6                	mov    %eax,%esi
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 3e                	js     8016cb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80168d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801690:	89 c2                	mov    %eax,%edx
  801692:	c1 ea 0c             	shr    $0xc,%edx
  801695:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80169c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016a2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016b1:	00 
  8016b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bd:	e8 f5 f7 ff ff       	call   800eb7 <sys_page_map>
  8016c2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c7:	85 f6                	test   %esi,%esi
  8016c9:	79 22                	jns    8016ed <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8016cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d6:	e8 2f f8 ff ff       	call   800f0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e6:	e8 1f f8 ff ff       	call   800f0a <sys_page_unmap>
	return r;
  8016eb:	89 f0                	mov    %esi,%eax
}
  8016ed:	83 c4 3c             	add    $0x3c,%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5e                   	pop    %esi
  8016f2:	5f                   	pop    %edi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	53                   	push   %ebx
  8016f9:	83 ec 24             	sub    $0x24,%esp
  8016fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801702:	89 44 24 04          	mov    %eax,0x4(%esp)
  801706:	89 1c 24             	mov    %ebx,(%esp)
  801709:	e8 58 fd ff ff       	call   801466 <fd_lookup>
  80170e:	89 c2                	mov    %eax,%edx
  801710:	85 d2                	test   %edx,%edx
  801712:	78 6d                	js     801781 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801714:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171e:	8b 00                	mov    (%eax),%eax
  801720:	89 04 24             	mov    %eax,(%esp)
  801723:	e8 94 fd ff ff       	call   8014bc <dev_lookup>
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 55                	js     801781 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172f:	8b 50 08             	mov    0x8(%eax),%edx
  801732:	83 e2 03             	and    $0x3,%edx
  801735:	83 fa 01             	cmp    $0x1,%edx
  801738:	75 23                	jne    80175d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80173a:	a1 08 40 80 00       	mov    0x804008,%eax
  80173f:	8b 40 48             	mov    0x48(%eax),%eax
  801742:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801746:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174a:	c7 04 24 ad 2b 80 00 	movl   $0x802bad,(%esp)
  801751:	e8 c1 ec ff ff       	call   800417 <cprintf>
		return -E_INVAL;
  801756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175b:	eb 24                	jmp    801781 <read+0x8c>
	}
	if (!dev->dev_read)
  80175d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801760:	8b 52 08             	mov    0x8(%edx),%edx
  801763:	85 d2                	test   %edx,%edx
  801765:	74 15                	je     80177c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801767:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80176a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80176e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801771:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	ff d2                	call   *%edx
  80177a:	eb 05                	jmp    801781 <read+0x8c>
		return -E_NOT_SUPP;
  80177c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801781:	83 c4 24             	add    $0x24,%esp
  801784:	5b                   	pop    %ebx
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	57                   	push   %edi
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	83 ec 1c             	sub    $0x1c,%esp
  801790:	8b 7d 08             	mov    0x8(%ebp),%edi
  801793:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801796:	bb 00 00 00 00       	mov    $0x0,%ebx
  80179b:	eb 23                	jmp    8017c0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80179d:	89 f0                	mov    %esi,%eax
  80179f:	29 d8                	sub    %ebx,%eax
  8017a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a5:	89 d8                	mov    %ebx,%eax
  8017a7:	03 45 0c             	add    0xc(%ebp),%eax
  8017aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ae:	89 3c 24             	mov    %edi,(%esp)
  8017b1:	e8 3f ff ff ff       	call   8016f5 <read>
		if (m < 0)
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 10                	js     8017ca <readn+0x43>
			return m;
		if (m == 0)
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	74 0a                	je     8017c8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8017be:	01 c3                	add    %eax,%ebx
  8017c0:	39 f3                	cmp    %esi,%ebx
  8017c2:	72 d9                	jb     80179d <readn+0x16>
  8017c4:	89 d8                	mov    %ebx,%eax
  8017c6:	eb 02                	jmp    8017ca <readn+0x43>
  8017c8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017ca:	83 c4 1c             	add    $0x1c,%esp
  8017cd:	5b                   	pop    %ebx
  8017ce:	5e                   	pop    %esi
  8017cf:	5f                   	pop    %edi
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 24             	sub    $0x24,%esp
  8017d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e3:	89 1c 24             	mov    %ebx,(%esp)
  8017e6:	e8 7b fc ff ff       	call   801466 <fd_lookup>
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 d2                	test   %edx,%edx
  8017ef:	78 68                	js     801859 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fb:	8b 00                	mov    (%eax),%eax
  8017fd:	89 04 24             	mov    %eax,(%esp)
  801800:	e8 b7 fc ff ff       	call   8014bc <dev_lookup>
  801805:	85 c0                	test   %eax,%eax
  801807:	78 50                	js     801859 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801810:	75 23                	jne    801835 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801812:	a1 08 40 80 00       	mov    0x804008,%eax
  801817:	8b 40 48             	mov    0x48(%eax),%eax
  80181a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801822:	c7 04 24 c9 2b 80 00 	movl   $0x802bc9,(%esp)
  801829:	e8 e9 eb ff ff       	call   800417 <cprintf>
		return -E_INVAL;
  80182e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801833:	eb 24                	jmp    801859 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801835:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801838:	8b 52 0c             	mov    0xc(%edx),%edx
  80183b:	85 d2                	test   %edx,%edx
  80183d:	74 15                	je     801854 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80183f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801842:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801849:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80184d:	89 04 24             	mov    %eax,(%esp)
  801850:	ff d2                	call   *%edx
  801852:	eb 05                	jmp    801859 <write+0x87>
		return -E_NOT_SUPP;
  801854:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801859:	83 c4 24             	add    $0x24,%esp
  80185c:	5b                   	pop    %ebx
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <seek>:

int
seek(int fdnum, off_t offset)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801865:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	89 04 24             	mov    %eax,(%esp)
  801872:	e8 ef fb ff ff       	call   801466 <fd_lookup>
  801877:	85 c0                	test   %eax,%eax
  801879:	78 0e                	js     801889 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80187b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80187e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801881:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	53                   	push   %ebx
  80188f:	83 ec 24             	sub    $0x24,%esp
  801892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801895:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189c:	89 1c 24             	mov    %ebx,(%esp)
  80189f:	e8 c2 fb ff ff       	call   801466 <fd_lookup>
  8018a4:	89 c2                	mov    %eax,%edx
  8018a6:	85 d2                	test   %edx,%edx
  8018a8:	78 61                	js     80190b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b4:	8b 00                	mov    (%eax),%eax
  8018b6:	89 04 24             	mov    %eax,(%esp)
  8018b9:	e8 fe fb ff ff       	call   8014bc <dev_lookup>
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 49                	js     80190b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c9:	75 23                	jne    8018ee <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018cb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018d0:	8b 40 48             	mov    0x48(%eax),%eax
  8018d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018db:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  8018e2:	e8 30 eb ff ff       	call   800417 <cprintf>
		return -E_INVAL;
  8018e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018ec:	eb 1d                	jmp    80190b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f1:	8b 52 18             	mov    0x18(%edx),%edx
  8018f4:	85 d2                	test   %edx,%edx
  8018f6:	74 0e                	je     801906 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ff:	89 04 24             	mov    %eax,(%esp)
  801902:	ff d2                	call   *%edx
  801904:	eb 05                	jmp    80190b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801906:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80190b:	83 c4 24             	add    $0x24,%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	53                   	push   %ebx
  801915:	83 ec 24             	sub    $0x24,%esp
  801918:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	89 04 24             	mov    %eax,(%esp)
  801928:	e8 39 fb ff ff       	call   801466 <fd_lookup>
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	85 d2                	test   %edx,%edx
  801931:	78 52                	js     801985 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801933:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193d:	8b 00                	mov    (%eax),%eax
  80193f:	89 04 24             	mov    %eax,(%esp)
  801942:	e8 75 fb ff ff       	call   8014bc <dev_lookup>
  801947:	85 c0                	test   %eax,%eax
  801949:	78 3a                	js     801985 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801952:	74 2c                	je     801980 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801954:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801957:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80195e:	00 00 00 
	stat->st_isdir = 0;
  801961:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801968:	00 00 00 
	stat->st_dev = dev;
  80196b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801971:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801975:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801978:	89 14 24             	mov    %edx,(%esp)
  80197b:	ff 50 14             	call   *0x14(%eax)
  80197e:	eb 05                	jmp    801985 <fstat+0x74>
		return -E_NOT_SUPP;
  801980:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801985:	83 c4 24             	add    $0x24,%esp
  801988:	5b                   	pop    %ebx
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    

0080198b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801993:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80199a:	00 
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	89 04 24             	mov    %eax,(%esp)
  8019a1:	e8 fb 01 00 00       	call   801ba1 <open>
  8019a6:	89 c3                	mov    %eax,%ebx
  8019a8:	85 db                	test   %ebx,%ebx
  8019aa:	78 1b                	js     8019c7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b3:	89 1c 24             	mov    %ebx,(%esp)
  8019b6:	e8 56 ff ff ff       	call   801911 <fstat>
  8019bb:	89 c6                	mov    %eax,%esi
	close(fd);
  8019bd:	89 1c 24             	mov    %ebx,(%esp)
  8019c0:	e8 cd fb ff ff       	call   801592 <close>
	return r;
  8019c5:	89 f0                	mov    %esi,%eax
}
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5e                   	pop    %esi
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	83 ec 10             	sub    $0x10,%esp
  8019d6:	89 c6                	mov    %eax,%esi
  8019d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019da:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019e1:	75 11                	jne    8019f4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019ea:	e8 00 09 00 00       	call   8022ef <ipc_find_env>
  8019ef:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019f4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019fb:	00 
  8019fc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a03:	00 
  801a04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a08:	a1 04 40 80 00       	mov    0x804004,%eax
  801a0d:	89 04 24             	mov    %eax,(%esp)
  801a10:	e8 73 08 00 00       	call   802288 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a1c:	00 
  801a1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a28:	e8 f3 07 00 00       	call   802220 <ipc_recv>
}
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a40:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a48:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a52:	b8 02 00 00 00       	mov    $0x2,%eax
  801a57:	e8 72 ff ff ff       	call   8019ce <fsipc>
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <devfile_flush>:
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a74:	b8 06 00 00 00       	mov    $0x6,%eax
  801a79:	e8 50 ff ff ff       	call   8019ce <fsipc>
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <devfile_stat>:
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	53                   	push   %ebx
  801a84:	83 ec 14             	sub    $0x14,%esp
  801a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a90:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a95:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a9f:	e8 2a ff ff ff       	call   8019ce <fsipc>
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	85 d2                	test   %edx,%edx
  801aa8:	78 2b                	js     801ad5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aaa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ab1:	00 
  801ab2:	89 1c 24             	mov    %ebx,(%esp)
  801ab5:	e8 8d ef ff ff       	call   800a47 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aba:	a1 80 50 80 00       	mov    0x805080,%eax
  801abf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ac5:	a1 84 50 80 00       	mov    0x805084,%eax
  801aca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad5:	83 c4 14             	add    $0x14,%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <devfile_write>:
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801ae1:	c7 44 24 08 f8 2b 80 	movl   $0x802bf8,0x8(%esp)
  801ae8:	00 
  801ae9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801af0:	00 
  801af1:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  801af8:	e8 21 e8 ff ff       	call   80031e <_panic>

00801afd <devfile_read>:
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 10             	sub    $0x10,%esp
  801b05:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b08:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b23:	e8 a6 fe ff ff       	call   8019ce <fsipc>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	78 6a                	js     801b98 <devfile_read+0x9b>
	assert(r <= n);
  801b2e:	39 c6                	cmp    %eax,%esi
  801b30:	73 24                	jae    801b56 <devfile_read+0x59>
  801b32:	c7 44 24 0c 21 2c 80 	movl   $0x802c21,0xc(%esp)
  801b39:	00 
  801b3a:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  801b41:	00 
  801b42:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b49:	00 
  801b4a:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  801b51:	e8 c8 e7 ff ff       	call   80031e <_panic>
	assert(r <= PGSIZE);
  801b56:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b5b:	7e 24                	jle    801b81 <devfile_read+0x84>
  801b5d:	c7 44 24 0c 3d 2c 80 	movl   $0x802c3d,0xc(%esp)
  801b64:	00 
  801b65:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  801b6c:	00 
  801b6d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b74:	00 
  801b75:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  801b7c:	e8 9d e7 ff ff       	call   80031e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b81:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b85:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b8c:	00 
  801b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b90:	89 04 24             	mov    %eax,(%esp)
  801b93:	e8 4c f0 ff ff       	call   800be4 <memmove>
}
  801b98:	89 d8                	mov    %ebx,%eax
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <open>:
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	53                   	push   %ebx
  801ba5:	83 ec 24             	sub    $0x24,%esp
  801ba8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801bab:	89 1c 24             	mov    %ebx,(%esp)
  801bae:	e8 5d ee ff ff       	call   800a10 <strlen>
  801bb3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bb8:	7f 60                	jg     801c1a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801bba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbd:	89 04 24             	mov    %eax,(%esp)
  801bc0:	e8 52 f8 ff ff       	call   801417 <fd_alloc>
  801bc5:	89 c2                	mov    %eax,%edx
  801bc7:	85 d2                	test   %edx,%edx
  801bc9:	78 54                	js     801c1f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801bcb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bcf:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bd6:	e8 6c ee ff ff       	call   800a47 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bde:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be6:	b8 01 00 00 00       	mov    $0x1,%eax
  801beb:	e8 de fd ff ff       	call   8019ce <fsipc>
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	79 17                	jns    801c0d <open+0x6c>
		fd_close(fd, 0);
  801bf6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bfd:	00 
  801bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c01:	89 04 24             	mov    %eax,(%esp)
  801c04:	e8 08 f9 ff ff       	call   801511 <fd_close>
		return r;
  801c09:	89 d8                	mov    %ebx,%eax
  801c0b:	eb 12                	jmp    801c1f <open+0x7e>
	return fd2num(fd);
  801c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c10:	89 04 24             	mov    %eax,(%esp)
  801c13:	e8 d8 f7 ff ff       	call   8013f0 <fd2num>
  801c18:	eb 05                	jmp    801c1f <open+0x7e>
		return -E_BAD_PATH;
  801c1a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801c1f:	83 c4 24             	add    $0x24,%esp
  801c22:	5b                   	pop    %ebx
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c30:	b8 08 00 00 00       	mov    $0x8,%eax
  801c35:	e8 94 fd ff ff       	call   8019ce <fsipc>
}
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 10             	sub    $0x10,%esp
  801c44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c47:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4a:	89 04 24             	mov    %eax,(%esp)
  801c4d:	e8 ae f7 ff ff       	call   801400 <fd2data>
  801c52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c54:	c7 44 24 04 49 2c 80 	movl   $0x802c49,0x4(%esp)
  801c5b:	00 
  801c5c:	89 1c 24             	mov    %ebx,(%esp)
  801c5f:	e8 e3 ed ff ff       	call   800a47 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c64:	8b 46 04             	mov    0x4(%esi),%eax
  801c67:	2b 06                	sub    (%esi),%eax
  801c69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c6f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c76:	00 00 00 
	stat->st_dev = &devpipe;
  801c79:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c80:	30 80 00 
	return 0;
}
  801c83:	b8 00 00 00 00       	mov    $0x0,%eax
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	53                   	push   %ebx
  801c93:	83 ec 14             	sub    $0x14,%esp
  801c96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca4:	e8 61 f2 ff ff       	call   800f0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ca9:	89 1c 24             	mov    %ebx,(%esp)
  801cac:	e8 4f f7 ff ff       	call   801400 <fd2data>
  801cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cbc:	e8 49 f2 ff ff       	call   800f0a <sys_page_unmap>
}
  801cc1:	83 c4 14             	add    $0x14,%esp
  801cc4:	5b                   	pop    %ebx
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <_pipeisclosed>:
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	57                   	push   %edi
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	83 ec 2c             	sub    $0x2c,%esp
  801cd0:	89 c6                	mov    %eax,%esi
  801cd2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801cd5:	a1 08 40 80 00       	mov    0x804008,%eax
  801cda:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cdd:	89 34 24             	mov    %esi,(%esp)
  801ce0:	e8 42 06 00 00       	call   802327 <pageref>
  801ce5:	89 c7                	mov    %eax,%edi
  801ce7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cea:	89 04 24             	mov    %eax,(%esp)
  801ced:	e8 35 06 00 00       	call   802327 <pageref>
  801cf2:	39 c7                	cmp    %eax,%edi
  801cf4:	0f 94 c2             	sete   %dl
  801cf7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801cfa:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801d00:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d03:	39 fb                	cmp    %edi,%ebx
  801d05:	74 21                	je     801d28 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801d07:	84 d2                	test   %dl,%dl
  801d09:	74 ca                	je     801cd5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d0b:	8b 51 58             	mov    0x58(%ecx),%edx
  801d0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d12:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d1a:	c7 04 24 50 2c 80 00 	movl   $0x802c50,(%esp)
  801d21:	e8 f1 e6 ff ff       	call   800417 <cprintf>
  801d26:	eb ad                	jmp    801cd5 <_pipeisclosed+0xe>
}
  801d28:	83 c4 2c             	add    $0x2c,%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <devpipe_write>:
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	57                   	push   %edi
  801d34:	56                   	push   %esi
  801d35:	53                   	push   %ebx
  801d36:	83 ec 1c             	sub    $0x1c,%esp
  801d39:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d3c:	89 34 24             	mov    %esi,(%esp)
  801d3f:	e8 bc f6 ff ff       	call   801400 <fd2data>
  801d44:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d46:	bf 00 00 00 00       	mov    $0x0,%edi
  801d4b:	eb 45                	jmp    801d92 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801d4d:	89 da                	mov    %ebx,%edx
  801d4f:	89 f0                	mov    %esi,%eax
  801d51:	e8 71 ff ff ff       	call   801cc7 <_pipeisclosed>
  801d56:	85 c0                	test   %eax,%eax
  801d58:	75 41                	jne    801d9b <devpipe_write+0x6b>
			sys_yield();
  801d5a:	e8 e5 f0 ff ff       	call   800e44 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d5f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d62:	8b 0b                	mov    (%ebx),%ecx
  801d64:	8d 51 20             	lea    0x20(%ecx),%edx
  801d67:	39 d0                	cmp    %edx,%eax
  801d69:	73 e2                	jae    801d4d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d6e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d72:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d75:	99                   	cltd   
  801d76:	c1 ea 1b             	shr    $0x1b,%edx
  801d79:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d7c:	83 e1 1f             	and    $0x1f,%ecx
  801d7f:	29 d1                	sub    %edx,%ecx
  801d81:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d85:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d89:	83 c0 01             	add    $0x1,%eax
  801d8c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d8f:	83 c7 01             	add    $0x1,%edi
  801d92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d95:	75 c8                	jne    801d5f <devpipe_write+0x2f>
	return i;
  801d97:	89 f8                	mov    %edi,%eax
  801d99:	eb 05                	jmp    801da0 <devpipe_write+0x70>
				return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da0:	83 c4 1c             	add    $0x1c,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <devpipe_read>:
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	57                   	push   %edi
  801dac:	56                   	push   %esi
  801dad:	53                   	push   %ebx
  801dae:	83 ec 1c             	sub    $0x1c,%esp
  801db1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801db4:	89 3c 24             	mov    %edi,(%esp)
  801db7:	e8 44 f6 ff ff       	call   801400 <fd2data>
  801dbc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dbe:	be 00 00 00 00       	mov    $0x0,%esi
  801dc3:	eb 3d                	jmp    801e02 <devpipe_read+0x5a>
			if (i > 0)
  801dc5:	85 f6                	test   %esi,%esi
  801dc7:	74 04                	je     801dcd <devpipe_read+0x25>
				return i;
  801dc9:	89 f0                	mov    %esi,%eax
  801dcb:	eb 43                	jmp    801e10 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801dcd:	89 da                	mov    %ebx,%edx
  801dcf:	89 f8                	mov    %edi,%eax
  801dd1:	e8 f1 fe ff ff       	call   801cc7 <_pipeisclosed>
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	75 31                	jne    801e0b <devpipe_read+0x63>
			sys_yield();
  801dda:	e8 65 f0 ff ff       	call   800e44 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ddf:	8b 03                	mov    (%ebx),%eax
  801de1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801de4:	74 df                	je     801dc5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801de6:	99                   	cltd   
  801de7:	c1 ea 1b             	shr    $0x1b,%edx
  801dea:	01 d0                	add    %edx,%eax
  801dec:	83 e0 1f             	and    $0x1f,%eax
  801def:	29 d0                	sub    %edx,%eax
  801df1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dfc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dff:	83 c6 01             	add    $0x1,%esi
  801e02:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e05:	75 d8                	jne    801ddf <devpipe_read+0x37>
	return i;
  801e07:	89 f0                	mov    %esi,%eax
  801e09:	eb 05                	jmp    801e10 <devpipe_read+0x68>
				return 0;
  801e0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e10:	83 c4 1c             	add    $0x1c,%esp
  801e13:	5b                   	pop    %ebx
  801e14:	5e                   	pop    %esi
  801e15:	5f                   	pop    %edi
  801e16:	5d                   	pop    %ebp
  801e17:	c3                   	ret    

00801e18 <pipe>:
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	56                   	push   %esi
  801e1c:	53                   	push   %ebx
  801e1d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e23:	89 04 24             	mov    %eax,(%esp)
  801e26:	e8 ec f5 ff ff       	call   801417 <fd_alloc>
  801e2b:	89 c2                	mov    %eax,%edx
  801e2d:	85 d2                	test   %edx,%edx
  801e2f:	0f 88 4d 01 00 00    	js     801f82 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e35:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e3c:	00 
  801e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4b:	e8 13 f0 ff ff       	call   800e63 <sys_page_alloc>
  801e50:	89 c2                	mov    %eax,%edx
  801e52:	85 d2                	test   %edx,%edx
  801e54:	0f 88 28 01 00 00    	js     801f82 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801e5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e5d:	89 04 24             	mov    %eax,(%esp)
  801e60:	e8 b2 f5 ff ff       	call   801417 <fd_alloc>
  801e65:	89 c3                	mov    %eax,%ebx
  801e67:	85 c0                	test   %eax,%eax
  801e69:	0f 88 fe 00 00 00    	js     801f6d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e76:	00 
  801e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e85:	e8 d9 ef ff ff       	call   800e63 <sys_page_alloc>
  801e8a:	89 c3                	mov    %eax,%ebx
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	0f 88 d9 00 00 00    	js     801f6d <pipe+0x155>
	va = fd2data(fd0);
  801e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e97:	89 04 24             	mov    %eax,(%esp)
  801e9a:	e8 61 f5 ff ff       	call   801400 <fd2data>
  801e9f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ea8:	00 
  801ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ead:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb4:	e8 aa ef ff ff       	call   800e63 <sys_page_alloc>
  801eb9:	89 c3                	mov    %eax,%ebx
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	0f 88 97 00 00 00    	js     801f5a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec6:	89 04 24             	mov    %eax,(%esp)
  801ec9:	e8 32 f5 ff ff       	call   801400 <fd2data>
  801ece:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ed5:	00 
  801ed6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ee1:	00 
  801ee2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eed:	e8 c5 ef ff ff       	call   800eb7 <sys_page_map>
  801ef2:	89 c3                	mov    %eax,%ebx
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	78 52                	js     801f4a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801ef8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f01:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f06:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801f0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f16:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f1b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f25:	89 04 24             	mov    %eax,(%esp)
  801f28:	e8 c3 f4 ff ff       	call   8013f0 <fd2num>
  801f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f30:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f35:	89 04 24             	mov    %eax,(%esp)
  801f38:	e8 b3 f4 ff ff       	call   8013f0 <fd2num>
  801f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f40:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f43:	b8 00 00 00 00       	mov    $0x0,%eax
  801f48:	eb 38                	jmp    801f82 <pipe+0x16a>
	sys_page_unmap(0, va);
  801f4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f55:	e8 b0 ef ff ff       	call   800f0a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f68:	e8 9d ef ff ff       	call   800f0a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f7b:	e8 8a ef ff ff       	call   800f0a <sys_page_unmap>
  801f80:	89 d8                	mov    %ebx,%eax
}
  801f82:	83 c4 30             	add    $0x30,%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    

00801f89 <pipeisclosed>:
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	89 04 24             	mov    %eax,(%esp)
  801f9c:	e8 c5 f4 ff ff       	call   801466 <fd_lookup>
  801fa1:	89 c2                	mov    %eax,%edx
  801fa3:	85 d2                	test   %edx,%edx
  801fa5:	78 15                	js     801fbc <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faa:	89 04 24             	mov    %eax,(%esp)
  801fad:	e8 4e f4 ff ff       	call   801400 <fd2data>
	return _pipeisclosed(fd, p);
  801fb2:	89 c2                	mov    %eax,%edx
  801fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb7:	e8 0b fd ff ff       	call   801cc7 <_pipeisclosed>
}
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    
  801fbe:	66 90                	xchg   %ax,%ax

00801fc0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    

00801fca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fd0:	c7 44 24 04 63 2c 80 	movl   $0x802c63,0x4(%esp)
  801fd7:	00 
  801fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fdb:	89 04 24             	mov    %eax,(%esp)
  801fde:	e8 64 ea ff ff       	call   800a47 <strcpy>
	return 0;
}
  801fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <devcons_write>:
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	57                   	push   %edi
  801fee:	56                   	push   %esi
  801fef:	53                   	push   %ebx
  801ff0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ffb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802001:	eb 31                	jmp    802034 <devcons_write+0x4a>
		m = n - tot;
  802003:	8b 75 10             	mov    0x10(%ebp),%esi
  802006:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802008:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80200b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802010:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802013:	89 74 24 08          	mov    %esi,0x8(%esp)
  802017:	03 45 0c             	add    0xc(%ebp),%eax
  80201a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201e:	89 3c 24             	mov    %edi,(%esp)
  802021:	e8 be eb ff ff       	call   800be4 <memmove>
		sys_cputs(buf, m);
  802026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80202a:	89 3c 24             	mov    %edi,(%esp)
  80202d:	e8 64 ed ff ff       	call   800d96 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802032:	01 f3                	add    %esi,%ebx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802039:	72 c8                	jb     802003 <devcons_write+0x19>
}
  80203b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5f                   	pop    %edi
  802044:	5d                   	pop    %ebp
  802045:	c3                   	ret    

00802046 <devcons_read>:
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80204c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802051:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802055:	75 07                	jne    80205e <devcons_read+0x18>
  802057:	eb 2a                	jmp    802083 <devcons_read+0x3d>
		sys_yield();
  802059:	e8 e6 ed ff ff       	call   800e44 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80205e:	66 90                	xchg   %ax,%ax
  802060:	e8 4f ed ff ff       	call   800db4 <sys_cgetc>
  802065:	85 c0                	test   %eax,%eax
  802067:	74 f0                	je     802059 <devcons_read+0x13>
	if (c < 0)
  802069:	85 c0                	test   %eax,%eax
  80206b:	78 16                	js     802083 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80206d:	83 f8 04             	cmp    $0x4,%eax
  802070:	74 0c                	je     80207e <devcons_read+0x38>
	*(char*)vbuf = c;
  802072:	8b 55 0c             	mov    0xc(%ebp),%edx
  802075:	88 02                	mov    %al,(%edx)
	return 1;
  802077:	b8 01 00 00 00       	mov    $0x1,%eax
  80207c:	eb 05                	jmp    802083 <devcons_read+0x3d>
		return 0;
  80207e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802083:	c9                   	leave  
  802084:	c3                   	ret    

00802085 <cputchar>:
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80208b:	8b 45 08             	mov    0x8(%ebp),%eax
  80208e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802091:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802098:	00 
  802099:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209c:	89 04 24             	mov    %eax,(%esp)
  80209f:	e8 f2 ec ff ff       	call   800d96 <sys_cputs>
}
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <getchar>:
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8020ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020b3:	00 
  8020b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c2:	e8 2e f6 ff ff       	call   8016f5 <read>
	if (r < 0)
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	78 0f                	js     8020da <getchar+0x34>
	if (r < 1)
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	7e 06                	jle    8020d5 <getchar+0x2f>
	return c;
  8020cf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020d3:	eb 05                	jmp    8020da <getchar+0x34>
		return -E_EOF;
  8020d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8020da:	c9                   	leave  
  8020db:	c3                   	ret    

008020dc <iscons>:
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ec:	89 04 24             	mov    %eax,(%esp)
  8020ef:	e8 72 f3 ff ff       	call   801466 <fd_lookup>
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	78 11                	js     802109 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8020f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802101:	39 10                	cmp    %edx,(%eax)
  802103:	0f 94 c0             	sete   %al
  802106:	0f b6 c0             	movzbl %al,%eax
}
  802109:	c9                   	leave  
  80210a:	c3                   	ret    

0080210b <opencons>:
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802114:	89 04 24             	mov    %eax,(%esp)
  802117:	e8 fb f2 ff ff       	call   801417 <fd_alloc>
		return r;
  80211c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80211e:	85 c0                	test   %eax,%eax
  802120:	78 40                	js     802162 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802122:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802129:	00 
  80212a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802138:	e8 26 ed ff ff       	call   800e63 <sys_page_alloc>
		return r;
  80213d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80213f:	85 c0                	test   %eax,%eax
  802141:	78 1f                	js     802162 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802143:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80214e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802151:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802158:	89 04 24             	mov    %eax,(%esp)
  80215b:	e8 90 f2 ff ff       	call   8013f0 <fd2num>
  802160:	89 c2                	mov    %eax,%edx
}
  802162:	89 d0                	mov    %edx,%eax
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  80216c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802173:	75 70                	jne    8021e5 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802175:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80217c:	00 
  80217d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802184:	ee 
  802185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218c:	e8 d2 ec ff ff       	call   800e63 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  802191:	85 c0                	test   %eax,%eax
  802193:	79 1c                	jns    8021b1 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  802195:	c7 44 24 08 70 2c 80 	movl   $0x802c70,0x8(%esp)
  80219c:	00 
  80219d:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8021a4:	00 
  8021a5:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  8021ac:	e8 6d e1 ff ff       	call   80031e <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  8021b1:	c7 44 24 04 ef 21 80 	movl   $0x8021ef,0x4(%esp)
  8021b8:	00 
  8021b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c0:	e8 3e ee ff ff       	call   801003 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	79 1c                	jns    8021e5 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  8021c9:	c7 44 24 08 98 2c 80 	movl   $0x802c98,0x8(%esp)
  8021d0:	00 
  8021d1:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8021d8:	00 
  8021d9:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  8021e0:	e8 39 e1 ff ff       	call   80031e <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021ed:	c9                   	leave  
  8021ee:	c3                   	ret    

008021ef <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021ef:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021f0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021f5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021f7:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  8021fa:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  8021fe:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802202:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  802204:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  802206:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  802207:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  80220a:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  80220c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  80220f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802210:	83 c4 04             	add    $0x4,%esp
    popf;
  802213:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  802214:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  802215:	c3                   	ret    
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	56                   	push   %esi
  802224:	53                   	push   %ebx
  802225:	83 ec 10             	sub    $0x10,%esp
  802228:	8b 75 08             	mov    0x8(%ebp),%esi
  80222b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802231:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802233:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802238:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80223b:	89 04 24             	mov    %eax,(%esp)
  80223e:	e8 36 ee ff ff       	call   801079 <sys_ipc_recv>
    if(r < 0){
  802243:	85 c0                	test   %eax,%eax
  802245:	79 16                	jns    80225d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802247:	85 f6                	test   %esi,%esi
  802249:	74 06                	je     802251 <ipc_recv+0x31>
            *from_env_store = 0;
  80224b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802251:	85 db                	test   %ebx,%ebx
  802253:	74 2c                	je     802281 <ipc_recv+0x61>
            *perm_store = 0;
  802255:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80225b:	eb 24                	jmp    802281 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80225d:	85 f6                	test   %esi,%esi
  80225f:	74 0a                	je     80226b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802261:	a1 08 40 80 00       	mov    0x804008,%eax
  802266:	8b 40 74             	mov    0x74(%eax),%eax
  802269:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80226b:	85 db                	test   %ebx,%ebx
  80226d:	74 0a                	je     802279 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80226f:	a1 08 40 80 00       	mov    0x804008,%eax
  802274:	8b 40 78             	mov    0x78(%eax),%eax
  802277:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802279:	a1 08 40 80 00       	mov    0x804008,%eax
  80227e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802281:	83 c4 10             	add    $0x10,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	57                   	push   %edi
  80228c:	56                   	push   %esi
  80228d:	53                   	push   %ebx
  80228e:	83 ec 1c             	sub    $0x1c,%esp
  802291:	8b 7d 08             	mov    0x8(%ebp),%edi
  802294:	8b 75 0c             	mov    0xc(%ebp),%esi
  802297:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80229a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80229c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8022a1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8022a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8022a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b3:	89 3c 24             	mov    %edi,(%esp)
  8022b6:	e8 9b ed ff ff       	call   801056 <sys_ipc_try_send>
        if(r == 0){
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	74 28                	je     8022e7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8022bf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022c2:	74 1c                	je     8022e0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8022c4:	c7 44 24 08 da 2c 80 	movl   $0x802cda,0x8(%esp)
  8022cb:	00 
  8022cc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8022d3:	00 
  8022d4:	c7 04 24 f1 2c 80 00 	movl   $0x802cf1,(%esp)
  8022db:	e8 3e e0 ff ff       	call   80031e <_panic>
        }
        sys_yield();
  8022e0:	e8 5f eb ff ff       	call   800e44 <sys_yield>
    }
  8022e5:	eb bd                	jmp    8022a4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8022e7:	83 c4 1c             	add    $0x1c,%esp
  8022ea:	5b                   	pop    %ebx
  8022eb:	5e                   	pop    %esi
  8022ec:	5f                   	pop    %edi
  8022ed:	5d                   	pop    %ebp
  8022ee:	c3                   	ret    

008022ef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022ef:	55                   	push   %ebp
  8022f0:	89 e5                	mov    %esp,%ebp
  8022f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022f5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022fa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022fd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802303:	8b 52 50             	mov    0x50(%edx),%edx
  802306:	39 ca                	cmp    %ecx,%edx
  802308:	75 0d                	jne    802317 <ipc_find_env+0x28>
			return envs[i].env_id;
  80230a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80230d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802312:	8b 40 40             	mov    0x40(%eax),%eax
  802315:	eb 0e                	jmp    802325 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802317:	83 c0 01             	add    $0x1,%eax
  80231a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80231f:	75 d9                	jne    8022fa <ipc_find_env+0xb>
	return 0;
  802321:	66 b8 00 00          	mov    $0x0,%ax
}
  802325:	5d                   	pop    %ebp
  802326:	c3                   	ret    

00802327 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802327:	55                   	push   %ebp
  802328:	89 e5                	mov    %esp,%ebp
  80232a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80232d:	89 d0                	mov    %edx,%eax
  80232f:	c1 e8 16             	shr    $0x16,%eax
  802332:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802339:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80233e:	f6 c1 01             	test   $0x1,%cl
  802341:	74 1d                	je     802360 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802343:	c1 ea 0c             	shr    $0xc,%edx
  802346:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80234d:	f6 c2 01             	test   $0x1,%dl
  802350:	74 0e                	je     802360 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802352:	c1 ea 0c             	shr    $0xc,%edx
  802355:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80235c:	ef 
  80235d:	0f b7 c0             	movzwl %ax,%eax
}
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    
  802362:	66 90                	xchg   %ax,%ax
  802364:	66 90                	xchg   %ax,%ax
  802366:	66 90                	xchg   %ax,%ax
  802368:	66 90                	xchg   %ax,%ax
  80236a:	66 90                	xchg   %ax,%ax
  80236c:	66 90                	xchg   %ax,%ax
  80236e:	66 90                	xchg   %ax,%ax

00802370 <__udivdi3>:
  802370:	55                   	push   %ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	83 ec 0c             	sub    $0xc,%esp
  802376:	8b 44 24 28          	mov    0x28(%esp),%eax
  80237a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80237e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802382:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802386:	85 c0                	test   %eax,%eax
  802388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80238c:	89 ea                	mov    %ebp,%edx
  80238e:	89 0c 24             	mov    %ecx,(%esp)
  802391:	75 2d                	jne    8023c0 <__udivdi3+0x50>
  802393:	39 e9                	cmp    %ebp,%ecx
  802395:	77 61                	ja     8023f8 <__udivdi3+0x88>
  802397:	85 c9                	test   %ecx,%ecx
  802399:	89 ce                	mov    %ecx,%esi
  80239b:	75 0b                	jne    8023a8 <__udivdi3+0x38>
  80239d:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a2:	31 d2                	xor    %edx,%edx
  8023a4:	f7 f1                	div    %ecx
  8023a6:	89 c6                	mov    %eax,%esi
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	89 e8                	mov    %ebp,%eax
  8023ac:	f7 f6                	div    %esi
  8023ae:	89 c5                	mov    %eax,%ebp
  8023b0:	89 f8                	mov    %edi,%eax
  8023b2:	f7 f6                	div    %esi
  8023b4:	89 ea                	mov    %ebp,%edx
  8023b6:	83 c4 0c             	add    $0xc,%esp
  8023b9:	5e                   	pop    %esi
  8023ba:	5f                   	pop    %edi
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    
  8023bd:	8d 76 00             	lea    0x0(%esi),%esi
  8023c0:	39 e8                	cmp    %ebp,%eax
  8023c2:	77 24                	ja     8023e8 <__udivdi3+0x78>
  8023c4:	0f bd e8             	bsr    %eax,%ebp
  8023c7:	83 f5 1f             	xor    $0x1f,%ebp
  8023ca:	75 3c                	jne    802408 <__udivdi3+0x98>
  8023cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023d0:	39 34 24             	cmp    %esi,(%esp)
  8023d3:	0f 86 9f 00 00 00    	jbe    802478 <__udivdi3+0x108>
  8023d9:	39 d0                	cmp    %edx,%eax
  8023db:	0f 82 97 00 00 00    	jb     802478 <__udivdi3+0x108>
  8023e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	31 d2                	xor    %edx,%edx
  8023ea:	31 c0                	xor    %eax,%eax
  8023ec:	83 c4 0c             	add    $0xc,%esp
  8023ef:	5e                   	pop    %esi
  8023f0:	5f                   	pop    %edi
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    
  8023f3:	90                   	nop
  8023f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f8:	89 f8                	mov    %edi,%eax
  8023fa:	f7 f1                	div    %ecx
  8023fc:	31 d2                	xor    %edx,%edx
  8023fe:	83 c4 0c             	add    $0xc,%esp
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    
  802405:	8d 76 00             	lea    0x0(%esi),%esi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	8b 3c 24             	mov    (%esp),%edi
  80240d:	d3 e0                	shl    %cl,%eax
  80240f:	89 c6                	mov    %eax,%esi
  802411:	b8 20 00 00 00       	mov    $0x20,%eax
  802416:	29 e8                	sub    %ebp,%eax
  802418:	89 c1                	mov    %eax,%ecx
  80241a:	d3 ef                	shr    %cl,%edi
  80241c:	89 e9                	mov    %ebp,%ecx
  80241e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802422:	8b 3c 24             	mov    (%esp),%edi
  802425:	09 74 24 08          	or     %esi,0x8(%esp)
  802429:	89 d6                	mov    %edx,%esi
  80242b:	d3 e7                	shl    %cl,%edi
  80242d:	89 c1                	mov    %eax,%ecx
  80242f:	89 3c 24             	mov    %edi,(%esp)
  802432:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802436:	d3 ee                	shr    %cl,%esi
  802438:	89 e9                	mov    %ebp,%ecx
  80243a:	d3 e2                	shl    %cl,%edx
  80243c:	89 c1                	mov    %eax,%ecx
  80243e:	d3 ef                	shr    %cl,%edi
  802440:	09 d7                	or     %edx,%edi
  802442:	89 f2                	mov    %esi,%edx
  802444:	89 f8                	mov    %edi,%eax
  802446:	f7 74 24 08          	divl   0x8(%esp)
  80244a:	89 d6                	mov    %edx,%esi
  80244c:	89 c7                	mov    %eax,%edi
  80244e:	f7 24 24             	mull   (%esp)
  802451:	39 d6                	cmp    %edx,%esi
  802453:	89 14 24             	mov    %edx,(%esp)
  802456:	72 30                	jb     802488 <__udivdi3+0x118>
  802458:	8b 54 24 04          	mov    0x4(%esp),%edx
  80245c:	89 e9                	mov    %ebp,%ecx
  80245e:	d3 e2                	shl    %cl,%edx
  802460:	39 c2                	cmp    %eax,%edx
  802462:	73 05                	jae    802469 <__udivdi3+0xf9>
  802464:	3b 34 24             	cmp    (%esp),%esi
  802467:	74 1f                	je     802488 <__udivdi3+0x118>
  802469:	89 f8                	mov    %edi,%eax
  80246b:	31 d2                	xor    %edx,%edx
  80246d:	e9 7a ff ff ff       	jmp    8023ec <__udivdi3+0x7c>
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	31 d2                	xor    %edx,%edx
  80247a:	b8 01 00 00 00       	mov    $0x1,%eax
  80247f:	e9 68 ff ff ff       	jmp    8023ec <__udivdi3+0x7c>
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	8d 47 ff             	lea    -0x1(%edi),%eax
  80248b:	31 d2                	xor    %edx,%edx
  80248d:	83 c4 0c             	add    $0xc,%esp
  802490:	5e                   	pop    %esi
  802491:	5f                   	pop    %edi
  802492:	5d                   	pop    %ebp
  802493:	c3                   	ret    
  802494:	66 90                	xchg   %ax,%ax
  802496:	66 90                	xchg   %ax,%ax
  802498:	66 90                	xchg   %ax,%ax
  80249a:	66 90                	xchg   %ax,%ax
  80249c:	66 90                	xchg   %ax,%ax
  80249e:	66 90                	xchg   %ax,%ax

008024a0 <__umoddi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	57                   	push   %edi
  8024a2:	56                   	push   %esi
  8024a3:	83 ec 14             	sub    $0x14,%esp
  8024a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8024aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8024ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8024b2:	89 c7                	mov    %eax,%edi
  8024b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024c0:	89 34 24             	mov    %esi,(%esp)
  8024c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	89 c2                	mov    %eax,%edx
  8024cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024cf:	75 17                	jne    8024e8 <__umoddi3+0x48>
  8024d1:	39 fe                	cmp    %edi,%esi
  8024d3:	76 4b                	jbe    802520 <__umoddi3+0x80>
  8024d5:	89 c8                	mov    %ecx,%eax
  8024d7:	89 fa                	mov    %edi,%edx
  8024d9:	f7 f6                	div    %esi
  8024db:	89 d0                	mov    %edx,%eax
  8024dd:	31 d2                	xor    %edx,%edx
  8024df:	83 c4 14             	add    $0x14,%esp
  8024e2:	5e                   	pop    %esi
  8024e3:	5f                   	pop    %edi
  8024e4:	5d                   	pop    %ebp
  8024e5:	c3                   	ret    
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	39 f8                	cmp    %edi,%eax
  8024ea:	77 54                	ja     802540 <__umoddi3+0xa0>
  8024ec:	0f bd e8             	bsr    %eax,%ebp
  8024ef:	83 f5 1f             	xor    $0x1f,%ebp
  8024f2:	75 5c                	jne    802550 <__umoddi3+0xb0>
  8024f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024f8:	39 3c 24             	cmp    %edi,(%esp)
  8024fb:	0f 87 e7 00 00 00    	ja     8025e8 <__umoddi3+0x148>
  802501:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802505:	29 f1                	sub    %esi,%ecx
  802507:	19 c7                	sbb    %eax,%edi
  802509:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80250d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802511:	8b 44 24 08          	mov    0x8(%esp),%eax
  802515:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802519:	83 c4 14             	add    $0x14,%esp
  80251c:	5e                   	pop    %esi
  80251d:	5f                   	pop    %edi
  80251e:	5d                   	pop    %ebp
  80251f:	c3                   	ret    
  802520:	85 f6                	test   %esi,%esi
  802522:	89 f5                	mov    %esi,%ebp
  802524:	75 0b                	jne    802531 <__umoddi3+0x91>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f6                	div    %esi
  80252f:	89 c5                	mov    %eax,%ebp
  802531:	8b 44 24 04          	mov    0x4(%esp),%eax
  802535:	31 d2                	xor    %edx,%edx
  802537:	f7 f5                	div    %ebp
  802539:	89 c8                	mov    %ecx,%eax
  80253b:	f7 f5                	div    %ebp
  80253d:	eb 9c                	jmp    8024db <__umoddi3+0x3b>
  80253f:	90                   	nop
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 fa                	mov    %edi,%edx
  802544:	83 c4 14             	add    $0x14,%esp
  802547:	5e                   	pop    %esi
  802548:	5f                   	pop    %edi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    
  80254b:	90                   	nop
  80254c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802550:	8b 04 24             	mov    (%esp),%eax
  802553:	be 20 00 00 00       	mov    $0x20,%esi
  802558:	89 e9                	mov    %ebp,%ecx
  80255a:	29 ee                	sub    %ebp,%esi
  80255c:	d3 e2                	shl    %cl,%edx
  80255e:	89 f1                	mov    %esi,%ecx
  802560:	d3 e8                	shr    %cl,%eax
  802562:	89 e9                	mov    %ebp,%ecx
  802564:	89 44 24 04          	mov    %eax,0x4(%esp)
  802568:	8b 04 24             	mov    (%esp),%eax
  80256b:	09 54 24 04          	or     %edx,0x4(%esp)
  80256f:	89 fa                	mov    %edi,%edx
  802571:	d3 e0                	shl    %cl,%eax
  802573:	89 f1                	mov    %esi,%ecx
  802575:	89 44 24 08          	mov    %eax,0x8(%esp)
  802579:	8b 44 24 10          	mov    0x10(%esp),%eax
  80257d:	d3 ea                	shr    %cl,%edx
  80257f:	89 e9                	mov    %ebp,%ecx
  802581:	d3 e7                	shl    %cl,%edi
  802583:	89 f1                	mov    %esi,%ecx
  802585:	d3 e8                	shr    %cl,%eax
  802587:	89 e9                	mov    %ebp,%ecx
  802589:	09 f8                	or     %edi,%eax
  80258b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80258f:	f7 74 24 04          	divl   0x4(%esp)
  802593:	d3 e7                	shl    %cl,%edi
  802595:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802599:	89 d7                	mov    %edx,%edi
  80259b:	f7 64 24 08          	mull   0x8(%esp)
  80259f:	39 d7                	cmp    %edx,%edi
  8025a1:	89 c1                	mov    %eax,%ecx
  8025a3:	89 14 24             	mov    %edx,(%esp)
  8025a6:	72 2c                	jb     8025d4 <__umoddi3+0x134>
  8025a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8025ac:	72 22                	jb     8025d0 <__umoddi3+0x130>
  8025ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025b2:	29 c8                	sub    %ecx,%eax
  8025b4:	19 d7                	sbb    %edx,%edi
  8025b6:	89 e9                	mov    %ebp,%ecx
  8025b8:	89 fa                	mov    %edi,%edx
  8025ba:	d3 e8                	shr    %cl,%eax
  8025bc:	89 f1                	mov    %esi,%ecx
  8025be:	d3 e2                	shl    %cl,%edx
  8025c0:	89 e9                	mov    %ebp,%ecx
  8025c2:	d3 ef                	shr    %cl,%edi
  8025c4:	09 d0                	or     %edx,%eax
  8025c6:	89 fa                	mov    %edi,%edx
  8025c8:	83 c4 14             	add    $0x14,%esp
  8025cb:	5e                   	pop    %esi
  8025cc:	5f                   	pop    %edi
  8025cd:	5d                   	pop    %ebp
  8025ce:	c3                   	ret    
  8025cf:	90                   	nop
  8025d0:	39 d7                	cmp    %edx,%edi
  8025d2:	75 da                	jne    8025ae <__umoddi3+0x10e>
  8025d4:	8b 14 24             	mov    (%esp),%edx
  8025d7:	89 c1                	mov    %eax,%ecx
  8025d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025e1:	eb cb                	jmp    8025ae <__umoddi3+0x10e>
  8025e3:	90                   	nop
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025ec:	0f 82 0f ff ff ff    	jb     802501 <__umoddi3+0x61>
  8025f2:	e9 1a ff ff ff       	jmp    802511 <__umoddi3+0x71>
