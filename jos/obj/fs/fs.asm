
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 b6 1c 00 00       	call   801ce7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	b2 f7                	mov    $0xf7,%dl
  800082:	eb 0b                	jmp    80008f <ide_probe_disk1+0x30>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800084:	83 c1 01             	add    $0x1,%ecx
	for (x = 0;
  800087:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  80008d:	74 05                	je     800094 <ide_probe_disk1+0x35>
  80008f:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800090:	a8 a1                	test   $0xa1,%al
  800092:	75 f0                	jne    800084 <ide_probe_disk1+0x25>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800094:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800099:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009e:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  80009f:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a5:	0f 9e c3             	setle  %bl
  8000a8:	0f b6 c3             	movzbl %bl,%eax
  8000ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000af:	c7 04 24 00 3d 80 00 	movl   $0x803d00,(%esp)
  8000b6:	e8 86 1d 00 00       	call   801e41 <cprintf>
	return (x < 1000);
}
  8000bb:	89 d8                	mov    %ebx,%eax
  8000bd:	83 c4 14             	add    $0x14,%esp
  8000c0:	5b                   	pop    %ebx
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 18             	sub    $0x18,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 1c                	jbe    8000ed <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d1:	c7 44 24 08 17 3d 80 	movl   $0x803d17,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 27 3d 80 00 	movl   $0x803d27,(%esp)
  8000e8:	e8 5b 1c 00 00       	call   801d48 <_panic>
	diskno = d;
  8000ed:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 1c             	sub    $0x1c,%esp
  8000fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800103:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800106:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80010c:	76 24                	jbe    800132 <ide_read+0x3e>
  80010e:	c7 44 24 0c 30 3d 80 	movl   $0x803d30,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 27 3d 80 00 	movl   $0x803d27,(%esp)
  80012d:	e8 16 1c 00 00       	call   801d48 <_panic>

	ide_wait_ready(0);
  800132:	b8 00 00 00 00       	mov    $0x0,%eax
  800137:	e8 f7 fe ff ff       	call   800033 <ide_wait_ready>
  80013c:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800141:	89 f0                	mov    %esi,%eax
  800143:	ee                   	out    %al,(%dx)
  800144:	b2 f3                	mov    $0xf3,%dl
  800146:	89 f8                	mov    %edi,%eax
  800148:	ee                   	out    %al,(%dx)
  800149:	89 f8                	mov    %edi,%eax
  80014b:	0f b6 c4             	movzbl %ah,%eax
  80014e:	b2 f4                	mov    $0xf4,%dl
  800150:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 10             	shr    $0x10,%eax
  800156:	b2 f5                	mov    $0xf5,%dl
  800158:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800159:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800160:	83 e0 01             	and    $0x1,%eax
  800163:	c1 e0 04             	shl    $0x4,%eax
  800166:	83 c8 e0             	or     $0xffffffe0,%eax
  800169:	c1 ef 18             	shr    $0x18,%edi
  80016c:	83 e7 0f             	and    $0xf,%edi
  80016f:	09 f8                	or     %edi,%eax
  800171:	b2 f6                	mov    $0xf6,%dl
  800173:	ee                   	out    %al,(%dx)
  800174:	b2 f7                	mov    $0xf7,%dl
  800176:	b8 20 00 00 00       	mov    $0x20,%eax
  80017b:	ee                   	out    %al,(%dx)
  80017c:	c1 e6 09             	shl    $0x9,%esi
  80017f:	01 de                	add    %ebx,%esi
  800181:	eb 23                	jmp    8001a6 <ide_read+0xb2>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800183:	b8 01 00 00 00       	mov    $0x1,%eax
  800188:	e8 a6 fe ff ff       	call   800033 <ide_wait_ready>
  80018d:	85 c0                	test   %eax,%eax
  80018f:	78 1e                	js     8001af <ide_read+0xbb>
	asm volatile("cld\n\trepne\n\tinsl"
  800191:	89 df                	mov    %ebx,%edi
  800193:	b9 80 00 00 00       	mov    $0x80,%ecx
  800198:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019d:	fc                   	cld    
  80019e:	f2 6d                	repnz insl (%dx),%es:(%edi)
	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001a0:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8001a6:	39 f3                	cmp    %esi,%ebx
  8001a8:	75 d9                	jne    800183 <ide_read+0x8f>
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001af:	83 c4 1c             	add    $0x1c,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 1c             	sub    $0x1c,%esp
  8001c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c6:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c9:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001cf:	76 24                	jbe    8001f5 <ide_write+0x3e>
  8001d1:	c7 44 24 0c 30 3d 80 	movl   $0x803d30,0xc(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e8:	00 
  8001e9:	c7 04 24 27 3d 80 00 	movl   $0x803d27,(%esp)
  8001f0:	e8 53 1b 00 00       	call   801d48 <_panic>

	ide_wait_ready(0);
  8001f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8001fa:	e8 34 fe ff ff       	call   800033 <ide_wait_ready>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ff:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800204:	89 f8                	mov    %edi,%eax
  800206:	ee                   	out    %al,(%dx)
  800207:	b2 f3                	mov    $0xf3,%dl
  800209:	89 f0                	mov    %esi,%eax
  80020b:	ee                   	out    %al,(%dx)
  80020c:	89 f0                	mov    %esi,%eax
  80020e:	0f b6 c4             	movzbl %ah,%eax
  800211:	b2 f4                	mov    $0xf4,%dl
  800213:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
  800214:	89 f0                	mov    %esi,%eax
  800216:	c1 e8 10             	shr    $0x10,%eax
  800219:	b2 f5                	mov    $0xf5,%dl
  80021b:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800223:	83 e0 01             	and    $0x1,%eax
  800226:	c1 e0 04             	shl    $0x4,%eax
  800229:	83 c8 e0             	or     $0xffffffe0,%eax
  80022c:	c1 ee 18             	shr    $0x18,%esi
  80022f:	83 e6 0f             	and    $0xf,%esi
  800232:	09 f0                	or     %esi,%eax
  800234:	b2 f6                	mov    $0xf6,%dl
  800236:	ee                   	out    %al,(%dx)
  800237:	b2 f7                	mov    $0xf7,%dl
  800239:	b8 30 00 00 00       	mov    $0x30,%eax
  80023e:	ee                   	out    %al,(%dx)
  80023f:	c1 e7 09             	shl    $0x9,%edi
  800242:	01 df                	add    %ebx,%edi
  800244:	eb 23                	jmp    800269 <ide_write+0xb2>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800246:	b8 01 00 00 00       	mov    $0x1,%eax
  80024b:	e8 e3 fd ff ff       	call   800033 <ide_wait_ready>
  800250:	85 c0                	test   %eax,%eax
  800252:	78 1e                	js     800272 <ide_write+0xbb>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800254:	89 de                	mov    %ebx,%esi
  800256:	b9 80 00 00 00       	mov    $0x80,%ecx
  80025b:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800260:	fc                   	cld    
  800261:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800263:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800269:	39 fb                	cmp    %edi,%ebx
  80026b:	75 d9                	jne    800246 <ide_write+0x8f>
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800272:	83 c4 1c             	add    $0x1c,%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 20             	sub    $0x20,%esp
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800285:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800287:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80028d:	89 c6                	mov    %eax,%esi
  80028f:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800292:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800297:	76 2e                	jbe    8002c7 <bc_pgfault+0x4d>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800299:	8b 42 04             	mov    0x4(%edx),%eax
  80029c:	89 44 24 14          	mov    %eax,0x14(%esp)
  8002a0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002a4:	8b 42 28             	mov    0x28(%edx),%eax
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	c7 44 24 08 54 3d 80 	movl   $0x803d54,0x8(%esp)
  8002b2:	00 
  8002b3:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002ba:	00 
  8002bb:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  8002c2:	e8 81 1a 00 00       	call   801d48 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002c7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	74 25                	je     8002f5 <bc_pgfault+0x7b>
  8002d0:	3b 70 04             	cmp    0x4(%eax),%esi
  8002d3:	72 20                	jb     8002f5 <bc_pgfault+0x7b>
		panic("reading non-existent block %08x\n", blockno);
  8002d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d9:	c7 44 24 08 84 3d 80 	movl   $0x803d84,0x8(%esp)
  8002e0:	00 
  8002e1:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e8:	00 
  8002e9:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  8002f0:	e8 53 1a 00 00       	call   801d48 <_panic>
     *  Sectsize = 512 bytes per sector
     *
     */
    int perm = PTE_P | PTE_W | PTE_U;
  //  struct PageInfo* p = page_alloc(ALLOC_ZERO);
    addr = ROUNDDOWN(addr, PGSIZE);
  8002f5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    r = sys_page_alloc(0, addr, perm);// I'm not sure about the perms, so I'm going to give them the default
  8002fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800302:	00 
  800303:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80030e:	e8 70 25 00 00       	call   802883 <sys_page_alloc>
    if(r < 0){
  800313:	85 c0                	test   %eax,%eax
  800315:	79 1c                	jns    800333 <bc_pgfault+0xb9>
        panic("bc_pgfault: Sys_page_alloc has failed");
  800317:	c7 44 24 08 a8 3d 80 	movl   $0x803da8,0x8(%esp)
  80031e:	00 
  80031f:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800326:	00 
  800327:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  80032e:	e8 15 1a 00 00       	call   801d48 <_panic>
    }
    r = ide_read(blockno*BLKSECTS, addr, BLKSECTS); // I wonder if blocks can have custom sector sizes?
  800333:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  80033a:	00 
  80033b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033f:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	e8 a6 fd ff ff       	call   8000f4 <ide_read>
    if(r < 0){
  80034e:	85 c0                	test   %eax,%eax
  800350:	79 1c                	jns    80036e <bc_pgfault+0xf4>
        panic("bc_pgfault: ide_read has failed");
  800352:	c7 44 24 08 d0 3d 80 	movl   $0x803dd0,0x8(%esp)
  800359:	00 
  80035a:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  800361:	00 
  800362:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  800369:	e8 da 19 00 00       	call   801d48 <_panic>
    }
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80036e:	89 d8                	mov    %ebx,%eax
  800370:	c1 e8 0c             	shr    $0xc,%eax
  800373:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80037a:	25 07 0e 00 00       	and    $0xe07,%eax
  80037f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800383:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800387:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80038e:	00 
  80038f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800393:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80039a:	e8 38 25 00 00       	call   8028d7 <sys_page_map>
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	79 20                	jns    8003c3 <bc_pgfault+0x149>
		panic("in bc_pgfault, sys_page_map: %e", r);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	c7 44 24 08 f0 3d 80 	movl   $0x803df0,0x8(%esp)
  8003ae:	00 
  8003af:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8003b6:	00 
  8003b7:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  8003be:	e8 85 19 00 00       	call   801d48 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003c3:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  8003ca:	74 2c                	je     8003f8 <bc_pgfault+0x17e>
  8003cc:	89 34 24             	mov    %esi,(%esp)
  8003cf:	e8 7e 05 00 00       	call   800952 <block_is_free>
  8003d4:	84 c0                	test   %al,%al
  8003d6:	74 20                	je     8003f8 <bc_pgfault+0x17e>
		panic("reading free block %08x\n", blockno);
  8003d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003dc:	c7 44 24 08 60 3e 80 	movl   $0x803e60,0x8(%esp)
  8003e3:	00 
  8003e4:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  8003eb:	00 
  8003ec:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  8003f3:	e8 50 19 00 00       	call   801d48 <_panic>
}
  8003f8:	83 c4 20             	add    $0x20,%esp
  8003fb:	5b                   	pop    %ebx
  8003fc:	5e                   	pop    %esi
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <diskaddr>:
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	83 ec 18             	sub    $0x18,%esp
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800408:	85 c0                	test   %eax,%eax
  80040a:	74 0f                	je     80041b <diskaddr+0x1c>
  80040c:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	74 25                	je     80043b <diskaddr+0x3c>
  800416:	3b 42 04             	cmp    0x4(%edx),%eax
  800419:	72 20                	jb     80043b <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  80041b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041f:	c7 44 24 08 10 3e 80 	movl   $0x803e10,0x8(%esp)
  800426:	00 
  800427:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80042e:	00 
  80042f:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  800436:	e8 0d 19 00 00       	call   801d48 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80043b:	05 00 00 01 00       	add    $0x10000,%eax
  800440:	c1 e0 0c             	shl    $0xc,%eax
}
  800443:	c9                   	leave  
  800444:	c3                   	ret    

00800445 <va_is_mapped>:
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  80044b:	89 d0                	mov    %edx,%eax
  80044d:	c1 e8 16             	shr    $0x16,%eax
  800450:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	f6 c1 01             	test   $0x1,%cl
  80045f:	74 0d                	je     80046e <va_is_mapped+0x29>
  800461:	c1 ea 0c             	shr    $0xc,%edx
  800464:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80046b:	83 e0 01             	and    $0x1,%eax
  80046e:	83 e0 01             	and    $0x1,%eax
}
  800471:	5d                   	pop    %ebp
  800472:	c3                   	ret    

00800473 <va_is_dirty>:
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800476:	8b 45 08             	mov    0x8(%ebp),%eax
  800479:	c1 e8 0c             	shr    $0xc,%eax
  80047c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800483:	c1 e8 06             	shr    $0x6,%eax
  800486:	83 e0 01             	and    $0x1,%eax
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
  800490:	83 ec 20             	sub    $0x20,%esp
  800493:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800496:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80049c:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8004a1:	76 20                	jbe    8004c3 <flush_block+0x38>
		panic("flush_block of bad va %08x", addr);
  8004a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004a7:	c7 44 24 08 79 3e 80 	movl   $0x803e79,0x8(%esp)
  8004ae:	00 
  8004af:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  8004b6:	00 
  8004b7:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  8004be:	e8 85 18 00 00       	call   801d48 <_panic>
	// LAB 5: Your code here.
    /* The exercise mentions that if it's dirty, as in PTE_D is set, then we need to write a new block out.
     * That is why "blockno" is provided.
     * The hints mention functions in the first line. look above
     */
    addr = ROUNDDOWN(addr, PGSIZE);
  8004c3:	89 de                	mov    %ebx,%esi
  8004c5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    int r;
    if( !(va_is_mapped(addr)) || !(va_is_dirty(addr)) ){
  8004cb:	89 34 24             	mov    %esi,(%esp)
  8004ce:	e8 72 ff ff ff       	call   800445 <va_is_mapped>
  8004d3:	84 c0                	test   %al,%al
  8004d5:	0f 84 a5 00 00 00    	je     800580 <flush_block+0xf5>
  8004db:	89 34 24             	mov    %esi,(%esp)
  8004de:	e8 90 ff ff ff       	call   800473 <va_is_dirty>
  8004e3:	84 c0                	test   %al,%al
  8004e5:	0f 84 95 00 00 00    	je     800580 <flush_block+0xf5>
        return;
    }

    // Flush probably means replace
    r = ide_write(blockno*BLKSECTS, addr, BLKSECTS);
  8004eb:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004f2:	00 
  8004f3:	89 74 24 04          	mov    %esi,0x4(%esp)
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8004f7:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  8004fd:	c1 eb 0c             	shr    $0xc,%ebx
    r = ide_write(blockno*BLKSECTS, addr, BLKSECTS);
  800500:	c1 e3 03             	shl    $0x3,%ebx
  800503:	89 1c 24             	mov    %ebx,(%esp)
  800506:	e8 ac fc ff ff       	call   8001b7 <ide_write>

    if(r < 0){
  80050b:	85 c0                	test   %eax,%eax
  80050d:	79 1c                	jns    80052b <flush_block+0xa0>
        panic("flush block: ide_write failed");
  80050f:	c7 44 24 08 94 3e 80 	movl   $0x803e94,0x8(%esp)
  800516:	00 
  800517:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  80051e:	00 
  80051f:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  800526:	e8 1d 18 00 00       	call   801d48 <_panic>
    }
    // Copy pasted from above.
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80052b:	89 f0                	mov    %esi,%eax
  80052d:	c1 e8 0c             	shr    $0xc,%eax
  800530:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800537:	25 07 0e 00 00       	and    $0xe07,%eax
  80053c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800540:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800544:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80054b:	00 
  80054c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800550:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800557:	e8 7b 23 00 00       	call   8028d7 <sys_page_map>
  80055c:	85 c0                	test   %eax,%eax
  80055e:	79 20                	jns    800580 <flush_block+0xf5>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800560:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800564:	c7 44 24 08 f0 3d 80 	movl   $0x803df0,0x8(%esp)
  80056b:	00 
  80056c:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  800573:	00 
  800574:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  80057b:	e8 c8 17 00 00       	call   801d48 <_panic>

//	panic("flush_block not implemented");
}
  800580:	83 c4 20             	add    $0x20,%esp
  800583:	5b                   	pop    %ebx
  800584:	5e                   	pop    %esi
  800585:	5d                   	pop    %ebp
  800586:	c3                   	ret    

00800587 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  80058a:	53                   	push   %ebx
  80058b:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800591:	c7 04 24 7a 02 80 00 	movl   $0x80027a,(%esp)
  800598:	e8 4e 25 00 00       	call   802aeb <set_pgfault_handler>
	memmove(&backup, diskaddr(1), sizeof backup);
  80059d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a4:	e8 56 fe ff ff       	call   8003ff <diskaddr>
  8005a9:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8005b0:	00 
  8005b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	e8 41 20 00 00       	call   802604 <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  8005c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ca:	e8 30 fe ff ff       	call   8003ff <diskaddr>
  8005cf:	c7 44 24 04 b2 3e 80 	movl   $0x803eb2,0x4(%esp)
  8005d6:	00 
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	e8 88 1e 00 00       	call   802467 <strcpy>
	flush_block(diskaddr(1));
  8005df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005e6:	e8 14 fe ff ff       	call   8003ff <diskaddr>
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 98 fe ff ff       	call   80048b <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8005f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005fa:	e8 00 fe ff ff       	call   8003ff <diskaddr>
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	e8 3e fe ff ff       	call   800445 <va_is_mapped>
  800607:	84 c0                	test   %al,%al
  800609:	75 24                	jne    80062f <bc_init+0xa8>
  80060b:	c7 44 24 0c d4 3e 80 	movl   $0x803ed4,0xc(%esp)
  800612:	00 
  800613:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  80061a:	00 
  80061b:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  800622:	00 
  800623:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  80062a:	e8 19 17 00 00       	call   801d48 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80062f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800636:	e8 c4 fd ff ff       	call   8003ff <diskaddr>
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 30 fe ff ff       	call   800473 <va_is_dirty>
  800643:	84 c0                	test   %al,%al
  800645:	74 24                	je     80066b <bc_init+0xe4>
  800647:	c7 44 24 0c b9 3e 80 	movl   $0x803eb9,0xc(%esp)
  80064e:	00 
  80064f:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  800656:	00 
  800657:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  80065e:	00 
  80065f:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  800666:	e8 dd 16 00 00       	call   801d48 <_panic>
	sys_page_unmap(0, diskaddr(1));
  80066b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800672:	e8 88 fd ff ff       	call   8003ff <diskaddr>
  800677:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800682:	e8 a3 22 00 00       	call   80292a <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800687:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80068e:	e8 6c fd ff ff       	call   8003ff <diskaddr>
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	e8 aa fd ff ff       	call   800445 <va_is_mapped>
  80069b:	84 c0                	test   %al,%al
  80069d:	74 24                	je     8006c3 <bc_init+0x13c>
  80069f:	c7 44 24 0c d3 3e 80 	movl   $0x803ed3,0xc(%esp)
  8006a6:	00 
  8006a7:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  8006ae:	00 
  8006af:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8006b6:	00 
  8006b7:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  8006be:	e8 85 16 00 00       	call   801d48 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006ca:	e8 30 fd ff ff       	call   8003ff <diskaddr>
  8006cf:	c7 44 24 04 b2 3e 80 	movl   $0x803eb2,0x4(%esp)
  8006d6:	00 
  8006d7:	89 04 24             	mov    %eax,(%esp)
  8006da:	e8 3d 1e 00 00       	call   80251c <strcmp>
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 24                	je     800707 <bc_init+0x180>
  8006e3:	c7 44 24 0c 34 3e 80 	movl   $0x803e34,0xc(%esp)
  8006ea:	00 
  8006eb:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  8006f2:	00 
  8006f3:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  8006fa:	00 
  8006fb:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  800702:	e8 41 16 00 00       	call   801d48 <_panic>
	memmove(diskaddr(1), &backup, sizeof backup);
  800707:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80070e:	e8 ec fc ff ff       	call   8003ff <diskaddr>
  800713:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80071a:	00 
  80071b:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800721:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800725:	89 04 24             	mov    %eax,(%esp)
  800728:	e8 d7 1e 00 00       	call   802604 <memmove>
	flush_block(diskaddr(1));
  80072d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800734:	e8 c6 fc ff ff       	call   8003ff <diskaddr>
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	e8 4a fd ff ff       	call   80048b <flush_block>
	memmove(&backup, diskaddr(1), sizeof backup);
  800741:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800748:	e8 b2 fc ff ff       	call   8003ff <diskaddr>
  80074d:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800754:	00 
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	89 1c 24             	mov    %ebx,(%esp)
  80075c:	e8 a3 1e 00 00       	call   802604 <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  800761:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800768:	e8 92 fc ff ff       	call   8003ff <diskaddr>
  80076d:	c7 44 24 04 b2 3e 80 	movl   $0x803eb2,0x4(%esp)
  800774:	00 
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 ea 1c 00 00       	call   802467 <strcpy>
	flush_block(diskaddr(1) + 20);
  80077d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800784:	e8 76 fc ff ff       	call   8003ff <diskaddr>
  800789:	83 c0 14             	add    $0x14,%eax
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	e8 f7 fc ff ff       	call   80048b <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800794:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80079b:	e8 5f fc ff ff       	call   8003ff <diskaddr>
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	e8 9d fc ff ff       	call   800445 <va_is_mapped>
  8007a8:	84 c0                	test   %al,%al
  8007aa:	75 24                	jne    8007d0 <bc_init+0x249>
  8007ac:	c7 44 24 0c d4 3e 80 	movl   $0x803ed4,0xc(%esp)
  8007b3:	00 
  8007b4:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  8007bb:	00 
  8007bc:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
  8007c3:	00 
  8007c4:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  8007cb:	e8 78 15 00 00       	call   801d48 <_panic>
	sys_page_unmap(0, diskaddr(1));
  8007d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007d7:	e8 23 fc ff ff       	call   8003ff <diskaddr>
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007e7:	e8 3e 21 00 00       	call   80292a <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8007ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007f3:	e8 07 fc ff ff       	call   8003ff <diskaddr>
  8007f8:	89 04 24             	mov    %eax,(%esp)
  8007fb:	e8 45 fc ff ff       	call   800445 <va_is_mapped>
  800800:	84 c0                	test   %al,%al
  800802:	74 24                	je     800828 <bc_init+0x2a1>
  800804:	c7 44 24 0c d3 3e 80 	movl   $0x803ed3,0xc(%esp)
  80080b:	00 
  80080c:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  800813:	00 
  800814:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80081b:	00 
  80081c:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  800823:	e8 20 15 00 00       	call   801d48 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800828:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80082f:	e8 cb fb ff ff       	call   8003ff <diskaddr>
  800834:	c7 44 24 04 b2 3e 80 	movl   $0x803eb2,0x4(%esp)
  80083b:	00 
  80083c:	89 04 24             	mov    %eax,(%esp)
  80083f:	e8 d8 1c 00 00       	call   80251c <strcmp>
  800844:	85 c0                	test   %eax,%eax
  800846:	74 24                	je     80086c <bc_init+0x2e5>
  800848:	c7 44 24 0c 34 3e 80 	movl   $0x803e34,0xc(%esp)
  80084f:	00 
  800850:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  800857:	00 
  800858:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
  80085f:	00 
  800860:	c7 04 24 58 3e 80 00 	movl   $0x803e58,(%esp)
  800867:	e8 dc 14 00 00       	call   801d48 <_panic>
	memmove(diskaddr(1), &backup, sizeof backup);
  80086c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800873:	e8 87 fb ff ff       	call   8003ff <diskaddr>
  800878:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80087f:	00 
  800880:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800886:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088a:	89 04 24             	mov    %eax,(%esp)
  80088d:	e8 72 1d 00 00       	call   802604 <memmove>
	flush_block(diskaddr(1));
  800892:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800899:	e8 61 fb ff ff       	call   8003ff <diskaddr>
  80089e:	89 04 24             	mov    %eax,(%esp)
  8008a1:	e8 e5 fb ff ff       	call   80048b <flush_block>
	cprintf("block cache is good\n");
  8008a6:	c7 04 24 ee 3e 80 00 	movl   $0x803eee,(%esp)
  8008ad:	e8 8f 15 00 00       	call   801e41 <cprintf>
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  8008b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8008b9:	e8 41 fb ff ff       	call   8003ff <diskaddr>
  8008be:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8008c5:	00 
  8008c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008d0:	89 04 24             	mov    %eax,(%esp)
  8008d3:	e8 2c 1d 00 00       	call   802604 <memmove>
}
  8008d8:	81 c4 24 02 00 00    	add    $0x224,%esp
  8008de:	5b                   	pop    %ebx
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    
  8008e1:	66 90                	xchg   %ax,%ax
  8008e3:	66 90                	xchg   %ax,%ax
  8008e5:	66 90                	xchg   %ax,%ax
  8008e7:	66 90                	xchg   %ax,%ax
  8008e9:	66 90                	xchg   %ax,%ax
  8008eb:	66 90                	xchg   %ax,%ax
  8008ed:	66 90                	xchg   %ax,%ax
  8008ef:	90                   	nop

