
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 15 05 00 00       	call   800546 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004c:	89 34 24             	mov    %esi,(%esp)
  80004f:	e8 8b 1a 00 00       	call   801adf <seek>
	seek(kfd, off);
  800054:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800058:	89 3c 24             	mov    %edi,(%esp)
  80005b:	e8 7f 1a 00 00       	call   801adf <seek>

	cprintf("shell produced incorrect output.\n");
  800060:	c7 04 24 00 2d 80 00 	movl   $0x802d00,(%esp)
  800067:	e8 34 06 00 00       	call   8006a0 <cprintf>
	cprintf("expected:\n===\n");
  80006c:	c7 04 24 6b 2d 80 00 	movl   $0x802d6b,(%esp)
  800073:	e8 28 06 00 00       	call   8006a0 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800078:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007b:	eb 0c                	jmp    800089 <wrong+0x56>
		sys_cputs(buf, n);
  80007d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800081:	89 1c 24             	mov    %ebx,(%esp)
  800084:	e8 8d 0f 00 00       	call   801016 <sys_cputs>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800089:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800090:	00 
  800091:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800095:	89 3c 24             	mov    %edi,(%esp)
  800098:	e8 d8 18 00 00       	call   801975 <read>
  80009d:	85 c0                	test   %eax,%eax
  80009f:	7f dc                	jg     80007d <wrong+0x4a>
	cprintf("===\ngot:\n===\n");
  8000a1:	c7 04 24 7a 2d 80 00 	movl   $0x802d7a,(%esp)
  8000a8:	e8 f3 05 00 00       	call   8006a0 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ad:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b0:	eb 0c                	jmp    8000be <wrong+0x8b>
		sys_cputs(buf, n);
  8000b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b6:	89 1c 24             	mov    %ebx,(%esp)
  8000b9:	e8 58 0f 00 00       	call   801016 <sys_cputs>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000be:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c5:	00 
  8000c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ca:	89 34 24             	mov    %esi,(%esp)
  8000cd:	e8 a3 18 00 00       	call   801975 <read>
  8000d2:	85 c0                	test   %eax,%eax
  8000d4:	7f dc                	jg     8000b2 <wrong+0x7f>
	cprintf("===\n");
  8000d6:	c7 04 24 75 2d 80 00 	movl   $0x802d75,(%esp)
  8000dd:	e8 be 05 00 00       	call   8006a0 <cprintf>
	exit();
  8000e2:	e8 a7 04 00 00       	call   80058e <exit>
}
  8000e7:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5f                   	pop    %edi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <umain>:
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 3c             	sub    $0x3c,%esp
	close(0);
  8000fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800102:	e8 0b 17 00 00       	call   801812 <close>
	close(1);
  800107:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010e:	e8 ff 16 00 00       	call   801812 <close>
	opencons();
  800113:	e8 d3 03 00 00       	call   8004eb <opencons>
	opencons();
  800118:	e8 ce 03 00 00       	call   8004eb <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800124:	00 
  800125:	c7 04 24 88 2d 80 00 	movl   $0x802d88,(%esp)
  80012c:	e8 f0 1c 00 00       	call   801e21 <open>
  800131:	89 c3                	mov    %eax,%ebx
  800133:	85 c0                	test   %eax,%eax
  800135:	79 20                	jns    800157 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800137:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013b:	c7 44 24 08 95 2d 80 	movl   $0x802d95,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  800152:	e8 50 04 00 00       	call   8005a7 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800157:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015a:	89 04 24             	mov    %eax,(%esp)
  80015d:	e8 f2 24 00 00       	call   802654 <pipe>
  800162:	85 c0                	test   %eax,%eax
  800164:	79 20                	jns    800186 <umain+0x94>
		panic("pipe: %e", wfd);
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	c7 44 24 08 bc 2d 80 	movl   $0x802dbc,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  800181:	e8 21 04 00 00       	call   8005a7 <_panic>
	wfd = pfds[1];
  800186:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800189:	c7 04 24 24 2d 80 00 	movl   $0x802d24,(%esp)
  800190:	e8 0b 05 00 00       	call   8006a0 <cprintf>
	if ((r = fork()) < 0)
  800195:	e8 d8 12 00 00       	call   801472 <fork>
  80019a:	85 c0                	test   %eax,%eax
  80019c:	79 20                	jns    8001be <umain+0xcc>
		panic("fork: %e", r);
  80019e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a2:	c7 44 24 08 c5 2d 80 	movl   $0x802dc5,0x8(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b1:	00 
  8001b2:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  8001b9:	e8 e9 03 00 00       	call   8005a7 <_panic>
	if (r == 0) {
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	0f 85 9f 00 00 00    	jne    800265 <umain+0x173>
		dup(rfd, 0);
  8001c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001cd:	00 
  8001ce:	89 1c 24             	mov    %ebx,(%esp)
  8001d1:	e8 91 16 00 00       	call   801867 <dup>
		dup(wfd, 1);
  8001d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001dd:	00 
  8001de:	89 34 24             	mov    %esi,(%esp)
  8001e1:	e8 81 16 00 00       	call   801867 <dup>
		close(rfd);
  8001e6:	89 1c 24             	mov    %ebx,(%esp)
  8001e9:	e8 24 16 00 00       	call   801812 <close>
		close(wfd);
  8001ee:	89 34 24             	mov    %esi,(%esp)
  8001f1:	e8 1c 16 00 00       	call   801812 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 08 ce 2d 80 	movl   $0x802dce,0x8(%esp)
  800205:	00 
  800206:	c7 44 24 04 92 2d 80 	movl   $0x802d92,0x4(%esp)
  80020d:	00 
  80020e:	c7 04 24 d1 2d 80 00 	movl   $0x802dd1,(%esp)
  800215:	e8 e7 21 00 00       	call   802401 <spawnl>
  80021a:	89 c7                	mov    %eax,%edi
  80021c:	85 c0                	test   %eax,%eax
  80021e:	79 20                	jns    800240 <umain+0x14e>
			panic("spawn: %e", r);
  800220:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800224:	c7 44 24 08 d5 2d 80 	movl   $0x802dd5,0x8(%esp)
  80022b:	00 
  80022c:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800233:	00 
  800234:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  80023b:	e8 67 03 00 00       	call   8005a7 <_panic>
		close(0);
  800240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800247:	e8 c6 15 00 00       	call   801812 <close>
		close(1);
  80024c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800253:	e8 ba 15 00 00       	call   801812 <close>
		wait(r);
  800258:	89 3c 24             	mov    %edi,(%esp)
  80025b:	e8 9a 25 00 00       	call   8027fa <wait>
		exit();
  800260:	e8 29 03 00 00       	call   80058e <exit>
	close(rfd);
  800265:	89 1c 24             	mov    %ebx,(%esp)
  800268:	e8 a5 15 00 00       	call   801812 <close>
	close(wfd);
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	e8 9d 15 00 00       	call   801812 <close>
	rfd = pfds[0];
  800275:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800278:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  80027b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800282:	00 
  800283:	c7 04 24 df 2d 80 00 	movl   $0x802ddf,(%esp)
  80028a:	e8 92 1b 00 00       	call   801e21 <open>
  80028f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800292:	85 c0                	test   %eax,%eax
  800294:	79 20                	jns    8002b6 <umain+0x1c4>
		panic("open testshell.key for reading: %e", kfd);
  800296:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029a:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a9:	00 
  8002aa:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  8002b1:	e8 f1 02 00 00       	call   8005a7 <_panic>
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b6:	be 01 00 00 00       	mov    $0x1,%esi
  8002bb:	bf 00 00 00 00       	mov    $0x0,%edi
		n1 = read(rfd, &c1, 1);
  8002c0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c7:	00 
  8002c8:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	e8 9b 16 00 00       	call   801975 <read>
  8002da:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e3:	00 
  8002e4:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 7f 16 00 00       	call   801975 <read>
		if (n1 < 0)
  8002f6:	85 db                	test   %ebx,%ebx
  8002f8:	79 20                	jns    80031a <umain+0x228>
			panic("reading testshell.out: %e", n1);
  8002fa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002fe:	c7 44 24 08 ed 2d 80 	movl   $0x802ded,0x8(%esp)
  800305:	00 
  800306:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80030d:	00 
  80030e:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  800315:	e8 8d 02 00 00       	call   8005a7 <_panic>
		if (n2 < 0)
  80031a:	85 c0                	test   %eax,%eax
  80031c:	79 20                	jns    80033e <umain+0x24c>
			panic("reading testshell.key: %e", n2);
  80031e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800322:	c7 44 24 08 07 2e 80 	movl   $0x802e07,0x8(%esp)
  800329:	00 
  80032a:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  800331:	00 
  800332:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  800339:	e8 69 02 00 00       	call   8005a7 <_panic>
		if (n1 == 0 && n2 == 0)
  80033e:	89 c2                	mov    %eax,%edx
  800340:	09 da                	or     %ebx,%edx
  800342:	74 38                	je     80037c <umain+0x28a>
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800344:	83 fb 01             	cmp    $0x1,%ebx
  800347:	75 0e                	jne    800357 <umain+0x265>
  800349:	83 f8 01             	cmp    $0x1,%eax
  80034c:	75 09                	jne    800357 <umain+0x265>
  80034e:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  800352:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800355:	74 16                	je     80036d <umain+0x27b>
			wrong(rfd, kfd, nloff);
  800357:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80035b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800362:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	e8 c6 fc ff ff       	call   800033 <wrong>
			nloff = off+1;
  80036d:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  800371:	0f 44 fe             	cmove  %esi,%edi
  800374:	83 c6 01             	add    $0x1,%esi
	}
  800377:	e9 44 ff ff ff       	jmp    8002c0 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037c:	c7 04 24 21 2e 80 00 	movl   $0x802e21,(%esp)
  800383:	e8 18 03 00 00       	call   8006a0 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800388:	cc                   	int3   
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
  800391:	66 90                	xchg   %ax,%ax
  800393:	66 90                	xchg   %ax,%ax
  800395:	66 90                	xchg   %ax,%ax
  800397:	66 90                	xchg   %ax,%ax
  800399:	66 90                	xchg   %ax,%ax
  80039b:	66 90                	xchg   %ax,%ax
  80039d:	66 90                	xchg   %ax,%ax
  80039f:	90                   	nop

008003a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8003a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003b0:	c7 44 24 04 36 2e 80 	movl   $0x802e36,0x4(%esp)
  8003b7:	00 
  8003b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	e8 04 09 00 00       	call   800cc7 <strcpy>
	return 0;
}
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <devcons_write>:
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  8003d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8003db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8003e1:	eb 31                	jmp    800414 <devcons_write+0x4a>
		m = n - tot;
  8003e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8003e8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  8003eb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8003f0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8003f3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003f7:	03 45 0c             	add    0xc(%ebp),%eax
  8003fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fe:	89 3c 24             	mov    %edi,(%esp)
  800401:	e8 5e 0a 00 00       	call   800e64 <memmove>
		sys_cputs(buf, m);
  800406:	89 74 24 04          	mov    %esi,0x4(%esp)
  80040a:	89 3c 24             	mov    %edi,(%esp)
  80040d:	e8 04 0c 00 00       	call   801016 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800412:	01 f3                	add    %esi,%ebx
  800414:	89 d8                	mov    %ebx,%eax
  800416:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800419:	72 c8                	jb     8003e3 <devcons_write+0x19>
}
  80041b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800421:	5b                   	pop    %ebx
  800422:	5e                   	pop    %esi
  800423:	5f                   	pop    %edi
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <devcons_read>:
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80042c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800431:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800435:	75 07                	jne    80043e <devcons_read+0x18>
  800437:	eb 2a                	jmp    800463 <devcons_read+0x3d>
		sys_yield();
  800439:	e8 86 0c 00 00       	call   8010c4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80043e:	66 90                	xchg   %ax,%ax
  800440:	e8 ef 0b 00 00       	call   801034 <sys_cgetc>
  800445:	85 c0                	test   %eax,%eax
  800447:	74 f0                	je     800439 <devcons_read+0x13>
	if (c < 0)
  800449:	85 c0                	test   %eax,%eax
  80044b:	78 16                	js     800463 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80044d:	83 f8 04             	cmp    $0x4,%eax
  800450:	74 0c                	je     80045e <devcons_read+0x38>
	*(char*)vbuf = c;
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	88 02                	mov    %al,(%edx)
	return 1;
  800457:	b8 01 00 00 00       	mov    $0x1,%eax
  80045c:	eb 05                	jmp    800463 <devcons_read+0x3d>
		return 0;
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <cputchar>:
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800471:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800478:	00 
  800479:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 92 0b 00 00       	call   801016 <sys_cputs>
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <getchar>:
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80048c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800493:	00 
  800494:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004a2:	e8 ce 14 00 00       	call   801975 <read>
	if (r < 0)
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	78 0f                	js     8004ba <getchar+0x34>
	if (r < 1)
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	7e 06                	jle    8004b5 <getchar+0x2f>
	return c;
  8004af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004b3:	eb 05                	jmp    8004ba <getchar+0x34>
		return -E_EOF;
  8004b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <iscons>:
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	e8 12 12 00 00       	call   8016e6 <fd_lookup>
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 11                	js     8004e9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8004d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004db:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004e1:	39 10                	cmp    %edx,(%eax)
  8004e3:	0f 94 c0             	sete   %al
  8004e6:	0f b6 c0             	movzbl %al,%eax
}
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <opencons>:
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 9b 11 00 00       	call   801697 <fd_alloc>
		return r;
  8004fc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8004fe:	85 c0                	test   %eax,%eax
  800500:	78 40                	js     800542 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800502:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800509:	00 
  80050a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800518:	e8 c6 0b 00 00       	call   8010e3 <sys_page_alloc>
		return r;
  80051d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80051f:	85 c0                	test   %eax,%eax
  800521:	78 1f                	js     800542 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  800523:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80052c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80052e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800531:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	e8 30 11 00 00       	call   801670 <fd2num>
  800540:	89 c2                	mov    %eax,%edx
}
  800542:	89 d0                	mov    %edx,%eax
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	56                   	push   %esi
  80054a:	53                   	push   %ebx
  80054b:	83 ec 10             	sub    $0x10,%esp
  80054e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800551:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800554:	e8 4c 0b 00 00       	call   8010a5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800559:	25 ff 03 00 00       	and    $0x3ff,%eax
  80055e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800561:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800566:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80056b:	85 db                	test   %ebx,%ebx
  80056d:	7e 07                	jle    800576 <libmain+0x30>
		binaryname = argv[0];
  80056f:	8b 06                	mov    (%esi),%eax
  800571:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 70 fb ff ff       	call   8000f2 <umain>

	// exit gracefully
	exit();
  800582:	e8 07 00 00 00       	call   80058e <exit>
}
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5d                   	pop    %ebp
  80058d:	c3                   	ret    

0080058e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80058e:	55                   	push   %ebp
  80058f:	89 e5                	mov    %esp,%ebp
  800591:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800594:	e8 ac 12 00 00       	call   801845 <close_all>
	sys_env_destroy(0);
  800599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a0:	e8 ae 0a 00 00       	call   801053 <sys_env_destroy>
}
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    

008005a7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	56                   	push   %esi
  8005ab:	53                   	push   %ebx
  8005ac:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005af:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005b2:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8005b8:	e8 e8 0a 00 00       	call   8010a5 <sys_getenvid>
  8005bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cb:	89 74 24 08          	mov    %esi,0x8(%esp)
  8005cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d3:	c7 04 24 4c 2e 80 00 	movl   $0x802e4c,(%esp)
  8005da:	e8 c1 00 00 00       	call   8006a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e6:	89 04 24             	mov    %eax,(%esp)
  8005e9:	e8 51 00 00 00       	call   80063f <vcprintf>
	cprintf("\n");
  8005ee:	c7 04 24 78 2d 80 00 	movl   $0x802d78,(%esp)
  8005f5:	e8 a6 00 00 00       	call   8006a0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005fa:	cc                   	int3   
  8005fb:	eb fd                	jmp    8005fa <_panic+0x53>

008005fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005fd:	55                   	push   %ebp
  8005fe:	89 e5                	mov    %esp,%ebp
  800600:	53                   	push   %ebx
  800601:	83 ec 14             	sub    $0x14,%esp
  800604:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800607:	8b 13                	mov    (%ebx),%edx
  800609:	8d 42 01             	lea    0x1(%edx),%eax
  80060c:	89 03                	mov    %eax,(%ebx)
  80060e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800611:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800615:	3d ff 00 00 00       	cmp    $0xff,%eax
  80061a:	75 19                	jne    800635 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80061c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800623:	00 
  800624:	8d 43 08             	lea    0x8(%ebx),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 e7 09 00 00       	call   801016 <sys_cputs>
		b->idx = 0;
  80062f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800635:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800639:	83 c4 14             	add    $0x14,%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5d                   	pop    %ebp
  80063e:	c3                   	ret    

