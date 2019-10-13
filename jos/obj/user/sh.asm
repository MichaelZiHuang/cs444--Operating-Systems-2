
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 95 09 00 00       	call   8009c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  80004f:	85 db                	test   %ebx,%ebx
  800051:	75 28                	jne    80007b <_gettoken+0x3b>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800053:	b8 00 00 00 00       	mov    $0x0,%eax
		if (debug > 1)
  800058:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80005f:	0f 8e 33 01 00 00    	jle    800198 <_gettoken+0x158>
			cprintf("GETTOKEN NULL\n");
  800065:	c7 04 24 00 35 80 00 	movl   $0x803500,(%esp)
  80006c:	e8 af 0a 00 00       	call   800b20 <cprintf>
		return 0;
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
  800076:	e9 1d 01 00 00       	jmp    800198 <_gettoken+0x158>
	}

	if (debug > 1)
  80007b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800082:	7e 10                	jle    800094 <_gettoken+0x54>
		cprintf("GETTOKEN: %s\n", s);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	c7 04 24 0f 35 80 00 	movl   $0x80350f,(%esp)
  80008f:	e8 8c 0a 00 00       	call   800b20 <cprintf>

	*p1 = 0;
  800094:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  80009a:	8b 45 10             	mov    0x10(%ebp),%eax
  80009d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  8000a3:	eb 07                	jmp    8000ac <_gettoken+0x6c>
		*s++ = 0;
  8000a5:	83 c3 01             	add    $0x1,%ebx
  8000a8:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  8000ac:	0f be 03             	movsbl (%ebx),%eax
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	c7 04 24 1d 35 80 00 	movl   $0x80351d,(%esp)
  8000ba:	e8 8b 12 00 00       	call   80134a <strchr>
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	75 e2                	jne    8000a5 <_gettoken+0x65>
  8000c3:	89 df                	mov    %ebx,%edi
	if (*s == 0) {
  8000c5:	0f b6 03             	movzbl (%ebx),%eax
  8000c8:	84 c0                	test   %al,%al
  8000ca:	75 28                	jne    8000f4 <_gettoken+0xb4>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (debug > 1)
  8000d1:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000d8:	0f 8e ba 00 00 00    	jle    800198 <_gettoken+0x158>
			cprintf("EOL\n");
  8000de:	c7 04 24 22 35 80 00 	movl   $0x803522,(%esp)
  8000e5:	e8 36 0a 00 00       	call   800b20 <cprintf>
		return 0;
  8000ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ef:	e9 a4 00 00 00       	jmp    800198 <_gettoken+0x158>
	}
	if (strchr(SYMBOLS, *s)) {
  8000f4:	0f be c0             	movsbl %al,%eax
  8000f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fb:	c7 04 24 33 35 80 00 	movl   $0x803533,(%esp)
  800102:	e8 43 12 00 00       	call   80134a <strchr>
  800107:	85 c0                	test   %eax,%eax
  800109:	74 2f                	je     80013a <_gettoken+0xfa>
		t = *s;
  80010b:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  80010e:	89 3e                	mov    %edi,(%esi)
		*s++ = 0;
  800110:	c6 07 00             	movb   $0x0,(%edi)
  800113:	83 c7 01             	add    $0x1,%edi
  800116:	8b 45 10             	mov    0x10(%ebp),%eax
  800119:	89 38                	mov    %edi,(%eax)
		*p2 = s;
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  80011b:	89 d8                	mov    %ebx,%eax
		if (debug > 1)
  80011d:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800124:	7e 72                	jle    800198 <_gettoken+0x158>
			cprintf("TOK %c\n", t);
  800126:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80012a:	c7 04 24 27 35 80 00 	movl   $0x803527,(%esp)
  800131:	e8 ea 09 00 00       	call   800b20 <cprintf>
		return t;
  800136:	89 d8                	mov    %ebx,%eax
  800138:	eb 5e                	jmp    800198 <_gettoken+0x158>
	}
	*p1 = s;
  80013a:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013c:	eb 03                	jmp    800141 <_gettoken+0x101>
		s++;
  80013e:	83 c3 01             	add    $0x1,%ebx
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800141:	0f b6 03             	movzbl (%ebx),%eax
  800144:	84 c0                	test   %al,%al
  800146:	74 17                	je     80015f <_gettoken+0x11f>
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 2f 35 80 00 	movl   $0x80352f,(%esp)
  800156:	e8 ef 11 00 00       	call   80134a <strchr>
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 df                	je     80013e <_gettoken+0xfe>
	*p2 = s;
  80015f:	8b 45 10             	mov    0x10(%ebp),%eax
  800162:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800164:	b8 77 00 00 00       	mov    $0x77,%eax
	if (debug > 1) {
  800169:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800170:	7e 26                	jle    800198 <_gettoken+0x158>
		t = **p2;
  800172:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800175:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800178:	8b 06                	mov    (%esi),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	c7 04 24 3b 35 80 00 	movl   $0x80353b,(%esp)
  800185:	e8 96 09 00 00       	call   800b20 <cprintf>
		**p2 = t;
  80018a:	8b 45 10             	mov    0x10(%ebp),%eax
  80018d:	8b 00                	mov    (%eax),%eax
  80018f:	89 fa                	mov    %edi,%edx
  800191:	88 10                	mov    %dl,(%eax)
	return 'w';
  800193:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800198:	83 c4 1c             	add    $0x1c,%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5e                   	pop    %esi
  80019d:	5f                   	pop    %edi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	74 24                	je     8001d1 <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  8001ad:	c7 44 24 08 0c 50 80 	movl   $0x80500c,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 10 50 80 	movl   $0x805010,0x4(%esp)
  8001bc:	00 
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 7b fe ff ff       	call   800040 <_gettoken>
  8001c5:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cf:	eb 3c                	jmp    80020d <gettoken+0x6d>
	}
	c = nc;
  8001d1:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d6:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001de:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e4:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e6:	c7 44 24 08 0c 50 80 	movl   $0x80500c,0x8(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 04 10 50 80 	movl   $0x805010,0x4(%esp)
  8001f5:	00 
  8001f6:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 3d fe ff ff       	call   800040 <_gettoken>
  800203:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  800208:	a1 04 50 80 00       	mov    0x805004,%eax
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <runcmd>:
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	gettoken(s, 0);
  80021b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800222:	00 
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 72 ff ff ff       	call   8001a0 <gettoken>
	argc = 0;
  80022e:	be 00 00 00 00       	mov    $0x0,%esi
		switch ((c = gettoken(0, &t))) {
  800233:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800236:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80023a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800241:	e8 5a ff ff ff       	call   8001a0 <gettoken>
  800246:	83 f8 3e             	cmp    $0x3e,%eax
  800249:	0f 84 95 00 00 00    	je     8002e4 <runcmd+0xd5>
  80024f:	83 f8 3e             	cmp    $0x3e,%eax
  800252:	7f 13                	jg     800267 <runcmd+0x58>
  800254:	85 c0                	test   %eax,%eax
  800256:	0f 84 16 02 00 00    	je     800472 <runcmd+0x263>
  80025c:	83 f8 3c             	cmp    $0x3c,%eax
  80025f:	90                   	nop
  800260:	74 3d                	je     80029f <runcmd+0x90>
  800262:	e9 eb 01 00 00       	jmp    800452 <runcmd+0x243>
  800267:	83 f8 77             	cmp    $0x77,%eax
  80026a:	74 0f                	je     80027b <runcmd+0x6c>
  80026c:	83 f8 7c             	cmp    $0x7c,%eax
  80026f:	90                   	nop
  800270:	0f 84 ef 00 00 00    	je     800365 <runcmd+0x156>
  800276:	e9 d7 01 00 00       	jmp    800452 <runcmd+0x243>
			if (argc == MAXARGS) {
  80027b:	83 fe 10             	cmp    $0x10,%esi
  80027e:	66 90                	xchg   %ax,%ax
  800280:	75 11                	jne    800293 <runcmd+0x84>
				cprintf("too many arguments\n");
  800282:	c7 04 24 45 35 80 00 	movl   $0x803545,(%esp)
  800289:	e8 92 08 00 00       	call   800b20 <cprintf>
				exit();
  80028e:	e8 7b 07 00 00       	call   800a0e <exit>
			argv[argc++] = t;
  800293:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800296:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80029a:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80029d:	eb 97                	jmp    800236 <runcmd+0x27>
			if (gettoken(0, &t) != 'w') {
  80029f:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  8002a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ad:	e8 ee fe ff ff       	call   8001a0 <gettoken>
  8002b2:	83 f8 77             	cmp    $0x77,%eax
  8002b5:	74 11                	je     8002c8 <runcmd+0xb9>
				cprintf("syntax error: < not followed by word\n");
  8002b7:	c7 04 24 a0 36 80 00 	movl   $0x8036a0,(%esp)
  8002be:	e8 5d 08 00 00       	call   800b20 <cprintf>
				exit();
  8002c3:	e8 46 07 00 00       	call   800a0e <exit>
			panic("< redirection not implemented");
  8002c8:	c7 44 24 08 59 35 80 	movl   $0x803559,0x8(%esp)
  8002cf:	00 
  8002d0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8002d7:	00 
  8002d8:	c7 04 24 77 35 80 00 	movl   $0x803577,(%esp)
  8002df:	e8 43 07 00 00       	call   800a27 <_panic>
			if (gettoken(0, &t) != 'w') {
  8002e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ef:	e8 ac fe ff ff       	call   8001a0 <gettoken>
  8002f4:	83 f8 77             	cmp    $0x77,%eax
  8002f7:	74 11                	je     80030a <runcmd+0xfb>
				cprintf("syntax error: > not followed by word\n");
  8002f9:	c7 04 24 c8 36 80 00 	movl   $0x8036c8,(%esp)
  800300:	e8 1b 08 00 00       	call   800b20 <cprintf>
				exit();
  800305:	e8 04 07 00 00       	call   800a0e <exit>
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  80030a:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  800311:	00 
  800312:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	e8 d4 21 00 00       	call   8024f1 <open>
  80031d:	89 c7                	mov    %eax,%edi
  80031f:	85 c0                	test   %eax,%eax
  800321:	79 1c                	jns    80033f <runcmd+0x130>
				cprintf("open %s for write: %e", t, fd);
  800323:	89 44 24 08          	mov    %eax,0x8(%esp)
  800327:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 81 35 80 00 	movl   $0x803581,(%esp)
  800335:	e8 e6 07 00 00       	call   800b20 <cprintf>
				exit();
  80033a:	e8 cf 06 00 00       	call   800a0e <exit>
			if (fd != 1) {
  80033f:	83 ff 01             	cmp    $0x1,%edi
  800342:	0f 84 ee fe ff ff    	je     800236 <runcmd+0x27>
				dup(fd, 1);
  800348:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80034f:	00 
  800350:	89 3c 24             	mov    %edi,(%esp)
  800353:	e8 df 1b 00 00       	call   801f37 <dup>
				close(fd);
  800358:	89 3c 24             	mov    %edi,(%esp)
  80035b:	e8 82 1b 00 00       	call   801ee2 <close>
  800360:	e9 d1 fe ff ff       	jmp    800236 <runcmd+0x27>
			if ((r = pipe(p)) < 0) {
  800365:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	e8 f1 2a 00 00       	call   802e64 <pipe>
  800373:	85 c0                	test   %eax,%eax
  800375:	79 15                	jns    80038c <runcmd+0x17d>
				cprintf("pipe: %e", r);
  800377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037b:	c7 04 24 97 35 80 00 	movl   $0x803597,(%esp)
  800382:	e8 99 07 00 00       	call   800b20 <cprintf>
				exit();
  800387:	e8 82 06 00 00       	call   800a0e <exit>
			if (debug)
  80038c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800393:	74 20                	je     8003b5 <runcmd+0x1a6>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800395:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80039b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039f:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a9:	c7 04 24 a0 35 80 00 	movl   $0x8035a0,(%esp)
  8003b0:	e8 6b 07 00 00       	call   800b20 <cprintf>
			if ((r = fork()) < 0) {
  8003b5:	e8 28 16 00 00       	call   8019e2 <fork>
  8003ba:	89 c7                	mov    %eax,%edi
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	79 15                	jns    8003d5 <runcmd+0x1c6>
				cprintf("fork: %e", r);
  8003c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c4:	c7 04 24 ad 35 80 00 	movl   $0x8035ad,(%esp)
  8003cb:	e8 50 07 00 00       	call   800b20 <cprintf>
				exit();
  8003d0:	e8 39 06 00 00       	call   800a0e <exit>
			if (r == 0) {
  8003d5:	85 ff                	test   %edi,%edi
  8003d7:	75 40                	jne    800419 <runcmd+0x20a>
				if (p[0] != 0) {
  8003d9:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	74 1e                	je     800401 <runcmd+0x1f2>
					dup(p[0], 0);
  8003e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003ea:	00 
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	e8 44 1b 00 00       	call   801f37 <dup>
					close(p[0]);
  8003f3:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003f9:	89 04 24             	mov    %eax,(%esp)
  8003fc:	e8 e1 1a 00 00       	call   801ee2 <close>
				close(p[1]);
  800401:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	e8 d3 1a 00 00       	call   801ee2 <close>
	argc = 0;
  80040f:	be 00 00 00 00       	mov    $0x0,%esi
				goto again;
  800414:	e9 1d fe ff ff       	jmp    800236 <runcmd+0x27>
				if (p[1] != 1) {
  800419:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80041f:	83 f8 01             	cmp    $0x1,%eax
  800422:	74 1e                	je     800442 <runcmd+0x233>
					dup(p[1], 1);
  800424:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80042b:	00 
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	e8 03 1b 00 00       	call   801f37 <dup>
					close(p[1]);
  800434:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	e8 a0 1a 00 00       	call   801ee2 <close>
				close(p[0]);
  800442:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 92 1a 00 00       	call   801ee2 <close>
				goto runit;
  800450:	eb 25                	jmp    800477 <runcmd+0x268>
			panic("bad return %d from gettoken", c);
  800452:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800456:	c7 44 24 08 b6 35 80 	movl   $0x8035b6,0x8(%esp)
  80045d:	00 
  80045e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800465:	00 
  800466:	c7 04 24 77 35 80 00 	movl   $0x803577,(%esp)
  80046d:	e8 b5 05 00 00       	call   800a27 <_panic>
	pipe_child = 0;
  800472:	bf 00 00 00 00       	mov    $0x0,%edi
	if(argc == 0) {
  800477:	85 f6                	test   %esi,%esi
  800479:	75 1e                	jne    800499 <runcmd+0x28a>
		if (debug)
  80047b:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800482:	0f 84 85 01 00 00    	je     80060d <runcmd+0x3fe>
			cprintf("EMPTY COMMAND\n");
  800488:	c7 04 24 d2 35 80 00 	movl   $0x8035d2,(%esp)
  80048f:	e8 8c 06 00 00       	call   800b20 <cprintf>
  800494:	e9 74 01 00 00       	jmp    80060d <runcmd+0x3fe>
	if (argv[0][0] != '/') {
  800499:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80049c:	80 38 2f             	cmpb   $0x2f,(%eax)
  80049f:	74 22                	je     8004c3 <runcmd+0x2b4>
		argv0buf[0] = '/';
  8004a1:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ac:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004b2:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	e8 77 0d 00 00       	call   801237 <strcpy>
		argv[0] = argv0buf;
  8004c0:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	argv[argc] = 0;
  8004c3:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004ca:	00 
	if (debug) {
  8004cb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004d2:	74 43                	je     800517 <runcmd+0x308>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004d4:	a1 24 54 80 00       	mov    0x805424,%eax
  8004d9:	8b 40 48             	mov    0x48(%eax),%eax
  8004dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e0:	c7 04 24 e1 35 80 00 	movl   $0x8035e1,(%esp)
  8004e7:	e8 34 06 00 00       	call   800b20 <cprintf>
  8004ec:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  8004ef:	eb 10                	jmp    800501 <runcmd+0x2f2>
			cprintf(" %s", argv[i]);
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	c7 04 24 6c 36 80 00 	movl   $0x80366c,(%esp)
  8004fc:	e8 1f 06 00 00       	call   800b20 <cprintf>
  800501:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; argv[i]; i++)
  800504:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800507:	85 c0                	test   %eax,%eax
  800509:	75 e6                	jne    8004f1 <runcmd+0x2e2>
		cprintf("\n");
  80050b:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800512:	e8 09 06 00 00       	call   800b20 <cprintf>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800517:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80051a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	e8 a7 21 00 00       	call   8026d0 <spawn>
  800529:	89 c3                	mov    %eax,%ebx
  80052b:	85 c0                	test   %eax,%eax
  80052d:	0f 89 c3 00 00 00    	jns    8005f6 <runcmd+0x3e7>
		cprintf("spawn %s: %e\n", argv[0], r);
  800533:	89 44 24 08          	mov    %eax,0x8(%esp)
  800537:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80053a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053e:	c7 04 24 ef 35 80 00 	movl   $0x8035ef,(%esp)
  800545:	e8 d6 05 00 00       	call   800b20 <cprintf>
	close_all();
  80054a:	e8 c6 19 00 00       	call   801f15 <close_all>
  80054f:	eb 4c                	jmp    80059d <runcmd+0x38e>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800551:	a1 24 54 80 00       	mov    0x805424,%eax
  800556:	8b 40 48             	mov    0x48(%eax),%eax
  800559:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80055d:	8b 55 a8             	mov    -0x58(%ebp),%edx
  800560:	89 54 24 08          	mov    %edx,0x8(%esp)
  800564:	89 44 24 04          	mov    %eax,0x4(%esp)
  800568:	c7 04 24 fd 35 80 00 	movl   $0x8035fd,(%esp)
  80056f:	e8 ac 05 00 00       	call   800b20 <cprintf>
		wait(r);
  800574:	89 1c 24             	mov    %ebx,(%esp)
  800577:	e8 8e 2a 00 00       	call   80300a <wait>
		if (debug)
  80057c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800583:	74 18                	je     80059d <runcmd+0x38e>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800585:	a1 24 54 80 00       	mov    0x805424,%eax
  80058a:	8b 40 48             	mov    0x48(%eax),%eax
  80058d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800591:	c7 04 24 12 36 80 00 	movl   $0x803612,(%esp)
  800598:	e8 83 05 00 00       	call   800b20 <cprintf>
	if (pipe_child) {
  80059d:	85 ff                	test   %edi,%edi
  80059f:	74 4e                	je     8005ef <runcmd+0x3e0>
		if (debug)
  8005a1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005a8:	74 1c                	je     8005c6 <runcmd+0x3b7>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005aa:	a1 24 54 80 00       	mov    0x805424,%eax
  8005af:	8b 40 48             	mov    0x48(%eax),%eax
  8005b2:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ba:	c7 04 24 28 36 80 00 	movl   $0x803628,(%esp)
  8005c1:	e8 5a 05 00 00       	call   800b20 <cprintf>
		wait(pipe_child);
  8005c6:	89 3c 24             	mov    %edi,(%esp)
  8005c9:	e8 3c 2a 00 00       	call   80300a <wait>
		if (debug)
  8005ce:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005d5:	74 18                	je     8005ef <runcmd+0x3e0>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005d7:	a1 24 54 80 00       	mov    0x805424,%eax
  8005dc:	8b 40 48             	mov    0x48(%eax),%eax
  8005df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e3:	c7 04 24 12 36 80 00 	movl   $0x803612,(%esp)
  8005ea:	e8 31 05 00 00       	call   800b20 <cprintf>
	exit();
  8005ef:	e8 1a 04 00 00       	call   800a0e <exit>
  8005f4:	eb 17                	jmp    80060d <runcmd+0x3fe>
	close_all();
  8005f6:	e8 1a 19 00 00       	call   801f15 <close_all>
		if (debug)
  8005fb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800602:	0f 84 6c ff ff ff    	je     800574 <runcmd+0x365>
  800608:	e9 44 ff ff ff       	jmp    800551 <runcmd+0x342>
}
  80060d:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  800613:	5b                   	pop    %ebx
  800614:	5e                   	pop    %esi
  800615:	5f                   	pop    %edi
  800616:	5d                   	pop    %ebp
  800617:	c3                   	ret    

00800618 <usage>:


void
usage(void)
{
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  80061e:	c7 04 24 f0 36 80 00 	movl   $0x8036f0,(%esp)
  800625:	e8 f6 04 00 00       	call   800b20 <cprintf>
	exit();
  80062a:	e8 df 03 00 00       	call   800a0e <exit>
}
  80062f:	c9                   	leave  
  800630:	c3                   	ret    

00800631 <umain>:

void
umain(int argc, char **argv)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	57                   	push   %edi
  800635:	56                   	push   %esi
  800636:	53                   	push   %ebx
  800637:	83 ec 3c             	sub    $0x3c,%esp
  80063a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80063d:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800640:	89 44 24 08          	mov    %eax,0x8(%esp)
  800644:	89 74 24 04          	mov    %esi,0x4(%esp)
  800648:	8d 45 08             	lea    0x8(%ebp),%eax
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	e8 8b 15 00 00       	call   801bde <argstart>
	echocmds = 0;
  800653:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	interactive = '?';
  80065a:	bf 3f 00 00 00       	mov    $0x3f,%edi
	while ((r = argnext(&args)) >= 0)
  80065f:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800662:	eb 2f                	jmp    800693 <umain+0x62>
		switch (r) {
  800664:	83 f8 69             	cmp    $0x69,%eax
  800667:	74 0c                	je     800675 <umain+0x44>
  800669:	83 f8 78             	cmp    $0x78,%eax
  80066c:	74 1e                	je     80068c <umain+0x5b>
  80066e:	83 f8 64             	cmp    $0x64,%eax
  800671:	75 12                	jne    800685 <umain+0x54>
  800673:	eb 07                	jmp    80067c <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800675:	bf 01 00 00 00       	mov    $0x1,%edi
  80067a:	eb 17                	jmp    800693 <umain+0x62>
			debug++;
  80067c:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  800683:	eb 0e                	jmp    800693 <umain+0x62>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  800685:	e8 8e ff ff ff       	call   800618 <usage>
  80068a:	eb 07                	jmp    800693 <umain+0x62>
			echocmds = 1;
  80068c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	while ((r = argnext(&args)) >= 0)
  800693:	89 1c 24             	mov    %ebx,(%esp)
  800696:	e8 7b 15 00 00       	call   801c16 <argnext>
  80069b:	85 c0                	test   %eax,%eax
  80069d:	79 c5                	jns    800664 <umain+0x33>
  80069f:	89 fb                	mov    %edi,%ebx
		}

	if (argc > 2)
  8006a1:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006a5:	7e 05                	jle    8006ac <umain+0x7b>
		usage();
  8006a7:	e8 6c ff ff ff       	call   800618 <usage>
	if (argc == 2) {
  8006ac:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006b0:	75 72                	jne    800724 <umain+0xf3>
		close(0);
  8006b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b9:	e8 24 18 00 00       	call   801ee2 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8006c5:	00 
  8006c6:	8b 46 04             	mov    0x4(%esi),%eax
  8006c9:	89 04 24             	mov    %eax,(%esp)
  8006cc:	e8 20 1e 00 00       	call   8024f1 <open>
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	79 27                	jns    8006fc <umain+0xcb>
			panic("open %s: %e", argv[1], r);
  8006d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d9:	8b 46 04             	mov    0x4(%esi),%eax
  8006dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e0:	c7 44 24 08 48 36 80 	movl   $0x803648,0x8(%esp)
  8006e7:	00 
  8006e8:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  8006ef:	00 
  8006f0:	c7 04 24 77 35 80 00 	movl   $0x803577,(%esp)
  8006f7:	e8 2b 03 00 00       	call   800a27 <_panic>
		assert(r == 0);
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 24                	je     800724 <umain+0xf3>
  800700:	c7 44 24 0c 54 36 80 	movl   $0x803654,0xc(%esp)
  800707:	00 
  800708:	c7 44 24 08 5b 36 80 	movl   $0x80365b,0x8(%esp)
  80070f:	00 
  800710:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  800717:	00 
  800718:	c7 04 24 77 35 80 00 	movl   $0x803577,(%esp)
  80071f:	e8 03 03 00 00       	call   800a27 <_panic>
	}
	if (interactive == '?')
  800724:	83 fb 3f             	cmp    $0x3f,%ebx
  800727:	75 0e                	jne    800737 <umain+0x106>
		interactive = iscons(0);
  800729:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800730:	e8 07 02 00 00       	call   80093c <iscons>
  800735:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800737:	85 ff                	test   %edi,%edi
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
  80073e:	ba 45 36 80 00       	mov    $0x803645,%edx
  800743:	0f 45 c2             	cmovne %edx,%eax
  800746:	89 04 24             	mov    %eax,(%esp)
  800749:	e8 c2 09 00 00       	call   801110 <readline>
  80074e:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800750:	85 c0                	test   %eax,%eax
  800752:	75 1a                	jne    80076e <umain+0x13d>
			if (debug)
  800754:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80075b:	74 0c                	je     800769 <umain+0x138>
				cprintf("EXITING\n");
  80075d:	c7 04 24 70 36 80 00 	movl   $0x803670,(%esp)
  800764:	e8 b7 03 00 00       	call   800b20 <cprintf>
			exit();	// end of file
  800769:	e8 a0 02 00 00       	call   800a0e <exit>
		}
		if (debug)
  80076e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800775:	74 10                	je     800787 <umain+0x156>
			cprintf("LINE: %s\n", buf);
  800777:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077b:	c7 04 24 79 36 80 00 	movl   $0x803679,(%esp)
  800782:	e8 99 03 00 00       	call   800b20 <cprintf>
		if (buf[0] == '#')
  800787:	80 3b 23             	cmpb   $0x23,(%ebx)
  80078a:	74 ab                	je     800737 <umain+0x106>
			continue;
		if (echocmds)
  80078c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800790:	74 10                	je     8007a2 <umain+0x171>
			printf("# %s\n", buf);
  800792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800796:	c7 04 24 83 36 80 00 	movl   $0x803683,(%esp)
  80079d:	e8 ff 1e 00 00       	call   8026a1 <printf>
		if (debug)
  8007a2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007a9:	74 0c                	je     8007b7 <umain+0x186>
			cprintf("BEFORE FORK\n");
  8007ab:	c7 04 24 89 36 80 00 	movl   $0x803689,(%esp)
  8007b2:	e8 69 03 00 00       	call   800b20 <cprintf>
		if ((r = fork()) < 0)
  8007b7:	e8 26 12 00 00       	call   8019e2 <fork>
  8007bc:	89 c6                	mov    %eax,%esi
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	79 20                	jns    8007e2 <umain+0x1b1>
			panic("fork: %e", r);
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	c7 44 24 08 ad 35 80 	movl   $0x8035ad,0x8(%esp)
  8007cd:	00 
  8007ce:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  8007d5:	00 
  8007d6:	c7 04 24 77 35 80 00 	movl   $0x803577,(%esp)
  8007dd:	e8 45 02 00 00       	call   800a27 <_panic>
		if (debug)
  8007e2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007e9:	74 10                	je     8007fb <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  8007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ef:	c7 04 24 96 36 80 00 	movl   $0x803696,(%esp)
  8007f6:	e8 25 03 00 00       	call   800b20 <cprintf>
		if (r == 0) {
  8007fb:	85 f6                	test   %esi,%esi
  8007fd:	75 12                	jne    800811 <umain+0x1e0>
			runcmd(buf);
  8007ff:	89 1c 24             	mov    %ebx,(%esp)
  800802:	e8 08 fa ff ff       	call   80020f <runcmd>
			exit();
  800807:	e8 02 02 00 00       	call   800a0e <exit>
  80080c:	e9 26 ff ff ff       	jmp    800737 <umain+0x106>
		} else
			wait(r);
  800811:	89 34 24             	mov    %esi,(%esp)
  800814:	e8 f1 27 00 00       	call   80300a <wait>
  800819:	e9 19 ff ff ff       	jmp    800737 <umain+0x106>
  80081e:	66 90                	xchg   %ax,%ax

00800820 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800830:	c7 44 24 04 11 37 80 	movl   $0x803711,0x4(%esp)
  800837:	00 
  800838:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	e8 f4 09 00 00       	call   801237 <strcpy>
	return 0;
}
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <devcons_write>:
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	57                   	push   %edi
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  800856:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80085b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800861:	eb 31                	jmp    800894 <devcons_write+0x4a>
		m = n - tot;
  800863:	8b 75 10             	mov    0x10(%ebp),%esi
  800866:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800868:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80086b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800870:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800873:	89 74 24 08          	mov    %esi,0x8(%esp)
  800877:	03 45 0c             	add    0xc(%ebp),%eax
  80087a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087e:	89 3c 24             	mov    %edi,(%esp)
  800881:	e8 4e 0b 00 00       	call   8013d4 <memmove>
		sys_cputs(buf, m);
  800886:	89 74 24 04          	mov    %esi,0x4(%esp)
  80088a:	89 3c 24             	mov    %edi,(%esp)
  80088d:	e8 f4 0c 00 00       	call   801586 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800892:	01 f3                	add    %esi,%ebx
  800894:	89 d8                	mov    %ebx,%eax
  800896:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800899:	72 c8                	jb     800863 <devcons_write+0x19>
}
  80089b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5f                   	pop    %edi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <devcons_read>:
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8008b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008b5:	75 07                	jne    8008be <devcons_read+0x18>
  8008b7:	eb 2a                	jmp    8008e3 <devcons_read+0x3d>
		sys_yield();
  8008b9:	e8 76 0d 00 00       	call   801634 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8008be:	66 90                	xchg   %ax,%ax
  8008c0:	e8 df 0c 00 00       	call   8015a4 <sys_cgetc>
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 f0                	je     8008b9 <devcons_read+0x13>
	if (c < 0)
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	78 16                	js     8008e3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  8008cd:	83 f8 04             	cmp    $0x4,%eax
  8008d0:	74 0c                	je     8008de <devcons_read+0x38>
	*(char*)vbuf = c;
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d5:	88 02                	mov    %al,(%edx)
	return 1;
  8008d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8008dc:	eb 05                	jmp    8008e3 <devcons_read+0x3d>
		return 0;
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <cputchar>:
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8008f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8008f8:	00 
  8008f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008fc:	89 04 24             	mov    %eax,(%esp)
  8008ff:	e8 82 0c 00 00       	call   801586 <sys_cputs>
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <getchar>:
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80090c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800913:	00 
  800914:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800922:	e8 1e 17 00 00       	call   802045 <read>
	if (r < 0)
  800927:	85 c0                	test   %eax,%eax
  800929:	78 0f                	js     80093a <getchar+0x34>
	if (r < 1)
  80092b:	85 c0                	test   %eax,%eax
  80092d:	7e 06                	jle    800935 <getchar+0x2f>
	return c;
  80092f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800933:	eb 05                	jmp    80093a <getchar+0x34>
		return -E_EOF;
  800935:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <iscons>:
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800942:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 62 14 00 00       	call   801db6 <fd_lookup>
  800954:	85 c0                	test   %eax,%eax
  800956:	78 11                	js     800969 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  800958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800961:	39 10                	cmp    %edx,(%eax)
  800963:	0f 94 c0             	sete   %al
  800966:	0f b6 c0             	movzbl %al,%eax
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <opencons>:
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800971:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	e8 eb 13 00 00       	call   801d67 <fd_alloc>
		return r;
  80097c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80097e:	85 c0                	test   %eax,%eax
  800980:	78 40                	js     8009c2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800982:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800989:	00 
  80098a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800991:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800998:	e8 b6 0c 00 00       	call   801653 <sys_page_alloc>
		return r;
  80099d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	78 1f                	js     8009c2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8009a3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009b8:	89 04 24             	mov    %eax,(%esp)
  8009bb:	e8 80 13 00 00       	call   801d40 <fd2num>
  8009c0:	89 c2                	mov    %eax,%edx
}
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	83 ec 10             	sub    $0x10,%esp
  8009ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  8009d4:	e8 3c 0c 00 00       	call   801615 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  8009d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009e6:	a3 24 54 80 00       	mov    %eax,0x805424
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009eb:	85 db                	test   %ebx,%ebx
  8009ed:	7e 07                	jle    8009f6 <libmain+0x30>
		binaryname = argv[0];
  8009ef:	8b 06                	mov    (%esi),%eax
  8009f1:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fa:	89 1c 24             	mov    %ebx,(%esp)
  8009fd:	e8 2f fc ff ff       	call   800631 <umain>

	// exit gracefully
	exit();
  800a02:	e8 07 00 00 00       	call   800a0e <exit>
}
  800a07:	83 c4 10             	add    $0x10,%esp
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800a14:	e8 fc 14 00 00       	call   801f15 <close_all>
	sys_env_destroy(0);
  800a19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a20:	e8 9e 0b 00 00       	call   8015c3 <sys_env_destroy>
}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a2f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a32:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a38:	e8 d8 0b 00 00       	call   801615 <sys_getenvid>
  800a3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a40:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a44:	8b 55 08             	mov    0x8(%ebp),%edx
  800a47:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a4b:	89 74 24 08          	mov    %esi,0x8(%esp)
  800a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a53:	c7 04 24 28 37 80 00 	movl   $0x803728,(%esp)
  800a5a:	e8 c1 00 00 00       	call   800b20 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a63:	8b 45 10             	mov    0x10(%ebp),%eax
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 51 00 00 00       	call   800abf <vcprintf>
	cprintf("\n");
  800a6e:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800a75:	e8 a6 00 00 00       	call   800b20 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a7a:	cc                   	int3   
  800a7b:	eb fd                	jmp    800a7a <_panic+0x53>

00800a7d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	83 ec 14             	sub    $0x14,%esp
  800a84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a87:	8b 13                	mov    (%ebx),%edx
  800a89:	8d 42 01             	lea    0x1(%edx),%eax
  800a8c:	89 03                	mov    %eax,(%ebx)
  800a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a95:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a9a:	75 19                	jne    800ab5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800a9c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800aa3:	00 
  800aa4:	8d 43 08             	lea    0x8(%ebx),%eax
  800aa7:	89 04 24             	mov    %eax,(%esp)
  800aaa:	e8 d7 0a 00 00       	call   801586 <sys_cputs>
		b->idx = 0;
  800aaf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800ab5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ab9:	83 c4 14             	add    $0x14,%esp
  800abc:	5b                   	pop    %ebx
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800ac8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800acf:	00 00 00 
	b.cnt = 0;
  800ad2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ad9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800af0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af4:	c7 04 24 7d 0a 80 00 	movl   $0x800a7d,(%esp)
  800afb:	e8 ae 01 00 00       	call   800cae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b00:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b10:	89 04 24             	mov    %eax,(%esp)
  800b13:	e8 6e 0a 00 00       	call   801586 <sys_cputs>

	return b.cnt;
}
  800b18:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b26:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	89 04 24             	mov    %eax,(%esp)
  800b33:	e8 87 ff ff ff       	call   800abf <vcprintf>
	va_end(ap);

	return cnt;
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    
  800b3a:	66 90                	xchg   %ax,%ax
  800b3c:	66 90                	xchg   %ax,%ax
  800b3e:	66 90                	xchg   %ax,%ax

00800b40 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 3c             	sub    $0x3c,%esp
  800b49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 c3                	mov    %eax,%ebx
  800b59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b67:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b6d:	39 d9                	cmp    %ebx,%ecx
  800b6f:	72 05                	jb     800b76 <printnum+0x36>
  800b71:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800b74:	77 69                	ja     800bdf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b76:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800b79:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b7d:	83 ee 01             	sub    $0x1,%esi
  800b80:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b88:	8b 44 24 08          	mov    0x8(%esp),%eax
  800b8c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800b90:	89 c3                	mov    %eax,%ebx
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b97:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b9a:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ba2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ba5:	89 04 24             	mov    %eax,(%esp)
  800ba8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800baf:	e8 bc 26 00 00       	call   803270 <__udivdi3>
  800bb4:	89 d9                	mov    %ebx,%ecx
  800bb6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bbe:	89 04 24             	mov    %eax,(%esp)
  800bc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc5:	89 fa                	mov    %edi,%edx
  800bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bca:	e8 71 ff ff ff       	call   800b40 <printnum>
  800bcf:	eb 1b                	jmp    800bec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bd1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd5:	8b 45 18             	mov    0x18(%ebp),%eax
  800bd8:	89 04 24             	mov    %eax,(%esp)
  800bdb:	ff d3                	call   *%ebx
  800bdd:	eb 03                	jmp    800be2 <printnum+0xa2>
  800bdf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800be2:	83 ee 01             	sub    $0x1,%esi
  800be5:	85 f6                	test   %esi,%esi
  800be7:	7f e8                	jg     800bd1 <printnum+0x91>
  800be9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800bf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c02:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c05:	89 04 24             	mov    %eax,(%esp)
  800c08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0f:	e8 8c 27 00 00       	call   8033a0 <__umoddi3>
  800c14:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c18:	0f be 80 4b 37 80 00 	movsbl 0x80374b(%eax),%eax
  800c1f:	89 04 24             	mov    %eax,(%esp)
  800c22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c25:	ff d0                	call   *%eax
}
  800c27:	83 c4 3c             	add    $0x3c,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c32:	83 fa 01             	cmp    $0x1,%edx
  800c35:	7e 0e                	jle    800c45 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c37:	8b 10                	mov    (%eax),%edx
  800c39:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c3c:	89 08                	mov    %ecx,(%eax)
  800c3e:	8b 02                	mov    (%edx),%eax
  800c40:	8b 52 04             	mov    0x4(%edx),%edx
  800c43:	eb 22                	jmp    800c67 <getuint+0x38>
	else if (lflag)
  800c45:	85 d2                	test   %edx,%edx
  800c47:	74 10                	je     800c59 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c49:	8b 10                	mov    (%eax),%edx
  800c4b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c4e:	89 08                	mov    %ecx,(%eax)
  800c50:	8b 02                	mov    (%edx),%eax
  800c52:	ba 00 00 00 00       	mov    $0x0,%edx
  800c57:	eb 0e                	jmp    800c67 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c59:	8b 10                	mov    (%eax),%edx
  800c5b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c5e:	89 08                	mov    %ecx,(%eax)
  800c60:	8b 02                	mov    (%edx),%eax
  800c62:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c6f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c73:	8b 10                	mov    (%eax),%edx
  800c75:	3b 50 04             	cmp    0x4(%eax),%edx
  800c78:	73 0a                	jae    800c84 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c7a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c7d:	89 08                	mov    %ecx,(%eax)
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	88 02                	mov    %al,(%edx)
}
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <printfmt>:
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800c8c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c93:	8b 45 10             	mov    0x10(%ebp),%eax
  800c96:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	89 04 24             	mov    %eax,(%esp)
  800ca7:	e8 02 00 00 00       	call   800cae <vprintfmt>
}
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <vprintfmt>:
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 3c             	sub    $0x3c,%esp
  800cb7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbd:	eb 1f                	jmp    800cde <vprintfmt+0x30>
			if (ch == '\0'){
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	75 0f                	jne    800cd2 <vprintfmt+0x24>
				color = 0x0100;
  800cc3:	c7 05 14 50 80 00 00 	movl   $0x100,0x805014
  800cca:	01 00 00 
  800ccd:	e9 b3 03 00 00       	jmp    801085 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800cd2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cd6:	89 04 24             	mov    %eax,(%esp)
  800cd9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800cdc:	89 f3                	mov    %esi,%ebx
  800cde:	8d 73 01             	lea    0x1(%ebx),%esi
  800ce1:	0f b6 03             	movzbl (%ebx),%eax
  800ce4:	83 f8 25             	cmp    $0x25,%eax
  800ce7:	75 d6                	jne    800cbf <vprintfmt+0x11>
  800ce9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800ced:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800cf4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800cfb:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	eb 1d                	jmp    800d26 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800d09:	89 de                	mov    %ebx,%esi
			padc = '-';
  800d0b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800d0f:	eb 15                	jmp    800d26 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800d11:	89 de                	mov    %ebx,%esi
			padc = '0';
  800d13:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800d17:	eb 0d                	jmp    800d26 <vprintfmt+0x78>
				width = precision, precision = -1;
  800d19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800d1f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d26:	8d 5e 01             	lea    0x1(%esi),%ebx
  800d29:	0f b6 0e             	movzbl (%esi),%ecx
  800d2c:	0f b6 c1             	movzbl %cl,%eax
  800d2f:	83 e9 23             	sub    $0x23,%ecx
  800d32:	80 f9 55             	cmp    $0x55,%cl
  800d35:	0f 87 2a 03 00 00    	ja     801065 <vprintfmt+0x3b7>
  800d3b:	0f b6 c9             	movzbl %cl,%ecx
  800d3e:	ff 24 8d 80 38 80 00 	jmp    *0x803880(,%ecx,4)
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  800d4c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800d4f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800d53:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d56:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800d59:	83 fb 09             	cmp    $0x9,%ebx
  800d5c:	77 36                	ja     800d94 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  800d5e:	83 c6 01             	add    $0x1,%esi
			}
  800d61:	eb e9                	jmp    800d4c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800d63:	8b 45 14             	mov    0x14(%ebp),%eax
  800d66:	8d 48 04             	lea    0x4(%eax),%ecx
  800d69:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800d6c:	8b 00                	mov    (%eax),%eax
  800d6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d71:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800d73:	eb 22                	jmp    800d97 <vprintfmt+0xe9>
  800d75:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800d78:	85 c9                	test   %ecx,%ecx
  800d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7f:	0f 49 c1             	cmovns %ecx,%eax
  800d82:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d85:	89 de                	mov    %ebx,%esi
  800d87:	eb 9d                	jmp    800d26 <vprintfmt+0x78>
  800d89:	89 de                	mov    %ebx,%esi
			altflag = 1;
  800d8b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800d92:	eb 92                	jmp    800d26 <vprintfmt+0x78>
  800d94:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800d97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d9b:	79 89                	jns    800d26 <vprintfmt+0x78>
  800d9d:	e9 77 ff ff ff       	jmp    800d19 <vprintfmt+0x6b>
			lflag++;
  800da2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800da5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800da7:	e9 7a ff ff ff       	jmp    800d26 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  800dac:	8b 45 14             	mov    0x14(%ebp),%eax
  800daf:	8d 50 04             	lea    0x4(%eax),%edx
  800db2:	89 55 14             	mov    %edx,0x14(%ebp)
  800db5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800db9:	8b 00                	mov    (%eax),%eax
  800dbb:	89 04 24             	mov    %eax,(%esp)
  800dbe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800dc1:	e9 18 ff ff ff       	jmp    800cde <vprintfmt+0x30>
			err = va_arg(ap, int);
  800dc6:	8b 45 14             	mov    0x14(%ebp),%eax
  800dc9:	8d 50 04             	lea    0x4(%eax),%edx
  800dcc:	89 55 14             	mov    %edx,0x14(%ebp)
  800dcf:	8b 00                	mov    (%eax),%eax
  800dd1:	99                   	cltd   
  800dd2:	31 d0                	xor    %edx,%eax
  800dd4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800dd6:	83 f8 0f             	cmp    $0xf,%eax
  800dd9:	7f 0b                	jg     800de6 <vprintfmt+0x138>
  800ddb:	8b 14 85 e0 39 80 00 	mov    0x8039e0(,%eax,4),%edx
  800de2:	85 d2                	test   %edx,%edx
  800de4:	75 20                	jne    800e06 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800de6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dea:	c7 44 24 08 63 37 80 	movl   $0x803763,0x8(%esp)
  800df1:	00 
  800df2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	89 04 24             	mov    %eax,(%esp)
  800dfc:	e8 85 fe ff ff       	call   800c86 <printfmt>
  800e01:	e9 d8 fe ff ff       	jmp    800cde <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800e06:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e0a:	c7 44 24 08 6d 36 80 	movl   $0x80366d,0x8(%esp)
  800e11:	00 
  800e12:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	89 04 24             	mov    %eax,(%esp)
  800e1c:	e8 65 fe ff ff       	call   800c86 <printfmt>
  800e21:	e9 b8 fe ff ff       	jmp    800cde <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800e26:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e29:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  800e2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e32:	8d 50 04             	lea    0x4(%eax),%edx
  800e35:	89 55 14             	mov    %edx,0x14(%ebp)
  800e38:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800e3a:	85 f6                	test   %esi,%esi
  800e3c:	b8 5c 37 80 00       	mov    $0x80375c,%eax
  800e41:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800e44:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800e48:	0f 84 97 00 00 00    	je     800ee5 <vprintfmt+0x237>
  800e4e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800e52:	0f 8e 9b 00 00 00    	jle    800ef3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e58:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e5c:	89 34 24             	mov    %esi,(%esp)
  800e5f:	e8 b4 03 00 00       	call   801218 <strnlen>
  800e64:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800e67:	29 c2                	sub    %eax,%edx
  800e69:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800e6c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e70:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e73:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800e76:	8b 75 08             	mov    0x8(%ebp),%esi
  800e79:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e7c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800e7e:	eb 0f                	jmp    800e8f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800e80:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e84:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e87:	89 04 24             	mov    %eax,(%esp)
  800e8a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800e8c:	83 eb 01             	sub    $0x1,%ebx
  800e8f:	85 db                	test   %ebx,%ebx
  800e91:	7f ed                	jg     800e80 <vprintfmt+0x1d2>
  800e93:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800e96:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800e99:	85 d2                	test   %edx,%edx
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea0:	0f 49 c2             	cmovns %edx,%eax
  800ea3:	29 c2                	sub    %eax,%edx
  800ea5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ea8:	89 d7                	mov    %edx,%edi
  800eaa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ead:	eb 50                	jmp    800eff <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  800eaf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800eb3:	74 1e                	je     800ed3 <vprintfmt+0x225>
  800eb5:	0f be d2             	movsbl %dl,%edx
  800eb8:	83 ea 20             	sub    $0x20,%edx
  800ebb:	83 fa 5e             	cmp    $0x5e,%edx
  800ebe:	76 13                	jbe    800ed3 <vprintfmt+0x225>
					putch('?', putdat);
  800ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ece:	ff 55 08             	call   *0x8(%ebp)
  800ed1:	eb 0d                	jmp    800ee0 <vprintfmt+0x232>
					putch(ch, putdat);
  800ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eda:	89 04 24             	mov    %eax,(%esp)
  800edd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ee0:	83 ef 01             	sub    $0x1,%edi
  800ee3:	eb 1a                	jmp    800eff <vprintfmt+0x251>
  800ee5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ee8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800eeb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800eee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ef1:	eb 0c                	jmp    800eff <vprintfmt+0x251>
  800ef3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ef6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ef9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800efc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800eff:	83 c6 01             	add    $0x1,%esi
  800f02:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800f06:	0f be c2             	movsbl %dl,%eax
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	74 27                	je     800f34 <vprintfmt+0x286>
  800f0d:	85 db                	test   %ebx,%ebx
  800f0f:	78 9e                	js     800eaf <vprintfmt+0x201>
  800f11:	83 eb 01             	sub    $0x1,%ebx
  800f14:	79 99                	jns    800eaf <vprintfmt+0x201>
  800f16:	89 f8                	mov    %edi,%eax
  800f18:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	eb 1a                	jmp    800f3c <vprintfmt+0x28e>
				putch(' ', putdat);
  800f22:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f26:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800f2d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800f2f:	83 eb 01             	sub    $0x1,%ebx
  800f32:	eb 08                	jmp    800f3c <vprintfmt+0x28e>
  800f34:	89 fb                	mov    %edi,%ebx
  800f36:	8b 75 08             	mov    0x8(%ebp),%esi
  800f39:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f3c:	85 db                	test   %ebx,%ebx
  800f3e:	7f e2                	jg     800f22 <vprintfmt+0x274>
  800f40:	89 75 08             	mov    %esi,0x8(%ebp)
  800f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f46:	e9 93 fd ff ff       	jmp    800cde <vprintfmt+0x30>
	if (lflag >= 2)
  800f4b:	83 fa 01             	cmp    $0x1,%edx
  800f4e:	7e 16                	jle    800f66 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800f50:	8b 45 14             	mov    0x14(%ebp),%eax
  800f53:	8d 50 08             	lea    0x8(%eax),%edx
  800f56:	89 55 14             	mov    %edx,0x14(%ebp)
  800f59:	8b 50 04             	mov    0x4(%eax),%edx
  800f5c:	8b 00                	mov    (%eax),%eax
  800f5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f61:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f64:	eb 32                	jmp    800f98 <vprintfmt+0x2ea>
	else if (lflag)
  800f66:	85 d2                	test   %edx,%edx
  800f68:	74 18                	je     800f82 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  800f6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f6d:	8d 50 04             	lea    0x4(%eax),%edx
  800f70:	89 55 14             	mov    %edx,0x14(%ebp)
  800f73:	8b 30                	mov    (%eax),%esi
  800f75:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800f78:	89 f0                	mov    %esi,%eax
  800f7a:	c1 f8 1f             	sar    $0x1f,%eax
  800f7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f80:	eb 16                	jmp    800f98 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800f82:	8b 45 14             	mov    0x14(%ebp),%eax
  800f85:	8d 50 04             	lea    0x4(%eax),%edx
  800f88:	89 55 14             	mov    %edx,0x14(%ebp)
  800f8b:	8b 30                	mov    (%eax),%esi
  800f8d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800f90:	89 f0                	mov    %esi,%eax
  800f92:	c1 f8 1f             	sar    $0x1f,%eax
  800f95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800f98:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  800f9e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800fa3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fa7:	0f 89 80 00 00 00    	jns    80102d <vprintfmt+0x37f>
				putch('-', putdat);
  800fad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fb1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800fb8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800fbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fbe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fc1:	f7 d8                	neg    %eax
  800fc3:	83 d2 00             	adc    $0x0,%edx
  800fc6:	f7 da                	neg    %edx
			base = 10;
  800fc8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800fcd:	eb 5e                	jmp    80102d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800fcf:	8d 45 14             	lea    0x14(%ebp),%eax
  800fd2:	e8 58 fc ff ff       	call   800c2f <getuint>
			base = 10;
  800fd7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800fdc:	eb 4f                	jmp    80102d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800fde:	8d 45 14             	lea    0x14(%ebp),%eax
  800fe1:	e8 49 fc ff ff       	call   800c2f <getuint>
            base = 8;
  800fe6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  800feb:	eb 40                	jmp    80102d <vprintfmt+0x37f>
			putch('0', putdat);
  800fed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ff1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ff8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800ffb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fff:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801006:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  801009:	8b 45 14             	mov    0x14(%ebp),%eax
  80100c:	8d 50 04             	lea    0x4(%eax),%edx
  80100f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801012:	8b 00                	mov    (%eax),%eax
  801014:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  801019:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80101e:	eb 0d                	jmp    80102d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  801020:	8d 45 14             	lea    0x14(%ebp),%eax
  801023:	e8 07 fc ff ff       	call   800c2f <getuint>
			base = 16;
  801028:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80102d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801031:	89 74 24 10          	mov    %esi,0x10(%esp)
  801035:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801038:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80103c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801040:	89 04 24             	mov    %eax,(%esp)
  801043:	89 54 24 04          	mov    %edx,0x4(%esp)
  801047:	89 fa                	mov    %edi,%edx
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
  80104c:	e8 ef fa ff ff       	call   800b40 <printnum>
			break;
  801051:	e9 88 fc ff ff       	jmp    800cde <vprintfmt+0x30>
			putch(ch, putdat);
  801056:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80105a:	89 04 24             	mov    %eax,(%esp)
  80105d:	ff 55 08             	call   *0x8(%ebp)
			break;
  801060:	e9 79 fc ff ff       	jmp    800cde <vprintfmt+0x30>
			putch('%', putdat);
  801065:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801069:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801070:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801073:	89 f3                	mov    %esi,%ebx
  801075:	eb 03                	jmp    80107a <vprintfmt+0x3cc>
  801077:	83 eb 01             	sub    $0x1,%ebx
  80107a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80107e:	75 f7                	jne    801077 <vprintfmt+0x3c9>
  801080:	e9 59 fc ff ff       	jmp    800cde <vprintfmt+0x30>
}
  801085:	83 c4 3c             	add    $0x3c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	83 ec 28             	sub    $0x28,%esp
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801099:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80109c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8010a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	74 30                	je     8010de <vsnprintf+0x51>
  8010ae:	85 d2                	test   %edx,%edx
  8010b0:	7e 2c                	jle    8010de <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8010b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8010b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8010c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c7:	c7 04 24 69 0c 80 00 	movl   $0x800c69,(%esp)
  8010ce:	e8 db fb ff ff       	call   800cae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8010d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8010d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010dc:	eb 05                	jmp    8010e3 <vsnprintf+0x56>
		return -E_INVAL;
  8010de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010e3:	c9                   	leave  
  8010e4:	c3                   	ret    

008010e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8010eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8010ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	89 04 24             	mov    %eax,(%esp)
  801106:	e8 82 ff ff ff       	call   80108d <vsnprintf>
	va_end(ap);

	return rc;
}
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    
  80110d:	66 90                	xchg   %ax,%ax
  80110f:	90                   	nop

00801110 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	57                   	push   %edi
  801114:	56                   	push   %esi
  801115:	53                   	push   %ebx
  801116:	83 ec 1c             	sub    $0x1c,%esp
  801119:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80111c:	85 c0                	test   %eax,%eax
  80111e:	74 18                	je     801138 <readline+0x28>
		fprintf(1, "%s", prompt);
  801120:	89 44 24 08          	mov    %eax,0x8(%esp)
  801124:	c7 44 24 04 6d 36 80 	movl   $0x80366d,0x4(%esp)
  80112b:	00 
  80112c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801133:	e8 48 15 00 00       	call   802680 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  801138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80113f:	e8 f8 f7 ff ff       	call   80093c <iscons>
  801144:	89 c7                	mov    %eax,%edi
	i = 0;
  801146:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
  80114b:	e8 b6 f7 ff ff       	call   800906 <getchar>
  801150:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801152:	85 c0                	test   %eax,%eax
  801154:	79 25                	jns    80117b <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801156:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  80115b:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80115e:	0f 84 88 00 00 00    	je     8011ec <readline+0xdc>
				cprintf("read error: %e\n", c);
  801164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801168:	c7 04 24 3f 3a 80 00 	movl   $0x803a3f,(%esp)
  80116f:	e8 ac f9 ff ff       	call   800b20 <cprintf>
			return NULL;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
  801179:	eb 71                	jmp    8011ec <readline+0xdc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80117b:	83 f8 7f             	cmp    $0x7f,%eax
  80117e:	74 05                	je     801185 <readline+0x75>
  801180:	83 f8 08             	cmp    $0x8,%eax
  801183:	75 19                	jne    80119e <readline+0x8e>
  801185:	85 f6                	test   %esi,%esi
  801187:	7e 15                	jle    80119e <readline+0x8e>
			if (echoing)
  801189:	85 ff                	test   %edi,%edi
  80118b:	74 0c                	je     801199 <readline+0x89>
				cputchar('\b');
  80118d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801194:	e8 4c f7 ff ff       	call   8008e5 <cputchar>
			i--;
  801199:	83 ee 01             	sub    $0x1,%esi
  80119c:	eb ad                	jmp    80114b <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80119e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8011a4:	7f 1c                	jg     8011c2 <readline+0xb2>
  8011a6:	83 fb 1f             	cmp    $0x1f,%ebx
  8011a9:	7e 17                	jle    8011c2 <readline+0xb2>
			if (echoing)
  8011ab:	85 ff                	test   %edi,%edi
  8011ad:	74 08                	je     8011b7 <readline+0xa7>
				cputchar(c);
  8011af:	89 1c 24             	mov    %ebx,(%esp)
  8011b2:	e8 2e f7 ff ff       	call   8008e5 <cputchar>
			buf[i++] = c;
  8011b7:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8011bd:	8d 76 01             	lea    0x1(%esi),%esi
  8011c0:	eb 89                	jmp    80114b <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  8011c2:	83 fb 0d             	cmp    $0xd,%ebx
  8011c5:	74 09                	je     8011d0 <readline+0xc0>
  8011c7:	83 fb 0a             	cmp    $0xa,%ebx
  8011ca:	0f 85 7b ff ff ff    	jne    80114b <readline+0x3b>
			if (echoing)
  8011d0:	85 ff                	test   %edi,%edi
  8011d2:	74 0c                	je     8011e0 <readline+0xd0>
				cputchar('\n');
  8011d4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8011db:	e8 05 f7 ff ff       	call   8008e5 <cputchar>
			buf[i] = 0;
  8011e0:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  8011e7:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  8011ec:	83 c4 1c             	add    $0x1c,%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5f                   	pop    %edi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    
  8011f4:	66 90                	xchg   %ax,%ax
  8011f6:	66 90                	xchg   %ax,%ax
  8011f8:	66 90                	xchg   %ax,%ax
  8011fa:	66 90                	xchg   %ax,%ax
  8011fc:	66 90                	xchg   %ax,%ax
  8011fe:	66 90                	xchg   %ax,%ax

00801200 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801206:	b8 00 00 00 00       	mov    $0x0,%eax
  80120b:	eb 03                	jmp    801210 <strlen+0x10>
		n++;
  80120d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801210:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801214:	75 f7                	jne    80120d <strlen+0xd>
	return n;
}
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801221:	b8 00 00 00 00       	mov    $0x0,%eax
  801226:	eb 03                	jmp    80122b <strnlen+0x13>
		n++;
  801228:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80122b:	39 d0                	cmp    %edx,%eax
  80122d:	74 06                	je     801235 <strnlen+0x1d>
  80122f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801233:	75 f3                	jne    801228 <strnlen+0x10>
	return n;
}
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	53                   	push   %ebx
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
  80123e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801241:	89 c2                	mov    %eax,%edx
  801243:	83 c2 01             	add    $0x1,%edx
  801246:	83 c1 01             	add    $0x1,%ecx
  801249:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80124d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801250:	84 db                	test   %bl,%bl
  801252:	75 ef                	jne    801243 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801254:	5b                   	pop    %ebx
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	53                   	push   %ebx
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801261:	89 1c 24             	mov    %ebx,(%esp)
  801264:	e8 97 ff ff ff       	call   801200 <strlen>
	strcpy(dst + len, src);
  801269:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801270:	01 d8                	add    %ebx,%eax
  801272:	89 04 24             	mov    %eax,(%esp)
  801275:	e8 bd ff ff ff       	call   801237 <strcpy>
	return dst;
}
  80127a:	89 d8                	mov    %ebx,%eax
  80127c:	83 c4 08             	add    $0x8,%esp
  80127f:	5b                   	pop    %ebx
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	8b 75 08             	mov    0x8(%ebp),%esi
  80128a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128d:	89 f3                	mov    %esi,%ebx
  80128f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801292:	89 f2                	mov    %esi,%edx
  801294:	eb 0f                	jmp    8012a5 <strncpy+0x23>
		*dst++ = *src;
  801296:	83 c2 01             	add    $0x1,%edx
  801299:	0f b6 01             	movzbl (%ecx),%eax
  80129c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80129f:	80 39 01             	cmpb   $0x1,(%ecx)
  8012a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8012a5:	39 da                	cmp    %ebx,%edx
  8012a7:	75 ed                	jne    801296 <strncpy+0x14>
	}
	return ret;
}
  8012a9:	89 f0                	mov    %esi,%eax
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012bd:	89 f0                	mov    %esi,%eax
  8012bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8012c3:	85 c9                	test   %ecx,%ecx
  8012c5:	75 0b                	jne    8012d2 <strlcpy+0x23>
  8012c7:	eb 1d                	jmp    8012e6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8012c9:	83 c0 01             	add    $0x1,%eax
  8012cc:	83 c2 01             	add    $0x1,%edx
  8012cf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8012d2:	39 d8                	cmp    %ebx,%eax
  8012d4:	74 0b                	je     8012e1 <strlcpy+0x32>
  8012d6:	0f b6 0a             	movzbl (%edx),%ecx
  8012d9:	84 c9                	test   %cl,%cl
  8012db:	75 ec                	jne    8012c9 <strlcpy+0x1a>
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	eb 02                	jmp    8012e3 <strlcpy+0x34>
  8012e1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  8012e3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8012e6:	29 f0                	sub    %esi,%eax
}
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012f5:	eb 06                	jmp    8012fd <strcmp+0x11>
		p++, q++;
  8012f7:	83 c1 01             	add    $0x1,%ecx
  8012fa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8012fd:	0f b6 01             	movzbl (%ecx),%eax
  801300:	84 c0                	test   %al,%al
  801302:	74 04                	je     801308 <strcmp+0x1c>
  801304:	3a 02                	cmp    (%edx),%al
  801306:	74 ef                	je     8012f7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801308:	0f b6 c0             	movzbl %al,%eax
  80130b:	0f b6 12             	movzbl (%edx),%edx
  80130e:	29 d0                	sub    %edx,%eax
}
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    

