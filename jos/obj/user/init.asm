
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 d5 03 00 00       	call   800406 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80004b:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800050:	ba 00 00 00 00       	mov    $0x0,%edx
  800055:	eb 0c                	jmp    800063 <sum+0x23>
		tot ^= i * s[i];
  800057:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80005b:	0f af ca             	imul   %edx,%ecx
  80005e:	31 c8                	xor    %ecx,%eax
	for (i = 0; i < n; i++)
  800060:	83 c2 01             	add    $0x1,%edx
  800063:	39 da                	cmp    %ebx,%edx
  800065:	7c f0                	jl     800057 <sum+0x17>
	return tot;
}
  800067:	5b                   	pop    %ebx
  800068:	5e                   	pop    %esi
  800069:	5d                   	pop    %ebp
  80006a:	c3                   	ret    

0080006b <umain>:

void
umain(int argc, char **argv)
{
  80006b:	55                   	push   %ebp
  80006c:	89 e5                	mov    %esp,%ebp
  80006e:	57                   	push   %edi
  80006f:	56                   	push   %esi
  800070:	53                   	push   %ebx
  800071:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800077:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80007a:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800081:	e8 da 04 00 00       	call   800560 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800086:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80008d:	00 
  80008e:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800095:	e8 a6 ff ff ff       	call   800040 <sum>
  80009a:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80009f:	74 1a                	je     8000bb <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  8000a1:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  8000a8:	00 
  8000a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ad:	c7 04 24 a8 28 80 00 	movl   $0x8028a8,(%esp)
  8000b4:	e8 a7 04 00 00       	call   800560 <cprintf>
  8000b9:	eb 0c                	jmp    8000c7 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000bb:	c7 04 24 ef 27 80 00 	movl   $0x8027ef,(%esp)
  8000c2:	e8 99 04 00 00       	call   800560 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c7:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000ce:	00 
  8000cf:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000d6:	e8 65 ff ff ff       	call   800040 <sum>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	74 12                	je     8000f1 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e3:	c7 04 24 e4 28 80 00 	movl   $0x8028e4,(%esp)
  8000ea:	e8 71 04 00 00       	call   800560 <cprintf>
  8000ef:	eb 0c                	jmp    8000fd <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000f1:	c7 04 24 06 28 80 00 	movl   $0x802806,(%esp)
  8000f8:	e8 63 04 00 00       	call   800560 <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000fd:	c7 44 24 04 1c 28 80 	movl   $0x80281c,0x4(%esp)
  800104:	00 
  800105:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80010b:	89 04 24             	mov    %eax,(%esp)
  80010e:	e8 94 0a 00 00       	call   800ba7 <strcat>
	for (i = 0; i < argc; i++) {
  800113:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800118:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	for (i = 0; i < argc; i++) {
  80011e:	eb 32                	jmp    800152 <umain+0xe7>
		strcat(args, " '");
  800120:	c7 44 24 04 28 28 80 	movl   $0x802828,0x4(%esp)
  800127:	00 
  800128:	89 34 24             	mov    %esi,(%esp)
  80012b:	e8 77 0a 00 00       	call   800ba7 <strcat>
		strcat(args, argv[i]);
  800130:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800133:	89 44 24 04          	mov    %eax,0x4(%esp)
  800137:	89 34 24             	mov    %esi,(%esp)
  80013a:	e8 68 0a 00 00       	call   800ba7 <strcat>
		strcat(args, "'");
  80013f:	c7 44 24 04 29 28 80 	movl   $0x802829,0x4(%esp)
  800146:	00 
  800147:	89 34 24             	mov    %esi,(%esp)
  80014a:	e8 58 0a 00 00       	call   800ba7 <strcat>
	for (i = 0; i < argc; i++) {
  80014f:	83 c3 01             	add    $0x1,%ebx
  800152:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800155:	7c c9                	jl     800120 <umain+0xb5>
	}
	cprintf("%s\n", args);
  800157:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	c7 04 24 2b 28 80 00 	movl   $0x80282b,(%esp)
  800168:	e8 f3 03 00 00       	call   800560 <cprintf>

	cprintf("init: running sh\n");
  80016d:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  800174:	e8 e7 03 00 00       	call   800560 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800179:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800180:	e8 2d 12 00 00       	call   8013b2 <close>
	if ((r = opencons()) < 0)
  800185:	e8 21 02 00 00       	call   8003ab <opencons>
  80018a:	85 c0                	test   %eax,%eax
  80018c:	79 20                	jns    8001ae <umain+0x143>
		panic("opencons: %e", r);
  80018e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800192:	c7 44 24 08 41 28 80 	movl   $0x802841,0x8(%esp)
  800199:	00 
  80019a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8001a1:	00 
  8001a2:	c7 04 24 4e 28 80 00 	movl   $0x80284e,(%esp)
  8001a9:	e8 b9 02 00 00       	call   800467 <_panic>
	if (r != 0)
  8001ae:	85 c0                	test   %eax,%eax
  8001b0:	74 20                	je     8001d2 <umain+0x167>
		panic("first opencons used fd %d", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 5a 28 80 	movl   $0x80285a,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 4e 28 80 00 	movl   $0x80284e,(%esp)
  8001cd:	e8 95 02 00 00       	call   800467 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001e1:	e8 21 12 00 00       	call   801407 <dup>
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	79 20                	jns    80020a <umain+0x19f>
		panic("dup: %e", r);
  8001ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ee:	c7 44 24 08 74 28 80 	movl   $0x802874,0x8(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001fd:	00 
  8001fe:	c7 04 24 4e 28 80 00 	movl   $0x80284e,(%esp)
  800205:	e8 5d 02 00 00       	call   800467 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  80020a:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  800211:	e8 4a 03 00 00       	call   800560 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800216:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80021d:	00 
  80021e:	c7 44 24 04 90 28 80 	movl   $0x802890,0x4(%esp)
  800225:	00 
  800226:	c7 04 24 8f 28 80 00 	movl   $0x80288f,(%esp)
  80022d:	e8 6f 1d 00 00       	call   801fa1 <spawnl>
		if (r < 0) {
  800232:	85 c0                	test   %eax,%eax
  800234:	79 12                	jns    800248 <umain+0x1dd>
			cprintf("init: spawn sh: %e\n", r);
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	c7 04 24 93 28 80 00 	movl   $0x802893,(%esp)
  800241:	e8 1a 03 00 00       	call   800560 <cprintf>
			continue;
  800246:	eb c2                	jmp    80020a <umain+0x19f>
		}
		wait(r);
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 4a 21 00 00       	call   80239a <wait>
  800250:	eb b8                	jmp    80020a <umain+0x19f>
  800252:	66 90                	xchg   %ax,%ax
  800254:	66 90                	xchg   %ax,%ax
  800256:	66 90                	xchg   %ax,%ax
  800258:	66 90                	xchg   %ax,%ax
  80025a:	66 90                	xchg   %ax,%ax
  80025c:	66 90                	xchg   %ax,%ax
  80025e:	66 90                	xchg   %ax,%ax

00800260 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800270:	c7 44 24 04 13 29 80 	movl   $0x802913,0x4(%esp)
  800277:	00 
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 04 09 00 00       	call   800b87 <strcpy>
	return 0;
}
  800283:	b8 00 00 00 00       	mov    $0x0,%eax
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <devcons_write>:
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  800296:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80029b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8002a1:	eb 31                	jmp    8002d4 <devcons_write+0x4a>
		m = n - tot;
  8002a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8002a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8002a8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  8002ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8002b0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8002b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002b7:	03 45 0c             	add    0xc(%ebp),%eax
  8002ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002be:	89 3c 24             	mov    %edi,(%esp)
  8002c1:	e8 5e 0a 00 00       	call   800d24 <memmove>
		sys_cputs(buf, m);
  8002c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ca:	89 3c 24             	mov    %edi,(%esp)
  8002cd:	e8 04 0c 00 00       	call   800ed6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8002d2:	01 f3                	add    %esi,%ebx
  8002d4:	89 d8                	mov    %ebx,%eax
  8002d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8002d9:	72 c8                	jb     8002a3 <devcons_write+0x19>
}
  8002db:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <devcons_read>:
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  8002ec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8002f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002f5:	75 07                	jne    8002fe <devcons_read+0x18>
  8002f7:	eb 2a                	jmp    800323 <devcons_read+0x3d>
		sys_yield();
  8002f9:	e8 86 0c 00 00       	call   800f84 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8002fe:	66 90                	xchg   %ax,%ax
  800300:	e8 ef 0b 00 00       	call   800ef4 <sys_cgetc>
  800305:	85 c0                	test   %eax,%eax
  800307:	74 f0                	je     8002f9 <devcons_read+0x13>
	if (c < 0)
  800309:	85 c0                	test   %eax,%eax
  80030b:	78 16                	js     800323 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80030d:	83 f8 04             	cmp    $0x4,%eax
  800310:	74 0c                	je     80031e <devcons_read+0x38>
	*(char*)vbuf = c;
  800312:	8b 55 0c             	mov    0xc(%ebp),%edx
  800315:	88 02                	mov    %al,(%edx)
	return 1;
  800317:	b8 01 00 00 00       	mov    $0x1,%eax
  80031c:	eb 05                	jmp    800323 <devcons_read+0x3d>
		return 0;
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <cputchar>:
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800331:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800338:	00 
  800339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	e8 92 0b 00 00       	call   800ed6 <sys_cputs>
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <getchar>:
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80034c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800353:	00 
  800354:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800362:	e8 ae 11 00 00       	call   801515 <read>
	if (r < 0)
  800367:	85 c0                	test   %eax,%eax
  800369:	78 0f                	js     80037a <getchar+0x34>
	if (r < 1)
  80036b:	85 c0                	test   %eax,%eax
  80036d:	7e 06                	jle    800375 <getchar+0x2f>
	return c;
  80036f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800373:	eb 05                	jmp    80037a <getchar+0x34>
		return -E_EOF;
  800375:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <iscons>:
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800385:	89 44 24 04          	mov    %eax,0x4(%esp)
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 f2 0e 00 00       	call   801286 <fd_lookup>
  800394:	85 c0                	test   %eax,%eax
  800396:	78 11                	js     8003a9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  800398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80039b:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003a1:	39 10                	cmp    %edx,(%eax)
  8003a3:	0f 94 c0             	sete   %al
  8003a6:	0f b6 c0             	movzbl %al,%eax
}
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <opencons>:
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8003b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 7b 0e 00 00       	call   801237 <fd_alloc>
		return r;
  8003bc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	78 40                	js     800402 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003c9:	00 
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003d8:	e8 c6 0b 00 00       	call   800fa3 <sys_page_alloc>
		return r;
  8003dd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	78 1f                	js     800402 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8003e3:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 10 0e 00 00       	call   801210 <fd2num>
  800400:	89 c2                	mov    %eax,%edx
}
  800402:	89 d0                	mov    %edx,%eax
  800404:	c9                   	leave  
  800405:	c3                   	ret    

00800406 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	56                   	push   %esi
  80040a:	53                   	push   %ebx
  80040b:	83 ec 10             	sub    $0x10,%esp
  80040e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800411:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800414:	e8 4c 0b 00 00       	call   800f65 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800419:	25 ff 03 00 00       	and    $0x3ff,%eax
  80041e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800421:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800426:	a3 90 67 80 00       	mov    %eax,0x806790
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80042b:	85 db                	test   %ebx,%ebx
  80042d:	7e 07                	jle    800436 <libmain+0x30>
		binaryname = argv[0];
  80042f:	8b 06                	mov    (%esi),%eax
  800431:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  800436:	89 74 24 04          	mov    %esi,0x4(%esp)
  80043a:	89 1c 24             	mov    %ebx,(%esp)
  80043d:	e8 29 fc ff ff       	call   80006b <umain>

	// exit gracefully
	exit();
  800442:	e8 07 00 00 00       	call   80044e <exit>
}
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	5b                   	pop    %ebx
  80044b:	5e                   	pop    %esi
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    

0080044e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800454:	e8 8c 0f 00 00       	call   8013e5 <close_all>
	sys_env_destroy(0);
  800459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800460:	e8 ae 0a 00 00       	call   800f13 <sys_env_destroy>
}
  800465:	c9                   	leave  
  800466:	c3                   	ret    

00800467 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	56                   	push   %esi
  80046b:	53                   	push   %ebx
  80046c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80046f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800472:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  800478:	e8 e8 0a 00 00       	call   800f65 <sys_getenvid>
  80047d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800480:	89 54 24 10          	mov    %edx,0x10(%esp)
  800484:	8b 55 08             	mov    0x8(%ebp),%edx
  800487:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80048f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800493:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
  80049a:	e8 c1 00 00 00       	call   800560 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	e8 51 00 00 00       	call   8004ff <vcprintf>
	cprintf("\n");
  8004ae:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  8004b5:	e8 a6 00 00 00       	call   800560 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ba:	cc                   	int3   
  8004bb:	eb fd                	jmp    8004ba <_panic+0x53>

008004bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	53                   	push   %ebx
  8004c1:	83 ec 14             	sub    $0x14,%esp
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004c7:	8b 13                	mov    (%ebx),%edx
  8004c9:	8d 42 01             	lea    0x1(%edx),%eax
  8004cc:	89 03                	mov    %eax,(%ebx)
  8004ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004da:	75 19                	jne    8004f5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004dc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004e3:	00 
  8004e4:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e7:	89 04 24             	mov    %eax,(%esp)
  8004ea:	e8 e7 09 00 00       	call   800ed6 <sys_cputs>
		b->idx = 0;
  8004ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004f5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004f9:	83 c4 14             	add    $0x14,%esp
  8004fc:	5b                   	pop    %ebx
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800508:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80050f:	00 00 00 
	b.cnt = 0;
  800512:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800519:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80051c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800523:	8b 45 08             	mov    0x8(%ebp),%eax
  800526:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800530:	89 44 24 04          	mov    %eax,0x4(%esp)
  800534:	c7 04 24 bd 04 80 00 	movl   $0x8004bd,(%esp)
  80053b:	e8 ae 01 00 00       	call   8006ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800540:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800546:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 7e 09 00 00       	call   800ed6 <sys_cputs>

	return b.cnt;
}
  800558:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800566:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	8b 45 08             	mov    0x8(%ebp),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	e8 87 ff ff ff       	call   8004ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800578:	c9                   	leave  
  800579:	c3                   	ret    
  80057a:	66 90                	xchg   %ax,%ax
  80057c:	66 90                	xchg   %ax,%ax
  80057e:	66 90                	xchg   %ax,%ax

