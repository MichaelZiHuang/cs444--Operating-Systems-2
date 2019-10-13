
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 fa 02 00 00       	call   80032b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80004e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800055:	74 23                	je     80007a <ls1+0x3a>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800057:	89 f0                	mov    %esi,%eax
  800059:	3c 01                	cmp    $0x1,%al
  80005b:	19 c0                	sbb    %eax,%eax
  80005d:	83 e0 c9             	and    $0xffffffc9,%eax
  800060:	83 c0 64             	add    $0x64,%eax
  800063:	89 44 24 08          	mov    %eax,0x8(%esp)
  800067:	8b 45 10             	mov    0x10(%ebp),%eax
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 42 25 80 00 	movl   $0x802542,(%esp)
  800075:	e8 77 1b 00 00       	call   801bf1 <printf>
	if(prefix) {
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	74 38                	je     8000b6 <ls1+0x76>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80007e:	b8 a8 25 80 00       	mov    $0x8025a8,%eax
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800083:	80 3b 00             	cmpb   $0x0,(%ebx)
  800086:	74 1a                	je     8000a2 <ls1+0x62>
  800088:	89 1c 24             	mov    %ebx,(%esp)
  80008b:	e8 e0 09 00 00       	call   800a70 <strlen>
  800090:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
			sep = "/";
  800095:	b8 40 25 80 00       	mov    $0x802540,%eax
  80009a:	ba a8 25 80 00       	mov    $0x8025a8,%edx
  80009f:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  8000a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000aa:	c7 04 24 4b 25 80 00 	movl   $0x80254b,(%esp)
  8000b1:	e8 3b 1b 00 00       	call   801bf1 <printf>
	}
	printf("%s", name);
  8000b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 fe 29 80 00 	movl   $0x8029fe,(%esp)
  8000c4:	e8 28 1b 00 00       	call   801bf1 <printf>
	if(flag['F'] && isdir)
  8000c9:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000d0:	74 12                	je     8000e4 <ls1+0xa4>
  8000d2:	89 f0                	mov    %esi,%eax
  8000d4:	84 c0                	test   %al,%al
  8000d6:	74 0c                	je     8000e4 <ls1+0xa4>
		printf("/");
  8000d8:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  8000df:	e8 0d 1b 00 00       	call   801bf1 <printf>
	printf("\n");
  8000e4:	c7 04 24 a7 25 80 00 	movl   $0x8025a7,(%esp)
  8000eb:	e8 01 1b 00 00       	call   801bf1 <printf>
}
  8000f0:	83 c4 10             	add    $0x10,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <lsdir>:
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  800103:	8b 7d 08             	mov    0x8(%ebp),%edi
	if ((fd = open(path, O_RDONLY)) < 0)
  800106:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010d:	00 
  80010e:	89 3c 24             	mov    %edi,(%esp)
  800111:	e8 2b 19 00 00       	call   801a41 <open>
  800116:	89 c3                	mov    %eax,%ebx
  800118:	85 c0                	test   %eax,%eax
  80011a:	78 08                	js     800124 <lsdir+0x2d>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80011c:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800122:	eb 57                	jmp    80017b <lsdir+0x84>
		panic("open %s: %e", path, fd);
  800124:	89 44 24 10          	mov    %eax,0x10(%esp)
  800128:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80012c:	c7 44 24 08 50 25 80 	movl   $0x802550,0x8(%esp)
  800133:	00 
  800134:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80013b:	00 
  80013c:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800143:	e8 44 02 00 00       	call   80038c <_panic>
		if (f.f_name[0])
  800148:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80014f:	74 2a                	je     80017b <lsdir+0x84>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800151:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800155:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80015b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015f:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  800166:	0f 94 c0             	sete   %al
  800169:	0f b6 c0             	movzbl %al,%eax
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 c5 fe ff ff       	call   800040 <ls1>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80017b:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  800182:	00 
  800183:	89 74 24 04          	mov    %esi,0x4(%esp)
  800187:	89 1c 24             	mov    %ebx,(%esp)
  80018a:	e8 98 14 00 00       	call   801627 <readn>
  80018f:	3d 00 01 00 00       	cmp    $0x100,%eax
  800194:	74 b2                	je     800148 <lsdir+0x51>
	if (n > 0)
  800196:	85 c0                	test   %eax,%eax
  800198:	7e 20                	jle    8001ba <lsdir+0xc3>
		panic("short read in directory %s", path);
  80019a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80019e:	c7 44 24 08 66 25 80 	movl   $0x802566,0x8(%esp)
  8001a5:	00 
  8001a6:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001ad:	00 
  8001ae:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  8001b5:	e8 d2 01 00 00       	call   80038c <_panic>
	if (n < 0)
  8001ba:	85 c0                	test   %eax,%eax
  8001bc:	79 24                	jns    8001e2 <lsdir+0xeb>
		panic("error reading directory %s: %e", path, n);
  8001be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001c6:	c7 44 24 08 ac 25 80 	movl   $0x8025ac,0x8(%esp)
  8001cd:	00 
  8001ce:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d5:	00 
  8001d6:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  8001dd:	e8 aa 01 00 00       	call   80038c <_panic>
}
  8001e2:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <ls>:
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	53                   	push   %ebx
  8001f1:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  8001f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = stat(path, &st)) < 0)
  8001fa:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	89 1c 24             	mov    %ebx,(%esp)
  800207:	e8 1f 16 00 00       	call   80182b <stat>
  80020c:	85 c0                	test   %eax,%eax
  80020e:	79 24                	jns    800234 <ls+0x47>
		panic("stat %s: %e", path, r);
  800210:	89 44 24 10          	mov    %eax,0x10(%esp)
  800214:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800218:	c7 44 24 08 81 25 80 	movl   $0x802581,0x8(%esp)
  80021f:	00 
  800220:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800227:	00 
  800228:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  80022f:	e8 58 01 00 00       	call   80038c <_panic>
	if (st.st_isdir && !flag['d'])
  800234:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800237:	85 c0                	test   %eax,%eax
  800239:	74 1a                	je     800255 <ls+0x68>
  80023b:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800242:	75 11                	jne    800255 <ls+0x68>
		lsdir(path, prefix);
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
  800247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024b:	89 1c 24             	mov    %ebx,(%esp)
  80024e:	e8 a4 fe ff ff       	call   8000f7 <lsdir>
  800253:	eb 23                	jmp    800278 <ls+0x8b>
		ls1(0, st.st_isdir, st.st_size, path);
  800255:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800259:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80025c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800260:	85 c0                	test   %eax,%eax
  800262:	0f 95 c0             	setne  %al
  800265:	0f b6 c0             	movzbl %al,%eax
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800273:	e8 c8 fd ff ff       	call   800040 <ls1>
}
  800278:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <usage>:

void
usage(void)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800287:	c7 04 24 8d 25 80 00 	movl   $0x80258d,(%esp)
  80028e:	e8 5e 19 00 00       	call   801bf1 <printf>
	exit();
  800293:	e8 db 00 00 00       	call   800373 <exit>
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <umain>:

void
umain(int argc, char **argv)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 20             	sub    $0x20,%esp
  8002a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002a5:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b0:	8d 45 08             	lea    0x8(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	e8 70 0e 00 00       	call   80112b <argstart>
	while ((i = argnext(&args)) >= 0)
  8002bb:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002be:	eb 1e                	jmp    8002de <umain+0x44>
		switch (i) {
  8002c0:	83 f8 64             	cmp    $0x64,%eax
  8002c3:	74 0a                	je     8002cf <umain+0x35>
  8002c5:	83 f8 6c             	cmp    $0x6c,%eax
  8002c8:	74 05                	je     8002cf <umain+0x35>
  8002ca:	83 f8 46             	cmp    $0x46,%eax
  8002cd:	75 0a                	jne    8002d9 <umain+0x3f>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002cf:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  8002d6:	01 
			break;
  8002d7:	eb 05                	jmp    8002de <umain+0x44>
		default:
			usage();
  8002d9:	e8 a3 ff ff ff       	call   800281 <usage>
	while ((i = argnext(&args)) >= 0)
  8002de:	89 1c 24             	mov    %ebx,(%esp)
  8002e1:	e8 7d 0e 00 00       	call   801163 <argnext>
  8002e6:	85 c0                	test   %eax,%eax
  8002e8:	79 d6                	jns    8002c0 <umain+0x26>
		}

	if (argc == 1)
  8002ea:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002ee:	74 07                	je     8002f7 <umain+0x5d>
  8002f0:	bb 01 00 00 00       	mov    $0x1,%ebx
  8002f5:	eb 28                	jmp    80031f <umain+0x85>
		ls("/", "");
  8002f7:	c7 44 24 04 a8 25 80 	movl   $0x8025a8,0x4(%esp)
  8002fe:	00 
  8002ff:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  800306:	e8 e2 fe ff ff       	call   8001ed <ls>
  80030b:	eb 17                	jmp    800324 <umain+0x8a>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  80030d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	e8 d1 fe ff ff       	call   8001ed <ls>
		for (i = 1; i < argc; i++)
  80031c:	83 c3 01             	add    $0x1,%ebx
  80031f:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800322:	7c e9                	jl     80030d <umain+0x73>
	}
}
  800324:	83 c4 20             	add    $0x20,%esp
  800327:	5b                   	pop    %ebx
  800328:	5e                   	pop    %esi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
  800330:	83 ec 10             	sub    $0x10,%esp
  800333:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800336:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800339:	e8 47 0b 00 00       	call   800e85 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  80033e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800343:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800346:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80034b:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800350:	85 db                	test   %ebx,%ebx
  800352:	7e 07                	jle    80035b <libmain+0x30>
		binaryname = argv[0];
  800354:	8b 06                	mov    (%esi),%eax
  800356:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80035b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80035f:	89 1c 24             	mov    %ebx,(%esp)
  800362:	e8 33 ff ff ff       	call   80029a <umain>

	// exit gracefully
	exit();
  800367:	e8 07 00 00 00       	call   800373 <exit>
}
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800379:	e8 e7 10 00 00       	call   801465 <close_all>
	sys_env_destroy(0);
  80037e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800385:	e8 a9 0a 00 00       	call   800e33 <sys_env_destroy>
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
  800391:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800394:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800397:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80039d:	e8 e3 0a 00 00       	call   800e85 <sys_getenvid>
  8003a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	c7 04 24 d8 25 80 00 	movl   $0x8025d8,(%esp)
  8003bf:	e8 c1 00 00 00       	call   800485 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	e8 51 00 00 00       	call   800424 <vcprintf>
	cprintf("\n");
  8003d3:	c7 04 24 a7 25 80 00 	movl   $0x8025a7,(%esp)
  8003da:	e8 a6 00 00 00       	call   800485 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003df:	cc                   	int3   
  8003e0:	eb fd                	jmp    8003df <_panic+0x53>

008003e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 14             	sub    $0x14,%esp
  8003e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ec:	8b 13                	mov    (%ebx),%edx
  8003ee:	8d 42 01             	lea    0x1(%edx),%eax
  8003f1:	89 03                	mov    %eax,(%ebx)
  8003f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ff:	75 19                	jne    80041a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800401:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800408:	00 
  800409:	8d 43 08             	lea    0x8(%ebx),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 e2 09 00 00       	call   800df6 <sys_cputs>
		b->idx = 0;
  800414:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80041e:	83 c4 14             	add    $0x14,%esp
  800421:	5b                   	pop    %ebx
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80042d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800434:	00 00 00 
	b.cnt = 0;
  800437:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80043e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800441:	8b 45 0c             	mov    0xc(%ebp),%eax
  800444:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
  80044b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800455:	89 44 24 04          	mov    %eax,0x4(%esp)
  800459:	c7 04 24 e2 03 80 00 	movl   $0x8003e2,(%esp)
  800460:	e8 a9 01 00 00       	call   80060e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800465:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800475:	89 04 24             	mov    %eax,(%esp)
  800478:	e8 79 09 00 00       	call   800df6 <sys_cputs>

	return b.cnt;
}
  80047d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800492:	8b 45 08             	mov    0x8(%ebp),%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	e8 87 ff ff ff       	call   800424 <vcprintf>
	va_end(ap);

	return cnt;
}
  80049d:	c9                   	leave  
  80049e:	c3                   	ret    
  80049f:	90                   	nop

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 c3                	mov    %eax,%ebx
  8004b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004cd:	39 d9                	cmp    %ebx,%ecx
  8004cf:	72 05                	jb     8004d6 <printnum+0x36>
  8004d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004d4:	77 69                	ja     80053f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004f0:	89 c3                	mov    %eax,%ebx
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	e8 8c 1d 00 00       	call   8022a0 <__udivdi3>
  800514:	89 d9                	mov    %ebx,%ecx
  800516:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80051a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	89 54 24 04          	mov    %edx,0x4(%esp)
  800525:	89 fa                	mov    %edi,%edx
  800527:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052a:	e8 71 ff ff ff       	call   8004a0 <printnum>
  80052f:	eb 1b                	jmp    80054c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800531:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800535:	8b 45 18             	mov    0x18(%ebp),%eax
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	ff d3                	call   *%ebx
  80053d:	eb 03                	jmp    800542 <printnum+0xa2>
  80053f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800542:	83 ee 01             	sub    $0x1,%esi
  800545:	85 f6                	test   %esi,%esi
  800547:	7f e8                	jg     800531 <printnum+0x91>
  800549:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80054c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800550:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80055a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	e8 5c 1e 00 00       	call   8023d0 <__umoddi3>
  800574:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800578:	0f be 80 fb 25 80 00 	movsbl 0x8025fb(%eax),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800585:	ff d0                	call   *%eax
}
  800587:	83 c4 3c             	add    $0x3c,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5f                   	pop    %edi
  80058d:	5d                   	pop    %ebp
  80058e:	c3                   	ret    

