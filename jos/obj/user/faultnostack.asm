
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 28 00 00 00       	call   800059 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	c7 44 24 04 ef 03 80 	movl   $0x8003ef,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 da 02 00 00       	call   800327 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004d:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800054:	00 00 00 
}
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	56                   	push   %esi
  80005d:	53                   	push   %ebx
  80005e:	83 ec 10             	sub    $0x10,%esp
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800067:	e8 dd 00 00 00       	call   800149 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x30>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800089:	89 74 24 04          	mov    %esi,0x4(%esp)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 07 00 00 00       	call   8000a1 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a7:	e8 49 05 00 00       	call   8005f5 <close_all>
	sys_env_destroy(0);
  8000ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b3:	e8 3f 00 00 00       	call   8000f7 <sys_env_destroy>
}
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	89 c3                	mov    %eax,%ebx
  8000cd:	89 c7                	mov    %eax,%edi
  8000cf:	89 c6                	mov    %eax,%esi
  8000d1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800100:	b9 00 00 00 00       	mov    $0x0,%ecx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	89 cb                	mov    %ecx,%ebx
  80010f:	89 cf                	mov    %ecx,%edi
  800111:	89 ce                	mov    %ecx,%esi
  800113:	cd 30                	int    $0x30
	if(check && ret > 0)
  800115:	85 c0                	test   %eax,%eax
  800117:	7e 28                	jle    800141 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800119:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800124:	00 
  800125:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80012c:	00 
  80012d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800134:	00 
  800135:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80013c:	e8 55 10 00 00       	call   801196 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800141:	83 c4 2c             	add    $0x2c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 02 00 00 00       	mov    $0x2,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_yield>:

void
sys_yield(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016e:	ba 00 00 00 00       	mov    $0x0,%edx
  800173:	b8 0b 00 00 00       	mov    $0xb,%eax
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 d3                	mov    %edx,%ebx
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	89 d6                	mov    %edx,%esi
  800180:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800190:	be 00 00 00 00       	mov    $0x0,%esi
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	89 f7                	mov    %esi,%edi
  8001a5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	7e 28                	jle    8001d3 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001af:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b6:	00 
  8001b7:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8001be:	00 
  8001bf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c6:	00 
  8001c7:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8001ce:	e8 c3 0f 00 00       	call   801196 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d3:	83 c4 2c             	add    $0x2c,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 28                	jle    800226 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800202:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800209:	00 
  80020a:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  800211:	00 
  800212:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800219:	00 
  80021a:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800221:	e8 70 0f 00 00       	call   801196 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800226:	83 c4 2c             	add    $0x2c,%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800237:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023c:	b8 06 00 00 00       	mov    $0x6,%eax
  800241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	89 df                	mov    %ebx,%edi
  800249:	89 de                	mov    %ebx,%esi
  80024b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024d:	85 c0                	test   %eax,%eax
  80024f:	7e 28                	jle    800279 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800251:	89 44 24 10          	mov    %eax,0x10(%esp)
  800255:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025c:	00 
  80025d:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  800264:	00 
  800265:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026c:	00 
  80026d:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800274:	e8 1d 0f 00 00       	call   801196 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800279:	83 c4 2c             	add    $0x2c,%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80028a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028f:	b8 08 00 00 00       	mov    $0x8,%eax
  800294:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	89 df                	mov    %ebx,%edi
  80029c:	89 de                	mov    %ebx,%esi
  80029e:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	7e 28                	jle    8002cc <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002af:	00 
  8002b0:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8002b7:	00 
  8002b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bf:	00 
  8002c0:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8002c7:	e8 ca 0e 00 00       	call   801196 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002cc:	83 c4 2c             	add    $0x2c,%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	89 df                	mov    %ebx,%edi
  8002ef:	89 de                	mov    %ebx,%esi
  8002f1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	7e 28                	jle    80031f <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800302:	00 
  800303:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80030a:	00 
  80030b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800312:	00 
  800313:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80031a:	e8 77 0e 00 00       	call   801196 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80031f:	83 c4 2c             	add    $0x2c,%esp
  800322:	5b                   	pop    %ebx
  800323:	5e                   	pop    %esi
  800324:	5f                   	pop    %edi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	57                   	push   %edi
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800330:	bb 00 00 00 00       	mov    $0x0,%ebx
  800335:	b8 0a 00 00 00       	mov    $0xa,%eax
  80033a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033d:	8b 55 08             	mov    0x8(%ebp),%edx
  800340:	89 df                	mov    %ebx,%edi
  800342:	89 de                	mov    %ebx,%esi
  800344:	cd 30                	int    $0x30
	if(check && ret > 0)
  800346:	85 c0                	test   %eax,%eax
  800348:	7e 28                	jle    800372 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034e:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800355:	00 
  800356:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80035d:	00 
  80035e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800365:	00 
  800366:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80036d:	e8 24 0e 00 00       	call   801196 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800372:	83 c4 2c             	add    $0x2c,%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800380:	be 00 00 00 00       	mov    $0x0,%esi
  800385:	b8 0c 00 00 00       	mov    $0xc,%eax
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800393:	8b 7d 14             	mov    0x14(%ebp),%edi
  800396:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800398:	5b                   	pop    %ebx
  800399:	5e                   	pop    %esi
  80039a:	5f                   	pop    %edi
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8003a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ab:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b3:	89 cb                	mov    %ecx,%ebx
  8003b5:	89 cf                	mov    %ecx,%edi
  8003b7:	89 ce                	mov    %ecx,%esi
  8003b9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	7e 28                	jle    8003e7 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c3:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003ca:	00 
  8003cb:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8003d2:	00 
  8003d3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003da:	00 
  8003db:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8003e2:	e8 af 0d 00 00       	call   801196 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e7:	83 c4 2c             	add    $0x2c,%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003ef:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003f0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8003f5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003f7:	83 c4 04             	add    $0x4,%esp

    // the TA mentioned we'll need to grow the stack, but when? I feel
    // since we're going to be adding a new eip, that that might be the problem

    // Okay, the first one, store the EIP REMINDER THAT EACH STRUCT ATTRIBUTE IS 4 BYTES
    movl 40(%esp), %eax;// This needs to be JUST the eip. Counting from the top of utrap, each being 8 bytes, you get 40.
  8003fa:	8b 44 24 28          	mov    0x28(%esp),%eax
    //subl 0x4, (48)%esp // OKAY, I think I got it. We need to grow the stack so we can properly add the eip. I think. Hopefully.

    // Hmm, if we push, maybe no need to manually subl?

    // We need to be able to skip a chunk, go OVER the eip and grab the stack stuff. reminder this is IN THE USER TRAP FRAME.
    movl 48(%esp), %ebx
  8003fe:	8b 5c 24 30          	mov    0x30(%esp),%ebx

    // Save the stack just in case, who knows what'll happen
    movl %esp, %ebp;
  800402:	89 e5                	mov    %esp,%ebp

    // Switch to the other stack
    movl %ebx, %esp
  800404:	89 dc                	mov    %ebx,%esp

    // Now we need to push as described by the TA to the trap EIP stack.
    pushl %eax;
  800406:	50                   	push   %eax

    // Now that we've changed the utf_esp, we need to make sure it's updated in the OG place.
    movl %esp, 48(%ebp)
  800407:	89 65 30             	mov    %esp,0x30(%ebp)

    movl %ebp, %esp // return to the OG.
  80040a:	89 ec                	mov    %ebp,%esp

    addl $8, %esp // Ignore err and fault code
  80040c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    //add $8, %esp
    popa;
  80040f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  800410:	83 c4 04             	add    $0x4,%esp
    popf;
  800413:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp;
  800414:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret;
  800415:	c3                   	ret    
  800416:	66 90                	xchg   %ax,%ax
  800418:	66 90                	xchg   %ax,%ax
  80041a:	66 90                	xchg   %ax,%ax
  80041c:	66 90                	xchg   %ax,%ax
  80041e:	66 90                	xchg   %ax,%ax

00800420 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	05 00 00 00 30       	add    $0x30000000,%eax
  80042b:	c1 e8 0c             	shr    $0xc,%eax
}
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80043b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800440:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800445:	5d                   	pop    %ebp
  800446:	c3                   	ret    

00800447 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800452:	89 c2                	mov    %eax,%edx
  800454:	c1 ea 16             	shr    $0x16,%edx
  800457:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80045e:	f6 c2 01             	test   $0x1,%dl
  800461:	74 11                	je     800474 <fd_alloc+0x2d>
  800463:	89 c2                	mov    %eax,%edx
  800465:	c1 ea 0c             	shr    $0xc,%edx
  800468:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80046f:	f6 c2 01             	test   $0x1,%dl
  800472:	75 09                	jne    80047d <fd_alloc+0x36>
			*fd_store = fd;
  800474:	89 01                	mov    %eax,(%ecx)
			return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb 17                	jmp    800494 <fd_alloc+0x4d>
  80047d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800482:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800487:	75 c9                	jne    800452 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800489:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80048f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800494:	5d                   	pop    %ebp
  800495:	c3                   	ret    

00800496 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80049c:	83 f8 1f             	cmp    $0x1f,%eax
  80049f:	77 36                	ja     8004d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004a1:	c1 e0 0c             	shl    $0xc,%eax
  8004a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004a9:	89 c2                	mov    %eax,%edx
  8004ab:	c1 ea 16             	shr    $0x16,%edx
  8004ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004b5:	f6 c2 01             	test   $0x1,%dl
  8004b8:	74 24                	je     8004de <fd_lookup+0x48>
  8004ba:	89 c2                	mov    %eax,%edx
  8004bc:	c1 ea 0c             	shr    $0xc,%edx
  8004bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004c6:	f6 c2 01             	test   $0x1,%dl
  8004c9:	74 1a                	je     8004e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8004d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d5:	eb 13                	jmp    8004ea <fd_lookup+0x54>
		return -E_INVAL;
  8004d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004dc:	eb 0c                	jmp    8004ea <fd_lookup+0x54>
		return -E_INVAL;
  8004de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004e3:	eb 05                	jmp    8004ea <fd_lookup+0x54>
  8004e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ea:	5d                   	pop    %ebp
  8004eb:	c3                   	ret    

008004ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	83 ec 18             	sub    $0x18,%esp
  8004f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004f5:	ba 34 21 80 00       	mov    $0x802134,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004fa:	eb 13                	jmp    80050f <dev_lookup+0x23>
  8004fc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004ff:	39 08                	cmp    %ecx,(%eax)
  800501:	75 0c                	jne    80050f <dev_lookup+0x23>
			*dev = devtab[i];
  800503:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800506:	89 01                	mov    %eax,(%ecx)
			return 0;
  800508:	b8 00 00 00 00       	mov    $0x0,%eax
  80050d:	eb 30                	jmp    80053f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80050f:	8b 02                	mov    (%edx),%eax
  800511:	85 c0                	test   %eax,%eax
  800513:	75 e7                	jne    8004fc <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800515:	a1 08 40 80 00       	mov    0x804008,%eax
  80051a:	8b 40 48             	mov    0x48(%eax),%eax
  80051d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800521:	89 44 24 04          	mov    %eax,0x4(%esp)
  800525:	c7 04 24 b8 20 80 00 	movl   $0x8020b8,(%esp)
  80052c:	e8 5e 0d 00 00       	call   80128f <cprintf>
	*dev = 0;
  800531:	8b 45 0c             	mov    0xc(%ebp),%eax
  800534:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80053a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <fd_close>:
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	56                   	push   %esi
  800545:	53                   	push   %ebx
  800546:	83 ec 20             	sub    $0x20,%esp
  800549:	8b 75 08             	mov    0x8(%ebp),%esi
  80054c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80054f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800552:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800556:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80055c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80055f:	89 04 24             	mov    %eax,(%esp)
  800562:	e8 2f ff ff ff       	call   800496 <fd_lookup>
  800567:	85 c0                	test   %eax,%eax
  800569:	78 05                	js     800570 <fd_close+0x2f>
	    || fd != fd2)
  80056b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80056e:	74 0c                	je     80057c <fd_close+0x3b>
		return (must_exist ? r : 0);
  800570:	84 db                	test   %bl,%bl
  800572:	ba 00 00 00 00       	mov    $0x0,%edx
  800577:	0f 44 c2             	cmove  %edx,%eax
  80057a:	eb 3f                	jmp    8005bb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80057c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80057f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800583:	8b 06                	mov    (%esi),%eax
  800585:	89 04 24             	mov    %eax,(%esp)
  800588:	e8 5f ff ff ff       	call   8004ec <dev_lookup>
  80058d:	89 c3                	mov    %eax,%ebx
  80058f:	85 c0                	test   %eax,%eax
  800591:	78 16                	js     8005a9 <fd_close+0x68>
		if (dev->dev_close)
  800593:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800596:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800599:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 07                	je     8005a9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8005a2:	89 34 24             	mov    %esi,(%esp)
  8005a5:	ff d0                	call   *%eax
  8005a7:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8005a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005b4:	e8 75 fc ff ff       	call   80022e <sys_page_unmap>
	return r;
  8005b9:	89 d8                	mov    %ebx,%eax
}
  8005bb:	83 c4 20             	add    $0x20,%esp
  8005be:	5b                   	pop    %ebx
  8005bf:	5e                   	pop    %esi
  8005c0:	5d                   	pop    %ebp
  8005c1:	c3                   	ret    

