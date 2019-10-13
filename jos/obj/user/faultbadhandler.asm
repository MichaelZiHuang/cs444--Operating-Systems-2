
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800048:	ee 
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 4e 01 00 00       	call   8001a3 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800055:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005c:	de 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 da 02 00 00       	call   800343 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800069:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800070:	00 00 00 
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	83 ec 10             	sub    $0x10,%esp
  80007d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800080:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800083:	e8 dd 00 00 00       	call   800165 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800088:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800090:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800095:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009a:	85 db                	test   %ebx,%ebx
  80009c:	7e 07                	jle    8000a5 <libmain+0x30>
		binaryname = argv[0];
  80009e:	8b 06                	mov    (%esi),%eax
  8000a0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 07 00 00 00       	call   8000bd <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000c3:	e8 1d 05 00 00       	call   8005e5 <close_all>
	sys_env_destroy(0);
  8000c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cf:	e8 3f 00 00 00       	call   800113 <sys_env_destroy>
}
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    

008000d6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	89 c3                	mov    %eax,%ebx
  8000e9:	89 c7                	mov    %eax,%edi
  8000eb:	89 c6                	mov    %eax,%esi
  8000ed:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ff:	b8 01 00 00 00       	mov    $0x1,%eax
  800104:	89 d1                	mov    %edx,%ecx
  800106:	89 d3                	mov    %edx,%ebx
  800108:	89 d7                	mov    %edx,%edi
  80010a:	89 d6                	mov    %edx,%esi
  80010c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	b8 03 00 00 00       	mov    $0x3,%eax
  800126:	8b 55 08             	mov    0x8(%ebp),%edx
  800129:	89 cb                	mov    %ecx,%ebx
  80012b:	89 cf                	mov    %ecx,%edi
  80012d:	89 ce                	mov    %ecx,%esi
  80012f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7e 28                	jle    80015d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800135:	89 44 24 10          	mov    %eax,0x10(%esp)
  800139:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800140:	00 
  800141:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800148:	00 
  800149:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800158:	e8 29 10 00 00       	call   801186 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015d:	83 c4 2c             	add    $0x2c,%esp
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 02 00 00 00       	mov    $0x2,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_yield>:

void
sys_yield(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
	asm volatile("int %1\n"
  80018a:	ba 00 00 00 00       	mov    $0x0,%edx
  80018f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800194:	89 d1                	mov    %edx,%ecx
  800196:	89 d3                	mov    %edx,%ebx
  800198:	89 d7                	mov    %edx,%edi
  80019a:	89 d6                	mov    %edx,%esi
  80019c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001ac:	be 00 00 00 00       	mov    $0x0,%esi
  8001b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bf:	89 f7                	mov    %esi,%edi
  8001c1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	7e 28                	jle    8001ef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001d2:	00 
  8001d3:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8001da:	00 
  8001db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8001ea:	e8 97 0f 00 00       	call   801186 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ef:	83 c4 2c             	add    $0x2c,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800200:	b8 05 00 00 00       	mov    $0x5,%eax
  800205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800208:	8b 55 08             	mov    0x8(%ebp),%edx
  80020b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800211:	8b 75 18             	mov    0x18(%ebp),%esi
  800214:	cd 30                	int    $0x30
	if(check && ret > 0)
  800216:	85 c0                	test   %eax,%eax
  800218:	7e 28                	jle    800242 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800225:	00 
  800226:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  80022d:	00 
  80022e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800235:	00 
  800236:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  80023d:	e8 44 0f 00 00       	call   801186 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800242:	83 c4 2c             	add    $0x2c,%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	b8 06 00 00 00       	mov    $0x6,%eax
  80025d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	89 df                	mov    %ebx,%edi
  800265:	89 de                	mov    %ebx,%esi
  800267:	cd 30                	int    $0x30
	if(check && ret > 0)
  800269:	85 c0                	test   %eax,%eax
  80026b:	7e 28                	jle    800295 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800271:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800278:	00 
  800279:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800280:	00 
  800281:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800288:	00 
  800289:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800290:	e8 f1 0e 00 00       	call   801186 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800295:	83 c4 2c             	add    $0x2c,%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	89 df                	mov    %ebx,%edi
  8002b8:	89 de                	mov    %ebx,%esi
  8002ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bc:	85 c0                	test   %eax,%eax
  8002be:	7e 28                	jle    8002e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002cb:	00 
  8002cc:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8002d3:	00 
  8002d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002db:	00 
  8002dc:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8002e3:	e8 9e 0e 00 00       	call   801186 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e8:	83 c4 2c             	add    $0x2c,%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fe:	b8 09 00 00 00       	mov    $0x9,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	89 df                	mov    %ebx,%edi
  80030b:	89 de                	mov    %ebx,%esi
  80030d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80030f:	85 c0                	test   %eax,%eax
  800311:	7e 28                	jle    80033b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800313:	89 44 24 10          	mov    %eax,0x10(%esp)
  800317:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80031e:	00 
  80031f:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800326:	00 
  800327:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032e:	00 
  80032f:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800336:	e8 4b 0e 00 00       	call   801186 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80033b:	83 c4 2c             	add    $0x2c,%esp
  80033e:	5b                   	pop    %ebx
  80033f:	5e                   	pop    %esi
  800340:	5f                   	pop    %edi
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
  800349:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80034c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800351:	b8 0a 00 00 00       	mov    $0xa,%eax
  800356:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 df                	mov    %ebx,%edi
  80035e:	89 de                	mov    %ebx,%esi
  800360:	cd 30                	int    $0x30
	if(check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7e 28                	jle    80038e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800371:	00 
  800372:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800389:	e8 f8 0d 00 00       	call   801186 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80038e:	83 c4 2c             	add    $0x2c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80039c:	be 00 00 00 00       	mov    $0x0,%esi
  8003a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003b4:	5b                   	pop    %ebx
  8003b5:	5e                   	pop    %esi
  8003b6:	5f                   	pop    %edi
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8003c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cf:	89 cb                	mov    %ecx,%ebx
  8003d1:	89 cf                	mov    %ecx,%edi
  8003d3:	89 ce                	mov    %ecx,%esi
  8003d5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	7e 28                	jle    800403 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003e6:	00 
  8003e7:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8003ee:	00 
  8003ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f6:	00 
  8003f7:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8003fe:	e8 83 0d 00 00       	call   801186 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800403:	83 c4 2c             	add    $0x2c,%esp
  800406:	5b                   	pop    %ebx
  800407:	5e                   	pop    %esi
  800408:	5f                   	pop    %edi
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    
  80040b:	66 90                	xchg   %ax,%ax
  80040d:	66 90                	xchg   %ax,%ax
  80040f:	90                   	nop

00800410 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	05 00 00 00 30       	add    $0x30000000,%eax
  80041b:	c1 e8 0c             	shr    $0xc,%eax
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80042b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800430:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800442:	89 c2                	mov    %eax,%edx
  800444:	c1 ea 16             	shr    $0x16,%edx
  800447:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80044e:	f6 c2 01             	test   $0x1,%dl
  800451:	74 11                	je     800464 <fd_alloc+0x2d>
  800453:	89 c2                	mov    %eax,%edx
  800455:	c1 ea 0c             	shr    $0xc,%edx
  800458:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80045f:	f6 c2 01             	test   $0x1,%dl
  800462:	75 09                	jne    80046d <fd_alloc+0x36>
			*fd_store = fd;
  800464:	89 01                	mov    %eax,(%ecx)
			return 0;
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	eb 17                	jmp    800484 <fd_alloc+0x4d>
  80046d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800472:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800477:	75 c9                	jne    800442 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800479:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80047f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80048c:	83 f8 1f             	cmp    $0x1f,%eax
  80048f:	77 36                	ja     8004c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800491:	c1 e0 0c             	shl    $0xc,%eax
  800494:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800499:	89 c2                	mov    %eax,%edx
  80049b:	c1 ea 16             	shr    $0x16,%edx
  80049e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004a5:	f6 c2 01             	test   $0x1,%dl
  8004a8:	74 24                	je     8004ce <fd_lookup+0x48>
  8004aa:	89 c2                	mov    %eax,%edx
  8004ac:	c1 ea 0c             	shr    $0xc,%edx
  8004af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004b6:	f6 c2 01             	test   $0x1,%dl
  8004b9:	74 1a                	je     8004d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004be:	89 02                	mov    %eax,(%edx)
	return 0;
  8004c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c5:	eb 13                	jmp    8004da <fd_lookup+0x54>
		return -E_INVAL;
  8004c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004cc:	eb 0c                	jmp    8004da <fd_lookup+0x54>
		return -E_INVAL;
  8004ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004d3:	eb 05                	jmp    8004da <fd_lookup+0x54>
  8004d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	83 ec 18             	sub    $0x18,%esp
  8004e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e5:	ba 94 20 80 00       	mov    $0x802094,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004ea:	eb 13                	jmp    8004ff <dev_lookup+0x23>
  8004ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004ef:	39 08                	cmp    %ecx,(%eax)
  8004f1:	75 0c                	jne    8004ff <dev_lookup+0x23>
			*dev = devtab[i];
  8004f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fd:	eb 30                	jmp    80052f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8004ff:	8b 02                	mov    (%edx),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	75 e7                	jne    8004ec <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800505:	a1 08 40 80 00       	mov    0x804008,%eax
  80050a:	8b 40 48             	mov    0x48(%eax),%eax
  80050d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800511:	89 44 24 04          	mov    %eax,0x4(%esp)
  800515:	c7 04 24 18 20 80 00 	movl   $0x802018,(%esp)
  80051c:	e8 5e 0d 00 00       	call   80127f <cprintf>
	*dev = 0;
  800521:	8b 45 0c             	mov    0xc(%ebp),%eax
  800524:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80052a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <fd_close>:
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	56                   	push   %esi
  800535:	53                   	push   %ebx
  800536:	83 ec 20             	sub    $0x20,%esp
  800539:	8b 75 08             	mov    0x8(%ebp),%esi
  80053c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80053f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800542:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800546:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80054c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 2f ff ff ff       	call   800486 <fd_lookup>
  800557:	85 c0                	test   %eax,%eax
  800559:	78 05                	js     800560 <fd_close+0x2f>
	    || fd != fd2)
  80055b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80055e:	74 0c                	je     80056c <fd_close+0x3b>
		return (must_exist ? r : 0);
  800560:	84 db                	test   %bl,%bl
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	0f 44 c2             	cmove  %edx,%eax
  80056a:	eb 3f                	jmp    8005ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80056c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80056f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800573:	8b 06                	mov    (%esi),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	e8 5f ff ff ff       	call   8004dc <dev_lookup>
  80057d:	89 c3                	mov    %eax,%ebx
  80057f:	85 c0                	test   %eax,%eax
  800581:	78 16                	js     800599 <fd_close+0x68>
		if (dev->dev_close)
  800583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800586:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800589:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80058e:	85 c0                	test   %eax,%eax
  800590:	74 07                	je     800599 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800592:	89 34 24             	mov    %esi,(%esp)
  800595:	ff d0                	call   *%eax
  800597:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  800599:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a4:	e8 a1 fc ff ff       	call   80024a <sys_page_unmap>
	return r;
  8005a9:	89 d8                	mov    %ebx,%eax
}
  8005ab:	83 c4 20             	add    $0x20,%esp
  8005ae:	5b                   	pop    %ebx
  8005af:	5e                   	pop    %esi
  8005b0:	5d                   	pop    %ebp
  8005b1:	c3                   	ret    

008005b2 <close>:

int
close(int fdnum)
{
  8005b2:	55                   	push   %ebp
  8005b3:	89 e5                	mov    %esp,%ebp
  8005b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c2:	89 04 24             	mov    %eax,(%esp)
  8005c5:	e8 bc fe ff ff       	call   800486 <fd_lookup>
  8005ca:	89 c2                	mov    %eax,%edx
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	78 13                	js     8005e3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8005d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005d7:	00 
  8005d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005db:	89 04 24             	mov    %eax,(%esp)
  8005de:	e8 4e ff ff ff       	call   800531 <fd_close>
}
  8005e3:	c9                   	leave  
  8005e4:	c3                   	ret    

008005e5 <close_all>:

void
close_all(void)
{
  8005e5:	55                   	push   %ebp
  8005e6:	89 e5                	mov    %esp,%ebp
  8005e8:	53                   	push   %ebx
  8005e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005f1:	89 1c 24             	mov    %ebx,(%esp)
  8005f4:	e8 b9 ff ff ff       	call   8005b2 <close>
	for (i = 0; i < MAXFD; i++)
  8005f9:	83 c3 01             	add    $0x1,%ebx
  8005fc:	83 fb 20             	cmp    $0x20,%ebx
  8005ff:	75 f0                	jne    8005f1 <close_all+0xc>
}
  800601:	83 c4 14             	add    $0x14,%esp
  800604:	5b                   	pop    %ebx
  800605:	5d                   	pop    %ebp
  800606:	c3                   	ret    

00800607 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	57                   	push   %edi
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800610:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 64 fe ff ff       	call   800486 <fd_lookup>
  800622:	89 c2                	mov    %eax,%edx
  800624:	85 d2                	test   %edx,%edx
  800626:	0f 88 e1 00 00 00    	js     80070d <dup+0x106>
		return r;
	close(newfdnum);
  80062c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	e8 7b ff ff ff       	call   8005b2 <close>

	newfd = INDEX2FD(newfdnum);
  800637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063a:	c1 e3 0c             	shl    $0xc,%ebx
  80063d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800643:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800646:	89 04 24             	mov    %eax,(%esp)
  800649:	e8 d2 fd ff ff       	call   800420 <fd2data>
  80064e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800650:	89 1c 24             	mov    %ebx,(%esp)
  800653:	e8 c8 fd ff ff       	call   800420 <fd2data>
  800658:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80065a:	89 f0                	mov    %esi,%eax
  80065c:	c1 e8 16             	shr    $0x16,%eax
  80065f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800666:	a8 01                	test   $0x1,%al
  800668:	74 43                	je     8006ad <dup+0xa6>
  80066a:	89 f0                	mov    %esi,%eax
  80066c:	c1 e8 0c             	shr    $0xc,%eax
  80066f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800676:	f6 c2 01             	test   $0x1,%dl
  800679:	74 32                	je     8006ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80067b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800682:	25 07 0e 00 00       	and    $0xe07,%eax
  800687:	89 44 24 10          	mov    %eax,0x10(%esp)
  80068b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80068f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800696:	00 
  800697:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a2:	e8 50 fb ff ff       	call   8001f7 <sys_page_map>
  8006a7:	89 c6                	mov    %eax,%esi
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	78 3e                	js     8006eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006b0:	89 c2                	mov    %eax,%edx
  8006b2:	c1 ea 0c             	shr    $0xc,%edx
  8006b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006d1:	00 
  8006d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006dd:	e8 15 fb ff ff       	call   8001f7 <sys_page_map>
  8006e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8006e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006e7:	85 f6                	test   %esi,%esi
  8006e9:	79 22                	jns    80070d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8006eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f6:	e8 4f fb ff ff       	call   80024a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800706:	e8 3f fb ff ff       	call   80024a <sys_page_unmap>
	return r;
  80070b:	89 f0                	mov    %esi,%eax
}
  80070d:	83 c4 3c             	add    $0x3c,%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	53                   	push   %ebx
  800719:	83 ec 24             	sub    $0x24,%esp
  80071c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800722:	89 44 24 04          	mov    %eax,0x4(%esp)
  800726:	89 1c 24             	mov    %ebx,(%esp)
  800729:	e8 58 fd ff ff       	call   800486 <fd_lookup>
  80072e:	89 c2                	mov    %eax,%edx
  800730:	85 d2                	test   %edx,%edx
  800732:	78 6d                	js     8007a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800734:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	89 04 24             	mov    %eax,(%esp)
  800743:	e8 94 fd ff ff       	call   8004dc <dev_lookup>
  800748:	85 c0                	test   %eax,%eax
  80074a:	78 55                	js     8007a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	8b 50 08             	mov    0x8(%eax),%edx
  800752:	83 e2 03             	and    $0x3,%edx
  800755:	83 fa 01             	cmp    $0x1,%edx
  800758:	75 23                	jne    80077d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 08 40 80 00       	mov    0x804008,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800766:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076a:	c7 04 24 59 20 80 00 	movl   $0x802059,(%esp)
  800771:	e8 09 0b 00 00       	call   80127f <cprintf>
		return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb 24                	jmp    8007a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80077d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800780:	8b 52 08             	mov    0x8(%edx),%edx
  800783:	85 d2                	test   %edx,%edx
  800785:	74 15                	je     80079c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800787:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80078a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800795:	89 04 24             	mov    %eax,(%esp)
  800798:	ff d2                	call   *%edx
  80079a:	eb 05                	jmp    8007a1 <read+0x8c>
		return -E_NOT_SUPP;
  80079c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8007a1:	83 c4 24             	add    $0x24,%esp
  8007a4:	5b                   	pop    %ebx
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	57                   	push   %edi
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	83 ec 1c             	sub    $0x1c,%esp
  8007b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007bb:	eb 23                	jmp    8007e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007bd:	89 f0                	mov    %esi,%eax
  8007bf:	29 d8                	sub    %ebx,%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	89 d8                	mov    %ebx,%eax
  8007c7:	03 45 0c             	add    0xc(%ebp),%eax
  8007ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ce:	89 3c 24             	mov    %edi,(%esp)
  8007d1:	e8 3f ff ff ff       	call   800715 <read>
		if (m < 0)
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	78 10                	js     8007ea <readn+0x43>
			return m;
		if (m == 0)
  8007da:	85 c0                	test   %eax,%eax
  8007dc:	74 0a                	je     8007e8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8007de:	01 c3                	add    %eax,%ebx
  8007e0:	39 f3                	cmp    %esi,%ebx
  8007e2:	72 d9                	jb     8007bd <readn+0x16>
  8007e4:	89 d8                	mov    %ebx,%eax
  8007e6:	eb 02                	jmp    8007ea <readn+0x43>
  8007e8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007ea:	83 c4 1c             	add    $0x1c,%esp
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	5f                   	pop    %edi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 24             	sub    $0x24,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800803:	89 1c 24             	mov    %ebx,(%esp)
  800806:	e8 7b fc ff ff       	call   800486 <fd_lookup>
  80080b:	89 c2                	mov    %eax,%edx
  80080d:	85 d2                	test   %edx,%edx
  80080f:	78 68                	js     800879 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081b:	8b 00                	mov    (%eax),%eax
  80081d:	89 04 24             	mov    %eax,(%esp)
  800820:	e8 b7 fc ff ff       	call   8004dc <dev_lookup>
  800825:	85 c0                	test   %eax,%eax
  800827:	78 50                	js     800879 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800830:	75 23                	jne    800855 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800832:	a1 08 40 80 00       	mov    0x804008,%eax
  800837:	8b 40 48             	mov    0x48(%eax),%eax
  80083a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80083e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800842:	c7 04 24 75 20 80 00 	movl   $0x802075,(%esp)
  800849:	e8 31 0a 00 00       	call   80127f <cprintf>
		return -E_INVAL;
  80084e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800853:	eb 24                	jmp    800879 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800855:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800858:	8b 52 0c             	mov    0xc(%edx),%edx
  80085b:	85 d2                	test   %edx,%edx
  80085d:	74 15                	je     800874 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80085f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800862:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800869:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80086d:	89 04 24             	mov    %eax,(%esp)
  800870:	ff d2                	call   *%edx
  800872:	eb 05                	jmp    800879 <write+0x87>
		return -E_NOT_SUPP;
  800874:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800879:	83 c4 24             	add    $0x24,%esp
  80087c:	5b                   	pop    %ebx
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <seek>:

int
seek(int fdnum, off_t offset)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800885:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	89 04 24             	mov    %eax,(%esp)
  800892:	e8 ef fb ff ff       	call   800486 <fd_lookup>
  800897:	85 c0                	test   %eax,%eax
  800899:	78 0e                	js     8008a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80089b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	83 ec 24             	sub    $0x24,%esp
  8008b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bc:	89 1c 24             	mov    %ebx,(%esp)
  8008bf:	e8 c2 fb ff ff       	call   800486 <fd_lookup>
  8008c4:	89 c2                	mov    %eax,%edx
  8008c6:	85 d2                	test   %edx,%edx
  8008c8:	78 61                	js     80092b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d4:	8b 00                	mov    (%eax),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 fe fb ff ff       	call   8004dc <dev_lookup>
  8008de:	85 c0                	test   %eax,%eax
  8008e0:	78 49                	js     80092b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008e9:	75 23                	jne    80090e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008eb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008f0:	8b 40 48             	mov    0x48(%eax),%eax
  8008f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fb:	c7 04 24 38 20 80 00 	movl   $0x802038,(%esp)
  800902:	e8 78 09 00 00       	call   80127f <cprintf>
		return -E_INVAL;
  800907:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80090c:	eb 1d                	jmp    80092b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80090e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800911:	8b 52 18             	mov    0x18(%edx),%edx
  800914:	85 d2                	test   %edx,%edx
  800916:	74 0e                	je     800926 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	ff d2                	call   *%edx
  800924:	eb 05                	jmp    80092b <ftruncate+0x80>
		return -E_NOT_SUPP;
  800926:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80092b:	83 c4 24             	add    $0x24,%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	53                   	push   %ebx
  800935:	83 ec 24             	sub    $0x24,%esp
  800938:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80093b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80093e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	89 04 24             	mov    %eax,(%esp)
  800948:	e8 39 fb ff ff       	call   800486 <fd_lookup>
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	85 d2                	test   %edx,%edx
  800951:	78 52                	js     8009a5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095d:	8b 00                	mov    (%eax),%eax
  80095f:	89 04 24             	mov    %eax,(%esp)
  800962:	e8 75 fb ff ff       	call   8004dc <dev_lookup>
  800967:	85 c0                	test   %eax,%eax
  800969:	78 3a                	js     8009a5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80096b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800972:	74 2c                	je     8009a0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800974:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800977:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80097e:	00 00 00 
	stat->st_isdir = 0;
  800981:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800988:	00 00 00 
	stat->st_dev = dev;
  80098b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800991:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800995:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800998:	89 14 24             	mov    %edx,(%esp)
  80099b:	ff 50 14             	call   *0x14(%eax)
  80099e:	eb 05                	jmp    8009a5 <fstat+0x74>
		return -E_NOT_SUPP;
  8009a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8009a5:	83 c4 24             	add    $0x24,%esp
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009ba:	00 
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 fb 01 00 00       	call   800bc1 <open>
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	85 db                	test   %ebx,%ebx
  8009ca:	78 1b                	js     8009e7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d3:	89 1c 24             	mov    %ebx,(%esp)
  8009d6:	e8 56 ff ff ff       	call   800931 <fstat>
  8009db:	89 c6                	mov    %eax,%esi
	close(fd);
  8009dd:	89 1c 24             	mov    %ebx,(%esp)
  8009e0:	e8 cd fb ff ff       	call   8005b2 <close>
	return r;
  8009e5:	89 f0                	mov    %esi,%eax
}
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	83 ec 10             	sub    $0x10,%esp
  8009f6:	89 c6                	mov    %eax,%esi
  8009f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009fa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a01:	75 11                	jne    800a14 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a0a:	e8 c0 12 00 00       	call   801ccf <ipc_find_env>
  800a0f:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a14:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a1b:	00 
  800a1c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a23:	00 
  800a24:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a28:	a1 00 40 80 00       	mov    0x804000,%eax
  800a2d:	89 04 24             	mov    %eax,(%esp)
  800a30:	e8 33 12 00 00       	call   801c68 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a3c:	00 
  800a3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a48:	e8 b3 11 00 00       	call   801c00 <ipc_recv>
}
  800a4d:	83 c4 10             	add    $0x10,%esp
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a60:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	b8 02 00 00 00       	mov    $0x2,%eax
  800a77:	e8 72 ff ff ff       	call   8009ee <fsipc>
}
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <devfile_flush>:
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a94:	b8 06 00 00 00       	mov    $0x6,%eax
  800a99:	e8 50 ff ff ff       	call   8009ee <fsipc>
}
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <devfile_stat>:
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 14             	sub    $0x14,%esp
  800aa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aba:	b8 05 00 00 00       	mov    $0x5,%eax
  800abf:	e8 2a ff ff ff       	call   8009ee <fsipc>
  800ac4:	89 c2                	mov    %eax,%edx
  800ac6:	85 d2                	test   %edx,%edx
  800ac8:	78 2b                	js     800af5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ad1:	00 
  800ad2:	89 1c 24             	mov    %ebx,(%esp)
  800ad5:	e8 cd 0d 00 00       	call   8018a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ada:	a1 80 50 80 00       	mov    0x805080,%eax
  800adf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ae5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af5:	83 c4 14             	add    $0x14,%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <devfile_write>:
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  800b01:	c7 44 24 08 a4 20 80 	movl   $0x8020a4,0x8(%esp)
  800b08:	00 
  800b09:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800b10:	00 
  800b11:	c7 04 24 c2 20 80 00 	movl   $0x8020c2,(%esp)
  800b18:	e8 69 06 00 00       	call   801186 <_panic>

