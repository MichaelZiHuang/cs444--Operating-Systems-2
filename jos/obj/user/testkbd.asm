
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 95 02 00 00       	call   8002c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 f0 0e 00 00       	call   800f34 <sys_yield>
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>

	close(0);
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 0d 13 00 00       	call   801362 <close>
	if ((r = opencons()) < 0)
  800055:	e8 11 02 00 00       	call   80026b <opencons>
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4b>
		panic("opencons: %e", r);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 c0 22 80 	movl   $0x8022c0,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 cd 22 80 00 	movl   $0x8022cd,(%esp)
  800079:	e8 a9 02 00 00       	call   800327 <_panic>
	if (r != 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	74 20                	je     8000a2 <umain+0x6f>
		panic("first opencons used fd %d", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 cd 22 80 00 	movl   $0x8022cd,(%esp)
  80009d:	e8 85 02 00 00       	call   800327 <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000a9:	00 
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 01 13 00 00       	call   8013b7 <dup>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	79 20                	jns    8000da <umain+0xa7>
		panic("dup: %e", r);
  8000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000be:	c7 44 24 08 f6 22 80 	movl   $0x8022f6,0x8(%esp)
  8000c5:	00 
  8000c6:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000cd:	00 
  8000ce:	c7 04 24 cd 22 80 00 	movl   $0x8022cd,(%esp)
  8000d5:	e8 4d 02 00 00       	call   800327 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000da:	c7 04 24 fe 22 80 00 	movl   $0x8022fe,(%esp)
  8000e1:	e8 2a 09 00 00       	call   800a10 <readline>
		if (buf != NULL)
  8000e6:	85 c0                	test   %eax,%eax
  8000e8:	74 1a                	je     800104 <umain+0xd1>
			fprintf(1, "%s\n", buf);
  8000ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ee:	c7 44 24 04 0c 23 80 	movl   $0x80230c,0x4(%esp)
  8000f5:	00 
  8000f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fd:	e8 fe 19 00 00       	call   801b00 <fprintf>
  800102:	eb d6                	jmp    8000da <umain+0xa7>
		else
			fprintf(1, "(end of file received)\n");
  800104:	c7 44 24 04 10 23 80 	movl   $0x802310,0x4(%esp)
  80010b:	00 
  80010c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800113:	e8 e8 19 00 00       	call   801b00 <fprintf>
  800118:	eb c0                	jmp    8000da <umain+0xa7>
  80011a:	66 90                	xchg   %ax,%ax
  80011c:	66 90                	xchg   %ax,%ax
  80011e:	66 90                	xchg   %ax,%ax

00800120 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800123:	b8 00 00 00 00       	mov    $0x0,%eax
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800130:	c7 44 24 04 28 23 80 	movl   $0x802328,0x4(%esp)
  800137:	00 
  800138:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013b:	89 04 24             	mov    %eax,(%esp)
  80013e:	e8 f4 09 00 00       	call   800b37 <strcpy>
	return 0;
}
  800143:	b8 00 00 00 00       	mov    $0x0,%eax
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <devcons_write>:
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
  800150:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  800156:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80015b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800161:	eb 31                	jmp    800194 <devcons_write+0x4a>
		m = n - tot;
  800163:	8b 75 10             	mov    0x10(%ebp),%esi
  800166:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800168:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80016b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800170:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800173:	89 74 24 08          	mov    %esi,0x8(%esp)
  800177:	03 45 0c             	add    0xc(%ebp),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	89 3c 24             	mov    %edi,(%esp)
  800181:	e8 4e 0b 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  800186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018a:	89 3c 24             	mov    %edi,(%esp)
  80018d:	e8 f4 0c 00 00       	call   800e86 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800192:	01 f3                	add    %esi,%ebx
  800194:	89 d8                	mov    %ebx,%eax
  800196:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800199:	72 c8                	jb     800163 <devcons_write+0x19>
}
  80019b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <devcons_read>:
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  8001ac:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8001b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8001b5:	75 07                	jne    8001be <devcons_read+0x18>
  8001b7:	eb 2a                	jmp    8001e3 <devcons_read+0x3d>
		sys_yield();
  8001b9:	e8 76 0d 00 00       	call   800f34 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8001be:	66 90                	xchg   %ax,%ax
  8001c0:	e8 df 0c 00 00       	call   800ea4 <sys_cgetc>
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	74 f0                	je     8001b9 <devcons_read+0x13>
	if (c < 0)
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	78 16                	js     8001e3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  8001cd:	83 f8 04             	cmp    $0x4,%eax
  8001d0:	74 0c                	je     8001de <devcons_read+0x38>
	*(char*)vbuf = c;
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	88 02                	mov    %al,(%edx)
	return 1;
  8001d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8001dc:	eb 05                	jmp    8001e3 <devcons_read+0x3d>
		return 0;
  8001de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <cputchar>:
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8001eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ee:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8001f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f8:	00 
  8001f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	e8 82 0c 00 00       	call   800e86 <sys_cputs>
}
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <getchar>:
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80020c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800213:	00 
  800214:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800222:	e8 9e 12 00 00       	call   8014c5 <read>
	if (r < 0)
  800227:	85 c0                	test   %eax,%eax
  800229:	78 0f                	js     80023a <getchar+0x34>
	if (r < 1)
  80022b:	85 c0                	test   %eax,%eax
  80022d:	7e 06                	jle    800235 <getchar+0x2f>
	return c;
  80022f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800233:	eb 05                	jmp    80023a <getchar+0x34>
		return -E_EOF;
  800235:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <iscons>:
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800242:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 e2 0f 00 00       	call   801236 <fd_lookup>
  800254:	85 c0                	test   %eax,%eax
  800256:	78 11                	js     800269 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  800258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80025b:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800261:	39 10                	cmp    %edx,(%eax)
  800263:	0f 94 c0             	sete   %al
  800266:	0f b6 c0             	movzbl %al,%eax
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <opencons>:
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 6b 0f 00 00       	call   8011e7 <fd_alloc>
		return r;
  80027c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	78 40                	js     8002c2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800282:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800289:	00 
  80028a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80028d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800298:	e8 b6 0c 00 00       	call   800f53 <sys_page_alloc>
		return r;
  80029d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	78 1f                	js     8002c2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8002a3:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8002a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002ac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8002ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	e8 00 0f 00 00       	call   8011c0 <fd2num>
  8002c0:	89 c2                	mov    %eax,%edx
}
  8002c2:	89 d0                	mov    %edx,%eax
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 10             	sub    $0x10,%esp
  8002ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8002d4:	e8 3c 0c 00 00       	call   800f15 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8002d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e6:	a3 24 44 80 00       	mov    %eax,0x804424
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002eb:	85 db                	test   %ebx,%ebx
  8002ed:	7e 07                	jle    8002f6 <libmain+0x30>
		binaryname = argv[0];
  8002ef:	8b 06                	mov    (%esi),%eax
  8002f1:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002fa:	89 1c 24             	mov    %ebx,(%esp)
  8002fd:	e8 31 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800302:	e8 07 00 00 00       	call   80030e <exit>
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800314:	e8 7c 10 00 00       	call   801395 <close_all>
	sys_env_destroy(0);
  800319:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800320:	e8 9e 0b 00 00       	call   800ec3 <sys_env_destroy>
}
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80032f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800332:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  800338:	e8 d8 0b 00 00       	call   800f15 <sys_getenvid>
  80033d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800340:	89 54 24 10          	mov    %edx,0x10(%esp)
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80034b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	c7 04 24 40 23 80 00 	movl   $0x802340,(%esp)
  80035a:	e8 c1 00 00 00       	call   800420 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800363:	8b 45 10             	mov    0x10(%ebp),%eax
  800366:	89 04 24             	mov    %eax,(%esp)
  800369:	e8 51 00 00 00       	call   8003bf <vcprintf>
	cprintf("\n");
  80036e:	c7 04 24 26 23 80 00 	movl   $0x802326,(%esp)
  800375:	e8 a6 00 00 00       	call   800420 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037a:	cc                   	int3   
  80037b:	eb fd                	jmp    80037a <_panic+0x53>

0080037d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	53                   	push   %ebx
  800381:	83 ec 14             	sub    $0x14,%esp
  800384:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800387:	8b 13                	mov    (%ebx),%edx
  800389:	8d 42 01             	lea    0x1(%edx),%eax
  80038c:	89 03                	mov    %eax,(%ebx)
  80038e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800391:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800395:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039a:	75 19                	jne    8003b5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80039c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003a3:	00 
  8003a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a7:	89 04 24             	mov    %eax,(%esp)
  8003aa:	e8 d7 0a 00 00       	call   800e86 <sys_cputs>
		b->idx = 0;
  8003af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b9:	83 c4 14             	add    $0x14,%esp
  8003bc:	5b                   	pop    %ebx
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cf:	00 00 00 
	b.cnt = 0;
  8003d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f4:	c7 04 24 7d 03 80 00 	movl   $0x80037d,(%esp)
  8003fb:	e8 ae 01 00 00       	call   8005ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800400:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 6e 0a 00 00       	call   800e86 <sys_cputs>

	return b.cnt;
}
  800418:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800426:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800429:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	e8 87 ff ff ff       	call   8003bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800438:	c9                   	leave  
  800439:	c3                   	ret    
  80043a:	66 90                	xchg   %ax,%ax
  80043c:	66 90                	xchg   %ax,%ax
  80043e:	66 90                	xchg   %ax,%ax

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
  8004af:	e8 6c 1b 00 00       	call   802020 <__udivdi3>
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
  80050f:	e8 3c 1c 00 00       	call   802150 <__umoddi3>
  800514:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800518:	0f be 80 63 23 80 00 	movsbl 0x802363(%eax),%eax
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
  80063e:	ff 24 8d a0 24 80 00 	jmp    *0x8024a0(,%ecx,4)
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
  8006db:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8006e2:	85 d2                	test   %edx,%edx
  8006e4:	75 20                	jne    800706 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  8006e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ea:	c7 44 24 08 7b 23 80 	movl   $0x80237b,0x8(%esp)
  8006f1:	00 
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	89 04 24             	mov    %eax,(%esp)
  8006fc:	e8 85 fe ff ff       	call   800586 <printfmt>
  800701:	e9 d8 fe ff ff       	jmp    8005de <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800706:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070a:	c7 44 24 08 6e 27 80 	movl   $0x80276e,0x8(%esp)
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
  80073c:	b8 74 23 80 00       	mov    $0x802374,%eax
  800741:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800744:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800748:	0f 84 97 00 00 00    	je     8007e5 <vprintfmt+0x237>
  80074e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800752:	0f 8e 9b 00 00 00    	jle    8007f3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800758:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80075c:	89 34 24             	mov    %esi,(%esp)
  80075f:	e8 b4 03 00 00       	call   800b18 <strnlen>
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

