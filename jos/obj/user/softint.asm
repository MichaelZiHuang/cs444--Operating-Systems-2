
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 10             	sub    $0x10,%esp
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  800048:	e8 dd 00 00 00       	call   80012a <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  80004d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800052:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80006e:	89 1c 24             	mov    %ebx,(%esp)
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 07 00 00 00       	call   800082 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800088:	e8 18 05 00 00       	call   8005a5 <close_all>
	sys_env_destroy(0);
  80008d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800094:	e8 3f 00 00 00       	call   8000d8 <sys_env_destroy>
}
  800099:	c9                   	leave  
  80009a:	c3                   	ret    

0080009b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	57                   	push   %edi
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	89 c3                	mov    %eax,%ebx
  8000ae:	89 c7                	mov    %eax,%edi
  8000b0:	89 c6                	mov    %eax,%esi
  8000b2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c9:	89 d1                	mov    %edx,%ecx
  8000cb:	89 d3                	mov    %edx,%ebx
  8000cd:	89 d7                	mov    %edx,%edi
  8000cf:	89 d6                	mov    %edx,%esi
  8000d1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	89 cb                	mov    %ecx,%ebx
  8000f0:	89 cf                	mov    %ecx,%edi
  8000f2:	89 ce                	mov    %ecx,%esi
  8000f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	7e 28                	jle    800122 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000fe:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800105:	00 
  800106:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  80010d:	00 
  80010e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800115:	00 
  800116:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  80011d:	e8 24 10 00 00       	call   801146 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	83 c4 2c             	add    $0x2c,%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0b 00 00 00       	mov    $0xb,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 28                	jle    8001b4 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800190:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800197:	00 
  800198:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  80019f:	00 
  8001a0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a7:	00 
  8001a8:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8001af:	e8 92 0f 00 00       	call   801146 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	83 c4 2c             	add    $0x2c,%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 28                	jle    800207 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e3:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ea:	00 
  8001eb:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001fa:	00 
  8001fb:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  800202:	e8 3f 0f 00 00       	call   801146 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800207:	83 c4 2c             	add    $0x2c,%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800218:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021d:	b8 06 00 00 00       	mov    $0x6,%eax
  800222:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800225:	8b 55 08             	mov    0x8(%ebp),%edx
  800228:	89 df                	mov    %ebx,%edi
  80022a:	89 de                	mov    %ebx,%esi
  80022c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022e:	85 c0                	test   %eax,%eax
  800230:	7e 28                	jle    80025a <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800232:	89 44 24 10          	mov    %eax,0x10(%esp)
  800236:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80023d:	00 
  80023e:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  800245:	00 
  800246:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80024d:	00 
  80024e:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  800255:	e8 ec 0e 00 00       	call   801146 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025a:	83 c4 2c             	add    $0x2c,%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5e                   	pop    %esi
  80025f:	5f                   	pop    %edi
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    

00800262 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	57                   	push   %edi
  800266:	56                   	push   %esi
  800267:	53                   	push   %ebx
  800268:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80026b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800270:	b8 08 00 00 00       	mov    $0x8,%eax
  800275:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800278:	8b 55 08             	mov    0x8(%ebp),%edx
  80027b:	89 df                	mov    %ebx,%edi
  80027d:	89 de                	mov    %ebx,%esi
  80027f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800281:	85 c0                	test   %eax,%eax
  800283:	7e 28                	jle    8002ad <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800285:	89 44 24 10          	mov    %eax,0x10(%esp)
  800289:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800290:	00 
  800291:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  800298:	00 
  800299:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a0:	00 
  8002a1:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8002a8:	e8 99 0e 00 00       	call   801146 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ad:	83 c4 2c             	add    $0x2c,%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 28                	jle    800300 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002dc:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e3:	00 
  8002e4:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8002eb:	00 
  8002ec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f3:	00 
  8002f4:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8002fb:	e8 46 0e 00 00       	call   801146 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800300:	83 c4 2c             	add    $0x2c,%esp
  800303:	5b                   	pop    %ebx
  800304:	5e                   	pop    %esi
  800305:	5f                   	pop    %edi
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	57                   	push   %edi
  80030c:	56                   	push   %esi
  80030d:	53                   	push   %ebx
  80030e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800311:	bb 00 00 00 00       	mov    $0x0,%ebx
  800316:	b8 0a 00 00 00       	mov    $0xa,%eax
  80031b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031e:	8b 55 08             	mov    0x8(%ebp),%edx
  800321:	89 df                	mov    %ebx,%edi
  800323:	89 de                	mov    %ebx,%esi
  800325:	cd 30                	int    $0x30
	if(check && ret > 0)
  800327:	85 c0                	test   %eax,%eax
  800329:	7e 28                	jle    800353 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80032f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800336:	00 
  800337:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  80033e:	00 
  80033f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800346:	00 
  800347:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  80034e:	e8 f3 0d 00 00       	call   801146 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800353:	83 c4 2c             	add    $0x2c,%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	asm volatile("int %1\n"
  800361:	be 00 00 00 00       	mov    $0x0,%esi
  800366:	b8 0c 00 00 00       	mov    $0xc,%eax
  80036b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036e:	8b 55 08             	mov    0x8(%ebp),%edx
  800371:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800374:	8b 7d 14             	mov    0x14(%ebp),%edi
  800377:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800379:	5b                   	pop    %ebx
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	57                   	push   %edi
  800382:	56                   	push   %esi
  800383:	53                   	push   %ebx
  800384:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800387:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800391:	8b 55 08             	mov    0x8(%ebp),%edx
  800394:	89 cb                	mov    %ecx,%ebx
  800396:	89 cf                	mov    %ecx,%edi
  800398:	89 ce                	mov    %ecx,%esi
  80039a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80039c:	85 c0                	test   %eax,%eax
  80039e:	7e 28                	jle    8003c8 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a4:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8003b3:	00 
  8003b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003bb:	00 
  8003bc:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8003c3:	e8 7e 0d 00 00       	call   801146 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003c8:	83 c4 2c             	add    $0x2c,%esp
  8003cb:	5b                   	pop    %ebx
  8003cc:	5e                   	pop    %esi
  8003cd:	5f                   	pop    %edi
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003db:	c1 e8 0c             	shr    $0xc,%eax
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800402:	89 c2                	mov    %eax,%edx
  800404:	c1 ea 16             	shr    $0x16,%edx
  800407:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040e:	f6 c2 01             	test   $0x1,%dl
  800411:	74 11                	je     800424 <fd_alloc+0x2d>
  800413:	89 c2                	mov    %eax,%edx
  800415:	c1 ea 0c             	shr    $0xc,%edx
  800418:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041f:	f6 c2 01             	test   $0x1,%dl
  800422:	75 09                	jne    80042d <fd_alloc+0x36>
			*fd_store = fd;
  800424:	89 01                	mov    %eax,(%ecx)
			return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb 17                	jmp    800444 <fd_alloc+0x4d>
  80042d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800432:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800437:	75 c9                	jne    800402 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800439:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80043f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80044c:	83 f8 1f             	cmp    $0x1f,%eax
  80044f:	77 36                	ja     800487 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800451:	c1 e0 0c             	shl    $0xc,%eax
  800454:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800459:	89 c2                	mov    %eax,%edx
  80045b:	c1 ea 16             	shr    $0x16,%edx
  80045e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800465:	f6 c2 01             	test   $0x1,%dl
  800468:	74 24                	je     80048e <fd_lookup+0x48>
  80046a:	89 c2                	mov    %eax,%edx
  80046c:	c1 ea 0c             	shr    $0xc,%edx
  80046f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800476:	f6 c2 01             	test   $0x1,%dl
  800479:	74 1a                	je     800495 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80047b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047e:	89 02                	mov    %eax,(%edx)
	return 0;
  800480:	b8 00 00 00 00       	mov    $0x0,%eax
  800485:	eb 13                	jmp    80049a <fd_lookup+0x54>
		return -E_INVAL;
  800487:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80048c:	eb 0c                	jmp    80049a <fd_lookup+0x54>
		return -E_INVAL;
  80048e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800493:	eb 05                	jmp    80049a <fd_lookup+0x54>
  800495:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	83 ec 18             	sub    $0x18,%esp
  8004a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a5:	ba 54 20 80 00       	mov    $0x802054,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004aa:	eb 13                	jmp    8004bf <dev_lookup+0x23>
  8004ac:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004af:	39 08                	cmp    %ecx,(%eax)
  8004b1:	75 0c                	jne    8004bf <dev_lookup+0x23>
			*dev = devtab[i];
  8004b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	eb 30                	jmp    8004ef <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8004bf:	8b 02                	mov    (%edx),%eax
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	75 e7                	jne    8004ac <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8004ca:	8b 40 48             	mov    0x48(%eax),%eax
  8004cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d5:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  8004dc:	e8 5e 0d 00 00       	call   80123f <cprintf>
	*dev = 0;
  8004e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ef:	c9                   	leave  
  8004f0:	c3                   	ret    

008004f1 <fd_close>:
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 20             	sub    $0x20,%esp
  8004f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800502:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800506:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80050c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	e8 2f ff ff ff       	call   800446 <fd_lookup>
  800517:	85 c0                	test   %eax,%eax
  800519:	78 05                	js     800520 <fd_close+0x2f>
	    || fd != fd2)
  80051b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80051e:	74 0c                	je     80052c <fd_close+0x3b>
		return (must_exist ? r : 0);
  800520:	84 db                	test   %bl,%bl
  800522:	ba 00 00 00 00       	mov    $0x0,%edx
  800527:	0f 44 c2             	cmove  %edx,%eax
  80052a:	eb 3f                	jmp    80056b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80052c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80052f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800533:	8b 06                	mov    (%esi),%eax
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	e8 5f ff ff ff       	call   80049c <dev_lookup>
  80053d:	89 c3                	mov    %eax,%ebx
  80053f:	85 c0                	test   %eax,%eax
  800541:	78 16                	js     800559 <fd_close+0x68>
		if (dev->dev_close)
  800543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800546:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800549:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80054e:	85 c0                	test   %eax,%eax
  800550:	74 07                	je     800559 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800552:	89 34 24             	mov    %esi,(%esp)
  800555:	ff d0                	call   *%eax
  800557:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  800559:	89 74 24 04          	mov    %esi,0x4(%esp)
  80055d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800564:	e8 a6 fc ff ff       	call   80020f <sys_page_unmap>
	return r;
  800569:	89 d8                	mov    %ebx,%eax
}
  80056b:	83 c4 20             	add    $0x20,%esp
  80056e:	5b                   	pop    %ebx
  80056f:	5e                   	pop    %esi
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <close>:

int
close(int fdnum)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	8b 45 08             	mov    0x8(%ebp),%eax
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	e8 bc fe ff ff       	call   800446 <fd_lookup>
  80058a:	89 c2                	mov    %eax,%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	78 13                	js     8005a3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  800590:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800597:	00 
  800598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80059b:	89 04 24             	mov    %eax,(%esp)
  80059e:	e8 4e ff ff ff       	call   8004f1 <fd_close>
}
  8005a3:	c9                   	leave  
  8005a4:	c3                   	ret    

008005a5 <close_all>:

void
close_all(void)
{
  8005a5:	55                   	push   %ebp
  8005a6:	89 e5                	mov    %esp,%ebp
  8005a8:	53                   	push   %ebx
  8005a9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005b1:	89 1c 24             	mov    %ebx,(%esp)
  8005b4:	e8 b9 ff ff ff       	call   800572 <close>
	for (i = 0; i < MAXFD; i++)
  8005b9:	83 c3 01             	add    $0x1,%ebx
  8005bc:	83 fb 20             	cmp    $0x20,%ebx
  8005bf:	75 f0                	jne    8005b1 <close_all+0xc>
}
  8005c1:	83 c4 14             	add    $0x14,%esp
  8005c4:	5b                   	pop    %ebx
  8005c5:	5d                   	pop    %ebp
  8005c6:	c3                   	ret    

008005c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	57                   	push   %edi
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	e8 64 fe ff ff       	call   800446 <fd_lookup>
  8005e2:	89 c2                	mov    %eax,%edx
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	0f 88 e1 00 00 00    	js     8006cd <dup+0x106>
		return r;
	close(newfdnum);
  8005ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	e8 7b ff ff ff       	call   800572 <close>

	newfd = INDEX2FD(newfdnum);
  8005f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fa:	c1 e3 0c             	shl    $0xc,%ebx
  8005fd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800603:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800606:	89 04 24             	mov    %eax,(%esp)
  800609:	e8 d2 fd ff ff       	call   8003e0 <fd2data>
  80060e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800610:	89 1c 24             	mov    %ebx,(%esp)
  800613:	e8 c8 fd ff ff       	call   8003e0 <fd2data>
  800618:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80061a:	89 f0                	mov    %esi,%eax
  80061c:	c1 e8 16             	shr    $0x16,%eax
  80061f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800626:	a8 01                	test   $0x1,%al
  800628:	74 43                	je     80066d <dup+0xa6>
  80062a:	89 f0                	mov    %esi,%eax
  80062c:	c1 e8 0c             	shr    $0xc,%eax
  80062f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800636:	f6 c2 01             	test   $0x1,%dl
  800639:	74 32                	je     80066d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80063b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800642:	25 07 0e 00 00       	and    $0xe07,%eax
  800647:	89 44 24 10          	mov    %eax,0x10(%esp)
  80064b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80064f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800656:	00 
  800657:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800662:	e8 55 fb ff ff       	call   8001bc <sys_page_map>
  800667:	89 c6                	mov    %eax,%esi
  800669:	85 c0                	test   %eax,%eax
  80066b:	78 3e                	js     8006ab <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80066d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800670:	89 c2                	mov    %eax,%edx
  800672:	c1 ea 0c             	shr    $0xc,%edx
  800675:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80067c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800682:	89 54 24 10          	mov    %edx,0x10(%esp)
  800686:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80068a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800691:	00 
  800692:	89 44 24 04          	mov    %eax,0x4(%esp)
  800696:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80069d:	e8 1a fb ff ff       	call   8001bc <sys_page_map>
  8006a2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8006a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a7:	85 f6                	test   %esi,%esi
  8006a9:	79 22                	jns    8006cd <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8006ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b6:	e8 54 fb ff ff       	call   80020f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c6:	e8 44 fb ff ff       	call   80020f <sys_page_unmap>
	return r;
  8006cb:	89 f0                	mov    %esi,%eax
}
  8006cd:	83 c4 3c             	add    $0x3c,%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	53                   	push   %ebx
  8006d9:	83 ec 24             	sub    $0x24,%esp
  8006dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e6:	89 1c 24             	mov    %ebx,(%esp)
  8006e9:	e8 58 fd ff ff       	call   800446 <fd_lookup>
  8006ee:	89 c2                	mov    %eax,%edx
  8006f0:	85 d2                	test   %edx,%edx
  8006f2:	78 6d                	js     800761 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	e8 94 fd ff ff       	call   80049c <dev_lookup>
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 55                	js     800761 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80070c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070f:	8b 50 08             	mov    0x8(%eax),%edx
  800712:	83 e2 03             	and    $0x3,%edx
  800715:	83 fa 01             	cmp    $0x1,%edx
  800718:	75 23                	jne    80073d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80071a:	a1 08 40 80 00       	mov    0x804008,%eax
  80071f:	8b 40 48             	mov    0x48(%eax),%eax
  800722:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072a:	c7 04 24 19 20 80 00 	movl   $0x802019,(%esp)
  800731:	e8 09 0b 00 00       	call   80123f <cprintf>
		return -E_INVAL;
  800736:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073b:	eb 24                	jmp    800761 <read+0x8c>
	}
	if (!dev->dev_read)
  80073d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800740:	8b 52 08             	mov    0x8(%edx),%edx
  800743:	85 d2                	test   %edx,%edx
  800745:	74 15                	je     80075c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800747:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80074a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80074e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800751:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800755:	89 04 24             	mov    %eax,(%esp)
  800758:	ff d2                	call   *%edx
  80075a:	eb 05                	jmp    800761 <read+0x8c>
		return -E_NOT_SUPP;
  80075c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800761:	83 c4 24             	add    $0x24,%esp
  800764:	5b                   	pop    %ebx
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	57                   	push   %edi
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	83 ec 1c             	sub    $0x1c,%esp
  800770:	8b 7d 08             	mov    0x8(%ebp),%edi
  800773:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800776:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077b:	eb 23                	jmp    8007a0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80077d:	89 f0                	mov    %esi,%eax
  80077f:	29 d8                	sub    %ebx,%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	89 d8                	mov    %ebx,%eax
  800787:	03 45 0c             	add    0xc(%ebp),%eax
  80078a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078e:	89 3c 24             	mov    %edi,(%esp)
  800791:	e8 3f ff ff ff       	call   8006d5 <read>
		if (m < 0)
  800796:	85 c0                	test   %eax,%eax
  800798:	78 10                	js     8007aa <readn+0x43>
			return m;
		if (m == 0)
  80079a:	85 c0                	test   %eax,%eax
  80079c:	74 0a                	je     8007a8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  80079e:	01 c3                	add    %eax,%ebx
  8007a0:	39 f3                	cmp    %esi,%ebx
  8007a2:	72 d9                	jb     80077d <readn+0x16>
  8007a4:	89 d8                	mov    %ebx,%eax
  8007a6:	eb 02                	jmp    8007aa <readn+0x43>
  8007a8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007aa:	83 c4 1c             	add    $0x1c,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 24             	sub    $0x24,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c3:	89 1c 24             	mov    %ebx,(%esp)
  8007c6:	e8 7b fc ff ff       	call   800446 <fd_lookup>
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	78 68                	js     800839 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 04 24             	mov    %eax,(%esp)
  8007e0:	e8 b7 fc ff ff       	call   80049c <dev_lookup>
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	78 50                	js     800839 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f0:	75 23                	jne    800815 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8007f7:	8b 40 48             	mov    0x48(%eax),%eax
  8007fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800802:	c7 04 24 35 20 80 00 	movl   $0x802035,(%esp)
  800809:	e8 31 0a 00 00       	call   80123f <cprintf>
		return -E_INVAL;
  80080e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800813:	eb 24                	jmp    800839 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 0c             	mov    0xc(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 15                	je     800834 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80081f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800822:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800829:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80082d:	89 04 24             	mov    %eax,(%esp)
  800830:	ff d2                	call   *%edx
  800832:	eb 05                	jmp    800839 <write+0x87>
		return -E_NOT_SUPP;
  800834:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800839:	83 c4 24             	add    $0x24,%esp
  80083c:	5b                   	pop    %ebx
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <seek>:

int
seek(int fdnum, off_t offset)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800845:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 ef fb ff ff       	call   800446 <fd_lookup>
  800857:	85 c0                	test   %eax,%eax
  800859:	78 0e                	js     800869 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80085b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	83 ec 24             	sub    $0x24,%esp
  800872:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800875:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087c:	89 1c 24             	mov    %ebx,(%esp)
  80087f:	e8 c2 fb ff ff       	call   800446 <fd_lookup>
  800884:	89 c2                	mov    %eax,%edx
  800886:	85 d2                	test   %edx,%edx
  800888:	78 61                	js     8008eb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800891:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800894:	8b 00                	mov    (%eax),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 fe fb ff ff       	call   80049c <dev_lookup>
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	78 49                	js     8008eb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008a9:	75 23                	jne    8008ce <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008ab:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008b0:	8b 40 48             	mov    0x48(%eax),%eax
  8008b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bb:	c7 04 24 f8 1f 80 00 	movl   $0x801ff8,(%esp)
  8008c2:	e8 78 09 00 00       	call   80123f <cprintf>
		return -E_INVAL;
  8008c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cc:	eb 1d                	jmp    8008eb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8008ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008d1:	8b 52 18             	mov    0x18(%edx),%edx
  8008d4:	85 d2                	test   %edx,%edx
  8008d6:	74 0e                	je     8008e6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008df:	89 04 24             	mov    %eax,(%esp)
  8008e2:	ff d2                	call   *%edx
  8008e4:	eb 05                	jmp    8008eb <ftruncate+0x80>
		return -E_NOT_SUPP;
  8008e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8008eb:	83 c4 24             	add    $0x24,%esp
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	83 ec 24             	sub    $0x24,%esp
  8008f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	89 04 24             	mov    %eax,(%esp)
  800908:	e8 39 fb ff ff       	call   800446 <fd_lookup>
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	85 d2                	test   %edx,%edx
  800911:	78 52                	js     800965 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800913:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091d:	8b 00                	mov    (%eax),%eax
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	e8 75 fb ff ff       	call   80049c <dev_lookup>
  800927:	85 c0                	test   %eax,%eax
  800929:	78 3a                	js     800965 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80092b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800932:	74 2c                	je     800960 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800934:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800937:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80093e:	00 00 00 
	stat->st_isdir = 0;
  800941:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800948:	00 00 00 
	stat->st_dev = dev;
  80094b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800951:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800955:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800958:	89 14 24             	mov    %edx,(%esp)
  80095b:	ff 50 14             	call   *0x14(%eax)
  80095e:	eb 05                	jmp    800965 <fstat+0x74>
		return -E_NOT_SUPP;
  800960:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800965:	83 c4 24             	add    $0x24,%esp
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800973:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80097a:	00 
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	89 04 24             	mov    %eax,(%esp)
  800981:	e8 fb 01 00 00       	call   800b81 <open>
  800986:	89 c3                	mov    %eax,%ebx
  800988:	85 db                	test   %ebx,%ebx
  80098a:	78 1b                	js     8009a7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800993:	89 1c 24             	mov    %ebx,(%esp)
  800996:	e8 56 ff ff ff       	call   8008f1 <fstat>
  80099b:	89 c6                	mov    %eax,%esi
	close(fd);
  80099d:	89 1c 24             	mov    %ebx,(%esp)
  8009a0:	e8 cd fb ff ff       	call   800572 <close>
	return r;
  8009a5:	89 f0                	mov    %esi,%eax
}
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	83 ec 10             	sub    $0x10,%esp
  8009b6:	89 c6                	mov    %eax,%esi
  8009b8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009ba:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009c1:	75 11                	jne    8009d4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009ca:	e8 c0 12 00 00       	call   801c8f <ipc_find_env>
  8009cf:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009d4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8009db:	00 
  8009dc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8009e3:	00 
  8009e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e8:	a1 00 40 80 00       	mov    0x804000,%eax
  8009ed:	89 04 24             	mov    %eax,(%esp)
  8009f0:	e8 33 12 00 00       	call   801c28 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8009fc:	00 
  8009fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a08:	e8 b3 11 00 00       	call   801bc0 <ipc_recv>
}
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a20:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a28:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 02 00 00 00       	mov    $0x2,%eax
  800a37:	e8 72 ff ff ff       	call   8009ae <fsipc>
}
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <devfile_flush>:
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a54:	b8 06 00 00 00       	mov    $0x6,%eax
  800a59:	e8 50 ff ff ff       	call   8009ae <fsipc>
}
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <devfile_stat>:
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	83 ec 14             	sub    $0x14,%esp
  800a67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a70:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a7f:	e8 2a ff ff ff       	call   8009ae <fsipc>
  800a84:	89 c2                	mov    %eax,%edx
  800a86:	85 d2                	test   %edx,%edx
  800a88:	78 2b                	js     800ab5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a8a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800a91:	00 
  800a92:	89 1c 24             	mov    %ebx,(%esp)
  800a95:	e8 cd 0d 00 00       	call   801867 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a9a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a9f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aa5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aaa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab5:	83 c4 14             	add    $0x14,%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <devfile_write>:
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  800ac1:	c7 44 24 08 64 20 80 	movl   $0x802064,0x8(%esp)
  800ac8:	00 
  800ac9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800ad0:	00 
  800ad1:	c7 04 24 82 20 80 00 	movl   $0x802082,(%esp)
  800ad8:	e8 69 06 00 00       	call   801146 <_panic>