00801312 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	53                   	push   %ebx
  801316:	8b 45 08             	mov    0x8(%ebp),%eax
  801319:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131c:	89 c3                	mov    %eax,%ebx
  80131e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801321:	eb 06                	jmp    801329 <strncmp+0x17>
		n--, p++, q++;
  801323:	83 c0 01             	add    $0x1,%eax
  801326:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801329:	39 d8                	cmp    %ebx,%eax
  80132b:	74 15                	je     801342 <strncmp+0x30>
  80132d:	0f b6 08             	movzbl (%eax),%ecx
  801330:	84 c9                	test   %cl,%cl
  801332:	74 04                	je     801338 <strncmp+0x26>
  801334:	3a 0a                	cmp    (%edx),%cl
  801336:	74 eb                	je     801323 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801338:	0f b6 00             	movzbl (%eax),%eax
  80133b:	0f b6 12             	movzbl (%edx),%edx
  80133e:	29 d0                	sub    %edx,%eax
  801340:	eb 05                	jmp    801347 <strncmp+0x35>
		return 0;
  801342:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801347:	5b                   	pop    %ebx
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	8b 45 08             	mov    0x8(%ebp),%eax
  801350:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801354:	eb 07                	jmp    80135d <strchr+0x13>
		if (*s == c)
  801356:	38 ca                	cmp    %cl,%dl
  801358:	74 0f                	je     801369 <strchr+0x1f>
	for (; *s; s++)
  80135a:	83 c0 01             	add    $0x1,%eax
  80135d:	0f b6 10             	movzbl (%eax),%edx
  801360:	84 d2                	test   %dl,%dl
  801362:	75 f2                	jne    801356 <strchr+0xc>
			return (char *) s;
	return 0;
  801364:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801375:	eb 07                	jmp    80137e <strfind+0x13>
		if (*s == c)
  801377:	38 ca                	cmp    %cl,%dl
  801379:	74 0a                	je     801385 <strfind+0x1a>
	for (; *s; s++)
  80137b:	83 c0 01             	add    $0x1,%eax
  80137e:	0f b6 10             	movzbl (%eax),%edx
  801381:	84 d2                	test   %dl,%dl
  801383:	75 f2                	jne    801377 <strfind+0xc>
			break;
	return (char *) s;
}
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	57                   	push   %edi
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801390:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801393:	85 c9                	test   %ecx,%ecx
  801395:	74 36                	je     8013cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801397:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80139d:	75 28                	jne    8013c7 <memset+0x40>
  80139f:	f6 c1 03             	test   $0x3,%cl
  8013a2:	75 23                	jne    8013c7 <memset+0x40>
		c &= 0xFF;
  8013a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8013a8:	89 d3                	mov    %edx,%ebx
  8013aa:	c1 e3 08             	shl    $0x8,%ebx
  8013ad:	89 d6                	mov    %edx,%esi
  8013af:	c1 e6 18             	shl    $0x18,%esi
  8013b2:	89 d0                	mov    %edx,%eax
  8013b4:	c1 e0 10             	shl    $0x10,%eax
  8013b7:	09 f0                	or     %esi,%eax
  8013b9:	09 c2                	or     %eax,%edx
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8013bf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8013c2:	fc                   	cld    
  8013c3:	f3 ab                	rep stos %eax,%es:(%edi)
  8013c5:	eb 06                	jmp    8013cd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8013c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ca:	fc                   	cld    
  8013cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013cd:	89 f8                	mov    %edi,%eax
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	57                   	push   %edi
  8013d8:	56                   	push   %esi
  8013d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013e2:	39 c6                	cmp    %eax,%esi
  8013e4:	73 35                	jae    80141b <memmove+0x47>
  8013e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013e9:	39 d0                	cmp    %edx,%eax
  8013eb:	73 2e                	jae    80141b <memmove+0x47>
		s += n;
		d += n;
  8013ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8013f0:	89 d6                	mov    %edx,%esi
  8013f2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013fa:	75 13                	jne    80140f <memmove+0x3b>
  8013fc:	f6 c1 03             	test   $0x3,%cl
  8013ff:	75 0e                	jne    80140f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801401:	83 ef 04             	sub    $0x4,%edi
  801404:	8d 72 fc             	lea    -0x4(%edx),%esi
  801407:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80140a:	fd                   	std    
  80140b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80140d:	eb 09                	jmp    801418 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80140f:	83 ef 01             	sub    $0x1,%edi
  801412:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801415:	fd                   	std    
  801416:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801418:	fc                   	cld    
  801419:	eb 1d                	jmp    801438 <memmove+0x64>
  80141b:	89 f2                	mov    %esi,%edx
  80141d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80141f:	f6 c2 03             	test   $0x3,%dl
  801422:	75 0f                	jne    801433 <memmove+0x5f>
  801424:	f6 c1 03             	test   $0x3,%cl
  801427:	75 0a                	jne    801433 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801429:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80142c:	89 c7                	mov    %eax,%edi
  80142e:	fc                   	cld    
  80142f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801431:	eb 05                	jmp    801438 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801433:	89 c7                	mov    %eax,%edi
  801435:	fc                   	cld    
  801436:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801438:	5e                   	pop    %esi
  801439:	5f                   	pop    %edi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801442:	8b 45 10             	mov    0x10(%ebp),%eax
  801445:	89 44 24 08          	mov    %eax,0x8(%esp)
  801449:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801450:	8b 45 08             	mov    0x8(%ebp),%eax
  801453:	89 04 24             	mov    %eax,(%esp)
  801456:	e8 79 ff ff ff       	call   8013d4 <memmove>
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	56                   	push   %esi
  801461:	53                   	push   %ebx
  801462:	8b 55 08             	mov    0x8(%ebp),%edx
  801465:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801468:	89 d6                	mov    %edx,%esi
  80146a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80146d:	eb 1a                	jmp    801489 <memcmp+0x2c>
		if (*s1 != *s2)
  80146f:	0f b6 02             	movzbl (%edx),%eax
  801472:	0f b6 19             	movzbl (%ecx),%ebx
  801475:	38 d8                	cmp    %bl,%al
  801477:	74 0a                	je     801483 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801479:	0f b6 c0             	movzbl %al,%eax
  80147c:	0f b6 db             	movzbl %bl,%ebx
  80147f:	29 d8                	sub    %ebx,%eax
  801481:	eb 0f                	jmp    801492 <memcmp+0x35>
		s1++, s2++;
  801483:	83 c2 01             	add    $0x1,%edx
  801486:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  801489:	39 f2                	cmp    %esi,%edx
  80148b:	75 e2                	jne    80146f <memcmp+0x12>
	}

	return 0;
  80148d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801492:	5b                   	pop    %ebx
  801493:	5e                   	pop    %esi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    