00800b1d <devfile_read>:
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 10             	sub    $0x10,%esp
  800b25:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b33:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b43:	e8 a6 fe ff ff       	call   8009ee <fsipc>
  800b48:	89 c3                	mov    %eax,%ebx
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	78 6a                	js     800bb8 <devfile_read+0x9b>
	assert(r <= n);
  800b4e:	39 c6                	cmp    %eax,%esi
  800b50:	73 24                	jae    800b76 <devfile_read+0x59>
  800b52:	c7 44 24 0c cd 20 80 	movl   $0x8020cd,0xc(%esp)
  800b59:	00 
  800b5a:	c7 44 24 08 d4 20 80 	movl   $0x8020d4,0x8(%esp)
  800b61:	00 
  800b62:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b69:	00 
  800b6a:	c7 04 24 c2 20 80 00 	movl   $0x8020c2,(%esp)
  800b71:	e8 10 06 00 00       	call   801186 <_panic>
	assert(r <= PGSIZE);
  800b76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b7b:	7e 24                	jle    800ba1 <devfile_read+0x84>
  800b7d:	c7 44 24 0c e9 20 80 	movl   $0x8020e9,0xc(%esp)
  800b84:	00 
  800b85:	c7 44 24 08 d4 20 80 	movl   $0x8020d4,0x8(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b94:	00 
  800b95:	c7 04 24 c2 20 80 00 	movl   $0x8020c2,(%esp)
  800b9c:	e8 e5 05 00 00       	call   801186 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bac:	00 
  800bad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb0:	89 04 24             	mov    %eax,(%esp)
  800bb3:	e8 8c 0e 00 00       	call   801a44 <memmove>
}
  800bb8:	89 d8                	mov    %ebx,%eax
  800bba:	83 c4 10             	add    $0x10,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <open>:
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 24             	sub    $0x24,%esp
  800bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800bcb:	89 1c 24             	mov    %ebx,(%esp)
  800bce:	e8 9d 0c 00 00       	call   801870 <strlen>
  800bd3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bd8:	7f 60                	jg     800c3a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  800bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bdd:	89 04 24             	mov    %eax,(%esp)
  800be0:	e8 52 f8 ff ff       	call   800437 <fd_alloc>
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	85 d2                	test   %edx,%edx
  800be9:	78 54                	js     800c3f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  800beb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bef:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bf6:	e8 ac 0c 00 00       	call   8018a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfe:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c06:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0b:	e8 de fd ff ff       	call   8009ee <fsipc>
  800c10:	89 c3                	mov    %eax,%ebx
  800c12:	85 c0                	test   %eax,%eax
  800c14:	79 17                	jns    800c2d <open+0x6c>
		fd_close(fd, 0);
  800c16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c1d:	00 
  800c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c21:	89 04 24             	mov    %eax,(%esp)
  800c24:	e8 08 f9 ff ff       	call   800531 <fd_close>
		return r;
  800c29:	89 d8                	mov    %ebx,%eax
  800c2b:	eb 12                	jmp    800c3f <open+0x7e>
	return fd2num(fd);
  800c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c30:	89 04 24             	mov    %eax,(%esp)
  800c33:	e8 d8 f7 ff ff       	call   800410 <fd2num>
  800c38:	eb 05                	jmp    800c3f <open+0x7e>
		return -E_BAD_PATH;
  800c3a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  800c3f:	83 c4 24             	add    $0x24,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 08 00 00 00       	mov    $0x8,%eax
  800c55:	e8 94 fd ff ff       	call   8009ee <fsipc>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 10             	sub    $0x10,%esp
  800c64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	89 04 24             	mov    %eax,(%esp)
  800c6d:	e8 ae f7 ff ff       	call   800420 <fd2data>
  800c72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c74:	c7 44 24 04 f5 20 80 	movl   $0x8020f5,0x4(%esp)
  800c7b:	00 
  800c7c:	89 1c 24             	mov    %ebx,(%esp)
  800c7f:	e8 23 0c 00 00       	call   8018a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c84:	8b 46 04             	mov    0x4(%esi),%eax
  800c87:	2b 06                	sub    (%esi),%eax
  800c89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c8f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c96:	00 00 00 
	stat->st_dev = &devpipe;
  800c99:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ca0:	30 80 00 
	return 0;
}
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 14             	sub    $0x14,%esp
  800cb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800cb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cc4:	e8 81 f5 ff ff       	call   80024a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cc9:	89 1c 24             	mov    %ebx,(%esp)
  800ccc:	e8 4f f7 ff ff       	call   800420 <fd2data>
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cdc:	e8 69 f5 ff ff       	call   80024a <sys_page_unmap>
}
  800ce1:	83 c4 14             	add    $0x14,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <_pipeisclosed>:
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
  800cf0:	89 c6                	mov    %eax,%esi
  800cf2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  800cf5:	a1 08 40 80 00       	mov    0x804008,%eax
  800cfa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cfd:	89 34 24             	mov    %esi,(%esp)
  800d00:	e8 02 10 00 00       	call   801d07 <pageref>
  800d05:	89 c7                	mov    %eax,%edi
  800d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d0a:	89 04 24             	mov    %eax,(%esp)
  800d0d:	e8 f5 0f 00 00       	call   801d07 <pageref>
  800d12:	39 c7                	cmp    %eax,%edi
  800d14:	0f 94 c2             	sete   %dl
  800d17:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800d1a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  800d20:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800d23:	39 fb                	cmp    %edi,%ebx
  800d25:	74 21                	je     800d48 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  800d27:	84 d2                	test   %dl,%dl
  800d29:	74 ca                	je     800cf5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d2b:	8b 51 58             	mov    0x58(%ecx),%edx
  800d2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d32:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3a:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800d41:	e8 39 05 00 00       	call   80127f <cprintf>
  800d46:	eb ad                	jmp    800cf5 <_pipeisclosed+0xe>
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <devpipe_write>:
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 1c             	sub    $0x1c,%esp
  800d59:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d5c:	89 34 24             	mov    %esi,(%esp)
  800d5f:	e8 bc f6 ff ff       	call   800420 <fd2data>
  800d64:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d66:	bf 00 00 00 00       	mov    $0x0,%edi
  800d6b:	eb 45                	jmp    800db2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  800d6d:	89 da                	mov    %ebx,%edx
  800d6f:	89 f0                	mov    %esi,%eax
  800d71:	e8 71 ff ff ff       	call   800ce7 <_pipeisclosed>
  800d76:	85 c0                	test   %eax,%eax
  800d78:	75 41                	jne    800dbb <devpipe_write+0x6b>
			sys_yield();
  800d7a:	e8 05 f4 ff ff       	call   800184 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d7f:	8b 43 04             	mov    0x4(%ebx),%eax
  800d82:	8b 0b                	mov    (%ebx),%ecx
  800d84:	8d 51 20             	lea    0x20(%ecx),%edx
  800d87:	39 d0                	cmp    %edx,%eax
  800d89:	73 e2                	jae    800d6d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d95:	99                   	cltd   
  800d96:	c1 ea 1b             	shr    $0x1b,%edx
  800d99:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d9c:	83 e1 1f             	and    $0x1f,%ecx
  800d9f:	29 d1                	sub    %edx,%ecx
  800da1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800da5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800da9:	83 c0 01             	add    $0x1,%eax
  800dac:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800daf:	83 c7 01             	add    $0x1,%edi
  800db2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800db5:	75 c8                	jne    800d7f <devpipe_write+0x2f>
	return i;
  800db7:	89 f8                	mov    %edi,%eax
  800db9:	eb 05                	jmp    800dc0 <devpipe_write+0x70>
				return 0;
  800dbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc0:	83 c4 1c             	add    $0x1c,%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <devpipe_read>:
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 1c             	sub    $0x1c,%esp
  800dd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800dd4:	89 3c 24             	mov    %edi,(%esp)
  800dd7:	e8 44 f6 ff ff       	call   800420 <fd2data>
  800ddc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800dde:	be 00 00 00 00       	mov    $0x0,%esi
  800de3:	eb 3d                	jmp    800e22 <devpipe_read+0x5a>
			if (i > 0)
  800de5:	85 f6                	test   %esi,%esi
  800de7:	74 04                	je     800ded <devpipe_read+0x25>
				return i;
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	eb 43                	jmp    800e30 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  800ded:	89 da                	mov    %ebx,%edx
  800def:	89 f8                	mov    %edi,%eax
  800df1:	e8 f1 fe ff ff       	call   800ce7 <_pipeisclosed>
  800df6:	85 c0                	test   %eax,%eax
  800df8:	75 31                	jne    800e2b <devpipe_read+0x63>
			sys_yield();
  800dfa:	e8 85 f3 ff ff       	call   800184 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800dff:	8b 03                	mov    (%ebx),%eax
  800e01:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e04:	74 df                	je     800de5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e06:	99                   	cltd   
  800e07:	c1 ea 1b             	shr    $0x1b,%edx
  800e0a:	01 d0                	add    %edx,%eax
  800e0c:	83 e0 1f             	and    $0x1f,%eax
  800e0f:	29 d0                	sub    %edx,%eax
  800e11:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800e1c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800e1f:	83 c6 01             	add    $0x1,%esi
  800e22:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e25:	75 d8                	jne    800dff <devpipe_read+0x37>
	return i;
  800e27:	89 f0                	mov    %esi,%eax
  800e29:	eb 05                	jmp    800e30 <devpipe_read+0x68>
				return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e30:	83 c4 1c             	add    $0x1c,%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <pipe>:
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
  800e3d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e43:	89 04 24             	mov    %eax,(%esp)
  800e46:	e8 ec f5 ff ff       	call   800437 <fd_alloc>
  800e4b:	89 c2                	mov    %eax,%edx
  800e4d:	85 d2                	test   %edx,%edx
  800e4f:	0f 88 4d 01 00 00    	js     800fa2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e55:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e5c:	00 
  800e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e6b:	e8 33 f3 ff ff       	call   8001a3 <sys_page_alloc>
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	85 d2                	test   %edx,%edx
  800e74:	0f 88 28 01 00 00    	js     800fa2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  800e7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e7d:	89 04 24             	mov    %eax,(%esp)
  800e80:	e8 b2 f5 ff ff       	call   800437 <fd_alloc>
  800e85:	89 c3                	mov    %eax,%ebx
  800e87:	85 c0                	test   %eax,%eax
  800e89:	0f 88 fe 00 00 00    	js     800f8d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e8f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e96:	00 
  800e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea5:	e8 f9 f2 ff ff       	call   8001a3 <sys_page_alloc>
  800eaa:	89 c3                	mov    %eax,%ebx
  800eac:	85 c0                	test   %eax,%eax
  800eae:	0f 88 d9 00 00 00    	js     800f8d <pipe+0x155>
	va = fd2data(fd0);
  800eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb7:	89 04 24             	mov    %eax,(%esp)
  800eba:	e8 61 f5 ff ff       	call   800420 <fd2data>
  800ebf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ec1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ec8:	00 
  800ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed4:	e8 ca f2 ff ff       	call   8001a3 <sys_page_alloc>
  800ed9:	89 c3                	mov    %eax,%ebx
  800edb:	85 c0                	test   %eax,%eax
  800edd:	0f 88 97 00 00 00    	js     800f7a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee6:	89 04 24             	mov    %eax,(%esp)
  800ee9:	e8 32 f5 ff ff       	call   800420 <fd2data>
  800eee:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ef5:	00 
  800ef6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f01:	00 
  800f02:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0d:	e8 e5 f2 ff ff       	call   8001f7 <sys_page_map>
  800f12:	89 c3                	mov    %eax,%ebx
  800f14:	85 c0                	test   %eax,%eax
  800f16:	78 52                	js     800f6a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  800f18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800f2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f45:	89 04 24             	mov    %eax,(%esp)
  800f48:	e8 c3 f4 ff ff       	call   800410 <fd2num>
  800f4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f55:	89 04 24             	mov    %eax,(%esp)
  800f58:	e8 b3 f4 ff ff       	call   800410 <fd2num>
  800f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
  800f68:	eb 38                	jmp    800fa2 <pipe+0x16a>
	sys_page_unmap(0, va);
  800f6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f75:	e8 d0 f2 ff ff       	call   80024a <sys_page_unmap>
	sys_page_unmap(0, fd1);
  800f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f88:	e8 bd f2 ff ff       	call   80024a <sys_page_unmap>
	sys_page_unmap(0, fd0);
  800f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f90:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f9b:	e8 aa f2 ff ff       	call   80024a <sys_page_unmap>
  800fa0:	89 d8                	mov    %ebx,%eax
}
  800fa2:	83 c4 30             	add    $0x30,%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <pipeisclosed>:
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	89 04 24             	mov    %eax,(%esp)
  800fbc:	e8 c5 f4 ff ff       	call   800486 <fd_lookup>
  800fc1:	89 c2                	mov    %eax,%edx
  800fc3:	85 d2                	test   %edx,%edx
  800fc5:	78 15                	js     800fdc <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  800fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fca:	89 04 24             	mov    %eax,(%esp)
  800fcd:	e8 4e f4 ff ff       	call   800420 <fd2data>
	return _pipeisclosed(fd, p);
  800fd2:	89 c2                	mov    %eax,%edx
  800fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd7:	e8 0b fd ff ff       	call   800ce7 <_pipeisclosed>
}
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    
  800fde:	66 90                	xchg   %ax,%ax