0080058f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800592:	83 fa 01             	cmp    $0x1,%edx
  800595:	7e 0e                	jle    8005a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800597:	8b 10                	mov    (%eax),%edx
  800599:	8d 4a 08             	lea    0x8(%edx),%ecx
  80059c:	89 08                	mov    %ecx,(%eax)
  80059e:	8b 02                	mov    (%edx),%eax
  8005a0:	8b 52 04             	mov    0x4(%edx),%edx
  8005a3:	eb 22                	jmp    8005c7 <getuint+0x38>
	else if (lflag)
  8005a5:	85 d2                	test   %edx,%edx
  8005a7:	74 10                	je     8005b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ae:	89 08                	mov    %ecx,(%eax)
  8005b0:	8b 02                	mov    (%edx),%eax
  8005b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b7:	eb 0e                	jmp    8005c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005be:	89 08                	mov    %ecx,(%eax)
  8005c0:	8b 02                	mov    (%edx),%eax
  8005c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005c7:	5d                   	pop    %ebp
  8005c8:	c3                   	ret    

008005c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8005d8:	73 0a                	jae    8005e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005dd:	89 08                	mov    %ecx,(%eax)
  8005df:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e2:	88 02                	mov    %al,(%edx)
}
  8005e4:	5d                   	pop    %ebp
  8005e5:	c3                   	ret    

008005e6 <printfmt>:
{
  8005e6:	55                   	push   %ebp
  8005e7:	89 e5                	mov    %esp,%ebp
  8005e9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800601:	8b 45 08             	mov    0x8(%ebp),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	e8 02 00 00 00       	call   80060e <vprintfmt>
}
  80060c:	c9                   	leave  
  80060d:	c3                   	ret    

0080060e <vprintfmt>:
{
  80060e:	55                   	push   %ebp
  80060f:	89 e5                	mov    %esp,%ebp
  800611:	57                   	push   %edi
  800612:	56                   	push   %esi
  800613:	53                   	push   %ebx
  800614:	83 ec 3c             	sub    $0x3c,%esp
  800617:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80061a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80061d:	eb 1f                	jmp    80063e <vprintfmt+0x30>
			if (ch == '\0'){
  80061f:	85 c0                	test   %eax,%eax
  800621:	75 0f                	jne    800632 <vprintfmt+0x24>
				color = 0x0100;
  800623:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  80062a:	01 00 00 
  80062d:	e9 b3 03 00 00       	jmp    8009e5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800636:	89 04 24             	mov    %eax,(%esp)
  800639:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063c:	89 f3                	mov    %esi,%ebx
  80063e:	8d 73 01             	lea    0x1(%ebx),%esi
  800641:	0f b6 03             	movzbl (%ebx),%eax
  800644:	83 f8 25             	cmp    $0x25,%eax
  800647:	75 d6                	jne    80061f <vprintfmt+0x11>
  800649:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80064d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800654:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80065b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800662:	ba 00 00 00 00       	mov    $0x0,%edx
  800667:	eb 1d                	jmp    800686 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800669:	89 de                	mov    %ebx,%esi
			padc = '-';
  80066b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80066f:	eb 15                	jmp    800686 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800671:	89 de                	mov    %ebx,%esi
			padc = '0';
  800673:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800677:	eb 0d                	jmp    800686 <vprintfmt+0x78>
				width = precision, precision = -1;
  800679:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80067c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80067f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8d 5e 01             	lea    0x1(%esi),%ebx
  800689:	0f b6 0e             	movzbl (%esi),%ecx
  80068c:	0f b6 c1             	movzbl %cl,%eax
  80068f:	83 e9 23             	sub    $0x23,%ecx
  800692:	80 f9 55             	cmp    $0x55,%cl
  800695:	0f 87 2a 03 00 00    	ja     8009c5 <vprintfmt+0x3b7>
  80069b:	0f b6 c9             	movzbl %cl,%ecx
  80069e:	ff 24 8d 40 27 80 00 	jmp    *0x802740(,%ecx,4)
  8006a5:	89 de                	mov    %ebx,%esi
  8006a7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8006ac:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006af:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006b3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006b6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006b9:	83 fb 09             	cmp    $0x9,%ebx
  8006bc:	77 36                	ja     8006f4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8006be:	83 c6 01             	add    $0x1,%esi
			}
  8006c1:	eb e9                	jmp    8006ac <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8006d3:	eb 22                	jmp    8006f7 <vprintfmt+0xe9>
  8006d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	0f 49 c1             	cmovns %ecx,%eax
  8006e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006e5:	89 de                	mov    %ebx,%esi
  8006e7:	eb 9d                	jmp    800686 <vprintfmt+0x78>
  8006e9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8006eb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8006f2:	eb 92                	jmp    800686 <vprintfmt+0x78>
  8006f4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8006f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006fb:	79 89                	jns    800686 <vprintfmt+0x78>
  8006fd:	e9 77 ff ff ff       	jmp    800679 <vprintfmt+0x6b>
			lflag++;
  800702:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800705:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800707:	e9 7a ff ff ff       	jmp    800686 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8d 50 04             	lea    0x4(%eax),%edx
  800712:	89 55 14             	mov    %edx,0x14(%ebp)
  800715:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800719:	8b 00                	mov    (%eax),%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800721:	e9 18 ff ff ff       	jmp    80063e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	99                   	cltd   
  800732:	31 d0                	xor    %edx,%eax
  800734:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800736:	83 f8 0f             	cmp    $0xf,%eax
  800739:	7f 0b                	jg     800746 <vprintfmt+0x138>
  80073b:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  800742:	85 d2                	test   %edx,%edx
  800744:	75 20                	jne    800766 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800746:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074a:	c7 44 24 08 13 26 80 	movl   $0x802613,0x8(%esp)
  800751:	00 
  800752:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	89 04 24             	mov    %eax,(%esp)
  80075c:	e8 85 fe ff ff       	call   8005e6 <printfmt>
  800761:	e9 d8 fe ff ff       	jmp    80063e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800766:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80076a:	c7 44 24 08 fe 29 80 	movl   $0x8029fe,0x8(%esp)
  800771:	00 
  800772:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	89 04 24             	mov    %eax,(%esp)
  80077c:	e8 65 fe ff ff       	call   8005e6 <printfmt>
  800781:	e9 b8 fe ff ff       	jmp    80063e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800789:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80078c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 04             	lea    0x4(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80079a:	85 f6                	test   %esi,%esi
  80079c:	b8 0c 26 80 00       	mov    $0x80260c,%eax
  8007a1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007a4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007a8:	0f 84 97 00 00 00    	je     800845 <vprintfmt+0x237>
  8007ae:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007b2:	0f 8e 9b 00 00 00    	jle    800853 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007bc:	89 34 24             	mov    %esi,(%esp)
  8007bf:	e8 c4 02 00 00       	call   800a88 <strnlen>
  8007c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007c7:	29 c2                	sub    %eax,%edx
  8007c9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8007cc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007d3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007dc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8007de:	eb 0f                	jmp    8007ef <vprintfmt+0x1e1>
					putch(padc, putdat);
  8007e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ec:	83 eb 01             	sub    $0x1,%ebx
  8007ef:	85 db                	test   %ebx,%ebx
  8007f1:	7f ed                	jg     8007e0 <vprintfmt+0x1d2>
  8007f3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	0f 49 c2             	cmovns %edx,%eax
  800803:	29 c2                	sub    %eax,%edx
  800805:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800808:	89 d7                	mov    %edx,%edi
  80080a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80080d:	eb 50                	jmp    80085f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80080f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800813:	74 1e                	je     800833 <vprintfmt+0x225>
  800815:	0f be d2             	movsbl %dl,%edx
  800818:	83 ea 20             	sub    $0x20,%edx
  80081b:	83 fa 5e             	cmp    $0x5e,%edx
  80081e:	76 13                	jbe    800833 <vprintfmt+0x225>
					putch('?', putdat);
  800820:	8b 45 0c             	mov    0xc(%ebp),%eax
  800823:	89 44 24 04          	mov    %eax,0x4(%esp)
  800827:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80082e:	ff 55 08             	call   *0x8(%ebp)
  800831:	eb 0d                	jmp    800840 <vprintfmt+0x232>
					putch(ch, putdat);
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
  800836:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083a:	89 04 24             	mov    %eax,(%esp)
  80083d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800840:	83 ef 01             	sub    $0x1,%edi
  800843:	eb 1a                	jmp    80085f <vprintfmt+0x251>
  800845:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800848:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80084b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80084e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800851:	eb 0c                	jmp    80085f <vprintfmt+0x251>
  800853:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800856:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800859:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80085c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80085f:	83 c6 01             	add    $0x1,%esi
  800862:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800866:	0f be c2             	movsbl %dl,%eax
  800869:	85 c0                	test   %eax,%eax
  80086b:	74 27                	je     800894 <vprintfmt+0x286>
  80086d:	85 db                	test   %ebx,%ebx
  80086f:	78 9e                	js     80080f <vprintfmt+0x201>
  800871:	83 eb 01             	sub    $0x1,%ebx
  800874:	79 99                	jns    80080f <vprintfmt+0x201>
  800876:	89 f8                	mov    %edi,%eax
  800878:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	89 c3                	mov    %eax,%ebx
  800880:	eb 1a                	jmp    80089c <vprintfmt+0x28e>
				putch(' ', putdat);
  800882:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800886:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80088d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80088f:	83 eb 01             	sub    $0x1,%ebx
  800892:	eb 08                	jmp    80089c <vprintfmt+0x28e>
  800894:	89 fb                	mov    %edi,%ebx
  800896:	8b 75 08             	mov    0x8(%ebp),%esi
  800899:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80089c:	85 db                	test   %ebx,%ebx
  80089e:	7f e2                	jg     800882 <vprintfmt+0x274>
  8008a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8008a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008a6:	e9 93 fd ff ff       	jmp    80063e <vprintfmt+0x30>
	if (lflag >= 2)
  8008ab:	83 fa 01             	cmp    $0x1,%edx
  8008ae:	7e 16                	jle    8008c6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	8d 50 08             	lea    0x8(%eax),%edx
  8008b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b9:	8b 50 04             	mov    0x4(%eax),%edx
  8008bc:	8b 00                	mov    (%eax),%eax
  8008be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008c4:	eb 32                	jmp    8008f8 <vprintfmt+0x2ea>
	else if (lflag)
  8008c6:	85 d2                	test   %edx,%edx
  8008c8:	74 18                	je     8008e2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 30                	mov    (%eax),%esi
  8008d5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008d8:	89 f0                	mov    %esi,%eax
  8008da:	c1 f8 1f             	sar    $0x1f,%eax
  8008dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e0:	eb 16                	jmp    8008f8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8d 50 04             	lea    0x4(%eax),%edx
  8008e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008eb:	8b 30                	mov    (%eax),%esi
  8008ed:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008f0:	89 f0                	mov    %esi,%eax
  8008f2:	c1 f8 1f             	sar    $0x1f,%eax
  8008f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8008f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8008fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800903:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800907:	0f 89 80 00 00 00    	jns    80098d <vprintfmt+0x37f>
				putch('-', putdat);
  80090d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800911:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800918:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80091b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800921:	f7 d8                	neg    %eax
  800923:	83 d2 00             	adc    $0x0,%edx
  800926:	f7 da                	neg    %edx
			base = 10;
  800928:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80092d:	eb 5e                	jmp    80098d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80092f:	8d 45 14             	lea    0x14(%ebp),%eax
  800932:	e8 58 fc ff ff       	call   80058f <getuint>
			base = 10;
  800937:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80093c:	eb 4f                	jmp    80098d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80093e:	8d 45 14             	lea    0x14(%ebp),%eax
  800941:	e8 49 fc ff ff       	call   80058f <getuint>
            base = 8;
  800946:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80094b:	eb 40                	jmp    80098d <vprintfmt+0x37f>
			putch('0', putdat);
  80094d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800951:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800958:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80095b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800966:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800969:	8b 45 14             	mov    0x14(%ebp),%eax
  80096c:	8d 50 04             	lea    0x4(%eax),%edx
  80096f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800972:	8b 00                	mov    (%eax),%eax
  800974:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800979:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80097e:	eb 0d                	jmp    80098d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800980:	8d 45 14             	lea    0x14(%ebp),%eax
  800983:	e8 07 fc ff ff       	call   80058f <getuint>
			base = 16;
  800988:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80098d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800991:	89 74 24 10          	mov    %esi,0x10(%esp)
  800995:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800998:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80099c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009a0:	89 04 24             	mov    %eax,(%esp)
  8009a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a7:	89 fa                	mov    %edi,%edx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	e8 ef fa ff ff       	call   8004a0 <printnum>
			break;
  8009b1:	e9 88 fc ff ff       	jmp    80063e <vprintfmt+0x30>
			putch(ch, putdat);
  8009b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ba:	89 04 24             	mov    %eax,(%esp)
  8009bd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009c0:	e9 79 fc ff ff       	jmp    80063e <vprintfmt+0x30>
			putch('%', putdat);
  8009c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009c9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009d0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009d3:	89 f3                	mov    %esi,%ebx
  8009d5:	eb 03                	jmp    8009da <vprintfmt+0x3cc>
  8009d7:	83 eb 01             	sub    $0x1,%ebx
  8009da:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009de:	75 f7                	jne    8009d7 <vprintfmt+0x3c9>
  8009e0:	e9 59 fc ff ff       	jmp    80063e <vprintfmt+0x30>
}
  8009e5:	83 c4 3c             	add    $0x3c,%esp
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	83 ec 28             	sub    $0x28,%esp
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a00:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a0a:	85 c0                	test   %eax,%eax
  800a0c:	74 30                	je     800a3e <vsnprintf+0x51>
  800a0e:	85 d2                	test   %edx,%edx
  800a10:	7e 2c                	jle    800a3e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a12:	8b 45 14             	mov    0x14(%ebp),%eax
  800a15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a19:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a20:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a27:	c7 04 24 c9 05 80 00 	movl   $0x8005c9,(%esp)
  800a2e:	e8 db fb ff ff       	call   80060e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a36:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a3c:	eb 05                	jmp    800a43 <vsnprintf+0x56>
		return -E_INVAL;
  800a3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a43:	c9                   	leave  
  800a44:	c3                   	ret    

00800a45 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a4b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a52:	8b 45 10             	mov    0x10(%ebp),%eax
  800a55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	89 04 24             	mov    %eax,(%esp)
  800a66:	e8 82 ff ff ff       	call   8009ed <vsnprintf>
	va_end(ap);

	return rc;
}
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    
  800a6d:	66 90                	xchg   %ax,%ax
  800a6f:	90                   	nop