00801496 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8014a4:	eb 07                	jmp    8014ad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014a6:	38 08                	cmp    %cl,(%eax)
  8014a8:	74 07                	je     8014b1 <memfind+0x1b>
	for (; s < ends; s++)
  8014aa:	83 c0 01             	add    $0x1,%eax
  8014ad:	39 d0                	cmp    %edx,%eax
  8014af:	72 f5                	jb     8014a6 <memfind+0x10>
			break;
	return (void *) s;
}
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	57                   	push   %edi
  8014b7:	56                   	push   %esi
  8014b8:	53                   	push   %ebx
  8014b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014bf:	eb 03                	jmp    8014c4 <strtol+0x11>
		s++;
  8014c1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8014c4:	0f b6 0a             	movzbl (%edx),%ecx
  8014c7:	80 f9 09             	cmp    $0x9,%cl
  8014ca:	74 f5                	je     8014c1 <strtol+0xe>
  8014cc:	80 f9 20             	cmp    $0x20,%cl
  8014cf:	74 f0                	je     8014c1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8014d1:	80 f9 2b             	cmp    $0x2b,%cl
  8014d4:	75 0a                	jne    8014e0 <strtol+0x2d>
		s++;
  8014d6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8014d9:	bf 00 00 00 00       	mov    $0x0,%edi
  8014de:	eb 11                	jmp    8014f1 <strtol+0x3e>
  8014e0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  8014e5:	80 f9 2d             	cmp    $0x2d,%cl
  8014e8:	75 07                	jne    8014f1 <strtol+0x3e>
		s++, neg = 1;
  8014ea:	8d 52 01             	lea    0x1(%edx),%edx
  8014ed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014f1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  8014f6:	75 15                	jne    80150d <strtol+0x5a>
  8014f8:	80 3a 30             	cmpb   $0x30,(%edx)
  8014fb:	75 10                	jne    80150d <strtol+0x5a>
  8014fd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801501:	75 0a                	jne    80150d <strtol+0x5a>
		s += 2, base = 16;
  801503:	83 c2 02             	add    $0x2,%edx
  801506:	b8 10 00 00 00       	mov    $0x10,%eax
  80150b:	eb 10                	jmp    80151d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80150d:	85 c0                	test   %eax,%eax
  80150f:	75 0c                	jne    80151d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801511:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801513:	80 3a 30             	cmpb   $0x30,(%edx)
  801516:	75 05                	jne    80151d <strtol+0x6a>
		s++, base = 8;
  801518:	83 c2 01             	add    $0x1,%edx
  80151b:	b0 08                	mov    $0x8,%al
		base = 10;
  80151d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801522:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801525:	0f b6 0a             	movzbl (%edx),%ecx
  801528:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80152b:	89 f0                	mov    %esi,%eax
  80152d:	3c 09                	cmp    $0x9,%al
  80152f:	77 08                	ja     801539 <strtol+0x86>
			dig = *s - '0';
  801531:	0f be c9             	movsbl %cl,%ecx
  801534:	83 e9 30             	sub    $0x30,%ecx
  801537:	eb 20                	jmp    801559 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801539:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80153c:	89 f0                	mov    %esi,%eax
  80153e:	3c 19                	cmp    $0x19,%al
  801540:	77 08                	ja     80154a <strtol+0x97>
			dig = *s - 'a' + 10;
  801542:	0f be c9             	movsbl %cl,%ecx
  801545:	83 e9 57             	sub    $0x57,%ecx
  801548:	eb 0f                	jmp    801559 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80154a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80154d:	89 f0                	mov    %esi,%eax
  80154f:	3c 19                	cmp    $0x19,%al
  801551:	77 16                	ja     801569 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801553:	0f be c9             	movsbl %cl,%ecx
  801556:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801559:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80155c:	7d 0f                	jge    80156d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80155e:	83 c2 01             	add    $0x1,%edx
  801561:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801565:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801567:	eb bc                	jmp    801525 <strtol+0x72>
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	eb 02                	jmp    80156f <strtol+0xbc>
  80156d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80156f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801573:	74 05                	je     80157a <strtol+0xc7>
		*endptr = (char *) s;
  801575:	8b 75 0c             	mov    0xc(%ebp),%esi
  801578:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80157a:	f7 d8                	neg    %eax
  80157c:	85 ff                	test   %edi,%edi
  80157e:	0f 44 c3             	cmove  %ebx,%eax
}
  801581:	5b                   	pop    %ebx
  801582:	5e                   	pop    %esi
  801583:	5f                   	pop    %edi
  801584:	5d                   	pop    %ebp
  801585:	c3                   	ret    

