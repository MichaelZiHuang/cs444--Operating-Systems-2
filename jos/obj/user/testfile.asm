
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 52 07 00 00       	call   800783 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800040:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800047:	e8 bb 0e 00 00       	call   800f07 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004c:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800052:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800059:	e8 01 16 00 00       	call   80165f <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800065:	00 
  800066:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80006d:	00 
  80006e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800075:	00 
  800076:	89 04 24             	mov    %eax,(%esp)
  800079:	e8 7a 15 00 00       	call   8015f8 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800085:	00 
  800086:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008d:	cc 
  80008e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800095:	e8 f6 14 00 00       	call   801590 <ipc_recv>
}
  80009a:	83 c4 14             	add    $0x14,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <umain>:

void
umain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b1:	b8 00 27 80 00       	mov    $0x802700,%eax
  8000b6:	e8 78 ff ff ff       	call   800033 <xopen>
  8000bb:	85 c0                	test   %eax,%eax
  8000bd:	79 25                	jns    8000e4 <umain+0x44>
  8000bf:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c2:	74 3c                	je     800100 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c8:	c7 44 24 08 0b 27 80 	movl   $0x80270b,0x8(%esp)
  8000cf:	00 
  8000d0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d7:	00 
  8000d8:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8000df:	e8 00 07 00 00       	call   8007e4 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e4:	c7 44 24 08 c0 28 80 	movl   $0x8028c0,0x8(%esp)
  8000eb:	00 
  8000ec:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f3:	00 
  8000f4:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8000fb:	e8 e4 06 00 00       	call   8007e4 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800100:	ba 00 00 00 00       	mov    $0x0,%edx
  800105:	b8 35 27 80 00       	mov    $0x802735,%eax
  80010a:	e8 24 ff ff ff       	call   800033 <xopen>
  80010f:	85 c0                	test   %eax,%eax
  800111:	79 20                	jns    800133 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	c7 44 24 08 3e 27 80 	movl   $0x80273e,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80012e:	e8 b1 06 00 00       	call   8007e4 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800133:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013a:	75 12                	jne    80014e <umain+0xae>
  80013c:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800143:	75 09                	jne    80014e <umain+0xae>
  800145:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014c:	74 1c                	je     80016a <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014e:	c7 44 24 08 e4 28 80 	movl   $0x8028e4,0x8(%esp)
  800155:	00 
  800156:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  800165:	e8 7a 06 00 00       	call   8007e4 <_panic>
	cprintf("serve_open is good\n");
  80016a:	c7 04 24 56 27 80 00 	movl   $0x802756,(%esp)
  800171:	e8 67 07 00 00       	call   8008dd <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800176:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800187:	ff 15 1c 30 80 00    	call   *0x80301c
  80018d:	85 c0                	test   %eax,%eax
  80018f:	79 20                	jns    8001b1 <umain+0x111>
		panic("file_stat: %e", r);
  800191:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800195:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  80019c:	00 
  80019d:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a4:	00 
  8001a5:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8001ac:	e8 33 06 00 00       	call   8007e4 <_panic>
	if (strlen(msg) != st.st_size)
  8001b1:	a1 00 30 80 00       	mov    0x803000,%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 12 0d 00 00       	call   800ed0 <strlen>
  8001be:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c1:	74 34                	je     8001f7 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c3:	a1 00 30 80 00       	mov    0x803000,%eax
  8001c8:	89 04 24             	mov    %eax,(%esp)
  8001cb:	e8 00 0d 00 00       	call   800ed0 <strlen>
  8001d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001db:	c7 44 24 08 14 29 80 	movl   $0x802914,0x8(%esp)
  8001e2:	00 
  8001e3:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001ea:	00 
  8001eb:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8001f2:	e8 ed 05 00 00       	call   8007e4 <_panic>
	cprintf("file_stat is good\n");
  8001f7:	c7 04 24 78 27 80 00 	movl   $0x802778,(%esp)
  8001fe:	e8 da 06 00 00       	call   8008dd <cprintf>

	memset(buf, 0, sizeof buf);
  800203:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020a:	00 
  80020b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800212:	00 
  800213:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800219:	89 1c 24             	mov    %ebx,(%esp)
  80021c:	e8 36 0e 00 00       	call   801057 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800221:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800228:	00 
  800229:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022d:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800234:	ff 15 10 30 80 00    	call   *0x803010
  80023a:	85 c0                	test   %eax,%eax
  80023c:	79 20                	jns    80025e <umain+0x1be>
		panic("file_read: %e", r);
  80023e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800242:	c7 44 24 08 8b 27 80 	movl   $0x80278b,0x8(%esp)
  800249:	00 
  80024a:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800251:	00 
  800252:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  800259:	e8 86 05 00 00       	call   8007e4 <_panic>
	if (strcmp(buf, msg) != 0)
  80025e:	a1 00 30 80 00       	mov    0x803000,%eax
  800263:	89 44 24 04          	mov    %eax,0x4(%esp)
  800267:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026d:	89 04 24             	mov    %eax,(%esp)
  800270:	e8 47 0d 00 00       	call   800fbc <strcmp>
  800275:	85 c0                	test   %eax,%eax
  800277:	74 1c                	je     800295 <umain+0x1f5>
		panic("file_read returned wrong data");
  800279:	c7 44 24 08 99 27 80 	movl   $0x802799,0x8(%esp)
  800280:	00 
  800281:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800288:	00 
  800289:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  800290:	e8 4f 05 00 00       	call   8007e4 <_panic>
	cprintf("file_read is good\n");
  800295:	c7 04 24 b7 27 80 00 	movl   $0x8027b7,(%esp)
  80029c:	e8 3c 06 00 00       	call   8008dd <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a1:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a8:	ff 15 18 30 80 00    	call   *0x803018
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	79 20                	jns    8002d2 <umain+0x232>
		panic("file_close: %e", r);
  8002b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b6:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8002cd:	e8 12 05 00 00       	call   8007e4 <_panic>
	cprintf("file_close is good\n");
  8002d2:	c7 04 24 d9 27 80 00 	movl   $0x8027d9,(%esp)
  8002d9:	e8 ff 05 00 00       	call   8008dd <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002de:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8002e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e6:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8002eb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002ee:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8002f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f6:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8002fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8002fe:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800305:	cc 
  800306:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80030d:	e8 b8 10 00 00       	call   8013ca <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800312:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800319:	00 
  80031a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800320:	89 44 24 04          	mov    %eax,0x4(%esp)
  800324:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	ff 15 10 30 80 00    	call   *0x803010
  800330:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800333:	74 20                	je     800355 <umain+0x2b5>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800339:	c7 44 24 08 3c 29 80 	movl   $0x80293c,0x8(%esp)
  800340:	00 
  800341:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800348:	00 
  800349:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  800350:	e8 8f 04 00 00       	call   8007e4 <_panic>
	cprintf("stale fileid is good\n");
  800355:	c7 04 24 ed 27 80 00 	movl   $0x8027ed,(%esp)
  80035c:	e8 7c 05 00 00       	call   8008dd <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800361:	ba 02 01 00 00       	mov    $0x102,%edx
  800366:	b8 03 28 80 00       	mov    $0x802803,%eax
  80036b:	e8 c3 fc ff ff       	call   800033 <xopen>
  800370:	85 c0                	test   %eax,%eax
  800372:	79 20                	jns    800394 <umain+0x2f4>
		panic("serve_open /new-file: %e", r);
  800374:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800378:	c7 44 24 08 0d 28 80 	movl   $0x80280d,0x8(%esp)
  80037f:	00 
  800380:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800387:	00 
  800388:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80038f:	e8 50 04 00 00       	call   8007e4 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800394:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  80039a:	a1 00 30 80 00       	mov    0x803000,%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	e8 29 0b 00 00       	call   800ed0 <strlen>
  8003a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ab:	a1 00 30 80 00       	mov    0x803000,%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003bb:	ff d3                	call   *%ebx
  8003bd:	89 c3                	mov    %eax,%ebx
  8003bf:	a1 00 30 80 00       	mov    0x803000,%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 04 0b 00 00       	call   800ed0 <strlen>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	74 20                	je     8003f0 <umain+0x350>
		panic("file_write: %e", r);
  8003d0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d4:	c7 44 24 08 26 28 80 	movl   $0x802826,0x8(%esp)
  8003db:	00 
  8003dc:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003e3:	00 
  8003e4:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8003eb:	e8 f4 03 00 00       	call   8007e4 <_panic>
	cprintf("file_write is good\n");
  8003f0:	c7 04 24 35 28 80 00 	movl   $0x802835,(%esp)
  8003f7:	e8 e1 04 00 00       	call   8008dd <cprintf>

	FVA->fd_offset = 0;
  8003fc:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800403:	00 00 00 
	memset(buf, 0, sizeof buf);
  800406:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80040d:	00 
  80040e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800415:	00 
  800416:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80041c:	89 1c 24             	mov    %ebx,(%esp)
  80041f:	e8 33 0c 00 00       	call   801057 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800424:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80042b:	00 
  80042c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800430:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800437:	ff 15 10 30 80 00    	call   *0x803010
  80043d:	89 c3                	mov    %eax,%ebx
  80043f:	85 c0                	test   %eax,%eax
  800441:	79 20                	jns    800463 <umain+0x3c3>
		panic("file_read after file_write: %e", r);
  800443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800447:	c7 44 24 08 74 29 80 	movl   $0x802974,0x8(%esp)
  80044e:	00 
  80044f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800456:	00 
  800457:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80045e:	e8 81 03 00 00       	call   8007e4 <_panic>
	if (r != strlen(msg))
  800463:	a1 00 30 80 00       	mov    0x803000,%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	e8 60 0a 00 00       	call   800ed0 <strlen>
  800470:	39 d8                	cmp    %ebx,%eax
  800472:	74 20                	je     800494 <umain+0x3f4>
		panic("file_read after file_write returned wrong length: %d", r);
  800474:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800478:	c7 44 24 08 94 29 80 	movl   $0x802994,0x8(%esp)
  80047f:	00 
  800480:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800487:	00 
  800488:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80048f:	e8 50 03 00 00       	call   8007e4 <_panic>
	if (strcmp(buf, msg) != 0)
  800494:	a1 00 30 80 00       	mov    0x803000,%eax
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	e8 11 0b 00 00       	call   800fbc <strcmp>
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	74 1c                	je     8004cb <umain+0x42b>
		panic("file_read after file_write returned wrong data");
  8004af:	c7 44 24 08 cc 29 80 	movl   $0x8029cc,0x8(%esp)
  8004b6:	00 
  8004b7:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004be:	00 
  8004bf:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8004c6:	e8 19 03 00 00       	call   8007e4 <_panic>
	cprintf("file_read after file_write is good\n");
  8004cb:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8004d2:	e8 06 04 00 00       	call   8008dd <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004de:	00 
  8004df:	c7 04 24 00 27 80 00 	movl   $0x802700,(%esp)
  8004e6:	e8 66 19 00 00       	call   801e51 <open>
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	79 25                	jns    800514 <umain+0x474>
  8004ef:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004f2:	74 3c                	je     800530 <umain+0x490>
		panic("open /not-found: %e", r);
  8004f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f8:	c7 44 24 08 11 27 80 	movl   $0x802711,0x8(%esp)
  8004ff:	00 
  800500:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800507:	00 
  800508:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80050f:	e8 d0 02 00 00       	call   8007e4 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800514:	c7 44 24 08 49 28 80 	movl   $0x802849,0x8(%esp)
  80051b:	00 
  80051c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800523:	00 
  800524:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80052b:	e8 b4 02 00 00       	call   8007e4 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800530:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800537:	00 
  800538:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  80053f:	e8 0d 19 00 00       	call   801e51 <open>
  800544:	85 c0                	test   %eax,%eax
  800546:	79 20                	jns    800568 <umain+0x4c8>
		panic("open /newmotd: %e", r);
  800548:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054c:	c7 44 24 08 44 27 80 	movl   $0x802744,0x8(%esp)
  800553:	00 
  800554:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80055b:	00 
  80055c:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  800563:	e8 7c 02 00 00       	call   8007e4 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800568:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80056b:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800572:	75 12                	jne    800586 <umain+0x4e6>
  800574:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  80057b:	75 09                	jne    800586 <umain+0x4e6>
  80057d:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  800584:	74 1c                	je     8005a2 <umain+0x502>
		panic("open did not fill struct Fd correctly\n");
  800586:	c7 44 24 08 20 2a 80 	movl   $0x802a20,0x8(%esp)
  80058d:	00 
  80058e:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800595:	00 
  800596:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80059d:	e8 42 02 00 00       	call   8007e4 <_panic>
	cprintf("open is good\n");
  8005a2:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  8005a9:	e8 2f 03 00 00       	call   8008dd <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8005ae:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005b5:	00 
  8005b6:	c7 04 24 64 28 80 00 	movl   $0x802864,(%esp)
  8005bd:	e8 8f 18 00 00       	call   801e51 <open>
  8005c2:	89 c6                	mov    %eax,%esi
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	79 20                	jns    8005e8 <umain+0x548>
		panic("creat /big: %e", f);
  8005c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cc:	c7 44 24 08 69 28 80 	movl   $0x802869,0x8(%esp)
  8005d3:	00 
  8005d4:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005db:	00 
  8005dc:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8005e3:	e8 fc 01 00 00       	call   8007e4 <_panic>
	memset(buf, 0, sizeof(buf));
  8005e8:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005ef:	00 
  8005f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005f7:	00 
  8005f8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	e8 51 0a 00 00       	call   801057 <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800606:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  80060b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
		*(int*)buf = i;
  800611:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800617:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80061e:	00 
  80061f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	e8 57 14 00 00       	call   801a82 <write>
  80062b:	85 c0                	test   %eax,%eax
  80062d:	79 24                	jns    800653 <umain+0x5b3>
			panic("write /big@%d: %e", i, r);
  80062f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800633:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800637:	c7 44 24 08 78 28 80 	movl   $0x802878,0x8(%esp)
  80063e:	00 
  80063f:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800646:	00 
  800647:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80064e:	e8 91 01 00 00       	call   8007e4 <_panic>
  800653:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  800659:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80065b:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800660:	75 af                	jne    800611 <umain+0x571>
	}
	close(f);
  800662:	89 34 24             	mov    %esi,(%esp)
  800665:	e8 d8 11 00 00       	call   801842 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80066a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800671:	00 
  800672:	c7 04 24 64 28 80 00 	movl   $0x802864,(%esp)
  800679:	e8 d3 17 00 00       	call   801e51 <open>
  80067e:	89 c6                	mov    %eax,%esi
  800680:	85 c0                	test   %eax,%eax
  800682:	79 20                	jns    8006a4 <umain+0x604>
		panic("open /big: %e", f);
  800684:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800688:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  80068f:	00 
  800690:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800697:	00 
  800698:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80069f:	e8 40 01 00 00       	call   8007e4 <_panic>
	if ((f = open("/big", O_RDONLY)) < 0)
  8006a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006a9:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
		*(int*)buf = i;
  8006af:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006b5:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006bc:	00 
  8006bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c1:	89 34 24             	mov    %esi,(%esp)
  8006c4:	e8 6e 13 00 00       	call   801a37 <readn>
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	79 24                	jns    8006f1 <umain+0x651>
			panic("read /big@%d: %e", i, r);
  8006cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d5:	c7 44 24 08 98 28 80 	movl   $0x802898,0x8(%esp)
  8006dc:	00 
  8006dd:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006e4:	00 
  8006e5:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8006ec:	e8 f3 00 00 00       	call   8007e4 <_panic>
		if (r != sizeof(buf))
  8006f1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006f6:	74 2c                	je     800724 <umain+0x684>
			panic("read /big from %d returned %d < %d bytes",
  8006f8:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006ff:	00 
  800700:	89 44 24 10          	mov    %eax,0x10(%esp)
  800704:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800708:	c7 44 24 08 48 2a 80 	movl   $0x802a48,0x8(%esp)
  80070f:	00 
  800710:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800717:	00 
  800718:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80071f:	e8 c0 00 00 00       	call   8007e4 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800724:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  80072a:	39 d8                	cmp    %ebx,%eax
  80072c:	74 24                	je     800752 <umain+0x6b2>
			panic("read /big from %d returned bad data %d",
  80072e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800732:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800736:	c7 44 24 08 74 2a 80 	movl   $0x802a74,0x8(%esp)
  80073d:	00 
  80073e:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800745:	00 
  800746:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  80074d:	e8 92 00 00 00       	call   8007e4 <_panic>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800752:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  800758:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  80075e:	0f 8e 4b ff ff ff    	jle    8006af <umain+0x60f>
			      i, *(int*)buf);
	}
	close(f);
  800764:	89 34 24             	mov    %esi,(%esp)
  800767:	e8 d6 10 00 00       	call   801842 <close>
	cprintf("large file is good\n");
  80076c:	c7 04 24 a9 28 80 00 	movl   $0x8028a9,(%esp)
  800773:	e8 65 01 00 00       	call   8008dd <cprintf>
}
  800778:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  80077e:	5b                   	pop    %ebx
  80077f:	5e                   	pop    %esi
  800780:	5f                   	pop    %edi
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	56                   	push   %esi
  800787:	53                   	push   %ebx
  800788:	83 ec 10             	sub    $0x10,%esp
  80078b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80078e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800791:	e8 4f 0b 00 00       	call   8012e5 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800796:	25 ff 03 00 00       	and    $0x3ff,%eax
  80079b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80079e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007a3:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007a8:	85 db                	test   %ebx,%ebx
  8007aa:	7e 07                	jle    8007b3 <libmain+0x30>
		binaryname = argv[0];
  8007ac:	8b 06                	mov    (%esi),%eax
  8007ae:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8007b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b7:	89 1c 24             	mov    %ebx,(%esp)
  8007ba:	e8 e1 f8 ff ff       	call   8000a0 <umain>

	// exit gracefully
	exit();
  8007bf:	e8 07 00 00 00       	call   8007cb <exit>
}
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007d1:	e8 9f 10 00 00       	call   801875 <close_all>
	sys_env_destroy(0);
  8007d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007dd:	e8 b1 0a 00 00       	call   801293 <sys_env_destroy>
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
  8007e9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ec:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007ef:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8007f5:	e8 eb 0a 00 00       	call   8012e5 <sys_getenvid>
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800801:	8b 55 08             	mov    0x8(%ebp),%edx
  800804:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800808:	89 74 24 08          	mov    %esi,0x8(%esp)
  80080c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800810:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  800817:	e8 c1 00 00 00       	call   8008dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80081c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800820:	8b 45 10             	mov    0x10(%ebp),%eax
  800823:	89 04 24             	mov    %eax,(%esp)
  800826:	e8 51 00 00 00       	call   80087c <vcprintf>
	cprintf("\n");
  80082b:	c7 04 24 45 2f 80 00 	movl   $0x802f45,(%esp)
  800832:	e8 a6 00 00 00       	call   8008dd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800837:	cc                   	int3   
  800838:	eb fd                	jmp    800837 <_panic+0x53>