00800add <devfile_read>:
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	83 ec 10             	sub    $0x10,%esp
  800ae5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	8b 40 0c             	mov    0xc(%eax),%eax
  800aee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800af3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 03 00 00 00       	mov    $0x3,%eax
  800b03:	e8 a6 fe ff ff       	call   8009ae <fsipc>
  800b08:	89 c3                	mov    %eax,%ebx
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	78 6a                	js     800b78 <devfile_read+0x9b>
	assert(r <= n);
  800b0e:	39 c6                	cmp    %eax,%esi
  800b10:	73 24                	jae    800b36 <devfile_read+0x59>
  800b12:	c7 44 24 0c 8d 20 80 	movl   $0x80208d,0xc(%esp)
  800b19:	00 
  800b1a:	c7 44 24 08 94 20 80 	movl   $0x802094,0x8(%esp)
  800b21:	00 
  800b22:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b29:	00 
  800b2a:	c7 04 24 82 20 80 00 	movl   $0x802082,(%esp)
  800b31:	e8 10 06 00 00       	call   801146 <_panic>
	assert(r <= PGSIZE);
  800b36:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b3b:	7e 24                	jle    800b61 <devfile_read+0x84>
  800b3d:	c7 44 24 0c a9 20 80 	movl   $0x8020a9,0xc(%esp)
  800b44:	00 
  800b45:	c7 44 24 08 94 20 80 	movl   $0x802094,0x8(%esp)
  800b4c:	00 
  800b4d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b54:	00 
  800b55:	c7 04 24 82 20 80 00 	movl   $0x802082,(%esp)
  800b5c:	e8 e5 05 00 00       	call   801146 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b65:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b6c:	00 
  800b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b70:	89 04 24             	mov    %eax,(%esp)
  800b73:	e8 8c 0e 00 00       	call   801a04 <memmove>
}
  800b78:	89 d8                	mov    %ebx,%eax
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <open>:
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	83 ec 24             	sub    $0x24,%esp
  800b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800b8b:	89 1c 24             	mov    %ebx,(%esp)
  800b8e:	e8 9d 0c 00 00       	call   801830 <strlen>
  800b93:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b98:	7f 60                	jg     800bfa <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  800b9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b9d:	89 04 24             	mov    %eax,(%esp)
  800ba0:	e8 52 f8 ff ff       	call   8003f7 <fd_alloc>
  800ba5:	89 c2                	mov    %eax,%edx
  800ba7:	85 d2                	test   %edx,%edx
  800ba9:	78 54                	js     800bff <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  800bab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800baf:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bb6:	e8 ac 0c 00 00       	call   801867 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bcb:	e8 de fd ff ff       	call   8009ae <fsipc>
  800bd0:	89 c3                	mov    %eax,%ebx
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	79 17                	jns    800bed <open+0x6c>
		fd_close(fd, 0);
  800bd6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800bdd:	00 
  800bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800be1:	89 04 24             	mov    %eax,(%esp)
  800be4:	e8 08 f9 ff ff       	call   8004f1 <fd_close>
		return r;
  800be9:	89 d8                	mov    %ebx,%eax
  800beb:	eb 12                	jmp    800bff <open+0x7e>
	return fd2num(fd);
  800bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf0:	89 04 24             	mov    %eax,(%esp)
  800bf3:	e8 d8 f7 ff ff       	call   8003d0 <fd2num>
  800bf8:	eb 05                	jmp    800bff <open+0x7e>
		return -E_BAD_PATH;
  800bfa:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  800bff:	83 c4 24             	add    $0x24,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 08 00 00 00       	mov    $0x8,%eax
  800c15:	e8 94 fd ff ff       	call   8009ae <fsipc>
}
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 10             	sub    $0x10,%esp
  800c24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	89 04 24             	mov    %eax,(%esp)
  800c2d:	e8 ae f7 ff ff       	call   8003e0 <fd2data>
  800c32:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c34:	c7 44 24 04 b5 20 80 	movl   $0x8020b5,0x4(%esp)
  800c3b:	00 
  800c3c:	89 1c 24             	mov    %ebx,(%esp)
  800c3f:	e8 23 0c 00 00       	call   801867 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c44:	8b 46 04             	mov    0x4(%esi),%eax
  800c47:	2b 06                	sub    (%esi),%eax
  800c49:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c4f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c56:	00 00 00 
	stat->st_dev = &devpipe;
  800c59:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c60:	30 80 00 
	return 0;
}
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	53                   	push   %ebx
  800c73:	83 ec 14             	sub    $0x14,%esp
  800c76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c84:	e8 86 f5 ff ff       	call   80020f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c89:	89 1c 24             	mov    %ebx,(%esp)
  800c8c:	e8 4f f7 ff ff       	call   8003e0 <fd2data>
  800c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c9c:	e8 6e f5 ff ff       	call   80020f <sys_page_unmap>
}
  800ca1:	83 c4 14             	add    $0x14,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <_pipeisclosed>:
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 2c             	sub    $0x2c,%esp
  800cb0:	89 c6                	mov    %eax,%esi
  800cb2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  800cb5:	a1 08 40 80 00       	mov    0x804008,%eax
  800cba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cbd:	89 34 24             	mov    %esi,(%esp)
  800cc0:	e8 02 10 00 00       	call   801cc7 <pageref>
  800cc5:	89 c7                	mov    %eax,%edi
  800cc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cca:	89 04 24             	mov    %eax,(%esp)
  800ccd:	e8 f5 0f 00 00       	call   801cc7 <pageref>
  800cd2:	39 c7                	cmp    %eax,%edi
  800cd4:	0f 94 c2             	sete   %dl
  800cd7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800cda:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  800ce0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800ce3:	39 fb                	cmp    %edi,%ebx
  800ce5:	74 21                	je     800d08 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  800ce7:	84 d2                	test   %dl,%dl
  800ce9:	74 ca                	je     800cb5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800ceb:	8b 51 58             	mov    0x58(%ecx),%edx
  800cee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf2:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cf6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cfa:	c7 04 24 bc 20 80 00 	movl   $0x8020bc,(%esp)
  800d01:	e8 39 05 00 00       	call   80123f <cprintf>
  800d06:	eb ad                	jmp    800cb5 <_pipeisclosed+0xe>
}
  800d08:	83 c4 2c             	add    $0x2c,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <devpipe_write>:
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 1c             	sub    $0x1c,%esp
  800d19:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d1c:	89 34 24             	mov    %esi,(%esp)
  800d1f:	e8 bc f6 ff ff       	call   8003e0 <fd2data>
  800d24:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d26:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2b:	eb 45                	jmp    800d72 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  800d2d:	89 da                	mov    %ebx,%edx
  800d2f:	89 f0                	mov    %esi,%eax
  800d31:	e8 71 ff ff ff       	call   800ca7 <_pipeisclosed>
  800d36:	85 c0                	test   %eax,%eax
  800d38:	75 41                	jne    800d7b <devpipe_write+0x6b>
			sys_yield();
  800d3a:	e8 0a f4 ff ff       	call   800149 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d3f:	8b 43 04             	mov    0x4(%ebx),%eax
  800d42:	8b 0b                	mov    (%ebx),%ecx
  800d44:	8d 51 20             	lea    0x20(%ecx),%edx
  800d47:	39 d0                	cmp    %edx,%eax
  800d49:	73 e2                	jae    800d2d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d52:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d55:	99                   	cltd   
  800d56:	c1 ea 1b             	shr    $0x1b,%edx
  800d59:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d5c:	83 e1 1f             	and    $0x1f,%ecx
  800d5f:	29 d1                	sub    %edx,%ecx
  800d61:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d65:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800d69:	83 c0 01             	add    $0x1,%eax
  800d6c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d6f:	83 c7 01             	add    $0x1,%edi
  800d72:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d75:	75 c8                	jne    800d3f <devpipe_write+0x2f>
	return i;
  800d77:	89 f8                	mov    %edi,%eax
  800d79:	eb 05                	jmp    800d80 <devpipe_write+0x70>
				return 0;
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d80:	83 c4 1c             	add    $0x1c,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <devpipe_read>:
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 1c             	sub    $0x1c,%esp
  800d91:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d94:	89 3c 24             	mov    %edi,(%esp)
  800d97:	e8 44 f6 ff ff       	call   8003e0 <fd2data>
  800d9c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d9e:	be 00 00 00 00       	mov    $0x0,%esi
  800da3:	eb 3d                	jmp    800de2 <devpipe_read+0x5a>
			if (i > 0)
  800da5:	85 f6                	test   %esi,%esi
  800da7:	74 04                	je     800dad <devpipe_read+0x25>
				return i;
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	eb 43                	jmp    800df0 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  800dad:	89 da                	mov    %ebx,%edx
  800daf:	89 f8                	mov    %edi,%eax
  800db1:	e8 f1 fe ff ff       	call   800ca7 <_pipeisclosed>
  800db6:	85 c0                	test   %eax,%eax
  800db8:	75 31                	jne    800deb <devpipe_read+0x63>
			sys_yield();
  800dba:	e8 8a f3 ff ff       	call   800149 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800dbf:	8b 03                	mov    (%ebx),%eax
  800dc1:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dc4:	74 df                	je     800da5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dc6:	99                   	cltd   
  800dc7:	c1 ea 1b             	shr    $0x1b,%edx
  800dca:	01 d0                	add    %edx,%eax
  800dcc:	83 e0 1f             	and    $0x1f,%eax
  800dcf:	29 d0                	sub    %edx,%eax
  800dd1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800ddc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800ddf:	83 c6 01             	add    $0x1,%esi
  800de2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800de5:	75 d8                	jne    800dbf <devpipe_read+0x37>
	return i;
  800de7:	89 f0                	mov    %esi,%eax
  800de9:	eb 05                	jmp    800df0 <devpipe_read+0x68>
				return 0;
  800deb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <pipe>:
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e03:	89 04 24             	mov    %eax,(%esp)
  800e06:	e8 ec f5 ff ff       	call   8003f7 <fd_alloc>
  800e0b:	89 c2                	mov    %eax,%edx
  800e0d:	85 d2                	test   %edx,%edx
  800e0f:	0f 88 4d 01 00 00    	js     800f62 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e15:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e1c:	00 
  800e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e2b:	e8 38 f3 ff ff       	call   800168 <sys_page_alloc>
  800e30:	89 c2                	mov    %eax,%edx
  800e32:	85 d2                	test   %edx,%edx
  800e34:	0f 88 28 01 00 00    	js     800f62 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  800e3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e3d:	89 04 24             	mov    %eax,(%esp)
  800e40:	e8 b2 f5 ff ff       	call   8003f7 <fd_alloc>
  800e45:	89 c3                	mov    %eax,%ebx
  800e47:	85 c0                	test   %eax,%eax
  800e49:	0f 88 fe 00 00 00    	js     800f4d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e4f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e56:	00 
  800e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e65:	e8 fe f2 ff ff       	call   800168 <sys_page_alloc>
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	0f 88 d9 00 00 00    	js     800f4d <pipe+0x155>
	va = fd2data(fd0);
  800e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e77:	89 04 24             	mov    %eax,(%esp)
  800e7a:	e8 61 f5 ff ff       	call   8003e0 <fd2data>
  800e7f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e81:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e88:	00 
  800e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e94:	e8 cf f2 ff ff       	call   800168 <sys_page_alloc>
  800e99:	89 c3                	mov    %eax,%ebx
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	0f 88 97 00 00 00    	js     800f3a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea6:	89 04 24             	mov    %eax,(%esp)
  800ea9:	e8 32 f5 ff ff       	call   8003e0 <fd2data>
  800eae:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800eb5:	00 
  800eb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ec1:	00 
  800ec2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ec6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ecd:	e8 ea f2 ff ff       	call   8001bc <sys_page_map>
  800ed2:	89 c3                	mov    %eax,%ebx
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	78 52                	js     800f2a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  800ed8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800eed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800efb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f05:	89 04 24             	mov    %eax,(%esp)
  800f08:	e8 c3 f4 ff ff       	call   8003d0 <fd2num>
  800f0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f10:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f15:	89 04 24             	mov    %eax,(%esp)
  800f18:	e8 b3 f4 ff ff       	call   8003d0 <fd2num>
  800f1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f20:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
  800f28:	eb 38                	jmp    800f62 <pipe+0x16a>
	sys_page_unmap(0, va);
  800f2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f35:	e8 d5 f2 ff ff       	call   80020f <sys_page_unmap>
	sys_page_unmap(0, fd1);
  800f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f48:	e8 c2 f2 ff ff       	call   80020f <sys_page_unmap>
	sys_page_unmap(0, fd0);
  800f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5b:	e8 af f2 ff ff       	call   80020f <sys_page_unmap>
  800f60:	89 d8                	mov    %ebx,%eax
}
  800f62:	83 c4 30             	add    $0x30,%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <pipeisclosed>:
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	89 04 24             	mov    %eax,(%esp)
  800f7c:	e8 c5 f4 ff ff       	call   800446 <fd_lookup>
  800f81:	89 c2                	mov    %eax,%edx
  800f83:	85 d2                	test   %edx,%edx
  800f85:	78 15                	js     800f9c <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  800f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8a:	89 04 24             	mov    %eax,(%esp)
  800f8d:	e8 4e f4 ff ff       	call   8003e0 <fd2data>
	return _pipeisclosed(fd, p);
  800f92:	89 c2                	mov    %eax,%edx
  800f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f97:	e8 0b fd ff ff       	call   800ca7 <_pipeisclosed>
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fb0:	c7 44 24 04 d4 20 80 	movl   $0x8020d4,0x4(%esp)
  800fb7:	00 
  800fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbb:	89 04 24             	mov    %eax,(%esp)
  800fbe:	e8 a4 08 00 00       	call   801867 <strcpy>
	return 0;
}
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <devcons_write>:
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800fdb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800fe1:	eb 31                	jmp    801014 <devcons_write+0x4a>
		m = n - tot;
  800fe3:	8b 75 10             	mov    0x10(%ebp),%esi
  800fe6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800fe8:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  800feb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ff0:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ff3:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ff7:	03 45 0c             	add    0xc(%ebp),%eax
  800ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffe:	89 3c 24             	mov    %edi,(%esp)
  801001:	e8 fe 09 00 00       	call   801a04 <memmove>
		sys_cputs(buf, m);
  801006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100a:	89 3c 24             	mov    %edi,(%esp)
  80100d:	e8 89 f0 ff ff       	call   80009b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801012:	01 f3                	add    %esi,%ebx
  801014:	89 d8                	mov    %ebx,%eax
  801016:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801019:	72 c8                	jb     800fe3 <devcons_write+0x19>
}
  80101b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <devcons_read>:
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80102c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801031:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801035:	75 07                	jne    80103e <devcons_read+0x18>
  801037:	eb 2a                	jmp    801063 <devcons_read+0x3d>
		sys_yield();
  801039:	e8 0b f1 ff ff       	call   800149 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80103e:	66 90                	xchg   %ax,%ax
  801040:	e8 74 f0 ff ff       	call   8000b9 <sys_cgetc>
  801045:	85 c0                	test   %eax,%eax
  801047:	74 f0                	je     801039 <devcons_read+0x13>
	if (c < 0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 16                	js     801063 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80104d:	83 f8 04             	cmp    $0x4,%eax
  801050:	74 0c                	je     80105e <devcons_read+0x38>
	*(char*)vbuf = c;
  801052:	8b 55 0c             	mov    0xc(%ebp),%edx
  801055:	88 02                	mov    %al,(%edx)
	return 1;
  801057:	b8 01 00 00 00       	mov    $0x1,%eax
  80105c:	eb 05                	jmp    801063 <devcons_read+0x3d>
		return 0;
  80105e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <cputchar>:
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80106b:	8b 45 08             	mov    0x8(%ebp),%eax
  80106e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801071:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801078:	00 
  801079:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80107c:	89 04 24             	mov    %eax,(%esp)
  80107f:	e8 17 f0 ff ff       	call   80009b <sys_cputs>
}
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <getchar>:
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80108c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801093:	00 
  801094:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a2:	e8 2e f6 ff ff       	call   8006d5 <read>
	if (r < 0)
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 0f                	js     8010ba <getchar+0x34>
	if (r < 1)
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	7e 06                	jle    8010b5 <getchar+0x2f>
	return c;
  8010af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010b3:	eb 05                	jmp    8010ba <getchar+0x34>
		return -E_EOF;
  8010b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <iscons>:
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cc:	89 04 24             	mov    %eax,(%esp)
  8010cf:	e8 72 f3 ff ff       	call   800446 <fd_lookup>
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 11                	js     8010e9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8010d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010db:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010e1:	39 10                	cmp    %edx,(%eax)
  8010e3:	0f 94 c0             	sete   %al
  8010e6:	0f b6 c0             	movzbl %al,%eax
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <opencons>:
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8010f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f4:	89 04 24             	mov    %eax,(%esp)
  8010f7:	e8 fb f2 ff ff       	call   8003f7 <fd_alloc>
		return r;
  8010fc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 40                	js     801142 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801102:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801109:	00 
  80110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801111:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801118:	e8 4b f0 ff ff       	call   800168 <sys_page_alloc>
		return r;
  80111d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 1f                	js     801142 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801123:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80112e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801131:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801138:	89 04 24             	mov    %eax,(%esp)
  80113b:	e8 90 f2 ff ff       	call   8003d0 <fd2num>
  801140:	89 c2                	mov    %eax,%edx
}
  801142:	89 d0                	mov    %edx,%eax
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80114e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801151:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801157:	e8 ce ef ff ff       	call   80012a <sys_getenvid>
  80115c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801163:	8b 55 08             	mov    0x8(%ebp),%edx
  801166:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80116a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80116e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801172:	c7 04 24 e0 20 80 00 	movl   $0x8020e0,(%esp)
  801179:	e8 c1 00 00 00       	call   80123f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80117e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801182:	8b 45 10             	mov    0x10(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 51 00 00 00       	call   8011de <vcprintf>
	cprintf("\n");
  80118d:	c7 04 24 cd 20 80 00 	movl   $0x8020cd,(%esp)
  801194:	e8 a6 00 00 00       	call   80123f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801199:	cc                   	int3   
  80119a:	eb fd                	jmp    801199 <_panic+0x53>

0080119c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 14             	sub    $0x14,%esp
  8011a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011a6:	8b 13                	mov    (%ebx),%edx
  8011a8:	8d 42 01             	lea    0x1(%edx),%eax
  8011ab:	89 03                	mov    %eax,(%ebx)
  8011ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8011b4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011b9:	75 19                	jne    8011d4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8011bb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011c2:	00 
  8011c3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011c6:	89 04 24             	mov    %eax,(%esp)
  8011c9:	e8 cd ee ff ff       	call   80009b <sys_cputs>
		b->idx = 0;
  8011ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8011d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8011d8:	83 c4 14             	add    $0x14,%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8011e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8011ee:	00 00 00 
	b.cnt = 0;
  8011f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8011f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8011fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801202:	8b 45 08             	mov    0x8(%ebp),%eax
  801205:	89 44 24 08          	mov    %eax,0x8(%esp)
  801209:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80120f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801213:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  80121a:	e8 af 01 00 00       	call   8013ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80121f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801225:	89 44 24 04          	mov    %eax,0x4(%esp)
  801229:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80122f:	89 04 24             	mov    %eax,(%esp)
  801232:	e8 64 ee ff ff       	call   80009b <sys_cputs>

	return b.cnt;
}
  801237:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801245:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 87 ff ff ff       	call   8011de <vcprintf>
	va_end(ap);

	return cnt;
}
  801257:	c9                   	leave  
  801258:	c3                   	ret    
  801259:	66 90                	xchg   %ax,%ax
  80125b:	66 90                	xchg   %ax,%ax
  80125d:	66 90                	xchg   %ax,%ax
  80125f:	90                   	nop