0080063f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800648:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80064f:	00 00 00 
	b.cnt = 0;
  800652:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800659:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80065c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800663:	8b 45 08             	mov    0x8(%ebp),%eax
  800666:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	c7 04 24 fd 05 80 00 	movl   $0x8005fd,(%esp)
  80067b:	e8 ae 01 00 00       	call   80082e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800680:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	e8 7e 09 00 00       	call   801016 <sys_cputs>

	return b.cnt;
}
  800698:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80069e:	c9                   	leave  
  80069f:	c3                   	ret    

008006a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	e8 87 ff ff ff       	call   80063f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    
  8006ba:	66 90                	xchg   %ax,%ax
  8006bc:	66 90                	xchg   %ax,%ax
  8006be:	66 90                	xchg   %ax,%ax

008006c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 3c             	sub    $0x3c,%esp
  8006c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cc:	89 d7                	mov    %edx,%edi
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d7:	89 c3                	mov    %eax,%ebx
  8006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8006df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ed:	39 d9                	cmp    %ebx,%ecx
  8006ef:	72 05                	jb     8006f6 <printnum+0x36>
  8006f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8006f4:	77 69                	ja     80075f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006fd:	83 ee 01             	sub    $0x1,%esi
  800700:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800704:	89 44 24 08          	mov    %eax,0x8(%esp)
  800708:	8b 44 24 08          	mov    0x8(%esp),%eax
  80070c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800710:	89 c3                	mov    %eax,%ebx
  800712:	89 d6                	mov    %edx,%esi
  800714:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800717:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80071e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800722:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800725:	89 04 24             	mov    %eax,(%esp)
  800728:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80072b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072f:	e8 2c 23 00 00       	call   802a60 <__udivdi3>
  800734:	89 d9                	mov    %ebx,%ecx
  800736:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80073a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	89 54 24 04          	mov    %edx,0x4(%esp)
  800745:	89 fa                	mov    %edi,%edx
  800747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80074a:	e8 71 ff ff ff       	call   8006c0 <printnum>
  80074f:	eb 1b                	jmp    80076c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800751:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800755:	8b 45 18             	mov    0x18(%ebp),%eax
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	ff d3                	call   *%ebx
  80075d:	eb 03                	jmp    800762 <printnum+0xa2>
  80075f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800762:	83 ee 01             	sub    $0x1,%esi
  800765:	85 f6                	test   %esi,%esi
  800767:	7f e8                	jg     800751 <printnum+0x91>
  800769:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80076c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800770:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800774:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800777:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80077a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800782:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	e8 fc 23 00 00       	call   802b90 <__umoddi3>
  800794:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800798:	0f be 80 6f 2e 80 00 	movsbl 0x802e6f(%eax),%eax
  80079f:	89 04 24             	mov    %eax,(%esp)
  8007a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a5:	ff d0                	call   *%eax
}
  8007a7:	83 c4 3c             	add    $0x3c,%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b2:	83 fa 01             	cmp    $0x1,%edx
  8007b5:	7e 0e                	jle    8007c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007bc:	89 08                	mov    %ecx,(%eax)
  8007be:	8b 02                	mov    (%edx),%eax
  8007c0:	8b 52 04             	mov    0x4(%edx),%edx
  8007c3:	eb 22                	jmp    8007e7 <getuint+0x38>
	else if (lflag)
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 10                	je     8007d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ce:	89 08                	mov    %ecx,(%eax)
  8007d0:	8b 02                	mov    (%edx),%eax
  8007d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d7:	eb 0e                	jmp    8007e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007d9:	8b 10                	mov    (%eax),%edx
  8007db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007de:	89 08                	mov    %ecx,(%eax)
  8007e0:	8b 02                	mov    (%edx),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8007f8:	73 0a                	jae    800804 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007fd:	89 08                	mov    %ecx,(%eax)
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	88 02                	mov    %al,(%edx)
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <printfmt>:
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80080c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80080f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800813:	8b 45 10             	mov    0x10(%ebp),%eax
  800816:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	e8 02 00 00 00       	call   80082e <vprintfmt>
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <vprintfmt>:
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	57                   	push   %edi
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	83 ec 3c             	sub    $0x3c,%esp
  800837:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80083a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80083d:	eb 1f                	jmp    80085e <vprintfmt+0x30>
			if (ch == '\0'){
  80083f:	85 c0                	test   %eax,%eax
  800841:	75 0f                	jne    800852 <vprintfmt+0x24>
				color = 0x0100;
  800843:	c7 05 00 50 80 00 00 	movl   $0x100,0x805000
  80084a:	01 00 00 
  80084d:	e9 b3 03 00 00       	jmp    800c05 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800852:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80085c:	89 f3                	mov    %esi,%ebx
  80085e:	8d 73 01             	lea    0x1(%ebx),%esi
  800861:	0f b6 03             	movzbl (%ebx),%eax
  800864:	83 f8 25             	cmp    $0x25,%eax
  800867:	75 d6                	jne    80083f <vprintfmt+0x11>
  800869:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80086d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800874:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80087b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800882:	ba 00 00 00 00       	mov    $0x0,%edx
  800887:	eb 1d                	jmp    8008a6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800889:	89 de                	mov    %ebx,%esi
			padc = '-';
  80088b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80088f:	eb 15                	jmp    8008a6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800891:	89 de                	mov    %ebx,%esi
			padc = '0';
  800893:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800897:	eb 0d                	jmp    8008a6 <vprintfmt+0x78>
				width = precision, precision = -1;
  800899:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80089c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80089f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8008a9:	0f b6 0e             	movzbl (%esi),%ecx
  8008ac:	0f b6 c1             	movzbl %cl,%eax
  8008af:	83 e9 23             	sub    $0x23,%ecx
  8008b2:	80 f9 55             	cmp    $0x55,%cl
  8008b5:	0f 87 2a 03 00 00    	ja     800be5 <vprintfmt+0x3b7>
  8008bb:	0f b6 c9             	movzbl %cl,%ecx
  8008be:	ff 24 8d c0 2f 80 00 	jmp    *0x802fc0(,%ecx,4)
  8008c5:	89 de                	mov    %ebx,%esi
  8008c7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8008cc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8008cf:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8008d3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008d6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8008d9:	83 fb 09             	cmp    $0x9,%ebx
  8008dc:	77 36                	ja     800914 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8008de:	83 c6 01             	add    $0x1,%esi
			}
  8008e1:	eb e9                	jmp    8008cc <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8008e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8008e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008ec:	8b 00                	mov    (%eax),%eax
  8008ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8008f3:	eb 22                	jmp    800917 <vprintfmt+0xe9>
  8008f5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008f8:	85 c9                	test   %ecx,%ecx
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ff:	0f 49 c1             	cmovns %ecx,%eax
  800902:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800905:	89 de                	mov    %ebx,%esi
  800907:	eb 9d                	jmp    8008a6 <vprintfmt+0x78>
  800909:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80090b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800912:	eb 92                	jmp    8008a6 <vprintfmt+0x78>
  800914:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800917:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80091b:	79 89                	jns    8008a6 <vprintfmt+0x78>
  80091d:	e9 77 ff ff ff       	jmp    800899 <vprintfmt+0x6b>
			lflag++;
  800922:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800925:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800927:	e9 7a ff ff ff       	jmp    8008a6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8d 50 04             	lea    0x4(%eax),%edx
  800932:	89 55 14             	mov    %edx,0x14(%ebp)
  800935:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800939:	8b 00                	mov    (%eax),%eax
  80093b:	89 04 24             	mov    %eax,(%esp)
  80093e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800941:	e9 18 ff ff ff       	jmp    80085e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8d 50 04             	lea    0x4(%eax),%edx
  80094c:	89 55 14             	mov    %edx,0x14(%ebp)
  80094f:	8b 00                	mov    (%eax),%eax
  800951:	99                   	cltd   
  800952:	31 d0                	xor    %edx,%eax
  800954:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800956:	83 f8 0f             	cmp    $0xf,%eax
  800959:	7f 0b                	jg     800966 <vprintfmt+0x138>
  80095b:	8b 14 85 20 31 80 00 	mov    0x803120(,%eax,4),%edx
  800962:	85 d2                	test   %edx,%edx
  800964:	75 20                	jne    800986 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800966:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096a:	c7 44 24 08 87 2e 80 	movl   $0x802e87,0x8(%esp)
  800971:	00 
  800972:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	89 04 24             	mov    %eax,(%esp)
  80097c:	e8 85 fe ff ff       	call   800806 <printfmt>
  800981:	e9 d8 fe ff ff       	jmp    80085e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800986:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80098a:	c7 44 24 08 da 33 80 	movl   $0x8033da,0x8(%esp)
  800991:	00 
  800992:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	89 04 24             	mov    %eax,(%esp)
  80099c:	e8 65 fe ff ff       	call   800806 <printfmt>
  8009a1:	e9 b8 fe ff ff       	jmp    80085e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  8009a6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8009a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009ba:	85 f6                	test   %esi,%esi
  8009bc:	b8 80 2e 80 00       	mov    $0x802e80,%eax
  8009c1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009c4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009c8:	0f 84 97 00 00 00    	je     800a65 <vprintfmt+0x237>
  8009ce:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8009d2:	0f 8e 9b 00 00 00    	jle    800a73 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009dc:	89 34 24             	mov    %esi,(%esp)
  8009df:	e8 c4 02 00 00       	call   800ca8 <strnlen>
  8009e4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009e7:	29 c2                	sub    %eax,%edx
  8009e9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8009ec:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8009f3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8009f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009fc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8009fe:	eb 0f                	jmp    800a0f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800a00:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a04:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a07:	89 04 24             	mov    %eax,(%esp)
  800a0a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a0c:	83 eb 01             	sub    $0x1,%ebx
  800a0f:	85 db                	test   %ebx,%ebx
  800a11:	7f ed                	jg     800a00 <vprintfmt+0x1d2>
  800a13:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a16:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a19:	85 d2                	test   %edx,%edx
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	0f 49 c2             	cmovns %edx,%eax
  800a23:	29 c2                	sub    %eax,%edx
  800a25:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a28:	89 d7                	mov    %edx,%edi
  800a2a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a2d:	eb 50                	jmp    800a7f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  800a2f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a33:	74 1e                	je     800a53 <vprintfmt+0x225>
  800a35:	0f be d2             	movsbl %dl,%edx
  800a38:	83 ea 20             	sub    $0x20,%edx
  800a3b:	83 fa 5e             	cmp    $0x5e,%edx
  800a3e:	76 13                	jbe    800a53 <vprintfmt+0x225>
					putch('?', putdat);
  800a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a47:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a4e:	ff 55 08             	call   *0x8(%ebp)
  800a51:	eb 0d                	jmp    800a60 <vprintfmt+0x232>
					putch(ch, putdat);
  800a53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a56:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a5a:	89 04 24             	mov    %eax,(%esp)
  800a5d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a60:	83 ef 01             	sub    $0x1,%edi
  800a63:	eb 1a                	jmp    800a7f <vprintfmt+0x251>
  800a65:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a68:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a6b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a71:	eb 0c                	jmp    800a7f <vprintfmt+0x251>
  800a73:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a76:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a79:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a7c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a7f:	83 c6 01             	add    $0x1,%esi
  800a82:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800a86:	0f be c2             	movsbl %dl,%eax
  800a89:	85 c0                	test   %eax,%eax
  800a8b:	74 27                	je     800ab4 <vprintfmt+0x286>
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	78 9e                	js     800a2f <vprintfmt+0x201>
  800a91:	83 eb 01             	sub    $0x1,%ebx
  800a94:	79 99                	jns    800a2f <vprintfmt+0x201>
  800a96:	89 f8                	mov    %edi,%eax
  800a98:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9e:	89 c3                	mov    %eax,%ebx
  800aa0:	eb 1a                	jmp    800abc <vprintfmt+0x28e>
				putch(' ', putdat);
  800aa2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800aad:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800aaf:	83 eb 01             	sub    $0x1,%ebx
  800ab2:	eb 08                	jmp    800abc <vprintfmt+0x28e>
  800ab4:	89 fb                	mov    %edi,%ebx
  800ab6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800abc:	85 db                	test   %ebx,%ebx
  800abe:	7f e2                	jg     800aa2 <vprintfmt+0x274>
  800ac0:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ac6:	e9 93 fd ff ff       	jmp    80085e <vprintfmt+0x30>
	if (lflag >= 2)
  800acb:	83 fa 01             	cmp    $0x1,%edx
  800ace:	7e 16                	jle    800ae6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800ad0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad3:	8d 50 08             	lea    0x8(%eax),%edx
  800ad6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad9:	8b 50 04             	mov    0x4(%eax),%edx
  800adc:	8b 00                	mov    (%eax),%eax
  800ade:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ae1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ae4:	eb 32                	jmp    800b18 <vprintfmt+0x2ea>
	else if (lflag)
  800ae6:	85 d2                	test   %edx,%edx
  800ae8:	74 18                	je     800b02 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  800aea:	8b 45 14             	mov    0x14(%ebp),%eax
  800aed:	8d 50 04             	lea    0x4(%eax),%edx
  800af0:	89 55 14             	mov    %edx,0x14(%ebp)
  800af3:	8b 30                	mov    (%eax),%esi
  800af5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800af8:	89 f0                	mov    %esi,%eax
  800afa:	c1 f8 1f             	sar    $0x1f,%eax
  800afd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b00:	eb 16                	jmp    800b18 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8d 50 04             	lea    0x4(%eax),%edx
  800b08:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0b:	8b 30                	mov    (%eax),%esi
  800b0d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b10:	89 f0                	mov    %esi,%eax
  800b12:	c1 f8 1f             	sar    $0x1f,%eax
  800b15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800b18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  800b1e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800b23:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b27:	0f 89 80 00 00 00    	jns    800bad <vprintfmt+0x37f>
				putch('-', putdat);
  800b2d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b31:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b38:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b41:	f7 d8                	neg    %eax
  800b43:	83 d2 00             	adc    $0x0,%edx
  800b46:	f7 da                	neg    %edx
			base = 10;
  800b48:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b4d:	eb 5e                	jmp    800bad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800b4f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b52:	e8 58 fc ff ff       	call   8007af <getuint>
			base = 10;
  800b57:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b5c:	eb 4f                	jmp    800bad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800b5e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b61:	e8 49 fc ff ff       	call   8007af <getuint>
            base = 8;
  800b66:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  800b6b:	eb 40                	jmp    800bad <vprintfmt+0x37f>
			putch('0', putdat);
  800b6d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b71:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b78:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b7b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b7f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b86:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800b89:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8c:	8d 50 04             	lea    0x4(%eax),%edx
  800b8f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800b92:	8b 00                	mov    (%eax),%eax
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800b99:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b9e:	eb 0d                	jmp    800bad <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800ba0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba3:	e8 07 fc ff ff       	call   8007af <getuint>
			base = 16;
  800ba8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800bad:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800bb1:	89 74 24 10          	mov    %esi,0x10(%esp)
  800bb5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800bb8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bbc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bc0:	89 04 24             	mov    %eax,(%esp)
  800bc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc7:	89 fa                	mov    %edi,%edx
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	e8 ef fa ff ff       	call   8006c0 <printnum>
			break;
  800bd1:	e9 88 fc ff ff       	jmp    80085e <vprintfmt+0x30>
			putch(ch, putdat);
  800bd6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bda:	89 04 24             	mov    %eax,(%esp)
  800bdd:	ff 55 08             	call   *0x8(%ebp)
			break;
  800be0:	e9 79 fc ff ff       	jmp    80085e <vprintfmt+0x30>
			putch('%', putdat);
  800be5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bf0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bf3:	89 f3                	mov    %esi,%ebx
  800bf5:	eb 03                	jmp    800bfa <vprintfmt+0x3cc>
  800bf7:	83 eb 01             	sub    $0x1,%ebx
  800bfa:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800bfe:	75 f7                	jne    800bf7 <vprintfmt+0x3c9>
  800c00:	e9 59 fc ff ff       	jmp    80085e <vprintfmt+0x30>
}
  800c05:	83 c4 3c             	add    $0x3c,%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 28             	sub    $0x28,%esp
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c1c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c20:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	74 30                	je     800c5e <vsnprintf+0x51>
  800c2e:	85 d2                	test   %edx,%edx
  800c30:	7e 2c                	jle    800c5e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c32:	8b 45 14             	mov    0x14(%ebp),%eax
  800c35:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c39:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c40:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c47:	c7 04 24 e9 07 80 00 	movl   $0x8007e9,(%esp)
  800c4e:	e8 db fb ff ff       	call   80082e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c56:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5c:	eb 05                	jmp    800c63 <vsnprintf+0x56>
		return -E_INVAL;
  800c5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800c63:	c9                   	leave  
  800c64:	c3                   	ret    

00800c65 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c6b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c72:	8b 45 10             	mov    0x10(%ebp),%eax
  800c75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	89 04 24             	mov    %eax,(%esp)
  800c86:	e8 82 ff ff ff       	call   800c0d <vsnprintf>
	va_end(ap);

	return rc;
}
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    
  800c8d:	66 90                	xchg   %ax,%ax
  800c8f:	90                   	nop

