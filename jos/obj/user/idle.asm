
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 c0 	movl   $0x801fc0,0x803000
  800040:	1f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 11 01 00 00       	call   800159 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	83 ec 10             	sub    $0x10,%esp
  800052:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800055:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800058:	e8 dd 00 00 00       	call   80013a <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  80005d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800062:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 db                	test   %ebx,%ebx
  800071:	7e 07                	jle    80007a <libmain+0x30>
		binaryname = argv[0];
  800073:	8b 06                	mov    (%esi),%eax
  800075:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80007e:	89 1c 24             	mov    %ebx,(%esp)
  800081:	e8 ad ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800086:	e8 07 00 00 00       	call   800092 <exit>
}
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    

00800092 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800098:	e8 18 05 00 00       	call   8005b5 <close_all>
	sys_env_destroy(0);
  80009d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a4:	e8 3f 00 00 00       	call   8000e8 <sys_env_destroy>
}
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	89 c3                	mov    %eax,%ebx
  8000be:	89 c7                	mov    %eax,%edi
  8000c0:	89 c6                	mov    %eax,%esi
  8000c2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	89 d1                	mov    %edx,%ecx
  8000db:	89 d3                	mov    %edx,%ebx
  8000dd:	89 d7                	mov    %edx,%edi
  8000df:	89 d6                	mov    %edx,%esi
  8000e1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
  8000ee:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	89 cb                	mov    %ecx,%ebx
  800100:	89 cf                	mov    %ecx,%edi
  800102:	89 ce                	mov    %ecx,%esi
  800104:	cd 30                	int    $0x30
	if(check && ret > 0)
  800106:	85 c0                	test   %eax,%eax
  800108:	7e 28                	jle    800132 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  80012d:	e8 24 10 00 00       	call   801156 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800132:	83 c4 2c             	add    $0x2c,%esp
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 02 00 00 00       	mov    $0x2,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <sys_yield>:

void
sys_yield(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 0b 00 00 00       	mov    $0xb,%eax
  800169:	89 d1                	mov    %edx,%ecx
  80016b:	89 d3                	mov    %edx,%ebx
  80016d:	89 d7                	mov    %edx,%edi
  80016f:	89 d6                	mov    %edx,%esi
  800171:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800173:	5b                   	pop    %ebx
  800174:	5e                   	pop    %esi
  800175:	5f                   	pop    %edi
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800181:	be 00 00 00 00       	mov    $0x0,%esi
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800194:	89 f7                	mov    %esi,%edi
  800196:	cd 30                	int    $0x30
	if(check && ret > 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	7e 28                	jle    8001c4 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8001af:	00 
  8001b0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b7:	00 
  8001b8:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8001bf:	e8 92 0f 00 00       	call   801156 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c4:	83 c4 2c             	add    $0x2c,%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001eb:	85 c0                	test   %eax,%eax
  8001ed:	7e 28                	jle    800217 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f3:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  800202:	00 
  800203:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020a:	00 
  80020b:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  800212:	e8 3f 0f 00 00       	call   801156 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800217:	83 c4 2c             	add    $0x2c,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5f                   	pop    %edi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	b8 06 00 00 00       	mov    $0x6,%eax
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	89 df                	mov    %ebx,%edi
  80023a:	89 de                	mov    %ebx,%esi
  80023c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023e:	85 c0                	test   %eax,%eax
  800240:	7e 28                	jle    80026a <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800242:	89 44 24 10          	mov    %eax,0x10(%esp)
  800246:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024d:	00 
  80024e:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  800255:	00 
  800256:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025d:	00 
  80025e:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  800265:	e8 ec 0e 00 00       	call   801156 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026a:	83 c4 2c             	add    $0x2c,%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80027b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800280:	b8 08 00 00 00       	mov    $0x8,%eax
  800285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	89 df                	mov    %ebx,%edi
  80028d:	89 de                	mov    %ebx,%esi
  80028f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800291:	85 c0                	test   %eax,%eax
  800293:	7e 28                	jle    8002bd <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800295:	89 44 24 10          	mov    %eax,0x10(%esp)
  800299:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a0:	00 
  8002a1:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8002a8:	00 
  8002a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b0:	00 
  8002b1:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8002b8:	e8 99 0e 00 00       	call   801156 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002bd:	83 c4 2c             	add    $0x2c,%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	89 df                	mov    %ebx,%edi
  8002e0:	89 de                	mov    %ebx,%esi
  8002e2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7e 28                	jle    800310 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ec:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f3:	00 
  8002f4:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8002fb:	00 
  8002fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800303:	00 
  800304:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  80030b:	e8 46 0e 00 00       	call   801156 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800310:	83 c4 2c             	add    $0x2c,%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	b8 0a 00 00 00       	mov    $0xa,%eax
  80032b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	89 df                	mov    %ebx,%edi
  800333:	89 de                	mov    %ebx,%esi
  800335:	cd 30                	int    $0x30
	if(check && ret > 0)
  800337:	85 c0                	test   %eax,%eax
  800339:	7e 28                	jle    800363 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80033f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800346:	00 
  800347:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  80034e:	00 
  80034f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800356:	00 
  800357:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  80035e:	e8 f3 0d 00 00       	call   801156 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800363:	83 c4 2c             	add    $0x2c,%esp
  800366:	5b                   	pop    %ebx
  800367:	5e                   	pop    %esi
  800368:	5f                   	pop    %edi
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
	asm volatile("int %1\n"
  800371:	be 00 00 00 00       	mov    $0x0,%esi
  800376:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
  800394:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800397:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039c:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a4:	89 cb                	mov    %ecx,%ebx
  8003a6:	89 cf                	mov    %ecx,%edi
  8003a8:	89 ce                	mov    %ecx,%esi
  8003aa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	7e 28                	jle    8003d8 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b4:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003bb:	00 
  8003bc:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8003c3:	00 
  8003c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003cb:	00 
  8003cc:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8003d3:	e8 7e 0d 00 00       	call   801156 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d8:	83 c4 2c             	add    $0x2c,%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800400:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800412:	89 c2                	mov    %eax,%edx
  800414:	c1 ea 16             	shr    $0x16,%edx
  800417:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041e:	f6 c2 01             	test   $0x1,%dl
  800421:	74 11                	je     800434 <fd_alloc+0x2d>
  800423:	89 c2                	mov    %eax,%edx
  800425:	c1 ea 0c             	shr    $0xc,%edx
  800428:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042f:	f6 c2 01             	test   $0x1,%dl
  800432:	75 09                	jne    80043d <fd_alloc+0x36>
			*fd_store = fd;
  800434:	89 01                	mov    %eax,(%ecx)
			return 0;
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	eb 17                	jmp    800454 <fd_alloc+0x4d>
  80043d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800442:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800447:	75 c9                	jne    800412 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800449:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80044f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80045c:	83 f8 1f             	cmp    $0x1f,%eax
  80045f:	77 36                	ja     800497 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800461:	c1 e0 0c             	shl    $0xc,%eax
  800464:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800469:	89 c2                	mov    %eax,%edx
  80046b:	c1 ea 16             	shr    $0x16,%edx
  80046e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800475:	f6 c2 01             	test   $0x1,%dl
  800478:	74 24                	je     80049e <fd_lookup+0x48>
  80047a:	89 c2                	mov    %eax,%edx
  80047c:	c1 ea 0c             	shr    $0xc,%edx
  80047f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800486:	f6 c2 01             	test   $0x1,%dl
  800489:	74 1a                	je     8004a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80048b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048e:	89 02                	mov    %eax,(%edx)
	return 0;
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	eb 13                	jmp    8004aa <fd_lookup+0x54>
		return -E_INVAL;
  800497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80049c:	eb 0c                	jmp    8004aa <fd_lookup+0x54>
		return -E_INVAL;
  80049e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a3:	eb 05                	jmp    8004aa <fd_lookup+0x54>
  8004a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004aa:	5d                   	pop    %ebp
  8004ab:	c3                   	ret    

008004ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	83 ec 18             	sub    $0x18,%esp
  8004b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b5:	ba 78 20 80 00       	mov    $0x802078,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004ba:	eb 13                	jmp    8004cf <dev_lookup+0x23>
  8004bc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004bf:	39 08                	cmp    %ecx,(%eax)
  8004c1:	75 0c                	jne    8004cf <dev_lookup+0x23>
			*dev = devtab[i];
  8004c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	eb 30                	jmp    8004ff <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 e7                	jne    8004bc <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8004da:	8b 40 48             	mov    0x48(%eax),%eax
  8004dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e5:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  8004ec:	e8 5e 0d 00 00       	call   80124f <cprintf>
	*dev = 0;
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ff:	c9                   	leave  
  800500:	c3                   	ret    

00800501 <fd_close>:
{
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
  800506:	83 ec 20             	sub    $0x20,%esp
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80050f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800512:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800516:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80051c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 2f ff ff ff       	call   800456 <fd_lookup>
  800527:	85 c0                	test   %eax,%eax
  800529:	78 05                	js     800530 <fd_close+0x2f>
	    || fd != fd2)
  80052b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80052e:	74 0c                	je     80053c <fd_close+0x3b>
		return (must_exist ? r : 0);
  800530:	84 db                	test   %bl,%bl
  800532:	ba 00 00 00 00       	mov    $0x0,%edx
  800537:	0f 44 c2             	cmove  %edx,%eax
  80053a:	eb 3f                	jmp    80057b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80053c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80053f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800543:	8b 06                	mov    (%esi),%eax
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	e8 5f ff ff ff       	call   8004ac <dev_lookup>
  80054d:	89 c3                	mov    %eax,%ebx
  80054f:	85 c0                	test   %eax,%eax
  800551:	78 16                	js     800569 <fd_close+0x68>
		if (dev->dev_close)
  800553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800556:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800559:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80055e:	85 c0                	test   %eax,%eax
  800560:	74 07                	je     800569 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800562:	89 34 24             	mov    %esi,(%esp)
  800565:	ff d0                	call   *%eax
  800567:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  800569:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800574:	e8 a6 fc ff ff       	call   80021f <sys_page_unmap>
	return r;
  800579:	89 d8                	mov    %ebx,%eax
}
  80057b:	83 c4 20             	add    $0x20,%esp
  80057e:	5b                   	pop    %ebx
  80057f:	5e                   	pop    %esi
  800580:	5d                   	pop    %ebp
  800581:	c3                   	ret    

00800582 <close>:

int
close(int fdnum)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80058b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058f:	8b 45 08             	mov    0x8(%ebp),%eax
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	e8 bc fe ff ff       	call   800456 <fd_lookup>
  80059a:	89 c2                	mov    %eax,%edx
  80059c:	85 d2                	test   %edx,%edx
  80059e:	78 13                	js     8005b3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8005a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005a7:	00 
  8005a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005ab:	89 04 24             	mov    %eax,(%esp)
  8005ae:	e8 4e ff ff ff       	call   800501 <fd_close>
}
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <close_all>:

void
close_all(void)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	53                   	push   %ebx
  8005b9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c1:	89 1c 24             	mov    %ebx,(%esp)
  8005c4:	e8 b9 ff ff ff       	call   800582 <close>
	for (i = 0; i < MAXFD; i++)
  8005c9:	83 c3 01             	add    $0x1,%ebx
  8005cc:	83 fb 20             	cmp    $0x20,%ebx
  8005cf:	75 f0                	jne    8005c1 <close_all+0xc>
}
  8005d1:	83 c4 14             	add    $0x14,%esp
  8005d4:	5b                   	pop    %ebx
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	57                   	push   %edi
  8005db:	56                   	push   %esi
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	e8 64 fe ff ff       	call   800456 <fd_lookup>
  8005f2:	89 c2                	mov    %eax,%edx
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	0f 88 e1 00 00 00    	js     8006dd <dup+0x106>
		return r;
	close(newfdnum);
  8005fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	e8 7b ff ff ff       	call   800582 <close>

	newfd = INDEX2FD(newfdnum);
  800607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060a:	c1 e3 0c             	shl    $0xc,%ebx
  80060d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	e8 d2 fd ff ff       	call   8003f0 <fd2data>
  80061e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800620:	89 1c 24             	mov    %ebx,(%esp)
  800623:	e8 c8 fd ff ff       	call   8003f0 <fd2data>
  800628:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80062a:	89 f0                	mov    %esi,%eax
  80062c:	c1 e8 16             	shr    $0x16,%eax
  80062f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800636:	a8 01                	test   $0x1,%al
  800638:	74 43                	je     80067d <dup+0xa6>
  80063a:	89 f0                	mov    %esi,%eax
  80063c:	c1 e8 0c             	shr    $0xc,%eax
  80063f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800646:	f6 c2 01             	test   $0x1,%dl
  800649:	74 32                	je     80067d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80064b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800652:	25 07 0e 00 00       	and    $0xe07,%eax
  800657:	89 44 24 10          	mov    %eax,0x10(%esp)
  80065b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80065f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800666:	00 
  800667:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800672:	e8 55 fb ff ff       	call   8001cc <sys_page_map>
  800677:	89 c6                	mov    %eax,%esi
  800679:	85 c0                	test   %eax,%eax
  80067b:	78 3e                	js     8006bb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80067d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800680:	89 c2                	mov    %eax,%edx
  800682:	c1 ea 0c             	shr    $0xc,%edx
  800685:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80068c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800692:	89 54 24 10          	mov    %edx,0x10(%esp)
  800696:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80069a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006a1:	00 
  8006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ad:	e8 1a fb ff ff       	call   8001cc <sys_page_map>
  8006b2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8006b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b7:	85 f6                	test   %esi,%esi
  8006b9:	79 22                	jns    8006dd <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c6:	e8 54 fb ff ff       	call   80021f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d6:	e8 44 fb ff ff       	call   80021f <sys_page_unmap>
	return r;
  8006db:	89 f0                	mov    %esi,%eax
}
  8006dd:	83 c4 3c             	add    $0x3c,%esp
  8006e0:	5b                   	pop    %ebx
  8006e1:	5e                   	pop    %esi
  8006e2:	5f                   	pop    %edi
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 24             	sub    $0x24,%esp
  8006ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f6:	89 1c 24             	mov    %ebx,(%esp)
  8006f9:	e8 58 fd ff ff       	call   800456 <fd_lookup>
  8006fe:	89 c2                	mov    %eax,%edx
  800700:	85 d2                	test   %edx,%edx
  800702:	78 6d                	js     800771 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800704:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	e8 94 fd ff ff       	call   8004ac <dev_lookup>
  800718:	85 c0                	test   %eax,%eax
  80071a:	78 55                	js     800771 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80071c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071f:	8b 50 08             	mov    0x8(%eax),%edx
  800722:	83 e2 03             	and    $0x3,%edx
  800725:	83 fa 01             	cmp    $0x1,%edx
  800728:	75 23                	jne    80074d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80072a:	a1 08 40 80 00       	mov    0x804008,%eax
  80072f:	8b 40 48             	mov    0x48(%eax),%eax
  800732:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073a:	c7 04 24 3d 20 80 00 	movl   $0x80203d,(%esp)
  800741:	e8 09 0b 00 00       	call   80124f <cprintf>
		return -E_INVAL;
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074b:	eb 24                	jmp    800771 <read+0x8c>
	}
	if (!dev->dev_read)
  80074d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800750:	8b 52 08             	mov    0x8(%edx),%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	74 15                	je     80076c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800757:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80075a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80075e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800761:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	ff d2                	call   *%edx
  80076a:	eb 05                	jmp    800771 <read+0x8c>
		return -E_NOT_SUPP;
  80076c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800771:	83 c4 24             	add    $0x24,%esp
  800774:	5b                   	pop    %ebx
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	57                   	push   %edi
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	83 ec 1c             	sub    $0x1c,%esp
  800780:	8b 7d 08             	mov    0x8(%ebp),%edi
  800783:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800786:	bb 00 00 00 00       	mov    $0x0,%ebx
  80078b:	eb 23                	jmp    8007b0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80078d:	89 f0                	mov    %esi,%eax
  80078f:	29 d8                	sub    %ebx,%eax
  800791:	89 44 24 08          	mov    %eax,0x8(%esp)
  800795:	89 d8                	mov    %ebx,%eax
  800797:	03 45 0c             	add    0xc(%ebp),%eax
  80079a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079e:	89 3c 24             	mov    %edi,(%esp)
  8007a1:	e8 3f ff ff ff       	call   8006e5 <read>
		if (m < 0)
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 10                	js     8007ba <readn+0x43>
			return m;
		if (m == 0)
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	74 0a                	je     8007b8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8007ae:	01 c3                	add    %eax,%ebx
  8007b0:	39 f3                	cmp    %esi,%ebx
  8007b2:	72 d9                	jb     80078d <readn+0x16>
  8007b4:	89 d8                	mov    %ebx,%eax
  8007b6:	eb 02                	jmp    8007ba <readn+0x43>
  8007b8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007ba:	83 c4 1c             	add    $0x1c,%esp
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	5f                   	pop    %edi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 24             	sub    $0x24,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	89 1c 24             	mov    %ebx,(%esp)
  8007d6:	e8 7b fc ff ff       	call   800456 <fd_lookup>
  8007db:	89 c2                	mov    %eax,%edx
  8007dd:	85 d2                	test   %edx,%edx
  8007df:	78 68                	js     800849 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007eb:	8b 00                	mov    (%eax),%eax
  8007ed:	89 04 24             	mov    %eax,(%esp)
  8007f0:	e8 b7 fc ff ff       	call   8004ac <dev_lookup>
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	78 50                	js     800849 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800800:	75 23                	jne    800825 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800802:	a1 08 40 80 00       	mov    0x804008,%eax
  800807:	8b 40 48             	mov    0x48(%eax),%eax
  80080a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80080e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800812:	c7 04 24 59 20 80 00 	movl   $0x802059,(%esp)
  800819:	e8 31 0a 00 00       	call   80124f <cprintf>
		return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800823:	eb 24                	jmp    800849 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 0c             	mov    0xc(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 15                	je     800844 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80082f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800832:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800839:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	ff d2                	call   *%edx
  800842:	eb 05                	jmp    800849 <write+0x87>
		return -E_NOT_SUPP;
  800844:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800849:	83 c4 24             	add    $0x24,%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <seek>:

int
seek(int fdnum, off_t offset)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800855:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 ef fb ff ff       	call   800456 <fd_lookup>
  800867:	85 c0                	test   %eax,%eax
  800869:	78 0e                	js     800879 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80086b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 24             	sub    $0x24,%esp
  800882:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088c:	89 1c 24             	mov    %ebx,(%esp)
  80088f:	e8 c2 fb ff ff       	call   800456 <fd_lookup>
  800894:	89 c2                	mov    %eax,%edx
  800896:	85 d2                	test   %edx,%edx
  800898:	78 61                	js     8008fb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 fe fb ff ff       	call   8004ac <dev_lookup>
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 49                	js     8008fb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008b9:	75 23                	jne    8008de <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008bb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008c0:	8b 40 48             	mov    0x48(%eax),%eax
  8008c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cb:	c7 04 24 1c 20 80 00 	movl   $0x80201c,(%esp)
  8008d2:	e8 78 09 00 00       	call   80124f <cprintf>
		return -E_INVAL;
  8008d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008dc:	eb 1d                	jmp    8008fb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8008de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008e1:	8b 52 18             	mov    0x18(%edx),%edx
  8008e4:	85 d2                	test   %edx,%edx
  8008e6:	74 0e                	je     8008f6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	ff d2                	call   *%edx
  8008f4:	eb 05                	jmp    8008fb <ftruncate+0x80>
		return -E_NOT_SUPP;
  8008f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8008fb:	83 c4 24             	add    $0x24,%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	83 ec 24             	sub    $0x24,%esp
  800908:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80090b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	e8 39 fb ff ff       	call   800456 <fd_lookup>
  80091d:	89 c2                	mov    %eax,%edx
  80091f:	85 d2                	test   %edx,%edx
  800921:	78 52                	js     800975 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80092d:	8b 00                	mov    (%eax),%eax
  80092f:	89 04 24             	mov    %eax,(%esp)
  800932:	e8 75 fb ff ff       	call   8004ac <dev_lookup>
  800937:	85 c0                	test   %eax,%eax
  800939:	78 3a                	js     800975 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80093b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800942:	74 2c                	je     800970 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800944:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800947:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80094e:	00 00 00 
	stat->st_isdir = 0;
  800951:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800958:	00 00 00 
	stat->st_dev = dev;
  80095b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800965:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800968:	89 14 24             	mov    %edx,(%esp)
  80096b:	ff 50 14             	call   *0x14(%eax)
  80096e:	eb 05                	jmp    800975 <fstat+0x74>
		return -E_NOT_SUPP;
  800970:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800975:	83 c4 24             	add    $0x24,%esp
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800983:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80098a:	00 
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	89 04 24             	mov    %eax,(%esp)
  800991:	e8 fb 01 00 00       	call   800b91 <open>
  800996:	89 c3                	mov    %eax,%ebx
  800998:	85 db                	test   %ebx,%ebx
  80099a:	78 1b                	js     8009b7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a3:	89 1c 24             	mov    %ebx,(%esp)
  8009a6:	e8 56 ff ff ff       	call   800901 <fstat>
  8009ab:	89 c6                	mov    %eax,%esi
	close(fd);
  8009ad:	89 1c 24             	mov    %ebx,(%esp)
  8009b0:	e8 cd fb ff ff       	call   800582 <close>
	return r;
  8009b5:	89 f0                	mov    %esi,%eax
}
  8009b7:	83 c4 10             	add    $0x10,%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	83 ec 10             	sub    $0x10,%esp
  8009c6:	89 c6                	mov    %eax,%esi
  8009c8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009ca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009d1:	75 11                	jne    8009e4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009da:	e8 c0 12 00 00       	call   801c9f <ipc_find_env>
  8009df:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009e4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8009eb:	00 
  8009ec:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8009f3:	00 
  8009f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f8:	a1 00 40 80 00       	mov    0x804000,%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 33 12 00 00       	call   801c38 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a0c:	00 
  800a0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a18:	e8 b3 11 00 00       	call   801bd0 <ipc_recv>
}
  800a1d:	83 c4 10             	add    $0x10,%esp
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a30:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	b8 02 00 00 00       	mov    $0x2,%eax
  800a47:	e8 72 ff ff ff       	call   8009be <fsipc>
}
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <devfile_flush>:
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a64:	b8 06 00 00 00       	mov    $0x6,%eax
  800a69:	e8 50 ff ff ff       	call   8009be <fsipc>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <devfile_stat>:
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	83 ec 14             	sub    $0x14,%esp
  800a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a80:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a8f:	e8 2a ff ff ff       	call   8009be <fsipc>
  800a94:	89 c2                	mov    %eax,%edx
  800a96:	85 d2                	test   %edx,%edx
  800a98:	78 2b                	js     800ac5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a9a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800aa1:	00 
  800aa2:	89 1c 24             	mov    %ebx,(%esp)
  800aa5:	e8 cd 0d 00 00       	call   801877 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aaa:	a1 80 50 80 00       	mov    0x805080,%eax
  800aaf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ab5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac5:	83 c4 14             	add    $0x14,%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <devfile_write>:
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  800ad1:	c7 44 24 08 88 20 80 	movl   $0x802088,0x8(%esp)
  800ad8:	00 
  800ad9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800ae0:	00 
  800ae1:	c7 04 24 a6 20 80 00 	movl   $0x8020a6,(%esp)
  800ae8:	e8 69 06 00 00       	call   801156 <_panic>