008008f0 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  8008f6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8008fb:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800901:	74 1c                	je     80091f <check_super+0x2f>
		panic("bad file system magic number");
  800903:	c7 44 24 08 03 3f 80 	movl   $0x803f03,0x8(%esp)
  80090a:	00 
  80090b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800912:	00 
  800913:	c7 04 24 20 3f 80 00 	movl   $0x803f20,(%esp)
  80091a:	e8 29 14 00 00       	call   801d48 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80091f:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800926:	76 1c                	jbe    800944 <check_super+0x54>
		panic("file system is too large");
  800928:	c7 44 24 08 28 3f 80 	movl   $0x803f28,0x8(%esp)
  80092f:	00 
  800930:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  800937:	00 
  800938:	c7 04 24 20 3f 80 00 	movl   $0x803f20,(%esp)
  80093f:	e8 04 14 00 00       	call   801d48 <_panic>

	cprintf("superblock is good\n");
  800944:	c7 04 24 41 3f 80 00 	movl   $0x803f41,(%esp)
  80094b:	e8 f1 14 00 00       	call   801e41 <cprintf>
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800958:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80095e:	85 d2                	test   %edx,%edx
  800960:	74 22                	je     800984 <block_is_free+0x32>
		return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
	if (super == 0 || blockno >= super->s_nblocks)
  800967:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80096a:	76 1d                	jbe    800989 <block_is_free+0x37>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80096c:	b8 01 00 00 00       	mov    $0x1,%eax
  800971:	d3 e0                	shl    %cl,%eax
  800973:	c1 e9 05             	shr    $0x5,%ecx
  800976:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80097c:	85 04 8a             	test   %eax,(%edx,%ecx,4)
		return 1;
  80097f:	0f 95 c0             	setne  %al
  800982:	eb 05                	jmp    800989 <block_is_free+0x37>
		return 0;
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	83 ec 14             	sub    $0x14,%esp
  800992:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800995:	85 c9                	test   %ecx,%ecx
  800997:	75 1c                	jne    8009b5 <free_block+0x2a>
		panic("attempt to free zero block");
  800999:	c7 44 24 08 55 3f 80 	movl   $0x803f55,0x8(%esp)
  8009a0:	00 
  8009a1:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8009a8:	00 
  8009a9:	c7 04 24 20 3f 80 00 	movl   $0x803f20,(%esp)
  8009b0:	e8 93 13 00 00       	call   801d48 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8009b5:	89 ca                	mov    %ecx,%edx
  8009b7:	c1 ea 05             	shr    $0x5,%edx
  8009ba:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8009bf:	bb 01 00 00 00       	mov    $0x1,%ebx
  8009c4:	d3 e3                	shl    %cl,%ebx
  8009c6:	09 1c 90             	or     %ebx,(%eax,%edx,4)
}
  8009c9:	83 c4 14             	add    $0x14,%esp
  8009cc:	5b                   	pop    %ebx
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	56                   	push   %esi
  8009d3:	53                   	push   %ebx
  8009d4:	83 ec 10             	sub    $0x10,%esp
    // There's a bitmap varaible in fs.h
    // I'm willing to bet we need to go through the super-block as mentioned above.
    // Look at the above function, we probably need to iterate through the whole mess and find free stuff
    int blockno;

    for (blockno = 0; blockno < super->s_nblocks; blockno++){
  8009d7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8009dc:	8b 70 04             	mov    0x4(%eax),%esi
  8009df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009e4:	eb 50                	jmp    800a36 <alloc_block+0x67>
        if(block_is_free(blockno)){
  8009e6:	89 1c 24             	mov    %ebx,(%esp)
  8009e9:	e8 64 ff ff ff       	call   800952 <block_is_free>
  8009ee:	84 c0                	test   %al,%al
  8009f0:	74 41                	je     800a33 <alloc_block+0x64>
	        bitmap[blockno/32] &= ~(1<<(blockno%32)); // Copy pasted from above, I had to ask for help regarding the
  8009f2:	8d 43 1f             	lea    0x1f(%ebx),%eax
  8009f5:	85 db                	test   %ebx,%ebx
  8009f7:	0f 49 c3             	cmovns %ebx,%eax
  8009fa:	c1 f8 05             	sar    $0x5,%eax
  8009fd:	c1 e0 02             	shl    $0x2,%eax
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	03 15 08 a0 80 00    	add    0x80a008,%edx
  800a08:	89 de                	mov    %ebx,%esi
  800a0a:	c1 fe 1f             	sar    $0x1f,%esi
  800a0d:	c1 ee 1b             	shr    $0x1b,%esi
  800a10:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
  800a13:	83 e1 1f             	and    $0x1f,%ecx
  800a16:	29 f1                	sub    %esi,%ecx
  800a18:	be fe ff ff ff       	mov    $0xfffffffe,%esi
  800a1d:	d3 c6                	rol    %cl,%esi
  800a1f:	21 32                	and    %esi,(%edx)
                                                      // &= ~ part, so I'm not 100% what it does or why we do it.
            flush_block(&bitmap[blockno/32]); // Reminder, "flush" means to kick things back to the disk. I think.
  800a21:	03 05 08 a0 80 00    	add    0x80a008,%eax
  800a27:	89 04 24             	mov    %eax,(%esp)
  800a2a:	e8 5c fa ff ff       	call   80048b <flush_block>
            return blockno;
  800a2f:	89 d8                	mov    %ebx,%eax
  800a31:	eb 0c                	jmp    800a3f <alloc_block+0x70>
    for (blockno = 0; blockno < super->s_nblocks; blockno++){
  800a33:	83 c3 01             	add    $0x1,%ebx
  800a36:	39 f3                	cmp    %esi,%ebx
  800a38:	75 ac                	jne    8009e6 <alloc_block+0x17>
        }
    }
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
  800a3a:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	83 ec 1c             	sub    $0x1c,%esp
  800a4f:	89 d3                	mov    %edx,%ebx
  800a51:	8b 55 08             	mov    0x8(%ebp),%edx
        * NDIRECT = 10, number of block pointers in a File descriptor
        * NINDIRECT = (BLKSIZE/4), numbe roif direct block pointers in an indirect block.
        * There's a "walk" function below, maybe we use that?
        */
        int r;
        if(filebno >= (NDIRECT+NINDIRECT)){
  800a54:	81 fb 09 04 00 00    	cmp    $0x409,%ebx
  800a5a:	0f 87 8e 00 00 00    	ja     800aee <file_block_walk+0xa8>
  800a60:	89 c6                	mov    %eax,%esi
  800a62:	89 cf                	mov    %ecx,%edi
            return -E_INVAL;
        }

        if(filebno < NDIRECT){ // Okay, so it has less than 10 block pointers.
  800a64:	83 fb 09             	cmp    $0x9,%ebx
  800a67:	77 13                	ja     800a7c <file_block_walk+0x36>
            // My assumption is that "Filebno" means File Block Number"
            // This is the first instruction we're given, so let's go ahead and do that.
            // I tihnk this means that we have space for another block (or something of the sort)
            *ppdiskbno = &f->f_direct[filebno];
  800a69:	8d 84 98 88 00 00 00 	lea    0x88(%eax,%ebx,4),%eax
  800a70:	89 01                	mov    %eax,(%ecx)
            return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	e9 85 00 00 00       	jmp    800b01 <file_block_walk+0xbb>
             *
             */

        }

       return 0;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
        if(f->f_indirect == 0){
  800a81:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  800a88:	75 77                	jne    800b01 <file_block_walk+0xbb>
            if(!alloc){
  800a8a:	84 d2                	test   %dl,%dl
  800a8c:	74 67                	je     800af5 <file_block_walk+0xaf>
            r = alloc_block();
  800a8e:	e8 3c ff ff ff       	call   8009cf <alloc_block>
            if(r < 0){
  800a93:	85 c0                	test   %eax,%eax
  800a95:	78 65                	js     800afc <file_block_walk+0xb6>
            f->f_indirect = r;
  800a97:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
            memset(diskaddr(f->f_indirect), 0, BLKSIZE);
  800a9d:	89 04 24             	mov    %eax,(%esp)
  800aa0:	e8 5a f9 ff ff       	call   8003ff <diskaddr>
  800aa5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800aac:	00 
  800aad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ab4:	00 
  800ab5:	89 04 24             	mov    %eax,(%esp)
  800ab8:	e8 fa 1a 00 00       	call   8025b7 <memset>
            flush_block(diskaddr(f->f_indirect)); // Idk about this one.
  800abd:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 34 f9 ff ff       	call   8003ff <diskaddr>
  800acb:	89 04 24             	mov    %eax,(%esp)
  800ace:	e8 b8 f9 ff ff       	call   80048b <flush_block>
            *ppdiskbno = &((uint32_t*)diskaddr(f->f_indirect))[filebno-NDIRECT];
  800ad3:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800ad9:	89 04 24             	mov    %eax,(%esp)
  800adc:	e8 1e f9 ff ff       	call   8003ff <diskaddr>
  800ae1:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800ae5:	89 07                	mov    %eax,(%edi)
       return 0;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	eb 13                	jmp    800b01 <file_block_walk+0xbb>
            return -E_INVAL;
  800aee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800af3:	eb 0c                	jmp    800b01 <file_block_walk+0xbb>
                return -E_NOT_FOUND;
  800af5:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800afa:	eb 05                	jmp    800b01 <file_block_walk+0xbb>
                return -E_NO_DISK;
  800afc:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  800b01:	83 c4 1c             	add    $0x1c,%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <check_bitmap>:
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 10             	sub    $0x10,%esp
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800b11:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800b16:	8b 70 04             	mov    0x4(%eax),%esi
  800b19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b1e:	eb 36                	jmp    800b56 <check_bitmap+0x4d>
  800b20:	8d 43 02             	lea    0x2(%ebx),%eax
		assert(!block_is_free(2+i));
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 27 fe ff ff       	call   800952 <block_is_free>
  800b2b:	84 c0                	test   %al,%al
  800b2d:	74 24                	je     800b53 <check_bitmap+0x4a>
  800b2f:	c7 44 24 0c 70 3f 80 	movl   $0x803f70,0xc(%esp)
  800b36:	00 
  800b37:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  800b46:	00 
  800b47:	c7 04 24 20 3f 80 00 	movl   $0x803f20,(%esp)
  800b4e:	e8 f5 11 00 00       	call   801d48 <_panic>
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800b53:	83 c3 01             	add    $0x1,%ebx
  800b56:	89 d8                	mov    %ebx,%eax
  800b58:	c1 e0 0f             	shl    $0xf,%eax
  800b5b:	39 c6                	cmp    %eax,%esi
  800b5d:	77 c1                	ja     800b20 <check_bitmap+0x17>
	assert(!block_is_free(0));
  800b5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b66:	e8 e7 fd ff ff       	call   800952 <block_is_free>
  800b6b:	84 c0                	test   %al,%al
  800b6d:	74 24                	je     800b93 <check_bitmap+0x8a>
  800b6f:	c7 44 24 0c 84 3f 80 	movl   $0x803f84,0xc(%esp)
  800b76:	00 
  800b77:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  800b7e:	00 
  800b7f:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  800b86:	00 
  800b87:	c7 04 24 20 3f 80 00 	movl   $0x803f20,(%esp)
  800b8e:	e8 b5 11 00 00       	call   801d48 <_panic>
	assert(!block_is_free(1));
  800b93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b9a:	e8 b3 fd ff ff       	call   800952 <block_is_free>
  800b9f:	84 c0                	test   %al,%al
  800ba1:	74 24                	je     800bc7 <check_bitmap+0xbe>
  800ba3:	c7 44 24 0c 96 3f 80 	movl   $0x803f96,0xc(%esp)
  800baa:	00 
  800bab:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800bba:	00 
  800bbb:	c7 04 24 20 3f 80 00 	movl   $0x803f20,(%esp)
  800bc2:	e8 81 11 00 00       	call   801d48 <_panic>
	cprintf("bitmap is good\n");
  800bc7:	c7 04 24 a8 3f 80 00 	movl   $0x803fa8,(%esp)
  800bce:	e8 6e 12 00 00       	call   801e41 <cprintf>
}
  800bd3:	83 c4 10             	add    $0x10,%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <fs_init>:
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	83 ec 18             	sub    $0x18,%esp
	if (ide_probe_disk1())
  800be0:	e8 7a f4 ff ff       	call   80005f <ide_probe_disk1>
  800be5:	84 c0                	test   %al,%al
  800be7:	74 0e                	je     800bf7 <fs_init+0x1d>
		ide_set_disk(1);
  800be9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800bf0:	e8 ce f4 ff ff       	call   8000c3 <ide_set_disk>
  800bf5:	eb 0c                	jmp    800c03 <fs_init+0x29>
		ide_set_disk(0);
  800bf7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bfe:	e8 c0 f4 ff ff       	call   8000c3 <ide_set_disk>
	bc_init();
  800c03:	e8 7f f9 ff ff       	call   800587 <bc_init>
	super = diskaddr(1);
  800c08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c0f:	e8 eb f7 ff ff       	call   8003ff <diskaddr>
  800c14:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800c19:	e8 d2 fc ff ff       	call   8008f0 <check_super>
	bitmap = diskaddr(2);
  800c1e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800c25:	e8 d5 f7 ff ff       	call   8003ff <diskaddr>
  800c2a:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  800c2f:	e8 d5 fe ff ff       	call   800b09 <check_bitmap>
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 28             	sub    $0x28,%esp
       // LAB 5: Your code here.
       // We should probably think about this like we did some of the things that used pgdir.
       // Well, to use file_block_walk, we should probably make sure we have all the related parameters.
       uint32_t *ppdiskbno;
       int r;
       r = file_block_walk(f, filebno, &ppdiskbno, 1);
  800c3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c43:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800c46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	e8 f5 fd ff ff       	call   800a46 <file_block_walk>
       if(r < 0){
  800c51:	85 c0                	test   %eax,%eax
  800c53:	78 2d                	js     800c82 <file_get_block+0x4c>
            return r;
       }
       if(*ppdiskbno == 0){
  800c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c58:	83 38 00             	cmpl   $0x0,(%eax)
  800c5b:	75 0e                	jne    800c6b <file_get_block+0x35>
            r = alloc_block();
  800c5d:	e8 6d fd ff ff       	call   8009cf <alloc_block>
            if(r < 0){
  800c62:	85 c0                	test   %eax,%eax
  800c64:	78 1c                	js     800c82 <file_get_block+0x4c>
                return r;
            }
            *ppdiskbno = r;
  800c66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c69:	89 02                	mov    %eax,(%edx)
       }
       *blk = diskaddr(*ppdiskbno);
  800c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6e:	8b 00                	mov    (%eax),%eax
  800c70:	89 04 24             	mov    %eax,(%esp)
  800c73:	e8 87 f7 ff ff       	call   8003ff <diskaddr>
  800c78:	8b 55 10             	mov    0x10(%ebp),%edx
  800c7b:	89 02                	mov    %eax,(%edx)
       return 0;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax

}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800c90:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
  800c96:	89 8d 40 ff ff ff    	mov    %ecx,-0xc0(%ebp)
  800c9c:	eb 03                	jmp    800ca1 <walk_path+0x1d>
		p++;
  800c9e:	83 c0 01             	add    $0x1,%eax
	while (*p == '/')
  800ca1:	80 38 2f             	cmpb   $0x2f,(%eax)
  800ca4:	74 f8                	je     800c9e <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800ca6:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  800cac:	83 c1 08             	add    $0x8,%ecx
  800caf:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
	dir = 0;
	name[0] = 0;
  800cb5:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800cbc:	8b 8d 44 ff ff ff    	mov    -0xbc(%ebp),%ecx
  800cc2:	85 c9                	test   %ecx,%ecx
  800cc4:	74 06                	je     800ccc <walk_path+0x48>
		*pdir = 0;
  800cc6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800ccc:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800cd2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	dir = 0;
  800cd8:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800cdd:	e9 71 01 00 00       	jmp    800e53 <walk_path+0x1cf>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800ce2:	83 c7 01             	add    $0x1,%edi
		while (*path != '/' && *path != '\0')
  800ce5:	0f b6 17             	movzbl (%edi),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	74 05                	je     800cf1 <walk_path+0x6d>
  800cec:	80 fa 2f             	cmp    $0x2f,%dl
  800cef:	75 f1                	jne    800ce2 <walk_path+0x5e>
		if (path - p >= MAXNAMELEN)
  800cf1:	89 fb                	mov    %edi,%ebx
  800cf3:	29 c3                	sub    %eax,%ebx
  800cf5:	83 fb 7f             	cmp    $0x7f,%ebx
  800cf8:	0f 8f 82 01 00 00    	jg     800e80 <walk_path+0x1fc>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800cfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d06:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800d0c:	89 04 24             	mov    %eax,(%esp)
  800d0f:	e8 f0 18 00 00       	call   802604 <memmove>
		name[path - p] = '\0';
  800d14:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800d1b:	00 
  800d1c:	eb 03                	jmp    800d21 <walk_path+0x9d>
		p++;
  800d1e:	83 c7 01             	add    $0x1,%edi
	while (*p == '/')
  800d21:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800d24:	74 f8                	je     800d1e <walk_path+0x9a>
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800d26:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800d2c:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800d33:	0f 85 4e 01 00 00    	jne    800e87 <walk_path+0x203>
	assert((dir->f_size % BLKSIZE) == 0);
  800d39:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800d3f:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800d44:	74 24                	je     800d6a <walk_path+0xe6>
  800d46:	c7 44 24 0c b8 3f 80 	movl   $0x803fb8,0xc(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  800d55:	00 
  800d56:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  800d5d:	00 
  800d5e:	c7 04 24 20 3f 80 00 	movl   $0x803f20,(%esp)
  800d65:	e8 de 0f 00 00       	call   801d48 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800d6a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800d70:	85 c0                	test   %eax,%eax
  800d72:	0f 48 c2             	cmovs  %edx,%eax
  800d75:	c1 f8 0c             	sar    $0xc,%eax
  800d78:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	for (i = 0; i < nblock; i++) {
  800d7e:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800d85:	00 00 00 
  800d88:	89 bd 48 ff ff ff    	mov    %edi,-0xb8(%ebp)
  800d8e:	eb 61                	jmp    800df1 <walk_path+0x16d>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800d90:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800d96:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9a:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800da0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da4:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800daa:	89 04 24             	mov    %eax,(%esp)
  800dad:	e8 84 fe ff ff       	call   800c36 <file_get_block>
  800db2:	85 c0                	test   %eax,%eax
  800db4:	0f 88 ea 00 00 00    	js     800ea4 <walk_path+0x220>
  800dba:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
		f = (struct File*) blk;
  800dc0:	be 10 00 00 00       	mov    $0x10,%esi
			if (strcmp(f[j].f_name, name) == 0) {
  800dc5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcf:	89 1c 24             	mov    %ebx,(%esp)
  800dd2:	e8 45 17 00 00       	call   80251c <strcmp>
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	0f 84 af 00 00 00    	je     800e8e <walk_path+0x20a>
  800ddf:	81 c3 00 01 00 00    	add    $0x100,%ebx
		for (j = 0; j < BLKFILES; j++)
  800de5:	83 ee 01             	sub    $0x1,%esi
  800de8:	75 db                	jne    800dc5 <walk_path+0x141>
	for (i = 0; i < nblock; i++) {
  800dea:	83 85 54 ff ff ff 01 	addl   $0x1,-0xac(%ebp)
  800df1:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800df7:	39 85 4c ff ff ff    	cmp    %eax,-0xb4(%ebp)
  800dfd:	75 91                	jne    800d90 <walk_path+0x10c>
  800dff:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800e05:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
			if (r == -E_NOT_FOUND && *path == '\0') {
  800e0a:	80 3f 00             	cmpb   $0x0,(%edi)
  800e0d:	0f 85 a0 00 00 00    	jne    800eb3 <walk_path+0x22f>
				if (pdir)
  800e13:	8b 85 44 ff ff ff    	mov    -0xbc(%ebp),%eax
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	74 08                	je     800e25 <walk_path+0x1a1>
					*pdir = dir;
  800e1d:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800e23:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800e25:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e29:	74 15                	je     800e40 <walk_path+0x1bc>
					strcpy(lastelem, name);
  800e2b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	89 04 24             	mov    %eax,(%esp)
  800e3b:	e8 27 16 00 00       	call   802467 <strcpy>
				*pf = 0;
  800e40:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800e46:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return r;
  800e4c:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800e51:	eb 60                	jmp    800eb3 <walk_path+0x22f>
	while (*path != '\0') {
  800e53:	80 38 00             	cmpb   $0x0,(%eax)
  800e56:	74 07                	je     800e5f <walk_path+0x1db>
  800e58:	89 c7                	mov    %eax,%edi
  800e5a:	e9 86 fe ff ff       	jmp    800ce5 <walk_path+0x61>
		}
	}

	if (pdir)
  800e5f:	8b 85 44 ff ff ff    	mov    -0xbc(%ebp),%eax
  800e65:	85 c0                	test   %eax,%eax
  800e67:	74 02                	je     800e6b <walk_path+0x1e7>
		*pdir = dir;
  800e69:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800e6b:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800e71:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800e77:	89 08                	mov    %ecx,(%eax)
	return 0;
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7e:	eb 33                	jmp    800eb3 <walk_path+0x22f>
			return -E_BAD_PATH;
  800e80:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800e85:	eb 2c                	jmp    800eb3 <walk_path+0x22f>
			return -E_NOT_FOUND;
  800e87:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800e8c:	eb 25                	jmp    800eb3 <walk_path+0x22f>
  800e8e:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi
  800e94:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
			if (strcmp(f[j].f_name, name) == 0) {
  800e9a:	89 9d 50 ff ff ff    	mov    %ebx,-0xb0(%ebp)
  800ea0:	89 f8                	mov    %edi,%eax
  800ea2:	eb af                	jmp    800e53 <walk_path+0x1cf>
  800ea4:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi
			if (r == -E_NOT_FOUND && *path == '\0') {
  800eaa:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ead:	0f 84 52 ff ff ff    	je     800e05 <walk_path+0x181>
}
  800eb3:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800ec4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ecb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ece:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	e8 a9 fd ff ff       	call   800c84 <walk_path>
}
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 3c             	sub    $0x3c,%esp
  800ee6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ee9:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
		return 0;
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (offset >= f->f_size)
  800efa:	39 d1                	cmp    %edx,%ecx
  800efc:	0f 8e 83 00 00 00    	jle    800f85 <file_read+0xa8>

	count = MIN(count, f->f_size - offset);
  800f02:	29 d1                	sub    %edx,%ecx
  800f04:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800f07:	0f 47 4d 10          	cmova  0x10(%ebp),%ecx
  800f0b:	89 4d d0             	mov    %ecx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800f0e:	89 d3                	mov    %edx,%ebx
  800f10:	01 ca                	add    %ecx,%edx
  800f12:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800f15:	eb 64                	jmp    800f7b <file_read+0x9e>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f17:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1e:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800f24:	85 db                	test   %ebx,%ebx
  800f26:	0f 49 c3             	cmovns %ebx,%eax
  800f29:	c1 f8 0c             	sar    $0xc,%eax
  800f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	e8 fb fc ff ff       	call   800c36 <file_get_block>
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 46                	js     800f85 <file_read+0xa8>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f3f:	89 da                	mov    %ebx,%edx
  800f41:	c1 fa 1f             	sar    $0x1f,%edx
  800f44:	c1 ea 14             	shr    $0x14,%edx
  800f47:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800f4a:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f4f:	29 d0                	sub    %edx,%eax
  800f51:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f56:	29 c1                	sub    %eax,%ecx
  800f58:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f5b:	29 f2                	sub    %esi,%edx
  800f5d:	39 d1                	cmp    %edx,%ecx
  800f5f:	89 d6                	mov    %edx,%esi
  800f61:	0f 46 f1             	cmovbe %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800f64:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f68:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6f:	89 3c 24             	mov    %edi,(%esp)
  800f72:	e8 8d 16 00 00       	call   802604 <memmove>
		pos += bn;
  800f77:	01 f3                	add    %esi,%ebx
		buf += bn;
  800f79:	01 f7                	add    %esi,%edi
	for (pos = offset; pos < offset + count; ) {
  800f7b:	89 de                	mov    %ebx,%esi
  800f7d:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800f80:	72 95                	jb     800f17 <file_read+0x3a>
	}

	return count;
  800f82:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800f85:	83 c4 3c             	add    $0x3c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	57                   	push   %edi
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
  800f93:	83 ec 2c             	sub    $0x2c,%esp
  800f96:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800f99:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f9f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800fa2:	0f 8e 9a 00 00 00    	jle    801042 <file_set_size+0xb5>
	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800fa8:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800fae:	05 ff 0f 00 00       	add    $0xfff,%eax
  800fb3:	0f 49 f8             	cmovns %eax,%edi
  800fb6:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbc:	8d 90 fe 1f 00 00    	lea    0x1ffe(%eax),%edx
  800fc2:	05 ff 0f 00 00       	add    $0xfff,%eax
  800fc7:	0f 48 c2             	cmovs  %edx,%eax
  800fca:	c1 f8 0c             	sar    $0xc,%eax
  800fcd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800fd0:	89 c3                	mov    %eax,%ebx
  800fd2:	eb 34                	jmp    801008 <file_set_size+0x7b>
	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800fd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fdb:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800fde:	89 da                	mov    %ebx,%edx
  800fe0:	89 f0                	mov    %esi,%eax
  800fe2:	e8 5f fa ff ff       	call   800a46 <file_block_walk>
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 45                	js     801030 <file_set_size+0xa3>
	if (*ptr) {
  800feb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fee:	8b 00                	mov    (%eax),%eax
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	74 11                	je     801005 <file_set_size+0x78>
		free_block(*ptr);
  800ff4:	89 04 24             	mov    %eax,(%esp)
  800ff7:	e8 8f f9 ff ff       	call   80098b <free_block>
		*ptr = 0;
  800ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  801005:	83 c3 01             	add    $0x1,%ebx
  801008:	39 df                	cmp    %ebx,%edi
  80100a:	77 c8                	ja     800fd4 <file_set_size+0x47>
	if (new_nblocks <= NDIRECT && f->f_indirect) {
  80100c:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  801010:	77 30                	ja     801042 <file_set_size+0xb5>
  801012:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801018:	85 c0                	test   %eax,%eax
  80101a:	74 26                	je     801042 <file_set_size+0xb5>
		free_block(f->f_indirect);
  80101c:	89 04 24             	mov    %eax,(%esp)
  80101f:	e8 67 f9 ff ff       	call   80098b <free_block>
		f->f_indirect = 0;
  801024:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  80102b:	00 00 00 
  80102e:	eb 12                	jmp    801042 <file_set_size+0xb5>
			cprintf("warning: file_free_block: %e", r);
  801030:	89 44 24 04          	mov    %eax,0x4(%esp)
  801034:	c7 04 24 d5 3f 80 00 	movl   $0x803fd5,(%esp)
  80103b:	e8 01 0e 00 00       	call   801e41 <cprintf>
  801040:	eb c3                	jmp    801005 <file_set_size+0x78>
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  801042:	8b 45 0c             	mov    0xc(%ebp),%eax
  801045:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  80104b:	89 34 24             	mov    %esi,(%esp)
  80104e:	e8 38 f4 ff ff       	call   80048b <flush_block>
	return 0;
}
  801053:	b8 00 00 00 00       	mov    $0x0,%eax
  801058:	83 c4 2c             	add    $0x2c,%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <file_write>:
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	83 ec 2c             	sub    $0x2c,%esp
  801069:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80106c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	if (offset + count > f->f_size)
  80106f:	89 d8                	mov    %ebx,%eax
  801071:	03 45 10             	add    0x10(%ebp),%eax
  801074:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801077:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107a:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  801080:	76 7c                	jbe    8010fe <file_write+0x9e>
		if ((r = file_set_size(f, offset + count)) < 0)
  801082:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801085:	89 44 24 04          	mov    %eax,0x4(%esp)
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	89 04 24             	mov    %eax,(%esp)
  80108f:	e8 f9 fe ff ff       	call   800f8d <file_set_size>
  801094:	85 c0                	test   %eax,%eax
  801096:	79 66                	jns    8010fe <file_write+0x9e>
  801098:	eb 6e                	jmp    801108 <file_write+0xa8>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  80109a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80109d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a1:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8010a7:	85 db                	test   %ebx,%ebx
  8010a9:	0f 49 c3             	cmovns %ebx,%eax
  8010ac:	c1 f8 0c             	sar    $0xc,%eax
  8010af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b6:	89 04 24             	mov    %eax,(%esp)
  8010b9:	e8 78 fb ff ff       	call   800c36 <file_get_block>
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	78 46                	js     801108 <file_write+0xa8>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  8010c2:	89 da                	mov    %ebx,%edx
  8010c4:	c1 fa 1f             	sar    $0x1f,%edx
  8010c7:	c1 ea 14             	shr    $0x14,%edx
  8010ca:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  8010cd:	25 ff 0f 00 00       	and    $0xfff,%eax
  8010d2:	29 d0                	sub    %edx,%eax
  8010d4:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8010d9:	29 c1                	sub    %eax,%ecx
  8010db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8010de:	29 f2                	sub    %esi,%edx
  8010e0:	39 d1                	cmp    %edx,%ecx
  8010e2:	89 d6                	mov    %edx,%esi
  8010e4:	0f 46 f1             	cmovbe %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  8010e7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ef:	03 45 e4             	add    -0x1c(%ebp),%eax
  8010f2:	89 04 24             	mov    %eax,(%esp)
  8010f5:	e8 0a 15 00 00       	call   802604 <memmove>
		pos += bn;
  8010fa:	01 f3                	add    %esi,%ebx
		buf += bn;
  8010fc:	01 f7                	add    %esi,%edi
	for (pos = offset; pos < offset + count; ) {
  8010fe:	89 de                	mov    %ebx,%esi
  801100:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  801103:	77 95                	ja     80109a <file_write+0x3a>
	return count;
  801105:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801108:	83 c4 2c             	add    $0x2c,%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
  801115:	83 ec 20             	sub    $0x20,%esp
  801118:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80111b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801120:	eb 37                	jmp    801159 <file_flush+0x49>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801122:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801129:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  80112c:	89 da                	mov    %ebx,%edx
  80112e:	89 f0                	mov    %esi,%eax
  801130:	e8 11 f9 ff ff       	call   800a46 <file_block_walk>
  801135:	85 c0                	test   %eax,%eax
  801137:	78 1d                	js     801156 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  801139:	8b 45 f4             	mov    -0xc(%ebp),%eax
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80113c:	85 c0                	test   %eax,%eax
  80113e:	74 16                	je     801156 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  801140:	8b 00                	mov    (%eax),%eax
  801142:	85 c0                	test   %eax,%eax
  801144:	74 10                	je     801156 <file_flush+0x46>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801146:	89 04 24             	mov    %eax,(%esp)
  801149:	e8 b1 f2 ff ff       	call   8003ff <diskaddr>
  80114e:	89 04 24             	mov    %eax,(%esp)
  801151:	e8 35 f3 ff ff       	call   80048b <flush_block>
	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801156:	83 c3 01             	add    $0x1,%ebx
  801159:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  80115f:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  801165:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80116b:	85 c9                	test   %ecx,%ecx
  80116d:	0f 49 c1             	cmovns %ecx,%eax
  801170:	c1 f8 0c             	sar    $0xc,%eax
  801173:	39 c3                	cmp    %eax,%ebx
  801175:	7c ab                	jl     801122 <file_flush+0x12>
	}
	flush_block(f);
  801177:	89 34 24             	mov    %esi,(%esp)
  80117a:	e8 0c f3 ff ff       	call   80048b <flush_block>
	if (f->f_indirect)
  80117f:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801185:	85 c0                	test   %eax,%eax
  801187:	74 10                	je     801199 <file_flush+0x89>
		flush_block(diskaddr(f->f_indirect));
  801189:	89 04 24             	mov    %eax,(%esp)
  80118c:	e8 6e f2 ff ff       	call   8003ff <diskaddr>
  801191:	89 04 24             	mov    %eax,(%esp)
  801194:	e8 f2 f2 ff ff       	call   80048b <flush_block>
}
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <file_create>:
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	57                   	push   %edi
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	if ((r = walk_path(path, &dir, &f, name)) == 0)
  8011ac:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8011b2:	89 04 24             	mov    %eax,(%esp)
  8011b5:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  8011bb:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c4:	e8 bb fa ff ff       	call   800c84 <walk_path>
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	0f 84 e0 00 00 00    	je     8012b3 <file_create+0x113>
	if (r != -E_NOT_FOUND || dir == 0)
  8011d3:	83 fa f5             	cmp    $0xfffffff5,%edx
  8011d6:	0f 85 1b 01 00 00    	jne    8012f7 <file_create+0x157>
  8011dc:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  8011e2:	85 f6                	test   %esi,%esi
  8011e4:	0f 84 d0 00 00 00    	je     8012ba <file_create+0x11a>
	assert((dir->f_size % BLKSIZE) == 0);
  8011ea:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  8011f0:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8011f5:	74 24                	je     80121b <file_create+0x7b>
  8011f7:	c7 44 24 0c b8 3f 80 	movl   $0x803fb8,0xc(%esp)
  8011fe:	00 
  8011ff:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801206:	00 
  801207:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  80120e:	00 
  80120f:	c7 04 24 20 3f 80 00 	movl   $0x803f20,(%esp)
  801216:	e8 2d 0b 00 00       	call   801d48 <_panic>
	nblock = dir->f_size / BLKSIZE;
  80121b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801221:	85 c0                	test   %eax,%eax
  801223:	0f 48 c2             	cmovs  %edx,%eax
  801226:	c1 f8 0c             	sar    $0xc,%eax
  801229:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  80122f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801234:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  80123a:	eb 3d                	jmp    801279 <file_create+0xd9>
  80123c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801240:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801244:	89 34 24             	mov    %esi,(%esp)
  801247:	e8 ea f9 ff ff       	call   800c36 <file_get_block>
  80124c:	85 c0                	test   %eax,%eax
  80124e:	0f 88 a3 00 00 00    	js     8012f7 <file_create+0x157>
  801254:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
		f = (struct File*) blk;
  80125a:	ba 10 00 00 00       	mov    $0x10,%edx
			if (f[j].f_name[0] == '\0') {
  80125f:	80 38 00             	cmpb   $0x0,(%eax)
  801262:	75 08                	jne    80126c <file_create+0xcc>
				*file = &f[j];
  801264:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80126a:	eb 55                	jmp    8012c1 <file_create+0x121>
  80126c:	05 00 01 00 00       	add    $0x100,%eax
		for (j = 0; j < BLKFILES; j++)
  801271:	83 ea 01             	sub    $0x1,%edx
  801274:	75 e9                	jne    80125f <file_create+0xbf>
	for (i = 0; i < nblock; i++) {
  801276:	83 c3 01             	add    $0x1,%ebx
  801279:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  80127f:	75 bb                	jne    80123c <file_create+0x9c>
	dir->f_size += BLKSIZE;
  801281:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  801288:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  80128b:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801291:	89 44 24 08          	mov    %eax,0x8(%esp)
  801295:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801299:	89 34 24             	mov    %esi,(%esp)
  80129c:	e8 95 f9 ff ff       	call   800c36 <file_get_block>
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 52                	js     8012f7 <file_create+0x157>
	*file = &f[0];
  8012a5:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8012ab:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8012b1:	eb 0e                	jmp    8012c1 <file_create+0x121>
		return -E_FILE_EXISTS;
  8012b3:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8012b8:	eb 3d                	jmp    8012f7 <file_create+0x157>
		return r;
  8012ba:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8012bf:	eb 36                	jmp    8012f7 <file_create+0x157>
	strcpy(f->f_name, name);
  8012c1:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8012c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cb:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8012d1:	89 04 24             	mov    %eax,(%esp)
  8012d4:	e8 8e 11 00 00       	call   802467 <strcpy>
	*pf = f;
  8012d9:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8012df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e2:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8012e4:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8012ea:	89 04 24             	mov    %eax,(%esp)
  8012ed:	e8 1e fe ff ff       	call   801110 <file_flush>
	return 0;
  8012f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f7:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801309:	bb 01 00 00 00       	mov    $0x1,%ebx
  80130e:	eb 13                	jmp    801323 <fs_sync+0x21>
		flush_block(diskaddr(i));
  801310:	89 1c 24             	mov    %ebx,(%esp)
  801313:	e8 e7 f0 ff ff       	call   8003ff <diskaddr>
  801318:	89 04 24             	mov    %eax,(%esp)
  80131b:	e8 6b f1 ff ff       	call   80048b <flush_block>
	for (i = 1; i < super->s_nblocks; i++)
  801320:	83 c3 01             	add    $0x1,%ebx
  801323:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  801328:	3b 58 04             	cmp    0x4(%eax),%ebx
  80132b:	72 e3                	jb     801310 <fs_sync+0xe>
}
  80132d:	83 c4 14             	add    $0x14,%esp
  801330:	5b                   	pop    %ebx
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
  801333:	66 90                	xchg   %ax,%ax
  801335:	66 90                	xchg   %ax,%ax
  801337:	66 90                	xchg   %ax,%ax
  801339:	66 90                	xchg   %ax,%ax
  80133b:	66 90                	xchg   %ax,%ax
  80133d:	66 90                	xchg   %ax,%ax
  80133f:	90                   	nop

00801340 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  801350:	c7 44 24 08 f2 3f 80 	movl   $0x803ff2,0x8(%esp)
  801357:	00 
  801358:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  80135f:	00 
  801360:	c7 04 24 0e 40 80 00 	movl   $0x80400e,(%esp)
  801367:	e8 dc 09 00 00       	call   801d48 <_panic>

0080136c <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801372:	e8 8b ff ff ff       	call   801302 <fs_sync>
	return 0;
}
  801377:	b8 00 00 00 00       	mov    $0x0,%eax
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <serve_init>:
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	ba 60 50 80 00       	mov    $0x805060,%edx
	uintptr_t va = FILEVA;
  801386:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  80138b:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801390:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801392:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801395:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  80139b:	83 c0 01             	add    $0x1,%eax
  80139e:	83 c2 10             	add    $0x10,%edx
  8013a1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013a6:	75 e8                	jne    801390 <serve_init+0x12>
}
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <openfile_alloc>:
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	56                   	push   %esi
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 10             	sub    $0x10,%esp
  8013b2:	8b 75 08             	mov    0x8(%ebp),%esi
	for (i = 0; i < MAXOPEN; i++) {
  8013b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ba:	89 d8                	mov    %ebx,%eax
  8013bc:	c1 e0 04             	shl    $0x4,%eax
		switch (pageref(opentab[i].o_fd)) {
  8013bf:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  8013c5:	89 04 24             	mov    %eax,(%esp)
  8013c8:	e8 2f 21 00 00       	call   8034fc <pageref>
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 07                	je     8013d8 <openfile_alloc+0x2e>
  8013d1:	83 f8 01             	cmp    $0x1,%eax
  8013d4:	74 2b                	je     801401 <openfile_alloc+0x57>
  8013d6:	eb 62                	jmp    80143a <openfile_alloc+0x90>
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8013d8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013df:	00 
  8013e0:	89 d8                	mov    %ebx,%eax
  8013e2:	c1 e0 04             	shl    $0x4,%eax
  8013e5:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f6:	e8 88 14 00 00       	call   802883 <sys_page_alloc>
  8013fb:	89 c2                	mov    %eax,%edx
  8013fd:	85 d2                	test   %edx,%edx
  8013ff:	78 4d                	js     80144e <openfile_alloc+0xa4>
			opentab[i].o_fileid += MAXOPEN;
  801401:	c1 e3 04             	shl    $0x4,%ebx
  801404:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  80140a:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801411:	04 00 00 
			*o = &opentab[i];
  801414:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801416:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80141d:	00 
  80141e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801425:	00 
  801426:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  80142c:	89 04 24             	mov    %eax,(%esp)
  80142f:	e8 83 11 00 00       	call   8025b7 <memset>
			return (*o)->o_fileid;
  801434:	8b 06                	mov    (%esi),%eax
  801436:	8b 00                	mov    (%eax),%eax
  801438:	eb 14                	jmp    80144e <openfile_alloc+0xa4>
	for (i = 0; i < MAXOPEN; i++) {
  80143a:	83 c3 01             	add    $0x1,%ebx
  80143d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801443:	0f 85 71 ff ff ff    	jne    8013ba <openfile_alloc+0x10>
	return -E_MAX_OPEN;
  801449:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <openfile_lookup>:
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	57                   	push   %edi
  801459:	56                   	push   %esi
  80145a:	53                   	push   %ebx
  80145b:	83 ec 1c             	sub    $0x1c,%esp
  80145e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	o = &opentab[fileid % MAXOPEN];
  801461:	89 de                	mov    %ebx,%esi
  801463:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801469:	c1 e6 04             	shl    $0x4,%esi
  80146c:	8d be 60 50 80 00    	lea    0x805060(%esi),%edi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801472:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  801478:	89 04 24             	mov    %eax,(%esp)
  80147b:	e8 7c 20 00 00       	call   8034fc <pageref>
  801480:	83 f8 01             	cmp    $0x1,%eax
  801483:	7e 14                	jle    801499 <openfile_lookup+0x44>
  801485:	39 9e 60 50 80 00    	cmp    %ebx,0x805060(%esi)
  80148b:	75 13                	jne    8014a0 <openfile_lookup+0x4b>
	*po = o;
  80148d:	8b 45 10             	mov    0x10(%ebp),%eax
  801490:	89 38                	mov    %edi,(%eax)
	return 0;
  801492:	b8 00 00 00 00       	mov    $0x0,%eax
  801497:	eb 0c                	jmp    8014a5 <openfile_lookup+0x50>
		return -E_INVAL;
  801499:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149e:	eb 05                	jmp    8014a5 <openfile_lookup+0x50>
  8014a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014a5:	83 c4 1c             	add    $0x1c,%esp
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5f                   	pop    %edi
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <serve_set_size>:
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 24             	sub    $0x24,%esp
  8014b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014be:	8b 03                	mov    (%ebx),%eax
  8014c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	89 04 24             	mov    %eax,(%esp)
  8014ca:	e8 86 ff ff ff       	call   801455 <openfile_lookup>
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	85 d2                	test   %edx,%edx
  8014d3:	78 15                	js     8014ea <serve_set_size+0x3d>
	return file_set_size(o->o_file, req->req_size);
  8014d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8014d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014df:	8b 40 04             	mov    0x4(%eax),%eax
  8014e2:	89 04 24             	mov    %eax,(%esp)
  8014e5:	e8 a3 fa ff ff       	call   800f8d <file_set_size>
}
  8014ea:	83 c4 24             	add    $0x24,%esp
  8014ed:	5b                   	pop    %ebx
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <serve_stat>:
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 24             	sub    $0x24,%esp
  8014f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801501:	8b 03                	mov    (%ebx),%eax
  801503:	89 44 24 04          	mov    %eax,0x4(%esp)
  801507:	8b 45 08             	mov    0x8(%ebp),%eax
  80150a:	89 04 24             	mov    %eax,(%esp)
  80150d:	e8 43 ff ff ff       	call   801455 <openfile_lookup>
  801512:	89 c2                	mov    %eax,%edx
  801514:	85 d2                	test   %edx,%edx
  801516:	78 3f                	js     801557 <serve_stat+0x67>
	strcpy(ret->ret_name, o->o_file->f_name);
  801518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151b:	8b 40 04             	mov    0x4(%eax),%eax
  80151e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801522:	89 1c 24             	mov    %ebx,(%esp)
  801525:	e8 3d 0f 00 00       	call   802467 <strcpy>
	ret->ret_size = o->o_file->f_size;
  80152a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152d:	8b 50 04             	mov    0x4(%eax),%edx
  801530:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801536:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80153c:	8b 40 04             	mov    0x4(%eax),%eax
  80153f:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801546:	0f 94 c0             	sete   %al
  801549:	0f b6 c0             	movzbl %al,%eax
  80154c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801552:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801557:	83 c4 24             	add    $0x24,%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <serve_flush>:
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 28             	sub    $0x28,%esp
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801563:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801566:	89 44 24 08          	mov    %eax,0x8(%esp)
  80156a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156d:	8b 00                	mov    (%eax),%eax
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	8b 45 08             	mov    0x8(%ebp),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 d7 fe ff ff       	call   801455 <openfile_lookup>
  80157e:	89 c2                	mov    %eax,%edx
  801580:	85 d2                	test   %edx,%edx
  801582:	78 13                	js     801597 <serve_flush+0x3a>
	file_flush(o->o_file);
  801584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801587:	8b 40 04             	mov    0x4(%eax),%eax
  80158a:	89 04 24             	mov    %eax,(%esp)
  80158d:	e8 7e fb ff ff       	call   801110 <file_flush>
	return 0;
  801592:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801597:	c9                   	leave  
  801598:	c3                   	ret    

00801599 <serve_open>:
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	53                   	push   %ebx
  80159d:	81 ec 24 04 00 00    	sub    $0x424,%esp
  8015a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	memmove(path, req->req_path, MAXPATHLEN);
  8015a6:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  8015ad:	00 
  8015ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b2:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015b8:	89 04 24             	mov    %eax,(%esp)
  8015bb:	e8 44 10 00 00       	call   802604 <memmove>
	path[MAXPATHLEN-1] = 0;
  8015c0:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
	if ((r = openfile_alloc(&o)) < 0) {
  8015c4:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8015ca:	89 04 24             	mov    %eax,(%esp)
  8015cd:	e8 d8 fd ff ff       	call   8013aa <openfile_alloc>
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	0f 88 f2 00 00 00    	js     8016cc <serve_open+0x133>
	if (req->req_omode & O_CREAT) {
  8015da:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8015e1:	74 34                	je     801617 <serve_open+0x7e>
		if ((r = file_create(path, &f)) < 0) {
  8015e3:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ed:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015f3:	89 04 24             	mov    %eax,(%esp)
  8015f6:	e8 a5 fb ff ff       	call   8011a0 <file_create>
  8015fb:	89 c2                	mov    %eax,%edx
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	79 36                	jns    801637 <serve_open+0x9e>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801601:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801608:	0f 85 be 00 00 00    	jne    8016cc <serve_open+0x133>
  80160e:	83 fa f3             	cmp    $0xfffffff3,%edx
  801611:	0f 85 b5 00 00 00    	jne    8016cc <serve_open+0x133>
		if ((r = file_open(path, &f)) < 0) {
  801617:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80161d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801621:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801627:	89 04 24             	mov    %eax,(%esp)
  80162a:	e8 8f f8 ff ff       	call   800ebe <file_open>
  80162f:	85 c0                	test   %eax,%eax
  801631:	0f 88 95 00 00 00    	js     8016cc <serve_open+0x133>
	if (req->req_omode & O_TRUNC) {
  801637:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  80163e:	74 1a                	je     80165a <serve_open+0xc1>
		if ((r = file_set_size(f, 0)) < 0) {
  801640:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801647:	00 
  801648:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  80164e:	89 04 24             	mov    %eax,(%esp)
  801651:	e8 37 f9 ff ff       	call   800f8d <file_set_size>
  801656:	85 c0                	test   %eax,%eax
  801658:	78 72                	js     8016cc <serve_open+0x133>
	if ((r = file_open(path, &f)) < 0) {
  80165a:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801660:	89 44 24 04          	mov    %eax,0x4(%esp)
  801664:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80166a:	89 04 24             	mov    %eax,(%esp)
  80166d:	e8 4c f8 ff ff       	call   800ebe <file_open>
  801672:	85 c0                	test   %eax,%eax
  801674:	78 56                	js     8016cc <serve_open+0x133>
	o->o_file = f;
  801676:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80167c:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801682:	89 50 04             	mov    %edx,0x4(%eax)
	o->o_fd->fd_file.id = o->o_fileid;
  801685:	8b 50 0c             	mov    0xc(%eax),%edx
  801688:	8b 08                	mov    (%eax),%ecx
  80168a:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  80168d:	8b 50 0c             	mov    0xc(%eax),%edx
  801690:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  801696:	83 e1 03             	and    $0x3,%ecx
  801699:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80169c:	8b 40 0c             	mov    0xc(%eax),%eax
  80169f:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8016a5:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8016a7:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016ad:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8016b3:	89 50 08             	mov    %edx,0x8(%eax)
	*pg_store = o->o_fd;
  8016b6:	8b 50 0c             	mov    0xc(%eax),%edx
  8016b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016bc:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8016be:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c1:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
	return 0;
  8016c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016cc:	81 c4 24 04 00 00    	add    $0x424,%esp
  8016d2:	5b                   	pop    %ebx
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    

008016d5 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8016dd:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8016e0:	8d 75 f4             	lea    -0xc(%ebp),%esi
		perm = 0;
  8016e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8016ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016ee:	a1 44 50 80 00       	mov    0x805044,%eax
  8016f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f7:	89 34 24             	mov    %esi,(%esp)
  8016fa:	e8 a1 14 00 00       	call   802ba0 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  8016ff:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801703:	75 15                	jne    80171a <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  801705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170c:	c7 04 24 3c 40 80 00 	movl   $0x80403c,(%esp)
  801713:	e8 29 07 00 00       	call   801e41 <cprintf>
				whom);
			continue; // just leave it hanging...
  801718:	eb c9                	jmp    8016e3 <serve+0xe>
		}

		pg = NULL;
  80171a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801721:	83 f8 01             	cmp    $0x1,%eax
  801724:	75 21                	jne    801747 <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801726:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80172a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80172d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801731:	a1 44 50 80 00       	mov    0x805044,%eax
  801736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173d:	89 04 24             	mov    %eax,(%esp)
  801740:	e8 54 fe ff ff       	call   801599 <serve_open>
  801745:	eb 3f                	jmp    801786 <serve+0xb1>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  801747:	83 f8 08             	cmp    $0x8,%eax
  80174a:	77 1e                	ja     80176a <serve+0x95>
  80174c:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801753:	85 d2                	test   %edx,%edx
  801755:	74 13                	je     80176a <serve+0x95>
			r = handlers[req](whom, fsreq);
  801757:	a1 44 50 80 00       	mov    0x805044,%eax
  80175c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801760:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801763:	89 04 24             	mov    %eax,(%esp)
  801766:	ff d2                	call   *%edx
  801768:	eb 1c                	jmp    801786 <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  80176a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801771:	89 44 24 04          	mov    %eax,0x4(%esp)
  801775:	c7 04 24 6c 40 80 00 	movl   $0x80406c,(%esp)
  80177c:	e8 c0 06 00 00       	call   801e41 <cprintf>
			r = -E_INVAL;
  801781:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801786:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801789:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80178d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801790:	89 54 24 08          	mov    %edx,0x8(%esp)
  801794:	89 44 24 04          	mov    %eax,0x4(%esp)
  801798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179b:	89 04 24             	mov    %eax,(%esp)
  80179e:	e8 65 14 00 00       	call   802c08 <ipc_send>
		sys_page_unmap(0, fsreq);
  8017a3:	a1 44 50 80 00       	mov    0x805044,%eax
  8017a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b3:	e8 72 11 00 00       	call   80292a <sys_page_unmap>
  8017b8:	e9 26 ff ff ff       	jmp    8016e3 <serve+0xe>

008017bd <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8017c3:	c7 05 60 90 80 00 18 	movl   $0x804018,0x809060
  8017ca:	40 80 00 
	cprintf("FS is running\n");
  8017cd:	c7 04 24 1b 40 80 00 	movl   $0x80401b,(%esp)
  8017d4:	e8 68 06 00 00       	call   801e41 <cprintf>
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8017d9:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8017de:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8017e3:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8017e5:	c7 04 24 2a 40 80 00 	movl   $0x80402a,(%esp)
  8017ec:	e8 50 06 00 00       	call   801e41 <cprintf>

	serve_init();
  8017f1:	e8 88 fb ff ff       	call   80137e <serve_init>
	fs_init();
  8017f6:	e8 df f3 ff ff       	call   800bda <fs_init>
        fs_test();
  8017fb:	90                   	nop
  8017fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801800:	e8 05 00 00 00       	call   80180a <fs_test>
	serve();
  801805:	e8 cb fe ff ff       	call   8016d5 <serve>

0080180a <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801811:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801818:	00 
  801819:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  801820:	00 
  801821:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801828:	e8 56 10 00 00       	call   802883 <sys_page_alloc>
  80182d:	85 c0                	test   %eax,%eax
  80182f:	79 20                	jns    801851 <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  801831:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801835:	c7 44 24 08 8f 40 80 	movl   $0x80408f,0x8(%esp)
  80183c:	00 
  80183d:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  801844:	00 
  801845:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  80184c:	e8 f7 04 00 00       	call   801d48 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801851:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801858:	00 
  801859:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80185e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801862:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  801869:	e8 96 0d 00 00       	call   802604 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80186e:	e8 5c f1 ff ff       	call   8009cf <alloc_block>
  801873:	85 c0                	test   %eax,%eax
  801875:	79 20                	jns    801897 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801877:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80187b:	c7 44 24 08 ac 40 80 	movl   $0x8040ac,0x8(%esp)
  801882:	00 
  801883:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  80188a:	00 
  80188b:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801892:	e8 b1 04 00 00       	call   801d48 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801897:	8d 58 1f             	lea    0x1f(%eax),%ebx
  80189a:	85 c0                	test   %eax,%eax
  80189c:	0f 49 d8             	cmovns %eax,%ebx
  80189f:	c1 fb 05             	sar    $0x5,%ebx
  8018a2:	99                   	cltd   
  8018a3:	c1 ea 1b             	shr    $0x1b,%edx
  8018a6:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8018a9:	83 e1 1f             	and    $0x1f,%ecx
  8018ac:	29 d1                	sub    %edx,%ecx
  8018ae:	ba 01 00 00 00       	mov    $0x1,%edx
  8018b3:	d3 e2                	shl    %cl,%edx
  8018b5:	85 14 9d 00 10 00 00 	test   %edx,0x1000(,%ebx,4)
  8018bc:	75 24                	jne    8018e2 <fs_test+0xd8>
  8018be:	c7 44 24 0c bc 40 80 	movl   $0x8040bc,0xc(%esp)
  8018c5:	00 
  8018c6:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  8018cd:	00 
  8018ce:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  8018d5:	00 
  8018d6:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  8018dd:	e8 66 04 00 00       	call   801d48 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8018e2:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8018e7:	85 14 98             	test   %edx,(%eax,%ebx,4)
  8018ea:	74 24                	je     801910 <fs_test+0x106>
  8018ec:	c7 44 24 0c 34 42 80 	movl   $0x804234,0xc(%esp)
  8018f3:	00 
  8018f4:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  8018fb:	00 
  8018fc:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  801903:	00 
  801904:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  80190b:	e8 38 04 00 00       	call   801d48 <_panic>
	cprintf("alloc_block is good\n");
  801910:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  801917:	e8 25 05 00 00       	call   801e41 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80191c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801923:	c7 04 24 ec 40 80 00 	movl   $0x8040ec,(%esp)
  80192a:	e8 8f f5 ff ff       	call   800ebe <file_open>
  80192f:	85 c0                	test   %eax,%eax
  801931:	79 25                	jns    801958 <fs_test+0x14e>
  801933:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801936:	74 40                	je     801978 <fs_test+0x16e>
		panic("file_open /not-found: %e", r);
  801938:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193c:	c7 44 24 08 f7 40 80 	movl   $0x8040f7,0x8(%esp)
  801943:	00 
  801944:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  80194b:	00 
  80194c:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801953:	e8 f0 03 00 00       	call   801d48 <_panic>
	else if (r == 0)
  801958:	85 c0                	test   %eax,%eax
  80195a:	75 1c                	jne    801978 <fs_test+0x16e>
		panic("file_open /not-found succeeded!");
  80195c:	c7 44 24 08 54 42 80 	movl   $0x804254,0x8(%esp)
  801963:	00 
  801964:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80196b:	00 
  80196c:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801973:	e8 d0 03 00 00       	call   801d48 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801978:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197f:	c7 04 24 10 41 80 00 	movl   $0x804110,(%esp)
  801986:	e8 33 f5 ff ff       	call   800ebe <file_open>
  80198b:	85 c0                	test   %eax,%eax
  80198d:	79 20                	jns    8019af <fs_test+0x1a5>
		panic("file_open /newmotd: %e", r);
  80198f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801993:	c7 44 24 08 19 41 80 	movl   $0x804119,0x8(%esp)
  80199a:	00 
  80199b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8019a2:	00 
  8019a3:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  8019aa:	e8 99 03 00 00       	call   801d48 <_panic>
	cprintf("file_open is good\n");
  8019af:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  8019b6:	e8 86 04 00 00       	call   801e41 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8019bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019c9:	00 
  8019ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cd:	89 04 24             	mov    %eax,(%esp)
  8019d0:	e8 61 f2 ff ff       	call   800c36 <file_get_block>
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	79 20                	jns    8019f9 <fs_test+0x1ef>
		panic("file_get_block: %e", r);
  8019d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019dd:	c7 44 24 08 43 41 80 	movl   $0x804143,0x8(%esp)
  8019e4:	00 
  8019e5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8019ec:	00 
  8019ed:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  8019f4:	e8 4f 03 00 00       	call   801d48 <_panic>
	if (strcmp(blk, msg) != 0)
  8019f9:	c7 44 24 04 74 42 80 	movl   $0x804274,0x4(%esp)
  801a00:	00 
  801a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a04:	89 04 24             	mov    %eax,(%esp)
  801a07:	e8 10 0b 00 00       	call   80251c <strcmp>
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	74 1c                	je     801a2c <fs_test+0x222>
		panic("file_get_block returned wrong data");
  801a10:	c7 44 24 08 9c 42 80 	movl   $0x80429c,0x8(%esp)
  801a17:	00 
  801a18:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801a1f:	00 
  801a20:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801a27:	e8 1c 03 00 00       	call   801d48 <_panic>
	cprintf("file_get_block is good\n");
  801a2c:	c7 04 24 56 41 80 00 	movl   $0x804156,(%esp)
  801a33:	e8 09 04 00 00       	call   801e41 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3b:	0f b6 10             	movzbl (%eax),%edx
  801a3e:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a43:	c1 e8 0c             	shr    $0xc,%eax
  801a46:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a4d:	a8 40                	test   $0x40,%al
  801a4f:	75 24                	jne    801a75 <fs_test+0x26b>
  801a51:	c7 44 24 0c 6f 41 80 	movl   $0x80416f,0xc(%esp)
  801a58:	00 
  801a59:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801a60:	00 
  801a61:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801a68:	00 
  801a69:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801a70:	e8 d3 02 00 00       	call   801d48 <_panic>
	file_flush(f);
  801a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a78:	89 04 24             	mov    %eax,(%esp)
  801a7b:	e8 90 f6 ff ff       	call   801110 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a83:	c1 e8 0c             	shr    $0xc,%eax
  801a86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a8d:	a8 40                	test   $0x40,%al
  801a8f:	74 24                	je     801ab5 <fs_test+0x2ab>
  801a91:	c7 44 24 0c 6e 41 80 	movl   $0x80416e,0xc(%esp)
  801a98:	00 
  801a99:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801aa0:	00 
  801aa1:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801aa8:	00 
  801aa9:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801ab0:	e8 93 02 00 00       	call   801d48 <_panic>
	cprintf("file_flush is good\n");
  801ab5:	c7 04 24 8a 41 80 00 	movl   $0x80418a,(%esp)
  801abc:	e8 80 03 00 00       	call   801e41 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801ac1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ac8:	00 
  801ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 b9 f4 ff ff       	call   800f8d <file_set_size>
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	79 20                	jns    801af8 <fs_test+0x2ee>
		panic("file_set_size: %e", r);
  801ad8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801adc:	c7 44 24 08 9e 41 80 	movl   $0x80419e,0x8(%esp)
  801ae3:	00 
  801ae4:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801aeb:	00 
  801aec:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801af3:	e8 50 02 00 00       	call   801d48 <_panic>
	assert(f->f_direct[0] == 0);
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801b02:	74 24                	je     801b28 <fs_test+0x31e>
  801b04:	c7 44 24 0c b0 41 80 	movl   $0x8041b0,0xc(%esp)
  801b0b:	00 
  801b0c:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801b13:	00 
  801b14:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801b1b:	00 
  801b1c:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801b23:	e8 20 02 00 00       	call   801d48 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b28:	c1 e8 0c             	shr    $0xc,%eax
  801b2b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b32:	a8 40                	test   $0x40,%al
  801b34:	74 24                	je     801b5a <fs_test+0x350>
  801b36:	c7 44 24 0c c4 41 80 	movl   $0x8041c4,0xc(%esp)
  801b3d:	00 
  801b3e:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801b45:	00 
  801b46:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801b4d:	00 
  801b4e:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801b55:	e8 ee 01 00 00       	call   801d48 <_panic>
	cprintf("file_truncate is good\n");
  801b5a:	c7 04 24 de 41 80 00 	movl   $0x8041de,(%esp)
  801b61:	e8 db 02 00 00       	call   801e41 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801b66:	c7 04 24 74 42 80 00 	movl   $0x804274,(%esp)
  801b6d:	e8 be 08 00 00       	call   802430 <strlen>
  801b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b79:	89 04 24             	mov    %eax,(%esp)
  801b7c:	e8 0c f4 ff ff       	call   800f8d <file_set_size>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	79 20                	jns    801ba5 <fs_test+0x39b>
		panic("file_set_size 2: %e", r);
  801b85:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b89:	c7 44 24 08 f5 41 80 	movl   $0x8041f5,0x8(%esp)
  801b90:	00 
  801b91:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801b98:	00 
  801b99:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801ba0:	e8 a3 01 00 00       	call   801d48 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba8:	89 c2                	mov    %eax,%edx
  801baa:	c1 ea 0c             	shr    $0xc,%edx
  801bad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bb4:	f6 c2 40             	test   $0x40,%dl
  801bb7:	74 24                	je     801bdd <fs_test+0x3d3>
  801bb9:	c7 44 24 0c c4 41 80 	movl   $0x8041c4,0xc(%esp)
  801bc0:	00 
  801bc1:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801bc8:	00 
  801bc9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801bd0:	00 
  801bd1:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801bd8:	e8 6b 01 00 00       	call   801d48 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801bdd:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801be0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801be4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801beb:	00 
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 42 f0 ff ff       	call   800c36 <file_get_block>
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	79 20                	jns    801c18 <fs_test+0x40e>
		panic("file_get_block 2: %e", r);
  801bf8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfc:	c7 44 24 08 09 42 80 	movl   $0x804209,0x8(%esp)
  801c03:	00 
  801c04:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801c0b:	00 
  801c0c:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801c13:	e8 30 01 00 00       	call   801d48 <_panic>
	strcpy(blk, msg);
  801c18:	c7 44 24 04 74 42 80 	movl   $0x804274,0x4(%esp)
  801c1f:	00 
  801c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c23:	89 04 24             	mov    %eax,(%esp)
  801c26:	e8 3c 08 00 00       	call   802467 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2e:	c1 e8 0c             	shr    $0xc,%eax
  801c31:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c38:	a8 40                	test   $0x40,%al
  801c3a:	75 24                	jne    801c60 <fs_test+0x456>
  801c3c:	c7 44 24 0c 6f 41 80 	movl   $0x80416f,0xc(%esp)
  801c43:	00 
  801c44:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801c4b:	00 
  801c4c:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c53:	00 
  801c54:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801c5b:	e8 e8 00 00 00       	call   801d48 <_panic>
	file_flush(f);
  801c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c63:	89 04 24             	mov    %eax,(%esp)
  801c66:	e8 a5 f4 ff ff       	call   801110 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6e:	c1 e8 0c             	shr    $0xc,%eax
  801c71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c78:	a8 40                	test   $0x40,%al
  801c7a:	74 24                	je     801ca0 <fs_test+0x496>
  801c7c:	c7 44 24 0c 6e 41 80 	movl   $0x80416e,0xc(%esp)
  801c83:	00 
  801c84:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801c8b:	00 
  801c8c:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c93:	00 
  801c94:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801c9b:	e8 a8 00 00 00       	call   801d48 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca3:	c1 e8 0c             	shr    $0xc,%eax
  801ca6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cad:	a8 40                	test   $0x40,%al
  801caf:	74 24                	je     801cd5 <fs_test+0x4cb>
  801cb1:	c7 44 24 0c c4 41 80 	movl   $0x8041c4,0xc(%esp)
  801cb8:	00 
  801cb9:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  801cc0:	00 
  801cc1:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801cc8:	00 
  801cc9:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801cd0:	e8 73 00 00 00       	call   801d48 <_panic>
	cprintf("file rewrite is good\n");
  801cd5:	c7 04 24 1e 42 80 00 	movl   $0x80421e,(%esp)
  801cdc:	e8 60 01 00 00       	call   801e41 <cprintf>
}
  801ce1:	83 c4 24             	add    $0x24,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 10             	sub    $0x10,%esp
  801cef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801cf2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  801cf5:	e8 4b 0b 00 00       	call   802845 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  801cfa:	25 ff 03 00 00       	and    $0x3ff,%eax
  801cff:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d02:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d07:	a3 10 a0 80 00       	mov    %eax,0x80a010
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801d0c:	85 db                	test   %ebx,%ebx
  801d0e:	7e 07                	jle    801d17 <libmain+0x30>
		binaryname = argv[0];
  801d10:	8b 06                	mov    (%esi),%eax
  801d12:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801d17:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1b:	89 1c 24             	mov    %ebx,(%esp)
  801d1e:	e8 9a fa ff ff       	call   8017bd <umain>

	// exit gracefully
	exit();
  801d23:	e8 07 00 00 00       	call   801d2f <exit>
}
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801d35:	e8 4b 11 00 00       	call   802e85 <close_all>
	sys_env_destroy(0);
  801d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d41:	e8 ad 0a 00 00       	call   8027f3 <sys_env_destroy>
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	56                   	push   %esi
  801d4c:	53                   	push   %ebx
  801d4d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801d50:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d53:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801d59:	e8 e7 0a 00 00       	call   802845 <sys_getenvid>
  801d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d61:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d65:	8b 55 08             	mov    0x8(%ebp),%edx
  801d68:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d6c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d74:	c7 04 24 cc 42 80 00 	movl   $0x8042cc,(%esp)
  801d7b:	e8 c1 00 00 00       	call   801e41 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d84:	8b 45 10             	mov    0x10(%ebp),%eax
  801d87:	89 04 24             	mov    %eax,(%esp)
  801d8a:	e8 51 00 00 00       	call   801de0 <vcprintf>
	cprintf("\n");
  801d8f:	c7 04 24 b7 3e 80 00 	movl   $0x803eb7,(%esp)
  801d96:	e8 a6 00 00 00       	call   801e41 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d9b:	cc                   	int3   
  801d9c:	eb fd                	jmp    801d9b <_panic+0x53>

00801d9e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	53                   	push   %ebx
  801da2:	83 ec 14             	sub    $0x14,%esp
  801da5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801da8:	8b 13                	mov    (%ebx),%edx
  801daa:	8d 42 01             	lea    0x1(%edx),%eax
  801dad:	89 03                	mov    %eax,(%ebx)
  801daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801db6:	3d ff 00 00 00       	cmp    $0xff,%eax
  801dbb:	75 19                	jne    801dd6 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801dbd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801dc4:	00 
  801dc5:	8d 43 08             	lea    0x8(%ebx),%eax
  801dc8:	89 04 24             	mov    %eax,(%esp)
  801dcb:	e8 e6 09 00 00       	call   8027b6 <sys_cputs>
		b->idx = 0;
  801dd0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801dd6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801dda:	83 c4 14             	add    $0x14,%esp
  801ddd:	5b                   	pop    %ebx
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801de9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801df0:	00 00 00 
	b.cnt = 0;
  801df3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801dfa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e04:	8b 45 08             	mov    0x8(%ebp),%eax
  801e07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e0b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801e11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e15:	c7 04 24 9e 1d 80 00 	movl   $0x801d9e,(%esp)
  801e1c:	e8 ad 01 00 00       	call   801fce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801e21:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801e31:	89 04 24             	mov    %eax,(%esp)
  801e34:	e8 7d 09 00 00       	call   8027b6 <sys_cputs>

	return b.cnt;
}
  801e39:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    

00801e41 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801e47:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e51:	89 04 24             	mov    %eax,(%esp)
  801e54:	e8 87 ff ff ff       	call   801de0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    
  801e5b:	66 90                	xchg   %ax,%ax
  801e5d:	66 90                	xchg   %ax,%ax
  801e5f:	90                   	nop

00801e60 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	57                   	push   %edi
  801e64:	56                   	push   %esi
  801e65:	53                   	push   %ebx
  801e66:	83 ec 3c             	sub    $0x3c,%esp
  801e69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e6c:	89 d7                	mov    %edx,%edi
  801e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e77:	89 c3                	mov    %eax,%ebx
  801e79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801e7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e7f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801e82:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e8a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e8d:	39 d9                	cmp    %ebx,%ecx
  801e8f:	72 05                	jb     801e96 <printnum+0x36>
  801e91:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801e94:	77 69                	ja     801eff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801e96:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801e99:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e9d:	83 ee 01             	sub    $0x1,%esi
  801ea0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ea4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea8:	8b 44 24 08          	mov    0x8(%esp),%eax
  801eac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801eb0:	89 c3                	mov    %eax,%ebx
  801eb2:	89 d6                	mov    %edx,%esi
  801eb4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801eb7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801eba:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ebe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ec2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec5:	89 04 24             	mov    %eax,(%esp)
  801ec8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecf:	e8 9c 1b 00 00       	call   803a70 <__udivdi3>
  801ed4:	89 d9                	mov    %ebx,%ecx
  801ed6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eda:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ede:	89 04 24             	mov    %eax,(%esp)
  801ee1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ee5:	89 fa                	mov    %edi,%edx
  801ee7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eea:	e8 71 ff ff ff       	call   801e60 <printnum>
  801eef:	eb 1b                	jmp    801f0c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801ef1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ef5:	8b 45 18             	mov    0x18(%ebp),%eax
  801ef8:	89 04 24             	mov    %eax,(%esp)
  801efb:	ff d3                	call   *%ebx
  801efd:	eb 03                	jmp    801f02 <printnum+0xa2>
  801eff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  801f02:	83 ee 01             	sub    $0x1,%esi
  801f05:	85 f6                	test   %esi,%esi
  801f07:	7f e8                	jg     801ef1 <printnum+0x91>
  801f09:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801f0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f10:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f14:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f17:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801f1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f1e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f22:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f25:	89 04 24             	mov    %eax,(%esp)
  801f28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2f:	e8 6c 1c 00 00       	call   803ba0 <__umoddi3>
  801f34:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f38:	0f be 80 ef 42 80 00 	movsbl 0x8042ef(%eax),%eax
  801f3f:	89 04 24             	mov    %eax,(%esp)
  801f42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f45:	ff d0                	call   *%eax
}
  801f47:	83 c4 3c             	add    $0x3c,%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801f52:	83 fa 01             	cmp    $0x1,%edx
  801f55:	7e 0e                	jle    801f65 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801f57:	8b 10                	mov    (%eax),%edx
  801f59:	8d 4a 08             	lea    0x8(%edx),%ecx
  801f5c:	89 08                	mov    %ecx,(%eax)
  801f5e:	8b 02                	mov    (%edx),%eax
  801f60:	8b 52 04             	mov    0x4(%edx),%edx
  801f63:	eb 22                	jmp    801f87 <getuint+0x38>
	else if (lflag)
  801f65:	85 d2                	test   %edx,%edx
  801f67:	74 10                	je     801f79 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801f69:	8b 10                	mov    (%eax),%edx
  801f6b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801f6e:	89 08                	mov    %ecx,(%eax)
  801f70:	8b 02                	mov    (%edx),%eax
  801f72:	ba 00 00 00 00       	mov    $0x0,%edx
  801f77:	eb 0e                	jmp    801f87 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801f79:	8b 10                	mov    (%eax),%edx
  801f7b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801f7e:	89 08                	mov    %ecx,(%eax)
  801f80:	8b 02                	mov    (%edx),%eax
  801f82:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    

00801f89 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801f8f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801f93:	8b 10                	mov    (%eax),%edx
  801f95:	3b 50 04             	cmp    0x4(%eax),%edx
  801f98:	73 0a                	jae    801fa4 <sprintputch+0x1b>
		*b->buf++ = ch;
  801f9a:	8d 4a 01             	lea    0x1(%edx),%ecx
  801f9d:	89 08                	mov    %ecx,(%eax)
  801f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa2:	88 02                	mov    %al,(%edx)
}
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    

00801fa6 <printfmt>:
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  801fac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc4:	89 04 24             	mov    %eax,(%esp)
  801fc7:	e8 02 00 00 00       	call   801fce <vprintfmt>
}
  801fcc:	c9                   	leave  
  801fcd:	c3                   	ret    

00801fce <vprintfmt>:
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 3c             	sub    $0x3c,%esp
  801fd7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fdd:	eb 1f                	jmp    801ffe <vprintfmt+0x30>
			if (ch == '\0'){
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	75 0f                	jne    801ff2 <vprintfmt+0x24>
				color = 0x0100;
  801fe3:	c7 05 00 a0 80 00 00 	movl   $0x100,0x80a000
  801fea:	01 00 00 
  801fed:	e9 b3 03 00 00       	jmp    8023a5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  801ff2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ff6:	89 04 24             	mov    %eax,(%esp)
  801ff9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ffc:	89 f3                	mov    %esi,%ebx
  801ffe:	8d 73 01             	lea    0x1(%ebx),%esi
  802001:	0f b6 03             	movzbl (%ebx),%eax
  802004:	83 f8 25             	cmp    $0x25,%eax
  802007:	75 d6                	jne    801fdf <vprintfmt+0x11>
  802009:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80200d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  802014:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80201b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  802022:	ba 00 00 00 00       	mov    $0x0,%edx
  802027:	eb 1d                	jmp    802046 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  802029:	89 de                	mov    %ebx,%esi
			padc = '-';
  80202b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80202f:	eb 15                	jmp    802046 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  802031:	89 de                	mov    %ebx,%esi
			padc = '0';
  802033:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  802037:	eb 0d                	jmp    802046 <vprintfmt+0x78>
				width = precision, precision = -1;
  802039:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80203c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80203f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  802046:	8d 5e 01             	lea    0x1(%esi),%ebx
  802049:	0f b6 0e             	movzbl (%esi),%ecx
  80204c:	0f b6 c1             	movzbl %cl,%eax
  80204f:	83 e9 23             	sub    $0x23,%ecx
  802052:	80 f9 55             	cmp    $0x55,%cl
  802055:	0f 87 2a 03 00 00    	ja     802385 <vprintfmt+0x3b7>
  80205b:	0f b6 c9             	movzbl %cl,%ecx
  80205e:	ff 24 8d 40 44 80 00 	jmp    *0x804440(,%ecx,4)
  802065:	89 de                	mov    %ebx,%esi
  802067:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80206c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80206f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  802073:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  802076:	8d 58 d0             	lea    -0x30(%eax),%ebx
  802079:	83 fb 09             	cmp    $0x9,%ebx
  80207c:	77 36                	ja     8020b4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80207e:	83 c6 01             	add    $0x1,%esi
			}
  802081:	eb e9                	jmp    80206c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  802083:	8b 45 14             	mov    0x14(%ebp),%eax
  802086:	8d 48 04             	lea    0x4(%eax),%ecx
  802089:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80208c:	8b 00                	mov    (%eax),%eax
  80208e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  802091:	89 de                	mov    %ebx,%esi
			goto process_precision;
  802093:	eb 22                	jmp    8020b7 <vprintfmt+0xe9>
  802095:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  802098:	85 c9                	test   %ecx,%ecx
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
  80209f:	0f 49 c1             	cmovns %ecx,%eax
  8020a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8020a5:	89 de                	mov    %ebx,%esi
  8020a7:	eb 9d                	jmp    802046 <vprintfmt+0x78>
  8020a9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8020ab:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8020b2:	eb 92                	jmp    802046 <vprintfmt+0x78>
  8020b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8020b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8020bb:	79 89                	jns    802046 <vprintfmt+0x78>
  8020bd:	e9 77 ff ff ff       	jmp    802039 <vprintfmt+0x6b>
			lflag++;
  8020c2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8020c5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8020c7:	e9 7a ff ff ff       	jmp    802046 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8020cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8020cf:	8d 50 04             	lea    0x4(%eax),%edx
  8020d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8020d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020d9:	8b 00                	mov    (%eax),%eax
  8020db:	89 04 24             	mov    %eax,(%esp)
  8020de:	ff 55 08             	call   *0x8(%ebp)
			break;
  8020e1:	e9 18 ff ff ff       	jmp    801ffe <vprintfmt+0x30>
			err = va_arg(ap, int);
  8020e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8020e9:	8d 50 04             	lea    0x4(%eax),%edx
  8020ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8020ef:	8b 00                	mov    (%eax),%eax
  8020f1:	99                   	cltd   
  8020f2:	31 d0                	xor    %edx,%eax
  8020f4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8020f6:	83 f8 0f             	cmp    $0xf,%eax
  8020f9:	7f 0b                	jg     802106 <vprintfmt+0x138>
  8020fb:	8b 14 85 a0 45 80 00 	mov    0x8045a0(,%eax,4),%edx
  802102:	85 d2                	test   %edx,%edx
  802104:	75 20                	jne    802126 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  802106:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210a:	c7 44 24 08 07 43 80 	movl   $0x804307,0x8(%esp)
  802111:	00 
  802112:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802116:	8b 45 08             	mov    0x8(%ebp),%eax
  802119:	89 04 24             	mov    %eax,(%esp)
  80211c:	e8 85 fe ff ff       	call   801fa6 <printfmt>
  802121:	e9 d8 fe ff ff       	jmp    801ffe <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  802126:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80212a:	c7 44 24 08 4f 3d 80 	movl   $0x803d4f,0x8(%esp)
  802131:	00 
  802132:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802136:	8b 45 08             	mov    0x8(%ebp),%eax
  802139:	89 04 24             	mov    %eax,(%esp)
  80213c:	e8 65 fe ff ff       	call   801fa6 <printfmt>
  802141:	e9 b8 fe ff ff       	jmp    801ffe <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  802146:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  802149:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80214c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80214f:	8b 45 14             	mov    0x14(%ebp),%eax
  802152:	8d 50 04             	lea    0x4(%eax),%edx
  802155:	89 55 14             	mov    %edx,0x14(%ebp)
  802158:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80215a:	85 f6                	test   %esi,%esi
  80215c:	b8 00 43 80 00       	mov    $0x804300,%eax
  802161:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  802164:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  802168:	0f 84 97 00 00 00    	je     802205 <vprintfmt+0x237>
  80216e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  802172:	0f 8e 9b 00 00 00    	jle    802213 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  802178:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80217c:	89 34 24             	mov    %esi,(%esp)
  80217f:	e8 c4 02 00 00       	call   802448 <strnlen>
  802184:	8b 55 d0             	mov    -0x30(%ebp),%edx
  802187:	29 c2                	sub    %eax,%edx
  802189:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80218c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  802190:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802193:	89 75 d8             	mov    %esi,-0x28(%ebp)
  802196:	8b 75 08             	mov    0x8(%ebp),%esi
  802199:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80219c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80219e:	eb 0f                	jmp    8021af <vprintfmt+0x1e1>
					putch(padc, putdat);
  8021a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8021a7:	89 04 24             	mov    %eax,(%esp)
  8021aa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8021ac:	83 eb 01             	sub    $0x1,%ebx
  8021af:	85 db                	test   %ebx,%ebx
  8021b1:	7f ed                	jg     8021a0 <vprintfmt+0x1d2>
  8021b3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8021b6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8021b9:	85 d2                	test   %edx,%edx
  8021bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c0:	0f 49 c2             	cmovns %edx,%eax
  8021c3:	29 c2                	sub    %eax,%edx
  8021c5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8021c8:	89 d7                	mov    %edx,%edi
  8021ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8021cd:	eb 50                	jmp    80221f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8021cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8021d3:	74 1e                	je     8021f3 <vprintfmt+0x225>
  8021d5:	0f be d2             	movsbl %dl,%edx
  8021d8:	83 ea 20             	sub    $0x20,%edx
  8021db:	83 fa 5e             	cmp    $0x5e,%edx
  8021de:	76 13                	jbe    8021f3 <vprintfmt+0x225>
					putch('?', putdat);
  8021e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8021ee:	ff 55 08             	call   *0x8(%ebp)
  8021f1:	eb 0d                	jmp    802200 <vprintfmt+0x232>
					putch(ch, putdat);
  8021f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021fa:	89 04 24             	mov    %eax,(%esp)
  8021fd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802200:	83 ef 01             	sub    $0x1,%edi
  802203:	eb 1a                	jmp    80221f <vprintfmt+0x251>
  802205:	89 7d 0c             	mov    %edi,0xc(%ebp)
  802208:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80220b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80220e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802211:	eb 0c                	jmp    80221f <vprintfmt+0x251>
  802213:	89 7d 0c             	mov    %edi,0xc(%ebp)
  802216:	8b 7d dc             	mov    -0x24(%ebp),%edi
  802219:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80221c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80221f:	83 c6 01             	add    $0x1,%esi
  802222:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  802226:	0f be c2             	movsbl %dl,%eax
  802229:	85 c0                	test   %eax,%eax
  80222b:	74 27                	je     802254 <vprintfmt+0x286>
  80222d:	85 db                	test   %ebx,%ebx
  80222f:	78 9e                	js     8021cf <vprintfmt+0x201>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	79 99                	jns    8021cf <vprintfmt+0x201>
  802236:	89 f8                	mov    %edi,%eax
  802238:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80223b:	8b 75 08             	mov    0x8(%ebp),%esi
  80223e:	89 c3                	mov    %eax,%ebx
  802240:	eb 1a                	jmp    80225c <vprintfmt+0x28e>
				putch(' ', putdat);
  802242:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802246:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80224d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80224f:	83 eb 01             	sub    $0x1,%ebx
  802252:	eb 08                	jmp    80225c <vprintfmt+0x28e>
  802254:	89 fb                	mov    %edi,%ebx
  802256:	8b 75 08             	mov    0x8(%ebp),%esi
  802259:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80225c:	85 db                	test   %ebx,%ebx
  80225e:	7f e2                	jg     802242 <vprintfmt+0x274>
  802260:	89 75 08             	mov    %esi,0x8(%ebp)
  802263:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802266:	e9 93 fd ff ff       	jmp    801ffe <vprintfmt+0x30>
	if (lflag >= 2)
  80226b:	83 fa 01             	cmp    $0x1,%edx
  80226e:	7e 16                	jle    802286 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  802270:	8b 45 14             	mov    0x14(%ebp),%eax
  802273:	8d 50 08             	lea    0x8(%eax),%edx
  802276:	89 55 14             	mov    %edx,0x14(%ebp)
  802279:	8b 50 04             	mov    0x4(%eax),%edx
  80227c:	8b 00                	mov    (%eax),%eax
  80227e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802281:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802284:	eb 32                	jmp    8022b8 <vprintfmt+0x2ea>
	else if (lflag)
  802286:	85 d2                	test   %edx,%edx
  802288:	74 18                	je     8022a2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80228a:	8b 45 14             	mov    0x14(%ebp),%eax
  80228d:	8d 50 04             	lea    0x4(%eax),%edx
  802290:	89 55 14             	mov    %edx,0x14(%ebp)
  802293:	8b 30                	mov    (%eax),%esi
  802295:	89 75 e0             	mov    %esi,-0x20(%ebp)
  802298:	89 f0                	mov    %esi,%eax
  80229a:	c1 f8 1f             	sar    $0x1f,%eax
  80229d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8022a0:	eb 16                	jmp    8022b8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8022a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8022a5:	8d 50 04             	lea    0x4(%eax),%edx
  8022a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8022ab:	8b 30                	mov    (%eax),%esi
  8022ad:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8022b0:	89 f0                	mov    %esi,%eax
  8022b2:	c1 f8 1f             	sar    $0x1f,%eax
  8022b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8022b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8022be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8022c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8022c7:	0f 89 80 00 00 00    	jns    80234d <vprintfmt+0x37f>
				putch('-', putdat);
  8022cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022d1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8022d8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8022db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8022e1:	f7 d8                	neg    %eax
  8022e3:	83 d2 00             	adc    $0x0,%edx
  8022e6:	f7 da                	neg    %edx
			base = 10;
  8022e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8022ed:	eb 5e                	jmp    80234d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8022ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8022f2:	e8 58 fc ff ff       	call   801f4f <getuint>
			base = 10;
  8022f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8022fc:	eb 4f                	jmp    80234d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8022fe:	8d 45 14             	lea    0x14(%ebp),%eax
  802301:	e8 49 fc ff ff       	call   801f4f <getuint>
            base = 8;
  802306:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80230b:	eb 40                	jmp    80234d <vprintfmt+0x37f>
			putch('0', putdat);
  80230d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802311:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802318:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80231b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80231f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  802326:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  802329:	8b 45 14             	mov    0x14(%ebp),%eax
  80232c:	8d 50 04             	lea    0x4(%eax),%edx
  80232f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  802332:	8b 00                	mov    (%eax),%eax
  802334:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  802339:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80233e:	eb 0d                	jmp    80234d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  802340:	8d 45 14             	lea    0x14(%ebp),%eax
  802343:	e8 07 fc ff ff       	call   801f4f <getuint>
			base = 16;
  802348:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80234d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  802351:	89 74 24 10          	mov    %esi,0x10(%esp)
  802355:	8b 75 dc             	mov    -0x24(%ebp),%esi
  802358:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80235c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802360:	89 04 24             	mov    %eax,(%esp)
  802363:	89 54 24 04          	mov    %edx,0x4(%esp)
  802367:	89 fa                	mov    %edi,%edx
  802369:	8b 45 08             	mov    0x8(%ebp),%eax
  80236c:	e8 ef fa ff ff       	call   801e60 <printnum>
			break;
  802371:	e9 88 fc ff ff       	jmp    801ffe <vprintfmt+0x30>
			putch(ch, putdat);
  802376:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80237a:	89 04 24             	mov    %eax,(%esp)
  80237d:	ff 55 08             	call   *0x8(%ebp)
			break;
  802380:	e9 79 fc ff ff       	jmp    801ffe <vprintfmt+0x30>
			putch('%', putdat);
  802385:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802389:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802390:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  802393:	89 f3                	mov    %esi,%ebx
  802395:	eb 03                	jmp    80239a <vprintfmt+0x3cc>
  802397:	83 eb 01             	sub    $0x1,%ebx
  80239a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80239e:	75 f7                	jne    802397 <vprintfmt+0x3c9>
  8023a0:	e9 59 fc ff ff       	jmp    801ffe <vprintfmt+0x30>
}
  8023a5:	83 c4 3c             	add    $0x3c,%esp
  8023a8:	5b                   	pop    %ebx
  8023a9:	5e                   	pop    %esi
  8023aa:	5f                   	pop    %edi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    

008023ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8023ad:	55                   	push   %ebp
  8023ae:	89 e5                	mov    %esp,%ebp
  8023b0:	83 ec 28             	sub    $0x28,%esp
  8023b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8023b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8023bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8023c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8023c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8023ca:	85 c0                	test   %eax,%eax
  8023cc:	74 30                	je     8023fe <vsnprintf+0x51>
  8023ce:	85 d2                	test   %edx,%edx
  8023d0:	7e 2c                	jle    8023fe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8023d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8023d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8023dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8023e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e7:	c7 04 24 89 1f 80 00 	movl   $0x801f89,(%esp)
  8023ee:	e8 db fb ff ff       	call   801fce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8023f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8023f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8023f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fc:	eb 05                	jmp    802403 <vsnprintf+0x56>
		return -E_INVAL;
  8023fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802403:	c9                   	leave  
  802404:	c3                   	ret    

00802405 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802405:	55                   	push   %ebp
  802406:	89 e5                	mov    %esp,%ebp
  802408:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80240b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80240e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802412:	8b 45 10             	mov    0x10(%ebp),%eax
  802415:	89 44 24 08          	mov    %eax,0x8(%esp)
  802419:	8b 45 0c             	mov    0xc(%ebp),%eax
  80241c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802420:	8b 45 08             	mov    0x8(%ebp),%eax
  802423:	89 04 24             	mov    %eax,(%esp)
  802426:	e8 82 ff ff ff       	call   8023ad <vsnprintf>
	va_end(ap);

	return rc;
}
  80242b:	c9                   	leave  
  80242c:	c3                   	ret    
  80242d:	66 90                	xchg   %ax,%ax
  80242f:	90                   	nop

00802430 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802436:	b8 00 00 00 00       	mov    $0x0,%eax
  80243b:	eb 03                	jmp    802440 <strlen+0x10>
		n++;
  80243d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  802440:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802444:	75 f7                	jne    80243d <strlen+0xd>
	return n;
}
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    

00802448 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802448:	55                   	push   %ebp
  802449:	89 e5                	mov    %esp,%ebp
  80244b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80244e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802451:	b8 00 00 00 00       	mov    $0x0,%eax
  802456:	eb 03                	jmp    80245b <strnlen+0x13>
		n++;
  802458:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80245b:	39 d0                	cmp    %edx,%eax
  80245d:	74 06                	je     802465 <strnlen+0x1d>
  80245f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  802463:	75 f3                	jne    802458 <strnlen+0x10>
	return n;
}
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    

00802467 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
  80246a:	53                   	push   %ebx
  80246b:	8b 45 08             	mov    0x8(%ebp),%eax
  80246e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802471:	89 c2                	mov    %eax,%edx
  802473:	83 c2 01             	add    $0x1,%edx
  802476:	83 c1 01             	add    $0x1,%ecx
  802479:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80247d:	88 5a ff             	mov    %bl,-0x1(%edx)
  802480:	84 db                	test   %bl,%bl
  802482:	75 ef                	jne    802473 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802484:	5b                   	pop    %ebx
  802485:	5d                   	pop    %ebp
  802486:	c3                   	ret    

00802487 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802487:	55                   	push   %ebp
  802488:	89 e5                	mov    %esp,%ebp
  80248a:	53                   	push   %ebx
  80248b:	83 ec 08             	sub    $0x8,%esp
  80248e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802491:	89 1c 24             	mov    %ebx,(%esp)
  802494:	e8 97 ff ff ff       	call   802430 <strlen>
	strcpy(dst + len, src);
  802499:	8b 55 0c             	mov    0xc(%ebp),%edx
  80249c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024a0:	01 d8                	add    %ebx,%eax
  8024a2:	89 04 24             	mov    %eax,(%esp)
  8024a5:	e8 bd ff ff ff       	call   802467 <strcpy>
	return dst;
}
  8024aa:	89 d8                	mov    %ebx,%eax
  8024ac:	83 c4 08             	add    $0x8,%esp
  8024af:	5b                   	pop    %ebx
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    

008024b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8024b2:	55                   	push   %ebp
  8024b3:	89 e5                	mov    %esp,%ebp
  8024b5:	56                   	push   %esi
  8024b6:	53                   	push   %ebx
  8024b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024bd:	89 f3                	mov    %esi,%ebx
  8024bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	eb 0f                	jmp    8024d5 <strncpy+0x23>
		*dst++ = *src;
  8024c6:	83 c2 01             	add    $0x1,%edx
  8024c9:	0f b6 01             	movzbl (%ecx),%eax
  8024cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8024cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8024d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8024d5:	39 da                	cmp    %ebx,%edx
  8024d7:	75 ed                	jne    8024c6 <strncpy+0x14>
	}
	return ret;
}
  8024d9:	89 f0                	mov    %esi,%eax
  8024db:	5b                   	pop    %ebx
  8024dc:	5e                   	pop    %esi
  8024dd:	5d                   	pop    %ebp
  8024de:	c3                   	ret    