00800a10 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	83 ec 1c             	sub    $0x1c,%esp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800a1c:	85 c0                	test   %eax,%eax
  800a1e:	74 18                	je     800a38 <readline+0x28>
		fprintf(1, "%s", prompt);
  800a20:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a24:	c7 44 24 04 6e 27 80 	movl   $0x80276e,0x4(%esp)
  800a2b:	00 
  800a2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a33:	e8 c8 10 00 00       	call   801b00 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  800a38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a3f:	e8 f8 f7 ff ff       	call   80023c <iscons>
  800a44:	89 c7                	mov    %eax,%edi
	i = 0;
  800a46:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
  800a4b:	e8 b6 f7 ff ff       	call   800206 <getchar>
  800a50:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800a52:	85 c0                	test   %eax,%eax
  800a54:	79 25                	jns    800a7b <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  800a5b:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800a5e:	0f 84 88 00 00 00    	je     800aec <readline+0xdc>
				cprintf("read error: %e\n", c);
  800a64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a68:	c7 04 24 5f 26 80 00 	movl   $0x80265f,(%esp)
  800a6f:	e8 ac f9 ff ff       	call   800420 <cprintf>
			return NULL;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	eb 71                	jmp    800aec <readline+0xdc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a7b:	83 f8 7f             	cmp    $0x7f,%eax
  800a7e:	74 05                	je     800a85 <readline+0x75>
  800a80:	83 f8 08             	cmp    $0x8,%eax
  800a83:	75 19                	jne    800a9e <readline+0x8e>
  800a85:	85 f6                	test   %esi,%esi
  800a87:	7e 15                	jle    800a9e <readline+0x8e>
			if (echoing)
  800a89:	85 ff                	test   %edi,%edi
  800a8b:	74 0c                	je     800a99 <readline+0x89>
				cputchar('\b');
  800a8d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800a94:	e8 4c f7 ff ff       	call   8001e5 <cputchar>
			i--;
  800a99:	83 ee 01             	sub    $0x1,%esi
  800a9c:	eb ad                	jmp    800a4b <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a9e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800aa4:	7f 1c                	jg     800ac2 <readline+0xb2>
  800aa6:	83 fb 1f             	cmp    $0x1f,%ebx
  800aa9:	7e 17                	jle    800ac2 <readline+0xb2>
			if (echoing)
  800aab:	85 ff                	test   %edi,%edi
  800aad:	74 08                	je     800ab7 <readline+0xa7>
				cputchar(c);
  800aaf:	89 1c 24             	mov    %ebx,(%esp)
  800ab2:	e8 2e f7 ff ff       	call   8001e5 <cputchar>
			buf[i++] = c;
  800ab7:	88 9e 20 40 80 00    	mov    %bl,0x804020(%esi)
  800abd:	8d 76 01             	lea    0x1(%esi),%esi
  800ac0:	eb 89                	jmp    800a4b <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800ac2:	83 fb 0d             	cmp    $0xd,%ebx
  800ac5:	74 09                	je     800ad0 <readline+0xc0>
  800ac7:	83 fb 0a             	cmp    $0xa,%ebx
  800aca:	0f 85 7b ff ff ff    	jne    800a4b <readline+0x3b>
			if (echoing)
  800ad0:	85 ff                	test   %edi,%edi
  800ad2:	74 0c                	je     800ae0 <readline+0xd0>
				cputchar('\n');
  800ad4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800adb:	e8 05 f7 ff ff       	call   8001e5 <cputchar>
			buf[i] = 0;
  800ae0:	c6 86 20 40 80 00 00 	movb   $0x0,0x804020(%esi)
			return buf;
  800ae7:	b8 20 40 80 00       	mov    $0x804020,%eax
		}
	}
}
  800aec:	83 c4 1c             	add    $0x1c,%esp
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    
  800af4:	66 90                	xchg   %ax,%ax
  800af6:	66 90                	xchg   %ax,%ax
  800af8:	66 90                	xchg   %ax,%ax
  800afa:	66 90                	xchg   %ax,%ax
  800afc:	66 90                	xchg   %ax,%ax
  800afe:	66 90                	xchg   %ax,%ax

00800b00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	eb 03                	jmp    800b10 <strlen+0x10>
		n++;
  800b0d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b10:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b14:	75 f7                	jne    800b0d <strlen+0xd>
	return n;
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	eb 03                	jmp    800b2b <strnlen+0x13>
		n++;
  800b28:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2b:	39 d0                	cmp    %edx,%eax
  800b2d:	74 06                	je     800b35 <strnlen+0x1d>
  800b2f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b33:	75 f3                	jne    800b28 <strnlen+0x10>
	return n;
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b41:	89 c2                	mov    %eax,%edx
  800b43:	83 c2 01             	add    $0x1,%edx
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b4d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b50:	84 db                	test   %bl,%bl
  800b52:	75 ef                	jne    800b43 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b54:	5b                   	pop    %ebx
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 08             	sub    $0x8,%esp
  800b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b61:	89 1c 24             	mov    %ebx,(%esp)
  800b64:	e8 97 ff ff ff       	call   800b00 <strlen>
	strcpy(dst + len, src);
  800b69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b70:	01 d8                	add    %ebx,%eax
  800b72:	89 04 24             	mov    %eax,(%esp)
  800b75:	e8 bd ff ff ff       	call   800b37 <strcpy>
	return dst;
}
  800b7a:	89 d8                	mov    %ebx,%eax
  800b7c:	83 c4 08             	add    $0x8,%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	89 f3                	mov    %esi,%ebx
  800b8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b92:	89 f2                	mov    %esi,%edx
  800b94:	eb 0f                	jmp    800ba5 <strncpy+0x23>
		*dst++ = *src;
  800b96:	83 c2 01             	add    $0x1,%edx
  800b99:	0f b6 01             	movzbl (%ecx),%eax
  800b9c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b9f:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800ba5:	39 da                	cmp    %ebx,%edx
  800ba7:	75 ed                	jne    800b96 <strncpy+0x14>
	}
	return ret;
}
  800ba9:	89 f0                	mov    %esi,%eax
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bbd:	89 f0                	mov    %esi,%eax
  800bbf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc3:	85 c9                	test   %ecx,%ecx
  800bc5:	75 0b                	jne    800bd2 <strlcpy+0x23>
  800bc7:	eb 1d                	jmp    800be6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bc9:	83 c0 01             	add    $0x1,%eax
  800bcc:	83 c2 01             	add    $0x1,%edx
  800bcf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bd2:	39 d8                	cmp    %ebx,%eax
  800bd4:	74 0b                	je     800be1 <strlcpy+0x32>
  800bd6:	0f b6 0a             	movzbl (%edx),%ecx
  800bd9:	84 c9                	test   %cl,%cl
  800bdb:	75 ec                	jne    800bc9 <strlcpy+0x1a>
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	eb 02                	jmp    800be3 <strlcpy+0x34>
  800be1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800be3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 07                	jmp    800c7e <strfind+0x13>
		if (*s == c)
  800c77:	38 ca                	cmp    %cl,%dl
  800c79:	74 0a                	je     800c85 <strfind+0x1a>
	for (; *s; s++)
  800c7b:	83 c0 01             	add    $0x1,%eax
  800c7e:	0f b6 10             	movzbl (%eax),%edx
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
  800cbb:	89 d0                	mov    %edx,%eax
  800cbd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d29:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d42:	8b 45 10             	mov    0x10(%ebp),%eax
  800d45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	89 04 24             	mov    %eax,(%esp)
  800d56:	e8 79 ff ff ff       	call   800cd4 <memmove>
}
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	89 d6                	mov    %edx,%esi
  800d6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d6d:	eb 1a                	jmp    800d89 <memcmp+0x2c>
		if (*s1 != *s2)
  800d6f:	0f b6 02             	movzbl (%edx),%eax
  800d72:	0f b6 19             	movzbl (%ecx),%ebx
  800d75:	38 d8                	cmp    %bl,%al
  800d77:	74 0a                	je     800d83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d79:	0f b6 c0             	movzbl %al,%eax
  800d7c:	0f b6 db             	movzbl %bl,%ebx
  800d7f:	29 d8                	sub    %ebx,%eax
  800d81:	eb 0f                	jmp    800d92 <memcmp+0x35>
		s1++, s2++;
  800d83:	83 c2 01             	add    $0x1,%edx
  800d86:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800d89:	39 f2                	cmp    %esi,%edx
  800d8b:	75 e2                	jne    800d6f <memcmp+0x12>
	}

	return 0;
  800d8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800da4:	eb 07                	jmp    800dad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800da6:	38 08                	cmp    %cl,(%eax)
  800da8:	74 07                	je     800db1 <memfind+0x1b>
	for (; s < ends; s++)
  800daa:	83 c0 01             	add    $0x1,%eax
  800dad:	39 d0                	cmp    %edx,%eax
  800daf:	72 f5                	jb     800da6 <memfind+0x10>
			break;
	return (void *) s;
}
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbf:	eb 03                	jmp    800dc4 <strtol+0x11>
		s++;
  800dc1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800dc4:	0f b6 0a             	movzbl (%edx),%ecx
  800dc7:	80 f9 09             	cmp    $0x9,%cl
  800dca:	74 f5                	je     800dc1 <strtol+0xe>
  800dcc:	80 f9 20             	cmp    $0x20,%cl
  800dcf:	74 f0                	je     800dc1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800dd1:	80 f9 2b             	cmp    $0x2b,%cl
  800dd4:	75 0a                	jne    800de0 <strtol+0x2d>
		s++;
  800dd6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800dd9:	bf 00 00 00 00       	mov    $0x0,%edi
  800dde:	eb 11                	jmp    800df1 <strtol+0x3e>
  800de0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800de5:	80 f9 2d             	cmp    $0x2d,%cl
  800de8:	75 07                	jne    800df1 <strtol+0x3e>
		s++, neg = 1;
  800dea:	8d 52 01             	lea    0x1(%edx),%edx
  800ded:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800df1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800df6:	75 15                	jne    800e0d <strtol+0x5a>
  800df8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dfb:	75 10                	jne    800e0d <strtol+0x5a>
  800dfd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e01:	75 0a                	jne    800e0d <strtol+0x5a>
		s += 2, base = 16;
  800e03:	83 c2 02             	add    $0x2,%edx
  800e06:	b8 10 00 00 00       	mov    $0x10,%eax
  800e0b:	eb 10                	jmp    800e1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	75 0c                	jne    800e1d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e11:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800e13:	80 3a 30             	cmpb   $0x30,(%edx)
  800e16:	75 05                	jne    800e1d <strtol+0x6a>
		s++, base = 8;
  800e18:	83 c2 01             	add    $0x1,%edx
  800e1b:	b0 08                	mov    $0x8,%al
		base = 10;
  800e1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e22:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e25:	0f b6 0a             	movzbl (%edx),%ecx
  800e28:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e2b:	89 f0                	mov    %esi,%eax
  800e2d:	3c 09                	cmp    $0x9,%al
  800e2f:	77 08                	ja     800e39 <strtol+0x86>
			dig = *s - '0';
  800e31:	0f be c9             	movsbl %cl,%ecx
  800e34:	83 e9 30             	sub    $0x30,%ecx
  800e37:	eb 20                	jmp    800e59 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e39:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e3c:	89 f0                	mov    %esi,%eax
  800e3e:	3c 19                	cmp    $0x19,%al
  800e40:	77 08                	ja     800e4a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e42:	0f be c9             	movsbl %cl,%ecx
  800e45:	83 e9 57             	sub    $0x57,%ecx
  800e48:	eb 0f                	jmp    800e59 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e4a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e4d:	89 f0                	mov    %esi,%eax
  800e4f:	3c 19                	cmp    $0x19,%al
  800e51:	77 16                	ja     800e69 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e53:	0f be c9             	movsbl %cl,%ecx
  800e56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e5c:	7d 0f                	jge    800e6d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e5e:	83 c2 01             	add    $0x1,%edx
  800e61:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e65:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e67:	eb bc                	jmp    800e25 <strtol+0x72>
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	eb 02                	jmp    800e6f <strtol+0xbc>
  800e6d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e73:	74 05                	je     800e7a <strtol+0xc7>
		*endptr = (char *) s;
  800e75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e78:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e7a:	f7 d8                	neg    %eax
  800e7c:	85 ff                	test   %edi,%edi
  800e7e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	89 c3                	mov    %eax,%ebx
  800e99:	89 c7                	mov    %eax,%edi
  800e9b:	89 c6                	mov    %eax,%esi
  800e9d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaf:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb4:	89 d1                	mov    %edx,%ecx
  800eb6:	89 d3                	mov    %edx,%ebx
  800eb8:	89 d7                	mov    %edx,%edi
  800eba:	89 d6                	mov    %edx,%esi
  800ebc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ecc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	89 cb                	mov    %ecx,%ebx
  800edb:	89 cf                	mov    %ecx,%edi
  800edd:	89 ce                	mov    %ecx,%esi
  800edf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	7e 28                	jle    800f0d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f00:	00 
  800f01:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  800f08:	e8 1a f4 ff ff       	call   800327 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f0d:	83 c4 2c             	add    $0x2c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	b8 02 00 00 00       	mov    $0x2,%eax
  800f25:	89 d1                	mov    %edx,%ecx
  800f27:	89 d3                	mov    %edx,%ebx
  800f29:	89 d7                	mov    %edx,%edi
  800f2b:	89 d6                	mov    %edx,%esi
  800f2d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <sys_yield>:

void
sys_yield(void)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f44:	89 d1                	mov    %edx,%ecx
  800f46:	89 d3                	mov    %edx,%ebx
  800f48:	89 d7                	mov    %edx,%edi
  800f4a:	89 d6                	mov    %edx,%esi
  800f4c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f5c:	be 00 00 00 00       	mov    $0x0,%esi
  800f61:	b8 04 00 00 00       	mov    $0x4,%eax
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6f:	89 f7                	mov    %esi,%edi
  800f71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	7e 28                	jle    800f9f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f82:	00 
  800f83:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f92:	00 
  800f93:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  800f9a:	e8 88 f3 ff ff       	call   800327 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f9f:	83 c4 2c             	add    $0x2c,%esp
  800fa2:	5b                   	pop    %ebx
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fb0:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800fc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	7e 28                	jle    800ff2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  800fdd:	00 
  800fde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe5:	00 
  800fe6:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  800fed:	e8 35 f3 ff ff       	call   800327 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ff2:	83 c4 2c             	add    $0x2c,%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5f                   	pop    %edi
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	57                   	push   %edi
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801003:	bb 00 00 00 00       	mov    $0x0,%ebx
  801008:	b8 06 00 00 00       	mov    $0x6,%eax
  80100d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801010:	8b 55 08             	mov    0x8(%ebp),%edx
  801013:	89 df                	mov    %ebx,%edi
  801015:	89 de                	mov    %ebx,%esi
  801017:	cd 30                	int    $0x30
	if(check && ret > 0)
  801019:	85 c0                	test   %eax,%eax
  80101b:	7e 28                	jle    801045 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801021:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801028:	00 
  801029:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  801030:	00 
  801031:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801038:	00 
  801039:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  801040:	e8 e2 f2 ff ff       	call   800327 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801045:	83 c4 2c             	add    $0x2c,%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
  801053:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801056:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105b:	b8 08 00 00 00       	mov    $0x8,%eax
  801060:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801063:	8b 55 08             	mov    0x8(%ebp),%edx
  801066:	89 df                	mov    %ebx,%edi
  801068:	89 de                	mov    %ebx,%esi
  80106a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80106c:	85 c0                	test   %eax,%eax
  80106e:	7e 28                	jle    801098 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801070:	89 44 24 10          	mov    %eax,0x10(%esp)
  801074:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80107b:	00 
  80107c:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  801083:	00 
  801084:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80108b:	00 
  80108c:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  801093:	e8 8f f2 ff ff       	call   800327 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801098:	83 c4 2c             	add    $0x2c,%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b9:	89 df                	mov    %ebx,%edi
  8010bb:	89 de                	mov    %ebx,%esi
  8010bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	7e 28                	jle    8010eb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010ce:	00 
  8010cf:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  8010d6:	00 
  8010d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010de:	00 
  8010df:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  8010e6:	e8 3c f2 ff ff       	call   800327 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010eb:	83 c4 2c             	add    $0x2c,%esp
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5f                   	pop    %edi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8010fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801101:	b8 0a 00 00 00       	mov    $0xa,%eax
  801106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801109:	8b 55 08             	mov    0x8(%ebp),%edx
  80110c:	89 df                	mov    %ebx,%edi
  80110e:	89 de                	mov    %ebx,%esi
  801110:	cd 30                	int    $0x30
	if(check && ret > 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	7e 28                	jle    80113e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801116:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801121:	00 
  801122:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  801129:	00 
  80112a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801131:	00 
  801132:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  801139:	e8 e9 f1 ff ff       	call   800327 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80113e:	83 c4 2c             	add    $0x2c,%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	57                   	push   %edi
  80114a:	56                   	push   %esi
  80114b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80114c:	be 00 00 00 00       	mov    $0x0,%esi
  801151:	b8 0c 00 00 00       	mov    $0xc,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80115f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801162:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801172:	b9 00 00 00 00       	mov    $0x0,%ecx
  801177:	b8 0d 00 00 00       	mov    $0xd,%eax
  80117c:	8b 55 08             	mov    0x8(%ebp),%edx
  80117f:	89 cb                	mov    %ecx,%ebx
  801181:	89 cf                	mov    %ecx,%edi
  801183:	89 ce                	mov    %ecx,%esi
  801185:	cd 30                	int    $0x30
	if(check && ret > 0)
  801187:	85 c0                	test   %eax,%eax
  801189:	7e 28                	jle    8011b3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801196:	00 
  801197:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  80119e:	00 
  80119f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a6:	00 
  8011a7:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  8011ae:	e8 74 f1 ff ff       	call   800327 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011b3:	83 c4 2c             	add    $0x2c,%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    
  8011bb:	66 90                	xchg   %ax,%ax
  8011bd:	66 90                	xchg   %ax,%ax
  8011bf:	90                   	nop

008011c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ed:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	c1 ea 16             	shr    $0x16,%edx
  8011f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fe:	f6 c2 01             	test   $0x1,%dl
  801201:	74 11                	je     801214 <fd_alloc+0x2d>
  801203:	89 c2                	mov    %eax,%edx
  801205:	c1 ea 0c             	shr    $0xc,%edx
  801208:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120f:	f6 c2 01             	test   $0x1,%dl
  801212:	75 09                	jne    80121d <fd_alloc+0x36>
			*fd_store = fd;
  801214:	89 01                	mov    %eax,(%ecx)
			return 0;
  801216:	b8 00 00 00 00       	mov    $0x0,%eax
  80121b:	eb 17                	jmp    801234 <fd_alloc+0x4d>
  80121d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801222:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801227:	75 c9                	jne    8011f2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801229:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80122f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123c:	83 f8 1f             	cmp    $0x1f,%eax
  80123f:	77 36                	ja     801277 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801241:	c1 e0 0c             	shl    $0xc,%eax
  801244:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801249:	89 c2                	mov    %eax,%edx
  80124b:	c1 ea 16             	shr    $0x16,%edx
  80124e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801255:	f6 c2 01             	test   $0x1,%dl
  801258:	74 24                	je     80127e <fd_lookup+0x48>
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	c1 ea 0c             	shr    $0xc,%edx
  80125f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801266:	f6 c2 01             	test   $0x1,%dl
  801269:	74 1a                	je     801285 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80126b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126e:	89 02                	mov    %eax,(%edx)
	return 0;
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	eb 13                	jmp    80128a <fd_lookup+0x54>
		return -E_INVAL;
  801277:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127c:	eb 0c                	jmp    80128a <fd_lookup+0x54>
		return -E_INVAL;
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801283:	eb 05                	jmp    80128a <fd_lookup+0x54>
  801285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	83 ec 18             	sub    $0x18,%esp
  801292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801295:	ba 1c 27 80 00       	mov    $0x80271c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80129a:	eb 13                	jmp    8012af <dev_lookup+0x23>
  80129c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80129f:	39 08                	cmp    %ecx,(%eax)
  8012a1:	75 0c                	jne    8012af <dev_lookup+0x23>
			*dev = devtab[i];
  8012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ad:	eb 30                	jmp    8012df <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8012af:	8b 02                	mov    (%edx),%eax
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	75 e7                	jne    80129c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b5:	a1 24 44 80 00       	mov    0x804424,%eax
  8012ba:	8b 40 48             	mov    0x48(%eax),%eax
  8012bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c5:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  8012cc:	e8 4f f1 ff ff       	call   800420 <cprintf>
	*dev = 0;
  8012d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <fd_close>:
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	56                   	push   %esi
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 20             	sub    $0x20,%esp
  8012e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012fc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ff:	89 04 24             	mov    %eax,(%esp)
  801302:	e8 2f ff ff ff       	call   801236 <fd_lookup>
  801307:	85 c0                	test   %eax,%eax
  801309:	78 05                	js     801310 <fd_close+0x2f>
	    || fd != fd2)
  80130b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80130e:	74 0c                	je     80131c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801310:	84 db                	test   %bl,%bl
  801312:	ba 00 00 00 00       	mov    $0x0,%edx
  801317:	0f 44 c2             	cmove  %edx,%eax
  80131a:	eb 3f                	jmp    80135b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80131c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801323:	8b 06                	mov    (%esi),%eax
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	e8 5f ff ff ff       	call   80128c <dev_lookup>
  80132d:	89 c3                	mov    %eax,%ebx
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 16                	js     801349 <fd_close+0x68>
		if (dev->dev_close)
  801333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801336:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801339:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80133e:	85 c0                	test   %eax,%eax
  801340:	74 07                	je     801349 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801342:	89 34 24             	mov    %esi,(%esp)
  801345:	ff d0                	call   *%eax
  801347:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801349:	89 74 24 04          	mov    %esi,0x4(%esp)
  80134d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801354:	e8 a1 fc ff ff       	call   800ffa <sys_page_unmap>
	return r;
  801359:	89 d8                	mov    %ebx,%eax
}
  80135b:	83 c4 20             	add    $0x20,%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <close>:

int
close(int fdnum)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801368:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136f:	8b 45 08             	mov    0x8(%ebp),%eax
  801372:	89 04 24             	mov    %eax,(%esp)
  801375:	e8 bc fe ff ff       	call   801236 <fd_lookup>
  80137a:	89 c2                	mov    %eax,%edx
  80137c:	85 d2                	test   %edx,%edx
  80137e:	78 13                	js     801393 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801380:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801387:	00 
  801388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138b:	89 04 24             	mov    %eax,(%esp)
  80138e:	e8 4e ff ff ff       	call   8012e1 <fd_close>
}
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <close_all>:

void
close_all(void)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80139c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a1:	89 1c 24             	mov    %ebx,(%esp)
  8013a4:	e8 b9 ff ff ff       	call   801362 <close>
	for (i = 0; i < MAXFD; i++)
  8013a9:	83 c3 01             	add    $0x1,%ebx
  8013ac:	83 fb 20             	cmp    $0x20,%ebx
  8013af:	75 f0                	jne    8013a1 <close_all+0xc>
}
  8013b1:	83 c4 14             	add    $0x14,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	57                   	push   %edi
  8013bb:	56                   	push   %esi
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	89 04 24             	mov    %eax,(%esp)
  8013cd:	e8 64 fe ff ff       	call   801236 <fd_lookup>
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	85 d2                	test   %edx,%edx
  8013d6:	0f 88 e1 00 00 00    	js     8014bd <dup+0x106>
		return r;
	close(newfdnum);
  8013dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013df:	89 04 24             	mov    %eax,(%esp)
  8013e2:	e8 7b ff ff ff       	call   801362 <close>

	newfd = INDEX2FD(newfdnum);
  8013e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ea:	c1 e3 0c             	shl    $0xc,%ebx
  8013ed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	e8 d2 fd ff ff       	call   8011d0 <fd2data>
  8013fe:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801400:	89 1c 24             	mov    %ebx,(%esp)
  801403:	e8 c8 fd ff ff       	call   8011d0 <fd2data>
  801408:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80140a:	89 f0                	mov    %esi,%eax
  80140c:	c1 e8 16             	shr    $0x16,%eax
  80140f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801416:	a8 01                	test   $0x1,%al
  801418:	74 43                	je     80145d <dup+0xa6>
  80141a:	89 f0                	mov    %esi,%eax
  80141c:	c1 e8 0c             	shr    $0xc,%eax
  80141f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801426:	f6 c2 01             	test   $0x1,%dl
  801429:	74 32                	je     80145d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80142b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801432:	25 07 0e 00 00       	and    $0xe07,%eax
  801437:	89 44 24 10          	mov    %eax,0x10(%esp)
  80143b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80143f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801446:	00 
  801447:	89 74 24 04          	mov    %esi,0x4(%esp)
  80144b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801452:	e8 50 fb ff ff       	call   800fa7 <sys_page_map>
  801457:	89 c6                	mov    %eax,%esi
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 3e                	js     80149b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801460:	89 c2                	mov    %eax,%edx
  801462:	c1 ea 0c             	shr    $0xc,%edx
  801465:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80146c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801472:	89 54 24 10          	mov    %edx,0x10(%esp)
  801476:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80147a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801481:	00 
  801482:	89 44 24 04          	mov    %eax,0x4(%esp)
  801486:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80148d:	e8 15 fb ff ff       	call   800fa7 <sys_page_map>
  801492:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801494:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801497:	85 f6                	test   %esi,%esi
  801499:	79 22                	jns    8014bd <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80149b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80149f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a6:	e8 4f fb ff ff       	call   800ffa <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b6:	e8 3f fb ff ff       	call   800ffa <sys_page_unmap>
	return r;
  8014bb:	89 f0                	mov    %esi,%eax
}
  8014bd:	83 c4 3c             	add    $0x3c,%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5f                   	pop    %edi
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 24             	sub    $0x24,%esp
  8014cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	89 1c 24             	mov    %ebx,(%esp)
  8014d9:	e8 58 fd ff ff       	call   801236 <fd_lookup>
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	78 6d                	js     801551 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ee:	8b 00                	mov    (%eax),%eax
  8014f0:	89 04 24             	mov    %eax,(%esp)
  8014f3:	e8 94 fd ff ff       	call   80128c <dev_lookup>
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 55                	js     801551 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ff:	8b 50 08             	mov    0x8(%eax),%edx
  801502:	83 e2 03             	and    $0x3,%edx
  801505:	83 fa 01             	cmp    $0x1,%edx
  801508:	75 23                	jne    80152d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80150a:	a1 24 44 80 00       	mov    0x804424,%eax
  80150f:	8b 40 48             	mov    0x48(%eax),%eax
  801512:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151a:	c7 04 24 e0 26 80 00 	movl   $0x8026e0,(%esp)
  801521:	e8 fa ee ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152b:	eb 24                	jmp    801551 <read+0x8c>
	}
	if (!dev->dev_read)
  80152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801530:	8b 52 08             	mov    0x8(%edx),%edx
  801533:	85 d2                	test   %edx,%edx
  801535:	74 15                	je     80154c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801537:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80153a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80153e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801541:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801545:	89 04 24             	mov    %eax,(%esp)
  801548:	ff d2                	call   *%edx
  80154a:	eb 05                	jmp    801551 <read+0x8c>
		return -E_NOT_SUPP;
  80154c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801551:	83 c4 24             	add    $0x24,%esp
  801554:	5b                   	pop    %ebx
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	57                   	push   %edi
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 1c             	sub    $0x1c,%esp
  801560:	8b 7d 08             	mov    0x8(%ebp),%edi
  801563:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801566:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156b:	eb 23                	jmp    801590 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156d:	89 f0                	mov    %esi,%eax
  80156f:	29 d8                	sub    %ebx,%eax
  801571:	89 44 24 08          	mov    %eax,0x8(%esp)
  801575:	89 d8                	mov    %ebx,%eax
  801577:	03 45 0c             	add    0xc(%ebp),%eax
  80157a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157e:	89 3c 24             	mov    %edi,(%esp)
  801581:	e8 3f ff ff ff       	call   8014c5 <read>
		if (m < 0)
  801586:	85 c0                	test   %eax,%eax
  801588:	78 10                	js     80159a <readn+0x43>
			return m;
		if (m == 0)
  80158a:	85 c0                	test   %eax,%eax
  80158c:	74 0a                	je     801598 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80158e:	01 c3                	add    %eax,%ebx
  801590:	39 f3                	cmp    %esi,%ebx
  801592:	72 d9                	jb     80156d <readn+0x16>
  801594:	89 d8                	mov    %ebx,%eax
  801596:	eb 02                	jmp    80159a <readn+0x43>
  801598:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80159a:	83 c4 1c             	add    $0x1c,%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5f                   	pop    %edi
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 24             	sub    $0x24,%esp
  8015a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b3:	89 1c 24             	mov    %ebx,(%esp)
  8015b6:	e8 7b fc ff ff       	call   801236 <fd_lookup>
  8015bb:	89 c2                	mov    %eax,%edx
  8015bd:	85 d2                	test   %edx,%edx
  8015bf:	78 68                	js     801629 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cb:	8b 00                	mov    (%eax),%eax
  8015cd:	89 04 24             	mov    %eax,(%esp)
  8015d0:	e8 b7 fc ff ff       	call   80128c <dev_lookup>
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 50                	js     801629 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e0:	75 23                	jne    801605 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e2:	a1 24 44 80 00       	mov    0x804424,%eax
  8015e7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f2:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  8015f9:	e8 22 ee ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  8015fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801603:	eb 24                	jmp    801629 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801605:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801608:	8b 52 0c             	mov    0xc(%edx),%edx
  80160b:	85 d2                	test   %edx,%edx
  80160d:	74 15                	je     801624 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801612:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801616:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801619:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80161d:	89 04 24             	mov    %eax,(%esp)
  801620:	ff d2                	call   *%edx
  801622:	eb 05                	jmp    801629 <write+0x87>
		return -E_NOT_SUPP;
  801624:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801629:	83 c4 24             	add    $0x24,%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <seek>:

int
seek(int fdnum, off_t offset)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801635:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163c:	8b 45 08             	mov    0x8(%ebp),%eax
  80163f:	89 04 24             	mov    %eax,(%esp)
  801642:	e8 ef fb ff ff       	call   801236 <fd_lookup>
  801647:	85 c0                	test   %eax,%eax
  801649:	78 0e                	js     801659 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80164b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80164e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801651:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801654:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	53                   	push   %ebx
  80165f:	83 ec 24             	sub    $0x24,%esp
  801662:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801665:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166c:	89 1c 24             	mov    %ebx,(%esp)
  80166f:	e8 c2 fb ff ff       	call   801236 <fd_lookup>
  801674:	89 c2                	mov    %eax,%edx
  801676:	85 d2                	test   %edx,%edx
  801678:	78 61                	js     8016db <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	8b 00                	mov    (%eax),%eax
  801686:	89 04 24             	mov    %eax,(%esp)
  801689:	e8 fe fb ff ff       	call   80128c <dev_lookup>
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 49                	js     8016db <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801699:	75 23                	jne    8016be <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80169b:	a1 24 44 80 00       	mov    0x804424,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a0:	8b 40 48             	mov    0x48(%eax),%eax
  8016a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  8016b2:	e8 69 ed ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  8016b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bc:	eb 1d                	jmp    8016db <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8016be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c1:	8b 52 18             	mov    0x18(%edx),%edx
  8016c4:	85 d2                	test   %edx,%edx
  8016c6:	74 0e                	je     8016d6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016cf:	89 04 24             	mov    %eax,(%esp)
  8016d2:	ff d2                	call   *%edx
  8016d4:	eb 05                	jmp    8016db <ftruncate+0x80>
		return -E_NOT_SUPP;
  8016d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016db:	83 c4 24             	add    $0x24,%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 24             	sub    $0x24,%esp
  8016e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	e8 39 fb ff ff       	call   801236 <fd_lookup>
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	85 d2                	test   %edx,%edx
  801701:	78 52                	js     801755 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801706:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	8b 00                	mov    (%eax),%eax
  80170f:	89 04 24             	mov    %eax,(%esp)
  801712:	e8 75 fb ff ff       	call   80128c <dev_lookup>
  801717:	85 c0                	test   %eax,%eax
  801719:	78 3a                	js     801755 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80171b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801722:	74 2c                	je     801750 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801724:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801727:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172e:	00 00 00 
	stat->st_isdir = 0;
  801731:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801738:	00 00 00 
	stat->st_dev = dev;
  80173b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801741:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801745:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801748:	89 14 24             	mov    %edx,(%esp)
  80174b:	ff 50 14             	call   *0x14(%eax)
  80174e:	eb 05                	jmp    801755 <fstat+0x74>
		return -E_NOT_SUPP;
  801750:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801755:	83 c4 24             	add    $0x24,%esp
  801758:	5b                   	pop    %ebx
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    

0080175b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801763:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80176a:	00 
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 fb 01 00 00       	call   801971 <open>
  801776:	89 c3                	mov    %eax,%ebx
  801778:	85 db                	test   %ebx,%ebx
  80177a:	78 1b                	js     801797 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80177c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801783:	89 1c 24             	mov    %ebx,(%esp)
  801786:	e8 56 ff ff ff       	call   8016e1 <fstat>
  80178b:	89 c6                	mov    %eax,%esi
	close(fd);
  80178d:	89 1c 24             	mov    %ebx,(%esp)
  801790:	e8 cd fb ff ff       	call   801362 <close>
	return r;
  801795:	89 f0                	mov    %esi,%eax
}
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
  8017a3:	83 ec 10             	sub    $0x10,%esp
  8017a6:	89 c6                	mov    %eax,%esi
  8017a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017aa:	83 3d 20 44 80 00 00 	cmpl   $0x0,0x804420
  8017b1:	75 11                	jne    8017c4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017ba:	e8 e0 07 00 00       	call   801f9f <ipc_find_env>
  8017bf:	a3 20 44 80 00       	mov    %eax,0x804420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017cb:	00 
  8017cc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017d3:	00 
  8017d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017d8:	a1 20 44 80 00       	mov    0x804420,%eax
  8017dd:	89 04 24             	mov    %eax,(%esp)
  8017e0:	e8 53 07 00 00       	call   801f38 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ec:	00 
  8017ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f8:	e8 d3 06 00 00       	call   801ed0 <ipc_recv>
}
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	8b 40 0c             	mov    0xc(%eax),%eax
  801810:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801815:	8b 45 0c             	mov    0xc(%ebp),%eax
  801818:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 02 00 00 00       	mov    $0x2,%eax
  801827:	e8 72 ff ff ff       	call   80179e <fsipc>
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devfile_flush>:
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	8b 40 0c             	mov    0xc(%eax),%eax
  80183a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 06 00 00 00       	mov    $0x6,%eax
  801849:	e8 50 ff ff ff       	call   80179e <fsipc>
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devfile_stat>:
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	53                   	push   %ebx
  801854:	83 ec 14             	sub    $0x14,%esp
  801857:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	8b 40 0c             	mov    0xc(%eax),%eax
  801860:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801865:	ba 00 00 00 00       	mov    $0x0,%edx
  80186a:	b8 05 00 00 00       	mov    $0x5,%eax
  80186f:	e8 2a ff ff ff       	call   80179e <fsipc>
  801874:	89 c2                	mov    %eax,%edx
  801876:	85 d2                	test   %edx,%edx
  801878:	78 2b                	js     8018a5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80187a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801881:	00 
  801882:	89 1c 24             	mov    %ebx,(%esp)
  801885:	e8 ad f2 ff ff       	call   800b37 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80188a:	a1 80 50 80 00       	mov    0x805080,%eax
  80188f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801895:	a1 84 50 80 00       	mov    0x805084,%eax
  80189a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a5:	83 c4 14             	add    $0x14,%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <devfile_write>:
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  8018b1:	c7 44 24 08 2c 27 80 	movl   $0x80272c,0x8(%esp)
  8018b8:	00 
  8018b9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8018c0:	00 
  8018c1:	c7 04 24 4a 27 80 00 	movl   $0x80274a,(%esp)
  8018c8:	e8 5a ea ff ff       	call   800327 <_panic>

008018cd <devfile_read>:
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 10             	sub    $0x10,%esp
  8018d5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018db:	8b 40 0c             	mov    0xc(%eax),%eax
  8018de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f3:	e8 a6 fe ff ff       	call   80179e <fsipc>
  8018f8:	89 c3                	mov    %eax,%ebx
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 6a                	js     801968 <devfile_read+0x9b>
	assert(r <= n);
  8018fe:	39 c6                	cmp    %eax,%esi
  801900:	73 24                	jae    801926 <devfile_read+0x59>
  801902:	c7 44 24 0c 55 27 80 	movl   $0x802755,0xc(%esp)
  801909:	00 
  80190a:	c7 44 24 08 5c 27 80 	movl   $0x80275c,0x8(%esp)
  801911:	00 
  801912:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801919:	00 
  80191a:	c7 04 24 4a 27 80 00 	movl   $0x80274a,(%esp)
  801921:	e8 01 ea ff ff       	call   800327 <_panic>
	assert(r <= PGSIZE);
  801926:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80192b:	7e 24                	jle    801951 <devfile_read+0x84>
  80192d:	c7 44 24 0c 71 27 80 	movl   $0x802771,0xc(%esp)
  801934:	00 
  801935:	c7 44 24 08 5c 27 80 	movl   $0x80275c,0x8(%esp)
  80193c:	00 
  80193d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801944:	00 
  801945:	c7 04 24 4a 27 80 00 	movl   $0x80274a,(%esp)
  80194c:	e8 d6 e9 ff ff       	call   800327 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801951:	89 44 24 08          	mov    %eax,0x8(%esp)
  801955:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80195c:	00 
  80195d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801960:	89 04 24             	mov    %eax,(%esp)
  801963:	e8 6c f3 ff ff       	call   800cd4 <memmove>
}
  801968:	89 d8                	mov    %ebx,%eax
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	5b                   	pop    %ebx
  80196e:	5e                   	pop    %esi
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    