00800aed <devfile_read>:
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	83 ec 10             	sub    $0x10,%esp
  800af5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 40 0c             	mov    0xc(%eax),%eax
  800afe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b03:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b13:	e8 a6 fe ff ff       	call   8009be <fsipc>
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	78 6a                	js     800b88 <devfile_read+0x9b>
	assert(r <= n);
  800b1e:	39 c6                	cmp    %eax,%esi
  800b20:	73 24                	jae    800b46 <devfile_read+0x59>
  800b22:	c7 44 24 0c b1 20 80 	movl   $0x8020b1,0xc(%esp)
  800b29:	00 
  800b2a:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800b31:	00 
  800b32:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b39:	00 
  800b3a:	c7 04 24 a6 20 80 00 	movl   $0x8020a6,(%esp)
  800b41:	e8 10 06 00 00       	call   801156 <_panic>
	assert(r <= PGSIZE);
  800b46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b4b:	7e 24                	jle    800b71 <devfile_read+0x84>
  800b4d:	c7 44 24 0c cd 20 80 	movl   $0x8020cd,0xc(%esp)
  800b54:	00 
  800b55:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800b5c:	00 
  800b5d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b64:	00 
  800b65:	c7 04 24 a6 20 80 00 	movl   $0x8020a6,(%esp)
  800b6c:	e8 e5 05 00 00       	call   801156 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b75:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b7c:	00 
  800b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b80:	89 04 24             	mov    %eax,(%esp)
  800b83:	e8 8c 0e 00 00       	call   801a14 <memmove>
}
  800b88:	89 d8                	mov    %ebx,%eax
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <open>:
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	53                   	push   %ebx
  800b95:	83 ec 24             	sub    $0x24,%esp
  800b98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800b9b:	89 1c 24             	mov    %ebx,(%esp)
  800b9e:	e8 9d 0c 00 00       	call   801840 <strlen>
  800ba3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ba8:	7f 60                	jg     800c0a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  800baa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bad:	89 04 24             	mov    %eax,(%esp)
  800bb0:	e8 52 f8 ff ff       	call   800407 <fd_alloc>
  800bb5:	89 c2                	mov    %eax,%edx
  800bb7:	85 d2                	test   %edx,%edx
  800bb9:	78 54                	js     800c0f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  800bbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bbf:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bc6:	e8 ac 0c 00 00       	call   801877 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdb:	e8 de fd ff ff       	call   8009be <fsipc>
  800be0:	89 c3                	mov    %eax,%ebx
  800be2:	85 c0                	test   %eax,%eax
  800be4:	79 17                	jns    800bfd <open+0x6c>
		fd_close(fd, 0);
  800be6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800bed:	00 
  800bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf1:	89 04 24             	mov    %eax,(%esp)
  800bf4:	e8 08 f9 ff ff       	call   800501 <fd_close>
		return r;
  800bf9:	89 d8                	mov    %ebx,%eax
  800bfb:	eb 12                	jmp    800c0f <open+0x7e>
	return fd2num(fd);
  800bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c00:	89 04 24             	mov    %eax,(%esp)
  800c03:	e8 d8 f7 ff ff       	call   8003e0 <fd2num>
  800c08:	eb 05                	jmp    800c0f <open+0x7e>
		return -E_BAD_PATH;
  800c0a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  800c0f:	83 c4 24             	add    $0x24,%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c20:	b8 08 00 00 00       	mov    $0x8,%eax
  800c25:	e8 94 fd ff ff       	call   8009be <fsipc>
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 10             	sub    $0x10,%esp
  800c34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c37:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3a:	89 04 24             	mov    %eax,(%esp)
  800c3d:	e8 ae f7 ff ff       	call   8003f0 <fd2data>
  800c42:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c44:	c7 44 24 04 d9 20 80 	movl   $0x8020d9,0x4(%esp)
  800c4b:	00 
  800c4c:	89 1c 24             	mov    %ebx,(%esp)
  800c4f:	e8 23 0c 00 00       	call   801877 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c54:	8b 46 04             	mov    0x4(%esi),%eax
  800c57:	2b 06                	sub    (%esi),%eax
  800c59:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c5f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c66:	00 00 00 
	stat->st_dev = &devpipe;
  800c69:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c70:	30 80 00 
	return 0;
}
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	53                   	push   %ebx
  800c83:	83 ec 14             	sub    $0x14,%esp
  800c86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c94:	e8 86 f5 ff ff       	call   80021f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c99:	89 1c 24             	mov    %ebx,(%esp)
  800c9c:	e8 4f f7 ff ff       	call   8003f0 <fd2data>
  800ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cac:	e8 6e f5 ff ff       	call   80021f <sys_page_unmap>
}
  800cb1:	83 c4 14             	add    $0x14,%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <_pipeisclosed>:
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 2c             	sub    $0x2c,%esp
  800cc0:	89 c6                	mov    %eax,%esi
  800cc2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  800cc5:	a1 08 40 80 00       	mov    0x804008,%eax
  800cca:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800ccd:	89 34 24             	mov    %esi,(%esp)
  800cd0:	e8 02 10 00 00       	call   801cd7 <pageref>
  800cd5:	89 c7                	mov    %eax,%edi
  800cd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cda:	89 04 24             	mov    %eax,(%esp)
  800cdd:	e8 f5 0f 00 00       	call   801cd7 <pageref>
  800ce2:	39 c7                	cmp    %eax,%edi
  800ce4:	0f 94 c2             	sete   %dl
  800ce7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800cea:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  800cf0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800cf3:	39 fb                	cmp    %edi,%ebx
  800cf5:	74 21                	je     800d18 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  800cf7:	84 d2                	test   %dl,%dl
  800cf9:	74 ca                	je     800cc5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cfb:	8b 51 58             	mov    0x58(%ecx),%edx
  800cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d02:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d0a:	c7 04 24 e0 20 80 00 	movl   $0x8020e0,(%esp)
  800d11:	e8 39 05 00 00       	call   80124f <cprintf>
  800d16:	eb ad                	jmp    800cc5 <_pipeisclosed+0xe>
}
  800d18:	83 c4 2c             	add    $0x2c,%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <devpipe_write>:
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 1c             	sub    $0x1c,%esp
  800d29:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d2c:	89 34 24             	mov    %esi,(%esp)
  800d2f:	e8 bc f6 ff ff       	call   8003f0 <fd2data>
  800d34:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d36:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3b:	eb 45                	jmp    800d82 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  800d3d:	89 da                	mov    %ebx,%edx
  800d3f:	89 f0                	mov    %esi,%eax
  800d41:	e8 71 ff ff ff       	call   800cb7 <_pipeisclosed>
  800d46:	85 c0                	test   %eax,%eax
  800d48:	75 41                	jne    800d8b <devpipe_write+0x6b>
			sys_yield();
  800d4a:	e8 0a f4 ff ff       	call   800159 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d4f:	8b 43 04             	mov    0x4(%ebx),%eax
  800d52:	8b 0b                	mov    (%ebx),%ecx
  800d54:	8d 51 20             	lea    0x20(%ecx),%edx
  800d57:	39 d0                	cmp    %edx,%eax
  800d59:	73 e2                	jae    800d3d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d62:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d65:	99                   	cltd   
  800d66:	c1 ea 1b             	shr    $0x1b,%edx
  800d69:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d6c:	83 e1 1f             	and    $0x1f,%ecx
  800d6f:	29 d1                	sub    %edx,%ecx
  800d71:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d75:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800d79:	83 c0 01             	add    $0x1,%eax
  800d7c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d7f:	83 c7 01             	add    $0x1,%edi
  800d82:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d85:	75 c8                	jne    800d4f <devpipe_write+0x2f>
	return i;
  800d87:	89 f8                	mov    %edi,%eax
  800d89:	eb 05                	jmp    800d90 <devpipe_write+0x70>
				return 0;
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d90:	83 c4 1c             	add    $0x1c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <devpipe_read>:
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 1c             	sub    $0x1c,%esp
  800da1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800da4:	89 3c 24             	mov    %edi,(%esp)
  800da7:	e8 44 f6 ff ff       	call   8003f0 <fd2data>
  800dac:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800dae:	be 00 00 00 00       	mov    $0x0,%esi
  800db3:	eb 3d                	jmp    800df2 <devpipe_read+0x5a>
			if (i > 0)
  800db5:	85 f6                	test   %esi,%esi
  800db7:	74 04                	je     800dbd <devpipe_read+0x25>
				return i;
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	eb 43                	jmp    800e00 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  800dbd:	89 da                	mov    %ebx,%edx
  800dbf:	89 f8                	mov    %edi,%eax
  800dc1:	e8 f1 fe ff ff       	call   800cb7 <_pipeisclosed>
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	75 31                	jne    800dfb <devpipe_read+0x63>
			sys_yield();
  800dca:	e8 8a f3 ff ff       	call   800159 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800dcf:	8b 03                	mov    (%ebx),%eax
  800dd1:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dd4:	74 df                	je     800db5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dd6:	99                   	cltd   
  800dd7:	c1 ea 1b             	shr    $0x1b,%edx
  800dda:	01 d0                	add    %edx,%eax
  800ddc:	83 e0 1f             	and    $0x1f,%eax
  800ddf:	29 d0                	sub    %edx,%eax
  800de1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800dec:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800def:	83 c6 01             	add    $0x1,%esi
  800df2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800df5:	75 d8                	jne    800dcf <devpipe_read+0x37>
	return i;
  800df7:	89 f0                	mov    %esi,%eax
  800df9:	eb 05                	jmp    800e00 <devpipe_read+0x68>
				return 0;
  800dfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <pipe>:
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e13:	89 04 24             	mov    %eax,(%esp)
  800e16:	e8 ec f5 ff ff       	call   800407 <fd_alloc>
  800e1b:	89 c2                	mov    %eax,%edx
  800e1d:	85 d2                	test   %edx,%edx
  800e1f:	0f 88 4d 01 00 00    	js     800f72 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e25:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e2c:	00 
  800e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e3b:	e8 38 f3 ff ff       	call   800178 <sys_page_alloc>
  800e40:	89 c2                	mov    %eax,%edx
  800e42:	85 d2                	test   %edx,%edx
  800e44:	0f 88 28 01 00 00    	js     800f72 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  800e4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e4d:	89 04 24             	mov    %eax,(%esp)
  800e50:	e8 b2 f5 ff ff       	call   800407 <fd_alloc>
  800e55:	89 c3                	mov    %eax,%ebx
  800e57:	85 c0                	test   %eax,%eax
  800e59:	0f 88 fe 00 00 00    	js     800f5d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e5f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e66:	00 
  800e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e75:	e8 fe f2 ff ff       	call   800178 <sys_page_alloc>
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	0f 88 d9 00 00 00    	js     800f5d <pipe+0x155>
	va = fd2data(fd0);
  800e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e87:	89 04 24             	mov    %eax,(%esp)
  800e8a:	e8 61 f5 ff ff       	call   8003f0 <fd2data>
  800e8f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e91:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e98:	00 
  800e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea4:	e8 cf f2 ff ff       	call   800178 <sys_page_alloc>
  800ea9:	89 c3                	mov    %eax,%ebx
  800eab:	85 c0                	test   %eax,%eax
  800ead:	0f 88 97 00 00 00    	js     800f4a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb6:	89 04 24             	mov    %eax,(%esp)
  800eb9:	e8 32 f5 ff ff       	call   8003f0 <fd2data>
  800ebe:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ec5:	00 
  800ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed1:	00 
  800ed2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ed6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800edd:	e8 ea f2 ff ff       	call   8001cc <sys_page_map>
  800ee2:	89 c3                	mov    %eax,%ebx
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	78 52                	js     800f3a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  800ee8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800efd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f06:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f15:	89 04 24             	mov    %eax,(%esp)
  800f18:	e8 c3 f4 ff ff       	call   8003e0 <fd2num>
  800f1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f25:	89 04 24             	mov    %eax,(%esp)
  800f28:	e8 b3 f4 ff ff       	call   8003e0 <fd2num>
  800f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
  800f38:	eb 38                	jmp    800f72 <pipe+0x16a>
	sys_page_unmap(0, va);
  800f3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f45:	e8 d5 f2 ff ff       	call   80021f <sys_page_unmap>
	sys_page_unmap(0, fd1);
  800f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f58:	e8 c2 f2 ff ff       	call   80021f <sys_page_unmap>
	sys_page_unmap(0, fd0);
  800f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6b:	e8 af f2 ff ff       	call   80021f <sys_page_unmap>
  800f70:	89 d8                	mov    %ebx,%eax
}
  800f72:	83 c4 30             	add    $0x30,%esp
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <pipeisclosed>:
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f86:	8b 45 08             	mov    0x8(%ebp),%eax
  800f89:	89 04 24             	mov    %eax,(%esp)
  800f8c:	e8 c5 f4 ff ff       	call   800456 <fd_lookup>
  800f91:	89 c2                	mov    %eax,%edx
  800f93:	85 d2                	test   %edx,%edx
  800f95:	78 15                	js     800fac <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  800f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9a:	89 04 24             	mov    %eax,(%esp)
  800f9d:	e8 4e f4 ff ff       	call   8003f0 <fd2data>
	return _pipeisclosed(fd, p);
  800fa2:	89 c2                	mov    %eax,%edx
  800fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa7:	e8 0b fd ff ff       	call   800cb7 <_pipeisclosed>
}
  800fac:	c9                   	leave  
  800fad:	c3                   	ret    
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fc0:	c7 44 24 04 f8 20 80 	movl   $0x8020f8,0x4(%esp)
  800fc7:	00 
  800fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcb:	89 04 24             	mov    %eax,(%esp)
  800fce:	e8 a4 08 00 00       	call   801877 <strcpy>
	return 0;
}
  800fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd8:	c9                   	leave  
  800fd9:	c3                   	ret    