008005c2 <close>:

int
close(int fdnum)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	e8 bc fe ff ff       	call   800496 <fd_lookup>
  8005da:	89 c2                	mov    %eax,%edx
  8005dc:	85 d2                	test   %edx,%edx
  8005de:	78 13                	js     8005f3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8005e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005e7:	00 
  8005e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 4e ff ff ff       	call   800541 <fd_close>
}
  8005f3:	c9                   	leave  
  8005f4:	c3                   	ret    

008005f5 <close_all>:

void
close_all(void)
{
  8005f5:	55                   	push   %ebp
  8005f6:	89 e5                	mov    %esp,%ebp
  8005f8:	53                   	push   %ebx
  8005f9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800601:	89 1c 24             	mov    %ebx,(%esp)
  800604:	e8 b9 ff ff ff       	call   8005c2 <close>
	for (i = 0; i < MAXFD; i++)
  800609:	83 c3 01             	add    $0x1,%ebx
  80060c:	83 fb 20             	cmp    $0x20,%ebx
  80060f:	75 f0                	jne    800601 <close_all+0xc>
}
  800611:	83 c4 14             	add    $0x14,%esp
  800614:	5b                   	pop    %ebx
  800615:	5d                   	pop    %ebp
  800616:	c3                   	ret    

00800617 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800617:	55                   	push   %ebp
  800618:	89 e5                	mov    %esp,%ebp
  80061a:	57                   	push   %edi
  80061b:	56                   	push   %esi
  80061c:	53                   	push   %ebx
  80061d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800620:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800623:	89 44 24 04          	mov    %eax,0x4(%esp)
  800627:	8b 45 08             	mov    0x8(%ebp),%eax
  80062a:	89 04 24             	mov    %eax,(%esp)
  80062d:	e8 64 fe ff ff       	call   800496 <fd_lookup>
  800632:	89 c2                	mov    %eax,%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	0f 88 e1 00 00 00    	js     80071d <dup+0x106>
		return r;
	close(newfdnum);
  80063c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	e8 7b ff ff ff       	call   8005c2 <close>

	newfd = INDEX2FD(newfdnum);
  800647:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80064a:	c1 e3 0c             	shl    $0xc,%ebx
  80064d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800653:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800656:	89 04 24             	mov    %eax,(%esp)
  800659:	e8 d2 fd ff ff       	call   800430 <fd2data>
  80065e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800660:	89 1c 24             	mov    %ebx,(%esp)
  800663:	e8 c8 fd ff ff       	call   800430 <fd2data>
  800668:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80066a:	89 f0                	mov    %esi,%eax
  80066c:	c1 e8 16             	shr    $0x16,%eax
  80066f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800676:	a8 01                	test   $0x1,%al
  800678:	74 43                	je     8006bd <dup+0xa6>
  80067a:	89 f0                	mov    %esi,%eax
  80067c:	c1 e8 0c             	shr    $0xc,%eax
  80067f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800686:	f6 c2 01             	test   $0x1,%dl
  800689:	74 32                	je     8006bd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80068b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800692:	25 07 0e 00 00       	and    $0xe07,%eax
  800697:	89 44 24 10          	mov    %eax,0x10(%esp)
  80069b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80069f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006a6:	00 
  8006a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b2:	e8 24 fb ff ff       	call   8001db <sys_page_map>
  8006b7:	89 c6                	mov    %eax,%esi
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	78 3e                	js     8006fb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c0:	89 c2                	mov    %eax,%edx
  8006c2:	c1 ea 0c             	shr    $0xc,%edx
  8006c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006e1:	00 
  8006e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ed:	e8 e9 fa ff ff       	call   8001db <sys_page_map>
  8006f2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8006f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006f7:	85 f6                	test   %esi,%esi
  8006f9:	79 22                	jns    80071d <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800706:	e8 23 fb ff ff       	call   80022e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80070b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800716:	e8 13 fb ff ff       	call   80022e <sys_page_unmap>
	return r;
  80071b:	89 f0                	mov    %esi,%eax
}
  80071d:	83 c4 3c             	add    $0x3c,%esp
  800720:	5b                   	pop    %ebx
  800721:	5e                   	pop    %esi
  800722:	5f                   	pop    %edi
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	53                   	push   %ebx
  800729:	83 ec 24             	sub    $0x24,%esp
  80072c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800732:	89 44 24 04          	mov    %eax,0x4(%esp)
  800736:	89 1c 24             	mov    %ebx,(%esp)
  800739:	e8 58 fd ff ff       	call   800496 <fd_lookup>
  80073e:	89 c2                	mov    %eax,%edx
  800740:	85 d2                	test   %edx,%edx
  800742:	78 6d                	js     8007b1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800744:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	e8 94 fd ff ff       	call   8004ec <dev_lookup>
  800758:	85 c0                	test   %eax,%eax
  80075a:	78 55                	js     8007b1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80075c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075f:	8b 50 08             	mov    0x8(%eax),%edx
  800762:	83 e2 03             	and    $0x3,%edx
  800765:	83 fa 01             	cmp    $0x1,%edx
  800768:	75 23                	jne    80078d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80076a:	a1 08 40 80 00       	mov    0x804008,%eax
  80076f:	8b 40 48             	mov    0x48(%eax),%eax
  800772:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077a:	c7 04 24 f9 20 80 00 	movl   $0x8020f9,(%esp)
  800781:	e8 09 0b 00 00       	call   80128f <cprintf>
		return -E_INVAL;
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078b:	eb 24                	jmp    8007b1 <read+0x8c>
	}
	if (!dev->dev_read)
  80078d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800790:	8b 52 08             	mov    0x8(%edx),%edx
  800793:	85 d2                	test   %edx,%edx
  800795:	74 15                	je     8007ac <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800797:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80079a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a5:	89 04 24             	mov    %eax,(%esp)
  8007a8:	ff d2                	call   *%edx
  8007aa:	eb 05                	jmp    8007b1 <read+0x8c>
		return -E_NOT_SUPP;
  8007ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8007b1:	83 c4 24             	add    $0x24,%esp
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	57                   	push   %edi
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	83 ec 1c             	sub    $0x1c,%esp
  8007c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007cb:	eb 23                	jmp    8007f0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	29 d8                	sub    %ebx,%eax
  8007d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	03 45 0c             	add    0xc(%ebp),%eax
  8007da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007de:	89 3c 24             	mov    %edi,(%esp)
  8007e1:	e8 3f ff ff ff       	call   800725 <read>
		if (m < 0)
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	78 10                	js     8007fa <readn+0x43>
			return m;
		if (m == 0)
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	74 0a                	je     8007f8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8007ee:	01 c3                	add    %eax,%ebx
  8007f0:	39 f3                	cmp    %esi,%ebx
  8007f2:	72 d9                	jb     8007cd <readn+0x16>
  8007f4:	89 d8                	mov    %ebx,%eax
  8007f6:	eb 02                	jmp    8007fa <readn+0x43>
  8007f8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007fa:	83 c4 1c             	add    $0x1c,%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	83 ec 24             	sub    $0x24,%esp
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800813:	89 1c 24             	mov    %ebx,(%esp)
  800816:	e8 7b fc ff ff       	call   800496 <fd_lookup>
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	85 d2                	test   %edx,%edx
  80081f:	78 68                	js     800889 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800824:	89 44 24 04          	mov    %eax,0x4(%esp)
  800828:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082b:	8b 00                	mov    (%eax),%eax
  80082d:	89 04 24             	mov    %eax,(%esp)
  800830:	e8 b7 fc ff ff       	call   8004ec <dev_lookup>
  800835:	85 c0                	test   %eax,%eax
  800837:	78 50                	js     800889 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800840:	75 23                	jne    800865 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800842:	a1 08 40 80 00       	mov    0x804008,%eax
  800847:	8b 40 48             	mov    0x48(%eax),%eax
  80084a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80084e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800852:	c7 04 24 15 21 80 00 	movl   $0x802115,(%esp)
  800859:	e8 31 0a 00 00       	call   80128f <cprintf>
		return -E_INVAL;
  80085e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800863:	eb 24                	jmp    800889 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800865:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800868:	8b 52 0c             	mov    0xc(%edx),%edx
  80086b:	85 d2                	test   %edx,%edx
  80086d:	74 15                	je     800884 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80086f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800872:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80087d:	89 04 24             	mov    %eax,(%esp)
  800880:	ff d2                	call   *%edx
  800882:	eb 05                	jmp    800889 <write+0x87>
		return -E_NOT_SUPP;
  800884:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800889:	83 c4 24             	add    $0x24,%esp
  80088c:	5b                   	pop    %ebx
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <seek>:

int
seek(int fdnum, off_t offset)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800895:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	89 04 24             	mov    %eax,(%esp)
  8008a2:	e8 ef fb ff ff       	call   800496 <fd_lookup>
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	78 0e                	js     8008b9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 24             	sub    $0x24,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cc:	89 1c 24             	mov    %ebx,(%esp)
  8008cf:	e8 c2 fb ff ff       	call   800496 <fd_lookup>
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	78 61                	js     80093b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e4:	8b 00                	mov    (%eax),%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 fe fb ff ff       	call   8004ec <dev_lookup>
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	78 49                	js     80093b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008f9:	75 23                	jne    80091e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008fb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800900:	8b 40 48             	mov    0x48(%eax),%eax
  800903:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090b:	c7 04 24 d8 20 80 00 	movl   $0x8020d8,(%esp)
  800912:	e8 78 09 00 00       	call   80128f <cprintf>
		return -E_INVAL;
  800917:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80091c:	eb 1d                	jmp    80093b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80091e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800921:	8b 52 18             	mov    0x18(%edx),%edx
  800924:	85 d2                	test   %edx,%edx
  800926:	74 0e                	je     800936 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80092f:	89 04 24             	mov    %eax,(%esp)
  800932:	ff d2                	call   *%edx
  800934:	eb 05                	jmp    80093b <ftruncate+0x80>
		return -E_NOT_SUPP;
  800936:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80093b:	83 c4 24             	add    $0x24,%esp
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	83 ec 24             	sub    $0x24,%esp
  800948:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80094b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80094e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	e8 39 fb ff ff       	call   800496 <fd_lookup>
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	85 d2                	test   %edx,%edx
  800961:	78 52                	js     8009b5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096d:	8b 00                	mov    (%eax),%eax
  80096f:	89 04 24             	mov    %eax,(%esp)
  800972:	e8 75 fb ff ff       	call   8004ec <dev_lookup>
  800977:	85 c0                	test   %eax,%eax
  800979:	78 3a                	js     8009b5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80097b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800982:	74 2c                	je     8009b0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800984:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800987:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80098e:	00 00 00 
	stat->st_isdir = 0;
  800991:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800998:	00 00 00 
	stat->st_dev = dev;
  80099b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009a8:	89 14 24             	mov    %edx,(%esp)
  8009ab:	ff 50 14             	call   *0x14(%eax)
  8009ae:	eb 05                	jmp    8009b5 <fstat+0x74>
		return -E_NOT_SUPP;
  8009b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8009b5:	83 c4 24             	add    $0x24,%esp
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009ca:	00 
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 fb 01 00 00       	call   800bd1 <open>
  8009d6:	89 c3                	mov    %eax,%ebx
  8009d8:	85 db                	test   %ebx,%ebx
  8009da:	78 1b                	js     8009f7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e3:	89 1c 24             	mov    %ebx,(%esp)
  8009e6:	e8 56 ff ff ff       	call   800941 <fstat>
  8009eb:	89 c6                	mov    %eax,%esi
	close(fd);
  8009ed:	89 1c 24             	mov    %ebx,(%esp)
  8009f0:	e8 cd fb ff ff       	call   8005c2 <close>
	return r;
  8009f5:	89 f0                	mov    %esi,%eax
}
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	83 ec 10             	sub    $0x10,%esp
  800a06:	89 c6                	mov    %eax,%esi
  800a08:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800a0a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a11:	75 11                	jne    800a24 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a1a:	e8 40 13 00 00       	call   801d5f <ipc_find_env>
  800a1f:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a24:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a2b:	00 
  800a2c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a33:	00 
  800a34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a38:	a1 00 40 80 00       	mov    0x804000,%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 b3 12 00 00       	call   801cf8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a4c:	00 
  800a4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a58:	e8 33 12 00 00       	call   801c90 <ipc_recv>
}
  800a5d:	83 c4 10             	add    $0x10,%esp
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a70:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 02 00 00 00       	mov    $0x2,%eax
  800a87:	e8 72 ff ff ff       	call   8009fe <fsipc>
}
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <devfile_flush>:
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa4:	b8 06 00 00 00       	mov    $0x6,%eax
  800aa9:	e8 50 ff ff ff       	call   8009fe <fsipc>
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <devfile_stat>:
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 14             	sub    $0x14,%esp
  800ab7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	8b 40 0c             	mov    0xc(%eax),%eax
  800ac0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 05 00 00 00       	mov    $0x5,%eax
  800acf:	e8 2a ff ff ff       	call   8009fe <fsipc>
  800ad4:	89 c2                	mov    %eax,%edx
  800ad6:	85 d2                	test   %edx,%edx
  800ad8:	78 2b                	js     800b05 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ada:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ae1:	00 
  800ae2:	89 1c 24             	mov    %ebx,(%esp)
  800ae5:	e8 cd 0d 00 00       	call   8018b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aea:	a1 80 50 80 00       	mov    0x805080,%eax
  800aef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800af5:	a1 84 50 80 00       	mov    0x805084,%eax
  800afa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b05:	83 c4 14             	add    $0x14,%esp
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <devfile_write>:
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  800b11:	c7 44 24 08 44 21 80 	movl   $0x802144,0x8(%esp)
  800b18:	00 
  800b19:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800b20:	00 
  800b21:	c7 04 24 62 21 80 00 	movl   $0x802162,(%esp)
  800b28:	e8 69 06 00 00       	call   801196 <_panic>

00800b2d <devfile_read>:
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 10             	sub    $0x10,%esp
  800b35:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b3e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b43:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b53:	e8 a6 fe ff ff       	call   8009fe <fsipc>
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	78 6a                	js     800bc8 <devfile_read+0x9b>
	assert(r <= n);
  800b5e:	39 c6                	cmp    %eax,%esi
  800b60:	73 24                	jae    800b86 <devfile_read+0x59>
  800b62:	c7 44 24 0c 6d 21 80 	movl   $0x80216d,0xc(%esp)
  800b69:	00 
  800b6a:	c7 44 24 08 74 21 80 	movl   $0x802174,0x8(%esp)
  800b71:	00 
  800b72:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b79:	00 
  800b7a:	c7 04 24 62 21 80 00 	movl   $0x802162,(%esp)
  800b81:	e8 10 06 00 00       	call   801196 <_panic>
	assert(r <= PGSIZE);
  800b86:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b8b:	7e 24                	jle    800bb1 <devfile_read+0x84>
  800b8d:	c7 44 24 0c 89 21 80 	movl   $0x802189,0xc(%esp)
  800b94:	00 
  800b95:	c7 44 24 08 74 21 80 	movl   $0x802174,0x8(%esp)
  800b9c:	00 
  800b9d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800ba4:	00 
  800ba5:	c7 04 24 62 21 80 00 	movl   $0x802162,(%esp)
  800bac:	e8 e5 05 00 00       	call   801196 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800bb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bbc:	00 
  800bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc0:	89 04 24             	mov    %eax,(%esp)
  800bc3:	e8 8c 0e 00 00       	call   801a54 <memmove>
}
  800bc8:	89 d8                	mov    %ebx,%eax
  800bca:	83 c4 10             	add    $0x10,%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <open>:
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 24             	sub    $0x24,%esp
  800bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800bdb:	89 1c 24             	mov    %ebx,(%esp)
  800bde:	e8 9d 0c 00 00       	call   801880 <strlen>
  800be3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800be8:	7f 60                	jg     800c4a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  800bea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bed:	89 04 24             	mov    %eax,(%esp)
  800bf0:	e8 52 f8 ff ff       	call   800447 <fd_alloc>
  800bf5:	89 c2                	mov    %eax,%edx
  800bf7:	85 d2                	test   %edx,%edx
  800bf9:	78 54                	js     800c4f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  800bfb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bff:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c06:	e8 ac 0c 00 00       	call   8018b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c16:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1b:	e8 de fd ff ff       	call   8009fe <fsipc>
  800c20:	89 c3                	mov    %eax,%ebx
  800c22:	85 c0                	test   %eax,%eax
  800c24:	79 17                	jns    800c3d <open+0x6c>
		fd_close(fd, 0);
  800c26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c2d:	00 
  800c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c31:	89 04 24             	mov    %eax,(%esp)
  800c34:	e8 08 f9 ff ff       	call   800541 <fd_close>
		return r;
  800c39:	89 d8                	mov    %ebx,%eax
  800c3b:	eb 12                	jmp    800c4f <open+0x7e>
	return fd2num(fd);
  800c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c40:	89 04 24             	mov    %eax,(%esp)
  800c43:	e8 d8 f7 ff ff       	call   800420 <fd2num>
  800c48:	eb 05                	jmp    800c4f <open+0x7e>
		return -E_BAD_PATH;
  800c4a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  800c4f:	83 c4 24             	add    $0x24,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 08 00 00 00       	mov    $0x8,%eax
  800c65:	e8 94 fd ff ff       	call   8009fe <fsipc>
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 10             	sub    $0x10,%esp
  800c74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	89 04 24             	mov    %eax,(%esp)
  800c7d:	e8 ae f7 ff ff       	call   800430 <fd2data>
  800c82:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c84:	c7 44 24 04 95 21 80 	movl   $0x802195,0x4(%esp)
  800c8b:	00 
  800c8c:	89 1c 24             	mov    %ebx,(%esp)
  800c8f:	e8 23 0c 00 00       	call   8018b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c94:	8b 46 04             	mov    0x4(%esi),%eax
  800c97:	2b 06                	sub    (%esi),%eax
  800c99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c9f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ca6:	00 00 00 
	stat->st_dev = &devpipe;
  800ca9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800cb0:	30 80 00 
	return 0;
}
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	83 c4 10             	add    $0x10,%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 14             	sub    $0x14,%esp
  800cc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800cc9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ccd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cd4:	e8 55 f5 ff ff       	call   80022e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cd9:	89 1c 24             	mov    %ebx,(%esp)
  800cdc:	e8 4f f7 ff ff       	call   800430 <fd2data>
  800ce1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cec:	e8 3d f5 ff ff       	call   80022e <sys_page_unmap>
}
  800cf1:	83 c4 14             	add    $0x14,%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <_pipeisclosed>:
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 2c             	sub    $0x2c,%esp
  800d00:	89 c6                	mov    %eax,%esi
  800d02:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  800d05:	a1 08 40 80 00       	mov    0x804008,%eax
  800d0a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d0d:	89 34 24             	mov    %esi,(%esp)
  800d10:	e8 82 10 00 00       	call   801d97 <pageref>
  800d15:	89 c7                	mov    %eax,%edi
  800d17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d1a:	89 04 24             	mov    %eax,(%esp)
  800d1d:	e8 75 10 00 00       	call   801d97 <pageref>
  800d22:	39 c7                	cmp    %eax,%edi
  800d24:	0f 94 c2             	sete   %dl
  800d27:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800d2a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  800d30:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800d33:	39 fb                	cmp    %edi,%ebx
  800d35:	74 21                	je     800d58 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  800d37:	84 d2                	test   %dl,%dl
  800d39:	74 ca                	je     800d05 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d3b:	8b 51 58             	mov    0x58(%ecx),%edx
  800d3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d42:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d4a:	c7 04 24 9c 21 80 00 	movl   $0x80219c,(%esp)
  800d51:	e8 39 05 00 00       	call   80128f <cprintf>
  800d56:	eb ad                	jmp    800d05 <_pipeisclosed+0xe>
}
  800d58:	83 c4 2c             	add    $0x2c,%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <devpipe_write>:
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 1c             	sub    $0x1c,%esp
  800d69:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d6c:	89 34 24             	mov    %esi,(%esp)
  800d6f:	e8 bc f6 ff ff       	call   800430 <fd2data>
  800d74:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d76:	bf 00 00 00 00       	mov    $0x0,%edi
  800d7b:	eb 45                	jmp    800dc2 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  800d7d:	89 da                	mov    %ebx,%edx
  800d7f:	89 f0                	mov    %esi,%eax
  800d81:	e8 71 ff ff ff       	call   800cf7 <_pipeisclosed>
  800d86:	85 c0                	test   %eax,%eax
  800d88:	75 41                	jne    800dcb <devpipe_write+0x6b>
			sys_yield();
  800d8a:	e8 d9 f3 ff ff       	call   800168 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d8f:	8b 43 04             	mov    0x4(%ebx),%eax
  800d92:	8b 0b                	mov    (%ebx),%ecx
  800d94:	8d 51 20             	lea    0x20(%ecx),%edx
  800d97:	39 d0                	cmp    %edx,%eax
  800d99:	73 e2                	jae    800d7d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800da2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800da5:	99                   	cltd   
  800da6:	c1 ea 1b             	shr    $0x1b,%edx
  800da9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800dac:	83 e1 1f             	and    $0x1f,%ecx
  800daf:	29 d1                	sub    %edx,%ecx
  800db1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800db5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800db9:	83 c0 01             	add    $0x1,%eax
  800dbc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800dbf:	83 c7 01             	add    $0x1,%edi
  800dc2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800dc5:	75 c8                	jne    800d8f <devpipe_write+0x2f>
	return i;
  800dc7:	89 f8                	mov    %edi,%eax
  800dc9:	eb 05                	jmp    800dd0 <devpipe_write+0x70>
				return 0;
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd0:	83 c4 1c             	add    $0x1c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <devpipe_read>:
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 1c             	sub    $0x1c,%esp
  800de1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800de4:	89 3c 24             	mov    %edi,(%esp)
  800de7:	e8 44 f6 ff ff       	call   800430 <fd2data>
  800dec:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800dee:	be 00 00 00 00       	mov    $0x0,%esi
  800df3:	eb 3d                	jmp    800e32 <devpipe_read+0x5a>
			if (i > 0)
  800df5:	85 f6                	test   %esi,%esi
  800df7:	74 04                	je     800dfd <devpipe_read+0x25>
				return i;
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	eb 43                	jmp    800e40 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  800dfd:	89 da                	mov    %ebx,%edx
  800dff:	89 f8                	mov    %edi,%eax
  800e01:	e8 f1 fe ff ff       	call   800cf7 <_pipeisclosed>
  800e06:	85 c0                	test   %eax,%eax
  800e08:	75 31                	jne    800e3b <devpipe_read+0x63>
			sys_yield();
  800e0a:	e8 59 f3 ff ff       	call   800168 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800e0f:	8b 03                	mov    (%ebx),%eax
  800e11:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e14:	74 df                	je     800df5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e16:	99                   	cltd   
  800e17:	c1 ea 1b             	shr    $0x1b,%edx
  800e1a:	01 d0                	add    %edx,%eax
  800e1c:	83 e0 1f             	and    $0x1f,%eax
  800e1f:	29 d0                	sub    %edx,%eax
  800e21:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800e2c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800e2f:	83 c6 01             	add    $0x1,%esi
  800e32:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e35:	75 d8                	jne    800e0f <devpipe_read+0x37>
	return i;
  800e37:	89 f0                	mov    %esi,%eax
  800e39:	eb 05                	jmp    800e40 <devpipe_read+0x68>
				return 0;
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e40:	83 c4 1c             	add    $0x1c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <pipe>:
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e53:	89 04 24             	mov    %eax,(%esp)
  800e56:	e8 ec f5 ff ff       	call   800447 <fd_alloc>
  800e5b:	89 c2                	mov    %eax,%edx
  800e5d:	85 d2                	test   %edx,%edx
  800e5f:	0f 88 4d 01 00 00    	js     800fb2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e65:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e6c:	00 
  800e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e7b:	e8 07 f3 ff ff       	call   800187 <sys_page_alloc>
  800e80:	89 c2                	mov    %eax,%edx
  800e82:	85 d2                	test   %edx,%edx
  800e84:	0f 88 28 01 00 00    	js     800fb2 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  800e8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	e8 b2 f5 ff ff       	call   800447 <fd_alloc>
  800e95:	89 c3                	mov    %eax,%ebx
  800e97:	85 c0                	test   %eax,%eax
  800e99:	0f 88 fe 00 00 00    	js     800f9d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e9f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ea6:	00 
  800ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb5:	e8 cd f2 ff ff       	call   800187 <sys_page_alloc>
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	0f 88 d9 00 00 00    	js     800f9d <pipe+0x155>
	va = fd2data(fd0);
  800ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec7:	89 04 24             	mov    %eax,(%esp)
  800eca:	e8 61 f5 ff ff       	call   800430 <fd2data>
  800ecf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ed1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ed8:	00 
  800ed9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800edd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ee4:	e8 9e f2 ff ff       	call   800187 <sys_page_alloc>
  800ee9:	89 c3                	mov    %eax,%ebx
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	0f 88 97 00 00 00    	js     800f8a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef6:	89 04 24             	mov    %eax,(%esp)
  800ef9:	e8 32 f5 ff ff       	call   800430 <fd2data>
  800efe:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f05:	00 
  800f06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f11:	00 
  800f12:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1d:	e8 b9 f2 ff ff       	call   8001db <sys_page_map>
  800f22:	89 c3                	mov    %eax,%ebx
  800f24:	85 c0                	test   %eax,%eax
  800f26:	78 52                	js     800f7a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  800f28:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f31:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f36:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800f3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f46:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f55:	89 04 24             	mov    %eax,(%esp)
  800f58:	e8 c3 f4 ff ff       	call   800420 <fd2num>
  800f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f60:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f65:	89 04 24             	mov    %eax,(%esp)
  800f68:	e8 b3 f4 ff ff       	call   800420 <fd2num>
  800f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f70:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
  800f78:	eb 38                	jmp    800fb2 <pipe+0x16a>
	sys_page_unmap(0, va);
  800f7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f85:	e8 a4 f2 ff ff       	call   80022e <sys_page_unmap>
	sys_page_unmap(0, fd1);
  800f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f98:	e8 91 f2 ff ff       	call   80022e <sys_page_unmap>
	sys_page_unmap(0, fd0);
  800f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fab:	e8 7e f2 ff ff       	call   80022e <sys_page_unmap>
  800fb0:	89 d8                	mov    %ebx,%eax
}
  800fb2:	83 c4 30             	add    $0x30,%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <pipeisclosed>:
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	89 04 24             	mov    %eax,(%esp)
  800fcc:	e8 c5 f4 ff ff       	call   800496 <fd_lookup>
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	85 d2                	test   %edx,%edx
  800fd5:	78 15                	js     800fec <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  800fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fda:	89 04 24             	mov    %eax,(%esp)
  800fdd:	e8 4e f4 ff ff       	call   800430 <fd2data>
	return _pipeisclosed(fd, p);
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe7:	e8 0b fd ff ff       	call   800cf7 <_pipeisclosed>
}
  800fec:	c9                   	leave  
  800fed:	c3                   	ret    
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801000:	c7 44 24 04 b4 21 80 	movl   $0x8021b4,0x4(%esp)
  801007:	00 
  801008:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100b:	89 04 24             	mov    %eax,(%esp)
  80100e:	e8 a4 08 00 00       	call   8018b7 <strcpy>
	return 0;
}
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
  801018:	c9                   	leave  
  801019:	c3                   	ret    