00800580 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 3c             	sub    $0x3c,%esp
  800589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058c:	89 d7                	mov    %edx,%edi
  80058e:	8b 45 08             	mov    0x8(%ebp),%eax
  800591:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	89 c3                	mov    %eax,%ebx
  800599:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80059c:	8b 45 10             	mov    0x10(%ebp),%eax
  80059f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ad:	39 d9                	cmp    %ebx,%ecx
  8005af:	72 05                	jb     8005b6 <printnum+0x36>
  8005b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005b4:	77 69                	ja     80061f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005bd:	83 ee 01             	sub    $0x1,%esi
  8005c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005d0:	89 c3                	mov    %eax,%ebx
  8005d2:	89 d6                	mov    %edx,%esi
  8005d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8005de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8005e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e5:	89 04 24             	mov    %eax,(%esp)
  8005e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ef:	e8 5c 1f 00 00       	call   802550 <__udivdi3>
  8005f4:	89 d9                	mov    %ebx,%ecx
  8005f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	89 54 24 04          	mov    %edx,0x4(%esp)
  800605:	89 fa                	mov    %edi,%edx
  800607:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060a:	e8 71 ff ff ff       	call   800580 <printnum>
  80060f:	eb 1b                	jmp    80062c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800611:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800615:	8b 45 18             	mov    0x18(%ebp),%eax
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	ff d3                	call   *%ebx
  80061d:	eb 03                	jmp    800622 <printnum+0xa2>
  80061f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800622:	83 ee 01             	sub    $0x1,%esi
  800625:	85 f6                	test   %esi,%esi
  800627:	7f e8                	jg     800611 <printnum+0x91>
  800629:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80062c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800630:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800634:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800637:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800642:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	e8 2c 20 00 00       	call   802680 <__umoddi3>
  800654:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800658:	0f be 80 4f 29 80 00 	movsbl 0x80294f(%eax),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800665:	ff d0                	call   *%eax
}
  800667:	83 c4 3c             	add    $0x3c,%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5f                   	pop    %edi
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800672:	83 fa 01             	cmp    $0x1,%edx
  800675:	7e 0e                	jle    800685 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800677:	8b 10                	mov    (%eax),%edx
  800679:	8d 4a 08             	lea    0x8(%edx),%ecx
  80067c:	89 08                	mov    %ecx,(%eax)
  80067e:	8b 02                	mov    (%edx),%eax
  800680:	8b 52 04             	mov    0x4(%edx),%edx
  800683:	eb 22                	jmp    8006a7 <getuint+0x38>
	else if (lflag)
  800685:	85 d2                	test   %edx,%edx
  800687:	74 10                	je     800699 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800689:	8b 10                	mov    (%eax),%edx
  80068b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068e:	89 08                	mov    %ecx,(%eax)
  800690:	8b 02                	mov    (%edx),%eax
  800692:	ba 00 00 00 00       	mov    $0x0,%edx
  800697:	eb 0e                	jmp    8006a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069e:	89 08                	mov    %ecx,(%eax)
  8006a0:	8b 02                	mov    (%edx),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8006b8:	73 0a                	jae    8006c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006bd:	89 08                	mov    %ecx,(%eax)
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	88 02                	mov    %al,(%edx)
}
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <printfmt>:
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	e8 02 00 00 00       	call   8006ee <vprintfmt>
}
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <vprintfmt>:
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	57                   	push   %edi
  8006f2:	56                   	push   %esi
  8006f3:	53                   	push   %ebx
  8006f4:	83 ec 3c             	sub    $0x3c,%esp
  8006f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006fd:	eb 1f                	jmp    80071e <vprintfmt+0x30>
			if (ch == '\0'){
  8006ff:	85 c0                	test   %eax,%eax
  800701:	75 0f                	jne    800712 <vprintfmt+0x24>
				color = 0x0100;
  800703:	c7 05 00 50 80 00 00 	movl   $0x100,0x805000
  80070a:	01 00 00 
  80070d:	e9 b3 03 00 00       	jmp    800ac5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071c:	89 f3                	mov    %esi,%ebx
  80071e:	8d 73 01             	lea    0x1(%ebx),%esi
  800721:	0f b6 03             	movzbl (%ebx),%eax
  800724:	83 f8 25             	cmp    $0x25,%eax
  800727:	75 d6                	jne    8006ff <vprintfmt+0x11>
  800729:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80072d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800734:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80073b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800742:	ba 00 00 00 00       	mov    $0x0,%edx
  800747:	eb 1d                	jmp    800766 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800749:	89 de                	mov    %ebx,%esi
			padc = '-';
  80074b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80074f:	eb 15                	jmp    800766 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800751:	89 de                	mov    %ebx,%esi
			padc = '0';
  800753:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800757:	eb 0d                	jmp    800766 <vprintfmt+0x78>
				width = precision, precision = -1;
  800759:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80075c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80075f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800766:	8d 5e 01             	lea    0x1(%esi),%ebx
  800769:	0f b6 0e             	movzbl (%esi),%ecx
  80076c:	0f b6 c1             	movzbl %cl,%eax
  80076f:	83 e9 23             	sub    $0x23,%ecx
  800772:	80 f9 55             	cmp    $0x55,%cl
  800775:	0f 87 2a 03 00 00    	ja     800aa5 <vprintfmt+0x3b7>
  80077b:	0f b6 c9             	movzbl %cl,%ecx
  80077e:	ff 24 8d a0 2a 80 00 	jmp    *0x802aa0(,%ecx,4)
  800785:	89 de                	mov    %ebx,%esi
  800787:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80078c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80078f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800793:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800796:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800799:	83 fb 09             	cmp    $0x9,%ebx
  80079c:	77 36                	ja     8007d4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80079e:	83 c6 01             	add    $0x1,%esi
			}
  8007a1:	eb e9                	jmp    80078c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8007a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007b1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8007b3:	eb 22                	jmp    8007d7 <vprintfmt+0xe9>
  8007b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007b8:	85 c9                	test   %ecx,%ecx
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bf:	0f 49 c1             	cmovns %ecx,%eax
  8007c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007c5:	89 de                	mov    %ebx,%esi
  8007c7:	eb 9d                	jmp    800766 <vprintfmt+0x78>
  8007c9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8007cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007d2:	eb 92                	jmp    800766 <vprintfmt+0x78>
  8007d4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8007d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007db:	79 89                	jns    800766 <vprintfmt+0x78>
  8007dd:	e9 77 ff ff ff       	jmp    800759 <vprintfmt+0x6b>
			lflag++;
  8007e2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8007e5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8007e7:	e9 7a ff ff ff       	jmp    800766 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8d 50 04             	lea    0x4(%eax),%edx
  8007f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f9:	8b 00                	mov    (%eax),%eax
  8007fb:	89 04 24             	mov    %eax,(%esp)
  8007fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800801:	e9 18 ff ff ff       	jmp    80071e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 00                	mov    (%eax),%eax
  800811:	99                   	cltd   
  800812:	31 d0                	xor    %edx,%eax
  800814:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800816:	83 f8 0f             	cmp    $0xf,%eax
  800819:	7f 0b                	jg     800826 <vprintfmt+0x138>
  80081b:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  800822:	85 d2                	test   %edx,%edx
  800824:	75 20                	jne    800846 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800826:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082a:	c7 44 24 08 67 29 80 	movl   $0x802967,0x8(%esp)
  800831:	00 
  800832:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	89 04 24             	mov    %eax,(%esp)
  80083c:	e8 85 fe ff ff       	call   8006c6 <printfmt>
  800841:	e9 d8 fe ff ff       	jmp    80071e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800846:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80084a:	c7 44 24 08 5a 2d 80 	movl   $0x802d5a,0x8(%esp)
  800851:	00 
  800852:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	89 04 24             	mov    %eax,(%esp)
  80085c:	e8 65 fe ff ff       	call   8006c6 <printfmt>
  800861:	e9 b8 fe ff ff       	jmp    80071e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800866:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800869:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80086c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8d 50 04             	lea    0x4(%eax),%edx
  800875:	89 55 14             	mov    %edx,0x14(%ebp)
  800878:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80087a:	85 f6                	test   %esi,%esi
  80087c:	b8 60 29 80 00       	mov    $0x802960,%eax
  800881:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800884:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800888:	0f 84 97 00 00 00    	je     800925 <vprintfmt+0x237>
  80088e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800892:	0f 8e 9b 00 00 00    	jle    800933 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800898:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80089c:	89 34 24             	mov    %esi,(%esp)
  80089f:	e8 c4 02 00 00       	call   800b68 <strnlen>
  8008a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008a7:	29 c2                	sub    %eax,%edx
  8008a9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8008ac:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008b3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008bc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8008be:	eb 0f                	jmp    8008cf <vprintfmt+0x1e1>
					putch(padc, putdat);
  8008c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cc:	83 eb 01             	sub    $0x1,%ebx
  8008cf:	85 db                	test   %ebx,%ebx
  8008d1:	7f ed                	jg     8008c0 <vprintfmt+0x1d2>
  8008d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e0:	0f 49 c2             	cmovns %edx,%eax
  8008e3:	29 c2                	sub    %eax,%edx
  8008e5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8008e8:	89 d7                	mov    %edx,%edi
  8008ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8008ed:	eb 50                	jmp    80093f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8008ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008f3:	74 1e                	je     800913 <vprintfmt+0x225>
  8008f5:	0f be d2             	movsbl %dl,%edx
  8008f8:	83 ea 20             	sub    $0x20,%edx
  8008fb:	83 fa 5e             	cmp    $0x5e,%edx
  8008fe:	76 13                	jbe    800913 <vprintfmt+0x225>
					putch('?', putdat);
  800900:	8b 45 0c             	mov    0xc(%ebp),%eax
  800903:	89 44 24 04          	mov    %eax,0x4(%esp)
  800907:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	eb 0d                	jmp    800920 <vprintfmt+0x232>
					putch(ch, putdat);
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
  800916:	89 54 24 04          	mov    %edx,0x4(%esp)
  80091a:	89 04 24             	mov    %eax,(%esp)
  80091d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800920:	83 ef 01             	sub    $0x1,%edi
  800923:	eb 1a                	jmp    80093f <vprintfmt+0x251>
  800925:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800928:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80092b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80092e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800931:	eb 0c                	jmp    80093f <vprintfmt+0x251>
  800933:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800936:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800939:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80093c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80093f:	83 c6 01             	add    $0x1,%esi
  800942:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800946:	0f be c2             	movsbl %dl,%eax
  800949:	85 c0                	test   %eax,%eax
  80094b:	74 27                	je     800974 <vprintfmt+0x286>
  80094d:	85 db                	test   %ebx,%ebx
  80094f:	78 9e                	js     8008ef <vprintfmt+0x201>
  800951:	83 eb 01             	sub    $0x1,%ebx
  800954:	79 99                	jns    8008ef <vprintfmt+0x201>
  800956:	89 f8                	mov    %edi,%eax
  800958:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80095b:	8b 75 08             	mov    0x8(%ebp),%esi
  80095e:	89 c3                	mov    %eax,%ebx
  800960:	eb 1a                	jmp    80097c <vprintfmt+0x28e>
				putch(' ', putdat);
  800962:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800966:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80096d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80096f:	83 eb 01             	sub    $0x1,%ebx
  800972:	eb 08                	jmp    80097c <vprintfmt+0x28e>
  800974:	89 fb                	mov    %edi,%ebx
  800976:	8b 75 08             	mov    0x8(%ebp),%esi
  800979:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80097c:	85 db                	test   %ebx,%ebx
  80097e:	7f e2                	jg     800962 <vprintfmt+0x274>
  800980:	89 75 08             	mov    %esi,0x8(%ebp)
  800983:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800986:	e9 93 fd ff ff       	jmp    80071e <vprintfmt+0x30>
	if (lflag >= 2)
  80098b:	83 fa 01             	cmp    $0x1,%edx
  80098e:	7e 16                	jle    8009a6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800990:	8b 45 14             	mov    0x14(%ebp),%eax
  800993:	8d 50 08             	lea    0x8(%eax),%edx
  800996:	89 55 14             	mov    %edx,0x14(%ebp)
  800999:	8b 50 04             	mov    0x4(%eax),%edx
  80099c:	8b 00                	mov    (%eax),%eax
  80099e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009a4:	eb 32                	jmp    8009d8 <vprintfmt+0x2ea>
	else if (lflag)
  8009a6:	85 d2                	test   %edx,%edx
  8009a8:	74 18                	je     8009c2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8009aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ad:	8d 50 04             	lea    0x4(%eax),%edx
  8009b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b3:	8b 30                	mov    (%eax),%esi
  8009b5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009b8:	89 f0                	mov    %esi,%eax
  8009ba:	c1 f8 1f             	sar    $0x1f,%eax
  8009bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009c0:	eb 16                	jmp    8009d8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8d 50 04             	lea    0x4(%eax),%edx
  8009c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cb:	8b 30                	mov    (%eax),%esi
  8009cd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009d0:	89 f0                	mov    %esi,%eax
  8009d2:	c1 f8 1f             	sar    $0x1f,%eax
  8009d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8009d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8009de:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8009e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009e7:	0f 89 80 00 00 00    	jns    800a6d <vprintfmt+0x37f>
				putch('-', putdat);
  8009ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009f8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a01:	f7 d8                	neg    %eax
  800a03:	83 d2 00             	adc    $0x0,%edx
  800a06:	f7 da                	neg    %edx
			base = 10;
  800a08:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a0d:	eb 5e                	jmp    800a6d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800a0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a12:	e8 58 fc ff ff       	call   80066f <getuint>
			base = 10;
  800a17:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a1c:	eb 4f                	jmp    800a6d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800a1e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a21:	e8 49 fc ff ff       	call   80066f <getuint>
            base = 8;
  800a26:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  800a2b:	eb 40                	jmp    800a6d <vprintfmt+0x37f>
			putch('0', putdat);
  800a2d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a31:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a38:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a3b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a3f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a46:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800a49:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4c:	8d 50 04             	lea    0x4(%eax),%edx
  800a4f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800a52:	8b 00                	mov    (%eax),%eax
  800a54:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800a59:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a5e:	eb 0d                	jmp    800a6d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800a60:	8d 45 14             	lea    0x14(%ebp),%eax
  800a63:	e8 07 fc ff ff       	call   80066f <getuint>
			base = 16;
  800a68:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800a6d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800a71:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a75:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a78:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a7c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a80:	89 04 24             	mov    %eax,(%esp)
  800a83:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a87:	89 fa                	mov    %edi,%edx
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	e8 ef fa ff ff       	call   800580 <printnum>
			break;
  800a91:	e9 88 fc ff ff       	jmp    80071e <vprintfmt+0x30>
			putch(ch, putdat);
  800a96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9a:	89 04 24             	mov    %eax,(%esp)
  800a9d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800aa0:	e9 79 fc ff ff       	jmp    80071e <vprintfmt+0x30>
			putch('%', putdat);
  800aa5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ab0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ab3:	89 f3                	mov    %esi,%ebx
  800ab5:	eb 03                	jmp    800aba <vprintfmt+0x3cc>
  800ab7:	83 eb 01             	sub    $0x1,%ebx
  800aba:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800abe:	75 f7                	jne    800ab7 <vprintfmt+0x3c9>
  800ac0:	e9 59 fc ff ff       	jmp    80071e <vprintfmt+0x30>
}
  800ac5:	83 c4 3c             	add    $0x3c,%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	83 ec 28             	sub    $0x28,%esp
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800adc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ae0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ae3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aea:	85 c0                	test   %eax,%eax
  800aec:	74 30                	je     800b1e <vsnprintf+0x51>
  800aee:	85 d2                	test   %edx,%edx
  800af0:	7e 2c                	jle    800b1e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800af2:	8b 45 14             	mov    0x14(%ebp),%eax
  800af5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af9:	8b 45 10             	mov    0x10(%ebp),%eax
  800afc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b00:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b07:	c7 04 24 a9 06 80 00 	movl   $0x8006a9,(%esp)
  800b0e:	e8 db fb ff ff       	call   8006ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b16:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b1c:	eb 05                	jmp    800b23 <vsnprintf+0x56>
		return -E_INVAL;
  800b1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b2b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b32:	8b 45 10             	mov    0x10(%ebp),%eax
  800b35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	89 04 24             	mov    %eax,(%esp)
  800b46:	e8 82 ff ff ff       	call   800acd <vsnprintf>
	va_end(ap);

	return rc;
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    
  800b4d:	66 90                	xchg   %ax,%ax
  800b4f:	90                   	nop