00800fda <devcons_write>:
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  800fe6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800feb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ff1:	eb 31                	jmp    801024 <devcons_write+0x4a>
		m = n - tot;
  800ff3:	8b 75 10             	mov    0x10(%ebp),%esi
  800ff6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800ff8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  800ffb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801000:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801003:	89 74 24 08          	mov    %esi,0x8(%esp)
  801007:	03 45 0c             	add    0xc(%ebp),%eax
  80100a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100e:	89 3c 24             	mov    %edi,(%esp)
  801011:	e8 fe 09 00 00       	call   801a14 <memmove>
		sys_cputs(buf, m);
  801016:	89 74 24 04          	mov    %esi,0x4(%esp)
  80101a:	89 3c 24             	mov    %edi,(%esp)
  80101d:	e8 89 f0 ff ff       	call   8000ab <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801022:	01 f3                	add    %esi,%ebx
  801024:	89 d8                	mov    %ebx,%eax
  801026:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801029:	72 c8                	jb     800ff3 <devcons_write+0x19>
}
  80102b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <devcons_read>:
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801041:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801045:	75 07                	jne    80104e <devcons_read+0x18>
  801047:	eb 2a                	jmp    801073 <devcons_read+0x3d>
		sys_yield();
  801049:	e8 0b f1 ff ff       	call   800159 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80104e:	66 90                	xchg   %ax,%ax
  801050:	e8 74 f0 ff ff       	call   8000c9 <sys_cgetc>
  801055:	85 c0                	test   %eax,%eax
  801057:	74 f0                	je     801049 <devcons_read+0x13>
	if (c < 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 16                	js     801073 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80105d:	83 f8 04             	cmp    $0x4,%eax
  801060:	74 0c                	je     80106e <devcons_read+0x38>
	*(char*)vbuf = c;
  801062:	8b 55 0c             	mov    0xc(%ebp),%edx
  801065:	88 02                	mov    %al,(%edx)
	return 1;
  801067:	b8 01 00 00 00       	mov    $0x1,%eax
  80106c:	eb 05                	jmp    801073 <devcons_read+0x3d>
		return 0;
  80106e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <cputchar>:
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801081:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801088:	00 
  801089:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80108c:	89 04 24             	mov    %eax,(%esp)
  80108f:	e8 17 f0 ff ff       	call   8000ab <sys_cputs>
}
  801094:	c9                   	leave  
  801095:	c3                   	ret    

00801096 <getchar>:
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80109c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010a3:	00 
  8010a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b2:	e8 2e f6 ff ff       	call   8006e5 <read>
	if (r < 0)
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 0f                	js     8010ca <getchar+0x34>
	if (r < 1)
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	7e 06                	jle    8010c5 <getchar+0x2f>
	return c;
  8010bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010c3:	eb 05                	jmp    8010ca <getchar+0x34>
		return -E_EOF;
  8010c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <iscons>:
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dc:	89 04 24             	mov    %eax,(%esp)
  8010df:	e8 72 f3 ff ff       	call   800456 <fd_lookup>
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	78 11                	js     8010f9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8010e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010eb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010f1:	39 10                	cmp    %edx,(%eax)
  8010f3:	0f 94 c0             	sete   %al
  8010f6:	0f b6 c0             	movzbl %al,%eax
}
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <opencons>:
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801104:	89 04 24             	mov    %eax,(%esp)
  801107:	e8 fb f2 ff ff       	call   800407 <fd_alloc>
		return r;
  80110c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80110e:	85 c0                	test   %eax,%eax
  801110:	78 40                	js     801152 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801112:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801119:	00 
  80111a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801121:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801128:	e8 4b f0 ff ff       	call   800178 <sys_page_alloc>
		return r;
  80112d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 1f                	js     801152 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801133:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80113e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801141:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801148:	89 04 24             	mov    %eax,(%esp)
  80114b:	e8 90 f2 ff ff       	call   8003e0 <fd2num>
  801150:	89 c2                	mov    %eax,%edx
}
  801152:	89 d0                	mov    %edx,%eax
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80115e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801161:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801167:	e8 ce ef ff ff       	call   80013a <sys_getenvid>
  80116c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801173:	8b 55 08             	mov    0x8(%ebp),%edx
  801176:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80117a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80117e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801182:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  801189:	e8 c1 00 00 00       	call   80124f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80118e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801192:	8b 45 10             	mov    0x10(%ebp),%eax
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	e8 51 00 00 00       	call   8011ee <vcprintf>
	cprintf("\n");
  80119d:	c7 04 24 f1 20 80 00 	movl   $0x8020f1,(%esp)
  8011a4:	e8 a6 00 00 00       	call   80124f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011a9:	cc                   	int3   
  8011aa:	eb fd                	jmp    8011a9 <_panic+0x53>

008011ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	53                   	push   %ebx
  8011b0:	83 ec 14             	sub    $0x14,%esp
  8011b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011b6:	8b 13                	mov    (%ebx),%edx
  8011b8:	8d 42 01             	lea    0x1(%edx),%eax
  8011bb:	89 03                	mov    %eax,(%ebx)
  8011bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8011c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011c9:	75 19                	jne    8011e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8011cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011d2:	00 
  8011d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011d6:	89 04 24             	mov    %eax,(%esp)
  8011d9:	e8 cd ee ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  8011de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8011e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8011e8:	83 c4 14             	add    $0x14,%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8011f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8011fe:	00 00 00 
	b.cnt = 0;
  801201:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801208:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80120b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801212:	8b 45 08             	mov    0x8(%ebp),%eax
  801215:	89 44 24 08          	mov    %eax,0x8(%esp)
  801219:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80121f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801223:	c7 04 24 ac 11 80 00 	movl   $0x8011ac,(%esp)
  80122a:	e8 af 01 00 00       	call   8013de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80122f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801235:	89 44 24 04          	mov    %eax,0x4(%esp)
  801239:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80123f:	89 04 24             	mov    %eax,(%esp)
  801242:	e8 64 ee ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  801247:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801255:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125c:	8b 45 08             	mov    0x8(%ebp),%eax
  80125f:	89 04 24             	mov    %eax,(%esp)
  801262:	e8 87 ff ff ff       	call   8011ee <vcprintf>
	va_end(ap);

	return cnt;
}
  801267:	c9                   	leave  
  801268:	c3                   	ret    
  801269:	66 90                	xchg   %ax,%ax
  80126b:	66 90                	xchg   %ax,%ax
  80126d:	66 90                	xchg   %ax,%ax
  80126f:	90                   	nop