008024df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8024e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8024ed:	89 f0                	mov    %esi,%eax
  8024ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8024f3:	85 c9                	test   %ecx,%ecx
  8024f5:	75 0b                	jne    802502 <strlcpy+0x23>
  8024f7:	eb 1d                	jmp    802516 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8024f9:	83 c0 01             	add    $0x1,%eax
  8024fc:	83 c2 01             	add    $0x1,%edx
  8024ff:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  802502:	39 d8                	cmp    %ebx,%eax
  802504:	74 0b                	je     802511 <strlcpy+0x32>
  802506:	0f b6 0a             	movzbl (%edx),%ecx
  802509:	84 c9                	test   %cl,%cl
  80250b:	75 ec                	jne    8024f9 <strlcpy+0x1a>
  80250d:	89 c2                	mov    %eax,%edx
  80250f:	eb 02                	jmp    802513 <strlcpy+0x34>
  802511:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  802513:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  802516:	29 f0                	sub    %esi,%eax
}
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    

0080251c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80251c:	55                   	push   %ebp
  80251d:	89 e5                	mov    %esp,%ebp
  80251f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802522:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802525:	eb 06                	jmp    80252d <strcmp+0x11>
		p++, q++;
  802527:	83 c1 01             	add    $0x1,%ecx
  80252a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80252d:	0f b6 01             	movzbl (%ecx),%eax
  802530:	84 c0                	test   %al,%al
  802532:	74 04                	je     802538 <strcmp+0x1c>
  802534:	3a 02                	cmp    (%edx),%al
  802536:	74 ef                	je     802527 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802538:	0f b6 c0             	movzbl %al,%eax
  80253b:	0f b6 12             	movzbl (%edx),%edx
  80253e:	29 d0                	sub    %edx,%eax
}
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    