00800b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	eb 03                	jmp    800b60 <strlen+0x10>
		n++;
  800b5d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b64:	75 f7                	jne    800b5d <strlen+0xd>
	return n;
}
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	eb 03                	jmp    800b7b <strnlen+0x13>
		n++;
  800b78:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7b:	39 d0                	cmp    %edx,%eax
  800b7d:	74 06                	je     800b85 <strnlen+0x1d>
  800b7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b83:	75 f3                	jne    800b78 <strnlen+0x10>
	return n;
}
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	53                   	push   %ebx
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	83 c1 01             	add    $0x1,%ecx
  800b99:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b9d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ba0:	84 db                	test   %bl,%bl
  800ba2:	75 ef                	jne    800b93 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	53                   	push   %ebx
  800bab:	83 ec 08             	sub    $0x8,%esp
  800bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb1:	89 1c 24             	mov    %ebx,(%esp)
  800bb4:	e8 97 ff ff ff       	call   800b50 <strlen>
	strcpy(dst + len, src);
  800bb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc0:	01 d8                	add    %ebx,%eax
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	e8 bd ff ff ff       	call   800b87 <strcpy>
	return dst;
}
  800bca:	89 d8                	mov    %ebx,%eax
  800bcc:	83 c4 08             	add    $0x8,%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	8b 75 08             	mov    0x8(%ebp),%esi
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	89 f3                	mov    %esi,%ebx
  800bdf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be2:	89 f2                	mov    %esi,%edx
  800be4:	eb 0f                	jmp    800bf5 <strncpy+0x23>
		*dst++ = *src;
  800be6:	83 c2 01             	add    $0x1,%edx
  800be9:	0f b6 01             	movzbl (%ecx),%eax
  800bec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bef:	80 39 01             	cmpb   $0x1,(%ecx)
  800bf2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800bf5:	39 da                	cmp    %ebx,%edx
  800bf7:	75 ed                	jne    800be6 <strncpy+0x14>
	}
	return ret;
}
  800bf9:	89 f0                	mov    %esi,%eax
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 75 08             	mov    0x8(%ebp),%esi
  800c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c0d:	89 f0                	mov    %esi,%eax
  800c0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c13:	85 c9                	test   %ecx,%ecx
  800c15:	75 0b                	jne    800c22 <strlcpy+0x23>
  800c17:	eb 1d                	jmp    800c36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c19:	83 c0 01             	add    $0x1,%eax
  800c1c:	83 c2 01             	add    $0x1,%edx
  800c1f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800c22:	39 d8                	cmp    %ebx,%eax
  800c24:	74 0b                	je     800c31 <strlcpy+0x32>
  800c26:	0f b6 0a             	movzbl (%edx),%ecx
  800c29:	84 c9                	test   %cl,%cl
  800c2b:	75 ec                	jne    800c19 <strlcpy+0x1a>
  800c2d:	89 c2                	mov    %eax,%edx
  800c2f:	eb 02                	jmp    800c33 <strlcpy+0x34>
  800c31:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800c33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c36:	29 f0                	sub    %esi,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c45:	eb 06                	jmp    800c4d <strcmp+0x11>
		p++, q++;
  800c47:	83 c1 01             	add    $0x1,%ecx
  800c4a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800c4d:	0f b6 01             	movzbl (%ecx),%eax
  800c50:	84 c0                	test   %al,%al
  800c52:	74 04                	je     800c58 <strcmp+0x1c>
  800c54:	3a 02                	cmp    (%edx),%al
  800c56:	74 ef                	je     800c47 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c58:	0f b6 c0             	movzbl %al,%eax
  800c5b:	0f b6 12             	movzbl (%edx),%edx
  800c5e:	29 d0                	sub    %edx,%eax
}
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	53                   	push   %ebx
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6c:	89 c3                	mov    %eax,%ebx
  800c6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c71:	eb 06                	jmp    800c79 <strncmp+0x17>
		n--, p++, q++;
  800c73:	83 c0 01             	add    $0x1,%eax
  800c76:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c79:	39 d8                	cmp    %ebx,%eax
  800c7b:	74 15                	je     800c92 <strncmp+0x30>
  800c7d:	0f b6 08             	movzbl (%eax),%ecx
  800c80:	84 c9                	test   %cl,%cl
  800c82:	74 04                	je     800c88 <strncmp+0x26>
  800c84:	3a 0a                	cmp    (%edx),%cl
  800c86:	74 eb                	je     800c73 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c88:	0f b6 00             	movzbl (%eax),%eax
  800c8b:	0f b6 12             	movzbl (%edx),%edx
  800c8e:	29 d0                	sub    %edx,%eax
  800c90:	eb 05                	jmp    800c97 <strncmp+0x35>
		return 0;
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c97:	5b                   	pop    %ebx
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca4:	eb 07                	jmp    800cad <strchr+0x13>
		if (*s == c)
  800ca6:	38 ca                	cmp    %cl,%dl
  800ca8:	74 0f                	je     800cb9 <strchr+0x1f>
	for (; *s; s++)
  800caa:	83 c0 01             	add    $0x1,%eax
  800cad:	0f b6 10             	movzbl (%eax),%edx
  800cb0:	84 d2                	test   %dl,%dl
  800cb2:	75 f2                	jne    800ca6 <strchr+0xc>
			return (char *) s;
	return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc5:	eb 07                	jmp    800cce <strfind+0x13>
		if (*s == c)
  800cc7:	38 ca                	cmp    %cl,%dl
  800cc9:	74 0a                	je     800cd5 <strfind+0x1a>
	for (; *s; s++)
  800ccb:	83 c0 01             	add    $0x1,%eax
  800cce:	0f b6 10             	movzbl (%eax),%edx
  800cd1:	84 d2                	test   %dl,%dl
  800cd3:	75 f2                	jne    800cc7 <strfind+0xc>
			break;
	return (char *) s;
}
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ce3:	85 c9                	test   %ecx,%ecx
  800ce5:	74 36                	je     800d1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ce7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ced:	75 28                	jne    800d17 <memset+0x40>
  800cef:	f6 c1 03             	test   $0x3,%cl
  800cf2:	75 23                	jne    800d17 <memset+0x40>
		c &= 0xFF;
  800cf4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cf8:	89 d3                	mov    %edx,%ebx
  800cfa:	c1 e3 08             	shl    $0x8,%ebx
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	c1 e6 18             	shl    $0x18,%esi
  800d02:	89 d0                	mov    %edx,%eax
  800d04:	c1 e0 10             	shl    $0x10,%eax
  800d07:	09 f0                	or     %esi,%eax
  800d09:	09 c2                	or     %eax,%edx
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d0f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d12:	fc                   	cld    
  800d13:	f3 ab                	rep stos %eax,%es:(%edi)
  800d15:	eb 06                	jmp    800d1d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1a:	fc                   	cld    
  800d1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d1d:	89 f8                	mov    %edi,%eax
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d32:	39 c6                	cmp    %eax,%esi
  800d34:	73 35                	jae    800d6b <memmove+0x47>
  800d36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d39:	39 d0                	cmp    %edx,%eax
  800d3b:	73 2e                	jae    800d6b <memmove+0x47>
		s += n;
		d += n;
  800d3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d4a:	75 13                	jne    800d5f <memmove+0x3b>
  800d4c:	f6 c1 03             	test   $0x3,%cl
  800d4f:	75 0e                	jne    800d5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d51:	83 ef 04             	sub    $0x4,%edi
  800d54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d57:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d5a:	fd                   	std    
  800d5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d5d:	eb 09                	jmp    800d68 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d5f:	83 ef 01             	sub    $0x1,%edi
  800d62:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d65:	fd                   	std    
  800d66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d68:	fc                   	cld    
  800d69:	eb 1d                	jmp    800d88 <memmove+0x64>
  800d6b:	89 f2                	mov    %esi,%edx
  800d6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6f:	f6 c2 03             	test   $0x3,%dl
  800d72:	75 0f                	jne    800d83 <memmove+0x5f>
  800d74:	f6 c1 03             	test   $0x3,%cl
  800d77:	75 0a                	jne    800d83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d7c:	89 c7                	mov    %eax,%edi
  800d7e:	fc                   	cld    
  800d7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d81:	eb 05                	jmp    800d88 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800d83:	89 c7                	mov    %eax,%edi
  800d85:	fc                   	cld    
  800d86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d92:	8b 45 10             	mov    0x10(%ebp),%eax
  800d95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	89 04 24             	mov    %eax,(%esp)
  800da6:	e8 79 ff ff ff       	call   800d24 <memmove>
}
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    

00800dad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	89 d6                	mov    %edx,%esi
  800dba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbd:	eb 1a                	jmp    800dd9 <memcmp+0x2c>
		if (*s1 != *s2)
  800dbf:	0f b6 02             	movzbl (%edx),%eax
  800dc2:	0f b6 19             	movzbl (%ecx),%ebx
  800dc5:	38 d8                	cmp    %bl,%al
  800dc7:	74 0a                	je     800dd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800dc9:	0f b6 c0             	movzbl %al,%eax
  800dcc:	0f b6 db             	movzbl %bl,%ebx
  800dcf:	29 d8                	sub    %ebx,%eax
  800dd1:	eb 0f                	jmp    800de2 <memcmp+0x35>
		s1++, s2++;
  800dd3:	83 c2 01             	add    $0x1,%edx
  800dd6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800dd9:	39 f2                	cmp    %esi,%edx
  800ddb:	75 e2                	jne    800dbf <memcmp+0x12>
	}

	return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800def:	89 c2                	mov    %eax,%edx
  800df1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df4:	eb 07                	jmp    800dfd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df6:	38 08                	cmp    %cl,(%eax)
  800df8:	74 07                	je     800e01 <memfind+0x1b>
	for (; s < ends; s++)
  800dfa:	83 c0 01             	add    $0x1,%eax
  800dfd:	39 d0                	cmp    %edx,%eax
  800dff:	72 f5                	jb     800df6 <memfind+0x10>
			break;
	return (void *) s;
}
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0f:	eb 03                	jmp    800e14 <strtol+0x11>
		s++;
  800e11:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e14:	0f b6 0a             	movzbl (%edx),%ecx
  800e17:	80 f9 09             	cmp    $0x9,%cl
  800e1a:	74 f5                	je     800e11 <strtol+0xe>
  800e1c:	80 f9 20             	cmp    $0x20,%cl
  800e1f:	74 f0                	je     800e11 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e21:	80 f9 2b             	cmp    $0x2b,%cl
  800e24:	75 0a                	jne    800e30 <strtol+0x2d>
		s++;
  800e26:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e29:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2e:	eb 11                	jmp    800e41 <strtol+0x3e>
  800e30:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800e35:	80 f9 2d             	cmp    $0x2d,%cl
  800e38:	75 07                	jne    800e41 <strtol+0x3e>
		s++, neg = 1;
  800e3a:	8d 52 01             	lea    0x1(%edx),%edx
  800e3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e46:	75 15                	jne    800e5d <strtol+0x5a>
  800e48:	80 3a 30             	cmpb   $0x30,(%edx)
  800e4b:	75 10                	jne    800e5d <strtol+0x5a>
  800e4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e51:	75 0a                	jne    800e5d <strtol+0x5a>
		s += 2, base = 16;
  800e53:	83 c2 02             	add    $0x2,%edx
  800e56:	b8 10 00 00 00       	mov    $0x10,%eax
  800e5b:	eb 10                	jmp    800e6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	75 0c                	jne    800e6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e61:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800e63:	80 3a 30             	cmpb   $0x30,(%edx)
  800e66:	75 05                	jne    800e6d <strtol+0x6a>
		s++, base = 8;
  800e68:	83 c2 01             	add    $0x1,%edx
  800e6b:	b0 08                	mov    $0x8,%al
		base = 10;
  800e6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e75:	0f b6 0a             	movzbl (%edx),%ecx
  800e78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e7b:	89 f0                	mov    %esi,%eax
  800e7d:	3c 09                	cmp    $0x9,%al
  800e7f:	77 08                	ja     800e89 <strtol+0x86>
			dig = *s - '0';
  800e81:	0f be c9             	movsbl %cl,%ecx
  800e84:	83 e9 30             	sub    $0x30,%ecx
  800e87:	eb 20                	jmp    800ea9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e8c:	89 f0                	mov    %esi,%eax
  800e8e:	3c 19                	cmp    $0x19,%al
  800e90:	77 08                	ja     800e9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e92:	0f be c9             	movsbl %cl,%ecx
  800e95:	83 e9 57             	sub    $0x57,%ecx
  800e98:	eb 0f                	jmp    800ea9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e9d:	89 f0                	mov    %esi,%eax
  800e9f:	3c 19                	cmp    $0x19,%al
  800ea1:	77 16                	ja     800eb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ea3:	0f be c9             	movsbl %cl,%ecx
  800ea6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ea9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800eac:	7d 0f                	jge    800ebd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800eae:	83 c2 01             	add    $0x1,%edx
  800eb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800eb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800eb7:	eb bc                	jmp    800e75 <strtol+0x72>
  800eb9:	89 d8                	mov    %ebx,%eax
  800ebb:	eb 02                	jmp    800ebf <strtol+0xbc>
  800ebd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ebf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec3:	74 05                	je     800eca <strtol+0xc7>
		*endptr = (char *) s;
  800ec5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ec8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800eca:	f7 d8                	neg    %eax
  800ecc:	85 ff                	test   %edi,%edi
  800ece:	0f 44 c3             	cmove  %ebx,%eax
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee7:	89 c3                	mov    %eax,%ebx
  800ee9:	89 c7                	mov    %eax,%edi
  800eeb:	89 c6                	mov    %eax,%esi
  800eed:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	b8 01 00 00 00       	mov    $0x1,%eax
  800f04:	89 d1                	mov    %edx,%ecx
  800f06:	89 d3                	mov    %edx,%ebx
  800f08:	89 d7                	mov    %edx,%edi
  800f0a:	89 d6                	mov    %edx,%esi
  800f0c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f21:	b8 03 00 00 00       	mov    $0x3,%eax
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 cb                	mov    %ecx,%ebx
  800f2b:	89 cf                	mov    %ecx,%edi
  800f2d:	89 ce                	mov    %ecx,%esi
  800f2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 28                	jle    800f5d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f40:	00 
  800f41:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800f58:	e8 0a f5 ff ff       	call   800467 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f5d:	83 c4 2c             	add    $0x2c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f70:	b8 02 00 00 00       	mov    $0x2,%eax
  800f75:	89 d1                	mov    %edx,%ecx
  800f77:	89 d3                	mov    %edx,%ebx
  800f79:	89 d7                	mov    %edx,%edi
  800f7b:	89 d6                	mov    %edx,%esi
  800f7d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sys_yield>:

void
sys_yield(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f94:	89 d1                	mov    %edx,%ecx
  800f96:	89 d3                	mov    %edx,%ebx
  800f98:	89 d7                	mov    %edx,%edi
  800f9a:	89 d6                	mov    %edx,%esi
  800f9c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fac:	be 00 00 00 00       	mov    $0x0,%esi
  800fb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbf:	89 f7                	mov    %esi,%edi
  800fc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	7e 28                	jle    800fef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800fea:	e8 78 f4 ff ff       	call   800467 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fef:	83 c4 2c             	add    $0x2c,%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5f                   	pop    %edi
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801000:	b8 05 00 00 00       	mov    $0x5,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801011:	8b 75 18             	mov    0x18(%ebp),%esi
  801014:	cd 30                	int    $0x30
	if(check && ret > 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	7e 28                	jle    801042 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801025:	00 
  801026:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  80102d:	00 
  80102e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  80103d:	e8 25 f4 ff ff       	call   800467 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801042:	83 c4 2c             	add    $0x2c,%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	57                   	push   %edi
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
  801058:	b8 06 00 00 00       	mov    $0x6,%eax
  80105d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	89 df                	mov    %ebx,%edi
  801065:	89 de                	mov    %ebx,%esi
  801067:	cd 30                	int    $0x30
	if(check && ret > 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	7e 28                	jle    801095 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801071:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801078:	00 
  801079:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  801090:	e8 d2 f3 ff ff       	call   800467 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801095:	83 c4 2c             	add    $0x2c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	89 df                	mov    %ebx,%edi
  8010b8:	89 de                	mov    %ebx,%esi
  8010ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	7e 28                	jle    8010e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010db:	00 
  8010dc:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  8010e3:	e8 7f f3 ff ff       	call   800467 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010e8:	83 c4 2c             	add    $0x2c,%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8010f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	89 df                	mov    %ebx,%edi
  80110b:	89 de                	mov    %ebx,%esi
  80110d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	7e 28                	jle    80113b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801113:	89 44 24 10          	mov    %eax,0x10(%esp)
  801117:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80111e:	00 
  80111f:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  801126:	00 
  801127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80112e:	00 
  80112f:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  801136:	e8 2c f3 ff ff       	call   800467 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80113b:	83 c4 2c             	add    $0x2c,%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801151:	b8 0a 00 00 00       	mov    $0xa,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	89 df                	mov    %ebx,%edi
  80115e:	89 de                	mov    %ebx,%esi
  801160:	cd 30                	int    $0x30
	if(check && ret > 0)
  801162:	85 c0                	test   %eax,%eax
  801164:	7e 28                	jle    80118e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801166:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801171:	00 
  801172:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  801179:	00 
  80117a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801181:	00 
  801182:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  801189:	e8 d9 f2 ff ff       	call   800467 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80118e:	83 c4 2c             	add    $0x2c,%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	57                   	push   %edi
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80119c:	be 00 00 00 00       	mov    $0x0,%esi
  8011a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011b2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8011c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cf:	89 cb                	mov    %ecx,%ebx
  8011d1:	89 cf                	mov    %ecx,%edi
  8011d3:	89 ce                	mov    %ecx,%esi
  8011d5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	7e 28                	jle    801203 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  8011ee:	00 
  8011ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011f6:	00 
  8011f7:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  8011fe:	e8 64 f2 ff ff       	call   800467 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801203:	83 c4 2c             	add    $0x2c,%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    
  80120b:	66 90                	xchg   %ax,%ax
  80120d:	66 90                	xchg   %ax,%ax
  80120f:	90                   	nop

00801210 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	05 00 00 00 30       	add    $0x30000000,%eax
  80121b:	c1 e8 0c             	shr    $0xc,%eax
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80122b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801230:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801242:	89 c2                	mov    %eax,%edx
  801244:	c1 ea 16             	shr    $0x16,%edx
  801247:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124e:	f6 c2 01             	test   $0x1,%dl
  801251:	74 11                	je     801264 <fd_alloc+0x2d>
  801253:	89 c2                	mov    %eax,%edx
  801255:	c1 ea 0c             	shr    $0xc,%edx
  801258:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125f:	f6 c2 01             	test   $0x1,%dl
  801262:	75 09                	jne    80126d <fd_alloc+0x36>
			*fd_store = fd;
  801264:	89 01                	mov    %eax,(%ecx)
			return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
  80126b:	eb 17                	jmp    801284 <fd_alloc+0x4d>
  80126d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801272:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801277:	75 c9                	jne    801242 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801279:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80127f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80128c:	83 f8 1f             	cmp    $0x1f,%eax
  80128f:	77 36                	ja     8012c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801291:	c1 e0 0c             	shl    $0xc,%eax
  801294:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801299:	89 c2                	mov    %eax,%edx
  80129b:	c1 ea 16             	shr    $0x16,%edx
  80129e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a5:	f6 c2 01             	test   $0x1,%dl
  8012a8:	74 24                	je     8012ce <fd_lookup+0x48>
  8012aa:	89 c2                	mov    %eax,%edx
  8012ac:	c1 ea 0c             	shr    $0xc,%edx
  8012af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b6:	f6 c2 01             	test   $0x1,%dl
  8012b9:	74 1a                	je     8012d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012be:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c5:	eb 13                	jmp    8012da <fd_lookup+0x54>
		return -E_INVAL;
  8012c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cc:	eb 0c                	jmp    8012da <fd_lookup+0x54>
		return -E_INVAL;
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d3:	eb 05                	jmp    8012da <fd_lookup+0x54>
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 18             	sub    $0x18,%esp
  8012e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e5:	ba 08 2d 80 00       	mov    $0x802d08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ea:	eb 13                	jmp    8012ff <dev_lookup+0x23>
  8012ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012ef:	39 08                	cmp    %ecx,(%eax)
  8012f1:	75 0c                	jne    8012ff <dev_lookup+0x23>
			*dev = devtab[i];
  8012f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fd:	eb 30                	jmp    80132f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8012ff:	8b 02                	mov    (%edx),%eax
  801301:	85 c0                	test   %eax,%eax
  801303:	75 e7                	jne    8012ec <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801305:	a1 90 67 80 00       	mov    0x806790,%eax
  80130a:	8b 40 48             	mov    0x48(%eax),%eax
  80130d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801311:	89 44 24 04          	mov    %eax,0x4(%esp)
  801315:	c7 04 24 8c 2c 80 00 	movl   $0x802c8c,(%esp)
  80131c:	e8 3f f2 ff ff       	call   800560 <cprintf>
	*dev = 0;
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <fd_close>:
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	56                   	push   %esi
  801335:	53                   	push   %ebx
  801336:	83 ec 20             	sub    $0x20,%esp
  801339:	8b 75 08             	mov    0x8(%ebp),%esi
  80133c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801346:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80134c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134f:	89 04 24             	mov    %eax,(%esp)
  801352:	e8 2f ff ff ff       	call   801286 <fd_lookup>
  801357:	85 c0                	test   %eax,%eax
  801359:	78 05                	js     801360 <fd_close+0x2f>
	    || fd != fd2)
  80135b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80135e:	74 0c                	je     80136c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801360:	84 db                	test   %bl,%bl
  801362:	ba 00 00 00 00       	mov    $0x0,%edx
  801367:	0f 44 c2             	cmove  %edx,%eax
  80136a:	eb 3f                	jmp    8013ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80136c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801373:	8b 06                	mov    (%esi),%eax
  801375:	89 04 24             	mov    %eax,(%esp)
  801378:	e8 5f ff ff ff       	call   8012dc <dev_lookup>
  80137d:	89 c3                	mov    %eax,%ebx
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 16                	js     801399 <fd_close+0x68>
		if (dev->dev_close)
  801383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801386:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801389:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80138e:	85 c0                	test   %eax,%eax
  801390:	74 07                	je     801399 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801392:	89 34 24             	mov    %esi,(%esp)
  801395:	ff d0                	call   *%eax
  801397:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801399:	89 74 24 04          	mov    %esi,0x4(%esp)
  80139d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a4:	e8 a1 fc ff ff       	call   80104a <sys_page_unmap>
	return r;
  8013a9:	89 d8                	mov    %ebx,%eax
}
  8013ab:	83 c4 20             	add    $0x20,%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <close>:

int
close(int fdnum)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c2:	89 04 24             	mov    %eax,(%esp)
  8013c5:	e8 bc fe ff ff       	call   801286 <fd_lookup>
  8013ca:	89 c2                	mov    %eax,%edx
  8013cc:	85 d2                	test   %edx,%edx
  8013ce:	78 13                	js     8013e3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8013d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013d7:	00 
  8013d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	e8 4e ff ff ff       	call   801331 <fd_close>
}
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <close_all>:

void
close_all(void)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f1:	89 1c 24             	mov    %ebx,(%esp)
  8013f4:	e8 b9 ff ff ff       	call   8013b2 <close>
	for (i = 0; i < MAXFD; i++)
  8013f9:	83 c3 01             	add    $0x1,%ebx
  8013fc:	83 fb 20             	cmp    $0x20,%ebx
  8013ff:	75 f0                	jne    8013f1 <close_all+0xc>
}
  801401:	83 c4 14             	add    $0x14,%esp
  801404:	5b                   	pop    %ebx
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	57                   	push   %edi
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801410:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801413:	89 44 24 04          	mov    %eax,0x4(%esp)
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	89 04 24             	mov    %eax,(%esp)
  80141d:	e8 64 fe ff ff       	call   801286 <fd_lookup>
  801422:	89 c2                	mov    %eax,%edx
  801424:	85 d2                	test   %edx,%edx
  801426:	0f 88 e1 00 00 00    	js     80150d <dup+0x106>
		return r;
	close(newfdnum);
  80142c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142f:	89 04 24             	mov    %eax,(%esp)
  801432:	e8 7b ff ff ff       	call   8013b2 <close>

	newfd = INDEX2FD(newfdnum);
  801437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80143a:	c1 e3 0c             	shl    $0xc,%ebx
  80143d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801443:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801446:	89 04 24             	mov    %eax,(%esp)
  801449:	e8 d2 fd ff ff       	call   801220 <fd2data>
  80144e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801450:	89 1c 24             	mov    %ebx,(%esp)
  801453:	e8 c8 fd ff ff       	call   801220 <fd2data>
  801458:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145a:	89 f0                	mov    %esi,%eax
  80145c:	c1 e8 16             	shr    $0x16,%eax
  80145f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801466:	a8 01                	test   $0x1,%al
  801468:	74 43                	je     8014ad <dup+0xa6>
  80146a:	89 f0                	mov    %esi,%eax
  80146c:	c1 e8 0c             	shr    $0xc,%eax
  80146f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801476:	f6 c2 01             	test   $0x1,%dl
  801479:	74 32                	je     8014ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801482:	25 07 0e 00 00       	and    $0xe07,%eax
  801487:	89 44 24 10          	mov    %eax,0x10(%esp)
  80148b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80148f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801496:	00 
  801497:	89 74 24 04          	mov    %esi,0x4(%esp)
  80149b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a2:	e8 50 fb ff ff       	call   800ff7 <sys_page_map>
  8014a7:	89 c6                	mov    %eax,%esi
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 3e                	js     8014eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	c1 ea 0c             	shr    $0xc,%edx
  8014b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014d1:	00 
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014dd:	e8 15 fb ff ff       	call   800ff7 <sys_page_map>
  8014e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8014e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e7:	85 f6                	test   %esi,%esi
  8014e9:	79 22                	jns    80150d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8014eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f6:	e8 4f fb ff ff       	call   80104a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801506:	e8 3f fb ff ff       	call   80104a <sys_page_unmap>
	return r;
  80150b:	89 f0                	mov    %esi,%eax
}
  80150d:	83 c4 3c             	add    $0x3c,%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 24             	sub    $0x24,%esp
  80151c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801522:	89 44 24 04          	mov    %eax,0x4(%esp)
  801526:	89 1c 24             	mov    %ebx,(%esp)
  801529:	e8 58 fd ff ff       	call   801286 <fd_lookup>
  80152e:	89 c2                	mov    %eax,%edx
  801530:	85 d2                	test   %edx,%edx
  801532:	78 6d                	js     8015a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	8b 00                	mov    (%eax),%eax
  801540:	89 04 24             	mov    %eax,(%esp)
  801543:	e8 94 fd ff ff       	call   8012dc <dev_lookup>
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 55                	js     8015a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154f:	8b 50 08             	mov    0x8(%eax),%edx
  801552:	83 e2 03             	and    $0x3,%edx
  801555:	83 fa 01             	cmp    $0x1,%edx
  801558:	75 23                	jne    80157d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155a:	a1 90 67 80 00       	mov    0x806790,%eax
  80155f:	8b 40 48             	mov    0x48(%eax),%eax
  801562:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	c7 04 24 cd 2c 80 00 	movl   $0x802ccd,(%esp)
  801571:	e8 ea ef ff ff       	call   800560 <cprintf>
		return -E_INVAL;
  801576:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157b:	eb 24                	jmp    8015a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80157d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801580:	8b 52 08             	mov    0x8(%edx),%edx
  801583:	85 d2                	test   %edx,%edx
  801585:	74 15                	je     80159c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801587:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80158a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80158e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801591:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	ff d2                	call   *%edx
  80159a:	eb 05                	jmp    8015a1 <read+0x8c>
		return -E_NOT_SUPP;
  80159c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015a1:	83 c4 24             	add    $0x24,%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    