00801586 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	57                   	push   %edi
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80158c:	b8 00 00 00 00       	mov    $0x0,%eax
  801591:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801594:	8b 55 08             	mov    0x8(%ebp),%edx
  801597:	89 c3                	mov    %eax,%ebx
  801599:	89 c7                	mov    %eax,%edi
  80159b:	89 c6                	mov    %eax,%esi
  80159d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80159f:	5b                   	pop    %ebx
  8015a0:	5e                   	pop    %esi
  8015a1:	5f                   	pop    %edi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	57                   	push   %edi
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015af:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b4:	89 d1                	mov    %edx,%ecx
  8015b6:	89 d3                	mov    %edx,%ebx
  8015b8:	89 d7                	mov    %edx,%edi
  8015ba:	89 d6                	mov    %edx,%esi
  8015bc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5f                   	pop    %edi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	57                   	push   %edi
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8015cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d1:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d9:	89 cb                	mov    %ecx,%ebx
  8015db:	89 cf                	mov    %ecx,%edi
  8015dd:	89 ce                	mov    %ecx,%esi
  8015df:	cd 30                	int    $0x30
	if(check && ret > 0)
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	7e 28                	jle    80160d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8015f0:	00 
  8015f1:	c7 44 24 08 4f 3a 80 	movl   $0x803a4f,0x8(%esp)
  8015f8:	00 
  8015f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801600:	00 
  801601:	c7 04 24 6c 3a 80 00 	movl   $0x803a6c,(%esp)
  801608:	e8 1a f4 ff ff       	call   800a27 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80160d:	83 c4 2c             	add    $0x2c,%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5f                   	pop    %edi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	57                   	push   %edi
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80161b:	ba 00 00 00 00       	mov    $0x0,%edx
  801620:	b8 02 00 00 00       	mov    $0x2,%eax
  801625:	89 d1                	mov    %edx,%ecx
  801627:	89 d3                	mov    %edx,%ebx
  801629:	89 d7                	mov    %edx,%edi
  80162b:	89 d6                	mov    %edx,%esi
  80162d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80162f:	5b                   	pop    %ebx
  801630:	5e                   	pop    %esi
  801631:	5f                   	pop    %edi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    

00801634 <sys_yield>:

void
sys_yield(void)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	57                   	push   %edi
  801638:	56                   	push   %esi
  801639:	53                   	push   %ebx
	asm volatile("int %1\n"
  80163a:	ba 00 00 00 00       	mov    $0x0,%edx
  80163f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801644:	89 d1                	mov    %edx,%ecx
  801646:	89 d3                	mov    %edx,%ebx
  801648:	89 d7                	mov    %edx,%edi
  80164a:	89 d6                	mov    %edx,%esi
  80164c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5f                   	pop    %edi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	57                   	push   %edi
  801657:	56                   	push   %esi
  801658:	53                   	push   %ebx
  801659:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80165c:	be 00 00 00 00       	mov    $0x0,%esi
  801661:	b8 04 00 00 00       	mov    $0x4,%eax
  801666:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801669:	8b 55 08             	mov    0x8(%ebp),%edx
  80166c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80166f:	89 f7                	mov    %esi,%edi
  801671:	cd 30                	int    $0x30
	if(check && ret > 0)
  801673:	85 c0                	test   %eax,%eax
  801675:	7e 28                	jle    80169f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801677:	89 44 24 10          	mov    %eax,0x10(%esp)
  80167b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801682:	00 
  801683:	c7 44 24 08 4f 3a 80 	movl   $0x803a4f,0x8(%esp)
  80168a:	00 
  80168b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801692:	00 
  801693:	c7 04 24 6c 3a 80 00 	movl   $0x803a6c,(%esp)
  80169a:	e8 88 f3 ff ff       	call   800a27 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80169f:	83 c4 2c             	add    $0x2c,%esp
  8016a2:	5b                   	pop    %ebx
  8016a3:	5e                   	pop    %esi
  8016a4:	5f                   	pop    %edi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	57                   	push   %edi
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8016b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016c1:	8b 75 18             	mov    0x18(%ebp),%esi
  8016c4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	7e 28                	jle    8016f2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8016d5:	00 
  8016d6:	c7 44 24 08 4f 3a 80 	movl   $0x803a4f,0x8(%esp)
  8016dd:	00 
  8016de:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016e5:	00 
  8016e6:	c7 04 24 6c 3a 80 00 	movl   $0x803a6c,(%esp)
  8016ed:	e8 35 f3 ff ff       	call   800a27 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8016f2:	83 c4 2c             	add    $0x2c,%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801703:	bb 00 00 00 00       	mov    $0x0,%ebx
  801708:	b8 06 00 00 00       	mov    $0x6,%eax
  80170d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801710:	8b 55 08             	mov    0x8(%ebp),%edx
  801713:	89 df                	mov    %ebx,%edi
  801715:	89 de                	mov    %ebx,%esi
  801717:	cd 30                	int    $0x30
	if(check && ret > 0)
  801719:	85 c0                	test   %eax,%eax
  80171b:	7e 28                	jle    801745 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80171d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801721:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801728:	00 
  801729:	c7 44 24 08 4f 3a 80 	movl   $0x803a4f,0x8(%esp)
  801730:	00 
  801731:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801738:	00 
  801739:	c7 04 24 6c 3a 80 00 	movl   $0x803a6c,(%esp)
  801740:	e8 e2 f2 ff ff       	call   800a27 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801745:	83 c4 2c             	add    $0x2c,%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5f                   	pop    %edi
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    

0080174d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	57                   	push   %edi
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801756:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175b:	b8 08 00 00 00       	mov    $0x8,%eax
  801760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801763:	8b 55 08             	mov    0x8(%ebp),%edx
  801766:	89 df                	mov    %ebx,%edi
  801768:	89 de                	mov    %ebx,%esi
  80176a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80176c:	85 c0                	test   %eax,%eax
  80176e:	7e 28                	jle    801798 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801770:	89 44 24 10          	mov    %eax,0x10(%esp)
  801774:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80177b:	00 
  80177c:	c7 44 24 08 4f 3a 80 	movl   $0x803a4f,0x8(%esp)
  801783:	00 
  801784:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80178b:	00 
  80178c:	c7 04 24 6c 3a 80 00 	movl   $0x803a6c,(%esp)
  801793:	e8 8f f2 ff ff       	call   800a27 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801798:	83 c4 2c             	add    $0x2c,%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5f                   	pop    %edi
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	57                   	push   %edi
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8017a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8017b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b9:	89 df                	mov    %ebx,%edi
  8017bb:	89 de                	mov    %ebx,%esi
  8017bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	7e 28                	jle    8017eb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017c7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8017ce:	00 
  8017cf:	c7 44 24 08 4f 3a 80 	movl   $0x803a4f,0x8(%esp)
  8017d6:	00 
  8017d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017de:	00 
  8017df:	c7 04 24 6c 3a 80 00 	movl   $0x803a6c,(%esp)
  8017e6:	e8 3c f2 ff ff       	call   800a27 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8017eb:	83 c4 2c             	add    $0x2c,%esp
  8017ee:	5b                   	pop    %ebx
  8017ef:	5e                   	pop    %esi
  8017f0:	5f                   	pop    %edi
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	57                   	push   %edi
  8017f7:	56                   	push   %esi
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8017fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801801:	b8 0a 00 00 00       	mov    $0xa,%eax
  801806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801809:	8b 55 08             	mov    0x8(%ebp),%edx
  80180c:	89 df                	mov    %ebx,%edi
  80180e:	89 de                	mov    %ebx,%esi
  801810:	cd 30                	int    $0x30
	if(check && ret > 0)
  801812:	85 c0                	test   %eax,%eax
  801814:	7e 28                	jle    80183e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801816:	89 44 24 10          	mov    %eax,0x10(%esp)
  80181a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801821:	00 
  801822:	c7 44 24 08 4f 3a 80 	movl   $0x803a4f,0x8(%esp)
  801829:	00 
  80182a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801831:	00 
  801832:	c7 04 24 6c 3a 80 00 	movl   $0x803a6c,(%esp)
  801839:	e8 e9 f1 ff ff       	call   800a27 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80183e:	83 c4 2c             	add    $0x2c,%esp
  801841:	5b                   	pop    %ebx
  801842:	5e                   	pop    %esi
  801843:	5f                   	pop    %edi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	57                   	push   %edi
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80184c:	be 00 00 00 00       	mov    $0x0,%esi
  801851:	b8 0c 00 00 00       	mov    $0xc,%eax
  801856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801859:	8b 55 08             	mov    0x8(%ebp),%edx
  80185c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80185f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801862:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801864:	5b                   	pop    %ebx
  801865:	5e                   	pop    %esi
  801866:	5f                   	pop    %edi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	57                   	push   %edi
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801872:	b9 00 00 00 00       	mov    $0x0,%ecx
  801877:	b8 0d 00 00 00       	mov    $0xd,%eax
  80187c:	8b 55 08             	mov    0x8(%ebp),%edx
  80187f:	89 cb                	mov    %ecx,%ebx
  801881:	89 cf                	mov    %ecx,%edi
  801883:	89 ce                	mov    %ecx,%esi
  801885:	cd 30                	int    $0x30
	if(check && ret > 0)
  801887:	85 c0                	test   %eax,%eax
  801889:	7e 28                	jle    8018b3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80188b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80188f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801896:	00 
  801897:	c7 44 24 08 4f 3a 80 	movl   $0x803a4f,0x8(%esp)
  80189e:	00 
  80189f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8018a6:	00 
  8018a7:	c7 04 24 6c 3a 80 00 	movl   $0x803a6c,(%esp)
  8018ae:	e8 74 f1 ff ff       	call   800a27 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8018b3:	83 c4 2c             	add    $0x2c,%esp
  8018b6:	5b                   	pop    %ebx
  8018b7:	5e                   	pop    %esi
  8018b8:	5f                   	pop    %edi
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    
  8018bb:	66 90                	xchg   %ax,%ax
  8018bd:	66 90                	xchg   %ax,%ax
  8018bf:	90                   	nop

008018c0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 24             	sub    $0x24,%esp
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax

	void *addr = (void *) utf->utf_fault_va;
  8018ca:	8b 18                	mov    (%eax),%ebx
    //          fec_pr page fault by protection violation
    //          fec_wr by write
    //          fec_u by user mode
    //Let's think about this, what do we need to access? Reminder that the fork happens from the USER SPACE
    //User space... Maybe the UPVT? (User virtual page table). memlayout has some infomation about it.
    if( !(err & FEC_WR) || (uvpt[PGNUM(addr)] & (perm | PTE_COW)) != (perm | PTE_COW) ){
  8018cc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8018d0:	74 18                	je     8018ea <pgfault+0x2a>
  8018d2:	89 d8                	mov    %ebx,%eax
  8018d4:	c1 e8 0c             	shr    $0xc,%eax
  8018d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018de:	25 05 08 00 00       	and    $0x805,%eax
  8018e3:	3d 05 08 00 00       	cmp    $0x805,%eax
  8018e8:	74 1c                	je     801906 <pgfault+0x46>
        panic("pgfault error: Incorrect permissions OR FEC_WR");
  8018ea:	c7 44 24 08 7c 3a 80 	movl   $0x803a7c,0x8(%esp)
  8018f1:	00 
  8018f2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8018f9:	00 
  8018fa:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  801901:	e8 21 f1 ff ff       	call   800a27 <_panic>
	// Hint:
	//   You should make three system calls.
    //   Let's think, since this is a PAGE FAULT, we probably have a pre-existing page. This
    //   is the "old page" that's referenced, the "Va" has this address written.
    //   BUG FOUND: MAKE SURE ADDR IS PAGE ALIGNED.
    r = sys_page_alloc(0, (void *)PFTEMP, (perm | PTE_W));
  801906:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80190d:	00 
  80190e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801915:	00 
  801916:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191d:	e8 31 fd ff ff       	call   801653 <sys_page_alloc>
	if(r < 0){
  801922:	85 c0                	test   %eax,%eax
  801924:	79 1c                	jns    801942 <pgfault+0x82>
        panic("Pgfault error: syscall for page alloc has failed");
  801926:	c7 44 24 08 ac 3a 80 	movl   $0x803aac,0x8(%esp)
  80192d:	00 
  80192e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801935:	00 
  801936:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  80193d:	e8 e5 f0 ff ff       	call   800a27 <_panic>
    }
    // memcpy format: memccpy(dest, src, size)
    memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801942:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801948:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80194f:	00 
  801950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801954:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80195b:	e8 dc fa ff ff       	call   80143c <memcpy>
    // Copy, so memcpy probably. Maybe there's a page copy in our functions? I didn't write one.
    // Okay, so we HAVE the new page, we need to map it now to PFTEMP (note that PG_alloc does not map it)
    // map:(source env, source va, destination env, destination va, perms)
    r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), perm | PTE_W);
  801960:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801967:	00 
  801968:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80196c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801973:	00 
  801974:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80197b:	00 
  80197c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801983:	e8 1f fd ff ff       	call   8016a7 <sys_page_map>
    // Think about the above, notice that we're putting it into the SAME ENV.
    // Really make note of this.
    if(r < 0){
  801988:	85 c0                	test   %eax,%eax
  80198a:	79 1c                	jns    8019a8 <pgfault+0xe8>
        panic("Pgfault error: map bad");
  80198c:	c7 44 24 08 78 3b 80 	movl   $0x803b78,0x8(%esp)
  801993:	00 
  801994:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80199b:	00 
  80199c:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  8019a3:	e8 7f f0 ff ff       	call   800a27 <_panic>
    }
    // So we've used our temp, make sure we free the location now.
    r = sys_page_unmap(0, (void *)PFTEMP);
  8019a8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8019af:	00 
  8019b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b7:	e8 3e fd ff ff       	call   8016fa <sys_page_unmap>
    if(r < 0){
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	79 1c                	jns    8019dc <pgfault+0x11c>
        panic("Pgfault error: unmap bad");
  8019c0:	c7 44 24 08 8f 3b 80 	movl   $0x803b8f,0x8(%esp)
  8019c7:	00 
  8019c8:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8019cf:	00 
  8019d0:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  8019d7:	e8 4b f0 ff ff       	call   800a27 <_panic>
    }
    // LAB 4
}
  8019dc:	83 c4 24             	add    $0x24,%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	57                   	push   %edi
  8019e6:	56                   	push   %esi
  8019e7:	53                   	push   %ebx
  8019e8:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
    envid_t child;
    int r;
    uint32_t va;

    set_pgfault_handler(pgfault); // What goes in here?
  8019eb:	c7 04 24 c0 18 80 00 	movl   $0x8018c0,(%esp)
  8019f2:	e8 73 16 00 00       	call   80306a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8019f7:	b8 07 00 00 00       	mov    $0x7,%eax
  8019fc:	cd 30                	int    $0x30
  8019fe:	89 c7                	mov    %eax,%edi
  801a00:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    // Fix "thisenv", this probably means the whole PID thing that happens.
    // Luckily, we have sys_exo fork to create our new environment.
    child = sys_exofork();
    if(child < 0){
  801a03:	85 c0                	test   %eax,%eax
  801a05:	79 1c                	jns    801a23 <fork+0x41>
        panic("fork: Error on sys_exofork()");
  801a07:	c7 44 24 08 a8 3b 80 	movl   $0x803ba8,0x8(%esp)
  801a0e:	00 
  801a0f:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801a16:	00 
  801a17:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  801a1e:	e8 04 f0 ff ff       	call   800a27 <_panic>
    }
    if(child == 0){
  801a23:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	75 21                	jne    801a4d <fork+0x6b>
        thisenv = &envs[ENVX(sys_getenvid())]; // Remember that whole bit about the pid? That goes here.
  801a2c:	e8 e4 fb ff ff       	call   801615 <sys_getenvid>
  801a31:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a36:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a39:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a3e:	a3 24 54 80 00       	mov    %eax,0x805424
        // It's a whole lot like lab3 with the env stuff
        return 0;
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
  801a48:	e9 67 01 00 00       	jmp    801bb4 <fork+0x1d2>
    */

    // Reminder: UVPD = Page directory (use pdx), UVPT = Page Table (Use PGNUM)

    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
        if( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)){
  801a4d:	89 d8                	mov    %ebx,%eax
  801a4f:	c1 e8 16             	shr    $0x16,%eax
  801a52:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a59:	a8 01                	test   $0x1,%al
  801a5b:	74 4b                	je     801aa8 <fork+0xc6>
  801a5d:	89 de                	mov    %ebx,%esi
  801a5f:	c1 ee 0c             	shr    $0xc,%esi
  801a62:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a69:	a8 01                	test   $0x1,%al
  801a6b:	74 3b                	je     801aa8 <fork+0xc6>
    if(uvpt[pn] & (PTE_W | PTE_COW)){
  801a6d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a74:	a9 02 08 00 00       	test   $0x802,%eax
  801a79:	0f 85 02 01 00 00    	jne    801b81 <fork+0x19f>
  801a7f:	e9 d2 00 00 00       	jmp    801b56 <fork+0x174>
	    r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), defaultperms);
  801a84:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801a8b:	00 
  801a8c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a97:	00 
  801a98:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa3:	e8 ff fb ff ff       	call   8016a7 <sys_page_map>
    for(va = 0; va < USTACKTOP; va += PGSIZE) { // Since it tells us to allocate a page for the UX stack, I'm gonna assume that's at the top.
  801aa8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aae:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801ab4:	75 97                	jne    801a4d <fork+0x6b>
            duppage(child, PGNUM(va)); // "pn" for page number
        }

    }

    r = sys_page_alloc(child, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);// Taking this very literally, we add a page, minus from the top.
  801ab6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801abd:	00 
  801abe:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801ac5:	ee 
  801ac6:	89 3c 24             	mov    %edi,(%esp)
  801ac9:	e8 85 fb ff ff       	call   801653 <sys_page_alloc>

    if(r < 0){
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	79 1c                	jns    801aee <fork+0x10c>
        panic("fork: sys_page_alloc has failed");
  801ad2:	c7 44 24 08 e0 3a 80 	movl   $0x803ae0,0x8(%esp)
  801ad9:	00 
  801ada:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  801ae1:	00 
  801ae2:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  801ae9:	e8 39 ef ff ff       	call   800a27 <_panic>
    }

    r = sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall);
  801aee:	a1 24 54 80 00       	mov    0x805424,%eax
  801af3:	8b 40 64             	mov    0x64(%eax),%eax
  801af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afa:	89 3c 24             	mov    %edi,(%esp)
  801afd:	e8 f1 fc ff ff       	call   8017f3 <sys_env_set_pgfault_upcall>
    if(r < 0){
  801b02:	85 c0                	test   %eax,%eax
  801b04:	79 1c                	jns    801b22 <fork+0x140>
        panic("fork: set_env_pgfault_upcall has failed");
  801b06:	c7 44 24 08 00 3b 80 	movl   $0x803b00,0x8(%esp)
  801b0d:	00 
  801b0e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  801b15:	00 
  801b16:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  801b1d:	e8 05 ef ff ff       	call   800a27 <_panic>
    }

    r = sys_env_set_status(child, ENV_RUNNABLE);
  801b22:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801b29:	00 
  801b2a:	89 3c 24             	mov    %edi,(%esp)
  801b2d:	e8 1b fc ff ff       	call   80174d <sys_env_set_status>
    if(r < 0){
  801b32:	85 c0                	test   %eax,%eax
  801b34:	79 1c                	jns    801b52 <fork+0x170>
        panic("Fork: sys_env_set_status has failed! Couldn't set child to runnable!");
  801b36:	c7 44 24 08 28 3b 80 	movl   $0x803b28,0x8(%esp)
  801b3d:	00 
  801b3e:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  801b45:	00 
  801b46:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  801b4d:	e8 d5 ee ff ff       	call   800a27 <_panic>
    }
    return child;
  801b52:	89 f8                	mov    %edi,%eax
  801b54:	eb 5e                	jmp    801bb4 <fork+0x1d2>
	r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), defaultperms);
  801b56:	c1 e6 0c             	shl    $0xc,%esi
  801b59:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801b60:	00 
  801b61:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b77:	e8 2b fb ff ff       	call   8016a7 <sys_page_map>
  801b7c:	e9 27 ff ff ff       	jmp    801aa8 <fork+0xc6>
  801b81:	c1 e6 0c             	shl    $0xc,%esi
  801b84:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801b8b:	00 
  801b8c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b93:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b97:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba2:	e8 00 fb ff ff       	call   8016a7 <sys_page_map>
    if( r < 0 ){
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	0f 89 d5 fe ff ff    	jns    801a84 <fork+0xa2>
  801baf:	e9 f4 fe ff ff       	jmp    801aa8 <fork+0xc6>
//	panic("fork not implemented");
}
  801bb4:	83 c4 2c             	add    $0x2c,%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5f                   	pop    %edi
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <sfork>:

// Challenge!
int
sfork(void)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801bc2:	c7 44 24 08 c5 3b 80 	movl   $0x803bc5,0x8(%esp)
  801bc9:	00 
  801bca:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  801bd1:	00 
  801bd2:	c7 04 24 6d 3b 80 00 	movl   $0x803b6d,(%esp)
  801bd9:	e8 49 ee ff ff       	call   800a27 <_panic>

00801bde <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	53                   	push   %ebx
  801be2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be8:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801beb:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  801bed:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801bf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf5:	83 39 01             	cmpl   $0x1,(%ecx)
  801bf8:	7e 0f                	jle    801c09 <argstart+0x2b>
  801bfa:	85 d2                	test   %edx,%edx
  801bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  801c01:	bb 21 35 80 00       	mov    $0x803521,%ebx
  801c06:	0f 44 da             	cmove  %edx,%ebx
  801c09:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  801c0c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801c13:	5b                   	pop    %ebx
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <argnext>:

int
argnext(struct Argstate *args)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	53                   	push   %ebx
  801c1a:	83 ec 14             	sub    $0x14,%esp
  801c1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801c20:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801c27:	8b 43 08             	mov    0x8(%ebx),%eax
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	74 71                	je     801c9f <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  801c2e:	80 38 00             	cmpb   $0x0,(%eax)
  801c31:	75 50                	jne    801c83 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801c33:	8b 0b                	mov    (%ebx),%ecx
  801c35:	83 39 01             	cmpl   $0x1,(%ecx)
  801c38:	74 57                	je     801c91 <argnext+0x7b>
		    || args->argv[1][0] != '-'
  801c3a:	8b 53 04             	mov    0x4(%ebx),%edx
  801c3d:	8b 42 04             	mov    0x4(%edx),%eax
  801c40:	80 38 2d             	cmpb   $0x2d,(%eax)
  801c43:	75 4c                	jne    801c91 <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  801c45:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801c49:	74 46                	je     801c91 <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801c4b:	83 c0 01             	add    $0x1,%eax
  801c4e:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c51:	8b 01                	mov    (%ecx),%eax
  801c53:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801c5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c5e:	8d 42 08             	lea    0x8(%edx),%eax
  801c61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c65:	83 c2 04             	add    $0x4,%edx
  801c68:	89 14 24             	mov    %edx,(%esp)
  801c6b:	e8 64 f7 ff ff       	call   8013d4 <memmove>
		(*args->argc)--;
  801c70:	8b 03                	mov    (%ebx),%eax
  801c72:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801c75:	8b 43 08             	mov    0x8(%ebx),%eax
  801c78:	80 38 2d             	cmpb   $0x2d,(%eax)
  801c7b:	75 06                	jne    801c83 <argnext+0x6d>
  801c7d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801c81:	74 0e                	je     801c91 <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801c83:	8b 53 08             	mov    0x8(%ebx),%edx
  801c86:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801c89:	83 c2 01             	add    $0x1,%edx
  801c8c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801c8f:	eb 13                	jmp    801ca4 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  801c91:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c9d:	eb 05                	jmp    801ca4 <argnext+0x8e>
		return -1;
  801c9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  801ca4:	83 c4 14             	add    $0x14,%esp
  801ca7:	5b                   	pop    %ebx
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    

00801caa <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	53                   	push   %ebx
  801cae:	83 ec 14             	sub    $0x14,%esp
  801cb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801cb4:	8b 43 08             	mov    0x8(%ebx),%eax
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	74 5a                	je     801d15 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  801cbb:	80 38 00             	cmpb   $0x0,(%eax)
  801cbe:	74 0c                	je     801ccc <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801cc0:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801cc3:	c7 43 08 21 35 80 00 	movl   $0x803521,0x8(%ebx)
  801cca:	eb 44                	jmp    801d10 <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  801ccc:	8b 03                	mov    (%ebx),%eax
  801cce:	83 38 01             	cmpl   $0x1,(%eax)
  801cd1:	7e 2f                	jle    801d02 <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  801cd3:	8b 53 04             	mov    0x4(%ebx),%edx
  801cd6:	8b 4a 04             	mov    0x4(%edx),%ecx
  801cd9:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801cdc:	8b 00                	mov    (%eax),%eax
  801cde:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801ce5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce9:	8d 42 08             	lea    0x8(%edx),%eax
  801cec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf0:	83 c2 04             	add    $0x4,%edx
  801cf3:	89 14 24             	mov    %edx,(%esp)
  801cf6:	e8 d9 f6 ff ff       	call   8013d4 <memmove>
		(*args->argc)--;
  801cfb:	8b 03                	mov    (%ebx),%eax
  801cfd:	83 28 01             	subl   $0x1,(%eax)
  801d00:	eb 0e                	jmp    801d10 <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  801d02:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801d09:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801d10:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d13:	eb 05                	jmp    801d1a <argnextvalue+0x70>
		return 0;
  801d15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d1a:	83 c4 14             	add    $0x14,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <argvalue>:
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 18             	sub    $0x18,%esp
  801d26:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801d29:	8b 51 0c             	mov    0xc(%ecx),%edx
  801d2c:	89 d0                	mov    %edx,%eax
  801d2e:	85 d2                	test   %edx,%edx
  801d30:	75 08                	jne    801d3a <argvalue+0x1a>
  801d32:	89 0c 24             	mov    %ecx,(%esp)
  801d35:	e8 70 ff ff ff       	call   801caa <argnextvalue>
}
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d43:	8b 45 08             	mov    0x8(%ebp),%eax
  801d46:	05 00 00 00 30       	add    $0x30000000,%eax
  801d4b:	c1 e8 0c             	shr    $0xc,%eax
}
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d53:	8b 45 08             	mov    0x8(%ebp),%eax
  801d56:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801d5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801d60:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801d72:	89 c2                	mov    %eax,%edx
  801d74:	c1 ea 16             	shr    $0x16,%edx
  801d77:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d7e:	f6 c2 01             	test   $0x1,%dl
  801d81:	74 11                	je     801d94 <fd_alloc+0x2d>
  801d83:	89 c2                	mov    %eax,%edx
  801d85:	c1 ea 0c             	shr    $0xc,%edx
  801d88:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d8f:	f6 c2 01             	test   $0x1,%dl
  801d92:	75 09                	jne    801d9d <fd_alloc+0x36>
			*fd_store = fd;
  801d94:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9b:	eb 17                	jmp    801db4 <fd_alloc+0x4d>
  801d9d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801da2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801da7:	75 c9                	jne    801d72 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801da9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801daf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801dbc:	83 f8 1f             	cmp    $0x1f,%eax
  801dbf:	77 36                	ja     801df7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801dc1:	c1 e0 0c             	shl    $0xc,%eax
  801dc4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801dc9:	89 c2                	mov    %eax,%edx
  801dcb:	c1 ea 16             	shr    $0x16,%edx
  801dce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dd5:	f6 c2 01             	test   $0x1,%dl
  801dd8:	74 24                	je     801dfe <fd_lookup+0x48>
  801dda:	89 c2                	mov    %eax,%edx
  801ddc:	c1 ea 0c             	shr    $0xc,%edx
  801ddf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801de6:	f6 c2 01             	test   $0x1,%dl
  801de9:	74 1a                	je     801e05 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801deb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dee:	89 02                	mov    %eax,(%edx)
	return 0;
  801df0:	b8 00 00 00 00       	mov    $0x0,%eax
  801df5:	eb 13                	jmp    801e0a <fd_lookup+0x54>
		return -E_INVAL;
  801df7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801dfc:	eb 0c                	jmp    801e0a <fd_lookup+0x54>
		return -E_INVAL;
  801dfe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e03:	eb 05                	jmp    801e0a <fd_lookup+0x54>
  801e05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 18             	sub    $0x18,%esp
  801e12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e15:	ba 58 3c 80 00       	mov    $0x803c58,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801e1a:	eb 13                	jmp    801e2f <dev_lookup+0x23>
  801e1c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801e1f:	39 08                	cmp    %ecx,(%eax)
  801e21:	75 0c                	jne    801e2f <dev_lookup+0x23>
			*dev = devtab[i];
  801e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e26:	89 01                	mov    %eax,(%ecx)
			return 0;
  801e28:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2d:	eb 30                	jmp    801e5f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801e2f:	8b 02                	mov    (%edx),%eax
  801e31:	85 c0                	test   %eax,%eax
  801e33:	75 e7                	jne    801e1c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801e35:	a1 24 54 80 00       	mov    0x805424,%eax
  801e3a:	8b 40 48             	mov    0x48(%eax),%eax
  801e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e45:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  801e4c:	e8 cf ec ff ff       	call   800b20 <cprintf>
	*dev = 0;
  801e51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801e5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <fd_close>:
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	56                   	push   %esi
  801e65:	53                   	push   %ebx
  801e66:	83 ec 20             	sub    $0x20,%esp
  801e69:	8b 75 08             	mov    0x8(%ebp),%esi
  801e6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801e6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e72:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e76:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801e7c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801e7f:	89 04 24             	mov    %eax,(%esp)
  801e82:	e8 2f ff ff ff       	call   801db6 <fd_lookup>
  801e87:	85 c0                	test   %eax,%eax
  801e89:	78 05                	js     801e90 <fd_close+0x2f>
	    || fd != fd2)
  801e8b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801e8e:	74 0c                	je     801e9c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801e90:	84 db                	test   %bl,%bl
  801e92:	ba 00 00 00 00       	mov    $0x0,%edx
  801e97:	0f 44 c2             	cmove  %edx,%eax
  801e9a:	eb 3f                	jmp    801edb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea3:	8b 06                	mov    (%esi),%eax
  801ea5:	89 04 24             	mov    %eax,(%esp)
  801ea8:	e8 5f ff ff ff       	call   801e0c <dev_lookup>
  801ead:	89 c3                	mov    %eax,%ebx
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	78 16                	js     801ec9 <fd_close+0x68>
		if (dev->dev_close)
  801eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801eb9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	74 07                	je     801ec9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801ec2:	89 34 24             	mov    %esi,(%esp)
  801ec5:	ff d0                	call   *%eax
  801ec7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801ec9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed4:	e8 21 f8 ff ff       	call   8016fa <sys_page_unmap>
	return r;
  801ed9:	89 d8                	mov    %ebx,%eax
}
  801edb:	83 c4 20             	add    $0x20,%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <close>:

int
close(int fdnum)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ee8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef2:	89 04 24             	mov    %eax,(%esp)
  801ef5:	e8 bc fe ff ff       	call   801db6 <fd_lookup>
  801efa:	89 c2                	mov    %eax,%edx
  801efc:	85 d2                	test   %edx,%edx
  801efe:	78 13                	js     801f13 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801f00:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f07:	00 
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	89 04 24             	mov    %eax,(%esp)
  801f0e:	e8 4e ff ff ff       	call   801e61 <fd_close>
}
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <close_all>:

void
close_all(void)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	53                   	push   %ebx
  801f19:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801f21:	89 1c 24             	mov    %ebx,(%esp)
  801f24:	e8 b9 ff ff ff       	call   801ee2 <close>
	for (i = 0; i < MAXFD; i++)
  801f29:	83 c3 01             	add    $0x1,%ebx
  801f2c:	83 fb 20             	cmp    $0x20,%ebx
  801f2f:	75 f0                	jne    801f21 <close_all+0xc>
}
  801f31:	83 c4 14             	add    $0x14,%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	57                   	push   %edi
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801f40:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f47:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4a:	89 04 24             	mov    %eax,(%esp)
  801f4d:	e8 64 fe ff ff       	call   801db6 <fd_lookup>
  801f52:	89 c2                	mov    %eax,%edx
  801f54:	85 d2                	test   %edx,%edx
  801f56:	0f 88 e1 00 00 00    	js     80203d <dup+0x106>
		return r;
	close(newfdnum);
  801f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5f:	89 04 24             	mov    %eax,(%esp)
  801f62:	e8 7b ff ff ff       	call   801ee2 <close>

	newfd = INDEX2FD(newfdnum);
  801f67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f6a:	c1 e3 0c             	shl    $0xc,%ebx
  801f6d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f76:	89 04 24             	mov    %eax,(%esp)
  801f79:	e8 d2 fd ff ff       	call   801d50 <fd2data>
  801f7e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801f80:	89 1c 24             	mov    %ebx,(%esp)
  801f83:	e8 c8 fd ff ff       	call   801d50 <fd2data>
  801f88:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801f8a:	89 f0                	mov    %esi,%eax
  801f8c:	c1 e8 16             	shr    $0x16,%eax
  801f8f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f96:	a8 01                	test   $0x1,%al
  801f98:	74 43                	je     801fdd <dup+0xa6>
  801f9a:	89 f0                	mov    %esi,%eax
  801f9c:	c1 e8 0c             	shr    $0xc,%eax
  801f9f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fa6:	f6 c2 01             	test   $0x1,%dl
  801fa9:	74 32                	je     801fdd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801fab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801fb2:	25 07 0e 00 00       	and    $0xe07,%eax
  801fb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fbf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fc6:	00 
  801fc7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fcb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd2:	e8 d0 f6 ff ff       	call   8016a7 <sys_page_map>
  801fd7:	89 c6                	mov    %eax,%esi
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 3e                	js     80201b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801fdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fe0:	89 c2                	mov    %eax,%edx
  801fe2:	c1 ea 0c             	shr    $0xc,%edx
  801fe5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801fec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ff2:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ff6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ffa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802001:	00 
  802002:	89 44 24 04          	mov    %eax,0x4(%esp)
  802006:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200d:	e8 95 f6 ff ff       	call   8016a7 <sys_page_map>
  802012:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  802014:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802017:	85 f6                	test   %esi,%esi
  802019:	79 22                	jns    80203d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80201b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80201f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802026:	e8 cf f6 ff ff       	call   8016fa <sys_page_unmap>
	sys_page_unmap(0, nva);
  80202b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80202f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802036:	e8 bf f6 ff ff       	call   8016fa <sys_page_unmap>
	return r;
  80203b:	89 f0                	mov    %esi,%eax
}
  80203d:	83 c4 3c             	add    $0x3c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	53                   	push   %ebx
  802049:	83 ec 24             	sub    $0x24,%esp
  80204c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80204f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802052:	89 44 24 04          	mov    %eax,0x4(%esp)
  802056:	89 1c 24             	mov    %ebx,(%esp)
  802059:	e8 58 fd ff ff       	call   801db6 <fd_lookup>
  80205e:	89 c2                	mov    %eax,%edx
  802060:	85 d2                	test   %edx,%edx
  802062:	78 6d                	js     8020d1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802064:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802067:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80206e:	8b 00                	mov    (%eax),%eax
  802070:	89 04 24             	mov    %eax,(%esp)
  802073:	e8 94 fd ff ff       	call   801e0c <dev_lookup>
  802078:	85 c0                	test   %eax,%eax
  80207a:	78 55                	js     8020d1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80207c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80207f:	8b 50 08             	mov    0x8(%eax),%edx
  802082:	83 e2 03             	and    $0x3,%edx
  802085:	83 fa 01             	cmp    $0x1,%edx
  802088:	75 23                	jne    8020ad <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80208a:	a1 24 54 80 00       	mov    0x805424,%eax
  80208f:	8b 40 48             	mov    0x48(%eax),%eax
  802092:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209a:	c7 04 24 1d 3c 80 00 	movl   $0x803c1d,(%esp)
  8020a1:	e8 7a ea ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  8020a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020ab:	eb 24                	jmp    8020d1 <read+0x8c>
	}
	if (!dev->dev_read)
  8020ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020b0:	8b 52 08             	mov    0x8(%edx),%edx
  8020b3:	85 d2                	test   %edx,%edx
  8020b5:	74 15                	je     8020cc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8020b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8020ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020c5:	89 04 24             	mov    %eax,(%esp)
  8020c8:	ff d2                	call   *%edx
  8020ca:	eb 05                	jmp    8020d1 <read+0x8c>
		return -E_NOT_SUPP;
  8020cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8020d1:	83 c4 24             	add    $0x24,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    

008020d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	57                   	push   %edi
  8020db:	56                   	push   %esi
  8020dc:	53                   	push   %ebx
  8020dd:	83 ec 1c             	sub    $0x1c,%esp
  8020e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8020e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020eb:	eb 23                	jmp    802110 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8020ed:	89 f0                	mov    %esi,%eax
  8020ef:	29 d8                	sub    %ebx,%eax
  8020f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020f5:	89 d8                	mov    %ebx,%eax
  8020f7:	03 45 0c             	add    0xc(%ebp),%eax
  8020fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fe:	89 3c 24             	mov    %edi,(%esp)
  802101:	e8 3f ff ff ff       	call   802045 <read>
		if (m < 0)
  802106:	85 c0                	test   %eax,%eax
  802108:	78 10                	js     80211a <readn+0x43>
			return m;
		if (m == 0)
  80210a:	85 c0                	test   %eax,%eax
  80210c:	74 0a                	je     802118 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80210e:	01 c3                	add    %eax,%ebx
  802110:	39 f3                	cmp    %esi,%ebx
  802112:	72 d9                	jb     8020ed <readn+0x16>
  802114:	89 d8                	mov    %ebx,%eax
  802116:	eb 02                	jmp    80211a <readn+0x43>
  802118:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    

00802122 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	53                   	push   %ebx
  802126:	83 ec 24             	sub    $0x24,%esp
  802129:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80212c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80212f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802133:	89 1c 24             	mov    %ebx,(%esp)
  802136:	e8 7b fc ff ff       	call   801db6 <fd_lookup>
  80213b:	89 c2                	mov    %eax,%edx
  80213d:	85 d2                	test   %edx,%edx
  80213f:	78 68                	js     8021a9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802144:	89 44 24 04          	mov    %eax,0x4(%esp)
  802148:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80214b:	8b 00                	mov    (%eax),%eax
  80214d:	89 04 24             	mov    %eax,(%esp)
  802150:	e8 b7 fc ff ff       	call   801e0c <dev_lookup>
  802155:	85 c0                	test   %eax,%eax
  802157:	78 50                	js     8021a9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80215c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802160:	75 23                	jne    802185 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802162:	a1 24 54 80 00       	mov    0x805424,%eax
  802167:	8b 40 48             	mov    0x48(%eax),%eax
  80216a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80216e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802172:	c7 04 24 39 3c 80 00 	movl   $0x803c39,(%esp)
  802179:	e8 a2 e9 ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  80217e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802183:	eb 24                	jmp    8021a9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802185:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802188:	8b 52 0c             	mov    0xc(%edx),%edx
  80218b:	85 d2                	test   %edx,%edx
  80218d:	74 15                	je     8021a4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80218f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802192:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802199:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80219d:	89 04 24             	mov    %eax,(%esp)
  8021a0:	ff d2                	call   *%edx
  8021a2:	eb 05                	jmp    8021a9 <write+0x87>
		return -E_NOT_SUPP;
  8021a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8021a9:	83 c4 24             	add    $0x24,%esp
  8021ac:	5b                   	pop    %ebx
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <seek>:

int
seek(int fdnum, off_t offset)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8021b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bf:	89 04 24             	mov    %eax,(%esp)
  8021c2:	e8 ef fb ff ff       	call   801db6 <fd_lookup>
  8021c7:	85 c0                	test   %eax,%eax
  8021c9:	78 0e                	js     8021d9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8021cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8021ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8021d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021d9:	c9                   	leave  
  8021da:	c3                   	ret    