0080083a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800844:	8b 13                	mov    (%ebx),%edx
  800846:	8d 42 01             	lea    0x1(%edx),%eax
  800849:	89 03                	mov    %eax,(%ebx)
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800852:	3d ff 00 00 00       	cmp    $0xff,%eax
  800857:	75 19                	jne    800872 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800859:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800860:	00 
  800861:	8d 43 08             	lea    0x8(%ebx),%eax
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	e8 ea 09 00 00       	call   801256 <sys_cputs>
		b->idx = 0;
  80086c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800872:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800876:	83 c4 14             	add    $0x14,%esp
  800879:	5b                   	pop    %ebx
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800885:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80088c:	00 00 00 
	b.cnt = 0;
  80088f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800896:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	c7 04 24 3a 08 80 00 	movl   $0x80083a,(%esp)
  8008b8:	e8 b1 01 00 00       	call   800a6e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008bd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008cd:	89 04 24             	mov    %eax,(%esp)
  8008d0:	e8 81 09 00 00       	call   801256 <sys_cputs>

	return b.cnt;
}
  8008d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008e3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	e8 87 ff ff ff       	call   80087c <vcprintf>
	va_end(ap);

	return cnt;
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    
  8008f7:	66 90                	xchg   %ax,%ax
  8008f9:	66 90                	xchg   %ax,%ax
  8008fb:	66 90                	xchg   %ax,%ax
  8008fd:	66 90                	xchg   %ax,%ax
  8008ff:	90                   	nop