00800c90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9b:	eb 03                	jmp    800ca0 <strlen+0x10>
		n++;
  800c9d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800ca0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ca4:	75 f7                	jne    800c9d <strlen+0xd>
	return n;
}
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	eb 03                	jmp    800cbb <strnlen+0x13>
		n++;
  800cb8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbb:	39 d0                	cmp    %edx,%eax
  800cbd:	74 06                	je     800cc5 <strnlen+0x1d>
  800cbf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800cc3:	75 f3                	jne    800cb8 <strnlen+0x10>
	return n;
}
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	53                   	push   %ebx
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	83 c2 01             	add    $0x1,%edx
  800cd6:	83 c1 01             	add    $0x1,%ecx
  800cd9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cdd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ce0:	84 db                	test   %bl,%bl
  800ce2:	75 ef                	jne    800cd3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 08             	sub    $0x8,%esp
  800cee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cf1:	89 1c 24             	mov    %ebx,(%esp)
  800cf4:	e8 97 ff ff ff       	call   800c90 <strlen>
	strcpy(dst + len, src);
  800cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d00:	01 d8                	add    %ebx,%eax
  800d02:	89 04 24             	mov    %eax,(%esp)
  800d05:	e8 bd ff ff ff       	call   800cc7 <strcpy>
	return dst;
}
  800d0a:	89 d8                	mov    %ebx,%eax
  800d0c:	83 c4 08             	add    $0x8,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	89 f3                	mov    %esi,%ebx
  800d1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d22:	89 f2                	mov    %esi,%edx
  800d24:	eb 0f                	jmp    800d35 <strncpy+0x23>
		*dst++ = *src;
  800d26:	83 c2 01             	add    $0x1,%edx
  800d29:	0f b6 01             	movzbl (%ecx),%eax
  800d2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d32:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800d35:	39 da                	cmp    %ebx,%edx
  800d37:	75 ed                	jne    800d26 <strncpy+0x14>
	}
	return ret;
}
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	8b 75 08             	mov    0x8(%ebp),%esi
  800d47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d4d:	89 f0                	mov    %esi,%eax
  800d4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d53:	85 c9                	test   %ecx,%ecx
  800d55:	75 0b                	jne    800d62 <strlcpy+0x23>
  800d57:	eb 1d                	jmp    800d76 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d59:	83 c0 01             	add    $0x1,%eax
  800d5c:	83 c2 01             	add    $0x1,%edx
  800d5f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800d62:	39 d8                	cmp    %ebx,%eax
  800d64:	74 0b                	je     800d71 <strlcpy+0x32>
  800d66:	0f b6 0a             	movzbl (%edx),%ecx
  800d69:	84 c9                	test   %cl,%cl
  800d6b:	75 ec                	jne    800d59 <strlcpy+0x1a>
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	eb 02                	jmp    800d73 <strlcpy+0x34>
  800d71:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800d73:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d76:	29 f0                	sub    %esi,%eax
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d85:	eb 06                	jmp    800d8d <strcmp+0x11>
		p++, q++;
  800d87:	83 c1 01             	add    $0x1,%ecx
  800d8a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800d8d:	0f b6 01             	movzbl (%ecx),%eax
  800d90:	84 c0                	test   %al,%al
  800d92:	74 04                	je     800d98 <strcmp+0x1c>
  800d94:	3a 02                	cmp    (%edx),%al
  800d96:	74 ef                	je     800d87 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d98:	0f b6 c0             	movzbl %al,%eax
  800d9b:	0f b6 12             	movzbl (%edx),%edx
  800d9e:	29 d0                	sub    %edx,%eax
}
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	53                   	push   %ebx
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dac:	89 c3                	mov    %eax,%ebx
  800dae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800db1:	eb 06                	jmp    800db9 <strncmp+0x17>
		n--, p++, q++;
  800db3:	83 c0 01             	add    $0x1,%eax
  800db6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800db9:	39 d8                	cmp    %ebx,%eax
  800dbb:	74 15                	je     800dd2 <strncmp+0x30>
  800dbd:	0f b6 08             	movzbl (%eax),%ecx
  800dc0:	84 c9                	test   %cl,%cl
  800dc2:	74 04                	je     800dc8 <strncmp+0x26>
  800dc4:	3a 0a                	cmp    (%edx),%cl
  800dc6:	74 eb                	je     800db3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc8:	0f b6 00             	movzbl (%eax),%eax
  800dcb:	0f b6 12             	movzbl (%edx),%edx
  800dce:	29 d0                	sub    %edx,%eax
  800dd0:	eb 05                	jmp    800dd7 <strncmp+0x35>
		return 0;
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de4:	eb 07                	jmp    800ded <strchr+0x13>
		if (*s == c)
  800de6:	38 ca                	cmp    %cl,%dl
  800de8:	74 0f                	je     800df9 <strchr+0x1f>
	for (; *s; s++)
  800dea:	83 c0 01             	add    $0x1,%eax
  800ded:	0f b6 10             	movzbl (%eax),%edx
  800df0:	84 d2                	test   %dl,%dl
  800df2:	75 f2                	jne    800de6 <strchr+0xc>
			return (char *) s;
	return 0;
  800df4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e05:	eb 07                	jmp    800e0e <strfind+0x13>
		if (*s == c)
  800e07:	38 ca                	cmp    %cl,%dl
  800e09:	74 0a                	je     800e15 <strfind+0x1a>
	for (; *s; s++)
  800e0b:	83 c0 01             	add    $0x1,%eax
  800e0e:	0f b6 10             	movzbl (%eax),%edx
  800e11:	84 d2                	test   %dl,%dl
  800e13:	75 f2                	jne    800e07 <strfind+0xc>
			break;
	return (char *) s;
}
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e23:	85 c9                	test   %ecx,%ecx
  800e25:	74 36                	je     800e5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e2d:	75 28                	jne    800e57 <memset+0x40>
  800e2f:	f6 c1 03             	test   $0x3,%cl
  800e32:	75 23                	jne    800e57 <memset+0x40>
		c &= 0xFF;
  800e34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e38:	89 d3                	mov    %edx,%ebx
  800e3a:	c1 e3 08             	shl    $0x8,%ebx
  800e3d:	89 d6                	mov    %edx,%esi
  800e3f:	c1 e6 18             	shl    $0x18,%esi
  800e42:	89 d0                	mov    %edx,%eax
  800e44:	c1 e0 10             	shl    $0x10,%eax
  800e47:	09 f0                	or     %esi,%eax
  800e49:	09 c2                	or     %eax,%edx
  800e4b:	89 d0                	mov    %edx,%eax
  800e4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e4f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800e52:	fc                   	cld    
  800e53:	f3 ab                	rep stos %eax,%es:(%edi)
  800e55:	eb 06                	jmp    800e5d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	fc                   	cld    
  800e5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e5d:	89 f8                	mov    %edi,%eax
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e72:	39 c6                	cmp    %eax,%esi
  800e74:	73 35                	jae    800eab <memmove+0x47>
  800e76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e79:	39 d0                	cmp    %edx,%eax
  800e7b:	73 2e                	jae    800eab <memmove+0x47>
		s += n;
		d += n;
  800e7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e8a:	75 13                	jne    800e9f <memmove+0x3b>
  800e8c:	f6 c1 03             	test   $0x3,%cl
  800e8f:	75 0e                	jne    800e9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e91:	83 ef 04             	sub    $0x4,%edi
  800e94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800e9a:	fd                   	std    
  800e9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e9d:	eb 09                	jmp    800ea8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e9f:	83 ef 01             	sub    $0x1,%edi
  800ea2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ea5:	fd                   	std    
  800ea6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ea8:	fc                   	cld    
  800ea9:	eb 1d                	jmp    800ec8 <memmove+0x64>
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eaf:	f6 c2 03             	test   $0x3,%dl
  800eb2:	75 0f                	jne    800ec3 <memmove+0x5f>
  800eb4:	f6 c1 03             	test   $0x3,%cl
  800eb7:	75 0a                	jne    800ec3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800eb9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ebc:	89 c7                	mov    %eax,%edi
  800ebe:	fc                   	cld    
  800ebf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec1:	eb 05                	jmp    800ec8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ec3:	89 c7                	mov    %eax,%edi
  800ec5:	fc                   	cld    
  800ec6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ed2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	89 04 24             	mov    %eax,(%esp)
  800ee6:	e8 79 ff ff ff       	call   800e64 <memmove>
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef8:	89 d6                	mov    %edx,%esi
  800efa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800efd:	eb 1a                	jmp    800f19 <memcmp+0x2c>
		if (*s1 != *s2)
  800eff:	0f b6 02             	movzbl (%edx),%eax
  800f02:	0f b6 19             	movzbl (%ecx),%ebx
  800f05:	38 d8                	cmp    %bl,%al
  800f07:	74 0a                	je     800f13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f09:	0f b6 c0             	movzbl %al,%eax
  800f0c:	0f b6 db             	movzbl %bl,%ebx
  800f0f:	29 d8                	sub    %ebx,%eax
  800f11:	eb 0f                	jmp    800f22 <memcmp+0x35>
		s1++, s2++;
  800f13:	83 c2 01             	add    $0x1,%edx
  800f16:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800f19:	39 f2                	cmp    %esi,%edx
  800f1b:	75 e2                	jne    800eff <memcmp+0x12>
	}

	return 0;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f34:	eb 07                	jmp    800f3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f36:	38 08                	cmp    %cl,(%eax)
  800f38:	74 07                	je     800f41 <memfind+0x1b>
	for (; s < ends; s++)
  800f3a:	83 c0 01             	add    $0x1,%eax
  800f3d:	39 d0                	cmp    %edx,%eax
  800f3f:	72 f5                	jb     800f36 <memfind+0x10>
			break;
	return (void *) s;
}
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f4f:	eb 03                	jmp    800f54 <strtol+0x11>
		s++;
  800f51:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800f54:	0f b6 0a             	movzbl (%edx),%ecx
  800f57:	80 f9 09             	cmp    $0x9,%cl
  800f5a:	74 f5                	je     800f51 <strtol+0xe>
  800f5c:	80 f9 20             	cmp    $0x20,%cl
  800f5f:	74 f0                	je     800f51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800f61:	80 f9 2b             	cmp    $0x2b,%cl
  800f64:	75 0a                	jne    800f70 <strtol+0x2d>
		s++;
  800f66:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800f69:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6e:	eb 11                	jmp    800f81 <strtol+0x3e>
  800f70:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800f75:	80 f9 2d             	cmp    $0x2d,%cl
  800f78:	75 07                	jne    800f81 <strtol+0x3e>
		s++, neg = 1;
  800f7a:	8d 52 01             	lea    0x1(%edx),%edx
  800f7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800f86:	75 15                	jne    800f9d <strtol+0x5a>
  800f88:	80 3a 30             	cmpb   $0x30,(%edx)
  800f8b:	75 10                	jne    800f9d <strtol+0x5a>
  800f8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f91:	75 0a                	jne    800f9d <strtol+0x5a>
		s += 2, base = 16;
  800f93:	83 c2 02             	add    $0x2,%edx
  800f96:	b8 10 00 00 00       	mov    $0x10,%eax
  800f9b:	eb 10                	jmp    800fad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	75 0c                	jne    800fad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fa1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800fa3:	80 3a 30             	cmpb   $0x30,(%edx)
  800fa6:	75 05                	jne    800fad <strtol+0x6a>
		s++, base = 8;
  800fa8:	83 c2 01             	add    $0x1,%edx
  800fab:	b0 08                	mov    $0x8,%al
		base = 10;
  800fad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fb5:	0f b6 0a             	movzbl (%edx),%ecx
  800fb8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800fbb:	89 f0                	mov    %esi,%eax
  800fbd:	3c 09                	cmp    $0x9,%al
  800fbf:	77 08                	ja     800fc9 <strtol+0x86>
			dig = *s - '0';
  800fc1:	0f be c9             	movsbl %cl,%ecx
  800fc4:	83 e9 30             	sub    $0x30,%ecx
  800fc7:	eb 20                	jmp    800fe9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800fc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800fcc:	89 f0                	mov    %esi,%eax
  800fce:	3c 19                	cmp    $0x19,%al
  800fd0:	77 08                	ja     800fda <strtol+0x97>
			dig = *s - 'a' + 10;
  800fd2:	0f be c9             	movsbl %cl,%ecx
  800fd5:	83 e9 57             	sub    $0x57,%ecx
  800fd8:	eb 0f                	jmp    800fe9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800fda:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800fdd:	89 f0                	mov    %esi,%eax
  800fdf:	3c 19                	cmp    $0x19,%al
  800fe1:	77 16                	ja     800ff9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800fe3:	0f be c9             	movsbl %cl,%ecx
  800fe6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fe9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800fec:	7d 0f                	jge    800ffd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800fee:	83 c2 01             	add    $0x1,%edx
  800ff1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ff5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ff7:	eb bc                	jmp    800fb5 <strtol+0x72>
  800ff9:	89 d8                	mov    %ebx,%eax
  800ffb:	eb 02                	jmp    800fff <strtol+0xbc>
  800ffd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800fff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801003:	74 05                	je     80100a <strtol+0xc7>
		*endptr = (char *) s;
  801005:	8b 75 0c             	mov    0xc(%ebp),%esi
  801008:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80100a:	f7 d8                	neg    %eax
  80100c:	85 ff                	test   %edi,%edi
  80100e:	0f 44 c3             	cmove  %ebx,%eax
}
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80101c:	b8 00 00 00 00       	mov    $0x0,%eax
  801021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	89 c3                	mov    %eax,%ebx
  801029:	89 c7                	mov    %eax,%edi
  80102b:	89 c6                	mov    %eax,%esi
  80102d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_cgetc>:

int
sys_cgetc(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	asm volatile("int %1\n"
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	b8 01 00 00 00       	mov    $0x1,%eax
  801044:	89 d1                	mov    %edx,%ecx
  801046:	89 d3                	mov    %edx,%ebx
  801048:	89 d7                	mov    %edx,%edi
  80104a:	89 d6                	mov    %edx,%esi
  80104c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80105c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801061:	b8 03 00 00 00       	mov    $0x3,%eax
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
  801069:	89 cb                	mov    %ecx,%ebx
  80106b:	89 cf                	mov    %ecx,%edi
  80106d:	89 ce                	mov    %ecx,%esi
  80106f:	cd 30                	int    $0x30
	if(check && ret > 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	7e 28                	jle    80109d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801075:	89 44 24 10          	mov    %eax,0x10(%esp)
  801079:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801080:	00 
  801081:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  801098:	e8 0a f5 ff ff       	call   8005a7 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80109d:	83 c4 2c             	add    $0x2c,%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	57                   	push   %edi
  8010a9:	56                   	push   %esi
  8010aa:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8010b5:	89 d1                	mov    %edx,%ecx
  8010b7:	89 d3                	mov    %edx,%ebx
  8010b9:	89 d7                	mov    %edx,%edi
  8010bb:	89 d6                	mov    %edx,%esi
  8010bd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_yield>:

void
sys_yield(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010d4:	89 d1                	mov    %edx,%ecx
  8010d6:	89 d3                	mov    %edx,%ebx
  8010d8:	89 d7                	mov    %edx,%edi
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8010ec:	be 00 00 00 00       	mov    $0x0,%esi
  8010f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8010f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ff:	89 f7                	mov    %esi,%edi
  801101:	cd 30                	int    $0x30
	if(check && ret > 0)
  801103:	85 c0                	test   %eax,%eax
  801105:	7e 28                	jle    80112f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801112:	00 
  801113:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  80111a:	00 
  80111b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  80112a:	e8 78 f4 ff ff       	call   8005a7 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80112f:	83 c4 2c             	add    $0x2c,%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801140:	b8 05 00 00 00       	mov    $0x5,%eax
  801145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801148:	8b 55 08             	mov    0x8(%ebp),%edx
  80114b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801151:	8b 75 18             	mov    0x18(%ebp),%esi
  801154:	cd 30                	int    $0x30
	if(check && ret > 0)
  801156:	85 c0                	test   %eax,%eax
  801158:	7e 28                	jle    801182 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801165:	00 
  801166:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  80117d:	e8 25 f4 ff ff       	call   8005a7 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801182:	83 c4 2c             	add    $0x2c,%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	57                   	push   %edi
  80118e:	56                   	push   %esi
  80118f:	53                   	push   %ebx
  801190:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801193:	bb 00 00 00 00       	mov    $0x0,%ebx
  801198:	b8 06 00 00 00       	mov    $0x6,%eax
  80119d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a3:	89 df                	mov    %ebx,%edi
  8011a5:	89 de                	mov    %ebx,%esi
  8011a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	7e 28                	jle    8011d5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  8011d0:	e8 d2 f3 ff ff       	call   8005a7 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011d5:	83 c4 2c             	add    $0x2c,%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8011e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8011f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f6:	89 df                	mov    %ebx,%edi
  8011f8:	89 de                	mov    %ebx,%esi
  8011fa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	7e 28                	jle    801228 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801200:	89 44 24 10          	mov    %eax,0x10(%esp)
  801204:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80120b:	00 
  80120c:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  801213:	00 
  801214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80121b:	00 
  80121c:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  801223:	e8 7f f3 ff ff       	call   8005a7 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801228:	83 c4 2c             	add    $0x2c,%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123e:	b8 09 00 00 00       	mov    $0x9,%eax
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	8b 55 08             	mov    0x8(%ebp),%edx
  801249:	89 df                	mov    %ebx,%edi
  80124b:	89 de                	mov    %ebx,%esi
  80124d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80124f:	85 c0                	test   %eax,%eax
  801251:	7e 28                	jle    80127b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801253:	89 44 24 10          	mov    %eax,0x10(%esp)
  801257:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80125e:	00 
  80125f:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126e:	00 
  80126f:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  801276:	e8 2c f3 ff ff       	call   8005a7 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80127b:	83 c4 2c             	add    $0x2c,%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	57                   	push   %edi
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80128c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801291:	b8 0a 00 00 00       	mov    $0xa,%eax
  801296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801299:	8b 55 08             	mov    0x8(%ebp),%edx
  80129c:	89 df                	mov    %ebx,%edi
  80129e:	89 de                	mov    %ebx,%esi
  8012a0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	7e 28                	jle    8012ce <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012aa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012b1:	00 
  8012b2:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  8012b9:	00 
  8012ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c1:	00 
  8012c2:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  8012c9:	e8 d9 f2 ff ff       	call   8005a7 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012ce:	83 c4 2c             	add    $0x2c,%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	57                   	push   %edi
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012dc:	be 00 00 00 00       	mov    $0x0,%esi
  8012e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012f2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801302:	b9 00 00 00 00       	mov    $0x0,%ecx
  801307:	b8 0d 00 00 00       	mov    $0xd,%eax
  80130c:	8b 55 08             	mov    0x8(%ebp),%edx
  80130f:	89 cb                	mov    %ecx,%ebx
  801311:	89 cf                	mov    %ecx,%edi
  801313:	89 ce                	mov    %ecx,%esi
  801315:	cd 30                	int    $0x30
	if(check && ret > 0)
  801317:	85 c0                	test   %eax,%eax
  801319:	7e 28                	jle    801343 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801326:	00 
  801327:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  80132e:	00 
  80132f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801336:	00 
  801337:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  80133e:	e8 64 f2 ff ff       	call   8005a7 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801343:	83 c4 2c             	add    $0x2c,%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5f                   	pop    %edi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    
  80134b:	66 90                	xchg   %ax,%ax
  80134d:	66 90                	xchg   %ax,%ax
  80134f:	90                   	nop

00801350 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	53                   	push   %ebx
  801354:	83 ec 24             	sub    $0x24,%esp
  801357:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  80135a:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  80135c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801360:	74 18                	je     80137a <pgfault+0x2a>
  801362:	89 d8                	mov    %ebx,%eax
  801364:	c1 e8 0c             	shr    $0xc,%eax
  801367:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136e:	25 05 08 00 00       	and    $0x805,%eax
  801373:	3d 05 08 00 00       	cmp    $0x805,%eax
  801378:	74 1c                	je     801396 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  80137a:	c7 44 24 08 ac 31 80 	movl   $0x8031ac,0x8(%esp)
  801381:	00 
  801382:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801389:	00 
  80138a:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  801391:	e8 11 f2 ff ff       	call   8005a7 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  801396:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80139d:	00 
  80139e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013a5:	00 
  8013a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ad:	e8 31 fd ff ff       	call   8010e3 <sys_page_alloc>
	if(r < 0){
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	79 1c                	jns    8013d2 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  8013b6:	c7 44 24 08 dc 31 80 	movl   $0x8031dc,0x8(%esp)
  8013bd:	00 
  8013be:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8013c5:	00 
  8013c6:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  8013cd:	e8 d5 f1 ff ff       	call   8005a7 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8013d2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8013d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8013df:	00 
  8013e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8013eb:	e8 dc fa ff ff       	call   800ecc <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  8013f0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013f7:	00 
  8013f8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801403:	00 
  801404:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80140b:	00 
  80140c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801413:	e8 1f fd ff ff       	call   801137 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  801418:	85 c0                	test   %eax,%eax
  80141a:	79 1c                	jns    801438 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  80141c:	c7 44 24 08 a8 32 80 	movl   $0x8032a8,0x8(%esp)
  801423:	00 
  801424:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80142b:	00 
  80142c:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  801433:	e8 6f f1 ff ff       	call   8005a7 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  801438:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80143f:	00 
  801440:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801447:	e8 3e fd ff ff       	call   80118a <sys_page_unmap>
    if(r < 0){
  80144c:	85 c0                	test   %eax,%eax
  80144e:	79 1c                	jns    80146c <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  801450:	c7 44 24 08 bf 32 80 	movl   $0x8032bf,0x8(%esp)
  801457:	00 
  801458:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80145f:	00 
  801460:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  801467:	e8 3b f1 ff ff       	call   8005a7 <_panic>
    }
    // LAB 4
}
  80146c:	83 c4 24             	add    $0x24,%esp
  80146f:	5b                   	pop    %ebx
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	57                   	push   %edi
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  80147b:	c7 04 24 50 13 80 00 	movl   $0x801350,(%esp)
  801482:	e8 d3 13 00 00       	call   80285a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801487:	b8 07 00 00 00       	mov    $0x7,%eax
  80148c:	cd 30                	int    $0x30
  80148e:	89 c7                	mov    %eax,%edi
  801490:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801493:	85 c0                	test   %eax,%eax
  801495:	79 1c                	jns    8014b3 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801497:	c7 44 24 08 d8 32 80 	movl   $0x8032d8,0x8(%esp)
  80149e:	00 
  80149f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  8014a6:	00 
  8014a7:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  8014ae:	e8 f4 f0 ff ff       	call   8005a7 <_panic>
    }
    if(child == 0){
  8014b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	75 21                	jne    8014dd <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  8014bc:	e8 e4 fb ff ff       	call   8010a5 <sys_getenvid>
  8014c1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014ce:	a3 08 50 80 00       	mov    %eax,0x805008
        // It's a whole lot like lab3 with the env stuff
        return 0;
  8014d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d8:	e9 67 01 00 00       	jmp    801644 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  8014dd:	89 d8                	mov    %ebx,%eax
  8014df:	c1 e8 16             	shr    $0x16,%eax
  8014e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e9:	a8 01                	test   $0x1,%al
  8014eb:	74 4b                	je     801538 <fork+0xc6>
  8014ed:	89 de                	mov    %ebx,%esi
  8014ef:	c1 ee 0c             	shr    $0xc,%esi
  8014f2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014f9:	a8 01                	test   $0x1,%al
  8014fb:	74 3b                	je     801538 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  8014fd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801504:	a9 02 08 00 00       	test   $0x802,%eax
  801509:	0f 85 02 01 00 00    	jne    801611 <fork+0x19f>
  80150f:	e9 d2 00 00 00       	jmp    8015e6 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  801514:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80151b:	00 
  80151c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801520:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801527:	00 
  801528:	89 74 24 04          	mov    %esi,0x4(%esp)
  80152c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801533:	e8 ff fb ff ff       	call   801137 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801538:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80153e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801544:	75 97                	jne    8014dd <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801546:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80154d:	00 
  80154e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801555:	ee 
  801556:	89 3c 24             	mov    %edi,(%esp)
  801559:	e8 85 fb ff ff       	call   8010e3 <sys_page_alloc>

    if(r < 0){
  80155e:	85 c0                	test   %eax,%eax
  801560:	79 1c                	jns    80157e <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801562:	c7 44 24 08 10 32 80 	movl   $0x803210,0x8(%esp)
  801569:	00 
  80156a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801571:	00 
  801572:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  801579:	e8 29 f0 ff ff       	call   8005a7 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  80157e:	a1 08 50 80 00       	mov    0x805008,%eax
  801583:	8b 40 64             	mov    0x64(%eax),%eax
  801586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158a:	89 3c 24             	mov    %edi,(%esp)
  80158d:	e8 f1 fc ff ff       	call   801283 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801592:	85 c0                	test   %eax,%eax
  801594:	79 1c                	jns    8015b2 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801596:	c7 44 24 08 30 32 80 	movl   $0x803230,0x8(%esp)
  80159d:	00 
  80159e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  8015a5:	00 
  8015a6:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  8015ad:	e8 f5 ef ff ff       	call   8005a7 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  8015b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015b9:	00 
  8015ba:	89 3c 24             	mov    %edi,(%esp)
  8015bd:	e8 1b fc ff ff       	call   8011dd <sys_env_set_status>
    if(r < 0){
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	79 1c                	jns    8015e2 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  8015c6:	c7 44 24 08 58 32 80 	movl   $0x803258,0x8(%esp)
  8015cd:	00 
  8015ce:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  8015d5:	00 
  8015d6:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  8015dd:	e8 c5 ef ff ff       	call   8005a7 <_panic>
    }
    return child;
  8015e2:	89 f8                	mov    %edi,%eax
  8015e4:	eb 5e                	jmp    801644 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  8015e6:	c1 e6 0c             	shl    $0xc,%esi
  8015e9:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8015f0:	00 
  8015f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801600:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801607:	e8 2b fb ff ff       	call   801137 <sys_page_map>
  80160c:	e9 27 ff ff ff       	jmp    801538 <fork+0xc6>
  801611:	c1 e6 0c             	shl    $0xc,%esi
  801614:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80161b:	00 
  80161c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801623:	89 44 24 08          	mov    %eax,0x8(%esp)
  801627:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801632:	e8 00 fb ff ff       	call   801137 <sys_page_map>
    if( r < 0 ){
  801637:	85 c0                	test   %eax,%eax
  801639:	0f 89 d5 fe ff ff    	jns    801514 <fork+0xa2>
  80163f:	e9 f4 fe ff ff       	jmp    801538 <fork+0xc6>
//	panic("fork not implemented");
}
  801644:	83 c4 2c             	add    $0x2c,%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5f                   	pop    %edi
  80164a:	5d                   	pop    %ebp
  80164b:	c3                   	ret    

0080164c <sfork>:

// Challenge!
int
sfork(void)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801652:	c7 44 24 08 f5 32 80 	movl   $0x8032f5,0x8(%esp)
  801659:	00 
  80165a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801661:	00 
  801662:	c7 04 24 9d 32 80 00 	movl   $0x80329d,(%esp)
  801669:	e8 39 ef ff ff       	call   8005a7 <_panic>
  80166e:	66 90                	xchg   %ax,%ax

00801670 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	05 00 00 00 30       	add    $0x30000000,%eax
  80167b:	c1 e8 0c             	shr    $0xc,%eax
}
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80168b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801690:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	c1 ea 16             	shr    $0x16,%edx
  8016a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016ae:	f6 c2 01             	test   $0x1,%dl
  8016b1:	74 11                	je     8016c4 <fd_alloc+0x2d>
  8016b3:	89 c2                	mov    %eax,%edx
  8016b5:	c1 ea 0c             	shr    $0xc,%edx
  8016b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016bf:	f6 c2 01             	test   $0x1,%dl
  8016c2:	75 09                	jne    8016cd <fd_alloc+0x36>
			*fd_store = fd;
  8016c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cb:	eb 17                	jmp    8016e4 <fd_alloc+0x4d>
  8016cd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8016d2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016d7:	75 c9                	jne    8016a2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8016d9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8016df:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016ec:	83 f8 1f             	cmp    $0x1f,%eax
  8016ef:	77 36                	ja     801727 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016f1:	c1 e0 0c             	shl    $0xc,%eax
  8016f4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	c1 ea 16             	shr    $0x16,%edx
  8016fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801705:	f6 c2 01             	test   $0x1,%dl
  801708:	74 24                	je     80172e <fd_lookup+0x48>
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	c1 ea 0c             	shr    $0xc,%edx
  80170f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801716:	f6 c2 01             	test   $0x1,%dl
  801719:	74 1a                	je     801735 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80171b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171e:	89 02                	mov    %eax,(%edx)
	return 0;
  801720:	b8 00 00 00 00       	mov    $0x0,%eax
  801725:	eb 13                	jmp    80173a <fd_lookup+0x54>
		return -E_INVAL;
  801727:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172c:	eb 0c                	jmp    80173a <fd_lookup+0x54>
		return -E_INVAL;
  80172e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801733:	eb 05                	jmp    80173a <fd_lookup+0x54>
  801735:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 18             	sub    $0x18,%esp
  801742:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801745:	ba 88 33 80 00       	mov    $0x803388,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80174a:	eb 13                	jmp    80175f <dev_lookup+0x23>
  80174c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80174f:	39 08                	cmp    %ecx,(%eax)
  801751:	75 0c                	jne    80175f <dev_lookup+0x23>
			*dev = devtab[i];
  801753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801756:	89 01                	mov    %eax,(%ecx)
			return 0;
  801758:	b8 00 00 00 00       	mov    $0x0,%eax
  80175d:	eb 30                	jmp    80178f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80175f:	8b 02                	mov    (%edx),%eax
  801761:	85 c0                	test   %eax,%eax
  801763:	75 e7                	jne    80174c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801765:	a1 08 50 80 00       	mov    0x805008,%eax
  80176a:	8b 40 48             	mov    0x48(%eax),%eax
  80176d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801771:	89 44 24 04          	mov    %eax,0x4(%esp)
  801775:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  80177c:	e8 1f ef ff ff       	call   8006a0 <cprintf>
	*dev = 0;
  801781:	8b 45 0c             	mov    0xc(%ebp),%eax
  801784:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80178a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80178f:	c9                   	leave  
  801790:	c3                   	ret    

00801791 <fd_close>:
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 20             	sub    $0x20,%esp
  801799:	8b 75 08             	mov    0x8(%ebp),%esi
  80179c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80179f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8017a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8017ac:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017af:	89 04 24             	mov    %eax,(%esp)
  8017b2:	e8 2f ff ff ff       	call   8016e6 <fd_lookup>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 05                	js     8017c0 <fd_close+0x2f>
	    || fd != fd2)
  8017bb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017be:	74 0c                	je     8017cc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8017c0:	84 db                	test   %bl,%bl
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	0f 44 c2             	cmove  %edx,%eax
  8017ca:	eb 3f                	jmp    80180b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d3:	8b 06                	mov    (%esi),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 5f ff ff ff       	call   80173c <dev_lookup>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 16                	js     8017f9 <fd_close+0x68>
		if (dev->dev_close)
  8017e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8017e9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	74 07                	je     8017f9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8017f2:	89 34 24             	mov    %esi,(%esp)
  8017f5:	ff d0                	call   *%eax
  8017f7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8017f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801804:	e8 81 f9 ff ff       	call   80118a <sys_page_unmap>
	return r;
  801809:	89 d8                	mov    %ebx,%eax
}
  80180b:	83 c4 20             	add    $0x20,%esp
  80180e:	5b                   	pop    %ebx
  80180f:	5e                   	pop    %esi
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    

00801812 <close>:

int
close(int fdnum)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801818:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	89 04 24             	mov    %eax,(%esp)
  801825:	e8 bc fe ff ff       	call   8016e6 <fd_lookup>
  80182a:	89 c2                	mov    %eax,%edx
  80182c:	85 d2                	test   %edx,%edx
  80182e:	78 13                	js     801843 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801830:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801837:	00 
  801838:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183b:	89 04 24             	mov    %eax,(%esp)
  80183e:	e8 4e ff ff ff       	call   801791 <fd_close>
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <close_all>:

void
close_all(void)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	53                   	push   %ebx
  801849:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80184c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801851:	89 1c 24             	mov    %ebx,(%esp)
  801854:	e8 b9 ff ff ff       	call   801812 <close>
	for (i = 0; i < MAXFD; i++)
  801859:	83 c3 01             	add    $0x1,%ebx
  80185c:	83 fb 20             	cmp    $0x20,%ebx
  80185f:	75 f0                	jne    801851 <close_all+0xc>
}
  801861:	83 c4 14             	add    $0x14,%esp
  801864:	5b                   	pop    %ebx
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	57                   	push   %edi
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801870:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801873:	89 44 24 04          	mov    %eax,0x4(%esp)
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	89 04 24             	mov    %eax,(%esp)
  80187d:	e8 64 fe ff ff       	call   8016e6 <fd_lookup>
  801882:	89 c2                	mov    %eax,%edx
  801884:	85 d2                	test   %edx,%edx
  801886:	0f 88 e1 00 00 00    	js     80196d <dup+0x106>
		return r;
	close(newfdnum);
  80188c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 7b ff ff ff       	call   801812 <close>

	newfd = INDEX2FD(newfdnum);
  801897:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80189a:	c1 e3 0c             	shl    $0xc,%ebx
  80189d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	e8 d2 fd ff ff       	call   801680 <fd2data>
  8018ae:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8018b0:	89 1c 24             	mov    %ebx,(%esp)
  8018b3:	e8 c8 fd ff ff       	call   801680 <fd2data>
  8018b8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018ba:	89 f0                	mov    %esi,%eax
  8018bc:	c1 e8 16             	shr    $0x16,%eax
  8018bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018c6:	a8 01                	test   $0x1,%al
  8018c8:	74 43                	je     80190d <dup+0xa6>
  8018ca:	89 f0                	mov    %esi,%eax
  8018cc:	c1 e8 0c             	shr    $0xc,%eax
  8018cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018d6:	f6 c2 01             	test   $0x1,%dl
  8018d9:	74 32                	je     80190d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8018e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018f6:	00 
  8018f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801902:	e8 30 f8 ff ff       	call   801137 <sys_page_map>
  801907:	89 c6                	mov    %eax,%esi
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 3e                	js     80194b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80190d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801910:	89 c2                	mov    %eax,%edx
  801912:	c1 ea 0c             	shr    $0xc,%edx
  801915:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80191c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801922:	89 54 24 10          	mov    %edx,0x10(%esp)
  801926:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80192a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801931:	00 
  801932:	89 44 24 04          	mov    %eax,0x4(%esp)
  801936:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193d:	e8 f5 f7 ff ff       	call   801137 <sys_page_map>
  801942:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801944:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801947:	85 f6                	test   %esi,%esi
  801949:	79 22                	jns    80196d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80194b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801956:	e8 2f f8 ff ff       	call   80118a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80195b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80195f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801966:	e8 1f f8 ff ff       	call   80118a <sys_page_unmap>
	return r;
  80196b:	89 f0                	mov    %esi,%eax
}
  80196d:	83 c4 3c             	add    $0x3c,%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5f                   	pop    %edi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    