00801971 <open>:
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	53                   	push   %ebx
  801975:	83 ec 24             	sub    $0x24,%esp
  801978:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80197b:	89 1c 24             	mov    %ebx,(%esp)
  80197e:	e8 7d f1 ff ff       	call   800b00 <strlen>
  801983:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801988:	7f 60                	jg     8019ea <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80198a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198d:	89 04 24             	mov    %eax,(%esp)
  801990:	e8 52 f8 ff ff       	call   8011e7 <fd_alloc>
  801995:	89 c2                	mov    %eax,%edx
  801997:	85 d2                	test   %edx,%edx
  801999:	78 54                	js     8019ef <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80199b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019a6:	e8 8c f1 ff ff       	call   800b37 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ae:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019bb:	e8 de fd ff ff       	call   80179e <fsipc>
  8019c0:	89 c3                	mov    %eax,%ebx
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	79 17                	jns    8019dd <open+0x6c>
		fd_close(fd, 0);
  8019c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019cd:	00 
  8019ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d1:	89 04 24             	mov    %eax,(%esp)
  8019d4:	e8 08 f9 ff ff       	call   8012e1 <fd_close>
		return r;
  8019d9:	89 d8                	mov    %ebx,%eax
  8019db:	eb 12                	jmp    8019ef <open+0x7e>
	return fd2num(fd);
  8019dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e0:	89 04 24             	mov    %eax,(%esp)
  8019e3:	e8 d8 f7 ff ff       	call   8011c0 <fd2num>
  8019e8:	eb 05                	jmp    8019ef <open+0x7e>
		return -E_BAD_PATH;
  8019ea:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8019ef:	83 c4 24             	add    $0x24,%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 08 00 00 00       	mov    $0x8,%eax
  801a05:	e8 94 fd ff ff       	call   80179e <fsipc>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 14             	sub    $0x14,%esp
  801a13:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a15:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a19:	7e 31                	jle    801a4c <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a1b:	8b 40 04             	mov    0x4(%eax),%eax
  801a1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a22:	8d 43 10             	lea    0x10(%ebx),%eax
  801a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a29:	8b 03                	mov    (%ebx),%eax
  801a2b:	89 04 24             	mov    %eax,(%esp)
  801a2e:	e8 6f fb ff ff       	call   8015a2 <write>
		if (result > 0)
  801a33:	85 c0                	test   %eax,%eax
  801a35:	7e 03                	jle    801a3a <writebuf+0x2e>
			b->result += result;
  801a37:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a3a:	39 43 04             	cmp    %eax,0x4(%ebx)
  801a3d:	74 0d                	je     801a4c <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	ba 00 00 00 00       	mov    $0x0,%edx
  801a46:	0f 4f c2             	cmovg  %edx,%eax
  801a49:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801a4c:	83 c4 14             	add    $0x14,%esp
  801a4f:	5b                   	pop    %ebx
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    

00801a52 <putch>:

static void
putch(int ch, void *thunk)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	53                   	push   %ebx
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a5c:	8b 53 04             	mov    0x4(%ebx),%edx
  801a5f:	8d 42 01             	lea    0x1(%edx),%eax
  801a62:	89 43 04             	mov    %eax,0x4(%ebx)
  801a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a68:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801a6c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a71:	75 0e                	jne    801a81 <putch+0x2f>
		writebuf(b);
  801a73:	89 d8                	mov    %ebx,%eax
  801a75:	e8 92 ff ff ff       	call   801a0c <writebuf>
		b->idx = 0;
  801a7a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a81:	83 c4 04             	add    $0x4,%esp
  801a84:	5b                   	pop    %ebx
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a99:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801aa0:	00 00 00 
	b.result = 0;
  801aa3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801aaa:	00 00 00 
	b.error = 1;
  801aad:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801ab4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801ab7:	8b 45 10             	mov    0x10(%ebp),%eax
  801aba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acf:	c7 04 24 52 1a 80 00 	movl   $0x801a52,(%esp)
  801ad6:	e8 d3 ea ff ff       	call   8005ae <vprintfmt>
	if (b.idx > 0)
  801adb:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801ae2:	7e 0b                	jle    801aef <vfprintf+0x68>
		writebuf(&b);
  801ae4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801aea:	e8 1d ff ff ff       	call   801a0c <writebuf>

	return (b.result ? b.result : b.error);
  801aef:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801af5:	85 c0                	test   %eax,%eax
  801af7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b06:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b09:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	89 04 24             	mov    %eax,(%esp)
  801b1a:	e8 68 ff ff ff       	call   801a87 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <printf>:

int
printf(const char *fmt, ...)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b27:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b35:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b3c:	e8 46 ff ff ff       	call   801a87 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b41:	c9                   	leave  
  801b42:	c3                   	ret    

00801b43 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	83 ec 10             	sub    $0x10,%esp
  801b4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 77 f6 ff ff       	call   8011d0 <fd2data>
  801b59:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b5b:	c7 44 24 04 7d 27 80 	movl   $0x80277d,0x4(%esp)
  801b62:	00 
  801b63:	89 1c 24             	mov    %ebx,(%esp)
  801b66:	e8 cc ef ff ff       	call   800b37 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b6b:	8b 46 04             	mov    0x4(%esi),%eax
  801b6e:	2b 06                	sub    (%esi),%eax
  801b70:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b7d:	00 00 00 
	stat->st_dev = &devpipe;
  801b80:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b87:	30 80 00 
	return 0;
}
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 14             	sub    $0x14,%esp
  801b9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ba0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bab:	e8 4a f4 ff ff       	call   800ffa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bb0:	89 1c 24             	mov    %ebx,(%esp)
  801bb3:	e8 18 f6 ff ff       	call   8011d0 <fd2data>
  801bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc3:	e8 32 f4 ff ff       	call   800ffa <sys_page_unmap>
}
  801bc8:	83 c4 14             	add    $0x14,%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <_pipeisclosed>:
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 2c             	sub    $0x2c,%esp
  801bd7:	89 c6                	mov    %eax,%esi
  801bd9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801bdc:	a1 24 44 80 00       	mov    0x804424,%eax
  801be1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801be4:	89 34 24             	mov    %esi,(%esp)
  801be7:	e8 eb 03 00 00       	call   801fd7 <pageref>
  801bec:	89 c7                	mov    %eax,%edi
  801bee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bf1:	89 04 24             	mov    %eax,(%esp)
  801bf4:	e8 de 03 00 00       	call   801fd7 <pageref>
  801bf9:	39 c7                	cmp    %eax,%edi
  801bfb:	0f 94 c2             	sete   %dl
  801bfe:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c01:	8b 0d 24 44 80 00    	mov    0x804424,%ecx
  801c07:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c0a:	39 fb                	cmp    %edi,%ebx
  801c0c:	74 21                	je     801c2f <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801c0e:	84 d2                	test   %dl,%dl
  801c10:	74 ca                	je     801bdc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c12:	8b 51 58             	mov    0x58(%ecx),%edx
  801c15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c19:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c21:	c7 04 24 84 27 80 00 	movl   $0x802784,(%esp)
  801c28:	e8 f3 e7 ff ff       	call   800420 <cprintf>
  801c2d:	eb ad                	jmp    801bdc <_pipeisclosed+0xe>
}
  801c2f:	83 c4 2c             	add    $0x2c,%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5f                   	pop    %edi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <devpipe_write>:
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	57                   	push   %edi
  801c3b:	56                   	push   %esi
  801c3c:	53                   	push   %ebx
  801c3d:	83 ec 1c             	sub    $0x1c,%esp
  801c40:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c43:	89 34 24             	mov    %esi,(%esp)
  801c46:	e8 85 f5 ff ff       	call   8011d0 <fd2data>
  801c4b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c4d:	bf 00 00 00 00       	mov    $0x0,%edi
  801c52:	eb 45                	jmp    801c99 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801c54:	89 da                	mov    %ebx,%edx
  801c56:	89 f0                	mov    %esi,%eax
  801c58:	e8 71 ff ff ff       	call   801bce <_pipeisclosed>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	75 41                	jne    801ca2 <devpipe_write+0x6b>
			sys_yield();
  801c61:	e8 ce f2 ff ff       	call   800f34 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c66:	8b 43 04             	mov    0x4(%ebx),%eax
  801c69:	8b 0b                	mov    (%ebx),%ecx
  801c6b:	8d 51 20             	lea    0x20(%ecx),%edx
  801c6e:	39 d0                	cmp    %edx,%eax
  801c70:	73 e2                	jae    801c54 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c75:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c79:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c7c:	99                   	cltd   
  801c7d:	c1 ea 1b             	shr    $0x1b,%edx
  801c80:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801c83:	83 e1 1f             	and    $0x1f,%ecx
  801c86:	29 d1                	sub    %edx,%ecx
  801c88:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801c8c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801c90:	83 c0 01             	add    $0x1,%eax
  801c93:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c96:	83 c7 01             	add    $0x1,%edi
  801c99:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c9c:	75 c8                	jne    801c66 <devpipe_write+0x2f>
	return i;
  801c9e:	89 f8                	mov    %edi,%eax
  801ca0:	eb 05                	jmp    801ca7 <devpipe_write+0x70>
				return 0;
  801ca2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca7:	83 c4 1c             	add    $0x1c,%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <devpipe_read>:
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	57                   	push   %edi
  801cb3:	56                   	push   %esi
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 1c             	sub    $0x1c,%esp
  801cb8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cbb:	89 3c 24             	mov    %edi,(%esp)
  801cbe:	e8 0d f5 ff ff       	call   8011d0 <fd2data>
  801cc3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cc5:	be 00 00 00 00       	mov    $0x0,%esi
  801cca:	eb 3d                	jmp    801d09 <devpipe_read+0x5a>
			if (i > 0)
  801ccc:	85 f6                	test   %esi,%esi
  801cce:	74 04                	je     801cd4 <devpipe_read+0x25>
				return i;
  801cd0:	89 f0                	mov    %esi,%eax
  801cd2:	eb 43                	jmp    801d17 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801cd4:	89 da                	mov    %ebx,%edx
  801cd6:	89 f8                	mov    %edi,%eax
  801cd8:	e8 f1 fe ff ff       	call   801bce <_pipeisclosed>
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	75 31                	jne    801d12 <devpipe_read+0x63>
			sys_yield();
  801ce1:	e8 4e f2 ff ff       	call   800f34 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ce6:	8b 03                	mov    (%ebx),%eax
  801ce8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ceb:	74 df                	je     801ccc <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ced:	99                   	cltd   
  801cee:	c1 ea 1b             	shr    $0x1b,%edx
  801cf1:	01 d0                	add    %edx,%eax
  801cf3:	83 e0 1f             	and    $0x1f,%eax
  801cf6:	29 d0                	sub    %edx,%eax
  801cf8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d00:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d03:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d06:	83 c6 01             	add    $0x1,%esi
  801d09:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d0c:	75 d8                	jne    801ce6 <devpipe_read+0x37>
	return i;
  801d0e:	89 f0                	mov    %esi,%eax
  801d10:	eb 05                	jmp    801d17 <devpipe_read+0x68>
				return 0;
  801d12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d17:	83 c4 1c             	add    $0x1c,%esp
  801d1a:	5b                   	pop    %ebx
  801d1b:	5e                   	pop    %esi
  801d1c:	5f                   	pop    %edi
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    