0080101a <devcons_write>:
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801026:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80102b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801031:	eb 31                	jmp    801064 <devcons_write+0x4a>
		m = n - tot;
  801033:	8b 75 10             	mov    0x10(%ebp),%esi
  801036:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801038:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80103b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801040:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801043:	89 74 24 08          	mov    %esi,0x8(%esp)
  801047:	03 45 0c             	add    0xc(%ebp),%eax
  80104a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104e:	89 3c 24             	mov    %edi,(%esp)
  801051:	e8 fe 09 00 00       	call   801a54 <memmove>
		sys_cputs(buf, m);
  801056:	89 74 24 04          	mov    %esi,0x4(%esp)
  80105a:	89 3c 24             	mov    %edi,(%esp)
  80105d:	e8 58 f0 ff ff       	call   8000ba <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801062:	01 f3                	add    %esi,%ebx
  801064:	89 d8                	mov    %ebx,%eax
  801066:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801069:	72 c8                	jb     801033 <devcons_write+0x19>
}
  80106b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <devcons_read>:
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801081:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801085:	75 07                	jne    80108e <devcons_read+0x18>
  801087:	eb 2a                	jmp    8010b3 <devcons_read+0x3d>
		sys_yield();
  801089:	e8 da f0 ff ff       	call   800168 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80108e:	66 90                	xchg   %ax,%ax
  801090:	e8 43 f0 ff ff       	call   8000d8 <sys_cgetc>
  801095:	85 c0                	test   %eax,%eax
  801097:	74 f0                	je     801089 <devcons_read+0x13>
	if (c < 0)
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 16                	js     8010b3 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80109d:	83 f8 04             	cmp    $0x4,%eax
  8010a0:	74 0c                	je     8010ae <devcons_read+0x38>
	*(char*)vbuf = c;
  8010a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a5:	88 02                	mov    %al,(%edx)
	return 1;
  8010a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ac:	eb 05                	jmp    8010b3 <devcons_read+0x3d>
		return 0;
  8010ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010b3:	c9                   	leave  
  8010b4:	c3                   	ret    

008010b5 <cputchar>:
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8010c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c8:	00 
  8010c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010cc:	89 04 24             	mov    %eax,(%esp)
  8010cf:	e8 e6 ef ff ff       	call   8000ba <sys_cputs>
}
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    

008010d6 <getchar>:
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8010dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010e3:	00 
  8010e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f2:	e8 2e f6 ff ff       	call   800725 <read>
	if (r < 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 0f                	js     80110a <getchar+0x34>
	if (r < 1)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	7e 06                	jle    801105 <getchar+0x2f>
	return c;
  8010ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801103:	eb 05                	jmp    80110a <getchar+0x34>
		return -E_EOF;
  801105:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <iscons>:
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801115:	89 44 24 04          	mov    %eax,0x4(%esp)
  801119:	8b 45 08             	mov    0x8(%ebp),%eax
  80111c:	89 04 24             	mov    %eax,(%esp)
  80111f:	e8 72 f3 ff ff       	call   800496 <fd_lookup>
  801124:	85 c0                	test   %eax,%eax
  801126:	78 11                	js     801139 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801131:	39 10                	cmp    %edx,(%eax)
  801133:	0f 94 c0             	sete   %al
  801136:	0f b6 c0             	movzbl %al,%eax
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <opencons>:
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801144:	89 04 24             	mov    %eax,(%esp)
  801147:	e8 fb f2 ff ff       	call   800447 <fd_alloc>
		return r;
  80114c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 40                	js     801192 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801152:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801159:	00 
  80115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801168:	e8 1a f0 ff ff       	call   800187 <sys_page_alloc>
		return r;
  80116d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 1f                	js     801192 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801173:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801181:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801188:	89 04 24             	mov    %eax,(%esp)
  80118b:	e8 90 f2 ff ff       	call   800420 <fd2num>
  801190:	89 c2                	mov    %eax,%edx
}
  801192:	89 d0                	mov    %edx,%eax
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	56                   	push   %esi
  80119a:	53                   	push   %ebx
  80119b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80119e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011a1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8011a7:	e8 9d ef ff ff       	call   800149 <sys_getenvid>
  8011ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011af:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c2:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  8011c9:	e8 c1 00 00 00       	call   80128f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d5:	89 04 24             	mov    %eax,(%esp)
  8011d8:	e8 51 00 00 00       	call   80122e <vcprintf>
	cprintf("\n");
  8011dd:	c7 04 24 ad 21 80 00 	movl   $0x8021ad,(%esp)
  8011e4:	e8 a6 00 00 00       	call   80128f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011e9:	cc                   	int3   
  8011ea:	eb fd                	jmp    8011e9 <_panic+0x53>

008011ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 14             	sub    $0x14,%esp
  8011f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011f6:	8b 13                	mov    (%ebx),%edx
  8011f8:	8d 42 01             	lea    0x1(%edx),%eax
  8011fb:	89 03                	mov    %eax,(%ebx)
  8011fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801200:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801204:	3d ff 00 00 00       	cmp    $0xff,%eax
  801209:	75 19                	jne    801224 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80120b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801212:	00 
  801213:	8d 43 08             	lea    0x8(%ebx),%eax
  801216:	89 04 24             	mov    %eax,(%esp)
  801219:	e8 9c ee ff ff       	call   8000ba <sys_cputs>
		b->idx = 0;
  80121e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801224:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801228:	83 c4 14             	add    $0x14,%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801237:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80123e:	00 00 00 
	b.cnt = 0;
  801241:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801248:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80124b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801252:	8b 45 08             	mov    0x8(%ebp),%eax
  801255:	89 44 24 08          	mov    %eax,0x8(%esp)
  801259:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80125f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801263:	c7 04 24 ec 11 80 00 	movl   $0x8011ec,(%esp)
  80126a:	e8 af 01 00 00       	call   80141e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80126f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801275:	89 44 24 04          	mov    %eax,0x4(%esp)
  801279:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 33 ee ff ff       	call   8000ba <sys_cputs>

	return b.cnt;
}
  801287:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801295:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
  80129f:	89 04 24             	mov    %eax,(%esp)
  8012a2:	e8 87 ff ff ff       	call   80122e <vcprintf>
	va_end(ap);

	return cnt;
}
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    
  8012a9:	66 90                	xchg   %ax,%ax
  8012ab:	66 90                	xchg   %ax,%ax
  8012ad:	66 90                	xchg   %ax,%ax
  8012af:	90                   	nop

008012b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	57                   	push   %edi
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
  8012b6:	83 ec 3c             	sub    $0x3c,%esp
  8012b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bc:	89 d7                	mov    %edx,%edi
  8012be:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c7:	89 c3                	mov    %eax,%ebx
  8012c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8012cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012dd:	39 d9                	cmp    %ebx,%ecx
  8012df:	72 05                	jb     8012e6 <printnum+0x36>
  8012e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012e4:	77 69                	ja     80134f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012ed:	83 ee 01             	sub    $0x1,%esi
  8012f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801300:	89 c3                	mov    %eax,%ebx
  801302:	89 d6                	mov    %edx,%esi
  801304:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801307:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80130a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80130e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801315:	89 04 24             	mov    %eax,(%esp)
  801318:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80131b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131f:	e8 bc 0a 00 00       	call   801de0 <__udivdi3>
  801324:	89 d9                	mov    %ebx,%ecx
  801326:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80132e:	89 04 24             	mov    %eax,(%esp)
  801331:	89 54 24 04          	mov    %edx,0x4(%esp)
  801335:	89 fa                	mov    %edi,%edx
  801337:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80133a:	e8 71 ff ff ff       	call   8012b0 <printnum>
  80133f:	eb 1b                	jmp    80135c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801341:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801345:	8b 45 18             	mov    0x18(%ebp),%eax
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	ff d3                	call   *%ebx
  80134d:	eb 03                	jmp    801352 <printnum+0xa2>
  80134f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  801352:	83 ee 01             	sub    $0x1,%esi
  801355:	85 f6                	test   %esi,%esi
  801357:	7f e8                	jg     801341 <printnum+0x91>
  801359:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80135c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801360:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801364:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801367:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80136a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80136e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801372:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801375:	89 04 24             	mov    %eax,(%esp)
  801378:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80137b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137f:	e8 8c 0b 00 00       	call   801f10 <__umoddi3>
  801384:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801388:	0f be 80 e3 21 80 00 	movsbl 0x8021e3(%eax),%eax
  80138f:	89 04 24             	mov    %eax,(%esp)
  801392:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801395:	ff d0                	call   *%eax
}
  801397:	83 c4 3c             	add    $0x3c,%esp
  80139a:	5b                   	pop    %ebx
  80139b:	5e                   	pop    %esi
  80139c:	5f                   	pop    %edi
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    