00801975 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	53                   	push   %ebx
  801979:	83 ec 24             	sub    $0x24,%esp
  80197c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801982:	89 44 24 04          	mov    %eax,0x4(%esp)
  801986:	89 1c 24             	mov    %ebx,(%esp)
  801989:	e8 58 fd ff ff       	call   8016e6 <fd_lookup>
  80198e:	89 c2                	mov    %eax,%edx
  801990:	85 d2                	test   %edx,%edx
  801992:	78 6d                	js     801a01 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801994:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199e:	8b 00                	mov    (%eax),%eax
  8019a0:	89 04 24             	mov    %eax,(%esp)
  8019a3:	e8 94 fd ff ff       	call   80173c <dev_lookup>
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	78 55                	js     801a01 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019af:	8b 50 08             	mov    0x8(%eax),%edx
  8019b2:	83 e2 03             	and    $0x3,%edx
  8019b5:	83 fa 01             	cmp    $0x1,%edx
  8019b8:	75 23                	jne    8019dd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019ba:	a1 08 50 80 00       	mov    0x805008,%eax
  8019bf:	8b 40 48             	mov    0x48(%eax),%eax
  8019c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ca:	c7 04 24 4d 33 80 00 	movl   $0x80334d,(%esp)
  8019d1:	e8 ca ec ff ff       	call   8006a0 <cprintf>
		return -E_INVAL;
  8019d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019db:	eb 24                	jmp    801a01 <read+0x8c>
	}
	if (!dev->dev_read)
  8019dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e0:	8b 52 08             	mov    0x8(%edx),%edx
  8019e3:	85 d2                	test   %edx,%edx
  8019e5:	74 15                	je     8019fc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019f5:	89 04 24             	mov    %eax,(%esp)
  8019f8:	ff d2                	call   *%edx
  8019fa:	eb 05                	jmp    801a01 <read+0x8c>
		return -E_NOT_SUPP;
  8019fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801a01:	83 c4 24             	add    $0x24,%esp
  801a04:	5b                   	pop    %ebx
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	57                   	push   %edi
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 1c             	sub    $0x1c,%esp
  801a10:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a13:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a16:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a1b:	eb 23                	jmp    801a40 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a1d:	89 f0                	mov    %esi,%eax
  801a1f:	29 d8                	sub    %ebx,%eax
  801a21:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a25:	89 d8                	mov    %ebx,%eax
  801a27:	03 45 0c             	add    0xc(%ebp),%eax
  801a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2e:	89 3c 24             	mov    %edi,(%esp)
  801a31:	e8 3f ff ff ff       	call   801975 <read>
		if (m < 0)
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 10                	js     801a4a <readn+0x43>
			return m;
		if (m == 0)
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	74 0a                	je     801a48 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  801a3e:	01 c3                	add    %eax,%ebx
  801a40:	39 f3                	cmp    %esi,%ebx
  801a42:	72 d9                	jb     801a1d <readn+0x16>
  801a44:	89 d8                	mov    %ebx,%eax
  801a46:	eb 02                	jmp    801a4a <readn+0x43>
  801a48:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a4a:	83 c4 1c             	add    $0x1c,%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5f                   	pop    %edi
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    

00801a52 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	53                   	push   %ebx
  801a56:	83 ec 24             	sub    $0x24,%esp
  801a59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a63:	89 1c 24             	mov    %ebx,(%esp)
  801a66:	e8 7b fc ff ff       	call   8016e6 <fd_lookup>
  801a6b:	89 c2                	mov    %eax,%edx
  801a6d:	85 d2                	test   %edx,%edx
  801a6f:	78 68                	js     801ad9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7b:	8b 00                	mov    (%eax),%eax
  801a7d:	89 04 24             	mov    %eax,(%esp)
  801a80:	e8 b7 fc ff ff       	call   80173c <dev_lookup>
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 50                	js     801ad9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a90:	75 23                	jne    801ab5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a92:	a1 08 50 80 00       	mov    0x805008,%eax
  801a97:	8b 40 48             	mov    0x48(%eax),%eax
  801a9a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa2:	c7 04 24 69 33 80 00 	movl   $0x803369,(%esp)
  801aa9:	e8 f2 eb ff ff       	call   8006a0 <cprintf>
		return -E_INVAL;
  801aae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ab3:	eb 24                	jmp    801ad9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ab5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab8:	8b 52 0c             	mov    0xc(%edx),%edx
  801abb:	85 d2                	test   %edx,%edx
  801abd:	74 15                	je     801ad4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ac2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801acd:	89 04 24             	mov    %eax,(%esp)
  801ad0:	ff d2                	call   *%edx
  801ad2:	eb 05                	jmp    801ad9 <write+0x87>
		return -E_NOT_SUPP;
  801ad4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801ad9:	83 c4 24             	add    $0x24,%esp
  801adc:	5b                   	pop    %ebx
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <seek>:

int
seek(int fdnum, off_t offset)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	89 04 24             	mov    %eax,(%esp)
  801af2:	e8 ef fb ff ff       	call   8016e6 <fd_lookup>
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 0e                	js     801b09 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801afb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801afe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b01:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	53                   	push   %ebx
  801b0f:	83 ec 24             	sub    $0x24,%esp
  801b12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1c:	89 1c 24             	mov    %ebx,(%esp)
  801b1f:	e8 c2 fb ff ff       	call   8016e6 <fd_lookup>
  801b24:	89 c2                	mov    %eax,%edx
  801b26:	85 d2                	test   %edx,%edx
  801b28:	78 61                	js     801b8b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b34:	8b 00                	mov    (%eax),%eax
  801b36:	89 04 24             	mov    %eax,(%esp)
  801b39:	e8 fe fb ff ff       	call   80173c <dev_lookup>
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 49                	js     801b8b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b45:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b49:	75 23                	jne    801b6e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b4b:	a1 08 50 80 00       	mov    0x805008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b50:	8b 40 48             	mov    0x48(%eax),%eax
  801b53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5b:	c7 04 24 2c 33 80 00 	movl   $0x80332c,(%esp)
  801b62:	e8 39 eb ff ff       	call   8006a0 <cprintf>
		return -E_INVAL;
  801b67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b6c:	eb 1d                	jmp    801b8b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801b6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b71:	8b 52 18             	mov    0x18(%edx),%edx
  801b74:	85 d2                	test   %edx,%edx
  801b76:	74 0e                	je     801b86 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b7f:	89 04 24             	mov    %eax,(%esp)
  801b82:	ff d2                	call   *%edx
  801b84:	eb 05                	jmp    801b8b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801b86:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801b8b:	83 c4 24             	add    $0x24,%esp
  801b8e:	5b                   	pop    %ebx
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	53                   	push   %ebx
  801b95:	83 ec 24             	sub    $0x24,%esp
  801b98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba5:	89 04 24             	mov    %eax,(%esp)
  801ba8:	e8 39 fb ff ff       	call   8016e6 <fd_lookup>
  801bad:	89 c2                	mov    %eax,%edx
  801baf:	85 d2                	test   %edx,%edx
  801bb1:	78 52                	js     801c05 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bbd:	8b 00                	mov    (%eax),%eax
  801bbf:	89 04 24             	mov    %eax,(%esp)
  801bc2:	e8 75 fb ff ff       	call   80173c <dev_lookup>
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 3a                	js     801c05 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bce:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801bd2:	74 2c                	je     801c00 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801bd4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bd7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bde:	00 00 00 
	stat->st_isdir = 0;
  801be1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801be8:	00 00 00 
	stat->st_dev = dev;
  801beb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801bf1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bf5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bf8:	89 14 24             	mov    %edx,(%esp)
  801bfb:	ff 50 14             	call   *0x14(%eax)
  801bfe:	eb 05                	jmp    801c05 <fstat+0x74>
		return -E_NOT_SUPP;
  801c00:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801c05:	83 c4 24             	add    $0x24,%esp
  801c08:	5b                   	pop    %ebx
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	56                   	push   %esi
  801c0f:	53                   	push   %ebx
  801c10:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c1a:	00 
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	89 04 24             	mov    %eax,(%esp)
  801c21:	e8 fb 01 00 00       	call   801e21 <open>
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	85 db                	test   %ebx,%ebx
  801c2a:	78 1b                	js     801c47 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c33:	89 1c 24             	mov    %ebx,(%esp)
  801c36:	e8 56 ff ff ff       	call   801b91 <fstat>
  801c3b:	89 c6                	mov    %eax,%esi
	close(fd);
  801c3d:	89 1c 24             	mov    %ebx,(%esp)
  801c40:	e8 cd fb ff ff       	call   801812 <close>
	return r;
  801c45:	89 f0                	mov    %esi,%eax
}
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	83 ec 10             	sub    $0x10,%esp
  801c56:	89 c6                	mov    %eax,%esi
  801c58:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801c5a:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801c61:	75 11                	jne    801c74 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c6a:	e8 70 0d 00 00       	call   8029df <ipc_find_env>
  801c6f:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c74:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c7b:	00 
  801c7c:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c83:	00 
  801c84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c88:	a1 04 50 80 00       	mov    0x805004,%eax
  801c8d:	89 04 24             	mov    %eax,(%esp)
  801c90:	e8 e3 0c 00 00       	call   802978 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c9c:	00 
  801c9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca8:	e8 63 0c 00 00       	call   802910 <ipc_recv>
}
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cba:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbd:	8b 40 0c             	mov    0xc(%eax),%eax
  801cc0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc8:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ccd:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd2:	b8 02 00 00 00       	mov    $0x2,%eax
  801cd7:	e8 72 ff ff ff       	call   801c4e <fsipc>
}
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <devfile_flush>:
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	8b 40 0c             	mov    0xc(%eax),%eax
  801cea:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801cef:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf4:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf9:	e8 50 ff ff ff       	call   801c4e <fsipc>
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <devfile_stat>:
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	53                   	push   %ebx
  801d04:	83 ec 14             	sub    $0x14,%esp
  801d07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d10:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d15:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1a:	b8 05 00 00 00       	mov    $0x5,%eax
  801d1f:	e8 2a ff ff ff       	call   801c4e <fsipc>
  801d24:	89 c2                	mov    %eax,%edx
  801d26:	85 d2                	test   %edx,%edx
  801d28:	78 2b                	js     801d55 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d2a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d31:	00 
  801d32:	89 1c 24             	mov    %ebx,(%esp)
  801d35:	e8 8d ef ff ff       	call   800cc7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d3a:	a1 80 60 80 00       	mov    0x806080,%eax
  801d3f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d45:	a1 84 60 80 00       	mov    0x806084,%eax
  801d4a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d55:	83 c4 14             	add    $0x14,%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <devfile_write>:
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801d61:	c7 44 24 08 98 33 80 	movl   $0x803398,0x8(%esp)
  801d68:	00 
  801d69:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801d70:	00 
  801d71:	c7 04 24 b6 33 80 00 	movl   $0x8033b6,(%esp)
  801d78:	e8 2a e8 ff ff       	call   8005a7 <_panic>

00801d7d <devfile_read>:
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	83 ec 10             	sub    $0x10,%esp
  801d85:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d88:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8b:	8b 40 0c             	mov    0xc(%eax),%eax
  801d8e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801d93:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d99:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9e:	b8 03 00 00 00       	mov    $0x3,%eax
  801da3:	e8 a6 fe ff ff       	call   801c4e <fsipc>
  801da8:	89 c3                	mov    %eax,%ebx
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 6a                	js     801e18 <devfile_read+0x9b>
	assert(r <= n);
  801dae:	39 c6                	cmp    %eax,%esi
  801db0:	73 24                	jae    801dd6 <devfile_read+0x59>
  801db2:	c7 44 24 0c c1 33 80 	movl   $0x8033c1,0xc(%esp)
  801db9:	00 
  801dba:	c7 44 24 08 c8 33 80 	movl   $0x8033c8,0x8(%esp)
  801dc1:	00 
  801dc2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801dc9:	00 
  801dca:	c7 04 24 b6 33 80 00 	movl   $0x8033b6,(%esp)
  801dd1:	e8 d1 e7 ff ff       	call   8005a7 <_panic>
	assert(r <= PGSIZE);
  801dd6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ddb:	7e 24                	jle    801e01 <devfile_read+0x84>
  801ddd:	c7 44 24 0c dd 33 80 	movl   $0x8033dd,0xc(%esp)
  801de4:	00 
  801de5:	c7 44 24 08 c8 33 80 	movl   $0x8033c8,0x8(%esp)
  801dec:	00 
  801ded:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801df4:	00 
  801df5:	c7 04 24 b6 33 80 00 	movl   $0x8033b6,(%esp)
  801dfc:	e8 a6 e7 ff ff       	call   8005a7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e01:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e05:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e0c:	00 
  801e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e10:	89 04 24             	mov    %eax,(%esp)
  801e13:	e8 4c f0 ff ff       	call   800e64 <memmove>
}
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	83 c4 10             	add    $0x10,%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <open>:
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	53                   	push   %ebx
  801e25:	83 ec 24             	sub    $0x24,%esp
  801e28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e2b:	89 1c 24             	mov    %ebx,(%esp)
  801e2e:	e8 5d ee ff ff       	call   800c90 <strlen>
  801e33:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e38:	7f 60                	jg     801e9a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801e3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3d:	89 04 24             	mov    %eax,(%esp)
  801e40:	e8 52 f8 ff ff       	call   801697 <fd_alloc>
  801e45:	89 c2                	mov    %eax,%edx
  801e47:	85 d2                	test   %edx,%edx
  801e49:	78 54                	js     801e9f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801e4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e4f:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e56:	e8 6c ee ff ff       	call   800cc7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5e:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e66:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6b:	e8 de fd ff ff       	call   801c4e <fsipc>
  801e70:	89 c3                	mov    %eax,%ebx
  801e72:	85 c0                	test   %eax,%eax
  801e74:	79 17                	jns    801e8d <open+0x6c>
		fd_close(fd, 0);
  801e76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e7d:	00 
  801e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e81:	89 04 24             	mov    %eax,(%esp)
  801e84:	e8 08 f9 ff ff       	call   801791 <fd_close>
		return r;
  801e89:	89 d8                	mov    %ebx,%eax
  801e8b:	eb 12                	jmp    801e9f <open+0x7e>
	return fd2num(fd);
  801e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e90:	89 04 24             	mov    %eax,(%esp)
  801e93:	e8 d8 f7 ff ff       	call   801670 <fd2num>
  801e98:	eb 05                	jmp    801e9f <open+0x7e>
		return -E_BAD_PATH;
  801e9a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801e9f:	83 c4 24             	add    $0x24,%esp
  801ea2:	5b                   	pop    %ebx
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    

00801ea5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801eab:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb0:	b8 08 00 00 00       	mov    $0x8,%eax
  801eb5:	e8 94 fd ff ff       	call   801c4e <fsipc>
}
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    
  801ebc:	66 90                	xchg   %ax,%ax
  801ebe:	66 90                	xchg   %ax,%ax