00800a70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	eb 03                	jmp    800a80 <strlen+0x10>
		n++;
  800a7d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a80:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a84:	75 f7                	jne    800a7d <strlen+0xd>
	return n;
}
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	eb 03                	jmp    800a9b <strnlen+0x13>
		n++;
  800a98:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a9b:	39 d0                	cmp    %edx,%eax
  800a9d:	74 06                	je     800aa5 <strnlen+0x1d>
  800a9f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aa3:	75 f3                	jne    800a98 <strnlen+0x10>
	return n;
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab1:	89 c2                	mov    %eax,%edx
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800abd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ac0:	84 db                	test   %bl,%bl
  800ac2:	75 ef                	jne    800ab3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	83 ec 08             	sub    $0x8,%esp
  800ace:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad1:	89 1c 24             	mov    %ebx,(%esp)
  800ad4:	e8 97 ff ff ff       	call   800a70 <strlen>
	strcpy(dst + len, src);
  800ad9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae0:	01 d8                	add    %ebx,%eax
  800ae2:	89 04 24             	mov    %eax,(%esp)
  800ae5:	e8 bd ff ff ff       	call   800aa7 <strcpy>
	return dst;
}
  800aea:	89 d8                	mov    %ebx,%eax
  800aec:	83 c4 08             	add    $0x8,%esp
  800aef:	5b                   	pop    %ebx
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	8b 75 08             	mov    0x8(%ebp),%esi
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	89 f3                	mov    %esi,%ebx
  800aff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b02:	89 f2                	mov    %esi,%edx
  800b04:	eb 0f                	jmp    800b15 <strncpy+0x23>
		*dst++ = *src;
  800b06:	83 c2 01             	add    $0x1,%edx
  800b09:	0f b6 01             	movzbl (%ecx),%eax
  800b0c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b0f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b12:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b15:	39 da                	cmp    %ebx,%edx
  800b17:	75 ed                	jne    800b06 <strncpy+0x14>
	}
	return ret;
}
  800b19:	89 f0                	mov    %esi,%eax
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 75 08             	mov    0x8(%ebp),%esi
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b2d:	89 f0                	mov    %esi,%eax
  800b2f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b33:	85 c9                	test   %ecx,%ecx
  800b35:	75 0b                	jne    800b42 <strlcpy+0x23>
  800b37:	eb 1d                	jmp    800b56 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b39:	83 c0 01             	add    $0x1,%eax
  800b3c:	83 c2 01             	add    $0x1,%edx
  800b3f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b42:	39 d8                	cmp    %ebx,%eax
  800b44:	74 0b                	je     800b51 <strlcpy+0x32>
  800b46:	0f b6 0a             	movzbl (%edx),%ecx
  800b49:	84 c9                	test   %cl,%cl
  800b4b:	75 ec                	jne    800b39 <strlcpy+0x1a>
  800b4d:	89 c2                	mov    %eax,%edx
  800b4f:	eb 02                	jmp    800b53 <strlcpy+0x34>
  800b51:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800b53:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b56:	29 f0                	sub    %esi,%eax
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b62:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b65:	eb 06                	jmp    800b6d <strcmp+0x11>
		p++, q++;
  800b67:	83 c1 01             	add    $0x1,%ecx
  800b6a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b6d:	0f b6 01             	movzbl (%ecx),%eax
  800b70:	84 c0                	test   %al,%al
  800b72:	74 04                	je     800b78 <strcmp+0x1c>
  800b74:	3a 02                	cmp    (%edx),%al
  800b76:	74 ef                	je     800b67 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b78:	0f b6 c0             	movzbl %al,%eax
  800b7b:	0f b6 12             	movzbl (%edx),%edx
  800b7e:	29 d0                	sub    %edx,%eax
}
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8c:	89 c3                	mov    %eax,%ebx
  800b8e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b91:	eb 06                	jmp    800b99 <strncmp+0x17>
		n--, p++, q++;
  800b93:	83 c0 01             	add    $0x1,%eax
  800b96:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b99:	39 d8                	cmp    %ebx,%eax
  800b9b:	74 15                	je     800bb2 <strncmp+0x30>
  800b9d:	0f b6 08             	movzbl (%eax),%ecx
  800ba0:	84 c9                	test   %cl,%cl
  800ba2:	74 04                	je     800ba8 <strncmp+0x26>
  800ba4:	3a 0a                	cmp    (%edx),%cl
  800ba6:	74 eb                	je     800b93 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba8:	0f b6 00             	movzbl (%eax),%eax
  800bab:	0f b6 12             	movzbl (%edx),%edx
  800bae:	29 d0                	sub    %edx,%eax
  800bb0:	eb 05                	jmp    800bb7 <strncmp+0x35>
		return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc4:	eb 07                	jmp    800bcd <strchr+0x13>
		if (*s == c)
  800bc6:	38 ca                	cmp    %cl,%dl
  800bc8:	74 0f                	je     800bd9 <strchr+0x1f>
	for (; *s; s++)
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	0f b6 10             	movzbl (%eax),%edx
  800bd0:	84 d2                	test   %dl,%dl
  800bd2:	75 f2                	jne    800bc6 <strchr+0xc>
			return (char *) s;
	return 0;
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be5:	eb 07                	jmp    800bee <strfind+0x13>
		if (*s == c)
  800be7:	38 ca                	cmp    %cl,%dl
  800be9:	74 0a                	je     800bf5 <strfind+0x1a>
	for (; *s; s++)
  800beb:	83 c0 01             	add    $0x1,%eax
  800bee:	0f b6 10             	movzbl (%eax),%edx
  800bf1:	84 d2                	test   %dl,%dl
  800bf3:	75 f2                	jne    800be7 <strfind+0xc>
			break;
	return (char *) s;
}
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c03:	85 c9                	test   %ecx,%ecx
  800c05:	74 36                	je     800c3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0d:	75 28                	jne    800c37 <memset+0x40>
  800c0f:	f6 c1 03             	test   $0x3,%cl
  800c12:	75 23                	jne    800c37 <memset+0x40>
		c &= 0xFF;
  800c14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c18:	89 d3                	mov    %edx,%ebx
  800c1a:	c1 e3 08             	shl    $0x8,%ebx
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	c1 e6 18             	shl    $0x18,%esi
  800c22:	89 d0                	mov    %edx,%eax
  800c24:	c1 e0 10             	shl    $0x10,%eax
  800c27:	09 f0                	or     %esi,%eax
  800c29:	09 c2                	or     %eax,%edx
  800c2b:	89 d0                	mov    %edx,%eax
  800c2d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c2f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c32:	fc                   	cld    
  800c33:	f3 ab                	rep stos %eax,%es:(%edi)
  800c35:	eb 06                	jmp    800c3d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3a:	fc                   	cld    
  800c3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c3d:	89 f8                	mov    %edi,%eax
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c52:	39 c6                	cmp    %eax,%esi
  800c54:	73 35                	jae    800c8b <memmove+0x47>
  800c56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c59:	39 d0                	cmp    %edx,%eax
  800c5b:	73 2e                	jae    800c8b <memmove+0x47>
		s += n;
		d += n;
  800c5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c6a:	75 13                	jne    800c7f <memmove+0x3b>
  800c6c:	f6 c1 03             	test   $0x3,%cl
  800c6f:	75 0e                	jne    800c7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c71:	83 ef 04             	sub    $0x4,%edi
  800c74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c77:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c7a:	fd                   	std    
  800c7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7d:	eb 09                	jmp    800c88 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c7f:	83 ef 01             	sub    $0x1,%edi
  800c82:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c85:	fd                   	std    
  800c86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c88:	fc                   	cld    
  800c89:	eb 1d                	jmp    800ca8 <memmove+0x64>
  800c8b:	89 f2                	mov    %esi,%edx
  800c8d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8f:	f6 c2 03             	test   $0x3,%dl
  800c92:	75 0f                	jne    800ca3 <memmove+0x5f>
  800c94:	f6 c1 03             	test   $0x3,%cl
  800c97:	75 0a                	jne    800ca3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c99:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	fc                   	cld    
  800c9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca1:	eb 05                	jmp    800ca8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ca3:	89 c7                	mov    %eax,%edi
  800ca5:	fc                   	cld    
  800ca6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	89 04 24             	mov    %eax,(%esp)
  800cc6:	e8 79 ff ff ff       	call   800c44 <memmove>
}
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdd:	eb 1a                	jmp    800cf9 <memcmp+0x2c>
		if (*s1 != *s2)
  800cdf:	0f b6 02             	movzbl (%edx),%eax
  800ce2:	0f b6 19             	movzbl (%ecx),%ebx
  800ce5:	38 d8                	cmp    %bl,%al
  800ce7:	74 0a                	je     800cf3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ce9:	0f b6 c0             	movzbl %al,%eax
  800cec:	0f b6 db             	movzbl %bl,%ebx
  800cef:	29 d8                	sub    %ebx,%eax
  800cf1:	eb 0f                	jmp    800d02 <memcmp+0x35>
		s1++, s2++;
  800cf3:	83 c2 01             	add    $0x1,%edx
  800cf6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800cf9:	39 f2                	cmp    %esi,%edx
  800cfb:	75 e2                	jne    800cdf <memcmp+0x12>
	}

	return 0;
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d0f:	89 c2                	mov    %eax,%edx
  800d11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d14:	eb 07                	jmp    800d1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d16:	38 08                	cmp    %cl,(%eax)
  800d18:	74 07                	je     800d21 <memfind+0x1b>
	for (; s < ends; s++)
  800d1a:	83 c0 01             	add    $0x1,%eax
  800d1d:	39 d0                	cmp    %edx,%eax
  800d1f:	72 f5                	jb     800d16 <memfind+0x10>
			break;
	return (void *) s;
}
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2f:	eb 03                	jmp    800d34 <strtol+0x11>
		s++;
  800d31:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d34:	0f b6 0a             	movzbl (%edx),%ecx
  800d37:	80 f9 09             	cmp    $0x9,%cl
  800d3a:	74 f5                	je     800d31 <strtol+0xe>
  800d3c:	80 f9 20             	cmp    $0x20,%cl
  800d3f:	74 f0                	je     800d31 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d41:	80 f9 2b             	cmp    $0x2b,%cl
  800d44:	75 0a                	jne    800d50 <strtol+0x2d>
		s++;
  800d46:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d49:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4e:	eb 11                	jmp    800d61 <strtol+0x3e>
  800d50:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800d55:	80 f9 2d             	cmp    $0x2d,%cl
  800d58:	75 07                	jne    800d61 <strtol+0x3e>
		s++, neg = 1;
  800d5a:	8d 52 01             	lea    0x1(%edx),%edx
  800d5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d66:	75 15                	jne    800d7d <strtol+0x5a>
  800d68:	80 3a 30             	cmpb   $0x30,(%edx)
  800d6b:	75 10                	jne    800d7d <strtol+0x5a>
  800d6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d71:	75 0a                	jne    800d7d <strtol+0x5a>
		s += 2, base = 16;
  800d73:	83 c2 02             	add    $0x2,%edx
  800d76:	b8 10 00 00 00       	mov    $0x10,%eax
  800d7b:	eb 10                	jmp    800d8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	75 0c                	jne    800d8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d81:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800d83:	80 3a 30             	cmpb   $0x30,(%edx)
  800d86:	75 05                	jne    800d8d <strtol+0x6a>
		s++, base = 8;
  800d88:	83 c2 01             	add    $0x1,%edx
  800d8b:	b0 08                	mov    $0x8,%al
		base = 10;
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d95:	0f b6 0a             	movzbl (%edx),%ecx
  800d98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d9b:	89 f0                	mov    %esi,%eax
  800d9d:	3c 09                	cmp    $0x9,%al
  800d9f:	77 08                	ja     800da9 <strtol+0x86>
			dig = *s - '0';
  800da1:	0f be c9             	movsbl %cl,%ecx
  800da4:	83 e9 30             	sub    $0x30,%ecx
  800da7:	eb 20                	jmp    800dc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800da9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dac:	89 f0                	mov    %esi,%eax
  800dae:	3c 19                	cmp    $0x19,%al
  800db0:	77 08                	ja     800dba <strtol+0x97>
			dig = *s - 'a' + 10;
  800db2:	0f be c9             	movsbl %cl,%ecx
  800db5:	83 e9 57             	sub    $0x57,%ecx
  800db8:	eb 0f                	jmp    800dc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800dba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	3c 19                	cmp    $0x19,%al
  800dc1:	77 16                	ja     800dd9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800dc3:	0f be c9             	movsbl %cl,%ecx
  800dc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dc9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dcc:	7d 0f                	jge    800ddd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800dce:	83 c2 01             	add    $0x1,%edx
  800dd1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800dd5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800dd7:	eb bc                	jmp    800d95 <strtol+0x72>
  800dd9:	89 d8                	mov    %ebx,%eax
  800ddb:	eb 02                	jmp    800ddf <strtol+0xbc>
  800ddd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ddf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de3:	74 05                	je     800dea <strtol+0xc7>
		*endptr = (char *) s;
  800de5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800dea:	f7 d8                	neg    %eax
  800dec:	85 ff                	test   %edi,%edi
  800dee:	0f 44 c3             	cmove  %ebx,%eax
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	89 c7                	mov    %eax,%edi
  800e0b:	89 c6                	mov    %eax,%esi
  800e0d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e24:	89 d1                	mov    %edx,%ecx
  800e26:	89 d3                	mov    %edx,%ebx
  800e28:	89 d7                	mov    %edx,%edi
  800e2a:	89 d6                	mov    %edx,%esi
  800e2c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e41:	b8 03 00 00 00       	mov    $0x3,%eax
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 cb                	mov    %ecx,%ebx
  800e4b:	89 cf                	mov    %ecx,%edi
  800e4d:	89 ce                	mov    %ecx,%esi
  800e4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 28                	jle    800e7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e60:	00 
  800e61:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e68:	00 
  800e69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e78:	e8 0f f5 ff ff       	call   80038c <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e7d:	83 c4 2c             	add    $0x2c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	b8 02 00 00 00       	mov    $0x2,%eax
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	89 d3                	mov    %edx,%ebx
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_yield>:

void
sys_yield(void)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eb4:	89 d1                	mov    %edx,%ecx
  800eb6:	89 d3                	mov    %edx,%ebx
  800eb8:	89 d7                	mov    %edx,%edi
  800eba:	89 d6                	mov    %edx,%esi
  800ebc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ecc:	be 00 00 00 00       	mov    $0x0,%esi
  800ed1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edf:	89 f7                	mov    %esi,%edi
  800ee1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 28                	jle    800f0f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eeb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800f0a:	e8 7d f4 ff ff       	call   80038c <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f0f:	83 c4 2c             	add    $0x2c,%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f20:	b8 05 00 00 00       	mov    $0x5,%eax
  800f25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f28:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f31:	8b 75 18             	mov    0x18(%ebp),%esi
  800f34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f36:	85 c0                	test   %eax,%eax
  800f38:	7e 28                	jle    800f62 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f45:	00 
  800f46:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f55:	00 
  800f56:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800f5d:	e8 2a f4 ff ff       	call   80038c <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f62:	83 c4 2c             	add    $0x2c,%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f78:	b8 06 00 00 00       	mov    $0x6,%eax
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 df                	mov    %ebx,%edi
  800f85:	89 de                	mov    %ebx,%esi
  800f87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 28                	jle    800fb5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f98:	00 
  800f99:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800fb0:	e8 d7 f3 ff ff       	call   80038c <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fb5:	83 c4 2c             	add    $0x2c,%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 df                	mov    %ebx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 28                	jle    801008 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801003:	e8 84 f3 ff ff       	call   80038c <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801008:	83 c4 2c             	add    $0x2c,%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101e:	b8 09 00 00 00       	mov    $0x9,%eax
  801023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801026:	8b 55 08             	mov    0x8(%ebp),%edx
  801029:	89 df                	mov    %ebx,%edi
  80102b:	89 de                	mov    %ebx,%esi
  80102d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	7e 28                	jle    80105b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801033:	89 44 24 10          	mov    %eax,0x10(%esp)
  801037:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80103e:	00 
  80103f:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801046:	00 
  801047:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80104e:	00 
  80104f:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801056:	e8 31 f3 ff ff       	call   80038c <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80105b:	83 c4 2c             	add    $0x2c,%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	57                   	push   %edi
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80106c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801071:	b8 0a 00 00 00       	mov    $0xa,%eax
  801076:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801079:	8b 55 08             	mov    0x8(%ebp),%edx
  80107c:	89 df                	mov    %ebx,%edi
  80107e:	89 de                	mov    %ebx,%esi
  801080:	cd 30                	int    $0x30
	if(check && ret > 0)
  801082:	85 c0                	test   %eax,%eax
  801084:	7e 28                	jle    8010ae <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801091:	00 
  801092:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801099:	00 
  80109a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a1:	00 
  8010a2:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8010a9:	e8 de f2 ff ff       	call   80038c <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ae:	83 c4 2c             	add    $0x2c,%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	57                   	push   %edi
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010bc:	be 00 00 00 00       	mov    $0x0,%esi
  8010c1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010cf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8010e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ef:	89 cb                	mov    %ecx,%ebx
  8010f1:	89 cf                	mov    %ecx,%edi
  8010f3:	89 ce                	mov    %ecx,%esi
  8010f5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	7e 28                	jle    801123 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ff:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801106:	00 
  801107:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  80110e:	00 
  80110f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801116:	00 
  801117:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  80111e:	e8 69 f2 ff ff       	call   80038c <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801123:	83 c4 2c             	add    $0x2c,%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	53                   	push   %ebx
  80112f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801132:	8b 55 0c             	mov    0xc(%ebp),%edx
  801135:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801138:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  80113a:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	83 39 01             	cmpl   $0x1,(%ecx)
  801145:	7e 0f                	jle    801156 <argstart+0x2b>
  801147:	85 d2                	test   %edx,%edx
  801149:	ba 00 00 00 00       	mov    $0x0,%edx
  80114e:	bb a8 25 80 00       	mov    $0x8025a8,%ebx
  801153:	0f 44 da             	cmove  %edx,%ebx
  801156:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  801159:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801160:	5b                   	pop    %ebx
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <argnext>:

int
argnext(struct Argstate *args)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	53                   	push   %ebx
  801167:	83 ec 14             	sub    $0x14,%esp
  80116a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  80116d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801174:	8b 43 08             	mov    0x8(%ebx),%eax
  801177:	85 c0                	test   %eax,%eax
  801179:	74 71                	je     8011ec <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  80117b:	80 38 00             	cmpb   $0x0,(%eax)
  80117e:	75 50                	jne    8011d0 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801180:	8b 0b                	mov    (%ebx),%ecx
  801182:	83 39 01             	cmpl   $0x1,(%ecx)
  801185:	74 57                	je     8011de <argnext+0x7b>
		    || args->argv[1][0] != '-'
  801187:	8b 53 04             	mov    0x4(%ebx),%edx
  80118a:	8b 42 04             	mov    0x4(%edx),%eax
  80118d:	80 38 2d             	cmpb   $0x2d,(%eax)
  801190:	75 4c                	jne    8011de <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  801192:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801196:	74 46                	je     8011de <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801198:	83 c0 01             	add    $0x1,%eax
  80119b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80119e:	8b 01                	mov    (%ecx),%eax
  8011a0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8011a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ab:	8d 42 08             	lea    0x8(%edx),%eax
  8011ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b2:	83 c2 04             	add    $0x4,%edx
  8011b5:	89 14 24             	mov    %edx,(%esp)
  8011b8:	e8 87 fa ff ff       	call   800c44 <memmove>
		(*args->argc)--;
  8011bd:	8b 03                	mov    (%ebx),%eax
  8011bf:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8011c2:	8b 43 08             	mov    0x8(%ebx),%eax
  8011c5:	80 38 2d             	cmpb   $0x2d,(%eax)
  8011c8:	75 06                	jne    8011d0 <argnext+0x6d>
  8011ca:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8011ce:	74 0e                	je     8011de <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8011d0:	8b 53 08             	mov    0x8(%ebx),%edx
  8011d3:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8011d6:	83 c2 01             	add    $0x1,%edx
  8011d9:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8011dc:	eb 13                	jmp    8011f1 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  8011de:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8011e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011ea:	eb 05                	jmp    8011f1 <argnext+0x8e>
		return -1;
  8011ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  8011f1:	83 c4 14             	add    $0x14,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	53                   	push   %ebx
  8011fb:	83 ec 14             	sub    $0x14,%esp
  8011fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801201:	8b 43 08             	mov    0x8(%ebx),%eax
  801204:	85 c0                	test   %eax,%eax
  801206:	74 5a                	je     801262 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  801208:	80 38 00             	cmpb   $0x0,(%eax)
  80120b:	74 0c                	je     801219 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80120d:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801210:	c7 43 08 a8 25 80 00 	movl   $0x8025a8,0x8(%ebx)
  801217:	eb 44                	jmp    80125d <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  801219:	8b 03                	mov    (%ebx),%eax
  80121b:	83 38 01             	cmpl   $0x1,(%eax)
  80121e:	7e 2f                	jle    80124f <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  801220:	8b 53 04             	mov    0x4(%ebx),%edx
  801223:	8b 4a 04             	mov    0x4(%edx),%ecx
  801226:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801229:	8b 00                	mov    (%eax),%eax
  80122b:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801232:	89 44 24 08          	mov    %eax,0x8(%esp)
  801236:	8d 42 08             	lea    0x8(%edx),%eax
  801239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123d:	83 c2 04             	add    $0x4,%edx
  801240:	89 14 24             	mov    %edx,(%esp)
  801243:	e8 fc f9 ff ff       	call   800c44 <memmove>
		(*args->argc)--;
  801248:	8b 03                	mov    (%ebx),%eax
  80124a:	83 28 01             	subl   $0x1,(%eax)
  80124d:	eb 0e                	jmp    80125d <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  80124f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801256:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80125d:	8b 43 0c             	mov    0xc(%ebx),%eax
  801260:	eb 05                	jmp    801267 <argnextvalue+0x70>
		return 0;
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801267:	83 c4 14             	add    $0x14,%esp
  80126a:	5b                   	pop    %ebx
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <argvalue>:
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 18             	sub    $0x18,%esp
  801273:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801276:	8b 51 0c             	mov    0xc(%ecx),%edx
  801279:	89 d0                	mov    %edx,%eax
  80127b:	85 d2                	test   %edx,%edx
  80127d:	75 08                	jne    801287 <argvalue+0x1a>
  80127f:	89 0c 24             	mov    %ecx,(%esp)
  801282:	e8 70 ff ff ff       	call   8011f7 <argnextvalue>
}
  801287:	c9                   	leave  
  801288:	c3                   	ret    
  801289:	66 90                	xchg   %ax,%ax
  80128b:	66 90                	xchg   %ax,%ax
  80128d:	66 90                	xchg   %ax,%ax
  80128f:	90                   	nop

00801290 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
  801296:	05 00 00 00 30       	add    $0x30000000,%eax
  80129b:	c1 e8 0c             	shr    $0xc,%eax
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	c1 ea 16             	shr    $0x16,%edx
  8012c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ce:	f6 c2 01             	test   $0x1,%dl
  8012d1:	74 11                	je     8012e4 <fd_alloc+0x2d>
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	c1 ea 0c             	shr    $0xc,%edx
  8012d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012df:	f6 c2 01             	test   $0x1,%dl
  8012e2:	75 09                	jne    8012ed <fd_alloc+0x36>
			*fd_store = fd;
  8012e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012eb:	eb 17                	jmp    801304 <fd_alloc+0x4d>
  8012ed:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012f7:	75 c9                	jne    8012c2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  8012f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80130c:	83 f8 1f             	cmp    $0x1f,%eax
  80130f:	77 36                	ja     801347 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801311:	c1 e0 0c             	shl    $0xc,%eax
  801314:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801319:	89 c2                	mov    %eax,%edx
  80131b:	c1 ea 16             	shr    $0x16,%edx
  80131e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801325:	f6 c2 01             	test   $0x1,%dl
  801328:	74 24                	je     80134e <fd_lookup+0x48>
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	c1 ea 0c             	shr    $0xc,%edx
  80132f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801336:	f6 c2 01             	test   $0x1,%dl
  801339:	74 1a                	je     801355 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80133b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133e:	89 02                	mov    %eax,(%edx)
	return 0;
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	eb 13                	jmp    80135a <fd_lookup+0x54>
		return -E_INVAL;
  801347:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134c:	eb 0c                	jmp    80135a <fd_lookup+0x54>
		return -E_INVAL;
  80134e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801353:	eb 05                	jmp    80135a <fd_lookup+0x54>
  801355:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 18             	sub    $0x18,%esp
  801362:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801365:	ba ac 29 80 00       	mov    $0x8029ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80136a:	eb 13                	jmp    80137f <dev_lookup+0x23>
  80136c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80136f:	39 08                	cmp    %ecx,(%eax)
  801371:	75 0c                	jne    80137f <dev_lookup+0x23>
			*dev = devtab[i];
  801373:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801376:	89 01                	mov    %eax,(%ecx)
			return 0;
  801378:	b8 00 00 00 00       	mov    $0x0,%eax
  80137d:	eb 30                	jmp    8013af <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80137f:	8b 02                	mov    (%edx),%eax
  801381:	85 c0                	test   %eax,%eax
  801383:	75 e7                	jne    80136c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801385:	a1 20 44 80 00       	mov    0x804420,%eax
  80138a:	8b 40 48             	mov    0x48(%eax),%eax
  80138d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801391:	89 44 24 04          	mov    %eax,0x4(%esp)
  801395:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
  80139c:	e8 e4 f0 ff ff       	call   800485 <cprintf>
	*dev = 0;
  8013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <fd_close>:
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 20             	sub    $0x20,%esp
  8013b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013cc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013cf:	89 04 24             	mov    %eax,(%esp)
  8013d2:	e8 2f ff ff ff       	call   801306 <fd_lookup>
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 05                	js     8013e0 <fd_close+0x2f>
	    || fd != fd2)
  8013db:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013de:	74 0c                	je     8013ec <fd_close+0x3b>
		return (must_exist ? r : 0);
  8013e0:	84 db                	test   %bl,%bl
  8013e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e7:	0f 44 c2             	cmove  %edx,%eax
  8013ea:	eb 3f                	jmp    80142b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f3:	8b 06                	mov    (%esi),%eax
  8013f5:	89 04 24             	mov    %eax,(%esp)
  8013f8:	e8 5f ff ff ff       	call   80135c <dev_lookup>
  8013fd:	89 c3                	mov    %eax,%ebx
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 16                	js     801419 <fd_close+0x68>
		if (dev->dev_close)
  801403:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801406:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801409:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80140e:	85 c0                	test   %eax,%eax
  801410:	74 07                	je     801419 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801412:	89 34 24             	mov    %esi,(%esp)
  801415:	ff d0                	call   *%eax
  801417:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801419:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801424:	e8 41 fb ff ff       	call   800f6a <sys_page_unmap>
	return r;
  801429:	89 d8                	mov    %ebx,%eax
}
  80142b:	83 c4 20             	add    $0x20,%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5e                   	pop    %esi
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <close>:

int
close(int fdnum)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801438:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
  801442:	89 04 24             	mov    %eax,(%esp)
  801445:	e8 bc fe ff ff       	call   801306 <fd_lookup>
  80144a:	89 c2                	mov    %eax,%edx
  80144c:	85 d2                	test   %edx,%edx
  80144e:	78 13                	js     801463 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801450:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801457:	00 
  801458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145b:	89 04 24             	mov    %eax,(%esp)
  80145e:	e8 4e ff ff ff       	call   8013b1 <fd_close>
}
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <close_all>:

void
close_all(void)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	53                   	push   %ebx
  801469:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80146c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801471:	89 1c 24             	mov    %ebx,(%esp)
  801474:	e8 b9 ff ff ff       	call   801432 <close>
	for (i = 0; i < MAXFD; i++)
  801479:	83 c3 01             	add    $0x1,%ebx
  80147c:	83 fb 20             	cmp    $0x20,%ebx
  80147f:	75 f0                	jne    801471 <close_all+0xc>
}
  801481:	83 c4 14             	add    $0x14,%esp
  801484:	5b                   	pop    %ebx
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	57                   	push   %edi
  80148b:	56                   	push   %esi
  80148c:	53                   	push   %ebx
  80148d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801490:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801493:	89 44 24 04          	mov    %eax,0x4(%esp)
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
  80149a:	89 04 24             	mov    %eax,(%esp)
  80149d:	e8 64 fe ff ff       	call   801306 <fd_lookup>
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	85 d2                	test   %edx,%edx
  8014a6:	0f 88 e1 00 00 00    	js     80158d <dup+0x106>
		return r;
	close(newfdnum);
  8014ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014af:	89 04 24             	mov    %eax,(%esp)
  8014b2:	e8 7b ff ff ff       	call   801432 <close>

	newfd = INDEX2FD(newfdnum);
  8014b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ba:	c1 e3 0c             	shl    $0xc,%ebx
  8014bd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014c6:	89 04 24             	mov    %eax,(%esp)
  8014c9:	e8 d2 fd ff ff       	call   8012a0 <fd2data>
  8014ce:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8014d0:	89 1c 24             	mov    %ebx,(%esp)
  8014d3:	e8 c8 fd ff ff       	call   8012a0 <fd2data>
  8014d8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014da:	89 f0                	mov    %esi,%eax
  8014dc:	c1 e8 16             	shr    $0x16,%eax
  8014df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e6:	a8 01                	test   $0x1,%al
  8014e8:	74 43                	je     80152d <dup+0xa6>
  8014ea:	89 f0                	mov    %esi,%eax
  8014ec:	c1 e8 0c             	shr    $0xc,%eax
  8014ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014f6:	f6 c2 01             	test   $0x1,%dl
  8014f9:	74 32                	je     80152d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801502:	25 07 0e 00 00       	and    $0xe07,%eax
  801507:	89 44 24 10          	mov    %eax,0x10(%esp)
  80150b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80150f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801516:	00 
  801517:	89 74 24 04          	mov    %esi,0x4(%esp)
  80151b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801522:	e8 f0 f9 ff ff       	call   800f17 <sys_page_map>
  801527:	89 c6                	mov    %eax,%esi
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 3e                	js     80156b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80152d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801530:	89 c2                	mov    %eax,%edx
  801532:	c1 ea 0c             	shr    $0xc,%edx
  801535:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80153c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801542:	89 54 24 10          	mov    %edx,0x10(%esp)
  801546:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80154a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801551:	00 
  801552:	89 44 24 04          	mov    %eax,0x4(%esp)
  801556:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80155d:	e8 b5 f9 ff ff       	call   800f17 <sys_page_map>
  801562:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801564:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801567:	85 f6                	test   %esi,%esi
  801569:	79 22                	jns    80158d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80156b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80156f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801576:	e8 ef f9 ff ff       	call   800f6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80157b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80157f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801586:	e8 df f9 ff ff       	call   800f6a <sys_page_unmap>
	return r;
  80158b:	89 f0                	mov    %esi,%eax
}
  80158d:	83 c4 3c             	add    $0x3c,%esp
  801590:	5b                   	pop    %ebx
  801591:	5e                   	pop    %esi
  801592:	5f                   	pop    %edi
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    

00801595 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	53                   	push   %ebx
  801599:	83 ec 24             	sub    $0x24,%esp
  80159c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a6:	89 1c 24             	mov    %ebx,(%esp)
  8015a9:	e8 58 fd ff ff       	call   801306 <fd_lookup>
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	85 d2                	test   %edx,%edx
  8015b2:	78 6d                	js     801621 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	8b 00                	mov    (%eax),%eax
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	e8 94 fd ff ff       	call   80135c <dev_lookup>
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 55                	js     801621 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	8b 50 08             	mov    0x8(%eax),%edx
  8015d2:	83 e2 03             	and    $0x3,%edx
  8015d5:	83 fa 01             	cmp    $0x1,%edx
  8015d8:	75 23                	jne    8015fd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015da:	a1 20 44 80 00       	mov    0x804420,%eax
  8015df:	8b 40 48             	mov    0x48(%eax),%eax
  8015e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ea:	c7 04 24 70 29 80 00 	movl   $0x802970,(%esp)
  8015f1:	e8 8f ee ff ff       	call   800485 <cprintf>
		return -E_INVAL;
  8015f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fb:	eb 24                	jmp    801621 <read+0x8c>
	}
	if (!dev->dev_read)
  8015fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801600:	8b 52 08             	mov    0x8(%edx),%edx
  801603:	85 d2                	test   %edx,%edx
  801605:	74 15                	je     80161c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801607:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80160a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80160e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801611:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	ff d2                	call   *%edx
  80161a:	eb 05                	jmp    801621 <read+0x8c>
		return -E_NOT_SUPP;
  80161c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801621:	83 c4 24             	add    $0x24,%esp
  801624:	5b                   	pop    %ebx
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	57                   	push   %edi
  80162b:	56                   	push   %esi
  80162c:	53                   	push   %ebx
  80162d:	83 ec 1c             	sub    $0x1c,%esp
  801630:	8b 7d 08             	mov    0x8(%ebp),%edi
  801633:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801636:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163b:	eb 23                	jmp    801660 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163d:	89 f0                	mov    %esi,%eax
  80163f:	29 d8                	sub    %ebx,%eax
  801641:	89 44 24 08          	mov    %eax,0x8(%esp)
  801645:	89 d8                	mov    %ebx,%eax
  801647:	03 45 0c             	add    0xc(%ebp),%eax
  80164a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164e:	89 3c 24             	mov    %edi,(%esp)
  801651:	e8 3f ff ff ff       	call   801595 <read>
		if (m < 0)
  801656:	85 c0                	test   %eax,%eax
  801658:	78 10                	js     80166a <readn+0x43>
			return m;
		if (m == 0)
  80165a:	85 c0                	test   %eax,%eax
  80165c:	74 0a                	je     801668 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80165e:	01 c3                	add    %eax,%ebx
  801660:	39 f3                	cmp    %esi,%ebx
  801662:	72 d9                	jb     80163d <readn+0x16>
  801664:	89 d8                	mov    %ebx,%eax
  801666:	eb 02                	jmp    80166a <readn+0x43>
  801668:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80166a:	83 c4 1c             	add    $0x1c,%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5f                   	pop    %edi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	53                   	push   %ebx
  801676:	83 ec 24             	sub    $0x24,%esp
  801679:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801683:	89 1c 24             	mov    %ebx,(%esp)
  801686:	e8 7b fc ff ff       	call   801306 <fd_lookup>
  80168b:	89 c2                	mov    %eax,%edx
  80168d:	85 d2                	test   %edx,%edx
  80168f:	78 68                	js     8016f9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801691:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801694:	89 44 24 04          	mov    %eax,0x4(%esp)
  801698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169b:	8b 00                	mov    (%eax),%eax
  80169d:	89 04 24             	mov    %eax,(%esp)
  8016a0:	e8 b7 fc ff ff       	call   80135c <dev_lookup>
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 50                	js     8016f9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016b0:	75 23                	jne    8016d5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b2:	a1 20 44 80 00       	mov    0x804420,%eax
  8016b7:	8b 40 48             	mov    0x48(%eax),%eax
  8016ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c2:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  8016c9:	e8 b7 ed ff ff       	call   800485 <cprintf>
		return -E_INVAL;
  8016ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d3:	eb 24                	jmp    8016f9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8016db:	85 d2                	test   %edx,%edx
  8016dd:	74 15                	je     8016f4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016ed:	89 04 24             	mov    %eax,(%esp)
  8016f0:	ff d2                	call   *%edx
  8016f2:	eb 05                	jmp    8016f9 <write+0x87>
		return -E_NOT_SUPP;
  8016f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016f9:	83 c4 24             	add    $0x24,%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801705:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170c:	8b 45 08             	mov    0x8(%ebp),%eax
  80170f:	89 04 24             	mov    %eax,(%esp)
  801712:	e8 ef fb ff ff       	call   801306 <fd_lookup>
  801717:	85 c0                	test   %eax,%eax
  801719:	78 0e                	js     801729 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80171b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80171e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801721:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801724:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	53                   	push   %ebx
  80172f:	83 ec 24             	sub    $0x24,%esp
  801732:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801735:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173c:	89 1c 24             	mov    %ebx,(%esp)
  80173f:	e8 c2 fb ff ff       	call   801306 <fd_lookup>
  801744:	89 c2                	mov    %eax,%edx
  801746:	85 d2                	test   %edx,%edx
  801748:	78 61                	js     8017ab <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801754:	8b 00                	mov    (%eax),%eax
  801756:	89 04 24             	mov    %eax,(%esp)
  801759:	e8 fe fb ff ff       	call   80135c <dev_lookup>
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 49                	js     8017ab <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801762:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801765:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801769:	75 23                	jne    80178e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80176b:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801770:	8b 40 48             	mov    0x48(%eax),%eax
  801773:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177b:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  801782:	e8 fe ec ff ff       	call   800485 <cprintf>
		return -E_INVAL;
  801787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80178c:	eb 1d                	jmp    8017ab <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80178e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801791:	8b 52 18             	mov    0x18(%edx),%edx
  801794:	85 d2                	test   %edx,%edx
  801796:	74 0e                	je     8017a6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80179f:	89 04 24             	mov    %eax,(%esp)
  8017a2:	ff d2                	call   *%edx
  8017a4:	eb 05                	jmp    8017ab <ftruncate+0x80>
		return -E_NOT_SUPP;
  8017a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017ab:	83 c4 24             	add    $0x24,%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 24             	sub    $0x24,%esp
  8017b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	89 04 24             	mov    %eax,(%esp)
  8017c8:	e8 39 fb ff ff       	call   801306 <fd_lookup>
  8017cd:	89 c2                	mov    %eax,%edx
  8017cf:	85 d2                	test   %edx,%edx
  8017d1:	78 52                	js     801825 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017dd:	8b 00                	mov    (%eax),%eax
  8017df:	89 04 24             	mov    %eax,(%esp)
  8017e2:	e8 75 fb ff ff       	call   80135c <dev_lookup>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 3a                	js     801825 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8017eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ee:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017f2:	74 2c                	je     801820 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017f4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017f7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017fe:	00 00 00 
	stat->st_isdir = 0;
  801801:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801808:	00 00 00 
	stat->st_dev = dev;
  80180b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801811:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801815:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801818:	89 14 24             	mov    %edx,(%esp)
  80181b:	ff 50 14             	call   *0x14(%eax)
  80181e:	eb 05                	jmp    801825 <fstat+0x74>
		return -E_NOT_SUPP;
  801820:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801825:	83 c4 24             	add    $0x24,%esp
  801828:	5b                   	pop    %ebx
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
  801830:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801833:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80183a:	00 
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	e8 fb 01 00 00       	call   801a41 <open>
  801846:	89 c3                	mov    %eax,%ebx
  801848:	85 db                	test   %ebx,%ebx
  80184a:	78 1b                	js     801867 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80184c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801853:	89 1c 24             	mov    %ebx,(%esp)
  801856:	e8 56 ff ff ff       	call   8017b1 <fstat>
  80185b:	89 c6                	mov    %eax,%esi
	close(fd);
  80185d:	89 1c 24             	mov    %ebx,(%esp)
  801860:	e8 cd fb ff ff       	call   801432 <close>
	return r;
  801865:	89 f0                	mov    %esi,%eax
}
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	5b                   	pop    %ebx
  80186b:	5e                   	pop    %esi
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	56                   	push   %esi
  801872:	53                   	push   %ebx
  801873:	83 ec 10             	sub    $0x10,%esp
  801876:	89 c6                	mov    %eax,%esi
  801878:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80187a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801881:	75 11                	jne    801894 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801883:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80188a:	e8 90 09 00 00       	call   80221f <ipc_find_env>
  80188f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801894:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80189b:	00 
  80189c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018a3:	00 
  8018a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ad:	89 04 24             	mov    %eax,(%esp)
  8018b0:	e8 03 09 00 00       	call   8021b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018bc:	00 
  8018bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c8:	e8 83 08 00 00       	call   802150 <ipc_recv>
}
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f7:	e8 72 ff ff ff       	call   80186e <fsipc>
}
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <devfile_flush>:
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	8b 40 0c             	mov    0xc(%eax),%eax
  80190a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
  801914:	b8 06 00 00 00       	mov    $0x6,%eax
  801919:	e8 50 ff ff ff       	call   80186e <fsipc>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <devfile_stat>:
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	83 ec 14             	sub    $0x14,%esp
  801927:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 40 0c             	mov    0xc(%eax),%eax
  801930:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
  80193a:	b8 05 00 00 00       	mov    $0x5,%eax
  80193f:	e8 2a ff ff ff       	call   80186e <fsipc>
  801944:	89 c2                	mov    %eax,%edx
  801946:	85 d2                	test   %edx,%edx
  801948:	78 2b                	js     801975 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80194a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801951:	00 
  801952:	89 1c 24             	mov    %ebx,(%esp)
  801955:	e8 4d f1 ff ff       	call   800aa7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80195a:	a1 80 50 80 00       	mov    0x805080,%eax
  80195f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801965:	a1 84 50 80 00       	mov    0x805084,%eax
  80196a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801975:	83 c4 14             	add    $0x14,%esp
  801978:	5b                   	pop    %ebx
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <devfile_write>:
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801981:	c7 44 24 08 bc 29 80 	movl   $0x8029bc,0x8(%esp)
  801988:	00 
  801989:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801990:	00 
  801991:	c7 04 24 da 29 80 00 	movl   $0x8029da,(%esp)
  801998:	e8 ef e9 ff ff       	call   80038c <_panic>