008021db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	53                   	push   %ebx
  8021df:	83 ec 24             	sub    $0x24,%esp
  8021e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ec:	89 1c 24             	mov    %ebx,(%esp)
  8021ef:	e8 c2 fb ff ff       	call   801db6 <fd_lookup>
  8021f4:	89 c2                	mov    %eax,%edx
  8021f6:	85 d2                	test   %edx,%edx
  8021f8:	78 61                	js     80225b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802201:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802204:	8b 00                	mov    (%eax),%eax
  802206:	89 04 24             	mov    %eax,(%esp)
  802209:	e8 fe fb ff ff       	call   801e0c <dev_lookup>
  80220e:	85 c0                	test   %eax,%eax
  802210:	78 49                	js     80225b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802212:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802215:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802219:	75 23                	jne    80223e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80221b:	a1 24 54 80 00       	mov    0x805424,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802220:	8b 40 48             	mov    0x48(%eax),%eax
  802223:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80222b:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  802232:	e8 e9 e8 ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  802237:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80223c:	eb 1d                	jmp    80225b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80223e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802241:	8b 52 18             	mov    0x18(%edx),%edx
  802244:	85 d2                	test   %edx,%edx
  802246:	74 0e                	je     802256 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80224b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80224f:	89 04 24             	mov    %eax,(%esp)
  802252:	ff d2                	call   *%edx
  802254:	eb 05                	jmp    80225b <ftruncate+0x80>
		return -E_NOT_SUPP;
  802256:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80225b:	83 c4 24             	add    $0x24,%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    

00802261 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	53                   	push   %ebx
  802265:	83 ec 24             	sub    $0x24,%esp
  802268:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80226b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80226e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802272:	8b 45 08             	mov    0x8(%ebp),%eax
  802275:	89 04 24             	mov    %eax,(%esp)
  802278:	e8 39 fb ff ff       	call   801db6 <fd_lookup>
  80227d:	89 c2                	mov    %eax,%edx
  80227f:	85 d2                	test   %edx,%edx
  802281:	78 52                	js     8022d5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802283:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80228d:	8b 00                	mov    (%eax),%eax
  80228f:	89 04 24             	mov    %eax,(%esp)
  802292:	e8 75 fb ff ff       	call   801e0c <dev_lookup>
  802297:	85 c0                	test   %eax,%eax
  802299:	78 3a                	js     8022d5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80229b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8022a2:	74 2c                	je     8022d0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8022a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8022a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8022ae:	00 00 00 
	stat->st_isdir = 0;
  8022b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022b8:	00 00 00 
	stat->st_dev = dev;
  8022bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8022c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022c8:	89 14 24             	mov    %edx,(%esp)
  8022cb:	ff 50 14             	call   *0x14(%eax)
  8022ce:	eb 05                	jmp    8022d5 <fstat+0x74>
		return -E_NOT_SUPP;
  8022d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8022d5:	83 c4 24             	add    $0x24,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5d                   	pop    %ebp
  8022da:	c3                   	ret    

008022db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8022e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022ea:	00 
  8022eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ee:	89 04 24             	mov    %eax,(%esp)
  8022f1:	e8 fb 01 00 00       	call   8024f1 <open>
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	85 db                	test   %ebx,%ebx
  8022fa:	78 1b                	js     802317 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8022fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802303:	89 1c 24             	mov    %ebx,(%esp)
  802306:	e8 56 ff ff ff       	call   802261 <fstat>
  80230b:	89 c6                	mov    %eax,%esi
	close(fd);
  80230d:	89 1c 24             	mov    %ebx,(%esp)
  802310:	e8 cd fb ff ff       	call   801ee2 <close>
	return r;
  802315:	89 f0                	mov    %esi,%eax
}
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	5b                   	pop    %ebx
  80231b:	5e                   	pop    %esi
  80231c:	5d                   	pop    %ebp
  80231d:	c3                   	ret    

0080231e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	56                   	push   %esi
  802322:	53                   	push   %ebx
  802323:	83 ec 10             	sub    $0x10,%esp
  802326:	89 c6                	mov    %eax,%esi
  802328:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80232a:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802331:	75 11                	jne    802344 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802333:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80233a:	e8 b0 0e 00 00       	call   8031ef <ipc_find_env>
  80233f:	a3 20 54 80 00       	mov    %eax,0x805420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802344:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80234b:	00 
  80234c:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802353:	00 
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	a1 20 54 80 00       	mov    0x805420,%eax
  80235d:	89 04 24             	mov    %eax,(%esp)
  802360:	e8 23 0e 00 00       	call   803188 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802365:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80236c:	00 
  80236d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802371:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802378:	e8 a3 0d 00 00       	call   803120 <ipc_recv>
}
  80237d:	83 c4 10             	add    $0x10,%esp
  802380:	5b                   	pop    %ebx
  802381:	5e                   	pop    %esi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    

00802384 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802384:	55                   	push   %ebp
  802385:	89 e5                	mov    %esp,%ebp
  802387:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80238a:	8b 45 08             	mov    0x8(%ebp),%eax
  80238d:	8b 40 0c             	mov    0xc(%eax),%eax
  802390:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802395:	8b 45 0c             	mov    0xc(%ebp),%eax
  802398:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80239d:	ba 00 00 00 00       	mov    $0x0,%edx
  8023a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8023a7:	e8 72 ff ff ff       	call   80231e <fsipc>
}
  8023ac:	c9                   	leave  
  8023ad:	c3                   	ret    

008023ae <devfile_flush>:
{
  8023ae:	55                   	push   %ebp
  8023af:	89 e5                	mov    %esp,%ebp
  8023b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8023b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8023ba:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8023bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8023c9:	e8 50 ff ff ff       	call   80231e <fsipc>
}
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <devfile_stat>:
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	53                   	push   %ebx
  8023d4:	83 ec 14             	sub    $0x14,%esp
  8023d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8023da:	8b 45 08             	mov    0x8(%ebp),%eax
  8023dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8023e0:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8023e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8023ef:	e8 2a ff ff ff       	call   80231e <fsipc>
  8023f4:	89 c2                	mov    %eax,%edx
  8023f6:	85 d2                	test   %edx,%edx
  8023f8:	78 2b                	js     802425 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8023fa:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802401:	00 
  802402:	89 1c 24             	mov    %ebx,(%esp)
  802405:	e8 2d ee ff ff       	call   801237 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80240a:	a1 80 60 80 00       	mov    0x806080,%eax
  80240f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802415:	a1 84 60 80 00       	mov    0x806084,%eax
  80241a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802420:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802425:	83 c4 14             	add    $0x14,%esp
  802428:	5b                   	pop    %ebx
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    

0080242b <devfile_write>:
{
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  802431:	c7 44 24 08 68 3c 80 	movl   $0x803c68,0x8(%esp)
  802438:	00 
  802439:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  802440:	00 
  802441:	c7 04 24 86 3c 80 00 	movl   $0x803c86,(%esp)
  802448:	e8 da e5 ff ff       	call   800a27 <_panic>

0080244d <devfile_read>:
{
  80244d:	55                   	push   %ebp
  80244e:	89 e5                	mov    %esp,%ebp
  802450:	56                   	push   %esi
  802451:	53                   	push   %ebx
  802452:	83 ec 10             	sub    $0x10,%esp
  802455:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802458:	8b 45 08             	mov    0x8(%ebp),%eax
  80245b:	8b 40 0c             	mov    0xc(%eax),%eax
  80245e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802463:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802469:	ba 00 00 00 00       	mov    $0x0,%edx
  80246e:	b8 03 00 00 00       	mov    $0x3,%eax
  802473:	e8 a6 fe ff ff       	call   80231e <fsipc>
  802478:	89 c3                	mov    %eax,%ebx
  80247a:	85 c0                	test   %eax,%eax
  80247c:	78 6a                	js     8024e8 <devfile_read+0x9b>
	assert(r <= n);
  80247e:	39 c6                	cmp    %eax,%esi
  802480:	73 24                	jae    8024a6 <devfile_read+0x59>
  802482:	c7 44 24 0c 91 3c 80 	movl   $0x803c91,0xc(%esp)
  802489:	00 
  80248a:	c7 44 24 08 5b 36 80 	movl   $0x80365b,0x8(%esp)
  802491:	00 
  802492:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802499:	00 
  80249a:	c7 04 24 86 3c 80 00 	movl   $0x803c86,(%esp)
  8024a1:	e8 81 e5 ff ff       	call   800a27 <_panic>
	assert(r <= PGSIZE);
  8024a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8024ab:	7e 24                	jle    8024d1 <devfile_read+0x84>
  8024ad:	c7 44 24 0c 98 3c 80 	movl   $0x803c98,0xc(%esp)
  8024b4:	00 
  8024b5:	c7 44 24 08 5b 36 80 	movl   $0x80365b,0x8(%esp)
  8024bc:	00 
  8024bd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8024c4:	00 
  8024c5:	c7 04 24 86 3c 80 00 	movl   $0x803c86,(%esp)
  8024cc:	e8 56 e5 ff ff       	call   800a27 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8024d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024d5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8024dc:	00 
  8024dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024e0:	89 04 24             	mov    %eax,(%esp)
  8024e3:	e8 ec ee ff ff       	call   8013d4 <memmove>
}
  8024e8:	89 d8                	mov    %ebx,%eax
  8024ea:	83 c4 10             	add    $0x10,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5d                   	pop    %ebp
  8024f0:	c3                   	ret    

008024f1 <open>:
{
  8024f1:	55                   	push   %ebp
  8024f2:	89 e5                	mov    %esp,%ebp
  8024f4:	53                   	push   %ebx
  8024f5:	83 ec 24             	sub    $0x24,%esp
  8024f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8024fb:	89 1c 24             	mov    %ebx,(%esp)
  8024fe:	e8 fd ec ff ff       	call   801200 <strlen>
  802503:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802508:	7f 60                	jg     80256a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80250a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80250d:	89 04 24             	mov    %eax,(%esp)
  802510:	e8 52 f8 ff ff       	call   801d67 <fd_alloc>
  802515:	89 c2                	mov    %eax,%edx
  802517:	85 d2                	test   %edx,%edx
  802519:	78 54                	js     80256f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80251b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80251f:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802526:	e8 0c ed ff ff       	call   801237 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80252b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80252e:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802533:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	e8 de fd ff ff       	call   80231e <fsipc>
  802540:	89 c3                	mov    %eax,%ebx
  802542:	85 c0                	test   %eax,%eax
  802544:	79 17                	jns    80255d <open+0x6c>
		fd_close(fd, 0);
  802546:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80254d:	00 
  80254e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802551:	89 04 24             	mov    %eax,(%esp)
  802554:	e8 08 f9 ff ff       	call   801e61 <fd_close>
		return r;
  802559:	89 d8                	mov    %ebx,%eax
  80255b:	eb 12                	jmp    80256f <open+0x7e>
	return fd2num(fd);
  80255d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802560:	89 04 24             	mov    %eax,(%esp)
  802563:	e8 d8 f7 ff ff       	call   801d40 <fd2num>
  802568:	eb 05                	jmp    80256f <open+0x7e>
		return -E_BAD_PATH;
  80256a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  80256f:	83 c4 24             	add    $0x24,%esp
  802572:	5b                   	pop    %ebx
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80257b:	ba 00 00 00 00       	mov    $0x0,%edx
  802580:	b8 08 00 00 00       	mov    $0x8,%eax
  802585:	e8 94 fd ff ff       	call   80231e <fsipc>
}
  80258a:	c9                   	leave  
  80258b:	c3                   	ret    

0080258c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80258c:	55                   	push   %ebp
  80258d:	89 e5                	mov    %esp,%ebp
  80258f:	53                   	push   %ebx
  802590:	83 ec 14             	sub    $0x14,%esp
  802593:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  802595:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802599:	7e 31                	jle    8025cc <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80259b:	8b 40 04             	mov    0x4(%eax),%eax
  80259e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025a2:	8d 43 10             	lea    0x10(%ebx),%eax
  8025a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a9:	8b 03                	mov    (%ebx),%eax
  8025ab:	89 04 24             	mov    %eax,(%esp)
  8025ae:	e8 6f fb ff ff       	call   802122 <write>
		if (result > 0)
  8025b3:	85 c0                	test   %eax,%eax
  8025b5:	7e 03                	jle    8025ba <writebuf+0x2e>
			b->result += result;
  8025b7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8025ba:	39 43 04             	cmp    %eax,0x4(%ebx)
  8025bd:	74 0d                	je     8025cc <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  8025bf:	85 c0                	test   %eax,%eax
  8025c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8025c6:	0f 4f c2             	cmovg  %edx,%eax
  8025c9:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8025cc:	83 c4 14             	add    $0x14,%esp
  8025cf:	5b                   	pop    %ebx
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    

008025d2 <putch>:

static void
putch(int ch, void *thunk)
{
  8025d2:	55                   	push   %ebp
  8025d3:	89 e5                	mov    %esp,%ebp
  8025d5:	53                   	push   %ebx
  8025d6:	83 ec 04             	sub    $0x4,%esp
  8025d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8025dc:	8b 53 04             	mov    0x4(%ebx),%edx
  8025df:	8d 42 01             	lea    0x1(%edx),%eax
  8025e2:	89 43 04             	mov    %eax,0x4(%ebx)
  8025e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025e8:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8025ec:	3d 00 01 00 00       	cmp    $0x100,%eax
  8025f1:	75 0e                	jne    802601 <putch+0x2f>
		writebuf(b);
  8025f3:	89 d8                	mov    %ebx,%eax
  8025f5:	e8 92 ff ff ff       	call   80258c <writebuf>
		b->idx = 0;
  8025fa:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802601:	83 c4 04             	add    $0x4,%esp
  802604:	5b                   	pop    %ebx
  802605:	5d                   	pop    %ebp
  802606:	c3                   	ret    

00802607 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802607:	55                   	push   %ebp
  802608:	89 e5                	mov    %esp,%ebp
  80260a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  802610:	8b 45 08             	mov    0x8(%ebp),%eax
  802613:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802619:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802620:	00 00 00 
	b.result = 0;
  802623:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80262a:	00 00 00 
	b.error = 1;
  80262d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802634:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802637:	8b 45 10             	mov    0x10(%ebp),%eax
  80263a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802641:	89 44 24 08          	mov    %eax,0x8(%esp)
  802645:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80264b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80264f:	c7 04 24 d2 25 80 00 	movl   $0x8025d2,(%esp)
  802656:	e8 53 e6 ff ff       	call   800cae <vprintfmt>
	if (b.idx > 0)
  80265b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802662:	7e 0b                	jle    80266f <vfprintf+0x68>
		writebuf(&b);
  802664:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80266a:	e8 1d ff ff ff       	call   80258c <writebuf>

	return (b.result ? b.result : b.error);
  80266f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802675:	85 c0                	test   %eax,%eax
  802677:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80267e:	c9                   	leave  
  80267f:	c3                   	ret    

00802680 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802686:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802689:	89 44 24 08          	mov    %eax,0x8(%esp)
  80268d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802690:	89 44 24 04          	mov    %eax,0x4(%esp)
  802694:	8b 45 08             	mov    0x8(%ebp),%eax
  802697:	89 04 24             	mov    %eax,(%esp)
  80269a:	e8 68 ff ff ff       	call   802607 <vfprintf>
	va_end(ap);

	return cnt;
}
  80269f:	c9                   	leave  
  8026a0:	c3                   	ret    

008026a1 <printf>:

int
printf(const char *fmt, ...)
{
  8026a1:	55                   	push   %ebp
  8026a2:	89 e5                	mov    %esp,%ebp
  8026a4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8026a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8026aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8026bc:	e8 46 ff ff ff       	call   802607 <vfprintf>
	va_end(ap);

	return cnt;
}
  8026c1:	c9                   	leave  
  8026c2:	c3                   	ret    
  8026c3:	66 90                	xchg   %ax,%ax
  8026c5:	66 90                	xchg   %ax,%ax
  8026c7:	66 90                	xchg   %ax,%ax
  8026c9:	66 90                	xchg   %ax,%ax
  8026cb:	66 90                	xchg   %ax,%ax
  8026cd:	66 90                	xchg   %ax,%ax
  8026cf:	90                   	nop

008026d0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	57                   	push   %edi
  8026d4:	56                   	push   %esi
  8026d5:	53                   	push   %ebx
  8026d6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8026dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8026e3:	00 
  8026e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8026e7:	89 04 24             	mov    %eax,(%esp)
  8026ea:	e8 02 fe ff ff       	call   8024f1 <open>
  8026ef:	89 c1                	mov    %eax,%ecx
  8026f1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	0f 88 a8 04 00 00    	js     802ba7 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8026ff:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802706:	00 
  802707:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80270d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802711:	89 0c 24             	mov    %ecx,(%esp)
  802714:	e8 be f9 ff ff       	call   8020d7 <readn>
  802719:	3d 00 02 00 00       	cmp    $0x200,%eax
  80271e:	75 0c                	jne    80272c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  802720:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802727:	45 4c 46 
  80272a:	74 36                	je     802762 <spawn+0x92>
		close(fd);
  80272c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802732:	89 04 24             	mov    %eax,(%esp)
  802735:	e8 a8 f7 ff ff       	call   801ee2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80273a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802741:	46 
  802742:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80274c:	c7 04 24 a4 3c 80 00 	movl   $0x803ca4,(%esp)
  802753:	e8 c8 e3 ff ff       	call   800b20 <cprintf>
		return -E_NOT_EXEC;
  802758:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80275d:	e9 a4 04 00 00       	jmp    802c06 <spawn+0x536>
  802762:	b8 07 00 00 00       	mov    $0x7,%eax
  802767:	cd 30                	int    $0x30
  802769:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80276f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802775:	85 c0                	test   %eax,%eax
  802777:	0f 88 32 04 00 00    	js     802baf <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80277d:	89 c6                	mov    %eax,%esi
  80277f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802785:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802788:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80278e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802794:	b9 11 00 00 00       	mov    $0x11,%ecx
  802799:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80279b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8027a1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8027a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8027ac:	be 00 00 00 00       	mov    $0x0,%esi
  8027b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027b4:	eb 0f                	jmp    8027c5 <spawn+0xf5>
		string_size += strlen(argv[argc]) + 1;
  8027b6:	89 04 24             	mov    %eax,(%esp)
  8027b9:	e8 42 ea ff ff       	call   801200 <strlen>
  8027be:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8027c2:	83 c3 01             	add    $0x1,%ebx
  8027c5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8027cc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8027cf:	85 c0                	test   %eax,%eax
  8027d1:	75 e3                	jne    8027b6 <spawn+0xe6>
  8027d3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8027d9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8027df:	bf 00 10 40 00       	mov    $0x401000,%edi
  8027e4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8027e6:	89 fa                	mov    %edi,%edx
  8027e8:	83 e2 fc             	and    $0xfffffffc,%edx
  8027eb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8027f2:	29 c2                	sub    %eax,%edx
  8027f4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8027fa:	8d 42 f8             	lea    -0x8(%edx),%eax
  8027fd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802802:	0f 86 b7 03 00 00    	jbe    802bbf <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802808:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80280f:	00 
  802810:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802817:	00 
  802818:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80281f:	e8 2f ee ff ff       	call   801653 <sys_page_alloc>
  802824:	85 c0                	test   %eax,%eax
  802826:	0f 88 da 03 00 00    	js     802c06 <spawn+0x536>
  80282c:	be 00 00 00 00       	mov    $0x0,%esi
  802831:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802837:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80283a:	eb 30                	jmp    80286c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80283c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802842:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802848:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80284b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80284e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802852:	89 3c 24             	mov    %edi,(%esp)
  802855:	e8 dd e9 ff ff       	call   801237 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80285a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80285d:	89 04 24             	mov    %eax,(%esp)
  802860:	e8 9b e9 ff ff       	call   801200 <strlen>
  802865:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  802869:	83 c6 01             	add    $0x1,%esi
  80286c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802872:	7f c8                	jg     80283c <spawn+0x16c>
	}
	argv_store[argc] = 0;
  802874:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80287a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802880:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802887:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80288d:	74 24                	je     8028b3 <spawn+0x1e3>
  80288f:	c7 44 24 0c 18 3d 80 	movl   $0x803d18,0xc(%esp)
  802896:	00 
  802897:	c7 44 24 08 5b 36 80 	movl   $0x80365b,0x8(%esp)
  80289e:	00 
  80289f:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  8028a6:	00 
  8028a7:	c7 04 24 be 3c 80 00 	movl   $0x803cbe,(%esp)
  8028ae:	e8 74 e1 ff ff       	call   800a27 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8028b3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8028b9:	89 c8                	mov    %ecx,%eax
  8028bb:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8028c0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8028c3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8028c9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8028cc:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8028d2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8028d8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8028df:	00 
  8028e0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8028e7:	ee 
  8028e8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8028ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028f2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8028f9:	00 
  8028fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802901:	e8 a1 ed ff ff       	call   8016a7 <sys_page_map>
  802906:	89 c3                	mov    %eax,%ebx
  802908:	85 c0                	test   %eax,%eax
  80290a:	0f 88 e0 02 00 00    	js     802bf0 <spawn+0x520>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802910:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802917:	00 
  802918:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80291f:	e8 d6 ed ff ff       	call   8016fa <sys_page_unmap>
  802924:	89 c3                	mov    %eax,%ebx
  802926:	85 c0                	test   %eax,%eax
  802928:	0f 88 c2 02 00 00    	js     802bf0 <spawn+0x520>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80292e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802934:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80293b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802941:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802948:	00 00 00 
  80294b:	e9 b6 01 00 00       	jmp    802b06 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  802950:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802956:	83 38 01             	cmpl   $0x1,(%eax)
  802959:	0f 85 99 01 00 00    	jne    802af8 <spawn+0x428>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80295f:	89 c1                	mov    %eax,%ecx
  802961:	8b 40 18             	mov    0x18(%eax),%eax
  802964:	83 e0 02             	and    $0x2,%eax
		perm = PTE_P | PTE_U;
  802967:	83 f8 01             	cmp    $0x1,%eax
  80296a:	19 c0                	sbb    %eax,%eax
  80296c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802972:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  802979:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802980:	89 c8                	mov    %ecx,%eax
  802982:	8b 51 04             	mov    0x4(%ecx),%edx
  802985:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  80298b:	8b 49 10             	mov    0x10(%ecx),%ecx
  80298e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  802994:	8b 50 14             	mov    0x14(%eax),%edx
  802997:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  80299d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8029a0:	89 f0                	mov    %esi,%eax
  8029a2:	25 ff 0f 00 00       	and    $0xfff,%eax
  8029a7:	74 14                	je     8029bd <spawn+0x2ed>
		va -= i;
  8029a9:	29 c6                	sub    %eax,%esi
		memsz += i;
  8029ab:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8029b1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8029b7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8029bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029c2:	e9 23 01 00 00       	jmp    802aea <spawn+0x41a>
		if (i >= filesz) {
  8029c7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8029cd:	77 2b                	ja     8029fa <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8029cf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8029d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029dd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8029e3:	89 04 24             	mov    %eax,(%esp)
  8029e6:	e8 68 ec ff ff       	call   801653 <sys_page_alloc>
  8029eb:	85 c0                	test   %eax,%eax
  8029ed:	0f 89 eb 00 00 00    	jns    802ade <spawn+0x40e>
  8029f3:	89 c3                	mov    %eax,%ebx
  8029f5:	e9 d6 01 00 00       	jmp    802bd0 <spawn+0x500>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029fa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802a01:	00 
  802a02:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a09:	00 
  802a0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a11:	e8 3d ec ff ff       	call   801653 <sys_page_alloc>
  802a16:	85 c0                	test   %eax,%eax
  802a18:	0f 88 a8 01 00 00    	js     802bc6 <spawn+0x4f6>
  802a1e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a24:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a2a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802a30:	89 04 24             	mov    %eax,(%esp)
  802a33:	e8 77 f7 ff ff       	call   8021af <seek>
  802a38:	85 c0                	test   %eax,%eax
  802a3a:	0f 88 8a 01 00 00    	js     802bca <spawn+0x4fa>
  802a40:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802a46:	29 fa                	sub    %edi,%edx
  802a48:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a4a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  802a50:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802a55:	0f 47 c1             	cmova  %ecx,%eax
  802a58:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a5c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a63:	00 
  802a64:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802a6a:	89 04 24             	mov    %eax,(%esp)
  802a6d:	e8 65 f6 ff ff       	call   8020d7 <readn>
  802a72:	85 c0                	test   %eax,%eax
  802a74:	0f 88 54 01 00 00    	js     802bce <spawn+0x4fe>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802a7a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802a80:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a84:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802a88:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802a8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a92:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a99:	00 
  802a9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802aa1:	e8 01 ec ff ff       	call   8016a7 <sys_page_map>
  802aa6:	85 c0                	test   %eax,%eax
  802aa8:	79 20                	jns    802aca <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  802aaa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802aae:	c7 44 24 08 ca 3c 80 	movl   $0x803cca,0x8(%esp)
  802ab5:	00 
  802ab6:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  802abd:	00 
  802abe:	c7 04 24 be 3c 80 00 	movl   $0x803cbe,(%esp)
  802ac5:	e8 5d df ff ff       	call   800a27 <_panic>
			sys_page_unmap(0, UTEMP);
  802aca:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802ad1:	00 
  802ad2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ad9:	e8 1c ec ff ff       	call   8016fa <sys_page_unmap>
	for (i = 0; i < memsz; i += PGSIZE) {
  802ade:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802ae4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802aea:	89 df                	mov    %ebx,%edi
  802aec:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802af2:	0f 87 cf fe ff ff    	ja     8029c7 <spawn+0x2f7>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802af8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802aff:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802b06:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802b0d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802b13:	0f 8c 37 fe ff ff    	jl     802950 <spawn+0x280>
	close(fd);
  802b19:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b1f:	89 04 24             	mov    %eax,(%esp)
  802b22:	e8 bb f3 ff ff       	call   801ee2 <close>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802b27:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802b2e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802b31:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b3b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b41:	89 04 24             	mov    %eax,(%esp)
  802b44:	e8 57 ec ff ff       	call   8017a0 <sys_env_set_trapframe>
  802b49:	85 c0                	test   %eax,%eax
  802b4b:	79 20                	jns    802b6d <spawn+0x49d>
		panic("sys_env_set_trapframe: %e", r);
  802b4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b51:	c7 44 24 08 e7 3c 80 	movl   $0x803ce7,0x8(%esp)
  802b58:	00 
  802b59:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802b60:	00 
  802b61:	c7 04 24 be 3c 80 00 	movl   $0x803cbe,(%esp)
  802b68:	e8 ba de ff ff       	call   800a27 <_panic>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802b6d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802b74:	00 
  802b75:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b7b:	89 04 24             	mov    %eax,(%esp)
  802b7e:	e8 ca eb ff ff       	call   80174d <sys_env_set_status>
  802b83:	85 c0                	test   %eax,%eax
  802b85:	79 30                	jns    802bb7 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  802b87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b8b:	c7 44 24 08 01 3d 80 	movl   $0x803d01,0x8(%esp)
  802b92:	00 
  802b93:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  802b9a:	00 
  802b9b:	c7 04 24 be 3c 80 00 	movl   $0x803cbe,(%esp)
  802ba2:	e8 80 de ff ff       	call   800a27 <_panic>
		return r;
  802ba7:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802bad:	eb 57                	jmp    802c06 <spawn+0x536>
		return r;
  802baf:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802bb5:	eb 4f                	jmp    802c06 <spawn+0x536>
	return child;
  802bb7:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802bbd:	eb 47                	jmp    802c06 <spawn+0x536>
		return -E_NO_MEM;
  802bbf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  802bc4:	eb 40                	jmp    802c06 <spawn+0x536>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802bc6:	89 c3                	mov    %eax,%ebx
  802bc8:	eb 06                	jmp    802bd0 <spawn+0x500>
			if ((r = seek(fd, fileoffset + i)) < 0)
  802bca:	89 c3                	mov    %eax,%ebx
  802bcc:	eb 02                	jmp    802bd0 <spawn+0x500>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802bce:	89 c3                	mov    %eax,%ebx
	sys_env_destroy(child);
  802bd0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802bd6:	89 04 24             	mov    %eax,(%esp)
  802bd9:	e8 e5 e9 ff ff       	call   8015c3 <sys_env_destroy>
	close(fd);
  802bde:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802be4:	89 04 24             	mov    %eax,(%esp)
  802be7:	e8 f6 f2 ff ff       	call   801ee2 <close>
	return r;
  802bec:	89 d8                	mov    %ebx,%eax
  802bee:	eb 16                	jmp    802c06 <spawn+0x536>
	sys_page_unmap(0, UTEMP);
  802bf0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802bf7:	00 
  802bf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bff:	e8 f6 ea ff ff       	call   8016fa <sys_page_unmap>
  802c04:	89 d8                	mov    %ebx,%eax
}
  802c06:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  802c0c:	5b                   	pop    %ebx
  802c0d:	5e                   	pop    %esi
  802c0e:	5f                   	pop    %edi
  802c0f:	5d                   	pop    %ebp
  802c10:	c3                   	ret    

00802c11 <spawnl>:
{
  802c11:	55                   	push   %ebp
  802c12:	89 e5                	mov    %esp,%ebp
  802c14:	56                   	push   %esi
  802c15:	53                   	push   %ebx
  802c16:	83 ec 10             	sub    $0x10,%esp
	while(va_arg(vl, void *) != NULL)
  802c19:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  802c1c:	ba 00 00 00 00       	mov    $0x0,%edx
	while(va_arg(vl, void *) != NULL)
  802c21:	eb 03                	jmp    802c26 <spawnl+0x15>
		argc++;
  802c23:	83 c2 01             	add    $0x1,%edx
	while(va_arg(vl, void *) != NULL)
  802c26:	83 c0 04             	add    $0x4,%eax
  802c29:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  802c2d:	75 f4                	jne    802c23 <spawnl+0x12>
	const char *argv[argc+2];
  802c2f:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  802c36:	83 e0 f0             	and    $0xfffffff0,%eax
  802c39:	29 c4                	sub    %eax,%esp
  802c3b:	8d 44 24 0b          	lea    0xb(%esp),%eax
  802c3f:	c1 e8 02             	shr    $0x2,%eax
  802c42:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  802c49:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c4e:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  802c55:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  802c5c:	00 
	for(i=0;i<argc;i++)
  802c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  802c62:	eb 0a                	jmp    802c6e <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  802c64:	83 c0 01             	add    $0x1,%eax
  802c67:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802c6b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	for(i=0;i<argc;i++)
  802c6e:	39 d0                	cmp    %edx,%eax
  802c70:	75 f2                	jne    802c64 <spawnl+0x53>
	return spawn(prog, argv);
  802c72:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c76:	8b 45 08             	mov    0x8(%ebp),%eax
  802c79:	89 04 24             	mov    %eax,(%esp)
  802c7c:	e8 4f fa ff ff       	call   8026d0 <spawn>
}
  802c81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c84:	5b                   	pop    %ebx
  802c85:	5e                   	pop    %esi
  802c86:	5d                   	pop    %ebp
  802c87:	c3                   	ret    

00802c88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802c88:	55                   	push   %ebp
  802c89:	89 e5                	mov    %esp,%ebp
  802c8b:	56                   	push   %esi
  802c8c:	53                   	push   %ebx
  802c8d:	83 ec 10             	sub    $0x10,%esp
  802c90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802c93:	8b 45 08             	mov    0x8(%ebp),%eax
  802c96:	89 04 24             	mov    %eax,(%esp)
  802c99:	e8 b2 f0 ff ff       	call   801d50 <fd2data>
  802c9e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ca0:	c7 44 24 04 3e 3d 80 	movl   $0x803d3e,0x4(%esp)
  802ca7:	00 
  802ca8:	89 1c 24             	mov    %ebx,(%esp)
  802cab:	e8 87 e5 ff ff       	call   801237 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802cb0:	8b 46 04             	mov    0x4(%esi),%eax
  802cb3:	2b 06                	sub    (%esi),%eax
  802cb5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802cbb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802cc2:	00 00 00 
	stat->st_dev = &devpipe;
  802cc5:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802ccc:	40 80 00 
	return 0;
}
  802ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  802cd4:	83 c4 10             	add    $0x10,%esp
  802cd7:	5b                   	pop    %ebx
  802cd8:	5e                   	pop    %esi
  802cd9:	5d                   	pop    %ebp
  802cda:	c3                   	ret    