00800900 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	83 ec 3c             	sub    $0x3c,%esp
  800909:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80090c:	89 d7                	mov    %edx,%edi
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	89 c3                	mov    %eax,%ebx
  800919:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80091c:	8b 45 10             	mov    0x10(%ebp),%eax
  80091f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800922:	b9 00 00 00 00       	mov    $0x0,%ecx
  800927:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80092d:	39 d9                	cmp    %ebx,%ecx
  80092f:	72 05                	jb     800936 <printnum+0x36>
  800931:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800934:	77 69                	ja     80099f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800936:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800939:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80093d:	83 ee 01             	sub    $0x1,%esi
  800940:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800944:	89 44 24 08          	mov    %eax,0x8(%esp)
  800948:	8b 44 24 08          	mov    0x8(%esp),%eax
  80094c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	89 d6                	mov    %edx,%esi
  800954:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800957:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80095a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80095e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800962:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80096b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096f:	e8 ec 1a 00 00       	call   802460 <__udivdi3>
  800974:	89 d9                	mov    %ebx,%ecx
  800976:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80097a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80097e:	89 04 24             	mov    %eax,(%esp)
  800981:	89 54 24 04          	mov    %edx,0x4(%esp)
  800985:	89 fa                	mov    %edi,%edx
  800987:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80098a:	e8 71 ff ff ff       	call   800900 <printnum>
  80098f:	eb 1b                	jmp    8009ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800991:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800995:	8b 45 18             	mov    0x18(%ebp),%eax
  800998:	89 04 24             	mov    %eax,(%esp)
  80099b:	ff d3                	call   *%ebx
  80099d:	eb 03                	jmp    8009a2 <printnum+0xa2>
  80099f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8009a2:	83 ee 01             	sub    $0x1,%esi
  8009a5:	85 f6                	test   %esi,%esi
  8009a7:	7f e8                	jg     800991 <printnum+0x91>
  8009a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	e8 bc 1b 00 00       	call   802590 <__umoddi3>
  8009d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009d8:	0f be 80 ef 2a 80 00 	movsbl 0x802aef(%eax),%eax
  8009df:	89 04 24             	mov    %eax,(%esp)
  8009e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009e5:	ff d0                	call   *%eax
}
  8009e7:	83 c4 3c             	add    $0x3c,%esp
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009f2:	83 fa 01             	cmp    $0x1,%edx
  8009f5:	7e 0e                	jle    800a05 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009f7:	8b 10                	mov    (%eax),%edx
  8009f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009fc:	89 08                	mov    %ecx,(%eax)
  8009fe:	8b 02                	mov    (%edx),%eax
  800a00:	8b 52 04             	mov    0x4(%edx),%edx
  800a03:	eb 22                	jmp    800a27 <getuint+0x38>
	else if (lflag)
  800a05:	85 d2                	test   %edx,%edx
  800a07:	74 10                	je     800a19 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800a09:	8b 10                	mov    (%eax),%edx
  800a0b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a0e:	89 08                	mov    %ecx,(%eax)
  800a10:	8b 02                	mov    (%edx),%eax
  800a12:	ba 00 00 00 00       	mov    $0x0,%edx
  800a17:	eb 0e                	jmp    800a27 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a19:	8b 10                	mov    (%eax),%edx
  800a1b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a1e:	89 08                	mov    %ecx,(%eax)
  800a20:	8b 02                	mov    (%edx),%eax
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a2f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a33:	8b 10                	mov    (%eax),%edx
  800a35:	3b 50 04             	cmp    0x4(%eax),%edx
  800a38:	73 0a                	jae    800a44 <sprintputch+0x1b>
		*b->buf++ = ch;
  800a3a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a3d:	89 08                	mov    %ecx,(%eax)
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	88 02                	mov    %al,(%edx)
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <printfmt>:
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800a4c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a53:	8b 45 10             	mov    0x10(%ebp),%eax
  800a56:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	89 04 24             	mov    %eax,(%esp)
  800a67:	e8 02 00 00 00       	call   800a6e <vprintfmt>
}
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <vprintfmt>:
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	83 ec 3c             	sub    $0x3c,%esp
  800a77:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a7d:	eb 1f                	jmp    800a9e <vprintfmt+0x30>
			if (ch == '\0'){
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	75 0f                	jne    800a92 <vprintfmt+0x24>
				color = 0x0100;
  800a83:	c7 05 00 40 80 00 00 	movl   $0x100,0x804000
  800a8a:	01 00 00 
  800a8d:	e9 b3 03 00 00       	jmp    800e45 <vprintfmt+0x3d7>
			putch(ch, putdat);
  800a92:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a96:	89 04 24             	mov    %eax,(%esp)
  800a99:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	8d 73 01             	lea    0x1(%ebx),%esi
  800aa1:	0f b6 03             	movzbl (%ebx),%eax
  800aa4:	83 f8 25             	cmp    $0x25,%eax
  800aa7:	75 d6                	jne    800a7f <vprintfmt+0x11>
  800aa9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800aad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800ab4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800abb:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	eb 1d                	jmp    800ae6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800ac9:	89 de                	mov    %ebx,%esi
			padc = '-';
  800acb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800acf:	eb 15                	jmp    800ae6 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  800ad1:	89 de                	mov    %ebx,%esi
			padc = '0';
  800ad3:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800ad7:	eb 0d                	jmp    800ae6 <vprintfmt+0x78>
				width = precision, precision = -1;
  800ad9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800adc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800adf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800ae6:	8d 5e 01             	lea    0x1(%esi),%ebx
  800ae9:	0f b6 0e             	movzbl (%esi),%ecx
  800aec:	0f b6 c1             	movzbl %cl,%eax
  800aef:	83 e9 23             	sub    $0x23,%ecx
  800af2:	80 f9 55             	cmp    $0x55,%cl
  800af5:	0f 87 2a 03 00 00    	ja     800e25 <vprintfmt+0x3b7>
  800afb:	0f b6 c9             	movzbl %cl,%ecx
  800afe:	ff 24 8d 40 2c 80 00 	jmp    *0x802c40(,%ecx,4)
  800b05:	89 de                	mov    %ebx,%esi
  800b07:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  800b0c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800b0f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800b13:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800b16:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800b19:	83 fb 09             	cmp    $0x9,%ebx
  800b1c:	77 36                	ja     800b54 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  800b1e:	83 c6 01             	add    $0x1,%esi
			}
  800b21:	eb e9                	jmp    800b0c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  800b23:	8b 45 14             	mov    0x14(%ebp),%eax
  800b26:	8d 48 04             	lea    0x4(%eax),%ecx
  800b29:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b2c:	8b 00                	mov    (%eax),%eax
  800b2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800b31:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800b33:	eb 22                	jmp    800b57 <vprintfmt+0xe9>
  800b35:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b38:	85 c9                	test   %ecx,%ecx
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	0f 49 c1             	cmovns %ecx,%eax
  800b42:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800b45:	89 de                	mov    %ebx,%esi
  800b47:	eb 9d                	jmp    800ae6 <vprintfmt+0x78>
  800b49:	89 de                	mov    %ebx,%esi
			altflag = 1;
  800b4b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800b52:	eb 92                	jmp    800ae6 <vprintfmt+0x78>
  800b54:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  800b57:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b5b:	79 89                	jns    800ae6 <vprintfmt+0x78>
  800b5d:	e9 77 ff ff ff       	jmp    800ad9 <vprintfmt+0x6b>
			lflag++;
  800b62:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800b65:	89 de                	mov    %ebx,%esi
			goto reswitch;
  800b67:	e9 7a ff ff ff       	jmp    800ae6 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  800b6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6f:	8d 50 04             	lea    0x4(%eax),%edx
  800b72:	89 55 14             	mov    %edx,0x14(%ebp)
  800b75:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b79:	8b 00                	mov    (%eax),%eax
  800b7b:	89 04 24             	mov    %eax,(%esp)
  800b7e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b81:	e9 18 ff ff ff       	jmp    800a9e <vprintfmt+0x30>
			err = va_arg(ap, int);
  800b86:	8b 45 14             	mov    0x14(%ebp),%eax
  800b89:	8d 50 04             	lea    0x4(%eax),%edx
  800b8c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b8f:	8b 00                	mov    (%eax),%eax
  800b91:	99                   	cltd   
  800b92:	31 d0                	xor    %edx,%eax
  800b94:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b96:	83 f8 0f             	cmp    $0xf,%eax
  800b99:	7f 0b                	jg     800ba6 <vprintfmt+0x138>
  800b9b:	8b 14 85 a0 2d 80 00 	mov    0x802da0(,%eax,4),%edx
  800ba2:	85 d2                	test   %edx,%edx
  800ba4:	75 20                	jne    800bc6 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  800ba6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800baa:	c7 44 24 08 07 2b 80 	movl   $0x802b07,0x8(%esp)
  800bb1:	00 
  800bb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	89 04 24             	mov    %eax,(%esp)
  800bbc:	e8 85 fe ff ff       	call   800a46 <printfmt>
  800bc1:	e9 d8 fe ff ff       	jmp    800a9e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  800bc6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bca:	c7 44 24 08 1e 2f 80 	movl   $0x802f1e,0x8(%esp)
  800bd1:	00 
  800bd2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	89 04 24             	mov    %eax,(%esp)
  800bdc:	e8 65 fe ff ff       	call   800a46 <printfmt>
  800be1:	e9 b8 fe ff ff       	jmp    800a9e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  800be6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800be9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800bec:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  800bef:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf2:	8d 50 04             	lea    0x4(%eax),%edx
  800bf5:	89 55 14             	mov    %edx,0x14(%ebp)
  800bf8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800bfa:	85 f6                	test   %esi,%esi
  800bfc:	b8 00 2b 80 00       	mov    $0x802b00,%eax
  800c01:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800c04:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800c08:	0f 84 97 00 00 00    	je     800ca5 <vprintfmt+0x237>
  800c0e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800c12:	0f 8e 9b 00 00 00    	jle    800cb3 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  800c18:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c1c:	89 34 24             	mov    %esi,(%esp)
  800c1f:	e8 c4 02 00 00       	call   800ee8 <strnlen>
  800c24:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800c27:	29 c2                	sub    %eax,%edx
  800c29:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800c2c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800c30:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800c33:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800c36:	8b 75 08             	mov    0x8(%ebp),%esi
  800c39:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c3c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800c3e:	eb 0f                	jmp    800c4f <vprintfmt+0x1e1>
					putch(padc, putdat);
  800c40:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c44:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800c47:	89 04 24             	mov    %eax,(%esp)
  800c4a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800c4c:	83 eb 01             	sub    $0x1,%ebx
  800c4f:	85 db                	test   %ebx,%ebx
  800c51:	7f ed                	jg     800c40 <vprintfmt+0x1d2>
  800c53:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800c56:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800c59:	85 d2                	test   %edx,%edx
  800c5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c60:	0f 49 c2             	cmovns %edx,%eax
  800c63:	29 c2                	sub    %eax,%edx
  800c65:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800c6d:	eb 50                	jmp    800cbf <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  800c6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c73:	74 1e                	je     800c93 <vprintfmt+0x225>
  800c75:	0f be d2             	movsbl %dl,%edx
  800c78:	83 ea 20             	sub    $0x20,%edx
  800c7b:	83 fa 5e             	cmp    $0x5e,%edx
  800c7e:	76 13                	jbe    800c93 <vprintfmt+0x225>
					putch('?', putdat);
  800c80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c87:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c8e:	ff 55 08             	call   *0x8(%ebp)
  800c91:	eb 0d                	jmp    800ca0 <vprintfmt+0x232>
					putch(ch, putdat);
  800c93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c96:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c9a:	89 04 24             	mov    %eax,(%esp)
  800c9d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ca0:	83 ef 01             	sub    $0x1,%edi
  800ca3:	eb 1a                	jmp    800cbf <vprintfmt+0x251>
  800ca5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ca8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800cab:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800cb1:	eb 0c                	jmp    800cbf <vprintfmt+0x251>
  800cb3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800cb6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800cb9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cbc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800cbf:	83 c6 01             	add    $0x1,%esi
  800cc2:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800cc6:	0f be c2             	movsbl %dl,%eax
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	74 27                	je     800cf4 <vprintfmt+0x286>
  800ccd:	85 db                	test   %ebx,%ebx
  800ccf:	78 9e                	js     800c6f <vprintfmt+0x201>
  800cd1:	83 eb 01             	sub    $0x1,%ebx
  800cd4:	79 99                	jns    800c6f <vprintfmt+0x201>
  800cd6:	89 f8                	mov    %edi,%eax
  800cd8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cdb:	8b 75 08             	mov    0x8(%ebp),%esi
  800cde:	89 c3                	mov    %eax,%ebx
  800ce0:	eb 1a                	jmp    800cfc <vprintfmt+0x28e>
				putch(' ', putdat);
  800ce2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ce6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ced:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800cef:	83 eb 01             	sub    $0x1,%ebx
  800cf2:	eb 08                	jmp    800cfc <vprintfmt+0x28e>
  800cf4:	89 fb                	mov    %edi,%ebx
  800cf6:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cfc:	85 db                	test   %ebx,%ebx
  800cfe:	7f e2                	jg     800ce2 <vprintfmt+0x274>
  800d00:	89 75 08             	mov    %esi,0x8(%ebp)
  800d03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d06:	e9 93 fd ff ff       	jmp    800a9e <vprintfmt+0x30>
	if (lflag >= 2)
  800d0b:	83 fa 01             	cmp    $0x1,%edx
  800d0e:	7e 16                	jle    800d26 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800d10:	8b 45 14             	mov    0x14(%ebp),%eax
  800d13:	8d 50 08             	lea    0x8(%eax),%edx
  800d16:	89 55 14             	mov    %edx,0x14(%ebp)
  800d19:	8b 50 04             	mov    0x4(%eax),%edx
  800d1c:	8b 00                	mov    (%eax),%eax
  800d1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d24:	eb 32                	jmp    800d58 <vprintfmt+0x2ea>
	else if (lflag)
  800d26:	85 d2                	test   %edx,%edx
  800d28:	74 18                	je     800d42 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  800d2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2d:	8d 50 04             	lea    0x4(%eax),%edx
  800d30:	89 55 14             	mov    %edx,0x14(%ebp)
  800d33:	8b 30                	mov    (%eax),%esi
  800d35:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800d38:	89 f0                	mov    %esi,%eax
  800d3a:	c1 f8 1f             	sar    $0x1f,%eax
  800d3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d40:	eb 16                	jmp    800d58 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  800d42:	8b 45 14             	mov    0x14(%ebp),%eax
  800d45:	8d 50 04             	lea    0x4(%eax),%edx
  800d48:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4b:	8b 30                	mov    (%eax),%esi
  800d4d:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800d50:	89 f0                	mov    %esi,%eax
  800d52:	c1 f8 1f             	sar    $0x1f,%eax
  800d55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  800d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d5b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  800d5e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800d63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d67:	0f 89 80 00 00 00    	jns    800ded <vprintfmt+0x37f>
				putch('-', putdat);
  800d6d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d71:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800d78:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800d7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d81:	f7 d8                	neg    %eax
  800d83:	83 d2 00             	adc    $0x0,%edx
  800d86:	f7 da                	neg    %edx
			base = 10;
  800d88:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800d8d:	eb 5e                	jmp    800ded <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800d8f:	8d 45 14             	lea    0x14(%ebp),%eax
  800d92:	e8 58 fc ff ff       	call   8009ef <getuint>
			base = 10;
  800d97:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800d9c:	eb 4f                	jmp    800ded <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800d9e:	8d 45 14             	lea    0x14(%ebp),%eax
  800da1:	e8 49 fc ff ff       	call   8009ef <getuint>
            base = 8;
  800da6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  800dab:	eb 40                	jmp    800ded <vprintfmt+0x37f>
			putch('0', putdat);
  800dad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800db1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800db8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800dbb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dbf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800dc6:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800dc9:	8b 45 14             	mov    0x14(%ebp),%eax
  800dcc:	8d 50 04             	lea    0x4(%eax),%edx
  800dcf:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800dd2:	8b 00                	mov    (%eax),%eax
  800dd4:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800dd9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800dde:	eb 0d                	jmp    800ded <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  800de0:	8d 45 14             	lea    0x14(%ebp),%eax
  800de3:	e8 07 fc ff ff       	call   8009ef <getuint>
			base = 16;
  800de8:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800ded:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800df1:	89 74 24 10          	mov    %esi,0x10(%esp)
  800df5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800df8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800dfc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e00:	89 04 24             	mov    %eax,(%esp)
  800e03:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e07:	89 fa                	mov    %edi,%edx
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	e8 ef fa ff ff       	call   800900 <printnum>
			break;
  800e11:	e9 88 fc ff ff       	jmp    800a9e <vprintfmt+0x30>
			putch(ch, putdat);
  800e16:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e1a:	89 04 24             	mov    %eax,(%esp)
  800e1d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800e20:	e9 79 fc ff ff       	jmp    800a9e <vprintfmt+0x30>
			putch('%', putdat);
  800e25:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e29:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e30:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e33:	89 f3                	mov    %esi,%ebx
  800e35:	eb 03                	jmp    800e3a <vprintfmt+0x3cc>
  800e37:	83 eb 01             	sub    $0x1,%ebx
  800e3a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800e3e:	75 f7                	jne    800e37 <vprintfmt+0x3c9>
  800e40:	e9 59 fc ff ff       	jmp    800a9e <vprintfmt+0x30>
}
  800e45:	83 c4 3c             	add    $0x3c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	83 ec 28             	sub    $0x28,%esp
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e5c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e60:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	74 30                	je     800e9e <vsnprintf+0x51>
  800e6e:	85 d2                	test   %edx,%edx
  800e70:	7e 2c                	jle    800e9e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e72:	8b 45 14             	mov    0x14(%ebp),%eax
  800e75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e79:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e80:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e87:	c7 04 24 29 0a 80 00 	movl   $0x800a29,(%esp)
  800e8e:	e8 db fb ff ff       	call   800a6e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e93:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e96:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e9c:	eb 05                	jmp    800ea3 <vsnprintf+0x56>
		return -E_INVAL;
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800eab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800eae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec3:	89 04 24             	mov    %eax,(%esp)
  800ec6:	e8 82 ff ff ff       	call   800e4d <vsnprintf>
	va_end(ap);

	return rc;
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    
  800ecd:	66 90                	xchg   %ax,%ax
  800ecf:	90                   	nop