0080139f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8013a2:	83 fa 01             	cmp    $0x1,%edx
  8013a5:	7e 0e                	jle    8013b5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8013a7:	8b 10                	mov    (%eax),%edx
  8013a9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013ac:	89 08                	mov    %ecx,(%eax)
  8013ae:	8b 02                	mov    (%edx),%eax
  8013b0:	8b 52 04             	mov    0x4(%edx),%edx
  8013b3:	eb 22                	jmp    8013d7 <getuint+0x38>
	else if (lflag)
  8013b5:	85 d2                	test   %edx,%edx
  8013b7:	74 10                	je     8013c9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8013b9:	8b 10                	mov    (%eax),%edx
  8013bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013be:	89 08                	mov    %ecx,(%eax)
  8013c0:	8b 02                	mov    (%edx),%eax
  8013c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c7:	eb 0e                	jmp    8013d7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8013c9:	8b 10                	mov    (%eax),%edx
  8013cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013ce:	89 08                	mov    %ecx,(%eax)
  8013d0:	8b 02                	mov    (%edx),%eax
  8013d2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013df:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8013e3:	8b 10                	mov    (%eax),%edx
  8013e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8013e8:	73 0a                	jae    8013f4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8013ea:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013ed:	89 08                	mov    %ecx,(%eax)
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	88 02                	mov    %al,(%edx)
}
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <printfmt>:
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8013fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801403:	8b 45 10             	mov    0x10(%ebp),%eax
  801406:	89 44 24 08          	mov    %eax,0x8(%esp)
  80140a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	89 04 24             	mov    %eax,(%esp)
  801417:	e8 02 00 00 00       	call   80141e <vprintfmt>
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <vprintfmt>:
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	57                   	push   %edi
  801422:	56                   	push   %esi
  801423:	53                   	push   %ebx
  801424:	83 ec 3c             	sub    $0x3c,%esp
  801427:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80142a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80142d:	eb 1f                	jmp    80144e <vprintfmt+0x30>
			if (ch == '\0'){
  80142f:	85 c0                	test   %eax,%eax
  801431:	75 0f                	jne    801442 <vprintfmt+0x24>
				color = 0x0100;
  801433:	c7 05 04 40 80 00 00 	movl   $0x100,0x804004
  80143a:	01 00 00 
  80143d:	e9 b3 03 00 00       	jmp    8017f5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  801442:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801446:	89 04 24             	mov    %eax,(%esp)
  801449:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80144c:	89 f3                	mov    %esi,%ebx
  80144e:	8d 73 01             	lea    0x1(%ebx),%esi
  801451:	0f b6 03             	movzbl (%ebx),%eax
  801454:	83 f8 25             	cmp    $0x25,%eax
  801457:	75 d6                	jne    80142f <vprintfmt+0x11>
  801459:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80145d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801464:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80146b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801472:	ba 00 00 00 00       	mov    $0x0,%edx
  801477:	eb 1d                	jmp    801496 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801479:	89 de                	mov    %ebx,%esi
			padc = '-';
  80147b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80147f:	eb 15                	jmp    801496 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801481:	89 de                	mov    %ebx,%esi
			padc = '0';
  801483:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801487:	eb 0d                	jmp    801496 <vprintfmt+0x78>
				width = precision, precision = -1;
  801489:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80148c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80148f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801496:	8d 5e 01             	lea    0x1(%esi),%ebx
  801499:	0f b6 0e             	movzbl (%esi),%ecx
  80149c:	0f b6 c1             	movzbl %cl,%eax
  80149f:	83 e9 23             	sub    $0x23,%ecx
  8014a2:	80 f9 55             	cmp    $0x55,%cl
  8014a5:	0f 87 2a 03 00 00    	ja     8017d5 <vprintfmt+0x3b7>
  8014ab:	0f b6 c9             	movzbl %cl,%ecx
  8014ae:	ff 24 8d 20 23 80 00 	jmp    *0x802320(,%ecx,4)
  8014b5:	89 de                	mov    %ebx,%esi
  8014b7:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8014bc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8014bf:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8014c3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014c6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8014c9:	83 fb 09             	cmp    $0x9,%ebx
  8014cc:	77 36                	ja     801504 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  8014ce:	83 c6 01             	add    $0x1,%esi
			}
  8014d1:	eb e9                	jmp    8014bc <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8014d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d6:	8d 48 04             	lea    0x4(%eax),%ecx
  8014d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8014dc:	8b 00                	mov    (%eax),%eax
  8014de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014e1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8014e3:	eb 22                	jmp    801507 <vprintfmt+0xe9>
  8014e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014e8:	85 c9                	test   %ecx,%ecx
  8014ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ef:	0f 49 c1             	cmovns %ecx,%eax
  8014f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014f5:	89 de                	mov    %ebx,%esi
  8014f7:	eb 9d                	jmp    801496 <vprintfmt+0x78>
  8014f9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8014fb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801502:	eb 92                	jmp    801496 <vprintfmt+0x78>
  801504:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  801507:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80150b:	79 89                	jns    801496 <vprintfmt+0x78>
  80150d:	e9 77 ff ff ff       	jmp    801489 <vprintfmt+0x6b>
			lflag++;
  801512:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  801515:	89 de                	mov    %ebx,%esi
			goto reswitch;
  801517:	e9 7a ff ff ff       	jmp    801496 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  80151c:	8b 45 14             	mov    0x14(%ebp),%eax
  80151f:	8d 50 04             	lea    0x4(%eax),%edx
  801522:	89 55 14             	mov    %edx,0x14(%ebp)
  801525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801529:	8b 00                	mov    (%eax),%eax
  80152b:	89 04 24             	mov    %eax,(%esp)
  80152e:	ff 55 08             	call   *0x8(%ebp)
			break;
  801531:	e9 18 ff ff ff       	jmp    80144e <vprintfmt+0x30>
			err = va_arg(ap, int);
  801536:	8b 45 14             	mov    0x14(%ebp),%eax
  801539:	8d 50 04             	lea    0x4(%eax),%edx
  80153c:	89 55 14             	mov    %edx,0x14(%ebp)
  80153f:	8b 00                	mov    (%eax),%eax
  801541:	99                   	cltd   
  801542:	31 d0                	xor    %edx,%eax
  801544:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801546:	83 f8 0f             	cmp    $0xf,%eax
  801549:	7f 0b                	jg     801556 <vprintfmt+0x138>
  80154b:	8b 14 85 80 24 80 00 	mov    0x802480(,%eax,4),%edx
  801552:	85 d2                	test   %edx,%edx
  801554:	75 20                	jne    801576 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  801556:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80155a:	c7 44 24 08 fb 21 80 	movl   $0x8021fb,0x8(%esp)
  801561:	00 
  801562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801566:	8b 45 08             	mov    0x8(%ebp),%eax
  801569:	89 04 24             	mov    %eax,(%esp)
  80156c:	e8 85 fe ff ff       	call   8013f6 <printfmt>
  801571:	e9 d8 fe ff ff       	jmp    80144e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  801576:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80157a:	c7 44 24 08 86 21 80 	movl   $0x802186,0x8(%esp)
  801581:	00 
  801582:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	89 04 24             	mov    %eax,(%esp)
  80158c:	e8 65 fe ff ff       	call   8013f6 <printfmt>
  801591:	e9 b8 fe ff ff       	jmp    80144e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  801596:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801599:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80159c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80159f:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a2:	8d 50 04             	lea    0x4(%eax),%edx
  8015a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8015a8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8015aa:	85 f6                	test   %esi,%esi
  8015ac:	b8 f4 21 80 00       	mov    $0x8021f4,%eax
  8015b1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8015b4:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8015b8:	0f 84 97 00 00 00    	je     801655 <vprintfmt+0x237>
  8015be:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8015c2:	0f 8e 9b 00 00 00    	jle    801663 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015cc:	89 34 24             	mov    %esi,(%esp)
  8015cf:	e8 c4 02 00 00       	call   801898 <strnlen>
  8015d4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015d7:	29 c2                	sub    %eax,%edx
  8015d9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8015dc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8015e3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8015e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8015e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015ec:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8015ee:	eb 0f                	jmp    8015ff <vprintfmt+0x1e1>
					putch(padc, putdat);
  8015f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015f7:	89 04 24             	mov    %eax,(%esp)
  8015fa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8015fc:	83 eb 01             	sub    $0x1,%ebx
  8015ff:	85 db                	test   %ebx,%ebx
  801601:	7f ed                	jg     8015f0 <vprintfmt+0x1d2>
  801603:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801606:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801609:	85 d2                	test   %edx,%edx
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
  801610:	0f 49 c2             	cmovns %edx,%eax
  801613:	29 c2                	sub    %eax,%edx
  801615:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801618:	89 d7                	mov    %edx,%edi
  80161a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80161d:	eb 50                	jmp    80166f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  80161f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801623:	74 1e                	je     801643 <vprintfmt+0x225>
  801625:	0f be d2             	movsbl %dl,%edx
  801628:	83 ea 20             	sub    $0x20,%edx
  80162b:	83 fa 5e             	cmp    $0x5e,%edx
  80162e:	76 13                	jbe    801643 <vprintfmt+0x225>
					putch('?', putdat);
  801630:	8b 45 0c             	mov    0xc(%ebp),%eax
  801633:	89 44 24 04          	mov    %eax,0x4(%esp)
  801637:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80163e:	ff 55 08             	call   *0x8(%ebp)
  801641:	eb 0d                	jmp    801650 <vprintfmt+0x232>
					putch(ch, putdat);
  801643:	8b 55 0c             	mov    0xc(%ebp),%edx
  801646:	89 54 24 04          	mov    %edx,0x4(%esp)
  80164a:	89 04 24             	mov    %eax,(%esp)
  80164d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801650:	83 ef 01             	sub    $0x1,%edi
  801653:	eb 1a                	jmp    80166f <vprintfmt+0x251>
  801655:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801658:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80165b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80165e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801661:	eb 0c                	jmp    80166f <vprintfmt+0x251>
  801663:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801666:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801669:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80166c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80166f:	83 c6 01             	add    $0x1,%esi
  801672:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801676:	0f be c2             	movsbl %dl,%eax
  801679:	85 c0                	test   %eax,%eax
  80167b:	74 27                	je     8016a4 <vprintfmt+0x286>
  80167d:	85 db                	test   %ebx,%ebx
  80167f:	78 9e                	js     80161f <vprintfmt+0x201>
  801681:	83 eb 01             	sub    $0x1,%ebx
  801684:	79 99                	jns    80161f <vprintfmt+0x201>
  801686:	89 f8                	mov    %edi,%eax
  801688:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80168b:	8b 75 08             	mov    0x8(%ebp),%esi
  80168e:	89 c3                	mov    %eax,%ebx
  801690:	eb 1a                	jmp    8016ac <vprintfmt+0x28e>
				putch(' ', putdat);
  801692:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801696:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80169d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80169f:	83 eb 01             	sub    $0x1,%ebx
  8016a2:	eb 08                	jmp    8016ac <vprintfmt+0x28e>
  8016a4:	89 fb                	mov    %edi,%ebx
  8016a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016ac:	85 db                	test   %ebx,%ebx
  8016ae:	7f e2                	jg     801692 <vprintfmt+0x274>
  8016b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8016b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016b6:	e9 93 fd ff ff       	jmp    80144e <vprintfmt+0x30>
	if (lflag >= 2)
  8016bb:	83 fa 01             	cmp    $0x1,%edx
  8016be:	7e 16                	jle    8016d6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  8016c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c3:	8d 50 08             	lea    0x8(%eax),%edx
  8016c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c9:	8b 50 04             	mov    0x4(%eax),%edx
  8016cc:	8b 00                	mov    (%eax),%eax
  8016ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8016d4:	eb 32                	jmp    801708 <vprintfmt+0x2ea>
	else if (lflag)
  8016d6:	85 d2                	test   %edx,%edx
  8016d8:	74 18                	je     8016f2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8016da:	8b 45 14             	mov    0x14(%ebp),%eax
  8016dd:	8d 50 04             	lea    0x4(%eax),%edx
  8016e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8016e3:	8b 30                	mov    (%eax),%esi
  8016e5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016e8:	89 f0                	mov    %esi,%eax
  8016ea:	c1 f8 1f             	sar    $0x1f,%eax
  8016ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016f0:	eb 16                	jmp    801708 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8016f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f5:	8d 50 04             	lea    0x4(%eax),%edx
  8016f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016fb:	8b 30                	mov    (%eax),%esi
  8016fd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801700:	89 f0                	mov    %esi,%eax
  801702:	c1 f8 1f             	sar    $0x1f,%eax
  801705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  801708:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80170b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  80170e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  801713:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801717:	0f 89 80 00 00 00    	jns    80179d <vprintfmt+0x37f>
				putch('-', putdat);
  80171d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801721:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801728:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80172b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80172e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801731:	f7 d8                	neg    %eax
  801733:	83 d2 00             	adc    $0x0,%edx
  801736:	f7 da                	neg    %edx
			base = 10;
  801738:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80173d:	eb 5e                	jmp    80179d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80173f:	8d 45 14             	lea    0x14(%ebp),%eax
  801742:	e8 58 fc ff ff       	call   80139f <getuint>
			base = 10;
  801747:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80174c:	eb 4f                	jmp    80179d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80174e:	8d 45 14             	lea    0x14(%ebp),%eax
  801751:	e8 49 fc ff ff       	call   80139f <getuint>
            base = 8;
  801756:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80175b:	eb 40                	jmp    80179d <vprintfmt+0x37f>
			putch('0', putdat);
  80175d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801761:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801768:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80176b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80176f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801776:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  801779:	8b 45 14             	mov    0x14(%ebp),%eax
  80177c:	8d 50 04             	lea    0x4(%eax),%edx
  80177f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801782:	8b 00                	mov    (%eax),%eax
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  801789:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80178e:	eb 0d                	jmp    80179d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  801790:	8d 45 14             	lea    0x14(%ebp),%eax
  801793:	e8 07 fc ff ff       	call   80139f <getuint>
			base = 16;
  801798:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80179d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8017a1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8017a5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8017a8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017ac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017b0:	89 04 24             	mov    %eax,(%esp)
  8017b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017b7:	89 fa                	mov    %edi,%edx
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	e8 ef fa ff ff       	call   8012b0 <printnum>
			break;
  8017c1:	e9 88 fc ff ff       	jmp    80144e <vprintfmt+0x30>
			putch(ch, putdat);
  8017c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017ca:	89 04 24             	mov    %eax,(%esp)
  8017cd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8017d0:	e9 79 fc ff ff       	jmp    80144e <vprintfmt+0x30>
			putch('%', putdat);
  8017d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017d9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017e0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017e3:	89 f3                	mov    %esi,%ebx
  8017e5:	eb 03                	jmp    8017ea <vprintfmt+0x3cc>
  8017e7:	83 eb 01             	sub    $0x1,%ebx
  8017ea:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017ee:	75 f7                	jne    8017e7 <vprintfmt+0x3c9>
  8017f0:	e9 59 fc ff ff       	jmp    80144e <vprintfmt+0x30>
}
  8017f5:	83 c4 3c             	add    $0x3c,%esp
  8017f8:	5b                   	pop    %ebx
  8017f9:	5e                   	pop    %esi
  8017fa:	5f                   	pop    %edi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	83 ec 28             	sub    $0x28,%esp
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801809:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80180c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801810:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801813:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80181a:	85 c0                	test   %eax,%eax
  80181c:	74 30                	je     80184e <vsnprintf+0x51>
  80181e:	85 d2                	test   %edx,%edx
  801820:	7e 2c                	jle    80184e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801822:	8b 45 14             	mov    0x14(%ebp),%eax
  801825:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801829:	8b 45 10             	mov    0x10(%ebp),%eax
  80182c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801830:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801833:	89 44 24 04          	mov    %eax,0x4(%esp)
  801837:	c7 04 24 d9 13 80 00 	movl   $0x8013d9,(%esp)
  80183e:	e8 db fb ff ff       	call   80141e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801843:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801846:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184c:	eb 05                	jmp    801853 <vsnprintf+0x56>
		return -E_INVAL;
  80184e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80185b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80185e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801862:	8b 45 10             	mov    0x10(%ebp),%eax
  801865:	89 44 24 08          	mov    %eax,0x8(%esp)
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 82 ff ff ff       	call   8017fd <vsnprintf>
	va_end(ap);

	return rc;
}
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    
  80187d:	66 90                	xchg   %ax,%ax
  80187f:	90                   	nop