00800fe0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800ff0:	c7 44 24 04 14 21 80 	movl   $0x802114,0x4(%esp)
  800ff7:	00 
  800ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffb:	89 04 24             	mov    %eax,(%esp)
  800ffe:	e8 a4 08 00 00       	call   8018a7 <strcpy>
	return 0;
}
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <devcons_write>:
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	57                   	push   %edi
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801016:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80101b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801021:	eb 31                	jmp    801054 <devcons_write+0x4a>
		m = n - tot;
  801023:	8b 75 10             	mov    0x10(%ebp),%esi
  801026:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801028:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80102b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801030:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801033:	89 74 24 08          	mov    %esi,0x8(%esp)
  801037:	03 45 0c             	add    0xc(%ebp),%eax
  80103a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103e:	89 3c 24             	mov    %edi,(%esp)
  801041:	e8 fe 09 00 00       	call   801a44 <memmove>
		sys_cputs(buf, m);
  801046:	89 74 24 04          	mov    %esi,0x4(%esp)
  80104a:	89 3c 24             	mov    %edi,(%esp)
  80104d:	e8 84 f0 ff ff       	call   8000d6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801052:	01 f3                	add    %esi,%ebx
  801054:	89 d8                	mov    %ebx,%eax
  801056:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801059:	72 c8                	jb     801023 <devcons_write+0x19>
}
  80105b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <devcons_read>:
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801071:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801075:	75 07                	jne    80107e <devcons_read+0x18>
  801077:	eb 2a                	jmp    8010a3 <devcons_read+0x3d>
		sys_yield();
  801079:	e8 06 f1 ff ff       	call   800184 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80107e:	66 90                	xchg   %ax,%ax
  801080:	e8 6f f0 ff ff       	call   8000f4 <sys_cgetc>
  801085:	85 c0                	test   %eax,%eax
  801087:	74 f0                	je     801079 <devcons_read+0x13>
	if (c < 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 16                	js     8010a3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80108d:	83 f8 04             	cmp    $0x4,%eax
  801090:	74 0c                	je     80109e <devcons_read+0x38>
	*(char*)vbuf = c;
  801092:	8b 55 0c             	mov    0xc(%ebp),%edx
  801095:	88 02                	mov    %al,(%edx)
	return 1;
  801097:	b8 01 00 00 00       	mov    $0x1,%eax
  80109c:	eb 05                	jmp    8010a3 <devcons_read+0x3d>
		return 0;
  80109e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    

008010a5 <cputchar>:
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8010b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b8:	00 
  8010b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010bc:	89 04 24             	mov    %eax,(%esp)
  8010bf:	e8 12 f0 ff ff       	call   8000d6 <sys_cputs>
}
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <getchar>:
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8010cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010d3:	00 
  8010d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e2:	e8 2e f6 ff ff       	call   800715 <read>
	if (r < 0)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 0f                	js     8010fa <getchar+0x34>
	if (r < 1)
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	7e 06                	jle    8010f5 <getchar+0x2f>
	return c;
  8010ef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010f3:	eb 05                	jmp    8010fa <getchar+0x34>
		return -E_EOF;
  8010f5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <iscons>:
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801105:	89 44 24 04          	mov    %eax,0x4(%esp)
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
  80110c:	89 04 24             	mov    %eax,(%esp)
  80110f:	e8 72 f3 ff ff       	call   800486 <fd_lookup>
  801114:	85 c0                	test   %eax,%eax
  801116:	78 11                	js     801129 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801121:	39 10                	cmp    %edx,(%eax)
  801123:	0f 94 c0             	sete   %al
  801126:	0f b6 c0             	movzbl %al,%eax
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <opencons>:
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801131:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801134:	89 04 24             	mov    %eax,(%esp)
  801137:	e8 fb f2 ff ff       	call   800437 <fd_alloc>
		return r;
  80113c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 40                	js     801182 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801142:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801149:	00 
  80114a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801151:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801158:	e8 46 f0 ff ff       	call   8001a3 <sys_page_alloc>
		return r;
  80115d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 1f                	js     801182 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801163:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801169:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80116e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801171:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801178:	89 04 24             	mov    %eax,(%esp)
  80117b:	e8 90 f2 ff ff       	call   800410 <fd2num>
  801180:	89 c2                	mov    %eax,%edx
}
  801182:	89 d0                	mov    %edx,%eax
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80118e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801191:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801197:	e8 c9 ef ff ff       	call   800165 <sys_getenvid>
  80119c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119f:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b2:	c7 04 24 20 21 80 00 	movl   $0x802120,(%esp)
  8011b9:	e8 c1 00 00 00       	call   80127f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 51 00 00 00       	call   80121e <vcprintf>
	cprintf("\n");
  8011cd:	c7 04 24 0d 21 80 00 	movl   $0x80210d,(%esp)
  8011d4:	e8 a6 00 00 00       	call   80127f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011d9:	cc                   	int3   
  8011da:	eb fd                	jmp    8011d9 <_panic+0x53>

008011dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 14             	sub    $0x14,%esp
  8011e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011e6:	8b 13                	mov    (%ebx),%edx
  8011e8:	8d 42 01             	lea    0x1(%edx),%eax
  8011eb:	89 03                	mov    %eax,(%ebx)
  8011ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8011f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011f9:	75 19                	jne    801214 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8011fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801202:	00 
  801203:	8d 43 08             	lea    0x8(%ebx),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 c8 ee ff ff       	call   8000d6 <sys_cputs>
		b->idx = 0;
  80120e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801214:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801218:	83 c4 14             	add    $0x14,%esp
  80121b:	5b                   	pop    %ebx
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801227:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80122e:	00 00 00 
	b.cnt = 0;
  801231:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801238:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80123b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
  801245:	89 44 24 08          	mov    %eax,0x8(%esp)
  801249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80124f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801253:	c7 04 24 dc 11 80 00 	movl   $0x8011dc,(%esp)
  80125a:	e8 af 01 00 00       	call   80140e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80125f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801265:	89 44 24 04          	mov    %eax,0x4(%esp)
  801269:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80126f:	89 04 24             	mov    %eax,(%esp)
  801272:	e8 5f ee ff ff       	call   8000d6 <sys_cputs>

	return b.cnt;
}
  801277:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801285:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128c:	8b 45 08             	mov    0x8(%ebp),%eax
  80128f:	89 04 24             	mov    %eax,(%esp)
  801292:	e8 87 ff ff ff       	call   80121e <vcprintf>
	va_end(ap);

	return cnt;
}
  801297:	c9                   	leave  
  801298:	c3                   	ret    
  801299:	66 90                	xchg   %ax,%ax
  80129b:	66 90                	xchg   %ax,%ax
  80129d:	66 90                	xchg   %ax,%ax
  80129f:	90                   	nop

008012a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 3c             	sub    $0x3c,%esp
  8012a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ac:	89 d7                	mov    %edx,%edi
  8012ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8012bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012cd:	39 d9                	cmp    %ebx,%ecx
  8012cf:	72 05                	jb     8012d6 <printnum+0x36>
  8012d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012d4:	77 69                	ja     80133f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012dd:	83 ee 01             	sub    $0x1,%esi
  8012e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012f0:	89 c3                	mov    %eax,%ebx
  8012f2:	89 d6                	mov    %edx,%esi
  8012f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801302:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801305:	89 04 24             	mov    %eax,(%esp)
  801308:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80130b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130f:	e8 3c 0a 00 00       	call   801d50 <__udivdi3>
  801314:	89 d9                	mov    %ebx,%ecx
  801316:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80131a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80131e:	89 04 24             	mov    %eax,(%esp)
  801321:	89 54 24 04          	mov    %edx,0x4(%esp)
  801325:	89 fa                	mov    %edi,%edx
  801327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80132a:	e8 71 ff ff ff       	call   8012a0 <printnum>
  80132f:	eb 1b                	jmp    80134c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801335:	8b 45 18             	mov    0x18(%ebp),%eax
  801338:	89 04 24             	mov    %eax,(%esp)
  80133b:	ff d3                	call   *%ebx
  80133d:	eb 03                	jmp    801342 <printnum+0xa2>
  80133f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  801342:	83 ee 01             	sub    $0x1,%esi
  801345:	85 f6                	test   %esi,%esi
  801347:	7f e8                	jg     801331 <printnum+0x91>
  801349:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80134c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801350:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801354:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801357:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80135a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80135e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80136b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136f:	e8 0c 0b 00 00       	call   801e80 <__umoddi3>
  801374:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801378:	0f be 80 43 21 80 00 	movsbl 0x802143(%eax),%eax
  80137f:	89 04 24             	mov    %eax,(%esp)
  801382:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801385:	ff d0                	call   *%eax
}
  801387:	83 c4 3c             	add    $0x3c,%esp
  80138a:	5b                   	pop    %ebx
  80138b:	5e                   	pop    %esi
  80138c:	5f                   	pop    %edi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801392:	83 fa 01             	cmp    $0x1,%edx
  801395:	7e 0e                	jle    8013a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801397:	8b 10                	mov    (%eax),%edx
  801399:	8d 4a 08             	lea    0x8(%edx),%ecx
  80139c:	89 08                	mov    %ecx,(%eax)
  80139e:	8b 02                	mov    (%edx),%eax
  8013a0:	8b 52 04             	mov    0x4(%edx),%edx
  8013a3:	eb 22                	jmp    8013c7 <getuint+0x38>
	else if (lflag)
  8013a5:	85 d2                	test   %edx,%edx
  8013a7:	74 10                	je     8013b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8013a9:	8b 10                	mov    (%eax),%edx
  8013ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013ae:	89 08                	mov    %ecx,(%eax)
  8013b0:	8b 02                	mov    (%edx),%eax
  8013b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b7:	eb 0e                	jmp    8013c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8013b9:	8b 10                	mov    (%eax),%edx
  8013bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013be:	89 08                	mov    %ecx,(%eax)
  8013c0:	8b 02                	mov    (%edx),%eax
  8013c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    