00802542 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802542:	55                   	push   %ebp
  802543:	89 e5                	mov    %esp,%ebp
  802545:	53                   	push   %ebx
  802546:	8b 45 08             	mov    0x8(%ebp),%eax
  802549:	8b 55 0c             	mov    0xc(%ebp),%edx
  80254c:	89 c3                	mov    %eax,%ebx
  80254e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802551:	eb 06                	jmp    802559 <strncmp+0x17>
		n--, p++, q++;
  802553:	83 c0 01             	add    $0x1,%eax
  802556:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  802559:	39 d8                	cmp    %ebx,%eax
  80255b:	74 15                	je     802572 <strncmp+0x30>
  80255d:	0f b6 08             	movzbl (%eax),%ecx
  802560:	84 c9                	test   %cl,%cl
  802562:	74 04                	je     802568 <strncmp+0x26>
  802564:	3a 0a                	cmp    (%edx),%cl
  802566:	74 eb                	je     802553 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802568:	0f b6 00             	movzbl (%eax),%eax
  80256b:	0f b6 12             	movzbl (%edx),%edx
  80256e:	29 d0                	sub    %edx,%eax
  802570:	eb 05                	jmp    802577 <strncmp+0x35>
		return 0;
  802572:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802577:	5b                   	pop    %ebx
  802578:	5d                   	pop    %ebp
  802579:	c3                   	ret    