00801260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
  801266:	83 ec 3c             	sub    $0x3c,%esp
  801269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126c:	89 d7                	mov    %edx,%edi
  80126e:	8b 45 08             	mov    0x8(%ebp),%eax
  801271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801274:	8b 45 0c             	mov    0xc(%ebp),%eax
  801277:	89 c3                	mov    %eax,%ebx
  801279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80127c:	8b 45 10             	mov    0x10(%ebp),%eax
  80127f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801282:	b9 00 00 00 00       	mov    $0x0,%ecx
  801287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80128a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80128d:	39 d9                	cmp    %ebx,%ecx
  80128f:	72 05                	jb     801296 <printnum+0x36>
  801291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801294:	77 69                	ja     8012ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801296:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801299:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80129d:	83 ee 01             	sub    $0x1,%esi
  8012a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012b0:	89 c3                	mov    %eax,%ebx
  8012b2:	89 d6                	mov    %edx,%esi
  8012b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c5:	89 04 24             	mov    %eax,(%esp)
  8012c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	e8 3c 0a 00 00       	call   801d10 <__udivdi3>
  8012d4:	89 d9                	mov    %ebx,%ecx
  8012d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012de:	89 04 24             	mov    %eax,(%esp)
  8012e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012e5:	89 fa                	mov    %edi,%edx
  8012e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ea:	e8 71 ff ff ff       	call   801260 <printnum>
  8012ef:	eb 1b                	jmp    80130c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8012f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	ff d3                	call   *%ebx
  8012fd:	eb 03                	jmp    801302 <printnum+0xa2>
  8012ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  801302:	83 ee 01             	sub    $0x1,%esi
  801305:	85 f6                	test   %esi,%esi
  801307:	7f e8                	jg     8012f1 <printnum+0x91>
  801309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80130c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801314:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801317:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80131a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80132b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132f:	e8 0c 0b 00 00       	call   801e40 <__umoddi3>
  801334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801338:	0f be 80 03 21 80 00 	movsbl 0x802103(%eax),%eax
  80133f:	89 04 24             	mov    %eax,(%esp)
  801342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801345:	ff d0                	call   *%eax
}
  801347:	83 c4 3c             	add    $0x3c,%esp
  80134a:	5b                   	pop    %ebx
  80134b:	5e                   	pop    %esi
  80134c:	5f                   	pop    %edi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    