00801270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	57                   	push   %edi
  801274:	56                   	push   %esi
  801275:	53                   	push   %ebx
  801276:	83 ec 3c             	sub    $0x3c,%esp
  801279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127c:	89 d7                	mov    %edx,%edi
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
  801287:	89 c3                	mov    %eax,%ebx
  801289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80128c:	8b 45 10             	mov    0x10(%ebp),%eax
  80128f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801292:	b9 00 00 00 00       	mov    $0x0,%ecx
  801297:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80129a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80129d:	39 d9                	cmp    %ebx,%ecx
  80129f:	72 05                	jb     8012a6 <printnum+0x36>
  8012a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012a4:	77 69                	ja     80130f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012ad:	83 ee 01             	sub    $0x1,%esi
  8012b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012c0:	89 c3                	mov    %eax,%ebx
  8012c2:	89 d6                	mov    %edx,%esi
  8012c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d5:	89 04 24             	mov    %eax,(%esp)
  8012d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012df:	e8 3c 0a 00 00       	call   801d20 <__udivdi3>
  8012e4:	89 d9                	mov    %ebx,%ecx
  8012e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012ee:	89 04 24             	mov    %eax,(%esp)
  8012f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012f5:	89 fa                	mov    %edi,%edx
  8012f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012fa:	e8 71 ff ff ff       	call   801270 <printnum>
  8012ff:	eb 1b                	jmp    80131c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801305:	8b 45 18             	mov    0x18(%ebp),%eax
  801308:	89 04 24             	mov    %eax,(%esp)
  80130b:	ff d3                	call   *%ebx
  80130d:	eb 03                	jmp    801312 <printnum+0xa2>
  80130f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  801312:	83 ee 01             	sub    $0x1,%esi
  801315:	85 f6                	test   %esi,%esi
  801317:	7f e8                	jg     801301 <printnum+0x91>
  801319:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80131c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801320:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801324:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801327:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80132a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80132e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801335:	89 04 24             	mov    %eax,(%esp)
  801338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80133b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133f:	e8 0c 0b 00 00       	call   801e50 <__umoddi3>
  801344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801348:	0f be 80 27 21 80 00 	movsbl 0x802127(%eax),%eax
  80134f:	89 04 24             	mov    %eax,(%esp)
  801352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801355:	ff d0                	call   *%eax
}
  801357:	83 c4 3c             	add    $0x3c,%esp
  80135a:	5b                   	pop    %ebx
  80135b:	5e                   	pop    %esi
  80135c:	5f                   	pop    %edi
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801362:	83 fa 01             	cmp    $0x1,%edx
  801365:	7e 0e                	jle    801375 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801367:	8b 10                	mov    (%eax),%edx
  801369:	8d 4a 08             	lea    0x8(%edx),%ecx
  80136c:	89 08                	mov    %ecx,(%eax)
  80136e:	8b 02                	mov    (%edx),%eax
  801370:	8b 52 04             	mov    0x4(%edx),%edx
  801373:	eb 22                	jmp    801397 <getuint+0x38>
	else if (lflag)
  801375:	85 d2                	test   %edx,%edx
  801377:	74 10                	je     801389 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801379:	8b 10                	mov    (%eax),%edx
  80137b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80137e:	89 08                	mov    %ecx,(%eax)
  801380:	8b 02                	mov    (%edx),%eax
  801382:	ba 00 00 00 00       	mov    $0x0,%edx
  801387:	eb 0e                	jmp    801397 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801389:	8b 10                	mov    (%eax),%edx
  80138b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80138e:	89 08                	mov    %ecx,(%eax)
  801390:	8b 02                	mov    (%edx),%eax
  801392:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80139f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8013a3:	8b 10                	mov    (%eax),%edx
  8013a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8013a8:	73 0a                	jae    8013b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8013aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013ad:	89 08                	mov    %ecx,(%eax)
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	88 02                	mov    %al,(%edx)
}
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <printfmt>:
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8013bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d4:	89 04 24             	mov    %eax,(%esp)
  8013d7:	e8 02 00 00 00       	call   8013de <vprintfmt>
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <vprintfmt>:
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 3c             	sub    $0x3c,%esp
  8013e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ed:	eb 1f                	jmp    80140e <vprintfmt+0x30>
			if (ch == '\0'){
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	75 0f                	jne    801402 <vprintfmt+0x24>
				color = 0x0100;
  8013f3:	c7 05 04 40 80 00 00 	movl   $0x100,0x804004
  8013fa:	01 00 00 
  8013fd:	e9 b3 03 00 00       	jmp    8017b5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  801402:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801406:	89 04 24             	mov    %eax,(%esp)
  801409:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80140c:	89 f3                	mov    %esi,%ebx
  80140e:	8d 73 01             	lea    0x1(%ebx),%esi
  801411:	0f b6 03             	movzbl (%ebx),%eax
  801414:	83 f8 25             	cmp    $0x25,%eax
  801417:	75 d6                	jne    8013ef <vprintfmt+0x11>
  801419:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80141d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801424:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80142b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801432:	ba 00 00 00 00       	mov    $0x0,%edx
  801437:	eb 1d                	jmp    801456 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801439:	89 de                	mov    %ebx,%esi
			padc = '-';
  80143b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80143f:	eb 15                	jmp    801456 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801441:	89 de                	mov    %ebx,%esi
			padc = '0';
  801443:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801447:	eb 0d                	jmp    801456 <vprintfmt+0x78>
				width = precision, precision = -1;
  801449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80144c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80144f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801456:	8d 5e 01             	lea    0x1(%esi),%ebx
  801459:	0f b6 0e             	movzbl (%esi),%ecx
  80145c:	0f b6 c1             	movzbl %cl,%eax
  80145f:	83 e9 23             	sub    $0x23,%ecx
  801462:	80 f9 55             	cmp    $0x55,%cl
  801465:	0f 87 2a 03 00 00    	ja     801795 <vprintfmt+0x3b7>
  80146b:	0f b6 c9             	movzbl %cl,%ecx
  80146e:	ff 24 8d 60 22 80 00 	jmp    *0x802260(,%ecx,4)
  801475:	89 de                	mov    %ebx,%esi
  801477:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80147c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80147f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801483:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801486:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801489:	83 fb 09             	cmp    $0x9,%ebx
  80148c:	77 36                	ja     8014c4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80148e:	83 c6 01             	add    $0x1,%esi
			}
  801491:	eb e9                	jmp    80147c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  801493:	8b 45 14             	mov    0x14(%ebp),%eax
  801496:	8d 48 04             	lea    0x4(%eax),%ecx
  801499:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80149c:	8b 00                	mov    (%eax),%eax
  80149e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014a1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8014a3:	eb 22                	jmp    8014c7 <vprintfmt+0xe9>
  8014a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014a8:	85 c9                	test   %ecx,%ecx
  8014aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014af:	0f 49 c1             	cmovns %ecx,%eax
  8014b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014b5:	89 de                	mov    %ebx,%esi
  8014b7:	eb 9d                	jmp    801456 <vprintfmt+0x78>
  8014b9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8014bb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8014c2:	eb 92                	jmp    801456 <vprintfmt+0x78>
  8014c4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8014c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014cb:	79 89                	jns    801456 <vprintfmt+0x78>
  8014cd:	e9 77 ff ff ff       	jmp    801449 <vprintfmt+0x6b>
			lflag++;
  8014d2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8014d5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8014d7:	e9 7a ff ff ff       	jmp    801456 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8014dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014df:	8d 50 04             	lea    0x4(%eax),%edx
  8014e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014e9:	8b 00                	mov    (%eax),%eax
  8014eb:	89 04 24             	mov    %eax,(%esp)
  8014ee:	ff 55 08             	call   *0x8(%ebp)
			break;
  8014f1:	e9 18 ff ff ff       	jmp    80140e <vprintfmt+0x30>
			err = va_arg(ap, int);
  8014f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f9:	8d 50 04             	lea    0x4(%eax),%edx
  8014fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ff:	8b 00                	mov    (%eax),%eax
  801501:	99                   	cltd   
  801502:	31 d0                	xor    %edx,%eax
  801504:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801506:	83 f8 0f             	cmp    $0xf,%eax
  801509:	7f 0b                	jg     801516 <vprintfmt+0x138>
  80150b:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  801512:	85 d2                	test   %edx,%edx
  801514:	75 20                	jne    801536 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  801516:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80151a:	c7 44 24 08 3f 21 80 	movl   $0x80213f,0x8(%esp)
  801521:	00 
  801522:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801526:	8b 45 08             	mov    0x8(%ebp),%eax
  801529:	89 04 24             	mov    %eax,(%esp)
  80152c:	e8 85 fe ff ff       	call   8013b6 <printfmt>
  801531:	e9 d8 fe ff ff       	jmp    80140e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  801536:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80153a:	c7 44 24 08 ca 20 80 	movl   $0x8020ca,0x8(%esp)
  801541:	00 
  801542:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801546:	8b 45 08             	mov    0x8(%ebp),%eax
  801549:	89 04 24             	mov    %eax,(%esp)
  80154c:	e8 65 fe ff ff       	call   8013b6 <printfmt>
  801551:	e9 b8 fe ff ff       	jmp    80140e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  801556:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801559:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80155c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80155f:	8b 45 14             	mov    0x14(%ebp),%eax
  801562:	8d 50 04             	lea    0x4(%eax),%edx
  801565:	89 55 14             	mov    %edx,0x14(%ebp)
  801568:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80156a:	85 f6                	test   %esi,%esi
  80156c:	b8 38 21 80 00       	mov    $0x802138,%eax
  801571:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801574:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801578:	0f 84 97 00 00 00    	je     801615 <vprintfmt+0x237>
  80157e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801582:	0f 8e 9b 00 00 00    	jle    801623 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  801588:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80158c:	89 34 24             	mov    %esi,(%esp)
  80158f:	e8 c4 02 00 00       	call   801858 <strnlen>
  801594:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801597:	29 c2                	sub    %eax,%edx
  801599:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80159c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8015a3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8015a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015ac:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8015ae:	eb 0f                	jmp    8015bf <vprintfmt+0x1e1>
					putch(padc, putdat);
  8015b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015b7:	89 04 24             	mov    %eax,(%esp)
  8015ba:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8015bc:	83 eb 01             	sub    $0x1,%ebx
  8015bf:	85 db                	test   %ebx,%ebx
  8015c1:	7f ed                	jg     8015b0 <vprintfmt+0x1d2>
  8015c3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015c6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015c9:	85 d2                	test   %edx,%edx
  8015cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d0:	0f 49 c2             	cmovns %edx,%eax
  8015d3:	29 c2                	sub    %eax,%edx
  8015d5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015d8:	89 d7                	mov    %edx,%edi
  8015da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015dd:	eb 50                	jmp    80162f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8015df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015e3:	74 1e                	je     801603 <vprintfmt+0x225>
  8015e5:	0f be d2             	movsbl %dl,%edx
  8015e8:	83 ea 20             	sub    $0x20,%edx
  8015eb:	83 fa 5e             	cmp    $0x5e,%edx
  8015ee:	76 13                	jbe    801603 <vprintfmt+0x225>
					putch('?', putdat);
  8015f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015fe:	ff 55 08             	call   *0x8(%ebp)
  801601:	eb 0d                	jmp    801610 <vprintfmt+0x232>
					putch(ch, putdat);
  801603:	8b 55 0c             	mov    0xc(%ebp),%edx
  801606:	89 54 24 04          	mov    %edx,0x4(%esp)
  80160a:	89 04 24             	mov    %eax,(%esp)
  80160d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801610:	83 ef 01             	sub    $0x1,%edi
  801613:	eb 1a                	jmp    80162f <vprintfmt+0x251>
  801615:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801618:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80161b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80161e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801621:	eb 0c                	jmp    80162f <vprintfmt+0x251>
  801623:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801626:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801629:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80162c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80162f:	83 c6 01             	add    $0x1,%esi
  801632:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801636:	0f be c2             	movsbl %dl,%eax
  801639:	85 c0                	test   %eax,%eax
  80163b:	74 27                	je     801664 <vprintfmt+0x286>
  80163d:	85 db                	test   %ebx,%ebx
  80163f:	78 9e                	js     8015df <vprintfmt+0x201>
  801641:	83 eb 01             	sub    $0x1,%ebx
  801644:	79 99                	jns    8015df <vprintfmt+0x201>
  801646:	89 f8                	mov    %edi,%eax
  801648:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80164b:	8b 75 08             	mov    0x8(%ebp),%esi
  80164e:	89 c3                	mov    %eax,%ebx
  801650:	eb 1a                	jmp    80166c <vprintfmt+0x28e>
				putch(' ', putdat);
  801652:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801656:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80165d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80165f:	83 eb 01             	sub    $0x1,%ebx
  801662:	eb 08                	jmp    80166c <vprintfmt+0x28e>
  801664:	89 fb                	mov    %edi,%ebx
  801666:	8b 75 08             	mov    0x8(%ebp),%esi
  801669:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80166c:	85 db                	test   %ebx,%ebx
  80166e:	7f e2                	jg     801652 <vprintfmt+0x274>
  801670:	89 75 08             	mov    %esi,0x8(%ebp)
  801673:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801676:	e9 93 fd ff ff       	jmp    80140e <vprintfmt+0x30>
	if (lflag >= 2)
  80167b:	83 fa 01             	cmp    $0x1,%edx
  80167e:	7e 16                	jle    801696 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  801680:	8b 45 14             	mov    0x14(%ebp),%eax
  801683:	8d 50 08             	lea    0x8(%eax),%edx
  801686:	89 55 14             	mov    %edx,0x14(%ebp)
  801689:	8b 50 04             	mov    0x4(%eax),%edx
  80168c:	8b 00                	mov    (%eax),%eax
  80168e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801691:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801694:	eb 32                	jmp    8016c8 <vprintfmt+0x2ea>
	else if (lflag)
  801696:	85 d2                	test   %edx,%edx
  801698:	74 18                	je     8016b2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80169a:	8b 45 14             	mov    0x14(%ebp),%eax
  80169d:	8d 50 04             	lea    0x4(%eax),%edx
  8016a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8016a3:	8b 30                	mov    (%eax),%esi
  8016a5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016a8:	89 f0                	mov    %esi,%eax
  8016aa:	c1 f8 1f             	sar    $0x1f,%eax
  8016ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016b0:	eb 16                	jmp    8016c8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8016b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b5:	8d 50 04             	lea    0x4(%eax),%edx
  8016b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016bb:	8b 30                	mov    (%eax),%esi
  8016bd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016c0:	89 f0                	mov    %esi,%eax
  8016c2:	c1 f8 1f             	sar    $0x1f,%eax
  8016c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8016c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8016ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8016d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016d7:	0f 89 80 00 00 00    	jns    80175d <vprintfmt+0x37f>
				putch('-', putdat);
  8016dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016e1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016e8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8016eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f1:	f7 d8                	neg    %eax
  8016f3:	83 d2 00             	adc    $0x0,%edx
  8016f6:	f7 da                	neg    %edx
			base = 10;
  8016f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8016fd:	eb 5e                	jmp    80175d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8016ff:	8d 45 14             	lea    0x14(%ebp),%eax
  801702:	e8 58 fc ff ff       	call   80135f <getuint>
			base = 10;
  801707:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80170c:	eb 4f                	jmp    80175d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80170e:	8d 45 14             	lea    0x14(%ebp),%eax
  801711:	e8 49 fc ff ff       	call   80135f <getuint>
            base = 8;
  801716:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80171b:	eb 40                	jmp    80175d <vprintfmt+0x37f>
			putch('0', putdat);
  80171d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801721:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801728:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80172b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80172f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801736:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  801739:	8b 45 14             	mov    0x14(%ebp),%eax
  80173c:	8d 50 04             	lea    0x4(%eax),%edx
  80173f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801742:	8b 00                	mov    (%eax),%eax
  801744:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  801749:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80174e:	eb 0d                	jmp    80175d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  801750:	8d 45 14             	lea    0x14(%ebp),%eax
  801753:	e8 07 fc ff ff       	call   80135f <getuint>
			base = 16;
  801758:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80175d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801761:	89 74 24 10          	mov    %esi,0x10(%esp)
  801765:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801768:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80176c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801770:	89 04 24             	mov    %eax,(%esp)
  801773:	89 54 24 04          	mov    %edx,0x4(%esp)
  801777:	89 fa                	mov    %edi,%edx
  801779:	8b 45 08             	mov    0x8(%ebp),%eax
  80177c:	e8 ef fa ff ff       	call   801270 <printnum>
			break;
  801781:	e9 88 fc ff ff       	jmp    80140e <vprintfmt+0x30>
			putch(ch, putdat);
  801786:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80178a:	89 04 24             	mov    %eax,(%esp)
  80178d:	ff 55 08             	call   *0x8(%ebp)
			break;
  801790:	e9 79 fc ff ff       	jmp    80140e <vprintfmt+0x30>
			putch('%', putdat);
  801795:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801799:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017a0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017a3:	89 f3                	mov    %esi,%ebx
  8017a5:	eb 03                	jmp    8017aa <vprintfmt+0x3cc>
  8017a7:	83 eb 01             	sub    $0x1,%ebx
  8017aa:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017ae:	75 f7                	jne    8017a7 <vprintfmt+0x3c9>
  8017b0:	e9 59 fc ff ff       	jmp    80140e <vprintfmt+0x30>
}
  8017b5:	83 c4 3c             	add    $0x3c,%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5f                   	pop    %edi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 28             	sub    $0x28,%esp
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	74 30                	je     80180e <vsnprintf+0x51>
  8017de:	85 d2                	test   %edx,%edx
  8017e0:	7e 2c                	jle    80180e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	c7 04 24 99 13 80 00 	movl   $0x801399,(%esp)
  8017fe:	e8 db fb ff ff       	call   8013de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801803:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801806:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801809:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180c:	eb 05                	jmp    801813 <vsnprintf+0x56>
		return -E_INVAL;
  80180e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80181b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80181e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801822:	8b 45 10             	mov    0x10(%ebp),%eax
  801825:	89 44 24 08          	mov    %eax,0x8(%esp)
  801829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	89 04 24             	mov    %eax,(%esp)
  801836:	e8 82 ff ff ff       	call   8017bd <vsnprintf>
	va_end(ap);

	return rc;
}
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    
  80183d:	66 90                	xchg   %ax,%ax
  80183f:	90                   	nop