008013c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8013d3:	8b 10                	mov    (%eax),%edx
  8013d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8013d8:	73 0a                	jae    8013e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8013da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013dd:	89 08                	mov    %ecx,(%eax)
  8013df:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e2:	88 02                	mov    %al,(%edx)
}
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <printfmt>:
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8013ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801401:	8b 45 08             	mov    0x8(%ebp),%eax
  801404:	89 04 24             	mov    %eax,(%esp)
  801407:	e8 02 00 00 00       	call   80140e <vprintfmt>
}
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <vprintfmt>:
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	57                   	push   %edi
  801412:	56                   	push   %esi
  801413:	53                   	push   %ebx
  801414:	83 ec 3c             	sub    $0x3c,%esp
  801417:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80141a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80141d:	eb 1f                	jmp    80143e <vprintfmt+0x30>
			if (ch == '\0'){
  80141f:	85 c0                	test   %eax,%eax
  801421:	75 0f                	jne    801432 <vprintfmt+0x24>
				color = 0x0100;
  801423:	c7 05 04 40 80 00 00 	movl   $0x100,0x804004
  80142a:	01 00 00 
  80142d:	e9 b3 03 00 00       	jmp    8017e5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  801432:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801436:	89 04 24             	mov    %eax,(%esp)
  801439:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80143c:	89 f3                	mov    %esi,%ebx
  80143e:	8d 73 01             	lea    0x1(%ebx),%esi
  801441:	0f b6 03             	movzbl (%ebx),%eax
  801444:	83 f8 25             	cmp    $0x25,%eax
  801447:	75 d6                	jne    80141f <vprintfmt+0x11>
  801449:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80144d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801454:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80145b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801462:	ba 00 00 00 00       	mov    $0x0,%edx
  801467:	eb 1d                	jmp    801486 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801469:	89 de                	mov    %ebx,%esi
			padc = '-';
  80146b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80146f:	eb 15                	jmp    801486 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801471:	89 de                	mov    %ebx,%esi
			padc = '0';
  801473:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801477:	eb 0d                	jmp    801486 <vprintfmt+0x78>
				width = precision, precision = -1;
  801479:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80147c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80147f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801486:	8d 5e 01             	lea    0x1(%esi),%ebx
  801489:	0f b6 0e             	movzbl (%esi),%ecx
  80148c:	0f b6 c1             	movzbl %cl,%eax
  80148f:	83 e9 23             	sub    $0x23,%ecx
  801492:	80 f9 55             	cmp    $0x55,%cl
  801495:	0f 87 2a 03 00 00    	ja     8017c5 <vprintfmt+0x3b7>
  80149b:	0f b6 c9             	movzbl %cl,%ecx
  80149e:	ff 24 8d 80 22 80 00 	jmp    *0x802280(,%ecx,4)
  8014a5:	89 de                	mov    %ebx,%esi
  8014a7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8014ac:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8014af:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8014b3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014b6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8014b9:	83 fb 09             	cmp    $0x9,%ebx
  8014bc:	77 36                	ja     8014f4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8014be:	83 c6 01             	add    $0x1,%esi
			}
  8014c1:	eb e9                	jmp    8014ac <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8014c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8014c9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8014cc:	8b 00                	mov    (%eax),%eax
  8014ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014d1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8014d3:	eb 22                	jmp    8014f7 <vprintfmt+0xe9>
  8014d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014d8:	85 c9                	test   %ecx,%ecx
  8014da:	b8 00 00 00 00       	mov    $0x0,%eax
  8014df:	0f 49 c1             	cmovns %ecx,%eax
  8014e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014e5:	89 de                	mov    %ebx,%esi
  8014e7:	eb 9d                	jmp    801486 <vprintfmt+0x78>
  8014e9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8014eb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8014f2:	eb 92                	jmp    801486 <vprintfmt+0x78>
  8014f4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8014f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014fb:	79 89                	jns    801486 <vprintfmt+0x78>
  8014fd:	e9 77 ff ff ff       	jmp    801479 <vprintfmt+0x6b>
			lflag++;
  801502:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  801505:	89 de                	mov    %ebx,%esi
			goto reswitch;
  801507:	e9 7a ff ff ff       	jmp    801486 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80150c:	8b 45 14             	mov    0x14(%ebp),%eax
  80150f:	8d 50 04             	lea    0x4(%eax),%edx
  801512:	89 55 14             	mov    %edx,0x14(%ebp)
  801515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801519:	8b 00                	mov    (%eax),%eax
  80151b:	89 04 24             	mov    %eax,(%esp)
  80151e:	ff 55 08             	call   *0x8(%ebp)
			break;
  801521:	e9 18 ff ff ff       	jmp    80143e <vprintfmt+0x30>
			err = va_arg(ap, int);
  801526:	8b 45 14             	mov    0x14(%ebp),%eax
  801529:	8d 50 04             	lea    0x4(%eax),%edx
  80152c:	89 55 14             	mov    %edx,0x14(%ebp)
  80152f:	8b 00                	mov    (%eax),%eax
  801531:	99                   	cltd   
  801532:	31 d0                	xor    %edx,%eax
  801534:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801536:	83 f8 0f             	cmp    $0xf,%eax
  801539:	7f 0b                	jg     801546 <vprintfmt+0x138>
  80153b:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  801542:	85 d2                	test   %edx,%edx
  801544:	75 20                	jne    801566 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  801546:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80154a:	c7 44 24 08 5b 21 80 	movl   $0x80215b,0x8(%esp)
  801551:	00 
  801552:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	89 04 24             	mov    %eax,(%esp)
  80155c:	e8 85 fe ff ff       	call   8013e6 <printfmt>
  801561:	e9 d8 fe ff ff       	jmp    80143e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  801566:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80156a:	c7 44 24 08 e6 20 80 	movl   $0x8020e6,0x8(%esp)
  801571:	00 
  801572:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801576:	8b 45 08             	mov    0x8(%ebp),%eax
  801579:	89 04 24             	mov    %eax,(%esp)
  80157c:	e8 65 fe ff ff       	call   8013e6 <printfmt>
  801581:	e9 b8 fe ff ff       	jmp    80143e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  801586:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801589:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80158c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80158f:	8b 45 14             	mov    0x14(%ebp),%eax
  801592:	8d 50 04             	lea    0x4(%eax),%edx
  801595:	89 55 14             	mov    %edx,0x14(%ebp)
  801598:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80159a:	85 f6                	test   %esi,%esi
  80159c:	b8 54 21 80 00       	mov    $0x802154,%eax
  8015a1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8015a4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8015a8:	0f 84 97 00 00 00    	je     801645 <vprintfmt+0x237>
  8015ae:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8015b2:	0f 8e 9b 00 00 00    	jle    801653 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015bc:	89 34 24             	mov    %esi,(%esp)
  8015bf:	e8 c4 02 00 00       	call   801888 <strnlen>
  8015c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015c7:	29 c2                	sub    %eax,%edx
  8015c9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8015cc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8015d3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8015d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8015d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015dc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8015de:	eb 0f                	jmp    8015ef <vprintfmt+0x1e1>
					putch(padc, putdat);
  8015e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015e7:	89 04 24             	mov    %eax,(%esp)
  8015ea:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8015ec:	83 eb 01             	sub    $0x1,%ebx
  8015ef:	85 db                	test   %ebx,%ebx
  8015f1:	7f ed                	jg     8015e0 <vprintfmt+0x1d2>
  8015f3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015f9:	85 d2                	test   %edx,%edx
  8015fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801600:	0f 49 c2             	cmovns %edx,%eax
  801603:	29 c2                	sub    %eax,%edx
  801605:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801608:	89 d7                	mov    %edx,%edi
  80160a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80160d:	eb 50                	jmp    80165f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80160f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801613:	74 1e                	je     801633 <vprintfmt+0x225>
  801615:	0f be d2             	movsbl %dl,%edx
  801618:	83 ea 20             	sub    $0x20,%edx
  80161b:	83 fa 5e             	cmp    $0x5e,%edx
  80161e:	76 13                	jbe    801633 <vprintfmt+0x225>
					putch('?', putdat);
  801620:	8b 45 0c             	mov    0xc(%ebp),%eax
  801623:	89 44 24 04          	mov    %eax,0x4(%esp)
  801627:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80162e:	ff 55 08             	call   *0x8(%ebp)
  801631:	eb 0d                	jmp    801640 <vprintfmt+0x232>
					putch(ch, putdat);
  801633:	8b 55 0c             	mov    0xc(%ebp),%edx
  801636:	89 54 24 04          	mov    %edx,0x4(%esp)
  80163a:	89 04 24             	mov    %eax,(%esp)
  80163d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801640:	83 ef 01             	sub    $0x1,%edi
  801643:	eb 1a                	jmp    80165f <vprintfmt+0x251>
  801645:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801648:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80164b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80164e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801651:	eb 0c                	jmp    80165f <vprintfmt+0x251>
  801653:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801656:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801659:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80165c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80165f:	83 c6 01             	add    $0x1,%esi
  801662:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801666:	0f be c2             	movsbl %dl,%eax
  801669:	85 c0                	test   %eax,%eax
  80166b:	74 27                	je     801694 <vprintfmt+0x286>
  80166d:	85 db                	test   %ebx,%ebx
  80166f:	78 9e                	js     80160f <vprintfmt+0x201>
  801671:	83 eb 01             	sub    $0x1,%ebx
  801674:	79 99                	jns    80160f <vprintfmt+0x201>
  801676:	89 f8                	mov    %edi,%eax
  801678:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80167b:	8b 75 08             	mov    0x8(%ebp),%esi
  80167e:	89 c3                	mov    %eax,%ebx
  801680:	eb 1a                	jmp    80169c <vprintfmt+0x28e>
				putch(' ', putdat);
  801682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801686:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80168d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80168f:	83 eb 01             	sub    $0x1,%ebx
  801692:	eb 08                	jmp    80169c <vprintfmt+0x28e>
  801694:	89 fb                	mov    %edi,%ebx
  801696:	8b 75 08             	mov    0x8(%ebp),%esi
  801699:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80169c:	85 db                	test   %ebx,%ebx
  80169e:	7f e2                	jg     801682 <vprintfmt+0x274>
  8016a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8016a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016a6:	e9 93 fd ff ff       	jmp    80143e <vprintfmt+0x30>
	if (lflag >= 2)
  8016ab:	83 fa 01             	cmp    $0x1,%edx
  8016ae:	7e 16                	jle    8016c6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8016b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b3:	8d 50 08             	lea    0x8(%eax),%edx
  8016b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b9:	8b 50 04             	mov    0x4(%eax),%edx
  8016bc:	8b 00                	mov    (%eax),%eax
  8016be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8016c4:	eb 32                	jmp    8016f8 <vprintfmt+0x2ea>
	else if (lflag)
  8016c6:	85 d2                	test   %edx,%edx
  8016c8:	74 18                	je     8016e2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8016ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8016cd:	8d 50 04             	lea    0x4(%eax),%edx
  8016d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d3:	8b 30                	mov    (%eax),%esi
  8016d5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016d8:	89 f0                	mov    %esi,%eax
  8016da:	c1 f8 1f             	sar    $0x1f,%eax
  8016dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e0:	eb 16                	jmp    8016f8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8016e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e5:	8d 50 04             	lea    0x4(%eax),%edx
  8016e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016eb:	8b 30                	mov    (%eax),%esi
  8016ed:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016f0:	89 f0                	mov    %esi,%eax
  8016f2:	c1 f8 1f             	sar    $0x1f,%eax
  8016f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8016f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8016fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  801703:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801707:	0f 89 80 00 00 00    	jns    80178d <vprintfmt+0x37f>
				putch('-', putdat);
  80170d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801711:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801718:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80171b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80171e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801721:	f7 d8                	neg    %eax
  801723:	83 d2 00             	adc    $0x0,%edx
  801726:	f7 da                	neg    %edx
			base = 10;
  801728:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80172d:	eb 5e                	jmp    80178d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80172f:	8d 45 14             	lea    0x14(%ebp),%eax
  801732:	e8 58 fc ff ff       	call   80138f <getuint>
			base = 10;
  801737:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80173c:	eb 4f                	jmp    80178d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80173e:	8d 45 14             	lea    0x14(%ebp),%eax
  801741:	e8 49 fc ff ff       	call   80138f <getuint>
            base = 8;
  801746:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80174b:	eb 40                	jmp    80178d <vprintfmt+0x37f>
			putch('0', putdat);
  80174d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801751:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801758:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80175b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80175f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801766:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  801769:	8b 45 14             	mov    0x14(%ebp),%eax
  80176c:	8d 50 04             	lea    0x4(%eax),%edx
  80176f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801772:	8b 00                	mov    (%eax),%eax
  801774:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  801779:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80177e:	eb 0d                	jmp    80178d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  801780:	8d 45 14             	lea    0x14(%ebp),%eax
  801783:	e8 07 fc ff ff       	call   80138f <getuint>
			base = 16;
  801788:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80178d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801791:	89 74 24 10          	mov    %esi,0x10(%esp)
  801795:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801798:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80179c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017a0:	89 04 24             	mov    %eax,(%esp)
  8017a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017a7:	89 fa                	mov    %edi,%edx
  8017a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ac:	e8 ef fa ff ff       	call   8012a0 <printnum>
			break;
  8017b1:	e9 88 fc ff ff       	jmp    80143e <vprintfmt+0x30>
			putch(ch, putdat);
  8017b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017ba:	89 04 24             	mov    %eax,(%esp)
  8017bd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8017c0:	e9 79 fc ff ff       	jmp    80143e <vprintfmt+0x30>
			putch('%', putdat);
  8017c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017c9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017d0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017d3:	89 f3                	mov    %esi,%ebx
  8017d5:	eb 03                	jmp    8017da <vprintfmt+0x3cc>
  8017d7:	83 eb 01             	sub    $0x1,%ebx
  8017da:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017de:	75 f7                	jne    8017d7 <vprintfmt+0x3c9>
  8017e0:	e9 59 fc ff ff       	jmp    80143e <vprintfmt+0x30>
}
  8017e5:	83 c4 3c             	add    $0x3c,%esp
  8017e8:	5b                   	pop    %ebx
  8017e9:	5e                   	pop    %esi
  8017ea:	5f                   	pop    %edi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	83 ec 28             	sub    $0x28,%esp
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801800:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801803:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80180a:	85 c0                	test   %eax,%eax
  80180c:	74 30                	je     80183e <vsnprintf+0x51>
  80180e:	85 d2                	test   %edx,%edx
  801810:	7e 2c                	jle    80183e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801812:	8b 45 14             	mov    0x14(%ebp),%eax
  801815:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801819:	8b 45 10             	mov    0x10(%ebp),%eax
  80181c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801820:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	c7 04 24 c9 13 80 00 	movl   $0x8013c9,(%esp)
  80182e:	e8 db fb ff ff       	call   80140e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801833:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801836:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183c:	eb 05                	jmp    801843 <vsnprintf+0x56>
		return -E_INVAL;
  80183e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80184b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80184e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801852:	8b 45 10             	mov    0x10(%ebp),%eax
  801855:	89 44 24 08          	mov    %eax,0x8(%esp)
  801859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801860:	8b 45 08             	mov    0x8(%ebp),%eax
  801863:	89 04 24             	mov    %eax,(%esp)
  801866:	e8 82 ff ff ff       	call   8017ed <vsnprintf>
	va_end(ap);

	return rc;
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    
  80186d:	66 90                	xchg   %ax,%ax
  80186f:	90                   	nop