0080134f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801352:	83 fa 01             	cmp    $0x1,%edx
  801355:	7e 0e                	jle    801365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801357:	8b 10                	mov    (%eax),%edx
  801359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80135c:	89 08                	mov    %ecx,(%eax)
  80135e:	8b 02                	mov    (%edx),%eax
  801360:	8b 52 04             	mov    0x4(%edx),%edx
  801363:	eb 22                	jmp    801387 <getuint+0x38>
	else if (lflag)
  801365:	85 d2                	test   %edx,%edx
  801367:	74 10                	je     801379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801369:	8b 10                	mov    (%eax),%edx
  80136b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80136e:	89 08                	mov    %ecx,(%eax)
  801370:	8b 02                	mov    (%edx),%eax
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
  801377:	eb 0e                	jmp    801387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801379:	8b 10                	mov    (%eax),%edx
  80137b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80137e:	89 08                	mov    %ecx,(%eax)
  801380:	8b 02                	mov    (%edx),%eax
  801382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    

00801389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80138f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801393:	8b 10                	mov    (%eax),%edx
  801395:	3b 50 04             	cmp    0x4(%eax),%edx
  801398:	73 0a                	jae    8013a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80139a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80139d:	89 08                	mov    %ecx,(%eax)
  80139f:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a2:	88 02                	mov    %al,(%edx)
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <printfmt>:
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8013ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	89 04 24             	mov    %eax,(%esp)
  8013c7:	e8 02 00 00 00       	call   8013ce <vprintfmt>
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <vprintfmt>:
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 3c             	sub    $0x3c,%esp
  8013d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013dd:	eb 1f                	jmp    8013fe <vprintfmt+0x30>
			if (ch == '\0'){
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	75 0f                	jne    8013f2 <vprintfmt+0x24>
				color = 0x0100;
  8013e3:	c7 05 04 40 80 00 00 	movl   $0x100,0x804004
  8013ea:	01 00 00 
  8013ed:	e9 b3 03 00 00       	jmp    8017a5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  8013f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8013fc:	89 f3                	mov    %esi,%ebx
  8013fe:	8d 73 01             	lea    0x1(%ebx),%esi
  801401:	0f b6 03             	movzbl (%ebx),%eax
  801404:	83 f8 25             	cmp    $0x25,%eax
  801407:	75 d6                	jne    8013df <vprintfmt+0x11>
  801409:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80140d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801414:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80141b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801422:	ba 00 00 00 00       	mov    $0x0,%edx
  801427:	eb 1d                	jmp    801446 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801429:	89 de                	mov    %ebx,%esi
			padc = '-';
  80142b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80142f:	eb 15                	jmp    801446 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801431:	89 de                	mov    %ebx,%esi
			padc = '0';
  801433:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801437:	eb 0d                	jmp    801446 <vprintfmt+0x78>
				width = precision, precision = -1;
  801439:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80143c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80143f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801446:	8d 5e 01             	lea    0x1(%esi),%ebx
  801449:	0f b6 0e             	movzbl (%esi),%ecx
  80144c:	0f b6 c1             	movzbl %cl,%eax
  80144f:	83 e9 23             	sub    $0x23,%ecx
  801452:	80 f9 55             	cmp    $0x55,%cl
  801455:	0f 87 2a 03 00 00    	ja     801785 <vprintfmt+0x3b7>
  80145b:	0f b6 c9             	movzbl %cl,%ecx
  80145e:	ff 24 8d 40 22 80 00 	jmp    *0x802240(,%ecx,4)
  801465:	89 de                	mov    %ebx,%esi
  801467:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80146c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80146f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801473:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801476:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801479:	83 fb 09             	cmp    $0x9,%ebx
  80147c:	77 36                	ja     8014b4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80147e:	83 c6 01             	add    $0x1,%esi
			}
  801481:	eb e9                	jmp    80146c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  801483:	8b 45 14             	mov    0x14(%ebp),%eax
  801486:	8d 48 04             	lea    0x4(%eax),%ecx
  801489:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80148c:	8b 00                	mov    (%eax),%eax
  80148e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801491:	89 de                	mov    %ebx,%esi
			goto process_precision;
  801493:	eb 22                	jmp    8014b7 <vprintfmt+0xe9>
  801495:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801498:	85 c9                	test   %ecx,%ecx
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
  80149f:	0f 49 c1             	cmovns %ecx,%eax
  8014a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014a5:	89 de                	mov    %ebx,%esi
  8014a7:	eb 9d                	jmp    801446 <vprintfmt+0x78>
  8014a9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8014ab:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8014b2:	eb 92                	jmp    801446 <vprintfmt+0x78>
  8014b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8014b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014bb:	79 89                	jns    801446 <vprintfmt+0x78>
  8014bd:	e9 77 ff ff ff       	jmp    801439 <vprintfmt+0x6b>
			lflag++;
  8014c2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8014c5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8014c7:	e9 7a ff ff ff       	jmp    801446 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8014cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cf:	8d 50 04             	lea    0x4(%eax),%edx
  8014d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014d9:	8b 00                	mov    (%eax),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	ff 55 08             	call   *0x8(%ebp)
			break;
  8014e1:	e9 18 ff ff ff       	jmp    8013fe <vprintfmt+0x30>
			err = va_arg(ap, int);
  8014e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e9:	8d 50 04             	lea    0x4(%eax),%edx
  8014ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ef:	8b 00                	mov    (%eax),%eax
  8014f1:	99                   	cltd   
  8014f2:	31 d0                	xor    %edx,%eax
  8014f4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014f6:	83 f8 0f             	cmp    $0xf,%eax
  8014f9:	7f 0b                	jg     801506 <vprintfmt+0x138>
  8014fb:	8b 14 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%edx
  801502:	85 d2                	test   %edx,%edx
  801504:	75 20                	jne    801526 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  801506:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150a:	c7 44 24 08 1b 21 80 	movl   $0x80211b,0x8(%esp)
  801511:	00 
  801512:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801516:	8b 45 08             	mov    0x8(%ebp),%eax
  801519:	89 04 24             	mov    %eax,(%esp)
  80151c:	e8 85 fe ff ff       	call   8013a6 <printfmt>
  801521:	e9 d8 fe ff ff       	jmp    8013fe <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  801526:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80152a:	c7 44 24 08 a6 20 80 	movl   $0x8020a6,0x8(%esp)
  801531:	00 
  801532:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	89 04 24             	mov    %eax,(%esp)
  80153c:	e8 65 fe ff ff       	call   8013a6 <printfmt>
  801541:	e9 b8 fe ff ff       	jmp    8013fe <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  801546:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801549:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80154c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80154f:	8b 45 14             	mov    0x14(%ebp),%eax
  801552:	8d 50 04             	lea    0x4(%eax),%edx
  801555:	89 55 14             	mov    %edx,0x14(%ebp)
  801558:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80155a:	85 f6                	test   %esi,%esi
  80155c:	b8 14 21 80 00       	mov    $0x802114,%eax
  801561:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801564:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801568:	0f 84 97 00 00 00    	je     801605 <vprintfmt+0x237>
  80156e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801572:	0f 8e 9b 00 00 00    	jle    801613 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  801578:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80157c:	89 34 24             	mov    %esi,(%esp)
  80157f:	e8 c4 02 00 00       	call   801848 <strnlen>
  801584:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801587:	29 c2                	sub    %eax,%edx
  801589:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  80158c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801590:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801593:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801596:	8b 75 08             	mov    0x8(%ebp),%esi
  801599:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80159c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80159e:	eb 0f                	jmp    8015af <vprintfmt+0x1e1>
					putch(padc, putdat);
  8015a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8015ac:	83 eb 01             	sub    $0x1,%ebx
  8015af:	85 db                	test   %ebx,%ebx
  8015b1:	7f ed                	jg     8015a0 <vprintfmt+0x1d2>
  8015b3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015b6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015b9:	85 d2                	test   %edx,%edx
  8015bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c0:	0f 49 c2             	cmovns %edx,%eax
  8015c3:	29 c2                	sub    %eax,%edx
  8015c5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015c8:	89 d7                	mov    %edx,%edi
  8015ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015cd:	eb 50                	jmp    80161f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8015cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015d3:	74 1e                	je     8015f3 <vprintfmt+0x225>
  8015d5:	0f be d2             	movsbl %dl,%edx
  8015d8:	83 ea 20             	sub    $0x20,%edx
  8015db:	83 fa 5e             	cmp    $0x5e,%edx
  8015de:	76 13                	jbe    8015f3 <vprintfmt+0x225>
					putch('?', putdat);
  8015e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015ee:	ff 55 08             	call   *0x8(%ebp)
  8015f1:	eb 0d                	jmp    801600 <vprintfmt+0x232>
					putch(ch, putdat);
  8015f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015fa:	89 04 24             	mov    %eax,(%esp)
  8015fd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801600:	83 ef 01             	sub    $0x1,%edi
  801603:	eb 1a                	jmp    80161f <vprintfmt+0x251>
  801605:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801608:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80160b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80160e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801611:	eb 0c                	jmp    80161f <vprintfmt+0x251>
  801613:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801616:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801619:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80161c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80161f:	83 c6 01             	add    $0x1,%esi
  801622:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801626:	0f be c2             	movsbl %dl,%eax
  801629:	85 c0                	test   %eax,%eax
  80162b:	74 27                	je     801654 <vprintfmt+0x286>
  80162d:	85 db                	test   %ebx,%ebx
  80162f:	78 9e                	js     8015cf <vprintfmt+0x201>
  801631:	83 eb 01             	sub    $0x1,%ebx
  801634:	79 99                	jns    8015cf <vprintfmt+0x201>
  801636:	89 f8                	mov    %edi,%eax
  801638:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80163b:	8b 75 08             	mov    0x8(%ebp),%esi
  80163e:	89 c3                	mov    %eax,%ebx
  801640:	eb 1a                	jmp    80165c <vprintfmt+0x28e>
				putch(' ', putdat);
  801642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801646:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80164d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80164f:	83 eb 01             	sub    $0x1,%ebx
  801652:	eb 08                	jmp    80165c <vprintfmt+0x28e>
  801654:	89 fb                	mov    %edi,%ebx
  801656:	8b 75 08             	mov    0x8(%ebp),%esi
  801659:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80165c:	85 db                	test   %ebx,%ebx
  80165e:	7f e2                	jg     801642 <vprintfmt+0x274>
  801660:	89 75 08             	mov    %esi,0x8(%ebp)
  801663:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801666:	e9 93 fd ff ff       	jmp    8013fe <vprintfmt+0x30>
	if (lflag >= 2)
  80166b:	83 fa 01             	cmp    $0x1,%edx
  80166e:	7e 16                	jle    801686 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  801670:	8b 45 14             	mov    0x14(%ebp),%eax
  801673:	8d 50 08             	lea    0x8(%eax),%edx
  801676:	89 55 14             	mov    %edx,0x14(%ebp)
  801679:	8b 50 04             	mov    0x4(%eax),%edx
  80167c:	8b 00                	mov    (%eax),%eax
  80167e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801681:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801684:	eb 32                	jmp    8016b8 <vprintfmt+0x2ea>
	else if (lflag)
  801686:	85 d2                	test   %edx,%edx
  801688:	74 18                	je     8016a2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  80168a:	8b 45 14             	mov    0x14(%ebp),%eax
  80168d:	8d 50 04             	lea    0x4(%eax),%edx
  801690:	89 55 14             	mov    %edx,0x14(%ebp)
  801693:	8b 30                	mov    (%eax),%esi
  801695:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801698:	89 f0                	mov    %esi,%eax
  80169a:	c1 f8 1f             	sar    $0x1f,%eax
  80169d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016a0:	eb 16                	jmp    8016b8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8016a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a5:	8d 50 04             	lea    0x4(%eax),%edx
  8016a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ab:	8b 30                	mov    (%eax),%esi
  8016ad:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016b0:	89 f0                	mov    %esi,%eax
  8016b2:	c1 f8 1f             	sar    $0x1f,%eax
  8016b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8016b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8016be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8016c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016c7:	0f 89 80 00 00 00    	jns    80174d <vprintfmt+0x37f>
				putch('-', putdat);
  8016cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016d1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016d8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8016db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016e1:	f7 d8                	neg    %eax
  8016e3:	83 d2 00             	adc    $0x0,%edx
  8016e6:	f7 da                	neg    %edx
			base = 10;
  8016e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8016ed:	eb 5e                	jmp    80174d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8016ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8016f2:	e8 58 fc ff ff       	call   80134f <getuint>
			base = 10;
  8016f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8016fc:	eb 4f                	jmp    80174d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  8016fe:	8d 45 14             	lea    0x14(%ebp),%eax
  801701:	e8 49 fc ff ff       	call   80134f <getuint>
            base = 8;
  801706:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80170b:	eb 40                	jmp    80174d <vprintfmt+0x37f>
			putch('0', putdat);
  80170d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801711:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801718:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80171b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80171f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801726:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  801729:	8b 45 14             	mov    0x14(%ebp),%eax
  80172c:	8d 50 04             	lea    0x4(%eax),%edx
  80172f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801732:	8b 00                	mov    (%eax),%eax
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  801739:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80173e:	eb 0d                	jmp    80174d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  801740:	8d 45 14             	lea    0x14(%ebp),%eax
  801743:	e8 07 fc ff ff       	call   80134f <getuint>
			base = 16;
  801748:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80174d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801751:	89 74 24 10          	mov    %esi,0x10(%esp)
  801755:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801758:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80175c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801760:	89 04 24             	mov    %eax,(%esp)
  801763:	89 54 24 04          	mov    %edx,0x4(%esp)
  801767:	89 fa                	mov    %edi,%edx
  801769:	8b 45 08             	mov    0x8(%ebp),%eax
  80176c:	e8 ef fa ff ff       	call   801260 <printnum>
			break;
  801771:	e9 88 fc ff ff       	jmp    8013fe <vprintfmt+0x30>
			putch(ch, putdat);
  801776:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80177a:	89 04 24             	mov    %eax,(%esp)
  80177d:	ff 55 08             	call   *0x8(%ebp)
			break;
  801780:	e9 79 fc ff ff       	jmp    8013fe <vprintfmt+0x30>
			putch('%', putdat);
  801785:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801789:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801790:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801793:	89 f3                	mov    %esi,%ebx
  801795:	eb 03                	jmp    80179a <vprintfmt+0x3cc>
  801797:	83 eb 01             	sub    $0x1,%ebx
  80179a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80179e:	75 f7                	jne    801797 <vprintfmt+0x3c9>
  8017a0:	e9 59 fc ff ff       	jmp    8013fe <vprintfmt+0x30>
}
  8017a5:	83 c4 3c             	add    $0x3c,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	83 ec 28             	sub    $0x28,%esp
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	74 30                	je     8017fe <vsnprintf+0x51>
  8017ce:	85 d2                	test   %edx,%edx
  8017d0:	7e 2c                	jle    8017fe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e7:	c7 04 24 89 13 80 00 	movl   $0x801389,(%esp)
  8017ee:	e8 db fb ff ff       	call   8013ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fc:	eb 05                	jmp    801803 <vsnprintf+0x56>
		return -E_INVAL;
  8017fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801803:	c9                   	leave  
  801804:	c3                   	ret    

