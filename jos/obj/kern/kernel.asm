
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6a 00 00 00       	call   f01000a8 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 4e 21 f0 00 	cmpl   $0x0,0xf0214e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 4e 21 f0    	mov    %esi,0xf0214e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 75 68 00 00       	call   f01068d9 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 c0 6f 10 f0 	movl   $0xf0106fc0,(%esp)
f010007d:	e8 59 42 00 00       	call   f01042db <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 1a 42 00 00       	call   f01042a8 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 fa 84 10 f0 	movl   $0xf01084fa,(%esp)
f0100095:	e8 41 42 00 00       	call   f01042db <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 ab 0c 00 00       	call   f0100d51 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	cons_init();
f01000af:	e8 b8 05 00 00       	call   f010066c <cons_init>
	cprintf("444544 decimal is %o octal!\n", 444544);
f01000b4:	c7 44 24 04 80 c8 06 	movl   $0x6c880,0x4(%esp)
f01000bb:	00 
f01000bc:	c7 04 24 2c 70 10 f0 	movl   $0xf010702c,(%esp)
f01000c3:	e8 13 42 00 00       	call   f01042db <cprintf>
	mem_init();
f01000c8:	e8 f6 17 00 00       	call   f01018c3 <mem_init>
	env_init();
f01000cd:	e8 af 39 00 00       	call   f0103a81 <env_init>
	trap_init();
f01000d2:	e8 08 43 00 00       	call   f01043df <trap_init>
	mp_init();
f01000d7:	e8 ee 64 00 00       	call   f01065ca <mp_init>
	lapic_init();
f01000dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01000e0:	e8 0f 68 00 00       	call   f01068f4 <lapic_init>
	pic_init();
f01000e5:	e8 21 41 00 00       	call   f010420b <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ea:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000f1:	e8 61 6a 00 00       	call   f0106b57 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f6:	83 3d 88 4e 21 f0 07 	cmpl   $0x7,0xf0214e88
f01000fd:	77 24                	ja     f0100123 <i386_init+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ff:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100106:	00 
f0100107:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f010010e:	f0 
f010010f:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0100116:	00 
f0100117:	c7 04 24 49 70 10 f0 	movl   $0xf0107049,(%esp)
f010011e:	e8 1d ff ff ff       	call   f0100040 <_panic>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100123:	b8 02 65 10 f0       	mov    $0xf0106502,%eax
f0100128:	2d 88 64 10 f0       	sub    $0xf0106488,%eax
f010012d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100131:	c7 44 24 04 88 64 10 	movl   $0xf0106488,0x4(%esp)
f0100138:	f0 
f0100139:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100140:	e8 8f 61 00 00       	call   f01062d4 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100145:	bb 20 50 21 f0       	mov    $0xf0215020,%ebx
f010014a:	eb 4d                	jmp    f0100199 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f010014c:	e8 88 67 00 00       	call   f01068d9 <cpunum>
f0100151:	6b c0 74             	imul   $0x74,%eax,%eax
f0100154:	05 20 50 21 f0       	add    $0xf0215020,%eax
f0100159:	39 c3                	cmp    %eax,%ebx
f010015b:	74 39                	je     f0100196 <i386_init+0xee>
f010015d:	89 d8                	mov    %ebx,%eax
f010015f:	2d 20 50 21 f0       	sub    $0xf0215020,%eax
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100164:	c1 f8 02             	sar    $0x2,%eax
f0100167:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016d:	c1 e0 0f             	shl    $0xf,%eax
f0100170:	8d 80 00 e0 21 f0    	lea    -0xfde2000(%eax),%eax
f0100176:	a3 84 4e 21 f0       	mov    %eax,0xf0214e84
		lapic_startap(c->cpu_id, PADDR(code));
f010017b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100182:	00 
f0100183:	0f b6 03             	movzbl (%ebx),%eax
f0100186:	89 04 24             	mov    %eax,(%esp)
f0100189:	e8 b6 68 00 00       	call   f0106a44 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f010018e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100191:	83 f8 01             	cmp    $0x1,%eax
f0100194:	75 f8                	jne    f010018e <i386_init+0xe6>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100196:	83 c3 74             	add    $0x74,%ebx
f0100199:	6b 05 c4 53 21 f0 74 	imul   $0x74,0xf02153c4,%eax
f01001a0:	05 20 50 21 f0       	add    $0xf0215020,%eax
f01001a5:	39 c3                	cmp    %eax,%ebx
f01001a7:	72 a3                	jb     f010014c <i386_init+0xa4>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01001b0:	00 
f01001b1:	c7 04 24 1c 2f 1d f0 	movl   $0xf01d2f1c,(%esp)
f01001b8:	e8 8b 3a 00 00       	call   f0103c48 <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001c4:	00 
f01001c5:	c7 04 24 dc 3f 20 f0 	movl   $0xf0203fdc,(%esp)
f01001cc:	e8 77 3a 00 00       	call   f0103c48 <env_create>
	kbd_intr();
f01001d1:	e8 3a 04 00 00       	call   f0100610 <kbd_intr>
	sched_yield();
f01001d6:	e8 ef 4d 00 00       	call   f0104fca <sched_yield>

f01001db <mp_main>:
{
f01001db:	55                   	push   %ebp
f01001dc:	89 e5                	mov    %esp,%ebp
f01001de:	83 ec 18             	sub    $0x18,%esp
	lcr3(PADDR(kern_pgdir));
f01001e1:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001e6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001eb:	77 20                	ja     f010020d <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001f1:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f01001f8:	f0 
f01001f9:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0100200:	00 
f0100201:	c7 04 24 49 70 10 f0 	movl   $0xf0107049,(%esp)
f0100208:	e8 33 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010020d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100212:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100215:	e8 bf 66 00 00       	call   f01068d9 <cpunum>
f010021a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010021e:	c7 04 24 55 70 10 f0 	movl   $0xf0107055,(%esp)
f0100225:	e8 b1 40 00 00       	call   f01042db <cprintf>
	lapic_init();
f010022a:	e8 c5 66 00 00       	call   f01068f4 <lapic_init>
	env_init_percpu();
f010022f:	e8 23 38 00 00       	call   f0103a57 <env_init_percpu>
	trap_init_percpu();
f0100234:	e8 c7 40 00 00       	call   f0104300 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100239:	e8 9b 66 00 00       	call   f01068d9 <cpunum>
f010023e:	6b d0 74             	imul   $0x74,%eax,%edx
f0100241:	81 c2 20 50 21 f0    	add    $0xf0215020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100247:	b8 01 00 00 00       	mov    $0x1,%eax
f010024c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100250:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100257:	e8 fb 68 00 00       	call   f0106b57 <spin_lock>
    sched_yield();
f010025c:	e8 69 4d 00 00       	call   f0104fca <sched_yield>

f0100261 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100261:	55                   	push   %ebp
f0100262:	89 e5                	mov    %esp,%ebp
f0100264:	53                   	push   %ebx
f0100265:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100268:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010026b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010026e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100272:	8b 45 08             	mov    0x8(%ebp),%eax
f0100275:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100279:	c7 04 24 6b 70 10 f0 	movl   $0xf010706b,(%esp)
f0100280:	e8 56 40 00 00       	call   f01042db <cprintf>
	vcprintf(fmt, ap);
f0100285:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100289:	8b 45 10             	mov    0x10(%ebp),%eax
f010028c:	89 04 24             	mov    %eax,(%esp)
f010028f:	e8 14 40 00 00       	call   f01042a8 <vcprintf>
	cprintf("\n");
f0100294:	c7 04 24 fa 84 10 f0 	movl   $0xf01084fa,(%esp)
f010029b:	e8 3b 40 00 00       	call   f01042db <cprintf>
	va_end(ap);
}
f01002a0:	83 c4 14             	add    $0x14,%esp
f01002a3:	5b                   	pop    %ebx
f01002a4:	5d                   	pop    %ebp
f01002a5:	c3                   	ret    
f01002a6:	66 90                	xchg   %ax,%ax
f01002a8:	66 90                	xchg   %ax,%ax
f01002aa:	66 90                	xchg   %ax,%ax
f01002ac:	66 90                	xchg   %ax,%ax
f01002ae:	66 90                	xchg   %ax,%ax

f01002b0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002b0:	55                   	push   %ebp
f01002b1:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002b8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002b9:	a8 01                	test   $0x1,%al
f01002bb:	74 08                	je     f01002c5 <serial_proc_data+0x15>
f01002bd:	b2 f8                	mov    $0xf8,%dl
f01002bf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002c0:	0f b6 c0             	movzbl %al,%eax
f01002c3:	eb 05                	jmp    f01002ca <serial_proc_data+0x1a>
		return -1;
f01002c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002ca:	5d                   	pop    %ebp
f01002cb:	c3                   	ret    

f01002cc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002cc:	55                   	push   %ebp
f01002cd:	89 e5                	mov    %esp,%ebp
f01002cf:	53                   	push   %ebx
f01002d0:	83 ec 04             	sub    $0x4,%esp
f01002d3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002d5:	eb 2a                	jmp    f0100301 <cons_intr+0x35>
		if (c == 0)
f01002d7:	85 d2                	test   %edx,%edx
f01002d9:	74 26                	je     f0100301 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002db:	a1 24 42 21 f0       	mov    0xf0214224,%eax
f01002e0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002e3:	89 0d 24 42 21 f0    	mov    %ecx,0xf0214224
f01002e9:	88 90 20 40 21 f0    	mov    %dl,-0xfdebfe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002ef:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01002f5:	75 0a                	jne    f0100301 <cons_intr+0x35>
			cons.wpos = 0;
f01002f7:	c7 05 24 42 21 f0 00 	movl   $0x0,0xf0214224
f01002fe:	00 00 00 
	while ((c = (*proc)()) != -1) {
f0100301:	ff d3                	call   *%ebx
f0100303:	89 c2                	mov    %eax,%edx
f0100305:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100308:	75 cd                	jne    f01002d7 <cons_intr+0xb>
	}
}
f010030a:	83 c4 04             	add    $0x4,%esp
f010030d:	5b                   	pop    %ebx
f010030e:	5d                   	pop    %ebp
f010030f:	c3                   	ret    

f0100310 <kbd_proc_data>:
f0100310:	ba 64 00 00 00       	mov    $0x64,%edx
f0100315:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100316:	a8 01                	test   $0x1,%al
f0100318:	0f 84 f7 00 00 00    	je     f0100415 <kbd_proc_data+0x105>
	if (stat & KBS_TERR)
f010031e:	a8 20                	test   $0x20,%al
f0100320:	0f 85 f5 00 00 00    	jne    f010041b <kbd_proc_data+0x10b>
f0100326:	b2 60                	mov    $0x60,%dl
f0100328:	ec                   	in     (%dx),%al
f0100329:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010032b:	3c e0                	cmp    $0xe0,%al
f010032d:	75 0d                	jne    f010033c <kbd_proc_data+0x2c>
		shift |= E0ESC;
f010032f:	83 0d 00 40 21 f0 40 	orl    $0x40,0xf0214000
		return 0;
f0100336:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010033b:	c3                   	ret    
{
f010033c:	55                   	push   %ebp
f010033d:	89 e5                	mov    %esp,%ebp
f010033f:	53                   	push   %ebx
f0100340:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
f0100343:	84 c0                	test   %al,%al
f0100345:	79 37                	jns    f010037e <kbd_proc_data+0x6e>
		data = (shift & E0ESC ? data : data & 0x7F);
f0100347:	8b 0d 00 40 21 f0    	mov    0xf0214000,%ecx
f010034d:	89 cb                	mov    %ecx,%ebx
f010034f:	83 e3 40             	and    $0x40,%ebx
f0100352:	83 e0 7f             	and    $0x7f,%eax
f0100355:	85 db                	test   %ebx,%ebx
f0100357:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010035a:	0f b6 d2             	movzbl %dl,%edx
f010035d:	0f b6 82 e0 71 10 f0 	movzbl -0xfef8e20(%edx),%eax
f0100364:	83 c8 40             	or     $0x40,%eax
f0100367:	0f b6 c0             	movzbl %al,%eax
f010036a:	f7 d0                	not    %eax
f010036c:	21 c1                	and    %eax,%ecx
f010036e:	89 0d 00 40 21 f0    	mov    %ecx,0xf0214000
		return 0;
f0100374:	b8 00 00 00 00       	mov    $0x0,%eax
f0100379:	e9 a3 00 00 00       	jmp    f0100421 <kbd_proc_data+0x111>
	} else if (shift & E0ESC) {
f010037e:	8b 0d 00 40 21 f0    	mov    0xf0214000,%ecx
f0100384:	f6 c1 40             	test   $0x40,%cl
f0100387:	74 0e                	je     f0100397 <kbd_proc_data+0x87>
		data |= 0x80;
f0100389:	83 c8 80             	or     $0xffffff80,%eax
f010038c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010038e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100391:	89 0d 00 40 21 f0    	mov    %ecx,0xf0214000
	shift |= shiftcode[data];
f0100397:	0f b6 d2             	movzbl %dl,%edx
f010039a:	0f b6 82 e0 71 10 f0 	movzbl -0xfef8e20(%edx),%eax
f01003a1:	0b 05 00 40 21 f0    	or     0xf0214000,%eax
	shift ^= togglecode[data];
f01003a7:	0f b6 8a e0 70 10 f0 	movzbl -0xfef8f20(%edx),%ecx
f01003ae:	31 c8                	xor    %ecx,%eax
f01003b0:	a3 00 40 21 f0       	mov    %eax,0xf0214000
	c = charcode[shift & (CTL | SHIFT)][data];
f01003b5:	89 c1                	mov    %eax,%ecx
f01003b7:	83 e1 03             	and    $0x3,%ecx
f01003ba:	8b 0c 8d c0 70 10 f0 	mov    -0xfef8f40(,%ecx,4),%ecx
f01003c1:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003c5:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003c8:	a8 08                	test   $0x8,%al
f01003ca:	74 1b                	je     f01003e7 <kbd_proc_data+0xd7>
		if ('a' <= c && c <= 'z')
f01003cc:	89 da                	mov    %ebx,%edx
f01003ce:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003d1:	83 f9 19             	cmp    $0x19,%ecx
f01003d4:	77 05                	ja     f01003db <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f01003d6:	83 eb 20             	sub    $0x20,%ebx
f01003d9:	eb 0c                	jmp    f01003e7 <kbd_proc_data+0xd7>
		else if ('A' <= c && c <= 'Z')
f01003db:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003de:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003e1:	83 fa 19             	cmp    $0x19,%edx
f01003e4:	0f 46 d9             	cmovbe %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003e7:	f7 d0                	not    %eax
f01003e9:	89 c2                	mov    %eax,%edx
	return c;
f01003eb:	89 d8                	mov    %ebx,%eax
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003ed:	f6 c2 06             	test   $0x6,%dl
f01003f0:	75 2f                	jne    f0100421 <kbd_proc_data+0x111>
f01003f2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003f8:	75 27                	jne    f0100421 <kbd_proc_data+0x111>
		cprintf("Rebooting!\n");
f01003fa:	c7 04 24 85 70 10 f0 	movl   $0xf0107085,(%esp)
f0100401:	e8 d5 3e 00 00       	call   f01042db <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100406:	ba 92 00 00 00       	mov    $0x92,%edx
f010040b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100410:	ee                   	out    %al,(%dx)
	return c;
f0100411:	89 d8                	mov    %ebx,%eax
f0100413:	eb 0c                	jmp    f0100421 <kbd_proc_data+0x111>
		return -1;
f0100415:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010041a:	c3                   	ret    
		return -1;
f010041b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100420:	c3                   	ret    
}
f0100421:	83 c4 14             	add    $0x14,%esp
f0100424:	5b                   	pop    %ebx
f0100425:	5d                   	pop    %ebp
f0100426:	c3                   	ret    

f0100427 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100427:	55                   	push   %ebp
f0100428:	89 e5                	mov    %esp,%ebp
f010042a:	57                   	push   %edi
f010042b:	56                   	push   %esi
f010042c:	53                   	push   %ebx
f010042d:	83 ec 1c             	sub    $0x1c,%esp
f0100430:	89 c7                	mov    %eax,%edi
f0100432:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100437:	be fd 03 00 00       	mov    $0x3fd,%esi
f010043c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100441:	eb 06                	jmp    f0100449 <cons_putc+0x22>
f0100443:	89 ca                	mov    %ecx,%edx
f0100445:	ec                   	in     (%dx),%al
f0100446:	ec                   	in     (%dx),%al
f0100447:	ec                   	in     (%dx),%al
f0100448:	ec                   	in     (%dx),%al
f0100449:	89 f2                	mov    %esi,%edx
f010044b:	ec                   	in     (%dx),%al
	for (i = 0;
f010044c:	a8 20                	test   $0x20,%al
f010044e:	75 05                	jne    f0100455 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100450:	83 eb 01             	sub    $0x1,%ebx
f0100453:	75 ee                	jne    f0100443 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100455:	89 f8                	mov    %edi,%eax
f0100457:	0f b6 c0             	movzbl %al,%eax
f010045a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100462:	ee                   	out    %al,(%dx)
f0100463:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100468:	be 79 03 00 00       	mov    $0x379,%esi
f010046d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100472:	eb 06                	jmp    f010047a <cons_putc+0x53>
f0100474:	89 ca                	mov    %ecx,%edx
f0100476:	ec                   	in     (%dx),%al
f0100477:	ec                   	in     (%dx),%al
f0100478:	ec                   	in     (%dx),%al
f0100479:	ec                   	in     (%dx),%al
f010047a:	89 f2                	mov    %esi,%edx
f010047c:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010047d:	84 c0                	test   %al,%al
f010047f:	78 05                	js     f0100486 <cons_putc+0x5f>
f0100481:	83 eb 01             	sub    $0x1,%ebx
f0100484:	75 ee                	jne    f0100474 <cons_putc+0x4d>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100486:	ba 78 03 00 00       	mov    $0x378,%edx
f010048b:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010048f:	ee                   	out    %al,(%dx)
f0100490:	b2 7a                	mov    $0x7a,%dl
f0100492:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100497:	ee                   	out    %al,(%dx)
f0100498:	b8 08 00 00 00       	mov    $0x8,%eax
f010049d:	ee                   	out    %al,(%dx)
    c |= color;
f010049e:	0b 3d 64 4a 21 f0    	or     0xf0214a64,%edi
f01004a4:	89 fa                	mov    %edi,%edx
	switch (c & 0xff) {
f01004a6:	0f b6 c2             	movzbl %dl,%eax
f01004a9:	83 f8 09             	cmp    $0x9,%eax
f01004ac:	74 71                	je     f010051f <cons_putc+0xf8>
f01004ae:	83 f8 09             	cmp    $0x9,%eax
f01004b1:	7f 0a                	jg     f01004bd <cons_putc+0x96>
f01004b3:	83 f8 08             	cmp    $0x8,%eax
f01004b6:	74 14                	je     f01004cc <cons_putc+0xa5>
f01004b8:	e9 96 00 00 00       	jmp    f0100553 <cons_putc+0x12c>
f01004bd:	83 f8 0a             	cmp    $0xa,%eax
f01004c0:	74 37                	je     f01004f9 <cons_putc+0xd2>
f01004c2:	83 f8 0d             	cmp    $0xd,%eax
f01004c5:	74 3a                	je     f0100501 <cons_putc+0xda>
f01004c7:	e9 87 00 00 00       	jmp    f0100553 <cons_putc+0x12c>
		if (crt_pos > 0) {
f01004cc:	0f b7 05 28 42 21 f0 	movzwl 0xf0214228,%eax
f01004d3:	66 85 c0             	test   %ax,%ax
f01004d6:	0f 84 e2 00 00 00    	je     f01005be <cons_putc+0x197>
			crt_pos--;
f01004dc:	83 e8 01             	sub    $0x1,%eax
f01004df:	66 a3 28 42 21 f0    	mov    %ax,0xf0214228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	b2 00                	mov    $0x0,%dl
f01004ea:	83 ca 20             	or     $0x20,%edx
f01004ed:	8b 0d 2c 42 21 f0    	mov    0xf021422c,%ecx
f01004f3:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004f7:	eb 78                	jmp    f0100571 <cons_putc+0x14a>
		crt_pos += CRT_COLS;
f01004f9:	66 83 05 28 42 21 f0 	addw   $0x50,0xf0214228
f0100500:	50 
		crt_pos -= (crt_pos % CRT_COLS);
f0100501:	0f b7 05 28 42 21 f0 	movzwl 0xf0214228,%eax
f0100508:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010050e:	c1 e8 16             	shr    $0x16,%eax
f0100511:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100514:	c1 e0 04             	shl    $0x4,%eax
f0100517:	66 a3 28 42 21 f0    	mov    %ax,0xf0214228
f010051d:	eb 52                	jmp    f0100571 <cons_putc+0x14a>
		cons_putc(' ');
f010051f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100524:	e8 fe fe ff ff       	call   f0100427 <cons_putc>
		cons_putc(' ');
f0100529:	b8 20 00 00 00       	mov    $0x20,%eax
f010052e:	e8 f4 fe ff ff       	call   f0100427 <cons_putc>
		cons_putc(' ');
f0100533:	b8 20 00 00 00       	mov    $0x20,%eax
f0100538:	e8 ea fe ff ff       	call   f0100427 <cons_putc>
		cons_putc(' ');
f010053d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100542:	e8 e0 fe ff ff       	call   f0100427 <cons_putc>
		cons_putc(' ');
f0100547:	b8 20 00 00 00       	mov    $0x20,%eax
f010054c:	e8 d6 fe ff ff       	call   f0100427 <cons_putc>
f0100551:	eb 1e                	jmp    f0100571 <cons_putc+0x14a>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100553:	0f b7 05 28 42 21 f0 	movzwl 0xf0214228,%eax
f010055a:	8d 48 01             	lea    0x1(%eax),%ecx
f010055d:	66 89 0d 28 42 21 f0 	mov    %cx,0xf0214228
f0100564:	0f b7 c0             	movzwl %ax,%eax
f0100567:	8b 0d 2c 42 21 f0    	mov    0xf021422c,%ecx
f010056d:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
	if (crt_pos >= CRT_SIZE) {
f0100571:	66 81 3d 28 42 21 f0 	cmpw   $0x7cf,0xf0214228
f0100578:	cf 07 
f010057a:	76 42                	jbe    f01005be <cons_putc+0x197>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010057c:	a1 2c 42 21 f0       	mov    0xf021422c,%eax
f0100581:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100588:	00 
f0100589:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010058f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100593:	89 04 24             	mov    %eax,(%esp)
f0100596:	e8 39 5d 00 00       	call   f01062d4 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010059b:	8b 15 2c 42 21 f0    	mov    0xf021422c,%edx
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a1:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005a6:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005ac:	83 c0 01             	add    $0x1,%eax
f01005af:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005b4:	75 f0                	jne    f01005a6 <cons_putc+0x17f>
		crt_pos -= CRT_COLS;
f01005b6:	66 83 2d 28 42 21 f0 	subw   $0x50,0xf0214228
f01005bd:	50 
	outb(addr_6845, 14);
f01005be:	8b 0d 30 42 21 f0    	mov    0xf0214230,%ecx
f01005c4:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005c9:	89 ca                	mov    %ecx,%edx
f01005cb:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005cc:	0f b7 1d 28 42 21 f0 	movzwl 0xf0214228,%ebx
f01005d3:	8d 71 01             	lea    0x1(%ecx),%esi
f01005d6:	89 d8                	mov    %ebx,%eax
f01005d8:	66 c1 e8 08          	shr    $0x8,%ax
f01005dc:	89 f2                	mov    %esi,%edx
f01005de:	ee                   	out    %al,(%dx)
f01005df:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005e4:	89 ca                	mov    %ecx,%edx
f01005e6:	ee                   	out    %al,(%dx)
f01005e7:	89 d8                	mov    %ebx,%eax
f01005e9:	89 f2                	mov    %esi,%edx
f01005eb:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005ec:	83 c4 1c             	add    $0x1c,%esp
f01005ef:	5b                   	pop    %ebx
f01005f0:	5e                   	pop    %esi
f01005f1:	5f                   	pop    %edi
f01005f2:	5d                   	pop    %ebp
f01005f3:	c3                   	ret    

f01005f4 <serial_intr>:
	if (serial_exists)
f01005f4:	80 3d 34 42 21 f0 00 	cmpb   $0x0,0xf0214234
f01005fb:	74 11                	je     f010060e <serial_intr+0x1a>
{
f01005fd:	55                   	push   %ebp
f01005fe:	89 e5                	mov    %esp,%ebp
f0100600:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100603:	b8 b0 02 10 f0       	mov    $0xf01002b0,%eax
f0100608:	e8 bf fc ff ff       	call   f01002cc <cons_intr>
}
f010060d:	c9                   	leave  
f010060e:	f3 c3                	repz ret 

f0100610 <kbd_intr>:
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100616:	b8 10 03 10 f0       	mov    $0xf0100310,%eax
f010061b:	e8 ac fc ff ff       	call   f01002cc <cons_intr>
}
f0100620:	c9                   	leave  
f0100621:	c3                   	ret    

f0100622 <cons_getc>:
{
f0100622:	55                   	push   %ebp
f0100623:	89 e5                	mov    %esp,%ebp
f0100625:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100628:	e8 c7 ff ff ff       	call   f01005f4 <serial_intr>
	kbd_intr();
f010062d:	e8 de ff ff ff       	call   f0100610 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100632:	a1 20 42 21 f0       	mov    0xf0214220,%eax
f0100637:	3b 05 24 42 21 f0    	cmp    0xf0214224,%eax
f010063d:	74 26                	je     f0100665 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010063f:	8d 50 01             	lea    0x1(%eax),%edx
f0100642:	89 15 20 42 21 f0    	mov    %edx,0xf0214220
f0100648:	0f b6 88 20 40 21 f0 	movzbl -0xfdebfe0(%eax),%ecx
		return c;
f010064f:	89 c8                	mov    %ecx,%eax
		if (cons.rpos == CONSBUFSIZE)
f0100651:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100657:	75 11                	jne    f010066a <cons_getc+0x48>
			cons.rpos = 0;
f0100659:	c7 05 20 42 21 f0 00 	movl   $0x0,0xf0214220
f0100660:	00 00 00 
f0100663:	eb 05                	jmp    f010066a <cons_getc+0x48>
	return 0;
f0100665:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010066a:	c9                   	leave  
f010066b:	c3                   	ret    

f010066c <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010066c:	55                   	push   %ebp
f010066d:	89 e5                	mov    %esp,%ebp
f010066f:	57                   	push   %edi
f0100670:	56                   	push   %esi
f0100671:	53                   	push   %ebx
f0100672:	83 ec 1c             	sub    $0x1c,%esp
	was = *cp;
f0100675:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010067c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100683:	5a a5 
	if (*cp != 0xA55A) {
f0100685:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010068c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100690:	74 11                	je     f01006a3 <cons_init+0x37>
		addr_6845 = MONO_BASE;
f0100692:	c7 05 30 42 21 f0 b4 	movl   $0x3b4,0xf0214230
f0100699:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069c:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006a1:	eb 16                	jmp    f01006b9 <cons_init+0x4d>
		*cp = was;
f01006a3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006aa:	c7 05 30 42 21 f0 d4 	movl   $0x3d4,0xf0214230
f01006b1:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b4:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
	outb(addr_6845, 14);
f01006b9:	8b 0d 30 42 21 f0    	mov    0xf0214230,%ecx
f01006bf:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c4:	89 ca                	mov    %ecx,%edx
f01006c6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006c7:	8d 59 01             	lea    0x1(%ecx),%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ca:	89 da                	mov    %ebx,%edx
f01006cc:	ec                   	in     (%dx),%al
f01006cd:	0f b6 f0             	movzbl %al,%esi
f01006d0:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006d8:	89 ca                	mov    %ecx,%edx
f01006da:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006db:	89 da                	mov    %ebx,%edx
f01006dd:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006de:	89 3d 2c 42 21 f0    	mov    %edi,0xf021422c
	pos |= inb(addr_6845 + 1);
f01006e4:	0f b6 d8             	movzbl %al,%ebx
f01006e7:	09 de                	or     %ebx,%esi
	crt_pos = pos;
f01006e9:	66 89 35 28 42 21 f0 	mov    %si,0xf0214228
	kbd_intr();
f01006f0:	e8 1b ff ff ff       	call   f0100610 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006f5:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006fc:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100701:	89 04 24             	mov    %eax,(%esp)
f0100704:	e8 93 3a 00 00       	call   f010419c <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100709:	be fa 03 00 00       	mov    $0x3fa,%esi
f010070e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100713:	89 f2                	mov    %esi,%edx
f0100715:	ee                   	out    %al,(%dx)
f0100716:	b2 fb                	mov    $0xfb,%dl
f0100718:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010071d:	ee                   	out    %al,(%dx)
f010071e:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100723:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100728:	89 da                	mov    %ebx,%edx
f010072a:	ee                   	out    %al,(%dx)
f010072b:	b2 f9                	mov    $0xf9,%dl
f010072d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100732:	ee                   	out    %al,(%dx)
f0100733:	b2 fb                	mov    $0xfb,%dl
f0100735:	b8 03 00 00 00       	mov    $0x3,%eax
f010073a:	ee                   	out    %al,(%dx)
f010073b:	b2 fc                	mov    $0xfc,%dl
f010073d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100742:	ee                   	out    %al,(%dx)
f0100743:	b2 f9                	mov    $0xf9,%dl
f0100745:	b8 01 00 00 00       	mov    $0x1,%eax
f010074a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074b:	b2 fd                	mov    $0xfd,%dl
f010074d:	ec                   	in     (%dx),%al
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010074e:	3c ff                	cmp    $0xff,%al
f0100750:	0f 95 c1             	setne  %cl
f0100753:	88 0d 34 42 21 f0    	mov    %cl,0xf0214234
f0100759:	89 f2                	mov    %esi,%edx
f010075b:	ec                   	in     (%dx),%al
f010075c:	89 da                	mov    %ebx,%edx
f010075e:	ec                   	in     (%dx),%al
	if (serial_exists)
f010075f:	84 c9                	test   %cl,%cl
f0100761:	74 1d                	je     f0100780 <cons_init+0x114>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100763:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010076a:	25 ef ff 00 00       	and    $0xffef,%eax
f010076f:	89 04 24             	mov    %eax,(%esp)
f0100772:	e8 25 3a 00 00       	call   f010419c <irq_setmask_8259A>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100777:	80 3d 34 42 21 f0 00 	cmpb   $0x0,0xf0214234
f010077e:	75 0c                	jne    f010078c <cons_init+0x120>
		cprintf("Serial port does not exist!\n");
f0100780:	c7 04 24 91 70 10 f0 	movl   $0xf0107091,(%esp)
f0100787:	e8 4f 3b 00 00       	call   f01042db <cprintf>
}
f010078c:	83 c4 1c             	add    $0x1c,%esp
f010078f:	5b                   	pop    %ebx
f0100790:	5e                   	pop    %esi
f0100791:	5f                   	pop    %edi
f0100792:	5d                   	pop    %ebp
f0100793:	c3                   	ret    

f0100794 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100794:	55                   	push   %ebp
f0100795:	89 e5                	mov    %esp,%ebp
f0100797:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079a:	8b 45 08             	mov    0x8(%ebp),%eax
f010079d:	e8 85 fc ff ff       	call   f0100427 <cons_putc>
}
f01007a2:	c9                   	leave  
f01007a3:	c3                   	ret    

f01007a4 <getchar>:

int
getchar(void)
{
f01007a4:	55                   	push   %ebp
f01007a5:	89 e5                	mov    %esp,%ebp
f01007a7:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007aa:	e8 73 fe ff ff       	call   f0100622 <cons_getc>
f01007af:	85 c0                	test   %eax,%eax
f01007b1:	74 f7                	je     f01007aa <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b3:	c9                   	leave  
f01007b4:	c3                   	ret    

f01007b5 <iscons>:

int
iscons(int fdnum)
{
f01007b5:	55                   	push   %ebp
f01007b6:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007bd:	5d                   	pop    %ebp
f01007be:	c3                   	ret    
f01007bf:	90                   	nop

f01007c0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

    int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c0:	55                   	push   %ebp
f01007c1:	89 e5                	mov    %esp,%ebp
f01007c3:	56                   	push   %esi
f01007c4:	53                   	push   %ebx
f01007c5:	83 ec 10             	sub    $0x10,%esp
f01007c8:	bb 04 78 10 f0       	mov    $0xf0107804,%ebx
f01007cd:	be 4c 78 10 f0       	mov    $0xf010784c,%esi
    int i;

    for (i = 0; i < ARRAY_SIZE(commands); i++)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007d2:	8b 03                	mov    (%ebx),%eax
f01007d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d8:	8b 43 fc             	mov    -0x4(%ebx),%eax
f01007db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007df:	c7 04 24 e0 72 10 f0 	movl   $0xf01072e0,(%esp)
f01007e6:	e8 f0 3a 00 00       	call   f01042db <cprintf>
f01007eb:	83 c3 0c             	add    $0xc,%ebx
    for (i = 0; i < ARRAY_SIZE(commands); i++)
f01007ee:	39 f3                	cmp    %esi,%ebx
f01007f0:	75 e0                	jne    f01007d2 <mon_help+0x12>
    return 0;
}
f01007f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f7:	83 c4 10             	add    $0x10,%esp
f01007fa:	5b                   	pop    %ebx
f01007fb:	5e                   	pop    %esi
f01007fc:	5d                   	pop    %ebp
f01007fd:	c3                   	ret    

f01007fe <mon_kerninfo>:

    int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007fe:	55                   	push   %ebp
f01007ff:	89 e5                	mov    %esp,%ebp
f0100801:	83 ec 18             	sub    $0x18,%esp
    extern char _start[], entry[], etext[], edata[], end[];

    cprintf("Special kernel symbols:\n");
f0100804:	c7 04 24 e9 72 10 f0 	movl   $0xf01072e9,(%esp)
f010080b:	e8 cb 3a 00 00       	call   f01042db <cprintf>
    cprintf("  _start                  %08x (phys)\n", _start);
f0100810:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100817:	00 
f0100818:	c7 04 24 5c 74 10 f0 	movl   $0xf010745c,(%esp)
f010081f:	e8 b7 3a 00 00       	call   f01042db <cprintf>
    cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100824:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010082b:	00 
f010082c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100833:	f0 
f0100834:	c7 04 24 84 74 10 f0 	movl   $0xf0107484,(%esp)
f010083b:	e8 9b 3a 00 00       	call   f01042db <cprintf>
    cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100840:	c7 44 24 08 a7 6f 10 	movl   $0x106fa7,0x8(%esp)
f0100847:	00 
f0100848:	c7 44 24 04 a7 6f 10 	movl   $0xf0106fa7,0x4(%esp)
f010084f:	f0 
f0100850:	c7 04 24 a8 74 10 f0 	movl   $0xf01074a8,(%esp)
f0100857:	e8 7f 3a 00 00       	call   f01042db <cprintf>
    cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010085c:	c7 44 24 08 00 40 21 	movl   $0x214000,0x8(%esp)
f0100863:	00 
f0100864:	c7 44 24 04 00 40 21 	movl   $0xf0214000,0x4(%esp)
f010086b:	f0 
f010086c:	c7 04 24 cc 74 10 f0 	movl   $0xf01074cc,(%esp)
f0100873:	e8 63 3a 00 00       	call   f01042db <cprintf>
    cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100878:	c7 44 24 08 08 60 25 	movl   $0x256008,0x8(%esp)
f010087f:	00 
f0100880:	c7 44 24 04 08 60 25 	movl   $0xf0256008,0x4(%esp)
f0100887:	f0 
f0100888:	c7 04 24 f0 74 10 f0 	movl   $0xf01074f0,(%esp)
f010088f:	e8 47 3a 00 00       	call   f01042db <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            ROUNDUP(end - entry, 1024) / 1024);
f0100894:	b8 07 64 25 f0       	mov    $0xf0256407,%eax
f0100899:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010089e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
    cprintf("Kernel executable memory footprint: %dKB\n",
f01008a3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008a9:	85 c0                	test   %eax,%eax
f01008ab:	0f 48 c2             	cmovs  %edx,%eax
f01008ae:	c1 f8 0a             	sar    $0xa,%eax
f01008b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b5:	c7 04 24 14 75 10 f0 	movl   $0xf0107514,(%esp)
f01008bc:	e8 1a 3a 00 00       	call   f01042db <cprintf>
    return 0;
}
f01008c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c6:	c9                   	leave  
f01008c7:	c3                   	ret    

f01008c8 <mon_backtrace>:

    int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c8:	55                   	push   %ebp
f01008c9:	89 e5                	mov    %esp,%ebp
f01008cb:	56                   	push   %esi
f01008cc:	53                   	push   %ebx
f01008cd:	83 ec 40             	sub    $0x40,%esp
    // LAB 1: Your code here.
    // HINT 1: use read_ebp().
    // HINT 2: print the current ebp on the first line (not current_ebp[0])
    uint32_t *ebp;

    cprintf("Stack backtrace:\n");
f01008d0:	c7 04 24 02 73 10 f0 	movl   $0xf0107302,(%esp)
f01008d7:	e8 ff 39 00 00       	call   f01042db <cprintf>
    struct Eipdebuginfo ed;

    ebp = ((uint32_t*)read_ebp());
f01008dc:	89 eb                	mov    %ebp,%ebx

    while(ebp){
        cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
                ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);

        debuginfo_eip(ebp[1], &ed);
f01008de:	8d 75 e0             	lea    -0x20(%ebp),%esi
    while(ebp){
f01008e1:	eb 7d                	jmp    f0100960 <mon_backtrace+0x98>
        cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
f01008e3:	8b 43 18             	mov    0x18(%ebx),%eax
f01008e6:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01008ea:	8b 43 14             	mov    0x14(%ebx),%eax
f01008ed:	89 44 24 18          	mov    %eax,0x18(%esp)
f01008f1:	8b 43 10             	mov    0x10(%ebx),%eax
f01008f4:	89 44 24 14          	mov    %eax,0x14(%esp)
f01008f8:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008fb:	89 44 24 10          	mov    %eax,0x10(%esp)
f01008ff:	8b 43 08             	mov    0x8(%ebx),%eax
f0100902:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100906:	8b 43 04             	mov    0x4(%ebx),%eax
f0100909:	89 44 24 08          	mov    %eax,0x8(%esp)
f010090d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100911:	c7 04 24 40 75 10 f0 	movl   $0xf0107540,(%esp)
f0100918:	e8 be 39 00 00       	call   f01042db <cprintf>
        debuginfo_eip(ebp[1], &ed);
f010091d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100921:	8b 43 04             	mov    0x4(%ebx),%eax
f0100924:	89 04 24             	mov    %eax,(%esp)
f0100927:	e8 14 4e 00 00       	call   f0105740 <debuginfo_eip>
        cprintf("\t%s:%d: %.*s+%d\n", ed.eip_file, ed.eip_line, ed.eip_fn_namelen,ed.eip_fn_name, ebp[1]-ed.eip_fn_addr);
f010092c:	8b 43 04             	mov    0x4(%ebx),%eax
f010092f:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100932:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100936:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100939:	89 44 24 10          	mov    %eax,0x10(%esp)
f010093d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100940:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100944:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100947:	89 44 24 08          	mov    %eax,0x8(%esp)
f010094b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010094e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100952:	c7 04 24 14 73 10 f0 	movl   $0xf0107314,(%esp)
f0100959:	e8 7d 39 00 00       	call   f01042db <cprintf>
        ebp = (uint32_t *)(*ebp); // Go "UP" the stack, reminder that the stack increments when we want to read it.
f010095e:	8b 1b                	mov    (%ebx),%ebx
    while(ebp){
f0100960:	85 db                	test   %ebx,%ebx
f0100962:	0f 85 7b ff ff ff    	jne    f01008e3 <mon_backtrace+0x1b>
    }
    return 0;
}
f0100968:	b8 00 00 00 00       	mov    $0x0,%eax
f010096d:	83 c4 40             	add    $0x40,%esp
f0100970:	5b                   	pop    %ebx
f0100971:	5e                   	pop    %esi
f0100972:	5d                   	pop    %ebp
f0100973:	c3                   	ret    

f0100974 <mon_showmapping>:
    return 0;

}

int
mon_showmapping(int argc, char **argv, struct Trapframe *tf){
f0100974:	55                   	push   %ebp
f0100975:	89 e5                	mov    %esp,%ebp
f0100977:	57                   	push   %edi
f0100978:	56                   	push   %esi
f0100979:	53                   	push   %ebx
f010097a:	83 ec 1c             	sub    $0x1c,%esp
f010097d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

    if(argc != 3){
f0100980:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100984:	74 1c                	je     f01009a2 <mon_showmapping+0x2e>
        panic("We cannot do showmapping with these parameters\n The format is: showmapping start_va end_va\n");
f0100986:	c7 44 24 08 74 75 10 	movl   $0xf0107574,0x8(%esp)
f010098d:	f0 
f010098e:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
f0100995:	00 
f0100996:	c7 04 24 25 73 10 f0 	movl   $0xf0107325,(%esp)
f010099d:	e8 9e f6 ff ff       	call   f0100040 <_panic>
    }



    uintptr_t start_va = ROUNDDOWN(strtol(argv[1], NULL, 0), PGSIZE); // Someone on the Discord gave me this advice for converting into base16.
f01009a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01009a9:	00 
f01009aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009b1:	00 
f01009b2:	8b 43 04             	mov    0x4(%ebx),%eax
f01009b5:	89 04 24             	mov    %eax,(%esp)
f01009b8:	e8 f6 59 00 00       	call   f01063b3 <strtol>
f01009bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009c2:	89 c6                	mov    %eax,%esi
    uintptr_t end_va = ROUNDUP(strtol(argv[2], NULL, 0), PGSIZE);
f01009c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01009cb:	00 
f01009cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009d3:	00 
f01009d4:	8b 43 08             	mov    0x8(%ebx),%eax
f01009d7:	89 04 24             	mov    %eax,(%esp)
f01009da:	e8 d4 59 00 00       	call   f01063b3 <strtol>
f01009df:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01009e5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    uintptr_t pageoffset = 0x1000;
    cprintf("Start_va: %p, End_va: %p\n", start_va, end_va);
f01009eb:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009ef:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009f3:	c7 04 24 34 73 10 f0 	movl   $0xf0107334,(%esp)
f01009fa:	e8 dc 38 00 00       	call   f01042db <cprintf>

    for(; start_va <= end_va; start_va += PGSIZE){
f01009ff:	e9 91 00 00 00       	jmp    f0100a95 <mon_showmapping+0x121>
        pte_t *pte;
        //page_lookup(kern_pgdir, (void *)start_va, &pte); // I'm not sure if we'll need this.
        pte = pgdir_walk(kern_pgdir, (void *)start_va, 0);
f0100a04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a0b:	00 
f0100a0c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a10:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0100a15:	89 04 24             	mov    %eax,(%esp)
f0100a18:	e8 69 0b 00 00       	call   f0101586 <pgdir_walk>
f0100a1d:	89 c3                	mov    %eax,%ebx
        if(pte){
f0100a1f:	85 c0                	test   %eax,%eax
f0100a21:	74 5c                	je     f0100a7f <mon_showmapping+0x10b>
            cprintf("VA: 0x%x maps to 0x%x\n  Permissions: [ ", start_va,PTE_ADDR(*pte));
f0100a23:	8b 00                	mov    (%eax),%eax
f0100a25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a2e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a32:	c7 04 24 d0 75 10 f0 	movl   $0xf01075d0,(%esp)
f0100a39:	e8 9d 38 00 00       	call   f01042db <cprintf>
            if(*pte & PTE_P) cprintf("P ");
f0100a3e:	f6 03 01             	testb  $0x1,(%ebx)
f0100a41:	74 0c                	je     f0100a4f <mon_showmapping+0xdb>
f0100a43:	c7 04 24 4e 73 10 f0 	movl   $0xf010734e,(%esp)
f0100a4a:	e8 8c 38 00 00       	call   f01042db <cprintf>
            if(*pte & PTE_U) cprintf("U ");
f0100a4f:	f6 03 04             	testb  $0x4,(%ebx)
f0100a52:	74 0c                	je     f0100a60 <mon_showmapping+0xec>
f0100a54:	c7 04 24 51 73 10 f0 	movl   $0xf0107351,(%esp)
f0100a5b:	e8 7b 38 00 00       	call   f01042db <cprintf>
            if(*pte & PTE_W) cprintf("W ");
f0100a60:	f6 03 02             	testb  $0x2,(%ebx)
f0100a63:	74 0c                	je     f0100a71 <mon_showmapping+0xfd>
f0100a65:	c7 04 24 54 73 10 f0 	movl   $0xf0107354,(%esp)
f0100a6c:	e8 6a 38 00 00       	call   f01042db <cprintf>
            if(*pte & PTE_PCD) cprintf("PCD ");
            if(*pte & PTE_A) cprintf("A ");
            if(*pte & PTE_D) cprintf("D ");
            if(*pte & PTE_PS) cprintf("PS ");
            if(*pte & PTE_G) cprintf("G ");*/
            cprintf("]\n");
f0100a71:	c7 04 24 f6 86 10 f0 	movl   $0xf01086f6,(%esp)
f0100a78:	e8 5e 38 00 00       	call   f01042db <cprintf>
f0100a7d:	eb 10                	jmp    f0100a8f <mon_showmapping+0x11b>
        }
        else{
            cprintf("Location at %p does not have a valid page\n", start_va);
f0100a7f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a83:	c7 04 24 f8 75 10 f0 	movl   $0xf01075f8,(%esp)
f0100a8a:	e8 4c 38 00 00       	call   f01042db <cprintf>
    for(; start_va <= end_va; start_va += PGSIZE){
f0100a8f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100a95:	39 fe                	cmp    %edi,%esi
f0100a97:	0f 86 67 ff ff ff    	jbe    f0100a04 <mon_showmapping+0x90>
        }
    }
    return 0;
}
f0100a9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aa2:	83 c4 1c             	add    $0x1c,%esp
f0100aa5:	5b                   	pop    %ebx
f0100aa6:	5e                   	pop    %esi
f0100aa7:	5f                   	pop    %edi
f0100aa8:	5d                   	pop    %ebp
f0100aa9:	c3                   	ret    

f0100aaa <mon_setperms>:
mon_setperms(int argc, char **argv, struct Trapframe *tf){
f0100aaa:	55                   	push   %ebp
f0100aab:	89 e5                	mov    %esp,%ebp
f0100aad:	56                   	push   %esi
f0100aae:	53                   	push   %ebx
f0100aaf:	83 ec 10             	sub    $0x10,%esp
f0100ab2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    uintptr_t va = strtol(argv[2], NULL, 0);
f0100ab5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100abc:	00 
f0100abd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ac4:	00 
f0100ac5:	8b 43 08             	mov    0x8(%ebx),%eax
f0100ac8:	89 04 24             	mov    %eax,(%esp)
f0100acb:	e8 e3 58 00 00       	call   f01063b3 <strtol>
    pte = pgdir_walk(kern_pgdir, (void *)va, 0);
f0100ad0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ad7:	00 
f0100ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100adc:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0100ae1:	89 04 24             	mov    %eax,(%esp)
f0100ae4:	e8 9d 0a 00 00       	call   f0101586 <pgdir_walk>
    if(argc <= 1) {
f0100ae9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100aed:	7f 28                	jg     f0100b17 <mon_setperms+0x6d>
        cprintf("Format required\n");
f0100aef:	c7 04 24 57 73 10 f0 	movl   $0xf0107357,(%esp)
f0100af6:	e8 e0 37 00 00       	call   f01042db <cprintf>
        panic("setperms clear va OR setperms set va [W|U|P]\n");
f0100afb:	c7 44 24 08 24 76 10 	movl   $0xf0107624,0x8(%esp)
f0100b02:	f0 
f0100b03:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
f0100b0a:	00 
f0100b0b:	c7 04 24 25 73 10 f0 	movl   $0xf0107325,(%esp)
f0100b12:	e8 29 f5 ff ff       	call   f0100040 <_panic>
f0100b17:	89 c6                	mov    %eax,%esi
    if(!pte){
f0100b19:	85 c0                	test   %eax,%eax
f0100b1b:	75 1c                	jne    f0100b39 <mon_setperms+0x8f>
        panic("The given address does not have a page mapped\n");
f0100b1d:	c7 44 24 08 54 76 10 	movl   $0xf0107654,0x8(%esp)
f0100b24:	f0 
f0100b25:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
f0100b2c:	00 
f0100b2d:	c7 04 24 25 73 10 f0 	movl   $0xf0107325,(%esp)
f0100b34:	e8 07 f5 ff ff       	call   f0100040 <_panic>
    if(strcmp(argv[1], "clear") == 0){
f0100b39:	c7 44 24 04 68 73 10 	movl   $0xf0107368,0x4(%esp)
f0100b40:	f0 
f0100b41:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b44:	89 04 24             	mov    %eax,(%esp)
f0100b47:	e8 a0 56 00 00       	call   f01061ec <strcmp>
f0100b4c:	85 c0                	test   %eax,%eax
f0100b4e:	75 11                	jne    f0100b61 <mon_setperms+0xb7>
        cprintf("Clearing\n");
f0100b50:	c7 04 24 6e 73 10 f0 	movl   $0xf010736e,(%esp)
f0100b57:	e8 7f 37 00 00       	call   f01042db <cprintf>
        *pte &= ~0x7;
f0100b5c:	83 26 f8             	andl   $0xfffffff8,(%esi)
f0100b5f:	eb 50                	jmp    f0100bb1 <mon_setperms+0x107>
    else if(strcmp(argv[1], "set") == 0){
f0100b61:	c7 44 24 04 78 73 10 	movl   $0xf0107378,0x4(%esp)
f0100b68:	f0 
f0100b69:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b6c:	89 04 24             	mov    %eax,(%esp)
f0100b6f:	e8 78 56 00 00       	call   f01061ec <strcmp>
f0100b74:	85 c0                	test   %eax,%eax
f0100b76:	75 39                	jne    f0100bb1 <mon_setperms+0x107>
        *pte &= ~0x7;
f0100b78:	83 26 f8             	andl   $0xfffffff8,(%esi)
        int i = 1;
f0100b7b:	ba 01 00 00 00       	mov    $0x1,%edx
        while(argv[3][i]){
f0100b80:	eb 22                	jmp    f0100ba4 <mon_setperms+0xfa>
            if(argv[3][i] == 'P') *pte |= PTE_P;
f0100b82:	3c 50                	cmp    $0x50,%al
f0100b84:	75 03                	jne    f0100b89 <mon_setperms+0xdf>
f0100b86:	83 0e 01             	orl    $0x1,(%esi)
            if(argv[3][i] == 'U') *pte |= PTE_U;
f0100b89:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100b8c:	80 3c 08 55          	cmpb   $0x55,(%eax,%ecx,1)
f0100b90:	75 03                	jne    f0100b95 <mon_setperms+0xeb>
f0100b92:	83 0e 04             	orl    $0x4,(%esi)
            if(argv[3][i] == 'W') *pte |= PTE_W;
f0100b95:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100b98:	80 3c 08 57          	cmpb   $0x57,(%eax,%ecx,1)
f0100b9c:	75 03                	jne    f0100ba1 <mon_setperms+0xf7>
f0100b9e:	83 0e 02             	orl    $0x2,(%esi)
            i += 2;
f0100ba1:	83 c2 02             	add    $0x2,%edx
        while(argv[3][i]){
f0100ba4:	89 d1                	mov    %edx,%ecx
f0100ba6:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100ba9:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
f0100bad:	84 c0                	test   %al,%al
f0100baf:	75 d1                	jne    f0100b82 <mon_setperms+0xd8>
}
f0100bb1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bb6:	83 c4 10             	add    $0x10,%esp
f0100bb9:	5b                   	pop    %ebx
f0100bba:	5e                   	pop    %esi
f0100bbb:	5d                   	pop    %ebp
f0100bbc:	c3                   	ret    

f0100bbd <dumpmemhelper>:
dumpmemhelper(void* start_va, void* end_va){
f0100bbd:	55                   	push   %ebp
f0100bbe:	89 e5                	mov    %esp,%ebp
f0100bc0:	56                   	push   %esi
f0100bc1:	53                   	push   %ebx
f0100bc2:	83 ec 10             	sub    $0x10,%esp
f0100bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100bc8:	8b 75 0c             	mov    0xc(%ebp),%esi
    for(; start_va <= end_va; start_va += 4) {// We need to add a byte
f0100bcb:	eb 48                	jmp    f0100c15 <dumpmemhelper+0x58>
        pte_t *pte = pgdir_walk(kern_pgdir, start_va, 0);
f0100bcd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100bd4:	00 
f0100bd5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100bd9:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0100bde:	89 04 24             	mov    %eax,(%esp)
f0100be1:	e8 a0 09 00 00       	call   f0101586 <pgdir_walk>
        if(!pte) cprintf("Inaccessible @ 0x%x\n", start_va);
f0100be6:	85 c0                	test   %eax,%eax
f0100be8:	75 12                	jne    f0100bfc <dumpmemhelper+0x3f>
f0100bea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100bee:	c7 04 24 7c 73 10 f0 	movl   $0xf010737c,(%esp)
f0100bf5:	e8 e1 36 00 00       	call   f01042db <cprintf>
f0100bfa:	eb 16                	jmp    f0100c12 <dumpmemhelper+0x55>
            cprintf("Address: 0x%x Found 0x%x\n", start_va, *(uint32_t*)start_va);
f0100bfc:	8b 03                	mov    (%ebx),%eax
f0100bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c06:	c7 04 24 91 73 10 f0 	movl   $0xf0107391,(%esp)
f0100c0d:	e8 c9 36 00 00       	call   f01042db <cprintf>
    for(; start_va <= end_va; start_va += 4) {// We need to add a byte
f0100c12:	83 c3 04             	add    $0x4,%ebx
f0100c15:	39 f3                	cmp    %esi,%ebx
f0100c17:	76 b4                	jbe    f0100bcd <dumpmemhelper+0x10>
}
f0100c19:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c1e:	83 c4 10             	add    $0x10,%esp
f0100c21:	5b                   	pop    %ebx
f0100c22:	5e                   	pop    %esi
f0100c23:	5d                   	pop    %ebp
f0100c24:	c3                   	ret    

f0100c25 <mon_dumpmem>:
mon_dumpmem(int argc, char**argv, struct Trapframe *tf){
f0100c25:	55                   	push   %ebp
f0100c26:	89 e5                	mov    %esp,%ebp
f0100c28:	57                   	push   %edi
f0100c29:	56                   	push   %esi
f0100c2a:	53                   	push   %ebx
f0100c2b:	83 ec 1c             	sub    $0x1c,%esp
f0100c2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if(argc != 4){
f0100c31:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100c35:	74 28                	je     f0100c5f <mon_dumpmem+0x3a>
        cprintf("We cannot do mon_dumpmem with these parameters\n");
f0100c37:	c7 04 24 84 76 10 f0 	movl   $0xf0107684,(%esp)
f0100c3e:	e8 98 36 00 00       	call   f01042db <cprintf>
        panic("Format: dumpmem va start_va end_va OR dumpmem pa start_pa end_pa\n");
f0100c43:	c7 44 24 08 b4 76 10 	movl   $0xf01076b4,0x8(%esp)
f0100c4a:	f0 
f0100c4b:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f0100c52:	00 
f0100c53:	c7 04 24 25 73 10 f0 	movl   $0xf0107325,(%esp)
f0100c5a:	e8 e1 f3 ff ff       	call   f0100040 <_panic>
    uintptr_t start_va = strtol(argv[2], NULL, 0);
f0100c5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c66:	00 
f0100c67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c6e:	00 
f0100c6f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c72:	89 04 24             	mov    %eax,(%esp)
f0100c75:	e8 39 57 00 00       	call   f01063b3 <strtol>
f0100c7a:	89 c6                	mov    %eax,%esi
    uintptr_t end_va = strtol(argv[3], NULL, 0);
f0100c7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c83:	00 
f0100c84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c8b:	00 
f0100c8c:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100c8f:	89 04 24             	mov    %eax,(%esp)
f0100c92:	e8 1c 57 00 00       	call   f01063b3 <strtol>
f0100c97:	89 c7                	mov    %eax,%edi
    if(strcmp(argv[1], "pa") == 0){
f0100c99:	c7 44 24 04 ab 73 10 	movl   $0xf01073ab,0x4(%esp)
f0100ca0:	f0 
f0100ca1:	8b 43 04             	mov    0x4(%ebx),%eax
f0100ca4:	89 04 24             	mov    %eax,(%esp)
f0100ca7:	e8 40 55 00 00       	call   f01061ec <strcmp>
f0100cac:	85 c0                	test   %eax,%eax
f0100cae:	75 71                	jne    f0100d21 <mon_dumpmem+0xfc>
	if (PGNUM(pa) >= npages)
f0100cb0:	a1 88 4e 21 f0       	mov    0xf0214e88,%eax
f0100cb5:	89 fa                	mov    %edi,%edx
f0100cb7:	c1 ea 0c             	shr    $0xc,%edx
f0100cba:	39 c2                	cmp    %eax,%edx
f0100cbc:	72 20                	jb     f0100cde <mon_dumpmem+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cbe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0100cc2:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0100cc9:	f0 
f0100cca:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
f0100cd1:	00 
f0100cd2:	c7 04 24 25 73 10 f0 	movl   $0xf0107325,(%esp)
f0100cd9:	e8 62 f3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100cde:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (PGNUM(pa) >= npages)
f0100ce4:	89 f2                	mov    %esi,%edx
f0100ce6:	c1 ea 0c             	shr    $0xc,%edx
f0100ce9:	39 d0                	cmp    %edx,%eax
f0100ceb:	77 20                	ja     f0100d0d <mon_dumpmem+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ced:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100cf1:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0100cf8:	f0 
f0100cf9:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
f0100d00:	00 
f0100d01:	c7 04 24 25 73 10 f0 	movl   $0xf0107325,(%esp)
f0100d08:	e8 33 f3 ff ff       	call   f0100040 <_panic>
       dumpmemhelper(KADDR(start_va2), KADDR(end_va2));
f0100d0d:	89 7c 24 04          	mov    %edi,0x4(%esp)
	return (void *)(pa + KERNBASE);
f0100d11:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0100d17:	89 34 24             	mov    %esi,(%esp)
f0100d1a:	e8 9e fe ff ff       	call   f0100bbd <dumpmemhelper>
        return 0;
f0100d1f:	eb 23                	jmp    f0100d44 <mon_dumpmem+0x11f>
    else if (strcmp(argv[1], "va") == 0){
f0100d21:	c7 44 24 04 ae 73 10 	movl   $0xf01073ae,0x4(%esp)
f0100d28:	f0 
f0100d29:	8b 43 04             	mov    0x4(%ebx),%eax
f0100d2c:	89 04 24             	mov    %eax,(%esp)
f0100d2f:	e8 b8 54 00 00       	call   f01061ec <strcmp>
f0100d34:	85 c0                	test   %eax,%eax
f0100d36:	75 0c                	jne    f0100d44 <mon_dumpmem+0x11f>
        dumpmemhelper((void *)start_va, (void *)end_va);
f0100d38:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d3c:	89 34 24             	mov    %esi,(%esp)
f0100d3f:	e8 79 fe ff ff       	call   f0100bbd <dumpmemhelper>
}
f0100d44:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d49:	83 c4 1c             	add    $0x1c,%esp
f0100d4c:	5b                   	pop    %ebx
f0100d4d:	5e                   	pop    %esi
f0100d4e:	5f                   	pop    %edi
f0100d4f:	5d                   	pop    %ebp
f0100d50:	c3                   	ret    

f0100d51 <monitor>:
    return 0;
}

    void
monitor(struct Trapframe *tf)
{
f0100d51:	55                   	push   %ebp
f0100d52:	89 e5                	mov    %esp,%ebp
f0100d54:	57                   	push   %edi
f0100d55:	56                   	push   %esi
f0100d56:	53                   	push   %ebx
f0100d57:	83 ec 5c             	sub    $0x5c,%esp

    char *buf;
    //cprintf("\033[1;31m");
    cprintf("Welcome to the JOS kernel monitor!\n");
f0100d5a:	c7 04 24 f8 76 10 f0 	movl   $0xf01076f8,(%esp)
f0100d61:	e8 75 35 00 00       	call   f01042db <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
f0100d66:	c7 04 24 1c 77 10 f0 	movl   $0xf010771c,(%esp)
f0100d6d:	e8 69 35 00 00       	call   f01042db <cprintf>
	if (tf != NULL)
f0100d72:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100d76:	74 0b                	je     f0100d83 <monitor+0x32>
		print_trapframe(tf);
f0100d78:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d7b:	89 04 24             	mov    %eax,(%esp)
f0100d7e:	e8 43 3b 00 00       	call   f01048c6 <print_trapframe>
    //   cprintf("\033[1;31m");
    //    cprintf("\033[1;31m Color Test my GUY");
    while (1) {
        buf = readline("K> ");
f0100d83:	c7 04 24 b1 73 10 f0 	movl   $0xf01073b1,(%esp)
f0100d8a:	e8 91 52 00 00       	call   f0106020 <readline>
f0100d8f:	89 c3                	mov    %eax,%ebx
        if (buf != NULL)
f0100d91:	85 c0                	test   %eax,%eax
f0100d93:	74 ee                	je     f0100d83 <monitor+0x32>
    argv[argc] = 0;
f0100d95:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
    argc = 0;
f0100d9c:	be 00 00 00 00       	mov    $0x0,%esi
f0100da1:	eb 0a                	jmp    f0100dad <monitor+0x5c>
            *buf++ = 0;
f0100da3:	c6 03 00             	movb   $0x0,(%ebx)
f0100da6:	89 f7                	mov    %esi,%edi
f0100da8:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100dab:	89 fe                	mov    %edi,%esi
        while (*buf && strchr(WHITESPACE, *buf))
f0100dad:	0f b6 03             	movzbl (%ebx),%eax
f0100db0:	84 c0                	test   %al,%al
f0100db2:	74 63                	je     f0100e17 <monitor+0xc6>
f0100db4:	0f be c0             	movsbl %al,%eax
f0100db7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dbb:	c7 04 24 b5 73 10 f0 	movl   $0xf01073b5,(%esp)
f0100dc2:	e8 83 54 00 00       	call   f010624a <strchr>
f0100dc7:	85 c0                	test   %eax,%eax
f0100dc9:	75 d8                	jne    f0100da3 <monitor+0x52>
        if (*buf == 0)
f0100dcb:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100dce:	74 47                	je     f0100e17 <monitor+0xc6>
        if (argc == MAXARGS-1) {
f0100dd0:	83 fe 0f             	cmp    $0xf,%esi
f0100dd3:	75 16                	jne    f0100deb <monitor+0x9a>
            cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100dd5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100ddc:	00 
f0100ddd:	c7 04 24 ba 73 10 f0 	movl   $0xf01073ba,(%esp)
f0100de4:	e8 f2 34 00 00       	call   f01042db <cprintf>
f0100de9:	eb 98                	jmp    f0100d83 <monitor+0x32>
        argv[argc++] = buf;
f0100deb:	8d 7e 01             	lea    0x1(%esi),%edi
f0100dee:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100df2:	eb 03                	jmp    f0100df7 <monitor+0xa6>
            buf++;
f0100df4:	83 c3 01             	add    $0x1,%ebx
        while (*buf && !strchr(WHITESPACE, *buf))
f0100df7:	0f b6 03             	movzbl (%ebx),%eax
f0100dfa:	84 c0                	test   %al,%al
f0100dfc:	74 ad                	je     f0100dab <monitor+0x5a>
f0100dfe:	0f be c0             	movsbl %al,%eax
f0100e01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e05:	c7 04 24 b5 73 10 f0 	movl   $0xf01073b5,(%esp)
f0100e0c:	e8 39 54 00 00       	call   f010624a <strchr>
f0100e11:	85 c0                	test   %eax,%eax
f0100e13:	74 df                	je     f0100df4 <monitor+0xa3>
f0100e15:	eb 94                	jmp    f0100dab <monitor+0x5a>
    argv[argc] = 0;
f0100e17:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e1e:	00 
    if (argc == 0)
f0100e1f:	85 f6                	test   %esi,%esi
f0100e21:	0f 84 5c ff ff ff    	je     f0100d83 <monitor+0x32>
f0100e27:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e2c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
        if (strcmp(argv[0], commands[i].name) == 0)
f0100e2f:	8b 04 85 00 78 10 f0 	mov    -0xfef8800(,%eax,4),%eax
f0100e36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e3a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100e3d:	89 04 24             	mov    %eax,(%esp)
f0100e40:	e8 a7 53 00 00       	call   f01061ec <strcmp>
f0100e45:	85 c0                	test   %eax,%eax
f0100e47:	75 24                	jne    f0100e6d <monitor+0x11c>
            return commands[i].func(argc, argv, tf);
f0100e49:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100e4c:	8b 55 08             	mov    0x8(%ebp),%edx
f0100e4f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e53:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100e56:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100e5a:	89 34 24             	mov    %esi,(%esp)
f0100e5d:	ff 14 85 08 78 10 f0 	call   *-0xfef87f8(,%eax,4)
            if (runcmd(buf, tf) < 0)
f0100e64:	85 c0                	test   %eax,%eax
f0100e66:	78 25                	js     f0100e8d <monitor+0x13c>
f0100e68:	e9 16 ff ff ff       	jmp    f0100d83 <monitor+0x32>
    for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100e6d:	83 c3 01             	add    $0x1,%ebx
f0100e70:	83 fb 06             	cmp    $0x6,%ebx
f0100e73:	75 b7                	jne    f0100e2c <monitor+0xdb>
    cprintf("Unknown command '%s'\n", argv[0]);
f0100e75:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100e78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e7c:	c7 04 24 d7 73 10 f0 	movl   $0xf01073d7,(%esp)
f0100e83:	e8 53 34 00 00       	call   f01042db <cprintf>
f0100e88:	e9 f6 fe ff ff       	jmp    f0100d83 <monitor+0x32>
                break;
    }
}
f0100e8d:	83 c4 5c             	add    $0x5c,%esp
f0100e90:	5b                   	pop    %ebx
f0100e91:	5e                   	pop    %esi
f0100e92:	5f                   	pop    %edi
f0100e93:	5d                   	pop    %ebp
f0100e94:	c3                   	ret    
f0100e95:	66 90                	xchg   %ax,%ax
f0100e97:	66 90                	xchg   %ax,%ax
f0100e99:	66 90                	xchg   %ax,%ax
f0100e9b:	66 90                	xchg   %ax,%ax
f0100e9d:	66 90                	xchg   %ax,%ax
f0100e9f:	90                   	nop

f0100ea0 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ea0:	55                   	push   %ebp
f0100ea1:	89 e5                	mov    %esp,%ebp
f0100ea3:	56                   	push   %esi
f0100ea4:	53                   	push   %ebx
f0100ea5:	83 ec 10             	sub    $0x10,%esp
f0100ea8:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100eaa:	89 04 24             	mov    %eax,(%esp)
f0100ead:	e8 c0 32 00 00       	call   f0104172 <mc146818_read>
f0100eb2:	89 c6                	mov    %eax,%esi
f0100eb4:	83 c3 01             	add    $0x1,%ebx
f0100eb7:	89 1c 24             	mov    %ebx,(%esp)
f0100eba:	e8 b3 32 00 00       	call   f0104172 <mc146818_read>
f0100ebf:	c1 e0 08             	shl    $0x8,%eax
f0100ec2:	09 f0                	or     %esi,%eax
}
f0100ec4:	83 c4 10             	add    $0x10,%esp
f0100ec7:	5b                   	pop    %ebx
f0100ec8:	5e                   	pop    %esi
f0100ec9:	5d                   	pop    %ebp
f0100eca:	c3                   	ret    

f0100ecb <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ecb:	8b 15 38 42 21 f0    	mov    0xf0214238,%edx
f0100ed1:	85 d2                	test   %edx,%edx
f0100ed3:	75 5e                	jne    f0100f33 <boot_alloc+0x68>
		extern char end[];
		nextfree = ROUNDUP((char *) end+1, PGSIZE);
f0100ed5:	ba 08 70 25 f0       	mov    $0xf0257008,%edx
f0100eda:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ee0:	89 15 38 42 21 f0    	mov    %edx,0xf0214238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
    result = nextfree;
    if( n > 0 ){
f0100ee6:	85 c0                	test   %eax,%eax
f0100ee8:	74 46                	je     f0100f30 <boot_alloc+0x65>
        nextfree = ROUNDUP((char*)nextfree+n, PGSIZE);
f0100eea:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100ef1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ef6:	a3 38 42 21 f0       	mov    %eax,0xf0214238
        //panic("We have an error at line 112");
    	if((uint32_t)nextfree - KERNBASE > (npages*PGSIZE)){
f0100efb:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100f01:	8b 15 88 4e 21 f0    	mov    0xf0214e88,%edx
f0100f07:	c1 e2 0c             	shl    $0xc,%edx
f0100f0a:	39 d1                	cmp    %edx,%ecx
f0100f0c:	76 2b                	jbe    f0100f39 <boot_alloc+0x6e>
{
f0100f0e:	55                   	push   %ebp
f0100f0f:	89 e5                	mov    %esp,%ebp
f0100f11:	83 ec 18             	sub    $0x18,%esp
            panic("Number of bytes requested is too large, not enough pages\n");
f0100f14:	c7 44 24 08 48 78 10 	movl   $0xf0107848,0x8(%esp)
f0100f1b:	f0 
f0100f1c:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
f0100f23:	00 
f0100f24:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0100f2b:	e8 10 f1 ff ff       	call   f0100040 <_panic>
    result = nextfree;
f0100f30:	89 d0                	mov    %edx,%eax
f0100f32:	c3                   	ret    
    if( n > 0 ){
f0100f33:	85 c0                	test   %eax,%eax
f0100f35:	75 b3                	jne    f0100eea <boot_alloc+0x1f>
    result = nextfree;
f0100f37:	89 d0                	mov    %edx,%eax
    }
    else if ( n == 0 ){
        return result;
    }
    return NULL;
}
f0100f39:	f3 c3                	repz ret 

f0100f3b <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f3b:	2b 05 90 4e 21 f0    	sub    0xf0214e90,%eax
f0100f41:	c1 f8 03             	sar    $0x3,%eax
f0100f44:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f47:	89 c2                	mov    %eax,%edx
f0100f49:	c1 ea 0c             	shr    $0xc,%edx
f0100f4c:	3b 15 88 4e 21 f0    	cmp    0xf0214e88,%edx
f0100f52:	72 26                	jb     f0100f7a <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100f54:	55                   	push   %ebp
f0100f55:	89 e5                	mov    %esp,%ebp
f0100f57:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f5e:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0100f65:	f0 
f0100f66:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f6d:	00 
f0100f6e:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0100f75:	e8 c6 f0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100f7a:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return KADDR(page2pa(pp));
}
f0100f7f:	c3                   	ret    

f0100f80 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f80:	89 d1                	mov    %edx,%ecx
f0100f82:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100f85:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f88:	a8 01                	test   $0x1,%al
f0100f8a:	74 5d                	je     f0100fe9 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100f91:	89 c1                	mov    %eax,%ecx
f0100f93:	c1 e9 0c             	shr    $0xc,%ecx
f0100f96:	3b 0d 88 4e 21 f0    	cmp    0xf0214e88,%ecx
f0100f9c:	72 26                	jb     f0100fc4 <check_va2pa+0x44>
{
f0100f9e:	55                   	push   %ebp
f0100f9f:	89 e5                	mov    %esp,%ebp
f0100fa1:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fa8:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0100faf:	f0 
f0100fb0:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0100fb7:	00 
f0100fb8:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0100fbf:	e8 7c f0 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100fc4:	c1 ea 0c             	shr    $0xc,%edx
f0100fc7:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fcd:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100fd4:	89 c2                	mov    %eax,%edx
f0100fd6:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100fd9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fde:	85 d2                	test   %edx,%edx
f0100fe0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100fe5:	0f 44 c2             	cmove  %edx,%eax
f0100fe8:	c3                   	ret    
		return ~0;
f0100fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100fee:	c3                   	ret    

f0100fef <check_page_free_list>:
{
f0100fef:	55                   	push   %ebp
f0100ff0:	89 e5                	mov    %esp,%ebp
f0100ff2:	57                   	push   %edi
f0100ff3:	56                   	push   %esi
f0100ff4:	53                   	push   %ebx
f0100ff5:	83 ec 4c             	sub    $0x4c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ff8:	84 c0                	test   %al,%al
f0100ffa:	0f 85 3f 03 00 00    	jne    f010133f <check_page_free_list+0x350>
f0101000:	e9 50 03 00 00       	jmp    f0101355 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0101005:	c7 44 24 08 84 78 10 	movl   $0xf0107884,0x8(%esp)
f010100c:	f0 
f010100d:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0101014:	00 
f0101015:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010101c:	e8 1f f0 ff ff       	call   f0100040 <_panic>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101021:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101024:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101027:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010102a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f010102d:	89 c2                	mov    %eax,%edx
f010102f:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101035:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010103b:	0f 95 c2             	setne  %dl
f010103e:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101041:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101045:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101047:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010104b:	8b 00                	mov    (%eax),%eax
f010104d:	85 c0                	test   %eax,%eax
f010104f:	75 dc                	jne    f010102d <check_page_free_list+0x3e>
		*tp[1] = 0;
f0101051:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101054:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010105a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010105d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101060:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101062:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101065:	a3 40 42 21 f0       	mov    %eax,0xf0214240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010106a:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010106f:	8b 1d 40 42 21 f0    	mov    0xf0214240,%ebx
f0101075:	eb 63                	jmp    f01010da <check_page_free_list+0xeb>
f0101077:	89 d8                	mov    %ebx,%eax
f0101079:	2b 05 90 4e 21 f0    	sub    0xf0214e90,%eax
f010107f:	c1 f8 03             	sar    $0x3,%eax
f0101082:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101085:	89 c2                	mov    %eax,%edx
f0101087:	c1 ea 16             	shr    $0x16,%edx
f010108a:	39 f2                	cmp    %esi,%edx
f010108c:	73 4a                	jae    f01010d8 <check_page_free_list+0xe9>
	if (PGNUM(pa) >= npages)
f010108e:	89 c2                	mov    %eax,%edx
f0101090:	c1 ea 0c             	shr    $0xc,%edx
f0101093:	3b 15 88 4e 21 f0    	cmp    0xf0214e88,%edx
f0101099:	72 20                	jb     f01010bb <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010109b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010109f:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f01010a6:	f0 
f01010a7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01010ae:	00 
f01010af:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f01010b6:	e8 85 ef ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010bb:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01010c2:	00 
f01010c3:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01010ca:	00 
	return (void *)(pa + KERNBASE);
f01010cb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010d0:	89 04 24             	mov    %eax,(%esp)
f01010d3:	e8 af 51 00 00       	call   f0106287 <memset>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010d8:	8b 1b                	mov    (%ebx),%ebx
f01010da:	85 db                	test   %ebx,%ebx
f01010dc:	75 99                	jne    f0101077 <check_page_free_list+0x88>
	first_free_page = (char *) boot_alloc(0);
f01010de:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e3:	e8 e3 fd ff ff       	call   f0100ecb <boot_alloc>
f01010e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010eb:	8b 15 40 42 21 f0    	mov    0xf0214240,%edx
		assert(pp >= pages);
f01010f1:	8b 0d 90 4e 21 f0    	mov    0xf0214e90,%ecx
		assert(pp < pages + npages);
f01010f7:	a1 88 4e 21 f0       	mov    0xf0214e88,%eax
f01010fc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01010ff:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101102:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101105:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0101108:	bf 00 00 00 00       	mov    $0x0,%edi
f010110d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101110:	e9 c4 01 00 00       	jmp    f01012d9 <check_page_free_list+0x2ea>
		assert(pp >= pages);
f0101115:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101118:	73 24                	jae    f010113e <check_page_free_list+0x14f>
f010111a:	c7 44 24 0c 03 82 10 	movl   $0xf0108203,0xc(%esp)
f0101121:	f0 
f0101122:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101129:	f0 
f010112a:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101131:	00 
f0101132:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101139:	e8 02 ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010113e:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101141:	72 24                	jb     f0101167 <check_page_free_list+0x178>
f0101143:	c7 44 24 0c 24 82 10 	movl   $0xf0108224,0xc(%esp)
f010114a:	f0 
f010114b:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101152:	f0 
f0101153:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f010115a:	00 
f010115b:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101162:	e8 d9 ee ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101167:	89 d0                	mov    %edx,%eax
f0101169:	2b 45 cc             	sub    -0x34(%ebp),%eax
f010116c:	a8 07                	test   $0x7,%al
f010116e:	74 24                	je     f0101194 <check_page_free_list+0x1a5>
f0101170:	c7 44 24 0c a8 78 10 	movl   $0xf01078a8,0xc(%esp)
f0101177:	f0 
f0101178:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010117f:	f0 
f0101180:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0101187:	00 
f0101188:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010118f:	e8 ac ee ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101194:	c1 f8 03             	sar    $0x3,%eax
f0101197:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f010119a:	85 c0                	test   %eax,%eax
f010119c:	75 24                	jne    f01011c2 <check_page_free_list+0x1d3>
f010119e:	c7 44 24 0c 38 82 10 	movl   $0xf0108238,0xc(%esp)
f01011a5:	f0 
f01011a6:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01011ad:	f0 
f01011ae:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01011b5:	00 
f01011b6:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01011bd:	e8 7e ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011c2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011c7:	75 24                	jne    f01011ed <check_page_free_list+0x1fe>
f01011c9:	c7 44 24 0c 49 82 10 	movl   $0xf0108249,0xc(%esp)
f01011d0:	f0 
f01011d1:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01011d8:	f0 
f01011d9:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f01011e0:	00 
f01011e1:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01011e8:	e8 53 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011ed:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011f2:	75 24                	jne    f0101218 <check_page_free_list+0x229>
f01011f4:	c7 44 24 0c dc 78 10 	movl   $0xf01078dc,0xc(%esp)
f01011fb:	f0 
f01011fc:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101203:	f0 
f0101204:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f010120b:	00 
f010120c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101213:	e8 28 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101218:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010121d:	75 24                	jne    f0101243 <check_page_free_list+0x254>
f010121f:	c7 44 24 0c 62 82 10 	movl   $0xf0108262,0xc(%esp)
f0101226:	f0 
f0101227:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010122e:	f0 
f010122f:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101236:	00 
f0101237:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010123e:	e8 fd ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101243:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101248:	0f 86 2e 01 00 00    	jbe    f010137c <check_page_free_list+0x38d>
	if (PGNUM(pa) >= npages)
f010124e:	89 c1                	mov    %eax,%ecx
f0101250:	c1 e9 0c             	shr    $0xc,%ecx
f0101253:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0101256:	77 20                	ja     f0101278 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101258:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010125c:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0101263:	f0 
f0101264:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010126b:	00 
f010126c:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0101273:	e8 c8 ed ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101278:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f010127e:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101281:	0f 86 e5 00 00 00    	jbe    f010136c <check_page_free_list+0x37d>
f0101287:	c7 44 24 0c 00 79 10 	movl   $0xf0107900,0xc(%esp)
f010128e:	f0 
f010128f:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101296:	f0 
f0101297:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f010129e:	00 
f010129f:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01012a6:	e8 95 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != MPENTRY_PADDR);
f01012ab:	c7 44 24 0c 7c 82 10 	movl   $0xf010827c,0xc(%esp)
f01012b2:	f0 
f01012b3:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01012ba:	f0 
f01012bb:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01012c2:	00 
f01012c3:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01012ca:	e8 71 ed ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f01012cf:	83 c3 01             	add    $0x1,%ebx
f01012d2:	eb 03                	jmp    f01012d7 <check_page_free_list+0x2e8>
			++nfree_extmem;
f01012d4:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012d7:	8b 12                	mov    (%edx),%edx
f01012d9:	85 d2                	test   %edx,%edx
f01012db:	0f 85 34 fe ff ff    	jne    f0101115 <check_page_free_list+0x126>
	assert(nfree_basemem > 0);
f01012e1:	85 db                	test   %ebx,%ebx
f01012e3:	7f 24                	jg     f0101309 <check_page_free_list+0x31a>
f01012e5:	c7 44 24 0c 99 82 10 	movl   $0xf0108299,0xc(%esp)
f01012ec:	f0 
f01012ed:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01012f4:	f0 
f01012f5:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f01012fc:	00 
f01012fd:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101304:	e8 37 ed ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101309:	85 ff                	test   %edi,%edi
f010130b:	7f 24                	jg     f0101331 <check_page_free_list+0x342>
f010130d:	c7 44 24 0c ab 82 10 	movl   $0xf01082ab,0xc(%esp)
f0101314:	f0 
f0101315:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010131c:	f0 
f010131d:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0101324:	00 
f0101325:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010132c:	e8 0f ed ff ff       	call   f0100040 <_panic>
	cprintf("check_page_free_list() succeeded!\n");
f0101331:	c7 04 24 48 79 10 f0 	movl   $0xf0107948,(%esp)
f0101338:	e8 9e 2f 00 00       	call   f01042db <cprintf>
f010133d:	eb 4d                	jmp    f010138c <check_page_free_list+0x39d>
	if (!page_free_list)
f010133f:	a1 40 42 21 f0       	mov    0xf0214240,%eax
f0101344:	85 c0                	test   %eax,%eax
f0101346:	0f 85 d5 fc ff ff    	jne    f0101021 <check_page_free_list+0x32>
f010134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101350:	e9 b0 fc ff ff       	jmp    f0101005 <check_page_free_list+0x16>
f0101355:	83 3d 40 42 21 f0 00 	cmpl   $0x0,0xf0214240
f010135c:	0f 84 a3 fc ff ff    	je     f0101005 <check_page_free_list+0x16>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101362:	be 00 04 00 00       	mov    $0x400,%esi
f0101367:	e9 03 fd ff ff       	jmp    f010106f <check_page_free_list+0x80>
		assert(page2pa(pp) != MPENTRY_PADDR);
f010136c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101371:	0f 85 5d ff ff ff    	jne    f01012d4 <check_page_free_list+0x2e5>
f0101377:	e9 2f ff ff ff       	jmp    f01012ab <check_page_free_list+0x2bc>
f010137c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101381:	0f 85 48 ff ff ff    	jne    f01012cf <check_page_free_list+0x2e0>
f0101387:	e9 1f ff ff ff       	jmp    f01012ab <check_page_free_list+0x2bc>
}
f010138c:	83 c4 4c             	add    $0x4c,%esp
f010138f:	5b                   	pop    %ebx
f0101390:	5e                   	pop    %esi
f0101391:	5f                   	pop    %edi
f0101392:	5d                   	pop    %ebp
f0101393:	c3                   	ret    

f0101394 <page_init>:
{
f0101394:	55                   	push   %ebp
f0101395:	89 e5                	mov    %esp,%ebp
f0101397:	57                   	push   %edi
f0101398:	56                   	push   %esi
f0101399:	53                   	push   %ebx
f010139a:	83 ec 0c             	sub    $0xc,%esp
    size_t kernel = ((size_t)boot_alloc(0)-KERNBASE)/PGSIZE;
f010139d:	b8 00 00 00 00       	mov    $0x0,%eax
f01013a2:	e8 24 fb ff ff       	call   f0100ecb <boot_alloc>
f01013a7:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01013ad:	c1 e9 0c             	shr    $0xc,%ecx
    pages[0].pp_ref = 1; /* This should mean that a pointer is pointing to the page, this mean it's busy*/
f01013b0:	a1 90 4e 21 f0       	mov    0xf0214e90,%eax
f01013b5:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	for (i = 1; i < npages_basemem; i++) {
f01013bb:	8b 3d 44 42 21 f0    	mov    0xf0214244,%edi
f01013c1:	8b 35 40 42 21 f0    	mov    0xf0214240,%esi
f01013c7:	b8 01 00 00 00       	mov    $0x1,%eax
f01013cc:	eb 35                	jmp    f0101403 <page_init+0x6f>
        if(i == markMP){
f01013ce:	83 f8 07             	cmp    $0x7,%eax
f01013d1:	75 0e                	jne    f01013e1 <page_init+0x4d>
            pages[i].pp_ref = 1;
f01013d3:	8b 15 90 4e 21 f0    	mov    0xf0214e90,%edx
f01013d9:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
f01013df:	eb 1f                	jmp    f0101400 <page_init+0x6c>
f01013e1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
	    	pages[i].pp_ref = 0;
f01013e8:	8b 1d 90 4e 21 f0    	mov    0xf0214e90,%ebx
f01013ee:	66 c7 44 13 04 00 00 	movw   $0x0,0x4(%ebx,%edx,1)
	    	pages[i].pp_link = page_free_list;
f01013f5:	89 34 c3             	mov    %esi,(%ebx,%eax,8)
		    page_free_list = &pages[i];
f01013f8:	89 d6                	mov    %edx,%esi
f01013fa:	03 35 90 4e 21 f0    	add    0xf0214e90,%esi
	for (i = 1; i < npages_basemem; i++) {
f0101400:	83 c0 01             	add    $0x1,%eax
f0101403:	39 f8                	cmp    %edi,%eax
f0101405:	72 c7                	jb     f01013ce <page_init+0x3a>
f0101407:	89 35 40 42 21 f0    	mov    %esi,0xf0214240
        pages[i].pp_ref = 1;
f010140d:	8b 15 90 4e 21 f0    	mov    0xf0214e90,%edx
f0101413:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0101418:	66 c7 44 c2 04 01 00 	movw   $0x1,0x4(%edx,%eax,8)
    for(i = 160; i < 256; i++) {
f010141f:	83 c0 01             	add    $0x1,%eax
f0101422:	3d 00 01 00 00       	cmp    $0x100,%eax
f0101427:	75 ef                	jne    f0101418 <page_init+0x84>
        pages[i].pp_ref = 1;
f0101429:	8b 1d 90 4e 21 f0    	mov    0xf0214e90,%ebx
   for(i = 256; i < (256 + kernel); i++){
f010142f:	81 c1 00 01 00 00    	add    $0x100,%ecx
f0101435:	eb 0a                	jmp    f0101441 <page_init+0xad>
        pages[i].pp_ref = 1;
f0101437:	66 c7 44 c3 04 01 00 	movw   $0x1,0x4(%ebx,%eax,8)
   for(i = 256; i < (256 + kernel); i++){
f010143e:	83 c0 01             	add    $0x1,%eax
f0101441:	89 ca                	mov    %ecx,%edx
f0101443:	39 c8                	cmp    %ecx,%eax
f0101445:	72 f0                	jb     f0101437 <page_init+0xa3>
f0101447:	81 f9 00 01 00 00    	cmp    $0x100,%ecx
f010144d:	b8 00 01 00 00       	mov    $0x100,%eax
f0101452:	0f 42 d0             	cmovb  %eax,%edx
f0101455:	8b 1d 40 42 21 f0    	mov    0xf0214240,%ebx
f010145b:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0101462:	eb 1e                	jmp    f0101482 <page_init+0xee>
        pages[i].pp_ref = 0;
f0101464:	8b 0d 90 4e 21 f0    	mov    0xf0214e90,%ecx
f010146a:	66 c7 44 01 04 00 00 	movw   $0x0,0x4(%ecx,%eax,1)
        pages[i].pp_link = page_free_list;
f0101471:	89 1c 01             	mov    %ebx,(%ecx,%eax,1)
        page_free_list = &pages[i];
f0101474:	89 c3                	mov    %eax,%ebx
f0101476:	03 1d 90 4e 21 f0    	add    0xf0214e90,%ebx
   for(i; i < npages; i++){
f010147c:	83 c2 01             	add    $0x1,%edx
f010147f:	83 c0 08             	add    $0x8,%eax
f0101482:	3b 15 88 4e 21 f0    	cmp    0xf0214e88,%edx
f0101488:	72 da                	jb     f0101464 <page_init+0xd0>
f010148a:	89 1d 40 42 21 f0    	mov    %ebx,0xf0214240
}
f0101490:	83 c4 0c             	add    $0xc,%esp
f0101493:	5b                   	pop    %ebx
f0101494:	5e                   	pop    %esi
f0101495:	5f                   	pop    %edi
f0101496:	5d                   	pop    %ebp
f0101497:	c3                   	ret    

f0101498 <page_alloc>:
{
f0101498:	55                   	push   %ebp
f0101499:	89 e5                	mov    %esp,%ebp
f010149b:	53                   	push   %ebx
f010149c:	83 ec 14             	sub    $0x14,%esp
	if(page_free_list == NULL)
f010149f:	8b 1d 40 42 21 f0    	mov    0xf0214240,%ebx
f01014a5:	85 db                	test   %ebx,%ebx
f01014a7:	74 6f                	je     f0101518 <page_alloc+0x80>
    if(alloc_flags & ALLOC_ZERO){
f01014a9:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01014ad:	74 58                	je     f0101507 <page_alloc+0x6f>
	return (pp - pages) << PGSHIFT;
f01014af:	89 d8                	mov    %ebx,%eax
f01014b1:	2b 05 90 4e 21 f0    	sub    0xf0214e90,%eax
f01014b7:	c1 f8 03             	sar    $0x3,%eax
f01014ba:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01014bd:	89 c2                	mov    %eax,%edx
f01014bf:	c1 ea 0c             	shr    $0xc,%edx
f01014c2:	3b 15 88 4e 21 f0    	cmp    0xf0214e88,%edx
f01014c8:	72 20                	jb     f01014ea <page_alloc+0x52>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014ce:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f01014d5:	f0 
f01014d6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01014dd:	00 
f01014de:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f01014e5:	e8 56 eb ff ff       	call   f0100040 <_panic>
        memset(page2kva(pp), '\0', PGSIZE);
f01014ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014f1:	00 
f01014f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014f9:	00 
	return (void *)(pa + KERNBASE);
f01014fa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014ff:	89 04 24             	mov    %eax,(%esp)
f0101502:	e8 80 4d 00 00       	call   f0106287 <memset>
    page_free_list = pp->pp_link;
f0101507:	8b 03                	mov    (%ebx),%eax
f0101509:	a3 40 42 21 f0       	mov    %eax,0xf0214240
    pp->pp_link = NULL;
f010150e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    return pp;
f0101514:	89 d8                	mov    %ebx,%eax
f0101516:	eb 05                	jmp    f010151d <page_alloc+0x85>
        return NULL;
f0101518:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010151d:	83 c4 14             	add    $0x14,%esp
f0101520:	5b                   	pop    %ebx
f0101521:	5d                   	pop    %ebp
f0101522:	c3                   	ret    

f0101523 <page_free>:
{
f0101523:	55                   	push   %ebp
f0101524:	89 e5                	mov    %esp,%ebp
f0101526:	83 ec 18             	sub    $0x18,%esp
f0101529:	8b 45 08             	mov    0x8(%ebp),%eax
    if(pp->pp_ref != 0 || pp->pp_link != NULL){
f010152c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101531:	75 05                	jne    f0101538 <page_free+0x15>
f0101533:	83 38 00             	cmpl   $0x0,(%eax)
f0101536:	74 1c                	je     f0101554 <page_free+0x31>
        panic("Error at page_free");
f0101538:	c7 44 24 08 bc 82 10 	movl   $0xf01082bc,0x8(%esp)
f010153f:	f0 
f0101540:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0101547:	00 
f0101548:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010154f:	e8 ec ea ff ff       	call   f0100040 <_panic>
    pp->pp_link = page_free_list;
f0101554:	8b 15 40 42 21 f0    	mov    0xf0214240,%edx
f010155a:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f010155c:	a3 40 42 21 f0       	mov    %eax,0xf0214240
}
f0101561:	c9                   	leave  
f0101562:	c3                   	ret    

f0101563 <page_decref>:
{
f0101563:	55                   	push   %ebp
f0101564:	89 e5                	mov    %esp,%ebp
f0101566:	83 ec 18             	sub    $0x18,%esp
f0101569:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010156c:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0101570:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101573:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101577:	66 85 d2             	test   %dx,%dx
f010157a:	75 08                	jne    f0101584 <page_decref+0x21>
		page_free(pp);
f010157c:	89 04 24             	mov    %eax,(%esp)
f010157f:	e8 9f ff ff ff       	call   f0101523 <page_free>
}
f0101584:	c9                   	leave  
f0101585:	c3                   	ret    

f0101586 <pgdir_walk>:
{
f0101586:	55                   	push   %ebp
f0101587:	89 e5                	mov    %esp,%ebp
f0101589:	56                   	push   %esi
f010158a:	53                   	push   %ebx
f010158b:	83 ec 10             	sub    $0x10,%esp
f010158e:	8b 45 0c             	mov    0xc(%ebp),%eax
    pde_t pde = pgdir[PDX(va)];
f0101591:	89 c3                	mov    %eax,%ebx
f0101593:	c1 eb 16             	shr    $0x16,%ebx
f0101596:	c1 e3 02             	shl    $0x2,%ebx
f0101599:	03 5d 08             	add    0x8(%ebp),%ebx
f010159c:	8b 13                	mov    (%ebx),%edx
    pte_t table = PTX(va); // Table index, I'm not sure if we'll need this.
f010159e:	c1 e8 0c             	shr    $0xc,%eax
f01015a1:	25 ff 03 00 00       	and    $0x3ff,%eax
f01015a6:	89 c6                	mov    %eax,%esi
    if(pde & PTE_P){ // Page exists, note that the & operator is a bitwise operator
f01015a8:	f6 c2 01             	test   $0x1,%dl
f01015ab:	74 3b                	je     f01015e8 <pgdir_walk+0x62>
        holder = (pte_t*)KADDR(PTE_ADDR(pde)); // Address in page table, look at inc\mmu.h
f01015ad:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01015b3:	89 d0                	mov    %edx,%eax
f01015b5:	c1 e8 0c             	shr    $0xc,%eax
f01015b8:	3b 05 88 4e 21 f0    	cmp    0xf0214e88,%eax
f01015be:	72 20                	jb     f01015e0 <pgdir_walk+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01015c4:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f01015cb:	f0 
f01015cc:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
f01015d3:	00 
f01015d4:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01015db:	e8 60 ea ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01015e0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01015e6:	eb 6d                	jmp    f0101655 <pgdir_walk+0xcf>
        if(create){
f01015e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01015ec:	74 6c                	je     f010165a <pgdir_walk+0xd4>
            struct PageInfo* pNew = page_alloc(ALLOC_ZERO);
f01015ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015f5:	e8 9e fe ff ff       	call   f0101498 <page_alloc>
            if( pNew == NULL )
f01015fa:	85 c0                	test   %eax,%eax
f01015fc:	74 63                	je     f0101661 <pgdir_walk+0xdb>
            pNew->pp_ref++;
f01015fe:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101603:	89 c2                	mov    %eax,%edx
f0101605:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f010160b:	c1 fa 03             	sar    $0x3,%edx
f010160e:	c1 e2 0c             	shl    $0xc,%edx
            pgdir[PDX(va)] = page2pa(pNew) | PTE_P | PTE_U | PTE_W; // Grab the address, then add the permission bits
f0101611:	83 ca 07             	or     $0x7,%edx
f0101614:	89 13                	mov    %edx,(%ebx)
f0101616:	2b 05 90 4e 21 f0    	sub    0xf0214e90,%eax
f010161c:	c1 f8 03             	sar    $0x3,%eax
f010161f:	c1 e0 0c             	shl    $0xc,%eax
f0101622:	89 c2                	mov    %eax,%edx
	if (PGNUM(pa) >= npages)
f0101624:	c1 e8 0c             	shr    $0xc,%eax
f0101627:	3b 05 88 4e 21 f0    	cmp    0xf0214e88,%eax
f010162d:	72 20                	jb     f010164f <pgdir_walk+0xc9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010162f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101633:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f010163a:	f0 
f010163b:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
f0101642:	00 
f0101643:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010164a:	e8 f1 e9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010164f:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
    return &holder[table];
f0101655:	8d 04 b2             	lea    (%edx,%esi,4),%eax
f0101658:	eb 0c                	jmp    f0101666 <pgdir_walk+0xe0>
            return NULL;
f010165a:	b8 00 00 00 00       	mov    $0x0,%eax
f010165f:	eb 05                	jmp    f0101666 <pgdir_walk+0xe0>
              return NULL;
f0101661:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101666:	83 c4 10             	add    $0x10,%esp
f0101669:	5b                   	pop    %ebx
f010166a:	5e                   	pop    %esi
f010166b:	5d                   	pop    %ebp
f010166c:	c3                   	ret    

f010166d <boot_map_region>:
{
f010166d:	55                   	push   %ebp
f010166e:	89 e5                	mov    %esp,%ebp
f0101670:	57                   	push   %edi
f0101671:	56                   	push   %esi
f0101672:	53                   	push   %ebx
f0101673:	83 ec 2c             	sub    $0x2c,%esp
f0101676:	89 c7                	mov    %eax,%edi
f0101678:	89 d6                	mov    %edx,%esi
f010167a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    for(size_t i = 0; i < size; i += PGSIZE){ // "i" should be our offset
f010167d:	bb 00 00 00 00       	mov    $0x0,%ebx
        *result = PTE_ADDR(pa+i) | perm | PTE_P; // Reminder, this is a bitwise or operator, essentially it just adds the related bits.
f0101682:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101685:	83 c8 01             	or     $0x1,%eax
f0101688:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(size_t i = 0; i < size; i += PGSIZE){ // "i" should be our offset
f010168b:	eb 4d                	jmp    f01016da <boot_map_region+0x6d>
        pte_t* result = pgdir_walk(pgdir, (const void*)(va+i), 1); // Perhaps
f010168d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101694:	00 
f0101695:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101698:	89 44 24 04          	mov    %eax,0x4(%esp)
f010169c:	89 3c 24             	mov    %edi,(%esp)
f010169f:	e8 e2 fe ff ff       	call   f0101586 <pgdir_walk>
        if( result == NULL ){
f01016a4:	85 c0                	test   %eax,%eax
f01016a6:	75 1c                	jne    f01016c4 <boot_map_region+0x57>
            panic("It looks like we have an issue here.");
f01016a8:	c7 44 24 08 6c 79 10 	movl   $0xf010796c,0x8(%esp)
f01016af:	f0 
f01016b0:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f01016b7:	00 
f01016b8:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01016bf:	e8 7c e9 ff ff       	call   f0100040 <_panic>
f01016c4:	89 da                	mov    %ebx,%edx
f01016c6:	03 55 08             	add    0x8(%ebp),%edx
        *result = PTE_ADDR(pa+i) | perm | PTE_P; // Reminder, this is a bitwise or operator, essentially it just adds the related bits.
f01016c9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01016cf:	0b 55 e0             	or     -0x20(%ebp),%edx
f01016d2:	89 10                	mov    %edx,(%eax)
    for(size_t i = 0; i < size; i += PGSIZE){ // "i" should be our offset
f01016d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01016da:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01016dd:	72 ae                	jb     f010168d <boot_map_region+0x20>
}
f01016df:	83 c4 2c             	add    $0x2c,%esp
f01016e2:	5b                   	pop    %ebx
f01016e3:	5e                   	pop    %esi
f01016e4:	5f                   	pop    %edi
f01016e5:	5d                   	pop    %ebp
f01016e6:	c3                   	ret    

f01016e7 <page_lookup>:
{
f01016e7:	55                   	push   %ebp
f01016e8:	89 e5                	mov    %esp,%ebp
f01016ea:	53                   	push   %ebx
f01016eb:	83 ec 14             	sub    $0x14,%esp
f01016ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
    pte_t* pp = pgdir_walk(pgdir, va, 0);
f01016f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01016f8:	00 
f01016f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101700:	8b 45 08             	mov    0x8(%ebp),%eax
f0101703:	89 04 24             	mov    %eax,(%esp)
f0101706:	e8 7b fe ff ff       	call   f0101586 <pgdir_walk>
    if(pp == NULL || !(*pp & PTE_P))
f010170b:	85 c0                	test   %eax,%eax
f010170d:	74 3f                	je     f010174e <page_lookup+0x67>
f010170f:	f6 00 01             	testb  $0x1,(%eax)
f0101712:	74 41                	je     f0101755 <page_lookup+0x6e>
    if(pte_store != 0){
f0101714:	85 db                	test   %ebx,%ebx
f0101716:	74 02                	je     f010171a <page_lookup+0x33>
        *pte_store = pp; // note that pte_store is a double pointer
f0101718:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pp)); // Found @ Line 76 in inc\mmu.h
f010171a:	8b 00                	mov    (%eax),%eax
	if (PGNUM(pa) >= npages)
f010171c:	c1 e8 0c             	shr    $0xc,%eax
f010171f:	3b 05 88 4e 21 f0    	cmp    0xf0214e88,%eax
f0101725:	72 1c                	jb     f0101743 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101727:	c7 44 24 08 94 79 10 	movl   $0xf0107994,0x8(%esp)
f010172e:	f0 
f010172f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101736:	00 
f0101737:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f010173e:	e8 fd e8 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101743:	8b 15 90 4e 21 f0    	mov    0xf0214e90,%edx
f0101749:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010174c:	eb 0c                	jmp    f010175a <page_lookup+0x73>
        return NULL;
f010174e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101753:	eb 05                	jmp    f010175a <page_lookup+0x73>
f0101755:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010175a:	83 c4 14             	add    $0x14,%esp
f010175d:	5b                   	pop    %ebx
f010175e:	5d                   	pop    %ebp
f010175f:	c3                   	ret    

f0101760 <tlb_invalidate>:
{
f0101760:	55                   	push   %ebp
f0101761:	89 e5                	mov    %esp,%ebp
f0101763:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101766:	e8 6e 51 00 00       	call   f01068d9 <cpunum>
f010176b:	6b c0 74             	imul   $0x74,%eax,%eax
f010176e:	83 b8 28 50 21 f0 00 	cmpl   $0x0,-0xfdeafd8(%eax)
f0101775:	74 16                	je     f010178d <tlb_invalidate+0x2d>
f0101777:	e8 5d 51 00 00       	call   f01068d9 <cpunum>
f010177c:	6b c0 74             	imul   $0x74,%eax,%eax
f010177f:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0101785:	8b 55 08             	mov    0x8(%ebp),%edx
f0101788:	39 50 60             	cmp    %edx,0x60(%eax)
f010178b:	75 06                	jne    f0101793 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010178d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101790:	0f 01 38             	invlpg (%eax)
}
f0101793:	c9                   	leave  
f0101794:	c3                   	ret    

f0101795 <page_remove>:
{
f0101795:	55                   	push   %ebp
f0101796:	89 e5                	mov    %esp,%ebp
f0101798:	56                   	push   %esi
f0101799:	53                   	push   %ebx
f010179a:	83 ec 20             	sub    $0x20,%esp
f010179d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01017a0:	8b 75 0c             	mov    0xc(%ebp),%esi
    struct PageInfo* got = page_lookup(pgdir, va, &pte_store);
f01017a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01017a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017aa:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017ae:	89 1c 24             	mov    %ebx,(%esp)
f01017b1:	e8 31 ff ff ff       	call   f01016e7 <page_lookup>
    if(got != NULL && (*pte_store & PTE_P)){
f01017b6:	85 c0                	test   %eax,%eax
f01017b8:	74 25                	je     f01017df <page_remove+0x4a>
f01017ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017bd:	f6 02 01             	testb  $0x1,(%edx)
f01017c0:	74 1d                	je     f01017df <page_remove+0x4a>
        page_decref(got);
f01017c2:	89 04 24             	mov    %eax,(%esp)
f01017c5:	e8 99 fd ff ff       	call   f0101563 <page_decref>
        *pte_store = 0;
f01017ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, va);
f01017d3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017d7:	89 1c 24             	mov    %ebx,(%esp)
f01017da:	e8 81 ff ff ff       	call   f0101760 <tlb_invalidate>
}
f01017df:	83 c4 20             	add    $0x20,%esp
f01017e2:	5b                   	pop    %ebx
f01017e3:	5e                   	pop    %esi
f01017e4:	5d                   	pop    %ebp
f01017e5:	c3                   	ret    

f01017e6 <page_insert>:
{
f01017e6:	55                   	push   %ebp
f01017e7:	89 e5                	mov    %esp,%ebp
f01017e9:	57                   	push   %edi
f01017ea:	56                   	push   %esi
f01017eb:	53                   	push   %ebx
f01017ec:	83 ec 1c             	sub    $0x1c,%esp
f01017ef:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017f2:	8b 7d 10             	mov    0x10(%ebp),%edi
    pte_t* pte = pgdir_walk(pgdir, va, 1);
f01017f5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01017fc:	00 
f01017fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101801:	8b 45 08             	mov    0x8(%ebp),%eax
f0101804:	89 04 24             	mov    %eax,(%esp)
f0101807:	e8 7a fd ff ff       	call   f0101586 <pgdir_walk>
f010180c:	89 c3                	mov    %eax,%ebx
    if(pte == NULL){
f010180e:	85 c0                	test   %eax,%eax
f0101810:	74 36                	je     f0101848 <page_insert+0x62>
    pp->pp_ref++;
f0101812:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
    if(*pte & PTE_P){
f0101817:	f6 00 01             	testb  $0x1,(%eax)
f010181a:	74 0f                	je     f010182b <page_insert+0x45>
        page_remove(pgdir, va);
f010181c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101820:	8b 45 08             	mov    0x8(%ebp),%eax
f0101823:	89 04 24             	mov    %eax,(%esp)
f0101826:	e8 6a ff ff ff       	call   f0101795 <page_remove>
    *pte = page2pa(pp) | perm | PTE_P;
f010182b:	8b 45 14             	mov    0x14(%ebp),%eax
f010182e:	83 c8 01             	or     $0x1,%eax
	return (pp - pages) << PGSHIFT;
f0101831:	2b 35 90 4e 21 f0    	sub    0xf0214e90,%esi
f0101837:	c1 fe 03             	sar    $0x3,%esi
f010183a:	c1 e6 0c             	shl    $0xc,%esi
f010183d:	09 c6                	or     %eax,%esi
f010183f:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101841:	b8 00 00 00 00       	mov    $0x0,%eax
f0101846:	eb 05                	jmp    f010184d <page_insert+0x67>
        return -E_NO_MEM;
f0101848:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f010184d:	83 c4 1c             	add    $0x1c,%esp
f0101850:	5b                   	pop    %ebx
f0101851:	5e                   	pop    %esi
f0101852:	5f                   	pop    %edi
f0101853:	5d                   	pop    %ebp
f0101854:	c3                   	ret    

f0101855 <mmio_map_region>:
{
f0101855:	55                   	push   %ebp
f0101856:	89 e5                	mov    %esp,%ebp
f0101858:	56                   	push   %esi
f0101859:	53                   	push   %ebx
f010185a:	83 ec 10             	sub    $0x10,%esp
    size_t fixed = ROUNDUP(size, PGSIZE);
f010185d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101860:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f0101866:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    uintptr_t reserved = base;
f010186c:	8b 1d 00 23 12 f0    	mov    0xf0122300,%ebx
    if(base+fixed > MMIOLIM){
f0101872:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101875:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010187a:	76 1c                	jbe    f0101898 <mmio_map_region+0x43>
        panic("mmio_map_region: fixed > mmio");
f010187c:	c7 44 24 08 cf 82 10 	movl   $0xf01082cf,0x8(%esp)
f0101883:	f0 
f0101884:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f010188b:	00 
f010188c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101893:	e8 a8 e7 ff ff       	call   f0100040 <_panic>
    boot_map_region(kern_pgdir, base, fixed, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101898:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f010189f:	00 
f01018a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01018a3:	89 04 24             	mov    %eax,(%esp)
f01018a6:	89 f1                	mov    %esi,%ecx
f01018a8:	89 da                	mov    %ebx,%edx
f01018aa:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01018af:	e8 b9 fd ff ff       	call   f010166d <boot_map_region>
    base = base + fixed;
f01018b4:	01 35 00 23 12 f0    	add    %esi,0xf0122300
}
f01018ba:	89 d8                	mov    %ebx,%eax
f01018bc:	83 c4 10             	add    $0x10,%esp
f01018bf:	5b                   	pop    %ebx
f01018c0:	5e                   	pop    %esi
f01018c1:	5d                   	pop    %ebp
f01018c2:	c3                   	ret    

f01018c3 <mem_init>:
{
f01018c3:	55                   	push   %ebp
f01018c4:	89 e5                	mov    %esp,%ebp
f01018c6:	57                   	push   %edi
f01018c7:	56                   	push   %esi
f01018c8:	53                   	push   %ebx
f01018c9:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01018cc:	b8 15 00 00 00       	mov    $0x15,%eax
f01018d1:	e8 ca f5 ff ff       	call   f0100ea0 <nvram_read>
f01018d6:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01018d8:	b8 17 00 00 00       	mov    $0x17,%eax
f01018dd:	e8 be f5 ff ff       	call   f0100ea0 <nvram_read>
f01018e2:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01018e4:	b8 34 00 00 00       	mov    $0x34,%eax
f01018e9:	e8 b2 f5 ff ff       	call   f0100ea0 <nvram_read>
f01018ee:	c1 e0 06             	shl    $0x6,%eax
f01018f1:	89 c2                	mov    %eax,%edx
		totalmem = 16 * 1024 + ext16mem;
f01018f3:	8d 80 00 40 00 00    	lea    0x4000(%eax),%eax
	if (ext16mem)
f01018f9:	85 d2                	test   %edx,%edx
f01018fb:	75 0b                	jne    f0101908 <mem_init+0x45>
		totalmem = 1 * 1024 + extmem;
f01018fd:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101903:	85 f6                	test   %esi,%esi
f0101905:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101908:	89 c2                	mov    %eax,%edx
f010190a:	c1 ea 02             	shr    $0x2,%edx
f010190d:	89 15 88 4e 21 f0    	mov    %edx,0xf0214e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101913:	89 d9                	mov    %ebx,%ecx
f0101915:	c1 e9 02             	shr    $0x2,%ecx
f0101918:	89 0d 44 42 21 f0    	mov    %ecx,0xf0214244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK, PG_Size = %uB, Npages = %u\n",
f010191e:	89 54 24 14          	mov    %edx,0x14(%esp)
f0101922:	c7 44 24 10 00 10 00 	movl   $0x1000,0x10(%esp)
f0101929:	00 
f010192a:	89 c2                	mov    %eax,%edx
f010192c:	29 da                	sub    %ebx,%edx
f010192e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101932:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101936:	89 44 24 04          	mov    %eax,0x4(%esp)
f010193a:	c7 04 24 b4 79 10 f0 	movl   $0xf01079b4,(%esp)
f0101941:	e8 95 29 00 00       	call   f01042db <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101946:	b8 00 10 00 00       	mov    $0x1000,%eax
f010194b:	e8 7b f5 ff ff       	call   f0100ecb <boot_alloc>
f0101950:	a3 8c 4e 21 f0       	mov    %eax,0xf0214e8c
    memset(kern_pgdir, 0, PGSIZE);
f0101955:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010195c:	00 
f010195d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101964:	00 
f0101965:	89 04 24             	mov    %eax,(%esp)
f0101968:	e8 1a 49 00 00       	call   f0106287 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010196d:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101972:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101977:	77 20                	ja     f0101999 <mem_init+0xd6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101979:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010197d:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0101984:	f0 
f0101985:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
f010198c:	00 
f010198d:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101994:	e8 a7 e6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101999:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010199f:	83 ca 05             	or     $0x5,%edx
f01019a2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
    pages = (struct PageInfo*)boot_alloc( npages * (sizeof(struct PageInfo*)) );
f01019a8:	a1 88 4e 21 f0       	mov    0xf0214e88,%eax
f01019ad:	c1 e0 02             	shl    $0x2,%eax
f01019b0:	e8 16 f5 ff ff       	call   f0100ecb <boot_alloc>
f01019b5:	a3 90 4e 21 f0       	mov    %eax,0xf0214e90
    memset(pages, '\0', npages);
f01019ba:	8b 15 88 4e 21 f0    	mov    0xf0214e88,%edx
f01019c0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019cb:	00 
f01019cc:	89 04 24             	mov    %eax,(%esp)
f01019cf:	e8 b3 48 00 00       	call   f0106287 <memset>
    envs = (struct Env*)boot_alloc(NENV * (sizeof(struct Env)));
f01019d4:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01019d9:	e8 ed f4 ff ff       	call   f0100ecb <boot_alloc>
f01019de:	a3 48 42 21 f0       	mov    %eax,0xf0214248
	page_init();
f01019e3:	e8 ac f9 ff ff       	call   f0101394 <page_init>
	check_page_free_list(1);
f01019e8:	b8 01 00 00 00       	mov    $0x1,%eax
f01019ed:	e8 fd f5 ff ff       	call   f0100fef <check_page_free_list>
	if (!pages)
f01019f2:	83 3d 90 4e 21 f0 00 	cmpl   $0x0,0xf0214e90
f01019f9:	75 1c                	jne    f0101a17 <mem_init+0x154>
		panic("'pages' is a null pointer!");
f01019fb:	c7 44 24 08 ed 82 10 	movl   $0xf01082ed,0x8(%esp)
f0101a02:	f0 
f0101a03:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101a0a:	00 
f0101a0b:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101a12:	e8 29 e6 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a17:	a1 40 42 21 f0       	mov    0xf0214240,%eax
f0101a1c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a21:	eb 05                	jmp    f0101a28 <mem_init+0x165>
		++nfree;
f0101a23:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a26:	8b 00                	mov    (%eax),%eax
f0101a28:	85 c0                	test   %eax,%eax
f0101a2a:	75 f7                	jne    f0101a23 <mem_init+0x160>
	assert((pp0 = page_alloc(0)));
f0101a2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a33:	e8 60 fa ff ff       	call   f0101498 <page_alloc>
f0101a38:	89 c7                	mov    %eax,%edi
f0101a3a:	85 c0                	test   %eax,%eax
f0101a3c:	75 24                	jne    f0101a62 <mem_init+0x19f>
f0101a3e:	c7 44 24 0c 08 83 10 	movl   $0xf0108308,0xc(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101a4d:	f0 
f0101a4e:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101a55:	00 
f0101a56:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101a5d:	e8 de e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a69:	e8 2a fa ff ff       	call   f0101498 <page_alloc>
f0101a6e:	89 c6                	mov    %eax,%esi
f0101a70:	85 c0                	test   %eax,%eax
f0101a72:	75 24                	jne    f0101a98 <mem_init+0x1d5>
f0101a74:	c7 44 24 0c 1e 83 10 	movl   $0xf010831e,0xc(%esp)
f0101a7b:	f0 
f0101a7c:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101a83:	f0 
f0101a84:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101a8b:	00 
f0101a8c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101a93:	e8 a8 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a9f:	e8 f4 f9 ff ff       	call   f0101498 <page_alloc>
f0101aa4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101aa7:	85 c0                	test   %eax,%eax
f0101aa9:	75 24                	jne    f0101acf <mem_init+0x20c>
f0101aab:	c7 44 24 0c 34 83 10 	movl   $0xf0108334,0xc(%esp)
f0101ab2:	f0 
f0101ab3:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101aba:	f0 
f0101abb:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101ac2:	00 
f0101ac3:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101aca:	e8 71 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101acf:	39 f7                	cmp    %esi,%edi
f0101ad1:	75 24                	jne    f0101af7 <mem_init+0x234>
f0101ad3:	c7 44 24 0c 4a 83 10 	movl   $0xf010834a,0xc(%esp)
f0101ada:	f0 
f0101adb:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101ae2:	f0 
f0101ae3:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101aea:	00 
f0101aeb:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101af2:	e8 49 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101af7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101afa:	39 c6                	cmp    %eax,%esi
f0101afc:	74 04                	je     f0101b02 <mem_init+0x23f>
f0101afe:	39 c7                	cmp    %eax,%edi
f0101b00:	75 24                	jne    f0101b26 <mem_init+0x263>
f0101b02:	c7 44 24 0c 0c 7a 10 	movl   $0xf0107a0c,0xc(%esp)
f0101b09:	f0 
f0101b0a:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101b11:	f0 
f0101b12:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101b19:	00 
f0101b1a:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101b21:	e8 1a e5 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101b26:	8b 15 90 4e 21 f0    	mov    0xf0214e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b2c:	a1 88 4e 21 f0       	mov    0xf0214e88,%eax
f0101b31:	c1 e0 0c             	shl    $0xc,%eax
f0101b34:	89 f9                	mov    %edi,%ecx
f0101b36:	29 d1                	sub    %edx,%ecx
f0101b38:	c1 f9 03             	sar    $0x3,%ecx
f0101b3b:	c1 e1 0c             	shl    $0xc,%ecx
f0101b3e:	39 c1                	cmp    %eax,%ecx
f0101b40:	72 24                	jb     f0101b66 <mem_init+0x2a3>
f0101b42:	c7 44 24 0c 5c 83 10 	movl   $0xf010835c,0xc(%esp)
f0101b49:	f0 
f0101b4a:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101b51:	f0 
f0101b52:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101b59:	00 
f0101b5a:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101b61:	e8 da e4 ff ff       	call   f0100040 <_panic>
f0101b66:	89 f1                	mov    %esi,%ecx
f0101b68:	29 d1                	sub    %edx,%ecx
f0101b6a:	c1 f9 03             	sar    $0x3,%ecx
f0101b6d:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101b70:	39 c8                	cmp    %ecx,%eax
f0101b72:	77 24                	ja     f0101b98 <mem_init+0x2d5>
f0101b74:	c7 44 24 0c 79 83 10 	movl   $0xf0108379,0xc(%esp)
f0101b7b:	f0 
f0101b7c:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101b83:	f0 
f0101b84:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101b8b:	00 
f0101b8c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101b93:	e8 a8 e4 ff ff       	call   f0100040 <_panic>
f0101b98:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b9b:	29 d1                	sub    %edx,%ecx
f0101b9d:	89 ca                	mov    %ecx,%edx
f0101b9f:	c1 fa 03             	sar    $0x3,%edx
f0101ba2:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ba5:	39 d0                	cmp    %edx,%eax
f0101ba7:	77 24                	ja     f0101bcd <mem_init+0x30a>
f0101ba9:	c7 44 24 0c 96 83 10 	movl   $0xf0108396,0xc(%esp)
f0101bb0:	f0 
f0101bb1:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101bb8:	f0 
f0101bb9:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101bc0:	00 
f0101bc1:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101bc8:	e8 73 e4 ff ff       	call   f0100040 <_panic>
	fl = page_free_list;
f0101bcd:	a1 40 42 21 f0       	mov    0xf0214240,%eax
f0101bd2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101bd5:	c7 05 40 42 21 f0 00 	movl   $0x0,0xf0214240
f0101bdc:	00 00 00 
	assert(!page_alloc(0));
f0101bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be6:	e8 ad f8 ff ff       	call   f0101498 <page_alloc>
f0101beb:	85 c0                	test   %eax,%eax
f0101bed:	74 24                	je     f0101c13 <mem_init+0x350>
f0101bef:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f0101bf6:	f0 
f0101bf7:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101bfe:	f0 
f0101bff:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0101c06:	00 
f0101c07:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101c0e:	e8 2d e4 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0101c13:	89 3c 24             	mov    %edi,(%esp)
f0101c16:	e8 08 f9 ff ff       	call   f0101523 <page_free>
	page_free(pp1);
f0101c1b:	89 34 24             	mov    %esi,(%esp)
f0101c1e:	e8 00 f9 ff ff       	call   f0101523 <page_free>
	page_free(pp2);
f0101c23:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c26:	89 04 24             	mov    %eax,(%esp)
f0101c29:	e8 f5 f8 ff ff       	call   f0101523 <page_free>
	assert((pp0 = page_alloc(0)));
f0101c2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c35:	e8 5e f8 ff ff       	call   f0101498 <page_alloc>
f0101c3a:	89 c6                	mov    %eax,%esi
f0101c3c:	85 c0                	test   %eax,%eax
f0101c3e:	75 24                	jne    f0101c64 <mem_init+0x3a1>
f0101c40:	c7 44 24 0c 08 83 10 	movl   $0xf0108308,0xc(%esp)
f0101c47:	f0 
f0101c48:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101c4f:	f0 
f0101c50:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101c57:	00 
f0101c58:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101c5f:	e8 dc e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c6b:	e8 28 f8 ff ff       	call   f0101498 <page_alloc>
f0101c70:	89 c7                	mov    %eax,%edi
f0101c72:	85 c0                	test   %eax,%eax
f0101c74:	75 24                	jne    f0101c9a <mem_init+0x3d7>
f0101c76:	c7 44 24 0c 1e 83 10 	movl   $0xf010831e,0xc(%esp)
f0101c7d:	f0 
f0101c7e:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101c85:	f0 
f0101c86:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101c8d:	00 
f0101c8e:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101c95:	e8 a6 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ca1:	e8 f2 f7 ff ff       	call   f0101498 <page_alloc>
f0101ca6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ca9:	85 c0                	test   %eax,%eax
f0101cab:	75 24                	jne    f0101cd1 <mem_init+0x40e>
f0101cad:	c7 44 24 0c 34 83 10 	movl   $0xf0108334,0xc(%esp)
f0101cb4:	f0 
f0101cb5:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101cbc:	f0 
f0101cbd:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101cc4:	00 
f0101cc5:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101ccc:	e8 6f e3 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101cd1:	39 fe                	cmp    %edi,%esi
f0101cd3:	75 24                	jne    f0101cf9 <mem_init+0x436>
f0101cd5:	c7 44 24 0c 4a 83 10 	movl   $0xf010834a,0xc(%esp)
f0101cdc:	f0 
f0101cdd:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101ce4:	f0 
f0101ce5:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101cec:	00 
f0101ced:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101cf4:	e8 47 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cf9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cfc:	39 c7                	cmp    %eax,%edi
f0101cfe:	74 04                	je     f0101d04 <mem_init+0x441>
f0101d00:	39 c6                	cmp    %eax,%esi
f0101d02:	75 24                	jne    f0101d28 <mem_init+0x465>
f0101d04:	c7 44 24 0c 0c 7a 10 	movl   $0xf0107a0c,0xc(%esp)
f0101d0b:	f0 
f0101d0c:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101d13:	f0 
f0101d14:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0101d1b:	00 
f0101d1c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101d23:	e8 18 e3 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101d28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d2f:	e8 64 f7 ff ff       	call   f0101498 <page_alloc>
f0101d34:	85 c0                	test   %eax,%eax
f0101d36:	74 24                	je     f0101d5c <mem_init+0x499>
f0101d38:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f0101d3f:	f0 
f0101d40:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101d47:	f0 
f0101d48:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101d4f:	00 
f0101d50:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101d57:	e8 e4 e2 ff ff       	call   f0100040 <_panic>
f0101d5c:	89 f0                	mov    %esi,%eax
f0101d5e:	2b 05 90 4e 21 f0    	sub    0xf0214e90,%eax
f0101d64:	c1 f8 03             	sar    $0x3,%eax
f0101d67:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101d6a:	89 c2                	mov    %eax,%edx
f0101d6c:	c1 ea 0c             	shr    $0xc,%edx
f0101d6f:	3b 15 88 4e 21 f0    	cmp    0xf0214e88,%edx
f0101d75:	72 20                	jb     f0101d97 <mem_init+0x4d4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d77:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d7b:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0101d82:	f0 
f0101d83:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101d8a:	00 
f0101d8b:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0101d92:	e8 a9 e2 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
f0101d97:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d9e:	00 
f0101d9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101da6:	00 
	return (void *)(pa + KERNBASE);
f0101da7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dac:	89 04 24             	mov    %eax,(%esp)
f0101daf:	e8 d3 44 00 00       	call   f0106287 <memset>
	page_free(pp0);
f0101db4:	89 34 24             	mov    %esi,(%esp)
f0101db7:	e8 67 f7 ff ff       	call   f0101523 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101dbc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101dc3:	e8 d0 f6 ff ff       	call   f0101498 <page_alloc>
f0101dc8:	85 c0                	test   %eax,%eax
f0101dca:	75 24                	jne    f0101df0 <mem_init+0x52d>
f0101dcc:	c7 44 24 0c c2 83 10 	movl   $0xf01083c2,0xc(%esp)
f0101dd3:	f0 
f0101dd4:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101ddb:	f0 
f0101ddc:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0101de3:	00 
f0101de4:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101deb:	e8 50 e2 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101df0:	39 c6                	cmp    %eax,%esi
f0101df2:	74 24                	je     f0101e18 <mem_init+0x555>
f0101df4:	c7 44 24 0c e0 83 10 	movl   $0xf01083e0,0xc(%esp)
f0101dfb:	f0 
f0101dfc:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101e03:	f0 
f0101e04:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101e0b:	00 
f0101e0c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101e13:	e8 28 e2 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101e18:	89 f0                	mov    %esi,%eax
f0101e1a:	2b 05 90 4e 21 f0    	sub    0xf0214e90,%eax
f0101e20:	c1 f8 03             	sar    $0x3,%eax
f0101e23:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e26:	89 c2                	mov    %eax,%edx
f0101e28:	c1 ea 0c             	shr    $0xc,%edx
f0101e2b:	3b 15 88 4e 21 f0    	cmp    0xf0214e88,%edx
f0101e31:	72 20                	jb     f0101e53 <mem_init+0x590>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e33:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e37:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0101e3e:	f0 
f0101e3f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101e46:	00 
f0101e47:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0101e4e:	e8 ed e1 ff ff       	call   f0100040 <_panic>
f0101e53:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101e59:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
		assert(c[i] == 0);
f0101e5f:	80 38 00             	cmpb   $0x0,(%eax)
f0101e62:	74 24                	je     f0101e88 <mem_init+0x5c5>
f0101e64:	c7 44 24 0c f0 83 10 	movl   $0xf01083f0,0xc(%esp)
f0101e6b:	f0 
f0101e6c:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101e73:	f0 
f0101e74:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101e7b:	00 
f0101e7c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101e83:	e8 b8 e1 ff ff       	call   f0100040 <_panic>
f0101e88:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101e8b:	39 d0                	cmp    %edx,%eax
f0101e8d:	75 d0                	jne    f0101e5f <mem_init+0x59c>
	page_free_list = fl;
f0101e8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e92:	a3 40 42 21 f0       	mov    %eax,0xf0214240
	page_free(pp0);
f0101e97:	89 34 24             	mov    %esi,(%esp)
f0101e9a:	e8 84 f6 ff ff       	call   f0101523 <page_free>
	page_free(pp1);
f0101e9f:	89 3c 24             	mov    %edi,(%esp)
f0101ea2:	e8 7c f6 ff ff       	call   f0101523 <page_free>
	page_free(pp2);
f0101ea7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eaa:	89 04 24             	mov    %eax,(%esp)
f0101ead:	e8 71 f6 ff ff       	call   f0101523 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101eb2:	a1 40 42 21 f0       	mov    0xf0214240,%eax
f0101eb7:	eb 05                	jmp    f0101ebe <mem_init+0x5fb>
		--nfree;
f0101eb9:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ebc:	8b 00                	mov    (%eax),%eax
f0101ebe:	85 c0                	test   %eax,%eax
f0101ec0:	75 f7                	jne    f0101eb9 <mem_init+0x5f6>
	assert(nfree == 0);
f0101ec2:	85 db                	test   %ebx,%ebx
f0101ec4:	74 24                	je     f0101eea <mem_init+0x627>
f0101ec6:	c7 44 24 0c fa 83 10 	movl   $0xf01083fa,0xc(%esp)
f0101ecd:	f0 
f0101ece:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101ed5:	f0 
f0101ed6:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101edd:	00 
f0101ede:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101ee5:	e8 56 e1 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_alloc() succeeded!\n");
f0101eea:	c7 04 24 2c 7a 10 f0 	movl   $0xf0107a2c,(%esp)
f0101ef1:	e8 e5 23 00 00       	call   f01042db <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ef6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101efd:	e8 96 f5 ff ff       	call   f0101498 <page_alloc>
f0101f02:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f05:	85 c0                	test   %eax,%eax
f0101f07:	75 24                	jne    f0101f2d <mem_init+0x66a>
f0101f09:	c7 44 24 0c 08 83 10 	movl   $0xf0108308,0xc(%esp)
f0101f10:	f0 
f0101f11:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101f18:	f0 
f0101f19:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101f20:	00 
f0101f21:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101f28:	e8 13 e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f34:	e8 5f f5 ff ff       	call   f0101498 <page_alloc>
f0101f39:	89 c3                	mov    %eax,%ebx
f0101f3b:	85 c0                	test   %eax,%eax
f0101f3d:	75 24                	jne    f0101f63 <mem_init+0x6a0>
f0101f3f:	c7 44 24 0c 1e 83 10 	movl   $0xf010831e,0xc(%esp)
f0101f46:	f0 
f0101f47:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101f4e:	f0 
f0101f4f:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101f56:	00 
f0101f57:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101f5e:	e8 dd e0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f6a:	e8 29 f5 ff ff       	call   f0101498 <page_alloc>
f0101f6f:	89 c6                	mov    %eax,%esi
f0101f71:	85 c0                	test   %eax,%eax
f0101f73:	75 24                	jne    f0101f99 <mem_init+0x6d6>
f0101f75:	c7 44 24 0c 34 83 10 	movl   $0xf0108334,0xc(%esp)
f0101f7c:	f0 
f0101f7d:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101f84:	f0 
f0101f85:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101f8c:	00 
f0101f8d:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101f94:	e8 a7 e0 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f99:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101f9c:	75 24                	jne    f0101fc2 <mem_init+0x6ff>
f0101f9e:	c7 44 24 0c 4a 83 10 	movl   $0xf010834a,0xc(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101fb5:	00 
f0101fb6:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101fbd:	e8 7e e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fc2:	39 c3                	cmp    %eax,%ebx
f0101fc4:	74 05                	je     f0101fcb <mem_init+0x708>
f0101fc6:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101fc9:	75 24                	jne    f0101fef <mem_init+0x72c>
f0101fcb:	c7 44 24 0c 0c 7a 10 	movl   $0xf0107a0c,0xc(%esp)
f0101fd2:	f0 
f0101fd3:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0101fda:	f0 
f0101fdb:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0101fe2:	00 
f0101fe3:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0101fea:	e8 51 e0 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101fef:	a1 40 42 21 f0       	mov    0xf0214240,%eax
f0101ff4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101ff7:	c7 05 40 42 21 f0 00 	movl   $0x0,0xf0214240
f0101ffe:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102001:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102008:	e8 8b f4 ff ff       	call   f0101498 <page_alloc>
f010200d:	85 c0                	test   %eax,%eax
f010200f:	74 24                	je     f0102035 <mem_init+0x772>
f0102011:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f0102018:	f0 
f0102019:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102020:	f0 
f0102021:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102028:	00 
f0102029:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102030:	e8 0b e0 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102035:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102038:	89 44 24 08          	mov    %eax,0x8(%esp)
f010203c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102043:	00 
f0102044:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102049:	89 04 24             	mov    %eax,(%esp)
f010204c:	e8 96 f6 ff ff       	call   f01016e7 <page_lookup>
f0102051:	85 c0                	test   %eax,%eax
f0102053:	74 24                	je     f0102079 <mem_init+0x7b6>
f0102055:	c7 44 24 0c 4c 7a 10 	movl   $0xf0107a4c,0xc(%esp)
f010205c:	f0 
f010205d:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102064:	f0 
f0102065:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f010206c:	00 
f010206d:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102074:	e8 c7 df ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102079:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102080:	00 
f0102081:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102088:	00 
f0102089:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010208d:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102092:	89 04 24             	mov    %eax,(%esp)
f0102095:	e8 4c f7 ff ff       	call   f01017e6 <page_insert>
f010209a:	85 c0                	test   %eax,%eax
f010209c:	78 24                	js     f01020c2 <mem_init+0x7ff>
f010209e:	c7 44 24 0c 84 7a 10 	movl   $0xf0107a84,0xc(%esp)
f01020a5:	f0 
f01020a6:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01020ad:	f0 
f01020ae:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01020b5:	00 
f01020b6:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01020bd:	e8 7e df ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01020c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020c5:	89 04 24             	mov    %eax,(%esp)
f01020c8:	e8 56 f4 ff ff       	call   f0101523 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01020cd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020d4:	00 
f01020d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020dc:	00 
f01020dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020e1:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01020e6:	89 04 24             	mov    %eax,(%esp)
f01020e9:	e8 f8 f6 ff ff       	call   f01017e6 <page_insert>
f01020ee:	85 c0                	test   %eax,%eax
f01020f0:	74 24                	je     f0102116 <mem_init+0x853>
f01020f2:	c7 44 24 0c b4 7a 10 	movl   $0xf0107ab4,0xc(%esp)
f01020f9:	f0 
f01020fa:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102101:	f0 
f0102102:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102109:	00 
f010210a:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102111:	e8 2a df ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102116:	8b 3d 8c 4e 21 f0    	mov    0xf0214e8c,%edi
	return (pp - pages) << PGSHIFT;
f010211c:	a1 90 4e 21 f0       	mov    0xf0214e90,%eax
f0102121:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102124:	8b 17                	mov    (%edi),%edx
f0102126:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010212c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010212f:	29 c1                	sub    %eax,%ecx
f0102131:	89 c8                	mov    %ecx,%eax
f0102133:	c1 f8 03             	sar    $0x3,%eax
f0102136:	c1 e0 0c             	shl    $0xc,%eax
f0102139:	39 c2                	cmp    %eax,%edx
f010213b:	74 24                	je     f0102161 <mem_init+0x89e>
f010213d:	c7 44 24 0c e4 7a 10 	movl   $0xf0107ae4,0xc(%esp)
f0102144:	f0 
f0102145:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010214c:	f0 
f010214d:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102154:	00 
f0102155:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010215c:	e8 df de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102161:	ba 00 00 00 00       	mov    $0x0,%edx
f0102166:	89 f8                	mov    %edi,%eax
f0102168:	e8 13 ee ff ff       	call   f0100f80 <check_va2pa>
f010216d:	89 da                	mov    %ebx,%edx
f010216f:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0102172:	c1 fa 03             	sar    $0x3,%edx
f0102175:	c1 e2 0c             	shl    $0xc,%edx
f0102178:	39 d0                	cmp    %edx,%eax
f010217a:	74 24                	je     f01021a0 <mem_init+0x8dd>
f010217c:	c7 44 24 0c 0c 7b 10 	movl   $0xf0107b0c,0xc(%esp)
f0102183:	f0 
f0102184:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010218b:	f0 
f010218c:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102193:	00 
f0102194:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010219b:	e8 a0 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01021a0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021a5:	74 24                	je     f01021cb <mem_init+0x908>
f01021a7:	c7 44 24 0c 05 84 10 	movl   $0xf0108405,0xc(%esp)
f01021ae:	f0 
f01021af:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01021b6:	f0 
f01021b7:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f01021be:	00 
f01021bf:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01021c6:	e8 75 de ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01021cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ce:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021d3:	74 24                	je     f01021f9 <mem_init+0x936>
f01021d5:	c7 44 24 0c 16 84 10 	movl   $0xf0108416,0xc(%esp)
f01021dc:	f0 
f01021dd:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01021e4:	f0 
f01021e5:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01021ec:	00 
f01021ed:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01021f4:	e8 47 de ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021f9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102200:	00 
f0102201:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102208:	00 
f0102209:	89 74 24 04          	mov    %esi,0x4(%esp)
f010220d:	89 3c 24             	mov    %edi,(%esp)
f0102210:	e8 d1 f5 ff ff       	call   f01017e6 <page_insert>
f0102215:	85 c0                	test   %eax,%eax
f0102217:	74 24                	je     f010223d <mem_init+0x97a>
f0102219:	c7 44 24 0c 3c 7b 10 	movl   $0xf0107b3c,0xc(%esp)
f0102220:	f0 
f0102221:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102228:	f0 
f0102229:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102230:	00 
f0102231:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102238:	e8 03 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010223d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102242:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102247:	e8 34 ed ff ff       	call   f0100f80 <check_va2pa>
f010224c:	89 f2                	mov    %esi,%edx
f010224e:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f0102254:	c1 fa 03             	sar    $0x3,%edx
f0102257:	c1 e2 0c             	shl    $0xc,%edx
f010225a:	39 d0                	cmp    %edx,%eax
f010225c:	74 24                	je     f0102282 <mem_init+0x9bf>
f010225e:	c7 44 24 0c 78 7b 10 	movl   $0xf0107b78,0xc(%esp)
f0102265:	f0 
f0102266:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010226d:	f0 
f010226e:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102275:	00 
f0102276:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010227d:	e8 be dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102282:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102287:	74 24                	je     f01022ad <mem_init+0x9ea>
f0102289:	c7 44 24 0c 27 84 10 	movl   $0xf0108427,0xc(%esp)
f0102290:	f0 
f0102291:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102298:	f0 
f0102299:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f01022a0:	00 
f01022a1:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01022a8:	e8 93 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022b4:	e8 df f1 ff ff       	call   f0101498 <page_alloc>
f01022b9:	85 c0                	test   %eax,%eax
f01022bb:	74 24                	je     f01022e1 <mem_init+0xa1e>
f01022bd:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f01022c4:	f0 
f01022c5:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01022cc:	f0 
f01022cd:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01022d4:	00 
f01022d5:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01022dc:	e8 5f dd ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022e1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022e8:	00 
f01022e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022f0:	00 
f01022f1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022f5:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01022fa:	89 04 24             	mov    %eax,(%esp)
f01022fd:	e8 e4 f4 ff ff       	call   f01017e6 <page_insert>
f0102302:	85 c0                	test   %eax,%eax
f0102304:	74 24                	je     f010232a <mem_init+0xa67>
f0102306:	c7 44 24 0c 3c 7b 10 	movl   $0xf0107b3c,0xc(%esp)
f010230d:	f0 
f010230e:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102315:	f0 
f0102316:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f010231d:	00 
f010231e:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102325:	e8 16 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010232a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010232f:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102334:	e8 47 ec ff ff       	call   f0100f80 <check_va2pa>
f0102339:	89 f2                	mov    %esi,%edx
f010233b:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f0102341:	c1 fa 03             	sar    $0x3,%edx
f0102344:	c1 e2 0c             	shl    $0xc,%edx
f0102347:	39 d0                	cmp    %edx,%eax
f0102349:	74 24                	je     f010236f <mem_init+0xaac>
f010234b:	c7 44 24 0c 78 7b 10 	movl   $0xf0107b78,0xc(%esp)
f0102352:	f0 
f0102353:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010235a:	f0 
f010235b:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102362:	00 
f0102363:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010236a:	e8 d1 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010236f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102374:	74 24                	je     f010239a <mem_init+0xad7>
f0102376:	c7 44 24 0c 27 84 10 	movl   $0xf0108427,0xc(%esp)
f010237d:	f0 
f010237e:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102385:	f0 
f0102386:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f010238d:	00 
f010238e:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102395:	e8 a6 dc ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010239a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023a1:	e8 f2 f0 ff ff       	call   f0101498 <page_alloc>
f01023a6:	85 c0                	test   %eax,%eax
f01023a8:	74 24                	je     f01023ce <mem_init+0xb0b>
f01023aa:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f01023b1:	f0 
f01023b2:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01023b9:	f0 
f01023ba:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01023c1:	00 
f01023c2:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01023c9:	e8 72 dc ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01023ce:	8b 15 8c 4e 21 f0    	mov    0xf0214e8c,%edx
f01023d4:	8b 02                	mov    (%edx),%eax
f01023d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01023db:	89 c1                	mov    %eax,%ecx
f01023dd:	c1 e9 0c             	shr    $0xc,%ecx
f01023e0:	3b 0d 88 4e 21 f0    	cmp    0xf0214e88,%ecx
f01023e6:	72 20                	jb     f0102408 <mem_init+0xb45>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023ec:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f01023f3:	f0 
f01023f4:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01023fb:	00 
f01023fc:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102403:	e8 38 dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102408:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010240d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102410:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102417:	00 
f0102418:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010241f:	00 
f0102420:	89 14 24             	mov    %edx,(%esp)
f0102423:	e8 5e f1 ff ff       	call   f0101586 <pgdir_walk>
f0102428:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010242b:	8d 51 04             	lea    0x4(%ecx),%edx
f010242e:	39 d0                	cmp    %edx,%eax
f0102430:	74 24                	je     f0102456 <mem_init+0xb93>
f0102432:	c7 44 24 0c a8 7b 10 	movl   $0xf0107ba8,0xc(%esp)
f0102439:	f0 
f010243a:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102441:	f0 
f0102442:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102449:	00 
f010244a:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102451:	e8 ea db ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102456:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010245d:	00 
f010245e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102465:	00 
f0102466:	89 74 24 04          	mov    %esi,0x4(%esp)
f010246a:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f010246f:	89 04 24             	mov    %eax,(%esp)
f0102472:	e8 6f f3 ff ff       	call   f01017e6 <page_insert>
f0102477:	85 c0                	test   %eax,%eax
f0102479:	74 24                	je     f010249f <mem_init+0xbdc>
f010247b:	c7 44 24 0c e8 7b 10 	movl   $0xf0107be8,0xc(%esp)
f0102482:	f0 
f0102483:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010248a:	f0 
f010248b:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0102492:	00 
f0102493:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010249a:	e8 a1 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010249f:	8b 3d 8c 4e 21 f0    	mov    0xf0214e8c,%edi
f01024a5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024aa:	89 f8                	mov    %edi,%eax
f01024ac:	e8 cf ea ff ff       	call   f0100f80 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01024b1:	89 f2                	mov    %esi,%edx
f01024b3:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f01024b9:	c1 fa 03             	sar    $0x3,%edx
f01024bc:	c1 e2 0c             	shl    $0xc,%edx
f01024bf:	39 d0                	cmp    %edx,%eax
f01024c1:	74 24                	je     f01024e7 <mem_init+0xc24>
f01024c3:	c7 44 24 0c 78 7b 10 	movl   $0xf0107b78,0xc(%esp)
f01024ca:	f0 
f01024cb:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01024d2:	f0 
f01024d3:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f01024da:	00 
f01024db:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01024e2:	e8 59 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01024e7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024ec:	74 24                	je     f0102512 <mem_init+0xc4f>
f01024ee:	c7 44 24 0c 27 84 10 	movl   $0xf0108427,0xc(%esp)
f01024f5:	f0 
f01024f6:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01024fd:	f0 
f01024fe:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102505:	00 
f0102506:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010250d:	e8 2e db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102512:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102519:	00 
f010251a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102521:	00 
f0102522:	89 3c 24             	mov    %edi,(%esp)
f0102525:	e8 5c f0 ff ff       	call   f0101586 <pgdir_walk>
f010252a:	f6 00 04             	testb  $0x4,(%eax)
f010252d:	75 24                	jne    f0102553 <mem_init+0xc90>
f010252f:	c7 44 24 0c 28 7c 10 	movl   $0xf0107c28,0xc(%esp)
f0102536:	f0 
f0102537:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010253e:	f0 
f010253f:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102546:	00 
f0102547:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010254e:	e8 ed da ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102553:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102558:	f6 00 04             	testb  $0x4,(%eax)
f010255b:	75 24                	jne    f0102581 <mem_init+0xcbe>
f010255d:	c7 44 24 0c 38 84 10 	movl   $0xf0108438,0xc(%esp)
f0102564:	f0 
f0102565:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010256c:	f0 
f010256d:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f0102574:	00 
f0102575:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010257c:	e8 bf da ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102581:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102588:	00 
f0102589:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102590:	00 
f0102591:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102595:	89 04 24             	mov    %eax,(%esp)
f0102598:	e8 49 f2 ff ff       	call   f01017e6 <page_insert>
f010259d:	85 c0                	test   %eax,%eax
f010259f:	74 24                	je     f01025c5 <mem_init+0xd02>
f01025a1:	c7 44 24 0c 3c 7b 10 	movl   $0xf0107b3c,0xc(%esp)
f01025a8:	f0 
f01025a9:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01025b0:	f0 
f01025b1:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f01025b8:	00 
f01025b9:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01025c0:	e8 7b da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01025c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025cc:	00 
f01025cd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025d4:	00 
f01025d5:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01025da:	89 04 24             	mov    %eax,(%esp)
f01025dd:	e8 a4 ef ff ff       	call   f0101586 <pgdir_walk>
f01025e2:	f6 00 02             	testb  $0x2,(%eax)
f01025e5:	75 24                	jne    f010260b <mem_init+0xd48>
f01025e7:	c7 44 24 0c 5c 7c 10 	movl   $0xf0107c5c,0xc(%esp)
f01025ee:	f0 
f01025ef:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01025f6:	f0 
f01025f7:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01025fe:	00 
f01025ff:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102606:	e8 35 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010260b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102612:	00 
f0102613:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010261a:	00 
f010261b:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102620:	89 04 24             	mov    %eax,(%esp)
f0102623:	e8 5e ef ff ff       	call   f0101586 <pgdir_walk>
f0102628:	f6 00 04             	testb  $0x4,(%eax)
f010262b:	74 24                	je     f0102651 <mem_init+0xd8e>
f010262d:	c7 44 24 0c 90 7c 10 	movl   $0xf0107c90,0xc(%esp)
f0102634:	f0 
f0102635:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010263c:	f0 
f010263d:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0102644:	00 
f0102645:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010264c:	e8 ef d9 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102651:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102658:	00 
f0102659:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102660:	00 
f0102661:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102664:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102668:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f010266d:	89 04 24             	mov    %eax,(%esp)
f0102670:	e8 71 f1 ff ff       	call   f01017e6 <page_insert>
f0102675:	85 c0                	test   %eax,%eax
f0102677:	78 24                	js     f010269d <mem_init+0xdda>
f0102679:	c7 44 24 0c c8 7c 10 	movl   $0xf0107cc8,0xc(%esp)
f0102680:	f0 
f0102681:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102688:	f0 
f0102689:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102690:	00 
f0102691:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102698:	e8 a3 d9 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010269d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01026a4:	00 
f01026a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026ac:	00 
f01026ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01026b1:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01026b6:	89 04 24             	mov    %eax,(%esp)
f01026b9:	e8 28 f1 ff ff       	call   f01017e6 <page_insert>
f01026be:	85 c0                	test   %eax,%eax
f01026c0:	74 24                	je     f01026e6 <mem_init+0xe23>
f01026c2:	c7 44 24 0c 00 7d 10 	movl   $0xf0107d00,0xc(%esp)
f01026c9:	f0 
f01026ca:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01026d1:	f0 
f01026d2:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f01026d9:	00 
f01026da:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01026e1:	e8 5a d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026ed:	00 
f01026ee:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026f5:	00 
f01026f6:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01026fb:	89 04 24             	mov    %eax,(%esp)
f01026fe:	e8 83 ee ff ff       	call   f0101586 <pgdir_walk>
f0102703:	f6 00 04             	testb  $0x4,(%eax)
f0102706:	74 24                	je     f010272c <mem_init+0xe69>
f0102708:	c7 44 24 0c 90 7c 10 	movl   $0xf0107c90,0xc(%esp)
f010270f:	f0 
f0102710:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102717:	f0 
f0102718:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f010271f:	00 
f0102720:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102727:	e8 14 d9 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010272c:	8b 3d 8c 4e 21 f0    	mov    0xf0214e8c,%edi
f0102732:	ba 00 00 00 00       	mov    $0x0,%edx
f0102737:	89 f8                	mov    %edi,%eax
f0102739:	e8 42 e8 ff ff       	call   f0100f80 <check_va2pa>
f010273e:	89 c1                	mov    %eax,%ecx
f0102740:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102743:	89 d8                	mov    %ebx,%eax
f0102745:	2b 05 90 4e 21 f0    	sub    0xf0214e90,%eax
f010274b:	c1 f8 03             	sar    $0x3,%eax
f010274e:	c1 e0 0c             	shl    $0xc,%eax
f0102751:	39 c1                	cmp    %eax,%ecx
f0102753:	74 24                	je     f0102779 <mem_init+0xeb6>
f0102755:	c7 44 24 0c 3c 7d 10 	movl   $0xf0107d3c,0xc(%esp)
f010275c:	f0 
f010275d:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102764:	f0 
f0102765:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f010276c:	00 
f010276d:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102774:	e8 c7 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102779:	ba 00 10 00 00       	mov    $0x1000,%edx
f010277e:	89 f8                	mov    %edi,%eax
f0102780:	e8 fb e7 ff ff       	call   f0100f80 <check_va2pa>
f0102785:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102788:	74 24                	je     f01027ae <mem_init+0xeeb>
f010278a:	c7 44 24 0c 68 7d 10 	movl   $0xf0107d68,0xc(%esp)
f0102791:	f0 
f0102792:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102799:	f0 
f010279a:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f01027a1:	00 
f01027a2:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01027a9:	e8 92 d8 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01027ae:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01027b3:	74 24                	je     f01027d9 <mem_init+0xf16>
f01027b5:	c7 44 24 0c 4e 84 10 	movl   $0xf010844e,0xc(%esp)
f01027bc:	f0 
f01027bd:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01027c4:	f0 
f01027c5:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f01027cc:	00 
f01027cd:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01027d4:	e8 67 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01027d9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01027de:	74 24                	je     f0102804 <mem_init+0xf41>
f01027e0:	c7 44 24 0c 5f 84 10 	movl   $0xf010845f,0xc(%esp)
f01027e7:	f0 
f01027e8:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01027ef:	f0 
f01027f0:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f01027f7:	00 
f01027f8:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01027ff:	e8 3c d8 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102804:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010280b:	e8 88 ec ff ff       	call   f0101498 <page_alloc>
f0102810:	85 c0                	test   %eax,%eax
f0102812:	74 04                	je     f0102818 <mem_init+0xf55>
f0102814:	39 c6                	cmp    %eax,%esi
f0102816:	74 24                	je     f010283c <mem_init+0xf79>
f0102818:	c7 44 24 0c 98 7d 10 	movl   $0xf0107d98,0xc(%esp)
f010281f:	f0 
f0102820:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102827:	f0 
f0102828:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f010282f:	00 
f0102830:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102837:	e8 04 d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010283c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102843:	00 
f0102844:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102849:	89 04 24             	mov    %eax,(%esp)
f010284c:	e8 44 ef ff ff       	call   f0101795 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102851:	8b 3d 8c 4e 21 f0    	mov    0xf0214e8c,%edi
f0102857:	ba 00 00 00 00       	mov    $0x0,%edx
f010285c:	89 f8                	mov    %edi,%eax
f010285e:	e8 1d e7 ff ff       	call   f0100f80 <check_va2pa>
f0102863:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102866:	74 24                	je     f010288c <mem_init+0xfc9>
f0102868:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f010286f:	f0 
f0102870:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102877:	f0 
f0102878:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f010287f:	00 
f0102880:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102887:	e8 b4 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010288c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102891:	89 f8                	mov    %edi,%eax
f0102893:	e8 e8 e6 ff ff       	call   f0100f80 <check_va2pa>
f0102898:	89 da                	mov    %ebx,%edx
f010289a:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f01028a0:	c1 fa 03             	sar    $0x3,%edx
f01028a3:	c1 e2 0c             	shl    $0xc,%edx
f01028a6:	39 d0                	cmp    %edx,%eax
f01028a8:	74 24                	je     f01028ce <mem_init+0x100b>
f01028aa:	c7 44 24 0c 68 7d 10 	movl   $0xf0107d68,0xc(%esp)
f01028b1:	f0 
f01028b2:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01028b9:	f0 
f01028ba:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f01028c1:	00 
f01028c2:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01028ce:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01028d3:	74 24                	je     f01028f9 <mem_init+0x1036>
f01028d5:	c7 44 24 0c 05 84 10 	movl   $0xf0108405,0xc(%esp)
f01028dc:	f0 
f01028dd:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01028e4:	f0 
f01028e5:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01028ec:	00 
f01028ed:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01028f4:	e8 47 d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01028f9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01028fe:	74 24                	je     f0102924 <mem_init+0x1061>
f0102900:	c7 44 24 0c 5f 84 10 	movl   $0xf010845f,0xc(%esp)
f0102907:	f0 
f0102908:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010290f:	f0 
f0102910:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102917:	00 
f0102918:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010291f:	e8 1c d7 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102924:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010292b:	00 
f010292c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102933:	00 
f0102934:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102938:	89 3c 24             	mov    %edi,(%esp)
f010293b:	e8 a6 ee ff ff       	call   f01017e6 <page_insert>
f0102940:	85 c0                	test   %eax,%eax
f0102942:	74 24                	je     f0102968 <mem_init+0x10a5>
f0102944:	c7 44 24 0c e0 7d 10 	movl   $0xf0107de0,0xc(%esp)
f010294b:	f0 
f010294c:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102953:	f0 
f0102954:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f010295b:	00 
f010295c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102968:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010296d:	75 24                	jne    f0102993 <mem_init+0x10d0>
f010296f:	c7 44 24 0c 70 84 10 	movl   $0xf0108470,0xc(%esp)
f0102976:	f0 
f0102977:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010297e:	f0 
f010297f:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0102986:	00 
f0102987:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010298e:	e8 ad d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102993:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102996:	74 24                	je     f01029bc <mem_init+0x10f9>
f0102998:	c7 44 24 0c 7c 84 10 	movl   $0xf010847c,0xc(%esp)
f010299f:	f0 
f01029a0:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01029a7:	f0 
f01029a8:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f01029af:	00 
f01029b0:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01029b7:	e8 84 d6 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01029bc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029c3:	00 
f01029c4:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01029c9:	89 04 24             	mov    %eax,(%esp)
f01029cc:	e8 c4 ed ff ff       	call   f0101795 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01029d1:	8b 3d 8c 4e 21 f0    	mov    0xf0214e8c,%edi
f01029d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01029dc:	89 f8                	mov    %edi,%eax
f01029de:	e8 9d e5 ff ff       	call   f0100f80 <check_va2pa>
f01029e3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029e6:	74 24                	je     f0102a0c <mem_init+0x1149>
f01029e8:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a0c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a11:	89 f8                	mov    %edi,%eax
f0102a13:	e8 68 e5 ff ff       	call   f0100f80 <check_va2pa>
f0102a18:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a1b:	74 24                	je     f0102a41 <mem_init+0x117e>
f0102a1d:	c7 44 24 0c 18 7e 10 	movl   $0xf0107e18,0xc(%esp)
f0102a24:	f0 
f0102a25:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102a2c:	f0 
f0102a2d:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102a34:	00 
f0102a35:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102a3c:	e8 ff d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102a41:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a46:	74 24                	je     f0102a6c <mem_init+0x11a9>
f0102a48:	c7 44 24 0c 91 84 10 	movl   $0xf0108491,0xc(%esp)
f0102a4f:	f0 
f0102a50:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102a57:	f0 
f0102a58:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102a5f:	00 
f0102a60:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102a67:	e8 d4 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a6c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102a71:	74 24                	je     f0102a97 <mem_init+0x11d4>
f0102a73:	c7 44 24 0c 5f 84 10 	movl   $0xf010845f,0xc(%esp)
f0102a7a:	f0 
f0102a7b:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102a82:	f0 
f0102a83:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0102a8a:	00 
f0102a8b:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102a92:	e8 a9 d5 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a9e:	e8 f5 e9 ff ff       	call   f0101498 <page_alloc>
f0102aa3:	85 c0                	test   %eax,%eax
f0102aa5:	74 04                	je     f0102aab <mem_init+0x11e8>
f0102aa7:	39 c3                	cmp    %eax,%ebx
f0102aa9:	74 24                	je     f0102acf <mem_init+0x120c>
f0102aab:	c7 44 24 0c 40 7e 10 	movl   $0xf0107e40,0xc(%esp)
f0102ab2:	f0 
f0102ab3:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102aba:	f0 
f0102abb:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0102ac2:	00 
f0102ac3:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102aca:	e8 71 d5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102acf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ad6:	e8 bd e9 ff ff       	call   f0101498 <page_alloc>
f0102adb:	85 c0                	test   %eax,%eax
f0102add:	74 24                	je     f0102b03 <mem_init+0x1240>
f0102adf:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f0102ae6:	f0 
f0102ae7:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102aee:	f0 
f0102aef:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f0102af6:	00 
f0102af7:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102afe:	e8 3d d5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b03:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102b08:	8b 08                	mov    (%eax),%ecx
f0102b0a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b10:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b13:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f0102b19:	c1 fa 03             	sar    $0x3,%edx
f0102b1c:	c1 e2 0c             	shl    $0xc,%edx
f0102b1f:	39 d1                	cmp    %edx,%ecx
f0102b21:	74 24                	je     f0102b47 <mem_init+0x1284>
f0102b23:	c7 44 24 0c e4 7a 10 	movl   $0xf0107ae4,0xc(%esp)
f0102b2a:	f0 
f0102b2b:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102b32:	f0 
f0102b33:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0102b3a:	00 
f0102b3b:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102b42:	e8 f9 d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102b47:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b50:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102b55:	74 24                	je     f0102b7b <mem_init+0x12b8>
f0102b57:	c7 44 24 0c 16 84 10 	movl   $0xf0108416,0xc(%esp)
f0102b5e:	f0 
f0102b5f:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102b66:	f0 
f0102b67:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f0102b6e:	00 
f0102b6f:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102b76:	e8 c5 d4 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102b7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b7e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b84:	89 04 24             	mov    %eax,(%esp)
f0102b87:	e8 97 e9 ff ff       	call   f0101523 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102b8c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b93:	00 
f0102b94:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b9b:	00 
f0102b9c:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102ba1:	89 04 24             	mov    %eax,(%esp)
f0102ba4:	e8 dd e9 ff ff       	call   f0101586 <pgdir_walk>
f0102ba9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102bac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102baf:	8b 15 8c 4e 21 f0    	mov    0xf0214e8c,%edx
f0102bb5:	8b 7a 04             	mov    0x4(%edx),%edi
f0102bb8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0102bbe:	8b 0d 88 4e 21 f0    	mov    0xf0214e88,%ecx
f0102bc4:	89 f8                	mov    %edi,%eax
f0102bc6:	c1 e8 0c             	shr    $0xc,%eax
f0102bc9:	39 c8                	cmp    %ecx,%eax
f0102bcb:	72 20                	jb     f0102bed <mem_init+0x132a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bcd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102bd1:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0102bd8:	f0 
f0102bd9:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102be0:	00 
f0102be1:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102be8:	e8 53 d4 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102bed:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102bf3:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102bf6:	74 24                	je     f0102c1c <mem_init+0x1359>
f0102bf8:	c7 44 24 0c a2 84 10 	movl   $0xf01084a2,0xc(%esp)
f0102bff:	f0 
f0102c00:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102c07:	f0 
f0102c08:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0102c0f:	00 
f0102c10:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102c17:	e8 24 d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102c1c:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102c23:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c26:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102c2c:	2b 05 90 4e 21 f0    	sub    0xf0214e90,%eax
f0102c32:	c1 f8 03             	sar    $0x3,%eax
f0102c35:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c38:	89 c2                	mov    %eax,%edx
f0102c3a:	c1 ea 0c             	shr    $0xc,%edx
f0102c3d:	39 d1                	cmp    %edx,%ecx
f0102c3f:	77 20                	ja     f0102c61 <mem_init+0x139e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c45:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0102c4c:	f0 
f0102c4d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c54:	00 
f0102c55:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0102c5c:	e8 df d3 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c61:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c68:	00 
f0102c69:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c70:	00 
	return (void *)(pa + KERNBASE);
f0102c71:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c76:	89 04 24             	mov    %eax,(%esp)
f0102c79:	e8 09 36 00 00       	call   f0106287 <memset>
	page_free(pp0);
f0102c7e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102c81:	89 3c 24             	mov    %edi,(%esp)
f0102c84:	e8 9a e8 ff ff       	call   f0101523 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102c89:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c90:	00 
f0102c91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c98:	00 
f0102c99:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102c9e:	89 04 24             	mov    %eax,(%esp)
f0102ca1:	e8 e0 e8 ff ff       	call   f0101586 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102ca6:	89 fa                	mov    %edi,%edx
f0102ca8:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f0102cae:	c1 fa 03             	sar    $0x3,%edx
f0102cb1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102cb4:	89 d0                	mov    %edx,%eax
f0102cb6:	c1 e8 0c             	shr    $0xc,%eax
f0102cb9:	3b 05 88 4e 21 f0    	cmp    0xf0214e88,%eax
f0102cbf:	72 20                	jb     f0102ce1 <mem_init+0x141e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cc5:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0102ccc:	f0 
f0102ccd:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102cd4:	00 
f0102cd5:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0102cdc:	e8 5f d3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102ce1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102ce7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102cea:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102cf0:	f6 00 01             	testb  $0x1,(%eax)
f0102cf3:	74 24                	je     f0102d19 <mem_init+0x1456>
f0102cf5:	c7 44 24 0c ba 84 10 	movl   $0xf01084ba,0xc(%esp)
f0102cfc:	f0 
f0102cfd:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102d04:	f0 
f0102d05:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f0102d0c:	00 
f0102d0d:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102d14:	e8 27 d3 ff ff       	call   f0100040 <_panic>
f0102d19:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102d1c:	39 d0                	cmp    %edx,%eax
f0102d1e:	75 d0                	jne    f0102cf0 <mem_init+0x142d>
	kern_pgdir[0] = 0;
f0102d20:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102d25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d2e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102d34:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102d37:	89 0d 40 42 21 f0    	mov    %ecx,0xf0214240

	// free the pages we took
	page_free(pp0);
f0102d3d:	89 04 24             	mov    %eax,(%esp)
f0102d40:	e8 de e7 ff ff       	call   f0101523 <page_free>
	page_free(pp1);
f0102d45:	89 1c 24             	mov    %ebx,(%esp)
f0102d48:	e8 d6 e7 ff ff       	call   f0101523 <page_free>
	page_free(pp2);
f0102d4d:	89 34 24             	mov    %esi,(%esp)
f0102d50:	e8 ce e7 ff ff       	call   f0101523 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102d55:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102d5c:	00 
f0102d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d64:	e8 ec ea ff ff       	call   f0101855 <mmio_map_region>
f0102d69:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102d6b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102d72:	00 
f0102d73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d7a:	e8 d6 ea ff ff       	call   f0101855 <mmio_map_region>
f0102d7f:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102d81:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102d87:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102d8c:	77 08                	ja     f0102d96 <mem_init+0x14d3>
f0102d8e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d94:	77 24                	ja     f0102dba <mem_init+0x14f7>
f0102d96:	c7 44 24 0c 64 7e 10 	movl   $0xf0107e64,0xc(%esp)
f0102d9d:	f0 
f0102d9e:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102da5:	f0 
f0102da6:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0102dad:	00 
f0102dae:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102db5:	e8 86 d2 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102dba:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102dc0:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102dc6:	77 08                	ja     f0102dd0 <mem_init+0x150d>
f0102dc8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102dce:	77 24                	ja     f0102df4 <mem_init+0x1531>
f0102dd0:	c7 44 24 0c 8c 7e 10 	movl   $0xf0107e8c,0xc(%esp)
f0102dd7:	f0 
f0102dd8:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102ddf:	f0 
f0102de0:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f0102de7:	00 
f0102de8:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102def:	e8 4c d2 ff ff       	call   f0100040 <_panic>
f0102df4:	89 da                	mov    %ebx,%edx
f0102df6:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102df8:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102dfe:	74 24                	je     f0102e24 <mem_init+0x1561>
f0102e00:	c7 44 24 0c b4 7e 10 	movl   $0xf0107eb4,0xc(%esp)
f0102e07:	f0 
f0102e08:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102e0f:	f0 
f0102e10:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0102e17:	00 
f0102e18:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102e1f:	e8 1c d2 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0102e24:	39 c6                	cmp    %eax,%esi
f0102e26:	73 24                	jae    f0102e4c <mem_init+0x1589>
f0102e28:	c7 44 24 0c d1 84 10 	movl   $0xf01084d1,0xc(%esp)
f0102e2f:	f0 
f0102e30:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102e37:	f0 
f0102e38:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f0102e3f:	00 
f0102e40:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102e47:	e8 f4 d1 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102e4c:	8b 3d 8c 4e 21 f0    	mov    0xf0214e8c,%edi
f0102e52:	89 da                	mov    %ebx,%edx
f0102e54:	89 f8                	mov    %edi,%eax
f0102e56:	e8 25 e1 ff ff       	call   f0100f80 <check_va2pa>
f0102e5b:	85 c0                	test   %eax,%eax
f0102e5d:	74 24                	je     f0102e83 <mem_init+0x15c0>
f0102e5f:	c7 44 24 0c dc 7e 10 	movl   $0xf0107edc,0xc(%esp)
f0102e66:	f0 
f0102e67:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102e6e:	f0 
f0102e6f:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f0102e76:	00 
f0102e77:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102e7e:	e8 bd d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102e83:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102e89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e8c:	89 c2                	mov    %eax,%edx
f0102e8e:	89 f8                	mov    %edi,%eax
f0102e90:	e8 eb e0 ff ff       	call   f0100f80 <check_va2pa>
f0102e95:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102e9a:	74 24                	je     f0102ec0 <mem_init+0x15fd>
f0102e9c:	c7 44 24 0c 00 7f 10 	movl   $0xf0107f00,0xc(%esp)
f0102ea3:	f0 
f0102ea4:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102eab:	f0 
f0102eac:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f0102eb3:	00 
f0102eb4:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102ebb:	e8 80 d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102ec0:	89 f2                	mov    %esi,%edx
f0102ec2:	89 f8                	mov    %edi,%eax
f0102ec4:	e8 b7 e0 ff ff       	call   f0100f80 <check_va2pa>
f0102ec9:	85 c0                	test   %eax,%eax
f0102ecb:	74 24                	je     f0102ef1 <mem_init+0x162e>
f0102ecd:	c7 44 24 0c 30 7f 10 	movl   $0xf0107f30,0xc(%esp)
f0102ed4:	f0 
f0102ed5:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102edc:	f0 
f0102edd:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0102ee4:	00 
f0102ee5:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102eec:	e8 4f d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102ef1:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102ef7:	89 f8                	mov    %edi,%eax
f0102ef9:	e8 82 e0 ff ff       	call   f0100f80 <check_va2pa>
f0102efe:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f01:	74 24                	je     f0102f27 <mem_init+0x1664>
f0102f03:	c7 44 24 0c 54 7f 10 	movl   $0xf0107f54,0xc(%esp)
f0102f0a:	f0 
f0102f0b:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102f12:	f0 
f0102f13:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f0102f1a:	00 
f0102f1b:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102f22:	e8 19 d1 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102f27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f2e:	00 
f0102f2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f33:	89 3c 24             	mov    %edi,(%esp)
f0102f36:	e8 4b e6 ff ff       	call   f0101586 <pgdir_walk>
f0102f3b:	f6 00 1a             	testb  $0x1a,(%eax)
f0102f3e:	75 24                	jne    f0102f64 <mem_init+0x16a1>
f0102f40:	c7 44 24 0c 80 7f 10 	movl   $0xf0107f80,0xc(%esp)
f0102f47:	f0 
f0102f48:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102f4f:	f0 
f0102f50:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102f57:	00 
f0102f58:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102f5f:	e8 dc d0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102f64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f6b:	00 
f0102f6c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f70:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102f75:	89 04 24             	mov    %eax,(%esp)
f0102f78:	e8 09 e6 ff ff       	call   f0101586 <pgdir_walk>
f0102f7d:	f6 00 04             	testb  $0x4,(%eax)
f0102f80:	74 24                	je     f0102fa6 <mem_init+0x16e3>
f0102f82:	c7 44 24 0c c4 7f 10 	movl   $0xf0107fc4,0xc(%esp)
f0102f89:	f0 
f0102f8a:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0102f91:	f0 
f0102f92:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f0102f99:	00 
f0102f9a:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0102fa1:	e8 9a d0 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102fa6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fad:	00 
f0102fae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102fb2:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102fb7:	89 04 24             	mov    %eax,(%esp)
f0102fba:	e8 c7 e5 ff ff       	call   f0101586 <pgdir_walk>
f0102fbf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102fc5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fcc:	00 
f0102fcd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fd4:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102fd9:	89 04 24             	mov    %eax,(%esp)
f0102fdc:	e8 a5 e5 ff ff       	call   f0101586 <pgdir_walk>
f0102fe1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102fe7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fee:	00 
f0102fef:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ff3:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0102ff8:	89 04 24             	mov    %eax,(%esp)
f0102ffb:	e8 86 e5 ff ff       	call   f0101586 <pgdir_walk>
f0103000:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103006:	c7 04 24 e3 84 10 f0 	movl   $0xf01084e3,(%esp)
f010300d:	e8 c9 12 00 00       	call   f01042db <cprintf>
    size_t pages_size = npages * sizeof(struct PageInfo);
f0103012:	a1 88 4e 21 f0       	mov    0xf0214e88,%eax
f0103017:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
    boot_map_region(kern_pgdir, UPAGES, pages_size, PADDR(pages), PTE_U | PTE_P); // Look at memlayout.h to see
f010301e:	a1 90 4e 21 f0       	mov    0xf0214e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0103023:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103028:	77 20                	ja     f010304a <mem_init+0x1787>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010302a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010302e:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103035:	f0 
f0103036:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
f010303d:	00 
f010303e:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103045:	e8 f6 cf ff ff       	call   f0100040 <_panic>
f010304a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103051:	00 
	return (physaddr_t)kva - KERNBASE;
f0103052:	05 00 00 00 10       	add    $0x10000000,%eax
f0103057:	89 04 24             	mov    %eax,(%esp)
f010305a:	89 d9                	mov    %ebx,%ecx
f010305c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103061:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0103066:	e8 02 e6 ff ff       	call   f010166d <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)pages, pages_size, PADDR(pages), PTE_W | PTE_P);
f010306b:	8b 15 90 4e 21 f0    	mov    0xf0214e90,%edx
	if ((uint32_t)kva < KERNBASE)
f0103071:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103077:	77 20                	ja     f0103099 <mem_init+0x17d6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103079:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010307d:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103084:	f0 
f0103085:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
f010308c:	00 
f010308d:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103094:	e8 a7 cf ff ff       	call   f0100040 <_panic>
f0103099:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01030a0:	00 
	return (physaddr_t)kva - KERNBASE;
f01030a1:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01030a7:	89 04 24             	mov    %eax,(%esp)
f01030aa:	89 d9                	mov    %ebx,%ecx
f01030ac:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01030b1:	e8 b7 e5 ff ff       	call   f010166d <boot_map_region>
    boot_map_region(kern_pgdir, UENVS, env_size, PADDR(envs), PTE_U | PTE_P);
f01030b6:	a1 48 42 21 f0       	mov    0xf0214248,%eax
	if ((uint32_t)kva < KERNBASE)
f01030bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030c0:	77 20                	ja     f01030e2 <mem_init+0x181f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030c6:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f01030cd:	f0 
f01030ce:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
f01030d5:	00 
f01030d6:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01030dd:	e8 5e cf ff ff       	call   f0100040 <_panic>
f01030e2:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01030e9:	00 
	return (physaddr_t)kva - KERNBASE;
f01030ea:	05 00 00 00 10       	add    $0x10000000,%eax
f01030ef:	89 04 24             	mov    %eax,(%esp)
f01030f2:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01030f7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01030fc:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0103101:	e8 67 e5 ff ff       	call   f010166d <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0103106:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f010310b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103110:	77 20                	ja     f0103132 <mem_init+0x186f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103112:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103116:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f010311d:	f0 
f010311e:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f0103125:	00 
f0103126:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010312d:	e8 0e cf ff ff       	call   f0100040 <_panic>
    boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0103132:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103139:	00 
f010313a:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0103141:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103146:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010314b:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0103150:	e8 18 e5 ff ff       	call   f010166d <boot_map_region>
f0103155:	bf 00 60 25 f0       	mov    $0xf0256000,%edi
f010315a:	bb 00 60 21 f0       	mov    $0xf0216000,%ebx
f010315f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
	if ((uint32_t)kva < KERNBASE)
f0103164:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010316a:	77 20                	ja     f010318c <mem_init+0x18c9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010316c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103170:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103177:	f0 
f0103178:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f010317f:	00 
f0103180:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103187:	e8 b4 ce ff ff       	call   f0100040 <_panic>
        boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f010318c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103193:	00 
f0103194:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010319a:	89 04 24             	mov    %eax,(%esp)
f010319d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01031a2:	89 f2                	mov    %esi,%edx
f01031a4:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01031a9:	e8 bf e4 ff ff       	call   f010166d <boot_map_region>
f01031ae:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01031b4:	81 ee 00 00 01 00    	sub    $0x10000,%esi
    for(int i = 0; i < NCPU; i++){
f01031ba:	39 fb                	cmp    %edi,%ebx
f01031bc:	75 a6                	jne    f0103164 <mem_init+0x18a1>
    boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W | PTE_P);
f01031be:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01031c5:	00 
f01031c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031cd:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01031d2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01031d7:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01031dc:	e8 8c e4 ff ff       	call   f010166d <boot_map_region>
	pgdir = kern_pgdir;
f01031e1:	8b 3d 8c 4e 21 f0    	mov    0xf0214e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01031e7:	a1 88 4e 21 f0       	mov    0xf0214e88,%eax
f01031ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01031ef:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01031f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01031fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01031fe:	8b 35 90 4e 21 f0    	mov    0xf0214e90,%esi
	if ((uint32_t)kva < KERNBASE)
f0103204:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0103207:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010320d:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0103210:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103215:	eb 6a                	jmp    f0103281 <mem_init+0x19be>
f0103217:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010321d:	89 f8                	mov    %edi,%eax
f010321f:	e8 5c dd ff ff       	call   f0100f80 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0103224:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010322b:	77 20                	ja     f010324d <mem_init+0x198a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010322d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103231:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103238:	f0 
f0103239:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0103240:	00 
f0103241:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103248:	e8 f3 cd ff ff       	call   f0100040 <_panic>
f010324d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103250:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0103253:	39 c2                	cmp    %eax,%edx
f0103255:	74 24                	je     f010327b <mem_init+0x19b8>
f0103257:	c7 44 24 0c f8 7f 10 	movl   $0xf0107ff8,0xc(%esp)
f010325e:	f0 
f010325f:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0103266:	f0 
f0103267:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f010326e:	00 
f010326f:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103276:	e8 c5 cd ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f010327b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103281:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0103284:	77 91                	ja     f0103217 <mem_init+0x1954>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103286:	8b 1d 48 42 21 f0    	mov    0xf0214248,%ebx
	if ((uint32_t)kva < KERNBASE)
f010328c:	89 de                	mov    %ebx,%esi
f010328e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103293:	89 f8                	mov    %edi,%eax
f0103295:	e8 e6 dc ff ff       	call   f0100f80 <check_va2pa>
f010329a:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01032a0:	77 20                	ja     f01032c2 <mem_init+0x19ff>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01032a6:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f01032ad:	f0 
f01032ae:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01032b5:	00 
f01032b6:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01032bd:	e8 7e cd ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f01032c2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01032c7:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f01032cd:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01032d0:	39 d0                	cmp    %edx,%eax
f01032d2:	74 24                	je     f01032f8 <mem_init+0x1a35>
f01032d4:	c7 44 24 0c 2c 80 10 	movl   $0xf010802c,0xc(%esp)
f01032db:	f0 
f01032dc:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01032e3:	f0 
f01032e4:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01032eb:	00 
f01032ec:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01032f3:	e8 48 cd ff ff       	call   f0100040 <_panic>
f01032f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f01032fe:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0103304:	0f 85 ab 05 00 00    	jne    f01038b5 <mem_init+0x1ff2>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010330a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010330d:	c1 e6 0c             	shl    $0xc,%esi
f0103310:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103315:	eb 3b                	jmp    f0103352 <mem_init+0x1a8f>
f0103317:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010331d:	89 f8                	mov    %edi,%eax
f010331f:	e8 5c dc ff ff       	call   f0100f80 <check_va2pa>
f0103324:	39 c3                	cmp    %eax,%ebx
f0103326:	74 24                	je     f010334c <mem_init+0x1a89>
f0103328:	c7 44 24 0c 60 80 10 	movl   $0xf0108060,0xc(%esp)
f010332f:	f0 
f0103330:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0103337:	f0 
f0103338:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f010333f:	00 
f0103340:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103347:	e8 f4 cc ff ff       	call   f0100040 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010334c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103352:	39 f3                	cmp    %esi,%ebx
f0103354:	72 c1                	jb     f0103317 <mem_init+0x1a54>
f0103356:	c7 45 d0 00 60 21 f0 	movl   $0xf0216000,-0x30(%ebp)
f010335d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103364:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0103369:	b8 00 60 21 f0       	mov    $0xf0216000,%eax
f010336e:	05 00 80 00 20       	add    $0x20008000,%eax
f0103373:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103376:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f010337c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010337f:	89 f2                	mov    %esi,%edx
f0103381:	89 f8                	mov    %edi,%eax
f0103383:	e8 f8 db ff ff       	call   f0100f80 <check_va2pa>
f0103388:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010338b:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0103391:	77 20                	ja     f01033b3 <mem_init+0x1af0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103393:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103397:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f010339e:	f0 
f010339f:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01033a6:	00 
f01033a7:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01033ae:	e8 8d cc ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f01033b3:	89 f3                	mov    %esi,%ebx
f01033b5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01033b8:	03 4d d4             	add    -0x2c(%ebp),%ecx
f01033bb:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01033be:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01033c1:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01033c4:	39 c2                	cmp    %eax,%edx
f01033c6:	74 24                	je     f01033ec <mem_init+0x1b29>
f01033c8:	c7 44 24 0c 88 80 10 	movl   $0xf0108088,0xc(%esp)
f01033cf:	f0 
f01033d0:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01033d7:	f0 
f01033d8:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01033df:	00 
f01033e0:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01033e7:	e8 54 cc ff ff       	call   f0100040 <_panic>
f01033ec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01033f2:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f01033f5:	0f 85 a9 04 00 00    	jne    f01038a4 <mem_init+0x1fe1>
f01033fb:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103401:	89 da                	mov    %ebx,%edx
f0103403:	89 f8                	mov    %edi,%eax
f0103405:	e8 76 db ff ff       	call   f0100f80 <check_va2pa>
f010340a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010340d:	74 24                	je     f0103433 <mem_init+0x1b70>
f010340f:	c7 44 24 0c d0 80 10 	movl   $0xf01080d0,0xc(%esp)
f0103416:	f0 
f0103417:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010341e:	f0 
f010341f:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0103426:	00 
f0103427:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010342e:	e8 0d cc ff ff       	call   f0100040 <_panic>
f0103433:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103439:	39 de                	cmp    %ebx,%esi
f010343b:	75 c4                	jne    f0103401 <mem_init+0x1b3e>
f010343d:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103443:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f010344a:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (n = 0; n < NCPU; n++) {
f0103451:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103457:	0f 85 19 ff ff ff    	jne    f0103376 <mem_init+0x1ab3>
f010345d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103462:	e9 c2 00 00 00       	jmp    f0103529 <mem_init+0x1c66>
		switch (i) {
f0103467:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010346d:	83 fa 04             	cmp    $0x4,%edx
f0103470:	77 2e                	ja     f01034a0 <mem_init+0x1bdd>
			assert(pgdir[i] & PTE_P);
f0103472:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103476:	0f 85 aa 00 00 00    	jne    f0103526 <mem_init+0x1c63>
f010347c:	c7 44 24 0c fc 84 10 	movl   $0xf01084fc,0xc(%esp)
f0103483:	f0 
f0103484:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010348b:	f0 
f010348c:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0103493:	00 
f0103494:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010349b:	e8 a0 cb ff ff       	call   f0100040 <_panic>
			if (i >= PDX(KERNBASE)) {
f01034a0:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01034a5:	76 55                	jbe    f01034fc <mem_init+0x1c39>
				assert(pgdir[i] & PTE_P);
f01034a7:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01034aa:	f6 c2 01             	test   $0x1,%dl
f01034ad:	75 24                	jne    f01034d3 <mem_init+0x1c10>
f01034af:	c7 44 24 0c fc 84 10 	movl   $0xf01084fc,0xc(%esp)
f01034b6:	f0 
f01034b7:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01034be:	f0 
f01034bf:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01034c6:	00 
f01034c7:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01034ce:	e8 6d cb ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01034d3:	f6 c2 02             	test   $0x2,%dl
f01034d6:	75 4e                	jne    f0103526 <mem_init+0x1c63>
f01034d8:	c7 44 24 0c 0d 85 10 	movl   $0xf010850d,0xc(%esp)
f01034df:	f0 
f01034e0:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01034e7:	f0 
f01034e8:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f01034ef:	00 
f01034f0:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01034f7:	e8 44 cb ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f01034fc:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0103500:	74 24                	je     f0103526 <mem_init+0x1c63>
f0103502:	c7 44 24 0c 1e 85 10 	movl   $0xf010851e,0xc(%esp)
f0103509:	f0 
f010350a:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0103511:	f0 
f0103512:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0103519:	00 
f010351a:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103521:	e8 1a cb ff ff       	call   f0100040 <_panic>
	for (i = 0; i < NPDENTRIES; i++) {
f0103526:	83 c0 01             	add    $0x1,%eax
f0103529:	3d 00 04 00 00       	cmp    $0x400,%eax
f010352e:	0f 85 33 ff ff ff    	jne    f0103467 <mem_init+0x1ba4>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103534:	c7 04 24 f4 80 10 f0 	movl   $0xf01080f4,(%esp)
f010353b:	e8 9b 0d 00 00       	call   f01042db <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103540:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0103545:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010354a:	77 20                	ja     f010356c <mem_init+0x1ca9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010354c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103550:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103557:	f0 
f0103558:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
f010355f:	00 
f0103560:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103567:	e8 d4 ca ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010356c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103571:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103574:	b8 00 00 00 00       	mov    $0x0,%eax
f0103579:	e8 71 da ff ff       	call   f0100fef <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010357e:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0103581:	83 e0 f3             	and    $0xfffffff3,%eax
f0103584:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0103589:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010358c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103593:	e8 00 df ff ff       	call   f0101498 <page_alloc>
f0103598:	89 c3                	mov    %eax,%ebx
f010359a:	85 c0                	test   %eax,%eax
f010359c:	75 24                	jne    f01035c2 <mem_init+0x1cff>
f010359e:	c7 44 24 0c 08 83 10 	movl   $0xf0108308,0xc(%esp)
f01035a5:	f0 
f01035a6:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01035ad:	f0 
f01035ae:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f01035b5:	00 
f01035b6:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01035bd:	e8 7e ca ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01035c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035c9:	e8 ca de ff ff       	call   f0101498 <page_alloc>
f01035ce:	89 c7                	mov    %eax,%edi
f01035d0:	85 c0                	test   %eax,%eax
f01035d2:	75 24                	jne    f01035f8 <mem_init+0x1d35>
f01035d4:	c7 44 24 0c 1e 83 10 	movl   $0xf010831e,0xc(%esp)
f01035db:	f0 
f01035dc:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01035e3:	f0 
f01035e4:	c7 44 24 04 90 04 00 	movl   $0x490,0x4(%esp)
f01035eb:	00 
f01035ec:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01035f3:	e8 48 ca ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01035f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035ff:	e8 94 de ff ff       	call   f0101498 <page_alloc>
f0103604:	89 c6                	mov    %eax,%esi
f0103606:	85 c0                	test   %eax,%eax
f0103608:	75 24                	jne    f010362e <mem_init+0x1d6b>
f010360a:	c7 44 24 0c 34 83 10 	movl   $0xf0108334,0xc(%esp)
f0103611:	f0 
f0103612:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0103619:	f0 
f010361a:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f0103621:	00 
f0103622:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103629:	e8 12 ca ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010362e:	89 1c 24             	mov    %ebx,(%esp)
f0103631:	e8 ed de ff ff       	call   f0101523 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103636:	89 f8                	mov    %edi,%eax
f0103638:	e8 fe d8 ff ff       	call   f0100f3b <page2kva>
f010363d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103644:	00 
f0103645:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010364c:	00 
f010364d:	89 04 24             	mov    %eax,(%esp)
f0103650:	e8 32 2c 00 00       	call   f0106287 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103655:	89 f0                	mov    %esi,%eax
f0103657:	e8 df d8 ff ff       	call   f0100f3b <page2kva>
f010365c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103663:	00 
f0103664:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010366b:	00 
f010366c:	89 04 24             	mov    %eax,(%esp)
f010366f:	e8 13 2c 00 00       	call   f0106287 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103674:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010367b:	00 
f010367c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103683:	00 
f0103684:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103688:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f010368d:	89 04 24             	mov    %eax,(%esp)
f0103690:	e8 51 e1 ff ff       	call   f01017e6 <page_insert>
	assert(pp1->pp_ref == 1);
f0103695:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010369a:	74 24                	je     f01036c0 <mem_init+0x1dfd>
f010369c:	c7 44 24 0c 05 84 10 	movl   $0xf0108405,0xc(%esp)
f01036a3:	f0 
f01036a4:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01036ab:	f0 
f01036ac:	c7 44 24 04 96 04 00 	movl   $0x496,0x4(%esp)
f01036b3:	00 
f01036b4:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01036bb:	e8 80 c9 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01036c0:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01036c7:	01 01 01 
f01036ca:	74 24                	je     f01036f0 <mem_init+0x1e2d>
f01036cc:	c7 44 24 0c 14 81 10 	movl   $0xf0108114,0xc(%esp)
f01036d3:	f0 
f01036d4:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01036db:	f0 
f01036dc:	c7 44 24 04 97 04 00 	movl   $0x497,0x4(%esp)
f01036e3:	00 
f01036e4:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01036eb:	e8 50 c9 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01036f0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01036f7:	00 
f01036f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01036ff:	00 
f0103700:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103704:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0103709:	89 04 24             	mov    %eax,(%esp)
f010370c:	e8 d5 e0 ff ff       	call   f01017e6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103711:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103718:	02 02 02 
f010371b:	74 24                	je     f0103741 <mem_init+0x1e7e>
f010371d:	c7 44 24 0c 38 81 10 	movl   $0xf0108138,0xc(%esp)
f0103724:	f0 
f0103725:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f010372c:	f0 
f010372d:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f0103734:	00 
f0103735:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010373c:	e8 ff c8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103741:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103746:	74 24                	je     f010376c <mem_init+0x1ea9>
f0103748:	c7 44 24 0c 27 84 10 	movl   $0xf0108427,0xc(%esp)
f010374f:	f0 
f0103750:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0103757:	f0 
f0103758:	c7 44 24 04 9a 04 00 	movl   $0x49a,0x4(%esp)
f010375f:	00 
f0103760:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103767:	e8 d4 c8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010376c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103771:	74 24                	je     f0103797 <mem_init+0x1ed4>
f0103773:	c7 44 24 0c 91 84 10 	movl   $0xf0108491,0xc(%esp)
f010377a:	f0 
f010377b:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0103782:	f0 
f0103783:	c7 44 24 04 9b 04 00 	movl   $0x49b,0x4(%esp)
f010378a:	00 
f010378b:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103792:	e8 a9 c8 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103797:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010379e:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01037a1:	89 f0                	mov    %esi,%eax
f01037a3:	e8 93 d7 ff ff       	call   f0100f3b <page2kva>
f01037a8:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f01037ae:	74 24                	je     f01037d4 <mem_init+0x1f11>
f01037b0:	c7 44 24 0c 5c 81 10 	movl   $0xf010815c,0xc(%esp)
f01037b7:	f0 
f01037b8:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01037bf:	f0 
f01037c0:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f01037c7:	00 
f01037c8:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f01037cf:	e8 6c c8 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01037d4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01037db:	00 
f01037dc:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f01037e1:	89 04 24             	mov    %eax,(%esp)
f01037e4:	e8 ac df ff ff       	call   f0101795 <page_remove>
	assert(pp2->pp_ref == 0);
f01037e9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01037ee:	74 24                	je     f0103814 <mem_init+0x1f51>
f01037f0:	c7 44 24 0c 5f 84 10 	movl   $0xf010845f,0xc(%esp)
f01037f7:	f0 
f01037f8:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f01037ff:	f0 
f0103800:	c7 44 24 04 9f 04 00 	movl   $0x49f,0x4(%esp)
f0103807:	00 
f0103808:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f010380f:	e8 2c c8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103814:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
f0103819:	8b 08                	mov    (%eax),%ecx
f010381b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	return (pp - pages) << PGSHIFT;
f0103821:	89 da                	mov    %ebx,%edx
f0103823:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f0103829:	c1 fa 03             	sar    $0x3,%edx
f010382c:	c1 e2 0c             	shl    $0xc,%edx
f010382f:	39 d1                	cmp    %edx,%ecx
f0103831:	74 24                	je     f0103857 <mem_init+0x1f94>
f0103833:	c7 44 24 0c e4 7a 10 	movl   $0xf0107ae4,0xc(%esp)
f010383a:	f0 
f010383b:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0103842:	f0 
f0103843:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f010384a:	00 
f010384b:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103852:	e8 e9 c7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103857:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010385d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103862:	74 24                	je     f0103888 <mem_init+0x1fc5>
f0103864:	c7 44 24 0c 16 84 10 	movl   $0xf0108416,0xc(%esp)
f010386b:	f0 
f010386c:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0103873:	f0 
f0103874:	c7 44 24 04 a4 04 00 	movl   $0x4a4,0x4(%esp)
f010387b:	00 
f010387c:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0103883:	e8 b8 c7 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103888:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010388e:	89 1c 24             	mov    %ebx,(%esp)
f0103891:	e8 8d dc ff ff       	call   f0101523 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103896:	c7 04 24 88 81 10 f0 	movl   $0xf0108188,(%esp)
f010389d:	e8 39 0a 00 00       	call   f01042db <cprintf>
f01038a2:	eb 21                	jmp    f01038c5 <mem_init+0x2002>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01038a4:	89 da                	mov    %ebx,%edx
f01038a6:	89 f8                	mov    %edi,%eax
f01038a8:	e8 d3 d6 ff ff       	call   f0100f80 <check_va2pa>
f01038ad:	8d 76 00             	lea    0x0(%esi),%esi
f01038b0:	e9 09 fb ff ff       	jmp    f01033be <mem_init+0x1afb>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01038b5:	89 da                	mov    %ebx,%edx
f01038b7:	89 f8                	mov    %edi,%eax
f01038b9:	e8 c2 d6 ff ff       	call   f0100f80 <check_va2pa>
f01038be:	66 90                	xchg   %ax,%ax
f01038c0:	e9 08 fa ff ff       	jmp    f01032cd <mem_init+0x1a0a>
}
f01038c5:	83 c4 4c             	add    $0x4c,%esp
f01038c8:	5b                   	pop    %ebx
f01038c9:	5e                   	pop    %esi
f01038ca:	5f                   	pop    %edi
f01038cb:	5d                   	pop    %ebp
f01038cc:	c3                   	ret    

f01038cd <user_mem_check>:
{
f01038cd:	55                   	push   %ebp
f01038ce:	89 e5                	mov    %esp,%ebp
f01038d0:	57                   	push   %edi
f01038d1:	56                   	push   %esi
f01038d2:	53                   	push   %ebx
f01038d3:	83 ec 1c             	sub    $0x1c,%esp
f01038d6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01038d9:	8b 75 14             	mov    0x14(%ebp),%esi
    uint32_t start_va =  (uint32_t)ROUNDDOWN((char *)va, PGSIZE);
f01038dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01038df:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end_va = (uint32_t)ROUNDUP((char *)va+len, PGSIZE);
f01038e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038e8:	03 45 10             	add    0x10(%ebp),%eax
f01038eb:	05 ff 0f 00 00       	add    $0xfff,%eax
f01038f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01038f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(; start_va < end_va; start_va += PGSIZE){
f01038f8:	eb 56                	jmp    f0103950 <user_mem_check+0x83>
        pte_t *pp = pgdir_walk(env->env_pgdir, (void *)start_va, 0);
f01038fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103901:	00 
f0103902:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103906:	8b 47 60             	mov    0x60(%edi),%eax
f0103909:	89 04 24             	mov    %eax,(%esp)
f010390c:	e8 75 dc ff ff       	call   f0101586 <pgdir_walk>
        if( (pp == NULL) || (start_va >= ULIM) || !(*pp & PTE_P) || ((*pp & perm) != perm)){
f0103911:	85 c0                	test   %eax,%eax
f0103913:	74 14                	je     f0103929 <user_mem_check+0x5c>
f0103915:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010391b:	77 0c                	ja     f0103929 <user_mem_check+0x5c>
f010391d:	8b 00                	mov    (%eax),%eax
f010391f:	a8 01                	test   $0x1,%al
f0103921:	74 06                	je     f0103929 <user_mem_check+0x5c>
f0103923:	21 f0                	and    %esi,%eax
f0103925:	39 c6                	cmp    %eax,%esi
f0103927:	74 21                	je     f010394a <user_mem_check+0x7d>
            if(start_va < (uint32_t)va)
f0103929:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f010392c:	76 0f                	jbe    f010393d <user_mem_check+0x70>
                user_mem_check_addr = (uint32_t)va;
f010392e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103931:	a3 3c 42 21 f0       	mov    %eax,0xf021423c
            return -E_FAULT;
f0103936:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010393b:	eb 1d                	jmp    f010395a <user_mem_check+0x8d>
                user_mem_check_addr = start_va;
f010393d:	89 1d 3c 42 21 f0    	mov    %ebx,0xf021423c
            return -E_FAULT;
f0103943:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103948:	eb 10                	jmp    f010395a <user_mem_check+0x8d>
    for(; start_va < end_va; start_va += PGSIZE){
f010394a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103950:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103953:	72 a5                	jb     f01038fa <user_mem_check+0x2d>
	return 0;
f0103955:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010395a:	83 c4 1c             	add    $0x1c,%esp
f010395d:	5b                   	pop    %ebx
f010395e:	5e                   	pop    %esi
f010395f:	5f                   	pop    %edi
f0103960:	5d                   	pop    %ebp
f0103961:	c3                   	ret    

f0103962 <user_mem_assert>:
{
f0103962:	55                   	push   %ebp
f0103963:	89 e5                	mov    %esp,%ebp
f0103965:	53                   	push   %ebx
f0103966:	83 ec 14             	sub    $0x14,%esp
f0103969:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010396c:	8b 45 14             	mov    0x14(%ebp),%eax
f010396f:	83 c8 04             	or     $0x4,%eax
f0103972:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103976:	8b 45 10             	mov    0x10(%ebp),%eax
f0103979:	89 44 24 08          	mov    %eax,0x8(%esp)
f010397d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103980:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103984:	89 1c 24             	mov    %ebx,(%esp)
f0103987:	e8 41 ff ff ff       	call   f01038cd <user_mem_check>
f010398c:	85 c0                	test   %eax,%eax
f010398e:	79 24                	jns    f01039b4 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103990:	a1 3c 42 21 f0       	mov    0xf021423c,%eax
f0103995:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103999:	8b 43 48             	mov    0x48(%ebx),%eax
f010399c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039a0:	c7 04 24 b4 81 10 f0 	movl   $0xf01081b4,(%esp)
f01039a7:	e8 2f 09 00 00       	call   f01042db <cprintf>
		env_destroy(env);	// may not return
f01039ac:	89 1c 24             	mov    %ebx,(%esp)
f01039af:	e8 2c 06 00 00       	call   f0103fe0 <env_destroy>
}
f01039b4:	83 c4 14             	add    $0x14,%esp
f01039b7:	5b                   	pop    %ebx
f01039b8:	5d                   	pop    %ebp
f01039b9:	c3                   	ret    

f01039ba <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01039ba:	55                   	push   %ebp
f01039bb:	89 e5                	mov    %esp,%ebp
f01039bd:	56                   	push   %esi
f01039be:	53                   	push   %ebx
f01039bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01039c2:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01039c5:	85 c0                	test   %eax,%eax
f01039c7:	75 1a                	jne    f01039e3 <envid2env+0x29>
		*env_store = curenv;
f01039c9:	e8 0b 2f 00 00       	call   f01068d9 <cpunum>
f01039ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d1:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01039d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01039da:	89 01                	mov    %eax,(%ecx)
		return 0;
f01039dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01039e1:	eb 70                	jmp    f0103a53 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01039e3:	89 c3                	mov    %eax,%ebx
f01039e5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01039eb:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01039ee:	03 1d 48 42 21 f0    	add    0xf0214248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01039f4:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01039f8:	74 05                	je     f01039ff <envid2env+0x45>
f01039fa:	39 43 48             	cmp    %eax,0x48(%ebx)
f01039fd:	74 10                	je     f0103a0f <envid2env+0x55>
		*env_store = 0;
f01039ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a02:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103a08:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a0d:	eb 44                	jmp    f0103a53 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103a0f:	84 d2                	test   %dl,%dl
f0103a11:	74 36                	je     f0103a49 <envid2env+0x8f>
f0103a13:	e8 c1 2e 00 00       	call   f01068d9 <cpunum>
f0103a18:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a1b:	39 98 28 50 21 f0    	cmp    %ebx,-0xfdeafd8(%eax)
f0103a21:	74 26                	je     f0103a49 <envid2env+0x8f>
f0103a23:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103a26:	e8 ae 2e 00 00       	call   f01068d9 <cpunum>
f0103a2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a2e:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0103a34:	3b 70 48             	cmp    0x48(%eax),%esi
f0103a37:	74 10                	je     f0103a49 <envid2env+0x8f>
		*env_store = 0;
f0103a39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103a42:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a47:	eb 0a                	jmp    f0103a53 <envid2env+0x99>
	}

	*env_store = e;
f0103a49:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a4c:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a53:	5b                   	pop    %ebx
f0103a54:	5e                   	pop    %esi
f0103a55:	5d                   	pop    %ebp
f0103a56:	c3                   	ret    

f0103a57 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103a57:	55                   	push   %ebp
f0103a58:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f0103a5a:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103a5f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103a62:	b8 23 00 00 00       	mov    $0x23,%eax
f0103a67:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103a69:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103a6b:	b0 10                	mov    $0x10,%al
f0103a6d:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103a6f:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103a71:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103a73:	ea 7a 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103a7a
	asm volatile("lldt %0" : : "r" (sel));
f0103a7a:	b0 00                	mov    $0x0,%al
f0103a7c:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103a7f:	5d                   	pop    %ebp
f0103a80:	c3                   	ret    

f0103a81 <env_init>:
{
f0103a81:	55                   	push   %ebp
f0103a82:	89 e5                	mov    %esp,%ebp
f0103a84:	56                   	push   %esi
f0103a85:	53                   	push   %ebx
        envs[i].env_id = 0;
f0103a86:	8b 35 48 42 21 f0    	mov    0xf0214248,%esi
f0103a8c:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103a92:	ba 00 04 00 00       	mov    $0x400,%edx
f0103a97:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103a9c:	89 c3                	mov    %eax,%ebx
f0103a9e:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE; //Same as 0
f0103aa5:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
        envs[i].env_link = env_free_list;
f0103aac:	89 48 44             	mov    %ecx,0x44(%eax)
f0103aaf:	83 e8 7c             	sub    $0x7c,%eax
    for(; i >= 0; i--){
f0103ab2:	83 ea 01             	sub    $0x1,%edx
f0103ab5:	74 04                	je     f0103abb <env_init+0x3a>
        env_free_list = &envs[i];
f0103ab7:	89 d9                	mov    %ebx,%ecx
f0103ab9:	eb e1                	jmp    f0103a9c <env_init+0x1b>
f0103abb:	89 35 4c 42 21 f0    	mov    %esi,0xf021424c
	env_init_percpu();
f0103ac1:	e8 91 ff ff ff       	call   f0103a57 <env_init_percpu>
}
f0103ac6:	5b                   	pop    %ebx
f0103ac7:	5e                   	pop    %esi
f0103ac8:	5d                   	pop    %ebp
f0103ac9:	c3                   	ret    

f0103aca <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103aca:	55                   	push   %ebp
f0103acb:	89 e5                	mov    %esp,%ebp
f0103acd:	53                   	push   %ebx
f0103ace:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103ad1:	8b 1d 4c 42 21 f0    	mov    0xf021424c,%ebx
f0103ad7:	85 db                	test   %ebx,%ebx
f0103ad9:	0f 84 57 01 00 00    	je     f0103c36 <env_alloc+0x16c>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103adf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103ae6:	e8 ad d9 ff ff       	call   f0101498 <page_alloc>
f0103aeb:	85 c0                	test   %eax,%eax
f0103aed:	0f 84 4a 01 00 00    	je     f0103c3d <env_alloc+0x173>
f0103af3:	89 c2                	mov    %eax,%edx
f0103af5:	2b 15 90 4e 21 f0    	sub    0xf0214e90,%edx
f0103afb:	c1 fa 03             	sar    $0x3,%edx
f0103afe:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103b01:	89 d1                	mov    %edx,%ecx
f0103b03:	c1 e9 0c             	shr    $0xc,%ecx
f0103b06:	3b 0d 88 4e 21 f0    	cmp    0xf0214e88,%ecx
f0103b0c:	72 20                	jb     f0103b2e <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b0e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103b12:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0103b19:	f0 
f0103b1a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103b21:	00 
f0103b22:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0103b29:	e8 12 c5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103b2e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103b34:	89 53 60             	mov    %edx,0x60(%ebx)
    p->pp_ref++;
f0103b37:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103b3c:	b8 ec 0e 00 00       	mov    $0xeec,%eax
        e->env_pgdir[x] = kern_pgdir[x]; // If we can use kern_pgdir as a template, then let's just copy it.
f0103b41:	8b 15 8c 4e 21 f0    	mov    0xf0214e8c,%edx
f0103b47:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103b4a:	8b 53 60             	mov    0x60(%ebx),%edx
f0103b4d:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103b50:	83 c0 04             	add    $0x4,%eax
    for(int x = PDX(UTOP); x < NPDENTRIES; ++x){ // NPDENTRIES = 1024, check mmu.h
f0103b53:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103b58:	75 e7                	jne    f0103b41 <env_alloc+0x77>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103b5a:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103b5d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b62:	77 20                	ja     f0103b84 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b64:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b68:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103b6f:	f0 
f0103b70:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0103b77:	00 
f0103b78:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0103b7f:	e8 bc c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b84:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103b8a:	83 ca 05             	or     $0x5,%edx
f0103b8d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103b93:	8b 43 48             	mov    0x48(%ebx),%eax
f0103b96:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103b9b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103ba0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103ba5:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103ba8:	89 da                	mov    %ebx,%edx
f0103baa:	2b 15 48 42 21 f0    	sub    0xf0214248,%edx
f0103bb0:	c1 fa 02             	sar    $0x2,%edx
f0103bb3:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103bb9:	09 d0                	or     %edx,%eax
f0103bbb:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bc1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103bc4:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103bcb:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103bd2:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103bd9:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103be0:	00 
f0103be1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103be8:	00 
f0103be9:	89 1c 24             	mov    %ebx,(%esp)
f0103bec:	e8 96 26 00 00       	call   f0106287 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103bf1:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103bf7:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103bfd:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103c03:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103c0a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
    e->env_tf.tf_eflags |= FL_IF;
f0103c10:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103c17:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103c1e:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103c22:	8b 43 44             	mov    0x44(%ebx),%eax
f0103c25:	a3 4c 42 21 f0       	mov    %eax,0xf021424c
	*newenv_store = e;
f0103c2a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c2d:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103c2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c34:	eb 0c                	jmp    f0103c42 <env_alloc+0x178>
		return -E_NO_FREE_ENV;
f0103c36:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103c3b:	eb 05                	jmp    f0103c42 <env_alloc+0x178>
		return -E_NO_MEM;
f0103c3d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f0103c42:	83 c4 14             	add    $0x14,%esp
f0103c45:	5b                   	pop    %ebx
f0103c46:	5d                   	pop    %ebp
f0103c47:	c3                   	ret    

f0103c48 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103c48:	55                   	push   %ebp
f0103c49:	89 e5                	mov    %esp,%ebp
f0103c4b:	57                   	push   %edi
f0103c4c:	56                   	push   %esi
f0103c4d:	53                   	push   %ebx
f0103c4e:	83 ec 3c             	sub    $0x3c,%esp
f0103c51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
    struct Env *e;
    if( env_alloc(&e, 0) < 0 || e == NULL ) {
f0103c54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c5b:	00 
f0103c5c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103c5f:	89 04 24             	mov    %eax,(%esp)
f0103c62:	e8 63 fe ff ff       	call   f0103aca <env_alloc>
f0103c67:	85 c0                	test   %eax,%eax
f0103c69:	78 07                	js     f0103c72 <env_create+0x2a>
f0103c6b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103c6e:	85 f6                	test   %esi,%esi
f0103c70:	75 1c                	jne    f0103c8e <env_create+0x46>
        panic("env_create: Env_alloc failed");
f0103c72:	c7 44 24 08 57 85 10 	movl   $0xf0108557,0x8(%esp)
f0103c79:	f0 
f0103c7a:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
f0103c81:	00 
f0103c82:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0103c89:	e8 b2 c3 ff ff       	call   f0100040 <_panic>
    }
    e->env_type = type;
f0103c8e:	89 5e 50             	mov    %ebx,0x50(%esi)
    if(e->env_type == ENV_TYPE_FS){
f0103c91:	83 fb 01             	cmp    $0x1,%ebx
f0103c94:	75 07                	jne    f0103c9d <env_create+0x55>
        // Grant IO Flags
        // Reminder, look at inc/mmu.h for flags.
        e->env_tf.tf_eflags = FL_IOPL_3; // What level? I'm going to go with 3 to be safe.
f0103c96:	c7 46 38 00 30 00 00 	movl   $0x3000,0x38(%esi)
	asm volatile("movl %%cr3,%0" : "=r" (val));
f0103c9d:	0f 20 d8             	mov    %cr3,%eax
f0103ca0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    lcr3(PADDR(e->env_pgdir));
f0103ca3:	8b 46 60             	mov    0x60(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103ca6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cab:	77 20                	ja     f0103ccd <env_create+0x85>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cb1:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103cb8:	f0 
f0103cb9:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0103cc0:	00 
f0103cc1:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0103cc8:	e8 73 c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ccd:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103cd2:	0f 22 d8             	mov    %eax,%cr3
    if(e_header->e_magic != ELF_MAGIC){
f0103cd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cd8:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103cde:	74 1c                	je     f0103cfc <env_create+0xb4>
        panic("load_icode: Elf error");
f0103ce0:	c7 44 24 08 74 85 10 	movl   $0xf0108574,0x8(%esp)
f0103ce7:	f0 
f0103ce8:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0103cef:	00 
f0103cf0:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0103cf7:	e8 44 c3 ff ff       	call   f0100040 <_panic>
    ph = (struct Proghdr *) ((uint8_t *)e_header + e_header->e_phoff);
f0103cfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cff:	89 c7                	mov    %eax,%edi
f0103d01:	03 78 1c             	add    0x1c(%eax),%edi
    eph = ph + e_header->e_phnum;
f0103d04:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103d08:	c1 e0 05             	shl    $0x5,%eax
f0103d0b:	01 f8                	add    %edi,%eax
f0103d0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103d10:	e9 b5 00 00 00       	jmp    f0103dca <env_create+0x182>
        if(ph->p_type == ELF_PROG_LOAD){
f0103d15:	83 3f 01             	cmpl   $0x1,(%edi)
f0103d18:	0f 85 a9 00 00 00    	jne    f0103dc7 <env_create+0x17f>
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103d1e:	8b 47 08             	mov    0x8(%edi),%eax
    void *y = ROUNDDOWN(va, PGSIZE);
f0103d21:	89 c3                	mov    %eax,%ebx
f0103d23:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    void *x = ROUNDUP(va+len, PGSIZE);
f0103d29:	03 47 14             	add    0x14(%edi),%eax
f0103d2c:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103d31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103d36:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0103d39:	89 c7                	mov    %eax,%edi
f0103d3b:	eb 4d                	jmp    f0103d8a <env_create+0x142>
        pp = page_alloc(ALLOC_ZERO);
f0103d3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103d44:	e8 4f d7 ff ff       	call   f0101498 <page_alloc>
        if(!pp){
f0103d49:	85 c0                	test   %eax,%eax
f0103d4b:	75 1c                	jne    f0103d69 <env_create+0x121>
            panic("Region Alloc, page alloc failed");
f0103d4d:	c7 44 24 08 2c 85 10 	movl   $0xf010852c,0x8(%esp)
f0103d54:	f0 
f0103d55:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f0103d5c:	00 
f0103d5d:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0103d64:	e8 d7 c2 ff ff       	call   f0100040 <_panic>
        int r = page_insert(e->env_pgdir, pp, y, PTE_U  | PTE_W);
f0103d69:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103d70:	00 
f0103d71:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103d75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d79:	8b 46 60             	mov    0x60(%esi),%eax
f0103d7c:	89 04 24             	mov    %eax,(%esp)
f0103d7f:	e8 62 da ff ff       	call   f01017e6 <page_insert>
    for(; y < x; y += PGSIZE){
f0103d84:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103d8a:	39 df                	cmp    %ebx,%edi
f0103d8c:	77 af                	ja     f0103d3d <env_create+0xf5>
f0103d8e:	8b 7d d0             	mov    -0x30(%ebp),%edi
            memset((void *)ph->p_va, 0, ph->p_memsz);
f0103d91:	8b 47 14             	mov    0x14(%edi),%eax
f0103d94:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d9f:	00 
f0103da0:	8b 47 08             	mov    0x8(%edi),%eax
f0103da3:	89 04 24             	mov    %eax,(%esp)
f0103da6:	e8 dc 24 00 00       	call   f0106287 <memset>
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103dab:	8b 47 10             	mov    0x10(%edi),%eax
f0103dae:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103db2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103db5:	03 47 04             	add    0x4(%edi),%eax
f0103db8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dbc:	8b 47 08             	mov    0x8(%edi),%eax
f0103dbf:	89 04 24             	mov    %eax,(%esp)
f0103dc2:	e8 75 25 00 00       	call   f010633c <memcpy>
    for(; ph < eph; ph++){
f0103dc7:	83 c7 20             	add    $0x20,%edi
f0103dca:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0103dcd:	0f 87 42 ff ff ff    	ja     f0103d15 <env_create+0xcd>
f0103dd3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103dd6:	0f 22 d8             	mov    %eax,%cr3
	page_insert(e->env_pgdir, page_alloc(0), (void *)(USTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
f0103dd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103de0:	e8 b3 d6 ff ff       	call   f0101498 <page_alloc>
f0103de5:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0103dec:	00 
f0103ded:	c7 44 24 08 00 d0 bf 	movl   $0xeebfd000,0x8(%esp)
f0103df4:	ee 
f0103df5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103df9:	8b 46 60             	mov    0x60(%esi),%eax
f0103dfc:	89 04 24             	mov    %eax,(%esp)
f0103dff:	e8 e2 d9 ff ff       	call   f01017e6 <page_insert>
    e->env_tf.tf_eip = e_header->e_entry; // I think this is right.
f0103e04:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e07:	8b 40 18             	mov    0x18(%eax),%eax
f0103e0a:	89 46 30             	mov    %eax,0x30(%esi)
        // Maybe there's a page flag we need to set? I'm not sure, but I don't know quite yet.
    }
    //e->env_parent_id = 0;
    load_icode(e, binary);
}
f0103e0d:	83 c4 3c             	add    $0x3c,%esp
f0103e10:	5b                   	pop    %ebx
f0103e11:	5e                   	pop    %esi
f0103e12:	5f                   	pop    %edi
f0103e13:	5d                   	pop    %ebp
f0103e14:	c3                   	ret    

f0103e15 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103e15:	55                   	push   %ebp
f0103e16:	89 e5                	mov    %esp,%ebp
f0103e18:	57                   	push   %edi
f0103e19:	56                   	push   %esi
f0103e1a:	53                   	push   %ebx
f0103e1b:	83 ec 2c             	sub    $0x2c,%esp
f0103e1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103e21:	e8 b3 2a 00 00       	call   f01068d9 <cpunum>
f0103e26:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e29:	39 b8 28 50 21 f0    	cmp    %edi,-0xfdeafd8(%eax)
f0103e2f:	74 09                	je     f0103e3a <env_free+0x25>
{
f0103e31:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103e38:	eb 36                	jmp    f0103e70 <env_free+0x5b>
		lcr3(PADDR(kern_pgdir));
f0103e3a:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103e3f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e44:	77 20                	ja     f0103e66 <env_free+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e46:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e4a:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103e51:	f0 
f0103e52:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
f0103e59:	00 
f0103e5a:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0103e61:	e8 da c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e66:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e6b:	0f 22 d8             	mov    %eax,%cr3
f0103e6e:	eb c1                	jmp    f0103e31 <env_free+0x1c>
f0103e70:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103e73:	89 c8                	mov    %ecx,%eax
f0103e75:	c1 e0 02             	shl    $0x2,%eax
f0103e78:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103e7b:	8b 47 60             	mov    0x60(%edi),%eax
f0103e7e:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103e81:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103e87:	0f 84 b7 00 00 00    	je     f0103f44 <env_free+0x12f>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103e8d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103e93:	89 f0                	mov    %esi,%eax
f0103e95:	c1 e8 0c             	shr    $0xc,%eax
f0103e98:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e9b:	3b 05 88 4e 21 f0    	cmp    0xf0214e88,%eax
f0103ea1:	72 20                	jb     f0103ec3 <env_free+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103ea3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103ea7:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0103eae:	f0 
f0103eaf:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
f0103eb6:	00 
f0103eb7:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0103ebe:	e8 7d c1 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ec3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ec6:	c1 e0 16             	shl    $0x16,%eax
f0103ec9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103ed1:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103ed8:	01 
f0103ed9:	74 17                	je     f0103ef2 <env_free+0xdd>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103edb:	89 d8                	mov    %ebx,%eax
f0103edd:	c1 e0 0c             	shl    $0xc,%eax
f0103ee0:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103ee3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee7:	8b 47 60             	mov    0x60(%edi),%eax
f0103eea:	89 04 24             	mov    %eax,(%esp)
f0103eed:	e8 a3 d8 ff ff       	call   f0101795 <page_remove>
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ef2:	83 c3 01             	add    $0x1,%ebx
f0103ef5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103efb:	75 d4                	jne    f0103ed1 <env_free+0xbc>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103efd:	8b 47 60             	mov    0x60(%edi),%eax
f0103f00:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f03:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103f0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103f0d:	3b 05 88 4e 21 f0    	cmp    0xf0214e88,%eax
f0103f13:	72 1c                	jb     f0103f31 <env_free+0x11c>
		panic("pa2page called with invalid pa");
f0103f15:	c7 44 24 08 94 79 10 	movl   $0xf0107994,0x8(%esp)
f0103f1c:	f0 
f0103f1d:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103f24:	00 
f0103f25:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0103f2c:	e8 0f c1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103f31:	a1 90 4e 21 f0       	mov    0xf0214e90,%eax
f0103f36:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103f39:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103f3c:	89 04 24             	mov    %eax,(%esp)
f0103f3f:	e8 1f d6 ff ff       	call   f0101563 <page_decref>
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103f44:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103f48:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103f4f:	0f 85 1b ff ff ff    	jne    f0103e70 <env_free+0x5b>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103f55:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103f58:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f5d:	77 20                	ja     f0103f7f <env_free+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f63:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0103f6a:	f0 
f0103f6b:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
f0103f72:	00 
f0103f73:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0103f7a:	e8 c1 c0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103f7f:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103f86:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103f8b:	c1 e8 0c             	shr    $0xc,%eax
f0103f8e:	3b 05 88 4e 21 f0    	cmp    0xf0214e88,%eax
f0103f94:	72 1c                	jb     f0103fb2 <env_free+0x19d>
		panic("pa2page called with invalid pa");
f0103f96:	c7 44 24 08 94 79 10 	movl   $0xf0107994,0x8(%esp)
f0103f9d:	f0 
f0103f9e:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103fa5:	00 
f0103fa6:	c7 04 24 f5 81 10 f0 	movl   $0xf01081f5,(%esp)
f0103fad:	e8 8e c0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103fb2:	8b 15 90 4e 21 f0    	mov    0xf0214e90,%edx
f0103fb8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103fbb:	89 04 24             	mov    %eax,(%esp)
f0103fbe:	e8 a0 d5 ff ff       	call   f0101563 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103fc3:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103fca:	a1 4c 42 21 f0       	mov    0xf021424c,%eax
f0103fcf:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103fd2:	89 3d 4c 42 21 f0    	mov    %edi,0xf021424c
}
f0103fd8:	83 c4 2c             	add    $0x2c,%esp
f0103fdb:	5b                   	pop    %ebx
f0103fdc:	5e                   	pop    %esi
f0103fdd:	5f                   	pop    %edi
f0103fde:	5d                   	pop    %ebp
f0103fdf:	c3                   	ret    

f0103fe0 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103fe0:	55                   	push   %ebp
f0103fe1:	89 e5                	mov    %esp,%ebp
f0103fe3:	53                   	push   %ebx
f0103fe4:	83 ec 14             	sub    $0x14,%esp
f0103fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103fea:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103fee:	75 19                	jne    f0104009 <env_destroy+0x29>
f0103ff0:	e8 e4 28 00 00       	call   f01068d9 <cpunum>
f0103ff5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff8:	39 98 28 50 21 f0    	cmp    %ebx,-0xfdeafd8(%eax)
f0103ffe:	74 09                	je     f0104009 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0104000:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0104007:	eb 2f                	jmp    f0104038 <env_destroy+0x58>
	}

	env_free(e);
f0104009:	89 1c 24             	mov    %ebx,(%esp)
f010400c:	e8 04 fe ff ff       	call   f0103e15 <env_free>

	if (curenv == e) {
f0104011:	e8 c3 28 00 00       	call   f01068d9 <cpunum>
f0104016:	6b c0 74             	imul   $0x74,%eax,%eax
f0104019:	39 98 28 50 21 f0    	cmp    %ebx,-0xfdeafd8(%eax)
f010401f:	75 17                	jne    f0104038 <env_destroy+0x58>
		curenv = NULL;
f0104021:	e8 b3 28 00 00       	call   f01068d9 <cpunum>
f0104026:	6b c0 74             	imul   $0x74,%eax,%eax
f0104029:	c7 80 28 50 21 f0 00 	movl   $0x0,-0xfdeafd8(%eax)
f0104030:	00 00 00 
		sched_yield();
f0104033:	e8 92 0f 00 00       	call   f0104fca <sched_yield>
	}
}
f0104038:	83 c4 14             	add    $0x14,%esp
f010403b:	5b                   	pop    %ebx
f010403c:	5d                   	pop    %ebp
f010403d:	c3                   	ret    

f010403e <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010403e:	55                   	push   %ebp
f010403f:	89 e5                	mov    %esp,%ebp
f0104041:	53                   	push   %ebx
f0104042:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104045:	e8 8f 28 00 00       	call   f01068d9 <cpunum>
f010404a:	6b c0 74             	imul   $0x74,%eax,%eax
f010404d:	8b 98 28 50 21 f0    	mov    -0xfdeafd8(%eax),%ebx
f0104053:	e8 81 28 00 00       	call   f01068d9 <cpunum>
f0104058:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010405b:	8b 65 08             	mov    0x8(%ebp),%esp
f010405e:	61                   	popa   
f010405f:	07                   	pop    %es
f0104060:	1f                   	pop    %ds
f0104061:	83 c4 08             	add    $0x8,%esp
f0104064:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104065:	c7 44 24 08 8a 85 10 	movl   $0xf010858a,0x8(%esp)
f010406c:	f0 
f010406d:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
f0104074:	00 
f0104075:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f010407c:	e8 bf bf ff ff       	call   f0100040 <_panic>

f0104081 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104081:	55                   	push   %ebp
f0104082:	89 e5                	mov    %esp,%ebp
f0104084:	53                   	push   %ebx
f0104085:	83 ec 14             	sub    $0x14,%esp
f0104088:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
    // Step 1:
    //1. It could be free, dying, runnable, nor not RUNNABLE.
    if(curenv != e){
f010408b:	e8 49 28 00 00       	call   f01068d9 <cpunum>
f0104090:	6b c0 74             	imul   $0x74,%eax,%eax
f0104093:	39 98 28 50 21 f0    	cmp    %ebx,-0xfdeafd8(%eax)
f0104099:	0f 84 af 00 00 00    	je     f010414e <env_run+0xcd>
        if(curenv != NULL && curenv->env_status == ENV_RUNNING){
f010409f:	e8 35 28 00 00       	call   f01068d9 <cpunum>
f01040a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a7:	83 b8 28 50 21 f0 00 	cmpl   $0x0,-0xfdeafd8(%eax)
f01040ae:	74 29                	je     f01040d9 <env_run+0x58>
f01040b0:	e8 24 28 00 00       	call   f01068d9 <cpunum>
f01040b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b8:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01040be:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01040c2:	75 15                	jne    f01040d9 <env_run+0x58>
            curenv->env_status = ENV_RUNNABLE;
f01040c4:	e8 10 28 00 00       	call   f01068d9 <cpunum>
f01040c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01040cc:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01040d2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        }
        curenv = e;
f01040d9:	e8 fb 27 00 00       	call   f01068d9 <cpunum>
f01040de:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e1:	89 98 28 50 21 f0    	mov    %ebx,-0xfdeafd8(%eax)
        curenv->env_status = ENV_RUNNING;
f01040e7:	e8 ed 27 00 00       	call   f01068d9 <cpunum>
f01040ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ef:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01040f5:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
        curenv->env_runs++;
f01040fc:	e8 d8 27 00 00       	call   f01068d9 <cpunum>
f0104101:	6b c0 74             	imul   $0x74,%eax,%eax
f0104104:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f010410a:	83 40 58 01          	addl   $0x1,0x58(%eax)
        lcr3(PADDR(curenv->env_pgdir));
f010410e:	e8 c6 27 00 00       	call   f01068d9 <cpunum>
f0104113:	6b c0 74             	imul   $0x74,%eax,%eax
f0104116:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f010411c:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010411f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104124:	77 20                	ja     f0104146 <env_run+0xc5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104126:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010412a:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0104131:	f0 
f0104132:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
f0104139:	00 
f010413a:	c7 04 24 4c 85 10 f0 	movl   $0xf010854c,(%esp)
f0104141:	e8 fa be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104146:	05 00 00 00 10       	add    $0x10000000,%eax
f010414b:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010414e:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104155:	e8 a9 2a 00 00       	call   f0106c03 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010415a:	f3 90                	pause  
    }
    unlock_kernel();
    env_pop_tf(&curenv->env_tf);
f010415c:	e8 78 27 00 00       	call   f01068d9 <cpunum>
f0104161:	6b c0 74             	imul   $0x74,%eax,%eax
f0104164:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f010416a:	89 04 24             	mov    %eax,(%esp)
f010416d:	e8 cc fe ff ff       	call   f010403e <env_pop_tf>

f0104172 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104172:	55                   	push   %ebp
f0104173:	89 e5                	mov    %esp,%ebp
f0104175:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104179:	ba 70 00 00 00       	mov    $0x70,%edx
f010417e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010417f:	b2 71                	mov    $0x71,%dl
f0104181:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104182:	0f b6 c0             	movzbl %al,%eax
}
f0104185:	5d                   	pop    %ebp
f0104186:	c3                   	ret    

f0104187 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104187:	55                   	push   %ebp
f0104188:	89 e5                	mov    %esp,%ebp
f010418a:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010418e:	ba 70 00 00 00       	mov    $0x70,%edx
f0104193:	ee                   	out    %al,(%dx)
f0104194:	b2 71                	mov    $0x71,%dl
f0104196:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104199:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010419a:	5d                   	pop    %ebp
f010419b:	c3                   	ret    

f010419c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010419c:	55                   	push   %ebp
f010419d:	89 e5                	mov    %esp,%ebp
f010419f:	56                   	push   %esi
f01041a0:	53                   	push   %ebx
f01041a1:	83 ec 10             	sub    $0x10,%esp
f01041a4:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01041a7:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01041ad:	80 3d 50 42 21 f0 00 	cmpb   $0x0,0xf0214250
f01041b4:	74 4e                	je     f0104204 <irq_setmask_8259A+0x68>
f01041b6:	89 c6                	mov    %eax,%esi
f01041b8:	ba 21 00 00 00       	mov    $0x21,%edx
f01041bd:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01041be:	66 c1 e8 08          	shr    $0x8,%ax
f01041c2:	b2 a1                	mov    $0xa1,%dl
f01041c4:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01041c5:	c7 04 24 96 85 10 f0 	movl   $0xf0108596,(%esp)
f01041cc:	e8 0a 01 00 00       	call   f01042db <cprintf>
	for (i = 0; i < 16; i++)
f01041d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01041d6:	0f b7 f6             	movzwl %si,%esi
f01041d9:	f7 d6                	not    %esi
f01041db:	0f a3 de             	bt     %ebx,%esi
f01041de:	73 10                	jae    f01041f0 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f01041e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041e4:	c7 04 24 2b 8a 10 f0 	movl   $0xf0108a2b,(%esp)
f01041eb:	e8 eb 00 00 00       	call   f01042db <cprintf>
	for (i = 0; i < 16; i++)
f01041f0:	83 c3 01             	add    $0x1,%ebx
f01041f3:	83 fb 10             	cmp    $0x10,%ebx
f01041f6:	75 e3                	jne    f01041db <irq_setmask_8259A+0x3f>
	cprintf("\n");
f01041f8:	c7 04 24 fa 84 10 f0 	movl   $0xf01084fa,(%esp)
f01041ff:	e8 d7 00 00 00       	call   f01042db <cprintf>
}
f0104204:	83 c4 10             	add    $0x10,%esp
f0104207:	5b                   	pop    %ebx
f0104208:	5e                   	pop    %esi
f0104209:	5d                   	pop    %ebp
f010420a:	c3                   	ret    

f010420b <pic_init>:
	didinit = 1;
f010420b:	c6 05 50 42 21 f0 01 	movb   $0x1,0xf0214250
f0104212:	ba 21 00 00 00       	mov    $0x21,%edx
f0104217:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010421c:	ee                   	out    %al,(%dx)
f010421d:	b2 a1                	mov    $0xa1,%dl
f010421f:	ee                   	out    %al,(%dx)
f0104220:	b2 20                	mov    $0x20,%dl
f0104222:	b8 11 00 00 00       	mov    $0x11,%eax
f0104227:	ee                   	out    %al,(%dx)
f0104228:	b2 21                	mov    $0x21,%dl
f010422a:	b8 20 00 00 00       	mov    $0x20,%eax
f010422f:	ee                   	out    %al,(%dx)
f0104230:	b8 04 00 00 00       	mov    $0x4,%eax
f0104235:	ee                   	out    %al,(%dx)
f0104236:	b8 03 00 00 00       	mov    $0x3,%eax
f010423b:	ee                   	out    %al,(%dx)
f010423c:	b2 a0                	mov    $0xa0,%dl
f010423e:	b8 11 00 00 00       	mov    $0x11,%eax
f0104243:	ee                   	out    %al,(%dx)
f0104244:	b2 a1                	mov    $0xa1,%dl
f0104246:	b8 28 00 00 00       	mov    $0x28,%eax
f010424b:	ee                   	out    %al,(%dx)
f010424c:	b8 02 00 00 00       	mov    $0x2,%eax
f0104251:	ee                   	out    %al,(%dx)
f0104252:	b8 01 00 00 00       	mov    $0x1,%eax
f0104257:	ee                   	out    %al,(%dx)
f0104258:	b2 20                	mov    $0x20,%dl
f010425a:	b8 68 00 00 00       	mov    $0x68,%eax
f010425f:	ee                   	out    %al,(%dx)
f0104260:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104265:	ee                   	out    %al,(%dx)
f0104266:	b2 a0                	mov    $0xa0,%dl
f0104268:	b8 68 00 00 00       	mov    $0x68,%eax
f010426d:	ee                   	out    %al,(%dx)
f010426e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104273:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0104274:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010427b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010427f:	74 12                	je     f0104293 <pic_init+0x88>
{
f0104281:	55                   	push   %ebp
f0104282:	89 e5                	mov    %esp,%ebp
f0104284:	83 ec 18             	sub    $0x18,%esp
		irq_setmask_8259A(irq_mask_8259A);
f0104287:	0f b7 c0             	movzwl %ax,%eax
f010428a:	89 04 24             	mov    %eax,(%esp)
f010428d:	e8 0a ff ff ff       	call   f010419c <irq_setmask_8259A>
}
f0104292:	c9                   	leave  
f0104293:	f3 c3                	repz ret 

f0104295 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104295:	55                   	push   %ebp
f0104296:	89 e5                	mov    %esp,%ebp
f0104298:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010429b:	8b 45 08             	mov    0x8(%ebp),%eax
f010429e:	89 04 24             	mov    %eax,(%esp)
f01042a1:	e8 ee c4 ff ff       	call   f0100794 <cputchar>
	*cnt++;
}
f01042a6:	c9                   	leave  
f01042a7:	c3                   	ret    

f01042a8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01042a8:	55                   	push   %ebp
f01042a9:	89 e5                	mov    %esp,%ebp
f01042ab:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01042ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01042b5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01042bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01042c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042ca:	c7 04 24 95 42 10 f0 	movl   $0xf0104295,(%esp)
f01042d1:	e8 e8 18 00 00       	call   f0105bbe <vprintfmt>
	return cnt;
}
f01042d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01042d9:	c9                   	leave  
f01042da:	c3                   	ret    

f01042db <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01042db:	55                   	push   %ebp
f01042dc:	89 e5                	mov    %esp,%ebp
f01042de:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01042e1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01042e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01042eb:	89 04 24             	mov    %eax,(%esp)
f01042ee:	e8 b5 ff ff ff       	call   f01042a8 <vcprintf>
	va_end(ap);

	return cnt;
}
f01042f3:	c9                   	leave  
f01042f4:	c3                   	ret    
f01042f5:	66 90                	xchg   %ax,%ax
f01042f7:	66 90                	xchg   %ax,%ax
f01042f9:	66 90                	xchg   %ax,%ax
f01042fb:	66 90                	xchg   %ax,%ax
f01042fd:	66 90                	xchg   %ax,%ax
f01042ff:	90                   	nop

f0104300 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
    void
trap_init_percpu(void)
{
f0104300:	55                   	push   %ebp
f0104301:	89 e5                	mov    %esp,%ebp
f0104303:	57                   	push   %edi
f0104304:	56                   	push   %esi
f0104305:	53                   	push   %ebx
f0104306:	83 ec 1c             	sub    $0x1c,%esp
    // when we trap to the kernel.
    /*ts.ts_esp0 = KSTACKTOP;
      ts.ts_ss0 = GD_KD;
      ts.ts_iomb = sizeof(struct Taskstate);
      */
    uint8_t id = thiscpu->cpu_id;
f0104309:	e8 cb 25 00 00       	call   f01068d9 <cpunum>
f010430e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104311:	0f b6 80 20 50 21 f0 	movzbl -0xfdeafe0(%eax),%eax
f0104318:	89 c3                	mov    %eax,%ebx
    thiscpu->cpu_ts.ts_esp0 = (uintptr_t) (percpu_kstacks[id] + KSTKSIZE);
f010431a:	e8 ba 25 00 00       	call   f01068d9 <cpunum>
f010431f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104322:	88 5d e7             	mov    %bl,-0x19(%ebp)
f0104325:	0f b6 db             	movzbl %bl,%ebx
f0104328:	89 da                	mov    %ebx,%edx
f010432a:	c1 e2 0f             	shl    $0xf,%edx
f010432d:	8d 92 00 e0 21 f0    	lea    -0xfde2000(%edx),%edx
f0104333:	89 90 30 50 21 f0    	mov    %edx,-0xfdeafd0(%eax)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104339:	e8 9b 25 00 00       	call   f01068d9 <cpunum>
f010433e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104341:	66 c7 80 34 50 21 f0 	movw   $0x10,-0xfdeafcc(%eax)
f0104348:	10 00 
    thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f010434a:	e8 8a 25 00 00       	call   f01068d9 <cpunum>
f010434f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104352:	66 c7 80 92 50 21 f0 	movw   $0x68,-0xfdeaf6e(%eax)
f0104359:	68 00 

    // Initialize the TSS slot of the gdt.
    gdt[(GD_TSS0 >> 3)+id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010435b:	83 c3 05             	add    $0x5,%ebx
f010435e:	e8 76 25 00 00       	call   f01068d9 <cpunum>
f0104363:	89 c7                	mov    %eax,%edi
f0104365:	e8 6f 25 00 00       	call   f01068d9 <cpunum>
f010436a:	89 c6                	mov    %eax,%esi
f010436c:	e8 68 25 00 00       	call   f01068d9 <cpunum>
f0104371:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0104378:	f0 67 00 
f010437b:	6b ff 74             	imul   $0x74,%edi,%edi
f010437e:	81 c7 2c 50 21 f0    	add    $0xf021502c,%edi
f0104384:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f010438b:	f0 
f010438c:	6b d6 74             	imul   $0x74,%esi,%edx
f010438f:	81 c2 2c 50 21 f0    	add    $0xf021502c,%edx
f0104395:	c1 ea 10             	shr    $0x10,%edx
f0104398:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f010439f:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f01043a6:	40 
f01043a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043aa:	05 2c 50 21 f0       	add    $0xf021502c,%eax
f01043af:	c1 e8 18             	shr    $0x18,%eax
f01043b2:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
            sizeof(struct Taskstate) - 1, 0);
    gdt[(GD_TSS0 >> 3)+id].sd_s = 0;
f01043b9:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f01043c0:	89 

    // Load the TSS selector (like other segment selectors, the
    // bottom three bits are special; we leave them 0)
    ltr(GD_TSS0 + (id << 3)); // I think we need to do the shifting? Let's just do 3 like it said.
f01043c1:	0f b6 75 e7          	movzbl -0x19(%ebp),%esi
f01043c5:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
	asm volatile("ltr %0" : : "r" (sel));
f01043cc:	0f 00 de             	ltr    %si
	asm volatile("lidt (%0)" : : "r" (p));
f01043cf:	b8 aa 23 12 f0       	mov    $0xf01223aa,%eax
f01043d4:	0f 01 18             	lidtl  (%eax)

    // Load the IDT
    lidt(&idt_pd);
}
f01043d7:	83 c4 1c             	add    $0x1c,%esp
f01043da:	5b                   	pop    %ebx
f01043db:	5e                   	pop    %esi
f01043dc:	5f                   	pop    %edi
f01043dd:	5d                   	pop    %ebp
f01043de:	c3                   	ret    

f01043df <trap_init>:
{
f01043df:	55                   	push   %ebp
f01043e0:	89 e5                	mov    %esp,%ebp
f01043e2:	83 ec 08             	sub    $0x8,%esp
    SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f01043e5:	b8 5e 4e 10 f0       	mov    $0xf0104e5e,%eax
f01043ea:	66 a3 60 42 21 f0    	mov    %ax,0xf0214260
f01043f0:	66 c7 05 62 42 21 f0 	movw   $0x8,0xf0214262
f01043f7:	08 00 
f01043f9:	c6 05 64 42 21 f0 00 	movb   $0x0,0xf0214264
f0104400:	c6 05 65 42 21 f0 8e 	movb   $0x8e,0xf0214265
f0104407:	c1 e8 10             	shr    $0x10,%eax
f010440a:	66 a3 66 42 21 f0    	mov    %ax,0xf0214266
    SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0104410:	b8 64 4e 10 f0       	mov    $0xf0104e64,%eax
f0104415:	66 a3 68 42 21 f0    	mov    %ax,0xf0214268
f010441b:	66 c7 05 6a 42 21 f0 	movw   $0x8,0xf021426a
f0104422:	08 00 
f0104424:	c6 05 6c 42 21 f0 00 	movb   $0x0,0xf021426c
f010442b:	c6 05 6d 42 21 f0 8e 	movb   $0x8e,0xf021426d
f0104432:	c1 e8 10             	shr    $0x10,%eax
f0104435:	66 a3 6e 42 21 f0    	mov    %ax,0xf021426e
    SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f010443b:	b8 6a 4e 10 f0       	mov    $0xf0104e6a,%eax
f0104440:	66 a3 70 42 21 f0    	mov    %ax,0xf0214270
f0104446:	66 c7 05 72 42 21 f0 	movw   $0x8,0xf0214272
f010444d:	08 00 
f010444f:	c6 05 74 42 21 f0 00 	movb   $0x0,0xf0214274
f0104456:	c6 05 75 42 21 f0 8e 	movb   $0x8e,0xf0214275
f010445d:	c1 e8 10             	shr    $0x10,%eax
f0104460:	66 a3 76 42 21 f0    	mov    %ax,0xf0214276
    SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0104466:	b8 70 4e 10 f0       	mov    $0xf0104e70,%eax
f010446b:	66 a3 78 42 21 f0    	mov    %ax,0xf0214278
f0104471:	66 c7 05 7a 42 21 f0 	movw   $0x8,0xf021427a
f0104478:	08 00 
f010447a:	c6 05 7c 42 21 f0 00 	movb   $0x0,0xf021427c
f0104481:	c6 05 7d 42 21 f0 ee 	movb   $0xee,0xf021427d
f0104488:	c1 e8 10             	shr    $0x10,%eax
f010448b:	66 a3 7e 42 21 f0    	mov    %ax,0xf021427e
    SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0104491:	b8 76 4e 10 f0       	mov    $0xf0104e76,%eax
f0104496:	66 a3 80 42 21 f0    	mov    %ax,0xf0214280
f010449c:	66 c7 05 82 42 21 f0 	movw   $0x8,0xf0214282
f01044a3:	08 00 
f01044a5:	c6 05 84 42 21 f0 00 	movb   $0x0,0xf0214284
f01044ac:	c6 05 85 42 21 f0 8e 	movb   $0x8e,0xf0214285
f01044b3:	c1 e8 10             	shr    $0x10,%eax
f01044b6:	66 a3 86 42 21 f0    	mov    %ax,0xf0214286
    SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f01044bc:	b8 7c 4e 10 f0       	mov    $0xf0104e7c,%eax
f01044c1:	66 a3 88 42 21 f0    	mov    %ax,0xf0214288
f01044c7:	66 c7 05 8a 42 21 f0 	movw   $0x8,0xf021428a
f01044ce:	08 00 
f01044d0:	c6 05 8c 42 21 f0 00 	movb   $0x0,0xf021428c
f01044d7:	c6 05 8d 42 21 f0 8e 	movb   $0x8e,0xf021428d
f01044de:	c1 e8 10             	shr    $0x10,%eax
f01044e1:	66 a3 8e 42 21 f0    	mov    %ax,0xf021428e
    SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f01044e7:	b8 82 4e 10 f0       	mov    $0xf0104e82,%eax
f01044ec:	66 a3 90 42 21 f0    	mov    %ax,0xf0214290
f01044f2:	66 c7 05 92 42 21 f0 	movw   $0x8,0xf0214292
f01044f9:	08 00 
f01044fb:	c6 05 94 42 21 f0 00 	movb   $0x0,0xf0214294
f0104502:	c6 05 95 42 21 f0 8e 	movb   $0x8e,0xf0214295
f0104509:	c1 e8 10             	shr    $0x10,%eax
f010450c:	66 a3 96 42 21 f0    	mov    %ax,0xf0214296
    SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0104512:	b8 88 4e 10 f0       	mov    $0xf0104e88,%eax
f0104517:	66 a3 98 42 21 f0    	mov    %ax,0xf0214298
f010451d:	66 c7 05 9a 42 21 f0 	movw   $0x8,0xf021429a
f0104524:	08 00 
f0104526:	c6 05 9c 42 21 f0 00 	movb   $0x0,0xf021429c
f010452d:	c6 05 9d 42 21 f0 8e 	movb   $0x8e,0xf021429d
f0104534:	c1 e8 10             	shr    $0x10,%eax
f0104537:	66 a3 9e 42 21 f0    	mov    %ax,0xf021429e
    SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f010453d:	b8 8e 4e 10 f0       	mov    $0xf0104e8e,%eax
f0104542:	66 a3 a0 42 21 f0    	mov    %ax,0xf02142a0
f0104548:	66 c7 05 a2 42 21 f0 	movw   $0x8,0xf02142a2
f010454f:	08 00 
f0104551:	c6 05 a4 42 21 f0 00 	movb   $0x0,0xf02142a4
f0104558:	c6 05 a5 42 21 f0 8e 	movb   $0x8e,0xf02142a5
f010455f:	c1 e8 10             	shr    $0x10,%eax
f0104562:	66 a3 a6 42 21 f0    	mov    %ax,0xf02142a6
    SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0104568:	b8 92 4e 10 f0       	mov    $0xf0104e92,%eax
f010456d:	66 a3 b0 42 21 f0    	mov    %ax,0xf02142b0
f0104573:	66 c7 05 b2 42 21 f0 	movw   $0x8,0xf02142b2
f010457a:	08 00 
f010457c:	c6 05 b4 42 21 f0 00 	movb   $0x0,0xf02142b4
f0104583:	c6 05 b5 42 21 f0 8e 	movb   $0x8e,0xf02142b5
f010458a:	c1 e8 10             	shr    $0x10,%eax
f010458d:	66 a3 b6 42 21 f0    	mov    %ax,0xf02142b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0104593:	b8 96 4e 10 f0       	mov    $0xf0104e96,%eax
f0104598:	66 a3 b8 42 21 f0    	mov    %ax,0xf02142b8
f010459e:	66 c7 05 ba 42 21 f0 	movw   $0x8,0xf02142ba
f01045a5:	08 00 
f01045a7:	c6 05 bc 42 21 f0 00 	movb   $0x0,0xf02142bc
f01045ae:	c6 05 bd 42 21 f0 8e 	movb   $0x8e,0xf02142bd
f01045b5:	c1 e8 10             	shr    $0x10,%eax
f01045b8:	66 a3 be 42 21 f0    	mov    %ax,0xf02142be
    SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f01045be:	b8 9a 4e 10 f0       	mov    $0xf0104e9a,%eax
f01045c3:	66 a3 c0 42 21 f0    	mov    %ax,0xf02142c0
f01045c9:	66 c7 05 c2 42 21 f0 	movw   $0x8,0xf02142c2
f01045d0:	08 00 
f01045d2:	c6 05 c4 42 21 f0 00 	movb   $0x0,0xf02142c4
f01045d9:	c6 05 c5 42 21 f0 8e 	movb   $0x8e,0xf02142c5
f01045e0:	c1 e8 10             	shr    $0x10,%eax
f01045e3:	66 a3 c6 42 21 f0    	mov    %ax,0xf02142c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f01045e9:	b8 9e 4e 10 f0       	mov    $0xf0104e9e,%eax
f01045ee:	66 a3 c8 42 21 f0    	mov    %ax,0xf02142c8
f01045f4:	66 c7 05 ca 42 21 f0 	movw   $0x8,0xf02142ca
f01045fb:	08 00 
f01045fd:	c6 05 cc 42 21 f0 00 	movb   $0x0,0xf02142cc
f0104604:	c6 05 cd 42 21 f0 8e 	movb   $0x8e,0xf02142cd
f010460b:	c1 e8 10             	shr    $0x10,%eax
f010460e:	66 a3 ce 42 21 f0    	mov    %ax,0xf02142ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0104614:	b8 56 4e 10 f0       	mov    $0xf0104e56,%eax
f0104619:	66 a3 d0 42 21 f0    	mov    %ax,0xf02142d0
f010461f:	66 c7 05 d2 42 21 f0 	movw   $0x8,0xf02142d2
f0104626:	08 00 
f0104628:	c6 05 d4 42 21 f0 00 	movb   $0x0,0xf02142d4
f010462f:	c6 05 d5 42 21 f0 8e 	movb   $0x8e,0xf02142d5
f0104636:	c1 e8 10             	shr    $0x10,%eax
f0104639:	66 a3 d6 42 21 f0    	mov    %ax,0xf02142d6
    SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f010463f:	b8 a2 4e 10 f0       	mov    $0xf0104ea2,%eax
f0104644:	66 a3 e0 42 21 f0    	mov    %ax,0xf02142e0
f010464a:	66 c7 05 e2 42 21 f0 	movw   $0x8,0xf02142e2
f0104651:	08 00 
f0104653:	c6 05 e4 42 21 f0 00 	movb   $0x0,0xf02142e4
f010465a:	c6 05 e5 42 21 f0 8e 	movb   $0x8e,0xf02142e5
f0104661:	c1 e8 10             	shr    $0x10,%eax
f0104664:	66 a3 e6 42 21 f0    	mov    %ax,0xf02142e6
    SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f010466a:	b8 a8 4e 10 f0       	mov    $0xf0104ea8,%eax
f010466f:	66 a3 e8 42 21 f0    	mov    %ax,0xf02142e8
f0104675:	66 c7 05 ea 42 21 f0 	movw   $0x8,0xf02142ea
f010467c:	08 00 
f010467e:	c6 05 ec 42 21 f0 00 	movb   $0x0,0xf02142ec
f0104685:	c6 05 ed 42 21 f0 8e 	movb   $0x8e,0xf02142ed
f010468c:	c1 e8 10             	shr    $0x10,%eax
f010468f:	66 a3 ee 42 21 f0    	mov    %ax,0xf02142ee
    SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0104695:	b8 ac 4e 10 f0       	mov    $0xf0104eac,%eax
f010469a:	66 a3 f0 42 21 f0    	mov    %ax,0xf02142f0
f01046a0:	66 c7 05 f2 42 21 f0 	movw   $0x8,0xf02142f2
f01046a7:	08 00 
f01046a9:	c6 05 f4 42 21 f0 00 	movb   $0x0,0xf02142f4
f01046b0:	c6 05 f5 42 21 f0 8e 	movb   $0x8e,0xf02142f5
f01046b7:	c1 e8 10             	shr    $0x10,%eax
f01046ba:	66 a3 f6 42 21 f0    	mov    %ax,0xf02142f6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f01046c0:	b8 b2 4e 10 f0       	mov    $0xf0104eb2,%eax
f01046c5:	66 a3 f8 42 21 f0    	mov    %ax,0xf02142f8
f01046cb:	66 c7 05 fa 42 21 f0 	movw   $0x8,0xf02142fa
f01046d2:	08 00 
f01046d4:	c6 05 fc 42 21 f0 00 	movb   $0x0,0xf02142fc
f01046db:	c6 05 fd 42 21 f0 8e 	movb   $0x8e,0xf02142fd
f01046e2:	c1 e8 10             	shr    $0x10,%eax
f01046e5:	66 a3 fe 42 21 f0    	mov    %ax,0xf02142fe
    SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01046eb:	b8 b8 4e 10 f0       	mov    $0xf0104eb8,%eax
f01046f0:	66 a3 e0 43 21 f0    	mov    %ax,0xf02143e0
f01046f6:	66 c7 05 e2 43 21 f0 	movw   $0x8,0xf02143e2
f01046fd:	08 00 
f01046ff:	c6 05 e4 43 21 f0 00 	movb   $0x0,0xf02143e4
f0104706:	c6 05 e5 43 21 f0 ee 	movb   $0xee,0xf02143e5
f010470d:	c1 e8 10             	shr    $0x10,%eax
f0104710:	66 a3 e6 43 21 f0    	mov    %ax,0xf02143e6
    SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f0104716:	b8 be 4e 10 f0       	mov    $0xf0104ebe,%eax
f010471b:	66 a3 60 43 21 f0    	mov    %ax,0xf0214360
f0104721:	66 c7 05 62 43 21 f0 	movw   $0x8,0xf0214362
f0104728:	08 00 
f010472a:	c6 05 64 43 21 f0 00 	movb   $0x0,0xf0214364
f0104731:	c6 05 65 43 21 f0 8e 	movb   $0x8e,0xf0214365
f0104738:	c1 e8 10             	shr    $0x10,%eax
f010473b:	66 a3 66 43 21 f0    	mov    %ax,0xf0214366
    SETGATE(idt[IRQ_OFFSET+IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f0104741:	b8 c4 4e 10 f0       	mov    $0xf0104ec4,%eax
f0104746:	66 a3 68 43 21 f0    	mov    %ax,0xf0214368
f010474c:	66 c7 05 6a 43 21 f0 	movw   $0x8,0xf021436a
f0104753:	08 00 
f0104755:	c6 05 6c 43 21 f0 00 	movb   $0x0,0xf021436c
f010475c:	c6 05 6d 43 21 f0 8e 	movb   $0x8e,0xf021436d
f0104763:	c1 e8 10             	shr    $0x10,%eax
f0104766:	66 a3 6e 43 21 f0    	mov    %ax,0xf021436e
    SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f010476c:	b8 ca 4e 10 f0       	mov    $0xf0104eca,%eax
f0104771:	66 a3 80 43 21 f0    	mov    %ax,0xf0214380
f0104777:	66 c7 05 82 43 21 f0 	movw   $0x8,0xf0214382
f010477e:	08 00 
f0104780:	c6 05 84 43 21 f0 00 	movb   $0x0,0xf0214384
f0104787:	c6 05 85 43 21 f0 8e 	movb   $0x8e,0xf0214385
f010478e:	c1 e8 10             	shr    $0x10,%eax
f0104791:	66 a3 86 43 21 f0    	mov    %ax,0xf0214386
    SETGATE(idt[IRQ_SPURIOUS+IRQ_OFFSET], 0, GD_KT, irq_spurious, 0);
f0104797:	b8 d0 4e 10 f0       	mov    $0xf0104ed0,%eax
f010479c:	66 a3 98 43 21 f0    	mov    %ax,0xf0214398
f01047a2:	66 c7 05 9a 43 21 f0 	movw   $0x8,0xf021439a
f01047a9:	08 00 
f01047ab:	c6 05 9c 43 21 f0 00 	movb   $0x0,0xf021439c
f01047b2:	c6 05 9d 43 21 f0 8e 	movb   $0x8e,0xf021439d
f01047b9:	c1 e8 10             	shr    $0x10,%eax
f01047bc:	66 a3 9e 43 21 f0    	mov    %ax,0xf021439e
    SETGATE(idt[IRQ_IDE+IRQ_OFFSET], 0, GD_KT, irq_ide, 0);
f01047c2:	b8 d6 4e 10 f0       	mov    $0xf0104ed6,%eax
f01047c7:	66 a3 d0 43 21 f0    	mov    %ax,0xf02143d0
f01047cd:	66 c7 05 d2 43 21 f0 	movw   $0x8,0xf02143d2
f01047d4:	08 00 
f01047d6:	c6 05 d4 43 21 f0 00 	movb   $0x0,0xf02143d4
f01047dd:	c6 05 d5 43 21 f0 8e 	movb   $0x8e,0xf02143d5
f01047e4:	c1 e8 10             	shr    $0x10,%eax
f01047e7:	66 a3 d6 43 21 f0    	mov    %ax,0xf02143d6
    SETGATE(idt[IRQ_ERROR+IRQ_OFFSET], 0, GD_KT, irq_error, 0);
f01047ed:	b8 dc 4e 10 f0       	mov    $0xf0104edc,%eax
f01047f2:	66 a3 f8 43 21 f0    	mov    %ax,0xf02143f8
f01047f8:	66 c7 05 fa 43 21 f0 	movw   $0x8,0xf02143fa
f01047ff:	08 00 
f0104801:	c6 05 fc 43 21 f0 00 	movb   $0x0,0xf02143fc
f0104808:	c6 05 fd 43 21 f0 8e 	movb   $0x8e,0xf02143fd
f010480f:	c1 e8 10             	shr    $0x10,%eax
f0104812:	66 a3 fe 43 21 f0    	mov    %ax,0xf02143fe
    trap_init_percpu();
f0104818:	e8 e3 fa ff ff       	call   f0104300 <trap_init_percpu>
}
f010481d:	c9                   	leave  
f010481e:	c3                   	ret    

f010481f <print_regs>:
    }
}

    void
print_regs(struct PushRegs *regs)
{
f010481f:	55                   	push   %ebp
f0104820:	89 e5                	mov    %esp,%ebp
f0104822:	53                   	push   %ebx
f0104823:	83 ec 14             	sub    $0x14,%esp
f0104826:	8b 5d 08             	mov    0x8(%ebp),%ebx
    cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104829:	8b 03                	mov    (%ebx),%eax
f010482b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010482f:	c7 04 24 aa 85 10 f0 	movl   $0xf01085aa,(%esp)
f0104836:	e8 a0 fa ff ff       	call   f01042db <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
f010483b:	8b 43 04             	mov    0x4(%ebx),%eax
f010483e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104842:	c7 04 24 b9 85 10 f0 	movl   $0xf01085b9,(%esp)
f0104849:	e8 8d fa ff ff       	call   f01042db <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010484e:	8b 43 08             	mov    0x8(%ebx),%eax
f0104851:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104855:	c7 04 24 c8 85 10 f0 	movl   $0xf01085c8,(%esp)
f010485c:	e8 7a fa ff ff       	call   f01042db <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104861:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104864:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104868:	c7 04 24 d7 85 10 f0 	movl   $0xf01085d7,(%esp)
f010486f:	e8 67 fa ff ff       	call   f01042db <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104874:	8b 43 10             	mov    0x10(%ebx),%eax
f0104877:	89 44 24 04          	mov    %eax,0x4(%esp)
f010487b:	c7 04 24 e6 85 10 f0 	movl   $0xf01085e6,(%esp)
f0104882:	e8 54 fa ff ff       	call   f01042db <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104887:	8b 43 14             	mov    0x14(%ebx),%eax
f010488a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010488e:	c7 04 24 f5 85 10 f0 	movl   $0xf01085f5,(%esp)
f0104895:	e8 41 fa ff ff       	call   f01042db <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010489a:	8b 43 18             	mov    0x18(%ebx),%eax
f010489d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a1:	c7 04 24 04 86 10 f0 	movl   $0xf0108604,(%esp)
f01048a8:	e8 2e fa ff ff       	call   f01042db <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
f01048ad:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01048b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048b4:	c7 04 24 13 86 10 f0 	movl   $0xf0108613,(%esp)
f01048bb:	e8 1b fa ff ff       	call   f01042db <cprintf>
}
f01048c0:	83 c4 14             	add    $0x14,%esp
f01048c3:	5b                   	pop    %ebx
f01048c4:	5d                   	pop    %ebp
f01048c5:	c3                   	ret    

f01048c6 <print_trapframe>:
{
f01048c6:	55                   	push   %ebp
f01048c7:	89 e5                	mov    %esp,%ebp
f01048c9:	56                   	push   %esi
f01048ca:	53                   	push   %ebx
f01048cb:	83 ec 10             	sub    $0x10,%esp
f01048ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
    cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01048d1:	e8 03 20 00 00       	call   f01068d9 <cpunum>
f01048d6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048de:	c7 04 24 77 86 10 f0 	movl   $0xf0108677,(%esp)
f01048e5:	e8 f1 f9 ff ff       	call   f01042db <cprintf>
    print_regs(&tf->tf_regs);
f01048ea:	89 1c 24             	mov    %ebx,(%esp)
f01048ed:	e8 2d ff ff ff       	call   f010481f <print_regs>
    cprintf("  es   0x----%04x\n", tf->tf_es);
f01048f2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01048f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048fa:	c7 04 24 95 86 10 f0 	movl   $0xf0108695,(%esp)
f0104901:	e8 d5 f9 ff ff       	call   f01042db <cprintf>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104906:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010490a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010490e:	c7 04 24 a8 86 10 f0 	movl   $0xf01086a8,(%esp)
f0104915:	e8 c1 f9 ff ff       	call   f01042db <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010491a:	8b 43 28             	mov    0x28(%ebx),%eax
    if (trapno < ARRAY_SIZE(excnames))
f010491d:	83 f8 13             	cmp    $0x13,%eax
f0104920:	77 09                	ja     f010492b <print_trapframe+0x65>
        return excnames[trapno];
f0104922:	8b 14 85 40 89 10 f0 	mov    -0xfef76c0(,%eax,4),%edx
f0104929:	eb 1f                	jmp    f010494a <print_trapframe+0x84>
    if (trapno == T_SYSCALL)
f010492b:	83 f8 30             	cmp    $0x30,%eax
f010492e:	74 15                	je     f0104945 <print_trapframe+0x7f>
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104930:	8d 50 e0             	lea    -0x20(%eax),%edx
        return "Hardware Interrupt";
f0104933:	83 fa 0f             	cmp    $0xf,%edx
f0104936:	ba 2e 86 10 f0       	mov    $0xf010862e,%edx
f010493b:	b9 41 86 10 f0       	mov    $0xf0108641,%ecx
f0104940:	0f 47 d1             	cmova  %ecx,%edx
f0104943:	eb 05                	jmp    f010494a <print_trapframe+0x84>
        return "System call";
f0104945:	ba 22 86 10 f0       	mov    $0xf0108622,%edx
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010494a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010494e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104952:	c7 04 24 bb 86 10 f0 	movl   $0xf01086bb,(%esp)
f0104959:	e8 7d f9 ff ff       	call   f01042db <cprintf>
    if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010495e:	3b 1d 60 4a 21 f0    	cmp    0xf0214a60,%ebx
f0104964:	75 19                	jne    f010497f <print_trapframe+0xb9>
f0104966:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010496a:	75 13                	jne    f010497f <print_trapframe+0xb9>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010496c:	0f 20 d0             	mov    %cr2,%eax
        cprintf("  cr2  0x%08x\n", rcr2());
f010496f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104973:	c7 04 24 cd 86 10 f0 	movl   $0xf01086cd,(%esp)
f010497a:	e8 5c f9 ff ff       	call   f01042db <cprintf>
    cprintf("  err  0x%08x", tf->tf_err);
f010497f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104982:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104986:	c7 04 24 dc 86 10 f0 	movl   $0xf01086dc,(%esp)
f010498d:	e8 49 f9 ff ff       	call   f01042db <cprintf>
    if (tf->tf_trapno == T_PGFLT)
f0104992:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104996:	75 51                	jne    f01049e9 <print_trapframe+0x123>
                tf->tf_err & 1 ? "protection" : "not-present");
f0104998:	8b 43 2c             	mov    0x2c(%ebx),%eax
        cprintf(" [%s, %s, %s]\n",
f010499b:	89 c2                	mov    %eax,%edx
f010499d:	83 e2 01             	and    $0x1,%edx
f01049a0:	ba 50 86 10 f0       	mov    $0xf0108650,%edx
f01049a5:	b9 5b 86 10 f0       	mov    $0xf010865b,%ecx
f01049aa:	0f 45 ca             	cmovne %edx,%ecx
f01049ad:	89 c2                	mov    %eax,%edx
f01049af:	83 e2 02             	and    $0x2,%edx
f01049b2:	ba 67 86 10 f0       	mov    $0xf0108667,%edx
f01049b7:	be 6d 86 10 f0       	mov    $0xf010866d,%esi
f01049bc:	0f 44 d6             	cmove  %esi,%edx
f01049bf:	83 e0 04             	and    $0x4,%eax
f01049c2:	b8 72 86 10 f0       	mov    $0xf0108672,%eax
f01049c7:	be a7 87 10 f0       	mov    $0xf01087a7,%esi
f01049cc:	0f 44 c6             	cmove  %esi,%eax
f01049cf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01049d3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01049d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049db:	c7 04 24 ea 86 10 f0 	movl   $0xf01086ea,(%esp)
f01049e2:	e8 f4 f8 ff ff       	call   f01042db <cprintf>
f01049e7:	eb 0c                	jmp    f01049f5 <print_trapframe+0x12f>
        cprintf("\n");
f01049e9:	c7 04 24 fa 84 10 f0 	movl   $0xf01084fa,(%esp)
f01049f0:	e8 e6 f8 ff ff       	call   f01042db <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
f01049f5:	8b 43 30             	mov    0x30(%ebx),%eax
f01049f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049fc:	c7 04 24 f9 86 10 f0 	movl   $0xf01086f9,(%esp)
f0104a03:	e8 d3 f8 ff ff       	call   f01042db <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104a08:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a10:	c7 04 24 08 87 10 f0 	movl   $0xf0108708,(%esp)
f0104a17:	e8 bf f8 ff ff       	call   f01042db <cprintf>
    cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104a1c:	8b 43 38             	mov    0x38(%ebx),%eax
f0104a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a23:	c7 04 24 1b 87 10 f0 	movl   $0xf010871b,(%esp)
f0104a2a:	e8 ac f8 ff ff       	call   f01042db <cprintf>
    if ((tf->tf_cs & 3) != 0) {
f0104a2f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a33:	74 27                	je     f0104a5c <print_trapframe+0x196>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104a35:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104a38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a3c:	c7 04 24 2a 87 10 f0 	movl   $0xf010872a,(%esp)
f0104a43:	e8 93 f8 ff ff       	call   f01042db <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104a48:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a50:	c7 04 24 39 87 10 f0 	movl   $0xf0108739,(%esp)
f0104a57:	e8 7f f8 ff ff       	call   f01042db <cprintf>
}
f0104a5c:	83 c4 10             	add    $0x10,%esp
f0104a5f:	5b                   	pop    %ebx
f0104a60:	5e                   	pop    %esi
f0104a61:	5d                   	pop    %ebp
f0104a62:	c3                   	ret    

f0104a63 <page_fault_handler>:
}


    void
page_fault_handler(struct Trapframe *tf)
{
f0104a63:	55                   	push   %ebp
f0104a64:	89 e5                	mov    %esp,%ebp
f0104a66:	57                   	push   %edi
f0104a67:	56                   	push   %esi
f0104a68:	53                   	push   %ebx
f0104a69:	83 ec 4c             	sub    $0x4c,%esp
f0104a6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a6f:	0f 20 d6             	mov    %cr2,%esi
    // LAB 3: Your code here.
    /* CR2 holds the linear address for PAGE FAULTS, we can pull from this*/
    /*If I'm understanding this correctly, "CS" has the code segment, I think
     * this is the area we need to pull from? This is just a guess as I don't
     * know which one.*/
    if((tf->tf_cs & 0x3) == 0){
f0104a72:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a76:	75 1c                	jne    f0104a94 <page_fault_handler+0x31>
        panic("Page fault handler, kernel error");
f0104a78:	c7 44 24 08 f4 88 10 	movl   $0xf01088f4,0x8(%esp)
f0104a7f:	f0 
f0104a80:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
f0104a87:	00 
f0104a88:	c7 04 24 4c 87 10 f0 	movl   $0xf010874c,(%esp)
f0104a8f:	e8 ac b5 ff ff       	call   f0100040 <_panic>
        //   user_mem_assert() and env_run() are useful here.
        //   To change what the user environment runs, modify 'curenv->env_tf'
        //   (the 'tf' variable points at 'curenv->env_tf').

        // LAB 4: Your code here.
        if(curenv->env_pgfault_upcall != NULL){
f0104a94:	e8 40 1e 00 00       	call   f01068d9 <cpunum>
f0104a99:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a9c:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104aa2:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104aa6:	0f 84 0d 01 00 00    	je     f0104bb9 <page_fault_handler+0x156>

            struct UTrapframe utf;
    //        user_mem_assert(curenv, (void *)tf->tf_esp, sizeof(utf), PTE_U|PTE_P|PTE_W);

            utf.utf_fault_va = fault_va;
            utf.utf_err = tf->tf_err;
f0104aac:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104aaf:	89 45 dc             	mov    %eax,-0x24(%ebp)
            utf.utf_regs = tf->tf_regs;
f0104ab2:	8b 03                	mov    (%ebx),%eax
f0104ab4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104ab7:	8b 43 04             	mov    0x4(%ebx),%eax
f0104aba:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104abd:	8b 43 08             	mov    0x8(%ebx),%eax
f0104ac0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ac3:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104ac6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104ac9:	8b 43 10             	mov    0x10(%ebx),%eax
f0104acc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104acf:	8b 43 14             	mov    0x14(%ebx),%eax
f0104ad2:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104ad5:	8b 43 18             	mov    0x18(%ebx),%eax
f0104ad8:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0104adb:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104ade:	89 45 b8             	mov    %eax,-0x48(%ebp)
            utf.utf_eip = tf->tf_eip;
f0104ae1:	8b 43 30             	mov    0x30(%ebx),%eax
f0104ae4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            utf.utf_eflags = tf->tf_eflags;
f0104ae7:	8b 43 38             	mov    0x38(%ebx),%eax
f0104aea:	89 45 cc             	mov    %eax,-0x34(%ebp)
            utf.utf_esp = tf->tf_esp;
f0104aed:	8b 7b 3c             	mov    0x3c(%ebx),%edi

            if(tf->tf_esp >= (UXSTACKTOP - PGSIZE) && tf->tf_esp <= UXSTACKTOP) // What if we're already at the user stack?
f0104af0:	8d 87 00 10 40 11    	lea    0x11401000(%edi),%eax
f0104af6:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0104afb:	77 08                	ja     f0104b05 <page_fault_handler+0xa2>
            {
                tf->tf_esp -= 4; // I'm not sure what this does quite yet, I was told this by the instructors.
f0104afd:	8d 47 fc             	lea    -0x4(%edi),%eax
f0104b00:	89 43 3c             	mov    %eax,0x3c(%ebx)
f0104b03:	eb 07                	jmp    f0104b0c <page_fault_handler+0xa9>
                                // Simply, it grows the stack pointer.
            }
            else{
                // Not at the user exception stack? Well let's go there.
                tf->tf_esp = UXSTACKTOP; // Reminder, that esp = Extended Stack Pointer
f0104b05:	c7 43 3c 00 00 c0 ee 	movl   $0xeec00000,0x3c(%ebx)
            }
            tf->tf_esp -= sizeof(utf);
f0104b0c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b0f:	83 e8 34             	sub    $0x34,%eax
f0104b12:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104b15:	89 43 3c             	mov    %eax,0x3c(%ebx)

            user_mem_assert(curenv, (void *)tf->tf_esp, sizeof(utf), PTE_U|PTE_P|PTE_W);
f0104b18:	e8 bc 1d 00 00       	call   f01068d9 <cpunum>
f0104b1d:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104b24:	00 
f0104b25:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104b2c:	00 
f0104b2d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104b30:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b37:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104b3d:	89 04 24             	mov    %eax,(%esp)
f0104b40:	e8 1d ee ff ff       	call   f0103962 <user_mem_assert>

            tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;// Okay, now make us point to the upcall. Reference the assembly for more info.
f0104b45:	e8 8f 1d 00 00       	call   f01068d9 <cpunum>
f0104b4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b4d:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104b53:	8b 40 64             	mov    0x64(%eax),%eax
f0104b56:	89 43 30             	mov    %eax,0x30(%ebx)
            *((struct UTrapframe *) tf->tf_esp) = utf; // The stack now has all this info, again reference the assembly
f0104b59:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b5c:	89 30                	mov    %esi,(%eax)
f0104b5e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104b61:	89 48 04             	mov    %ecx,0x4(%eax)
f0104b64:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104b67:	89 50 08             	mov    %edx,0x8(%eax)
f0104b6a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104b6d:	89 48 0c             	mov    %ecx,0xc(%eax)
f0104b70:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104b73:	89 50 10             	mov    %edx,0x10(%eax)
f0104b76:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104b79:	89 48 14             	mov    %ecx,0x14(%eax)
f0104b7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b7f:	89 50 18             	mov    %edx,0x18(%eax)
f0104b82:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104b85:	89 48 1c             	mov    %ecx,0x1c(%eax)
f0104b88:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104b8b:	89 50 20             	mov    %edx,0x20(%eax)
f0104b8e:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104b91:	89 48 24             	mov    %ecx,0x24(%eax)
f0104b94:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104b97:	89 50 28             	mov    %edx,0x28(%eax)
f0104b9a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104b9d:	89 48 2c             	mov    %ecx,0x2c(%eax)
f0104ba0:	89 78 30             	mov    %edi,0x30(%eax)
            env_run(curenv);
f0104ba3:	e8 31 1d 00 00       	call   f01068d9 <cpunum>
f0104ba8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bab:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104bb1:	89 04 24             	mov    %eax,(%esp)
f0104bb4:	e8 c8 f4 ff ff       	call   f0104081 <env_run>
        }
        // Destroy the environment that caused the fault.

        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bb9:	8b 7b 30             	mov    0x30(%ebx),%edi
                curenv->env_id, fault_va, tf->tf_eip);
f0104bbc:	e8 18 1d 00 00       	call   f01068d9 <cpunum>
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bc1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104bc5:	89 74 24 08          	mov    %esi,0x8(%esp)
                curenv->env_id, fault_va, tf->tf_eip);
f0104bc9:	6b c0 74             	imul   $0x74,%eax,%eax
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bcc:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104bd2:	8b 40 48             	mov    0x48(%eax),%eax
f0104bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bd9:	c7 04 24 18 89 10 f0 	movl   $0xf0108918,(%esp)
f0104be0:	e8 f6 f6 ff ff       	call   f01042db <cprintf>
        print_trapframe(tf);
f0104be5:	89 1c 24             	mov    %ebx,(%esp)
f0104be8:	e8 d9 fc ff ff       	call   f01048c6 <print_trapframe>
        env_destroy(curenv);
f0104bed:	e8 e7 1c 00 00       	call   f01068d9 <cpunum>
f0104bf2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bf5:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104bfb:	89 04 24             	mov    %eax,(%esp)
f0104bfe:	e8 dd f3 ff ff       	call   f0103fe0 <env_destroy>
    }
f0104c03:	83 c4 4c             	add    $0x4c,%esp
f0104c06:	5b                   	pop    %ebx
f0104c07:	5e                   	pop    %esi
f0104c08:	5f                   	pop    %edi
f0104c09:	5d                   	pop    %ebp
f0104c0a:	c3                   	ret    

f0104c0b <trap>:
{
f0104c0b:	55                   	push   %ebp
f0104c0c:	89 e5                	mov    %esp,%ebp
f0104c0e:	57                   	push   %edi
f0104c0f:	56                   	push   %esi
f0104c10:	83 ec 20             	sub    $0x20,%esp
f0104c13:	8b 75 08             	mov    0x8(%ebp),%esi
    asm volatile("cld" ::: "cc");
f0104c16:	fc                   	cld    
    if (panicstr)
f0104c17:	83 3d 80 4e 21 f0 00 	cmpl   $0x0,0xf0214e80
f0104c1e:	74 01                	je     f0104c21 <trap+0x16>
        asm volatile("hlt");
f0104c20:	f4                   	hlt    
    if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104c21:	e8 b3 1c 00 00       	call   f01068d9 <cpunum>
f0104c26:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c29:	81 c2 20 50 21 f0    	add    $0xf0215020,%edx
	asm volatile("lock; xchgl %0, %1"
f0104c2f:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c34:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104c38:	83 f8 02             	cmp    $0x2,%eax
f0104c3b:	75 0c                	jne    f0104c49 <trap+0x3e>
	spin_lock(&kernel_lock);
f0104c3d:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104c44:	e8 0e 1f 00 00       	call   f0106b57 <spin_lock>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104c49:	9c                   	pushf  
f0104c4a:	58                   	pop    %eax
    assert(!(read_eflags() & FL_IF));
f0104c4b:	f6 c4 02             	test   $0x2,%ah
f0104c4e:	74 24                	je     f0104c74 <trap+0x69>
f0104c50:	c7 44 24 0c 58 87 10 	movl   $0xf0108758,0xc(%esp)
f0104c57:	f0 
f0104c58:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0104c5f:	f0 
f0104c60:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0104c67:	00 
f0104c68:	c7 04 24 4c 87 10 f0 	movl   $0xf010874c,(%esp)
f0104c6f:	e8 cc b3 ff ff       	call   f0100040 <_panic>
    if ((tf->tf_cs & 3) == 3) {
f0104c74:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104c78:	83 e0 03             	and    $0x3,%eax
f0104c7b:	66 83 f8 03          	cmp    $0x3,%ax
f0104c7f:	0f 85 a7 00 00 00    	jne    f0104d2c <trap+0x121>
f0104c85:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104c8c:	e8 c6 1e 00 00       	call   f0106b57 <spin_lock>
        assert(curenv);
f0104c91:	e8 43 1c 00 00       	call   f01068d9 <cpunum>
f0104c96:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c99:	83 b8 28 50 21 f0 00 	cmpl   $0x0,-0xfdeafd8(%eax)
f0104ca0:	75 24                	jne    f0104cc6 <trap+0xbb>
f0104ca2:	c7 44 24 0c 71 87 10 	movl   $0xf0108771,0xc(%esp)
f0104ca9:	f0 
f0104caa:	c7 44 24 08 0f 82 10 	movl   $0xf010820f,0x8(%esp)
f0104cb1:	f0 
f0104cb2:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
f0104cb9:	00 
f0104cba:	c7 04 24 4c 87 10 f0 	movl   $0xf010874c,(%esp)
f0104cc1:	e8 7a b3 ff ff       	call   f0100040 <_panic>
        if (curenv->env_status == ENV_DYING) {
f0104cc6:	e8 0e 1c 00 00       	call   f01068d9 <cpunum>
f0104ccb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cce:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104cd4:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104cd8:	75 2d                	jne    f0104d07 <trap+0xfc>
            env_free(curenv);
f0104cda:	e8 fa 1b 00 00       	call   f01068d9 <cpunum>
f0104cdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ce2:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104ce8:	89 04 24             	mov    %eax,(%esp)
f0104ceb:	e8 25 f1 ff ff       	call   f0103e15 <env_free>
            curenv = NULL;
f0104cf0:	e8 e4 1b 00 00       	call   f01068d9 <cpunum>
f0104cf5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cf8:	c7 80 28 50 21 f0 00 	movl   $0x0,-0xfdeafd8(%eax)
f0104cff:	00 00 00 
            sched_yield();
f0104d02:	e8 c3 02 00 00       	call   f0104fca <sched_yield>
        curenv->env_tf = *tf;
f0104d07:	e8 cd 1b 00 00       	call   f01068d9 <cpunum>
f0104d0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d0f:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104d15:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d1a:	89 c7                	mov    %eax,%edi
f0104d1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        tf = &curenv->env_tf;
f0104d1e:	e8 b6 1b 00 00       	call   f01068d9 <cpunum>
f0104d23:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d26:	8b b0 28 50 21 f0    	mov    -0xfdeafd8(%eax),%esi
    last_tf = tf;
f0104d2c:	89 35 60 4a 21 f0    	mov    %esi,0xf0214a60
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104d32:	8b 46 28             	mov    0x28(%esi),%eax
f0104d35:	83 f8 27             	cmp    $0x27,%eax
f0104d38:	75 19                	jne    f0104d53 <trap+0x148>
		cprintf("Spurious interrupt on irq 7\n");
f0104d3a:	c7 04 24 78 87 10 f0 	movl   $0xf0108778,(%esp)
f0104d41:	e8 95 f5 ff ff       	call   f01042db <cprintf>
		print_trapframe(tf);
f0104d46:	89 34 24             	mov    %esi,(%esp)
f0104d49:	e8 78 fb ff ff       	call   f01048c6 <print_trapframe>
f0104d4e:	e9 c3 00 00 00       	jmp    f0104e16 <trap+0x20b>
    switch (tf->tf_trapno){
f0104d53:	83 f8 0e             	cmp    $0xe,%eax
f0104d56:	74 21                	je     f0104d79 <trap+0x16e>
f0104d58:	83 f8 0e             	cmp    $0xe,%eax
f0104d5b:	90                   	nop
f0104d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d60:	77 07                	ja     f0104d69 <trap+0x15e>
f0104d62:	83 f8 03             	cmp    $0x3,%eax
f0104d65:	74 23                	je     f0104d8a <trap+0x17f>
f0104d67:	eb 6c                	jmp    f0104dd5 <trap+0x1ca>
f0104d69:	83 f8 20             	cmp    $0x20,%eax
f0104d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d70:	74 57                	je     f0104dc9 <trap+0x1be>
f0104d72:	83 f8 30             	cmp    $0x30,%eax
f0104d75:	74 20                	je     f0104d97 <trap+0x18c>
f0104d77:	eb 5c                	jmp    f0104dd5 <trap+0x1ca>
                return page_fault_handler(tf);
f0104d79:	89 34 24             	mov    %esi,(%esp)
f0104d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d80:	e8 de fc ff ff       	call   f0104a63 <page_fault_handler>
f0104d85:	e9 8c 00 00 00       	jmp    f0104e16 <trap+0x20b>
                return monitor(tf);
f0104d8a:	89 34 24             	mov    %esi,(%esp)
f0104d8d:	e8 bf bf ff ff       	call   f0100d51 <monitor>
f0104d92:	e9 7f 00 00 00       	jmp    f0104e16 <trap+0x20b>
                int r = syscall(
f0104d97:	8b 46 04             	mov    0x4(%esi),%eax
f0104d9a:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104d9e:	8b 06                	mov    (%esi),%eax
f0104da0:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104da4:	8b 46 10             	mov    0x10(%esi),%eax
f0104da7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104dab:	8b 46 18             	mov    0x18(%esi),%eax
f0104dae:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104db2:	8b 46 14             	mov    0x14(%esi),%eax
f0104db5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104db9:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104dbc:	89 04 24             	mov    %eax,(%esp)
f0104dbf:	e8 bc 02 00 00       	call   f0105080 <syscall>
                tf->tf_regs.reg_eax = r;
f0104dc4:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104dc7:	eb 4d                	jmp    f0104e16 <trap+0x20b>
            lapic_eoi();
f0104dc9:	e8 58 1c 00 00       	call   f0106a26 <lapic_eoi>
            sched_yield();
f0104dce:	66 90                	xchg   %ax,%ax
f0104dd0:	e8 f5 01 00 00       	call   f0104fca <sched_yield>
    print_trapframe(tf);
f0104dd5:	89 34 24             	mov    %esi,(%esp)
f0104dd8:	e8 e9 fa ff ff       	call   f01048c6 <print_trapframe>
    if (tf->tf_cs == GD_KT)
f0104ddd:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104de2:	75 1c                	jne    f0104e00 <trap+0x1f5>
        panic("unhandled trap in kernel");
f0104de4:	c7 44 24 08 95 87 10 	movl   $0xf0108795,0x8(%esp)
f0104deb:	f0 
f0104dec:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f0104df3:	00 
f0104df4:	c7 04 24 4c 87 10 f0 	movl   $0xf010874c,(%esp)
f0104dfb:	e8 40 b2 ff ff       	call   f0100040 <_panic>
        env_destroy(curenv);
f0104e00:	e8 d4 1a 00 00       	call   f01068d9 <cpunum>
f0104e05:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e08:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104e0e:	89 04 24             	mov    %eax,(%esp)
f0104e11:	e8 ca f1 ff ff       	call   f0103fe0 <env_destroy>
    if (curenv && curenv->env_status == ENV_RUNNING)
f0104e16:	e8 be 1a 00 00       	call   f01068d9 <cpunum>
f0104e1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e1e:	83 b8 28 50 21 f0 00 	cmpl   $0x0,-0xfdeafd8(%eax)
f0104e25:	74 2a                	je     f0104e51 <trap+0x246>
f0104e27:	e8 ad 1a 00 00       	call   f01068d9 <cpunum>
f0104e2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e2f:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104e35:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e39:	75 16                	jne    f0104e51 <trap+0x246>
        env_run(curenv);
f0104e3b:	e8 99 1a 00 00       	call   f01068d9 <cpunum>
f0104e40:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e43:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104e49:	89 04 24             	mov    %eax,(%esp)
f0104e4c:	e8 30 f2 ff ff       	call   f0104081 <env_run>
        sched_yield();
f0104e51:	e8 74 01 00 00       	call   f0104fca <sched_yield>

f0104e56 <t_pgflt>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

// HINT 1 : TRAPHANDLER_NOEC(t_divide, T_DIVIDE);
TRAPHANDLER(t_pgflt, T_PGFLT)
f0104e56:	6a 0e                	push   $0xe
f0104e58:	e9 85 00 00 00       	jmp    f0104ee2 <_alltraps>
f0104e5d:	90                   	nop

f0104e5e <t_divide>:

TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0104e5e:	6a 00                	push   $0x0
f0104e60:	6a 00                	push   $0x0
f0104e62:	eb 7e                	jmp    f0104ee2 <_alltraps>

f0104e64 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104e64:	6a 00                	push   $0x0
f0104e66:	6a 01                	push   $0x1
f0104e68:	eb 78                	jmp    f0104ee2 <_alltraps>

f0104e6a <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104e6a:	6a 00                	push   $0x0
f0104e6c:	6a 02                	push   $0x2
f0104e6e:	eb 72                	jmp    f0104ee2 <_alltraps>

f0104e70 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0104e70:	6a 00                	push   $0x0
f0104e72:	6a 03                	push   $0x3
f0104e74:	eb 6c                	jmp    f0104ee2 <_alltraps>

f0104e76 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104e76:	6a 00                	push   $0x0
f0104e78:	6a 04                	push   $0x4
f0104e7a:	eb 66                	jmp    f0104ee2 <_alltraps>

f0104e7c <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0104e7c:	6a 00                	push   $0x0
f0104e7e:	6a 05                	push   $0x5
f0104e80:	eb 60                	jmp    f0104ee2 <_alltraps>

f0104e82 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104e82:	6a 00                	push   $0x0
f0104e84:	6a 06                	push   $0x6
f0104e86:	eb 5a                	jmp    f0104ee2 <_alltraps>

f0104e88 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104e88:	6a 00                	push   $0x0
f0104e8a:	6a 07                	push   $0x7
f0104e8c:	eb 54                	jmp    f0104ee2 <_alltraps>

f0104e8e <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT)
f0104e8e:	6a 08                	push   $0x8
f0104e90:	eb 50                	jmp    f0104ee2 <_alltraps>

f0104e92 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104e92:	6a 0a                	push   $0xa
f0104e94:	eb 4c                	jmp    f0104ee2 <_alltraps>

f0104e96 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0104e96:	6a 0b                	push   $0xb
f0104e98:	eb 48                	jmp    f0104ee2 <_alltraps>

f0104e9a <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0104e9a:	6a 0c                	push   $0xc
f0104e9c:	eb 44                	jmp    f0104ee2 <_alltraps>

f0104e9e <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104e9e:	6a 0d                	push   $0xd
f0104ea0:	eb 40                	jmp    f0104ee2 <_alltraps>

f0104ea2 <t_fperr>:
//TRAPHANDLER(t_pgflt, T_PGFLT)

TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104ea2:	6a 00                	push   $0x0
f0104ea4:	6a 10                	push   $0x10
f0104ea6:	eb 3a                	jmp    f0104ee2 <_alltraps>

f0104ea8 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104ea8:	6a 11                	push   $0x11
f0104eaa:	eb 36                	jmp    f0104ee2 <_alltraps>

f0104eac <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104eac:	6a 00                	push   $0x0
f0104eae:	6a 12                	push   $0x12
f0104eb0:	eb 30                	jmp    f0104ee2 <_alltraps>

f0104eb2 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104eb2:	6a 00                	push   $0x0
f0104eb4:	6a 13                	push   $0x13
f0104eb6:	eb 2a                	jmp    f0104ee2 <_alltraps>

f0104eb8 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104eb8:	6a 00                	push   $0x0
f0104eba:	6a 30                	push   $0x30
f0104ebc:	eb 24                	jmp    f0104ee2 <_alltraps>

f0104ebe <irq_timer>:

TRAPHANDLER_NOEC(irq_timer, IRQ_TIMER+IRQ_OFFSET)
f0104ebe:	6a 00                	push   $0x0
f0104ec0:	6a 20                	push   $0x20
f0104ec2:	eb 1e                	jmp    f0104ee2 <_alltraps>

f0104ec4 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_KBD+IRQ_OFFSET)
f0104ec4:	6a 00                	push   $0x0
f0104ec6:	6a 21                	push   $0x21
f0104ec8:	eb 18                	jmp    f0104ee2 <_alltraps>

f0104eca <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_SERIAL+IRQ_OFFSET)
f0104eca:	6a 00                	push   $0x0
f0104ecc:	6a 24                	push   $0x24
f0104ece:	eb 12                	jmp    f0104ee2 <_alltraps>

f0104ed0 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_SPURIOUS+IRQ_OFFSET)
f0104ed0:	6a 00                	push   $0x0
f0104ed2:	6a 27                	push   $0x27
f0104ed4:	eb 0c                	jmp    f0104ee2 <_alltraps>

f0104ed6 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_IDE+IRQ_OFFSET)
f0104ed6:	6a 00                	push   $0x0
f0104ed8:	6a 2e                	push   $0x2e
f0104eda:	eb 06                	jmp    f0104ee2 <_alltraps>

f0104edc <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_ERROR+IRQ_OFFSET)
f0104edc:	6a 00                	push   $0x0
f0104ede:	6a 33                	push   $0x33
f0104ee0:	eb 00                	jmp    f0104ee2 <_alltraps>

f0104ee2 <_alltraps>:
    ///add $0x4, %esp
   /* sub $0x2, %esp
    pushw %ds;
    sub $0x2, %esp
    pushw %es*/
    pushl %ds
f0104ee2:	1e                   	push   %ds
    pushl %es
f0104ee3:	06                   	push   %es
    pushal
f0104ee4:	60                   	pusha  

    movl $GD_KD, %eax
f0104ee5:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
f0104eea:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f0104eec:	8e c0                	mov    %eax,%es
    pushl %esp
f0104eee:	54                   	push   %esp

    call trap
f0104eef:	e8 17 fd ff ff       	call   f0104c0b <trap>

f0104ef4 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104ef4:	55                   	push   %ebp
f0104ef5:	89 e5                	mov    %esp,%ebp
f0104ef7:	83 ec 18             	sub    $0x18,%esp
f0104efa:	8b 15 48 42 21 f0    	mov    0xf0214248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104f00:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104f05:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104f08:	83 e9 01             	sub    $0x1,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104f0b:	83 f9 02             	cmp    $0x2,%ecx
f0104f0e:	76 0f                	jbe    f0104f1f <sched_halt+0x2b>
	for (i = 0; i < NENV; i++) {
f0104f10:	83 c0 01             	add    $0x1,%eax
f0104f13:	83 c2 7c             	add    $0x7c,%edx
f0104f16:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f1b:	75 e8                	jne    f0104f05 <sched_halt+0x11>
f0104f1d:	eb 07                	jmp    f0104f26 <sched_halt+0x32>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104f1f:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f24:	75 1a                	jne    f0104f40 <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f0104f26:	c7 04 24 90 89 10 f0 	movl   $0xf0108990,(%esp)
f0104f2d:	e8 a9 f3 ff ff       	call   f01042db <cprintf>
		while (1)
			monitor(NULL);
f0104f32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104f39:	e8 13 be ff ff       	call   f0100d51 <monitor>
f0104f3e:	eb f2                	jmp    f0104f32 <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104f40:	e8 94 19 00 00       	call   f01068d9 <cpunum>
f0104f45:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f48:	c7 80 28 50 21 f0 00 	movl   $0x0,-0xfdeafd8(%eax)
f0104f4f:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104f52:	a1 8c 4e 21 f0       	mov    0xf0214e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104f57:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104f5c:	77 20                	ja     f0104f7e <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104f5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104f62:	c7 44 24 08 08 70 10 	movl   $0xf0107008,0x8(%esp)
f0104f69:	f0 
f0104f6a:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
f0104f71:	00 
f0104f72:	c7 04 24 b9 89 10 f0 	movl   $0xf01089b9,(%esp)
f0104f79:	e8 c2 b0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104f7e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104f83:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104f86:	e8 4e 19 00 00       	call   f01068d9 <cpunum>
f0104f8b:	6b d0 74             	imul   $0x74,%eax,%edx
f0104f8e:	81 c2 20 50 21 f0    	add    $0xf0215020,%edx
	asm volatile("lock; xchgl %0, %1"
f0104f94:	b8 02 00 00 00       	mov    $0x2,%eax
f0104f99:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	spin_unlock(&kernel_lock);
f0104f9d:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104fa4:	e8 5a 1c 00 00       	call   f0106c03 <spin_unlock>
	asm volatile("pause");
f0104fa9:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104fab:	e8 29 19 00 00       	call   f01068d9 <cpunum>
f0104fb0:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104fb3:	8b 80 30 50 21 f0    	mov    -0xfdeafd0(%eax),%eax
f0104fb9:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104fbe:	89 c4                	mov    %eax,%esp
f0104fc0:	6a 00                	push   $0x0
f0104fc2:	6a 00                	push   $0x0
f0104fc4:	fb                   	sti    
f0104fc5:	f4                   	hlt    
f0104fc6:	eb fd                	jmp    f0104fc5 <sched_halt+0xd1>
}
f0104fc8:	c9                   	leave  
f0104fc9:	c3                   	ret    

f0104fca <sched_yield>:
{
f0104fca:	55                   	push   %ebp
f0104fcb:	89 e5                	mov    %esp,%ebp
f0104fcd:	56                   	push   %esi
f0104fce:	53                   	push   %ebx
f0104fcf:	83 ec 10             	sub    $0x10,%esp
    if (curenv != NULL)
f0104fd2:	e8 02 19 00 00       	call   f01068d9 <cpunum>
f0104fd7:	6b c0 74             	imul   $0x74,%eax,%eax
    int envid = 0;
f0104fda:	b9 00 00 00 00       	mov    $0x0,%ecx
    if (curenv != NULL)
f0104fdf:	83 b8 28 50 21 f0 00 	cmpl   $0x0,-0xfdeafd8(%eax)
f0104fe6:	74 17                	je     f0104fff <sched_yield+0x35>
        envid = ENVX(curenv->env_id);
f0104fe8:	e8 ec 18 00 00       	call   f01068d9 <cpunum>
f0104fed:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ff0:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0104ff6:	8b 48 48             	mov    0x48(%eax),%ecx
f0104ff9:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        if (envs[i%NENV].env_status == ENV_RUNNABLE){
f0104fff:	8b 1d 48 42 21 f0    	mov    0xf0214248,%ebx
    for(i = envid; i < envid+NENV ; i++) {
f0105005:	89 c8                	mov    %ecx,%eax
f0105007:	81 c1 00 04 00 00    	add    $0x400,%ecx
f010500d:	eb 25                	jmp    f0105034 <sched_yield+0x6a>
        if (envs[i%NENV].env_status == ENV_RUNNABLE){
f010500f:	99                   	cltd   
f0105010:	c1 ea 16             	shr    $0x16,%edx
f0105013:	8d 34 10             	lea    (%eax,%edx,1),%esi
f0105016:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010501c:	29 d6                	sub    %edx,%esi
f010501e:	6b d6 7c             	imul   $0x7c,%esi,%edx
f0105021:	01 da                	add    %ebx,%edx
f0105023:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0105027:	75 08                	jne    f0105031 <sched_yield+0x67>
            env_run(&envs[i%NENV]);
f0105029:	89 14 24             	mov    %edx,(%esp)
f010502c:	e8 50 f0 ff ff       	call   f0104081 <env_run>
    for(i = envid; i < envid+NENV ; i++) {
f0105031:	83 c0 01             	add    $0x1,%eax
f0105034:	39 c8                	cmp    %ecx,%eax
f0105036:	7c d7                	jl     f010500f <sched_yield+0x45>
    if(curenv && curenv->env_status == ENV_RUNNING) {
f0105038:	e8 9c 18 00 00       	call   f01068d9 <cpunum>
f010503d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105040:	83 b8 28 50 21 f0 00 	cmpl   $0x0,-0xfdeafd8(%eax)
f0105047:	74 2a                	je     f0105073 <sched_yield+0xa9>
f0105049:	e8 8b 18 00 00       	call   f01068d9 <cpunum>
f010504e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105051:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0105057:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010505b:	75 16                	jne    f0105073 <sched_yield+0xa9>
        env_run(curenv);
f010505d:	e8 77 18 00 00       	call   f01068d9 <cpunum>
f0105062:	6b c0 74             	imul   $0x74,%eax,%eax
f0105065:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f010506b:	89 04 24             	mov    %eax,(%esp)
f010506e:	e8 0e f0 ff ff       	call   f0104081 <env_run>
	sched_halt();
f0105073:	e8 7c fe ff ff       	call   f0104ef4 <sched_halt>
}
f0105078:	83 c4 10             	add    $0x10,%esp
f010507b:	5b                   	pop    %ebx
f010507c:	5e                   	pop    %esi
f010507d:	5d                   	pop    %ebp
f010507e:	c3                   	ret    
f010507f:	90                   	nop

f0105080 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105080:	55                   	push   %ebp
f0105081:	89 e5                	mov    %esp,%ebp
f0105083:	57                   	push   %edi
f0105084:	56                   	push   %esi
f0105085:	53                   	push   %ebx
f0105086:	83 ec 2c             	sub    $0x2c,%esp
f0105089:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno){
f010508c:	83 f8 0d             	cmp    $0xd,%eax
f010508f:	0f 87 95 05 00 00    	ja     f010562a <syscall+0x5aa>
f0105095:	ff 24 85 cc 89 10 f0 	jmp    *-0xfef7634(,%eax,4)
    user_mem_assert(curenv, s, len, PTE_P);
f010509c:	e8 38 18 00 00       	call   f01068d9 <cpunum>
f01050a1:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
f01050a8:	00 
f01050a9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01050ac:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01050b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01050b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ba:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01050c0:	89 04 24             	mov    %eax,(%esp)
f01050c3:	e8 9a e8 ff ff       	call   f0103962 <user_mem_assert>
	cprintf("%.*s", len, s);
f01050c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050cf:	8b 45 10             	mov    0x10(%ebp),%eax
f01050d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050d6:	c7 04 24 c6 89 10 f0 	movl   $0xf01089c6,(%esp)
f01050dd:	e8 f9 f1 ff ff       	call   f01042db <cprintf>
	return cons_getc();
f01050e2:	e8 3b b5 ff ff       	call   f0100622 <cons_getc>
        case(SYS_cputs):{
            sys_cputs((const char*)a1, (size_t)a2);
                        }
       case(SYS_cgetc):{
            return sys_cgetc();
f01050e7:	e9 4a 05 00 00       	jmp    f0105636 <syscall+0x5b6>
	return curenv->env_id;
f01050ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01050f0:	e8 e4 17 00 00       	call   f01068d9 <cpunum>
f01050f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01050f8:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01050fe:	8b 40 48             	mov    0x48(%eax),%eax
        }
        case(SYS_getenvid):{
            return sys_getenvid();
f0105101:	e9 30 05 00 00       	jmp    f0105636 <syscall+0x5b6>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0105106:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010510d:	00 
f010510e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105111:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105115:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105118:	89 04 24             	mov    %eax,(%esp)
f010511b:	e8 9a e8 ff ff       	call   f01039ba <envid2env>
		return r;
f0105120:	89 c2                	mov    %eax,%edx
	if ((r = envid2env(envid, &e, 1)) < 0)
f0105122:	85 c0                	test   %eax,%eax
f0105124:	78 10                	js     f0105136 <syscall+0xb6>
	env_destroy(e);
f0105126:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105129:	89 04 24             	mov    %eax,(%esp)
f010512c:	e8 af ee ff ff       	call   f0103fe0 <env_destroy>
	return 0;
f0105131:	ba 00 00 00 00       	mov    $0x0,%edx
        }
        case(SYS_env_destroy):{
           return sys_env_destroy(a1);
f0105136:	89 d0                	mov    %edx,%eax
f0105138:	e9 f9 04 00 00       	jmp    f0105636 <syscall+0x5b6>
	sched_yield();
f010513d:	e8 88 fe ff ff       	call   f0104fca <sched_yield>
    int a = env_alloc(&newenv, curenv->env_id);
f0105142:	e8 92 17 00 00       	call   f01068d9 <cpunum>
f0105147:	6b c0 74             	imul   $0x74,%eax,%eax
f010514a:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0105150:	8b 40 48             	mov    0x48(%eax),%eax
f0105153:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105157:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010515a:	89 04 24             	mov    %eax,(%esp)
f010515d:	e8 68 e9 ff ff       	call   f0103aca <env_alloc>
        return a;//-E_NO_FREE_ENV;
f0105162:	89 c2                	mov    %eax,%edx
    if(a < 0){
f0105164:	85 c0                	test   %eax,%eax
f0105166:	78 2e                	js     f0105196 <syscall+0x116>
    newenv->env_status = ENV_NOT_RUNNABLE;
f0105168:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010516b:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
    newenv->env_tf = curenv->env_tf;
f0105172:	e8 62 17 00 00       	call   f01068d9 <cpunum>
f0105177:	6b c0 74             	imul   $0x74,%eax,%eax
f010517a:	8b b0 28 50 21 f0    	mov    -0xfdeafd8(%eax),%esi
f0105180:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105185:	89 df                	mov    %ebx,%edi
f0105187:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    newenv->env_tf.tf_regs.reg_eax = 0;
f0105189:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010518c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    return newenv->env_id;
f0105193:	8b 50 48             	mov    0x48(%eax),%edx
        }
        case(SYS_yield):{
            sys_yield();
        }
        case(SYS_exofork):{
            return sys_exofork();
f0105196:	89 d0                	mov    %edx,%eax
f0105198:	e9 99 04 00 00       	jmp    f0105636 <syscall+0x5b6>
    int r = envid2env(envid, &found, 1);
f010519d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051a4:	00 
f01051a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051af:	89 04 24             	mov    %eax,(%esp)
f01051b2:	e8 03 e8 ff ff       	call   f01039ba <envid2env>
    if(r != 0 ){
f01051b7:	85 c0                	test   %eax,%eax
f01051b9:	75 1f                	jne    f01051da <syscall+0x15a>
    if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE){
f01051bb:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f01051bf:	74 06                	je     f01051c7 <syscall+0x147>
f01051c1:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f01051c5:	75 1d                	jne    f01051e4 <syscall+0x164>
    found->env_status = status;
f01051c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051ca:	8b 7d 10             	mov    0x10(%ebp),%edi
f01051cd:	89 78 54             	mov    %edi,0x54(%eax)
    return 0;
f01051d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01051d5:	e9 5c 04 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_BAD_ENV;
f01051da:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01051df:	e9 52 04 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_INVAL;
f01051e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        }

        case(SYS_env_set_status):{
            return sys_env_set_status(a1, a2);
f01051e9:	e9 48 04 00 00       	jmp    f0105636 <syscall+0x5b6>
    int x = envid2env(envid, &found, 1);
f01051ee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051f5:	00 
f01051f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105200:	89 04 24             	mov    %eax,(%esp)
f0105203:	e8 b2 e7 ff ff       	call   f01039ba <envid2env>
    if(x != 0 ){
f0105208:	85 c0                	test   %eax,%eax
f010520a:	75 6a                	jne    f0105276 <syscall+0x1f6>
    if(va >= (void *)UTOP || PGOFF(va) != 0){
f010520c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105213:	77 6b                	ja     f0105280 <syscall+0x200>
f0105215:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010521c:	75 6c                	jne    f010528a <syscall+0x20a>
    if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0){
f010521e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105221:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105226:	83 f8 05             	cmp    $0x5,%eax
f0105229:	75 69                	jne    f0105294 <syscall+0x214>
    struct PageInfo* newPage = page_alloc(ALLOC_ZERO);
f010522b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105232:	e8 61 c2 ff ff       	call   f0101498 <page_alloc>
f0105237:	89 c3                	mov    %eax,%ebx
    if(newPage == NULL){
f0105239:	85 c0                	test   %eax,%eax
f010523b:	74 61                	je     f010529e <syscall+0x21e>
    int r = page_insert(found->env_pgdir, newPage, va,PTE_U | PTE_P| perm);
f010523d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105240:	83 c8 05             	or     $0x5,%eax
f0105243:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105247:	8b 45 10             	mov    0x10(%ebp),%eax
f010524a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010524e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105255:	8b 40 60             	mov    0x60(%eax),%eax
f0105258:	89 04 24             	mov    %eax,(%esp)
f010525b:	e8 86 c5 ff ff       	call   f01017e6 <page_insert>
    if(r != 0){
f0105260:	85 c0                	test   %eax,%eax
f0105262:	74 44                	je     f01052a8 <syscall+0x228>
        page_free(newPage);
f0105264:	89 1c 24             	mov    %ebx,(%esp)
f0105267:	e8 b7 c2 ff ff       	call   f0101523 <page_free>
        return -E_NO_MEM;
f010526c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105271:	e9 c0 03 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_BAD_ENV;
f0105276:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010527b:	e9 b6 03 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_INVAL;
f0105280:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105285:	e9 ac 03 00 00       	jmp    f0105636 <syscall+0x5b6>
f010528a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010528f:	e9 a2 03 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_INVAL;
f0105294:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105299:	e9 98 03 00 00       	jmp    f0105636 <syscall+0x5b6>
       return -E_NO_MEM;
f010529e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01052a3:	e9 8e 03 00 00       	jmp    f0105636 <syscall+0x5b6>
    return 0;
f01052a8:	b8 00 00 00 00       	mov    $0x0,%eax
        }
        case(SYS_page_alloc):{
            return sys_page_alloc(a1, (void *)a2, a3);
f01052ad:	e9 84 03 00 00       	jmp    f0105636 <syscall+0x5b6>
    int x = envid2env(srcenvid, &src, 1);
f01052b2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052b9:	00 
f01052ba:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01052bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052c4:	89 04 24             	mov    %eax,(%esp)
f01052c7:	e8 ee e6 ff ff       	call   f01039ba <envid2env>
    if(x != 0 ){
f01052cc:	85 c0                	test   %eax,%eax
f01052ce:	0f 85 c0 00 00 00    	jne    f0105394 <syscall+0x314>
    x = envid2env(dstenvid, &dst, 1);
f01052d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052db:	00 
f01052dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01052df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e6:	89 04 24             	mov    %eax,(%esp)
f01052e9:	e8 cc e6 ff ff       	call   f01039ba <envid2env>
    if(x != 0 ){
f01052ee:	85 c0                	test   %eax,%eax
f01052f0:	0f 85 a8 00 00 00    	jne    f010539e <syscall+0x31e>
    if(srcva >= (void *)UTOP || PGOFF(srcva) != 0){
f01052f6:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01052fd:	0f 87 a5 00 00 00    	ja     f01053a8 <syscall+0x328>
f0105303:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010530a:	0f 85 a2 00 00 00    	jne    f01053b2 <syscall+0x332>
    if(dstva >= (void *)UTOP || PGOFF(dstva) != 0){
f0105310:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105317:	0f 87 9f 00 00 00    	ja     f01053bc <syscall+0x33c>
f010531d:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105324:	0f 85 9c 00 00 00    	jne    f01053c6 <syscall+0x346>
    if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0){
f010532a:	8b 45 1c             	mov    0x1c(%ebp),%eax
f010532d:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105332:	83 f8 05             	cmp    $0x5,%eax
f0105335:	0f 85 95 00 00 00    	jne    f01053d0 <syscall+0x350>
    p = page_lookup(src->env_pgdir, srcva, &pte);
f010533b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010533e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105342:	8b 45 10             	mov    0x10(%ebp),%eax
f0105345:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105349:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010534c:	8b 40 60             	mov    0x60(%eax),%eax
f010534f:	89 04 24             	mov    %eax,(%esp)
f0105352:	e8 90 c3 ff ff       	call   f01016e7 <page_lookup>
    if(p == NULL){
f0105357:	85 c0                	test   %eax,%eax
f0105359:	74 7f                	je     f01053da <syscall+0x35a>
    if((perm & PTE_W) && !(*pte & PTE_W)){
f010535b:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010535f:	74 08                	je     f0105369 <syscall+0x2e9>
f0105361:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105364:	f6 02 02             	testb  $0x2,(%edx)
f0105367:	74 7b                	je     f01053e4 <syscall+0x364>
    int r = page_insert(dst->env_pgdir, p, dstva, perm);
f0105369:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f010536c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105370:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105373:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105377:	89 44 24 04          	mov    %eax,0x4(%esp)
f010537b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010537e:	8b 40 60             	mov    0x60(%eax),%eax
f0105381:	89 04 24             	mov    %eax,(%esp)
f0105384:	e8 5d c4 ff ff       	call   f01017e6 <page_insert>
        return -E_NO_MEM;
f0105389:	c1 f8 1f             	sar    $0x1f,%eax
f010538c:	83 e0 fc             	and    $0xfffffffc,%eax
f010538f:	e9 a2 02 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_BAD_ENV;
f0105394:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105399:	e9 98 02 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_BAD_ENV;
f010539e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01053a3:	e9 8e 02 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_INVAL;
f01053a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053ad:	e9 84 02 00 00       	jmp    f0105636 <syscall+0x5b6>
f01053b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053b7:	e9 7a 02 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_INVAL;
f01053bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053c1:	e9 70 02 00 00       	jmp    f0105636 <syscall+0x5b6>
f01053c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053cb:	e9 66 02 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_INVAL;
f01053d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053d5:	e9 5c 02 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_NO_MEM;
f01053da:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01053df:	e9 52 02 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_INVAL;
f01053e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        }
        case(SYS_page_map):{
            return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f01053e9:	e9 48 02 00 00       	jmp    f0105636 <syscall+0x5b6>
    int x = envid2env(envid, &e, 1);
f01053ee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01053f5:	00 
f01053f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105400:	89 04 24             	mov    %eax,(%esp)
f0105403:	e8 b2 e5 ff ff       	call   f01039ba <envid2env>
    if(x != 0 ){
f0105408:	85 c0                	test   %eax,%eax
f010540a:	75 31                	jne    f010543d <syscall+0x3bd>
    if(va >= (void *)UTOP || PGOFF(va) != 0){
f010540c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105413:	77 32                	ja     f0105447 <syscall+0x3c7>
f0105415:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010541c:	75 33                	jne    f0105451 <syscall+0x3d1>
    page_remove(e->env_pgdir, va);
f010541e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105421:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105425:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105428:	8b 40 60             	mov    0x60(%eax),%eax
f010542b:	89 04 24             	mov    %eax,(%esp)
f010542e:	e8 62 c3 ff ff       	call   f0101795 <page_remove>
	return 0;
f0105433:	b8 00 00 00 00       	mov    $0x0,%eax
f0105438:	e9 f9 01 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_BAD_ENV;
f010543d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105442:	e9 ef 01 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_INVAL;
f0105447:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010544c:	e9 e5 01 00 00       	jmp    f0105636 <syscall+0x5b6>
f0105451:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        }
        case(SYS_page_unmap):{
            return sys_page_unmap(a1, (void *)a2);
f0105456:	e9 db 01 00 00       	jmp    f0105636 <syscall+0x5b6>
    int r = envid2env(envid, &found, 1);
f010545b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105462:	00 
f0105463:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105466:	89 44 24 04          	mov    %eax,0x4(%esp)
f010546a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010546d:	89 04 24             	mov    %eax,(%esp)
f0105470:	e8 45 e5 ff ff       	call   f01039ba <envid2env>
    if(r != 0 ){
f0105475:	85 c0                	test   %eax,%eax
f0105477:	75 13                	jne    f010548c <syscall+0x40c>
    found->env_pgfault_upcall = func;
f0105479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010547c:	8b 75 10             	mov    0x10(%ebp),%esi
f010547f:	89 70 64             	mov    %esi,0x64(%eax)
    return 0;
f0105482:	b8 00 00 00 00       	mov    $0x0,%eax
f0105487:	e9 aa 01 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_BAD_ENV;
f010548c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        }

        case (SYS_env_set_pgfault_upcall):{
            return sys_env_set_pgfault_upcall(a1, (void *) a2);
f0105491:	e9 a0 01 00 00       	jmp    f0105636 <syscall+0x5b6>
    r = envid2env(envid, &e, 0);
f0105496:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010549d:	00 
f010549e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01054a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054a8:	89 04 24             	mov    %eax,(%esp)
f01054ab:	e8 0a e5 ff ff       	call   f01039ba <envid2env>
    if(r < 0){
f01054b0:	85 c0                	test   %eax,%eax
f01054b2:	0f 88 7e 01 00 00    	js     f0105636 <syscall+0x5b6>
    if(!e->env_ipc_recving){
f01054b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054bb:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01054bf:	0f 84 e6 00 00 00    	je     f01055ab <syscall+0x52b>
    if(srcva < (void *)UTOP){
f01054c5:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01054cc:	0f 87 96 00 00 00    	ja     f0105568 <syscall+0x4e8>
        if(PGOFF(srcva) != 0){
f01054d2:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01054d9:	0f 85 d6 00 00 00    	jne    f01055b5 <syscall+0x535>
        if((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P) || (perm & ~PTE_SYSCALL) != 0){
f01054df:	8b 45 18             	mov    0x18(%ebp),%eax
f01054e2:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01054e7:	83 f8 05             	cmp    $0x5,%eax
f01054ea:	0f 85 cc 00 00 00    	jne    f01055bc <syscall+0x53c>
        p = page_lookup(curenv->env_pgdir, srcva, &pte);
f01054f0:	e8 e4 13 00 00       	call   f01068d9 <cpunum>
f01054f5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01054f8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01054fc:	8b 7d 14             	mov    0x14(%ebp),%edi
f01054ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105503:	6b c0 74             	imul   $0x74,%eax,%eax
f0105506:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f010550c:	8b 40 60             	mov    0x60(%eax),%eax
f010550f:	89 04 24             	mov    %eax,(%esp)
f0105512:	e8 d0 c1 ff ff       	call   f01016e7 <page_lookup>
        if(p == NULL){
f0105517:	85 c0                	test   %eax,%eax
f0105519:	0f 84 a4 00 00 00    	je     f01055c3 <syscall+0x543>
        if( !(*pte & PTE_W) && (perm & PTE_W) ){
f010551f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105522:	f6 02 02             	testb  $0x2,(%edx)
f0105525:	75 0a                	jne    f0105531 <syscall+0x4b1>
f0105527:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010552b:	0f 85 99 00 00 00    	jne    f01055ca <syscall+0x54a>
        if(e->env_ipc_dstva < (void *)UTOP){
f0105531:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105534:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105537:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010553d:	77 30                	ja     f010556f <syscall+0x4ef>
            r = page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm);
f010553f:	8b 75 18             	mov    0x18(%ebp),%esi
f0105542:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105546:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010554a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010554e:	8b 42 60             	mov    0x60(%edx),%eax
f0105551:	89 04 24             	mov    %eax,(%esp)
f0105554:	e8 8d c2 ff ff       	call   f01017e6 <page_insert>
            e->env_ipc_perm = perm;
f0105559:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010555c:	8b 75 18             	mov    0x18(%ebp),%esi
f010555f:	89 72 78             	mov    %esi,0x78(%edx)
        if(r < 0){
f0105562:	85 c0                	test   %eax,%eax
f0105564:	79 09                	jns    f010556f <syscall+0x4ef>
f0105566:	eb 69                	jmp    f01055d1 <syscall+0x551>
        e->env_ipc_perm = 0;
f0105568:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
    e->env_ipc_recving = 0;
f010556f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105572:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
    e->env_ipc_from = curenv->env_id;
f0105576:	e8 5e 13 00 00       	call   f01068d9 <cpunum>
f010557b:	6b c0 74             	imul   $0x74,%eax,%eax
f010557e:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0105584:	8b 40 48             	mov    0x48(%eax),%eax
f0105587:	89 43 74             	mov    %eax,0x74(%ebx)
    e->env_ipc_value = value;
f010558a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010558d:	8b 75 10             	mov    0x10(%ebp),%esi
f0105590:	89 70 70             	mov    %esi,0x70(%eax)
    e->env_tf.tf_regs.reg_eax = 0;
f0105593:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    e->env_status = ENV_RUNNABLE;
f010559a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    return 0;
f01055a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01055a6:	e9 8b 00 00 00       	jmp    f0105636 <syscall+0x5b6>
        return -E_IPC_NOT_RECV; // Honestly have no idea what this means, but usually "not" means not.
f01055ab:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01055b0:	e9 81 00 00 00       	jmp    f0105636 <syscall+0x5b6>
            return -E_INVAL;
f01055b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055ba:	eb 7a                	jmp    f0105636 <syscall+0x5b6>
            return -E_INVAL;
f01055bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055c1:	eb 73                	jmp    f0105636 <syscall+0x5b6>
            return -E_INVAL;
f01055c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055c8:	eb 6c                	jmp    f0105636 <syscall+0x5b6>
            return -E_INVAL;
f01055ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055cf:	eb 65                	jmp    f0105636 <syscall+0x5b6>
           return -E_NO_MEM;
f01055d1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        }
        case SYS_ipc_try_send:{
            return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f01055d6:	eb 5e                	jmp    f0105636 <syscall+0x5b6>
	if (dstva < (void *)UTOP && PGOFF(dstva) != 0){ // Had to ask about the whole page-aligned thing
f01055d8:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01055df:	77 09                	ja     f01055ea <syscall+0x56a>
f01055e1:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01055e8:	75 47                	jne    f0105631 <syscall+0x5b1>
    curenv->env_ipc_recving = 1;
f01055ea:	e8 ea 12 00 00       	call   f01068d9 <cpunum>
f01055ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01055f2:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01055f8:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_ipc_dstva = dstva;
f01055fc:	e8 d8 12 00 00       	call   f01068d9 <cpunum>
f0105601:	6b c0 74             	imul   $0x74,%eax,%eax
f0105604:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f010560a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010560d:	89 70 6c             	mov    %esi,0x6c(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0105610:	e8 c4 12 00 00       	call   f01068d9 <cpunum>
f0105615:	6b c0 74             	imul   $0x74,%eax,%eax
f0105618:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f010561e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0105625:	e8 a0 f9 ff ff       	call   f0104fca <sched_yield>
        }
        case SYS_ipc_recv:{
            return sys_ipc_recv((void *)a1);
        }
	default:
		return -E_INVAL;
f010562a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010562f:	eb 05                	jmp    f0105636 <syscall+0x5b6>
            return sys_ipc_recv((void *)a1);
f0105631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0105636:	83 c4 2c             	add    $0x2c,%esp
f0105639:	5b                   	pop    %ebx
f010563a:	5e                   	pop    %esi
f010563b:	5f                   	pop    %edi
f010563c:	5d                   	pop    %ebp
f010563d:	c3                   	ret    

f010563e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010563e:	55                   	push   %ebp
f010563f:	89 e5                	mov    %esp,%ebp
f0105641:	57                   	push   %edi
f0105642:	56                   	push   %esi
f0105643:	53                   	push   %ebx
f0105644:	83 ec 14             	sub    $0x14,%esp
f0105647:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010564a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010564d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105650:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105653:	8b 1a                	mov    (%edx),%ebx
f0105655:	8b 01                	mov    (%ecx),%eax
f0105657:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010565a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105661:	e9 88 00 00 00       	jmp    f01056ee <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0105666:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105669:	01 d8                	add    %ebx,%eax
f010566b:	89 c7                	mov    %eax,%edi
f010566d:	c1 ef 1f             	shr    $0x1f,%edi
f0105670:	01 c7                	add    %eax,%edi
f0105672:	d1 ff                	sar    %edi
f0105674:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105677:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010567a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010567d:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010567f:	eb 03                	jmp    f0105684 <stab_binsearch+0x46>
			m--;
f0105681:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0105684:	39 c3                	cmp    %eax,%ebx
f0105686:	7f 1f                	jg     f01056a7 <stab_binsearch+0x69>
f0105688:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010568c:	83 ea 0c             	sub    $0xc,%edx
f010568f:	39 f1                	cmp    %esi,%ecx
f0105691:	75 ee                	jne    f0105681 <stab_binsearch+0x43>
f0105693:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105696:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105699:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010569c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01056a0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01056a3:	76 18                	jbe    f01056bd <stab_binsearch+0x7f>
f01056a5:	eb 05                	jmp    f01056ac <stab_binsearch+0x6e>
			l = true_m + 1;
f01056a7:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01056aa:	eb 42                	jmp    f01056ee <stab_binsearch+0xb0>
			*region_left = m;
f01056ac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01056af:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01056b1:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01056b4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01056bb:	eb 31                	jmp    f01056ee <stab_binsearch+0xb0>
		} else if (stabs[m].n_value > addr) {
f01056bd:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01056c0:	73 17                	jae    f01056d9 <stab_binsearch+0x9b>
			*region_right = m - 1;
f01056c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01056c5:	83 e8 01             	sub    $0x1,%eax
f01056c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01056cb:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01056ce:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f01056d0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01056d7:	eb 15                	jmp    f01056ee <stab_binsearch+0xb0>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01056d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056dc:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01056df:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f01056e1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01056e5:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f01056e7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01056ee:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01056f1:	0f 8e 6f ff ff ff    	jle    f0105666 <stab_binsearch+0x28>
		}
	}

	if (!any_matches)
f01056f7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01056fb:	75 0f                	jne    f010570c <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01056fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105700:	8b 00                	mov    (%eax),%eax
f0105702:	83 e8 01             	sub    $0x1,%eax
f0105705:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105708:	89 07                	mov    %eax,(%edi)
f010570a:	eb 2c                	jmp    f0105738 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010570c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010570f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105711:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105714:	8b 0f                	mov    (%edi),%ecx
f0105716:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105719:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010571c:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f010571f:	eb 03                	jmp    f0105724 <stab_binsearch+0xe6>
		     l--)
f0105721:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0105724:	39 c8                	cmp    %ecx,%eax
f0105726:	7e 0b                	jle    f0105733 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0105728:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010572c:	83 ea 0c             	sub    $0xc,%edx
f010572f:	39 f3                	cmp    %esi,%ebx
f0105731:	75 ee                	jne    f0105721 <stab_binsearch+0xe3>
			/* do nothing */;
		*region_left = l;
f0105733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105736:	89 07                	mov    %eax,(%edi)
	}
}
f0105738:	83 c4 14             	add    $0x14,%esp
f010573b:	5b                   	pop    %ebx
f010573c:	5e                   	pop    %esi
f010573d:	5f                   	pop    %edi
f010573e:	5d                   	pop    %ebp
f010573f:	c3                   	ret    

f0105740 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105740:	55                   	push   %ebp
f0105741:	89 e5                	mov    %esp,%ebp
f0105743:	57                   	push   %edi
f0105744:	56                   	push   %esi
f0105745:	53                   	push   %ebx
f0105746:	83 ec 4c             	sub    $0x4c,%esp
f0105749:	8b 75 08             	mov    0x8(%ebp),%esi
f010574c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010574f:	c7 07 04 8a 10 f0    	movl   $0xf0108a04,(%edi)
	info->eip_line = 0;
f0105755:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010575c:	c7 47 08 04 8a 10 f0 	movl   $0xf0108a04,0x8(%edi)
	info->eip_fn_namelen = 9;
f0105763:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f010576a:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f010576d:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105774:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010577a:	0f 87 c1 00 00 00    	ja     f0105841 <debuginfo_eip+0x101>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

        if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) != 0)
f0105780:	e8 54 11 00 00       	call   f01068d9 <cpunum>
f0105785:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010578c:	00 
f010578d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105794:	00 
f0105795:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010579c:	00 
f010579d:	6b c0 74             	imul   $0x74,%eax,%eax
f01057a0:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01057a6:	89 04 24             	mov    %eax,(%esp)
f01057a9:	e8 1f e1 ff ff       	call   f01038cd <user_mem_check>
f01057ae:	85 c0                	test   %eax,%eax
f01057b0:	0f 85 51 02 00 00    	jne    f0105a07 <debuginfo_eip+0x2c7>
        {
            return -1;
        }
		stabs = usd->stabs;
f01057b6:	a1 00 00 20 00       	mov    0x200000,%eax
f01057bb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01057be:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f01057c4:	a1 08 00 20 00       	mov    0x200008,%eax
f01057c9:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f01057cc:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01057d2:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
        if(user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U) != 0){
f01057d5:	e8 ff 10 00 00       	call   f01068d9 <cpunum>
f01057da:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01057e1:	00 
f01057e2:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01057e9:	00 
f01057ea:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01057ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01057f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01057f4:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f01057fa:	89 04 24             	mov    %eax,(%esp)
f01057fd:	e8 cb e0 ff ff       	call   f01038cd <user_mem_check>
f0105802:	85 c0                	test   %eax,%eax
f0105804:	0f 85 04 02 00 00    	jne    f0105a0e <debuginfo_eip+0x2ce>
            return -1;
        }

        if(user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) != 0){
f010580a:	e8 ca 10 00 00       	call   f01068d9 <cpunum>
f010580f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105816:	00 
f0105817:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010581a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010581d:	29 ca                	sub    %ecx,%edx
f010581f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105823:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105827:	6b c0 74             	imul   $0x74,%eax,%eax
f010582a:	8b 80 28 50 21 f0    	mov    -0xfdeafd8(%eax),%eax
f0105830:	89 04 24             	mov    %eax,(%esp)
f0105833:	e8 95 e0 ff ff       	call   f01038cd <user_mem_check>
f0105838:	85 c0                	test   %eax,%eax
f010583a:	74 1f                	je     f010585b <debuginfo_eip+0x11b>
f010583c:	e9 d4 01 00 00       	jmp    f0105a15 <debuginfo_eip+0x2d5>
		stabstr_end = __STABSTR_END__;
f0105841:	c7 45 bc 5d 73 11 f0 	movl   $0xf011735d,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105848:	c7 45 c0 35 3b 11 f0 	movl   $0xf0113b35,-0x40(%ebp)
		stab_end = __STAB_END__;
f010584f:	bb 34 3b 11 f0       	mov    $0xf0113b34,%ebx
		stabs = __STAB_BEGIN__;
f0105854:	c7 45 c4 b0 8f 10 f0 	movl   $0xf0108fb0,-0x3c(%ebp)
            return -1;
        }
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010585b:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010585e:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0105861:	0f 83 b5 01 00 00    	jae    f0105a1c <debuginfo_eip+0x2dc>
f0105867:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010586b:	0f 85 b2 01 00 00    	jne    f0105a23 <debuginfo_eip+0x2e3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105871:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105878:	2b 5d c4             	sub    -0x3c(%ebp),%ebx
f010587b:	c1 fb 02             	sar    $0x2,%ebx
f010587e:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0105884:	83 e8 01             	sub    $0x1,%eax
f0105887:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010588a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010588e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105895:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105898:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010589b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010589e:	89 d8                	mov    %ebx,%eax
f01058a0:	e8 99 fd ff ff       	call   f010563e <stab_binsearch>
	if (lfile == 0)
f01058a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058a8:	85 c0                	test   %eax,%eax
f01058aa:	0f 84 7a 01 00 00    	je     f0105a2a <debuginfo_eip+0x2ea>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01058b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01058b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01058b9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01058bd:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01058c4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01058c7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01058ca:	89 d8                	mov    %ebx,%eax
f01058cc:	e8 6d fd ff ff       	call   f010563e <stab_binsearch>

	if (lfun <= rfun) {
f01058d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01058d4:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01058d7:	39 d8                	cmp    %ebx,%eax
f01058d9:	7f 32                	jg     f010590d <debuginfo_eip+0x1cd>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01058db:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01058de:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01058e1:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f01058e4:	8b 0a                	mov    (%edx),%ecx
f01058e6:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f01058e9:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01058ec:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f01058ef:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f01058f2:	73 09                	jae    f01058fd <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01058f4:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01058f7:	03 4d c0             	add    -0x40(%ebp),%ecx
f01058fa:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01058fd:	8b 52 08             	mov    0x8(%edx),%edx
f0105900:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0105903:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105905:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105908:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010590b:	eb 0f                	jmp    f010591c <debuginfo_eip+0x1dc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010590d:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f0105910:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105913:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105916:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105919:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010591c:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105923:	00 
f0105924:	8b 47 08             	mov    0x8(%edi),%eax
f0105927:	89 04 24             	mov    %eax,(%esp)
f010592a:	e8 3c 09 00 00       	call   f010626b <strfind>
f010592f:	2b 47 08             	sub    0x8(%edi),%eax
f0105932:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105935:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105939:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105940:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105943:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105946:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105949:	89 f0                	mov    %esi,%eax
f010594b:	e8 ee fc ff ff       	call   f010563e <stab_binsearch>

    if( lline <= rline ){
f0105950:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105953:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105956:	0f 8f d5 00 00 00    	jg     f0105a31 <debuginfo_eip+0x2f1>
        info->eip_line = stabs[lline].n_desc;
f010595c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010595f:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105964:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105967:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010596a:	89 c3                	mov    %eax,%ebx
f010596c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010596f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105972:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105975:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105978:	89 df                	mov    %ebx,%edi
f010597a:	eb 06                	jmp    f0105982 <debuginfo_eip+0x242>
f010597c:	83 e8 01             	sub    $0x1,%eax
f010597f:	83 ea 0c             	sub    $0xc,%edx
f0105982:	89 c6                	mov    %eax,%esi
f0105984:	39 c7                	cmp    %eax,%edi
f0105986:	7f 3c                	jg     f01059c4 <debuginfo_eip+0x284>
	       && stabs[lline].n_type != N_SOL
f0105988:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010598c:	80 f9 84             	cmp    $0x84,%cl
f010598f:	75 08                	jne    f0105999 <debuginfo_eip+0x259>
f0105991:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105994:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105997:	eb 11                	jmp    f01059aa <debuginfo_eip+0x26a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105999:	80 f9 64             	cmp    $0x64,%cl
f010599c:	75 de                	jne    f010597c <debuginfo_eip+0x23c>
f010599e:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01059a2:	74 d8                	je     f010597c <debuginfo_eip+0x23c>
f01059a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01059a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01059aa:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01059ad:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01059b0:	8b 04 86             	mov    (%esi,%eax,4),%eax
f01059b3:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01059b6:	2b 55 c0             	sub    -0x40(%ebp),%edx
f01059b9:	39 d0                	cmp    %edx,%eax
f01059bb:	73 0a                	jae    f01059c7 <debuginfo_eip+0x287>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01059bd:	03 45 c0             	add    -0x40(%ebp),%eax
f01059c0:	89 07                	mov    %eax,(%edi)
f01059c2:	eb 03                	jmp    f01059c7 <debuginfo_eip+0x287>
f01059c4:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01059c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01059ca:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01059cd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01059d2:	39 da                	cmp    %ebx,%edx
f01059d4:	7d 67                	jge    f0105a3d <debuginfo_eip+0x2fd>
		for (lline = lfun + 1;
f01059d6:	83 c2 01             	add    $0x1,%edx
f01059d9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01059dc:	89 d0                	mov    %edx,%eax
f01059de:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01059e1:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01059e4:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01059e7:	eb 04                	jmp    f01059ed <debuginfo_eip+0x2ad>
			info->eip_fn_narg++;
f01059e9:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f01059ed:	39 c3                	cmp    %eax,%ebx
f01059ef:	7e 47                	jle    f0105a38 <debuginfo_eip+0x2f8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01059f1:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01059f5:	83 c0 01             	add    $0x1,%eax
f01059f8:	83 c2 0c             	add    $0xc,%edx
f01059fb:	80 f9 a0             	cmp    $0xa0,%cl
f01059fe:	74 e9                	je     f01059e9 <debuginfo_eip+0x2a9>
	return 0;
f0105a00:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a05:	eb 36                	jmp    f0105a3d <debuginfo_eip+0x2fd>
            return -1;
f0105a07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a0c:	eb 2f                	jmp    f0105a3d <debuginfo_eip+0x2fd>
            return -1;
f0105a0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a13:	eb 28                	jmp    f0105a3d <debuginfo_eip+0x2fd>
            return -1;
f0105a15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a1a:	eb 21                	jmp    f0105a3d <debuginfo_eip+0x2fd>
		return -1;
f0105a1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a21:	eb 1a                	jmp    f0105a3d <debuginfo_eip+0x2fd>
f0105a23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a28:	eb 13                	jmp    f0105a3d <debuginfo_eip+0x2fd>
		return -1;
f0105a2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a2f:	eb 0c                	jmp    f0105a3d <debuginfo_eip+0x2fd>
        return -1;
f0105a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a36:	eb 05                	jmp    f0105a3d <debuginfo_eip+0x2fd>
	return 0;
f0105a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105a3d:	83 c4 4c             	add    $0x4c,%esp
f0105a40:	5b                   	pop    %ebx
f0105a41:	5e                   	pop    %esi
f0105a42:	5f                   	pop    %edi
f0105a43:	5d                   	pop    %ebp
f0105a44:	c3                   	ret    
f0105a45:	66 90                	xchg   %ax,%ax
f0105a47:	66 90                	xchg   %ax,%ax
f0105a49:	66 90                	xchg   %ax,%ax
f0105a4b:	66 90                	xchg   %ax,%ax
f0105a4d:	66 90                	xchg   %ax,%ax
f0105a4f:	90                   	nop

f0105a50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105a50:	55                   	push   %ebp
f0105a51:	89 e5                	mov    %esp,%ebp
f0105a53:	57                   	push   %edi
f0105a54:	56                   	push   %esi
f0105a55:	53                   	push   %ebx
f0105a56:	83 ec 3c             	sub    $0x3c,%esp
f0105a59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a5c:	89 d7                	mov    %edx,%edi
f0105a5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a61:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a67:	89 c3                	mov    %eax,%ebx
f0105a69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105a6c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a6f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105a72:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a77:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105a7a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105a7d:	39 d9                	cmp    %ebx,%ecx
f0105a7f:	72 05                	jb     f0105a86 <printnum+0x36>
f0105a81:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105a84:	77 69                	ja     f0105aef <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105a86:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105a89:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105a8d:	83 ee 01             	sub    $0x1,%esi
f0105a90:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105a94:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a98:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105a9c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105aa0:	89 c3                	mov    %eax,%ebx
f0105aa2:	89 d6                	mov    %edx,%esi
f0105aa4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105aa7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105aaa:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105aae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105ab2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ab5:	89 04 24             	mov    %eax,(%esp)
f0105ab8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105abb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105abf:	e8 5c 12 00 00       	call   f0106d20 <__udivdi3>
f0105ac4:	89 d9                	mov    %ebx,%ecx
f0105ac6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105aca:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105ace:	89 04 24             	mov    %eax,(%esp)
f0105ad1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ad5:	89 fa                	mov    %edi,%edx
f0105ad7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ada:	e8 71 ff ff ff       	call   f0105a50 <printnum>
f0105adf:	eb 1b                	jmp    f0105afc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105ae1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ae5:	8b 45 18             	mov    0x18(%ebp),%eax
f0105ae8:	89 04 24             	mov    %eax,(%esp)
f0105aeb:	ff d3                	call   *%ebx
f0105aed:	eb 03                	jmp    f0105af2 <printnum+0xa2>
f0105aef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
f0105af2:	83 ee 01             	sub    $0x1,%esi
f0105af5:	85 f6                	test   %esi,%esi
f0105af7:	7f e8                	jg     f0105ae1 <printnum+0x91>
f0105af9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105afc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b00:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105b04:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105b07:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105b0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b0e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105b12:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b15:	89 04 24             	mov    %eax,(%esp)
f0105b18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b1f:	e8 2c 13 00 00       	call   f0106e50 <__umoddi3>
f0105b24:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b28:	0f be 80 0e 8a 10 f0 	movsbl -0xfef75f2(%eax),%eax
f0105b2f:	89 04 24             	mov    %eax,(%esp)
f0105b32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b35:	ff d0                	call   *%eax
}
f0105b37:	83 c4 3c             	add    $0x3c,%esp
f0105b3a:	5b                   	pop    %ebx
f0105b3b:	5e                   	pop    %esi
f0105b3c:	5f                   	pop    %edi
f0105b3d:	5d                   	pop    %ebp
f0105b3e:	c3                   	ret    

f0105b3f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105b3f:	55                   	push   %ebp
f0105b40:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105b42:	83 fa 01             	cmp    $0x1,%edx
f0105b45:	7e 0e                	jle    f0105b55 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105b47:	8b 10                	mov    (%eax),%edx
f0105b49:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105b4c:	89 08                	mov    %ecx,(%eax)
f0105b4e:	8b 02                	mov    (%edx),%eax
f0105b50:	8b 52 04             	mov    0x4(%edx),%edx
f0105b53:	eb 22                	jmp    f0105b77 <getuint+0x38>
	else if (lflag)
f0105b55:	85 d2                	test   %edx,%edx
f0105b57:	74 10                	je     f0105b69 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105b59:	8b 10                	mov    (%eax),%edx
f0105b5b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105b5e:	89 08                	mov    %ecx,(%eax)
f0105b60:	8b 02                	mov    (%edx),%eax
f0105b62:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b67:	eb 0e                	jmp    f0105b77 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105b69:	8b 10                	mov    (%eax),%edx
f0105b6b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105b6e:	89 08                	mov    %ecx,(%eax)
f0105b70:	8b 02                	mov    (%edx),%eax
f0105b72:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105b77:	5d                   	pop    %ebp
f0105b78:	c3                   	ret    

f0105b79 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105b79:	55                   	push   %ebp
f0105b7a:	89 e5                	mov    %esp,%ebp
f0105b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105b7f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105b83:	8b 10                	mov    (%eax),%edx
f0105b85:	3b 50 04             	cmp    0x4(%eax),%edx
f0105b88:	73 0a                	jae    f0105b94 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105b8a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105b8d:	89 08                	mov    %ecx,(%eax)
f0105b8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b92:	88 02                	mov    %al,(%edx)
}
f0105b94:	5d                   	pop    %ebp
f0105b95:	c3                   	ret    

f0105b96 <printfmt>:
{
f0105b96:	55                   	push   %ebp
f0105b97:	89 e5                	mov    %esp,%ebp
f0105b99:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
f0105b9c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105b9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ba3:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ba6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105baa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105bad:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bb1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bb4:	89 04 24             	mov    %eax,(%esp)
f0105bb7:	e8 02 00 00 00       	call   f0105bbe <vprintfmt>
}
f0105bbc:	c9                   	leave  
f0105bbd:	c3                   	ret    

f0105bbe <vprintfmt>:
{
f0105bbe:	55                   	push   %ebp
f0105bbf:	89 e5                	mov    %esp,%ebp
f0105bc1:	57                   	push   %edi
f0105bc2:	56                   	push   %esi
f0105bc3:	53                   	push   %ebx
f0105bc4:	83 ec 3c             	sub    $0x3c,%esp
f0105bc7:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105bca:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105bcd:	eb 1f                	jmp    f0105bee <vprintfmt+0x30>
			if (ch == '\0'){
f0105bcf:	85 c0                	test   %eax,%eax
f0105bd1:	75 0f                	jne    f0105be2 <vprintfmt+0x24>
				color = 0x0100;
f0105bd3:	c7 05 64 4a 21 f0 00 	movl   $0x100,0xf0214a64
f0105bda:	01 00 00 
f0105bdd:	e9 b3 03 00 00       	jmp    f0105f95 <vprintfmt+0x3d7>
			putch(ch, putdat);
f0105be2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105be6:	89 04 24             	mov    %eax,(%esp)
f0105be9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105bec:	89 f3                	mov    %esi,%ebx
f0105bee:	8d 73 01             	lea    0x1(%ebx),%esi
f0105bf1:	0f b6 03             	movzbl (%ebx),%eax
f0105bf4:	83 f8 25             	cmp    $0x25,%eax
f0105bf7:	75 d6                	jne    f0105bcf <vprintfmt+0x11>
f0105bf9:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105bfd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105c04:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105c0b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105c12:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c17:	eb 1d                	jmp    f0105c36 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
f0105c19:	89 de                	mov    %ebx,%esi
			padc = '-';
f0105c1b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105c1f:	eb 15                	jmp    f0105c36 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
f0105c21:	89 de                	mov    %ebx,%esi
			padc = '0';
f0105c23:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105c27:	eb 0d                	jmp    f0105c36 <vprintfmt+0x78>
				width = precision, precision = -1;
f0105c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105c2c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105c2f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105c36:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105c39:	0f b6 0e             	movzbl (%esi),%ecx
f0105c3c:	0f b6 c1             	movzbl %cl,%eax
f0105c3f:	83 e9 23             	sub    $0x23,%ecx
f0105c42:	80 f9 55             	cmp    $0x55,%cl
f0105c45:	0f 87 2a 03 00 00    	ja     f0105f75 <vprintfmt+0x3b7>
f0105c4b:	0f b6 c9             	movzbl %cl,%ecx
f0105c4e:	ff 24 8d 60 8b 10 f0 	jmp    *-0xfef74a0(,%ecx,4)
f0105c55:	89 de                	mov    %ebx,%esi
f0105c57:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
f0105c5c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105c5f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105c63:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105c66:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105c69:	83 fb 09             	cmp    $0x9,%ebx
f0105c6c:	77 36                	ja     f0105ca4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
f0105c6e:	83 c6 01             	add    $0x1,%esi
			}
f0105c71:	eb e9                	jmp    f0105c5c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
f0105c73:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c76:	8d 48 04             	lea    0x4(%eax),%ecx
f0105c79:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105c7c:	8b 00                	mov    (%eax),%eax
f0105c7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105c81:	89 de                	mov    %ebx,%esi
			goto process_precision;
f0105c83:	eb 22                	jmp    f0105ca7 <vprintfmt+0xe9>
f0105c85:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105c88:	85 c9                	test   %ecx,%ecx
f0105c8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c8f:	0f 49 c1             	cmovns %ecx,%eax
f0105c92:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105c95:	89 de                	mov    %ebx,%esi
f0105c97:	eb 9d                	jmp    f0105c36 <vprintfmt+0x78>
f0105c99:	89 de                	mov    %ebx,%esi
			altflag = 1;
f0105c9b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105ca2:	eb 92                	jmp    f0105c36 <vprintfmt+0x78>
f0105ca4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
f0105ca7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105cab:	79 89                	jns    f0105c36 <vprintfmt+0x78>
f0105cad:	e9 77 ff ff ff       	jmp    f0105c29 <vprintfmt+0x6b>
			lflag++;
f0105cb2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
f0105cb5:	89 de                	mov    %ebx,%esi
			goto reswitch;
f0105cb7:	e9 7a ff ff ff       	jmp    f0105c36 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
f0105cbc:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cbf:	8d 50 04             	lea    0x4(%eax),%edx
f0105cc2:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cc5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cc9:	8b 00                	mov    (%eax),%eax
f0105ccb:	89 04 24             	mov    %eax,(%esp)
f0105cce:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105cd1:	e9 18 ff ff ff       	jmp    f0105bee <vprintfmt+0x30>
			err = va_arg(ap, int);
f0105cd6:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cd9:	8d 50 04             	lea    0x4(%eax),%edx
f0105cdc:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cdf:	8b 00                	mov    (%eax),%eax
f0105ce1:	99                   	cltd   
f0105ce2:	31 d0                	xor    %edx,%eax
f0105ce4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105ce6:	83 f8 0f             	cmp    $0xf,%eax
f0105ce9:	7f 0b                	jg     f0105cf6 <vprintfmt+0x138>
f0105ceb:	8b 14 85 c0 8c 10 f0 	mov    -0xfef7340(,%eax,4),%edx
f0105cf2:	85 d2                	test   %edx,%edx
f0105cf4:	75 20                	jne    f0105d16 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
f0105cf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105cfa:	c7 44 24 08 26 8a 10 	movl   $0xf0108a26,0x8(%esp)
f0105d01:	f0 
f0105d02:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d06:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d09:	89 04 24             	mov    %eax,(%esp)
f0105d0c:	e8 85 fe ff ff       	call   f0105b96 <printfmt>
f0105d11:	e9 d8 fe ff ff       	jmp    f0105bee <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
f0105d16:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105d1a:	c7 44 24 08 21 82 10 	movl   $0xf0108221,0x8(%esp)
f0105d21:	f0 
f0105d22:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d26:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d29:	89 04 24             	mov    %eax,(%esp)
f0105d2c:	e8 65 fe ff ff       	call   f0105b96 <printfmt>
f0105d31:	e9 b8 fe ff ff       	jmp    f0105bee <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
f0105d36:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105d39:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105d3c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
f0105d3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d42:	8d 50 04             	lea    0x4(%eax),%edx
f0105d45:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d48:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105d4a:	85 f6                	test   %esi,%esi
f0105d4c:	b8 1f 8a 10 f0       	mov    $0xf0108a1f,%eax
f0105d51:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0105d54:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105d58:	0f 84 97 00 00 00    	je     f0105df5 <vprintfmt+0x237>
f0105d5e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105d62:	0f 8e 9b 00 00 00    	jle    f0105e03 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105d68:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105d6c:	89 34 24             	mov    %esi,(%esp)
f0105d6f:	e8 a4 03 00 00       	call   f0106118 <strnlen>
f0105d74:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105d77:	29 c2                	sub    %eax,%edx
f0105d79:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0105d7c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105d80:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105d83:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0105d86:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d89:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105d8c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f0105d8e:	eb 0f                	jmp    f0105d9f <vprintfmt+0x1e1>
					putch(padc, putdat);
f0105d90:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d94:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105d97:	89 04 24             	mov    %eax,(%esp)
f0105d9a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105d9c:	83 eb 01             	sub    $0x1,%ebx
f0105d9f:	85 db                	test   %ebx,%ebx
f0105da1:	7f ed                	jg     f0105d90 <vprintfmt+0x1d2>
f0105da3:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105da6:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105da9:	85 d2                	test   %edx,%edx
f0105dab:	b8 00 00 00 00       	mov    $0x0,%eax
f0105db0:	0f 49 c2             	cmovns %edx,%eax
f0105db3:	29 c2                	sub    %eax,%edx
f0105db5:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105db8:	89 d7                	mov    %edx,%edi
f0105dba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105dbd:	eb 50                	jmp    f0105e0f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
f0105dbf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105dc3:	74 1e                	je     f0105de3 <vprintfmt+0x225>
f0105dc5:	0f be d2             	movsbl %dl,%edx
f0105dc8:	83 ea 20             	sub    $0x20,%edx
f0105dcb:	83 fa 5e             	cmp    $0x5e,%edx
f0105dce:	76 13                	jbe    f0105de3 <vprintfmt+0x225>
					putch('?', putdat);
f0105dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dd7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105dde:	ff 55 08             	call   *0x8(%ebp)
f0105de1:	eb 0d                	jmp    f0105df0 <vprintfmt+0x232>
					putch(ch, putdat);
f0105de3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105de6:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105dea:	89 04 24             	mov    %eax,(%esp)
f0105ded:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105df0:	83 ef 01             	sub    $0x1,%edi
f0105df3:	eb 1a                	jmp    f0105e0f <vprintfmt+0x251>
f0105df5:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105df8:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105dfb:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105dfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105e01:	eb 0c                	jmp    f0105e0f <vprintfmt+0x251>
f0105e03:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105e06:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105e09:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105e0c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105e0f:	83 c6 01             	add    $0x1,%esi
f0105e12:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0105e16:	0f be c2             	movsbl %dl,%eax
f0105e19:	85 c0                	test   %eax,%eax
f0105e1b:	74 27                	je     f0105e44 <vprintfmt+0x286>
f0105e1d:	85 db                	test   %ebx,%ebx
f0105e1f:	78 9e                	js     f0105dbf <vprintfmt+0x201>
f0105e21:	83 eb 01             	sub    $0x1,%ebx
f0105e24:	79 99                	jns    f0105dbf <vprintfmt+0x201>
f0105e26:	89 f8                	mov    %edi,%eax
f0105e28:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105e2b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e2e:	89 c3                	mov    %eax,%ebx
f0105e30:	eb 1a                	jmp    f0105e4c <vprintfmt+0x28e>
				putch(' ', putdat);
f0105e32:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e36:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105e3d:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105e3f:	83 eb 01             	sub    $0x1,%ebx
f0105e42:	eb 08                	jmp    f0105e4c <vprintfmt+0x28e>
f0105e44:	89 fb                	mov    %edi,%ebx
f0105e46:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e49:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105e4c:	85 db                	test   %ebx,%ebx
f0105e4e:	7f e2                	jg     f0105e32 <vprintfmt+0x274>
f0105e50:	89 75 08             	mov    %esi,0x8(%ebp)
f0105e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105e56:	e9 93 fd ff ff       	jmp    f0105bee <vprintfmt+0x30>
	if (lflag >= 2)
f0105e5b:	83 fa 01             	cmp    $0x1,%edx
f0105e5e:	7e 16                	jle    f0105e76 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
f0105e60:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e63:	8d 50 08             	lea    0x8(%eax),%edx
f0105e66:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e69:	8b 50 04             	mov    0x4(%eax),%edx
f0105e6c:	8b 00                	mov    (%eax),%eax
f0105e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105e71:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105e74:	eb 32                	jmp    f0105ea8 <vprintfmt+0x2ea>
	else if (lflag)
f0105e76:	85 d2                	test   %edx,%edx
f0105e78:	74 18                	je     f0105e92 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
f0105e7a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e7d:	8d 50 04             	lea    0x4(%eax),%edx
f0105e80:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e83:	8b 30                	mov    (%eax),%esi
f0105e85:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105e88:	89 f0                	mov    %esi,%eax
f0105e8a:	c1 f8 1f             	sar    $0x1f,%eax
f0105e8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e90:	eb 16                	jmp    f0105ea8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
f0105e92:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e95:	8d 50 04             	lea    0x4(%eax),%edx
f0105e98:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e9b:	8b 30                	mov    (%eax),%esi
f0105e9d:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105ea0:	89 f0                	mov    %esi,%eax
f0105ea2:	c1 f8 1f             	sar    $0x1f,%eax
f0105ea5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
f0105ea8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105eab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
f0105eae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
f0105eb3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105eb7:	0f 89 80 00 00 00    	jns    f0105f3d <vprintfmt+0x37f>
				putch('-', putdat);
f0105ebd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ec1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105ec8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ece:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105ed1:	f7 d8                	neg    %eax
f0105ed3:	83 d2 00             	adc    $0x0,%edx
f0105ed6:	f7 da                	neg    %edx
			base = 10;
f0105ed8:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105edd:	eb 5e                	jmp    f0105f3d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
f0105edf:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ee2:	e8 58 fc ff ff       	call   f0105b3f <getuint>
			base = 10;
f0105ee7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105eec:	eb 4f                	jmp    f0105f3d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
f0105eee:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ef1:	e8 49 fc ff ff       	call   f0105b3f <getuint>
            base = 8;
f0105ef6:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
f0105efb:	eb 40                	jmp    f0105f3d <vprintfmt+0x37f>
			putch('0', putdat);
f0105efd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f01:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105f08:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105f0b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f0f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105f16:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
f0105f19:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f1c:	8d 50 04             	lea    0x4(%eax),%edx
f0105f1f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
f0105f22:	8b 00                	mov    (%eax),%eax
f0105f24:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
f0105f29:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105f2e:	eb 0d                	jmp    f0105f3d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
f0105f30:	8d 45 14             	lea    0x14(%ebp),%eax
f0105f33:	e8 07 fc ff ff       	call   f0105b3f <getuint>
			base = 16;
f0105f38:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
f0105f3d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0105f41:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105f45:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105f48:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105f4c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105f50:	89 04 24             	mov    %eax,(%esp)
f0105f53:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f57:	89 fa                	mov    %edi,%edx
f0105f59:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f5c:	e8 ef fa ff ff       	call   f0105a50 <printnum>
			break;
f0105f61:	e9 88 fc ff ff       	jmp    f0105bee <vprintfmt+0x30>
			putch(ch, putdat);
f0105f66:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f6a:	89 04 24             	mov    %eax,(%esp)
f0105f6d:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105f70:	e9 79 fc ff ff       	jmp    f0105bee <vprintfmt+0x30>
			putch('%', putdat);
f0105f75:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f79:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105f80:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105f83:	89 f3                	mov    %esi,%ebx
f0105f85:	eb 03                	jmp    f0105f8a <vprintfmt+0x3cc>
f0105f87:	83 eb 01             	sub    $0x1,%ebx
f0105f8a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105f8e:	75 f7                	jne    f0105f87 <vprintfmt+0x3c9>
f0105f90:	e9 59 fc ff ff       	jmp    f0105bee <vprintfmt+0x30>
}
f0105f95:	83 c4 3c             	add    $0x3c,%esp
f0105f98:	5b                   	pop    %ebx
f0105f99:	5e                   	pop    %esi
f0105f9a:	5f                   	pop    %edi
f0105f9b:	5d                   	pop    %ebp
f0105f9c:	c3                   	ret    

f0105f9d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105f9d:	55                   	push   %ebp
f0105f9e:	89 e5                	mov    %esp,%ebp
f0105fa0:	83 ec 28             	sub    $0x28,%esp
f0105fa3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105fa9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105fac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105fb0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105fb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105fba:	85 c0                	test   %eax,%eax
f0105fbc:	74 30                	je     f0105fee <vsnprintf+0x51>
f0105fbe:	85 d2                	test   %edx,%edx
f0105fc0:	7e 2c                	jle    f0105fee <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105fc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fc5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fc9:	8b 45 10             	mov    0x10(%ebp),%eax
f0105fcc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105fd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fd7:	c7 04 24 79 5b 10 f0 	movl   $0xf0105b79,(%esp)
f0105fde:	e8 db fb ff ff       	call   f0105bbe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105fe6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105fec:	eb 05                	jmp    f0105ff3 <vsnprintf+0x56>
		return -E_INVAL;
f0105fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0105ff3:	c9                   	leave  
f0105ff4:	c3                   	ret    

f0105ff5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105ff5:	55                   	push   %ebp
f0105ff6:	89 e5                	mov    %esp,%ebp
f0105ff8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105ffb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105ffe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106002:	8b 45 10             	mov    0x10(%ebp),%eax
f0106005:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106009:	8b 45 0c             	mov    0xc(%ebp),%eax
f010600c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106010:	8b 45 08             	mov    0x8(%ebp),%eax
f0106013:	89 04 24             	mov    %eax,(%esp)
f0106016:	e8 82 ff ff ff       	call   f0105f9d <vsnprintf>
	va_end(ap);

	return rc;
}
f010601b:	c9                   	leave  
f010601c:	c3                   	ret    
f010601d:	66 90                	xchg   %ax,%ax
f010601f:	90                   	nop

f0106020 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106020:	55                   	push   %ebp
f0106021:	89 e5                	mov    %esp,%ebp
f0106023:	57                   	push   %edi
f0106024:	56                   	push   %esi
f0106025:	53                   	push   %ebx
f0106026:	83 ec 1c             	sub    $0x1c,%esp
f0106029:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f010602c:	85 c0                	test   %eax,%eax
f010602e:	74 10                	je     f0106040 <readline+0x20>
		cprintf("%s", prompt);
f0106030:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106034:	c7 04 24 21 82 10 f0 	movl   $0xf0108221,(%esp)
f010603b:	e8 9b e2 ff ff       	call   f01042db <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0106040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106047:	e8 69 a7 ff ff       	call   f01007b5 <iscons>
f010604c:	89 c7                	mov    %eax,%edi
	i = 0;
f010604e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0106053:	e8 4c a7 ff ff       	call   f01007a4 <getchar>
f0106058:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010605a:	85 c0                	test   %eax,%eax
f010605c:	79 25                	jns    f0106083 <readline+0x63>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010605e:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0106063:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0106066:	0f 84 89 00 00 00    	je     f01060f5 <readline+0xd5>
				cprintf("read error: %e\n", c);
f010606c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106070:	c7 04 24 1f 8d 10 f0 	movl   $0xf0108d1f,(%esp)
f0106077:	e8 5f e2 ff ff       	call   f01042db <cprintf>
			return NULL;
f010607c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106081:	eb 72                	jmp    f01060f5 <readline+0xd5>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106083:	83 f8 7f             	cmp    $0x7f,%eax
f0106086:	74 05                	je     f010608d <readline+0x6d>
f0106088:	83 f8 08             	cmp    $0x8,%eax
f010608b:	75 1a                	jne    f01060a7 <readline+0x87>
f010608d:	85 f6                	test   %esi,%esi
f010608f:	90                   	nop
f0106090:	7e 15                	jle    f01060a7 <readline+0x87>
			if (echoing)
f0106092:	85 ff                	test   %edi,%edi
f0106094:	74 0c                	je     f01060a2 <readline+0x82>
				cputchar('\b');
f0106096:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010609d:	e8 f2 a6 ff ff       	call   f0100794 <cputchar>
			i--;
f01060a2:	83 ee 01             	sub    $0x1,%esi
f01060a5:	eb ac                	jmp    f0106053 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01060a7:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01060ad:	7f 1c                	jg     f01060cb <readline+0xab>
f01060af:	83 fb 1f             	cmp    $0x1f,%ebx
f01060b2:	7e 17                	jle    f01060cb <readline+0xab>
			if (echoing)
f01060b4:	85 ff                	test   %edi,%edi
f01060b6:	74 08                	je     f01060c0 <readline+0xa0>
				cputchar(c);
f01060b8:	89 1c 24             	mov    %ebx,(%esp)
f01060bb:	e8 d4 a6 ff ff       	call   f0100794 <cputchar>
			buf[i++] = c;
f01060c0:	88 9e 80 4a 21 f0    	mov    %bl,-0xfdeb580(%esi)
f01060c6:	8d 76 01             	lea    0x1(%esi),%esi
f01060c9:	eb 88                	jmp    f0106053 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01060cb:	83 fb 0d             	cmp    $0xd,%ebx
f01060ce:	74 09                	je     f01060d9 <readline+0xb9>
f01060d0:	83 fb 0a             	cmp    $0xa,%ebx
f01060d3:	0f 85 7a ff ff ff    	jne    f0106053 <readline+0x33>
			if (echoing)
f01060d9:	85 ff                	test   %edi,%edi
f01060db:	74 0c                	je     f01060e9 <readline+0xc9>
				cputchar('\n');
f01060dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01060e4:	e8 ab a6 ff ff       	call   f0100794 <cputchar>
			buf[i] = 0;
f01060e9:	c6 86 80 4a 21 f0 00 	movb   $0x0,-0xfdeb580(%esi)
			return buf;
f01060f0:	b8 80 4a 21 f0       	mov    $0xf0214a80,%eax
		}
	}
}
f01060f5:	83 c4 1c             	add    $0x1c,%esp
f01060f8:	5b                   	pop    %ebx
f01060f9:	5e                   	pop    %esi
f01060fa:	5f                   	pop    %edi
f01060fb:	5d                   	pop    %ebp
f01060fc:	c3                   	ret    
f01060fd:	66 90                	xchg   %ax,%ax
f01060ff:	90                   	nop

f0106100 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0106100:	55                   	push   %ebp
f0106101:	89 e5                	mov    %esp,%ebp
f0106103:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106106:	b8 00 00 00 00       	mov    $0x0,%eax
f010610b:	eb 03                	jmp    f0106110 <strlen+0x10>
		n++;
f010610d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0106110:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0106114:	75 f7                	jne    f010610d <strlen+0xd>
	return n;
}
f0106116:	5d                   	pop    %ebp
f0106117:	c3                   	ret    

f0106118 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0106118:	55                   	push   %ebp
f0106119:	89 e5                	mov    %esp,%ebp
f010611b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010611e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106121:	b8 00 00 00 00       	mov    $0x0,%eax
f0106126:	eb 03                	jmp    f010612b <strnlen+0x13>
		n++;
f0106128:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010612b:	39 d0                	cmp    %edx,%eax
f010612d:	74 06                	je     f0106135 <strnlen+0x1d>
f010612f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0106133:	75 f3                	jne    f0106128 <strnlen+0x10>
	return n;
}
f0106135:	5d                   	pop    %ebp
f0106136:	c3                   	ret    

f0106137 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0106137:	55                   	push   %ebp
f0106138:	89 e5                	mov    %esp,%ebp
f010613a:	53                   	push   %ebx
f010613b:	8b 45 08             	mov    0x8(%ebp),%eax
f010613e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106141:	89 c2                	mov    %eax,%edx
f0106143:	83 c2 01             	add    $0x1,%edx
f0106146:	83 c1 01             	add    $0x1,%ecx
f0106149:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010614d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0106150:	84 db                	test   %bl,%bl
f0106152:	75 ef                	jne    f0106143 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0106154:	5b                   	pop    %ebx
f0106155:	5d                   	pop    %ebp
f0106156:	c3                   	ret    

f0106157 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106157:	55                   	push   %ebp
f0106158:	89 e5                	mov    %esp,%ebp
f010615a:	53                   	push   %ebx
f010615b:	83 ec 08             	sub    $0x8,%esp
f010615e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106161:	89 1c 24             	mov    %ebx,(%esp)
f0106164:	e8 97 ff ff ff       	call   f0106100 <strlen>
	strcpy(dst + len, src);
f0106169:	8b 55 0c             	mov    0xc(%ebp),%edx
f010616c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106170:	01 d8                	add    %ebx,%eax
f0106172:	89 04 24             	mov    %eax,(%esp)
f0106175:	e8 bd ff ff ff       	call   f0106137 <strcpy>
	return dst;
}
f010617a:	89 d8                	mov    %ebx,%eax
f010617c:	83 c4 08             	add    $0x8,%esp
f010617f:	5b                   	pop    %ebx
f0106180:	5d                   	pop    %ebp
f0106181:	c3                   	ret    

f0106182 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106182:	55                   	push   %ebp
f0106183:	89 e5                	mov    %esp,%ebp
f0106185:	56                   	push   %esi
f0106186:	53                   	push   %ebx
f0106187:	8b 75 08             	mov    0x8(%ebp),%esi
f010618a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010618d:	89 f3                	mov    %esi,%ebx
f010618f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106192:	89 f2                	mov    %esi,%edx
f0106194:	eb 0f                	jmp    f01061a5 <strncpy+0x23>
		*dst++ = *src;
f0106196:	83 c2 01             	add    $0x1,%edx
f0106199:	0f b6 01             	movzbl (%ecx),%eax
f010619c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010619f:	80 39 01             	cmpb   $0x1,(%ecx)
f01061a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01061a5:	39 da                	cmp    %ebx,%edx
f01061a7:	75 ed                	jne    f0106196 <strncpy+0x14>
	}
	return ret;
}
f01061a9:	89 f0                	mov    %esi,%eax
f01061ab:	5b                   	pop    %ebx
f01061ac:	5e                   	pop    %esi
f01061ad:	5d                   	pop    %ebp
f01061ae:	c3                   	ret    

f01061af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01061af:	55                   	push   %ebp
f01061b0:	89 e5                	mov    %esp,%ebp
f01061b2:	56                   	push   %esi
f01061b3:	53                   	push   %ebx
f01061b4:	8b 75 08             	mov    0x8(%ebp),%esi
f01061b7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01061ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01061bd:	89 f0                	mov    %esi,%eax
f01061bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01061c3:	85 c9                	test   %ecx,%ecx
f01061c5:	75 0b                	jne    f01061d2 <strlcpy+0x23>
f01061c7:	eb 1d                	jmp    f01061e6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01061c9:	83 c0 01             	add    $0x1,%eax
f01061cc:	83 c2 01             	add    $0x1,%edx
f01061cf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01061d2:	39 d8                	cmp    %ebx,%eax
f01061d4:	74 0b                	je     f01061e1 <strlcpy+0x32>
f01061d6:	0f b6 0a             	movzbl (%edx),%ecx
f01061d9:	84 c9                	test   %cl,%cl
f01061db:	75 ec                	jne    f01061c9 <strlcpy+0x1a>
f01061dd:	89 c2                	mov    %eax,%edx
f01061df:	eb 02                	jmp    f01061e3 <strlcpy+0x34>
f01061e1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
f01061e3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01061e6:	29 f0                	sub    %esi,%eax
}
f01061e8:	5b                   	pop    %ebx
f01061e9:	5e                   	pop    %esi
f01061ea:	5d                   	pop    %ebp
f01061eb:	c3                   	ret    

f01061ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01061ec:	55                   	push   %ebp
f01061ed:	89 e5                	mov    %esp,%ebp
f01061ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01061f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01061f5:	eb 06                	jmp    f01061fd <strcmp+0x11>
		p++, q++;
f01061f7:	83 c1 01             	add    $0x1,%ecx
f01061fa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01061fd:	0f b6 01             	movzbl (%ecx),%eax
f0106200:	84 c0                	test   %al,%al
f0106202:	74 04                	je     f0106208 <strcmp+0x1c>
f0106204:	3a 02                	cmp    (%edx),%al
f0106206:	74 ef                	je     f01061f7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106208:	0f b6 c0             	movzbl %al,%eax
f010620b:	0f b6 12             	movzbl (%edx),%edx
f010620e:	29 d0                	sub    %edx,%eax
}
f0106210:	5d                   	pop    %ebp
f0106211:	c3                   	ret    

f0106212 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106212:	55                   	push   %ebp
f0106213:	89 e5                	mov    %esp,%ebp
f0106215:	53                   	push   %ebx
f0106216:	8b 45 08             	mov    0x8(%ebp),%eax
f0106219:	8b 55 0c             	mov    0xc(%ebp),%edx
f010621c:	89 c3                	mov    %eax,%ebx
f010621e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0106221:	eb 06                	jmp    f0106229 <strncmp+0x17>
		n--, p++, q++;
f0106223:	83 c0 01             	add    $0x1,%eax
f0106226:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0106229:	39 d8                	cmp    %ebx,%eax
f010622b:	74 15                	je     f0106242 <strncmp+0x30>
f010622d:	0f b6 08             	movzbl (%eax),%ecx
f0106230:	84 c9                	test   %cl,%cl
f0106232:	74 04                	je     f0106238 <strncmp+0x26>
f0106234:	3a 0a                	cmp    (%edx),%cl
f0106236:	74 eb                	je     f0106223 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106238:	0f b6 00             	movzbl (%eax),%eax
f010623b:	0f b6 12             	movzbl (%edx),%edx
f010623e:	29 d0                	sub    %edx,%eax
f0106240:	eb 05                	jmp    f0106247 <strncmp+0x35>
		return 0;
f0106242:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106247:	5b                   	pop    %ebx
f0106248:	5d                   	pop    %ebp
f0106249:	c3                   	ret    

f010624a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010624a:	55                   	push   %ebp
f010624b:	89 e5                	mov    %esp,%ebp
f010624d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106250:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106254:	eb 07                	jmp    f010625d <strchr+0x13>
		if (*s == c)
f0106256:	38 ca                	cmp    %cl,%dl
f0106258:	74 0f                	je     f0106269 <strchr+0x1f>
	for (; *s; s++)
f010625a:	83 c0 01             	add    $0x1,%eax
f010625d:	0f b6 10             	movzbl (%eax),%edx
f0106260:	84 d2                	test   %dl,%dl
f0106262:	75 f2                	jne    f0106256 <strchr+0xc>
			return (char *) s;
	return 0;
f0106264:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106269:	5d                   	pop    %ebp
f010626a:	c3                   	ret    

f010626b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010626b:	55                   	push   %ebp
f010626c:	89 e5                	mov    %esp,%ebp
f010626e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106271:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106275:	eb 07                	jmp    f010627e <strfind+0x13>
		if (*s == c)
f0106277:	38 ca                	cmp    %cl,%dl
f0106279:	74 0a                	je     f0106285 <strfind+0x1a>
	for (; *s; s++)
f010627b:	83 c0 01             	add    $0x1,%eax
f010627e:	0f b6 10             	movzbl (%eax),%edx
f0106281:	84 d2                	test   %dl,%dl
f0106283:	75 f2                	jne    f0106277 <strfind+0xc>
			break;
	return (char *) s;
}
f0106285:	5d                   	pop    %ebp
f0106286:	c3                   	ret    

f0106287 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106287:	55                   	push   %ebp
f0106288:	89 e5                	mov    %esp,%ebp
f010628a:	57                   	push   %edi
f010628b:	56                   	push   %esi
f010628c:	53                   	push   %ebx
f010628d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106290:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106293:	85 c9                	test   %ecx,%ecx
f0106295:	74 36                	je     f01062cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106297:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010629d:	75 28                	jne    f01062c7 <memset+0x40>
f010629f:	f6 c1 03             	test   $0x3,%cl
f01062a2:	75 23                	jne    f01062c7 <memset+0x40>
		c &= 0xFF;
f01062a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01062a8:	89 d3                	mov    %edx,%ebx
f01062aa:	c1 e3 08             	shl    $0x8,%ebx
f01062ad:	89 d6                	mov    %edx,%esi
f01062af:	c1 e6 18             	shl    $0x18,%esi
f01062b2:	89 d0                	mov    %edx,%eax
f01062b4:	c1 e0 10             	shl    $0x10,%eax
f01062b7:	09 f0                	or     %esi,%eax
f01062b9:	09 c2                	or     %eax,%edx
f01062bb:	89 d0                	mov    %edx,%eax
f01062bd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01062bf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01062c2:	fc                   	cld    
f01062c3:	f3 ab                	rep stos %eax,%es:(%edi)
f01062c5:	eb 06                	jmp    f01062cd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01062c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01062ca:	fc                   	cld    
f01062cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01062cd:	89 f8                	mov    %edi,%eax
f01062cf:	5b                   	pop    %ebx
f01062d0:	5e                   	pop    %esi
f01062d1:	5f                   	pop    %edi
f01062d2:	5d                   	pop    %ebp
f01062d3:	c3                   	ret    

f01062d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01062d4:	55                   	push   %ebp
f01062d5:	89 e5                	mov    %esp,%ebp
f01062d7:	57                   	push   %edi
f01062d8:	56                   	push   %esi
f01062d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01062dc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01062e2:	39 c6                	cmp    %eax,%esi
f01062e4:	73 35                	jae    f010631b <memmove+0x47>
f01062e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01062e9:	39 d0                	cmp    %edx,%eax
f01062eb:	73 2e                	jae    f010631b <memmove+0x47>
		s += n;
		d += n;
f01062ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01062f0:	89 d6                	mov    %edx,%esi
f01062f2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01062f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01062fa:	75 13                	jne    f010630f <memmove+0x3b>
f01062fc:	f6 c1 03             	test   $0x3,%cl
f01062ff:	75 0e                	jne    f010630f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106301:	83 ef 04             	sub    $0x4,%edi
f0106304:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106307:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010630a:	fd                   	std    
f010630b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010630d:	eb 09                	jmp    f0106318 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010630f:	83 ef 01             	sub    $0x1,%edi
f0106312:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0106315:	fd                   	std    
f0106316:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106318:	fc                   	cld    
f0106319:	eb 1d                	jmp    f0106338 <memmove+0x64>
f010631b:	89 f2                	mov    %esi,%edx
f010631d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010631f:	f6 c2 03             	test   $0x3,%dl
f0106322:	75 0f                	jne    f0106333 <memmove+0x5f>
f0106324:	f6 c1 03             	test   $0x3,%cl
f0106327:	75 0a                	jne    f0106333 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106329:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010632c:	89 c7                	mov    %eax,%edi
f010632e:	fc                   	cld    
f010632f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106331:	eb 05                	jmp    f0106338 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
f0106333:	89 c7                	mov    %eax,%edi
f0106335:	fc                   	cld    
f0106336:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106338:	5e                   	pop    %esi
f0106339:	5f                   	pop    %edi
f010633a:	5d                   	pop    %ebp
f010633b:	c3                   	ret    

f010633c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010633c:	55                   	push   %ebp
f010633d:	89 e5                	mov    %esp,%ebp
f010633f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106342:	8b 45 10             	mov    0x10(%ebp),%eax
f0106345:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106349:	8b 45 0c             	mov    0xc(%ebp),%eax
f010634c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106350:	8b 45 08             	mov    0x8(%ebp),%eax
f0106353:	89 04 24             	mov    %eax,(%esp)
f0106356:	e8 79 ff ff ff       	call   f01062d4 <memmove>
}
f010635b:	c9                   	leave  
f010635c:	c3                   	ret    

f010635d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010635d:	55                   	push   %ebp
f010635e:	89 e5                	mov    %esp,%ebp
f0106360:	56                   	push   %esi
f0106361:	53                   	push   %ebx
f0106362:	8b 55 08             	mov    0x8(%ebp),%edx
f0106365:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106368:	89 d6                	mov    %edx,%esi
f010636a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010636d:	eb 1a                	jmp    f0106389 <memcmp+0x2c>
		if (*s1 != *s2)
f010636f:	0f b6 02             	movzbl (%edx),%eax
f0106372:	0f b6 19             	movzbl (%ecx),%ebx
f0106375:	38 d8                	cmp    %bl,%al
f0106377:	74 0a                	je     f0106383 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0106379:	0f b6 c0             	movzbl %al,%eax
f010637c:	0f b6 db             	movzbl %bl,%ebx
f010637f:	29 d8                	sub    %ebx,%eax
f0106381:	eb 0f                	jmp    f0106392 <memcmp+0x35>
		s1++, s2++;
f0106383:	83 c2 01             	add    $0x1,%edx
f0106386:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
f0106389:	39 f2                	cmp    %esi,%edx
f010638b:	75 e2                	jne    f010636f <memcmp+0x12>
	}

	return 0;
f010638d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106392:	5b                   	pop    %ebx
f0106393:	5e                   	pop    %esi
f0106394:	5d                   	pop    %ebp
f0106395:	c3                   	ret    

f0106396 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106396:	55                   	push   %ebp
f0106397:	89 e5                	mov    %esp,%ebp
f0106399:	8b 45 08             	mov    0x8(%ebp),%eax
f010639c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010639f:	89 c2                	mov    %eax,%edx
f01063a1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01063a4:	eb 07                	jmp    f01063ad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01063a6:	38 08                	cmp    %cl,(%eax)
f01063a8:	74 07                	je     f01063b1 <memfind+0x1b>
	for (; s < ends; s++)
f01063aa:	83 c0 01             	add    $0x1,%eax
f01063ad:	39 d0                	cmp    %edx,%eax
f01063af:	72 f5                	jb     f01063a6 <memfind+0x10>
			break;
	return (void *) s;
}
f01063b1:	5d                   	pop    %ebp
f01063b2:	c3                   	ret    

f01063b3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01063b3:	55                   	push   %ebp
f01063b4:	89 e5                	mov    %esp,%ebp
f01063b6:	57                   	push   %edi
f01063b7:	56                   	push   %esi
f01063b8:	53                   	push   %ebx
f01063b9:	8b 55 08             	mov    0x8(%ebp),%edx
f01063bc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01063bf:	eb 03                	jmp    f01063c4 <strtol+0x11>
		s++;
f01063c1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f01063c4:	0f b6 0a             	movzbl (%edx),%ecx
f01063c7:	80 f9 09             	cmp    $0x9,%cl
f01063ca:	74 f5                	je     f01063c1 <strtol+0xe>
f01063cc:	80 f9 20             	cmp    $0x20,%cl
f01063cf:	74 f0                	je     f01063c1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01063d1:	80 f9 2b             	cmp    $0x2b,%cl
f01063d4:	75 0a                	jne    f01063e0 <strtol+0x2d>
		s++;
f01063d6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f01063d9:	bf 00 00 00 00       	mov    $0x0,%edi
f01063de:	eb 11                	jmp    f01063f1 <strtol+0x3e>
f01063e0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f01063e5:	80 f9 2d             	cmp    $0x2d,%cl
f01063e8:	75 07                	jne    f01063f1 <strtol+0x3e>
		s++, neg = 1;
f01063ea:	8d 52 01             	lea    0x1(%edx),%edx
f01063ed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01063f1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f01063f6:	75 15                	jne    f010640d <strtol+0x5a>
f01063f8:	80 3a 30             	cmpb   $0x30,(%edx)
f01063fb:	75 10                	jne    f010640d <strtol+0x5a>
f01063fd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106401:	75 0a                	jne    f010640d <strtol+0x5a>
		s += 2, base = 16;
f0106403:	83 c2 02             	add    $0x2,%edx
f0106406:	b8 10 00 00 00       	mov    $0x10,%eax
f010640b:	eb 10                	jmp    f010641d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010640d:	85 c0                	test   %eax,%eax
f010640f:	75 0c                	jne    f010641d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106411:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
f0106413:	80 3a 30             	cmpb   $0x30,(%edx)
f0106416:	75 05                	jne    f010641d <strtol+0x6a>
		s++, base = 8;
f0106418:	83 c2 01             	add    $0x1,%edx
f010641b:	b0 08                	mov    $0x8,%al
		base = 10;
f010641d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106422:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106425:	0f b6 0a             	movzbl (%edx),%ecx
f0106428:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010642b:	89 f0                	mov    %esi,%eax
f010642d:	3c 09                	cmp    $0x9,%al
f010642f:	77 08                	ja     f0106439 <strtol+0x86>
			dig = *s - '0';
f0106431:	0f be c9             	movsbl %cl,%ecx
f0106434:	83 e9 30             	sub    $0x30,%ecx
f0106437:	eb 20                	jmp    f0106459 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0106439:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010643c:	89 f0                	mov    %esi,%eax
f010643e:	3c 19                	cmp    $0x19,%al
f0106440:	77 08                	ja     f010644a <strtol+0x97>
			dig = *s - 'a' + 10;
f0106442:	0f be c9             	movsbl %cl,%ecx
f0106445:	83 e9 57             	sub    $0x57,%ecx
f0106448:	eb 0f                	jmp    f0106459 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010644a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010644d:	89 f0                	mov    %esi,%eax
f010644f:	3c 19                	cmp    $0x19,%al
f0106451:	77 16                	ja     f0106469 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0106453:	0f be c9             	movsbl %cl,%ecx
f0106456:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106459:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010645c:	7d 0f                	jge    f010646d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f010645e:	83 c2 01             	add    $0x1,%edx
f0106461:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0106465:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0106467:	eb bc                	jmp    f0106425 <strtol+0x72>
f0106469:	89 d8                	mov    %ebx,%eax
f010646b:	eb 02                	jmp    f010646f <strtol+0xbc>
f010646d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f010646f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106473:	74 05                	je     f010647a <strtol+0xc7>
		*endptr = (char *) s;
f0106475:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106478:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f010647a:	f7 d8                	neg    %eax
f010647c:	85 ff                	test   %edi,%edi
f010647e:	0f 44 c3             	cmove  %ebx,%eax
}
f0106481:	5b                   	pop    %ebx
f0106482:	5e                   	pop    %esi
f0106483:	5f                   	pop    %edi
f0106484:	5d                   	pop    %ebp
f0106485:	c3                   	ret    
f0106486:	66 90                	xchg   %ax,%ax

f0106488 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106488:	fa                   	cli    

	xorw    %ax, %ax
f0106489:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010648b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010648d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010648f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106491:	0f 01 16             	lgdtl  (%esi)
f0106494:	74 70                	je     f0106506 <mpentry_end+0x4>
	movl    %cr0, %eax
f0106496:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106499:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010649d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01064a0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01064a6:	08 00                	or     %al,(%eax)

f01064a8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01064a8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01064ac:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01064ae:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01064b0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01064b2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01064b6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01064b8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01064ba:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01064bf:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01064c2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01064c5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01064ca:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01064cd:	8b 25 84 4e 21 f0    	mov    0xf0214e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01064d3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01064d8:	b8 db 01 10 f0       	mov    $0xf01001db,%eax
	call    *%eax
f01064dd:	ff d0                	call   *%eax

f01064df <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01064df:	eb fe                	jmp    f01064df <spin>
f01064e1:	8d 76 00             	lea    0x0(%esi),%esi

f01064e4 <gdt>:
	...
f01064ec:	ff                   	(bad)  
f01064ed:	ff 00                	incl   (%eax)
f01064ef:	00 00                	add    %al,(%eax)
f01064f1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01064f8:	00                   	.byte 0x0
f01064f9:	92                   	xchg   %eax,%edx
f01064fa:	cf                   	iret   
	...

f01064fc <gdtdesc>:
f01064fc:	17                   	pop    %ss
f01064fd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106502 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106502:	90                   	nop
f0106503:	66 90                	xchg   %ax,%ax
f0106505:	66 90                	xchg   %ax,%ax
f0106507:	66 90                	xchg   %ax,%ax
f0106509:	66 90                	xchg   %ax,%ax
f010650b:	66 90                	xchg   %ax,%ax
f010650d:	66 90                	xchg   %ax,%ax
f010650f:	90                   	nop

f0106510 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106510:	55                   	push   %ebp
f0106511:	89 e5                	mov    %esp,%ebp
f0106513:	56                   	push   %esi
f0106514:	53                   	push   %ebx
f0106515:	83 ec 10             	sub    $0x10,%esp
	if (PGNUM(pa) >= npages)
f0106518:	8b 0d 88 4e 21 f0    	mov    0xf0214e88,%ecx
f010651e:	89 c3                	mov    %eax,%ebx
f0106520:	c1 eb 0c             	shr    $0xc,%ebx
f0106523:	39 cb                	cmp    %ecx,%ebx
f0106525:	72 20                	jb     f0106547 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106527:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010652b:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0106532:	f0 
f0106533:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010653a:	00 
f010653b:	c7 04 24 bd 8e 10 f0 	movl   $0xf0108ebd,(%esp)
f0106542:	e8 f9 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106547:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010654d:	01 d0                	add    %edx,%eax
	if (PGNUM(pa) >= npages)
f010654f:	89 c2                	mov    %eax,%edx
f0106551:	c1 ea 0c             	shr    $0xc,%edx
f0106554:	39 d1                	cmp    %edx,%ecx
f0106556:	77 20                	ja     f0106578 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106558:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010655c:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0106563:	f0 
f0106564:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010656b:	00 
f010656c:	c7 04 24 bd 8e 10 f0 	movl   $0xf0108ebd,(%esp)
f0106573:	e8 c8 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106578:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010657e:	eb 36                	jmp    f01065b6 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106580:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106587:	00 
f0106588:	c7 44 24 04 cd 8e 10 	movl   $0xf0108ecd,0x4(%esp)
f010658f:	f0 
f0106590:	89 1c 24             	mov    %ebx,(%esp)
f0106593:	e8 c5 fd ff ff       	call   f010635d <memcmp>
f0106598:	85 c0                	test   %eax,%eax
f010659a:	75 17                	jne    f01065b3 <mpsearch1+0xa3>
	for (i = 0; i < len; i++)
f010659c:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f01065a1:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01065a5:	01 c8                	add    %ecx,%eax
	for (i = 0; i < len; i++)
f01065a7:	83 c2 01             	add    $0x1,%edx
f01065aa:	83 fa 10             	cmp    $0x10,%edx
f01065ad:	75 f2                	jne    f01065a1 <mpsearch1+0x91>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01065af:	84 c0                	test   %al,%al
f01065b1:	74 0e                	je     f01065c1 <mpsearch1+0xb1>
	for (; mp < end; mp++)
f01065b3:	83 c3 10             	add    $0x10,%ebx
f01065b6:	39 f3                	cmp    %esi,%ebx
f01065b8:	72 c6                	jb     f0106580 <mpsearch1+0x70>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01065ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01065bf:	eb 02                	jmp    f01065c3 <mpsearch1+0xb3>
f01065c1:	89 d8                	mov    %ebx,%eax
}
f01065c3:	83 c4 10             	add    $0x10,%esp
f01065c6:	5b                   	pop    %ebx
f01065c7:	5e                   	pop    %esi
f01065c8:	5d                   	pop    %ebp
f01065c9:	c3                   	ret    

f01065ca <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01065ca:	55                   	push   %ebp
f01065cb:	89 e5                	mov    %esp,%ebp
f01065cd:	57                   	push   %edi
f01065ce:	56                   	push   %esi
f01065cf:	53                   	push   %ebx
f01065d0:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01065d3:	c7 05 c0 53 21 f0 20 	movl   $0xf0215020,0xf02153c0
f01065da:	50 21 f0 
	if (PGNUM(pa) >= npages)
f01065dd:	83 3d 88 4e 21 f0 00 	cmpl   $0x0,0xf0214e88
f01065e4:	75 24                	jne    f010660a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065e6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01065ed:	00 
f01065ee:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f01065f5:	f0 
f01065f6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01065fd:	00 
f01065fe:	c7 04 24 bd 8e 10 f0 	movl   $0xf0108ebd,(%esp)
f0106605:	e8 36 9a ff ff       	call   f0100040 <_panic>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010660a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106611:	85 c0                	test   %eax,%eax
f0106613:	74 16                	je     f010662b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106615:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106618:	ba 00 04 00 00       	mov    $0x400,%edx
f010661d:	e8 ee fe ff ff       	call   f0106510 <mpsearch1>
f0106622:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106625:	85 c0                	test   %eax,%eax
f0106627:	75 3c                	jne    f0106665 <mp_init+0x9b>
f0106629:	eb 20                	jmp    f010664b <mp_init+0x81>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010662b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106632:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106635:	2d 00 04 00 00       	sub    $0x400,%eax
f010663a:	ba 00 04 00 00       	mov    $0x400,%edx
f010663f:	e8 cc fe ff ff       	call   f0106510 <mpsearch1>
f0106644:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106647:	85 c0                	test   %eax,%eax
f0106649:	75 1a                	jne    f0106665 <mp_init+0x9b>
	return mpsearch1(0xF0000, 0x10000);
f010664b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106650:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106655:	e8 b6 fe ff ff       	call   f0106510 <mpsearch1>
f010665a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f010665d:	85 c0                	test   %eax,%eax
f010665f:	0f 84 54 02 00 00    	je     f01068b9 <mp_init+0x2ef>
	if (mp->physaddr == 0 || mp->type != 0) {
f0106665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106668:	8b 70 04             	mov    0x4(%eax),%esi
f010666b:	85 f6                	test   %esi,%esi
f010666d:	74 06                	je     f0106675 <mp_init+0xab>
f010666f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106673:	74 11                	je     f0106686 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106675:	c7 04 24 30 8d 10 f0 	movl   $0xf0108d30,(%esp)
f010667c:	e8 5a dc ff ff       	call   f01042db <cprintf>
f0106681:	e9 33 02 00 00       	jmp    f01068b9 <mp_init+0x2ef>
	if (PGNUM(pa) >= npages)
f0106686:	89 f0                	mov    %esi,%eax
f0106688:	c1 e8 0c             	shr    $0xc,%eax
f010668b:	3b 05 88 4e 21 f0    	cmp    0xf0214e88,%eax
f0106691:	72 20                	jb     f01066b3 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106693:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106697:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f010669e:	f0 
f010669f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01066a6:	00 
f01066a7:	c7 04 24 bd 8e 10 f0 	movl   $0xf0108ebd,(%esp)
f01066ae:	e8 8d 99 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01066b3:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f01066b9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01066c0:	00 
f01066c1:	c7 44 24 04 d2 8e 10 	movl   $0xf0108ed2,0x4(%esp)
f01066c8:	f0 
f01066c9:	89 1c 24             	mov    %ebx,(%esp)
f01066cc:	e8 8c fc ff ff       	call   f010635d <memcmp>
f01066d1:	85 c0                	test   %eax,%eax
f01066d3:	74 11                	je     f01066e6 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01066d5:	c7 04 24 60 8d 10 f0 	movl   $0xf0108d60,(%esp)
f01066dc:	e8 fa db ff ff       	call   f01042db <cprintf>
f01066e1:	e9 d3 01 00 00       	jmp    f01068b9 <mp_init+0x2ef>
	if (sum(conf, conf->length) != 0) {
f01066e6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01066ea:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01066ee:	0f b7 f8             	movzwl %ax,%edi
	sum = 0;
f01066f1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01066f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01066fb:	eb 0d                	jmp    f010670a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f01066fd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106704:	f0 
f0106705:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106707:	83 c0 01             	add    $0x1,%eax
f010670a:	39 c7                	cmp    %eax,%edi
f010670c:	7f ef                	jg     f01066fd <mp_init+0x133>
	if (sum(conf, conf->length) != 0) {
f010670e:	84 d2                	test   %dl,%dl
f0106710:	74 11                	je     f0106723 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106712:	c7 04 24 94 8d 10 f0 	movl   $0xf0108d94,(%esp)
f0106719:	e8 bd db ff ff       	call   f01042db <cprintf>
f010671e:	e9 96 01 00 00       	jmp    f01068b9 <mp_init+0x2ef>
	if (conf->version != 1 && conf->version != 4) {
f0106723:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106727:	3c 04                	cmp    $0x4,%al
f0106729:	74 1f                	je     f010674a <mp_init+0x180>
f010672b:	3c 01                	cmp    $0x1,%al
f010672d:	8d 76 00             	lea    0x0(%esi),%esi
f0106730:	74 18                	je     f010674a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106732:	0f b6 c0             	movzbl %al,%eax
f0106735:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106739:	c7 04 24 b8 8d 10 f0 	movl   $0xf0108db8,(%esp)
f0106740:	e8 96 db ff ff       	call   f01042db <cprintf>
f0106745:	e9 6f 01 00 00       	jmp    f01068b9 <mp_init+0x2ef>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010674a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f010674e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0106752:	01 df                	add    %ebx,%edi
	sum = 0;
f0106754:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106759:	b8 00 00 00 00       	mov    $0x0,%eax
f010675e:	eb 09                	jmp    f0106769 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0106760:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0106764:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106766:	83 c0 01             	add    $0x1,%eax
f0106769:	39 c6                	cmp    %eax,%esi
f010676b:	7f f3                	jg     f0106760 <mp_init+0x196>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010676d:	02 53 2a             	add    0x2a(%ebx),%dl
f0106770:	84 d2                	test   %dl,%dl
f0106772:	74 11                	je     f0106785 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106774:	c7 04 24 d8 8d 10 f0 	movl   $0xf0108dd8,(%esp)
f010677b:	e8 5b db ff ff       	call   f01042db <cprintf>
f0106780:	e9 34 01 00 00       	jmp    f01068b9 <mp_init+0x2ef>
	if ((conf = mpconfig(&mp)) == 0)
f0106785:	85 db                	test   %ebx,%ebx
f0106787:	0f 84 2c 01 00 00    	je     f01068b9 <mp_init+0x2ef>
		return;
	ismp = 1;
f010678d:	c7 05 00 50 21 f0 01 	movl   $0x1,0xf0215000
f0106794:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106797:	8b 43 24             	mov    0x24(%ebx),%eax
f010679a:	a3 00 60 25 f0       	mov    %eax,0xf0256000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010679f:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01067a2:	be 00 00 00 00       	mov    $0x0,%esi
f01067a7:	e9 86 00 00 00       	jmp    f0106832 <mp_init+0x268>
		switch (*p) {
f01067ac:	0f b6 07             	movzbl (%edi),%eax
f01067af:	84 c0                	test   %al,%al
f01067b1:	74 06                	je     f01067b9 <mp_init+0x1ef>
f01067b3:	3c 04                	cmp    $0x4,%al
f01067b5:	77 57                	ja     f010680e <mp_init+0x244>
f01067b7:	eb 50                	jmp    f0106809 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01067b9:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01067bd:	8d 76 00             	lea    0x0(%esi),%esi
f01067c0:	74 11                	je     f01067d3 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f01067c2:	6b 05 c4 53 21 f0 74 	imul   $0x74,0xf02153c4,%eax
f01067c9:	05 20 50 21 f0       	add    $0xf0215020,%eax
f01067ce:	a3 c0 53 21 f0       	mov    %eax,0xf02153c0
			if (ncpu < NCPU) {
f01067d3:	a1 c4 53 21 f0       	mov    0xf02153c4,%eax
f01067d8:	83 f8 07             	cmp    $0x7,%eax
f01067db:	7f 13                	jg     f01067f0 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f01067dd:	6b d0 74             	imul   $0x74,%eax,%edx
f01067e0:	88 82 20 50 21 f0    	mov    %al,-0xfdeafe0(%edx)
				ncpu++;
f01067e6:	83 c0 01             	add    $0x1,%eax
f01067e9:	a3 c4 53 21 f0       	mov    %eax,0xf02153c4
f01067ee:	eb 14                	jmp    f0106804 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01067f0:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01067f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067f8:	c7 04 24 08 8e 10 f0 	movl   $0xf0108e08,(%esp)
f01067ff:	e8 d7 da ff ff       	call   f01042db <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106804:	83 c7 14             	add    $0x14,%edi
			continue;
f0106807:	eb 26                	jmp    f010682f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106809:	83 c7 08             	add    $0x8,%edi
			continue;
f010680c:	eb 21                	jmp    f010682f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010680e:	0f b6 c0             	movzbl %al,%eax
f0106811:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106815:	c7 04 24 30 8e 10 f0 	movl   $0xf0108e30,(%esp)
f010681c:	e8 ba da ff ff       	call   f01042db <cprintf>
			ismp = 0;
f0106821:	c7 05 00 50 21 f0 00 	movl   $0x0,0xf0215000
f0106828:	00 00 00 
			i = conf->entry;
f010682b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010682f:	83 c6 01             	add    $0x1,%esi
f0106832:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106836:	39 c6                	cmp    %eax,%esi
f0106838:	0f 82 6e ff ff ff    	jb     f01067ac <mp_init+0x1e2>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010683e:	a1 c0 53 21 f0       	mov    0xf02153c0,%eax
f0106843:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010684a:	83 3d 00 50 21 f0 00 	cmpl   $0x0,0xf0215000
f0106851:	75 22                	jne    f0106875 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106853:	c7 05 c4 53 21 f0 01 	movl   $0x1,0xf02153c4
f010685a:	00 00 00 
		lapicaddr = 0;
f010685d:	c7 05 00 60 25 f0 00 	movl   $0x0,0xf0256000
f0106864:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106867:	c7 04 24 50 8e 10 f0 	movl   $0xf0108e50,(%esp)
f010686e:	e8 68 da ff ff       	call   f01042db <cprintf>
		return;
f0106873:	eb 44                	jmp    f01068b9 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106875:	8b 15 c4 53 21 f0    	mov    0xf02153c4,%edx
f010687b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010687f:	0f b6 00             	movzbl (%eax),%eax
f0106882:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106886:	c7 04 24 d7 8e 10 f0 	movl   $0xf0108ed7,(%esp)
f010688d:	e8 49 da ff ff       	call   f01042db <cprintf>

	if (mp->imcrp) {
f0106892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106895:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106899:	74 1e                	je     f01068b9 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010689b:	c7 04 24 7c 8e 10 f0 	movl   $0xf0108e7c,(%esp)
f01068a2:	e8 34 da ff ff       	call   f01042db <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01068a7:	ba 22 00 00 00       	mov    $0x22,%edx
f01068ac:	b8 70 00 00 00       	mov    $0x70,%eax
f01068b1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01068b2:	b2 23                	mov    $0x23,%dl
f01068b4:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01068b5:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01068b8:	ee                   	out    %al,(%dx)
	}
}
f01068b9:	83 c4 2c             	add    $0x2c,%esp
f01068bc:	5b                   	pop    %ebx
f01068bd:	5e                   	pop    %esi
f01068be:	5f                   	pop    %edi
f01068bf:	5d                   	pop    %ebp
f01068c0:	c3                   	ret    

f01068c1 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01068c1:	55                   	push   %ebp
f01068c2:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01068c4:	8b 0d 04 60 25 f0    	mov    0xf0256004,%ecx
f01068ca:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01068cd:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01068cf:	a1 04 60 25 f0       	mov    0xf0256004,%eax
f01068d4:	8b 40 20             	mov    0x20(%eax),%eax
}
f01068d7:	5d                   	pop    %ebp
f01068d8:	c3                   	ret    

f01068d9 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01068d9:	55                   	push   %ebp
f01068da:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01068dc:	a1 04 60 25 f0       	mov    0xf0256004,%eax
f01068e1:	85 c0                	test   %eax,%eax
f01068e3:	74 08                	je     f01068ed <cpunum+0x14>
		return lapic[ID] >> 24;
f01068e5:	8b 40 20             	mov    0x20(%eax),%eax
f01068e8:	c1 e8 18             	shr    $0x18,%eax
f01068eb:	eb 05                	jmp    f01068f2 <cpunum+0x19>
	return 0;
f01068ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01068f2:	5d                   	pop    %ebp
f01068f3:	c3                   	ret    

f01068f4 <lapic_init>:
	if (!lapicaddr)
f01068f4:	a1 00 60 25 f0       	mov    0xf0256000,%eax
f01068f9:	85 c0                	test   %eax,%eax
f01068fb:	0f 84 23 01 00 00    	je     f0106a24 <lapic_init+0x130>
{
f0106901:	55                   	push   %ebp
f0106902:	89 e5                	mov    %esp,%ebp
f0106904:	83 ec 18             	sub    $0x18,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106907:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010690e:	00 
f010690f:	89 04 24             	mov    %eax,(%esp)
f0106912:	e8 3e af ff ff       	call   f0101855 <mmio_map_region>
f0106917:	a3 04 60 25 f0       	mov    %eax,0xf0256004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010691c:	ba 27 01 00 00       	mov    $0x127,%edx
f0106921:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106926:	e8 96 ff ff ff       	call   f01068c1 <lapicw>
	lapicw(TDCR, X1);
f010692b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106930:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106935:	e8 87 ff ff ff       	call   f01068c1 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010693a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010693f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106944:	e8 78 ff ff ff       	call   f01068c1 <lapicw>
	lapicw(TICR, 10000000); 
f0106949:	ba 80 96 98 00       	mov    $0x989680,%edx
f010694e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106953:	e8 69 ff ff ff       	call   f01068c1 <lapicw>
	if (thiscpu != bootcpu)
f0106958:	e8 7c ff ff ff       	call   f01068d9 <cpunum>
f010695d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106960:	05 20 50 21 f0       	add    $0xf0215020,%eax
f0106965:	39 05 c0 53 21 f0    	cmp    %eax,0xf02153c0
f010696b:	74 0f                	je     f010697c <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f010696d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106972:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106977:	e8 45 ff ff ff       	call   f01068c1 <lapicw>
	lapicw(LINT1, MASKED);
f010697c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106981:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106986:	e8 36 ff ff ff       	call   f01068c1 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010698b:	a1 04 60 25 f0       	mov    0xf0256004,%eax
f0106990:	8b 40 30             	mov    0x30(%eax),%eax
f0106993:	c1 e8 10             	shr    $0x10,%eax
f0106996:	3c 03                	cmp    $0x3,%al
f0106998:	76 0f                	jbe    f01069a9 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f010699a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010699f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01069a4:	e8 18 ff ff ff       	call   f01068c1 <lapicw>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01069a9:	ba 33 00 00 00       	mov    $0x33,%edx
f01069ae:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01069b3:	e8 09 ff ff ff       	call   f01068c1 <lapicw>
	lapicw(ESR, 0);
f01069b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01069bd:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01069c2:	e8 fa fe ff ff       	call   f01068c1 <lapicw>
	lapicw(ESR, 0);
f01069c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01069cc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01069d1:	e8 eb fe ff ff       	call   f01068c1 <lapicw>
	lapicw(EOI, 0);
f01069d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01069db:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01069e0:	e8 dc fe ff ff       	call   f01068c1 <lapicw>
	lapicw(ICRHI, 0);
f01069e5:	ba 00 00 00 00       	mov    $0x0,%edx
f01069ea:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01069ef:	e8 cd fe ff ff       	call   f01068c1 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01069f4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01069f9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069fe:	e8 be fe ff ff       	call   f01068c1 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106a03:	8b 15 04 60 25 f0    	mov    0xf0256004,%edx
f0106a09:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106a0f:	f6 c4 10             	test   $0x10,%ah
f0106a12:	75 f5                	jne    f0106a09 <lapic_init+0x115>
	lapicw(TPR, 0);
f0106a14:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a19:	b8 20 00 00 00       	mov    $0x20,%eax
f0106a1e:	e8 9e fe ff ff       	call   f01068c1 <lapicw>
}
f0106a23:	c9                   	leave  
f0106a24:	f3 c3                	repz ret 

f0106a26 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106a26:	83 3d 04 60 25 f0 00 	cmpl   $0x0,0xf0256004
f0106a2d:	74 13                	je     f0106a42 <lapic_eoi+0x1c>
{
f0106a2f:	55                   	push   %ebp
f0106a30:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0106a32:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a37:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106a3c:	e8 80 fe ff ff       	call   f01068c1 <lapicw>
}
f0106a41:	5d                   	pop    %ebp
f0106a42:	f3 c3                	repz ret 

f0106a44 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106a44:	55                   	push   %ebp
f0106a45:	89 e5                	mov    %esp,%ebp
f0106a47:	56                   	push   %esi
f0106a48:	53                   	push   %ebx
f0106a49:	83 ec 10             	sub    $0x10,%esp
f0106a4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106a4f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106a52:	ba 70 00 00 00       	mov    $0x70,%edx
f0106a57:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106a5c:	ee                   	out    %al,(%dx)
f0106a5d:	b2 71                	mov    $0x71,%dl
f0106a5f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106a64:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106a65:	83 3d 88 4e 21 f0 00 	cmpl   $0x0,0xf0214e88
f0106a6c:	75 24                	jne    f0106a92 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106a6e:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106a75:	00 
f0106a76:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0106a7d:	f0 
f0106a7e:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106a85:	00 
f0106a86:	c7 04 24 f4 8e 10 f0 	movl   $0xf0108ef4,(%esp)
f0106a8d:	e8 ae 95 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106a92:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106a99:	00 00 
	wrv[1] = addr >> 4;
f0106a9b:	89 f0                	mov    %esi,%eax
f0106a9d:	c1 e8 04             	shr    $0x4,%eax
f0106aa0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106aa6:	c1 e3 18             	shl    $0x18,%ebx
f0106aa9:	89 da                	mov    %ebx,%edx
f0106aab:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106ab0:	e8 0c fe ff ff       	call   f01068c1 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106ab5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106aba:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106abf:	e8 fd fd ff ff       	call   f01068c1 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106ac4:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106ac9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ace:	e8 ee fd ff ff       	call   f01068c1 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ad3:	c1 ee 0c             	shr    $0xc,%esi
f0106ad6:	81 ce 00 06 00 00    	or     $0x600,%esi
		lapicw(ICRHI, apicid << 24);
f0106adc:	89 da                	mov    %ebx,%edx
f0106ade:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106ae3:	e8 d9 fd ff ff       	call   f01068c1 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ae8:	89 f2                	mov    %esi,%edx
f0106aea:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106aef:	e8 cd fd ff ff       	call   f01068c1 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106af4:	89 da                	mov    %ebx,%edx
f0106af6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106afb:	e8 c1 fd ff ff       	call   f01068c1 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106b00:	89 f2                	mov    %esi,%edx
f0106b02:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106b07:	e8 b5 fd ff ff       	call   f01068c1 <lapicw>
		microdelay(200);
	}
}
f0106b0c:	83 c4 10             	add    $0x10,%esp
f0106b0f:	5b                   	pop    %ebx
f0106b10:	5e                   	pop    %esi
f0106b11:	5d                   	pop    %ebp
f0106b12:	c3                   	ret    

f0106b13 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106b13:	55                   	push   %ebp
f0106b14:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106b16:	8b 55 08             	mov    0x8(%ebp),%edx
f0106b19:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106b1f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106b24:	e8 98 fd ff ff       	call   f01068c1 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106b29:	8b 15 04 60 25 f0    	mov    0xf0256004,%edx
f0106b2f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106b35:	f6 c4 10             	test   $0x10,%ah
f0106b38:	75 f5                	jne    f0106b2f <lapic_ipi+0x1c>
		;
}
f0106b3a:	5d                   	pop    %ebp
f0106b3b:	c3                   	ret    

f0106b3c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106b3c:	55                   	push   %ebp
f0106b3d:	89 e5                	mov    %esp,%ebp
f0106b3f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106b42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106b48:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b4b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106b4e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106b55:	5d                   	pop    %ebp
f0106b56:	c3                   	ret    

f0106b57 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106b57:	55                   	push   %ebp
f0106b58:	89 e5                	mov    %esp,%ebp
f0106b5a:	56                   	push   %esi
f0106b5b:	53                   	push   %ebx
f0106b5c:	83 ec 20             	sub    $0x20,%esp
f0106b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106b62:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106b65:	75 07                	jne    f0106b6e <spin_lock+0x17>
	asm volatile("lock; xchgl %0, %1"
f0106b67:	ba 01 00 00 00       	mov    $0x1,%edx
f0106b6c:	eb 42                	jmp    f0106bb0 <spin_lock+0x59>
f0106b6e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106b71:	e8 63 fd ff ff       	call   f01068d9 <cpunum>
f0106b76:	6b c0 74             	imul   $0x74,%eax,%eax
f0106b79:	05 20 50 21 f0       	add    $0xf0215020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106b7e:	39 c6                	cmp    %eax,%esi
f0106b80:	75 e5                	jne    f0106b67 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106b82:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106b85:	e8 4f fd ff ff       	call   f01068d9 <cpunum>
f0106b8a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106b8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106b92:	c7 44 24 08 04 8f 10 	movl   $0xf0108f04,0x8(%esp)
f0106b99:	f0 
f0106b9a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106ba1:	00 
f0106ba2:	c7 04 24 68 8f 10 f0 	movl   $0xf0108f68,(%esp)
f0106ba9:	e8 92 94 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106bae:	f3 90                	pause  
f0106bb0:	89 d0                	mov    %edx,%eax
f0106bb2:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106bb5:	85 c0                	test   %eax,%eax
f0106bb7:	75 f5                	jne    f0106bae <spin_lock+0x57>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106bb9:	e8 1b fd ff ff       	call   f01068d9 <cpunum>
f0106bbe:	6b c0 74             	imul   $0x74,%eax,%eax
f0106bc1:	05 20 50 21 f0       	add    $0xf0215020,%eax
f0106bc6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106bc9:	83 c3 0c             	add    $0xc,%ebx
	ebp = (uint32_t *)read_ebp();
f0106bcc:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106bce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106bd3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106bd9:	76 12                	jbe    f0106bed <spin_lock+0x96>
		pcs[i] = ebp[1];          // saved %eip
f0106bdb:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106bde:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106be1:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106be3:	83 c0 01             	add    $0x1,%eax
f0106be6:	83 f8 0a             	cmp    $0xa,%eax
f0106be9:	75 e8                	jne    f0106bd3 <spin_lock+0x7c>
f0106beb:	eb 0f                	jmp    f0106bfc <spin_lock+0xa5>
		pcs[i] = 0;
f0106bed:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106bf4:	83 c0 01             	add    $0x1,%eax
f0106bf7:	83 f8 09             	cmp    $0x9,%eax
f0106bfa:	7e f1                	jle    f0106bed <spin_lock+0x96>
#endif
}
f0106bfc:	83 c4 20             	add    $0x20,%esp
f0106bff:	5b                   	pop    %ebx
f0106c00:	5e                   	pop    %esi
f0106c01:	5d                   	pop    %ebp
f0106c02:	c3                   	ret    

f0106c03 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106c03:	55                   	push   %ebp
f0106c04:	89 e5                	mov    %esp,%ebp
f0106c06:	57                   	push   %edi
f0106c07:	56                   	push   %esi
f0106c08:	53                   	push   %ebx
f0106c09:	83 ec 6c             	sub    $0x6c,%esp
f0106c0c:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106c0f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106c12:	74 18                	je     f0106c2c <spin_unlock+0x29>
f0106c14:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106c17:	e8 bd fc ff ff       	call   f01068d9 <cpunum>
f0106c1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c1f:	05 20 50 21 f0       	add    $0xf0215020,%eax
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106c24:	39 c3                	cmp    %eax,%ebx
f0106c26:	0f 84 ce 00 00 00    	je     f0106cfa <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106c2c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106c33:	00 
f0106c34:	8d 46 0c             	lea    0xc(%esi),%eax
f0106c37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c3b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106c3e:	89 1c 24             	mov    %ebx,(%esp)
f0106c41:	e8 8e f6 ff ff       	call   f01062d4 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106c46:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106c49:	0f b6 38             	movzbl (%eax),%edi
f0106c4c:	8b 76 04             	mov    0x4(%esi),%esi
f0106c4f:	e8 85 fc ff ff       	call   f01068d9 <cpunum>
f0106c54:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c58:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c60:	c7 04 24 30 8f 10 f0 	movl   $0xf0108f30,(%esp)
f0106c67:	e8 6f d6 ff ff       	call   f01042db <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106c6c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106c6f:	eb 65                	jmp    f0106cd6 <spin_unlock+0xd3>
f0106c71:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106c75:	89 04 24             	mov    %eax,(%esp)
f0106c78:	e8 c3 ea ff ff       	call   f0105740 <debuginfo_eip>
f0106c7d:	85 c0                	test   %eax,%eax
f0106c7f:	78 39                	js     f0106cba <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106c81:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106c83:	89 c2                	mov    %eax,%edx
f0106c85:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106c88:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106c8c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106c8f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106c93:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106c96:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106c9a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106c9d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106ca1:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106ca4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cac:	c7 04 24 78 8f 10 f0 	movl   $0xf0108f78,(%esp)
f0106cb3:	e8 23 d6 ff ff       	call   f01042db <cprintf>
f0106cb8:	eb 12                	jmp    f0106ccc <spin_unlock+0xc9>
			else
				cprintf("  %08x\n", pcs[i]);
f0106cba:	8b 06                	mov    (%esi),%eax
f0106cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cc0:	c7 04 24 8f 8f 10 f0 	movl   $0xf0108f8f,(%esp)
f0106cc7:	e8 0f d6 ff ff       	call   f01042db <cprintf>
f0106ccc:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106ccf:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106cd2:	39 c3                	cmp    %eax,%ebx
f0106cd4:	74 08                	je     f0106cde <spin_unlock+0xdb>
f0106cd6:	89 de                	mov    %ebx,%esi
f0106cd8:	8b 03                	mov    (%ebx),%eax
f0106cda:	85 c0                	test   %eax,%eax
f0106cdc:	75 93                	jne    f0106c71 <spin_unlock+0x6e>
		}
		panic("spin_unlock");
f0106cde:	c7 44 24 08 97 8f 10 	movl   $0xf0108f97,0x8(%esp)
f0106ce5:	f0 
f0106ce6:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106ced:	00 
f0106cee:	c7 04 24 68 8f 10 f0 	movl   $0xf0108f68,(%esp)
f0106cf5:	e8 46 93 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106cfa:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106d01:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106d08:	b8 00 00 00 00       	mov    $0x0,%eax
f0106d0d:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106d10:	83 c4 6c             	add    $0x6c,%esp
f0106d13:	5b                   	pop    %ebx
f0106d14:	5e                   	pop    %esi
f0106d15:	5f                   	pop    %edi
f0106d16:	5d                   	pop    %ebp
f0106d17:	c3                   	ret    
f0106d18:	66 90                	xchg   %ax,%ax
f0106d1a:	66 90                	xchg   %ax,%ax
f0106d1c:	66 90                	xchg   %ax,%ax
f0106d1e:	66 90                	xchg   %ax,%ax

f0106d20 <__udivdi3>:
f0106d20:	55                   	push   %ebp
f0106d21:	57                   	push   %edi
f0106d22:	56                   	push   %esi
f0106d23:	83 ec 0c             	sub    $0xc,%esp
f0106d26:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106d2a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106d2e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106d32:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106d36:	85 c0                	test   %eax,%eax
f0106d38:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106d3c:	89 ea                	mov    %ebp,%edx
f0106d3e:	89 0c 24             	mov    %ecx,(%esp)
f0106d41:	75 2d                	jne    f0106d70 <__udivdi3+0x50>
f0106d43:	39 e9                	cmp    %ebp,%ecx
f0106d45:	77 61                	ja     f0106da8 <__udivdi3+0x88>
f0106d47:	85 c9                	test   %ecx,%ecx
f0106d49:	89 ce                	mov    %ecx,%esi
f0106d4b:	75 0b                	jne    f0106d58 <__udivdi3+0x38>
f0106d4d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d52:	31 d2                	xor    %edx,%edx
f0106d54:	f7 f1                	div    %ecx
f0106d56:	89 c6                	mov    %eax,%esi
f0106d58:	31 d2                	xor    %edx,%edx
f0106d5a:	89 e8                	mov    %ebp,%eax
f0106d5c:	f7 f6                	div    %esi
f0106d5e:	89 c5                	mov    %eax,%ebp
f0106d60:	89 f8                	mov    %edi,%eax
f0106d62:	f7 f6                	div    %esi
f0106d64:	89 ea                	mov    %ebp,%edx
f0106d66:	83 c4 0c             	add    $0xc,%esp
f0106d69:	5e                   	pop    %esi
f0106d6a:	5f                   	pop    %edi
f0106d6b:	5d                   	pop    %ebp
f0106d6c:	c3                   	ret    
f0106d6d:	8d 76 00             	lea    0x0(%esi),%esi
f0106d70:	39 e8                	cmp    %ebp,%eax
f0106d72:	77 24                	ja     f0106d98 <__udivdi3+0x78>
f0106d74:	0f bd e8             	bsr    %eax,%ebp
f0106d77:	83 f5 1f             	xor    $0x1f,%ebp
f0106d7a:	75 3c                	jne    f0106db8 <__udivdi3+0x98>
f0106d7c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106d80:	39 34 24             	cmp    %esi,(%esp)
f0106d83:	0f 86 9f 00 00 00    	jbe    f0106e28 <__udivdi3+0x108>
f0106d89:	39 d0                	cmp    %edx,%eax
f0106d8b:	0f 82 97 00 00 00    	jb     f0106e28 <__udivdi3+0x108>
f0106d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106d98:	31 d2                	xor    %edx,%edx
f0106d9a:	31 c0                	xor    %eax,%eax
f0106d9c:	83 c4 0c             	add    $0xc,%esp
f0106d9f:	5e                   	pop    %esi
f0106da0:	5f                   	pop    %edi
f0106da1:	5d                   	pop    %ebp
f0106da2:	c3                   	ret    
f0106da3:	90                   	nop
f0106da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106da8:	89 f8                	mov    %edi,%eax
f0106daa:	f7 f1                	div    %ecx
f0106dac:	31 d2                	xor    %edx,%edx
f0106dae:	83 c4 0c             	add    $0xc,%esp
f0106db1:	5e                   	pop    %esi
f0106db2:	5f                   	pop    %edi
f0106db3:	5d                   	pop    %ebp
f0106db4:	c3                   	ret    
f0106db5:	8d 76 00             	lea    0x0(%esi),%esi
f0106db8:	89 e9                	mov    %ebp,%ecx
f0106dba:	8b 3c 24             	mov    (%esp),%edi
f0106dbd:	d3 e0                	shl    %cl,%eax
f0106dbf:	89 c6                	mov    %eax,%esi
f0106dc1:	b8 20 00 00 00       	mov    $0x20,%eax
f0106dc6:	29 e8                	sub    %ebp,%eax
f0106dc8:	89 c1                	mov    %eax,%ecx
f0106dca:	d3 ef                	shr    %cl,%edi
f0106dcc:	89 e9                	mov    %ebp,%ecx
f0106dce:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106dd2:	8b 3c 24             	mov    (%esp),%edi
f0106dd5:	09 74 24 08          	or     %esi,0x8(%esp)
f0106dd9:	89 d6                	mov    %edx,%esi
f0106ddb:	d3 e7                	shl    %cl,%edi
f0106ddd:	89 c1                	mov    %eax,%ecx
f0106ddf:	89 3c 24             	mov    %edi,(%esp)
f0106de2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106de6:	d3 ee                	shr    %cl,%esi
f0106de8:	89 e9                	mov    %ebp,%ecx
f0106dea:	d3 e2                	shl    %cl,%edx
f0106dec:	89 c1                	mov    %eax,%ecx
f0106dee:	d3 ef                	shr    %cl,%edi
f0106df0:	09 d7                	or     %edx,%edi
f0106df2:	89 f2                	mov    %esi,%edx
f0106df4:	89 f8                	mov    %edi,%eax
f0106df6:	f7 74 24 08          	divl   0x8(%esp)
f0106dfa:	89 d6                	mov    %edx,%esi
f0106dfc:	89 c7                	mov    %eax,%edi
f0106dfe:	f7 24 24             	mull   (%esp)
f0106e01:	39 d6                	cmp    %edx,%esi
f0106e03:	89 14 24             	mov    %edx,(%esp)
f0106e06:	72 30                	jb     f0106e38 <__udivdi3+0x118>
f0106e08:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106e0c:	89 e9                	mov    %ebp,%ecx
f0106e0e:	d3 e2                	shl    %cl,%edx
f0106e10:	39 c2                	cmp    %eax,%edx
f0106e12:	73 05                	jae    f0106e19 <__udivdi3+0xf9>
f0106e14:	3b 34 24             	cmp    (%esp),%esi
f0106e17:	74 1f                	je     f0106e38 <__udivdi3+0x118>
f0106e19:	89 f8                	mov    %edi,%eax
f0106e1b:	31 d2                	xor    %edx,%edx
f0106e1d:	e9 7a ff ff ff       	jmp    f0106d9c <__udivdi3+0x7c>
f0106e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106e28:	31 d2                	xor    %edx,%edx
f0106e2a:	b8 01 00 00 00       	mov    $0x1,%eax
f0106e2f:	e9 68 ff ff ff       	jmp    f0106d9c <__udivdi3+0x7c>
f0106e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106e38:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106e3b:	31 d2                	xor    %edx,%edx
f0106e3d:	83 c4 0c             	add    $0xc,%esp
f0106e40:	5e                   	pop    %esi
f0106e41:	5f                   	pop    %edi
f0106e42:	5d                   	pop    %ebp
f0106e43:	c3                   	ret    
f0106e44:	66 90                	xchg   %ax,%ax
f0106e46:	66 90                	xchg   %ax,%ax
f0106e48:	66 90                	xchg   %ax,%ax
f0106e4a:	66 90                	xchg   %ax,%ax
f0106e4c:	66 90                	xchg   %ax,%ax
f0106e4e:	66 90                	xchg   %ax,%ax

f0106e50 <__umoddi3>:
f0106e50:	55                   	push   %ebp
f0106e51:	57                   	push   %edi
f0106e52:	56                   	push   %esi
f0106e53:	83 ec 14             	sub    $0x14,%esp
f0106e56:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106e5a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106e5e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106e62:	89 c7                	mov    %eax,%edi
f0106e64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e68:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106e6c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106e70:	89 34 24             	mov    %esi,(%esp)
f0106e73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e77:	85 c0                	test   %eax,%eax
f0106e79:	89 c2                	mov    %eax,%edx
f0106e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106e7f:	75 17                	jne    f0106e98 <__umoddi3+0x48>
f0106e81:	39 fe                	cmp    %edi,%esi
f0106e83:	76 4b                	jbe    f0106ed0 <__umoddi3+0x80>
f0106e85:	89 c8                	mov    %ecx,%eax
f0106e87:	89 fa                	mov    %edi,%edx
f0106e89:	f7 f6                	div    %esi
f0106e8b:	89 d0                	mov    %edx,%eax
f0106e8d:	31 d2                	xor    %edx,%edx
f0106e8f:	83 c4 14             	add    $0x14,%esp
f0106e92:	5e                   	pop    %esi
f0106e93:	5f                   	pop    %edi
f0106e94:	5d                   	pop    %ebp
f0106e95:	c3                   	ret    
f0106e96:	66 90                	xchg   %ax,%ax
f0106e98:	39 f8                	cmp    %edi,%eax
f0106e9a:	77 54                	ja     f0106ef0 <__umoddi3+0xa0>
f0106e9c:	0f bd e8             	bsr    %eax,%ebp
f0106e9f:	83 f5 1f             	xor    $0x1f,%ebp
f0106ea2:	75 5c                	jne    f0106f00 <__umoddi3+0xb0>
f0106ea4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106ea8:	39 3c 24             	cmp    %edi,(%esp)
f0106eab:	0f 87 e7 00 00 00    	ja     f0106f98 <__umoddi3+0x148>
f0106eb1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106eb5:	29 f1                	sub    %esi,%ecx
f0106eb7:	19 c7                	sbb    %eax,%edi
f0106eb9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106ebd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106ec1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106ec5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106ec9:	83 c4 14             	add    $0x14,%esp
f0106ecc:	5e                   	pop    %esi
f0106ecd:	5f                   	pop    %edi
f0106ece:	5d                   	pop    %ebp
f0106ecf:	c3                   	ret    
f0106ed0:	85 f6                	test   %esi,%esi
f0106ed2:	89 f5                	mov    %esi,%ebp
f0106ed4:	75 0b                	jne    f0106ee1 <__umoddi3+0x91>
f0106ed6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106edb:	31 d2                	xor    %edx,%edx
f0106edd:	f7 f6                	div    %esi
f0106edf:	89 c5                	mov    %eax,%ebp
f0106ee1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106ee5:	31 d2                	xor    %edx,%edx
f0106ee7:	f7 f5                	div    %ebp
f0106ee9:	89 c8                	mov    %ecx,%eax
f0106eeb:	f7 f5                	div    %ebp
f0106eed:	eb 9c                	jmp    f0106e8b <__umoddi3+0x3b>
f0106eef:	90                   	nop
f0106ef0:	89 c8                	mov    %ecx,%eax
f0106ef2:	89 fa                	mov    %edi,%edx
f0106ef4:	83 c4 14             	add    $0x14,%esp
f0106ef7:	5e                   	pop    %esi
f0106ef8:	5f                   	pop    %edi
f0106ef9:	5d                   	pop    %ebp
f0106efa:	c3                   	ret    
f0106efb:	90                   	nop
f0106efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106f00:	8b 04 24             	mov    (%esp),%eax
f0106f03:	be 20 00 00 00       	mov    $0x20,%esi
f0106f08:	89 e9                	mov    %ebp,%ecx
f0106f0a:	29 ee                	sub    %ebp,%esi
f0106f0c:	d3 e2                	shl    %cl,%edx
f0106f0e:	89 f1                	mov    %esi,%ecx
f0106f10:	d3 e8                	shr    %cl,%eax
f0106f12:	89 e9                	mov    %ebp,%ecx
f0106f14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f18:	8b 04 24             	mov    (%esp),%eax
f0106f1b:	09 54 24 04          	or     %edx,0x4(%esp)
f0106f1f:	89 fa                	mov    %edi,%edx
f0106f21:	d3 e0                	shl    %cl,%eax
f0106f23:	89 f1                	mov    %esi,%ecx
f0106f25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106f29:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106f2d:	d3 ea                	shr    %cl,%edx
f0106f2f:	89 e9                	mov    %ebp,%ecx
f0106f31:	d3 e7                	shl    %cl,%edi
f0106f33:	89 f1                	mov    %esi,%ecx
f0106f35:	d3 e8                	shr    %cl,%eax
f0106f37:	89 e9                	mov    %ebp,%ecx
f0106f39:	09 f8                	or     %edi,%eax
f0106f3b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106f3f:	f7 74 24 04          	divl   0x4(%esp)
f0106f43:	d3 e7                	shl    %cl,%edi
f0106f45:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106f49:	89 d7                	mov    %edx,%edi
f0106f4b:	f7 64 24 08          	mull   0x8(%esp)
f0106f4f:	39 d7                	cmp    %edx,%edi
f0106f51:	89 c1                	mov    %eax,%ecx
f0106f53:	89 14 24             	mov    %edx,(%esp)
f0106f56:	72 2c                	jb     f0106f84 <__umoddi3+0x134>
f0106f58:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106f5c:	72 22                	jb     f0106f80 <__umoddi3+0x130>
f0106f5e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106f62:	29 c8                	sub    %ecx,%eax
f0106f64:	19 d7                	sbb    %edx,%edi
f0106f66:	89 e9                	mov    %ebp,%ecx
f0106f68:	89 fa                	mov    %edi,%edx
f0106f6a:	d3 e8                	shr    %cl,%eax
f0106f6c:	89 f1                	mov    %esi,%ecx
f0106f6e:	d3 e2                	shl    %cl,%edx
f0106f70:	89 e9                	mov    %ebp,%ecx
f0106f72:	d3 ef                	shr    %cl,%edi
f0106f74:	09 d0                	or     %edx,%eax
f0106f76:	89 fa                	mov    %edi,%edx
f0106f78:	83 c4 14             	add    $0x14,%esp
f0106f7b:	5e                   	pop    %esi
f0106f7c:	5f                   	pop    %edi
f0106f7d:	5d                   	pop    %ebp
f0106f7e:	c3                   	ret    
f0106f7f:	90                   	nop
f0106f80:	39 d7                	cmp    %edx,%edi
f0106f82:	75 da                	jne    f0106f5e <__umoddi3+0x10e>
f0106f84:	8b 14 24             	mov    (%esp),%edx
f0106f87:	89 c1                	mov    %eax,%ecx
f0106f89:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106f8d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106f91:	eb cb                	jmp    f0106f5e <__umoddi3+0x10e>
f0106f93:	90                   	nop
f0106f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106f98:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106f9c:	0f 82 0f ff ff ff    	jb     f0106eb1 <__umoddi3+0x61>
f0106fa2:	e9 1a ff ff ff       	jmp    f0106ec1 <__umoddi3+0x71>