00801880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
  80188b:	eb 03                	jmp    801890 <strlen+0x10>
		n++;
  80188d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801890:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801894:	75 f7                	jne    80188d <strlen+0xd>
	return n;
}
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a6:	eb 03                	jmp    8018ab <strnlen+0x13>
		n++;
  8018a8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018ab:	39 d0                	cmp    %edx,%eax
  8018ad:	74 06                	je     8018b5 <strnlen+0x1d>
  8018af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8018b3:	75 f3                	jne    8018a8 <strnlen+0x10>
	return n;
}
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	53                   	push   %ebx
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018c1:	89 c2                	mov    %eax,%edx
  8018c3:	83 c2 01             	add    $0x1,%edx
  8018c6:	83 c1 01             	add    $0x1,%ecx
  8018c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8018cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018d0:	84 db                	test   %bl,%bl
  8018d2:	75 ef                	jne    8018c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8018d4:	5b                   	pop    %ebx
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	53                   	push   %ebx
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018e1:	89 1c 24             	mov    %ebx,(%esp)
  8018e4:	e8 97 ff ff ff       	call   801880 <strlen>
	strcpy(dst + len, src);
  8018e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018f0:	01 d8                	add    %ebx,%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 bd ff ff ff       	call   8018b7 <strcpy>
	return dst;
}
  8018fa:	89 d8                	mov    %ebx,%eax
  8018fc:	83 c4 08             	add    $0x8,%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	8b 75 08             	mov    0x8(%ebp),%esi
  80190a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80190d:	89 f3                	mov    %esi,%ebx
  80190f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801912:	89 f2                	mov    %esi,%edx
  801914:	eb 0f                	jmp    801925 <strncpy+0x23>
		*dst++ = *src;
  801916:	83 c2 01             	add    $0x1,%edx
  801919:	0f b6 01             	movzbl (%ecx),%eax
  80191c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80191f:	80 39 01             	cmpb   $0x1,(%ecx)
  801922:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801925:	39 da                	cmp    %ebx,%edx
  801927:	75 ed                	jne    801916 <strncpy+0x14>
	}
	return ret;
}
  801929:	89 f0                	mov    %esi,%eax
  80192b:	5b                   	pop    %ebx
  80192c:	5e                   	pop    %esi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	8b 75 08             	mov    0x8(%ebp),%esi
  801937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80193d:	89 f0                	mov    %esi,%eax
  80193f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801943:	85 c9                	test   %ecx,%ecx
  801945:	75 0b                	jne    801952 <strlcpy+0x23>
  801947:	eb 1d                	jmp    801966 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801949:	83 c0 01             	add    $0x1,%eax
  80194c:	83 c2 01             	add    $0x1,%edx
  80194f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801952:	39 d8                	cmp    %ebx,%eax
  801954:	74 0b                	je     801961 <strlcpy+0x32>
  801956:	0f b6 0a             	movzbl (%edx),%ecx
  801959:	84 c9                	test   %cl,%cl
  80195b:	75 ec                	jne    801949 <strlcpy+0x1a>
  80195d:	89 c2                	mov    %eax,%edx
  80195f:	eb 02                	jmp    801963 <strlcpy+0x34>
  801961:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  801963:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801966:	29 f0                	sub    %esi,%eax
}
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801972:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801975:	eb 06                	jmp    80197d <strcmp+0x11>
		p++, q++;
  801977:	83 c1 01             	add    $0x1,%ecx
  80197a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80197d:	0f b6 01             	movzbl (%ecx),%eax
  801980:	84 c0                	test   %al,%al
  801982:	74 04                	je     801988 <strcmp+0x1c>
  801984:	3a 02                	cmp    (%edx),%al
  801986:	74 ef                	je     801977 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801988:	0f b6 c0             	movzbl %al,%eax
  80198b:	0f b6 12             	movzbl (%edx),%edx
  80198e:	29 d0                	sub    %edx,%eax
}
  801990:	5d                   	pop    %ebp
  801991:	c3                   	ret    