008015a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	57                   	push   %edi
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 1c             	sub    $0x1c,%esp
  8015b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bb:	eb 23                	jmp    8015e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bd:	89 f0                	mov    %esi,%eax
  8015bf:	29 d8                	sub    %ebx,%eax
  8015c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	03 45 0c             	add    0xc(%ebp),%eax
  8015ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ce:	89 3c 24             	mov    %edi,(%esp)
  8015d1:	e8 3f ff ff ff       	call   801515 <read>
		if (m < 0)
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 10                	js     8015ea <readn+0x43>
			return m;
		if (m == 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	74 0a                	je     8015e8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8015de:	01 c3                	add    %eax,%ebx
  8015e0:	39 f3                	cmp    %esi,%ebx
  8015e2:	72 d9                	jb     8015bd <readn+0x16>
  8015e4:	89 d8                	mov    %ebx,%eax
  8015e6:	eb 02                	jmp    8015ea <readn+0x43>
  8015e8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015ea:	83 c4 1c             	add    $0x1c,%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5f                   	pop    %edi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 24             	sub    $0x24,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801603:	89 1c 24             	mov    %ebx,(%esp)
  801606:	e8 7b fc ff ff       	call   801286 <fd_lookup>
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	85 d2                	test   %edx,%edx
  80160f:	78 68                	js     801679 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801611:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801614:	89 44 24 04          	mov    %eax,0x4(%esp)
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	8b 00                	mov    (%eax),%eax
  80161d:	89 04 24             	mov    %eax,(%esp)
  801620:	e8 b7 fc ff ff       	call   8012dc <dev_lookup>
  801625:	85 c0                	test   %eax,%eax
  801627:	78 50                	js     801679 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801630:	75 23                	jne    801655 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801632:	a1 90 67 80 00       	mov    0x806790,%eax
  801637:	8b 40 48             	mov    0x48(%eax),%eax
  80163a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80163e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801642:	c7 04 24 e9 2c 80 00 	movl   $0x802ce9,(%esp)
  801649:	e8 12 ef ff ff       	call   800560 <cprintf>
		return -E_INVAL;
  80164e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801653:	eb 24                	jmp    801679 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801655:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801658:	8b 52 0c             	mov    0xc(%edx),%edx
  80165b:	85 d2                	test   %edx,%edx
  80165d:	74 15                	je     801674 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801662:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801666:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801669:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	ff d2                	call   *%edx
  801672:	eb 05                	jmp    801679 <write+0x87>
		return -E_NOT_SUPP;
  801674:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801679:	83 c4 24             	add    $0x24,%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <seek>:

int
seek(int fdnum, off_t offset)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801685:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168c:	8b 45 08             	mov    0x8(%ebp),%eax
  80168f:	89 04 24             	mov    %eax,(%esp)
  801692:	e8 ef fb ff ff       	call   801286 <fd_lookup>
  801697:	85 c0                	test   %eax,%eax
  801699:	78 0e                	js     8016a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80169b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 24             	sub    $0x24,%esp
  8016b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bc:	89 1c 24             	mov    %ebx,(%esp)
  8016bf:	e8 c2 fb ff ff       	call   801286 <fd_lookup>
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	85 d2                	test   %edx,%edx
  8016c8:	78 61                	js     80172b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d4:	8b 00                	mov    (%eax),%eax
  8016d6:	89 04 24             	mov    %eax,(%esp)
  8016d9:	e8 fe fb ff ff       	call   8012dc <dev_lookup>
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 49                	js     80172b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e9:	75 23                	jne    80170e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016eb:	a1 90 67 80 00       	mov    0x806790,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016f0:	8b 40 48             	mov    0x48(%eax),%eax
  8016f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fb:	c7 04 24 ac 2c 80 00 	movl   $0x802cac,(%esp)
  801702:	e8 59 ee ff ff       	call   800560 <cprintf>
		return -E_INVAL;
  801707:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170c:	eb 1d                	jmp    80172b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80170e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801711:	8b 52 18             	mov    0x18(%edx),%edx
  801714:	85 d2                	test   %edx,%edx
  801716:	74 0e                	je     801726 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80171f:	89 04 24             	mov    %eax,(%esp)
  801722:	ff d2                	call   *%edx
  801724:	eb 05                	jmp    80172b <ftruncate+0x80>
		return -E_NOT_SUPP;
  801726:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80172b:	83 c4 24             	add    $0x24,%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	53                   	push   %ebx
  801735:	83 ec 24             	sub    $0x24,%esp
  801738:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 39 fb ff ff       	call   801286 <fd_lookup>
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	85 d2                	test   %edx,%edx
  801751:	78 52                	js     8017a5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801753:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801756:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175d:	8b 00                	mov    (%eax),%eax
  80175f:	89 04 24             	mov    %eax,(%esp)
  801762:	e8 75 fb ff ff       	call   8012dc <dev_lookup>
  801767:	85 c0                	test   %eax,%eax
  801769:	78 3a                	js     8017a5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80176b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801772:	74 2c                	je     8017a0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801774:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801777:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177e:	00 00 00 
	stat->st_isdir = 0;
  801781:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801788:	00 00 00 
	stat->st_dev = dev;
  80178b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801791:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801795:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801798:	89 14 24             	mov    %edx,(%esp)
  80179b:	ff 50 14             	call   *0x14(%eax)
  80179e:	eb 05                	jmp    8017a5 <fstat+0x74>
		return -E_NOT_SUPP;
  8017a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017a5:	83 c4 24             	add    $0x24,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
  8017b0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017ba:	00 
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	89 04 24             	mov    %eax,(%esp)
  8017c1:	e8 fb 01 00 00       	call   8019c1 <open>
  8017c6:	89 c3                	mov    %eax,%ebx
  8017c8:	85 db                	test   %ebx,%ebx
  8017ca:	78 1b                	js     8017e7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d3:	89 1c 24             	mov    %ebx,(%esp)
  8017d6:	e8 56 ff ff ff       	call   801731 <fstat>
  8017db:	89 c6                	mov    %eax,%esi
	close(fd);
  8017dd:	89 1c 24             	mov    %ebx,(%esp)
  8017e0:	e8 cd fb ff ff       	call   8013b2 <close>
	return r;
  8017e5:	89 f0                	mov    %esi,%eax
}
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5e                   	pop    %esi
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 10             	sub    $0x10,%esp
  8017f6:	89 c6                	mov    %eax,%esi
  8017f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017fa:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801801:	75 11                	jne    801814 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801803:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80180a:	e8 c0 0c 00 00       	call   8024cf <ipc_find_env>
  80180f:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801814:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80181b:	00 
  80181c:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801823:	00 
  801824:	89 74 24 04          	mov    %esi,0x4(%esp)
  801828:	a1 04 50 80 00       	mov    0x805004,%eax
  80182d:	89 04 24             	mov    %eax,(%esp)
  801830:	e8 33 0c 00 00       	call   802468 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801835:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80183c:	00 
  80183d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801841:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801848:	e8 b3 0b 00 00       	call   802400 <ipc_recv>
}
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	8b 40 0c             	mov    0xc(%eax),%eax
  801860:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	b8 02 00 00 00       	mov    $0x2,%eax
  801877:	e8 72 ff ff ff       	call   8017ee <fsipc>
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devfile_flush>:
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	8b 40 0c             	mov    0xc(%eax),%eax
  80188a:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80188f:	ba 00 00 00 00       	mov    $0x0,%edx
  801894:	b8 06 00 00 00       	mov    $0x6,%eax
  801899:	e8 50 ff ff ff       	call   8017ee <fsipc>
}
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <devfile_stat>:
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 14             	sub    $0x14,%esp
  8018a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b0:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8018bf:	e8 2a ff ff ff       	call   8017ee <fsipc>
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	85 d2                	test   %edx,%edx
  8018c8:	78 2b                	js     8018f5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ca:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8018d1:	00 
  8018d2:	89 1c 24             	mov    %ebx,(%esp)
  8018d5:	e8 ad f2 ff ff       	call   800b87 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018da:	a1 80 70 80 00       	mov    0x807080,%eax
  8018df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e5:	a1 84 70 80 00       	mov    0x807084,%eax
  8018ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f5:	83 c4 14             	add    $0x14,%esp
  8018f8:	5b                   	pop    %ebx
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <devfile_write>:
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801901:	c7 44 24 08 18 2d 80 	movl   $0x802d18,0x8(%esp)
  801908:	00 
  801909:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801910:	00 
  801911:	c7 04 24 36 2d 80 00 	movl   $0x802d36,(%esp)
  801918:	e8 4a eb ff ff       	call   800467 <_panic>

0080191d <devfile_read>:
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	83 ec 10             	sub    $0x10,%esp
  801925:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	8b 40 0c             	mov    0xc(%eax),%eax
  80192e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801933:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801939:	ba 00 00 00 00       	mov    $0x0,%edx
  80193e:	b8 03 00 00 00       	mov    $0x3,%eax
  801943:	e8 a6 fe ff ff       	call   8017ee <fsipc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 6a                	js     8019b8 <devfile_read+0x9b>
	assert(r <= n);
  80194e:	39 c6                	cmp    %eax,%esi
  801950:	73 24                	jae    801976 <devfile_read+0x59>
  801952:	c7 44 24 0c 41 2d 80 	movl   $0x802d41,0xc(%esp)
  801959:	00 
  80195a:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  801961:	00 
  801962:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801969:	00 
  80196a:	c7 04 24 36 2d 80 00 	movl   $0x802d36,(%esp)
  801971:	e8 f1 ea ff ff       	call   800467 <_panic>
	assert(r <= PGSIZE);
  801976:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80197b:	7e 24                	jle    8019a1 <devfile_read+0x84>
  80197d:	c7 44 24 0c 5d 2d 80 	movl   $0x802d5d,0xc(%esp)
  801984:	00 
  801985:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  80198c:	00 
  80198d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801994:	00 
  801995:	c7 04 24 36 2d 80 00 	movl   $0x802d36,(%esp)
  80199c:	e8 c6 ea ff ff       	call   800467 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019a5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8019ac:	00 
  8019ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b0:	89 04 24             	mov    %eax,(%esp)
  8019b3:	e8 6c f3 ff ff       	call   800d24 <memmove>
}
  8019b8:	89 d8                	mov    %ebx,%eax
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5e                   	pop    %esi
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <open>:
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 24             	sub    $0x24,%esp
  8019c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8019cb:	89 1c 24             	mov    %ebx,(%esp)
  8019ce:	e8 7d f1 ff ff       	call   800b50 <strlen>
  8019d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d8:	7f 60                	jg     801a3a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8019da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019dd:	89 04 24             	mov    %eax,(%esp)
  8019e0:	e8 52 f8 ff ff       	call   801237 <fd_alloc>
  8019e5:	89 c2                	mov    %eax,%edx
  8019e7:	85 d2                	test   %edx,%edx
  8019e9:	78 54                	js     801a3f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8019eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ef:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  8019f6:	e8 8c f1 ff ff       	call   800b87 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fe:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a06:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0b:	e8 de fd ff ff       	call   8017ee <fsipc>
  801a10:	89 c3                	mov    %eax,%ebx
  801a12:	85 c0                	test   %eax,%eax
  801a14:	79 17                	jns    801a2d <open+0x6c>
		fd_close(fd, 0);
  801a16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a1d:	00 
  801a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 08 f9 ff ff       	call   801331 <fd_close>
		return r;
  801a29:	89 d8                	mov    %ebx,%eax
  801a2b:	eb 12                	jmp    801a3f <open+0x7e>
	return fd2num(fd);
  801a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a30:	89 04 24             	mov    %eax,(%esp)
  801a33:	e8 d8 f7 ff ff       	call   801210 <fd2num>
  801a38:	eb 05                	jmp    801a3f <open+0x7e>
		return -E_BAD_PATH;
  801a3a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801a3f:	83 c4 24             	add    $0x24,%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a50:	b8 08 00 00 00       	mov    $0x8,%eax
  801a55:	e8 94 fd ff ff       	call   8017ee <fsipc>
}
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    
  801a5c:	66 90                	xchg   %ax,%ax
  801a5e:	66 90                	xchg   %ax,%ax