00800ed0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  800edb:	eb 03                	jmp    800ee0 <strlen+0x10>
		n++;
  800edd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800ee0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ee4:	75 f7                	jne    800edd <strlen+0xd>
	return n;
}
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	eb 03                	jmp    800efb <strnlen+0x13>
		n++;
  800ef8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800efb:	39 d0                	cmp    %edx,%eax
  800efd:	74 06                	je     800f05 <strnlen+0x1d>
  800eff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800f03:	75 f3                	jne    800ef8 <strnlen+0x10>
	return n;
}
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	53                   	push   %ebx
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800f11:	89 c2                	mov    %eax,%edx
  800f13:	83 c2 01             	add    $0x1,%edx
  800f16:	83 c1 01             	add    $0x1,%ecx
  800f19:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800f1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800f20:	84 db                	test   %bl,%bl
  800f22:	75 ef                	jne    800f13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800f24:	5b                   	pop    %ebx
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 08             	sub    $0x8,%esp
  800f2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f31:	89 1c 24             	mov    %ebx,(%esp)
  800f34:	e8 97 ff ff ff       	call   800ed0 <strlen>
	strcpy(dst + len, src);
  800f39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f40:	01 d8                	add    %ebx,%eax
  800f42:	89 04 24             	mov    %eax,(%esp)
  800f45:	e8 bd ff ff ff       	call   800f07 <strcpy>
	return dst;
}
  800f4a:	89 d8                	mov    %ebx,%eax
  800f4c:	83 c4 08             	add    $0x8,%esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
  800f57:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	89 f3                	mov    %esi,%ebx
  800f5f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	eb 0f                	jmp    800f75 <strncpy+0x23>
		*dst++ = *src;
  800f66:	83 c2 01             	add    $0x1,%edx
  800f69:	0f b6 01             	movzbl (%ecx),%eax
  800f6c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f6f:	80 39 01             	cmpb   $0x1,(%ecx)
  800f72:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800f75:	39 da                	cmp    %ebx,%edx
  800f77:	75 ed                	jne    800f66 <strncpy+0x14>
	}
	return ret;
}
  800f79:	89 f0                	mov    %esi,%eax
  800f7b:	5b                   	pop    %ebx
  800f7c:	5e                   	pop    %esi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	8b 75 08             	mov    0x8(%ebp),%esi
  800f87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f93:	85 c9                	test   %ecx,%ecx
  800f95:	75 0b                	jne    800fa2 <strlcpy+0x23>
  800f97:	eb 1d                	jmp    800fb6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f99:	83 c0 01             	add    $0x1,%eax
  800f9c:	83 c2 01             	add    $0x1,%edx
  800f9f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800fa2:	39 d8                	cmp    %ebx,%eax
  800fa4:	74 0b                	je     800fb1 <strlcpy+0x32>
  800fa6:	0f b6 0a             	movzbl (%edx),%ecx
  800fa9:	84 c9                	test   %cl,%cl
  800fab:	75 ec                	jne    800f99 <strlcpy+0x1a>
  800fad:	89 c2                	mov    %eax,%edx
  800faf:	eb 02                	jmp    800fb3 <strlcpy+0x34>
  800fb1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800fb3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800fb6:	29 f0                	sub    %esi,%eax
}
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800fc5:	eb 06                	jmp    800fcd <strcmp+0x11>
		p++, q++;
  800fc7:	83 c1 01             	add    $0x1,%ecx
  800fca:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800fcd:	0f b6 01             	movzbl (%ecx),%eax
  800fd0:	84 c0                	test   %al,%al
  800fd2:	74 04                	je     800fd8 <strcmp+0x1c>
  800fd4:	3a 02                	cmp    (%edx),%al
  800fd6:	74 ef                	je     800fc7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fd8:	0f b6 c0             	movzbl %al,%eax
  800fdb:	0f b6 12             	movzbl (%edx),%edx
  800fde:	29 d0                	sub    %edx,%eax
}
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	53                   	push   %ebx
  800fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fec:	89 c3                	mov    %eax,%ebx
  800fee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ff1:	eb 06                	jmp    800ff9 <strncmp+0x17>
		n--, p++, q++;
  800ff3:	83 c0 01             	add    $0x1,%eax
  800ff6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ff9:	39 d8                	cmp    %ebx,%eax
  800ffb:	74 15                	je     801012 <strncmp+0x30>
  800ffd:	0f b6 08             	movzbl (%eax),%ecx
  801000:	84 c9                	test   %cl,%cl
  801002:	74 04                	je     801008 <strncmp+0x26>
  801004:	3a 0a                	cmp    (%edx),%cl
  801006:	74 eb                	je     800ff3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801008:	0f b6 00             	movzbl (%eax),%eax
  80100b:	0f b6 12             	movzbl (%edx),%edx
  80100e:	29 d0                	sub    %edx,%eax
  801010:	eb 05                	jmp    801017 <strncmp+0x35>
		return 0;
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801017:	5b                   	pop    %ebx
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	8b 45 08             	mov    0x8(%ebp),%eax
  801020:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801024:	eb 07                	jmp    80102d <strchr+0x13>
		if (*s == c)
  801026:	38 ca                	cmp    %cl,%dl
  801028:	74 0f                	je     801039 <strchr+0x1f>
	for (; *s; s++)
  80102a:	83 c0 01             	add    $0x1,%eax
  80102d:	0f b6 10             	movzbl (%eax),%edx
  801030:	84 d2                	test   %dl,%dl
  801032:	75 f2                	jne    801026 <strchr+0xc>
			return (char *) s;
	return 0;
  801034:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
  801041:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801045:	eb 07                	jmp    80104e <strfind+0x13>
		if (*s == c)
  801047:	38 ca                	cmp    %cl,%dl
  801049:	74 0a                	je     801055 <strfind+0x1a>
	for (; *s; s++)
  80104b:	83 c0 01             	add    $0x1,%eax
  80104e:	0f b6 10             	movzbl (%eax),%edx
  801051:	84 d2                	test   %dl,%dl
  801053:	75 f2                	jne    801047 <strfind+0xc>
			break;
	return (char *) s;
}
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801060:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801063:	85 c9                	test   %ecx,%ecx
  801065:	74 36                	je     80109d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801067:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80106d:	75 28                	jne    801097 <memset+0x40>
  80106f:	f6 c1 03             	test   $0x3,%cl
  801072:	75 23                	jne    801097 <memset+0x40>
		c &= 0xFF;
  801074:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801078:	89 d3                	mov    %edx,%ebx
  80107a:	c1 e3 08             	shl    $0x8,%ebx
  80107d:	89 d6                	mov    %edx,%esi
  80107f:	c1 e6 18             	shl    $0x18,%esi
  801082:	89 d0                	mov    %edx,%eax
  801084:	c1 e0 10             	shl    $0x10,%eax
  801087:	09 f0                	or     %esi,%eax
  801089:	09 c2                	or     %eax,%edx
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80108f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801092:	fc                   	cld    
  801093:	f3 ab                	rep stos %eax,%es:(%edi)
  801095:	eb 06                	jmp    80109d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801097:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109a:	fc                   	cld    
  80109b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80109d:	89 f8                	mov    %edi,%eax
  80109f:	5b                   	pop    %ebx
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8010b2:	39 c6                	cmp    %eax,%esi
  8010b4:	73 35                	jae    8010eb <memmove+0x47>
  8010b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8010b9:	39 d0                	cmp    %edx,%eax
  8010bb:	73 2e                	jae    8010eb <memmove+0x47>
		s += n;
		d += n;
  8010bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8010c0:	89 d6                	mov    %edx,%esi
  8010c2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8010ca:	75 13                	jne    8010df <memmove+0x3b>
  8010cc:	f6 c1 03             	test   $0x3,%cl
  8010cf:	75 0e                	jne    8010df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8010d1:	83 ef 04             	sub    $0x4,%edi
  8010d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8010d7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8010da:	fd                   	std    
  8010db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010dd:	eb 09                	jmp    8010e8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8010df:	83 ef 01             	sub    $0x1,%edi
  8010e2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8010e5:	fd                   	std    
  8010e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8010e8:	fc                   	cld    
  8010e9:	eb 1d                	jmp    801108 <memmove+0x64>
  8010eb:	89 f2                	mov    %esi,%edx
  8010ed:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010ef:	f6 c2 03             	test   $0x3,%dl
  8010f2:	75 0f                	jne    801103 <memmove+0x5f>
  8010f4:	f6 c1 03             	test   $0x3,%cl
  8010f7:	75 0a                	jne    801103 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8010f9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8010fc:	89 c7                	mov    %eax,%edi
  8010fe:	fc                   	cld    
  8010ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801101:	eb 05                	jmp    801108 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801103:	89 c7                	mov    %eax,%edi
  801105:	fc                   	cld    
  801106:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801112:	8b 45 10             	mov    0x10(%ebp),%eax
  801115:	89 44 24 08          	mov    %eax,0x8(%esp)
  801119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	89 04 24             	mov    %eax,(%esp)
  801126:	e8 79 ff ff ff       	call   8010a4 <memmove>
}
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	8b 55 08             	mov    0x8(%ebp),%edx
  801135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801138:	89 d6                	mov    %edx,%esi
  80113a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80113d:	eb 1a                	jmp    801159 <memcmp+0x2c>
		if (*s1 != *s2)
  80113f:	0f b6 02             	movzbl (%edx),%eax
  801142:	0f b6 19             	movzbl (%ecx),%ebx
  801145:	38 d8                	cmp    %bl,%al
  801147:	74 0a                	je     801153 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801149:	0f b6 c0             	movzbl %al,%eax
  80114c:	0f b6 db             	movzbl %bl,%ebx
  80114f:	29 d8                	sub    %ebx,%eax
  801151:	eb 0f                	jmp    801162 <memcmp+0x35>
		s1++, s2++;
  801153:	83 c2 01             	add    $0x1,%edx
  801156:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  801159:	39 f2                	cmp    %esi,%edx
  80115b:	75 e2                	jne    80113f <memcmp+0x12>
	}

	return 0;
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801162:	5b                   	pop    %ebx
  801163:	5e                   	pop    %esi
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80116f:	89 c2                	mov    %eax,%edx
  801171:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801174:	eb 07                	jmp    80117d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801176:	38 08                	cmp    %cl,(%eax)
  801178:	74 07                	je     801181 <memfind+0x1b>
	for (; s < ends; s++)
  80117a:	83 c0 01             	add    $0x1,%eax
  80117d:	39 d0                	cmp    %edx,%eax
  80117f:	72 f5                	jb     801176 <memfind+0x10>
			break;
	return (void *) s;
}
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	57                   	push   %edi
  801187:	56                   	push   %esi
  801188:	53                   	push   %ebx
  801189:	8b 55 08             	mov    0x8(%ebp),%edx
  80118c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80118f:	eb 03                	jmp    801194 <strtol+0x11>
		s++;
  801191:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801194:	0f b6 0a             	movzbl (%edx),%ecx
  801197:	80 f9 09             	cmp    $0x9,%cl
  80119a:	74 f5                	je     801191 <strtol+0xe>
  80119c:	80 f9 20             	cmp    $0x20,%cl
  80119f:	74 f0                	je     801191 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8011a1:	80 f9 2b             	cmp    $0x2b,%cl
  8011a4:	75 0a                	jne    8011b0 <strtol+0x2d>
		s++;
  8011a6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8011a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8011ae:	eb 11                	jmp    8011c1 <strtol+0x3e>
  8011b0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  8011b5:	80 f9 2d             	cmp    $0x2d,%cl
  8011b8:	75 07                	jne    8011c1 <strtol+0x3e>
		s++, neg = 1;
  8011ba:	8d 52 01             	lea    0x1(%edx),%edx
  8011bd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8011c1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  8011c6:	75 15                	jne    8011dd <strtol+0x5a>
  8011c8:	80 3a 30             	cmpb   $0x30,(%edx)
  8011cb:	75 10                	jne    8011dd <strtol+0x5a>
  8011cd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8011d1:	75 0a                	jne    8011dd <strtol+0x5a>
		s += 2, base = 16;
  8011d3:	83 c2 02             	add    $0x2,%edx
  8011d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8011db:	eb 10                	jmp    8011ed <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	75 0c                	jne    8011ed <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8011e1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  8011e3:	80 3a 30             	cmpb   $0x30,(%edx)
  8011e6:	75 05                	jne    8011ed <strtol+0x6a>
		s++, base = 8;
  8011e8:	83 c2 01             	add    $0x1,%edx
  8011eb:	b0 08                	mov    $0x8,%al
		base = 10;
  8011ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8011f5:	0f b6 0a             	movzbl (%edx),%ecx
  8011f8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8011fb:	89 f0                	mov    %esi,%eax
  8011fd:	3c 09                	cmp    $0x9,%al
  8011ff:	77 08                	ja     801209 <strtol+0x86>
			dig = *s - '0';
  801201:	0f be c9             	movsbl %cl,%ecx
  801204:	83 e9 30             	sub    $0x30,%ecx
  801207:	eb 20                	jmp    801229 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801209:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80120c:	89 f0                	mov    %esi,%eax
  80120e:	3c 19                	cmp    $0x19,%al
  801210:	77 08                	ja     80121a <strtol+0x97>
			dig = *s - 'a' + 10;
  801212:	0f be c9             	movsbl %cl,%ecx
  801215:	83 e9 57             	sub    $0x57,%ecx
  801218:	eb 0f                	jmp    801229 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80121a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80121d:	89 f0                	mov    %esi,%eax
  80121f:	3c 19                	cmp    $0x19,%al
  801221:	77 16                	ja     801239 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801223:	0f be c9             	movsbl %cl,%ecx
  801226:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801229:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80122c:	7d 0f                	jge    80123d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80122e:	83 c2 01             	add    $0x1,%edx
  801231:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801235:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801237:	eb bc                	jmp    8011f5 <strtol+0x72>
  801239:	89 d8                	mov    %ebx,%eax
  80123b:	eb 02                	jmp    80123f <strtol+0xbc>
  80123d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80123f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801243:	74 05                	je     80124a <strtol+0xc7>
		*endptr = (char *) s;
  801245:	8b 75 0c             	mov    0xc(%ebp),%esi
  801248:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80124a:	f7 d8                	neg    %eax
  80124c:	85 ff                	test   %edi,%edi
  80124e:	0f 44 c3             	cmove  %ebx,%eax
}
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5f                   	pop    %edi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	57                   	push   %edi
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80125c:	b8 00 00 00 00       	mov    $0x0,%eax
  801261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801264:	8b 55 08             	mov    0x8(%ebp),%edx
  801267:	89 c3                	mov    %eax,%ebx
  801269:	89 c7                	mov    %eax,%edi
  80126b:	89 c6                	mov    %eax,%esi
  80126d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5f                   	pop    %edi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <sys_cgetc>:

int
sys_cgetc(void)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	57                   	push   %edi
  801278:	56                   	push   %esi
  801279:	53                   	push   %ebx
	asm volatile("int %1\n"
  80127a:	ba 00 00 00 00       	mov    $0x0,%edx
  80127f:	b8 01 00 00 00       	mov    $0x1,%eax
  801284:	89 d1                	mov    %edx,%ecx
  801286:	89 d3                	mov    %edx,%ebx
  801288:	89 d7                	mov    %edx,%edi
  80128a:	89 d6                	mov    %edx,%esi
  80128c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80128e:	5b                   	pop    %ebx
  80128f:	5e                   	pop    %esi
  801290:	5f                   	pop    %edi
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	57                   	push   %edi
  801297:	56                   	push   %esi
  801298:	53                   	push   %ebx
  801299:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80129c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a1:	b8 03 00 00 00       	mov    $0x3,%eax
  8012a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a9:	89 cb                	mov    %ecx,%ebx
  8012ab:	89 cf                	mov    %ecx,%edi
  8012ad:	89 ce                	mov    %ecx,%esi
  8012af:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	7e 28                	jle    8012dd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8012c0:	00 
  8012c1:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  8012c8:	00 
  8012c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d0:	00 
  8012d1:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  8012d8:	e8 07 f5 ff ff       	call   8007e4 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8012dd:	83 c4 2c             	add    $0x2c,%esp
  8012e0:	5b                   	pop    %ebx
  8012e1:	5e                   	pop    %esi
  8012e2:	5f                   	pop    %edi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	57                   	push   %edi
  8012e9:	56                   	push   %esi
  8012ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8012f5:	89 d1                	mov    %edx,%ecx
  8012f7:	89 d3                	mov    %edx,%ebx
  8012f9:	89 d7                	mov    %edx,%edi
  8012fb:	89 d6                	mov    %edx,%esi
  8012fd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <sys_yield>:

void
sys_yield(void)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	57                   	push   %edi
  801308:	56                   	push   %esi
  801309:	53                   	push   %ebx
	asm volatile("int %1\n"
  80130a:	ba 00 00 00 00       	mov    $0x0,%edx
  80130f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801314:	89 d1                	mov    %edx,%ecx
  801316:	89 d3                	mov    %edx,%ebx
  801318:	89 d7                	mov    %edx,%edi
  80131a:	89 d6                	mov    %edx,%esi
  80131c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80132c:	be 00 00 00 00       	mov    $0x0,%esi
  801331:	b8 04 00 00 00       	mov    $0x4,%eax
  801336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801339:	8b 55 08             	mov    0x8(%ebp),%edx
  80133c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133f:	89 f7                	mov    %esi,%edi
  801341:	cd 30                	int    $0x30
	if(check && ret > 0)
  801343:	85 c0                	test   %eax,%eax
  801345:	7e 28                	jle    80136f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801347:	89 44 24 10          	mov    %eax,0x10(%esp)
  80134b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801352:	00 
  801353:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  80135a:	00 
  80135b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801362:	00 
  801363:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  80136a:	e8 75 f4 ff ff       	call   8007e4 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80136f:	83 c4 2c             	add    $0x2c,%esp
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	57                   	push   %edi
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801380:	b8 05 00 00 00       	mov    $0x5,%eax
  801385:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801388:	8b 55 08             	mov    0x8(%ebp),%edx
  80138b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801391:	8b 75 18             	mov    0x18(%ebp),%esi
  801394:	cd 30                	int    $0x30
	if(check && ret > 0)
  801396:	85 c0                	test   %eax,%eax
  801398:	7e 28                	jle    8013c2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80139a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013a5:	00 
  8013a6:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  8013ad:	00 
  8013ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013b5:	00 
  8013b6:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  8013bd:	e8 22 f4 ff ff       	call   8007e4 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8013c2:	83 c4 2c             	add    $0x2c,%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8013d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d8:	b8 06 00 00 00       	mov    $0x6,%eax
  8013dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e3:	89 df                	mov    %ebx,%edi
  8013e5:	89 de                	mov    %ebx,%esi
  8013e7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	7e 28                	jle    801415 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013f8:	00 
  8013f9:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  801400:	00 
  801401:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801408:	00 
  801409:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801410:	e8 cf f3 ff ff       	call   8007e4 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801415:	83 c4 2c             	add    $0x2c,%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	57                   	push   %edi
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801426:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142b:	b8 08 00 00 00       	mov    $0x8,%eax
  801430:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801433:	8b 55 08             	mov    0x8(%ebp),%edx
  801436:	89 df                	mov    %ebx,%edi
  801438:	89 de                	mov    %ebx,%esi
  80143a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80143c:	85 c0                	test   %eax,%eax
  80143e:	7e 28                	jle    801468 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801440:	89 44 24 10          	mov    %eax,0x10(%esp)
  801444:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80144b:	00 
  80144c:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  801453:	00 
  801454:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80145b:	00 
  80145c:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801463:	e8 7c f3 ff ff       	call   8007e4 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801468:	83 c4 2c             	add    $0x2c,%esp
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5f                   	pop    %edi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	57                   	push   %edi
  801474:	56                   	push   %esi
  801475:	53                   	push   %ebx
  801476:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801479:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147e:	b8 09 00 00 00       	mov    $0x9,%eax
  801483:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801486:	8b 55 08             	mov    0x8(%ebp),%edx
  801489:	89 df                	mov    %ebx,%edi
  80148b:	89 de                	mov    %ebx,%esi
  80148d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80148f:	85 c0                	test   %eax,%eax
  801491:	7e 28                	jle    8014bb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801493:	89 44 24 10          	mov    %eax,0x10(%esp)
  801497:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80149e:	00 
  80149f:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  8014a6:	00 
  8014a7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014ae:	00 
  8014af:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  8014b6:	e8 29 f3 ff ff       	call   8007e4 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8014bb:	83 c4 2c             	add    $0x2c,%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5e                   	pop    %esi
  8014c0:	5f                   	pop    %edi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	57                   	push   %edi
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8014cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014dc:	89 df                	mov    %ebx,%edi
  8014de:	89 de                	mov    %ebx,%esi
  8014e0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	7e 28                	jle    80150e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ea:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8014f1:	00 
  8014f2:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801501:	00 
  801502:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801509:	e8 d6 f2 ff ff       	call   8007e4 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80150e:	83 c4 2c             	add    $0x2c,%esp
  801511:	5b                   	pop    %ebx
  801512:	5e                   	pop    %esi
  801513:	5f                   	pop    %edi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	57                   	push   %edi
  80151a:	56                   	push   %esi
  80151b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80151c:	be 00 00 00 00       	mov    $0x0,%esi
  801521:	b8 0c 00 00 00       	mov    $0xc,%eax
  801526:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801529:	8b 55 08             	mov    0x8(%ebp),%edx
  80152c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80152f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801532:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5f                   	pop    %edi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    

00801539 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	57                   	push   %edi
  80153d:	56                   	push   %esi
  80153e:	53                   	push   %ebx
  80153f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801542:	b9 00 00 00 00       	mov    $0x0,%ecx
  801547:	b8 0d 00 00 00       	mov    $0xd,%eax
  80154c:	8b 55 08             	mov    0x8(%ebp),%edx
  80154f:	89 cb                	mov    %ecx,%ebx
  801551:	89 cf                	mov    %ecx,%edi
  801553:	89 ce                	mov    %ecx,%esi
  801555:	cd 30                	int    $0x30
	if(check && ret > 0)
  801557:	85 c0                	test   %eax,%eax
  801559:	7e 28                	jle    801583 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80155b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80155f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801566:	00 
  801567:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  80156e:	00 
  80156f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801576:	00 
  801577:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  80157e:	e8 61 f2 ff ff       	call   8007e4 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801583:	83 c4 2c             	add    $0x2c,%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    
  80158b:	66 90                	xchg   %ax,%ax
  80158d:	66 90                	xchg   %ax,%ax
  80158f:	90                   	nop

00801590 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	83 ec 10             	sub    $0x10,%esp
  801598:	8b 75 08             	mov    0x8(%ebp),%esi
  80159b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  8015a1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  8015a3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8015a8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  8015ab:	89 04 24             	mov    %eax,(%esp)
  8015ae:	e8 86 ff ff ff       	call   801539 <sys_ipc_recv>
    if(r < 0){
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	79 16                	jns    8015cd <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  8015b7:	85 f6                	test   %esi,%esi
  8015b9:	74 06                	je     8015c1 <ipc_recv+0x31>
            *from_env_store = 0;
  8015bb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  8015c1:	85 db                	test   %ebx,%ebx
  8015c3:	74 2c                	je     8015f1 <ipc_recv+0x61>
            *perm_store = 0;
  8015c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015cb:	eb 24                	jmp    8015f1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  8015cd:	85 f6                	test   %esi,%esi
  8015cf:	74 0a                	je     8015db <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  8015d1:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d6:	8b 40 74             	mov    0x74(%eax),%eax
  8015d9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  8015db:	85 db                	test   %ebx,%ebx
  8015dd:	74 0a                	je     8015e9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  8015df:	a1 08 40 80 00       	mov    0x804008,%eax
  8015e4:	8b 40 78             	mov    0x78(%eax),%eax
  8015e7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8015e9:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ee:	8b 40 70             	mov    0x70(%eax),%eax
}
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5e                   	pop    %esi
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	57                   	push   %edi
  8015fc:	56                   	push   %esi
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 1c             	sub    $0x1c,%esp
  801601:	8b 7d 08             	mov    0x8(%ebp),%edi
  801604:	8b 75 0c             	mov    0xc(%ebp),%esi
  801607:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  80160a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  80160c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801611:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801614:	8b 45 14             	mov    0x14(%ebp),%eax
  801617:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80161b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80161f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801623:	89 3c 24             	mov    %edi,(%esp)
  801626:	e8 eb fe ff ff       	call   801516 <sys_ipc_try_send>
        if(r == 0){
  80162b:	85 c0                	test   %eax,%eax
  80162d:	74 28                	je     801657 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  80162f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801632:	74 1c                	je     801650 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801634:	c7 44 24 08 2a 2e 80 	movl   $0x802e2a,0x8(%esp)
  80163b:	00 
  80163c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801643:	00 
  801644:	c7 04 24 41 2e 80 00 	movl   $0x802e41,(%esp)
  80164b:	e8 94 f1 ff ff       	call   8007e4 <_panic>
        }
        sys_yield();
  801650:	e8 af fc ff ff       	call   801304 <sys_yield>
    }
  801655:	eb bd                	jmp    801614 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801657:	83 c4 1c             	add    $0x1c,%esp
  80165a:	5b                   	pop    %ebx
  80165b:	5e                   	pop    %esi
  80165c:	5f                   	pop    %edi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    

0080165f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801665:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80166a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80166d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801673:	8b 52 50             	mov    0x50(%edx),%edx
  801676:	39 ca                	cmp    %ecx,%edx
  801678:	75 0d                	jne    801687 <ipc_find_env+0x28>
			return envs[i].env_id;
  80167a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80167d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801682:	8b 40 40             	mov    0x40(%eax),%eax
  801685:	eb 0e                	jmp    801695 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801687:	83 c0 01             	add    $0x1,%eax
  80168a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80168f:	75 d9                	jne    80166a <ipc_find_env+0xb>
	return 0;
  801691:	66 b8 00 00          	mov    $0x0,%ax
}
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    
  801697:	66 90                	xchg   %ax,%ax
  801699:	66 90                	xchg   %ax,%ax
  80169b:	66 90                	xchg   %ax,%ax
  80169d:	66 90                	xchg   %ax,%ax
  80169f:	90                   	nop

008016a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8016bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8016c0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016d2:	89 c2                	mov    %eax,%edx
  8016d4:	c1 ea 16             	shr    $0x16,%edx
  8016d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016de:	f6 c2 01             	test   $0x1,%dl
  8016e1:	74 11                	je     8016f4 <fd_alloc+0x2d>
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	c1 ea 0c             	shr    $0xc,%edx
  8016e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ef:	f6 c2 01             	test   $0x1,%dl
  8016f2:	75 09                	jne    8016fd <fd_alloc+0x36>
			*fd_store = fd;
  8016f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fb:	eb 17                	jmp    801714 <fd_alloc+0x4d>
  8016fd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801702:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801707:	75 c9                	jne    8016d2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  801709:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80170f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80171c:	83 f8 1f             	cmp    $0x1f,%eax
  80171f:	77 36                	ja     801757 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801721:	c1 e0 0c             	shl    $0xc,%eax
  801724:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801729:	89 c2                	mov    %eax,%edx
  80172b:	c1 ea 16             	shr    $0x16,%edx
  80172e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801735:	f6 c2 01             	test   $0x1,%dl
  801738:	74 24                	je     80175e <fd_lookup+0x48>
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	c1 ea 0c             	shr    $0xc,%edx
  80173f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801746:	f6 c2 01             	test   $0x1,%dl
  801749:	74 1a                	je     801765 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80174b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174e:	89 02                	mov    %eax,(%edx)
	return 0;
  801750:	b8 00 00 00 00       	mov    $0x0,%eax
  801755:	eb 13                	jmp    80176a <fd_lookup+0x54>
		return -E_INVAL;
  801757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175c:	eb 0c                	jmp    80176a <fd_lookup+0x54>
		return -E_INVAL;
  80175e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801763:	eb 05                	jmp    80176a <fd_lookup+0x54>
  801765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	83 ec 18             	sub    $0x18,%esp
  801772:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801775:	ba cc 2e 80 00       	mov    $0x802ecc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80177a:	eb 13                	jmp    80178f <dev_lookup+0x23>
  80177c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80177f:	39 08                	cmp    %ecx,(%eax)
  801781:	75 0c                	jne    80178f <dev_lookup+0x23>
			*dev = devtab[i];
  801783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801786:	89 01                	mov    %eax,(%ecx)
			return 0;
  801788:	b8 00 00 00 00       	mov    $0x0,%eax
  80178d:	eb 30                	jmp    8017bf <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80178f:	8b 02                	mov    (%edx),%eax
  801791:	85 c0                	test   %eax,%eax
  801793:	75 e7                	jne    80177c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801795:	a1 08 40 80 00       	mov    0x804008,%eax
  80179a:	8b 40 48             	mov    0x48(%eax),%eax
  80179d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a5:	c7 04 24 4c 2e 80 00 	movl   $0x802e4c,(%esp)
  8017ac:	e8 2c f1 ff ff       	call   8008dd <cprintf>
	*dev = 0;
  8017b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8017ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <fd_close>:
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	56                   	push   %esi
  8017c5:	53                   	push   %ebx
  8017c6:	83 ec 20             	sub    $0x20,%esp
  8017c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8017cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8017d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8017dc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017df:	89 04 24             	mov    %eax,(%esp)
  8017e2:	e8 2f ff ff ff       	call   801716 <fd_lookup>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 05                	js     8017f0 <fd_close+0x2f>
	    || fd != fd2)
  8017eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017ee:	74 0c                	je     8017fc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8017f0:	84 db                	test   %bl,%bl
  8017f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f7:	0f 44 c2             	cmove  %edx,%eax
  8017fa:	eb 3f                	jmp    80183b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	8b 06                	mov    (%esi),%eax
  801805:	89 04 24             	mov    %eax,(%esp)
  801808:	e8 5f ff ff ff       	call   80176c <dev_lookup>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 16                	js     801829 <fd_close+0x68>
		if (dev->dev_close)
  801813:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801816:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801819:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80181e:	85 c0                	test   %eax,%eax
  801820:	74 07                	je     801829 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801822:	89 34 24             	mov    %esi,(%esp)
  801825:	ff d0                	call   *%eax
  801827:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  801829:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801834:	e8 91 fb ff ff       	call   8013ca <sys_page_unmap>
	return r;
  801839:	89 d8                	mov    %ebx,%eax
}
  80183b:	83 c4 20             	add    $0x20,%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <close>:

int
close(int fdnum)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801848:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	e8 bc fe ff ff       	call   801716 <fd_lookup>
  80185a:	89 c2                	mov    %eax,%edx
  80185c:	85 d2                	test   %edx,%edx
  80185e:	78 13                	js     801873 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801860:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801867:	00 
  801868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186b:	89 04 24             	mov    %eax,(%esp)
  80186e:	e8 4e ff ff ff       	call   8017c1 <fd_close>
}
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <close_all>:

void
close_all(void)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	53                   	push   %ebx
  801879:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80187c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801881:	89 1c 24             	mov    %ebx,(%esp)
  801884:	e8 b9 ff ff ff       	call   801842 <close>
	for (i = 0; i < MAXFD; i++)
  801889:	83 c3 01             	add    $0x1,%ebx
  80188c:	83 fb 20             	cmp    $0x20,%ebx
  80188f:	75 f0                	jne    801881 <close_all+0xc>
}
  801891:	83 c4 14             	add    $0x14,%esp
  801894:	5b                   	pop    %ebx
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	57                   	push   %edi
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
  80189d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	89 04 24             	mov    %eax,(%esp)
  8018ad:	e8 64 fe ff ff       	call   801716 <fd_lookup>
  8018b2:	89 c2                	mov    %eax,%edx
  8018b4:	85 d2                	test   %edx,%edx
  8018b6:	0f 88 e1 00 00 00    	js     80199d <dup+0x106>
		return r;
	close(newfdnum);
  8018bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bf:	89 04 24             	mov    %eax,(%esp)
  8018c2:	e8 7b ff ff ff       	call   801842 <close>

	newfd = INDEX2FD(newfdnum);
  8018c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018ca:	c1 e3 0c             	shl    $0xc,%ebx
  8018cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8018d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 d2 fd ff ff       	call   8016b0 <fd2data>
  8018de:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8018e0:	89 1c 24             	mov    %ebx,(%esp)
  8018e3:	e8 c8 fd ff ff       	call   8016b0 <fd2data>
  8018e8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018ea:	89 f0                	mov    %esi,%eax
  8018ec:	c1 e8 16             	shr    $0x16,%eax
  8018ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018f6:	a8 01                	test   $0x1,%al
  8018f8:	74 43                	je     80193d <dup+0xa6>
  8018fa:	89 f0                	mov    %esi,%eax
  8018fc:	c1 e8 0c             	shr    $0xc,%eax
  8018ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801906:	f6 c2 01             	test   $0x1,%dl
  801909:	74 32                	je     80193d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80190b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801912:	25 07 0e 00 00       	and    $0xe07,%eax
  801917:	89 44 24 10          	mov    %eax,0x10(%esp)
  80191b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80191f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801926:	00 
  801927:	89 74 24 04          	mov    %esi,0x4(%esp)
  80192b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801932:	e8 40 fa ff ff       	call   801377 <sys_page_map>
  801937:	89 c6                	mov    %eax,%esi
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 3e                	js     80197b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80193d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801940:	89 c2                	mov    %eax,%edx
  801942:	c1 ea 0c             	shr    $0xc,%edx
  801945:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80194c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801952:	89 54 24 10          	mov    %edx,0x10(%esp)
  801956:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80195a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801961:	00 
  801962:	89 44 24 04          	mov    %eax,0x4(%esp)
  801966:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196d:	e8 05 fa ff ff       	call   801377 <sys_page_map>
  801972:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801974:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801977:	85 f6                	test   %esi,%esi
  801979:	79 22                	jns    80199d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80197b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801986:	e8 3f fa ff ff       	call   8013ca <sys_page_unmap>
	sys_page_unmap(0, nva);
  80198b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80198f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801996:	e8 2f fa ff ff       	call   8013ca <sys_page_unmap>
	return r;
  80199b:	89 f0                	mov    %esi,%eax
}
  80199d:	83 c4 3c             	add    $0x3c,%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5f                   	pop    %edi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    