0080257a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80257a:	55                   	push   %ebp
  80257b:	89 e5                	mov    %esp,%ebp
  80257d:	8b 45 08             	mov    0x8(%ebp),%eax
  802580:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802584:	eb 07                	jmp    80258d <strchr+0x13>
		if (*s == c)
  802586:	38 ca                	cmp    %cl,%dl
  802588:	74 0f                	je     802599 <strchr+0x1f>
	for (; *s; s++)
  80258a:	83 c0 01             	add    $0x1,%eax
  80258d:	0f b6 10             	movzbl (%eax),%edx
  802590:	84 d2                	test   %dl,%dl
  802592:	75 f2                	jne    802586 <strchr+0xc>
			return (char *) s;
	return 0;
  802594:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    

0080259b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8025a5:	eb 07                	jmp    8025ae <strfind+0x13>
		if (*s == c)
  8025a7:	38 ca                	cmp    %cl,%dl
  8025a9:	74 0a                	je     8025b5 <strfind+0x1a>
	for (; *s; s++)
  8025ab:	83 c0 01             	add    $0x1,%eax
  8025ae:	0f b6 10             	movzbl (%eax),%edx
  8025b1:	84 d2                	test   %dl,%dl
  8025b3:	75 f2                	jne    8025a7 <strfind+0xc>
			break;
	return (char *) s;
}
  8025b5:	5d                   	pop    %ebp
  8025b6:	c3                   	ret    

008025b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8025b7:	55                   	push   %ebp
  8025b8:	89 e5                	mov    %esp,%ebp
  8025ba:	57                   	push   %edi
  8025bb:	56                   	push   %esi
  8025bc:	53                   	push   %ebx
  8025bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8025c3:	85 c9                	test   %ecx,%ecx
  8025c5:	74 36                	je     8025fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8025c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8025cd:	75 28                	jne    8025f7 <memset+0x40>
  8025cf:	f6 c1 03             	test   $0x3,%cl
  8025d2:	75 23                	jne    8025f7 <memset+0x40>
		c &= 0xFF;
  8025d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8025d8:	89 d3                	mov    %edx,%ebx
  8025da:	c1 e3 08             	shl    $0x8,%ebx
  8025dd:	89 d6                	mov    %edx,%esi
  8025df:	c1 e6 18             	shl    $0x18,%esi
  8025e2:	89 d0                	mov    %edx,%eax
  8025e4:	c1 e0 10             	shl    $0x10,%eax
  8025e7:	09 f0                	or     %esi,%eax
  8025e9:	09 c2                	or     %eax,%edx
  8025eb:	89 d0                	mov    %edx,%eax
  8025ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8025ef:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8025f2:	fc                   	cld    
  8025f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8025f5:	eb 06                	jmp    8025fd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8025f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025fa:	fc                   	cld    
  8025fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8025fd:	89 f8                	mov    %edi,%eax
  8025ff:	5b                   	pop    %ebx
  802600:	5e                   	pop    %esi
  802601:	5f                   	pop    %edi
  802602:	5d                   	pop    %ebp
  802603:	c3                   	ret    

00802604 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802604:	55                   	push   %ebp
  802605:	89 e5                	mov    %esp,%ebp
  802607:	57                   	push   %edi
  802608:	56                   	push   %esi
  802609:	8b 45 08             	mov    0x8(%ebp),%eax
  80260c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80260f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802612:	39 c6                	cmp    %eax,%esi
  802614:	73 35                	jae    80264b <memmove+0x47>
  802616:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802619:	39 d0                	cmp    %edx,%eax
  80261b:	73 2e                	jae    80264b <memmove+0x47>
		s += n;
		d += n;
  80261d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802620:	89 d6                	mov    %edx,%esi
  802622:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802624:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80262a:	75 13                	jne    80263f <memmove+0x3b>
  80262c:	f6 c1 03             	test   $0x3,%cl
  80262f:	75 0e                	jne    80263f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802631:	83 ef 04             	sub    $0x4,%edi
  802634:	8d 72 fc             	lea    -0x4(%edx),%esi
  802637:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80263a:	fd                   	std    
  80263b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80263d:	eb 09                	jmp    802648 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80263f:	83 ef 01             	sub    $0x1,%edi
  802642:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  802645:	fd                   	std    
  802646:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802648:	fc                   	cld    
  802649:	eb 1d                	jmp    802668 <memmove+0x64>
  80264b:	89 f2                	mov    %esi,%edx
  80264d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80264f:	f6 c2 03             	test   $0x3,%dl
  802652:	75 0f                	jne    802663 <memmove+0x5f>
  802654:	f6 c1 03             	test   $0x3,%cl
  802657:	75 0a                	jne    802663 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802659:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80265c:	89 c7                	mov    %eax,%edi
  80265e:	fc                   	cld    
  80265f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802661:	eb 05                	jmp    802668 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  802663:	89 c7                	mov    %eax,%edi
  802665:	fc                   	cld    
  802666:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802668:	5e                   	pop    %esi
  802669:	5f                   	pop    %edi
  80266a:	5d                   	pop    %ebp
  80266b:	c3                   	ret    

0080266c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80266c:	55                   	push   %ebp
  80266d:	89 e5                	mov    %esp,%ebp
  80266f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802672:	8b 45 10             	mov    0x10(%ebp),%eax
  802675:	89 44 24 08          	mov    %eax,0x8(%esp)
  802679:	8b 45 0c             	mov    0xc(%ebp),%eax
  80267c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802680:	8b 45 08             	mov    0x8(%ebp),%eax
  802683:	89 04 24             	mov    %eax,(%esp)
  802686:	e8 79 ff ff ff       	call   802604 <memmove>
}
  80268b:	c9                   	leave  
  80268c:	c3                   	ret    

0080268d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80268d:	55                   	push   %ebp
  80268e:	89 e5                	mov    %esp,%ebp
  802690:	56                   	push   %esi
  802691:	53                   	push   %ebx
  802692:	8b 55 08             	mov    0x8(%ebp),%edx
  802695:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802698:	89 d6                	mov    %edx,%esi
  80269a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80269d:	eb 1a                	jmp    8026b9 <memcmp+0x2c>
		if (*s1 != *s2)
  80269f:	0f b6 02             	movzbl (%edx),%eax
  8026a2:	0f b6 19             	movzbl (%ecx),%ebx
  8026a5:	38 d8                	cmp    %bl,%al
  8026a7:	74 0a                	je     8026b3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8026a9:	0f b6 c0             	movzbl %al,%eax
  8026ac:	0f b6 db             	movzbl %bl,%ebx
  8026af:	29 d8                	sub    %ebx,%eax
  8026b1:	eb 0f                	jmp    8026c2 <memcmp+0x35>
		s1++, s2++;
  8026b3:	83 c2 01             	add    $0x1,%edx
  8026b6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  8026b9:	39 f2                	cmp    %esi,%edx
  8026bb:	75 e2                	jne    80269f <memcmp+0x12>
	}

	return 0;
  8026bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026c2:	5b                   	pop    %ebx
  8026c3:	5e                   	pop    %esi
  8026c4:	5d                   	pop    %ebp
  8026c5:	c3                   	ret    

008026c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8026c6:	55                   	push   %ebp
  8026c7:	89 e5                	mov    %esp,%ebp
  8026c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8026cf:	89 c2                	mov    %eax,%edx
  8026d1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8026d4:	eb 07                	jmp    8026dd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8026d6:	38 08                	cmp    %cl,(%eax)
  8026d8:	74 07                	je     8026e1 <memfind+0x1b>
	for (; s < ends; s++)
  8026da:	83 c0 01             	add    $0x1,%eax
  8026dd:	39 d0                	cmp    %edx,%eax
  8026df:	72 f5                	jb     8026d6 <memfind+0x10>
			break;
	return (void *) s;
}
  8026e1:	5d                   	pop    %ebp
  8026e2:	c3                   	ret    

008026e3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8026e3:	55                   	push   %ebp
  8026e4:	89 e5                	mov    %esp,%ebp
  8026e6:	57                   	push   %edi
  8026e7:	56                   	push   %esi
  8026e8:	53                   	push   %ebx
  8026e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8026ef:	eb 03                	jmp    8026f4 <strtol+0x11>
		s++;
  8026f1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8026f4:	0f b6 0a             	movzbl (%edx),%ecx
  8026f7:	80 f9 09             	cmp    $0x9,%cl
  8026fa:	74 f5                	je     8026f1 <strtol+0xe>
  8026fc:	80 f9 20             	cmp    $0x20,%cl
  8026ff:	74 f0                	je     8026f1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  802701:	80 f9 2b             	cmp    $0x2b,%cl
  802704:	75 0a                	jne    802710 <strtol+0x2d>
		s++;
  802706:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  802709:	bf 00 00 00 00       	mov    $0x0,%edi
  80270e:	eb 11                	jmp    802721 <strtol+0x3e>
  802710:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  802715:	80 f9 2d             	cmp    $0x2d,%cl
  802718:	75 07                	jne    802721 <strtol+0x3e>
		s++, neg = 1;
  80271a:	8d 52 01             	lea    0x1(%edx),%edx
  80271d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802721:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  802726:	75 15                	jne    80273d <strtol+0x5a>
  802728:	80 3a 30             	cmpb   $0x30,(%edx)
  80272b:	75 10                	jne    80273d <strtol+0x5a>
  80272d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802731:	75 0a                	jne    80273d <strtol+0x5a>
		s += 2, base = 16;
  802733:	83 c2 02             	add    $0x2,%edx
  802736:	b8 10 00 00 00       	mov    $0x10,%eax
  80273b:	eb 10                	jmp    80274d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80273d:	85 c0                	test   %eax,%eax
  80273f:	75 0c                	jne    80274d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802741:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  802743:	80 3a 30             	cmpb   $0x30,(%edx)
  802746:	75 05                	jne    80274d <strtol+0x6a>
		s++, base = 8;
  802748:	83 c2 01             	add    $0x1,%edx
  80274b:	b0 08                	mov    $0x8,%al
		base = 10;
  80274d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802752:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802755:	0f b6 0a             	movzbl (%edx),%ecx
  802758:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80275b:	89 f0                	mov    %esi,%eax
  80275d:	3c 09                	cmp    $0x9,%al
  80275f:	77 08                	ja     802769 <strtol+0x86>
			dig = *s - '0';
  802761:	0f be c9             	movsbl %cl,%ecx
  802764:	83 e9 30             	sub    $0x30,%ecx
  802767:	eb 20                	jmp    802789 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  802769:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80276c:	89 f0                	mov    %esi,%eax
  80276e:	3c 19                	cmp    $0x19,%al
  802770:	77 08                	ja     80277a <strtol+0x97>
			dig = *s - 'a' + 10;
  802772:	0f be c9             	movsbl %cl,%ecx
  802775:	83 e9 57             	sub    $0x57,%ecx
  802778:	eb 0f                	jmp    802789 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80277a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80277d:	89 f0                	mov    %esi,%eax
  80277f:	3c 19                	cmp    $0x19,%al
  802781:	77 16                	ja     802799 <strtol+0xb6>
			dig = *s - 'A' + 10;
  802783:	0f be c9             	movsbl %cl,%ecx
  802786:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802789:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80278c:	7d 0f                	jge    80279d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80278e:	83 c2 01             	add    $0x1,%edx
  802791:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  802795:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  802797:	eb bc                	jmp    802755 <strtol+0x72>
  802799:	89 d8                	mov    %ebx,%eax
  80279b:	eb 02                	jmp    80279f <strtol+0xbc>
  80279d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80279f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8027a3:	74 05                	je     8027aa <strtol+0xc7>
		*endptr = (char *) s;
  8027a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027a8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8027aa:	f7 d8                	neg    %eax
  8027ac:	85 ff                	test   %edi,%edi
  8027ae:	0f 44 c3             	cmove  %ebx,%eax
}
  8027b1:	5b                   	pop    %ebx
  8027b2:	5e                   	pop    %esi
  8027b3:	5f                   	pop    %edi
  8027b4:	5d                   	pop    %ebp
  8027b5:	c3                   	ret    

008027b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8027b6:	55                   	push   %ebp
  8027b7:	89 e5                	mov    %esp,%ebp
  8027b9:	57                   	push   %edi
  8027ba:	56                   	push   %esi
  8027bb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8027bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8027c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8027c7:	89 c3                	mov    %eax,%ebx
  8027c9:	89 c7                	mov    %eax,%edi
  8027cb:	89 c6                	mov    %eax,%esi
  8027cd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8027cf:	5b                   	pop    %ebx
  8027d0:	5e                   	pop    %esi
  8027d1:	5f                   	pop    %edi
  8027d2:	5d                   	pop    %ebp
  8027d3:	c3                   	ret    

008027d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8027d4:	55                   	push   %ebp
  8027d5:	89 e5                	mov    %esp,%ebp
  8027d7:	57                   	push   %edi
  8027d8:	56                   	push   %esi
  8027d9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8027da:	ba 00 00 00 00       	mov    $0x0,%edx
  8027df:	b8 01 00 00 00       	mov    $0x1,%eax
  8027e4:	89 d1                	mov    %edx,%ecx
  8027e6:	89 d3                	mov    %edx,%ebx
  8027e8:	89 d7                	mov    %edx,%edi
  8027ea:	89 d6                	mov    %edx,%esi
  8027ec:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8027ee:	5b                   	pop    %ebx
  8027ef:	5e                   	pop    %esi
  8027f0:	5f                   	pop    %edi
  8027f1:	5d                   	pop    %ebp
  8027f2:	c3                   	ret    

008027f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8027f3:	55                   	push   %ebp
  8027f4:	89 e5                	mov    %esp,%ebp
  8027f6:	57                   	push   %edi
  8027f7:	56                   	push   %esi
  8027f8:	53                   	push   %ebx
  8027f9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8027fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  802801:	b8 03 00 00 00       	mov    $0x3,%eax
  802806:	8b 55 08             	mov    0x8(%ebp),%edx
  802809:	89 cb                	mov    %ecx,%ebx
  80280b:	89 cf                	mov    %ecx,%edi
  80280d:	89 ce                	mov    %ecx,%esi
  80280f:	cd 30                	int    $0x30
	if(check && ret > 0)
  802811:	85 c0                	test   %eax,%eax
  802813:	7e 28                	jle    80283d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802815:	89 44 24 10          	mov    %eax,0x10(%esp)
  802819:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802820:	00 
  802821:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  802828:	00 
  802829:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802830:	00 
  802831:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  802838:	e8 0b f5 ff ff       	call   801d48 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80283d:	83 c4 2c             	add    $0x2c,%esp
  802840:	5b                   	pop    %ebx
  802841:	5e                   	pop    %esi
  802842:	5f                   	pop    %edi
  802843:	5d                   	pop    %ebp
  802844:	c3                   	ret    

00802845 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802845:	55                   	push   %ebp
  802846:	89 e5                	mov    %esp,%ebp
  802848:	57                   	push   %edi
  802849:	56                   	push   %esi
  80284a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80284b:	ba 00 00 00 00       	mov    $0x0,%edx
  802850:	b8 02 00 00 00       	mov    $0x2,%eax
  802855:	89 d1                	mov    %edx,%ecx
  802857:	89 d3                	mov    %edx,%ebx
  802859:	89 d7                	mov    %edx,%edi
  80285b:	89 d6                	mov    %edx,%esi
  80285d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80285f:	5b                   	pop    %ebx
  802860:	5e                   	pop    %esi
  802861:	5f                   	pop    %edi
  802862:	5d                   	pop    %ebp
  802863:	c3                   	ret    

00802864 <sys_yield>:

void
sys_yield(void)
{
  802864:	55                   	push   %ebp
  802865:	89 e5                	mov    %esp,%ebp
  802867:	57                   	push   %edi
  802868:	56                   	push   %esi
  802869:	53                   	push   %ebx
	asm volatile("int %1\n"
  80286a:	ba 00 00 00 00       	mov    $0x0,%edx
  80286f:	b8 0b 00 00 00       	mov    $0xb,%eax
  802874:	89 d1                	mov    %edx,%ecx
  802876:	89 d3                	mov    %edx,%ebx
  802878:	89 d7                	mov    %edx,%edi
  80287a:	89 d6                	mov    %edx,%esi
  80287c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80287e:	5b                   	pop    %ebx
  80287f:	5e                   	pop    %esi
  802880:	5f                   	pop    %edi
  802881:	5d                   	pop    %ebp
  802882:	c3                   	ret    

00802883 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802883:	55                   	push   %ebp
  802884:	89 e5                	mov    %esp,%ebp
  802886:	57                   	push   %edi
  802887:	56                   	push   %esi
  802888:	53                   	push   %ebx
  802889:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80288c:	be 00 00 00 00       	mov    $0x0,%esi
  802891:	b8 04 00 00 00       	mov    $0x4,%eax
  802896:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802899:	8b 55 08             	mov    0x8(%ebp),%edx
  80289c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80289f:	89 f7                	mov    %esi,%edi
  8028a1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8028a3:	85 c0                	test   %eax,%eax
  8028a5:	7e 28                	jle    8028cf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028ab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8028b2:	00 
  8028b3:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  8028ba:	00 
  8028bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8028c2:	00 
  8028c3:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  8028ca:	e8 79 f4 ff ff       	call   801d48 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8028cf:	83 c4 2c             	add    $0x2c,%esp
  8028d2:	5b                   	pop    %ebx
  8028d3:	5e                   	pop    %esi
  8028d4:	5f                   	pop    %edi
  8028d5:	5d                   	pop    %ebp
  8028d6:	c3                   	ret    

008028d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8028d7:	55                   	push   %ebp
  8028d8:	89 e5                	mov    %esp,%ebp
  8028da:	57                   	push   %edi
  8028db:	56                   	push   %esi
  8028dc:	53                   	push   %ebx
  8028dd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8028e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8028e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8028eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8028f1:	8b 75 18             	mov    0x18(%ebp),%esi
  8028f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8028f6:	85 c0                	test   %eax,%eax
  8028f8:	7e 28                	jle    802922 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028fe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802905:	00 
  802906:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  80290d:	00 
  80290e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802915:	00 
  802916:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  80291d:	e8 26 f4 ff ff       	call   801d48 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802922:	83 c4 2c             	add    $0x2c,%esp
  802925:	5b                   	pop    %ebx
  802926:	5e                   	pop    %esi
  802927:	5f                   	pop    %edi
  802928:	5d                   	pop    %ebp
  802929:	c3                   	ret    

0080292a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80292a:	55                   	push   %ebp
  80292b:	89 e5                	mov    %esp,%ebp
  80292d:	57                   	push   %edi
  80292e:	56                   	push   %esi
  80292f:	53                   	push   %ebx
  802930:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  802933:	bb 00 00 00 00       	mov    $0x0,%ebx
  802938:	b8 06 00 00 00       	mov    $0x6,%eax
  80293d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802940:	8b 55 08             	mov    0x8(%ebp),%edx
  802943:	89 df                	mov    %ebx,%edi
  802945:	89 de                	mov    %ebx,%esi
  802947:	cd 30                	int    $0x30
	if(check && ret > 0)
  802949:	85 c0                	test   %eax,%eax
  80294b:	7e 28                	jle    802975 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80294d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802951:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802958:	00 
  802959:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  802960:	00 
  802961:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802968:	00 
  802969:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  802970:	e8 d3 f3 ff ff       	call   801d48 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802975:	83 c4 2c             	add    $0x2c,%esp
  802978:	5b                   	pop    %ebx
  802979:	5e                   	pop    %esi
  80297a:	5f                   	pop    %edi
  80297b:	5d                   	pop    %ebp
  80297c:	c3                   	ret    

0080297d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80297d:	55                   	push   %ebp
  80297e:	89 e5                	mov    %esp,%ebp
  802980:	57                   	push   %edi
  802981:	56                   	push   %esi
  802982:	53                   	push   %ebx
  802983:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  802986:	bb 00 00 00 00       	mov    $0x0,%ebx
  80298b:	b8 08 00 00 00       	mov    $0x8,%eax
  802990:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802993:	8b 55 08             	mov    0x8(%ebp),%edx
  802996:	89 df                	mov    %ebx,%edi
  802998:	89 de                	mov    %ebx,%esi
  80299a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80299c:	85 c0                	test   %eax,%eax
  80299e:	7e 28                	jle    8029c8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8029a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029a4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8029ab:	00 
  8029ac:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  8029b3:	00 
  8029b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8029bb:	00 
  8029bc:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  8029c3:	e8 80 f3 ff ff       	call   801d48 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8029c8:	83 c4 2c             	add    $0x2c,%esp
  8029cb:	5b                   	pop    %ebx
  8029cc:	5e                   	pop    %esi
  8029cd:	5f                   	pop    %edi
  8029ce:	5d                   	pop    %ebp
  8029cf:	c3                   	ret    

008029d0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8029d0:	55                   	push   %ebp
  8029d1:	89 e5                	mov    %esp,%ebp
  8029d3:	57                   	push   %edi
  8029d4:	56                   	push   %esi
  8029d5:	53                   	push   %ebx
  8029d6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8029d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029de:	b8 09 00 00 00       	mov    $0x9,%eax
  8029e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8029e9:	89 df                	mov    %ebx,%edi
  8029eb:	89 de                	mov    %ebx,%esi
  8029ed:	cd 30                	int    $0x30
	if(check && ret > 0)
  8029ef:	85 c0                	test   %eax,%eax
  8029f1:	7e 28                	jle    802a1b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8029f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029f7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8029fe:	00 
  8029ff:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  802a06:	00 
  802a07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a0e:	00 
  802a0f:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  802a16:	e8 2d f3 ff ff       	call   801d48 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802a1b:	83 c4 2c             	add    $0x2c,%esp
  802a1e:	5b                   	pop    %ebx
  802a1f:	5e                   	pop    %esi
  802a20:	5f                   	pop    %edi
  802a21:	5d                   	pop    %ebp
  802a22:	c3                   	ret    

00802a23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802a23:	55                   	push   %ebp
  802a24:	89 e5                	mov    %esp,%ebp
  802a26:	57                   	push   %edi
  802a27:	56                   	push   %esi
  802a28:	53                   	push   %ebx
  802a29:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  802a2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a31:	b8 0a 00 00 00       	mov    $0xa,%eax
  802a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a39:	8b 55 08             	mov    0x8(%ebp),%edx
  802a3c:	89 df                	mov    %ebx,%edi
  802a3e:	89 de                	mov    %ebx,%esi
  802a40:	cd 30                	int    $0x30
	if(check && ret > 0)
  802a42:	85 c0                	test   %eax,%eax
  802a44:	7e 28                	jle    802a6e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a46:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a4a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802a51:	00 
  802a52:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  802a59:	00 
  802a5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a61:	00 
  802a62:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  802a69:	e8 da f2 ff ff       	call   801d48 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802a6e:	83 c4 2c             	add    $0x2c,%esp
  802a71:	5b                   	pop    %ebx
  802a72:	5e                   	pop    %esi
  802a73:	5f                   	pop    %edi
  802a74:	5d                   	pop    %ebp
  802a75:	c3                   	ret    

00802a76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802a76:	55                   	push   %ebp
  802a77:	89 e5                	mov    %esp,%ebp
  802a79:	57                   	push   %edi
  802a7a:	56                   	push   %esi
  802a7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  802a7c:	be 00 00 00 00       	mov    $0x0,%esi
  802a81:	b8 0c 00 00 00       	mov    $0xc,%eax
  802a86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a89:	8b 55 08             	mov    0x8(%ebp),%edx
  802a8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802a8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  802a92:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802a94:	5b                   	pop    %ebx
  802a95:	5e                   	pop    %esi
  802a96:	5f                   	pop    %edi
  802a97:	5d                   	pop    %ebp
  802a98:	c3                   	ret    

00802a99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802a99:	55                   	push   %ebp
  802a9a:	89 e5                	mov    %esp,%ebp
  802a9c:	57                   	push   %edi
  802a9d:	56                   	push   %esi
  802a9e:	53                   	push   %ebx
  802a9f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  802aa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  802aa7:	b8 0d 00 00 00       	mov    $0xd,%eax
  802aac:	8b 55 08             	mov    0x8(%ebp),%edx
  802aaf:	89 cb                	mov    %ecx,%ebx
  802ab1:	89 cf                	mov    %ecx,%edi
  802ab3:	89 ce                	mov    %ecx,%esi
  802ab5:	cd 30                	int    $0x30
	if(check && ret > 0)
  802ab7:	85 c0                	test   %eax,%eax
  802ab9:	7e 28                	jle    802ae3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802abb:	89 44 24 10          	mov    %eax,0x10(%esp)
  802abf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802ac6:	00 
  802ac7:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  802ace:	00 
  802acf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802ad6:	00 
  802ad7:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  802ade:	e8 65 f2 ff ff       	call   801d48 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802ae3:	83 c4 2c             	add    $0x2c,%esp
  802ae6:	5b                   	pop    %ebx
  802ae7:	5e                   	pop    %esi
  802ae8:	5f                   	pop    %edi
  802ae9:	5d                   	pop    %ebp
  802aea:	c3                   	ret    

00802aeb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802aeb:	55                   	push   %ebp
  802aec:	89 e5                	mov    %esp,%ebp
  802aee:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  802af1:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  802af8:	75 70                	jne    802b6a <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  802afa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802b01:	00 
  802b02:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802b09:	ee 
  802b0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b11:	e8 6d fd ff ff       	call   802883 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  802b16:	85 c0                	test   %eax,%eax
  802b18:	79 1c                	jns    802b36 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  802b1a:	c7 44 24 08 2c 46 80 	movl   $0x80462c,0x8(%esp)
  802b21:	00 
  802b22:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  802b29:	00 
  802b2a:	c7 04 24 87 46 80 00 	movl   $0x804687,(%esp)
  802b31:	e8 12 f2 ff ff       	call   801d48 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  802b36:	c7 44 24 04 74 2b 80 	movl   $0x802b74,0x4(%esp)
  802b3d:	00 
  802b3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b45:	e8 d9 fe ff ff       	call   802a23 <sys_env_set_pgfault_upcall>
        if(r < 0)
  802b4a:	85 c0                	test   %eax,%eax
  802b4c:	79 1c                	jns    802b6a <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  802b4e:	c7 44 24 08 54 46 80 	movl   $0x804654,0x8(%esp)
  802b55:	00 
  802b56:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  802b5d:	00 
  802b5e:	c7 04 24 87 46 80 00 	movl   $0x804687,(%esp)
  802b65:	e8 de f1 ff ff       	call   801d48 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  802b6d:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  802b72:	c9                   	leave  
  802b73:	c3                   	ret    

00802b74 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b74:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b75:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802b7a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b7c:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  802b7f:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  802b83:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  802b87:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  802b89:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  802b8b:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  802b8c:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  802b8f:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  802b91:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  802b94:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  802b95:	83 c4 04             	add    $0x4,%esp
    popf;
  802b98:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  802b99:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  802b9a:	c3                   	ret    
  802b9b:	66 90                	xchg   %ax,%ax
  802b9d:	66 90                	xchg   %ax,%ax
  802b9f:	90                   	nop

00802ba0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802ba0:	55                   	push   %ebp
  802ba1:	89 e5                	mov    %esp,%ebp
  802ba3:	56                   	push   %esi
  802ba4:	53                   	push   %ebx
  802ba5:	83 ec 10             	sub    $0x10,%esp
  802ba8:	8b 75 08             	mov    0x8(%ebp),%esi
  802bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bae:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  802bb1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  802bb3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802bb8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  802bbb:	89 04 24             	mov    %eax,(%esp)
  802bbe:	e8 d6 fe ff ff       	call   802a99 <sys_ipc_recv>
    if(r < 0){
  802bc3:	85 c0                	test   %eax,%eax
  802bc5:	79 16                	jns    802bdd <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  802bc7:	85 f6                	test   %esi,%esi
  802bc9:	74 06                	je     802bd1 <ipc_recv+0x31>
            *from_env_store = 0;
  802bcb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  802bd1:	85 db                	test   %ebx,%ebx
  802bd3:	74 2c                	je     802c01 <ipc_recv+0x61>
            *perm_store = 0;
  802bd5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802bdb:	eb 24                	jmp    802c01 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  802bdd:	85 f6                	test   %esi,%esi
  802bdf:	74 0a                	je     802beb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  802be1:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802be6:	8b 40 74             	mov    0x74(%eax),%eax
  802be9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  802beb:	85 db                	test   %ebx,%ebx
  802bed:	74 0a                	je     802bf9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  802bef:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802bf4:	8b 40 78             	mov    0x78(%eax),%eax
  802bf7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802bf9:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802bfe:	8b 40 70             	mov    0x70(%eax),%eax
}
  802c01:	83 c4 10             	add    $0x10,%esp
  802c04:	5b                   	pop    %ebx
  802c05:	5e                   	pop    %esi
  802c06:	5d                   	pop    %ebp
  802c07:	c3                   	ret    

00802c08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802c08:	55                   	push   %ebp
  802c09:	89 e5                	mov    %esp,%ebp
  802c0b:	57                   	push   %edi
  802c0c:	56                   	push   %esi
  802c0d:	53                   	push   %ebx
  802c0e:	83 ec 1c             	sub    $0x1c,%esp
  802c11:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c14:	8b 75 0c             	mov    0xc(%ebp),%esi
  802c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  802c1a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  802c1c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802c21:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802c24:	8b 45 14             	mov    0x14(%ebp),%eax
  802c27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c33:	89 3c 24             	mov    %edi,(%esp)
  802c36:	e8 3b fe ff ff       	call   802a76 <sys_ipc_try_send>
        if(r == 0){
  802c3b:	85 c0                	test   %eax,%eax
  802c3d:	74 28                	je     802c67 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  802c3f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802c42:	74 1c                	je     802c60 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  802c44:	c7 44 24 08 95 46 80 	movl   $0x804695,0x8(%esp)
  802c4b:	00 
  802c4c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802c53:	00 
  802c54:	c7 04 24 ac 46 80 00 	movl   $0x8046ac,(%esp)
  802c5b:	e8 e8 f0 ff ff       	call   801d48 <_panic>
        }
        sys_yield();
  802c60:	e8 ff fb ff ff       	call   802864 <sys_yield>
    }
  802c65:	eb bd                	jmp    802c24 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802c67:	83 c4 1c             	add    $0x1c,%esp
  802c6a:	5b                   	pop    %ebx
  802c6b:	5e                   	pop    %esi
  802c6c:	5f                   	pop    %edi
  802c6d:	5d                   	pop    %ebp
  802c6e:	c3                   	ret    

00802c6f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c6f:	55                   	push   %ebp
  802c70:	89 e5                	mov    %esp,%ebp
  802c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802c75:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802c7a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802c7d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c83:	8b 52 50             	mov    0x50(%edx),%edx
  802c86:	39 ca                	cmp    %ecx,%edx
  802c88:	75 0d                	jne    802c97 <ipc_find_env+0x28>
			return envs[i].env_id;
  802c8a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802c8d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802c92:	8b 40 40             	mov    0x40(%eax),%eax
  802c95:	eb 0e                	jmp    802ca5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  802c97:	83 c0 01             	add    $0x1,%eax
  802c9a:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c9f:	75 d9                	jne    802c7a <ipc_find_env+0xb>
	return 0;
  802ca1:	66 b8 00 00          	mov    $0x0,%ax
}
  802ca5:	5d                   	pop    %ebp
  802ca6:	c3                   	ret    
  802ca7:	66 90                	xchg   %ax,%ax
  802ca9:	66 90                	xchg   %ax,%ax
  802cab:	66 90                	xchg   %ax,%ax
  802cad:	66 90                	xchg   %ax,%ax
  802caf:	90                   	nop

00802cb0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802cb0:	55                   	push   %ebp
  802cb1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  802cb6:	05 00 00 00 30       	add    $0x30000000,%eax
  802cbb:	c1 e8 0c             	shr    $0xc,%eax
}
  802cbe:	5d                   	pop    %ebp
  802cbf:	c3                   	ret    

00802cc0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802cc0:	55                   	push   %ebp
  802cc1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  802cc6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  802ccb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802cd0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802cd5:	5d                   	pop    %ebp
  802cd6:	c3                   	ret    

00802cd7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802cd7:	55                   	push   %ebp
  802cd8:	89 e5                	mov    %esp,%ebp
  802cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802cdd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802ce2:	89 c2                	mov    %eax,%edx
  802ce4:	c1 ea 16             	shr    $0x16,%edx
  802ce7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802cee:	f6 c2 01             	test   $0x1,%dl
  802cf1:	74 11                	je     802d04 <fd_alloc+0x2d>
  802cf3:	89 c2                	mov    %eax,%edx
  802cf5:	c1 ea 0c             	shr    $0xc,%edx
  802cf8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802cff:	f6 c2 01             	test   $0x1,%dl
  802d02:	75 09                	jne    802d0d <fd_alloc+0x36>
			*fd_store = fd;
  802d04:	89 01                	mov    %eax,(%ecx)
			return 0;
  802d06:	b8 00 00 00 00       	mov    $0x0,%eax
  802d0b:	eb 17                	jmp    802d24 <fd_alloc+0x4d>
  802d0d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  802d12:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802d17:	75 c9                	jne    802ce2 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  802d19:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802d1f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802d24:	5d                   	pop    %ebp
  802d25:	c3                   	ret    

00802d26 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802d26:	55                   	push   %ebp
  802d27:	89 e5                	mov    %esp,%ebp
  802d29:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802d2c:	83 f8 1f             	cmp    $0x1f,%eax
  802d2f:	77 36                	ja     802d67 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802d31:	c1 e0 0c             	shl    $0xc,%eax
  802d34:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802d39:	89 c2                	mov    %eax,%edx
  802d3b:	c1 ea 16             	shr    $0x16,%edx
  802d3e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802d45:	f6 c2 01             	test   $0x1,%dl
  802d48:	74 24                	je     802d6e <fd_lookup+0x48>
  802d4a:	89 c2                	mov    %eax,%edx
  802d4c:	c1 ea 0c             	shr    $0xc,%edx
  802d4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802d56:	f6 c2 01             	test   $0x1,%dl
  802d59:	74 1a                	je     802d75 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802d5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d5e:	89 02                	mov    %eax,(%edx)
	return 0;
  802d60:	b8 00 00 00 00       	mov    $0x0,%eax
  802d65:	eb 13                	jmp    802d7a <fd_lookup+0x54>
		return -E_INVAL;
  802d67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d6c:	eb 0c                	jmp    802d7a <fd_lookup+0x54>
		return -E_INVAL;
  802d6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d73:	eb 05                	jmp    802d7a <fd_lookup+0x54>
  802d75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802d7a:	5d                   	pop    %ebp
  802d7b:	c3                   	ret    

00802d7c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802d7c:	55                   	push   %ebp
  802d7d:	89 e5                	mov    %esp,%ebp
  802d7f:	83 ec 18             	sub    $0x18,%esp
  802d82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d85:	ba 38 47 80 00       	mov    $0x804738,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802d8a:	eb 13                	jmp    802d9f <dev_lookup+0x23>
  802d8c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802d8f:	39 08                	cmp    %ecx,(%eax)
  802d91:	75 0c                	jne    802d9f <dev_lookup+0x23>
			*dev = devtab[i];
  802d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d96:	89 01                	mov    %eax,(%ecx)
			return 0;
  802d98:	b8 00 00 00 00       	mov    $0x0,%eax
  802d9d:	eb 30                	jmp    802dcf <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  802d9f:	8b 02                	mov    (%edx),%eax
  802da1:	85 c0                	test   %eax,%eax
  802da3:	75 e7                	jne    802d8c <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802da5:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802daa:	8b 40 48             	mov    0x48(%eax),%eax
  802dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  802db5:	c7 04 24 b8 46 80 00 	movl   $0x8046b8,(%esp)
  802dbc:	e8 80 f0 ff ff       	call   801e41 <cprintf>
	*dev = 0;
  802dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  802dc4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802dca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802dcf:	c9                   	leave  
  802dd0:	c3                   	ret    

00802dd1 <fd_close>:
{
  802dd1:	55                   	push   %ebp
  802dd2:	89 e5                	mov    %esp,%ebp
  802dd4:	56                   	push   %esi
  802dd5:	53                   	push   %ebx
  802dd6:	83 ec 20             	sub    $0x20,%esp
  802dd9:	8b 75 08             	mov    0x8(%ebp),%esi
  802ddc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802ddf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802de2:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802de6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802dec:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802def:	89 04 24             	mov    %eax,(%esp)
  802df2:	e8 2f ff ff ff       	call   802d26 <fd_lookup>
  802df7:	85 c0                	test   %eax,%eax
  802df9:	78 05                	js     802e00 <fd_close+0x2f>
	    || fd != fd2)
  802dfb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802dfe:	74 0c                	je     802e0c <fd_close+0x3b>
		return (must_exist ? r : 0);
  802e00:	84 db                	test   %bl,%bl
  802e02:	ba 00 00 00 00       	mov    $0x0,%edx
  802e07:	0f 44 c2             	cmove  %edx,%eax
  802e0a:	eb 3f                	jmp    802e4b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802e0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e13:	8b 06                	mov    (%esi),%eax
  802e15:	89 04 24             	mov    %eax,(%esp)
  802e18:	e8 5f ff ff ff       	call   802d7c <dev_lookup>
  802e1d:	89 c3                	mov    %eax,%ebx
  802e1f:	85 c0                	test   %eax,%eax
  802e21:	78 16                	js     802e39 <fd_close+0x68>
		if (dev->dev_close)
  802e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e26:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  802e29:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  802e2e:	85 c0                	test   %eax,%eax
  802e30:	74 07                	je     802e39 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  802e32:	89 34 24             	mov    %esi,(%esp)
  802e35:	ff d0                	call   *%eax
  802e37:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  802e39:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e44:	e8 e1 fa ff ff       	call   80292a <sys_page_unmap>
	return r;
  802e49:	89 d8                	mov    %ebx,%eax
}
  802e4b:	83 c4 20             	add    $0x20,%esp
  802e4e:	5b                   	pop    %ebx
  802e4f:	5e                   	pop    %esi
  802e50:	5d                   	pop    %ebp
  802e51:	c3                   	ret    

00802e52 <close>:

int
close(int fdnum)
{
  802e52:	55                   	push   %ebp
  802e53:	89 e5                	mov    %esp,%ebp
  802e55:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  802e62:	89 04 24             	mov    %eax,(%esp)
  802e65:	e8 bc fe ff ff       	call   802d26 <fd_lookup>
  802e6a:	89 c2                	mov    %eax,%edx
  802e6c:	85 d2                	test   %edx,%edx
  802e6e:	78 13                	js     802e83 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  802e70:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802e77:	00 
  802e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e7b:	89 04 24             	mov    %eax,(%esp)
  802e7e:	e8 4e ff ff ff       	call   802dd1 <fd_close>
}
  802e83:	c9                   	leave  
  802e84:	c3                   	ret    

00802e85 <close_all>:

void
close_all(void)
{
  802e85:	55                   	push   %ebp
  802e86:	89 e5                	mov    %esp,%ebp
  802e88:	53                   	push   %ebx
  802e89:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802e91:	89 1c 24             	mov    %ebx,(%esp)
  802e94:	e8 b9 ff ff ff       	call   802e52 <close>
	for (i = 0; i < MAXFD; i++)
  802e99:	83 c3 01             	add    $0x1,%ebx
  802e9c:	83 fb 20             	cmp    $0x20,%ebx
  802e9f:	75 f0                	jne    802e91 <close_all+0xc>
}
  802ea1:	83 c4 14             	add    $0x14,%esp
  802ea4:	5b                   	pop    %ebx
  802ea5:	5d                   	pop    %ebp
  802ea6:	c3                   	ret    

00802ea7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802ea7:	55                   	push   %ebp
  802ea8:	89 e5                	mov    %esp,%ebp
  802eaa:	57                   	push   %edi
  802eab:	56                   	push   %esi
  802eac:	53                   	push   %ebx
  802ead:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802eb0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  802eba:	89 04 24             	mov    %eax,(%esp)
  802ebd:	e8 64 fe ff ff       	call   802d26 <fd_lookup>
  802ec2:	89 c2                	mov    %eax,%edx
  802ec4:	85 d2                	test   %edx,%edx
  802ec6:	0f 88 e1 00 00 00    	js     802fad <dup+0x106>
		return r;
	close(newfdnum);
  802ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ecf:	89 04 24             	mov    %eax,(%esp)
  802ed2:	e8 7b ff ff ff       	call   802e52 <close>

	newfd = INDEX2FD(newfdnum);
  802ed7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802eda:	c1 e3 0c             	shl    $0xc,%ebx
  802edd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ee6:	89 04 24             	mov    %eax,(%esp)
  802ee9:	e8 d2 fd ff ff       	call   802cc0 <fd2data>
  802eee:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  802ef0:	89 1c 24             	mov    %ebx,(%esp)
  802ef3:	e8 c8 fd ff ff       	call   802cc0 <fd2data>
  802ef8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802efa:	89 f0                	mov    %esi,%eax
  802efc:	c1 e8 16             	shr    $0x16,%eax
  802eff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802f06:	a8 01                	test   $0x1,%al
  802f08:	74 43                	je     802f4d <dup+0xa6>
  802f0a:	89 f0                	mov    %esi,%eax
  802f0c:	c1 e8 0c             	shr    $0xc,%eax
  802f0f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802f16:	f6 c2 01             	test   $0x1,%dl
  802f19:	74 32                	je     802f4d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802f1b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802f22:	25 07 0e 00 00       	and    $0xe07,%eax
  802f27:	89 44 24 10          	mov    %eax,0x10(%esp)
  802f2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802f2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f36:	00 
  802f37:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f42:	e8 90 f9 ff ff       	call   8028d7 <sys_page_map>
  802f47:	89 c6                	mov    %eax,%esi
  802f49:	85 c0                	test   %eax,%eax
  802f4b:	78 3e                	js     802f8b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802f4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f50:	89 c2                	mov    %eax,%edx
  802f52:	c1 ea 0c             	shr    $0xc,%edx
  802f55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802f5c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802f62:	89 54 24 10          	mov    %edx,0x10(%esp)
  802f66:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802f6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f71:	00 
  802f72:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f7d:	e8 55 f9 ff ff       	call   8028d7 <sys_page_map>
  802f82:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  802f84:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802f87:	85 f6                	test   %esi,%esi
  802f89:	79 22                	jns    802fad <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  802f8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802f8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f96:	e8 8f f9 ff ff       	call   80292a <sys_page_unmap>
	sys_page_unmap(0, nva);
  802f9b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802f9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fa6:	e8 7f f9 ff ff       	call   80292a <sys_page_unmap>
	return r;
  802fab:	89 f0                	mov    %esi,%eax
}
  802fad:	83 c4 3c             	add    $0x3c,%esp
  802fb0:	5b                   	pop    %ebx
  802fb1:	5e                   	pop    %esi
  802fb2:	5f                   	pop    %edi
  802fb3:	5d                   	pop    %ebp
  802fb4:	c3                   	ret    