00801d1f <pipe>:
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2a:	89 04 24             	mov    %eax,(%esp)
  801d2d:	e8 b5 f4 ff ff       	call   8011e7 <fd_alloc>
  801d32:	89 c2                	mov    %eax,%edx
  801d34:	85 d2                	test   %edx,%edx
  801d36:	0f 88 4d 01 00 00    	js     801e89 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d43:	00 
  801d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d52:	e8 fc f1 ff ff       	call   800f53 <sys_page_alloc>
  801d57:	89 c2                	mov    %eax,%edx
  801d59:	85 d2                	test   %edx,%edx
  801d5b:	0f 88 28 01 00 00    	js     801e89 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801d61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d64:	89 04 24             	mov    %eax,(%esp)
  801d67:	e8 7b f4 ff ff       	call   8011e7 <fd_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	0f 88 fe 00 00 00    	js     801e74 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d7d:	00 
  801d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d8c:	e8 c2 f1 ff ff       	call   800f53 <sys_page_alloc>
  801d91:	89 c3                	mov    %eax,%ebx
  801d93:	85 c0                	test   %eax,%eax
  801d95:	0f 88 d9 00 00 00    	js     801e74 <pipe+0x155>
	va = fd2data(fd0);
  801d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	e8 2a f4 ff ff       	call   8011d0 <fd2data>
  801da6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801daf:	00 
  801db0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbb:	e8 93 f1 ff ff       	call   800f53 <sys_page_alloc>
  801dc0:	89 c3                	mov    %eax,%ebx
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	0f 88 97 00 00 00    	js     801e61 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dcd:	89 04 24             	mov    %eax,(%esp)
  801dd0:	e8 fb f3 ff ff       	call   8011d0 <fd2data>
  801dd5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ddc:	00 
  801ddd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801de1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801de8:	00 
  801de9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ded:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df4:	e8 ae f1 ff ff       	call   800fa7 <sys_page_map>
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 52                	js     801e51 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801dff:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e14:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2c:	89 04 24             	mov    %eax,(%esp)
  801e2f:	e8 8c f3 ff ff       	call   8011c0 <fd2num>
  801e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e37:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3c:	89 04 24             	mov    %eax,(%esp)
  801e3f:	e8 7c f3 ff ff       	call   8011c0 <fd2num>
  801e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e47:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4f:	eb 38                	jmp    801e89 <pipe+0x16a>
	sys_page_unmap(0, va);
  801e51:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5c:	e8 99 f1 ff ff       	call   800ffa <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6f:	e8 86 f1 ff ff       	call   800ffa <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e82:	e8 73 f1 ff ff       	call   800ffa <sys_page_unmap>
  801e87:	89 d8                	mov    %ebx,%eax
}
  801e89:	83 c4 30             	add    $0x30,%esp
  801e8c:	5b                   	pop    %ebx
  801e8d:	5e                   	pop    %esi
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <pipeisclosed>:
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea0:	89 04 24             	mov    %eax,(%esp)
  801ea3:	e8 8e f3 ff ff       	call   801236 <fd_lookup>
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	85 d2                	test   %edx,%edx
  801eac:	78 15                	js     801ec3 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb1:	89 04 24             	mov    %eax,(%esp)
  801eb4:	e8 17 f3 ff ff       	call   8011d0 <fd2data>
	return _pipeisclosed(fd, p);
  801eb9:	89 c2                	mov    %eax,%edx
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	e8 0b fd ff ff       	call   801bce <_pipeisclosed>
}
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    
  801ec5:	66 90                	xchg   %ax,%ax
  801ec7:	66 90                	xchg   %ax,%ax
  801ec9:	66 90                	xchg   %ax,%ax
  801ecb:	66 90                	xchg   %ax,%ax
  801ecd:	66 90                	xchg   %ax,%ax
  801ecf:	90                   	nop

00801ed0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	56                   	push   %esi
  801ed4:	53                   	push   %ebx
  801ed5:	83 ec 10             	sub    $0x10,%esp
  801ed8:	8b 75 08             	mov    0x8(%ebp),%esi
  801edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ede:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801ee1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801ee3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ee8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801eeb:	89 04 24             	mov    %eax,(%esp)
  801eee:	e8 76 f2 ff ff       	call   801169 <sys_ipc_recv>
    if(r < 0){
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	79 16                	jns    801f0d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801ef7:	85 f6                	test   %esi,%esi
  801ef9:	74 06                	je     801f01 <ipc_recv+0x31>
            *from_env_store = 0;
  801efb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801f01:	85 db                	test   %ebx,%ebx
  801f03:	74 2c                	je     801f31 <ipc_recv+0x61>
            *perm_store = 0;
  801f05:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f0b:	eb 24                	jmp    801f31 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801f0d:	85 f6                	test   %esi,%esi
  801f0f:	74 0a                	je     801f1b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801f11:	a1 24 44 80 00       	mov    0x804424,%eax
  801f16:	8b 40 74             	mov    0x74(%eax),%eax
  801f19:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801f1b:	85 db                	test   %ebx,%ebx
  801f1d:	74 0a                	je     801f29 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801f1f:	a1 24 44 80 00       	mov    0x804424,%eax
  801f24:	8b 40 78             	mov    0x78(%eax),%eax
  801f27:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f29:	a1 24 44 80 00       	mov    0x804424,%eax
  801f2e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5e                   	pop    %esi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	57                   	push   %edi
  801f3c:	56                   	push   %esi
  801f3d:	53                   	push   %ebx
  801f3e:	83 ec 1c             	sub    $0x1c,%esp
  801f41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801f4a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801f4c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f51:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801f54:	8b 45 14             	mov    0x14(%ebp),%eax
  801f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f5b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f63:	89 3c 24             	mov    %edi,(%esp)
  801f66:	e8 db f1 ff ff       	call   801146 <sys_ipc_try_send>
        if(r == 0){
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	74 28                	je     801f97 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801f6f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f72:	74 1c                	je     801f90 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801f74:	c7 44 24 08 9c 27 80 	movl   $0x80279c,0x8(%esp)
  801f7b:	00 
  801f7c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801f83:	00 
  801f84:	c7 04 24 b3 27 80 00 	movl   $0x8027b3,(%esp)
  801f8b:	e8 97 e3 ff ff       	call   800327 <_panic>
        }
        sys_yield();
  801f90:	e8 9f ef ff ff       	call   800f34 <sys_yield>
    }
  801f95:	eb bd                	jmp    801f54 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801f97:	83 c4 1c             	add    $0x1c,%esp
  801f9a:	5b                   	pop    %ebx
  801f9b:	5e                   	pop    %esi
  801f9c:	5f                   	pop    %edi
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801faa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fb3:	8b 52 50             	mov    0x50(%edx),%edx
  801fb6:	39 ca                	cmp    %ecx,%edx
  801fb8:	75 0d                	jne    801fc7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fbd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801fc2:	8b 40 40             	mov    0x40(%eax),%eax
  801fc5:	eb 0e                	jmp    801fd5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801fc7:	83 c0 01             	add    $0x1,%eax
  801fca:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fcf:	75 d9                	jne    801faa <ipc_find_env+0xb>
	return 0;
  801fd1:	66 b8 00 00          	mov    $0x0,%ax
}
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    