00801870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
  80187b:	eb 03                	jmp    801880 <strlen+0x10>
		n++;
  80187d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801880:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801884:	75 f7                	jne    80187d <strlen+0xd>
	return n;
}
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801891:	b8 00 00 00 00       	mov    $0x0,%eax
  801896:	eb 03                	jmp    80189b <strnlen+0x13>
		n++;
  801898:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80189b:	39 d0                	cmp    %edx,%eax
  80189d:	74 06                	je     8018a5 <strnlen+0x1d>
  80189f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8018a3:	75 f3                	jne    801898 <strnlen+0x10>
	return n;
}
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018b1:	89 c2                	mov    %eax,%edx
  8018b3:	83 c2 01             	add    $0x1,%edx
  8018b6:	83 c1 01             	add    $0x1,%ecx
  8018b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8018bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018c0:	84 db                	test   %bl,%bl
  8018c2:	75 ef                	jne    8018b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8018c4:	5b                   	pop    %ebx
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	53                   	push   %ebx
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018d1:	89 1c 24             	mov    %ebx,(%esp)
  8018d4:	e8 97 ff ff ff       	call   801870 <strlen>
	strcpy(dst + len, src);
  8018d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018e0:	01 d8                	add    %ebx,%eax
  8018e2:	89 04 24             	mov    %eax,(%esp)
  8018e5:	e8 bd ff ff ff       	call   8018a7 <strcpy>
	return dst;
}
  8018ea:	89 d8                	mov    %ebx,%eax
  8018ec:	83 c4 08             	add    $0x8,%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fd:	89 f3                	mov    %esi,%ebx
  8018ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801902:	89 f2                	mov    %esi,%edx
  801904:	eb 0f                	jmp    801915 <strncpy+0x23>
		*dst++ = *src;
  801906:	83 c2 01             	add    $0x1,%edx
  801909:	0f b6 01             	movzbl (%ecx),%eax
  80190c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80190f:	80 39 01             	cmpb   $0x1,(%ecx)
  801912:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801915:	39 da                	cmp    %ebx,%edx
  801917:	75 ed                	jne    801906 <strncpy+0x14>
	}
	return ret;
}
  801919:	89 f0                	mov    %esi,%eax
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	8b 75 08             	mov    0x8(%ebp),%esi
  801927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80192d:	89 f0                	mov    %esi,%eax
  80192f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801933:	85 c9                	test   %ecx,%ecx
  801935:	75 0b                	jne    801942 <strlcpy+0x23>
  801937:	eb 1d                	jmp    801956 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801939:	83 c0 01             	add    $0x1,%eax
  80193c:	83 c2 01             	add    $0x1,%edx
  80193f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801942:	39 d8                	cmp    %ebx,%eax
  801944:	74 0b                	je     801951 <strlcpy+0x32>
  801946:	0f b6 0a             	movzbl (%edx),%ecx
  801949:	84 c9                	test   %cl,%cl
  80194b:	75 ec                	jne    801939 <strlcpy+0x1a>
  80194d:	89 c2                	mov    %eax,%edx
  80194f:	eb 02                	jmp    801953 <strlcpy+0x34>
  801951:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  801953:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801956:	29 f0                	sub    %esi,%eax
}
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801962:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801965:	eb 06                	jmp    80196d <strcmp+0x11>
		p++, q++;
  801967:	83 c1 01             	add    $0x1,%ecx
  80196a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80196d:	0f b6 01             	movzbl (%ecx),%eax
  801970:	84 c0                	test   %al,%al
  801972:	74 04                	je     801978 <strcmp+0x1c>
  801974:	3a 02                	cmp    (%edx),%al
  801976:	74 ef                	je     801967 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801978:	0f b6 c0             	movzbl %al,%eax
  80197b:	0f b6 12             	movzbl (%edx),%edx
  80197e:	29 d0                	sub    %edx,%eax
}
  801980:	5d                   	pop    %ebp
  801981:	c3                   	ret    

00801982 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	53                   	push   %ebx
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80198c:	89 c3                	mov    %eax,%ebx
  80198e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801991:	eb 06                	jmp    801999 <strncmp+0x17>
		n--, p++, q++;
  801993:	83 c0 01             	add    $0x1,%eax
  801996:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801999:	39 d8                	cmp    %ebx,%eax
  80199b:	74 15                	je     8019b2 <strncmp+0x30>
  80199d:	0f b6 08             	movzbl (%eax),%ecx
  8019a0:	84 c9                	test   %cl,%cl
  8019a2:	74 04                	je     8019a8 <strncmp+0x26>
  8019a4:	3a 0a                	cmp    (%edx),%cl
  8019a6:	74 eb                	je     801993 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8019a8:	0f b6 00             	movzbl (%eax),%eax
  8019ab:	0f b6 12             	movzbl (%edx),%edx
  8019ae:	29 d0                	sub    %edx,%eax
  8019b0:	eb 05                	jmp    8019b7 <strncmp+0x35>
		return 0;
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b7:	5b                   	pop    %ebx
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8019c4:	eb 07                	jmp    8019cd <strchr+0x13>
		if (*s == c)
  8019c6:	38 ca                	cmp    %cl,%dl
  8019c8:	74 0f                	je     8019d9 <strchr+0x1f>
	for (; *s; s++)
  8019ca:	83 c0 01             	add    $0x1,%eax
  8019cd:	0f b6 10             	movzbl (%eax),%edx
  8019d0:	84 d2                	test   %dl,%dl
  8019d2:	75 f2                	jne    8019c6 <strchr+0xc>
			return (char *) s;
	return 0;
  8019d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8019e5:	eb 07                	jmp    8019ee <strfind+0x13>
		if (*s == c)
  8019e7:	38 ca                	cmp    %cl,%dl
  8019e9:	74 0a                	je     8019f5 <strfind+0x1a>
	for (; *s; s++)
  8019eb:	83 c0 01             	add    $0x1,%eax
  8019ee:	0f b6 10             	movzbl (%eax),%edx
  8019f1:	84 d2                	test   %dl,%dl
  8019f3:	75 f2                	jne    8019e7 <strfind+0xc>
			break;
	return (char *) s;
}
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	57                   	push   %edi
  8019fb:	56                   	push   %esi
  8019fc:	53                   	push   %ebx
  8019fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801a03:	85 c9                	test   %ecx,%ecx
  801a05:	74 36                	je     801a3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801a07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a0d:	75 28                	jne    801a37 <memset+0x40>
  801a0f:	f6 c1 03             	test   $0x3,%cl
  801a12:	75 23                	jne    801a37 <memset+0x40>
		c &= 0xFF;
  801a14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801a18:	89 d3                	mov    %edx,%ebx
  801a1a:	c1 e3 08             	shl    $0x8,%ebx
  801a1d:	89 d6                	mov    %edx,%esi
  801a1f:	c1 e6 18             	shl    $0x18,%esi
  801a22:	89 d0                	mov    %edx,%eax
  801a24:	c1 e0 10             	shl    $0x10,%eax
  801a27:	09 f0                	or     %esi,%eax
  801a29:	09 c2                	or     %eax,%edx
  801a2b:	89 d0                	mov    %edx,%eax
  801a2d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a2f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801a32:	fc                   	cld    
  801a33:	f3 ab                	rep stos %eax,%es:(%edi)
  801a35:	eb 06                	jmp    801a3d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3a:	fc                   	cld    
  801a3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a3d:	89 f8                	mov    %edi,%eax
  801a3f:	5b                   	pop    %ebx
  801a40:	5e                   	pop    %esi
  801a41:	5f                   	pop    %edi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a52:	39 c6                	cmp    %eax,%esi
  801a54:	73 35                	jae    801a8b <memmove+0x47>
  801a56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a59:	39 d0                	cmp    %edx,%eax
  801a5b:	73 2e                	jae    801a8b <memmove+0x47>
		s += n;
		d += n;
  801a5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a60:	89 d6                	mov    %edx,%esi
  801a62:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a6a:	75 13                	jne    801a7f <memmove+0x3b>
  801a6c:	f6 c1 03             	test   $0x3,%cl
  801a6f:	75 0e                	jne    801a7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a71:	83 ef 04             	sub    $0x4,%edi
  801a74:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a77:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801a7a:	fd                   	std    
  801a7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a7d:	eb 09                	jmp    801a88 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a7f:	83 ef 01             	sub    $0x1,%edi
  801a82:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801a85:	fd                   	std    
  801a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a88:	fc                   	cld    
  801a89:	eb 1d                	jmp    801aa8 <memmove+0x64>
  801a8b:	89 f2                	mov    %esi,%edx
  801a8d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a8f:	f6 c2 03             	test   $0x3,%dl
  801a92:	75 0f                	jne    801aa3 <memmove+0x5f>
  801a94:	f6 c1 03             	test   $0x3,%cl
  801a97:	75 0a                	jne    801aa3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a99:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801a9c:	89 c7                	mov    %eax,%edi
  801a9e:	fc                   	cld    
  801a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801aa1:	eb 05                	jmp    801aa8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801aa3:	89 c7                	mov    %eax,%edi
  801aa5:	fc                   	cld    
  801aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801aa8:	5e                   	pop    %esi
  801aa9:	5f                   	pop    %edi
  801aaa:	5d                   	pop    %ebp
  801aab:	c3                   	ret    