008019a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 24             	sub    $0x24,%esp
  8019ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b6:	89 1c 24             	mov    %ebx,(%esp)
  8019b9:	e8 58 fd ff ff       	call   801716 <fd_lookup>
  8019be:	89 c2                	mov    %eax,%edx
  8019c0:	85 d2                	test   %edx,%edx
  8019c2:	78 6d                	js     801a31 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ce:	8b 00                	mov    (%eax),%eax
  8019d0:	89 04 24             	mov    %eax,(%esp)
  8019d3:	e8 94 fd ff ff       	call   80176c <dev_lookup>
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 55                	js     801a31 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019df:	8b 50 08             	mov    0x8(%eax),%edx
  8019e2:	83 e2 03             	and    $0x3,%edx
  8019e5:	83 fa 01             	cmp    $0x1,%edx
  8019e8:	75 23                	jne    801a0d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019ea:	a1 08 40 80 00       	mov    0x804008,%eax
  8019ef:	8b 40 48             	mov    0x48(%eax),%eax
  8019f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fa:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  801a01:	e8 d7 ee ff ff       	call   8008dd <cprintf>
		return -E_INVAL;
  801a06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a0b:	eb 24                	jmp    801a31 <read+0x8c>
	}
	if (!dev->dev_read)
  801a0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a10:	8b 52 08             	mov    0x8(%edx),%edx
  801a13:	85 d2                	test   %edx,%edx
  801a15:	74 15                	je     801a2c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a17:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a1a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a21:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a25:	89 04 24             	mov    %eax,(%esp)
  801a28:	ff d2                	call   *%edx
  801a2a:	eb 05                	jmp    801a31 <read+0x8c>
		return -E_NOT_SUPP;
  801a2c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801a31:	83 c4 24             	add    $0x24,%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    

00801a37 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	57                   	push   %edi
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 1c             	sub    $0x1c,%esp
  801a40:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a43:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a46:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a4b:	eb 23                	jmp    801a70 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a4d:	89 f0                	mov    %esi,%eax
  801a4f:	29 d8                	sub    %ebx,%eax
  801a51:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a55:	89 d8                	mov    %ebx,%eax
  801a57:	03 45 0c             	add    0xc(%ebp),%eax
  801a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5e:	89 3c 24             	mov    %edi,(%esp)
  801a61:	e8 3f ff ff ff       	call   8019a5 <read>
		if (m < 0)
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 10                	js     801a7a <readn+0x43>
			return m;
		if (m == 0)
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	74 0a                	je     801a78 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  801a6e:	01 c3                	add    %eax,%ebx
  801a70:	39 f3                	cmp    %esi,%ebx
  801a72:	72 d9                	jb     801a4d <readn+0x16>
  801a74:	89 d8                	mov    %ebx,%eax
  801a76:	eb 02                	jmp    801a7a <readn+0x43>
  801a78:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a7a:	83 c4 1c             	add    $0x1c,%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	5f                   	pop    %edi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	83 ec 24             	sub    $0x24,%esp
  801a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a93:	89 1c 24             	mov    %ebx,(%esp)
  801a96:	e8 7b fc ff ff       	call   801716 <fd_lookup>
  801a9b:	89 c2                	mov    %eax,%edx
  801a9d:	85 d2                	test   %edx,%edx
  801a9f:	78 68                	js     801b09 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aab:	8b 00                	mov    (%eax),%eax
  801aad:	89 04 24             	mov    %eax,(%esp)
  801ab0:	e8 b7 fc ff ff       	call   80176c <dev_lookup>
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 50                	js     801b09 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ac0:	75 23                	jne    801ae5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ac2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ac7:	8b 40 48             	mov    0x48(%eax),%eax
  801aca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad2:	c7 04 24 ac 2e 80 00 	movl   $0x802eac,(%esp)
  801ad9:	e8 ff ed ff ff       	call   8008dd <cprintf>
		return -E_INVAL;
  801ade:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ae3:	eb 24                	jmp    801b09 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ae5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae8:	8b 52 0c             	mov    0xc(%edx),%edx
  801aeb:	85 d2                	test   %edx,%edx
  801aed:	74 15                	je     801b04 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801aef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801af2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801afd:	89 04 24             	mov    %eax,(%esp)
  801b00:	ff d2                	call   *%edx
  801b02:	eb 05                	jmp    801b09 <write+0x87>
		return -E_NOT_SUPP;
  801b04:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801b09:	83 c4 24             	add    $0x24,%esp
  801b0c:	5b                   	pop    %ebx
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    

00801b0f <seek>:

int
seek(int fdnum, off_t offset)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b15:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	89 04 24             	mov    %eax,(%esp)
  801b22:	e8 ef fb ff ff       	call   801716 <fd_lookup>
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 0e                	js     801b39 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b31:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 24             	sub    $0x24,%esp
  801b42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4c:	89 1c 24             	mov    %ebx,(%esp)
  801b4f:	e8 c2 fb ff ff       	call   801716 <fd_lookup>
  801b54:	89 c2                	mov    %eax,%edx
  801b56:	85 d2                	test   %edx,%edx
  801b58:	78 61                	js     801bbb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b64:	8b 00                	mov    (%eax),%eax
  801b66:	89 04 24             	mov    %eax,(%esp)
  801b69:	e8 fe fb ff ff       	call   80176c <dev_lookup>
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 49                	js     801bbb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b75:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b79:	75 23                	jne    801b9e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b7b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b80:	8b 40 48             	mov    0x48(%eax),%eax
  801b83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8b:	c7 04 24 6c 2e 80 00 	movl   $0x802e6c,(%esp)
  801b92:	e8 46 ed ff ff       	call   8008dd <cprintf>
		return -E_INVAL;
  801b97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b9c:	eb 1d                	jmp    801bbb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801b9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba1:	8b 52 18             	mov    0x18(%edx),%edx
  801ba4:	85 d2                	test   %edx,%edx
  801ba6:	74 0e                	je     801bb6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801baf:	89 04 24             	mov    %eax,(%esp)
  801bb2:	ff d2                	call   *%edx
  801bb4:	eb 05                	jmp    801bbb <ftruncate+0x80>
		return -E_NOT_SUPP;
  801bb6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801bbb:	83 c4 24             	add    $0x24,%esp
  801bbe:	5b                   	pop    %ebx
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 24             	sub    $0x24,%esp
  801bc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bcb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd5:	89 04 24             	mov    %eax,(%esp)
  801bd8:	e8 39 fb ff ff       	call   801716 <fd_lookup>
  801bdd:	89 c2                	mov    %eax,%edx
  801bdf:	85 d2                	test   %edx,%edx
  801be1:	78 52                	js     801c35 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801be3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bed:	8b 00                	mov    (%eax),%eax
  801bef:	89 04 24             	mov    %eax,(%esp)
  801bf2:	e8 75 fb ff ff       	call   80176c <dev_lookup>
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 3a                	js     801c35 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c02:	74 2c                	je     801c30 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c04:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c07:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c0e:	00 00 00 
	stat->st_isdir = 0;
  801c11:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c18:	00 00 00 
	stat->st_dev = dev;
  801c1b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c25:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c28:	89 14 24             	mov    %edx,(%esp)
  801c2b:	ff 50 14             	call   *0x14(%eax)
  801c2e:	eb 05                	jmp    801c35 <fstat+0x74>
		return -E_NOT_SUPP;
  801c30:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801c35:	83 c4 24             	add    $0x24,%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	56                   	push   %esi
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c43:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c4a:	00 
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	89 04 24             	mov    %eax,(%esp)
  801c51:	e8 fb 01 00 00       	call   801e51 <open>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	85 db                	test   %ebx,%ebx
  801c5a:	78 1b                	js     801c77 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c63:	89 1c 24             	mov    %ebx,(%esp)
  801c66:	e8 56 ff ff ff       	call   801bc1 <fstat>
  801c6b:	89 c6                	mov    %eax,%esi
	close(fd);
  801c6d:	89 1c 24             	mov    %ebx,(%esp)
  801c70:	e8 cd fb ff ff       	call   801842 <close>
	return r;
  801c75:	89 f0                	mov    %esi,%eax
}
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	5b                   	pop    %ebx
  801c7b:	5e                   	pop    %esi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	56                   	push   %esi
  801c82:	53                   	push   %ebx
  801c83:	83 ec 10             	sub    $0x10,%esp
  801c86:	89 c6                	mov    %eax,%esi
  801c88:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801c8a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c91:	75 11                	jne    801ca4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c9a:	e8 c0 f9 ff ff       	call   80165f <ipc_find_env>
  801c9f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ca4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cab:	00 
  801cac:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cb3:	00 
  801cb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb8:	a1 04 40 80 00       	mov    0x804004,%eax
  801cbd:	89 04 24             	mov    %eax,(%esp)
  801cc0:	e8 33 f9 ff ff       	call   8015f8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cc5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ccc:	00 
  801ccd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd8:	e8 b3 f8 ff ff       	call   801590 <ipc_recv>
}
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	8b 40 0c             	mov    0xc(%eax),%eax
  801cf0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801cf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  801d02:	b8 02 00 00 00       	mov    $0x2,%eax
  801d07:	e8 72 ff ff ff       	call   801c7e <fsipc>
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <devfile_flush>:
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	8b 40 0c             	mov    0xc(%eax),%eax
  801d1a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d24:	b8 06 00 00 00       	mov    $0x6,%eax
  801d29:	e8 50 ff ff ff       	call   801c7e <fsipc>
}
  801d2e:	c9                   	leave  
  801d2f:	c3                   	ret    

00801d30 <devfile_stat>:
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	53                   	push   %ebx
  801d34:	83 ec 14             	sub    $0x14,%esp
  801d37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d40:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d45:	ba 00 00 00 00       	mov    $0x0,%edx
  801d4a:	b8 05 00 00 00       	mov    $0x5,%eax
  801d4f:	e8 2a ff ff ff       	call   801c7e <fsipc>
  801d54:	89 c2                	mov    %eax,%edx
  801d56:	85 d2                	test   %edx,%edx
  801d58:	78 2b                	js     801d85 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d5a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d61:	00 
  801d62:	89 1c 24             	mov    %ebx,(%esp)
  801d65:	e8 9d f1 ff ff       	call   800f07 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d6a:	a1 80 50 80 00       	mov    0x805080,%eax
  801d6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d75:	a1 84 50 80 00       	mov    0x805084,%eax
  801d7a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d85:	83 c4 14             	add    $0x14,%esp
  801d88:	5b                   	pop    %ebx
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <devfile_write>:
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  801d91:	c7 44 24 08 dc 2e 80 	movl   $0x802edc,0x8(%esp)
  801d98:	00 
  801d99:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801da0:	00 
  801da1:	c7 04 24 fa 2e 80 00 	movl   $0x802efa,(%esp)
  801da8:	e8 37 ea ff ff       	call   8007e4 <_panic>

00801dad <devfile_read>:
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	56                   	push   %esi
  801db1:	53                   	push   %ebx
  801db2:	83 ec 10             	sub    $0x10,%esp
  801db5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	8b 40 0c             	mov    0xc(%eax),%eax
  801dbe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801dc3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801dc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801dce:	b8 03 00 00 00       	mov    $0x3,%eax
  801dd3:	e8 a6 fe ff ff       	call   801c7e <fsipc>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 6a                	js     801e48 <devfile_read+0x9b>
	assert(r <= n);
  801dde:	39 c6                	cmp    %eax,%esi
  801de0:	73 24                	jae    801e06 <devfile_read+0x59>
  801de2:	c7 44 24 0c 05 2f 80 	movl   $0x802f05,0xc(%esp)
  801de9:	00 
  801dea:	c7 44 24 08 0c 2f 80 	movl   $0x802f0c,0x8(%esp)
  801df1:	00 
  801df2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801df9:	00 
  801dfa:	c7 04 24 fa 2e 80 00 	movl   $0x802efa,(%esp)
  801e01:	e8 de e9 ff ff       	call   8007e4 <_panic>
	assert(r <= PGSIZE);
  801e06:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e0b:	7e 24                	jle    801e31 <devfile_read+0x84>
  801e0d:	c7 44 24 0c 21 2f 80 	movl   $0x802f21,0xc(%esp)
  801e14:	00 
  801e15:	c7 44 24 08 0c 2f 80 	movl   $0x802f0c,0x8(%esp)
  801e1c:	00 
  801e1d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801e24:	00 
  801e25:	c7 04 24 fa 2e 80 00 	movl   $0x802efa,(%esp)
  801e2c:	e8 b3 e9 ff ff       	call   8007e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e31:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e35:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e3c:	00 
  801e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e40:	89 04 24             	mov    %eax,(%esp)
  801e43:	e8 5c f2 ff ff       	call   8010a4 <memmove>
}
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <open>:
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	53                   	push   %ebx
  801e55:	83 ec 24             	sub    $0x24,%esp
  801e58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e5b:	89 1c 24             	mov    %ebx,(%esp)
  801e5e:	e8 6d f0 ff ff       	call   800ed0 <strlen>
  801e63:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e68:	7f 60                	jg     801eca <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801e6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6d:	89 04 24             	mov    %eax,(%esp)
  801e70:	e8 52 f8 ff ff       	call   8016c7 <fd_alloc>
  801e75:	89 c2                	mov    %eax,%edx
  801e77:	85 d2                	test   %edx,%edx
  801e79:	78 54                	js     801ecf <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801e7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e7f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e86:	e8 7c f0 ff ff       	call   800f07 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e93:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e96:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9b:	e8 de fd ff ff       	call   801c7e <fsipc>
  801ea0:	89 c3                	mov    %eax,%ebx
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	79 17                	jns    801ebd <open+0x6c>
		fd_close(fd, 0);
  801ea6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ead:	00 
  801eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb1:	89 04 24             	mov    %eax,(%esp)
  801eb4:	e8 08 f9 ff ff       	call   8017c1 <fd_close>
		return r;
  801eb9:	89 d8                	mov    %ebx,%eax
  801ebb:	eb 12                	jmp    801ecf <open+0x7e>
	return fd2num(fd);
  801ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec0:	89 04 24             	mov    %eax,(%esp)
  801ec3:	e8 d8 f7 ff ff       	call   8016a0 <fd2num>
  801ec8:	eb 05                	jmp    801ecf <open+0x7e>
		return -E_BAD_PATH;
  801eca:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801ecf:	83 c4 24             	add    $0x24,%esp
  801ed2:	5b                   	pop    %ebx
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801edb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ee5:	e8 94 fd ff ff       	call   801c7e <fsipc>
}
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	83 ec 10             	sub    $0x10,%esp
  801ef4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  801efa:	89 04 24             	mov    %eax,(%esp)
  801efd:	e8 ae f7 ff ff       	call   8016b0 <fd2data>
  801f02:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f04:	c7 44 24 04 2d 2f 80 	movl   $0x802f2d,0x4(%esp)
  801f0b:	00 
  801f0c:	89 1c 24             	mov    %ebx,(%esp)
  801f0f:	e8 f3 ef ff ff       	call   800f07 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f14:	8b 46 04             	mov    0x4(%esi),%eax
  801f17:	2b 06                	sub    (%esi),%eax
  801f19:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f1f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f26:	00 00 00 
	stat->st_dev = &devpipe;
  801f29:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801f30:	30 80 00 
	return 0;
}
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	5b                   	pop    %ebx
  801f3c:	5e                   	pop    %esi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    