00801840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801846:	b8 00 00 00 00       	mov    $0x0,%eax
  80184b:	eb 03                	jmp    801850 <strlen+0x10>
		n++;
  80184d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801850:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801854:	75 f7                	jne    80184d <strlen+0xd>
	return n;
}
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
  801866:	eb 03                	jmp    80186b <strnlen+0x13>
		n++;
  801868:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80186b:	39 d0                	cmp    %edx,%eax
  80186d:	74 06                	je     801875 <strnlen+0x1d>
  80186f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801873:	75 f3                	jne    801868 <strnlen+0x10>
	return n;
}
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	53                   	push   %ebx
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801881:	89 c2                	mov    %eax,%edx
  801883:	83 c2 01             	add    $0x1,%edx
  801886:	83 c1 01             	add    $0x1,%ecx
  801889:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80188d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801890:	84 db                	test   %bl,%bl
  801892:	75 ef                	jne    801883 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801894:	5b                   	pop    %ebx
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	53                   	push   %ebx
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018a1:	89 1c 24             	mov    %ebx,(%esp)
  8018a4:	e8 97 ff ff ff       	call   801840 <strlen>
	strcpy(dst + len, src);
  8018a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018b0:	01 d8                	add    %ebx,%eax
  8018b2:	89 04 24             	mov    %eax,(%esp)
  8018b5:	e8 bd ff ff ff       	call   801877 <strcpy>
	return dst;
}
  8018ba:	89 d8                	mov    %ebx,%eax
  8018bc:	83 c4 08             	add    $0x8,%esp
  8018bf:	5b                   	pop    %ebx
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    

008018c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	56                   	push   %esi
  8018c6:	53                   	push   %ebx
  8018c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018cd:	89 f3                	mov    %esi,%ebx
  8018cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018d2:	89 f2                	mov    %esi,%edx
  8018d4:	eb 0f                	jmp    8018e5 <strncpy+0x23>
		*dst++ = *src;
  8018d6:	83 c2 01             	add    $0x1,%edx
  8018d9:	0f b6 01             	movzbl (%ecx),%eax
  8018dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8018df:	80 39 01             	cmpb   $0x1,(%ecx)
  8018e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8018e5:	39 da                	cmp    %ebx,%edx
  8018e7:	75 ed                	jne    8018d6 <strncpy+0x14>
	}
	return ret;
}
  8018e9:	89 f0                	mov    %esi,%eax
  8018eb:	5b                   	pop    %ebx
  8018ec:	5e                   	pop    %esi
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	56                   	push   %esi
  8018f3:	53                   	push   %ebx
  8018f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8018f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018fd:	89 f0                	mov    %esi,%eax
  8018ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801903:	85 c9                	test   %ecx,%ecx
  801905:	75 0b                	jne    801912 <strlcpy+0x23>
  801907:	eb 1d                	jmp    801926 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801909:	83 c0 01             	add    $0x1,%eax
  80190c:	83 c2 01             	add    $0x1,%edx
  80190f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801912:	39 d8                	cmp    %ebx,%eax
  801914:	74 0b                	je     801921 <strlcpy+0x32>
  801916:	0f b6 0a             	movzbl (%edx),%ecx
  801919:	84 c9                	test   %cl,%cl
  80191b:	75 ec                	jne    801909 <strlcpy+0x1a>
  80191d:	89 c2                	mov    %eax,%edx
  80191f:	eb 02                	jmp    801923 <strlcpy+0x34>
  801921:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  801923:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801926:	29 f0                	sub    %esi,%eax
}
  801928:	5b                   	pop    %ebx
  801929:	5e                   	pop    %esi
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801932:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801935:	eb 06                	jmp    80193d <strcmp+0x11>
		p++, q++;
  801937:	83 c1 01             	add    $0x1,%ecx
  80193a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80193d:	0f b6 01             	movzbl (%ecx),%eax
  801940:	84 c0                	test   %al,%al
  801942:	74 04                	je     801948 <strcmp+0x1c>
  801944:	3a 02                	cmp    (%edx),%al
  801946:	74 ef                	je     801937 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801948:	0f b6 c0             	movzbl %al,%eax
  80194b:	0f b6 12             	movzbl (%edx),%edx
  80194e:	29 d0                	sub    %edx,%eax
}
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	53                   	push   %ebx
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195c:	89 c3                	mov    %eax,%ebx
  80195e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801961:	eb 06                	jmp    801969 <strncmp+0x17>
		n--, p++, q++;
  801963:	83 c0 01             	add    $0x1,%eax
  801966:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801969:	39 d8                	cmp    %ebx,%eax
  80196b:	74 15                	je     801982 <strncmp+0x30>
  80196d:	0f b6 08             	movzbl (%eax),%ecx
  801970:	84 c9                	test   %cl,%cl
  801972:	74 04                	je     801978 <strncmp+0x26>
  801974:	3a 0a                	cmp    (%edx),%cl
  801976:	74 eb                	je     801963 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801978:	0f b6 00             	movzbl (%eax),%eax
  80197b:	0f b6 12             	movzbl (%edx),%edx
  80197e:	29 d0                	sub    %edx,%eax
  801980:	eb 05                	jmp    801987 <strncmp+0x35>
		return 0;
  801982:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801987:	5b                   	pop    %ebx
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	8b 45 08             	mov    0x8(%ebp),%eax
  801990:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801994:	eb 07                	jmp    80199d <strchr+0x13>
		if (*s == c)
  801996:	38 ca                	cmp    %cl,%dl
  801998:	74 0f                	je     8019a9 <strchr+0x1f>
	for (; *s; s++)
  80199a:	83 c0 01             	add    $0x1,%eax
  80199d:	0f b6 10             	movzbl (%eax),%edx
  8019a0:	84 d2                	test   %dl,%dl
  8019a2:	75 f2                	jne    801996 <strchr+0xc>
			return (char *) s;
	return 0;
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8019b5:	eb 07                	jmp    8019be <strfind+0x13>
		if (*s == c)
  8019b7:	38 ca                	cmp    %cl,%dl
  8019b9:	74 0a                	je     8019c5 <strfind+0x1a>
	for (; *s; s++)
  8019bb:	83 c0 01             	add    $0x1,%eax
  8019be:	0f b6 10             	movzbl (%eax),%edx
  8019c1:	84 d2                	test   %dl,%dl
  8019c3:	75 f2                	jne    8019b7 <strfind+0xc>
			break;
	return (char *) s;
}
  8019c5:	5d                   	pop    %ebp
  8019c6:	c3                   	ret    