00801805 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80180b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80180e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801812:	8b 45 10             	mov    0x10(%ebp),%eax
  801815:	89 44 24 08          	mov    %eax,0x8(%esp)
  801819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 82 ff ff ff       	call   8017ad <vsnprintf>
	va_end(ap);

	return rc;
}
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    
  80182d:	66 90                	xchg   %ax,%ax
  80182f:	90                   	nop

00801830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
  80183b:	eb 03                	jmp    801840 <strlen+0x10>
		n++;
  80183d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801844:	75 f7                	jne    80183d <strlen+0xd>
	return n;
}
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80184e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
  801856:	eb 03                	jmp    80185b <strnlen+0x13>
		n++;
  801858:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80185b:	39 d0                	cmp    %edx,%eax
  80185d:	74 06                	je     801865 <strnlen+0x1d>
  80185f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801863:	75 f3                	jne    801858 <strnlen+0x10>
	return n;
}
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801871:	89 c2                	mov    %eax,%edx
  801873:	83 c2 01             	add    $0x1,%edx
  801876:	83 c1 01             	add    $0x1,%ecx
  801879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80187d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801880:	84 db                	test   %bl,%bl
  801882:	75 ef                	jne    801873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801884:	5b                   	pop    %ebx
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801891:	89 1c 24             	mov    %ebx,(%esp)
  801894:	e8 97 ff ff ff       	call   801830 <strlen>
	strcpy(dst + len, src);
  801899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018a0:	01 d8                	add    %ebx,%eax
  8018a2:	89 04 24             	mov    %eax,(%esp)
  8018a5:	e8 bd ff ff ff       	call   801867 <strcpy>
	return dst;
}
  8018aa:	89 d8                	mov    %ebx,%eax
  8018ac:	83 c4 08             	add    $0x8,%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018bd:	89 f3                	mov    %esi,%ebx
  8018bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018c2:	89 f2                	mov    %esi,%edx
  8018c4:	eb 0f                	jmp    8018d5 <strncpy+0x23>
		*dst++ = *src;
  8018c6:	83 c2 01             	add    $0x1,%edx
  8018c9:	0f b6 01             	movzbl (%ecx),%eax
  8018cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8018cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8018d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8018d5:	39 da                	cmp    %ebx,%edx
  8018d7:	75 ed                	jne    8018c6 <strncpy+0x14>
	}
	return ret;
}
  8018d9:	89 f0                	mov    %esi,%eax
  8018db:	5b                   	pop    %ebx
  8018dc:	5e                   	pop    %esi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	56                   	push   %esi
  8018e3:	53                   	push   %ebx
  8018e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8018e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018ed:	89 f0                	mov    %esi,%eax
  8018ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018f3:	85 c9                	test   %ecx,%ecx
  8018f5:	75 0b                	jne    801902 <strlcpy+0x23>
  8018f7:	eb 1d                	jmp    801916 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018f9:	83 c0 01             	add    $0x1,%eax
  8018fc:	83 c2 01             	add    $0x1,%edx
  8018ff:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801902:	39 d8                	cmp    %ebx,%eax
  801904:	74 0b                	je     801911 <strlcpy+0x32>
  801906:	0f b6 0a             	movzbl (%edx),%ecx
  801909:	84 c9                	test   %cl,%cl
  80190b:	75 ec                	jne    8018f9 <strlcpy+0x1a>
  80190d:	89 c2                	mov    %eax,%edx
  80190f:	eb 02                	jmp    801913 <strlcpy+0x34>
  801911:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  801913:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801916:	29 f0                	sub    %esi,%eax
}
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801922:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801925:	eb 06                	jmp    80192d <strcmp+0x11>
		p++, q++;
  801927:	83 c1 01             	add    $0x1,%ecx
  80192a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80192d:	0f b6 01             	movzbl (%ecx),%eax
  801930:	84 c0                	test   %al,%al
  801932:	74 04                	je     801938 <strcmp+0x1c>
  801934:	3a 02                	cmp    (%edx),%al
  801936:	74 ef                	je     801927 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801938:	0f b6 c0             	movzbl %al,%eax
  80193b:	0f b6 12             	movzbl (%edx),%edx
  80193e:	29 d0                	sub    %edx,%eax
}
  801940:	5d                   	pop    %ebp
  801941:	c3                   	ret    

00801942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	53                   	push   %ebx
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194c:	89 c3                	mov    %eax,%ebx
  80194e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801951:	eb 06                	jmp    801959 <strncmp+0x17>
		n--, p++, q++;
  801953:	83 c0 01             	add    $0x1,%eax
  801956:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801959:	39 d8                	cmp    %ebx,%eax
  80195b:	74 15                	je     801972 <strncmp+0x30>
  80195d:	0f b6 08             	movzbl (%eax),%ecx
  801960:	84 c9                	test   %cl,%cl
  801962:	74 04                	je     801968 <strncmp+0x26>
  801964:	3a 0a                	cmp    (%edx),%cl
  801966:	74 eb                	je     801953 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801968:	0f b6 00             	movzbl (%eax),%eax
  80196b:	0f b6 12             	movzbl (%edx),%edx
  80196e:	29 d0                	sub    %edx,%eax
  801970:	eb 05                	jmp    801977 <strncmp+0x35>
		return 0;
  801972:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801977:	5b                   	pop    %ebx
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801984:	eb 07                	jmp    80198d <strchr+0x13>
		if (*s == c)
  801986:	38 ca                	cmp    %cl,%dl
  801988:	74 0f                	je     801999 <strchr+0x1f>
	for (; *s; s++)
  80198a:	83 c0 01             	add    $0x1,%eax
  80198d:	0f b6 10             	movzbl (%eax),%edx
  801990:	84 d2                	test   %dl,%dl
  801992:	75 f2                	jne    801986 <strchr+0xc>
			return (char *) s;
	return 0;
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8019a5:	eb 07                	jmp    8019ae <strfind+0x13>
		if (*s == c)
  8019a7:	38 ca                	cmp    %cl,%dl
  8019a9:	74 0a                	je     8019b5 <strfind+0x1a>
	for (; *s; s++)
  8019ab:	83 c0 01             	add    $0x1,%eax
  8019ae:	0f b6 10             	movzbl (%eax),%edx
  8019b1:	84 d2                	test   %dl,%dl
  8019b3:	75 f2                	jne    8019a7 <strfind+0xc>
			break;
	return (char *) s;
}
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	57                   	push   %edi
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019c3:	85 c9                	test   %ecx,%ecx
  8019c5:	74 36                	je     8019fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019cd:	75 28                	jne    8019f7 <memset+0x40>
  8019cf:	f6 c1 03             	test   $0x3,%cl
  8019d2:	75 23                	jne    8019f7 <memset+0x40>
		c &= 0xFF;
  8019d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8019d8:	89 d3                	mov    %edx,%ebx
  8019da:	c1 e3 08             	shl    $0x8,%ebx
  8019dd:	89 d6                	mov    %edx,%esi
  8019df:	c1 e6 18             	shl    $0x18,%esi
  8019e2:	89 d0                	mov    %edx,%eax
  8019e4:	c1 e0 10             	shl    $0x10,%eax
  8019e7:	09 f0                	or     %esi,%eax
  8019e9:	09 c2                	or     %eax,%edx
  8019eb:	89 d0                	mov    %edx,%eax
  8019ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8019ef:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8019f2:	fc                   	cld    
  8019f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8019f5:	eb 06                	jmp    8019fd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8019f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fa:	fc                   	cld    
  8019fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019fd:	89 f8                	mov    %edi,%eax
  8019ff:	5b                   	pop    %ebx
  801a00:	5e                   	pop    %esi
  801a01:	5f                   	pop    %edi
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    