00802cdb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802cdb:	55                   	push   %ebp
  802cdc:	89 e5                	mov    %esp,%ebp
  802cde:	53                   	push   %ebx
  802cdf:	83 ec 14             	sub    $0x14,%esp
  802ce2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802ce5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802ce9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cf0:	e8 05 ea ff ff       	call   8016fa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802cf5:	89 1c 24             	mov    %ebx,(%esp)
  802cf8:	e8 53 f0 ff ff       	call   801d50 <fd2data>
  802cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d08:	e8 ed e9 ff ff       	call   8016fa <sys_page_unmap>
}
  802d0d:	83 c4 14             	add    $0x14,%esp
  802d10:	5b                   	pop    %ebx
  802d11:	5d                   	pop    %ebp
  802d12:	c3                   	ret    

00802d13 <_pipeisclosed>:
{
  802d13:	55                   	push   %ebp
  802d14:	89 e5                	mov    %esp,%ebp
  802d16:	57                   	push   %edi
  802d17:	56                   	push   %esi
  802d18:	53                   	push   %ebx
  802d19:	83 ec 2c             	sub    $0x2c,%esp
  802d1c:	89 c6                	mov    %eax,%esi
  802d1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  802d21:	a1 24 54 80 00       	mov    0x805424,%eax
  802d26:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802d29:	89 34 24             	mov    %esi,(%esp)
  802d2c:	e8 f6 04 00 00       	call   803227 <pageref>
  802d31:	89 c7                	mov    %eax,%edi
  802d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d36:	89 04 24             	mov    %eax,(%esp)
  802d39:	e8 e9 04 00 00       	call   803227 <pageref>
  802d3e:	39 c7                	cmp    %eax,%edi
  802d40:	0f 94 c2             	sete   %dl
  802d43:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802d46:	8b 0d 24 54 80 00    	mov    0x805424,%ecx
  802d4c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802d4f:	39 fb                	cmp    %edi,%ebx
  802d51:	74 21                	je     802d74 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  802d53:	84 d2                	test   %dl,%dl
  802d55:	74 ca                	je     802d21 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802d57:	8b 51 58             	mov    0x58(%ecx),%edx
  802d5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d5e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802d62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802d66:	c7 04 24 45 3d 80 00 	movl   $0x803d45,(%esp)
  802d6d:	e8 ae dd ff ff       	call   800b20 <cprintf>
  802d72:	eb ad                	jmp    802d21 <_pipeisclosed+0xe>
}
  802d74:	83 c4 2c             	add    $0x2c,%esp
  802d77:	5b                   	pop    %ebx
  802d78:	5e                   	pop    %esi
  802d79:	5f                   	pop    %edi
  802d7a:	5d                   	pop    %ebp
  802d7b:	c3                   	ret    

00802d7c <devpipe_write>:
{
  802d7c:	55                   	push   %ebp
  802d7d:	89 e5                	mov    %esp,%ebp
  802d7f:	57                   	push   %edi
  802d80:	56                   	push   %esi
  802d81:	53                   	push   %ebx
  802d82:	83 ec 1c             	sub    $0x1c,%esp
  802d85:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802d88:	89 34 24             	mov    %esi,(%esp)
  802d8b:	e8 c0 ef ff ff       	call   801d50 <fd2data>
  802d90:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802d92:	bf 00 00 00 00       	mov    $0x0,%edi
  802d97:	eb 45                	jmp    802dde <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  802d99:	89 da                	mov    %ebx,%edx
  802d9b:	89 f0                	mov    %esi,%eax
  802d9d:	e8 71 ff ff ff       	call   802d13 <_pipeisclosed>
  802da2:	85 c0                	test   %eax,%eax
  802da4:	75 41                	jne    802de7 <devpipe_write+0x6b>
			sys_yield();
  802da6:	e8 89 e8 ff ff       	call   801634 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802dab:	8b 43 04             	mov    0x4(%ebx),%eax
  802dae:	8b 0b                	mov    (%ebx),%ecx
  802db0:	8d 51 20             	lea    0x20(%ecx),%edx
  802db3:	39 d0                	cmp    %edx,%eax
  802db5:	73 e2                	jae    802d99 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802dba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802dbe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802dc1:	99                   	cltd   
  802dc2:	c1 ea 1b             	shr    $0x1b,%edx
  802dc5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802dc8:	83 e1 1f             	and    $0x1f,%ecx
  802dcb:	29 d1                	sub    %edx,%ecx
  802dcd:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802dd1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802dd5:	83 c0 01             	add    $0x1,%eax
  802dd8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802ddb:	83 c7 01             	add    $0x1,%edi
  802dde:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802de1:	75 c8                	jne    802dab <devpipe_write+0x2f>
	return i;
  802de3:	89 f8                	mov    %edi,%eax
  802de5:	eb 05                	jmp    802dec <devpipe_write+0x70>
				return 0;
  802de7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802dec:	83 c4 1c             	add    $0x1c,%esp
  802def:	5b                   	pop    %ebx
  802df0:	5e                   	pop    %esi
  802df1:	5f                   	pop    %edi
  802df2:	5d                   	pop    %ebp
  802df3:	c3                   	ret    

00802df4 <devpipe_read>:
{
  802df4:	55                   	push   %ebp
  802df5:	89 e5                	mov    %esp,%ebp
  802df7:	57                   	push   %edi
  802df8:	56                   	push   %esi
  802df9:	53                   	push   %ebx
  802dfa:	83 ec 1c             	sub    $0x1c,%esp
  802dfd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802e00:	89 3c 24             	mov    %edi,(%esp)
  802e03:	e8 48 ef ff ff       	call   801d50 <fd2data>
  802e08:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802e0a:	be 00 00 00 00       	mov    $0x0,%esi
  802e0f:	eb 3d                	jmp    802e4e <devpipe_read+0x5a>
			if (i > 0)
  802e11:	85 f6                	test   %esi,%esi
  802e13:	74 04                	je     802e19 <devpipe_read+0x25>
				return i;
  802e15:	89 f0                	mov    %esi,%eax
  802e17:	eb 43                	jmp    802e5c <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  802e19:	89 da                	mov    %ebx,%edx
  802e1b:	89 f8                	mov    %edi,%eax
  802e1d:	e8 f1 fe ff ff       	call   802d13 <_pipeisclosed>
  802e22:	85 c0                	test   %eax,%eax
  802e24:	75 31                	jne    802e57 <devpipe_read+0x63>
			sys_yield();
  802e26:	e8 09 e8 ff ff       	call   801634 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802e2b:	8b 03                	mov    (%ebx),%eax
  802e2d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802e30:	74 df                	je     802e11 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802e32:	99                   	cltd   
  802e33:	c1 ea 1b             	shr    $0x1b,%edx
  802e36:	01 d0                	add    %edx,%eax
  802e38:	83 e0 1f             	and    $0x1f,%eax
  802e3b:	29 d0                	sub    %edx,%eax
  802e3d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e45:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802e48:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802e4b:	83 c6 01             	add    $0x1,%esi
  802e4e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802e51:	75 d8                	jne    802e2b <devpipe_read+0x37>
	return i;
  802e53:	89 f0                	mov    %esi,%eax
  802e55:	eb 05                	jmp    802e5c <devpipe_read+0x68>
				return 0;
  802e57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e5c:	83 c4 1c             	add    $0x1c,%esp
  802e5f:	5b                   	pop    %ebx
  802e60:	5e                   	pop    %esi
  802e61:	5f                   	pop    %edi
  802e62:	5d                   	pop    %ebp
  802e63:	c3                   	ret    

00802e64 <pipe>:
{
  802e64:	55                   	push   %ebp
  802e65:	89 e5                	mov    %esp,%ebp
  802e67:	56                   	push   %esi
  802e68:	53                   	push   %ebx
  802e69:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802e6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e6f:	89 04 24             	mov    %eax,(%esp)
  802e72:	e8 f0 ee ff ff       	call   801d67 <fd_alloc>
  802e77:	89 c2                	mov    %eax,%edx
  802e79:	85 d2                	test   %edx,%edx
  802e7b:	0f 88 4d 01 00 00    	js     802fce <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e81:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802e88:	00 
  802e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e97:	e8 b7 e7 ff ff       	call   801653 <sys_page_alloc>
  802e9c:	89 c2                	mov    %eax,%edx
  802e9e:	85 d2                	test   %edx,%edx
  802ea0:	0f 88 28 01 00 00    	js     802fce <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  802ea6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ea9:	89 04 24             	mov    %eax,(%esp)
  802eac:	e8 b6 ee ff ff       	call   801d67 <fd_alloc>
  802eb1:	89 c3                	mov    %eax,%ebx
  802eb3:	85 c0                	test   %eax,%eax
  802eb5:	0f 88 fe 00 00 00    	js     802fb9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ebb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802ec2:	00 
  802ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802eca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ed1:	e8 7d e7 ff ff       	call   801653 <sys_page_alloc>
  802ed6:	89 c3                	mov    %eax,%ebx
  802ed8:	85 c0                	test   %eax,%eax
  802eda:	0f 88 d9 00 00 00    	js     802fb9 <pipe+0x155>
	va = fd2data(fd0);
  802ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ee3:	89 04 24             	mov    %eax,(%esp)
  802ee6:	e8 65 ee ff ff       	call   801d50 <fd2data>
  802eeb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802eed:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802ef4:	00 
  802ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ef9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f00:	e8 4e e7 ff ff       	call   801653 <sys_page_alloc>
  802f05:	89 c3                	mov    %eax,%ebx
  802f07:	85 c0                	test   %eax,%eax
  802f09:	0f 88 97 00 00 00    	js     802fa6 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f12:	89 04 24             	mov    %eax,(%esp)
  802f15:	e8 36 ee ff ff       	call   801d50 <fd2data>
  802f1a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802f21:	00 
  802f22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802f26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f2d:	00 
  802f2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f39:	e8 69 e7 ff ff       	call   8016a7 <sys_page_map>
  802f3e:	89 c3                	mov    %eax,%ebx
  802f40:	85 c0                	test   %eax,%eax
  802f42:	78 52                	js     802f96 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  802f44:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f4d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  802f59:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f62:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f67:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f71:	89 04 24             	mov    %eax,(%esp)
  802f74:	e8 c7 ed ff ff       	call   801d40 <fd2num>
  802f79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802f7c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f81:	89 04 24             	mov    %eax,(%esp)
  802f84:	e8 b7 ed ff ff       	call   801d40 <fd2num>
  802f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802f8c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  802f94:	eb 38                	jmp    802fce <pipe+0x16a>
	sys_page_unmap(0, va);
  802f96:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fa1:	e8 54 e7 ff ff       	call   8016fa <sys_page_unmap>
	sys_page_unmap(0, fd1);
  802fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fb4:	e8 41 e7 ff ff       	call   8016fa <sys_page_unmap>
	sys_page_unmap(0, fd0);
  802fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fc7:	e8 2e e7 ff ff       	call   8016fa <sys_page_unmap>
  802fcc:	89 d8                	mov    %ebx,%eax
}
  802fce:	83 c4 30             	add    $0x30,%esp
  802fd1:	5b                   	pop    %ebx
  802fd2:	5e                   	pop    %esi
  802fd3:	5d                   	pop    %ebp
  802fd4:	c3                   	ret    

00802fd5 <pipeisclosed>:
{
  802fd5:	55                   	push   %ebp
  802fd6:	89 e5                	mov    %esp,%ebp
  802fd8:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802fdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fde:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  802fe5:	89 04 24             	mov    %eax,(%esp)
  802fe8:	e8 c9 ed ff ff       	call   801db6 <fd_lookup>
  802fed:	89 c2                	mov    %eax,%edx
  802fef:	85 d2                	test   %edx,%edx
  802ff1:	78 15                	js     803008 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  802ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ff6:	89 04 24             	mov    %eax,(%esp)
  802ff9:	e8 52 ed ff ff       	call   801d50 <fd2data>
	return _pipeisclosed(fd, p);
  802ffe:	89 c2                	mov    %eax,%edx
  803000:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803003:	e8 0b fd ff ff       	call   802d13 <_pipeisclosed>
}
  803008:	c9                   	leave  
  803009:	c3                   	ret    

0080300a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80300a:	55                   	push   %ebp
  80300b:	89 e5                	mov    %esp,%ebp
  80300d:	56                   	push   %esi
  80300e:	53                   	push   %ebx
  80300f:	83 ec 10             	sub    $0x10,%esp
  803012:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  803015:	85 f6                	test   %esi,%esi
  803017:	75 24                	jne    80303d <wait+0x33>
  803019:	c7 44 24 0c 5d 3d 80 	movl   $0x803d5d,0xc(%esp)
  803020:	00 
  803021:	c7 44 24 08 5b 36 80 	movl   $0x80365b,0x8(%esp)
  803028:	00 
  803029:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  803030:	00 
  803031:	c7 04 24 68 3d 80 00 	movl   $0x803d68,(%esp)
  803038:	e8 ea d9 ff ff       	call   800a27 <_panic>
	e = &envs[ENVX(envid)];
  80303d:	89 f3                	mov    %esi,%ebx
  80303f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  803045:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  803048:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80304e:	eb 05                	jmp    803055 <wait+0x4b>
		sys_yield();
  803050:	e8 df e5 ff ff       	call   801634 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803055:	8b 43 48             	mov    0x48(%ebx),%eax
  803058:	39 f0                	cmp    %esi,%eax
  80305a:	75 07                	jne    803063 <wait+0x59>
  80305c:	8b 43 54             	mov    0x54(%ebx),%eax
  80305f:	85 c0                	test   %eax,%eax
  803061:	75 ed                	jne    803050 <wait+0x46>
}
  803063:	83 c4 10             	add    $0x10,%esp
  803066:	5b                   	pop    %ebx
  803067:	5e                   	pop    %esi
  803068:	5d                   	pop    %ebp
  803069:	c3                   	ret    

0080306a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80306a:	55                   	push   %ebp
  80306b:	89 e5                	mov    %esp,%ebp
  80306d:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  803070:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  803077:	75 70                	jne    8030e9 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  803079:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  803080:	00 
  803081:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  803088:	ee 
  803089:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803090:	e8 be e5 ff ff       	call   801653 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  803095:	85 c0                	test   %eax,%eax
  803097:	79 1c                	jns    8030b5 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  803099:	c7 44 24 08 74 3d 80 	movl   $0x803d74,0x8(%esp)
  8030a0:	00 
  8030a1:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8030a8:	00 
  8030a9:	c7 04 24 d0 3d 80 00 	movl   $0x803dd0,(%esp)
  8030b0:	e8 72 d9 ff ff       	call   800a27 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  8030b5:	c7 44 24 04 f3 30 80 	movl   $0x8030f3,0x4(%esp)
  8030bc:	00 
  8030bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030c4:	e8 2a e7 ff ff       	call   8017f3 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8030c9:	85 c0                	test   %eax,%eax
  8030cb:	79 1c                	jns    8030e9 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  8030cd:	c7 44 24 08 9c 3d 80 	movl   $0x803d9c,0x8(%esp)
  8030d4:	00 
  8030d5:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8030dc:	00 
  8030dd:	c7 04 24 d0 3d 80 00 	movl   $0x803dd0,(%esp)
  8030e4:	e8 3e d9 ff ff       	call   800a27 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8030e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8030ec:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8030f1:	c9                   	leave  
  8030f2:	c3                   	ret    

008030f3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8030f3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8030f4:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8030f9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8030fb:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  8030fe:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  803102:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  803106:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  803108:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  80310a:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  80310b:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  80310e:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  803110:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  803113:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  803114:	83 c4 04             	add    $0x4,%esp
    popf;
  803117:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  803118:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  803119:	c3                   	ret    
  80311a:	66 90                	xchg   %ax,%ax
  80311c:	66 90                	xchg   %ax,%ax
  80311e:	66 90                	xchg   %ax,%ax

00803120 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803120:	55                   	push   %ebp
  803121:	89 e5                	mov    %esp,%ebp
  803123:	56                   	push   %esi
  803124:	53                   	push   %ebx
  803125:	83 ec 10             	sub    $0x10,%esp
  803128:	8b 75 08             	mov    0x8(%ebp),%esi
  80312b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80312e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  803131:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  803133:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  803138:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  80313b:	89 04 24             	mov    %eax,(%esp)
  80313e:	e8 26 e7 ff ff       	call   801869 <sys_ipc_recv>
    if(r < 0){
  803143:	85 c0                	test   %eax,%eax
  803145:	79 16                	jns    80315d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  803147:	85 f6                	test   %esi,%esi
  803149:	74 06                	je     803151 <ipc_recv+0x31>
            *from_env_store = 0;
  80314b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  803151:	85 db                	test   %ebx,%ebx
  803153:	74 2c                	je     803181 <ipc_recv+0x61>
            *perm_store = 0;
  803155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80315b:	eb 24                	jmp    803181 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  80315d:	85 f6                	test   %esi,%esi
  80315f:	74 0a                	je     80316b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  803161:	a1 24 54 80 00       	mov    0x805424,%eax
  803166:	8b 40 74             	mov    0x74(%eax),%eax
  803169:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  80316b:	85 db                	test   %ebx,%ebx
  80316d:	74 0a                	je     803179 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  80316f:	a1 24 54 80 00       	mov    0x805424,%eax
  803174:	8b 40 78             	mov    0x78(%eax),%eax
  803177:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  803179:	a1 24 54 80 00       	mov    0x805424,%eax
  80317e:	8b 40 70             	mov    0x70(%eax),%eax
}
  803181:	83 c4 10             	add    $0x10,%esp
  803184:	5b                   	pop    %ebx
  803185:	5e                   	pop    %esi
  803186:	5d                   	pop    %ebp
  803187:	c3                   	ret    

00803188 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803188:	55                   	push   %ebp
  803189:	89 e5                	mov    %esp,%ebp
  80318b:	57                   	push   %edi
  80318c:	56                   	push   %esi
  80318d:	53                   	push   %ebx
  80318e:	83 ec 1c             	sub    $0x1c,%esp
  803191:	8b 7d 08             	mov    0x8(%ebp),%edi
  803194:	8b 75 0c             	mov    0xc(%ebp),%esi
  803197:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80319a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80319c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8031a1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8031a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8031a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8031ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031b3:	89 3c 24             	mov    %edi,(%esp)
  8031b6:	e8 8b e6 ff ff       	call   801846 <sys_ipc_try_send>
        if(r == 0){
  8031bb:	85 c0                	test   %eax,%eax
  8031bd:	74 28                	je     8031e7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  8031bf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8031c2:	74 1c                	je     8031e0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  8031c4:	c7 44 24 08 de 3d 80 	movl   $0x803dde,0x8(%esp)
  8031cb:	00 
  8031cc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8031d3:	00 
  8031d4:	c7 04 24 f5 3d 80 00 	movl   $0x803df5,(%esp)
  8031db:	e8 47 d8 ff ff       	call   800a27 <_panic>
        }
        sys_yield();
  8031e0:	e8 4f e4 ff ff       	call   801634 <sys_yield>
    }
  8031e5:	eb bd                	jmp    8031a4 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8031e7:	83 c4 1c             	add    $0x1c,%esp
  8031ea:	5b                   	pop    %ebx
  8031eb:	5e                   	pop    %esi
  8031ec:	5f                   	pop    %edi
  8031ed:	5d                   	pop    %ebp
  8031ee:	c3                   	ret    