008019c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	57                   	push   %edi
  8019cb:	56                   	push   %esi
  8019cc:	53                   	push   %ebx
  8019cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019d3:	85 c9                	test   %ecx,%ecx
  8019d5:	74 36                	je     801a0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019dd:	75 28                	jne    801a07 <memset+0x40>
  8019df:	f6 c1 03             	test   $0x3,%cl
  8019e2:	75 23                	jne    801a07 <memset+0x40>
		c &= 0xFF;
  8019e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8019e8:	89 d3                	mov    %edx,%ebx
  8019ea:	c1 e3 08             	shl    $0x8,%ebx
  8019ed:	89 d6                	mov    %edx,%esi
  8019ef:	c1 e6 18             	shl    $0x18,%esi
  8019f2:	89 d0                	mov    %edx,%eax
  8019f4:	c1 e0 10             	shl    $0x10,%eax
  8019f7:	09 f0                	or     %esi,%eax
  8019f9:	09 c2                	or     %eax,%edx
  8019fb:	89 d0                	mov    %edx,%eax
  8019fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8019ff:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801a02:	fc                   	cld    
  801a03:	f3 ab                	rep stos %eax,%es:(%edi)
  801a05:	eb 06                	jmp    801a0d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0a:	fc                   	cld    
  801a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a0d:	89 f8                	mov    %edi,%eax
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5f                   	pop    %edi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    

00801a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	57                   	push   %edi
  801a18:	56                   	push   %esi
  801a19:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a22:	39 c6                	cmp    %eax,%esi
  801a24:	73 35                	jae    801a5b <memmove+0x47>
  801a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a29:	39 d0                	cmp    %edx,%eax
  801a2b:	73 2e                	jae    801a5b <memmove+0x47>
		s += n;
		d += n;
  801a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a30:	89 d6                	mov    %edx,%esi
  801a32:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a3a:	75 13                	jne    801a4f <memmove+0x3b>
  801a3c:	f6 c1 03             	test   $0x3,%cl
  801a3f:	75 0e                	jne    801a4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a41:	83 ef 04             	sub    $0x4,%edi
  801a44:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a47:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801a4a:	fd                   	std    
  801a4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a4d:	eb 09                	jmp    801a58 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a4f:	83 ef 01             	sub    $0x1,%edi
  801a52:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801a55:	fd                   	std    
  801a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a58:	fc                   	cld    
  801a59:	eb 1d                	jmp    801a78 <memmove+0x64>
  801a5b:	89 f2                	mov    %esi,%edx
  801a5d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a5f:	f6 c2 03             	test   $0x3,%dl
  801a62:	75 0f                	jne    801a73 <memmove+0x5f>
  801a64:	f6 c1 03             	test   $0x3,%cl
  801a67:	75 0a                	jne    801a73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a69:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801a6c:	89 c7                	mov    %eax,%edi
  801a6e:	fc                   	cld    
  801a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a71:	eb 05                	jmp    801a78 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801a73:	89 c7                	mov    %eax,%edi
  801a75:	fc                   	cld    
  801a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a78:	5e                   	pop    %esi
  801a79:	5f                   	pop    %edi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a82:	8b 45 10             	mov    0x10(%ebp),%eax
  801a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	89 04 24             	mov    %eax,(%esp)
  801a96:	e8 79 ff ff ff       	call   801a14 <memmove>
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	56                   	push   %esi
  801aa1:	53                   	push   %ebx
  801aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa8:	89 d6                	mov    %edx,%esi
  801aaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801aad:	eb 1a                	jmp    801ac9 <memcmp+0x2c>
		if (*s1 != *s2)
  801aaf:	0f b6 02             	movzbl (%edx),%eax
  801ab2:	0f b6 19             	movzbl (%ecx),%ebx
  801ab5:	38 d8                	cmp    %bl,%al
  801ab7:	74 0a                	je     801ac3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ab9:	0f b6 c0             	movzbl %al,%eax
  801abc:	0f b6 db             	movzbl %bl,%ebx
  801abf:	29 d8                	sub    %ebx,%eax
  801ac1:	eb 0f                	jmp    801ad2 <memcmp+0x35>
		s1++, s2++;
  801ac3:	83 c2 01             	add    $0x1,%edx
  801ac6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  801ac9:	39 f2                	cmp    %esi,%edx
  801acb:	75 e2                	jne    801aaf <memcmp+0x12>
	}

	return 0;
  801acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  801adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801adf:	89 c2                	mov    %eax,%edx
  801ae1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ae4:	eb 07                	jmp    801aed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ae6:	38 08                	cmp    %cl,(%eax)
  801ae8:	74 07                	je     801af1 <memfind+0x1b>
	for (; s < ends; s++)
  801aea:	83 c0 01             	add    $0x1,%eax
  801aed:	39 d0                	cmp    %edx,%eax
  801aef:	72 f5                	jb     801ae6 <memfind+0x10>
			break;
	return (void *) s;
}
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	57                   	push   %edi
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	8b 55 08             	mov    0x8(%ebp),%edx
  801afc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801aff:	eb 03                	jmp    801b04 <strtol+0x11>
		s++;
  801b01:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801b04:	0f b6 0a             	movzbl (%edx),%ecx
  801b07:	80 f9 09             	cmp    $0x9,%cl
  801b0a:	74 f5                	je     801b01 <strtol+0xe>
  801b0c:	80 f9 20             	cmp    $0x20,%cl
  801b0f:	74 f0                	je     801b01 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801b11:	80 f9 2b             	cmp    $0x2b,%cl
  801b14:	75 0a                	jne    801b20 <strtol+0x2d>
		s++;
  801b16:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801b19:	bf 00 00 00 00       	mov    $0x0,%edi
  801b1e:	eb 11                	jmp    801b31 <strtol+0x3e>
  801b20:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  801b25:	80 f9 2d             	cmp    $0x2d,%cl
  801b28:	75 07                	jne    801b31 <strtol+0x3e>
		s++, neg = 1;
  801b2a:	8d 52 01             	lea    0x1(%edx),%edx
  801b2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b36:	75 15                	jne    801b4d <strtol+0x5a>
  801b38:	80 3a 30             	cmpb   $0x30,(%edx)
  801b3b:	75 10                	jne    801b4d <strtol+0x5a>
  801b3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b41:	75 0a                	jne    801b4d <strtol+0x5a>
		s += 2, base = 16;
  801b43:	83 c2 02             	add    $0x2,%edx
  801b46:	b8 10 00 00 00       	mov    $0x10,%eax
  801b4b:	eb 10                	jmp    801b5d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	75 0c                	jne    801b5d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801b51:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801b53:	80 3a 30             	cmpb   $0x30,(%edx)
  801b56:	75 05                	jne    801b5d <strtol+0x6a>
		s++, base = 8;
  801b58:	83 c2 01             	add    $0x1,%edx
  801b5b:	b0 08                	mov    $0x8,%al
		base = 10;
  801b5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b62:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b65:	0f b6 0a             	movzbl (%edx),%ecx
  801b68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b6b:	89 f0                	mov    %esi,%eax
  801b6d:	3c 09                	cmp    $0x9,%al
  801b6f:	77 08                	ja     801b79 <strtol+0x86>
			dig = *s - '0';
  801b71:	0f be c9             	movsbl %cl,%ecx
  801b74:	83 e9 30             	sub    $0x30,%ecx
  801b77:	eb 20                	jmp    801b99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801b79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801b7c:	89 f0                	mov    %esi,%eax
  801b7e:	3c 19                	cmp    $0x19,%al
  801b80:	77 08                	ja     801b8a <strtol+0x97>
			dig = *s - 'a' + 10;
  801b82:	0f be c9             	movsbl %cl,%ecx
  801b85:	83 e9 57             	sub    $0x57,%ecx
  801b88:	eb 0f                	jmp    801b99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  801b8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801b8d:	89 f0                	mov    %esi,%eax
  801b8f:	3c 19                	cmp    $0x19,%al
  801b91:	77 16                	ja     801ba9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801b93:	0f be c9             	movsbl %cl,%ecx
  801b96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801b9c:	7d 0f                	jge    801bad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  801b9e:	83 c2 01             	add    $0x1,%edx
  801ba1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801ba5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801ba7:	eb bc                	jmp    801b65 <strtol+0x72>
  801ba9:	89 d8                	mov    %ebx,%eax
  801bab:	eb 02                	jmp    801baf <strtol+0xbc>
  801bad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801baf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bb3:	74 05                	je     801bba <strtol+0xc7>
		*endptr = (char *) s;
  801bb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bb8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801bba:	f7 d8                	neg    %eax
  801bbc:	85 ff                	test   %edi,%edi
  801bbe:	0f 44 c3             	cmove  %ebx,%eax
}
  801bc1:	5b                   	pop    %ebx
  801bc2:	5e                   	pop    %esi
  801bc3:	5f                   	pop    %edi
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    
  801bc6:	66 90                	xchg   %ax,%ax
  801bc8:	66 90                	xchg   %ax,%ax
  801bca:	66 90                	xchg   %ax,%ax
  801bcc:	66 90                	xchg   %ax,%ax
  801bce:	66 90                	xchg   %ax,%ax