00801f3f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	53                   	push   %ebx
  801f43:	83 ec 14             	sub    $0x14,%esp
  801f46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f49:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f54:	e8 71 f4 ff ff       	call   8013ca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f59:	89 1c 24             	mov    %ebx,(%esp)
  801f5c:	e8 4f f7 ff ff       	call   8016b0 <fd2data>
  801f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6c:	e8 59 f4 ff ff       	call   8013ca <sys_page_unmap>
}
  801f71:	83 c4 14             	add    $0x14,%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <_pipeisclosed>:
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	57                   	push   %edi
  801f7b:	56                   	push   %esi
  801f7c:	53                   	push   %ebx
  801f7d:	83 ec 2c             	sub    $0x2c,%esp
  801f80:	89 c6                	mov    %eax,%esi
  801f82:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801f85:	a1 08 40 80 00       	mov    0x804008,%eax
  801f8a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f8d:	89 34 24             	mov    %esi,(%esp)
  801f90:	e8 81 04 00 00       	call   802416 <pageref>
  801f95:	89 c7                	mov    %eax,%edi
  801f97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f9a:	89 04 24             	mov    %eax,(%esp)
  801f9d:	e8 74 04 00 00       	call   802416 <pageref>
  801fa2:	39 c7                	cmp    %eax,%edi
  801fa4:	0f 94 c2             	sete   %dl
  801fa7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801faa:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801fb0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801fb3:	39 fb                	cmp    %edi,%ebx
  801fb5:	74 21                	je     801fd8 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801fb7:	84 d2                	test   %dl,%dl
  801fb9:	74 ca                	je     801f85 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fbb:	8b 51 58             	mov    0x58(%ecx),%edx
  801fbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fc2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fca:	c7 04 24 34 2f 80 00 	movl   $0x802f34,(%esp)
  801fd1:	e8 07 e9 ff ff       	call   8008dd <cprintf>
  801fd6:	eb ad                	jmp    801f85 <_pipeisclosed+0xe>
}
  801fd8:	83 c4 2c             	add    $0x2c,%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5e                   	pop    %esi
  801fdd:	5f                   	pop    %edi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

00801fe0 <devpipe_write>:
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	53                   	push   %ebx
  801fe6:	83 ec 1c             	sub    $0x1c,%esp
  801fe9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801fec:	89 34 24             	mov    %esi,(%esp)
  801fef:	e8 bc f6 ff ff       	call   8016b0 <fd2data>
  801ff4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ff6:	bf 00 00 00 00       	mov    $0x0,%edi
  801ffb:	eb 45                	jmp    802042 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  801ffd:	89 da                	mov    %ebx,%edx
  801fff:	89 f0                	mov    %esi,%eax
  802001:	e8 71 ff ff ff       	call   801f77 <_pipeisclosed>
  802006:	85 c0                	test   %eax,%eax
  802008:	75 41                	jne    80204b <devpipe_write+0x6b>
			sys_yield();
  80200a:	e8 f5 f2 ff ff       	call   801304 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80200f:	8b 43 04             	mov    0x4(%ebx),%eax
  802012:	8b 0b                	mov    (%ebx),%ecx
  802014:	8d 51 20             	lea    0x20(%ecx),%edx
  802017:	39 d0                	cmp    %edx,%eax
  802019:	73 e2                	jae    801ffd <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80201b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80201e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802022:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802025:	99                   	cltd   
  802026:	c1 ea 1b             	shr    $0x1b,%edx
  802029:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80202c:	83 e1 1f             	and    $0x1f,%ecx
  80202f:	29 d1                	sub    %edx,%ecx
  802031:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802035:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802039:	83 c0 01             	add    $0x1,%eax
  80203c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80203f:	83 c7 01             	add    $0x1,%edi
  802042:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802045:	75 c8                	jne    80200f <devpipe_write+0x2f>
	return i;
  802047:	89 f8                	mov    %edi,%eax
  802049:	eb 05                	jmp    802050 <devpipe_write+0x70>
				return 0;
  80204b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    

00802058 <devpipe_read>:
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	57                   	push   %edi
  80205c:	56                   	push   %esi
  80205d:	53                   	push   %ebx
  80205e:	83 ec 1c             	sub    $0x1c,%esp
  802061:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802064:	89 3c 24             	mov    %edi,(%esp)
  802067:	e8 44 f6 ff ff       	call   8016b0 <fd2data>
  80206c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80206e:	be 00 00 00 00       	mov    $0x0,%esi
  802073:	eb 3d                	jmp    8020b2 <devpipe_read+0x5a>
			if (i > 0)
  802075:	85 f6                	test   %esi,%esi
  802077:	74 04                	je     80207d <devpipe_read+0x25>
				return i;
  802079:	89 f0                	mov    %esi,%eax
  80207b:	eb 43                	jmp    8020c0 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  80207d:	89 da                	mov    %ebx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	e8 f1 fe ff ff       	call   801f77 <_pipeisclosed>
  802086:	85 c0                	test   %eax,%eax
  802088:	75 31                	jne    8020bb <devpipe_read+0x63>
			sys_yield();
  80208a:	e8 75 f2 ff ff       	call   801304 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80208f:	8b 03                	mov    (%ebx),%eax
  802091:	3b 43 04             	cmp    0x4(%ebx),%eax
  802094:	74 df                	je     802075 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802096:	99                   	cltd   
  802097:	c1 ea 1b             	shr    $0x1b,%edx
  80209a:	01 d0                	add    %edx,%eax
  80209c:	83 e0 1f             	and    $0x1f,%eax
  80209f:	29 d0                	sub    %edx,%eax
  8020a1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020ac:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020af:	83 c6 01             	add    $0x1,%esi
  8020b2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020b5:	75 d8                	jne    80208f <devpipe_read+0x37>
	return i;
  8020b7:	89 f0                	mov    %esi,%eax
  8020b9:	eb 05                	jmp    8020c0 <devpipe_read+0x68>
				return 0;
  8020bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    

008020c8 <pipe>:
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
  8020cd:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d3:	89 04 24             	mov    %eax,(%esp)
  8020d6:	e8 ec f5 ff ff       	call   8016c7 <fd_alloc>
  8020db:	89 c2                	mov    %eax,%edx
  8020dd:	85 d2                	test   %edx,%edx
  8020df:	0f 88 4d 01 00 00    	js     802232 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020ec:	00 
  8020ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020fb:	e8 23 f2 ff ff       	call   801323 <sys_page_alloc>
  802100:	89 c2                	mov    %eax,%edx
  802102:	85 d2                	test   %edx,%edx
  802104:	0f 88 28 01 00 00    	js     802232 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  80210a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80210d:	89 04 24             	mov    %eax,(%esp)
  802110:	e8 b2 f5 ff ff       	call   8016c7 <fd_alloc>
  802115:	89 c3                	mov    %eax,%ebx
  802117:	85 c0                	test   %eax,%eax
  802119:	0f 88 fe 00 00 00    	js     80221d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802126:	00 
  802127:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80212a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802135:	e8 e9 f1 ff ff       	call   801323 <sys_page_alloc>
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	85 c0                	test   %eax,%eax
  80213e:	0f 88 d9 00 00 00    	js     80221d <pipe+0x155>
	va = fd2data(fd0);
  802144:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802147:	89 04 24             	mov    %eax,(%esp)
  80214a:	e8 61 f5 ff ff       	call   8016b0 <fd2data>
  80214f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802151:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802158:	00 
  802159:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802164:	e8 ba f1 ff ff       	call   801323 <sys_page_alloc>
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	85 c0                	test   %eax,%eax
  80216d:	0f 88 97 00 00 00    	js     80220a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802173:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802176:	89 04 24             	mov    %eax,(%esp)
  802179:	e8 32 f5 ff ff       	call   8016b0 <fd2data>
  80217e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802185:	00 
  802186:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802191:	00 
  802192:	89 74 24 04          	mov    %esi,0x4(%esp)
  802196:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80219d:	e8 d5 f1 ff ff       	call   801377 <sys_page_map>
  8021a2:	89 c3                	mov    %eax,%ebx
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 52                	js     8021fa <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  8021a8:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8021ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8021bd:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8021c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021cb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d5:	89 04 24             	mov    %eax,(%esp)
  8021d8:	e8 c3 f4 ff ff       	call   8016a0 <fd2num>
  8021dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021e0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e5:	89 04 24             	mov    %eax,(%esp)
  8021e8:	e8 b3 f4 ff ff       	call   8016a0 <fd2num>
  8021ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021f0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f8:	eb 38                	jmp    802232 <pipe+0x16a>
	sys_page_unmap(0, va);
  8021fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802205:	e8 c0 f1 ff ff       	call   8013ca <sys_page_unmap>
	sys_page_unmap(0, fd1);
  80220a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80220d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802211:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802218:	e8 ad f1 ff ff       	call   8013ca <sys_page_unmap>
	sys_page_unmap(0, fd0);
  80221d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802220:	89 44 24 04          	mov    %eax,0x4(%esp)
  802224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80222b:	e8 9a f1 ff ff       	call   8013ca <sys_page_unmap>
  802230:	89 d8                	mov    %ebx,%eax
}
  802232:	83 c4 30             	add    $0x30,%esp
  802235:	5b                   	pop    %ebx
  802236:	5e                   	pop    %esi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    

00802239 <pipeisclosed>:
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80223f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802242:	89 44 24 04          	mov    %eax,0x4(%esp)
  802246:	8b 45 08             	mov    0x8(%ebp),%eax
  802249:	89 04 24             	mov    %eax,(%esp)
  80224c:	e8 c5 f4 ff ff       	call   801716 <fd_lookup>
  802251:	89 c2                	mov    %eax,%edx
  802253:	85 d2                	test   %edx,%edx
  802255:	78 15                	js     80226c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  802257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225a:	89 04 24             	mov    %eax,(%esp)
  80225d:	e8 4e f4 ff ff       	call   8016b0 <fd2data>
	return _pipeisclosed(fd, p);
  802262:	89 c2                	mov    %eax,%edx
  802264:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802267:	e8 0b fd ff ff       	call   801f77 <_pipeisclosed>
}
  80226c:	c9                   	leave  
  80226d:	c3                   	ret    
  80226e:	66 90                	xchg   %ax,%ax

00802270 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802273:	b8 00 00 00 00       	mov    $0x0,%eax
  802278:	5d                   	pop    %ebp
  802279:	c3                   	ret    

0080227a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80227a:	55                   	push   %ebp
  80227b:	89 e5                	mov    %esp,%ebp
  80227d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802280:	c7 44 24 04 4c 2f 80 	movl   $0x802f4c,0x4(%esp)
  802287:	00 
  802288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228b:	89 04 24             	mov    %eax,(%esp)
  80228e:	e8 74 ec ff ff       	call   800f07 <strcpy>
	return 0;
}
  802293:	b8 00 00 00 00       	mov    $0x0,%eax
  802298:	c9                   	leave  
  802299:	c3                   	ret    

0080229a <devcons_write>:
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	57                   	push   %edi
  80229e:	56                   	push   %esi
  80229f:	53                   	push   %ebx
  8022a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022b1:	eb 31                	jmp    8022e4 <devcons_write+0x4a>
		m = n - tot;
  8022b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8022b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8022b8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  8022bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022c0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022c3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022c7:	03 45 0c             	add    0xc(%ebp),%eax
  8022ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ce:	89 3c 24             	mov    %edi,(%esp)
  8022d1:	e8 ce ed ff ff       	call   8010a4 <memmove>
		sys_cputs(buf, m);
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	89 3c 24             	mov    %edi,(%esp)
  8022dd:	e8 74 ef ff ff       	call   801256 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8022e2:	01 f3                	add    %esi,%ebx
  8022e4:	89 d8                	mov    %ebx,%eax
  8022e6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022e9:	72 c8                	jb     8022b3 <devcons_write+0x19>
}
  8022eb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8022f1:	5b                   	pop    %ebx
  8022f2:	5e                   	pop    %esi
  8022f3:	5f                   	pop    %edi
  8022f4:	5d                   	pop    %ebp
  8022f5:	c3                   	ret    

008022f6 <devcons_read>:
{
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	83 ec 08             	sub    $0x8,%esp
		return 0;
  8022fc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802301:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802305:	75 07                	jne    80230e <devcons_read+0x18>
  802307:	eb 2a                	jmp    802333 <devcons_read+0x3d>
		sys_yield();
  802309:	e8 f6 ef ff ff       	call   801304 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80230e:	66 90                	xchg   %ax,%ax
  802310:	e8 5f ef ff ff       	call   801274 <sys_cgetc>
  802315:	85 c0                	test   %eax,%eax
  802317:	74 f0                	je     802309 <devcons_read+0x13>
	if (c < 0)
  802319:	85 c0                	test   %eax,%eax
  80231b:	78 16                	js     802333 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80231d:	83 f8 04             	cmp    $0x4,%eax
  802320:	74 0c                	je     80232e <devcons_read+0x38>
	*(char*)vbuf = c;
  802322:	8b 55 0c             	mov    0xc(%ebp),%edx
  802325:	88 02                	mov    %al,(%edx)
	return 1;
  802327:	b8 01 00 00 00       	mov    $0x1,%eax
  80232c:	eb 05                	jmp    802333 <devcons_read+0x3d>
		return 0;
  80232e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802333:	c9                   	leave  
  802334:	c3                   	ret    

00802335 <cputchar>:
{
  802335:	55                   	push   %ebp
  802336:	89 e5                	mov    %esp,%ebp
  802338:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80233b:	8b 45 08             	mov    0x8(%ebp),%eax
  80233e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802341:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802348:	00 
  802349:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80234c:	89 04 24             	mov    %eax,(%esp)
  80234f:	e8 02 ef ff ff       	call   801256 <sys_cputs>
}
  802354:	c9                   	leave  
  802355:	c3                   	ret    

00802356 <getchar>:
{
  802356:	55                   	push   %ebp
  802357:	89 e5                	mov    %esp,%ebp
  802359:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80235c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802363:	00 
  802364:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802372:	e8 2e f6 ff ff       	call   8019a5 <read>
	if (r < 0)
  802377:	85 c0                	test   %eax,%eax
  802379:	78 0f                	js     80238a <getchar+0x34>
	if (r < 1)
  80237b:	85 c0                	test   %eax,%eax
  80237d:	7e 06                	jle    802385 <getchar+0x2f>
	return c;
  80237f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802383:	eb 05                	jmp    80238a <getchar+0x34>
		return -E_EOF;
  802385:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80238a:	c9                   	leave  
  80238b:	c3                   	ret    

0080238c <iscons>:
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802392:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802395:	89 44 24 04          	mov    %eax,0x4(%esp)
  802399:	8b 45 08             	mov    0x8(%ebp),%eax
  80239c:	89 04 24             	mov    %eax,(%esp)
  80239f:	e8 72 f3 ff ff       	call   801716 <fd_lookup>
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	78 11                	js     8023b9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8023a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ab:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8023b1:	39 10                	cmp    %edx,(%eax)
  8023b3:	0f 94 c0             	sete   %al
  8023b6:	0f b6 c0             	movzbl %al,%eax
}
  8023b9:	c9                   	leave  
  8023ba:	c3                   	ret    

008023bb <opencons>:
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
  8023be:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c4:	89 04 24             	mov    %eax,(%esp)
  8023c7:	e8 fb f2 ff ff       	call   8016c7 <fd_alloc>
		return r;
  8023cc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8023ce:	85 c0                	test   %eax,%eax
  8023d0:	78 40                	js     802412 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023d9:	00 
  8023da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023e8:	e8 36 ef ff ff       	call   801323 <sys_page_alloc>
		return r;
  8023ed:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 1f                	js     802412 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8023f3:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8023f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802401:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802408:	89 04 24             	mov    %eax,(%esp)
  80240b:	e8 90 f2 ff ff       	call   8016a0 <fd2num>
  802410:	89 c2                	mov    %eax,%edx
}
  802412:	89 d0                	mov    %edx,%eax
  802414:	c9                   	leave  
  802415:	c3                   	ret    