00801fd7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdd:	89 d0                	mov    %edx,%eax
  801fdf:	c1 e8 16             	shr    $0x16,%eax
  801fe2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801fee:	f6 c1 01             	test   $0x1,%cl
  801ff1:	74 1d                	je     802010 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801ff3:	c1 ea 0c             	shr    $0xc,%edx
  801ff6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ffd:	f6 c2 01             	test   $0x1,%dl
  802000:	74 0e                	je     802010 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802002:	c1 ea 0c             	shr    $0xc,%edx
  802005:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80200c:	ef 
  80200d:	0f b7 c0             	movzwl %ax,%eax
}
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	66 90                	xchg   %ax,%ax
  802014:	66 90                	xchg   %ax,%ax
  802016:	66 90                	xchg   %ax,%ax
  802018:	66 90                	xchg   %ax,%ax
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	83 ec 0c             	sub    $0xc,%esp
  802026:	8b 44 24 28          	mov    0x28(%esp),%eax
  80202a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80202e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802032:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802036:	85 c0                	test   %eax,%eax
  802038:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80203c:	89 ea                	mov    %ebp,%edx
  80203e:	89 0c 24             	mov    %ecx,(%esp)
  802041:	75 2d                	jne    802070 <__udivdi3+0x50>
  802043:	39 e9                	cmp    %ebp,%ecx
  802045:	77 61                	ja     8020a8 <__udivdi3+0x88>
  802047:	85 c9                	test   %ecx,%ecx
  802049:	89 ce                	mov    %ecx,%esi
  80204b:	75 0b                	jne    802058 <__udivdi3+0x38>
  80204d:	b8 01 00 00 00       	mov    $0x1,%eax
  802052:	31 d2                	xor    %edx,%edx
  802054:	f7 f1                	div    %ecx
  802056:	89 c6                	mov    %eax,%esi
  802058:	31 d2                	xor    %edx,%edx
  80205a:	89 e8                	mov    %ebp,%eax
  80205c:	f7 f6                	div    %esi
  80205e:	89 c5                	mov    %eax,%ebp
  802060:	89 f8                	mov    %edi,%eax
  802062:	f7 f6                	div    %esi
  802064:	89 ea                	mov    %ebp,%edx
  802066:	83 c4 0c             	add    $0xc,%esp
  802069:	5e                   	pop    %esi
  80206a:	5f                   	pop    %edi
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    
  80206d:	8d 76 00             	lea    0x0(%esi),%esi
  802070:	39 e8                	cmp    %ebp,%eax
  802072:	77 24                	ja     802098 <__udivdi3+0x78>
  802074:	0f bd e8             	bsr    %eax,%ebp
  802077:	83 f5 1f             	xor    $0x1f,%ebp
  80207a:	75 3c                	jne    8020b8 <__udivdi3+0x98>
  80207c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802080:	39 34 24             	cmp    %esi,(%esp)
  802083:	0f 86 9f 00 00 00    	jbe    802128 <__udivdi3+0x108>
  802089:	39 d0                	cmp    %edx,%eax
  80208b:	0f 82 97 00 00 00    	jb     802128 <__udivdi3+0x108>
  802091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802098:	31 d2                	xor    %edx,%edx
  80209a:	31 c0                	xor    %eax,%eax
  80209c:	83 c4 0c             	add    $0xc,%esp
  80209f:	5e                   	pop    %esi
  8020a0:	5f                   	pop    %edi
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    
  8020a3:	90                   	nop
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	89 f8                	mov    %edi,%eax
  8020aa:	f7 f1                	div    %ecx
  8020ac:	31 d2                	xor    %edx,%edx
  8020ae:	83 c4 0c             	add    $0xc,%esp
  8020b1:	5e                   	pop    %esi
  8020b2:	5f                   	pop    %edi
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    
  8020b5:	8d 76 00             	lea    0x0(%esi),%esi
  8020b8:	89 e9                	mov    %ebp,%ecx
  8020ba:	8b 3c 24             	mov    (%esp),%edi
  8020bd:	d3 e0                	shl    %cl,%eax
  8020bf:	89 c6                	mov    %eax,%esi
  8020c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8020c6:	29 e8                	sub    %ebp,%eax
  8020c8:	89 c1                	mov    %eax,%ecx
  8020ca:	d3 ef                	shr    %cl,%edi
  8020cc:	89 e9                	mov    %ebp,%ecx
  8020ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8020d2:	8b 3c 24             	mov    (%esp),%edi
  8020d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8020d9:	89 d6                	mov    %edx,%esi
  8020db:	d3 e7                	shl    %cl,%edi
  8020dd:	89 c1                	mov    %eax,%ecx
  8020df:	89 3c 24             	mov    %edi,(%esp)
  8020e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020e6:	d3 ee                	shr    %cl,%esi
  8020e8:	89 e9                	mov    %ebp,%ecx
  8020ea:	d3 e2                	shl    %cl,%edx
  8020ec:	89 c1                	mov    %eax,%ecx
  8020ee:	d3 ef                	shr    %cl,%edi
  8020f0:	09 d7                	or     %edx,%edi
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	89 f8                	mov    %edi,%eax
  8020f6:	f7 74 24 08          	divl   0x8(%esp)
  8020fa:	89 d6                	mov    %edx,%esi
  8020fc:	89 c7                	mov    %eax,%edi
  8020fe:	f7 24 24             	mull   (%esp)
  802101:	39 d6                	cmp    %edx,%esi
  802103:	89 14 24             	mov    %edx,(%esp)
  802106:	72 30                	jb     802138 <__udivdi3+0x118>
  802108:	8b 54 24 04          	mov    0x4(%esp),%edx
  80210c:	89 e9                	mov    %ebp,%ecx
  80210e:	d3 e2                	shl    %cl,%edx
  802110:	39 c2                	cmp    %eax,%edx
  802112:	73 05                	jae    802119 <__udivdi3+0xf9>
  802114:	3b 34 24             	cmp    (%esp),%esi
  802117:	74 1f                	je     802138 <__udivdi3+0x118>
  802119:	89 f8                	mov    %edi,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	e9 7a ff ff ff       	jmp    80209c <__udivdi3+0x7c>
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	31 d2                	xor    %edx,%edx
  80212a:	b8 01 00 00 00       	mov    $0x1,%eax
  80212f:	e9 68 ff ff ff       	jmp    80209c <__udivdi3+0x7c>
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	8d 47 ff             	lea    -0x1(%edi),%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	83 c4 0c             	add    $0xc,%esp
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	83 ec 14             	sub    $0x14,%esp
  802156:	8b 44 24 28          	mov    0x28(%esp),%eax
  80215a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80215e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802162:	89 c7                	mov    %eax,%edi
  802164:	89 44 24 04          	mov    %eax,0x4(%esp)
  802168:	8b 44 24 30          	mov    0x30(%esp),%eax
  80216c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802170:	89 34 24             	mov    %esi,(%esp)
  802173:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802177:	85 c0                	test   %eax,%eax
  802179:	89 c2                	mov    %eax,%edx
  80217b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80217f:	75 17                	jne    802198 <__umoddi3+0x48>
  802181:	39 fe                	cmp    %edi,%esi
  802183:	76 4b                	jbe    8021d0 <__umoddi3+0x80>
  802185:	89 c8                	mov    %ecx,%eax
  802187:	89 fa                	mov    %edi,%edx
  802189:	f7 f6                	div    %esi
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	31 d2                	xor    %edx,%edx
  80218f:	83 c4 14             	add    $0x14,%esp
  802192:	5e                   	pop    %esi
  802193:	5f                   	pop    %edi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    
  802196:	66 90                	xchg   %ax,%ax
  802198:	39 f8                	cmp    %edi,%eax
  80219a:	77 54                	ja     8021f0 <__umoddi3+0xa0>
  80219c:	0f bd e8             	bsr    %eax,%ebp
  80219f:	83 f5 1f             	xor    $0x1f,%ebp
  8021a2:	75 5c                	jne    802200 <__umoddi3+0xb0>
  8021a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8021a8:	39 3c 24             	cmp    %edi,(%esp)
  8021ab:	0f 87 e7 00 00 00    	ja     802298 <__umoddi3+0x148>
  8021b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021b5:	29 f1                	sub    %esi,%ecx
  8021b7:	19 c7                	sbb    %eax,%edi
  8021b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021c9:	83 c4 14             	add    $0x14,%esp
  8021cc:	5e                   	pop    %esi
  8021cd:	5f                   	pop    %edi
  8021ce:	5d                   	pop    %ebp
  8021cf:	c3                   	ret    
  8021d0:	85 f6                	test   %esi,%esi
  8021d2:	89 f5                	mov    %esi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f6                	div    %esi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021e5:	31 d2                	xor    %edx,%edx
  8021e7:	f7 f5                	div    %ebp
  8021e9:	89 c8                	mov    %ecx,%eax
  8021eb:	f7 f5                	div    %ebp
  8021ed:	eb 9c                	jmp    80218b <__umoddi3+0x3b>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 fa                	mov    %edi,%edx
  8021f4:	83 c4 14             	add    $0x14,%esp
  8021f7:	5e                   	pop    %esi
  8021f8:	5f                   	pop    %edi
  8021f9:	5d                   	pop    %ebp
  8021fa:	c3                   	ret    
  8021fb:	90                   	nop
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 04 24             	mov    (%esp),%eax
  802203:	be 20 00 00 00       	mov    $0x20,%esi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ee                	sub    %ebp,%esi
  80220c:	d3 e2                	shl    %cl,%edx
  80220e:	89 f1                	mov    %esi,%ecx
  802210:	d3 e8                	shr    %cl,%eax
  802212:	89 e9                	mov    %ebp,%ecx
  802214:	89 44 24 04          	mov    %eax,0x4(%esp)
  802218:	8b 04 24             	mov    (%esp),%eax
  80221b:	09 54 24 04          	or     %edx,0x4(%esp)
  80221f:	89 fa                	mov    %edi,%edx
  802221:	d3 e0                	shl    %cl,%eax
  802223:	89 f1                	mov    %esi,%ecx
  802225:	89 44 24 08          	mov    %eax,0x8(%esp)
  802229:	8b 44 24 10          	mov    0x10(%esp),%eax
  80222d:	d3 ea                	shr    %cl,%edx
  80222f:	89 e9                	mov    %ebp,%ecx
  802231:	d3 e7                	shl    %cl,%edi
  802233:	89 f1                	mov    %esi,%ecx
  802235:	d3 e8                	shr    %cl,%eax
  802237:	89 e9                	mov    %ebp,%ecx
  802239:	09 f8                	or     %edi,%eax
  80223b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80223f:	f7 74 24 04          	divl   0x4(%esp)
  802243:	d3 e7                	shl    %cl,%edi
  802245:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802249:	89 d7                	mov    %edx,%edi
  80224b:	f7 64 24 08          	mull   0x8(%esp)
  80224f:	39 d7                	cmp    %edx,%edi
  802251:	89 c1                	mov    %eax,%ecx
  802253:	89 14 24             	mov    %edx,(%esp)
  802256:	72 2c                	jb     802284 <__umoddi3+0x134>
  802258:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80225c:	72 22                	jb     802280 <__umoddi3+0x130>
  80225e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802262:	29 c8                	sub    %ecx,%eax
  802264:	19 d7                	sbb    %edx,%edi
  802266:	89 e9                	mov    %ebp,%ecx
  802268:	89 fa                	mov    %edi,%edx
  80226a:	d3 e8                	shr    %cl,%eax
  80226c:	89 f1                	mov    %esi,%ecx
  80226e:	d3 e2                	shl    %cl,%edx
  802270:	89 e9                	mov    %ebp,%ecx
  802272:	d3 ef                	shr    %cl,%edi
  802274:	09 d0                	or     %edx,%eax
  802276:	89 fa                	mov    %edi,%edx
  802278:	83 c4 14             	add    $0x14,%esp
  80227b:	5e                   	pop    %esi
  80227c:	5f                   	pop    %edi
  80227d:	5d                   	pop    %ebp
  80227e:	c3                   	ret    
  80227f:	90                   	nop
  802280:	39 d7                	cmp    %edx,%edi
  802282:	75 da                	jne    80225e <__umoddi3+0x10e>
  802284:	8b 14 24             	mov    (%esp),%edx
  802287:	89 c1                	mov    %eax,%ecx
  802289:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80228d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802291:	eb cb                	jmp    80225e <__umoddi3+0x10e>
  802293:	90                   	nop
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80229c:	0f 82 0f ff ff ff    	jb     8021b1 <__umoddi3+0x61>
  8022a2:	e9 1a ff ff ff       	jmp    8021c1 <__umoddi3+0x71>