00801a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	57                   	push   %edi
  801a08:	56                   	push   %esi
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a12:	39 c6                	cmp    %eax,%esi
  801a14:	73 35                	jae    801a4b <memmove+0x47>
  801a16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a19:	39 d0                	cmp    %edx,%eax
  801a1b:	73 2e                	jae    801a4b <memmove+0x47>
		s += n;
		d += n;
  801a1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a20:	89 d6                	mov    %edx,%esi
  801a22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a2a:	75 13                	jne    801a3f <memmove+0x3b>
  801a2c:	f6 c1 03             	test   $0x3,%cl
  801a2f:	75 0e                	jne    801a3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a31:	83 ef 04             	sub    $0x4,%edi
  801a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a37:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801a3a:	fd                   	std    
  801a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a3d:	eb 09                	jmp    801a48 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a3f:	83 ef 01             	sub    $0x1,%edi
  801a42:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801a45:	fd                   	std    
  801a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a48:	fc                   	cld    
  801a49:	eb 1d                	jmp    801a68 <memmove+0x64>
  801a4b:	89 f2                	mov    %esi,%edx
  801a4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a4f:	f6 c2 03             	test   $0x3,%dl
  801a52:	75 0f                	jne    801a63 <memmove+0x5f>
  801a54:	f6 c1 03             	test   $0x3,%cl
  801a57:	75 0a                	jne    801a63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a59:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801a5c:	89 c7                	mov    %eax,%edi
  801a5e:	fc                   	cld    
  801a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a61:	eb 05                	jmp    801a68 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801a63:	89 c7                	mov    %eax,%edi
  801a65:	fc                   	cld    
  801a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a72:	8b 45 10             	mov    0x10(%ebp),%eax
  801a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a80:	8b 45 08             	mov    0x8(%ebp),%eax
  801a83:	89 04 24             	mov    %eax,(%esp)
  801a86:	e8 79 ff ff ff       	call   801a04 <memmove>
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	8b 55 08             	mov    0x8(%ebp),%edx
  801a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a98:	89 d6                	mov    %edx,%esi
  801a9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a9d:	eb 1a                	jmp    801ab9 <memcmp+0x2c>
		if (*s1 != *s2)
  801a9f:	0f b6 02             	movzbl (%edx),%eax
  801aa2:	0f b6 19             	movzbl (%ecx),%ebx
  801aa5:	38 d8                	cmp    %bl,%al
  801aa7:	74 0a                	je     801ab3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801aa9:	0f b6 c0             	movzbl %al,%eax
  801aac:	0f b6 db             	movzbl %bl,%ebx
  801aaf:	29 d8                	sub    %ebx,%eax
  801ab1:	eb 0f                	jmp    801ac2 <memcmp+0x35>
		s1++, s2++;
  801ab3:	83 c2 01             	add    $0x1,%edx
  801ab6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  801ab9:	39 f2                	cmp    %esi,%edx
  801abb:	75 e2                	jne    801a9f <memcmp+0x12>
	}

	return 0;
  801abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801acf:	89 c2                	mov    %eax,%edx
  801ad1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ad4:	eb 07                	jmp    801add <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ad6:	38 08                	cmp    %cl,(%eax)
  801ad8:	74 07                	je     801ae1 <memfind+0x1b>
	for (; s < ends; s++)
  801ada:	83 c0 01             	add    $0x1,%eax
  801add:	39 d0                	cmp    %edx,%eax
  801adf:	72 f5                	jb     801ad6 <memfind+0x10>
			break;
	return (void *) s;
}
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    

00801ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  801aec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801aef:	eb 03                	jmp    801af4 <strtol+0x11>
		s++;
  801af1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801af4:	0f b6 0a             	movzbl (%edx),%ecx
  801af7:	80 f9 09             	cmp    $0x9,%cl
  801afa:	74 f5                	je     801af1 <strtol+0xe>
  801afc:	80 f9 20             	cmp    $0x20,%cl
  801aff:	74 f0                	je     801af1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801b01:	80 f9 2b             	cmp    $0x2b,%cl
  801b04:	75 0a                	jne    801b10 <strtol+0x2d>
		s++;
  801b06:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801b09:	bf 00 00 00 00       	mov    $0x0,%edi
  801b0e:	eb 11                	jmp    801b21 <strtol+0x3e>
  801b10:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  801b15:	80 f9 2d             	cmp    $0x2d,%cl
  801b18:	75 07                	jne    801b21 <strtol+0x3e>
		s++, neg = 1;
  801b1a:	8d 52 01             	lea    0x1(%edx),%edx
  801b1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b26:	75 15                	jne    801b3d <strtol+0x5a>
  801b28:	80 3a 30             	cmpb   $0x30,(%edx)
  801b2b:	75 10                	jne    801b3d <strtol+0x5a>
  801b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b31:	75 0a                	jne    801b3d <strtol+0x5a>
		s += 2, base = 16;
  801b33:	83 c2 02             	add    $0x2,%edx
  801b36:	b8 10 00 00 00       	mov    $0x10,%eax
  801b3b:	eb 10                	jmp    801b4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	75 0c                	jne    801b4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801b41:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801b43:	80 3a 30             	cmpb   $0x30,(%edx)
  801b46:	75 05                	jne    801b4d <strtol+0x6a>
		s++, base = 8;
  801b48:	83 c2 01             	add    $0x1,%edx
  801b4b:	b0 08                	mov    $0x8,%al
		base = 10;
  801b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b55:	0f b6 0a             	movzbl (%edx),%ecx
  801b58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b5b:	89 f0                	mov    %esi,%eax
  801b5d:	3c 09                	cmp    $0x9,%al
  801b5f:	77 08                	ja     801b69 <strtol+0x86>
			dig = *s - '0';
  801b61:	0f be c9             	movsbl %cl,%ecx
  801b64:	83 e9 30             	sub    $0x30,%ecx
  801b67:	eb 20                	jmp    801b89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801b69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801b6c:	89 f0                	mov    %esi,%eax
  801b6e:	3c 19                	cmp    $0x19,%al
  801b70:	77 08                	ja     801b7a <strtol+0x97>
			dig = *s - 'a' + 10;
  801b72:	0f be c9             	movsbl %cl,%ecx
  801b75:	83 e9 57             	sub    $0x57,%ecx
  801b78:	eb 0f                	jmp    801b89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  801b7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801b7d:	89 f0                	mov    %esi,%eax
  801b7f:	3c 19                	cmp    $0x19,%al
  801b81:	77 16                	ja     801b99 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801b83:	0f be c9             	movsbl %cl,%ecx
  801b86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801b8c:	7d 0f                	jge    801b9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  801b8e:	83 c2 01             	add    $0x1,%edx
  801b91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801b95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801b97:	eb bc                	jmp    801b55 <strtol+0x72>
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	eb 02                	jmp    801b9f <strtol+0xbc>
  801b9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ba3:	74 05                	je     801baa <strtol+0xc7>
		*endptr = (char *) s;
  801ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ba8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801baa:	f7 d8                	neg    %eax
  801bac:	85 ff                	test   %edi,%edi
  801bae:	0f 44 c3             	cmove  %ebx,%eax
}
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5f                   	pop    %edi
  801bb4:	5d                   	pop    %ebp
  801bb5:	c3                   	ret    
  801bb6:	66 90                	xchg   %ax,%ax
  801bb8:	66 90                	xchg   %ax,%ax
  801bba:	66 90                	xchg   %ax,%ax
  801bbc:	66 90                	xchg   %ax,%ax
  801bbe:	66 90                	xchg   %ax,%ax