00802416 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802416:	55                   	push   %ebp
  802417:	89 e5                	mov    %esp,%ebp
  802419:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80241c:	89 d0                	mov    %edx,%eax
  80241e:	c1 e8 16             	shr    $0x16,%eax
  802421:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802428:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80242d:	f6 c1 01             	test   $0x1,%cl
  802430:	74 1d                	je     80244f <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802432:	c1 ea 0c             	shr    $0xc,%edx
  802435:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80243c:	f6 c2 01             	test   $0x1,%dl
  80243f:	74 0e                	je     80244f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802441:	c1 ea 0c             	shr    $0xc,%edx
  802444:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80244b:	ef 
  80244c:	0f b7 c0             	movzwl %ax,%eax
}
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    
  802451:	66 90                	xchg   %ax,%ax
  802453:	66 90                	xchg   %ax,%ax
  802455:	66 90                	xchg   %ax,%ax
  802457:	66 90                	xchg   %ax,%ax
  802459:	66 90                	xchg   %ax,%ax
  80245b:	66 90                	xchg   %ax,%ax
  80245d:	66 90                	xchg   %ax,%ax
  80245f:	90                   	nop

00802460 <__udivdi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 0c             	sub    $0xc,%esp
  802466:	8b 44 24 28          	mov    0x28(%esp),%eax
  80246a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80246e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802472:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802476:	85 c0                	test   %eax,%eax
  802478:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80247c:	89 ea                	mov    %ebp,%edx
  80247e:	89 0c 24             	mov    %ecx,(%esp)
  802481:	75 2d                	jne    8024b0 <__udivdi3+0x50>
  802483:	39 e9                	cmp    %ebp,%ecx
  802485:	77 61                	ja     8024e8 <__udivdi3+0x88>
  802487:	85 c9                	test   %ecx,%ecx
  802489:	89 ce                	mov    %ecx,%esi
  80248b:	75 0b                	jne    802498 <__udivdi3+0x38>
  80248d:	b8 01 00 00 00       	mov    $0x1,%eax
  802492:	31 d2                	xor    %edx,%edx
  802494:	f7 f1                	div    %ecx
  802496:	89 c6                	mov    %eax,%esi
  802498:	31 d2                	xor    %edx,%edx
  80249a:	89 e8                	mov    %ebp,%eax
  80249c:	f7 f6                	div    %esi
  80249e:	89 c5                	mov    %eax,%ebp
  8024a0:	89 f8                	mov    %edi,%eax
  8024a2:	f7 f6                	div    %esi
  8024a4:	89 ea                	mov    %ebp,%edx
  8024a6:	83 c4 0c             	add    $0xc,%esp
  8024a9:	5e                   	pop    %esi
  8024aa:	5f                   	pop    %edi
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    
  8024ad:	8d 76 00             	lea    0x0(%esi),%esi
  8024b0:	39 e8                	cmp    %ebp,%eax
  8024b2:	77 24                	ja     8024d8 <__udivdi3+0x78>
  8024b4:	0f bd e8             	bsr    %eax,%ebp
  8024b7:	83 f5 1f             	xor    $0x1f,%ebp
  8024ba:	75 3c                	jne    8024f8 <__udivdi3+0x98>
  8024bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8024c0:	39 34 24             	cmp    %esi,(%esp)
  8024c3:	0f 86 9f 00 00 00    	jbe    802568 <__udivdi3+0x108>
  8024c9:	39 d0                	cmp    %edx,%eax
  8024cb:	0f 82 97 00 00 00    	jb     802568 <__udivdi3+0x108>
  8024d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	31 d2                	xor    %edx,%edx
  8024da:	31 c0                	xor    %eax,%eax
  8024dc:	83 c4 0c             	add    $0xc,%esp
  8024df:	5e                   	pop    %esi
  8024e0:	5f                   	pop    %edi
  8024e1:	5d                   	pop    %ebp
  8024e2:	c3                   	ret    
  8024e3:	90                   	nop
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	89 f8                	mov    %edi,%eax
  8024ea:	f7 f1                	div    %ecx
  8024ec:	31 d2                	xor    %edx,%edx
  8024ee:	83 c4 0c             	add    $0xc,%esp
  8024f1:	5e                   	pop    %esi
  8024f2:	5f                   	pop    %edi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    
  8024f5:	8d 76 00             	lea    0x0(%esi),%esi
  8024f8:	89 e9                	mov    %ebp,%ecx
  8024fa:	8b 3c 24             	mov    (%esp),%edi
  8024fd:	d3 e0                	shl    %cl,%eax
  8024ff:	89 c6                	mov    %eax,%esi
  802501:	b8 20 00 00 00       	mov    $0x20,%eax
  802506:	29 e8                	sub    %ebp,%eax
  802508:	89 c1                	mov    %eax,%ecx
  80250a:	d3 ef                	shr    %cl,%edi
  80250c:	89 e9                	mov    %ebp,%ecx
  80250e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802512:	8b 3c 24             	mov    (%esp),%edi
  802515:	09 74 24 08          	or     %esi,0x8(%esp)
  802519:	89 d6                	mov    %edx,%esi
  80251b:	d3 e7                	shl    %cl,%edi
  80251d:	89 c1                	mov    %eax,%ecx
  80251f:	89 3c 24             	mov    %edi,(%esp)
  802522:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802526:	d3 ee                	shr    %cl,%esi
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	d3 e2                	shl    %cl,%edx
  80252c:	89 c1                	mov    %eax,%ecx
  80252e:	d3 ef                	shr    %cl,%edi
  802530:	09 d7                	or     %edx,%edi
  802532:	89 f2                	mov    %esi,%edx
  802534:	89 f8                	mov    %edi,%eax
  802536:	f7 74 24 08          	divl   0x8(%esp)
  80253a:	89 d6                	mov    %edx,%esi
  80253c:	89 c7                	mov    %eax,%edi
  80253e:	f7 24 24             	mull   (%esp)
  802541:	39 d6                	cmp    %edx,%esi
  802543:	89 14 24             	mov    %edx,(%esp)
  802546:	72 30                	jb     802578 <__udivdi3+0x118>
  802548:	8b 54 24 04          	mov    0x4(%esp),%edx
  80254c:	89 e9                	mov    %ebp,%ecx
  80254e:	d3 e2                	shl    %cl,%edx
  802550:	39 c2                	cmp    %eax,%edx
  802552:	73 05                	jae    802559 <__udivdi3+0xf9>
  802554:	3b 34 24             	cmp    (%esp),%esi
  802557:	74 1f                	je     802578 <__udivdi3+0x118>
  802559:	89 f8                	mov    %edi,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	e9 7a ff ff ff       	jmp    8024dc <__udivdi3+0x7c>
  802562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802568:	31 d2                	xor    %edx,%edx
  80256a:	b8 01 00 00 00       	mov    $0x1,%eax
  80256f:	e9 68 ff ff ff       	jmp    8024dc <__udivdi3+0x7c>
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	8d 47 ff             	lea    -0x1(%edi),%eax
  80257b:	31 d2                	xor    %edx,%edx
  80257d:	83 c4 0c             	add    $0xc,%esp
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    
  802584:	66 90                	xchg   %ax,%ax
  802586:	66 90                	xchg   %ax,%ax
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__umoddi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	83 ec 14             	sub    $0x14,%esp
  802596:	8b 44 24 28          	mov    0x28(%esp),%eax
  80259a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80259e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8025a2:	89 c7                	mov    %eax,%edi
  8025a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8025b0:	89 34 24             	mov    %esi,(%esp)
  8025b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025b7:	85 c0                	test   %eax,%eax
  8025b9:	89 c2                	mov    %eax,%edx
  8025bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025bf:	75 17                	jne    8025d8 <__umoddi3+0x48>
  8025c1:	39 fe                	cmp    %edi,%esi
  8025c3:	76 4b                	jbe    802610 <__umoddi3+0x80>
  8025c5:	89 c8                	mov    %ecx,%eax
  8025c7:	89 fa                	mov    %edi,%edx
  8025c9:	f7 f6                	div    %esi
  8025cb:	89 d0                	mov    %edx,%eax
  8025cd:	31 d2                	xor    %edx,%edx
  8025cf:	83 c4 14             	add    $0x14,%esp
  8025d2:	5e                   	pop    %esi
  8025d3:	5f                   	pop    %edi
  8025d4:	5d                   	pop    %ebp
  8025d5:	c3                   	ret    
  8025d6:	66 90                	xchg   %ax,%ax
  8025d8:	39 f8                	cmp    %edi,%eax
  8025da:	77 54                	ja     802630 <__umoddi3+0xa0>
  8025dc:	0f bd e8             	bsr    %eax,%ebp
  8025df:	83 f5 1f             	xor    $0x1f,%ebp
  8025e2:	75 5c                	jne    802640 <__umoddi3+0xb0>
  8025e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8025e8:	39 3c 24             	cmp    %edi,(%esp)
  8025eb:	0f 87 e7 00 00 00    	ja     8026d8 <__umoddi3+0x148>
  8025f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025f5:	29 f1                	sub    %esi,%ecx
  8025f7:	19 c7                	sbb    %eax,%edi
  8025f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802601:	8b 44 24 08          	mov    0x8(%esp),%eax
  802605:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802609:	83 c4 14             	add    $0x14,%esp
  80260c:	5e                   	pop    %esi
  80260d:	5f                   	pop    %edi
  80260e:	5d                   	pop    %ebp
  80260f:	c3                   	ret    
  802610:	85 f6                	test   %esi,%esi
  802612:	89 f5                	mov    %esi,%ebp
  802614:	75 0b                	jne    802621 <__umoddi3+0x91>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f6                	div    %esi
  80261f:	89 c5                	mov    %eax,%ebp
  802621:	8b 44 24 04          	mov    0x4(%esp),%eax
  802625:	31 d2                	xor    %edx,%edx
  802627:	f7 f5                	div    %ebp
  802629:	89 c8                	mov    %ecx,%eax
  80262b:	f7 f5                	div    %ebp
  80262d:	eb 9c                	jmp    8025cb <__umoddi3+0x3b>
  80262f:	90                   	nop
  802630:	89 c8                	mov    %ecx,%eax
  802632:	89 fa                	mov    %edi,%edx
  802634:	83 c4 14             	add    $0x14,%esp
  802637:	5e                   	pop    %esi
  802638:	5f                   	pop    %edi
  802639:	5d                   	pop    %ebp
  80263a:	c3                   	ret    
  80263b:	90                   	nop
  80263c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802640:	8b 04 24             	mov    (%esp),%eax
  802643:	be 20 00 00 00       	mov    $0x20,%esi
  802648:	89 e9                	mov    %ebp,%ecx
  80264a:	29 ee                	sub    %ebp,%esi
  80264c:	d3 e2                	shl    %cl,%edx
  80264e:	89 f1                	mov    %esi,%ecx
  802650:	d3 e8                	shr    %cl,%eax
  802652:	89 e9                	mov    %ebp,%ecx
  802654:	89 44 24 04          	mov    %eax,0x4(%esp)
  802658:	8b 04 24             	mov    (%esp),%eax
  80265b:	09 54 24 04          	or     %edx,0x4(%esp)
  80265f:	89 fa                	mov    %edi,%edx
  802661:	d3 e0                	shl    %cl,%eax
  802663:	89 f1                	mov    %esi,%ecx
  802665:	89 44 24 08          	mov    %eax,0x8(%esp)
  802669:	8b 44 24 10          	mov    0x10(%esp),%eax
  80266d:	d3 ea                	shr    %cl,%edx
  80266f:	89 e9                	mov    %ebp,%ecx
  802671:	d3 e7                	shl    %cl,%edi
  802673:	89 f1                	mov    %esi,%ecx
  802675:	d3 e8                	shr    %cl,%eax
  802677:	89 e9                	mov    %ebp,%ecx
  802679:	09 f8                	or     %edi,%eax
  80267b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80267f:	f7 74 24 04          	divl   0x4(%esp)
  802683:	d3 e7                	shl    %cl,%edi
  802685:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802689:	89 d7                	mov    %edx,%edi
  80268b:	f7 64 24 08          	mull   0x8(%esp)
  80268f:	39 d7                	cmp    %edx,%edi
  802691:	89 c1                	mov    %eax,%ecx
  802693:	89 14 24             	mov    %edx,(%esp)
  802696:	72 2c                	jb     8026c4 <__umoddi3+0x134>
  802698:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80269c:	72 22                	jb     8026c0 <__umoddi3+0x130>
  80269e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026a2:	29 c8                	sub    %ecx,%eax
  8026a4:	19 d7                	sbb    %edx,%edi
  8026a6:	89 e9                	mov    %ebp,%ecx
  8026a8:	89 fa                	mov    %edi,%edx
  8026aa:	d3 e8                	shr    %cl,%eax
  8026ac:	89 f1                	mov    %esi,%ecx
  8026ae:	d3 e2                	shl    %cl,%edx
  8026b0:	89 e9                	mov    %ebp,%ecx
  8026b2:	d3 ef                	shr    %cl,%edi
  8026b4:	09 d0                	or     %edx,%eax
  8026b6:	89 fa                	mov    %edi,%edx
  8026b8:	83 c4 14             	add    $0x14,%esp
  8026bb:	5e                   	pop    %esi
  8026bc:	5f                   	pop    %edi
  8026bd:	5d                   	pop    %ebp
  8026be:	c3                   	ret    
  8026bf:	90                   	nop
  8026c0:	39 d7                	cmp    %edx,%edi
  8026c2:	75 da                	jne    80269e <__umoddi3+0x10e>
  8026c4:	8b 14 24             	mov    (%esp),%edx
  8026c7:	89 c1                	mov    %eax,%ecx
  8026c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8026cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8026d1:	eb cb                	jmp    80269e <__umoddi3+0x10e>
  8026d3:	90                   	nop
  8026d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8026dc:	0f 82 0f ff ff ff    	jb     8025f1 <__umoddi3+0x61>
  8026e2:	e9 1a ff ff ff       	jmp    802601 <__umoddi3+0x71>