00802fb5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802fb5:	55                   	push   %ebp
  802fb6:	89 e5                	mov    %esp,%ebp
  802fb8:	53                   	push   %ebx
  802fb9:	83 ec 24             	sub    $0x24,%esp
  802fbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802fbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fc6:	89 1c 24             	mov    %ebx,(%esp)
  802fc9:	e8 58 fd ff ff       	call   802d26 <fd_lookup>
  802fce:	89 c2                	mov    %eax,%edx
  802fd0:	85 d2                	test   %edx,%edx
  802fd2:	78 6d                	js     803041 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fde:	8b 00                	mov    (%eax),%eax
  802fe0:	89 04 24             	mov    %eax,(%esp)
  802fe3:	e8 94 fd ff ff       	call   802d7c <dev_lookup>
  802fe8:	85 c0                	test   %eax,%eax
  802fea:	78 55                	js     803041 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802fec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fef:	8b 50 08             	mov    0x8(%eax),%edx
  802ff2:	83 e2 03             	and    $0x3,%edx
  802ff5:	83 fa 01             	cmp    $0x1,%edx
  802ff8:	75 23                	jne    80301d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802ffa:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802fff:	8b 40 48             	mov    0x48(%eax),%eax
  803002:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803006:	89 44 24 04          	mov    %eax,0x4(%esp)
  80300a:	c7 04 24 fc 46 80 00 	movl   $0x8046fc,(%esp)
  803011:	e8 2b ee ff ff       	call   801e41 <cprintf>
		return -E_INVAL;
  803016:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80301b:	eb 24                	jmp    803041 <read+0x8c>
	}
	if (!dev->dev_read)
  80301d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803020:	8b 52 08             	mov    0x8(%edx),%edx
  803023:	85 d2                	test   %edx,%edx
  803025:	74 15                	je     80303c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  803027:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80302a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80302e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803031:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803035:	89 04 24             	mov    %eax,(%esp)
  803038:	ff d2                	call   *%edx
  80303a:	eb 05                	jmp    803041 <read+0x8c>
		return -E_NOT_SUPP;
  80303c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  803041:	83 c4 24             	add    $0x24,%esp
  803044:	5b                   	pop    %ebx
  803045:	5d                   	pop    %ebp
  803046:	c3                   	ret    

00803047 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  803047:	55                   	push   %ebp
  803048:	89 e5                	mov    %esp,%ebp
  80304a:	57                   	push   %edi
  80304b:	56                   	push   %esi
  80304c:	53                   	push   %ebx
  80304d:	83 ec 1c             	sub    $0x1c,%esp
  803050:	8b 7d 08             	mov    0x8(%ebp),%edi
  803053:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803056:	bb 00 00 00 00       	mov    $0x0,%ebx
  80305b:	eb 23                	jmp    803080 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80305d:	89 f0                	mov    %esi,%eax
  80305f:	29 d8                	sub    %ebx,%eax
  803061:	89 44 24 08          	mov    %eax,0x8(%esp)
  803065:	89 d8                	mov    %ebx,%eax
  803067:	03 45 0c             	add    0xc(%ebp),%eax
  80306a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80306e:	89 3c 24             	mov    %edi,(%esp)
  803071:	e8 3f ff ff ff       	call   802fb5 <read>
		if (m < 0)
  803076:	85 c0                	test   %eax,%eax
  803078:	78 10                	js     80308a <readn+0x43>
			return m;
		if (m == 0)
  80307a:	85 c0                	test   %eax,%eax
  80307c:	74 0a                	je     803088 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80307e:	01 c3                	add    %eax,%ebx
  803080:	39 f3                	cmp    %esi,%ebx
  803082:	72 d9                	jb     80305d <readn+0x16>
  803084:	89 d8                	mov    %ebx,%eax
  803086:	eb 02                	jmp    80308a <readn+0x43>
  803088:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80308a:	83 c4 1c             	add    $0x1c,%esp
  80308d:	5b                   	pop    %ebx
  80308e:	5e                   	pop    %esi
  80308f:	5f                   	pop    %edi
  803090:	5d                   	pop    %ebp
  803091:	c3                   	ret    

00803092 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  803092:	55                   	push   %ebp
  803093:	89 e5                	mov    %esp,%ebp
  803095:	53                   	push   %ebx
  803096:	83 ec 24             	sub    $0x24,%esp
  803099:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80309c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80309f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030a3:	89 1c 24             	mov    %ebx,(%esp)
  8030a6:	e8 7b fc ff ff       	call   802d26 <fd_lookup>
  8030ab:	89 c2                	mov    %eax,%edx
  8030ad:	85 d2                	test   %edx,%edx
  8030af:	78 68                	js     803119 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030bb:	8b 00                	mov    (%eax),%eax
  8030bd:	89 04 24             	mov    %eax,(%esp)
  8030c0:	e8 b7 fc ff ff       	call   802d7c <dev_lookup>
  8030c5:	85 c0                	test   %eax,%eax
  8030c7:	78 50                	js     803119 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8030c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8030d0:	75 23                	jne    8030f5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8030d2:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8030d7:	8b 40 48             	mov    0x48(%eax),%eax
  8030da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030e2:	c7 04 24 18 47 80 00 	movl   $0x804718,(%esp)
  8030e9:	e8 53 ed ff ff       	call   801e41 <cprintf>
		return -E_INVAL;
  8030ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8030f3:	eb 24                	jmp    803119 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8030f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8030fb:	85 d2                	test   %edx,%edx
  8030fd:	74 15                	je     803114 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8030ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  803102:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803109:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80310d:	89 04 24             	mov    %eax,(%esp)
  803110:	ff d2                	call   *%edx
  803112:	eb 05                	jmp    803119 <write+0x87>
		return -E_NOT_SUPP;
  803114:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  803119:	83 c4 24             	add    $0x24,%esp
  80311c:	5b                   	pop    %ebx
  80311d:	5d                   	pop    %ebp
  80311e:	c3                   	ret    

0080311f <seek>:

int
seek(int fdnum, off_t offset)
{
  80311f:	55                   	push   %ebp
  803120:	89 e5                	mov    %esp,%ebp
  803122:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803125:	8d 45 fc             	lea    -0x4(%ebp),%eax
  803128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80312c:	8b 45 08             	mov    0x8(%ebp),%eax
  80312f:	89 04 24             	mov    %eax,(%esp)
  803132:	e8 ef fb ff ff       	call   802d26 <fd_lookup>
  803137:	85 c0                	test   %eax,%eax
  803139:	78 0e                	js     803149 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80313b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80313e:	8b 55 0c             	mov    0xc(%ebp),%edx
  803141:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  803144:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803149:	c9                   	leave  
  80314a:	c3                   	ret    

0080314b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80314b:	55                   	push   %ebp
  80314c:	89 e5                	mov    %esp,%ebp
  80314e:	53                   	push   %ebx
  80314f:	83 ec 24             	sub    $0x24,%esp
  803152:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803155:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80315c:	89 1c 24             	mov    %ebx,(%esp)
  80315f:	e8 c2 fb ff ff       	call   802d26 <fd_lookup>
  803164:	89 c2                	mov    %eax,%edx
  803166:	85 d2                	test   %edx,%edx
  803168:	78 61                	js     8031cb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80316a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80316d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803174:	8b 00                	mov    (%eax),%eax
  803176:	89 04 24             	mov    %eax,(%esp)
  803179:	e8 fe fb ff ff       	call   802d7c <dev_lookup>
  80317e:	85 c0                	test   %eax,%eax
  803180:	78 49                	js     8031cb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  803182:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803185:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803189:	75 23                	jne    8031ae <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80318b:	a1 10 a0 80 00       	mov    0x80a010,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  803190:	8b 40 48             	mov    0x48(%eax),%eax
  803193:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80319b:	c7 04 24 d8 46 80 00 	movl   $0x8046d8,(%esp)
  8031a2:	e8 9a ec ff ff       	call   801e41 <cprintf>
		return -E_INVAL;
  8031a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8031ac:	eb 1d                	jmp    8031cb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8031ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031b1:	8b 52 18             	mov    0x18(%edx),%edx
  8031b4:	85 d2                	test   %edx,%edx
  8031b6:	74 0e                	je     8031c6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8031b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8031bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8031bf:	89 04 24             	mov    %eax,(%esp)
  8031c2:	ff d2                	call   *%edx
  8031c4:	eb 05                	jmp    8031cb <ftruncate+0x80>
		return -E_NOT_SUPP;
  8031c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8031cb:	83 c4 24             	add    $0x24,%esp
  8031ce:	5b                   	pop    %ebx
  8031cf:	5d                   	pop    %ebp
  8031d0:	c3                   	ret    

008031d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8031d1:	55                   	push   %ebp
  8031d2:	89 e5                	mov    %esp,%ebp
  8031d4:	53                   	push   %ebx
  8031d5:	83 ec 24             	sub    $0x24,%esp
  8031d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8031db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8031e5:	89 04 24             	mov    %eax,(%esp)
  8031e8:	e8 39 fb ff ff       	call   802d26 <fd_lookup>
  8031ed:	89 c2                	mov    %eax,%edx
  8031ef:	85 d2                	test   %edx,%edx
  8031f1:	78 52                	js     803245 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8031f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031fd:	8b 00                	mov    (%eax),%eax
  8031ff:	89 04 24             	mov    %eax,(%esp)
  803202:	e8 75 fb ff ff       	call   802d7c <dev_lookup>
  803207:	85 c0                	test   %eax,%eax
  803209:	78 3a                	js     803245 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80320b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80320e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  803212:	74 2c                	je     803240 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  803214:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  803217:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80321e:	00 00 00 
	stat->st_isdir = 0;
  803221:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803228:	00 00 00 
	stat->st_dev = dev;
  80322b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  803231:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803235:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803238:	89 14 24             	mov    %edx,(%esp)
  80323b:	ff 50 14             	call   *0x14(%eax)
  80323e:	eb 05                	jmp    803245 <fstat+0x74>
		return -E_NOT_SUPP;
  803240:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  803245:	83 c4 24             	add    $0x24,%esp
  803248:	5b                   	pop    %ebx
  803249:	5d                   	pop    %ebp
  80324a:	c3                   	ret    

0080324b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80324b:	55                   	push   %ebp
  80324c:	89 e5                	mov    %esp,%ebp
  80324e:	56                   	push   %esi
  80324f:	53                   	push   %ebx
  803250:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  803253:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80325a:	00 
  80325b:	8b 45 08             	mov    0x8(%ebp),%eax
  80325e:	89 04 24             	mov    %eax,(%esp)
  803261:	e8 fb 01 00 00       	call   803461 <open>
  803266:	89 c3                	mov    %eax,%ebx
  803268:	85 db                	test   %ebx,%ebx
  80326a:	78 1b                	js     803287 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80326c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80326f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803273:	89 1c 24             	mov    %ebx,(%esp)
  803276:	e8 56 ff ff ff       	call   8031d1 <fstat>
  80327b:	89 c6                	mov    %eax,%esi
	close(fd);
  80327d:	89 1c 24             	mov    %ebx,(%esp)
  803280:	e8 cd fb ff ff       	call   802e52 <close>
	return r;
  803285:	89 f0                	mov    %esi,%eax
}
  803287:	83 c4 10             	add    $0x10,%esp
  80328a:	5b                   	pop    %ebx
  80328b:	5e                   	pop    %esi
  80328c:	5d                   	pop    %ebp
  80328d:	c3                   	ret    

0080328e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80328e:	55                   	push   %ebp
  80328f:	89 e5                	mov    %esp,%ebp
  803291:	56                   	push   %esi
  803292:	53                   	push   %ebx
  803293:	83 ec 10             	sub    $0x10,%esp
  803296:	89 c6                	mov    %eax,%esi
  803298:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80329a:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8032a1:	75 11                	jne    8032b4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8032a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8032aa:	e8 c0 f9 ff ff       	call   802c6f <ipc_find_env>
  8032af:	a3 04 a0 80 00       	mov    %eax,0x80a004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8032b4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8032bb:	00 
  8032bc:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  8032c3:	00 
  8032c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032c8:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8032cd:	89 04 24             	mov    %eax,(%esp)
  8032d0:	e8 33 f9 ff ff       	call   802c08 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8032d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8032dc:	00 
  8032dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8032e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8032e8:	e8 b3 f8 ff ff       	call   802ba0 <ipc_recv>
}
  8032ed:	83 c4 10             	add    $0x10,%esp
  8032f0:	5b                   	pop    %ebx
  8032f1:	5e                   	pop    %esi
  8032f2:	5d                   	pop    %ebp
  8032f3:	c3                   	ret    

008032f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8032f4:	55                   	push   %ebp
  8032f5:	89 e5                	mov    %esp,%ebp
  8032f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8032fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8032fd:	8b 40 0c             	mov    0xc(%eax),%eax
  803300:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  803305:	8b 45 0c             	mov    0xc(%ebp),%eax
  803308:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80330d:	ba 00 00 00 00       	mov    $0x0,%edx
  803312:	b8 02 00 00 00       	mov    $0x2,%eax
  803317:	e8 72 ff ff ff       	call   80328e <fsipc>
}
  80331c:	c9                   	leave  
  80331d:	c3                   	ret    

0080331e <devfile_flush>:
{
  80331e:	55                   	push   %ebp
  80331f:	89 e5                	mov    %esp,%ebp
  803321:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803324:	8b 45 08             	mov    0x8(%ebp),%eax
  803327:	8b 40 0c             	mov    0xc(%eax),%eax
  80332a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  80332f:	ba 00 00 00 00       	mov    $0x0,%edx
  803334:	b8 06 00 00 00       	mov    $0x6,%eax
  803339:	e8 50 ff ff ff       	call   80328e <fsipc>
}
  80333e:	c9                   	leave  
  80333f:	c3                   	ret    

00803340 <devfile_stat>:
{
  803340:	55                   	push   %ebp
  803341:	89 e5                	mov    %esp,%ebp
  803343:	53                   	push   %ebx
  803344:	83 ec 14             	sub    $0x14,%esp
  803347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80334a:	8b 45 08             	mov    0x8(%ebp),%eax
  80334d:	8b 40 0c             	mov    0xc(%eax),%eax
  803350:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803355:	ba 00 00 00 00       	mov    $0x0,%edx
  80335a:	b8 05 00 00 00       	mov    $0x5,%eax
  80335f:	e8 2a ff ff ff       	call   80328e <fsipc>
  803364:	89 c2                	mov    %eax,%edx
  803366:	85 d2                	test   %edx,%edx
  803368:	78 2b                	js     803395 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80336a:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803371:	00 
  803372:	89 1c 24             	mov    %ebx,(%esp)
  803375:	e8 ed f0 ff ff       	call   802467 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80337a:	a1 80 b0 80 00       	mov    0x80b080,%eax
  80337f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803385:	a1 84 b0 80 00       	mov    0x80b084,%eax
  80338a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  803390:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803395:	83 c4 14             	add    $0x14,%esp
  803398:	5b                   	pop    %ebx
  803399:	5d                   	pop    %ebp
  80339a:	c3                   	ret    

0080339b <devfile_write>:
{
  80339b:	55                   	push   %ebp
  80339c:	89 e5                	mov    %esp,%ebp
  80339e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  8033a1:	c7 44 24 08 48 47 80 	movl   $0x804748,0x8(%esp)
  8033a8:	00 
  8033a9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8033b0:	00 
  8033b1:	c7 04 24 66 47 80 00 	movl   $0x804766,(%esp)
  8033b8:	e8 8b e9 ff ff       	call   801d48 <_panic>

008033bd <devfile_read>:
{
  8033bd:	55                   	push   %ebp
  8033be:	89 e5                	mov    %esp,%ebp
  8033c0:	56                   	push   %esi
  8033c1:	53                   	push   %ebx
  8033c2:	83 ec 10             	sub    $0x10,%esp
  8033c5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8033c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8033cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8033ce:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8033d3:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8033d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8033de:	b8 03 00 00 00       	mov    $0x3,%eax
  8033e3:	e8 a6 fe ff ff       	call   80328e <fsipc>
  8033e8:	89 c3                	mov    %eax,%ebx
  8033ea:	85 c0                	test   %eax,%eax
  8033ec:	78 6a                	js     803458 <devfile_read+0x9b>
	assert(r <= n);
  8033ee:	39 c6                	cmp    %eax,%esi
  8033f0:	73 24                	jae    803416 <devfile_read+0x59>
  8033f2:	c7 44 24 0c 71 47 80 	movl   $0x804771,0xc(%esp)
  8033f9:	00 
  8033fa:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  803401:	00 
  803402:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  803409:	00 
  80340a:	c7 04 24 66 47 80 00 	movl   $0x804766,(%esp)
  803411:	e8 32 e9 ff ff       	call   801d48 <_panic>
	assert(r <= PGSIZE);
  803416:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80341b:	7e 24                	jle    803441 <devfile_read+0x84>
  80341d:	c7 44 24 0c 78 47 80 	movl   $0x804778,0xc(%esp)
  803424:	00 
  803425:	c7 44 24 08 3d 3d 80 	movl   $0x803d3d,0x8(%esp)
  80342c:	00 
  80342d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  803434:	00 
  803435:	c7 04 24 66 47 80 00 	movl   $0x804766,(%esp)
  80343c:	e8 07 e9 ff ff       	call   801d48 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803441:	89 44 24 08          	mov    %eax,0x8(%esp)
  803445:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  80344c:	00 
  80344d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803450:	89 04 24             	mov    %eax,(%esp)
  803453:	e8 ac f1 ff ff       	call   802604 <memmove>
}
  803458:	89 d8                	mov    %ebx,%eax
  80345a:	83 c4 10             	add    $0x10,%esp
  80345d:	5b                   	pop    %ebx
  80345e:	5e                   	pop    %esi
  80345f:	5d                   	pop    %ebp
  803460:	c3                   	ret    

00803461 <open>:
{
  803461:	55                   	push   %ebp
  803462:	89 e5                	mov    %esp,%ebp
  803464:	53                   	push   %ebx
  803465:	83 ec 24             	sub    $0x24,%esp
  803468:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80346b:	89 1c 24             	mov    %ebx,(%esp)
  80346e:	e8 bd ef ff ff       	call   802430 <strlen>
  803473:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803478:	7f 60                	jg     8034da <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80347a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80347d:	89 04 24             	mov    %eax,(%esp)
  803480:	e8 52 f8 ff ff       	call   802cd7 <fd_alloc>
  803485:	89 c2                	mov    %eax,%edx
  803487:	85 d2                	test   %edx,%edx
  803489:	78 54                	js     8034df <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  80348b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80348f:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  803496:	e8 cc ef ff ff       	call   802467 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80349b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80349e:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8034a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8034a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8034ab:	e8 de fd ff ff       	call   80328e <fsipc>
  8034b0:	89 c3                	mov    %eax,%ebx
  8034b2:	85 c0                	test   %eax,%eax
  8034b4:	79 17                	jns    8034cd <open+0x6c>
		fd_close(fd, 0);
  8034b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8034bd:	00 
  8034be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034c1:	89 04 24             	mov    %eax,(%esp)
  8034c4:	e8 08 f9 ff ff       	call   802dd1 <fd_close>
		return r;
  8034c9:	89 d8                	mov    %ebx,%eax
  8034cb:	eb 12                	jmp    8034df <open+0x7e>
	return fd2num(fd);
  8034cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034d0:	89 04 24             	mov    %eax,(%esp)
  8034d3:	e8 d8 f7 ff ff       	call   802cb0 <fd2num>
  8034d8:	eb 05                	jmp    8034df <open+0x7e>
		return -E_BAD_PATH;
  8034da:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8034df:	83 c4 24             	add    $0x24,%esp
  8034e2:	5b                   	pop    %ebx
  8034e3:	5d                   	pop    %ebp
  8034e4:	c3                   	ret    

008034e5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8034e5:	55                   	push   %ebp
  8034e6:	89 e5                	mov    %esp,%ebp
  8034e8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8034eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8034f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8034f5:	e8 94 fd ff ff       	call   80328e <fsipc>
}
  8034fa:	c9                   	leave  
  8034fb:	c3                   	ret    

008034fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8034fc:	55                   	push   %ebp
  8034fd:	89 e5                	mov    %esp,%ebp
  8034ff:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803502:	89 d0                	mov    %edx,%eax
  803504:	c1 e8 16             	shr    $0x16,%eax
  803507:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80350e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  803513:	f6 c1 01             	test   $0x1,%cl
  803516:	74 1d                	je     803535 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  803518:	c1 ea 0c             	shr    $0xc,%edx
  80351b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803522:	f6 c2 01             	test   $0x1,%dl
  803525:	74 0e                	je     803535 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803527:	c1 ea 0c             	shr    $0xc,%edx
  80352a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803531:	ef 
  803532:	0f b7 c0             	movzwl %ax,%eax
}
  803535:	5d                   	pop    %ebp
  803536:	c3                   	ret    

00803537 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803537:	55                   	push   %ebp
  803538:	89 e5                	mov    %esp,%ebp
  80353a:	56                   	push   %esi
  80353b:	53                   	push   %ebx
  80353c:	83 ec 10             	sub    $0x10,%esp
  80353f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803542:	8b 45 08             	mov    0x8(%ebp),%eax
  803545:	89 04 24             	mov    %eax,(%esp)
  803548:	e8 73 f7 ff ff       	call   802cc0 <fd2data>
  80354d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80354f:	c7 44 24 04 84 47 80 	movl   $0x804784,0x4(%esp)
  803556:	00 
  803557:	89 1c 24             	mov    %ebx,(%esp)
  80355a:	e8 08 ef ff ff       	call   802467 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80355f:	8b 46 04             	mov    0x4(%esi),%eax
  803562:	2b 06                	sub    (%esi),%eax
  803564:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80356a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803571:	00 00 00 
	stat->st_dev = &devpipe;
  803574:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80357b:	90 80 00 
	return 0;
}
  80357e:	b8 00 00 00 00       	mov    $0x0,%eax
  803583:	83 c4 10             	add    $0x10,%esp
  803586:	5b                   	pop    %ebx
  803587:	5e                   	pop    %esi
  803588:	5d                   	pop    %ebp
  803589:	c3                   	ret    

0080358a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80358a:	55                   	push   %ebp
  80358b:	89 e5                	mov    %esp,%ebp
  80358d:	53                   	push   %ebx
  80358e:	83 ec 14             	sub    $0x14,%esp
  803591:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803594:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803598:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80359f:	e8 86 f3 ff ff       	call   80292a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8035a4:	89 1c 24             	mov    %ebx,(%esp)
  8035a7:	e8 14 f7 ff ff       	call   802cc0 <fd2data>
  8035ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035b7:	e8 6e f3 ff ff       	call   80292a <sys_page_unmap>
}
  8035bc:	83 c4 14             	add    $0x14,%esp
  8035bf:	5b                   	pop    %ebx
  8035c0:	5d                   	pop    %ebp
  8035c1:	c3                   	ret    

008035c2 <_pipeisclosed>:
{
  8035c2:	55                   	push   %ebp
  8035c3:	89 e5                	mov    %esp,%ebp
  8035c5:	57                   	push   %edi
  8035c6:	56                   	push   %esi
  8035c7:	53                   	push   %ebx
  8035c8:	83 ec 2c             	sub    $0x2c,%esp
  8035cb:	89 c6                	mov    %eax,%esi
  8035cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8035d0:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8035d5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8035d8:	89 34 24             	mov    %esi,(%esp)
  8035db:	e8 1c ff ff ff       	call   8034fc <pageref>
  8035e0:	89 c7                	mov    %eax,%edi
  8035e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8035e5:	89 04 24             	mov    %eax,(%esp)
  8035e8:	e8 0f ff ff ff       	call   8034fc <pageref>
  8035ed:	39 c7                	cmp    %eax,%edi
  8035ef:	0f 94 c2             	sete   %dl
  8035f2:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8035f5:	8b 0d 10 a0 80 00    	mov    0x80a010,%ecx
  8035fb:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8035fe:	39 fb                	cmp    %edi,%ebx
  803600:	74 21                	je     803623 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  803602:	84 d2                	test   %dl,%dl
  803604:	74 ca                	je     8035d0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803606:	8b 51 58             	mov    0x58(%ecx),%edx
  803609:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80360d:	89 54 24 08          	mov    %edx,0x8(%esp)
  803611:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803615:	c7 04 24 8b 47 80 00 	movl   $0x80478b,(%esp)
  80361c:	e8 20 e8 ff ff       	call   801e41 <cprintf>
  803621:	eb ad                	jmp    8035d0 <_pipeisclosed+0xe>
}
  803623:	83 c4 2c             	add    $0x2c,%esp
  803626:	5b                   	pop    %ebx
  803627:	5e                   	pop    %esi
  803628:	5f                   	pop    %edi
  803629:	5d                   	pop    %ebp
  80362a:	c3                   	ret    