00801aac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac3:	89 04 24             	mov    %eax,(%esp)
  801ac6:	e8 79 ff ff ff       	call   801a44 <memmove>
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad8:	89 d6                	mov    %edx,%esi
  801ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801add:	eb 1a                	jmp    801af9 <memcmp+0x2c>
		if (*s1 != *s2)
  801adf:	0f b6 02             	movzbl (%edx),%eax
  801ae2:	0f b6 19             	movzbl (%ecx),%ebx
  801ae5:	38 d8                	cmp    %bl,%al
  801ae7:	74 0a                	je     801af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ae9:	0f b6 c0             	movzbl %al,%eax
  801aec:	0f b6 db             	movzbl %bl,%ebx
  801aef:	29 d8                	sub    %ebx,%eax
  801af1:	eb 0f                	jmp    801b02 <memcmp+0x35>
		s1++, s2++;
  801af3:	83 c2 01             	add    $0x1,%edx
  801af6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  801af9:	39 f2                	cmp    %esi,%edx
  801afb:	75 e2                	jne    801adf <memcmp+0x12>
	}

	return 0;
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801b0f:	89 c2                	mov    %eax,%edx
  801b11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801b14:	eb 07                	jmp    801b1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801b16:	38 08                	cmp    %cl,(%eax)
  801b18:	74 07                	je     801b21 <memfind+0x1b>
	for (; s < ends; s++)
  801b1a:	83 c0 01             	add    $0x1,%eax
  801b1d:	39 d0                	cmp    %edx,%eax
  801b1f:	72 f5                	jb     801b16 <memfind+0x10>
			break;
	return (void *) s;
}
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	57                   	push   %edi
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 55 08             	mov    0x8(%ebp),%edx
  801b2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b2f:	eb 03                	jmp    801b34 <strtol+0x11>
		s++;
  801b31:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801b34:	0f b6 0a             	movzbl (%edx),%ecx
  801b37:	80 f9 09             	cmp    $0x9,%cl
  801b3a:	74 f5                	je     801b31 <strtol+0xe>
  801b3c:	80 f9 20             	cmp    $0x20,%cl
  801b3f:	74 f0                	je     801b31 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801b41:	80 f9 2b             	cmp    $0x2b,%cl
  801b44:	75 0a                	jne    801b50 <strtol+0x2d>
		s++;
  801b46:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801b49:	bf 00 00 00 00       	mov    $0x0,%edi
  801b4e:	eb 11                	jmp    801b61 <strtol+0x3e>
  801b50:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  801b55:	80 f9 2d             	cmp    $0x2d,%cl
  801b58:	75 07                	jne    801b61 <strtol+0x3e>
		s++, neg = 1;
  801b5a:	8d 52 01             	lea    0x1(%edx),%edx
  801b5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b66:	75 15                	jne    801b7d <strtol+0x5a>
  801b68:	80 3a 30             	cmpb   $0x30,(%edx)
  801b6b:	75 10                	jne    801b7d <strtol+0x5a>
  801b6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b71:	75 0a                	jne    801b7d <strtol+0x5a>
		s += 2, base = 16;
  801b73:	83 c2 02             	add    $0x2,%edx
  801b76:	b8 10 00 00 00       	mov    $0x10,%eax
  801b7b:	eb 10                	jmp    801b8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	75 0c                	jne    801b8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801b81:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801b83:	80 3a 30             	cmpb   $0x30,(%edx)
  801b86:	75 05                	jne    801b8d <strtol+0x6a>
		s++, base = 8;
  801b88:	83 c2 01             	add    $0x1,%edx
  801b8b:	b0 08                	mov    $0x8,%al
		base = 10;
  801b8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b95:	0f b6 0a             	movzbl (%edx),%ecx
  801b98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b9b:	89 f0                	mov    %esi,%eax
  801b9d:	3c 09                	cmp    $0x9,%al
  801b9f:	77 08                	ja     801ba9 <strtol+0x86>
			dig = *s - '0';
  801ba1:	0f be c9             	movsbl %cl,%ecx
  801ba4:	83 e9 30             	sub    $0x30,%ecx
  801ba7:	eb 20                	jmp    801bc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801ba9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801bac:	89 f0                	mov    %esi,%eax
  801bae:	3c 19                	cmp    $0x19,%al
  801bb0:	77 08                	ja     801bba <strtol+0x97>
			dig = *s - 'a' + 10;
  801bb2:	0f be c9             	movsbl %cl,%ecx
  801bb5:	83 e9 57             	sub    $0x57,%ecx
  801bb8:	eb 0f                	jmp    801bc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  801bba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801bbd:	89 f0                	mov    %esi,%eax
  801bbf:	3c 19                	cmp    $0x19,%al
  801bc1:	77 16                	ja     801bd9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801bc3:	0f be c9             	movsbl %cl,%ecx
  801bc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801bc9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801bcc:	7d 0f                	jge    801bdd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  801bce:	83 c2 01             	add    $0x1,%edx
  801bd1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801bd5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801bd7:	eb bc                	jmp    801b95 <strtol+0x72>
  801bd9:	89 d8                	mov    %ebx,%eax
  801bdb:	eb 02                	jmp    801bdf <strtol+0xbc>
  801bdd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801bdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801be3:	74 05                	je     801bea <strtol+0xc7>
		*endptr = (char *) s;
  801be5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801bea:	f7 d8                	neg    %eax
  801bec:	85 ff                	test   %edi,%edi
  801bee:	0f 44 c3             	cmove  %ebx,%eax
}
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5f                   	pop    %edi
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    
  801bf6:	66 90                	xchg   %ax,%ax
  801bf8:	66 90                	xchg   %ax,%ax
  801bfa:	66 90                	xchg   %ax,%ax
  801bfc:	66 90                	xchg   %ax,%ax
  801bfe:	66 90                	xchg   %ax,%ax

00801c00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	83 ec 10             	sub    $0x10,%esp
  801c08:	8b 75 08             	mov    0x8(%ebp),%esi
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801c11:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801c13:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801c18:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801c1b:	89 04 24             	mov    %eax,(%esp)
  801c1e:	e8 96 e7 ff ff       	call   8003b9 <sys_ipc_recv>
    if(r < 0){
  801c23:	85 c0                	test   %eax,%eax
  801c25:	79 16                	jns    801c3d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801c27:	85 f6                	test   %esi,%esi
  801c29:	74 06                	je     801c31 <ipc_recv+0x31>
            *from_env_store = 0;
  801c2b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801c31:	85 db                	test   %ebx,%ebx
  801c33:	74 2c                	je     801c61 <ipc_recv+0x61>
            *perm_store = 0;
  801c35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c3b:	eb 24                	jmp    801c61 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801c3d:	85 f6                	test   %esi,%esi
  801c3f:	74 0a                	je     801c4b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801c41:	a1 08 40 80 00       	mov    0x804008,%eax
  801c46:	8b 40 74             	mov    0x74(%eax),%eax
  801c49:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801c4b:	85 db                	test   %ebx,%ebx
  801c4d:	74 0a                	je     801c59 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801c4f:	a1 08 40 80 00       	mov    0x804008,%eax
  801c54:	8b 40 78             	mov    0x78(%eax),%eax
  801c57:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c59:	a1 08 40 80 00       	mov    0x804008,%eax
  801c5e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	57                   	push   %edi
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	83 ec 1c             	sub    $0x1c,%esp
  801c71:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801c7a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801c7c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801c81:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801c84:	8b 45 14             	mov    0x14(%ebp),%eax
  801c87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c8b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	e8 fb e6 ff ff       	call   800396 <sys_ipc_try_send>
        if(r == 0){
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	74 28                	je     801cc7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801c9f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ca2:	74 1c                	je     801cc0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801ca4:	c7 44 24 08 40 24 80 	movl   $0x802440,0x8(%esp)
  801cab:	00 
  801cac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801cb3:	00 
  801cb4:	c7 04 24 57 24 80 00 	movl   $0x802457,(%esp)
  801cbb:	e8 c6 f4 ff ff       	call   801186 <_panic>
        }
        sys_yield();
  801cc0:	e8 bf e4 ff ff       	call   800184 <sys_yield>
    }
  801cc5:	eb bd                	jmp    801c84 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801cc7:	83 c4 1c             	add    $0x1c,%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5f                   	pop    %edi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cda:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cdd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ce3:	8b 52 50             	mov    0x50(%edx),%edx
  801ce6:	39 ca                	cmp    %ecx,%edx
  801ce8:	75 0d                	jne    801cf7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ced:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cf2:	8b 40 40             	mov    0x40(%eax),%eax
  801cf5:	eb 0e                	jmp    801d05 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801cf7:	83 c0 01             	add    $0x1,%eax
  801cfa:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cff:	75 d9                	jne    801cda <ipc_find_env+0xb>
	return 0;
  801d01:	66 b8 00 00          	mov    $0x0,%ax
}
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d0d:	89 d0                	mov    %edx,%eax
  801d0f:	c1 e8 16             	shr    $0x16,%eax
  801d12:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d19:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801d1e:	f6 c1 01             	test   $0x1,%cl
  801d21:	74 1d                	je     801d40 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801d23:	c1 ea 0c             	shr    $0xc,%edx
  801d26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d2d:	f6 c2 01             	test   $0x1,%dl
  801d30:	74 0e                	je     801d40 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d32:	c1 ea 0c             	shr    $0xc,%edx
  801d35:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d3c:	ef 
  801d3d:	0f b7 c0             	movzwl %ax,%eax
}
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	66 90                	xchg   %ax,%ax
  801d44:	66 90                	xchg   %ax,%ax
  801d46:	66 90                	xchg   %ax,%ax
  801d48:	66 90                	xchg   %ax,%ax
  801d4a:	66 90                	xchg   %ax,%ax
  801d4c:	66 90                	xchg   %ax,%ax
  801d4e:	66 90                	xchg   %ax,%ax