00801992 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	53                   	push   %ebx
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
  801999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199c:	89 c3                	mov    %eax,%ebx
  80199e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8019a1:	eb 06                	jmp    8019a9 <strncmp+0x17>
		n--, p++, q++;
  8019a3:	83 c0 01             	add    $0x1,%eax
  8019a6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8019a9:	39 d8                	cmp    %ebx,%eax
  8019ab:	74 15                	je     8019c2 <strncmp+0x30>
  8019ad:	0f b6 08             	movzbl (%eax),%ecx
  8019b0:	84 c9                	test   %cl,%cl
  8019b2:	74 04                	je     8019b8 <strncmp+0x26>
  8019b4:	3a 0a                	cmp    (%edx),%cl
  8019b6:	74 eb                	je     8019a3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8019b8:	0f b6 00             	movzbl (%eax),%eax
  8019bb:	0f b6 12             	movzbl (%edx),%edx
  8019be:	29 d0                	sub    %edx,%eax
  8019c0:	eb 05                	jmp    8019c7 <strncmp+0x35>
		return 0;
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c7:	5b                   	pop    %ebx
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8019d4:	eb 07                	jmp    8019dd <strchr+0x13>
		if (*s == c)
  8019d6:	38 ca                	cmp    %cl,%dl
  8019d8:	74 0f                	je     8019e9 <strchr+0x1f>
	for (; *s; s++)
  8019da:	83 c0 01             	add    $0x1,%eax
  8019dd:	0f b6 10             	movzbl (%eax),%edx
  8019e0:	84 d2                	test   %dl,%dl
  8019e2:	75 f2                	jne    8019d6 <strchr+0xc>
			return (char *) s;
	return 0;
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8019f5:	eb 07                	jmp    8019fe <strfind+0x13>
		if (*s == c)
  8019f7:	38 ca                	cmp    %cl,%dl
  8019f9:	74 0a                	je     801a05 <strfind+0x1a>
	for (; *s; s++)
  8019fb:	83 c0 01             	add    $0x1,%eax
  8019fe:	0f b6 10             	movzbl (%eax),%edx
  801a01:	84 d2                	test   %dl,%dl
  801a03:	75 f2                	jne    8019f7 <strfind+0xc>
			break;
	return (char *) s;
}
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	57                   	push   %edi
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801a13:	85 c9                	test   %ecx,%ecx
  801a15:	74 36                	je     801a4d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801a17:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a1d:	75 28                	jne    801a47 <memset+0x40>
  801a1f:	f6 c1 03             	test   $0x3,%cl
  801a22:	75 23                	jne    801a47 <memset+0x40>
		c &= 0xFF;
  801a24:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801a28:	89 d3                	mov    %edx,%ebx
  801a2a:	c1 e3 08             	shl    $0x8,%ebx
  801a2d:	89 d6                	mov    %edx,%esi
  801a2f:	c1 e6 18             	shl    $0x18,%esi
  801a32:	89 d0                	mov    %edx,%eax
  801a34:	c1 e0 10             	shl    $0x10,%eax
  801a37:	09 f0                	or     %esi,%eax
  801a39:	09 c2                	or     %eax,%edx
  801a3b:	89 d0                	mov    %edx,%eax
  801a3d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a3f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801a42:	fc                   	cld    
  801a43:	f3 ab                	rep stos %eax,%es:(%edi)
  801a45:	eb 06                	jmp    801a4d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4a:	fc                   	cld    
  801a4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a4d:	89 f8                	mov    %edi,%eax
  801a4f:	5b                   	pop    %ebx
  801a50:	5e                   	pop    %esi
  801a51:	5f                   	pop    %edi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	57                   	push   %edi
  801a58:	56                   	push   %esi
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a62:	39 c6                	cmp    %eax,%esi
  801a64:	73 35                	jae    801a9b <memmove+0x47>
  801a66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a69:	39 d0                	cmp    %edx,%eax
  801a6b:	73 2e                	jae    801a9b <memmove+0x47>
		s += n;
		d += n;
  801a6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a70:	89 d6                	mov    %edx,%esi
  801a72:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a7a:	75 13                	jne    801a8f <memmove+0x3b>
  801a7c:	f6 c1 03             	test   $0x3,%cl
  801a7f:	75 0e                	jne    801a8f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a81:	83 ef 04             	sub    $0x4,%edi
  801a84:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a87:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801a8a:	fd                   	std    
  801a8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a8d:	eb 09                	jmp    801a98 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a8f:	83 ef 01             	sub    $0x1,%edi
  801a92:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801a95:	fd                   	std    
  801a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a98:	fc                   	cld    
  801a99:	eb 1d                	jmp    801ab8 <memmove+0x64>
  801a9b:	89 f2                	mov    %esi,%edx
  801a9d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a9f:	f6 c2 03             	test   $0x3,%dl
  801aa2:	75 0f                	jne    801ab3 <memmove+0x5f>
  801aa4:	f6 c1 03             	test   $0x3,%cl
  801aa7:	75 0a                	jne    801ab3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801aa9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801aac:	89 c7                	mov    %eax,%edi
  801aae:	fc                   	cld    
  801aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ab1:	eb 05                	jmp    801ab8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801ab3:	89 c7                	mov    %eax,%edi
  801ab5:	fc                   	cld    
  801ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801ac2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad3:	89 04 24             	mov    %eax,(%esp)
  801ad6:	e8 79 ff ff ff       	call   801a54 <memmove>
}
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	56                   	push   %esi
  801ae1:	53                   	push   %ebx
  801ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ae5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae8:	89 d6                	mov    %edx,%esi
  801aea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801aed:	eb 1a                	jmp    801b09 <memcmp+0x2c>
		if (*s1 != *s2)
  801aef:	0f b6 02             	movzbl (%edx),%eax
  801af2:	0f b6 19             	movzbl (%ecx),%ebx
  801af5:	38 d8                	cmp    %bl,%al
  801af7:	74 0a                	je     801b03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801af9:	0f b6 c0             	movzbl %al,%eax
  801afc:	0f b6 db             	movzbl %bl,%ebx
  801aff:	29 d8                	sub    %ebx,%eax
  801b01:	eb 0f                	jmp    801b12 <memcmp+0x35>
		s1++, s2++;
  801b03:	83 c2 01             	add    $0x1,%edx
  801b06:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  801b09:	39 f2                	cmp    %esi,%edx
  801b0b:	75 e2                	jne    801aef <memcmp+0x12>
	}

	return 0;
  801b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b12:	5b                   	pop    %ebx
  801b13:	5e                   	pop    %esi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801b24:	eb 07                	jmp    801b2d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801b26:	38 08                	cmp    %cl,(%eax)
  801b28:	74 07                	je     801b31 <memfind+0x1b>
	for (; s < ends; s++)
  801b2a:	83 c0 01             	add    $0x1,%eax
  801b2d:	39 d0                	cmp    %edx,%eax
  801b2f:	72 f5                	jb     801b26 <memfind+0x10>
			break;
	return (void *) s;
}
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	57                   	push   %edi
  801b37:	56                   	push   %esi
  801b38:	53                   	push   %ebx
  801b39:	8b 55 08             	mov    0x8(%ebp),%edx
  801b3c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b3f:	eb 03                	jmp    801b44 <strtol+0x11>
		s++;
  801b41:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801b44:	0f b6 0a             	movzbl (%edx),%ecx
  801b47:	80 f9 09             	cmp    $0x9,%cl
  801b4a:	74 f5                	je     801b41 <strtol+0xe>
  801b4c:	80 f9 20             	cmp    $0x20,%cl
  801b4f:	74 f0                	je     801b41 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801b51:	80 f9 2b             	cmp    $0x2b,%cl
  801b54:	75 0a                	jne    801b60 <strtol+0x2d>
		s++;
  801b56:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801b59:	bf 00 00 00 00       	mov    $0x0,%edi
  801b5e:	eb 11                	jmp    801b71 <strtol+0x3e>
  801b60:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  801b65:	80 f9 2d             	cmp    $0x2d,%cl
  801b68:	75 07                	jne    801b71 <strtol+0x3e>
		s++, neg = 1;
  801b6a:	8d 52 01             	lea    0x1(%edx),%edx
  801b6d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b71:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b76:	75 15                	jne    801b8d <strtol+0x5a>
  801b78:	80 3a 30             	cmpb   $0x30,(%edx)
  801b7b:	75 10                	jne    801b8d <strtol+0x5a>
  801b7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b81:	75 0a                	jne    801b8d <strtol+0x5a>
		s += 2, base = 16;
  801b83:	83 c2 02             	add    $0x2,%edx
  801b86:	b8 10 00 00 00       	mov    $0x10,%eax
  801b8b:	eb 10                	jmp    801b9d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	75 0c                	jne    801b9d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801b91:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801b93:	80 3a 30             	cmpb   $0x30,(%edx)
  801b96:	75 05                	jne    801b9d <strtol+0x6a>
		s++, base = 8;
  801b98:	83 c2 01             	add    $0x1,%edx
  801b9b:	b0 08                	mov    $0x8,%al
		base = 10;
  801b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ba5:	0f b6 0a             	movzbl (%edx),%ecx
  801ba8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801bab:	89 f0                	mov    %esi,%eax
  801bad:	3c 09                	cmp    $0x9,%al
  801baf:	77 08                	ja     801bb9 <strtol+0x86>
			dig = *s - '0';
  801bb1:	0f be c9             	movsbl %cl,%ecx
  801bb4:	83 e9 30             	sub    $0x30,%ecx
  801bb7:	eb 20                	jmp    801bd9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801bb9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801bbc:	89 f0                	mov    %esi,%eax
  801bbe:	3c 19                	cmp    $0x19,%al
  801bc0:	77 08                	ja     801bca <strtol+0x97>
			dig = *s - 'a' + 10;
  801bc2:	0f be c9             	movsbl %cl,%ecx
  801bc5:	83 e9 57             	sub    $0x57,%ecx
  801bc8:	eb 0f                	jmp    801bd9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  801bca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801bcd:	89 f0                	mov    %esi,%eax
  801bcf:	3c 19                	cmp    $0x19,%al
  801bd1:	77 16                	ja     801be9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801bd3:	0f be c9             	movsbl %cl,%ecx
  801bd6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801bd9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801bdc:	7d 0f                	jge    801bed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  801bde:	83 c2 01             	add    $0x1,%edx
  801be1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801be5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801be7:	eb bc                	jmp    801ba5 <strtol+0x72>
  801be9:	89 d8                	mov    %ebx,%eax
  801beb:	eb 02                	jmp    801bef <strtol+0xbc>
  801bed:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801bef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bf3:	74 05                	je     801bfa <strtol+0xc7>
		*endptr = (char *) s;
  801bf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bf8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801bfa:	f7 d8                	neg    %eax
  801bfc:	85 ff                	test   %edi,%edi
  801bfe:	0f 44 c3             	cmove  %ebx,%eax
}
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 18             	sub    $0x18,%esp
	//panic("Testing to see when this is first called");
    int r;

	if (_pgfault_handler == 0) {
  801c0c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801c13:	75 70                	jne    801c85 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.

		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W); // First, let's allocate some stuff here.
  801c15:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c1c:	00 
  801c1d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801c24:	ee 
  801c25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2c:	e8 56 e5 ff ff       	call   800187 <sys_page_alloc>
                                                                                    // Since it says at a page "UXSTACKTOP", let's minus a pg size just in case.
		if(r < 0)
  801c31:	85 c0                	test   %eax,%eax
  801c33:	79 1c                	jns    801c51 <set_pgfault_handler+0x4b>
        {
            panic("Set_pgfault_handler: page alloc error");
  801c35:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  801c3c:	00 
  801c3d:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801c44:	00 
  801c45:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  801c4c:	e8 45 f5 ff ff       	call   801196 <_panic>
        }
        r = sys_env_set_pgfault_upcall(0, _pgfault_upcall); // Now, setup the upcall.
  801c51:	c7 44 24 04 ef 03 80 	movl   $0x8003ef,0x4(%esp)
  801c58:	00 
  801c59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c60:	e8 c2 e6 ff ff       	call   800327 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801c65:	85 c0                	test   %eax,%eax
  801c67:	79 1c                	jns    801c85 <set_pgfault_handler+0x7f>
        {
            panic("set_pgfault_handler: pgfault upcall error, bad env");
  801c69:	c7 44 24 08 08 25 80 	movl   $0x802508,0x8(%esp)
  801c70:	00 
  801c71:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801c78:	00 
  801c79:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  801c80:	e8 11 f5 ff ff       	call   801196 <_panic>
        }
        //panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801c85:	8b 45 08             	mov    0x8(%ebp),%eax
  801c88:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    
  801c8f:	90                   	nop

00801c90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	83 ec 10             	sub    $0x10,%esp
  801c98:	8b 75 08             	mov    0x8(%ebp),%esi
  801c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801ca1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801ca3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ca8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801cab:	89 04 24             	mov    %eax,(%esp)
  801cae:	e8 ea e6 ff ff       	call   80039d <sys_ipc_recv>
    if(r < 0){
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	79 16                	jns    801ccd <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801cb7:	85 f6                	test   %esi,%esi
  801cb9:	74 06                	je     801cc1 <ipc_recv+0x31>
            *from_env_store = 0;
  801cbb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801cc1:	85 db                	test   %ebx,%ebx
  801cc3:	74 2c                	je     801cf1 <ipc_recv+0x61>
            *perm_store = 0;
  801cc5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ccb:	eb 24                	jmp    801cf1 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801ccd:	85 f6                	test   %esi,%esi
  801ccf:	74 0a                	je     801cdb <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801cd1:	a1 08 40 80 00       	mov    0x804008,%eax
  801cd6:	8b 40 74             	mov    0x74(%eax),%eax
  801cd9:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801cdb:	85 db                	test   %ebx,%ebx
  801cdd:	74 0a                	je     801ce9 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801cdf:	a1 08 40 80 00       	mov    0x804008,%eax
  801ce4:	8b 40 78             	mov    0x78(%eax),%eax
  801ce7:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ce9:	a1 08 40 80 00       	mov    0x804008,%eax
  801cee:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	57                   	push   %edi
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 1c             	sub    $0x1c,%esp
  801d01:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801d0a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801d0c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801d11:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801d14:	8b 45 14             	mov    0x14(%ebp),%eax
  801d17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	e8 4f e6 ff ff       	call   80037a <sys_ipc_try_send>
        if(r == 0){
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	74 28                	je     801d57 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801d2f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d32:	74 1c                	je     801d50 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801d34:	c7 44 24 08 4a 25 80 	movl   $0x80254a,0x8(%esp)
  801d3b:	00 
  801d3c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801d43:	00 
  801d44:	c7 04 24 61 25 80 00 	movl   $0x802561,(%esp)
  801d4b:	e8 46 f4 ff ff       	call   801196 <_panic>
        }
        sys_yield();
  801d50:	e8 13 e4 ff ff       	call   800168 <sys_yield>
    }
  801d55:	eb bd                	jmp    801d14 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801d57:	83 c4 1c             	add    $0x1c,%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d65:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d6a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d6d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d73:	8b 52 50             	mov    0x50(%edx),%edx
  801d76:	39 ca                	cmp    %ecx,%edx
  801d78:	75 0d                	jne    801d87 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d7a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d7d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d82:	8b 40 40             	mov    0x40(%eax),%eax
  801d85:	eb 0e                	jmp    801d95 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801d87:	83 c0 01             	add    $0x1,%eax
  801d8a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d8f:	75 d9                	jne    801d6a <ipc_find_env+0xb>
	return 0;
  801d91:	66 b8 00 00          	mov    $0x0,%ax
}
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d9d:	89 d0                	mov    %edx,%eax
  801d9f:	c1 e8 16             	shr    $0x16,%eax
  801da2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801dae:	f6 c1 01             	test   $0x1,%cl
  801db1:	74 1d                	je     801dd0 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801db3:	c1 ea 0c             	shr    $0xc,%edx
  801db6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dbd:	f6 c2 01             	test   $0x1,%dl
  801dc0:	74 0e                	je     801dd0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dc2:	c1 ea 0c             	shr    $0xc,%edx
  801dc5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dcc:	ef 
  801dcd:	0f b7 c0             	movzwl %ax,%eax
}
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    
  801dd2:	66 90                	xchg   %ax,%ax
  801dd4:	66 90                	xchg   %ax,%ax
  801dd6:	66 90                	xchg   %ax,%ax
  801dd8:	66 90                	xchg   %ax,%ax
  801dda:	66 90                	xchg   %ax,%ax
  801ddc:	66 90                	xchg   %ax,%ax
  801dde:	66 90                	xchg   %ax,%ax