00801a60 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	57                   	push   %edi
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a73:	00 
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	89 04 24             	mov    %eax,(%esp)
  801a7a:	e8 42 ff ff ff       	call   8019c1 <open>
  801a7f:	89 c1                	mov    %eax,%ecx
  801a81:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801a87:	85 c0                	test   %eax,%eax
  801a89:	0f 88 a8 04 00 00    	js     801f37 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a8f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a96:	00 
  801a97:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa1:	89 0c 24             	mov    %ecx,(%esp)
  801aa4:	e8 fe fa ff ff       	call   8015a7 <readn>
  801aa9:	3d 00 02 00 00       	cmp    $0x200,%eax
  801aae:	75 0c                	jne    801abc <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801ab0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ab7:	45 4c 46 
  801aba:	74 36                	je     801af2 <spawn+0x92>
		close(fd);
  801abc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 e8 f8 ff ff       	call   8013b2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801aca:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ad1:	46 
  801ad2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adc:	c7 04 24 69 2d 80 00 	movl   $0x802d69,(%esp)
  801ae3:	e8 78 ea ff ff       	call   800560 <cprintf>
		return -E_NOT_EXEC;
  801ae8:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801aed:	e9 a4 04 00 00       	jmp    801f96 <spawn+0x536>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801af2:	b8 07 00 00 00       	mov    $0x7,%eax
  801af7:	cd 30                	int    $0x30
  801af9:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801aff:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801b05:	85 c0                	test   %eax,%eax
  801b07:	0f 88 32 04 00 00    	js     801f3f <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b0d:	89 c6                	mov    %eax,%esi
  801b0f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801b15:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801b18:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801b1e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b24:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b2b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b31:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b37:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801b3c:	be 00 00 00 00       	mov    $0x0,%esi
  801b41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b44:	eb 0f                	jmp    801b55 <spawn+0xf5>
		string_size += strlen(argv[argc]) + 1;
  801b46:	89 04 24             	mov    %eax,(%esp)
  801b49:	e8 02 f0 ff ff       	call   800b50 <strlen>
  801b4e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801b52:	83 c3 01             	add    $0x1,%ebx
  801b55:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801b5c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	75 e3                	jne    801b46 <spawn+0xe6>
  801b63:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801b69:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b6f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b74:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b76:	89 fa                	mov    %edi,%edx
  801b78:	83 e2 fc             	and    $0xfffffffc,%edx
  801b7b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801b82:	29 c2                	sub    %eax,%edx
  801b84:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b8a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801b8d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b92:	0f 86 b7 03 00 00    	jbe    801f4f <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b98:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b9f:	00 
  801ba0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ba7:	00 
  801ba8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801baf:	e8 ef f3 ff ff       	call   800fa3 <sys_page_alloc>
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	0f 88 da 03 00 00    	js     801f96 <spawn+0x536>
  801bbc:	be 00 00 00 00       	mov    $0x0,%esi
  801bc1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801bc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bca:	eb 30                	jmp    801bfc <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801bcc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801bd2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801bd8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801bdb:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801bde:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be2:	89 3c 24             	mov    %edi,(%esp)
  801be5:	e8 9d ef ff ff       	call   800b87 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801bea:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 5b ef ff ff       	call   800b50 <strlen>
  801bf5:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801bf9:	83 c6 01             	add    $0x1,%esi
  801bfc:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801c02:	7f c8                	jg     801bcc <spawn+0x16c>
	}
	argv_store[argc] = 0;
  801c04:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c0a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801c10:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c17:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c1d:	74 24                	je     801c43 <spawn+0x1e3>
  801c1f:	c7 44 24 0c e0 2d 80 	movl   $0x802de0,0xc(%esp)
  801c26:	00 
  801c27:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  801c2e:	00 
  801c2f:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801c36:	00 
  801c37:	c7 04 24 83 2d 80 00 	movl   $0x802d83,(%esp)
  801c3e:	e8 24 e8 ff ff       	call   800467 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c43:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801c49:	89 c8                	mov    %ecx,%eax
  801c4b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c50:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801c53:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801c59:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c5c:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801c62:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c68:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c6f:	00 
  801c70:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c77:	ee 
  801c78:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c82:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c89:	00 
  801c8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c91:	e8 61 f3 ff ff       	call   800ff7 <sys_page_map>
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	0f 88 e0 02 00 00    	js     801f80 <spawn+0x520>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ca0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ca7:	00 
  801ca8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801caf:	e8 96 f3 ff ff       	call   80104a <sys_page_unmap>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	0f 88 c2 02 00 00    	js     801f80 <spawn+0x520>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cbe:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801cc4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ccb:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cd1:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801cd8:	00 00 00 
  801cdb:	e9 b6 01 00 00       	jmp    801e96 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801ce0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ce6:	83 38 01             	cmpl   $0x1,(%eax)
  801ce9:	0f 85 99 01 00 00    	jne    801e88 <spawn+0x428>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801cef:	89 c1                	mov    %eax,%ecx
  801cf1:	8b 40 18             	mov    0x18(%eax),%eax
  801cf4:	83 e0 02             	and    $0x2,%eax
		perm = PTE_P | PTE_U;
  801cf7:	83 f8 01             	cmp    $0x1,%eax
  801cfa:	19 c0                	sbb    %eax,%eax
  801cfc:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801d02:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801d09:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	8b 51 04             	mov    0x4(%ecx),%edx
  801d15:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801d1b:	8b 49 10             	mov    0x10(%ecx),%ecx
  801d1e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801d24:	8b 50 14             	mov    0x14(%eax),%edx
  801d27:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d2d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d30:	89 f0                	mov    %esi,%eax
  801d32:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d37:	74 14                	je     801d4d <spawn+0x2ed>
		va -= i;
  801d39:	29 c6                	sub    %eax,%esi
		memsz += i;
  801d3b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801d41:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801d47:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d52:	e9 23 01 00 00       	jmp    801e7a <spawn+0x41a>
		if (i >= filesz) {
  801d57:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801d5d:	77 2b                	ja     801d8a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d5f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801d65:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d69:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d73:	89 04 24             	mov    %eax,(%esp)
  801d76:	e8 28 f2 ff ff       	call   800fa3 <sys_page_alloc>
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	0f 89 eb 00 00 00    	jns    801e6e <spawn+0x40e>
  801d83:	89 c3                	mov    %eax,%ebx
  801d85:	e9 d6 01 00 00       	jmp    801f60 <spawn+0x500>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d8a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d91:	00 
  801d92:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d99:	00 
  801d9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da1:	e8 fd f1 ff ff       	call   800fa3 <sys_page_alloc>
  801da6:	85 c0                	test   %eax,%eax
  801da8:	0f 88 a8 01 00 00    	js     801f56 <spawn+0x4f6>
  801dae:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801db4:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801db6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dba:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801dc0:	89 04 24             	mov    %eax,(%esp)
  801dc3:	e8 b7 f8 ff ff       	call   80167f <seek>
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	0f 88 8a 01 00 00    	js     801f5a <spawn+0x4fa>
  801dd0:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801dd6:	29 fa                	sub    %edi,%edx
  801dd8:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dda:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801de0:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801de5:	0f 47 c1             	cmova  %ecx,%eax
  801de8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dec:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801df3:	00 
  801df4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801dfa:	89 04 24             	mov    %eax,(%esp)
  801dfd:	e8 a5 f7 ff ff       	call   8015a7 <readn>
  801e02:	85 c0                	test   %eax,%eax
  801e04:	0f 88 54 01 00 00    	js     801f5e <spawn+0x4fe>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e0a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e14:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e18:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e22:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e29:	00 
  801e2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e31:	e8 c1 f1 ff ff       	call   800ff7 <sys_page_map>
  801e36:	85 c0                	test   %eax,%eax
  801e38:	79 20                	jns    801e5a <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801e3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e3e:	c7 44 24 08 8f 2d 80 	movl   $0x802d8f,0x8(%esp)
  801e45:	00 
  801e46:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801e4d:	00 
  801e4e:	c7 04 24 83 2d 80 00 	movl   $0x802d83,(%esp)
  801e55:	e8 0d e6 ff ff       	call   800467 <_panic>
			sys_page_unmap(0, UTEMP);
  801e5a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e61:	00 
  801e62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e69:	e8 dc f1 ff ff       	call   80104a <sys_page_unmap>
	for (i = 0; i < memsz; i += PGSIZE) {
  801e6e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e74:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801e7a:	89 df                	mov    %ebx,%edi
  801e7c:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801e82:	0f 87 cf fe ff ff    	ja     801d57 <spawn+0x2f7>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e88:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801e8f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801e96:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e9d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ea3:	0f 8c 37 fe ff ff    	jl     801ce0 <spawn+0x280>
	close(fd);
  801ea9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801eaf:	89 04 24             	mov    %eax,(%esp)
  801eb2:	e8 fb f4 ff ff       	call   8013b2 <close>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801eb7:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ebe:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ec1:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecb:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 17 f2 ff ff       	call   8010f0 <sys_env_set_trapframe>
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	79 20                	jns    801efd <spawn+0x49d>
		panic("sys_env_set_trapframe: %e", r);
  801edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ee1:	c7 44 24 08 ac 2d 80 	movl   $0x802dac,0x8(%esp)
  801ee8:	00 
  801ee9:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801ef0:	00 
  801ef1:	c7 04 24 83 2d 80 00 	movl   $0x802d83,(%esp)
  801ef8:	e8 6a e5 ff ff       	call   800467 <_panic>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801efd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801f04:	00 
  801f05:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f0b:	89 04 24             	mov    %eax,(%esp)
  801f0e:	e8 8a f1 ff ff       	call   80109d <sys_env_set_status>
  801f13:	85 c0                	test   %eax,%eax
  801f15:	79 30                	jns    801f47 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801f17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f1b:	c7 44 24 08 c6 2d 80 	movl   $0x802dc6,0x8(%esp)
  801f22:	00 
  801f23:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801f2a:	00 
  801f2b:	c7 04 24 83 2d 80 00 	movl   $0x802d83,(%esp)
  801f32:	e8 30 e5 ff ff       	call   800467 <_panic>
		return r;
  801f37:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f3d:	eb 57                	jmp    801f96 <spawn+0x536>
		return r;
  801f3f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f45:	eb 4f                	jmp    801f96 <spawn+0x536>
	return child;
  801f47:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f4d:	eb 47                	jmp    801f96 <spawn+0x536>
		return -E_NO_MEM;
  801f4f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801f54:	eb 40                	jmp    801f96 <spawn+0x536>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	eb 06                	jmp    801f60 <spawn+0x500>
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	eb 02                	jmp    801f60 <spawn+0x500>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f5e:	89 c3                	mov    %eax,%ebx
	sys_env_destroy(child);
  801f60:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f66:	89 04 24             	mov    %eax,(%esp)
  801f69:	e8 a5 ef ff ff       	call   800f13 <sys_env_destroy>
	close(fd);
  801f6e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f74:	89 04 24             	mov    %eax,(%esp)
  801f77:	e8 36 f4 ff ff       	call   8013b2 <close>
	return r;
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	eb 16                	jmp    801f96 <spawn+0x536>
	sys_page_unmap(0, UTEMP);
  801f80:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f87:	00 
  801f88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8f:	e8 b6 f0 ff ff       	call   80104a <sys_page_unmap>
  801f94:	89 d8                	mov    %ebx,%eax
}
  801f96:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    

00801fa1 <spawnl>:
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	56                   	push   %esi
  801fa5:	53                   	push   %ebx
  801fa6:	83 ec 10             	sub    $0x10,%esp
	while(va_arg(vl, void *) != NULL)
  801fa9:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  801fac:	ba 00 00 00 00       	mov    $0x0,%edx
	while(va_arg(vl, void *) != NULL)
  801fb1:	eb 03                	jmp    801fb6 <spawnl+0x15>
		argc++;
  801fb3:	83 c2 01             	add    $0x1,%edx
	while(va_arg(vl, void *) != NULL)
  801fb6:	83 c0 04             	add    $0x4,%eax
  801fb9:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801fbd:	75 f4                	jne    801fb3 <spawnl+0x12>
	const char *argv[argc+2];
  801fbf:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  801fc6:	83 e0 f0             	and    $0xfffffff0,%eax
  801fc9:	29 c4                	sub    %eax,%esp
  801fcb:	8d 44 24 0b          	lea    0xb(%esp),%eax
  801fcf:	c1 e8 02             	shr    $0x2,%eax
  801fd2:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801fd9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fde:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801fe5:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  801fec:	00 
	for(i=0;i<argc;i++)
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff2:	eb 0a                	jmp    801ffe <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  801ff4:	83 c0 01             	add    $0x1,%eax
  801ff7:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ffb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	for(i=0;i<argc;i++)
  801ffe:	39 d0                	cmp    %edx,%eax
  802000:	75 f2                	jne    801ff4 <spawnl+0x53>
	return spawn(prog, argv);
  802002:	89 74 24 04          	mov    %esi,0x4(%esp)
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	89 04 24             	mov    %eax,(%esp)
  80200c:	e8 4f fa ff ff       	call   801a60 <spawn>
}
  802011:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802014:	5b                   	pop    %ebx
  802015:	5e                   	pop    %esi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    

00802018 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	56                   	push   %esi
  80201c:	53                   	push   %ebx
  80201d:	83 ec 10             	sub    $0x10,%esp
  802020:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802023:	8b 45 08             	mov    0x8(%ebp),%eax
  802026:	89 04 24             	mov    %eax,(%esp)
  802029:	e8 f2 f1 ff ff       	call   801220 <fd2data>
  80202e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802030:	c7 44 24 04 08 2e 80 	movl   $0x802e08,0x4(%esp)
  802037:	00 
  802038:	89 1c 24             	mov    %ebx,(%esp)
  80203b:	e8 47 eb ff ff       	call   800b87 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802040:	8b 46 04             	mov    0x4(%esi),%eax
  802043:	2b 06                	sub    (%esi),%eax
  802045:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80204b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802052:	00 00 00 
	stat->st_dev = &devpipe;
  802055:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  80205c:	47 80 00 
	return 0;
}
  80205f:	b8 00 00 00 00       	mov    $0x0,%eax
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	5b                   	pop    %ebx
  802068:	5e                   	pop    %esi
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    

0080206b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	53                   	push   %ebx
  80206f:	83 ec 14             	sub    $0x14,%esp
  802072:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802075:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802079:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802080:	e8 c5 ef ff ff       	call   80104a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802085:	89 1c 24             	mov    %ebx,(%esp)
  802088:	e8 93 f1 ff ff       	call   801220 <fd2data>
  80208d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802091:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802098:	e8 ad ef ff ff       	call   80104a <sys_page_unmap>
}
  80209d:	83 c4 14             	add    $0x14,%esp
  8020a0:	5b                   	pop    %ebx
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    

008020a3 <_pipeisclosed>:
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	57                   	push   %edi
  8020a7:	56                   	push   %esi
  8020a8:	53                   	push   %ebx
  8020a9:	83 ec 2c             	sub    $0x2c,%esp
  8020ac:	89 c6                	mov    %eax,%esi
  8020ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8020b1:	a1 90 67 80 00       	mov    0x806790,%eax
  8020b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020b9:	89 34 24             	mov    %esi,(%esp)
  8020bc:	e8 46 04 00 00       	call   802507 <pageref>
  8020c1:	89 c7                	mov    %eax,%edi
  8020c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020c6:	89 04 24             	mov    %eax,(%esp)
  8020c9:	e8 39 04 00 00       	call   802507 <pageref>
  8020ce:	39 c7                	cmp    %eax,%edi
  8020d0:	0f 94 c2             	sete   %dl
  8020d3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8020d6:	8b 0d 90 67 80 00    	mov    0x806790,%ecx
  8020dc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8020df:	39 fb                	cmp    %edi,%ebx
  8020e1:	74 21                	je     802104 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  8020e3:	84 d2                	test   %dl,%dl
  8020e5:	74 ca                	je     8020b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020e7:	8b 51 58             	mov    0x58(%ecx),%edx
  8020ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ee:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020f6:	c7 04 24 0f 2e 80 00 	movl   $0x802e0f,(%esp)
  8020fd:	e8 5e e4 ff ff       	call   800560 <cprintf>
  802102:	eb ad                	jmp    8020b1 <_pipeisclosed+0xe>
}
  802104:	83 c4 2c             	add    $0x2c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    