00801ec0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	57                   	push   %edi
  801ec4:	56                   	push   %esi
  801ec5:	53                   	push   %ebx
  801ec6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801ecc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ed3:	00 
  801ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed7:	89 04 24             	mov    %eax,(%esp)
  801eda:	e8 42 ff ff ff       	call   801e21 <open>
  801edf:	89 c1                	mov    %eax,%ecx
  801ee1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	0f 88 a8 04 00 00    	js     802397 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801eef:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801ef6:	00 
  801ef7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801efd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f01:	89 0c 24             	mov    %ecx,(%esp)
  801f04:	e8 fe fa ff ff       	call   801a07 <readn>
  801f09:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f0e:	75 0c                	jne    801f1c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801f10:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f17:	45 4c 46 
  801f1a:	74 36                	je     801f52 <spawn+0x92>
		close(fd);
  801f1c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f22:	89 04 24             	mov    %eax,(%esp)
  801f25:	e8 e8 f8 ff ff       	call   801812 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f2a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801f31:	46 
  801f32:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801f38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3c:	c7 04 24 e9 33 80 00 	movl   $0x8033e9,(%esp)
  801f43:	e8 58 e7 ff ff       	call   8006a0 <cprintf>
		return -E_NOT_EXEC;
  801f48:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801f4d:	e9 a4 04 00 00       	jmp    8023f6 <spawn+0x536>
  801f52:	b8 07 00 00 00       	mov    $0x7,%eax
  801f57:	cd 30                	int    $0x30
  801f59:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801f5f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801f65:	85 c0                	test   %eax,%eax
  801f67:	0f 88 32 04 00 00    	js     80239f <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801f6d:	89 c6                	mov    %eax,%esi
  801f6f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801f75:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801f78:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801f7e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801f84:	b9 11 00 00 00       	mov    $0x11,%ecx
  801f89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801f8b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801f91:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801f97:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801f9c:	be 00 00 00 00       	mov    $0x0,%esi
  801fa1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fa4:	eb 0f                	jmp    801fb5 <spawn+0xf5>
		string_size += strlen(argv[argc]) + 1;
  801fa6:	89 04 24             	mov    %eax,(%esp)
  801fa9:	e8 e2 ec ff ff       	call   800c90 <strlen>
  801fae:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801fb2:	83 c3 01             	add    $0x1,%ebx
  801fb5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801fbc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	75 e3                	jne    801fa6 <spawn+0xe6>
  801fc3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801fc9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801fcf:	bf 00 10 40 00       	mov    $0x401000,%edi
  801fd4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801fd6:	89 fa                	mov    %edi,%edx
  801fd8:	83 e2 fc             	and    $0xfffffffc,%edx
  801fdb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801fe2:	29 c2                	sub    %eax,%edx
  801fe4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801fea:	8d 42 f8             	lea    -0x8(%edx),%eax
  801fed:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ff2:	0f 86 b7 03 00 00    	jbe    8023af <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ff8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801fff:	00 
  802000:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802007:	00 
  802008:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200f:	e8 cf f0 ff ff       	call   8010e3 <sys_page_alloc>
  802014:	85 c0                	test   %eax,%eax
  802016:	0f 88 da 03 00 00    	js     8023f6 <spawn+0x536>
  80201c:	be 00 00 00 00       	mov    $0x0,%esi
  802021:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802027:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80202a:	eb 30                	jmp    80205c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80202c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802032:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802038:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80203b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80203e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802042:	89 3c 24             	mov    %edi,(%esp)
  802045:	e8 7d ec ff ff       	call   800cc7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80204a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80204d:	89 04 24             	mov    %eax,(%esp)
  802050:	e8 3b ec ff ff       	call   800c90 <strlen>
  802055:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  802059:	83 c6 01             	add    $0x1,%esi
  80205c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802062:	7f c8                	jg     80202c <spawn+0x16c>
	}
	argv_store[argc] = 0;
  802064:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80206a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802070:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802077:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80207d:	74 24                	je     8020a3 <spawn+0x1e3>
  80207f:	c7 44 24 0c 60 34 80 	movl   $0x803460,0xc(%esp)
  802086:	00 
  802087:	c7 44 24 08 c8 33 80 	movl   $0x8033c8,0x8(%esp)
  80208e:	00 
  80208f:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  802096:	00 
  802097:	c7 04 24 03 34 80 00 	movl   $0x803403,(%esp)
  80209e:	e8 04 e5 ff ff       	call   8005a7 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8020a3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8020a9:	89 c8                	mov    %ecx,%eax
  8020ab:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8020b0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8020b3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8020b9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8020bc:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8020c2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8020c8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8020cf:	00 
  8020d0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8020d7:	ee 
  8020d8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8020de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020e2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020e9:	00 
  8020ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f1:	e8 41 f0 ff ff       	call   801137 <sys_page_map>
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	0f 88 e0 02 00 00    	js     8023e0 <spawn+0x520>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802100:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802107:	00 
  802108:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210f:	e8 76 f0 ff ff       	call   80118a <sys_page_unmap>
  802114:	89 c3                	mov    %eax,%ebx
  802116:	85 c0                	test   %eax,%eax
  802118:	0f 88 c2 02 00 00    	js     8023e0 <spawn+0x520>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80211e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802124:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80212b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802131:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802138:	00 00 00 
  80213b:	e9 b6 01 00 00       	jmp    8022f6 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  802140:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802146:	83 38 01             	cmpl   $0x1,(%eax)
  802149:	0f 85 99 01 00 00    	jne    8022e8 <spawn+0x428>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80214f:	89 c1                	mov    %eax,%ecx
  802151:	8b 40 18             	mov    0x18(%eax),%eax
  802154:	83 e0 02             	and    $0x2,%eax
		perm = PTE_P | PTE_U;
  802157:	83 f8 01             	cmp    $0x1,%eax
  80215a:	19 c0                	sbb    %eax,%eax
  80215c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802162:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  802169:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802170:	89 c8                	mov    %ecx,%eax
  802172:	8b 51 04             	mov    0x4(%ecx),%edx
  802175:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  80217b:	8b 49 10             	mov    0x10(%ecx),%ecx
  80217e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  802184:	8b 50 14             	mov    0x14(%eax),%edx
  802187:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  80218d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802190:	89 f0                	mov    %esi,%eax
  802192:	25 ff 0f 00 00       	and    $0xfff,%eax
  802197:	74 14                	je     8021ad <spawn+0x2ed>
		va -= i;
  802199:	29 c6                	sub    %eax,%esi
		memsz += i;
  80219b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8021a1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8021a7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8021ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021b2:	e9 23 01 00 00       	jmp    8022da <spawn+0x41a>
		if (i >= filesz) {
  8021b7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8021bd:	77 2b                	ja     8021ea <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8021bf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8021c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021cd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8021d3:	89 04 24             	mov    %eax,(%esp)
  8021d6:	e8 08 ef ff ff       	call   8010e3 <sys_page_alloc>
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	0f 89 eb 00 00 00    	jns    8022ce <spawn+0x40e>
  8021e3:	89 c3                	mov    %eax,%ebx
  8021e5:	e9 d6 01 00 00       	jmp    8023c0 <spawn+0x500>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8021ea:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021f1:	00 
  8021f2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021f9:	00 
  8021fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802201:	e8 dd ee ff ff       	call   8010e3 <sys_page_alloc>
  802206:	85 c0                	test   %eax,%eax
  802208:	0f 88 a8 01 00 00    	js     8023b6 <spawn+0x4f6>
  80220e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802214:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80221a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802220:	89 04 24             	mov    %eax,(%esp)
  802223:	e8 b7 f8 ff ff       	call   801adf <seek>
  802228:	85 c0                	test   %eax,%eax
  80222a:	0f 88 8a 01 00 00    	js     8023ba <spawn+0x4fa>
  802230:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802236:	29 fa                	sub    %edi,%edx
  802238:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80223a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  802240:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802245:	0f 47 c1             	cmova  %ecx,%eax
  802248:	89 44 24 08          	mov    %eax,0x8(%esp)
  80224c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802253:	00 
  802254:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80225a:	89 04 24             	mov    %eax,(%esp)
  80225d:	e8 a5 f7 ff ff       	call   801a07 <readn>
  802262:	85 c0                	test   %eax,%eax
  802264:	0f 88 54 01 00 00    	js     8023be <spawn+0x4fe>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80226a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802270:	89 44 24 10          	mov    %eax,0x10(%esp)
  802274:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802278:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80227e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802282:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802289:	00 
  80228a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802291:	e8 a1 ee ff ff       	call   801137 <sys_page_map>
  802296:	85 c0                	test   %eax,%eax
  802298:	79 20                	jns    8022ba <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  80229a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229e:	c7 44 24 08 0f 34 80 	movl   $0x80340f,0x8(%esp)
  8022a5:	00 
  8022a6:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  8022ad:	00 
  8022ae:	c7 04 24 03 34 80 00 	movl   $0x803403,(%esp)
  8022b5:	e8 ed e2 ff ff       	call   8005a7 <_panic>
			sys_page_unmap(0, UTEMP);
  8022ba:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022c1:	00 
  8022c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c9:	e8 bc ee ff ff       	call   80118a <sys_page_unmap>
	for (i = 0; i < memsz; i += PGSIZE) {
  8022ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8022d4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8022da:	89 df                	mov    %ebx,%edi
  8022dc:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8022e2:	0f 87 cf fe ff ff    	ja     8021b7 <spawn+0x2f7>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8022e8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8022ef:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8022f6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8022fd:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802303:	0f 8c 37 fe ff ff    	jl     802140 <spawn+0x280>
	close(fd);
  802309:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80230f:	89 04 24             	mov    %eax,(%esp)
  802312:	e8 fb f4 ff ff       	call   801812 <close>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802317:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80231e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802321:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802327:	89 44 24 04          	mov    %eax,0x4(%esp)
  80232b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802331:	89 04 24             	mov    %eax,(%esp)
  802334:	e8 f7 ee ff ff       	call   801230 <sys_env_set_trapframe>
  802339:	85 c0                	test   %eax,%eax
  80233b:	79 20                	jns    80235d <spawn+0x49d>
		panic("sys_env_set_trapframe: %e", r);
  80233d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802341:	c7 44 24 08 2c 34 80 	movl   $0x80342c,0x8(%esp)
  802348:	00 
  802349:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802350:	00 
  802351:	c7 04 24 03 34 80 00 	movl   $0x803403,(%esp)
  802358:	e8 4a e2 ff ff       	call   8005a7 <_panic>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80235d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802364:	00 
  802365:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80236b:	89 04 24             	mov    %eax,(%esp)
  80236e:	e8 6a ee ff ff       	call   8011dd <sys_env_set_status>
  802373:	85 c0                	test   %eax,%eax
  802375:	79 30                	jns    8023a7 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  802377:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80237b:	c7 44 24 08 46 34 80 	movl   $0x803446,0x8(%esp)
  802382:	00 
  802383:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  80238a:	00 
  80238b:	c7 04 24 03 34 80 00 	movl   $0x803403,(%esp)
  802392:	e8 10 e2 ff ff       	call   8005a7 <_panic>
		return r;
  802397:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80239d:	eb 57                	jmp    8023f6 <spawn+0x536>
		return r;
  80239f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8023a5:	eb 4f                	jmp    8023f6 <spawn+0x536>
	return child;
  8023a7:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8023ad:	eb 47                	jmp    8023f6 <spawn+0x536>
		return -E_NO_MEM;
  8023af:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8023b4:	eb 40                	jmp    8023f6 <spawn+0x536>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8023b6:	89 c3                	mov    %eax,%ebx
  8023b8:	eb 06                	jmp    8023c0 <spawn+0x500>
			if ((r = seek(fd, fileoffset + i)) < 0)
  8023ba:	89 c3                	mov    %eax,%ebx
  8023bc:	eb 02                	jmp    8023c0 <spawn+0x500>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8023be:	89 c3                	mov    %eax,%ebx
	sys_env_destroy(child);
  8023c0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8023c6:	89 04 24             	mov    %eax,(%esp)
  8023c9:	e8 85 ec ff ff       	call   801053 <sys_env_destroy>
	close(fd);
  8023ce:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8023d4:	89 04 24             	mov    %eax,(%esp)
  8023d7:	e8 36 f4 ff ff       	call   801812 <close>
	return r;
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	eb 16                	jmp    8023f6 <spawn+0x536>
	sys_page_unmap(0, UTEMP);
  8023e0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8023e7:	00 
  8023e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ef:	e8 96 ed ff ff       	call   80118a <sys_page_unmap>
  8023f4:	89 d8                	mov    %ebx,%eax
}
  8023f6:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  8023fc:	5b                   	pop    %ebx
  8023fd:	5e                   	pop    %esi
  8023fe:	5f                   	pop    %edi
  8023ff:	5d                   	pop    %ebp
  802400:	c3                   	ret    

00802401 <spawnl>:
{
  802401:	55                   	push   %ebp
  802402:	89 e5                	mov    %esp,%ebp
  802404:	56                   	push   %esi
  802405:	53                   	push   %ebx
  802406:	83 ec 10             	sub    $0x10,%esp
	while(va_arg(vl, void *) != NULL)
  802409:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  80240c:	ba 00 00 00 00       	mov    $0x0,%edx
	while(va_arg(vl, void *) != NULL)
  802411:	eb 03                	jmp    802416 <spawnl+0x15>
		argc++;
  802413:	83 c2 01             	add    $0x1,%edx
	while(va_arg(vl, void *) != NULL)
  802416:	83 c0 04             	add    $0x4,%eax
  802419:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  80241d:	75 f4                	jne    802413 <spawnl+0x12>
	const char *argv[argc+2];
  80241f:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  802426:	83 e0 f0             	and    $0xfffffff0,%eax
  802429:	29 c4                	sub    %eax,%esp
  80242b:	8d 44 24 0b          	lea    0xb(%esp),%eax
  80242f:	c1 e8 02             	shr    $0x2,%eax
  802432:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  802439:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80243b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80243e:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  802445:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  80244c:	00 
	for(i=0;i<argc;i++)
  80244d:	b8 00 00 00 00       	mov    $0x0,%eax
  802452:	eb 0a                	jmp    80245e <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  802454:	83 c0 01             	add    $0x1,%eax
  802457:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80245b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	for(i=0;i<argc;i++)
  80245e:	39 d0                	cmp    %edx,%eax
  802460:	75 f2                	jne    802454 <spawnl+0x53>
	return spawn(prog, argv);
  802462:	89 74 24 04          	mov    %esi,0x4(%esp)
  802466:	8b 45 08             	mov    0x8(%ebp),%eax
  802469:	89 04 24             	mov    %eax,(%esp)
  80246c:	e8 4f fa ff ff       	call   801ec0 <spawn>
}
  802471:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802474:	5b                   	pop    %ebx
  802475:	5e                   	pop    %esi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    

00802478 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	56                   	push   %esi
  80247c:	53                   	push   %ebx
  80247d:	83 ec 10             	sub    $0x10,%esp
  802480:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802483:	8b 45 08             	mov    0x8(%ebp),%eax
  802486:	89 04 24             	mov    %eax,(%esp)
  802489:	e8 f2 f1 ff ff       	call   801680 <fd2data>
  80248e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802490:	c7 44 24 04 86 34 80 	movl   $0x803486,0x4(%esp)
  802497:	00 
  802498:	89 1c 24             	mov    %ebx,(%esp)
  80249b:	e8 27 e8 ff ff       	call   800cc7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8024a0:	8b 46 04             	mov    0x4(%esi),%eax
  8024a3:	2b 06                	sub    (%esi),%eax
  8024a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8024ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8024b2:	00 00 00 
	stat->st_dev = &devpipe;
  8024b5:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8024bc:	40 80 00 
	return 0;
}
  8024bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c4:	83 c4 10             	add    $0x10,%esp
  8024c7:	5b                   	pop    %ebx
  8024c8:	5e                   	pop    %esi
  8024c9:	5d                   	pop    %ebp
  8024ca:	c3                   	ret    

008024cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024cb:	55                   	push   %ebp
  8024cc:	89 e5                	mov    %esp,%ebp
  8024ce:	53                   	push   %ebx
  8024cf:	83 ec 14             	sub    $0x14,%esp
  8024d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e0:	e8 a5 ec ff ff       	call   80118a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024e5:	89 1c 24             	mov    %ebx,(%esp)
  8024e8:	e8 93 f1 ff ff       	call   801680 <fd2data>
  8024ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f8:	e8 8d ec ff ff       	call   80118a <sys_page_unmap>
}
  8024fd:	83 c4 14             	add    $0x14,%esp
  802500:	5b                   	pop    %ebx
  802501:	5d                   	pop    %ebp
  802502:	c3                   	ret    