0080199d <devfile_read>:
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	56                   	push   %esi
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 10             	sub    $0x10,%esp
  8019a5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019b3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019be:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c3:	e8 a6 fe ff ff       	call   80186e <fsipc>
  8019c8:	89 c3                	mov    %eax,%ebx
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 6a                	js     801a38 <devfile_read+0x9b>
	assert(r <= n);
  8019ce:	39 c6                	cmp    %eax,%esi
  8019d0:	73 24                	jae    8019f6 <devfile_read+0x59>
  8019d2:	c7 44 24 0c e5 29 80 	movl   $0x8029e5,0xc(%esp)
  8019d9:	00 
  8019da:	c7 44 24 08 ec 29 80 	movl   $0x8029ec,0x8(%esp)
  8019e1:	00 
  8019e2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019e9:	00 
  8019ea:	c7 04 24 da 29 80 00 	movl   $0x8029da,(%esp)
  8019f1:	e8 96 e9 ff ff       	call   80038c <_panic>
	assert(r <= PGSIZE);
  8019f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019fb:	7e 24                	jle    801a21 <devfile_read+0x84>
  8019fd:	c7 44 24 0c 01 2a 80 	movl   $0x802a01,0xc(%esp)
  801a04:	00 
  801a05:	c7 44 24 08 ec 29 80 	movl   $0x8029ec,0x8(%esp)
  801a0c:	00 
  801a0d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a14:	00 
  801a15:	c7 04 24 da 29 80 00 	movl   $0x8029da,(%esp)
  801a1c:	e8 6b e9 ff ff       	call   80038c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a21:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a25:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a2c:	00 
  801a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a30:	89 04 24             	mov    %eax,(%esp)
  801a33:	e8 0c f2 ff ff       	call   800c44 <memmove>
}
  801a38:	89 d8                	mov    %ebx,%eax
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5e                   	pop    %esi
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <open>:
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	53                   	push   %ebx
  801a45:	83 ec 24             	sub    $0x24,%esp
  801a48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a4b:	89 1c 24             	mov    %ebx,(%esp)
  801a4e:	e8 1d f0 ff ff       	call   800a70 <strlen>
  801a53:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a58:	7f 60                	jg     801aba <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801a5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5d:	89 04 24             	mov    %eax,(%esp)
  801a60:	e8 52 f8 ff ff       	call   8012b7 <fd_alloc>
  801a65:	89 c2                	mov    %eax,%edx
  801a67:	85 d2                	test   %edx,%edx
  801a69:	78 54                	js     801abf <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801a6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a6f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a76:	e8 2c f0 ff ff       	call   800aa7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a83:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a86:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8b:	e8 de fd ff ff       	call   80186e <fsipc>
  801a90:	89 c3                	mov    %eax,%ebx
  801a92:	85 c0                	test   %eax,%eax
  801a94:	79 17                	jns    801aad <open+0x6c>
		fd_close(fd, 0);
  801a96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a9d:	00 
  801a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 08 f9 ff ff       	call   8013b1 <fd_close>
		return r;
  801aa9:	89 d8                	mov    %ebx,%eax
  801aab:	eb 12                	jmp    801abf <open+0x7e>
	return fd2num(fd);
  801aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab0:	89 04 24             	mov    %eax,(%esp)
  801ab3:	e8 d8 f7 ff ff       	call   801290 <fd2num>
  801ab8:	eb 05                	jmp    801abf <open+0x7e>
		return -E_BAD_PATH;
  801aba:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801abf:	83 c4 24             	add    $0x24,%esp
  801ac2:	5b                   	pop    %ebx
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801acb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad5:	e8 94 fd ff ff       	call   80186e <fsipc>
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	53                   	push   %ebx
  801ae0:	83 ec 14             	sub    $0x14,%esp
  801ae3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801ae5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801ae9:	7e 31                	jle    801b1c <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801aeb:	8b 40 04             	mov    0x4(%eax),%eax
  801aee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af2:	8d 43 10             	lea    0x10(%ebx),%eax
  801af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af9:	8b 03                	mov    (%ebx),%eax
  801afb:	89 04 24             	mov    %eax,(%esp)
  801afe:	e8 6f fb ff ff       	call   801672 <write>
		if (result > 0)
  801b03:	85 c0                	test   %eax,%eax
  801b05:	7e 03                	jle    801b0a <writebuf+0x2e>
			b->result += result;
  801b07:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801b0a:	39 43 04             	cmp    %eax,0x4(%ebx)
  801b0d:	74 0d                	je     801b1c <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	ba 00 00 00 00       	mov    $0x0,%edx
  801b16:	0f 4f c2             	cmovg  %edx,%eax
  801b19:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801b1c:	83 c4 14             	add    $0x14,%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <putch>:

static void
putch(int ch, void *thunk)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	53                   	push   %ebx
  801b26:	83 ec 04             	sub    $0x4,%esp
  801b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801b2c:	8b 53 04             	mov    0x4(%ebx),%edx
  801b2f:	8d 42 01             	lea    0x1(%edx),%eax
  801b32:	89 43 04             	mov    %eax,0x4(%ebx)
  801b35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b38:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801b3c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801b41:	75 0e                	jne    801b51 <putch+0x2f>
		writebuf(b);
  801b43:	89 d8                	mov    %ebx,%eax
  801b45:	e8 92 ff ff ff       	call   801adc <writebuf>
		b->idx = 0;
  801b4a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801b51:	83 c4 04             	add    $0x4,%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801b69:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b70:	00 00 00 
	b.result = 0;
  801b73:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b7a:	00 00 00 
	b.error = 1;
  801b7d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b84:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b87:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b91:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b95:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9f:	c7 04 24 22 1b 80 00 	movl   $0x801b22,(%esp)
  801ba6:	e8 63 ea ff ff       	call   80060e <vprintfmt>
	if (b.idx > 0)
  801bab:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801bb2:	7e 0b                	jle    801bbf <vfprintf+0x68>
		writebuf(&b);
  801bb4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801bba:	e8 1d ff ff ff       	call   801adc <writebuf>

	return (b.result ? b.result : b.error);
  801bbf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bd6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801bd9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be4:	8b 45 08             	mov    0x8(%ebp),%eax
  801be7:	89 04 24             	mov    %eax,(%esp)
  801bea:	e8 68 ff ff ff       	call   801b57 <vfprintf>
	va_end(ap);

	return cnt;
}
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <printf>:

int
printf(const char *fmt, ...)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bf7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801bfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c0c:	e8 46 ff ff ff       	call   801b57 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	56                   	push   %esi
  801c17:	53                   	push   %ebx
  801c18:	83 ec 10             	sub    $0x10,%esp
  801c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	89 04 24             	mov    %eax,(%esp)
  801c24:	e8 77 f6 ff ff       	call   8012a0 <fd2data>
  801c29:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c2b:	c7 44 24 04 0d 2a 80 	movl   $0x802a0d,0x4(%esp)
  801c32:	00 
  801c33:	89 1c 24             	mov    %ebx,(%esp)
  801c36:	e8 6c ee ff ff       	call   800aa7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c3b:	8b 46 04             	mov    0x4(%esi),%eax
  801c3e:	2b 06                	sub    (%esi),%eax
  801c40:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c46:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c4d:	00 00 00 
	stat->st_dev = &devpipe;
  801c50:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c57:	30 80 00 
	return 0;
}
  801c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	5b                   	pop    %ebx
  801c63:	5e                   	pop    %esi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 14             	sub    $0x14,%esp
  801c6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7b:	e8 ea f2 ff ff       	call   800f6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c80:	89 1c 24             	mov    %ebx,(%esp)
  801c83:	e8 18 f6 ff ff       	call   8012a0 <fd2data>
  801c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c93:	e8 d2 f2 ff ff       	call   800f6a <sys_page_unmap>
}
  801c98:	83 c4 14             	add    $0x14,%esp
  801c9b:	5b                   	pop    %ebx
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <_pipeisclosed>:
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 2c             	sub    $0x2c,%esp
  801ca7:	89 c6                	mov    %eax,%esi
  801ca9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801cac:	a1 20 44 80 00       	mov    0x804420,%eax
  801cb1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cb4:	89 34 24             	mov    %esi,(%esp)
  801cb7:	e8 9b 05 00 00       	call   802257 <pageref>
  801cbc:	89 c7                	mov    %eax,%edi
  801cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc1:	89 04 24             	mov    %eax,(%esp)
  801cc4:	e8 8e 05 00 00       	call   802257 <pageref>
  801cc9:	39 c7                	cmp    %eax,%edi
  801ccb:	0f 94 c2             	sete   %dl
  801cce:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801cd1:	8b 0d 20 44 80 00    	mov    0x804420,%ecx
  801cd7:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801cda:	39 fb                	cmp    %edi,%ebx
  801cdc:	74 21                	je     801cff <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801cde:	84 d2                	test   %dl,%dl
  801ce0:	74 ca                	je     801cac <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ce2:	8b 51 58             	mov    0x58(%ecx),%edx
  801ce5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ce9:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ced:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf1:	c7 04 24 14 2a 80 00 	movl   $0x802a14,(%esp)
  801cf8:	e8 88 e7 ff ff       	call   800485 <cprintf>
  801cfd:	eb ad                	jmp    801cac <_pipeisclosed+0xe>
}
  801cff:	83 c4 2c             	add    $0x2c,%esp
  801d02:	5b                   	pop    %ebx
  801d03:	5e                   	pop    %esi
  801d04:	5f                   	pop    %edi
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <devpipe_write>:
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	57                   	push   %edi
  801d0b:	56                   	push   %esi
  801d0c:	53                   	push   %ebx
  801d0d:	83 ec 1c             	sub    $0x1c,%esp
  801d10:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d13:	89 34 24             	mov    %esi,(%esp)
  801d16:	e8 85 f5 ff ff       	call   8012a0 <fd2data>
  801d1b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d1d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d22:	eb 45                	jmp    801d69 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801d24:	89 da                	mov    %ebx,%edx
  801d26:	89 f0                	mov    %esi,%eax
  801d28:	e8 71 ff ff ff       	call   801c9e <_pipeisclosed>
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	75 41                	jne    801d72 <devpipe_write+0x6b>
			sys_yield();
  801d31:	e8 6e f1 ff ff       	call   800ea4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d36:	8b 43 04             	mov    0x4(%ebx),%eax
  801d39:	8b 0b                	mov    (%ebx),%ecx
  801d3b:	8d 51 20             	lea    0x20(%ecx),%edx
  801d3e:	39 d0                	cmp    %edx,%eax
  801d40:	73 e2                	jae    801d24 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d45:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d49:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d4c:	99                   	cltd   
  801d4d:	c1 ea 1b             	shr    $0x1b,%edx
  801d50:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d53:	83 e1 1f             	and    $0x1f,%ecx
  801d56:	29 d1                	sub    %edx,%ecx
  801d58:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d5c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d60:	83 c0 01             	add    $0x1,%eax
  801d63:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d66:	83 c7 01             	add    $0x1,%edi
  801d69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d6c:	75 c8                	jne    801d36 <devpipe_write+0x2f>
	return i;
  801d6e:	89 f8                	mov    %edi,%eax
  801d70:	eb 05                	jmp    801d77 <devpipe_write+0x70>
				return 0;
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d77:	83 c4 1c             	add    $0x1c,%esp
  801d7a:	5b                   	pop    %ebx
  801d7b:	5e                   	pop    %esi
  801d7c:	5f                   	pop    %edi
  801d7d:	5d                   	pop    %ebp
  801d7e:	c3                   	ret    