00801d50 <__udivdi3>:
  801d50:	55                   	push   %ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d5a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d5e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d62:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d66:	85 c0                	test   %eax,%eax
  801d68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d6c:	89 ea                	mov    %ebp,%edx
  801d6e:	89 0c 24             	mov    %ecx,(%esp)
  801d71:	75 2d                	jne    801da0 <__udivdi3+0x50>
  801d73:	39 e9                	cmp    %ebp,%ecx
  801d75:	77 61                	ja     801dd8 <__udivdi3+0x88>
  801d77:	85 c9                	test   %ecx,%ecx
  801d79:	89 ce                	mov    %ecx,%esi
  801d7b:	75 0b                	jne    801d88 <__udivdi3+0x38>
  801d7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d82:	31 d2                	xor    %edx,%edx
  801d84:	f7 f1                	div    %ecx
  801d86:	89 c6                	mov    %eax,%esi
  801d88:	31 d2                	xor    %edx,%edx
  801d8a:	89 e8                	mov    %ebp,%eax
  801d8c:	f7 f6                	div    %esi
  801d8e:	89 c5                	mov    %eax,%ebp
  801d90:	89 f8                	mov    %edi,%eax
  801d92:	f7 f6                	div    %esi
  801d94:	89 ea                	mov    %ebp,%edx
  801d96:	83 c4 0c             	add    $0xc,%esp
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi
  801da0:	39 e8                	cmp    %ebp,%eax
  801da2:	77 24                	ja     801dc8 <__udivdi3+0x78>
  801da4:	0f bd e8             	bsr    %eax,%ebp
  801da7:	83 f5 1f             	xor    $0x1f,%ebp
  801daa:	75 3c                	jne    801de8 <__udivdi3+0x98>
  801dac:	8b 74 24 04          	mov    0x4(%esp),%esi
  801db0:	39 34 24             	cmp    %esi,(%esp)
  801db3:	0f 86 9f 00 00 00    	jbe    801e58 <__udivdi3+0x108>
  801db9:	39 d0                	cmp    %edx,%eax
  801dbb:	0f 82 97 00 00 00    	jb     801e58 <__udivdi3+0x108>
  801dc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	31 d2                	xor    %edx,%edx
  801dca:	31 c0                	xor    %eax,%eax
  801dcc:	83 c4 0c             	add    $0xc,%esp
  801dcf:	5e                   	pop    %esi
  801dd0:	5f                   	pop    %edi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    
  801dd3:	90                   	nop
  801dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd8:	89 f8                	mov    %edi,%eax
  801dda:	f7 f1                	div    %ecx
  801ddc:	31 d2                	xor    %edx,%edx
  801dde:	83 c4 0c             	add    $0xc,%esp
  801de1:	5e                   	pop    %esi
  801de2:	5f                   	pop    %edi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
  801de5:	8d 76 00             	lea    0x0(%esi),%esi
  801de8:	89 e9                	mov    %ebp,%ecx
  801dea:	8b 3c 24             	mov    (%esp),%edi
  801ded:	d3 e0                	shl    %cl,%eax
  801def:	89 c6                	mov    %eax,%esi
  801df1:	b8 20 00 00 00       	mov    $0x20,%eax
  801df6:	29 e8                	sub    %ebp,%eax
  801df8:	89 c1                	mov    %eax,%ecx
  801dfa:	d3 ef                	shr    %cl,%edi
  801dfc:	89 e9                	mov    %ebp,%ecx
  801dfe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e02:	8b 3c 24             	mov    (%esp),%edi
  801e05:	09 74 24 08          	or     %esi,0x8(%esp)
  801e09:	89 d6                	mov    %edx,%esi
  801e0b:	d3 e7                	shl    %cl,%edi
  801e0d:	89 c1                	mov    %eax,%ecx
  801e0f:	89 3c 24             	mov    %edi,(%esp)
  801e12:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e16:	d3 ee                	shr    %cl,%esi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	d3 e2                	shl    %cl,%edx
  801e1c:	89 c1                	mov    %eax,%ecx
  801e1e:	d3 ef                	shr    %cl,%edi
  801e20:	09 d7                	or     %edx,%edi
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	89 f8                	mov    %edi,%eax
  801e26:	f7 74 24 08          	divl   0x8(%esp)
  801e2a:	89 d6                	mov    %edx,%esi
  801e2c:	89 c7                	mov    %eax,%edi
  801e2e:	f7 24 24             	mull   (%esp)
  801e31:	39 d6                	cmp    %edx,%esi
  801e33:	89 14 24             	mov    %edx,(%esp)
  801e36:	72 30                	jb     801e68 <__udivdi3+0x118>
  801e38:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e3c:	89 e9                	mov    %ebp,%ecx
  801e3e:	d3 e2                	shl    %cl,%edx
  801e40:	39 c2                	cmp    %eax,%edx
  801e42:	73 05                	jae    801e49 <__udivdi3+0xf9>
  801e44:	3b 34 24             	cmp    (%esp),%esi
  801e47:	74 1f                	je     801e68 <__udivdi3+0x118>
  801e49:	89 f8                	mov    %edi,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	e9 7a ff ff ff       	jmp    801dcc <__udivdi3+0x7c>
  801e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e58:	31 d2                	xor    %edx,%edx
  801e5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5f:	e9 68 ff ff ff       	jmp    801dcc <__udivdi3+0x7c>
  801e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e68:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e6b:	31 d2                	xor    %edx,%edx
  801e6d:	83 c4 0c             	add    $0xc,%esp
  801e70:	5e                   	pop    %esi
  801e71:	5f                   	pop    %edi
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    
  801e74:	66 90                	xchg   %ax,%ax
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	66 90                	xchg   %ax,%ax
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <__umoddi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	83 ec 14             	sub    $0x14,%esp
  801e86:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e8a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e8e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e92:	89 c7                	mov    %eax,%edi
  801e94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e98:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e9c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ea0:	89 34 24             	mov    %esi,(%esp)
  801ea3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	89 c2                	mov    %eax,%edx
  801eab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eaf:	75 17                	jne    801ec8 <__umoddi3+0x48>
  801eb1:	39 fe                	cmp    %edi,%esi
  801eb3:	76 4b                	jbe    801f00 <__umoddi3+0x80>
  801eb5:	89 c8                	mov    %ecx,%eax
  801eb7:	89 fa                	mov    %edi,%edx
  801eb9:	f7 f6                	div    %esi
  801ebb:	89 d0                	mov    %edx,%eax
  801ebd:	31 d2                	xor    %edx,%edx
  801ebf:	83 c4 14             	add    $0x14,%esp
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    
  801ec6:	66 90                	xchg   %ax,%ax
  801ec8:	39 f8                	cmp    %edi,%eax
  801eca:	77 54                	ja     801f20 <__umoddi3+0xa0>
  801ecc:	0f bd e8             	bsr    %eax,%ebp
  801ecf:	83 f5 1f             	xor    $0x1f,%ebp
  801ed2:	75 5c                	jne    801f30 <__umoddi3+0xb0>
  801ed4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ed8:	39 3c 24             	cmp    %edi,(%esp)
  801edb:	0f 87 e7 00 00 00    	ja     801fc8 <__umoddi3+0x148>
  801ee1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ee5:	29 f1                	sub    %esi,%ecx
  801ee7:	19 c7                	sbb    %eax,%edi
  801ee9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ef1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ef5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ef9:	83 c4 14             	add    $0x14,%esp
  801efc:	5e                   	pop    %esi
  801efd:	5f                   	pop    %edi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    
  801f00:	85 f6                	test   %esi,%esi
  801f02:	89 f5                	mov    %esi,%ebp
  801f04:	75 0b                	jne    801f11 <__umoddi3+0x91>
  801f06:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0b:	31 d2                	xor    %edx,%edx
  801f0d:	f7 f6                	div    %esi
  801f0f:	89 c5                	mov    %eax,%ebp
  801f11:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f15:	31 d2                	xor    %edx,%edx
  801f17:	f7 f5                	div    %ebp
  801f19:	89 c8                	mov    %ecx,%eax
  801f1b:	f7 f5                	div    %ebp
  801f1d:	eb 9c                	jmp    801ebb <__umoddi3+0x3b>
  801f1f:	90                   	nop
  801f20:	89 c8                	mov    %ecx,%eax
  801f22:	89 fa                	mov    %edi,%edx
  801f24:	83 c4 14             	add    $0x14,%esp
  801f27:	5e                   	pop    %esi
  801f28:	5f                   	pop    %edi
  801f29:	5d                   	pop    %ebp
  801f2a:	c3                   	ret    
  801f2b:	90                   	nop
  801f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f30:	8b 04 24             	mov    (%esp),%eax
  801f33:	be 20 00 00 00       	mov    $0x20,%esi
  801f38:	89 e9                	mov    %ebp,%ecx
  801f3a:	29 ee                	sub    %ebp,%esi
  801f3c:	d3 e2                	shl    %cl,%edx
  801f3e:	89 f1                	mov    %esi,%ecx
  801f40:	d3 e8                	shr    %cl,%eax
  801f42:	89 e9                	mov    %ebp,%ecx
  801f44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f48:	8b 04 24             	mov    (%esp),%eax
  801f4b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f4f:	89 fa                	mov    %edi,%edx
  801f51:	d3 e0                	shl    %cl,%eax
  801f53:	89 f1                	mov    %esi,%ecx
  801f55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f59:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f5d:	d3 ea                	shr    %cl,%edx
  801f5f:	89 e9                	mov    %ebp,%ecx
  801f61:	d3 e7                	shl    %cl,%edi
  801f63:	89 f1                	mov    %esi,%ecx
  801f65:	d3 e8                	shr    %cl,%eax
  801f67:	89 e9                	mov    %ebp,%ecx
  801f69:	09 f8                	or     %edi,%eax
  801f6b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f6f:	f7 74 24 04          	divl   0x4(%esp)
  801f73:	d3 e7                	shl    %cl,%edi
  801f75:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f79:	89 d7                	mov    %edx,%edi
  801f7b:	f7 64 24 08          	mull   0x8(%esp)
  801f7f:	39 d7                	cmp    %edx,%edi
  801f81:	89 c1                	mov    %eax,%ecx
  801f83:	89 14 24             	mov    %edx,(%esp)
  801f86:	72 2c                	jb     801fb4 <__umoddi3+0x134>
  801f88:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f8c:	72 22                	jb     801fb0 <__umoddi3+0x130>
  801f8e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f92:	29 c8                	sub    %ecx,%eax
  801f94:	19 d7                	sbb    %edx,%edi
  801f96:	89 e9                	mov    %ebp,%ecx
  801f98:	89 fa                	mov    %edi,%edx
  801f9a:	d3 e8                	shr    %cl,%eax
  801f9c:	89 f1                	mov    %esi,%ecx
  801f9e:	d3 e2                	shl    %cl,%edx
  801fa0:	89 e9                	mov    %ebp,%ecx
  801fa2:	d3 ef                	shr    %cl,%edi
  801fa4:	09 d0                	or     %edx,%eax
  801fa6:	89 fa                	mov    %edi,%edx
  801fa8:	83 c4 14             	add    $0x14,%esp
  801fab:	5e                   	pop    %esi
  801fac:	5f                   	pop    %edi
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    
  801faf:	90                   	nop
  801fb0:	39 d7                	cmp    %edx,%edi
  801fb2:	75 da                	jne    801f8e <__umoddi3+0x10e>
  801fb4:	8b 14 24             	mov    (%esp),%edx
  801fb7:	89 c1                	mov    %eax,%ecx
  801fb9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801fbd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801fc1:	eb cb                	jmp    801f8e <__umoddi3+0x10e>
  801fc3:	90                   	nop
  801fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801fcc:	0f 82 0f ff ff ff    	jb     801ee1 <__umoddi3+0x61>
  801fd2:	e9 1a ff ff ff       	jmp    801ef1 <__umoddi3+0x71>