00802503 <_pipeisclosed>:
{
  802503:	55                   	push   %ebp
  802504:	89 e5                	mov    %esp,%ebp
  802506:	57                   	push   %edi
  802507:	56                   	push   %esi
  802508:	53                   	push   %ebx
  802509:	83 ec 2c             	sub    $0x2c,%esp
  80250c:	89 c6                	mov    %eax,%esi
  80250e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  802511:	a1 08 50 80 00       	mov    0x805008,%eax
  802516:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802519:	89 34 24             	mov    %esi,(%esp)
  80251c:	e8 f6 04 00 00       	call   802a17 <pageref>
  802521:	89 c7                	mov    %eax,%edi
  802523:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802526:	89 04 24             	mov    %eax,(%esp)
  802529:	e8 e9 04 00 00       	call   802a17 <pageref>
  80252e:	39 c7                	cmp    %eax,%edi
  802530:	0f 94 c2             	sete   %dl
  802533:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802536:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  80253c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80253f:	39 fb                	cmp    %edi,%ebx
  802541:	74 21                	je     802564 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  802543:	84 d2                	test   %dl,%dl
  802545:	74 ca                	je     802511 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802547:	8b 51 58             	mov    0x58(%ecx),%edx
  80254a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80254e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802556:	c7 04 24 8d 34 80 00 	movl   $0x80348d,(%esp)
  80255d:	e8 3e e1 ff ff       	call   8006a0 <cprintf>
  802562:	eb ad                	jmp    802511 <_pipeisclosed+0xe>
}
  802564:	83 c4 2c             	add    $0x2c,%esp
  802567:	5b                   	pop    %ebx
  802568:	5e                   	pop    %esi
  802569:	5f                   	pop    %edi
  80256a:	5d                   	pop    %ebp
  80256b:	c3                   	ret    

0080256c <devpipe_write>:
{
  80256c:	55                   	push   %ebp
  80256d:	89 e5                	mov    %esp,%ebp
  80256f:	57                   	push   %edi
  802570:	56                   	push   %esi
  802571:	53                   	push   %ebx
  802572:	83 ec 1c             	sub    $0x1c,%esp
  802575:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802578:	89 34 24             	mov    %esi,(%esp)
  80257b:	e8 00 f1 ff ff       	call   801680 <fd2data>
  802580:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802582:	bf 00 00 00 00       	mov    $0x0,%edi
  802587:	eb 45                	jmp    8025ce <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  802589:	89 da                	mov    %ebx,%edx
  80258b:	89 f0                	mov    %esi,%eax
  80258d:	e8 71 ff ff ff       	call   802503 <_pipeisclosed>
  802592:	85 c0                	test   %eax,%eax
  802594:	75 41                	jne    8025d7 <devpipe_write+0x6b>
			sys_yield();
  802596:	e8 29 eb ff ff       	call   8010c4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80259b:	8b 43 04             	mov    0x4(%ebx),%eax
  80259e:	8b 0b                	mov    (%ebx),%ecx
  8025a0:	8d 51 20             	lea    0x20(%ecx),%edx
  8025a3:	39 d0                	cmp    %edx,%eax
  8025a5:	73 e2                	jae    802589 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8025a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025aa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8025ae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8025b1:	99                   	cltd   
  8025b2:	c1 ea 1b             	shr    $0x1b,%edx
  8025b5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8025b8:	83 e1 1f             	and    $0x1f,%ecx
  8025bb:	29 d1                	sub    %edx,%ecx
  8025bd:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8025c1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8025c5:	83 c0 01             	add    $0x1,%eax
  8025c8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8025cb:	83 c7 01             	add    $0x1,%edi
  8025ce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025d1:	75 c8                	jne    80259b <devpipe_write+0x2f>
	return i;
  8025d3:	89 f8                	mov    %edi,%eax
  8025d5:	eb 05                	jmp    8025dc <devpipe_write+0x70>
				return 0;
  8025d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025dc:	83 c4 1c             	add    $0x1c,%esp
  8025df:	5b                   	pop    %ebx
  8025e0:	5e                   	pop    %esi
  8025e1:	5f                   	pop    %edi
  8025e2:	5d                   	pop    %ebp
  8025e3:	c3                   	ret    

008025e4 <devpipe_read>:
{
  8025e4:	55                   	push   %ebp
  8025e5:	89 e5                	mov    %esp,%ebp
  8025e7:	57                   	push   %edi
  8025e8:	56                   	push   %esi
  8025e9:	53                   	push   %ebx
  8025ea:	83 ec 1c             	sub    $0x1c,%esp
  8025ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8025f0:	89 3c 24             	mov    %edi,(%esp)
  8025f3:	e8 88 f0 ff ff       	call   801680 <fd2data>
  8025f8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8025fa:	be 00 00 00 00       	mov    $0x0,%esi
  8025ff:	eb 3d                	jmp    80263e <devpipe_read+0x5a>
			if (i > 0)
  802601:	85 f6                	test   %esi,%esi
  802603:	74 04                	je     802609 <devpipe_read+0x25>
				return i;
  802605:	89 f0                	mov    %esi,%eax
  802607:	eb 43                	jmp    80264c <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  802609:	89 da                	mov    %ebx,%edx
  80260b:	89 f8                	mov    %edi,%eax
  80260d:	e8 f1 fe ff ff       	call   802503 <_pipeisclosed>
  802612:	85 c0                	test   %eax,%eax
  802614:	75 31                	jne    802647 <devpipe_read+0x63>
			sys_yield();
  802616:	e8 a9 ea ff ff       	call   8010c4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80261b:	8b 03                	mov    (%ebx),%eax
  80261d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802620:	74 df                	je     802601 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802622:	99                   	cltd   
  802623:	c1 ea 1b             	shr    $0x1b,%edx
  802626:	01 d0                	add    %edx,%eax
  802628:	83 e0 1f             	and    $0x1f,%eax
  80262b:	29 d0                	sub    %edx,%eax
  80262d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802632:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802635:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802638:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80263b:	83 c6 01             	add    $0x1,%esi
  80263e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802641:	75 d8                	jne    80261b <devpipe_read+0x37>
	return i;
  802643:	89 f0                	mov    %esi,%eax
  802645:	eb 05                	jmp    80264c <devpipe_read+0x68>
				return 0;
  802647:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80264c:	83 c4 1c             	add    $0x1c,%esp
  80264f:	5b                   	pop    %ebx
  802650:	5e                   	pop    %esi
  802651:	5f                   	pop    %edi
  802652:	5d                   	pop    %ebp
  802653:	c3                   	ret    

00802654 <pipe>:
{
  802654:	55                   	push   %ebp
  802655:	89 e5                	mov    %esp,%ebp
  802657:	56                   	push   %esi
  802658:	53                   	push   %ebx
  802659:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80265c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80265f:	89 04 24             	mov    %eax,(%esp)
  802662:	e8 30 f0 ff ff       	call   801697 <fd_alloc>
  802667:	89 c2                	mov    %eax,%edx
  802669:	85 d2                	test   %edx,%edx
  80266b:	0f 88 4d 01 00 00    	js     8027be <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802671:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802678:	00 
  802679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80267c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802687:	e8 57 ea ff ff       	call   8010e3 <sys_page_alloc>
  80268c:	89 c2                	mov    %eax,%edx
  80268e:	85 d2                	test   %edx,%edx
  802690:	0f 88 28 01 00 00    	js     8027be <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  802696:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802699:	89 04 24             	mov    %eax,(%esp)
  80269c:	e8 f6 ef ff ff       	call   801697 <fd_alloc>
  8026a1:	89 c3                	mov    %eax,%ebx
  8026a3:	85 c0                	test   %eax,%eax
  8026a5:	0f 88 fe 00 00 00    	js     8027a9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026ab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026b2:	00 
  8026b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026c1:	e8 1d ea ff ff       	call   8010e3 <sys_page_alloc>
  8026c6:	89 c3                	mov    %eax,%ebx
  8026c8:	85 c0                	test   %eax,%eax
  8026ca:	0f 88 d9 00 00 00    	js     8027a9 <pipe+0x155>
	va = fd2data(fd0);
  8026d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026d3:	89 04 24             	mov    %eax,(%esp)
  8026d6:	e8 a5 ef ff ff       	call   801680 <fd2data>
  8026db:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026e4:	00 
  8026e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026f0:	e8 ee e9 ff ff       	call   8010e3 <sys_page_alloc>
  8026f5:	89 c3                	mov    %eax,%ebx
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	0f 88 97 00 00 00    	js     802796 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802702:	89 04 24             	mov    %eax,(%esp)
  802705:	e8 76 ef ff ff       	call   801680 <fd2data>
  80270a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802711:	00 
  802712:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802716:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80271d:	00 
  80271e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802722:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802729:	e8 09 ea ff ff       	call   801137 <sys_page_map>
  80272e:	89 c3                	mov    %eax,%ebx
  802730:	85 c0                	test   %eax,%eax
  802732:	78 52                	js     802786 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  802734:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80273a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80273d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80273f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802742:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  802749:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80274f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802752:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802757:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80275e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802761:	89 04 24             	mov    %eax,(%esp)
  802764:	e8 07 ef ff ff       	call   801670 <fd2num>
  802769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80276c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80276e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802771:	89 04 24             	mov    %eax,(%esp)
  802774:	e8 f7 ee ff ff       	call   801670 <fd2num>
  802779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80277c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80277f:	b8 00 00 00 00       	mov    $0x0,%eax
  802784:	eb 38                	jmp    8027be <pipe+0x16a>
	sys_page_unmap(0, va);
  802786:	89 74 24 04          	mov    %esi,0x4(%esp)
  80278a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802791:	e8 f4 e9 ff ff       	call   80118a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  802796:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80279d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027a4:	e8 e1 e9 ff ff       	call   80118a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  8027a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027b7:	e8 ce e9 ff ff       	call   80118a <sys_page_unmap>
  8027bc:	89 d8                	mov    %ebx,%eax
}
  8027be:	83 c4 30             	add    $0x30,%esp
  8027c1:	5b                   	pop    %ebx
  8027c2:	5e                   	pop    %esi
  8027c3:	5d                   	pop    %ebp
  8027c4:	c3                   	ret    

008027c5 <pipeisclosed>:
{
  8027c5:	55                   	push   %ebp
  8027c6:	89 e5                	mov    %esp,%ebp
  8027c8:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8027d5:	89 04 24             	mov    %eax,(%esp)
  8027d8:	e8 09 ef ff ff       	call   8016e6 <fd_lookup>
  8027dd:	89 c2                	mov    %eax,%edx
  8027df:	85 d2                	test   %edx,%edx
  8027e1:	78 15                	js     8027f8 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  8027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027e6:	89 04 24             	mov    %eax,(%esp)
  8027e9:	e8 92 ee ff ff       	call   801680 <fd2data>
	return _pipeisclosed(fd, p);
  8027ee:	89 c2                	mov    %eax,%edx
  8027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027f3:	e8 0b fd ff ff       	call   802503 <_pipeisclosed>
}
  8027f8:	c9                   	leave  
  8027f9:	c3                   	ret    

008027fa <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8027fa:	55                   	push   %ebp
  8027fb:	89 e5                	mov    %esp,%ebp
  8027fd:	56                   	push   %esi
  8027fe:	53                   	push   %ebx
  8027ff:	83 ec 10             	sub    $0x10,%esp
  802802:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802805:	85 f6                	test   %esi,%esi
  802807:	75 24                	jne    80282d <wait+0x33>
  802809:	c7 44 24 0c a5 34 80 	movl   $0x8034a5,0xc(%esp)
  802810:	00 
  802811:	c7 44 24 08 c8 33 80 	movl   $0x8033c8,0x8(%esp)
  802818:	00 
  802819:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802820:	00 
  802821:	c7 04 24 b0 34 80 00 	movl   $0x8034b0,(%esp)
  802828:	e8 7a dd ff ff       	call   8005a7 <_panic>
	e = &envs[ENVX(envid)];
  80282d:	89 f3                	mov    %esi,%ebx
  80282f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802835:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802838:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80283e:	eb 05                	jmp    802845 <wait+0x4b>
		sys_yield();
  802840:	e8 7f e8 ff ff       	call   8010c4 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802845:	8b 43 48             	mov    0x48(%ebx),%eax
  802848:	39 f0                	cmp    %esi,%eax
  80284a:	75 07                	jne    802853 <wait+0x59>
  80284c:	8b 43 54             	mov    0x54(%ebx),%eax
  80284f:	85 c0                	test   %eax,%eax
  802851:	75 ed                	jne    802840 <wait+0x46>
}
  802853:	83 c4 10             	add    $0x10,%esp
  802856:	5b                   	pop    %ebx
  802857:	5e                   	pop    %esi
  802858:	5d                   	pop    %ebp
  802859:	c3                   	ret    

0080285a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80285a:	55                   	push   %ebp
  80285b:	89 e5                	mov    %esp,%ebp
  80285d:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  802860:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802867:	75 70                	jne    8028d9 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802869:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802870:	00 
  802871:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802878:	ee 
  802879:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802880:	e8 5e e8 ff ff       	call   8010e3 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  802885:	85 c0                	test   %eax,%eax
  802887:	79 1c                	jns    8028a5 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  802889:	c7 44 24 08 bc 34 80 	movl   $0x8034bc,0x8(%esp)
  802890:	00 
  802891:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  802898:	00 
  802899:	c7 04 24 18 35 80 00 	movl   $0x803518,(%esp)
  8028a0:	e8 02 dd ff ff       	call   8005a7 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  8028a5:	c7 44 24 04 e3 28 80 	movl   $0x8028e3,0x4(%esp)
  8028ac:	00 
  8028ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028b4:	e8 ca e9 ff ff       	call   801283 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8028b9:	85 c0                	test   %eax,%eax
  8028bb:	79 1c                	jns    8028d9 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  8028bd:	c7 44 24 08 e4 34 80 	movl   $0x8034e4,0x8(%esp)
  8028c4:	00 
  8028c5:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8028cc:	00 
  8028cd:	c7 04 24 18 35 80 00 	movl   $0x803518,(%esp)
  8028d4:	e8 ce dc ff ff       	call   8005a7 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8028dc:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8028e1:	c9                   	leave  
  8028e2:	c3                   	ret    

008028e3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028e3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028e4:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8028e9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028eb:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  8028ee:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  8028f2:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  8028f6:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  8028f8:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  8028fa:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  8028fb:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  8028fe:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  802900:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  802903:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802904:	83 c4 04             	add    $0x4,%esp
    popf;
  802907:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  802908:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  802909:	c3                   	ret    
  80290a:	66 90                	xchg   %ax,%ax
  80290c:	66 90                	xchg   %ax,%ax
  80290e:	66 90                	xchg   %ax,%ax

00802910 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802910:	55                   	push   %ebp
  802911:	89 e5                	mov    %esp,%ebp
  802913:	56                   	push   %esi
  802914:	53                   	push   %ebx
  802915:	83 ec 10             	sub    $0x10,%esp
  802918:	8b 75 08             	mov    0x8(%ebp),%esi
  80291b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80291e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802921:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802923:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802928:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80292b:	89 04 24             	mov    %eax,(%esp)
  80292e:	e8 c6 e9 ff ff       	call   8012f9 <sys_ipc_recv>
    if(r < 0){
  802933:	85 c0                	test   %eax,%eax
  802935:	79 16                	jns    80294d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802937:	85 f6                	test   %esi,%esi
  802939:	74 06                	je     802941 <ipc_recv+0x31>
            *from_env_store = 0;
  80293b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802941:	85 db                	test   %ebx,%ebx
  802943:	74 2c                	je     802971 <ipc_recv+0x61>
            *perm_store = 0;
  802945:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80294b:	eb 24                	jmp    802971 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80294d:	85 f6                	test   %esi,%esi
  80294f:	74 0a                	je     80295b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802951:	a1 08 50 80 00       	mov    0x805008,%eax
  802956:	8b 40 74             	mov    0x74(%eax),%eax
  802959:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80295b:	85 db                	test   %ebx,%ebx
  80295d:	74 0a                	je     802969 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80295f:	a1 08 50 80 00       	mov    0x805008,%eax
  802964:	8b 40 78             	mov    0x78(%eax),%eax
  802967:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802969:	a1 08 50 80 00       	mov    0x805008,%eax
  80296e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802971:	83 c4 10             	add    $0x10,%esp
  802974:	5b                   	pop    %ebx
  802975:	5e                   	pop    %esi
  802976:	5d                   	pop    %ebp
  802977:	c3                   	ret    

00802978 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802978:	55                   	push   %ebp
  802979:	89 e5                	mov    %esp,%ebp
  80297b:	57                   	push   %edi
  80297c:	56                   	push   %esi
  80297d:	53                   	push   %ebx
  80297e:	83 ec 1c             	sub    $0x1c,%esp
  802981:	8b 7d 08             	mov    0x8(%ebp),%edi
  802984:	8b 75 0c             	mov    0xc(%ebp),%esi
  802987:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80298a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80298c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802991:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802994:	8b 45 14             	mov    0x14(%ebp),%eax
  802997:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80299b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80299f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029a3:	89 3c 24             	mov    %edi,(%esp)
  8029a6:	e8 2b e9 ff ff       	call   8012d6 <sys_ipc_try_send>
        if(r == 0){
  8029ab:	85 c0                	test   %eax,%eax
  8029ad:	74 28                	je     8029d7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8029af:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029b2:	74 1c                	je     8029d0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8029b4:	c7 44 24 08 26 35 80 	movl   $0x803526,0x8(%esp)
  8029bb:	00 
  8029bc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8029c3:	00 
  8029c4:	c7 04 24 3d 35 80 00 	movl   $0x80353d,(%esp)
  8029cb:	e8 d7 db ff ff       	call   8005a7 <_panic>
        }
        sys_yield();
  8029d0:	e8 ef e6 ff ff       	call   8010c4 <sys_yield>
    }
  8029d5:	eb bd                	jmp    802994 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8029d7:	83 c4 1c             	add    $0x1c,%esp
  8029da:	5b                   	pop    %ebx
  8029db:	5e                   	pop    %esi
  8029dc:	5f                   	pop    %edi
  8029dd:	5d                   	pop    %ebp
  8029de:	c3                   	ret    

008029df <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029df:	55                   	push   %ebp
  8029e0:	89 e5                	mov    %esp,%ebp
  8029e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029e5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029ea:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8029ed:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029f3:	8b 52 50             	mov    0x50(%edx),%edx
  8029f6:	39 ca                	cmp    %ecx,%edx
  8029f8:	75 0d                	jne    802a07 <ipc_find_env+0x28>
			return envs[i].env_id;
  8029fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029fd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802a02:	8b 40 40             	mov    0x40(%eax),%eax
  802a05:	eb 0e                	jmp    802a15 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802a07:	83 c0 01             	add    $0x1,%eax
  802a0a:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a0f:	75 d9                	jne    8029ea <ipc_find_env+0xb>
	return 0;
  802a11:	66 b8 00 00          	mov    $0x0,%ax
}
  802a15:	5d                   	pop    %ebp
  802a16:	c3                   	ret    