00801d7f <devpipe_read>:
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	57                   	push   %edi
  801d83:	56                   	push   %esi
  801d84:	53                   	push   %ebx
  801d85:	83 ec 1c             	sub    $0x1c,%esp
  801d88:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d8b:	89 3c 24             	mov    %edi,(%esp)
  801d8e:	e8 0d f5 ff ff       	call   8012a0 <fd2data>
  801d93:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d95:	be 00 00 00 00       	mov    $0x0,%esi
  801d9a:	eb 3d                	jmp    801dd9 <devpipe_read+0x5a>
			if (i > 0)
  801d9c:	85 f6                	test   %esi,%esi
  801d9e:	74 04                	je     801da4 <devpipe_read+0x25>
				return i;
  801da0:	89 f0                	mov    %esi,%eax
  801da2:	eb 43                	jmp    801de7 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  801da4:	89 da                	mov    %ebx,%edx
  801da6:	89 f8                	mov    %edi,%eax
  801da8:	e8 f1 fe ff ff       	call   801c9e <_pipeisclosed>
  801dad:	85 c0                	test   %eax,%eax
  801daf:	75 31                	jne    801de2 <devpipe_read+0x63>
			sys_yield();
  801db1:	e8 ee f0 ff ff       	call   800ea4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801db6:	8b 03                	mov    (%ebx),%eax
  801db8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dbb:	74 df                	je     801d9c <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dbd:	99                   	cltd   
  801dbe:	c1 ea 1b             	shr    $0x1b,%edx
  801dc1:	01 d0                	add    %edx,%eax
  801dc3:	83 e0 1f             	and    $0x1f,%eax
  801dc6:	29 d0                	sub    %edx,%eax
  801dc8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dd3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dd6:	83 c6 01             	add    $0x1,%esi
  801dd9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ddc:	75 d8                	jne    801db6 <devpipe_read+0x37>
	return i;
  801dde:	89 f0                	mov    %esi,%eax
  801de0:	eb 05                	jmp    801de7 <devpipe_read+0x68>
				return 0;
  801de2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801de7:	83 c4 1c             	add    $0x1c,%esp
  801dea:	5b                   	pop    %ebx
  801deb:	5e                   	pop    %esi
  801dec:	5f                   	pop    %edi
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    

00801def <pipe>:
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801df7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfa:	89 04 24             	mov    %eax,(%esp)
  801dfd:	e8 b5 f4 ff ff       	call   8012b7 <fd_alloc>
  801e02:	89 c2                	mov    %eax,%edx
  801e04:	85 d2                	test   %edx,%edx
  801e06:	0f 88 4d 01 00 00    	js     801f59 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e13:	00 
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e22:	e8 9c f0 ff ff       	call   800ec3 <sys_page_alloc>
  801e27:	89 c2                	mov    %eax,%edx
  801e29:	85 d2                	test   %edx,%edx
  801e2b:	0f 88 28 01 00 00    	js     801f59 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801e31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e34:	89 04 24             	mov    %eax,(%esp)
  801e37:	e8 7b f4 ff ff       	call   8012b7 <fd_alloc>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	0f 88 fe 00 00 00    	js     801f44 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e4d:	00 
  801e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5c:	e8 62 f0 ff ff       	call   800ec3 <sys_page_alloc>
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	85 c0                	test   %eax,%eax
  801e65:	0f 88 d9 00 00 00    	js     801f44 <pipe+0x155>
	va = fd2data(fd0);
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 2a f4 ff ff       	call   8012a0 <fd2data>
  801e76:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e78:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e7f:	00 
  801e80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8b:	e8 33 f0 ff ff       	call   800ec3 <sys_page_alloc>
  801e90:	89 c3                	mov    %eax,%ebx
  801e92:	85 c0                	test   %eax,%eax
  801e94:	0f 88 97 00 00 00    	js     801f31 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e9d:	89 04 24             	mov    %eax,(%esp)
  801ea0:	e8 fb f3 ff ff       	call   8012a0 <fd2data>
  801ea5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801eac:	00 
  801ead:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eb8:	00 
  801eb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ebd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec4:	e8 4e f0 ff ff       	call   800f17 <sys_page_map>
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	78 52                	js     801f21 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801ecf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801ee4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eed:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ef2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efc:	89 04 24             	mov    %eax,(%esp)
  801eff:	e8 8c f3 ff ff       	call   801290 <fd2num>
  801f04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f07:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0c:	89 04 24             	mov    %eax,(%esp)
  801f0f:	e8 7c f3 ff ff       	call   801290 <fd2num>
  801f14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f17:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1f:	eb 38                	jmp    801f59 <pipe+0x16a>
	sys_page_unmap(0, va);
  801f21:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f2c:	e8 39 f0 ff ff       	call   800f6a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3f:	e8 26 f0 ff ff       	call   800f6a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f52:	e8 13 f0 ff ff       	call   800f6a <sys_page_unmap>
  801f57:	89 d8                	mov    %ebx,%eax
}
  801f59:	83 c4 30             	add    $0x30,%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <pipeisclosed>:
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f70:	89 04 24             	mov    %eax,(%esp)
  801f73:	e8 8e f3 ff ff       	call   801306 <fd_lookup>
  801f78:	89 c2                	mov    %eax,%edx
  801f7a:	85 d2                	test   %edx,%edx
  801f7c:	78 15                	js     801f93 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f81:	89 04 24             	mov    %eax,(%esp)
  801f84:	e8 17 f3 ff ff       	call   8012a0 <fd2data>
	return _pipeisclosed(fd, p);
  801f89:	89 c2                	mov    %eax,%edx
  801f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8e:	e8 0b fd ff ff       	call   801c9e <_pipeisclosed>
}
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    
  801f95:	66 90                	xchg   %ax,%ax
  801f97:	66 90                	xchg   %ax,%ax
  801f99:	66 90                	xchg   %ax,%ax
  801f9b:	66 90                	xchg   %ax,%ax
  801f9d:	66 90                	xchg   %ax,%ax
  801f9f:	90                   	nop

00801fa0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fb0:	c7 44 24 04 2c 2a 80 	movl   $0x802a2c,0x4(%esp)
  801fb7:	00 
  801fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 e4 ea ff ff       	call   800aa7 <strcpy>
	return 0;
}
  801fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc8:	c9                   	leave  
  801fc9:	c3                   	ret    

00801fca <devcons_write>:
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	57                   	push   %edi
  801fce:	56                   	push   %esi
  801fcf:	53                   	push   %ebx
  801fd0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fdb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fe1:	eb 31                	jmp    802014 <devcons_write+0x4a>
		m = n - tot;
  801fe3:	8b 75 10             	mov    0x10(%ebp),%esi
  801fe6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fe8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801feb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ff0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ff3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ff7:	03 45 0c             	add    0xc(%ebp),%eax
  801ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffe:	89 3c 24             	mov    %edi,(%esp)
  802001:	e8 3e ec ff ff       	call   800c44 <memmove>
		sys_cputs(buf, m);
  802006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80200a:	89 3c 24             	mov    %edi,(%esp)
  80200d:	e8 e4 ed ff ff       	call   800df6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802012:	01 f3                	add    %esi,%ebx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802019:	72 c8                	jb     801fe3 <devcons_write+0x19>
}
  80201b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802021:	5b                   	pop    %ebx
  802022:	5e                   	pop    %esi
  802023:	5f                   	pop    %edi
  802024:	5d                   	pop    %ebp
  802025:	c3                   	ret    

00802026 <devcons_read>:
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80202c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802031:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802035:	75 07                	jne    80203e <devcons_read+0x18>
  802037:	eb 2a                	jmp    802063 <devcons_read+0x3d>
		sys_yield();
  802039:	e8 66 ee ff ff       	call   800ea4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80203e:	66 90                	xchg   %ax,%ax
  802040:	e8 cf ed ff ff       	call   800e14 <sys_cgetc>
  802045:	85 c0                	test   %eax,%eax
  802047:	74 f0                	je     802039 <devcons_read+0x13>
	if (c < 0)
  802049:	85 c0                	test   %eax,%eax
  80204b:	78 16                	js     802063 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80204d:	83 f8 04             	cmp    $0x4,%eax
  802050:	74 0c                	je     80205e <devcons_read+0x38>
	*(char*)vbuf = c;
  802052:	8b 55 0c             	mov    0xc(%ebp),%edx
  802055:	88 02                	mov    %al,(%edx)
	return 1;
  802057:	b8 01 00 00 00       	mov    $0x1,%eax
  80205c:	eb 05                	jmp    802063 <devcons_read+0x3d>
		return 0;
  80205e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802063:	c9                   	leave  
  802064:	c3                   	ret    

00802065 <cputchar>:
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80206b:	8b 45 08             	mov    0x8(%ebp),%eax
  80206e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802071:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802078:	00 
  802079:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80207c:	89 04 24             	mov    %eax,(%esp)
  80207f:	e8 72 ed ff ff       	call   800df6 <sys_cputs>
}
  802084:	c9                   	leave  
  802085:	c3                   	ret    

00802086 <getchar>:
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80208c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802093:	00 
  802094:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a2:	e8 ee f4 ff ff       	call   801595 <read>
	if (r < 0)
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	78 0f                	js     8020ba <getchar+0x34>
	if (r < 1)
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	7e 06                	jle    8020b5 <getchar+0x2f>
	return c;
  8020af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020b3:	eb 05                	jmp    8020ba <getchar+0x34>
		return -E_EOF;
  8020b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8020ba:	c9                   	leave  
  8020bb:	c3                   	ret    

008020bc <iscons>:
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cc:	89 04 24             	mov    %eax,(%esp)
  8020cf:	e8 32 f2 ff ff       	call   801306 <fd_lookup>
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	78 11                	js     8020e9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8020d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020db:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020e1:	39 10                	cmp    %edx,(%eax)
  8020e3:	0f 94 c0             	sete   %al
  8020e6:	0f b6 c0             	movzbl %al,%eax
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <opencons>:
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f4:	89 04 24             	mov    %eax,(%esp)
  8020f7:	e8 bb f1 ff ff       	call   8012b7 <fd_alloc>
		return r;
  8020fc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 40                	js     802142 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802102:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802109:	00 
  80210a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802111:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802118:	e8 a6 ed ff ff       	call   800ec3 <sys_page_alloc>
		return r;
  80211d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80211f:	85 c0                	test   %eax,%eax
  802121:	78 1f                	js     802142 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802123:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802131:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802138:	89 04 24             	mov    %eax,(%esp)
  80213b:	e8 50 f1 ff ff       	call   801290 <fd2num>
  802140:	89 c2                	mov    %eax,%edx
}
  802142:	89 d0                	mov    %edx,%eax
  802144:	c9                   	leave  
  802145:	c3                   	ret    
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	56                   	push   %esi
  802154:	53                   	push   %ebx
  802155:	83 ec 10             	sub    $0x10,%esp
  802158:	8b 75 08             	mov    0x8(%ebp),%esi
  80215b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802161:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802163:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802168:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80216b:	89 04 24             	mov    %eax,(%esp)
  80216e:	e8 66 ef ff ff       	call   8010d9 <sys_ipc_recv>
    if(r < 0){
  802173:	85 c0                	test   %eax,%eax
  802175:	79 16                	jns    80218d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802177:	85 f6                	test   %esi,%esi
  802179:	74 06                	je     802181 <ipc_recv+0x31>
            *from_env_store = 0;
  80217b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802181:	85 db                	test   %ebx,%ebx
  802183:	74 2c                	je     8021b1 <ipc_recv+0x61>
            *perm_store = 0;
  802185:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80218b:	eb 24                	jmp    8021b1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80218d:	85 f6                	test   %esi,%esi
  80218f:	74 0a                	je     80219b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802191:	a1 20 44 80 00       	mov    0x804420,%eax
  802196:	8b 40 74             	mov    0x74(%eax),%eax
  802199:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80219b:	85 db                	test   %ebx,%ebx
  80219d:	74 0a                	je     8021a9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80219f:	a1 20 44 80 00       	mov    0x804420,%eax
  8021a4:	8b 40 78             	mov    0x78(%eax),%eax
  8021a7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8021a9:	a1 20 44 80 00       	mov    0x804420,%eax
  8021ae:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    

008021b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	57                   	push   %edi
  8021bc:	56                   	push   %esi
  8021bd:	53                   	push   %ebx
  8021be:	83 ec 1c             	sub    $0x1c,%esp
  8021c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  8021ca:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  8021cc:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8021d1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8021d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8021d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e3:	89 3c 24             	mov    %edi,(%esp)
  8021e6:	e8 cb ee ff ff       	call   8010b6 <sys_ipc_try_send>
        if(r == 0){
  8021eb:	85 c0                	test   %eax,%eax
  8021ed:	74 28                	je     802217 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8021ef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021f2:	74 1c                	je     802210 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8021f4:	c7 44 24 08 38 2a 80 	movl   $0x802a38,0x8(%esp)
  8021fb:	00 
  8021fc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802203:	00 
  802204:	c7 04 24 4f 2a 80 00 	movl   $0x802a4f,(%esp)
  80220b:	e8 7c e1 ff ff       	call   80038c <_panic>
        }
        sys_yield();
  802210:	e8 8f ec ff ff       	call   800ea4 <sys_yield>
    }
  802215:	eb bd                	jmp    8021d4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802217:	83 c4 1c             	add    $0x1c,%esp
  80221a:	5b                   	pop    %ebx
  80221b:	5e                   	pop    %esi
  80221c:	5f                   	pop    %edi
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    