0080362b <devpipe_write>:
{
  80362b:	55                   	push   %ebp
  80362c:	89 e5                	mov    %esp,%ebp
  80362e:	57                   	push   %edi
  80362f:	56                   	push   %esi
  803630:	53                   	push   %ebx
  803631:	83 ec 1c             	sub    $0x1c,%esp
  803634:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  803637:	89 34 24             	mov    %esi,(%esp)
  80363a:	e8 81 f6 ff ff       	call   802cc0 <fd2data>
  80363f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  803641:	bf 00 00 00 00       	mov    $0x0,%edi
  803646:	eb 45                	jmp    80368d <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  803648:	89 da                	mov    %ebx,%edx
  80364a:	89 f0                	mov    %esi,%eax
  80364c:	e8 71 ff ff ff       	call   8035c2 <_pipeisclosed>
  803651:	85 c0                	test   %eax,%eax
  803653:	75 41                	jne    803696 <devpipe_write+0x6b>
			sys_yield();
  803655:	e8 0a f2 ff ff       	call   802864 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80365a:	8b 43 04             	mov    0x4(%ebx),%eax
  80365d:	8b 0b                	mov    (%ebx),%ecx
  80365f:	8d 51 20             	lea    0x20(%ecx),%edx
  803662:	39 d0                	cmp    %edx,%eax
  803664:	73 e2                	jae    803648 <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803666:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803669:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80366d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803670:	99                   	cltd   
  803671:	c1 ea 1b             	shr    $0x1b,%edx
  803674:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  803677:	83 e1 1f             	and    $0x1f,%ecx
  80367a:	29 d1                	sub    %edx,%ecx
  80367c:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  803680:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  803684:	83 c0 01             	add    $0x1,%eax
  803687:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80368a:	83 c7 01             	add    $0x1,%edi
  80368d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803690:	75 c8                	jne    80365a <devpipe_write+0x2f>
	return i;
  803692:	89 f8                	mov    %edi,%eax
  803694:	eb 05                	jmp    80369b <devpipe_write+0x70>
				return 0;
  803696:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80369b:	83 c4 1c             	add    $0x1c,%esp
  80369e:	5b                   	pop    %ebx
  80369f:	5e                   	pop    %esi
  8036a0:	5f                   	pop    %edi
  8036a1:	5d                   	pop    %ebp
  8036a2:	c3                   	ret    

008036a3 <devpipe_read>:
{
  8036a3:	55                   	push   %ebp
  8036a4:	89 e5                	mov    %esp,%ebp
  8036a6:	57                   	push   %edi
  8036a7:	56                   	push   %esi
  8036a8:	53                   	push   %ebx
  8036a9:	83 ec 1c             	sub    $0x1c,%esp
  8036ac:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8036af:	89 3c 24             	mov    %edi,(%esp)
  8036b2:	e8 09 f6 ff ff       	call   802cc0 <fd2data>
  8036b7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8036b9:	be 00 00 00 00       	mov    $0x0,%esi
  8036be:	eb 3d                	jmp    8036fd <devpipe_read+0x5a>
			if (i > 0)
  8036c0:	85 f6                	test   %esi,%esi
  8036c2:	74 04                	je     8036c8 <devpipe_read+0x25>
				return i;
  8036c4:	89 f0                	mov    %esi,%eax
  8036c6:	eb 43                	jmp    80370b <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  8036c8:	89 da                	mov    %ebx,%edx
  8036ca:	89 f8                	mov    %edi,%eax
  8036cc:	e8 f1 fe ff ff       	call   8035c2 <_pipeisclosed>
  8036d1:	85 c0                	test   %eax,%eax
  8036d3:	75 31                	jne    803706 <devpipe_read+0x63>
			sys_yield();
  8036d5:	e8 8a f1 ff ff       	call   802864 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8036da:	8b 03                	mov    (%ebx),%eax
  8036dc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8036df:	74 df                	je     8036c0 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8036e1:	99                   	cltd   
  8036e2:	c1 ea 1b             	shr    $0x1b,%edx
  8036e5:	01 d0                	add    %edx,%eax
  8036e7:	83 e0 1f             	and    $0x1f,%eax
  8036ea:	29 d0                	sub    %edx,%eax
  8036ec:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8036f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8036f4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8036f7:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8036fa:	83 c6 01             	add    $0x1,%esi
  8036fd:	3b 75 10             	cmp    0x10(%ebp),%esi
  803700:	75 d8                	jne    8036da <devpipe_read+0x37>
	return i;
  803702:	89 f0                	mov    %esi,%eax
  803704:	eb 05                	jmp    80370b <devpipe_read+0x68>
				return 0;
  803706:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80370b:	83 c4 1c             	add    $0x1c,%esp
  80370e:	5b                   	pop    %ebx
  80370f:	5e                   	pop    %esi
  803710:	5f                   	pop    %edi
  803711:	5d                   	pop    %ebp
  803712:	c3                   	ret    

00803713 <pipe>:
{
  803713:	55                   	push   %ebp
  803714:	89 e5                	mov    %esp,%ebp
  803716:	56                   	push   %esi
  803717:	53                   	push   %ebx
  803718:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80371b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80371e:	89 04 24             	mov    %eax,(%esp)
  803721:	e8 b1 f5 ff ff       	call   802cd7 <fd_alloc>
  803726:	89 c2                	mov    %eax,%edx
  803728:	85 d2                	test   %edx,%edx
  80372a:	0f 88 4d 01 00 00    	js     80387d <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803730:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803737:	00 
  803738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80373b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80373f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803746:	e8 38 f1 ff ff       	call   802883 <sys_page_alloc>
  80374b:	89 c2                	mov    %eax,%edx
  80374d:	85 d2                	test   %edx,%edx
  80374f:	0f 88 28 01 00 00    	js     80387d <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  803755:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803758:	89 04 24             	mov    %eax,(%esp)
  80375b:	e8 77 f5 ff ff       	call   802cd7 <fd_alloc>
  803760:	89 c3                	mov    %eax,%ebx
  803762:	85 c0                	test   %eax,%eax
  803764:	0f 88 fe 00 00 00    	js     803868 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80376a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803771:	00 
  803772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803775:	89 44 24 04          	mov    %eax,0x4(%esp)
  803779:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803780:	e8 fe f0 ff ff       	call   802883 <sys_page_alloc>
  803785:	89 c3                	mov    %eax,%ebx
  803787:	85 c0                	test   %eax,%eax
  803789:	0f 88 d9 00 00 00    	js     803868 <pipe+0x155>
	va = fd2data(fd0);
  80378f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803792:	89 04 24             	mov    %eax,(%esp)
  803795:	e8 26 f5 ff ff       	call   802cc0 <fd2data>
  80379a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80379c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8037a3:	00 
  8037a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037af:	e8 cf f0 ff ff       	call   802883 <sys_page_alloc>
  8037b4:	89 c3                	mov    %eax,%ebx
  8037b6:	85 c0                	test   %eax,%eax
  8037b8:	0f 88 97 00 00 00    	js     803855 <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8037c1:	89 04 24             	mov    %eax,(%esp)
  8037c4:	e8 f7 f4 ff ff       	call   802cc0 <fd2data>
  8037c9:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8037d0:	00 
  8037d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8037d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8037dc:	00 
  8037dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037e8:	e8 ea f0 ff ff       	call   8028d7 <sys_page_map>
  8037ed:	89 c3                	mov    %eax,%ebx
  8037ef:	85 c0                	test   %eax,%eax
  8037f1:	78 52                	js     803845 <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  8037f3:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8037f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037fc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8037fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803801:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  803808:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80380e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803811:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803813:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803816:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80381d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803820:	89 04 24             	mov    %eax,(%esp)
  803823:	e8 88 f4 ff ff       	call   802cb0 <fd2num>
  803828:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80382b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80382d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803830:	89 04 24             	mov    %eax,(%esp)
  803833:	e8 78 f4 ff ff       	call   802cb0 <fd2num>
  803838:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80383b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80383e:	b8 00 00 00 00       	mov    $0x0,%eax
  803843:	eb 38                	jmp    80387d <pipe+0x16a>
	sys_page_unmap(0, va);
  803845:	89 74 24 04          	mov    %esi,0x4(%esp)
  803849:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803850:	e8 d5 f0 ff ff       	call   80292a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  803855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80385c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803863:	e8 c2 f0 ff ff       	call   80292a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  803868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80386b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80386f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803876:	e8 af f0 ff ff       	call   80292a <sys_page_unmap>
  80387b:	89 d8                	mov    %ebx,%eax
}
  80387d:	83 c4 30             	add    $0x30,%esp
  803880:	5b                   	pop    %ebx
  803881:	5e                   	pop    %esi
  803882:	5d                   	pop    %ebp
  803883:	c3                   	ret    

00803884 <pipeisclosed>:
{
  803884:	55                   	push   %ebp
  803885:	89 e5                	mov    %esp,%ebp
  803887:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80388a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80388d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803891:	8b 45 08             	mov    0x8(%ebp),%eax
  803894:	89 04 24             	mov    %eax,(%esp)
  803897:	e8 8a f4 ff ff       	call   802d26 <fd_lookup>
  80389c:	89 c2                	mov    %eax,%edx
  80389e:	85 d2                	test   %edx,%edx
  8038a0:	78 15                	js     8038b7 <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  8038a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038a5:	89 04 24             	mov    %eax,(%esp)
  8038a8:	e8 13 f4 ff ff       	call   802cc0 <fd2data>
	return _pipeisclosed(fd, p);
  8038ad:	89 c2                	mov    %eax,%edx
  8038af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038b2:	e8 0b fd ff ff       	call   8035c2 <_pipeisclosed>
}
  8038b7:	c9                   	leave  
  8038b8:	c3                   	ret    
  8038b9:	66 90                	xchg   %ax,%ax
  8038bb:	66 90                	xchg   %ax,%ax
  8038bd:	66 90                	xchg   %ax,%ax
  8038bf:	90                   	nop

008038c0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8038c0:	55                   	push   %ebp
  8038c1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8038c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8038c8:	5d                   	pop    %ebp
  8038c9:	c3                   	ret    

008038ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8038ca:	55                   	push   %ebp
  8038cb:	89 e5                	mov    %esp,%ebp
  8038cd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8038d0:	c7 44 24 04 a3 47 80 	movl   $0x8047a3,0x4(%esp)
  8038d7:	00 
  8038d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8038db:	89 04 24             	mov    %eax,(%esp)
  8038de:	e8 84 eb ff ff       	call   802467 <strcpy>
	return 0;
}
  8038e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8038e8:	c9                   	leave  
  8038e9:	c3                   	ret    

008038ea <devcons_write>:
{
  8038ea:	55                   	push   %ebp
  8038eb:	89 e5                	mov    %esp,%ebp
  8038ed:	57                   	push   %edi
  8038ee:	56                   	push   %esi
  8038ef:	53                   	push   %ebx
  8038f0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  8038f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8038fb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  803901:	eb 31                	jmp    803934 <devcons_write+0x4a>
		m = n - tot;
  803903:	8b 75 10             	mov    0x10(%ebp),%esi
  803906:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  803908:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80390b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803910:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803913:	89 74 24 08          	mov    %esi,0x8(%esp)
  803917:	03 45 0c             	add    0xc(%ebp),%eax
  80391a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80391e:	89 3c 24             	mov    %edi,(%esp)
  803921:	e8 de ec ff ff       	call   802604 <memmove>
		sys_cputs(buf, m);
  803926:	89 74 24 04          	mov    %esi,0x4(%esp)
  80392a:	89 3c 24             	mov    %edi,(%esp)
  80392d:	e8 84 ee ff ff       	call   8027b6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  803932:	01 f3                	add    %esi,%ebx
  803934:	89 d8                	mov    %ebx,%eax
  803936:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803939:	72 c8                	jb     803903 <devcons_write+0x19>
}
  80393b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803941:	5b                   	pop    %ebx
  803942:	5e                   	pop    %esi
  803943:	5f                   	pop    %edi
  803944:	5d                   	pop    %ebp
  803945:	c3                   	ret    

00803946 <devcons_read>:
{
  803946:	55                   	push   %ebp
  803947:	89 e5                	mov    %esp,%ebp
  803949:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80394c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  803951:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803955:	75 07                	jne    80395e <devcons_read+0x18>
  803957:	eb 2a                	jmp    803983 <devcons_read+0x3d>
		sys_yield();
  803959:	e8 06 ef ff ff       	call   802864 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80395e:	66 90                	xchg   %ax,%ax
  803960:	e8 6f ee ff ff       	call   8027d4 <sys_cgetc>
  803965:	85 c0                	test   %eax,%eax
  803967:	74 f0                	je     803959 <devcons_read+0x13>
	if (c < 0)
  803969:	85 c0                	test   %eax,%eax
  80396b:	78 16                	js     803983 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80396d:	83 f8 04             	cmp    $0x4,%eax
  803970:	74 0c                	je     80397e <devcons_read+0x38>
	*(char*)vbuf = c;
  803972:	8b 55 0c             	mov    0xc(%ebp),%edx
  803975:	88 02                	mov    %al,(%edx)
	return 1;
  803977:	b8 01 00 00 00       	mov    $0x1,%eax
  80397c:	eb 05                	jmp    803983 <devcons_read+0x3d>
		return 0;
  80397e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803983:	c9                   	leave  
  803984:	c3                   	ret    

00803985 <cputchar>:
{
  803985:	55                   	push   %ebp
  803986:	89 e5                	mov    %esp,%ebp
  803988:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80398b:	8b 45 08             	mov    0x8(%ebp),%eax
  80398e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  803991:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803998:	00 
  803999:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80399c:	89 04 24             	mov    %eax,(%esp)
  80399f:	e8 12 ee ff ff       	call   8027b6 <sys_cputs>
}
  8039a4:	c9                   	leave  
  8039a5:	c3                   	ret    

008039a6 <getchar>:
{
  8039a6:	55                   	push   %ebp
  8039a7:	89 e5                	mov    %esp,%ebp
  8039a9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8039ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8039b3:	00 
  8039b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8039b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8039bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8039c2:	e8 ee f5 ff ff       	call   802fb5 <read>
	if (r < 0)
  8039c7:	85 c0                	test   %eax,%eax
  8039c9:	78 0f                	js     8039da <getchar+0x34>
	if (r < 1)
  8039cb:	85 c0                	test   %eax,%eax
  8039cd:	7e 06                	jle    8039d5 <getchar+0x2f>
	return c;
  8039cf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8039d3:	eb 05                	jmp    8039da <getchar+0x34>
		return -E_EOF;
  8039d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8039da:	c9                   	leave  
  8039db:	c3                   	ret    

008039dc <iscons>:
{
  8039dc:	55                   	push   %ebp
  8039dd:	89 e5                	mov    %esp,%ebp
  8039df:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8039e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8039e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8039ec:	89 04 24             	mov    %eax,(%esp)
  8039ef:	e8 32 f3 ff ff       	call   802d26 <fd_lookup>
  8039f4:	85 c0                	test   %eax,%eax
  8039f6:	78 11                	js     803a09 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8039f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039fb:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803a01:	39 10                	cmp    %edx,(%eax)
  803a03:	0f 94 c0             	sete   %al
  803a06:	0f b6 c0             	movzbl %al,%eax
}
  803a09:	c9                   	leave  
  803a0a:	c3                   	ret    

00803a0b <opencons>:
{
  803a0b:	55                   	push   %ebp
  803a0c:	89 e5                	mov    %esp,%ebp
  803a0e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  803a11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a14:	89 04 24             	mov    %eax,(%esp)
  803a17:	e8 bb f2 ff ff       	call   802cd7 <fd_alloc>
		return r;
  803a1c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  803a1e:	85 c0                	test   %eax,%eax
  803a20:	78 40                	js     803a62 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803a29:	00 
  803a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803a31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803a38:	e8 46 ee ff ff       	call   802883 <sys_page_alloc>
		return r;
  803a3d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a3f:	85 c0                	test   %eax,%eax
  803a41:	78 1f                	js     803a62 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  803a43:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a4c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a51:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803a58:	89 04 24             	mov    %eax,(%esp)
  803a5b:	e8 50 f2 ff ff       	call   802cb0 <fd2num>
  803a60:	89 c2                	mov    %eax,%edx
}
  803a62:	89 d0                	mov    %edx,%eax
  803a64:	c9                   	leave  
  803a65:	c3                   	ret    
  803a66:	66 90                	xchg   %ax,%ax
  803a68:	66 90                	xchg   %ax,%ax
  803a6a:	66 90                	xchg   %ax,%ax
  803a6c:	66 90                	xchg   %ax,%ax
  803a6e:	66 90                	xchg   %ax,%ax

00803a70 <__udivdi3>:
  803a70:	55                   	push   %ebp
  803a71:	57                   	push   %edi
  803a72:	56                   	push   %esi
  803a73:	83 ec 0c             	sub    $0xc,%esp
  803a76:	8b 44 24 28          	mov    0x28(%esp),%eax
  803a7a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  803a7e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  803a82:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  803a86:	85 c0                	test   %eax,%eax
  803a88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  803a8c:	89 ea                	mov    %ebp,%edx
  803a8e:	89 0c 24             	mov    %ecx,(%esp)
  803a91:	75 2d                	jne    803ac0 <__udivdi3+0x50>
  803a93:	39 e9                	cmp    %ebp,%ecx
  803a95:	77 61                	ja     803af8 <__udivdi3+0x88>
  803a97:	85 c9                	test   %ecx,%ecx
  803a99:	89 ce                	mov    %ecx,%esi
  803a9b:	75 0b                	jne    803aa8 <__udivdi3+0x38>
  803a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  803aa2:	31 d2                	xor    %edx,%edx
  803aa4:	f7 f1                	div    %ecx
  803aa6:	89 c6                	mov    %eax,%esi
  803aa8:	31 d2                	xor    %edx,%edx
  803aaa:	89 e8                	mov    %ebp,%eax
  803aac:	f7 f6                	div    %esi
  803aae:	89 c5                	mov    %eax,%ebp
  803ab0:	89 f8                	mov    %edi,%eax
  803ab2:	f7 f6                	div    %esi
  803ab4:	89 ea                	mov    %ebp,%edx
  803ab6:	83 c4 0c             	add    $0xc,%esp
  803ab9:	5e                   	pop    %esi
  803aba:	5f                   	pop    %edi
  803abb:	5d                   	pop    %ebp
  803abc:	c3                   	ret    
  803abd:	8d 76 00             	lea    0x0(%esi),%esi
  803ac0:	39 e8                	cmp    %ebp,%eax
  803ac2:	77 24                	ja     803ae8 <__udivdi3+0x78>
  803ac4:	0f bd e8             	bsr    %eax,%ebp
  803ac7:	83 f5 1f             	xor    $0x1f,%ebp
  803aca:	75 3c                	jne    803b08 <__udivdi3+0x98>
  803acc:	8b 74 24 04          	mov    0x4(%esp),%esi
  803ad0:	39 34 24             	cmp    %esi,(%esp)
  803ad3:	0f 86 9f 00 00 00    	jbe    803b78 <__udivdi3+0x108>
  803ad9:	39 d0                	cmp    %edx,%eax
  803adb:	0f 82 97 00 00 00    	jb     803b78 <__udivdi3+0x108>
  803ae1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803ae8:	31 d2                	xor    %edx,%edx
  803aea:	31 c0                	xor    %eax,%eax
  803aec:	83 c4 0c             	add    $0xc,%esp
  803aef:	5e                   	pop    %esi
  803af0:	5f                   	pop    %edi
  803af1:	5d                   	pop    %ebp
  803af2:	c3                   	ret    
  803af3:	90                   	nop
  803af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803af8:	89 f8                	mov    %edi,%eax
  803afa:	f7 f1                	div    %ecx
  803afc:	31 d2                	xor    %edx,%edx
  803afe:	83 c4 0c             	add    $0xc,%esp
  803b01:	5e                   	pop    %esi
  803b02:	5f                   	pop    %edi
  803b03:	5d                   	pop    %ebp
  803b04:	c3                   	ret    
  803b05:	8d 76 00             	lea    0x0(%esi),%esi
  803b08:	89 e9                	mov    %ebp,%ecx
  803b0a:	8b 3c 24             	mov    (%esp),%edi
  803b0d:	d3 e0                	shl    %cl,%eax
  803b0f:	89 c6                	mov    %eax,%esi
  803b11:	b8 20 00 00 00       	mov    $0x20,%eax
  803b16:	29 e8                	sub    %ebp,%eax
  803b18:	89 c1                	mov    %eax,%ecx
  803b1a:	d3 ef                	shr    %cl,%edi
  803b1c:	89 e9                	mov    %ebp,%ecx
  803b1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803b22:	8b 3c 24             	mov    (%esp),%edi
  803b25:	09 74 24 08          	or     %esi,0x8(%esp)
  803b29:	89 d6                	mov    %edx,%esi
  803b2b:	d3 e7                	shl    %cl,%edi
  803b2d:	89 c1                	mov    %eax,%ecx
  803b2f:	89 3c 24             	mov    %edi,(%esp)
  803b32:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803b36:	d3 ee                	shr    %cl,%esi
  803b38:	89 e9                	mov    %ebp,%ecx
  803b3a:	d3 e2                	shl    %cl,%edx
  803b3c:	89 c1                	mov    %eax,%ecx
  803b3e:	d3 ef                	shr    %cl,%edi
  803b40:	09 d7                	or     %edx,%edi
  803b42:	89 f2                	mov    %esi,%edx
  803b44:	89 f8                	mov    %edi,%eax
  803b46:	f7 74 24 08          	divl   0x8(%esp)
  803b4a:	89 d6                	mov    %edx,%esi
  803b4c:	89 c7                	mov    %eax,%edi
  803b4e:	f7 24 24             	mull   (%esp)
  803b51:	39 d6                	cmp    %edx,%esi
  803b53:	89 14 24             	mov    %edx,(%esp)
  803b56:	72 30                	jb     803b88 <__udivdi3+0x118>
  803b58:	8b 54 24 04          	mov    0x4(%esp),%edx
  803b5c:	89 e9                	mov    %ebp,%ecx
  803b5e:	d3 e2                	shl    %cl,%edx
  803b60:	39 c2                	cmp    %eax,%edx
  803b62:	73 05                	jae    803b69 <__udivdi3+0xf9>
  803b64:	3b 34 24             	cmp    (%esp),%esi
  803b67:	74 1f                	je     803b88 <__udivdi3+0x118>
  803b69:	89 f8                	mov    %edi,%eax
  803b6b:	31 d2                	xor    %edx,%edx
  803b6d:	e9 7a ff ff ff       	jmp    803aec <__udivdi3+0x7c>
  803b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803b78:	31 d2                	xor    %edx,%edx
  803b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  803b7f:	e9 68 ff ff ff       	jmp    803aec <__udivdi3+0x7c>
  803b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803b88:	8d 47 ff             	lea    -0x1(%edi),%eax
  803b8b:	31 d2                	xor    %edx,%edx
  803b8d:	83 c4 0c             	add    $0xc,%esp
  803b90:	5e                   	pop    %esi
  803b91:	5f                   	pop    %edi
  803b92:	5d                   	pop    %ebp
  803b93:	c3                   	ret    
  803b94:	66 90                	xchg   %ax,%ax
  803b96:	66 90                	xchg   %ax,%ax
  803b98:	66 90                	xchg   %ax,%ax
  803b9a:	66 90                	xchg   %ax,%ax
  803b9c:	66 90                	xchg   %ax,%ax
  803b9e:	66 90                	xchg   %ax,%ax

00803ba0 <__umoddi3>:
  803ba0:	55                   	push   %ebp
  803ba1:	57                   	push   %edi
  803ba2:	56                   	push   %esi
  803ba3:	83 ec 14             	sub    $0x14,%esp
  803ba6:	8b 44 24 28          	mov    0x28(%esp),%eax
  803baa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  803bae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  803bb2:	89 c7                	mov    %eax,%edi
  803bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  803bb8:	8b 44 24 30          	mov    0x30(%esp),%eax
  803bbc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803bc0:	89 34 24             	mov    %esi,(%esp)
  803bc3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803bc7:	85 c0                	test   %eax,%eax
  803bc9:	89 c2                	mov    %eax,%edx
  803bcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803bcf:	75 17                	jne    803be8 <__umoddi3+0x48>
  803bd1:	39 fe                	cmp    %edi,%esi
  803bd3:	76 4b                	jbe    803c20 <__umoddi3+0x80>
  803bd5:	89 c8                	mov    %ecx,%eax
  803bd7:	89 fa                	mov    %edi,%edx
  803bd9:	f7 f6                	div    %esi
  803bdb:	89 d0                	mov    %edx,%eax
  803bdd:	31 d2                	xor    %edx,%edx
  803bdf:	83 c4 14             	add    $0x14,%esp
  803be2:	5e                   	pop    %esi
  803be3:	5f                   	pop    %edi
  803be4:	5d                   	pop    %ebp
  803be5:	c3                   	ret    
  803be6:	66 90                	xchg   %ax,%ax
  803be8:	39 f8                	cmp    %edi,%eax
  803bea:	77 54                	ja     803c40 <__umoddi3+0xa0>
  803bec:	0f bd e8             	bsr    %eax,%ebp
  803bef:	83 f5 1f             	xor    $0x1f,%ebp
  803bf2:	75 5c                	jne    803c50 <__umoddi3+0xb0>
  803bf4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  803bf8:	39 3c 24             	cmp    %edi,(%esp)
  803bfb:	0f 87 e7 00 00 00    	ja     803ce8 <__umoddi3+0x148>
  803c01:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803c05:	29 f1                	sub    %esi,%ecx
  803c07:	19 c7                	sbb    %eax,%edi
  803c09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803c0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803c11:	8b 44 24 08          	mov    0x8(%esp),%eax
  803c15:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803c19:	83 c4 14             	add    $0x14,%esp
  803c1c:	5e                   	pop    %esi
  803c1d:	5f                   	pop    %edi
  803c1e:	5d                   	pop    %ebp
  803c1f:	c3                   	ret    
  803c20:	85 f6                	test   %esi,%esi
  803c22:	89 f5                	mov    %esi,%ebp
  803c24:	75 0b                	jne    803c31 <__umoddi3+0x91>
  803c26:	b8 01 00 00 00       	mov    $0x1,%eax
  803c2b:	31 d2                	xor    %edx,%edx
  803c2d:	f7 f6                	div    %esi
  803c2f:	89 c5                	mov    %eax,%ebp
  803c31:	8b 44 24 04          	mov    0x4(%esp),%eax
  803c35:	31 d2                	xor    %edx,%edx
  803c37:	f7 f5                	div    %ebp
  803c39:	89 c8                	mov    %ecx,%eax
  803c3b:	f7 f5                	div    %ebp
  803c3d:	eb 9c                	jmp    803bdb <__umoddi3+0x3b>
  803c3f:	90                   	nop
  803c40:	89 c8                	mov    %ecx,%eax
  803c42:	89 fa                	mov    %edi,%edx
  803c44:	83 c4 14             	add    $0x14,%esp
  803c47:	5e                   	pop    %esi
  803c48:	5f                   	pop    %edi
  803c49:	5d                   	pop    %ebp
  803c4a:	c3                   	ret    
  803c4b:	90                   	nop
  803c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803c50:	8b 04 24             	mov    (%esp),%eax
  803c53:	be 20 00 00 00       	mov    $0x20,%esi
  803c58:	89 e9                	mov    %ebp,%ecx
  803c5a:	29 ee                	sub    %ebp,%esi
  803c5c:	d3 e2                	shl    %cl,%edx
  803c5e:	89 f1                	mov    %esi,%ecx
  803c60:	d3 e8                	shr    %cl,%eax
  803c62:	89 e9                	mov    %ebp,%ecx
  803c64:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c68:	8b 04 24             	mov    (%esp),%eax
  803c6b:	09 54 24 04          	or     %edx,0x4(%esp)
  803c6f:	89 fa                	mov    %edi,%edx
  803c71:	d3 e0                	shl    %cl,%eax
  803c73:	89 f1                	mov    %esi,%ecx
  803c75:	89 44 24 08          	mov    %eax,0x8(%esp)
  803c79:	8b 44 24 10          	mov    0x10(%esp),%eax
  803c7d:	d3 ea                	shr    %cl,%edx
  803c7f:	89 e9                	mov    %ebp,%ecx
  803c81:	d3 e7                	shl    %cl,%edi
  803c83:	89 f1                	mov    %esi,%ecx
  803c85:	d3 e8                	shr    %cl,%eax
  803c87:	89 e9                	mov    %ebp,%ecx
  803c89:	09 f8                	or     %edi,%eax
  803c8b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  803c8f:	f7 74 24 04          	divl   0x4(%esp)
  803c93:	d3 e7                	shl    %cl,%edi
  803c95:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803c99:	89 d7                	mov    %edx,%edi
  803c9b:	f7 64 24 08          	mull   0x8(%esp)
  803c9f:	39 d7                	cmp    %edx,%edi
  803ca1:	89 c1                	mov    %eax,%ecx
  803ca3:	89 14 24             	mov    %edx,(%esp)
  803ca6:	72 2c                	jb     803cd4 <__umoddi3+0x134>
  803ca8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  803cac:	72 22                	jb     803cd0 <__umoddi3+0x130>
  803cae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803cb2:	29 c8                	sub    %ecx,%eax
  803cb4:	19 d7                	sbb    %edx,%edi
  803cb6:	89 e9                	mov    %ebp,%ecx
  803cb8:	89 fa                	mov    %edi,%edx
  803cba:	d3 e8                	shr    %cl,%eax
  803cbc:	89 f1                	mov    %esi,%ecx
  803cbe:	d3 e2                	shl    %cl,%edx
  803cc0:	89 e9                	mov    %ebp,%ecx
  803cc2:	d3 ef                	shr    %cl,%edi
  803cc4:	09 d0                	or     %edx,%eax
  803cc6:	89 fa                	mov    %edi,%edx
  803cc8:	83 c4 14             	add    $0x14,%esp
  803ccb:	5e                   	pop    %esi
  803ccc:	5f                   	pop    %edi
  803ccd:	5d                   	pop    %ebp
  803cce:	c3                   	ret    
  803ccf:	90                   	nop
  803cd0:	39 d7                	cmp    %edx,%edi
  803cd2:	75 da                	jne    803cae <__umoddi3+0x10e>
  803cd4:	8b 14 24             	mov    (%esp),%edx
  803cd7:	89 c1                	mov    %eax,%ecx
  803cd9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  803cdd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  803ce1:	eb cb                	jmp    803cae <__umoddi3+0x10e>
  803ce3:	90                   	nop
  803ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803ce8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  803cec:	0f 82 0f ff ff ff    	jb     803c01 <__umoddi3+0x61>
  803cf2:	e9 1a ff ff ff       	jmp    803c11 <__umoddi3+0x71>