00801de0 <__udivdi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801dea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801dee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801df2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801df6:	85 c0                	test   %eax,%eax
  801df8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dfc:	89 ea                	mov    %ebp,%edx
  801dfe:	89 0c 24             	mov    %ecx,(%esp)
  801e01:	75 2d                	jne    801e30 <__udivdi3+0x50>
  801e03:	39 e9                	cmp    %ebp,%ecx
  801e05:	77 61                	ja     801e68 <__udivdi3+0x88>
  801e07:	85 c9                	test   %ecx,%ecx
  801e09:	89 ce                	mov    %ecx,%esi
  801e0b:	75 0b                	jne    801e18 <__udivdi3+0x38>
  801e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e12:	31 d2                	xor    %edx,%edx
  801e14:	f7 f1                	div    %ecx
  801e16:	89 c6                	mov    %eax,%esi
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	89 e8                	mov    %ebp,%eax
  801e1c:	f7 f6                	div    %esi
  801e1e:	89 c5                	mov    %eax,%ebp
  801e20:	89 f8                	mov    %edi,%eax
  801e22:	f7 f6                	div    %esi
  801e24:	89 ea                	mov    %ebp,%edx
  801e26:	83 c4 0c             	add    $0xc,%esp
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	39 e8                	cmp    %ebp,%eax
  801e32:	77 24                	ja     801e58 <__udivdi3+0x78>
  801e34:	0f bd e8             	bsr    %eax,%ebp
  801e37:	83 f5 1f             	xor    $0x1f,%ebp
  801e3a:	75 3c                	jne    801e78 <__udivdi3+0x98>
  801e3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e40:	39 34 24             	cmp    %esi,(%esp)
  801e43:	0f 86 9f 00 00 00    	jbe    801ee8 <__udivdi3+0x108>
  801e49:	39 d0                	cmp    %edx,%eax
  801e4b:	0f 82 97 00 00 00    	jb     801ee8 <__udivdi3+0x108>
  801e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e58:	31 d2                	xor    %edx,%edx
  801e5a:	31 c0                	xor    %eax,%eax
  801e5c:	83 c4 0c             	add    $0xc,%esp
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    
  801e63:	90                   	nop
  801e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e68:	89 f8                	mov    %edi,%eax
  801e6a:	f7 f1                	div    %ecx
  801e6c:	31 d2                	xor    %edx,%edx
  801e6e:	83 c4 0c             	add    $0xc,%esp
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	8b 3c 24             	mov    (%esp),%edi
  801e7d:	d3 e0                	shl    %cl,%eax
  801e7f:	89 c6                	mov    %eax,%esi
  801e81:	b8 20 00 00 00       	mov    $0x20,%eax
  801e86:	29 e8                	sub    %ebp,%eax
  801e88:	89 c1                	mov    %eax,%ecx
  801e8a:	d3 ef                	shr    %cl,%edi
  801e8c:	89 e9                	mov    %ebp,%ecx
  801e8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e92:	8b 3c 24             	mov    (%esp),%edi
  801e95:	09 74 24 08          	or     %esi,0x8(%esp)
  801e99:	89 d6                	mov    %edx,%esi
  801e9b:	d3 e7                	shl    %cl,%edi
  801e9d:	89 c1                	mov    %eax,%ecx
  801e9f:	89 3c 24             	mov    %edi,(%esp)
  801ea2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ea6:	d3 ee                	shr    %cl,%esi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	d3 e2                	shl    %cl,%edx
  801eac:	89 c1                	mov    %eax,%ecx
  801eae:	d3 ef                	shr    %cl,%edi
  801eb0:	09 d7                	or     %edx,%edi
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	89 f8                	mov    %edi,%eax
  801eb6:	f7 74 24 08          	divl   0x8(%esp)
  801eba:	89 d6                	mov    %edx,%esi
  801ebc:	89 c7                	mov    %eax,%edi
  801ebe:	f7 24 24             	mull   (%esp)
  801ec1:	39 d6                	cmp    %edx,%esi
  801ec3:	89 14 24             	mov    %edx,(%esp)
  801ec6:	72 30                	jb     801ef8 <__udivdi3+0x118>
  801ec8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ecc:	89 e9                	mov    %ebp,%ecx
  801ece:	d3 e2                	shl    %cl,%edx
  801ed0:	39 c2                	cmp    %eax,%edx
  801ed2:	73 05                	jae    801ed9 <__udivdi3+0xf9>
  801ed4:	3b 34 24             	cmp    (%esp),%esi
  801ed7:	74 1f                	je     801ef8 <__udivdi3+0x118>
  801ed9:	89 f8                	mov    %edi,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	e9 7a ff ff ff       	jmp    801e5c <__udivdi3+0x7c>
  801ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee8:	31 d2                	xor    %edx,%edx
  801eea:	b8 01 00 00 00       	mov    $0x1,%eax
  801eef:	e9 68 ff ff ff       	jmp    801e5c <__udivdi3+0x7c>
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	83 c4 0c             	add    $0xc,%esp
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    
  801f04:	66 90                	xchg   %ax,%ax
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	66 90                	xchg   %ax,%ax
  801f0a:	66 90                	xchg   %ax,%ax
  801f0c:	66 90                	xchg   %ax,%ax
  801f0e:	66 90                	xchg   %ax,%ax

00801f10 <__umoddi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	83 ec 14             	sub    $0x14,%esp
  801f16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f22:	89 c7                	mov    %eax,%edi
  801f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f28:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f30:	89 34 24             	mov    %esi,(%esp)
  801f33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	89 c2                	mov    %eax,%edx
  801f3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f3f:	75 17                	jne    801f58 <__umoddi3+0x48>
  801f41:	39 fe                	cmp    %edi,%esi
  801f43:	76 4b                	jbe    801f90 <__umoddi3+0x80>
  801f45:	89 c8                	mov    %ecx,%eax
  801f47:	89 fa                	mov    %edi,%edx
  801f49:	f7 f6                	div    %esi
  801f4b:	89 d0                	mov    %edx,%eax
  801f4d:	31 d2                	xor    %edx,%edx
  801f4f:	83 c4 14             	add    $0x14,%esp
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	39 f8                	cmp    %edi,%eax
  801f5a:	77 54                	ja     801fb0 <__umoddi3+0xa0>
  801f5c:	0f bd e8             	bsr    %eax,%ebp
  801f5f:	83 f5 1f             	xor    $0x1f,%ebp
  801f62:	75 5c                	jne    801fc0 <__umoddi3+0xb0>
  801f64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f68:	39 3c 24             	cmp    %edi,(%esp)
  801f6b:	0f 87 e7 00 00 00    	ja     802058 <__umoddi3+0x148>
  801f71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f75:	29 f1                	sub    %esi,%ecx
  801f77:	19 c7                	sbb    %eax,%edi
  801f79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f81:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f89:	83 c4 14             	add    $0x14,%esp
  801f8c:	5e                   	pop    %esi
  801f8d:	5f                   	pop    %edi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    
  801f90:	85 f6                	test   %esi,%esi
  801f92:	89 f5                	mov    %esi,%ebp
  801f94:	75 0b                	jne    801fa1 <__umoddi3+0x91>
  801f96:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	f7 f6                	div    %esi
  801f9f:	89 c5                	mov    %eax,%ebp
  801fa1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fa5:	31 d2                	xor    %edx,%edx
  801fa7:	f7 f5                	div    %ebp
  801fa9:	89 c8                	mov    %ecx,%eax
  801fab:	f7 f5                	div    %ebp
  801fad:	eb 9c                	jmp    801f4b <__umoddi3+0x3b>
  801faf:	90                   	nop
  801fb0:	89 c8                	mov    %ecx,%eax
  801fb2:	89 fa                	mov    %edi,%edx
  801fb4:	83 c4 14             	add    $0x14,%esp
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    
  801fbb:	90                   	nop
  801fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	8b 04 24             	mov    (%esp),%eax
  801fc3:	be 20 00 00 00       	mov    $0x20,%esi
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	29 ee                	sub    %ebp,%esi
  801fcc:	d3 e2                	shl    %cl,%edx
  801fce:	89 f1                	mov    %esi,%ecx
  801fd0:	d3 e8                	shr    %cl,%eax
  801fd2:	89 e9                	mov    %ebp,%ecx
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	8b 04 24             	mov    (%esp),%eax
  801fdb:	09 54 24 04          	or     %edx,0x4(%esp)
  801fdf:	89 fa                	mov    %edi,%edx
  801fe1:	d3 e0                	shl    %cl,%eax
  801fe3:	89 f1                	mov    %esi,%ecx
  801fe5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fed:	d3 ea                	shr    %cl,%edx
  801fef:	89 e9                	mov    %ebp,%ecx
  801ff1:	d3 e7                	shl    %cl,%edi
  801ff3:	89 f1                	mov    %esi,%ecx
  801ff5:	d3 e8                	shr    %cl,%eax
  801ff7:	89 e9                	mov    %ebp,%ecx
  801ff9:	09 f8                	or     %edi,%eax
  801ffb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801fff:	f7 74 24 04          	divl   0x4(%esp)
  802003:	d3 e7                	shl    %cl,%edi
  802005:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802009:	89 d7                	mov    %edx,%edi
  80200b:	f7 64 24 08          	mull   0x8(%esp)
  80200f:	39 d7                	cmp    %edx,%edi
  802011:	89 c1                	mov    %eax,%ecx
  802013:	89 14 24             	mov    %edx,(%esp)
  802016:	72 2c                	jb     802044 <__umoddi3+0x134>
  802018:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80201c:	72 22                	jb     802040 <__umoddi3+0x130>
  80201e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802022:	29 c8                	sub    %ecx,%eax
  802024:	19 d7                	sbb    %edx,%edi
  802026:	89 e9                	mov    %ebp,%ecx
  802028:	89 fa                	mov    %edi,%edx
  80202a:	d3 e8                	shr    %cl,%eax
  80202c:	89 f1                	mov    %esi,%ecx
  80202e:	d3 e2                	shl    %cl,%edx
  802030:	89 e9                	mov    %ebp,%ecx
  802032:	d3 ef                	shr    %cl,%edi
  802034:	09 d0                	or     %edx,%eax
  802036:	89 fa                	mov    %edi,%edx
  802038:	83 c4 14             	add    $0x14,%esp
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    
  80203f:	90                   	nop
  802040:	39 d7                	cmp    %edx,%edi
  802042:	75 da                	jne    80201e <__umoddi3+0x10e>
  802044:	8b 14 24             	mov    (%esp),%edx
  802047:	89 c1                	mov    %eax,%ecx
  802049:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80204d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802051:	eb cb                	jmp    80201e <__umoddi3+0x10e>
  802053:	90                   	nop
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80205c:	0f 82 0f ff ff ff    	jb     801f71 <__umoddi3+0x61>
  802062:	e9 1a ff ff ff       	jmp    801f81 <__umoddi3+0x71>