0080221f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802225:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80222a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80222d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802233:	8b 52 50             	mov    0x50(%edx),%edx
  802236:	39 ca                	cmp    %ecx,%edx
  802238:	75 0d                	jne    802247 <ipc_find_env+0x28>
			return envs[i].env_id;
  80223a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80223d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802242:	8b 40 40             	mov    0x40(%eax),%eax
  802245:	eb 0e                	jmp    802255 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802247:	83 c0 01             	add    $0x1,%eax
  80224a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80224f:	75 d9                	jne    80222a <ipc_find_env+0xb>
	return 0;
  802251:	66 b8 00 00          	mov    $0x0,%ax
}
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80225d:	89 d0                	mov    %edx,%eax
  80225f:	c1 e8 16             	shr    $0x16,%eax
  802262:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80226e:	f6 c1 01             	test   $0x1,%cl
  802271:	74 1d                	je     802290 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802273:	c1 ea 0c             	shr    $0xc,%edx
  802276:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80227d:	f6 c2 01             	test   $0x1,%dl
  802280:	74 0e                	je     802290 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802282:	c1 ea 0c             	shr    $0xc,%edx
  802285:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80228c:	ef 
  80228d:	0f b7 c0             	movzwl %ax,%eax
}
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__udivdi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	83 ec 0c             	sub    $0xc,%esp
  8022a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8022aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8022ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8022b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8022b6:	85 c0                	test   %eax,%eax
  8022b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022bc:	89 ea                	mov    %ebp,%edx
  8022be:	89 0c 24             	mov    %ecx,(%esp)
  8022c1:	75 2d                	jne    8022f0 <__udivdi3+0x50>
  8022c3:	39 e9                	cmp    %ebp,%ecx
  8022c5:	77 61                	ja     802328 <__udivdi3+0x88>
  8022c7:	85 c9                	test   %ecx,%ecx
  8022c9:	89 ce                	mov    %ecx,%esi
  8022cb:	75 0b                	jne    8022d8 <__udivdi3+0x38>
  8022cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d2:	31 d2                	xor    %edx,%edx
  8022d4:	f7 f1                	div    %ecx
  8022d6:	89 c6                	mov    %eax,%esi
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	89 e8                	mov    %ebp,%eax
  8022dc:	f7 f6                	div    %esi
  8022de:	89 c5                	mov    %eax,%ebp
  8022e0:	89 f8                	mov    %edi,%eax
  8022e2:	f7 f6                	div    %esi
  8022e4:	89 ea                	mov    %ebp,%edx
  8022e6:	83 c4 0c             	add    $0xc,%esp
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	39 e8                	cmp    %ebp,%eax
  8022f2:	77 24                	ja     802318 <__udivdi3+0x78>
  8022f4:	0f bd e8             	bsr    %eax,%ebp
  8022f7:	83 f5 1f             	xor    $0x1f,%ebp
  8022fa:	75 3c                	jne    802338 <__udivdi3+0x98>
  8022fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  802300:	39 34 24             	cmp    %esi,(%esp)
  802303:	0f 86 9f 00 00 00    	jbe    8023a8 <__udivdi3+0x108>
  802309:	39 d0                	cmp    %edx,%eax
  80230b:	0f 82 97 00 00 00    	jb     8023a8 <__udivdi3+0x108>
  802311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802318:	31 d2                	xor    %edx,%edx
  80231a:	31 c0                	xor    %eax,%eax
  80231c:	83 c4 0c             	add    $0xc,%esp
  80231f:	5e                   	pop    %esi
  802320:	5f                   	pop    %edi
  802321:	5d                   	pop    %ebp
  802322:	c3                   	ret    
  802323:	90                   	nop
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	89 f8                	mov    %edi,%eax
  80232a:	f7 f1                	div    %ecx
  80232c:	31 d2                	xor    %edx,%edx
  80232e:	83 c4 0c             	add    $0xc,%esp
  802331:	5e                   	pop    %esi
  802332:	5f                   	pop    %edi
  802333:	5d                   	pop    %ebp
  802334:	c3                   	ret    
  802335:	8d 76 00             	lea    0x0(%esi),%esi
  802338:	89 e9                	mov    %ebp,%ecx
  80233a:	8b 3c 24             	mov    (%esp),%edi
  80233d:	d3 e0                	shl    %cl,%eax
  80233f:	89 c6                	mov    %eax,%esi
  802341:	b8 20 00 00 00       	mov    $0x20,%eax
  802346:	29 e8                	sub    %ebp,%eax
  802348:	89 c1                	mov    %eax,%ecx
  80234a:	d3 ef                	shr    %cl,%edi
  80234c:	89 e9                	mov    %ebp,%ecx
  80234e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802352:	8b 3c 24             	mov    (%esp),%edi
  802355:	09 74 24 08          	or     %esi,0x8(%esp)
  802359:	89 d6                	mov    %edx,%esi
  80235b:	d3 e7                	shl    %cl,%edi
  80235d:	89 c1                	mov    %eax,%ecx
  80235f:	89 3c 24             	mov    %edi,(%esp)
  802362:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802366:	d3 ee                	shr    %cl,%esi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	d3 e2                	shl    %cl,%edx
  80236c:	89 c1                	mov    %eax,%ecx
  80236e:	d3 ef                	shr    %cl,%edi
  802370:	09 d7                	or     %edx,%edi
  802372:	89 f2                	mov    %esi,%edx
  802374:	89 f8                	mov    %edi,%eax
  802376:	f7 74 24 08          	divl   0x8(%esp)
  80237a:	89 d6                	mov    %edx,%esi
  80237c:	89 c7                	mov    %eax,%edi
  80237e:	f7 24 24             	mull   (%esp)
  802381:	39 d6                	cmp    %edx,%esi
  802383:	89 14 24             	mov    %edx,(%esp)
  802386:	72 30                	jb     8023b8 <__udivdi3+0x118>
  802388:	8b 54 24 04          	mov    0x4(%esp),%edx
  80238c:	89 e9                	mov    %ebp,%ecx
  80238e:	d3 e2                	shl    %cl,%edx
  802390:	39 c2                	cmp    %eax,%edx
  802392:	73 05                	jae    802399 <__udivdi3+0xf9>
  802394:	3b 34 24             	cmp    (%esp),%esi
  802397:	74 1f                	je     8023b8 <__udivdi3+0x118>
  802399:	89 f8                	mov    %edi,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	e9 7a ff ff ff       	jmp    80231c <__udivdi3+0x7c>
  8023a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8023af:	e9 68 ff ff ff       	jmp    80231c <__udivdi3+0x7c>
  8023b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	83 c4 0c             	add    $0xc,%esp
  8023c0:	5e                   	pop    %esi
  8023c1:	5f                   	pop    %edi
  8023c2:	5d                   	pop    %ebp
  8023c3:	c3                   	ret    
  8023c4:	66 90                	xchg   %ax,%ax
  8023c6:	66 90                	xchg   %ax,%ax
  8023c8:	66 90                	xchg   %ax,%ax
  8023ca:	66 90                	xchg   %ax,%ax
  8023cc:	66 90                	xchg   %ax,%ax
  8023ce:	66 90                	xchg   %ax,%ax

008023d0 <__umoddi3>:
  8023d0:	55                   	push   %ebp
  8023d1:	57                   	push   %edi
  8023d2:	56                   	push   %esi
  8023d3:	83 ec 14             	sub    $0x14,%esp
  8023d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8023de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8023e2:	89 c7                	mov    %eax,%edi
  8023e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8023f0:	89 34 24             	mov    %esi,(%esp)
  8023f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023f7:	85 c0                	test   %eax,%eax
  8023f9:	89 c2                	mov    %eax,%edx
  8023fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023ff:	75 17                	jne    802418 <__umoddi3+0x48>
  802401:	39 fe                	cmp    %edi,%esi
  802403:	76 4b                	jbe    802450 <__umoddi3+0x80>
  802405:	89 c8                	mov    %ecx,%eax
  802407:	89 fa                	mov    %edi,%edx
  802409:	f7 f6                	div    %esi
  80240b:	89 d0                	mov    %edx,%eax
  80240d:	31 d2                	xor    %edx,%edx
  80240f:	83 c4 14             	add    $0x14,%esp
  802412:	5e                   	pop    %esi
  802413:	5f                   	pop    %edi
  802414:	5d                   	pop    %ebp
  802415:	c3                   	ret    
  802416:	66 90                	xchg   %ax,%ax
  802418:	39 f8                	cmp    %edi,%eax
  80241a:	77 54                	ja     802470 <__umoddi3+0xa0>
  80241c:	0f bd e8             	bsr    %eax,%ebp
  80241f:	83 f5 1f             	xor    $0x1f,%ebp
  802422:	75 5c                	jne    802480 <__umoddi3+0xb0>
  802424:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802428:	39 3c 24             	cmp    %edi,(%esp)
  80242b:	0f 87 e7 00 00 00    	ja     802518 <__umoddi3+0x148>
  802431:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802435:	29 f1                	sub    %esi,%ecx
  802437:	19 c7                	sbb    %eax,%edi
  802439:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80243d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802441:	8b 44 24 08          	mov    0x8(%esp),%eax
  802445:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802449:	83 c4 14             	add    $0x14,%esp
  80244c:	5e                   	pop    %esi
  80244d:	5f                   	pop    %edi
  80244e:	5d                   	pop    %ebp
  80244f:	c3                   	ret    
  802450:	85 f6                	test   %esi,%esi
  802452:	89 f5                	mov    %esi,%ebp
  802454:	75 0b                	jne    802461 <__umoddi3+0x91>
  802456:	b8 01 00 00 00       	mov    $0x1,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	f7 f6                	div    %esi
  80245f:	89 c5                	mov    %eax,%ebp
  802461:	8b 44 24 04          	mov    0x4(%esp),%eax
  802465:	31 d2                	xor    %edx,%edx
  802467:	f7 f5                	div    %ebp
  802469:	89 c8                	mov    %ecx,%eax
  80246b:	f7 f5                	div    %ebp
  80246d:	eb 9c                	jmp    80240b <__umoddi3+0x3b>
  80246f:	90                   	nop
  802470:	89 c8                	mov    %ecx,%eax
  802472:	89 fa                	mov    %edi,%edx
  802474:	83 c4 14             	add    $0x14,%esp
  802477:	5e                   	pop    %esi
  802478:	5f                   	pop    %edi
  802479:	5d                   	pop    %ebp
  80247a:	c3                   	ret    
  80247b:	90                   	nop
  80247c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802480:	8b 04 24             	mov    (%esp),%eax
  802483:	be 20 00 00 00       	mov    $0x20,%esi
  802488:	89 e9                	mov    %ebp,%ecx
  80248a:	29 ee                	sub    %ebp,%esi
  80248c:	d3 e2                	shl    %cl,%edx
  80248e:	89 f1                	mov    %esi,%ecx
  802490:	d3 e8                	shr    %cl,%eax
  802492:	89 e9                	mov    %ebp,%ecx
  802494:	89 44 24 04          	mov    %eax,0x4(%esp)
  802498:	8b 04 24             	mov    (%esp),%eax
  80249b:	09 54 24 04          	or     %edx,0x4(%esp)
  80249f:	89 fa                	mov    %edi,%edx
  8024a1:	d3 e0                	shl    %cl,%eax
  8024a3:	89 f1                	mov    %esi,%ecx
  8024a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8024ad:	d3 ea                	shr    %cl,%edx
  8024af:	89 e9                	mov    %ebp,%ecx
  8024b1:	d3 e7                	shl    %cl,%edi
  8024b3:	89 f1                	mov    %esi,%ecx
  8024b5:	d3 e8                	shr    %cl,%eax
  8024b7:	89 e9                	mov    %ebp,%ecx
  8024b9:	09 f8                	or     %edi,%eax
  8024bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8024bf:	f7 74 24 04          	divl   0x4(%esp)
  8024c3:	d3 e7                	shl    %cl,%edi
  8024c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024c9:	89 d7                	mov    %edx,%edi
  8024cb:	f7 64 24 08          	mull   0x8(%esp)
  8024cf:	39 d7                	cmp    %edx,%edi
  8024d1:	89 c1                	mov    %eax,%ecx
  8024d3:	89 14 24             	mov    %edx,(%esp)
  8024d6:	72 2c                	jb     802504 <__umoddi3+0x134>
  8024d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8024dc:	72 22                	jb     802500 <__umoddi3+0x130>
  8024de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024e2:	29 c8                	sub    %ecx,%eax
  8024e4:	19 d7                	sbb    %edx,%edi
  8024e6:	89 e9                	mov    %ebp,%ecx
  8024e8:	89 fa                	mov    %edi,%edx
  8024ea:	d3 e8                	shr    %cl,%eax
  8024ec:	89 f1                	mov    %esi,%ecx
  8024ee:	d3 e2                	shl    %cl,%edx
  8024f0:	89 e9                	mov    %ebp,%ecx
  8024f2:	d3 ef                	shr    %cl,%edi
  8024f4:	09 d0                	or     %edx,%eax
  8024f6:	89 fa                	mov    %edi,%edx
  8024f8:	83 c4 14             	add    $0x14,%esp
  8024fb:	5e                   	pop    %esi
  8024fc:	5f                   	pop    %edi
  8024fd:	5d                   	pop    %ebp
  8024fe:	c3                   	ret    
  8024ff:	90                   	nop
  802500:	39 d7                	cmp    %edx,%edi
  802502:	75 da                	jne    8024de <__umoddi3+0x10e>
  802504:	8b 14 24             	mov    (%esp),%edx
  802507:	89 c1                	mov    %eax,%ecx
  802509:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80250d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802511:	eb cb                	jmp    8024de <__umoddi3+0x10e>
  802513:	90                   	nop
  802514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802518:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80251c:	0f 82 0f ff ff ff    	jb     802431 <__umoddi3+0x61>
  802522:	e9 1a ff ff ff       	jmp    802441 <__umoddi3+0x71>