008031ef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8031ef:	55                   	push   %ebp
  8031f0:	89 e5                	mov    %esp,%ebp
  8031f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8031f5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8031fa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8031fd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803203:	8b 52 50             	mov    0x50(%edx),%edx
  803206:	39 ca                	cmp    %ecx,%edx
  803208:	75 0d                	jne    803217 <ipc_find_env+0x28>
			return envs[i].env_id;
  80320a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80320d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803212:	8b 40 40             	mov    0x40(%eax),%eax
  803215:	eb 0e                	jmp    803225 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  803217:	83 c0 01             	add    $0x1,%eax
  80321a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80321f:	75 d9                	jne    8031fa <ipc_find_env+0xb>
	return 0;
  803221:	66 b8 00 00          	mov    $0x0,%ax
}
  803225:	5d                   	pop    %ebp
  803226:	c3                   	ret    

00803227 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803227:	55                   	push   %ebp
  803228:	89 e5                	mov    %esp,%ebp
  80322a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80322d:	89 d0                	mov    %edx,%eax
  80322f:	c1 e8 16             	shr    $0x16,%eax
  803232:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803239:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80323e:	f6 c1 01             	test   $0x1,%cl
  803241:	74 1d                	je     803260 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  803243:	c1 ea 0c             	shr    $0xc,%edx
  803246:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80324d:	f6 c2 01             	test   $0x1,%dl
  803250:	74 0e                	je     803260 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803252:	c1 ea 0c             	shr    $0xc,%edx
  803255:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80325c:	ef 
  80325d:	0f b7 c0             	movzwl %ax,%eax
}
  803260:	5d                   	pop    %ebp
  803261:	c3                   	ret    
  803262:	66 90                	xchg   %ax,%ax
  803264:	66 90                	xchg   %ax,%ax
  803266:	66 90                	xchg   %ax,%ax
  803268:	66 90                	xchg   %ax,%ax
  80326a:	66 90                	xchg   %ax,%ax
  80326c:	66 90                	xchg   %ax,%ax
  80326e:	66 90                	xchg   %ax,%ax

00803270 <__udivdi3>:
  803270:	55                   	push   %ebp
  803271:	57                   	push   %edi
  803272:	56                   	push   %esi
  803273:	83 ec 0c             	sub    $0xc,%esp
  803276:	8b 44 24 28          	mov    0x28(%esp),%eax
  80327a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80327e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  803282:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  803286:	85 c0                	test   %eax,%eax
  803288:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80328c:	89 ea                	mov    %ebp,%edx
  80328e:	89 0c 24             	mov    %ecx,(%esp)
  803291:	75 2d                	jne    8032c0 <__udivdi3+0x50>
  803293:	39 e9                	cmp    %ebp,%ecx
  803295:	77 61                	ja     8032f8 <__udivdi3+0x88>
  803297:	85 c9                	test   %ecx,%ecx
  803299:	89 ce                	mov    %ecx,%esi
  80329b:	75 0b                	jne    8032a8 <__udivdi3+0x38>
  80329d:	b8 01 00 00 00       	mov    $0x1,%eax
  8032a2:	31 d2                	xor    %edx,%edx
  8032a4:	f7 f1                	div    %ecx
  8032a6:	89 c6                	mov    %eax,%esi
  8032a8:	31 d2                	xor    %edx,%edx
  8032aa:	89 e8                	mov    %ebp,%eax
  8032ac:	f7 f6                	div    %esi
  8032ae:	89 c5                	mov    %eax,%ebp
  8032b0:	89 f8                	mov    %edi,%eax
  8032b2:	f7 f6                	div    %esi
  8032b4:	89 ea                	mov    %ebp,%edx
  8032b6:	83 c4 0c             	add    $0xc,%esp
  8032b9:	5e                   	pop    %esi
  8032ba:	5f                   	pop    %edi
  8032bb:	5d                   	pop    %ebp
  8032bc:	c3                   	ret    
  8032bd:	8d 76 00             	lea    0x0(%esi),%esi
  8032c0:	39 e8                	cmp    %ebp,%eax
  8032c2:	77 24                	ja     8032e8 <__udivdi3+0x78>
  8032c4:	0f bd e8             	bsr    %eax,%ebp
  8032c7:	83 f5 1f             	xor    $0x1f,%ebp
  8032ca:	75 3c                	jne    803308 <__udivdi3+0x98>
  8032cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8032d0:	39 34 24             	cmp    %esi,(%esp)
  8032d3:	0f 86 9f 00 00 00    	jbe    803378 <__udivdi3+0x108>
  8032d9:	39 d0                	cmp    %edx,%eax
  8032db:	0f 82 97 00 00 00    	jb     803378 <__udivdi3+0x108>
  8032e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8032e8:	31 d2                	xor    %edx,%edx
  8032ea:	31 c0                	xor    %eax,%eax
  8032ec:	83 c4 0c             	add    $0xc,%esp
  8032ef:	5e                   	pop    %esi
  8032f0:	5f                   	pop    %edi
  8032f1:	5d                   	pop    %ebp
  8032f2:	c3                   	ret    
  8032f3:	90                   	nop
  8032f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8032f8:	89 f8                	mov    %edi,%eax
  8032fa:	f7 f1                	div    %ecx
  8032fc:	31 d2                	xor    %edx,%edx
  8032fe:	83 c4 0c             	add    $0xc,%esp
  803301:	5e                   	pop    %esi
  803302:	5f                   	pop    %edi
  803303:	5d                   	pop    %ebp
  803304:	c3                   	ret    
  803305:	8d 76 00             	lea    0x0(%esi),%esi
  803308:	89 e9                	mov    %ebp,%ecx
  80330a:	8b 3c 24             	mov    (%esp),%edi
  80330d:	d3 e0                	shl    %cl,%eax
  80330f:	89 c6                	mov    %eax,%esi
  803311:	b8 20 00 00 00       	mov    $0x20,%eax
  803316:	29 e8                	sub    %ebp,%eax
  803318:	89 c1                	mov    %eax,%ecx
  80331a:	d3 ef                	shr    %cl,%edi
  80331c:	89 e9                	mov    %ebp,%ecx
  80331e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803322:	8b 3c 24             	mov    (%esp),%edi
  803325:	09 74 24 08          	or     %esi,0x8(%esp)
  803329:	89 d6                	mov    %edx,%esi
  80332b:	d3 e7                	shl    %cl,%edi
  80332d:	89 c1                	mov    %eax,%ecx
  80332f:	89 3c 24             	mov    %edi,(%esp)
  803332:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803336:	d3 ee                	shr    %cl,%esi
  803338:	89 e9                	mov    %ebp,%ecx
  80333a:	d3 e2                	shl    %cl,%edx
  80333c:	89 c1                	mov    %eax,%ecx
  80333e:	d3 ef                	shr    %cl,%edi
  803340:	09 d7                	or     %edx,%edi
  803342:	89 f2                	mov    %esi,%edx
  803344:	89 f8                	mov    %edi,%eax
  803346:	f7 74 24 08          	divl   0x8(%esp)
  80334a:	89 d6                	mov    %edx,%esi
  80334c:	89 c7                	mov    %eax,%edi
  80334e:	f7 24 24             	mull   (%esp)
  803351:	39 d6                	cmp    %edx,%esi
  803353:	89 14 24             	mov    %edx,(%esp)
  803356:	72 30                	jb     803388 <__udivdi3+0x118>
  803358:	8b 54 24 04          	mov    0x4(%esp),%edx
  80335c:	89 e9                	mov    %ebp,%ecx
  80335e:	d3 e2                	shl    %cl,%edx
  803360:	39 c2                	cmp    %eax,%edx
  803362:	73 05                	jae    803369 <__udivdi3+0xf9>
  803364:	3b 34 24             	cmp    (%esp),%esi
  803367:	74 1f                	je     803388 <__udivdi3+0x118>
  803369:	89 f8                	mov    %edi,%eax
  80336b:	31 d2                	xor    %edx,%edx
  80336d:	e9 7a ff ff ff       	jmp    8032ec <__udivdi3+0x7c>
  803372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803378:	31 d2                	xor    %edx,%edx
  80337a:	b8 01 00 00 00       	mov    $0x1,%eax
  80337f:	e9 68 ff ff ff       	jmp    8032ec <__udivdi3+0x7c>
  803384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803388:	8d 47 ff             	lea    -0x1(%edi),%eax
  80338b:	31 d2                	xor    %edx,%edx
  80338d:	83 c4 0c             	add    $0xc,%esp
  803390:	5e                   	pop    %esi
  803391:	5f                   	pop    %edi
  803392:	5d                   	pop    %ebp
  803393:	c3                   	ret    
  803394:	66 90                	xchg   %ax,%ax
  803396:	66 90                	xchg   %ax,%ax
  803398:	66 90                	xchg   %ax,%ax
  80339a:	66 90                	xchg   %ax,%ax
  80339c:	66 90                	xchg   %ax,%ax
  80339e:	66 90                	xchg   %ax,%ax

008033a0 <__umoddi3>:
  8033a0:	55                   	push   %ebp
  8033a1:	57                   	push   %edi
  8033a2:	56                   	push   %esi
  8033a3:	83 ec 14             	sub    $0x14,%esp
  8033a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8033aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8033ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8033b2:	89 c7                	mov    %eax,%edi
  8033b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8033bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8033c0:	89 34 24             	mov    %esi,(%esp)
  8033c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8033c7:	85 c0                	test   %eax,%eax
  8033c9:	89 c2                	mov    %eax,%edx
  8033cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8033cf:	75 17                	jne    8033e8 <__umoddi3+0x48>
  8033d1:	39 fe                	cmp    %edi,%esi
  8033d3:	76 4b                	jbe    803420 <__umoddi3+0x80>
  8033d5:	89 c8                	mov    %ecx,%eax
  8033d7:	89 fa                	mov    %edi,%edx
  8033d9:	f7 f6                	div    %esi
  8033db:	89 d0                	mov    %edx,%eax
  8033dd:	31 d2                	xor    %edx,%edx
  8033df:	83 c4 14             	add    $0x14,%esp
  8033e2:	5e                   	pop    %esi
  8033e3:	5f                   	pop    %edi
  8033e4:	5d                   	pop    %ebp
  8033e5:	c3                   	ret    
  8033e6:	66 90                	xchg   %ax,%ax
  8033e8:	39 f8                	cmp    %edi,%eax
  8033ea:	77 54                	ja     803440 <__umoddi3+0xa0>
  8033ec:	0f bd e8             	bsr    %eax,%ebp
  8033ef:	83 f5 1f             	xor    $0x1f,%ebp
  8033f2:	75 5c                	jne    803450 <__umoddi3+0xb0>
  8033f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8033f8:	39 3c 24             	cmp    %edi,(%esp)
  8033fb:	0f 87 e7 00 00 00    	ja     8034e8 <__umoddi3+0x148>
  803401:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803405:	29 f1                	sub    %esi,%ecx
  803407:	19 c7                	sbb    %eax,%edi
  803409:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80340d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803411:	8b 44 24 08          	mov    0x8(%esp),%eax
  803415:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803419:	83 c4 14             	add    $0x14,%esp
  80341c:	5e                   	pop    %esi
  80341d:	5f                   	pop    %edi
  80341e:	5d                   	pop    %ebp
  80341f:	c3                   	ret    
  803420:	85 f6                	test   %esi,%esi
  803422:	89 f5                	mov    %esi,%ebp
  803424:	75 0b                	jne    803431 <__umoddi3+0x91>
  803426:	b8 01 00 00 00       	mov    $0x1,%eax
  80342b:	31 d2                	xor    %edx,%edx
  80342d:	f7 f6                	div    %esi
  80342f:	89 c5                	mov    %eax,%ebp
  803431:	8b 44 24 04          	mov    0x4(%esp),%eax
  803435:	31 d2                	xor    %edx,%edx
  803437:	f7 f5                	div    %ebp
  803439:	89 c8                	mov    %ecx,%eax
  80343b:	f7 f5                	div    %ebp
  80343d:	eb 9c                	jmp    8033db <__umoddi3+0x3b>
  80343f:	90                   	nop
  803440:	89 c8                	mov    %ecx,%eax
  803442:	89 fa                	mov    %edi,%edx
  803444:	83 c4 14             	add    $0x14,%esp
  803447:	5e                   	pop    %esi
  803448:	5f                   	pop    %edi
  803449:	5d                   	pop    %ebp
  80344a:	c3                   	ret    
  80344b:	90                   	nop
  80344c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803450:	8b 04 24             	mov    (%esp),%eax
  803453:	be 20 00 00 00       	mov    $0x20,%esi
  803458:	89 e9                	mov    %ebp,%ecx
  80345a:	29 ee                	sub    %ebp,%esi
  80345c:	d3 e2                	shl    %cl,%edx
  80345e:	89 f1                	mov    %esi,%ecx
  803460:	d3 e8                	shr    %cl,%eax
  803462:	89 e9                	mov    %ebp,%ecx
  803464:	89 44 24 04          	mov    %eax,0x4(%esp)
  803468:	8b 04 24             	mov    (%esp),%eax
  80346b:	09 54 24 04          	or     %edx,0x4(%esp)
  80346f:	89 fa                	mov    %edi,%edx
  803471:	d3 e0                	shl    %cl,%eax
  803473:	89 f1                	mov    %esi,%ecx
  803475:	89 44 24 08          	mov    %eax,0x8(%esp)
  803479:	8b 44 24 10          	mov    0x10(%esp),%eax
  80347d:	d3 ea                	shr    %cl,%edx
  80347f:	89 e9                	mov    %ebp,%ecx
  803481:	d3 e7                	shl    %cl,%edi
  803483:	89 f1                	mov    %esi,%ecx
  803485:	d3 e8                	shr    %cl,%eax
  803487:	89 e9                	mov    %ebp,%ecx
  803489:	09 f8                	or     %edi,%eax
  80348b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80348f:	f7 74 24 04          	divl   0x4(%esp)
  803493:	d3 e7                	shl    %cl,%edi
  803495:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803499:	89 d7                	mov    %edx,%edi
  80349b:	f7 64 24 08          	mull   0x8(%esp)
  80349f:	39 d7                	cmp    %edx,%edi
  8034a1:	89 c1                	mov    %eax,%ecx
  8034a3:	89 14 24             	mov    %edx,(%esp)
  8034a6:	72 2c                	jb     8034d4 <__umoddi3+0x134>
  8034a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8034ac:	72 22                	jb     8034d0 <__umoddi3+0x130>
  8034ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8034b2:	29 c8                	sub    %ecx,%eax
  8034b4:	19 d7                	sbb    %edx,%edi
  8034b6:	89 e9                	mov    %ebp,%ecx
  8034b8:	89 fa                	mov    %edi,%edx
  8034ba:	d3 e8                	shr    %cl,%eax
  8034bc:	89 f1                	mov    %esi,%ecx
  8034be:	d3 e2                	shl    %cl,%edx
  8034c0:	89 e9                	mov    %ebp,%ecx
  8034c2:	d3 ef                	shr    %cl,%edi
  8034c4:	09 d0                	or     %edx,%eax
  8034c6:	89 fa                	mov    %edi,%edx
  8034c8:	83 c4 14             	add    $0x14,%esp
  8034cb:	5e                   	pop    %esi
  8034cc:	5f                   	pop    %edi
  8034cd:	5d                   	pop    %ebp
  8034ce:	c3                   	ret    
  8034cf:	90                   	nop
  8034d0:	39 d7                	cmp    %edx,%edi
  8034d2:	75 da                	jne    8034ae <__umoddi3+0x10e>
  8034d4:	8b 14 24             	mov    (%esp),%edx
  8034d7:	89 c1                	mov    %eax,%ecx
  8034d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8034dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8034e1:	eb cb                	jmp    8034ae <__umoddi3+0x10e>
  8034e3:	90                   	nop
  8034e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8034e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8034ec:	0f 82 0f ff ff ff    	jb     803401 <__umoddi3+0x61>
  8034f2:	e9 1a ff ff ff       	jmp    803411 <__umoddi3+0x71>