00801bc0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 10             	sub    $0x10,%esp
  801bc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bce:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801bd1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801bd3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801bd8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801bdb:	89 04 24             	mov    %eax,(%esp)
  801bde:	e8 9b e7 ff ff       	call   80037e <sys_ipc_recv>
    if(r < 0){
  801be3:	85 c0                	test   %eax,%eax
  801be5:	79 16                	jns    801bfd <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801be7:	85 f6                	test   %esi,%esi
  801be9:	74 06                	je     801bf1 <ipc_recv+0x31>
            *from_env_store = 0;
  801beb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801bf1:	85 db                	test   %ebx,%ebx
  801bf3:	74 2c                	je     801c21 <ipc_recv+0x61>
            *perm_store = 0;
  801bf5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bfb:	eb 24                	jmp    801c21 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801bfd:	85 f6                	test   %esi,%esi
  801bff:	74 0a                	je     801c0b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801c01:	a1 08 40 80 00       	mov    0x804008,%eax
  801c06:	8b 40 74             	mov    0x74(%eax),%eax
  801c09:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801c0b:	85 db                	test   %ebx,%ebx
  801c0d:	74 0a                	je     801c19 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801c0f:	a1 08 40 80 00       	mov    0x804008,%eax
  801c14:	8b 40 78             	mov    0x78(%eax),%eax
  801c17:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c19:	a1 08 40 80 00       	mov    0x804008,%eax
  801c1e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    

00801c28 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	57                   	push   %edi
  801c2c:	56                   	push   %esi
  801c2d:	53                   	push   %ebx
  801c2e:	83 ec 1c             	sub    $0x1c,%esp
  801c31:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c34:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801c3a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801c3c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801c41:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801c44:	8b 45 14             	mov    0x14(%ebp),%eax
  801c47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c53:	89 3c 24             	mov    %edi,(%esp)
  801c56:	e8 00 e7 ff ff       	call   80035b <sys_ipc_try_send>
        if(r == 0){
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	74 28                	je     801c87 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801c5f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c62:	74 1c                	je     801c80 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801c64:	c7 44 24 08 00 24 80 	movl   $0x802400,0x8(%esp)
  801c6b:	00 
  801c6c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801c73:	00 
  801c74:	c7 04 24 17 24 80 00 	movl   $0x802417,(%esp)
  801c7b:	e8 c6 f4 ff ff       	call   801146 <_panic>
        }
        sys_yield();
  801c80:	e8 c4 e4 ff ff       	call   800149 <sys_yield>
    }
  801c85:	eb bd                	jmp    801c44 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801c87:	83 c4 1c             	add    $0x1c,%esp
  801c8a:	5b                   	pop    %ebx
  801c8b:	5e                   	pop    %esi
  801c8c:	5f                   	pop    %edi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c9a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c9d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ca3:	8b 52 50             	mov    0x50(%edx),%edx
  801ca6:	39 ca                	cmp    %ecx,%edx
  801ca8:	75 0d                	jne    801cb7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801caa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cad:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cb2:	8b 40 40             	mov    0x40(%eax),%eax
  801cb5:	eb 0e                	jmp    801cc5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801cb7:	83 c0 01             	add    $0x1,%eax
  801cba:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cbf:	75 d9                	jne    801c9a <ipc_find_env+0xb>
	return 0;
  801cc1:	66 b8 00 00          	mov    $0x0,%ax
}
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ccd:	89 d0                	mov    %edx,%eax
  801ccf:	c1 e8 16             	shr    $0x16,%eax
  801cd2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801cde:	f6 c1 01             	test   $0x1,%cl
  801ce1:	74 1d                	je     801d00 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801ce3:	c1 ea 0c             	shr    $0xc,%edx
  801ce6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ced:	f6 c2 01             	test   $0x1,%dl
  801cf0:	74 0e                	je     801d00 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cf2:	c1 ea 0c             	shr    $0xc,%edx
  801cf5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cfc:	ef 
  801cfd:	0f b7 c0             	movzwl %ax,%eax
}
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	66 90                	xchg   %ax,%ax
  801d04:	66 90                	xchg   %ax,%ax
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__udivdi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d1a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d1e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d22:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d26:	85 c0                	test   %eax,%eax
  801d28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d2c:	89 ea                	mov    %ebp,%edx
  801d2e:	89 0c 24             	mov    %ecx,(%esp)
  801d31:	75 2d                	jne    801d60 <__udivdi3+0x50>
  801d33:	39 e9                	cmp    %ebp,%ecx
  801d35:	77 61                	ja     801d98 <__udivdi3+0x88>
  801d37:	85 c9                	test   %ecx,%ecx
  801d39:	89 ce                	mov    %ecx,%esi
  801d3b:	75 0b                	jne    801d48 <__udivdi3+0x38>
  801d3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d42:	31 d2                	xor    %edx,%edx
  801d44:	f7 f1                	div    %ecx
  801d46:	89 c6                	mov    %eax,%esi
  801d48:	31 d2                	xor    %edx,%edx
  801d4a:	89 e8                	mov    %ebp,%eax
  801d4c:	f7 f6                	div    %esi
  801d4e:	89 c5                	mov    %eax,%ebp
  801d50:	89 f8                	mov    %edi,%eax
  801d52:	f7 f6                	div    %esi
  801d54:	89 ea                	mov    %ebp,%edx
  801d56:	83 c4 0c             	add    $0xc,%esp
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi
  801d60:	39 e8                	cmp    %ebp,%eax
  801d62:	77 24                	ja     801d88 <__udivdi3+0x78>
  801d64:	0f bd e8             	bsr    %eax,%ebp
  801d67:	83 f5 1f             	xor    $0x1f,%ebp
  801d6a:	75 3c                	jne    801da8 <__udivdi3+0x98>
  801d6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d70:	39 34 24             	cmp    %esi,(%esp)
  801d73:	0f 86 9f 00 00 00    	jbe    801e18 <__udivdi3+0x108>
  801d79:	39 d0                	cmp    %edx,%eax
  801d7b:	0f 82 97 00 00 00    	jb     801e18 <__udivdi3+0x108>
  801d81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d88:	31 d2                	xor    %edx,%edx
  801d8a:	31 c0                	xor    %eax,%eax
  801d8c:	83 c4 0c             	add    $0xc,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	89 f8                	mov    %edi,%eax
  801d9a:	f7 f1                	div    %ecx
  801d9c:	31 d2                	xor    %edx,%edx
  801d9e:	83 c4 0c             	add    $0xc,%esp
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	8b 3c 24             	mov    (%esp),%edi
  801dad:	d3 e0                	shl    %cl,%eax
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	b8 20 00 00 00       	mov    $0x20,%eax
  801db6:	29 e8                	sub    %ebp,%eax
  801db8:	89 c1                	mov    %eax,%ecx
  801dba:	d3 ef                	shr    %cl,%edi
  801dbc:	89 e9                	mov    %ebp,%ecx
  801dbe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801dc2:	8b 3c 24             	mov    (%esp),%edi
  801dc5:	09 74 24 08          	or     %esi,0x8(%esp)
  801dc9:	89 d6                	mov    %edx,%esi
  801dcb:	d3 e7                	shl    %cl,%edi
  801dcd:	89 c1                	mov    %eax,%ecx
  801dcf:	89 3c 24             	mov    %edi,(%esp)
  801dd2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801dd6:	d3 ee                	shr    %cl,%esi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	d3 e2                	shl    %cl,%edx
  801ddc:	89 c1                	mov    %eax,%ecx
  801dde:	d3 ef                	shr    %cl,%edi
  801de0:	09 d7                	or     %edx,%edi
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	89 f8                	mov    %edi,%eax
  801de6:	f7 74 24 08          	divl   0x8(%esp)
  801dea:	89 d6                	mov    %edx,%esi
  801dec:	89 c7                	mov    %eax,%edi
  801dee:	f7 24 24             	mull   (%esp)
  801df1:	39 d6                	cmp    %edx,%esi
  801df3:	89 14 24             	mov    %edx,(%esp)
  801df6:	72 30                	jb     801e28 <__udivdi3+0x118>
  801df8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dfc:	89 e9                	mov    %ebp,%ecx
  801dfe:	d3 e2                	shl    %cl,%edx
  801e00:	39 c2                	cmp    %eax,%edx
  801e02:	73 05                	jae    801e09 <__udivdi3+0xf9>
  801e04:	3b 34 24             	cmp    (%esp),%esi
  801e07:	74 1f                	je     801e28 <__udivdi3+0x118>
  801e09:	89 f8                	mov    %edi,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	e9 7a ff ff ff       	jmp    801d8c <__udivdi3+0x7c>
  801e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1f:	e9 68 ff ff ff       	jmp    801d8c <__udivdi3+0x7c>
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	83 c4 0c             	add    $0xc,%esp
  801e30:	5e                   	pop    %esi
  801e31:	5f                   	pop    %edi
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    
  801e34:	66 90                	xchg   %ax,%ax
  801e36:	66 90                	xchg   %ax,%ax
  801e38:	66 90                	xchg   %ax,%ax
  801e3a:	66 90                	xchg   %ax,%ax
  801e3c:	66 90                	xchg   %ax,%ax
  801e3e:	66 90                	xchg   %ax,%ax

00801e40 <__umoddi3>:
  801e40:	55                   	push   %ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	83 ec 14             	sub    $0x14,%esp
  801e46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e52:	89 c7                	mov    %eax,%edi
  801e54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e58:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e60:	89 34 24             	mov    %esi,(%esp)
  801e63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e67:	85 c0                	test   %eax,%eax
  801e69:	89 c2                	mov    %eax,%edx
  801e6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e6f:	75 17                	jne    801e88 <__umoddi3+0x48>
  801e71:	39 fe                	cmp    %edi,%esi
  801e73:	76 4b                	jbe    801ec0 <__umoddi3+0x80>
  801e75:	89 c8                	mov    %ecx,%eax
  801e77:	89 fa                	mov    %edi,%edx
  801e79:	f7 f6                	div    %esi
  801e7b:	89 d0                	mov    %edx,%eax
  801e7d:	31 d2                	xor    %edx,%edx
  801e7f:	83 c4 14             	add    $0x14,%esp
  801e82:	5e                   	pop    %esi
  801e83:	5f                   	pop    %edi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    
  801e86:	66 90                	xchg   %ax,%ax
  801e88:	39 f8                	cmp    %edi,%eax
  801e8a:	77 54                	ja     801ee0 <__umoddi3+0xa0>
  801e8c:	0f bd e8             	bsr    %eax,%ebp
  801e8f:	83 f5 1f             	xor    $0x1f,%ebp
  801e92:	75 5c                	jne    801ef0 <__umoddi3+0xb0>
  801e94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801e98:	39 3c 24             	cmp    %edi,(%esp)
  801e9b:	0f 87 e7 00 00 00    	ja     801f88 <__umoddi3+0x148>
  801ea1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ea5:	29 f1                	sub    %esi,%ecx
  801ea7:	19 c7                	sbb    %eax,%edi
  801ea9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ead:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eb1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801eb5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801eb9:	83 c4 14             	add    $0x14,%esp
  801ebc:	5e                   	pop    %esi
  801ebd:	5f                   	pop    %edi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    
  801ec0:	85 f6                	test   %esi,%esi
  801ec2:	89 f5                	mov    %esi,%ebp
  801ec4:	75 0b                	jne    801ed1 <__umoddi3+0x91>
  801ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecb:	31 d2                	xor    %edx,%edx
  801ecd:	f7 f6                	div    %esi
  801ecf:	89 c5                	mov    %eax,%ebp
  801ed1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ed5:	31 d2                	xor    %edx,%edx
  801ed7:	f7 f5                	div    %ebp
  801ed9:	89 c8                	mov    %ecx,%eax
  801edb:	f7 f5                	div    %ebp
  801edd:	eb 9c                	jmp    801e7b <__umoddi3+0x3b>
  801edf:	90                   	nop
  801ee0:	89 c8                	mov    %ecx,%eax
  801ee2:	89 fa                	mov    %edi,%edx
  801ee4:	83 c4 14             	add    $0x14,%esp
  801ee7:	5e                   	pop    %esi
  801ee8:	5f                   	pop    %edi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    
  801eeb:	90                   	nop
  801eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	8b 04 24             	mov    (%esp),%eax
  801ef3:	be 20 00 00 00       	mov    $0x20,%esi
  801ef8:	89 e9                	mov    %ebp,%ecx
  801efa:	29 ee                	sub    %ebp,%esi
  801efc:	d3 e2                	shl    %cl,%edx
  801efe:	89 f1                	mov    %esi,%ecx
  801f00:	d3 e8                	shr    %cl,%eax
  801f02:	89 e9                	mov    %ebp,%ecx
  801f04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f08:	8b 04 24             	mov    (%esp),%eax
  801f0b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f0f:	89 fa                	mov    %edi,%edx
  801f11:	d3 e0                	shl    %cl,%eax
  801f13:	89 f1                	mov    %esi,%ecx
  801f15:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f1d:	d3 ea                	shr    %cl,%edx
  801f1f:	89 e9                	mov    %ebp,%ecx
  801f21:	d3 e7                	shl    %cl,%edi
  801f23:	89 f1                	mov    %esi,%ecx
  801f25:	d3 e8                	shr    %cl,%eax
  801f27:	89 e9                	mov    %ebp,%ecx
  801f29:	09 f8                	or     %edi,%eax
  801f2b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f2f:	f7 74 24 04          	divl   0x4(%esp)
  801f33:	d3 e7                	shl    %cl,%edi
  801f35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f39:	89 d7                	mov    %edx,%edi
  801f3b:	f7 64 24 08          	mull   0x8(%esp)
  801f3f:	39 d7                	cmp    %edx,%edi
  801f41:	89 c1                	mov    %eax,%ecx
  801f43:	89 14 24             	mov    %edx,(%esp)
  801f46:	72 2c                	jb     801f74 <__umoddi3+0x134>
  801f48:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f4c:	72 22                	jb     801f70 <__umoddi3+0x130>
  801f4e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f52:	29 c8                	sub    %ecx,%eax
  801f54:	19 d7                	sbb    %edx,%edi
  801f56:	89 e9                	mov    %ebp,%ecx
  801f58:	89 fa                	mov    %edi,%edx
  801f5a:	d3 e8                	shr    %cl,%eax
  801f5c:	89 f1                	mov    %esi,%ecx
  801f5e:	d3 e2                	shl    %cl,%edx
  801f60:	89 e9                	mov    %ebp,%ecx
  801f62:	d3 ef                	shr    %cl,%edi
  801f64:	09 d0                	or     %edx,%eax
  801f66:	89 fa                	mov    %edi,%edx
  801f68:	83 c4 14             	add    $0x14,%esp
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    
  801f6f:	90                   	nop
  801f70:	39 d7                	cmp    %edx,%edi
  801f72:	75 da                	jne    801f4e <__umoddi3+0x10e>
  801f74:	8b 14 24             	mov    (%esp),%edx
  801f77:	89 c1                	mov    %eax,%ecx
  801f79:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801f7d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801f81:	eb cb                	jmp    801f4e <__umoddi3+0x10e>
  801f83:	90                   	nop
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801f8c:	0f 82 0f ff ff ff    	jb     801ea1 <__umoddi3+0x61>
  801f92:	e9 1a ff ff ff       	jmp    801eb1 <__umoddi3+0x71>