0080210c <devpipe_write>:
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	57                   	push   %edi
  802110:	56                   	push   %esi
  802111:	53                   	push   %ebx
  802112:	83 ec 1c             	sub    $0x1c,%esp
  802115:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802118:	89 34 24             	mov    %esi,(%esp)
  80211b:	e8 00 f1 ff ff       	call   801220 <fd2data>
  802120:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802122:	bf 00 00 00 00       	mov    $0x0,%edi
  802127:	eb 45                	jmp    80216e <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  802129:	89 da                	mov    %ebx,%edx
  80212b:	89 f0                	mov    %esi,%eax
  80212d:	e8 71 ff ff ff       	call   8020a3 <_pipeisclosed>
  802132:	85 c0                	test   %eax,%eax
  802134:	75 41                	jne    802177 <devpipe_write+0x6b>
			sys_yield();
  802136:	e8 49 ee ff ff       	call   800f84 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80213b:	8b 43 04             	mov    0x4(%ebx),%eax
  80213e:	8b 0b                	mov    (%ebx),%ecx
  802140:	8d 51 20             	lea    0x20(%ecx),%edx
  802143:	39 d0                	cmp    %edx,%eax
  802145:	73 e2                	jae    802129 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80214a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80214e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802151:	99                   	cltd   
  802152:	c1 ea 1b             	shr    $0x1b,%edx
  802155:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802158:	83 e1 1f             	and    $0x1f,%ecx
  80215b:	29 d1                	sub    %edx,%ecx
  80215d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802161:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802165:	83 c0 01             	add    $0x1,%eax
  802168:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80216b:	83 c7 01             	add    $0x1,%edi
  80216e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802171:	75 c8                	jne    80213b <devpipe_write+0x2f>
	return i;
  802173:	89 f8                	mov    %edi,%eax
  802175:	eb 05                	jmp    80217c <devpipe_write+0x70>
				return 0;
  802177:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    

00802184 <devpipe_read>:
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	57                   	push   %edi
  802188:	56                   	push   %esi
  802189:	53                   	push   %ebx
  80218a:	83 ec 1c             	sub    $0x1c,%esp
  80218d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802190:	89 3c 24             	mov    %edi,(%esp)
  802193:	e8 88 f0 ff ff       	call   801220 <fd2data>
  802198:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80219a:	be 00 00 00 00       	mov    $0x0,%esi
  80219f:	eb 3d                	jmp    8021de <devpipe_read+0x5a>
			if (i > 0)
  8021a1:	85 f6                	test   %esi,%esi
  8021a3:	74 04                	je     8021a9 <devpipe_read+0x25>
				return i;
  8021a5:	89 f0                	mov    %esi,%eax
  8021a7:	eb 43                	jmp    8021ec <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  8021a9:	89 da                	mov    %ebx,%edx
  8021ab:	89 f8                	mov    %edi,%eax
  8021ad:	e8 f1 fe ff ff       	call   8020a3 <_pipeisclosed>
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	75 31                	jne    8021e7 <devpipe_read+0x63>
			sys_yield();
  8021b6:	e8 c9 ed ff ff       	call   800f84 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8021bb:	8b 03                	mov    (%ebx),%eax
  8021bd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021c0:	74 df                	je     8021a1 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021c2:	99                   	cltd   
  8021c3:	c1 ea 1b             	shr    $0x1b,%edx
  8021c6:	01 d0                	add    %edx,%eax
  8021c8:	83 e0 1f             	and    $0x1f,%eax
  8021cb:	29 d0                	sub    %edx,%eax
  8021cd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8021d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8021d8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8021db:	83 c6 01             	add    $0x1,%esi
  8021de:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021e1:	75 d8                	jne    8021bb <devpipe_read+0x37>
	return i;
  8021e3:	89 f0                	mov    %esi,%eax
  8021e5:	eb 05                	jmp    8021ec <devpipe_read+0x68>
				return 0;
  8021e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    

008021f4 <pipe>:
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	56                   	push   %esi
  8021f8:	53                   	push   %ebx
  8021f9:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8021fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ff:	89 04 24             	mov    %eax,(%esp)
  802202:	e8 30 f0 ff ff       	call   801237 <fd_alloc>
  802207:	89 c2                	mov    %eax,%edx
  802209:	85 d2                	test   %edx,%edx
  80220b:	0f 88 4d 01 00 00    	js     80235e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802211:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802218:	00 
  802219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802220:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802227:	e8 77 ed ff ff       	call   800fa3 <sys_page_alloc>
  80222c:	89 c2                	mov    %eax,%edx
  80222e:	85 d2                	test   %edx,%edx
  802230:	0f 88 28 01 00 00    	js     80235e <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  802236:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802239:	89 04 24             	mov    %eax,(%esp)
  80223c:	e8 f6 ef ff ff       	call   801237 <fd_alloc>
  802241:	89 c3                	mov    %eax,%ebx
  802243:	85 c0                	test   %eax,%eax
  802245:	0f 88 fe 00 00 00    	js     802349 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80224b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802252:	00 
  802253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802261:	e8 3d ed ff ff       	call   800fa3 <sys_page_alloc>
  802266:	89 c3                	mov    %eax,%ebx
  802268:	85 c0                	test   %eax,%eax
  80226a:	0f 88 d9 00 00 00    	js     802349 <pipe+0x155>
	va = fd2data(fd0);
  802270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802273:	89 04 24             	mov    %eax,(%esp)
  802276:	e8 a5 ef ff ff       	call   801220 <fd2data>
  80227b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80227d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802284:	00 
  802285:	89 44 24 04          	mov    %eax,0x4(%esp)
  802289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802290:	e8 0e ed ff ff       	call   800fa3 <sys_page_alloc>
  802295:	89 c3                	mov    %eax,%ebx
  802297:	85 c0                	test   %eax,%eax
  802299:	0f 88 97 00 00 00    	js     802336 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80229f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022a2:	89 04 24             	mov    %eax,(%esp)
  8022a5:	e8 76 ef ff ff       	call   801220 <fd2data>
  8022aa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022b1:	00 
  8022b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022bd:	00 
  8022be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c9:	e8 29 ed ff ff       	call   800ff7 <sys_page_map>
  8022ce:	89 c3                	mov    %eax,%ebx
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	78 52                	js     802326 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  8022d4:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8022da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8022e9:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8022ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8022fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802301:	89 04 24             	mov    %eax,(%esp)
  802304:	e8 07 ef ff ff       	call   801210 <fd2num>
  802309:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80230c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80230e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802311:	89 04 24             	mov    %eax,(%esp)
  802314:	e8 f7 ee ff ff       	call   801210 <fd2num>
  802319:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80231c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80231f:	b8 00 00 00 00       	mov    $0x0,%eax
  802324:	eb 38                	jmp    80235e <pipe+0x16a>
	sys_page_unmap(0, va);
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802331:	e8 14 ed ff ff       	call   80104a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  802336:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802344:	e8 01 ed ff ff       	call   80104a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  802349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802350:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802357:	e8 ee ec ff ff       	call   80104a <sys_page_unmap>
  80235c:	89 d8                	mov    %ebx,%eax
}
  80235e:	83 c4 30             	add    $0x30,%esp
  802361:	5b                   	pop    %ebx
  802362:	5e                   	pop    %esi
  802363:	5d                   	pop    %ebp
  802364:	c3                   	ret    

00802365 <pipeisclosed>:
{
  802365:	55                   	push   %ebp
  802366:	89 e5                	mov    %esp,%ebp
  802368:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80236b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802372:	8b 45 08             	mov    0x8(%ebp),%eax
  802375:	89 04 24             	mov    %eax,(%esp)
  802378:	e8 09 ef ff ff       	call   801286 <fd_lookup>
  80237d:	89 c2                	mov    %eax,%edx
  80237f:	85 d2                	test   %edx,%edx
  802381:	78 15                	js     802398 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  802383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802386:	89 04 24             	mov    %eax,(%esp)
  802389:	e8 92 ee ff ff       	call   801220 <fd2data>
	return _pipeisclosed(fd, p);
  80238e:	89 c2                	mov    %eax,%edx
  802390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802393:	e8 0b fd ff ff       	call   8020a3 <_pipeisclosed>
}
  802398:	c9                   	leave  
  802399:	c3                   	ret    

0080239a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80239a:	55                   	push   %ebp
  80239b:	89 e5                	mov    %esp,%ebp
  80239d:	56                   	push   %esi
  80239e:	53                   	push   %ebx
  80239f:	83 ec 10             	sub    $0x10,%esp
  8023a2:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8023a5:	85 f6                	test   %esi,%esi
  8023a7:	75 24                	jne    8023cd <wait+0x33>
  8023a9:	c7 44 24 0c 27 2e 80 	movl   $0x802e27,0xc(%esp)
  8023b0:	00 
  8023b1:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  8023b8:	00 
  8023b9:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8023c0:	00 
  8023c1:	c7 04 24 32 2e 80 00 	movl   $0x802e32,(%esp)
  8023c8:	e8 9a e0 ff ff       	call   800467 <_panic>
	e = &envs[ENVX(envid)];
  8023cd:	89 f3                	mov    %esi,%ebx
  8023cf:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8023d5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8023d8:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8023de:	eb 05                	jmp    8023e5 <wait+0x4b>
		sys_yield();
  8023e0:	e8 9f eb ff ff       	call   800f84 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8023e5:	8b 43 48             	mov    0x48(%ebx),%eax
  8023e8:	39 f0                	cmp    %esi,%eax
  8023ea:	75 07                	jne    8023f3 <wait+0x59>
  8023ec:	8b 43 54             	mov    0x54(%ebx),%eax
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	75 ed                	jne    8023e0 <wait+0x46>
}
  8023f3:	83 c4 10             	add    $0x10,%esp
  8023f6:	5b                   	pop    %ebx
  8023f7:	5e                   	pop    %esi
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    
  8023fa:	66 90                	xchg   %ax,%ax
  8023fc:	66 90                	xchg   %ax,%ax
  8023fe:	66 90                	xchg   %ax,%ax

00802400 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	56                   	push   %esi
  802404:	53                   	push   %ebx
  802405:	83 ec 10             	sub    $0x10,%esp
  802408:	8b 75 08             	mov    0x8(%ebp),%esi
  80240b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80240e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802411:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802413:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802418:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80241b:	89 04 24             	mov    %eax,(%esp)
  80241e:	e8 96 ed ff ff       	call   8011b9 <sys_ipc_recv>
    if(r < 0){
  802423:	85 c0                	test   %eax,%eax
  802425:	79 16                	jns    80243d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802427:	85 f6                	test   %esi,%esi
  802429:	74 06                	je     802431 <ipc_recv+0x31>
            *from_env_store = 0;
  80242b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802431:	85 db                	test   %ebx,%ebx
  802433:	74 2c                	je     802461 <ipc_recv+0x61>
            *perm_store = 0;
  802435:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80243b:	eb 24                	jmp    802461 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80243d:	85 f6                	test   %esi,%esi
  80243f:	74 0a                	je     80244b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802441:	a1 90 67 80 00       	mov    0x806790,%eax
  802446:	8b 40 74             	mov    0x74(%eax),%eax
  802449:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80244b:	85 db                	test   %ebx,%ebx
  80244d:	74 0a                	je     802459 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80244f:	a1 90 67 80 00       	mov    0x806790,%eax
  802454:	8b 40 78             	mov    0x78(%eax),%eax
  802457:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802459:	a1 90 67 80 00       	mov    0x806790,%eax
  80245e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802461:	83 c4 10             	add    $0x10,%esp
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    

00802468 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
  80246b:	57                   	push   %edi
  80246c:	56                   	push   %esi
  80246d:	53                   	push   %ebx
  80246e:	83 ec 1c             	sub    $0x1c,%esp
  802471:	8b 7d 08             	mov    0x8(%ebp),%edi
  802474:	8b 75 0c             	mov    0xc(%ebp),%esi
  802477:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80247a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80247c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802481:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802484:	8b 45 14             	mov    0x14(%ebp),%eax
  802487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80248b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802493:	89 3c 24             	mov    %edi,(%esp)
  802496:	e8 fb ec ff ff       	call   801196 <sys_ipc_try_send>
        if(r == 0){
  80249b:	85 c0                	test   %eax,%eax
  80249d:	74 28                	je     8024c7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80249f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024a2:	74 1c                	je     8024c0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8024a4:	c7 44 24 08 3d 2e 80 	movl   $0x802e3d,0x8(%esp)
  8024ab:	00 
  8024ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8024b3:	00 
  8024b4:	c7 04 24 54 2e 80 00 	movl   $0x802e54,(%esp)
  8024bb:	e8 a7 df ff ff       	call   800467 <_panic>
        }
        sys_yield();
  8024c0:	e8 bf ea ff ff       	call   800f84 <sys_yield>
    }
  8024c5:	eb bd                	jmp    802484 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8024c7:	83 c4 1c             	add    $0x1c,%esp
  8024ca:	5b                   	pop    %ebx
  8024cb:	5e                   	pop    %esi
  8024cc:	5f                   	pop    %edi
  8024cd:	5d                   	pop    %ebp
  8024ce:	c3                   	ret    

008024cf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024cf:	55                   	push   %ebp
  8024d0:	89 e5                	mov    %esp,%ebp
  8024d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024d5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024da:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024dd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024e3:	8b 52 50             	mov    0x50(%edx),%edx
  8024e6:	39 ca                	cmp    %ecx,%edx
  8024e8:	75 0d                	jne    8024f7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024ea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024ed:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8024f2:	8b 40 40             	mov    0x40(%eax),%eax
  8024f5:	eb 0e                	jmp    802505 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  8024f7:	83 c0 01             	add    $0x1,%eax
  8024fa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024ff:	75 d9                	jne    8024da <ipc_find_env+0xb>
	return 0;
  802501:	66 b8 00 00          	mov    $0x0,%ax
}
  802505:	5d                   	pop    %ebp
  802506:	c3                   	ret    