00802a17 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a17:	55                   	push   %ebp
  802a18:	89 e5                	mov    %esp,%ebp
  802a1a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a1d:	89 d0                	mov    %edx,%eax
  802a1f:	c1 e8 16             	shr    $0x16,%eax
  802a22:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a29:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802a2e:	f6 c1 01             	test   $0x1,%cl
  802a31:	74 1d                	je     802a50 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802a33:	c1 ea 0c             	shr    $0xc,%edx
  802a36:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a3d:	f6 c2 01             	test   $0x1,%dl
  802a40:	74 0e                	je     802a50 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a42:	c1 ea 0c             	shr    $0xc,%edx
  802a45:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a4c:	ef 
  802a4d:	0f b7 c0             	movzwl %ax,%eax
}
  802a50:	5d                   	pop    %ebp
  802a51:	c3                   	ret    
  802a52:	66 90                	xchg   %ax,%ax
  802a54:	66 90                	xchg   %ax,%ax
  802a56:	66 90                	xchg   %ax,%ax
  802a58:	66 90                	xchg   %ax,%ax
  802a5a:	66 90                	xchg   %ax,%ax
  802a5c:	66 90                	xchg   %ax,%ax
  802a5e:	66 90                	xchg   %ax,%ax

00802a60 <__udivdi3>:
  802a60:	55                   	push   %ebp
  802a61:	57                   	push   %edi
  802a62:	56                   	push   %esi
  802a63:	83 ec 0c             	sub    $0xc,%esp
  802a66:	8b 44 24 28          	mov    0x28(%esp),%eax
  802a6a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802a6e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802a72:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802a76:	85 c0                	test   %eax,%eax
  802a78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a7c:	89 ea                	mov    %ebp,%edx
  802a7e:	89 0c 24             	mov    %ecx,(%esp)
  802a81:	75 2d                	jne    802ab0 <__udivdi3+0x50>
  802a83:	39 e9                	cmp    %ebp,%ecx
  802a85:	77 61                	ja     802ae8 <__udivdi3+0x88>
  802a87:	85 c9                	test   %ecx,%ecx
  802a89:	89 ce                	mov    %ecx,%esi
  802a8b:	75 0b                	jne    802a98 <__udivdi3+0x38>
  802a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  802a92:	31 d2                	xor    %edx,%edx
  802a94:	f7 f1                	div    %ecx
  802a96:	89 c6                	mov    %eax,%esi
  802a98:	31 d2                	xor    %edx,%edx
  802a9a:	89 e8                	mov    %ebp,%eax
  802a9c:	f7 f6                	div    %esi
  802a9e:	89 c5                	mov    %eax,%ebp
  802aa0:	89 f8                	mov    %edi,%eax
  802aa2:	f7 f6                	div    %esi
  802aa4:	89 ea                	mov    %ebp,%edx
  802aa6:	83 c4 0c             	add    $0xc,%esp
  802aa9:	5e                   	pop    %esi
  802aaa:	5f                   	pop    %edi
  802aab:	5d                   	pop    %ebp
  802aac:	c3                   	ret    
  802aad:	8d 76 00             	lea    0x0(%esi),%esi
  802ab0:	39 e8                	cmp    %ebp,%eax
  802ab2:	77 24                	ja     802ad8 <__udivdi3+0x78>
  802ab4:	0f bd e8             	bsr    %eax,%ebp
  802ab7:	83 f5 1f             	xor    $0x1f,%ebp
  802aba:	75 3c                	jne    802af8 <__udivdi3+0x98>
  802abc:	8b 74 24 04          	mov    0x4(%esp),%esi
  802ac0:	39 34 24             	cmp    %esi,(%esp)
  802ac3:	0f 86 9f 00 00 00    	jbe    802b68 <__udivdi3+0x108>
  802ac9:	39 d0                	cmp    %edx,%eax
  802acb:	0f 82 97 00 00 00    	jb     802b68 <__udivdi3+0x108>
  802ad1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ad8:	31 d2                	xor    %edx,%edx
  802ada:	31 c0                	xor    %eax,%eax
  802adc:	83 c4 0c             	add    $0xc,%esp
  802adf:	5e                   	pop    %esi
  802ae0:	5f                   	pop    %edi
  802ae1:	5d                   	pop    %ebp
  802ae2:	c3                   	ret    
  802ae3:	90                   	nop
  802ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ae8:	89 f8                	mov    %edi,%eax
  802aea:	f7 f1                	div    %ecx
  802aec:	31 d2                	xor    %edx,%edx
  802aee:	83 c4 0c             	add    $0xc,%esp
  802af1:	5e                   	pop    %esi
  802af2:	5f                   	pop    %edi
  802af3:	5d                   	pop    %ebp
  802af4:	c3                   	ret    
  802af5:	8d 76 00             	lea    0x0(%esi),%esi
  802af8:	89 e9                	mov    %ebp,%ecx
  802afa:	8b 3c 24             	mov    (%esp),%edi
  802afd:	d3 e0                	shl    %cl,%eax
  802aff:	89 c6                	mov    %eax,%esi
  802b01:	b8 20 00 00 00       	mov    $0x20,%eax
  802b06:	29 e8                	sub    %ebp,%eax
  802b08:	89 c1                	mov    %eax,%ecx
  802b0a:	d3 ef                	shr    %cl,%edi
  802b0c:	89 e9                	mov    %ebp,%ecx
  802b0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802b12:	8b 3c 24             	mov    (%esp),%edi
  802b15:	09 74 24 08          	or     %esi,0x8(%esp)
  802b19:	89 d6                	mov    %edx,%esi
  802b1b:	d3 e7                	shl    %cl,%edi
  802b1d:	89 c1                	mov    %eax,%ecx
  802b1f:	89 3c 24             	mov    %edi,(%esp)
  802b22:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802b26:	d3 ee                	shr    %cl,%esi
  802b28:	89 e9                	mov    %ebp,%ecx
  802b2a:	d3 e2                	shl    %cl,%edx
  802b2c:	89 c1                	mov    %eax,%ecx
  802b2e:	d3 ef                	shr    %cl,%edi
  802b30:	09 d7                	or     %edx,%edi
  802b32:	89 f2                	mov    %esi,%edx
  802b34:	89 f8                	mov    %edi,%eax
  802b36:	f7 74 24 08          	divl   0x8(%esp)
  802b3a:	89 d6                	mov    %edx,%esi
  802b3c:	89 c7                	mov    %eax,%edi
  802b3e:	f7 24 24             	mull   (%esp)
  802b41:	39 d6                	cmp    %edx,%esi
  802b43:	89 14 24             	mov    %edx,(%esp)
  802b46:	72 30                	jb     802b78 <__udivdi3+0x118>
  802b48:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b4c:	89 e9                	mov    %ebp,%ecx
  802b4e:	d3 e2                	shl    %cl,%edx
  802b50:	39 c2                	cmp    %eax,%edx
  802b52:	73 05                	jae    802b59 <__udivdi3+0xf9>
  802b54:	3b 34 24             	cmp    (%esp),%esi
  802b57:	74 1f                	je     802b78 <__udivdi3+0x118>
  802b59:	89 f8                	mov    %edi,%eax
  802b5b:	31 d2                	xor    %edx,%edx
  802b5d:	e9 7a ff ff ff       	jmp    802adc <__udivdi3+0x7c>
  802b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b68:	31 d2                	xor    %edx,%edx
  802b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  802b6f:	e9 68 ff ff ff       	jmp    802adc <__udivdi3+0x7c>
  802b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b78:	8d 47 ff             	lea    -0x1(%edi),%eax
  802b7b:	31 d2                	xor    %edx,%edx
  802b7d:	83 c4 0c             	add    $0xc,%esp
  802b80:	5e                   	pop    %esi
  802b81:	5f                   	pop    %edi
  802b82:	5d                   	pop    %ebp
  802b83:	c3                   	ret    
  802b84:	66 90                	xchg   %ax,%ax
  802b86:	66 90                	xchg   %ax,%ax
  802b88:	66 90                	xchg   %ax,%ax
  802b8a:	66 90                	xchg   %ax,%ax
  802b8c:	66 90                	xchg   %ax,%ax
  802b8e:	66 90                	xchg   %ax,%ax

00802b90 <__umoddi3>:
  802b90:	55                   	push   %ebp
  802b91:	57                   	push   %edi
  802b92:	56                   	push   %esi
  802b93:	83 ec 14             	sub    $0x14,%esp
  802b96:	8b 44 24 28          	mov    0x28(%esp),%eax
  802b9a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802b9e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802ba2:	89 c7                	mov    %eax,%edi
  802ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ba8:	8b 44 24 30          	mov    0x30(%esp),%eax
  802bac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802bb0:	89 34 24             	mov    %esi,(%esp)
  802bb3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bb7:	85 c0                	test   %eax,%eax
  802bb9:	89 c2                	mov    %eax,%edx
  802bbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802bbf:	75 17                	jne    802bd8 <__umoddi3+0x48>
  802bc1:	39 fe                	cmp    %edi,%esi
  802bc3:	76 4b                	jbe    802c10 <__umoddi3+0x80>
  802bc5:	89 c8                	mov    %ecx,%eax
  802bc7:	89 fa                	mov    %edi,%edx
  802bc9:	f7 f6                	div    %esi
  802bcb:	89 d0                	mov    %edx,%eax
  802bcd:	31 d2                	xor    %edx,%edx
  802bcf:	83 c4 14             	add    $0x14,%esp
  802bd2:	5e                   	pop    %esi
  802bd3:	5f                   	pop    %edi
  802bd4:	5d                   	pop    %ebp
  802bd5:	c3                   	ret    
  802bd6:	66 90                	xchg   %ax,%ax
  802bd8:	39 f8                	cmp    %edi,%eax
  802bda:	77 54                	ja     802c30 <__umoddi3+0xa0>
  802bdc:	0f bd e8             	bsr    %eax,%ebp
  802bdf:	83 f5 1f             	xor    $0x1f,%ebp
  802be2:	75 5c                	jne    802c40 <__umoddi3+0xb0>
  802be4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802be8:	39 3c 24             	cmp    %edi,(%esp)
  802beb:	0f 87 e7 00 00 00    	ja     802cd8 <__umoddi3+0x148>
  802bf1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802bf5:	29 f1                	sub    %esi,%ecx
  802bf7:	19 c7                	sbb    %eax,%edi
  802bf9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bfd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802c01:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c05:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c09:	83 c4 14             	add    $0x14,%esp
  802c0c:	5e                   	pop    %esi
  802c0d:	5f                   	pop    %edi
  802c0e:	5d                   	pop    %ebp
  802c0f:	c3                   	ret    
  802c10:	85 f6                	test   %esi,%esi
  802c12:	89 f5                	mov    %esi,%ebp
  802c14:	75 0b                	jne    802c21 <__umoddi3+0x91>
  802c16:	b8 01 00 00 00       	mov    $0x1,%eax
  802c1b:	31 d2                	xor    %edx,%edx
  802c1d:	f7 f6                	div    %esi
  802c1f:	89 c5                	mov    %eax,%ebp
  802c21:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c25:	31 d2                	xor    %edx,%edx
  802c27:	f7 f5                	div    %ebp
  802c29:	89 c8                	mov    %ecx,%eax
  802c2b:	f7 f5                	div    %ebp
  802c2d:	eb 9c                	jmp    802bcb <__umoddi3+0x3b>
  802c2f:	90                   	nop
  802c30:	89 c8                	mov    %ecx,%eax
  802c32:	89 fa                	mov    %edi,%edx
  802c34:	83 c4 14             	add    $0x14,%esp
  802c37:	5e                   	pop    %esi
  802c38:	5f                   	pop    %edi
  802c39:	5d                   	pop    %ebp
  802c3a:	c3                   	ret    
  802c3b:	90                   	nop
  802c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c40:	8b 04 24             	mov    (%esp),%eax
  802c43:	be 20 00 00 00       	mov    $0x20,%esi
  802c48:	89 e9                	mov    %ebp,%ecx
  802c4a:	29 ee                	sub    %ebp,%esi
  802c4c:	d3 e2                	shl    %cl,%edx
  802c4e:	89 f1                	mov    %esi,%ecx
  802c50:	d3 e8                	shr    %cl,%eax
  802c52:	89 e9                	mov    %ebp,%ecx
  802c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c58:	8b 04 24             	mov    (%esp),%eax
  802c5b:	09 54 24 04          	or     %edx,0x4(%esp)
  802c5f:	89 fa                	mov    %edi,%edx
  802c61:	d3 e0                	shl    %cl,%eax
  802c63:	89 f1                	mov    %esi,%ecx
  802c65:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c69:	8b 44 24 10          	mov    0x10(%esp),%eax
  802c6d:	d3 ea                	shr    %cl,%edx
  802c6f:	89 e9                	mov    %ebp,%ecx
  802c71:	d3 e7                	shl    %cl,%edi
  802c73:	89 f1                	mov    %esi,%ecx
  802c75:	d3 e8                	shr    %cl,%eax
  802c77:	89 e9                	mov    %ebp,%ecx
  802c79:	09 f8                	or     %edi,%eax
  802c7b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802c7f:	f7 74 24 04          	divl   0x4(%esp)
  802c83:	d3 e7                	shl    %cl,%edi
  802c85:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802c89:	89 d7                	mov    %edx,%edi
  802c8b:	f7 64 24 08          	mull   0x8(%esp)
  802c8f:	39 d7                	cmp    %edx,%edi
  802c91:	89 c1                	mov    %eax,%ecx
  802c93:	89 14 24             	mov    %edx,(%esp)
  802c96:	72 2c                	jb     802cc4 <__umoddi3+0x134>
  802c98:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802c9c:	72 22                	jb     802cc0 <__umoddi3+0x130>
  802c9e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ca2:	29 c8                	sub    %ecx,%eax
  802ca4:	19 d7                	sbb    %edx,%edi
  802ca6:	89 e9                	mov    %ebp,%ecx
  802ca8:	89 fa                	mov    %edi,%edx
  802caa:	d3 e8                	shr    %cl,%eax
  802cac:	89 f1                	mov    %esi,%ecx
  802cae:	d3 e2                	shl    %cl,%edx
  802cb0:	89 e9                	mov    %ebp,%ecx
  802cb2:	d3 ef                	shr    %cl,%edi
  802cb4:	09 d0                	or     %edx,%eax
  802cb6:	89 fa                	mov    %edi,%edx
  802cb8:	83 c4 14             	add    $0x14,%esp
  802cbb:	5e                   	pop    %esi
  802cbc:	5f                   	pop    %edi
  802cbd:	5d                   	pop    %ebp
  802cbe:	c3                   	ret    
  802cbf:	90                   	nop
  802cc0:	39 d7                	cmp    %edx,%edi
  802cc2:	75 da                	jne    802c9e <__umoddi3+0x10e>
  802cc4:	8b 14 24             	mov    (%esp),%edx
  802cc7:	89 c1                	mov    %eax,%ecx
  802cc9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802ccd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802cd1:	eb cb                	jmp    802c9e <__umoddi3+0x10e>
  802cd3:	90                   	nop
  802cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802cd8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802cdc:	0f 82 0f ff ff ff    	jb     802bf1 <__umoddi3+0x61>
  802ce2:	e9 1a ff ff ff       	jmp    802c01 <__umoddi3+0x71>