00801bd0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 10             	sub    $0x10,%esp
  801bd8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bde:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801be1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801be3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801be8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 9b e7 ff ff       	call   80038e <sys_ipc_recv>
    if(r < 0){
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	79 16                	jns    801c0d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	74 06                	je     801c01 <ipc_recv+0x31>
            *from_env_store = 0;
  801bfb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801c01:	85 db                	test   %ebx,%ebx
  801c03:	74 2c                	je     801c31 <ipc_recv+0x61>
            *perm_store = 0;
  801c05:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c0b:	eb 24                	jmp    801c31 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801c0d:	85 f6                	test   %esi,%esi
  801c0f:	74 0a                	je     801c1b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801c11:	a1 08 40 80 00       	mov    0x804008,%eax
  801c16:	8b 40 74             	mov    0x74(%eax),%eax
  801c19:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801c1b:	85 db                	test   %ebx,%ebx
  801c1d:	74 0a                	je     801c29 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801c1f:	a1 08 40 80 00       	mov    0x804008,%eax
  801c24:	8b 40 78             	mov    0x78(%eax),%eax
  801c27:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c29:	a1 08 40 80 00       	mov    0x804008,%eax
  801c2e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	57                   	push   %edi
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 1c             	sub    $0x1c,%esp
  801c41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801c4a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801c4c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801c51:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801c54:	8b 45 14             	mov    0x14(%ebp),%eax
  801c57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c63:	89 3c 24             	mov    %edi,(%esp)
  801c66:	e8 00 e7 ff ff       	call   80036b <sys_ipc_try_send>
        if(r == 0){
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	74 28                	je     801c97 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801c6f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c72:	74 1c                	je     801c90 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801c74:	c7 44 24 08 20 24 80 	movl   $0x802420,0x8(%esp)
  801c7b:	00 
  801c7c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801c83:	00 
  801c84:	c7 04 24 37 24 80 00 	movl   $0x802437,(%esp)
  801c8b:	e8 c6 f4 ff ff       	call   801156 <_panic>
        }
        sys_yield();
  801c90:	e8 c4 e4 ff ff       	call   800159 <sys_yield>
    }
  801c95:	eb bd                	jmp    801c54 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801c97:	83 c4 1c             	add    $0x1c,%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5f                   	pop    %edi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ca5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801caa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cb3:	8b 52 50             	mov    0x50(%edx),%edx
  801cb6:	39 ca                	cmp    %ecx,%edx
  801cb8:	75 0d                	jne    801cc7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cbd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cc2:	8b 40 40             	mov    0x40(%eax),%eax
  801cc5:	eb 0e                	jmp    801cd5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801cc7:	83 c0 01             	add    $0x1,%eax
  801cca:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ccf:	75 d9                	jne    801caa <ipc_find_env+0xb>
	return 0;
  801cd1:	66 b8 00 00          	mov    $0x0,%ax
}
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cdd:	89 d0                	mov    %edx,%eax
  801cdf:	c1 e8 16             	shr    $0x16,%eax
  801ce2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ce9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801cee:	f6 c1 01             	test   $0x1,%cl
  801cf1:	74 1d                	je     801d10 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801cf3:	c1 ea 0c             	shr    $0xc,%edx
  801cf6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cfd:	f6 c2 01             	test   $0x1,%dl
  801d00:	74 0e                	je     801d10 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d02:	c1 ea 0c             	shr    $0xc,%edx
  801d05:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d0c:	ef 
  801d0d:	0f b7 c0             	movzwl %ax,%eax
}
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	66 90                	xchg   %ax,%ax
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__udivdi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	83 ec 0c             	sub    $0xc,%esp
  801d26:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d2a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d2e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d32:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d36:	85 c0                	test   %eax,%eax
  801d38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d3c:	89 ea                	mov    %ebp,%edx
  801d3e:	89 0c 24             	mov    %ecx,(%esp)
  801d41:	75 2d                	jne    801d70 <__udivdi3+0x50>
  801d43:	39 e9                	cmp    %ebp,%ecx
  801d45:	77 61                	ja     801da8 <__udivdi3+0x88>
  801d47:	85 c9                	test   %ecx,%ecx
  801d49:	89 ce                	mov    %ecx,%esi
  801d4b:	75 0b                	jne    801d58 <__udivdi3+0x38>
  801d4d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d52:	31 d2                	xor    %edx,%edx
  801d54:	f7 f1                	div    %ecx
  801d56:	89 c6                	mov    %eax,%esi
  801d58:	31 d2                	xor    %edx,%edx
  801d5a:	89 e8                	mov    %ebp,%eax
  801d5c:	f7 f6                	div    %esi
  801d5e:	89 c5                	mov    %eax,%ebp
  801d60:	89 f8                	mov    %edi,%eax
  801d62:	f7 f6                	div    %esi
  801d64:	89 ea                	mov    %ebp,%edx
  801d66:	83 c4 0c             	add    $0xc,%esp
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi
  801d70:	39 e8                	cmp    %ebp,%eax
  801d72:	77 24                	ja     801d98 <__udivdi3+0x78>
  801d74:	0f bd e8             	bsr    %eax,%ebp
  801d77:	83 f5 1f             	xor    $0x1f,%ebp
  801d7a:	75 3c                	jne    801db8 <__udivdi3+0x98>
  801d7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d80:	39 34 24             	cmp    %esi,(%esp)
  801d83:	0f 86 9f 00 00 00    	jbe    801e28 <__udivdi3+0x108>
  801d89:	39 d0                	cmp    %edx,%eax
  801d8b:	0f 82 97 00 00 00    	jb     801e28 <__udivdi3+0x108>
  801d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d98:	31 d2                	xor    %edx,%edx
  801d9a:	31 c0                	xor    %eax,%eax
  801d9c:	83 c4 0c             	add    $0xc,%esp
  801d9f:	5e                   	pop    %esi
  801da0:	5f                   	pop    %edi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    
  801da3:	90                   	nop
  801da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da8:	89 f8                	mov    %edi,%eax
  801daa:	f7 f1                	div    %ecx
  801dac:	31 d2                	xor    %edx,%edx
  801dae:	83 c4 0c             	add    $0xc,%esp
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	8b 3c 24             	mov    (%esp),%edi
  801dbd:	d3 e0                	shl    %cl,%eax
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	b8 20 00 00 00       	mov    $0x20,%eax
  801dc6:	29 e8                	sub    %ebp,%eax
  801dc8:	89 c1                	mov    %eax,%ecx
  801dca:	d3 ef                	shr    %cl,%edi
  801dcc:	89 e9                	mov    %ebp,%ecx
  801dce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801dd2:	8b 3c 24             	mov    (%esp),%edi
  801dd5:	09 74 24 08          	or     %esi,0x8(%esp)
  801dd9:	89 d6                	mov    %edx,%esi
  801ddb:	d3 e7                	shl    %cl,%edi
  801ddd:	89 c1                	mov    %eax,%ecx
  801ddf:	89 3c 24             	mov    %edi,(%esp)
  801de2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801de6:	d3 ee                	shr    %cl,%esi
  801de8:	89 e9                	mov    %ebp,%ecx
  801dea:	d3 e2                	shl    %cl,%edx
  801dec:	89 c1                	mov    %eax,%ecx
  801dee:	d3 ef                	shr    %cl,%edi
  801df0:	09 d7                	or     %edx,%edi
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	89 f8                	mov    %edi,%eax
  801df6:	f7 74 24 08          	divl   0x8(%esp)
  801dfa:	89 d6                	mov    %edx,%esi
  801dfc:	89 c7                	mov    %eax,%edi
  801dfe:	f7 24 24             	mull   (%esp)
  801e01:	39 d6                	cmp    %edx,%esi
  801e03:	89 14 24             	mov    %edx,(%esp)
  801e06:	72 30                	jb     801e38 <__udivdi3+0x118>
  801e08:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e0c:	89 e9                	mov    %ebp,%ecx
  801e0e:	d3 e2                	shl    %cl,%edx
  801e10:	39 c2                	cmp    %eax,%edx
  801e12:	73 05                	jae    801e19 <__udivdi3+0xf9>
  801e14:	3b 34 24             	cmp    (%esp),%esi
  801e17:	74 1f                	je     801e38 <__udivdi3+0x118>
  801e19:	89 f8                	mov    %edi,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	e9 7a ff ff ff       	jmp    801d9c <__udivdi3+0x7c>
  801e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e28:	31 d2                	xor    %edx,%edx
  801e2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2f:	e9 68 ff ff ff       	jmp    801d9c <__udivdi3+0x7c>
  801e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e38:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	83 c4 0c             	add    $0xc,%esp
  801e40:	5e                   	pop    %esi
  801e41:	5f                   	pop    %edi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    
  801e44:	66 90                	xchg   %ax,%ax
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__umoddi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	83 ec 14             	sub    $0x14,%esp
  801e56:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e5a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e5e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e62:	89 c7                	mov    %eax,%edi
  801e64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e68:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e6c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e70:	89 34 24             	mov    %esi,(%esp)
  801e73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e77:	85 c0                	test   %eax,%eax
  801e79:	89 c2                	mov    %eax,%edx
  801e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e7f:	75 17                	jne    801e98 <__umoddi3+0x48>
  801e81:	39 fe                	cmp    %edi,%esi
  801e83:	76 4b                	jbe    801ed0 <__umoddi3+0x80>
  801e85:	89 c8                	mov    %ecx,%eax
  801e87:	89 fa                	mov    %edi,%edx
  801e89:	f7 f6                	div    %esi
  801e8b:	89 d0                	mov    %edx,%eax
  801e8d:	31 d2                	xor    %edx,%edx
  801e8f:	83 c4 14             	add    $0x14,%esp
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    
  801e96:	66 90                	xchg   %ax,%ax
  801e98:	39 f8                	cmp    %edi,%eax
  801e9a:	77 54                	ja     801ef0 <__umoddi3+0xa0>
  801e9c:	0f bd e8             	bsr    %eax,%ebp
  801e9f:	83 f5 1f             	xor    $0x1f,%ebp
  801ea2:	75 5c                	jne    801f00 <__umoddi3+0xb0>
  801ea4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ea8:	39 3c 24             	cmp    %edi,(%esp)
  801eab:	0f 87 e7 00 00 00    	ja     801f98 <__umoddi3+0x148>
  801eb1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801eb5:	29 f1                	sub    %esi,%ecx
  801eb7:	19 c7                	sbb    %eax,%edi
  801eb9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ebd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ec1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ec5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ec9:	83 c4 14             	add    $0x14,%esp
  801ecc:	5e                   	pop    %esi
  801ecd:	5f                   	pop    %edi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    
  801ed0:	85 f6                	test   %esi,%esi
  801ed2:	89 f5                	mov    %esi,%ebp
  801ed4:	75 0b                	jne    801ee1 <__umoddi3+0x91>
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f6                	div    %esi
  801edf:	89 c5                	mov    %eax,%ebp
  801ee1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ee5:	31 d2                	xor    %edx,%edx
  801ee7:	f7 f5                	div    %ebp
  801ee9:	89 c8                	mov    %ecx,%eax
  801eeb:	f7 f5                	div    %ebp
  801eed:	eb 9c                	jmp    801e8b <__umoddi3+0x3b>
  801eef:	90                   	nop
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 fa                	mov    %edi,%edx
  801ef4:	83 c4 14             	add    $0x14,%esp
  801ef7:	5e                   	pop    %esi
  801ef8:	5f                   	pop    %edi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    
  801efb:	90                   	nop
  801efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f00:	8b 04 24             	mov    (%esp),%eax
  801f03:	be 20 00 00 00       	mov    $0x20,%esi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	29 ee                	sub    %ebp,%esi
  801f0c:	d3 e2                	shl    %cl,%edx
  801f0e:	89 f1                	mov    %esi,%ecx
  801f10:	d3 e8                	shr    %cl,%eax
  801f12:	89 e9                	mov    %ebp,%ecx
  801f14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f18:	8b 04 24             	mov    (%esp),%eax
  801f1b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f1f:	89 fa                	mov    %edi,%edx
  801f21:	d3 e0                	shl    %cl,%eax
  801f23:	89 f1                	mov    %esi,%ecx
  801f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f2d:	d3 ea                	shr    %cl,%edx
  801f2f:	89 e9                	mov    %ebp,%ecx
  801f31:	d3 e7                	shl    %cl,%edi
  801f33:	89 f1                	mov    %esi,%ecx
  801f35:	d3 e8                	shr    %cl,%eax
  801f37:	89 e9                	mov    %ebp,%ecx
  801f39:	09 f8                	or     %edi,%eax
  801f3b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f3f:	f7 74 24 04          	divl   0x4(%esp)
  801f43:	d3 e7                	shl    %cl,%edi
  801f45:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f49:	89 d7                	mov    %edx,%edi
  801f4b:	f7 64 24 08          	mull   0x8(%esp)
  801f4f:	39 d7                	cmp    %edx,%edi
  801f51:	89 c1                	mov    %eax,%ecx
  801f53:	89 14 24             	mov    %edx,(%esp)
  801f56:	72 2c                	jb     801f84 <__umoddi3+0x134>
  801f58:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f5c:	72 22                	jb     801f80 <__umoddi3+0x130>
  801f5e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f62:	29 c8                	sub    %ecx,%eax
  801f64:	19 d7                	sbb    %edx,%edi
  801f66:	89 e9                	mov    %ebp,%ecx
  801f68:	89 fa                	mov    %edi,%edx
  801f6a:	d3 e8                	shr    %cl,%eax
  801f6c:	89 f1                	mov    %esi,%ecx
  801f6e:	d3 e2                	shl    %cl,%edx
  801f70:	89 e9                	mov    %ebp,%ecx
  801f72:	d3 ef                	shr    %cl,%edi
  801f74:	09 d0                	or     %edx,%eax
  801f76:	89 fa                	mov    %edi,%edx
  801f78:	83 c4 14             	add    $0x14,%esp
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    
  801f7f:	90                   	nop
  801f80:	39 d7                	cmp    %edx,%edi
  801f82:	75 da                	jne    801f5e <__umoddi3+0x10e>
  801f84:	8b 14 24             	mov    (%esp),%edx
  801f87:	89 c1                	mov    %eax,%ecx
  801f89:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801f8d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801f91:	eb cb                	jmp    801f5e <__umoddi3+0x10e>
  801f93:	90                   	nop
  801f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f98:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801f9c:	0f 82 0f ff ff ff    	jb     801eb1 <__umoddi3+0x61>
  801fa2:	e9 1a ff ff ff       	jmp    801ec1 <__umoddi3+0x71>