00802507 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802507:	55                   	push   %ebp
  802508:	89 e5                	mov    %esp,%ebp
  80250a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80250d:	89 d0                	mov    %edx,%eax
  80250f:	c1 e8 16             	shr    $0x16,%eax
  802512:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802519:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80251e:	f6 c1 01             	test   $0x1,%cl
  802521:	74 1d                	je     802540 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802523:	c1 ea 0c             	shr    $0xc,%edx
  802526:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80252d:	f6 c2 01             	test   $0x1,%dl
  802530:	74 0e                	je     802540 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802532:	c1 ea 0c             	shr    $0xc,%edx
  802535:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80253c:	ef 
  80253d:	0f b7 c0             	movzwl %ax,%eax
}
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	66 90                	xchg   %ax,%ax
  802544:	66 90                	xchg   %ax,%ax
  802546:	66 90                	xchg   %ax,%ax
  802548:	66 90                	xchg   %ax,%ax
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	83 ec 0c             	sub    $0xc,%esp
  802556:	8b 44 24 28          	mov    0x28(%esp),%eax
  80255a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80255e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802562:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802566:	85 c0                	test   %eax,%eax
  802568:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80256c:	89 ea                	mov    %ebp,%edx
  80256e:	89 0c 24             	mov    %ecx,(%esp)
  802571:	75 2d                	jne    8025a0 <__udivdi3+0x50>
  802573:	39 e9                	cmp    %ebp,%ecx
  802575:	77 61                	ja     8025d8 <__udivdi3+0x88>
  802577:	85 c9                	test   %ecx,%ecx
  802579:	89 ce                	mov    %ecx,%esi
  80257b:	75 0b                	jne    802588 <__udivdi3+0x38>
  80257d:	b8 01 00 00 00       	mov    $0x1,%eax
  802582:	31 d2                	xor    %edx,%edx
  802584:	f7 f1                	div    %ecx
  802586:	89 c6                	mov    %eax,%esi
  802588:	31 d2                	xor    %edx,%edx
  80258a:	89 e8                	mov    %ebp,%eax
  80258c:	f7 f6                	div    %esi
  80258e:	89 c5                	mov    %eax,%ebp
  802590:	89 f8                	mov    %edi,%eax
  802592:	f7 f6                	div    %esi
  802594:	89 ea                	mov    %ebp,%edx
  802596:	83 c4 0c             	add    $0xc,%esp
  802599:	5e                   	pop    %esi
  80259a:	5f                   	pop    %edi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    
  80259d:	8d 76 00             	lea    0x0(%esi),%esi
  8025a0:	39 e8                	cmp    %ebp,%eax
  8025a2:	77 24                	ja     8025c8 <__udivdi3+0x78>
  8025a4:	0f bd e8             	bsr    %eax,%ebp
  8025a7:	83 f5 1f             	xor    $0x1f,%ebp
  8025aa:	75 3c                	jne    8025e8 <__udivdi3+0x98>
  8025ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025b0:	39 34 24             	cmp    %esi,(%esp)
  8025b3:	0f 86 9f 00 00 00    	jbe    802658 <__udivdi3+0x108>
  8025b9:	39 d0                	cmp    %edx,%eax
  8025bb:	0f 82 97 00 00 00    	jb     802658 <__udivdi3+0x108>
  8025c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c8:	31 d2                	xor    %edx,%edx
  8025ca:	31 c0                	xor    %eax,%eax
  8025cc:	83 c4 0c             	add    $0xc,%esp
  8025cf:	5e                   	pop    %esi
  8025d0:	5f                   	pop    %edi
  8025d1:	5d                   	pop    %ebp
  8025d2:	c3                   	ret    
  8025d3:	90                   	nop
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	89 f8                	mov    %edi,%eax
  8025da:	f7 f1                	div    %ecx
  8025dc:	31 d2                	xor    %edx,%edx
  8025de:	83 c4 0c             	add    $0xc,%esp
  8025e1:	5e                   	pop    %esi
  8025e2:	5f                   	pop    %edi
  8025e3:	5d                   	pop    %ebp
  8025e4:	c3                   	ret    
  8025e5:	8d 76 00             	lea    0x0(%esi),%esi
  8025e8:	89 e9                	mov    %ebp,%ecx
  8025ea:	8b 3c 24             	mov    (%esp),%edi
  8025ed:	d3 e0                	shl    %cl,%eax
  8025ef:	89 c6                	mov    %eax,%esi
  8025f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8025f6:	29 e8                	sub    %ebp,%eax
  8025f8:	89 c1                	mov    %eax,%ecx
  8025fa:	d3 ef                	shr    %cl,%edi
  8025fc:	89 e9                	mov    %ebp,%ecx
  8025fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802602:	8b 3c 24             	mov    (%esp),%edi
  802605:	09 74 24 08          	or     %esi,0x8(%esp)
  802609:	89 d6                	mov    %edx,%esi
  80260b:	d3 e7                	shl    %cl,%edi
  80260d:	89 c1                	mov    %eax,%ecx
  80260f:	89 3c 24             	mov    %edi,(%esp)
  802612:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802616:	d3 ee                	shr    %cl,%esi
  802618:	89 e9                	mov    %ebp,%ecx
  80261a:	d3 e2                	shl    %cl,%edx
  80261c:	89 c1                	mov    %eax,%ecx
  80261e:	d3 ef                	shr    %cl,%edi
  802620:	09 d7                	or     %edx,%edi
  802622:	89 f2                	mov    %esi,%edx
  802624:	89 f8                	mov    %edi,%eax
  802626:	f7 74 24 08          	divl   0x8(%esp)
  80262a:	89 d6                	mov    %edx,%esi
  80262c:	89 c7                	mov    %eax,%edi
  80262e:	f7 24 24             	mull   (%esp)
  802631:	39 d6                	cmp    %edx,%esi
  802633:	89 14 24             	mov    %edx,(%esp)
  802636:	72 30                	jb     802668 <__udivdi3+0x118>
  802638:	8b 54 24 04          	mov    0x4(%esp),%edx
  80263c:	89 e9                	mov    %ebp,%ecx
  80263e:	d3 e2                	shl    %cl,%edx
  802640:	39 c2                	cmp    %eax,%edx
  802642:	73 05                	jae    802649 <__udivdi3+0xf9>
  802644:	3b 34 24             	cmp    (%esp),%esi
  802647:	74 1f                	je     802668 <__udivdi3+0x118>
  802649:	89 f8                	mov    %edi,%eax
  80264b:	31 d2                	xor    %edx,%edx
  80264d:	e9 7a ff ff ff       	jmp    8025cc <__udivdi3+0x7c>
  802652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802658:	31 d2                	xor    %edx,%edx
  80265a:	b8 01 00 00 00       	mov    $0x1,%eax
  80265f:	e9 68 ff ff ff       	jmp    8025cc <__udivdi3+0x7c>
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	8d 47 ff             	lea    -0x1(%edi),%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	83 c4 0c             	add    $0xc,%esp
  802670:	5e                   	pop    %esi
  802671:	5f                   	pop    %edi
  802672:	5d                   	pop    %ebp
  802673:	c3                   	ret    
  802674:	66 90                	xchg   %ax,%ax
  802676:	66 90                	xchg   %ax,%ax
  802678:	66 90                	xchg   %ax,%ax
  80267a:	66 90                	xchg   %ax,%ax
  80267c:	66 90                	xchg   %ax,%ax
  80267e:	66 90                	xchg   %ax,%ax

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	57                   	push   %edi
  802682:	56                   	push   %esi
  802683:	83 ec 14             	sub    $0x14,%esp
  802686:	8b 44 24 28          	mov    0x28(%esp),%eax
  80268a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80268e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802692:	89 c7                	mov    %eax,%edi
  802694:	89 44 24 04          	mov    %eax,0x4(%esp)
  802698:	8b 44 24 30          	mov    0x30(%esp),%eax
  80269c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8026a0:	89 34 24             	mov    %esi,(%esp)
  8026a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026a7:	85 c0                	test   %eax,%eax
  8026a9:	89 c2                	mov    %eax,%edx
  8026ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026af:	75 17                	jne    8026c8 <__umoddi3+0x48>
  8026b1:	39 fe                	cmp    %edi,%esi
  8026b3:	76 4b                	jbe    802700 <__umoddi3+0x80>
  8026b5:	89 c8                	mov    %ecx,%eax
  8026b7:	89 fa                	mov    %edi,%edx
  8026b9:	f7 f6                	div    %esi
  8026bb:	89 d0                	mov    %edx,%eax
  8026bd:	31 d2                	xor    %edx,%edx
  8026bf:	83 c4 14             	add    $0x14,%esp
  8026c2:	5e                   	pop    %esi
  8026c3:	5f                   	pop    %edi
  8026c4:	5d                   	pop    %ebp
  8026c5:	c3                   	ret    
  8026c6:	66 90                	xchg   %ax,%ax
  8026c8:	39 f8                	cmp    %edi,%eax
  8026ca:	77 54                	ja     802720 <__umoddi3+0xa0>
  8026cc:	0f bd e8             	bsr    %eax,%ebp
  8026cf:	83 f5 1f             	xor    $0x1f,%ebp
  8026d2:	75 5c                	jne    802730 <__umoddi3+0xb0>
  8026d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8026d8:	39 3c 24             	cmp    %edi,(%esp)
  8026db:	0f 87 e7 00 00 00    	ja     8027c8 <__umoddi3+0x148>
  8026e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8026e5:	29 f1                	sub    %esi,%ecx
  8026e7:	19 c7                	sbb    %eax,%edi
  8026e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026f9:	83 c4 14             	add    $0x14,%esp
  8026fc:	5e                   	pop    %esi
  8026fd:	5f                   	pop    %edi
  8026fe:	5d                   	pop    %ebp
  8026ff:	c3                   	ret    
  802700:	85 f6                	test   %esi,%esi
  802702:	89 f5                	mov    %esi,%ebp
  802704:	75 0b                	jne    802711 <__umoddi3+0x91>
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	f7 f6                	div    %esi
  80270f:	89 c5                	mov    %eax,%ebp
  802711:	8b 44 24 04          	mov    0x4(%esp),%eax
  802715:	31 d2                	xor    %edx,%edx
  802717:	f7 f5                	div    %ebp
  802719:	89 c8                	mov    %ecx,%eax
  80271b:	f7 f5                	div    %ebp
  80271d:	eb 9c                	jmp    8026bb <__umoddi3+0x3b>
  80271f:	90                   	nop
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 fa                	mov    %edi,%edx
  802724:	83 c4 14             	add    $0x14,%esp
  802727:	5e                   	pop    %esi
  802728:	5f                   	pop    %edi
  802729:	5d                   	pop    %ebp
  80272a:	c3                   	ret    
  80272b:	90                   	nop
  80272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802730:	8b 04 24             	mov    (%esp),%eax
  802733:	be 20 00 00 00       	mov    $0x20,%esi
  802738:	89 e9                	mov    %ebp,%ecx
  80273a:	29 ee                	sub    %ebp,%esi
  80273c:	d3 e2                	shl    %cl,%edx
  80273e:	89 f1                	mov    %esi,%ecx
  802740:	d3 e8                	shr    %cl,%eax
  802742:	89 e9                	mov    %ebp,%ecx
  802744:	89 44 24 04          	mov    %eax,0x4(%esp)
  802748:	8b 04 24             	mov    (%esp),%eax
  80274b:	09 54 24 04          	or     %edx,0x4(%esp)
  80274f:	89 fa                	mov    %edi,%edx
  802751:	d3 e0                	shl    %cl,%eax
  802753:	89 f1                	mov    %esi,%ecx
  802755:	89 44 24 08          	mov    %eax,0x8(%esp)
  802759:	8b 44 24 10          	mov    0x10(%esp),%eax
  80275d:	d3 ea                	shr    %cl,%edx
  80275f:	89 e9                	mov    %ebp,%ecx
  802761:	d3 e7                	shl    %cl,%edi
  802763:	89 f1                	mov    %esi,%ecx
  802765:	d3 e8                	shr    %cl,%eax
  802767:	89 e9                	mov    %ebp,%ecx
  802769:	09 f8                	or     %edi,%eax
  80276b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80276f:	f7 74 24 04          	divl   0x4(%esp)
  802773:	d3 e7                	shl    %cl,%edi
  802775:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802779:	89 d7                	mov    %edx,%edi
  80277b:	f7 64 24 08          	mull   0x8(%esp)
  80277f:	39 d7                	cmp    %edx,%edi
  802781:	89 c1                	mov    %eax,%ecx
  802783:	89 14 24             	mov    %edx,(%esp)
  802786:	72 2c                	jb     8027b4 <__umoddi3+0x134>
  802788:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80278c:	72 22                	jb     8027b0 <__umoddi3+0x130>
  80278e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802792:	29 c8                	sub    %ecx,%eax
  802794:	19 d7                	sbb    %edx,%edi
  802796:	89 e9                	mov    %ebp,%ecx
  802798:	89 fa                	mov    %edi,%edx
  80279a:	d3 e8                	shr    %cl,%eax
  80279c:	89 f1                	mov    %esi,%ecx
  80279e:	d3 e2                	shl    %cl,%edx
  8027a0:	89 e9                	mov    %ebp,%ecx
  8027a2:	d3 ef                	shr    %cl,%edi
  8027a4:	09 d0                	or     %edx,%eax
  8027a6:	89 fa                	mov    %edi,%edx
  8027a8:	83 c4 14             	add    $0x14,%esp
  8027ab:	5e                   	pop    %esi
  8027ac:	5f                   	pop    %edi
  8027ad:	5d                   	pop    %ebp
  8027ae:	c3                   	ret    
  8027af:	90                   	nop
  8027b0:	39 d7                	cmp    %edx,%edi
  8027b2:	75 da                	jne    80278e <__umoddi3+0x10e>
  8027b4:	8b 14 24             	mov    (%esp),%edx
  8027b7:	89 c1                	mov    %eax,%ecx
  8027b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8027bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8027c1:	eb cb                	jmp    80278e <__umoddi3+0x10e>
  8027c3:	90                   	nop
  8027c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8027cc:	0f 82 0f ff ff ff    	jb     8026e1 <__umoddi3+0x61>
  8027d2:	e9 1a ff ff ff       	jmp    8026f1 <__umoddi3+0x71>
