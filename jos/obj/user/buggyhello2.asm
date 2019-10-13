
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  800039:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800040:	00 
  800041:	a1 00 30 80 00       	mov    0x803000,%eax
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 63 00 00 00       	call   8000b1 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
 //   envid_t id = syscall(SYS_getenvid, 0, 0, 0, 0, 0);
	envid_t id = sys_getenvid();
  80005e:	e8 dd 00 00 00       	call   800140 <sys_getenvid>
    //thisenv = envid2env(id, &thisenv, 1);
    thisenv = &envs[ENVX(id)];
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800080:	89 74 24 04          	mov    %esi,0x4(%esp)
  800084:	89 1c 24             	mov    %ebx,(%esp)
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009e:	e8 22 05 00 00       	call   8005c5 <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 3f 00 00 00       	call   8000ee <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	57                   	push   %edi
  8000b5:	56                   	push   %esi
  8000b6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	89 c3                	mov    %eax,%ebx
  8000c4:	89 c7                	mov    %eax,%edi
  8000c6:	89 c6                	mov    %eax,%esi
  8000c8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000da:	b8 01 00 00 00       	mov    $0x1,%eax
  8000df:	89 d1                	mov    %edx,%ecx
  8000e1:	89 d3                	mov    %edx,%ebx
  8000e3:	89 d7                	mov    %edx,%edi
  8000e5:	89 d6                	mov    %edx,%esi
  8000e7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	8b 55 08             	mov    0x8(%ebp),%edx
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7e 28                	jle    800138 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800110:	89 44 24 10          	mov    %eax,0x10(%esp)
  800114:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011b:	00 
  80011c:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  800123:	00 
  800124:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  800133:	e8 2e 10 00 00       	call   801166 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800138:	83 c4 2c             	add    $0x2c,%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 02 00 00 00       	mov    $0x2,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_yield>:

void
sys_yield(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	asm volatile("int %1\n"
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016f:	89 d1                	mov    %edx,%ecx
  800171:	89 d3                	mov    %edx,%ebx
  800173:	89 d7                	mov    %edx,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800187:	be 00 00 00 00       	mov    $0x0,%esi
  80018c:	b8 04 00 00 00       	mov    $0x4,%eax
  800191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800194:	8b 55 08             	mov    0x8(%ebp),%edx
  800197:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019a:	89 f7                	mov    %esi,%edi
  80019c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	7e 28                	jle    8001ca <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  8001b5:	00 
  8001b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bd:	00 
  8001be:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  8001c5:	e8 9c 0f 00 00       	call   801166 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ca:	83 c4 2c             	add    $0x2c,%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001db:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ec:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 28                	jle    80021d <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800200:	00 
  800201:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  800208:	00 
  800209:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800210:	00 
  800211:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  800218:	e8 49 0f 00 00       	call   801166 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021d:	83 c4 2c             	add    $0x2c,%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 06 00 00 00       	mov    $0x6,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 28                	jle    800270 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800253:	00 
  800254:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  80025b:	00 
  80025c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800263:	00 
  800264:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  80026b:	e8 f6 0e 00 00       	call   801166 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800270:	83 c4 2c             	add    $0x2c,%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800281:	bb 00 00 00 00       	mov    $0x0,%ebx
  800286:	b8 08 00 00 00       	mov    $0x8,%eax
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	8b 55 08             	mov    0x8(%ebp),%edx
  800291:	89 df                	mov    %ebx,%edi
  800293:	89 de                	mov    %ebx,%esi
  800295:	cd 30                	int    $0x30
	if(check && ret > 0)
  800297:	85 c0                	test   %eax,%eax
  800299:	7e 28                	jle    8002c3 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029f:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a6:	00 
  8002a7:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  8002ae:	00 
  8002af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b6:	00 
  8002b7:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  8002be:	e8 a3 0e 00 00       	call   801166 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c3:	83 c4 2c             	add    $0x2c,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 df                	mov    %ebx,%edi
  8002e6:	89 de                	mov    %ebx,%esi
  8002e8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 28                	jle    800316 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  800301:	00 
  800302:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800309:	00 
  80030a:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  800311:	e8 50 0e 00 00       	call   801166 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800316:	83 c4 2c             	add    $0x2c,%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800327:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	89 df                	mov    %ebx,%edi
  800339:	89 de                	mov    %ebx,%esi
  80033b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80033d:	85 c0                	test   %eax,%eax
  80033f:	7e 28                	jle    800369 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800341:	89 44 24 10          	mov    %eax,0x10(%esp)
  800345:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034c:	00 
  80034d:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  800354:	00 
  800355:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035c:	00 
  80035d:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  800364:	e8 fd 0d 00 00       	call   801166 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800369:	83 c4 2c             	add    $0x2c,%esp
  80036c:	5b                   	pop    %ebx
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
	asm volatile("int %1\n"
  800377:	be 00 00 00 00       	mov    $0x0,%esi
  80037c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800384:	8b 55 08             	mov    0x8(%ebp),%edx
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038f:	5b                   	pop    %ebx
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 cb                	mov    %ecx,%ebx
  8003ac:	89 cf                	mov    %ecx,%edi
  8003ae:	89 ce                	mov    %ecx,%esi
  8003b0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	7e 28                	jle    8003de <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ba:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c1:	00 
  8003c2:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  8003c9:	00 
  8003ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d1:	00 
  8003d2:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  8003d9:	e8 88 0d 00 00       	call   801166 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003de:	83 c4 2c             	add    $0x2c,%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    
  8003e6:	66 90                	xchg   %ax,%ax
  8003e8:	66 90                	xchg   %ax,%ax
  8003ea:	66 90                	xchg   %ax,%ax
  8003ec:	66 90                	xchg   %ax,%ax
  8003ee:	66 90                	xchg   %ax,%ax

008003f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80040b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800410:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800422:	89 c2                	mov    %eax,%edx
  800424:	c1 ea 16             	shr    $0x16,%edx
  800427:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042e:	f6 c2 01             	test   $0x1,%dl
  800431:	74 11                	je     800444 <fd_alloc+0x2d>
  800433:	89 c2                	mov    %eax,%edx
  800435:	c1 ea 0c             	shr    $0xc,%edx
  800438:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043f:	f6 c2 01             	test   $0x1,%dl
  800442:	75 09                	jne    80044d <fd_alloc+0x36>
			*fd_store = fd;
  800444:	89 01                	mov    %eax,(%ecx)
			return 0;
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	eb 17                	jmp    800464 <fd_alloc+0x4d>
  80044d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800452:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800457:	75 c9                	jne    800422 <fd_alloc+0xb>
		}
	}
	*fd_store = 0;
  800459:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80045f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80046c:	83 f8 1f             	cmp    $0x1f,%eax
  80046f:	77 36                	ja     8004a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800471:	c1 e0 0c             	shl    $0xc,%eax
  800474:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800479:	89 c2                	mov    %eax,%edx
  80047b:	c1 ea 16             	shr    $0x16,%edx
  80047e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800485:	f6 c2 01             	test   $0x1,%dl
  800488:	74 24                	je     8004ae <fd_lookup+0x48>
  80048a:	89 c2                	mov    %eax,%edx
  80048c:	c1 ea 0c             	shr    $0xc,%edx
  80048f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800496:	f6 c2 01             	test   $0x1,%dl
  800499:	74 1a                	je     8004b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80049b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049e:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	eb 13                	jmp    8004ba <fd_lookup+0x54>
		return -E_INVAL;
  8004a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ac:	eb 0c                	jmp    8004ba <fd_lookup+0x54>
		return -E_INVAL;
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b3:	eb 05                	jmp    8004ba <fd_lookup+0x54>
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 18             	sub    $0x18,%esp
  8004c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c5:	ba 80 20 80 00       	mov    $0x802080,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004ca:	eb 13                	jmp    8004df <dev_lookup+0x23>
  8004cc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004cf:	39 08                	cmp    %ecx,(%eax)
  8004d1:	75 0c                	jne    8004df <dev_lookup+0x23>
			*dev = devtab[i];
  8004d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	eb 30                	jmp    80050f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	75 e7                	jne    8004cc <dev_lookup+0x10>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8004ea:	8b 40 48             	mov    0x48(%eax),%eax
  8004ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8004fc:	e8 5e 0d 00 00       	call   80125f <cprintf>
	*dev = 0;
  800501:	8b 45 0c             	mov    0xc(%ebp),%eax
  800504:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80050a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <fd_close>:
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	56                   	push   %esi
  800515:	53                   	push   %ebx
  800516:	83 ec 20             	sub    $0x20,%esp
  800519:	8b 75 08             	mov    0x8(%ebp),%esi
  80051c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80051f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800522:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800526:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80052c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	e8 2f ff ff ff       	call   800466 <fd_lookup>
  800537:	85 c0                	test   %eax,%eax
  800539:	78 05                	js     800540 <fd_close+0x2f>
	    || fd != fd2)
  80053b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80053e:	74 0c                	je     80054c <fd_close+0x3b>
		return (must_exist ? r : 0);
  800540:	84 db                	test   %bl,%bl
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
  800547:	0f 44 c2             	cmove  %edx,%eax
  80054a:	eb 3f                	jmp    80058b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80054c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80054f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800553:	8b 06                	mov    (%esi),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	e8 5f ff ff ff       	call   8004bc <dev_lookup>
  80055d:	89 c3                	mov    %eax,%ebx
  80055f:	85 c0                	test   %eax,%eax
  800561:	78 16                	js     800579 <fd_close+0x68>
		if (dev->dev_close)
  800563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800566:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800569:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80056e:	85 c0                	test   %eax,%eax
  800570:	74 07                	je     800579 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800572:	89 34 24             	mov    %esi,(%esp)
  800575:	ff d0                	call   *%eax
  800577:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  800579:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800584:	e8 9c fc ff ff       	call   800225 <sys_page_unmap>
	return r;
  800589:	89 d8                	mov    %ebx,%eax
}
  80058b:	83 c4 20             	add    $0x20,%esp
  80058e:	5b                   	pop    %ebx
  80058f:	5e                   	pop    %esi
  800590:	5d                   	pop    %ebp
  800591:	c3                   	ret    

00800592 <close>:

int
close(int fdnum)
{
  800592:	55                   	push   %ebp
  800593:	89 e5                	mov    %esp,%ebp
  800595:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80059b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059f:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a2:	89 04 24             	mov    %eax,(%esp)
  8005a5:	e8 bc fe ff ff       	call   800466 <fd_lookup>
  8005aa:	89 c2                	mov    %eax,%edx
  8005ac:	85 d2                	test   %edx,%edx
  8005ae:	78 13                	js     8005c3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8005b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005b7:	00 
  8005b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	e8 4e ff ff ff       	call   800511 <fd_close>
}
  8005c3:	c9                   	leave  
  8005c4:	c3                   	ret    

008005c5 <close_all>:

void
close_all(void)
{
  8005c5:	55                   	push   %ebp
  8005c6:	89 e5                	mov    %esp,%ebp
  8005c8:	53                   	push   %ebx
  8005c9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005d1:	89 1c 24             	mov    %ebx,(%esp)
  8005d4:	e8 b9 ff ff ff       	call   800592 <close>
	for (i = 0; i < MAXFD; i++)
  8005d9:	83 c3 01             	add    $0x1,%ebx
  8005dc:	83 fb 20             	cmp    $0x20,%ebx
  8005df:	75 f0                	jne    8005d1 <close_all+0xc>
}
  8005e1:	83 c4 14             	add    $0x14,%esp
  8005e4:	5b                   	pop    %ebx
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    

008005e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	57                   	push   %edi
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 64 fe ff ff       	call   800466 <fd_lookup>
  800602:	89 c2                	mov    %eax,%edx
  800604:	85 d2                	test   %edx,%edx
  800606:	0f 88 e1 00 00 00    	js     8006ed <dup+0x106>
		return r;
	close(newfdnum);
  80060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 7b ff ff ff       	call   800592 <close>

	newfd = INDEX2FD(newfdnum);
  800617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061a:	c1 e3 0c             	shl    $0xc,%ebx
  80061d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	e8 d2 fd ff ff       	call   800400 <fd2data>
  80062e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800630:	89 1c 24             	mov    %ebx,(%esp)
  800633:	e8 c8 fd ff ff       	call   800400 <fd2data>
  800638:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80063a:	89 f0                	mov    %esi,%eax
  80063c:	c1 e8 16             	shr    $0x16,%eax
  80063f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800646:	a8 01                	test   $0x1,%al
  800648:	74 43                	je     80068d <dup+0xa6>
  80064a:	89 f0                	mov    %esi,%eax
  80064c:	c1 e8 0c             	shr    $0xc,%eax
  80064f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800656:	f6 c2 01             	test   $0x1,%dl
  800659:	74 32                	je     80068d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800662:	25 07 0e 00 00       	and    $0xe07,%eax
  800667:	89 44 24 10          	mov    %eax,0x10(%esp)
  80066b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80066f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800676:	00 
  800677:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800682:	e8 4b fb ff ff       	call   8001d2 <sys_page_map>
  800687:	89 c6                	mov    %eax,%esi
  800689:	85 c0                	test   %eax,%eax
  80068b:	78 3e                	js     8006cb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80068d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800690:	89 c2                	mov    %eax,%edx
  800692:	c1 ea 0c             	shr    $0xc,%edx
  800695:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80069c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006a2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006b1:	00 
  8006b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006bd:	e8 10 fb ff ff       	call   8001d2 <sys_page_map>
  8006c2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8006c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006c7:	85 f6                	test   %esi,%esi
  8006c9:	79 22                	jns    8006ed <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8006cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d6:	e8 4a fb ff ff       	call   800225 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006e6:	e8 3a fb ff ff       	call   800225 <sys_page_unmap>
	return r;
  8006eb:	89 f0                	mov    %esi,%eax
}
  8006ed:	83 c4 3c             	add    $0x3c,%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	53                   	push   %ebx
  8006f9:	83 ec 24             	sub    $0x24,%esp
  8006fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800702:	89 44 24 04          	mov    %eax,0x4(%esp)
  800706:	89 1c 24             	mov    %ebx,(%esp)
  800709:	e8 58 fd ff ff       	call   800466 <fd_lookup>
  80070e:	89 c2                	mov    %eax,%edx
  800710:	85 d2                	test   %edx,%edx
  800712:	78 6d                	js     800781 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800714:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071e:	8b 00                	mov    (%eax),%eax
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	e8 94 fd ff ff       	call   8004bc <dev_lookup>
  800728:	85 c0                	test   %eax,%eax
  80072a:	78 55                	js     800781 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80072c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072f:	8b 50 08             	mov    0x8(%eax),%edx
  800732:	83 e2 03             	and    $0x3,%edx
  800735:	83 fa 01             	cmp    $0x1,%edx
  800738:	75 23                	jne    80075d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 08 40 80 00       	mov    0x804008,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800746:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074a:	c7 04 24 45 20 80 00 	movl   $0x802045,(%esp)
  800751:	e8 09 0b 00 00       	call   80125f <cprintf>
		return -E_INVAL;
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075b:	eb 24                	jmp    800781 <read+0x8c>
	}
	if (!dev->dev_read)
  80075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800760:	8b 52 08             	mov    0x8(%edx),%edx
  800763:	85 d2                	test   %edx,%edx
  800765:	74 15                	je     80077c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800767:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80076a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80076e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800771:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	ff d2                	call   *%edx
  80077a:	eb 05                	jmp    800781 <read+0x8c>
		return -E_NOT_SUPP;
  80077c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800781:	83 c4 24             	add    $0x24,%esp
  800784:	5b                   	pop    %ebx
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	57                   	push   %edi
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	83 ec 1c             	sub    $0x1c,%esp
  800790:	8b 7d 08             	mov    0x8(%ebp),%edi
  800793:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800796:	bb 00 00 00 00       	mov    $0x0,%ebx
  80079b:	eb 23                	jmp    8007c0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80079d:	89 f0                	mov    %esi,%eax
  80079f:	29 d8                	sub    %ebx,%eax
  8007a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a5:	89 d8                	mov    %ebx,%eax
  8007a7:	03 45 0c             	add    0xc(%ebp),%eax
  8007aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ae:	89 3c 24             	mov    %edi,(%esp)
  8007b1:	e8 3f ff ff ff       	call   8006f5 <read>
		if (m < 0)
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	78 10                	js     8007ca <readn+0x43>
			return m;
		if (m == 0)
  8007ba:	85 c0                	test   %eax,%eax
  8007bc:	74 0a                	je     8007c8 <readn+0x41>
	for (tot = 0; tot < n; tot += m) {
  8007be:	01 c3                	add    %eax,%ebx
  8007c0:	39 f3                	cmp    %esi,%ebx
  8007c2:	72 d9                	jb     80079d <readn+0x16>
  8007c4:	89 d8                	mov    %ebx,%eax
  8007c6:	eb 02                	jmp    8007ca <readn+0x43>
  8007c8:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007ca:	83 c4 1c             	add    $0x1c,%esp
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	5f                   	pop    %edi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 24             	sub    $0x24,%esp
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e3:	89 1c 24             	mov    %ebx,(%esp)
  8007e6:	e8 7b fc ff ff       	call   800466 <fd_lookup>
  8007eb:	89 c2                	mov    %eax,%edx
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	78 68                	js     800859 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	89 04 24             	mov    %eax,(%esp)
  800800:	e8 b7 fc ff ff       	call   8004bc <dev_lookup>
  800805:	85 c0                	test   %eax,%eax
  800807:	78 50                	js     800859 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800810:	75 23                	jne    800835 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800812:	a1 08 40 80 00       	mov    0x804008,%eax
  800817:	8b 40 48             	mov    0x48(%eax),%eax
  80081a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80081e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800822:	c7 04 24 61 20 80 00 	movl   $0x802061,(%esp)
  800829:	e8 31 0a 00 00       	call   80125f <cprintf>
		return -E_INVAL;
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800833:	eb 24                	jmp    800859 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800835:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800838:	8b 52 0c             	mov    0xc(%edx),%edx
  80083b:	85 d2                	test   %edx,%edx
  80083d:	74 15                	je     800854 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80083f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800842:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80084d:	89 04 24             	mov    %eax,(%esp)
  800850:	ff d2                	call   *%edx
  800852:	eb 05                	jmp    800859 <write+0x87>
		return -E_NOT_SUPP;
  800854:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800859:	83 c4 24             	add    $0x24,%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <seek>:

int
seek(int fdnum, off_t offset)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800865:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	89 04 24             	mov    %eax,(%esp)
  800872:	e8 ef fb ff ff       	call   800466 <fd_lookup>
  800877:	85 c0                	test   %eax,%eax
  800879:	78 0e                	js     800889 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80087b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	83 ec 24             	sub    $0x24,%esp
  800892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800895:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089c:	89 1c 24             	mov    %ebx,(%esp)
  80089f:	e8 c2 fb ff ff       	call   800466 <fd_lookup>
  8008a4:	89 c2                	mov    %eax,%edx
  8008a6:	85 d2                	test   %edx,%edx
  8008a8:	78 61                	js     80090b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b4:	8b 00                	mov    (%eax),%eax
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	e8 fe fb ff ff       	call   8004bc <dev_lookup>
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	78 49                	js     80090b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008c9:	75 23                	jne    8008ee <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008cb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008d0:	8b 40 48             	mov    0x48(%eax),%eax
  8008d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008db:	c7 04 24 24 20 80 00 	movl   $0x802024,(%esp)
  8008e2:	e8 78 09 00 00       	call   80125f <cprintf>
		return -E_INVAL;
  8008e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ec:	eb 1d                	jmp    80090b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8008ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008f1:	8b 52 18             	mov    0x18(%edx),%edx
  8008f4:	85 d2                	test   %edx,%edx
  8008f6:	74 0e                	je     800906 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008ff:	89 04 24             	mov    %eax,(%esp)
  800902:	ff d2                	call   *%edx
  800904:	eb 05                	jmp    80090b <ftruncate+0x80>
		return -E_NOT_SUPP;
  800906:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80090b:	83 c4 24             	add    $0x24,%esp
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	53                   	push   %ebx
  800915:	83 ec 24             	sub    $0x24,%esp
  800918:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80091b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	89 04 24             	mov    %eax,(%esp)
  800928:	e8 39 fb ff ff       	call   800466 <fd_lookup>
  80092d:	89 c2                	mov    %eax,%edx
  80092f:	85 d2                	test   %edx,%edx
  800931:	78 52                	js     800985 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800933:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093d:	8b 00                	mov    (%eax),%eax
  80093f:	89 04 24             	mov    %eax,(%esp)
  800942:	e8 75 fb ff ff       	call   8004bc <dev_lookup>
  800947:	85 c0                	test   %eax,%eax
  800949:	78 3a                	js     800985 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80094b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800952:	74 2c                	je     800980 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800954:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800957:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80095e:	00 00 00 
	stat->st_isdir = 0;
  800961:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800968:	00 00 00 
	stat->st_dev = dev;
  80096b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800971:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800975:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800978:	89 14 24             	mov    %edx,(%esp)
  80097b:	ff 50 14             	call   *0x14(%eax)
  80097e:	eb 05                	jmp    800985 <fstat+0x74>
		return -E_NOT_SUPP;
  800980:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  800985:	83 c4 24             	add    $0x24,%esp
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800993:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80099a:	00 
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	e8 fb 01 00 00       	call   800ba1 <open>
  8009a6:	89 c3                	mov    %eax,%ebx
  8009a8:	85 db                	test   %ebx,%ebx
  8009aa:	78 1b                	js     8009c7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b3:	89 1c 24             	mov    %ebx,(%esp)
  8009b6:	e8 56 ff ff ff       	call   800911 <fstat>
  8009bb:	89 c6                	mov    %eax,%esi
	close(fd);
  8009bd:	89 1c 24             	mov    %ebx,(%esp)
  8009c0:	e8 cd fb ff ff       	call   800592 <close>
	return r;
  8009c5:	89 f0                	mov    %esi,%eax
}
  8009c7:	83 c4 10             	add    $0x10,%esp
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	83 ec 10             	sub    $0x10,%esp
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009da:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009e1:	75 11                	jne    8009f4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009ea:	e8 c0 12 00 00       	call   801caf <ipc_find_env>
  8009ef:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009f4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8009fb:	00 
  8009fc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a03:	00 
  800a04:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a08:	a1 00 40 80 00       	mov    0x804000,%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 33 12 00 00       	call   801c48 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a1c:	00 
  800a1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a28:	e8 b3 11 00 00       	call   801be0 <ipc_recv>
}
  800a2d:	83 c4 10             	add    $0x10,%esp
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a40:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 02 00 00 00       	mov    $0x2,%eax
  800a57:	e8 72 ff ff ff       	call   8009ce <fsipc>
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <devfile_flush>:
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 06 00 00 00       	mov    $0x6,%eax
  800a79:	e8 50 ff ff ff       	call   8009ce <fsipc>
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <devfile_stat>:
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	83 ec 14             	sub    $0x14,%esp
  800a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a90:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a9f:	e8 2a ff ff ff       	call   8009ce <fsipc>
  800aa4:	89 c2                	mov    %eax,%edx
  800aa6:	85 d2                	test   %edx,%edx
  800aa8:	78 2b                	js     800ad5 <devfile_stat+0x55>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aaa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ab1:	00 
  800ab2:	89 1c 24             	mov    %ebx,(%esp)
  800ab5:	e8 cd 0d 00 00       	call   801887 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aba:	a1 80 50 80 00       	mov    0x805080,%eax
  800abf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ac5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	83 c4 14             	add    $0x14,%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <devfile_write>:
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	83 ec 18             	sub    $0x18,%esp
	panic("devfile_write not implemented");
  800ae1:	c7 44 24 08 90 20 80 	movl   $0x802090,0x8(%esp)
  800ae8:	00 
  800ae9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800af0:	00 
  800af1:	c7 04 24 ae 20 80 00 	movl   $0x8020ae,(%esp)
  800af8:	e8 69 06 00 00       	call   801166 <_panic>

00800afd <devfile_read>:
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	83 ec 10             	sub    $0x10,%esp
  800b05:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b23:	e8 a6 fe ff ff       	call   8009ce <fsipc>
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 6a                	js     800b98 <devfile_read+0x9b>
	assert(r <= n);
  800b2e:	39 c6                	cmp    %eax,%esi
  800b30:	73 24                	jae    800b56 <devfile_read+0x59>
  800b32:	c7 44 24 0c b9 20 80 	movl   $0x8020b9,0xc(%esp)
  800b39:	00 
  800b3a:	c7 44 24 08 c0 20 80 	movl   $0x8020c0,0x8(%esp)
  800b41:	00 
  800b42:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b49:	00 
  800b4a:	c7 04 24 ae 20 80 00 	movl   $0x8020ae,(%esp)
  800b51:	e8 10 06 00 00       	call   801166 <_panic>
	assert(r <= PGSIZE);
  800b56:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b5b:	7e 24                	jle    800b81 <devfile_read+0x84>
  800b5d:	c7 44 24 0c d5 20 80 	movl   $0x8020d5,0xc(%esp)
  800b64:	00 
  800b65:	c7 44 24 08 c0 20 80 	movl   $0x8020c0,0x8(%esp)
  800b6c:	00 
  800b6d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b74:	00 
  800b75:	c7 04 24 ae 20 80 00 	movl   $0x8020ae,(%esp)
  800b7c:	e8 e5 05 00 00       	call   801166 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b85:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b8c:	00 
  800b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b90:	89 04 24             	mov    %eax,(%esp)
  800b93:	e8 8c 0e 00 00       	call   801a24 <memmove>
}
  800b98:	89 d8                	mov    %ebx,%eax
  800b9a:	83 c4 10             	add    $0x10,%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <open>:
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 24             	sub    $0x24,%esp
  800ba8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800bab:	89 1c 24             	mov    %ebx,(%esp)
  800bae:	e8 9d 0c 00 00       	call   801850 <strlen>
  800bb3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bb8:	7f 60                	jg     800c1a <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  800bba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bbd:	89 04 24             	mov    %eax,(%esp)
  800bc0:	e8 52 f8 ff ff       	call   800417 <fd_alloc>
  800bc5:	89 c2                	mov    %eax,%edx
  800bc7:	85 d2                	test   %edx,%edx
  800bc9:	78 54                	js     800c1f <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  800bcb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bcf:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bd6:	e8 ac 0c 00 00       	call   801887 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bde:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800be3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be6:	b8 01 00 00 00       	mov    $0x1,%eax
  800beb:	e8 de fd ff ff       	call   8009ce <fsipc>
  800bf0:	89 c3                	mov    %eax,%ebx
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	79 17                	jns    800c0d <open+0x6c>
		fd_close(fd, 0);
  800bf6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800bfd:	00 
  800bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c01:	89 04 24             	mov    %eax,(%esp)
  800c04:	e8 08 f9 ff ff       	call   800511 <fd_close>
		return r;
  800c09:	89 d8                	mov    %ebx,%eax
  800c0b:	eb 12                	jmp    800c1f <open+0x7e>
	return fd2num(fd);
  800c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c10:	89 04 24             	mov    %eax,(%esp)
  800c13:	e8 d8 f7 ff ff       	call   8003f0 <fd2num>
  800c18:	eb 05                	jmp    800c1f <open+0x7e>
		return -E_BAD_PATH;
  800c1a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  800c1f:	83 c4 24             	add    $0x24,%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 08 00 00 00       	mov    $0x8,%eax
  800c35:	e8 94 fd ff ff       	call   8009ce <fsipc>
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 10             	sub    $0x10,%esp
  800c44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	89 04 24             	mov    %eax,(%esp)
  800c4d:	e8 ae f7 ff ff       	call   800400 <fd2data>
  800c52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c54:	c7 44 24 04 e1 20 80 	movl   $0x8020e1,0x4(%esp)
  800c5b:	00 
  800c5c:	89 1c 24             	mov    %ebx,(%esp)
  800c5f:	e8 23 0c 00 00       	call   801887 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c64:	8b 46 04             	mov    0x4(%esi),%eax
  800c67:	2b 06                	sub    (%esi),%eax
  800c69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c6f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c76:	00 00 00 
	stat->st_dev = &devpipe;
  800c79:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800c80:	30 80 00 
	return 0;
}
  800c83:	b8 00 00 00 00       	mov    $0x0,%eax
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	53                   	push   %ebx
  800c93:	83 ec 14             	sub    $0x14,%esp
  800c96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ca4:	e8 7c f5 ff ff       	call   800225 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800ca9:	89 1c 24             	mov    %ebx,(%esp)
  800cac:	e8 4f f7 ff ff       	call   800400 <fd2data>
  800cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cbc:	e8 64 f5 ff ff       	call   800225 <sys_page_unmap>
}
  800cc1:	83 c4 14             	add    $0x14,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <_pipeisclosed>:
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 2c             	sub    $0x2c,%esp
  800cd0:	89 c6                	mov    %eax,%esi
  800cd2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  800cd5:	a1 08 40 80 00       	mov    0x804008,%eax
  800cda:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cdd:	89 34 24             	mov    %esi,(%esp)
  800ce0:	e8 02 10 00 00       	call   801ce7 <pageref>
  800ce5:	89 c7                	mov    %eax,%edi
  800ce7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cea:	89 04 24             	mov    %eax,(%esp)
  800ced:	e8 f5 0f 00 00       	call   801ce7 <pageref>
  800cf2:	39 c7                	cmp    %eax,%edi
  800cf4:	0f 94 c2             	sete   %dl
  800cf7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800cfa:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  800d00:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800d03:	39 fb                	cmp    %edi,%ebx
  800d05:	74 21                	je     800d28 <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  800d07:	84 d2                	test   %dl,%dl
  800d09:	74 ca                	je     800cd5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d0b:	8b 51 58             	mov    0x58(%ecx),%edx
  800d0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d12:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d1a:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  800d21:	e8 39 05 00 00       	call   80125f <cprintf>
  800d26:	eb ad                	jmp    800cd5 <_pipeisclosed+0xe>
}
  800d28:	83 c4 2c             	add    $0x2c,%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <devpipe_write>:
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 1c             	sub    $0x1c,%esp
  800d39:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d3c:	89 34 24             	mov    %esi,(%esp)
  800d3f:	e8 bc f6 ff ff       	call   800400 <fd2data>
  800d44:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d46:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4b:	eb 45                	jmp    800d92 <devpipe_write+0x62>
			if (_pipeisclosed(fd, p))
  800d4d:	89 da                	mov    %ebx,%edx
  800d4f:	89 f0                	mov    %esi,%eax
  800d51:	e8 71 ff ff ff       	call   800cc7 <_pipeisclosed>
  800d56:	85 c0                	test   %eax,%eax
  800d58:	75 41                	jne    800d9b <devpipe_write+0x6b>
			sys_yield();
  800d5a:	e8 00 f4 ff ff       	call   80015f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d5f:	8b 43 04             	mov    0x4(%ebx),%eax
  800d62:	8b 0b                	mov    (%ebx),%ecx
  800d64:	8d 51 20             	lea    0x20(%ecx),%edx
  800d67:	39 d0                	cmp    %edx,%eax
  800d69:	73 e2                	jae    800d4d <devpipe_write+0x1d>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d72:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d75:	99                   	cltd   
  800d76:	c1 ea 1b             	shr    $0x1b,%edx
  800d79:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d7c:	83 e1 1f             	and    $0x1f,%ecx
  800d7f:	29 d1                	sub    %edx,%ecx
  800d81:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d85:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800d89:	83 c0 01             	add    $0x1,%eax
  800d8c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d8f:	83 c7 01             	add    $0x1,%edi
  800d92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d95:	75 c8                	jne    800d5f <devpipe_write+0x2f>
	return i;
  800d97:	89 f8                	mov    %edi,%eax
  800d99:	eb 05                	jmp    800da0 <devpipe_write+0x70>
				return 0;
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da0:	83 c4 1c             	add    $0x1c,%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <devpipe_read>:
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 1c             	sub    $0x1c,%esp
  800db1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800db4:	89 3c 24             	mov    %edi,(%esp)
  800db7:	e8 44 f6 ff ff       	call   800400 <fd2data>
  800dbc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800dbe:	be 00 00 00 00       	mov    $0x0,%esi
  800dc3:	eb 3d                	jmp    800e02 <devpipe_read+0x5a>
			if (i > 0)
  800dc5:	85 f6                	test   %esi,%esi
  800dc7:	74 04                	je     800dcd <devpipe_read+0x25>
				return i;
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	eb 43                	jmp    800e10 <devpipe_read+0x68>
			if (_pipeisclosed(fd, p))
  800dcd:	89 da                	mov    %ebx,%edx
  800dcf:	89 f8                	mov    %edi,%eax
  800dd1:	e8 f1 fe ff ff       	call   800cc7 <_pipeisclosed>
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	75 31                	jne    800e0b <devpipe_read+0x63>
			sys_yield();
  800dda:	e8 80 f3 ff ff       	call   80015f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800ddf:	8b 03                	mov    (%ebx),%eax
  800de1:	3b 43 04             	cmp    0x4(%ebx),%eax
  800de4:	74 df                	je     800dc5 <devpipe_read+0x1d>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800de6:	99                   	cltd   
  800de7:	c1 ea 1b             	shr    $0x1b,%edx
  800dea:	01 d0                	add    %edx,%eax
  800dec:	83 e0 1f             	and    $0x1f,%eax
  800def:	29 d0                	sub    %edx,%eax
  800df1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800dfc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800dff:	83 c6 01             	add    $0x1,%esi
  800e02:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e05:	75 d8                	jne    800ddf <devpipe_read+0x37>
	return i;
  800e07:	89 f0                	mov    %esi,%eax
  800e09:	eb 05                	jmp    800e10 <devpipe_read+0x68>
				return 0;
  800e0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <pipe>:
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e23:	89 04 24             	mov    %eax,(%esp)
  800e26:	e8 ec f5 ff ff       	call   800417 <fd_alloc>
  800e2b:	89 c2                	mov    %eax,%edx
  800e2d:	85 d2                	test   %edx,%edx
  800e2f:	0f 88 4d 01 00 00    	js     800f82 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e35:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e3c:	00 
  800e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4b:	e8 2e f3 ff ff       	call   80017e <sys_page_alloc>
  800e50:	89 c2                	mov    %eax,%edx
  800e52:	85 d2                	test   %edx,%edx
  800e54:	0f 88 28 01 00 00    	js     800f82 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  800e5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e5d:	89 04 24             	mov    %eax,(%esp)
  800e60:	e8 b2 f5 ff ff       	call   800417 <fd_alloc>
  800e65:	89 c3                	mov    %eax,%ebx
  800e67:	85 c0                	test   %eax,%eax
  800e69:	0f 88 fe 00 00 00    	js     800f6d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e6f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e76:	00 
  800e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e85:	e8 f4 f2 ff ff       	call   80017e <sys_page_alloc>
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	0f 88 d9 00 00 00    	js     800f6d <pipe+0x155>
	va = fd2data(fd0);
  800e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e97:	89 04 24             	mov    %eax,(%esp)
  800e9a:	e8 61 f5 ff ff       	call   800400 <fd2data>
  800e9f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ea1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ea8:	00 
  800ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ead:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb4:	e8 c5 f2 ff ff       	call   80017e <sys_page_alloc>
  800eb9:	89 c3                	mov    %eax,%ebx
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	0f 88 97 00 00 00    	js     800f5a <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec6:	89 04 24             	mov    %eax,(%esp)
  800ec9:	e8 32 f5 ff ff       	call   800400 <fd2data>
  800ece:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ed5:	00 
  800ed6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee1:	00 
  800ee2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eed:	e8 e0 f2 ff ff       	call   8001d2 <sys_page_map>
  800ef2:	89 c3                	mov    %eax,%ebx
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 52                	js     800f4a <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  800ef8:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f01:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f06:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800f0d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f16:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f25:	89 04 24             	mov    %eax,(%esp)
  800f28:	e8 c3 f4 ff ff       	call   8003f0 <fd2num>
  800f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f30:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f35:	89 04 24             	mov    %eax,(%esp)
  800f38:	e8 b3 f4 ff ff       	call   8003f0 <fd2num>
  800f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f40:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
  800f48:	eb 38                	jmp    800f82 <pipe+0x16a>
	sys_page_unmap(0, va);
  800f4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f55:	e8 cb f2 ff ff       	call   800225 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  800f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f68:	e8 b8 f2 ff ff       	call   800225 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  800f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f7b:	e8 a5 f2 ff ff       	call   800225 <sys_page_unmap>
  800f80:	89 d8                	mov    %ebx,%eax
}
  800f82:	83 c4 30             	add    $0x30,%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <pipeisclosed>:
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	89 04 24             	mov    %eax,(%esp)
  800f9c:	e8 c5 f4 ff ff       	call   800466 <fd_lookup>
  800fa1:	89 c2                	mov    %eax,%edx
  800fa3:	85 d2                	test   %edx,%edx
  800fa5:	78 15                	js     800fbc <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  800fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800faa:	89 04 24             	mov    %eax,(%esp)
  800fad:	e8 4e f4 ff ff       	call   800400 <fd2data>
	return _pipeisclosed(fd, p);
  800fb2:	89 c2                	mov    %eax,%edx
  800fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb7:	e8 0b fd ff ff       	call   800cc7 <_pipeisclosed>
}
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fd0:	c7 44 24 04 00 21 80 	movl   $0x802100,0x4(%esp)
  800fd7:	00 
  800fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 a4 08 00 00       	call   801887 <strcpy>
	return 0;
}
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <devcons_write>:
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ffb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801001:	eb 31                	jmp    801034 <devcons_write+0x4a>
		m = n - tot;
  801003:	8b 75 10             	mov    0x10(%ebp),%esi
  801006:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801008:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  80100b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801010:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801013:	89 74 24 08          	mov    %esi,0x8(%esp)
  801017:	03 45 0c             	add    0xc(%ebp),%eax
  80101a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101e:	89 3c 24             	mov    %edi,(%esp)
  801021:	e8 fe 09 00 00       	call   801a24 <memmove>
		sys_cputs(buf, m);
  801026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102a:	89 3c 24             	mov    %edi,(%esp)
  80102d:	e8 7f f0 ff ff       	call   8000b1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801032:	01 f3                	add    %esi,%ebx
  801034:	89 d8                	mov    %ebx,%eax
  801036:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801039:	72 c8                	jb     801003 <devcons_write+0x19>
}
  80103b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <devcons_read>:
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80104c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801051:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801055:	75 07                	jne    80105e <devcons_read+0x18>
  801057:	eb 2a                	jmp    801083 <devcons_read+0x3d>
		sys_yield();
  801059:	e8 01 f1 ff ff       	call   80015f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80105e:	66 90                	xchg   %ax,%ax
  801060:	e8 6a f0 ff ff       	call   8000cf <sys_cgetc>
  801065:	85 c0                	test   %eax,%eax
  801067:	74 f0                	je     801059 <devcons_read+0x13>
	if (c < 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 16                	js     801083 <devcons_read+0x3d>
	if (c == 0x04)	// ctl-d is eof
  80106d:	83 f8 04             	cmp    $0x4,%eax
  801070:	74 0c                	je     80107e <devcons_read+0x38>
	*(char*)vbuf = c;
  801072:	8b 55 0c             	mov    0xc(%ebp),%edx
  801075:	88 02                	mov    %al,(%edx)
	return 1;
  801077:	b8 01 00 00 00       	mov    $0x1,%eax
  80107c:	eb 05                	jmp    801083 <devcons_read+0x3d>
		return 0;
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <cputchar>:
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801091:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801098:	00 
  801099:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80109c:	89 04 24             	mov    %eax,(%esp)
  80109f:	e8 0d f0 ff ff       	call   8000b1 <sys_cputs>
}
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <getchar>:
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8010ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010b3:	00 
  8010b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c2:	e8 2e f6 ff ff       	call   8006f5 <read>
	if (r < 0)
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 0f                	js     8010da <getchar+0x34>
	if (r < 1)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	7e 06                	jle    8010d5 <getchar+0x2f>
	return c;
  8010cf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010d3:	eb 05                	jmp    8010da <getchar+0x34>
		return -E_EOF;
  8010d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <iscons>:
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	89 04 24             	mov    %eax,(%esp)
  8010ef:	e8 72 f3 ff ff       	call   800466 <fd_lookup>
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 11                	js     801109 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8010f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fb:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801101:	39 10                	cmp    %edx,(%eax)
  801103:	0f 94 c0             	sete   %al
  801106:	0f b6 c0             	movzbl %al,%eax
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <opencons>:
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801114:	89 04 24             	mov    %eax,(%esp)
  801117:	e8 fb f2 ff ff       	call   800417 <fd_alloc>
		return r;
  80111c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 40                	js     801162 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801122:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801129:	00 
  80112a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801138:	e8 41 f0 ff ff       	call   80017e <sys_page_alloc>
		return r;
  80113d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 1f                	js     801162 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801143:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801151:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801158:	89 04 24             	mov    %eax,(%esp)
  80115b:	e8 90 f2 ff ff       	call   8003f0 <fd2num>
  801160:	89 c2                	mov    %eax,%edx
}
  801162:	89 d0                	mov    %edx,%eax
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80116e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801171:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801177:	e8 c4 ef ff ff       	call   800140 <sys_getenvid>
  80117c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801183:	8b 55 08             	mov    0x8(%ebp),%edx
  801186:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80118a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80118e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801192:	c7 04 24 0c 21 80 00 	movl   $0x80210c,(%esp)
  801199:	e8 c1 00 00 00       	call   80125f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80119e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a5:	89 04 24             	mov    %eax,(%esp)
  8011a8:	e8 51 00 00 00       	call   8011fe <vcprintf>
	cprintf("\n");
  8011ad:	c7 04 24 f9 20 80 00 	movl   $0x8020f9,(%esp)
  8011b4:	e8 a6 00 00 00       	call   80125f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011b9:	cc                   	int3   
  8011ba:	eb fd                	jmp    8011b9 <_panic+0x53>

008011bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 14             	sub    $0x14,%esp
  8011c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011c6:	8b 13                	mov    (%ebx),%edx
  8011c8:	8d 42 01             	lea    0x1(%edx),%eax
  8011cb:	89 03                	mov    %eax,(%ebx)
  8011cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8011d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011d9:	75 19                	jne    8011f4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8011db:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011e2:	00 
  8011e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011e6:	89 04 24             	mov    %eax,(%esp)
  8011e9:	e8 c3 ee ff ff       	call   8000b1 <sys_cputs>
		b->idx = 0;
  8011ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8011f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8011f8:	83 c4 14             	add    $0x14,%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801207:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80120e:	00 00 00 
	b.cnt = 0;
  801211:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801218:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80121b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801222:	8b 45 08             	mov    0x8(%ebp),%eax
  801225:	89 44 24 08          	mov    %eax,0x8(%esp)
  801229:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80122f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801233:	c7 04 24 bc 11 80 00 	movl   $0x8011bc,(%esp)
  80123a:	e8 af 01 00 00       	call   8013ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80123f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801245:	89 44 24 04          	mov    %eax,0x4(%esp)
  801249:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 5a ee ff ff       	call   8000b1 <sys_cputs>

	return b.cnt;
}
  801257:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801265:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126c:	8b 45 08             	mov    0x8(%ebp),%eax
  80126f:	89 04 24             	mov    %eax,(%esp)
  801272:	e8 87 ff ff ff       	call   8011fe <vcprintf>
	va_end(ap);

	return cnt;
}
  801277:	c9                   	leave  
  801278:	c3                   	ret    
  801279:	66 90                	xchg   %ax,%ax
  80127b:	66 90                	xchg   %ax,%ax
  80127d:	66 90                	xchg   %ax,%ax
  80127f:	90                   	nop

00801280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 3c             	sub    $0x3c,%esp
  801289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80128c:	89 d7                	mov    %edx,%edi
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801294:	8b 45 0c             	mov    0xc(%ebp),%eax
  801297:	89 c3                	mov    %eax,%ebx
  801299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80129c:	8b 45 10             	mov    0x10(%ebp),%eax
  80129f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012ad:	39 d9                	cmp    %ebx,%ecx
  8012af:	72 05                	jb     8012b6 <printnum+0x36>
  8012b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012b4:	77 69                	ja     80131f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012bd:	83 ee 01             	sub    $0x1,%esi
  8012c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012d0:	89 c3                	mov    %eax,%ebx
  8012d2:	89 d6                	mov    %edx,%esi
  8012d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e5:	89 04 24             	mov    %eax,(%esp)
  8012e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	e8 3c 0a 00 00       	call   801d30 <__udivdi3>
  8012f4:	89 d9                	mov    %ebx,%ecx
  8012f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012fe:	89 04 24             	mov    %eax,(%esp)
  801301:	89 54 24 04          	mov    %edx,0x4(%esp)
  801305:	89 fa                	mov    %edi,%edx
  801307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80130a:	e8 71 ff ff ff       	call   801280 <printnum>
  80130f:	eb 1b                	jmp    80132c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801315:	8b 45 18             	mov    0x18(%ebp),%eax
  801318:	89 04 24             	mov    %eax,(%esp)
  80131b:	ff d3                	call   *%ebx
  80131d:	eb 03                	jmp    801322 <printnum+0xa2>
  80131f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  801322:	83 ee 01             	sub    $0x1,%esi
  801325:	85 f6                	test   %esi,%esi
  801327:	7f e8                	jg     801311 <printnum+0x91>
  801329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80132c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801330:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801337:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80133a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80134b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134f:	e8 0c 0b 00 00       	call   801e60 <__umoddi3>
  801354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801358:	0f be 80 2f 21 80 00 	movsbl 0x80212f(%eax),%eax
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801365:	ff d0                	call   *%eax
}
  801367:	83 c4 3c             	add    $0x3c,%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801372:	83 fa 01             	cmp    $0x1,%edx
  801375:	7e 0e                	jle    801385 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801377:	8b 10                	mov    (%eax),%edx
  801379:	8d 4a 08             	lea    0x8(%edx),%ecx
  80137c:	89 08                	mov    %ecx,(%eax)
  80137e:	8b 02                	mov    (%edx),%eax
  801380:	8b 52 04             	mov    0x4(%edx),%edx
  801383:	eb 22                	jmp    8013a7 <getuint+0x38>
	else if (lflag)
  801385:	85 d2                	test   %edx,%edx
  801387:	74 10                	je     801399 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801389:	8b 10                	mov    (%eax),%edx
  80138b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80138e:	89 08                	mov    %ecx,(%eax)
  801390:	8b 02                	mov    (%edx),%eax
  801392:	ba 00 00 00 00       	mov    $0x0,%edx
  801397:	eb 0e                	jmp    8013a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801399:	8b 10                	mov    (%eax),%edx
  80139b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80139e:	89 08                	mov    %ecx,(%eax)
  8013a0:	8b 02                	mov    (%edx),%eax
  8013a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8013b3:	8b 10                	mov    (%eax),%edx
  8013b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8013b8:	73 0a                	jae    8013c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8013ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013bd:	89 08                	mov    %ecx,(%eax)
  8013bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c2:	88 02                	mov    %al,(%edx)
}
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <printfmt>:
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8013cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	89 04 24             	mov    %eax,(%esp)
  8013e7:	e8 02 00 00 00       	call   8013ee <vprintfmt>
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <vprintfmt>:
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 3c             	sub    $0x3c,%esp
  8013f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013fd:	eb 1f                	jmp    80141e <vprintfmt+0x30>
			if (ch == '\0'){
  8013ff:	85 c0                	test   %eax,%eax
  801401:	75 0f                	jne    801412 <vprintfmt+0x24>
				color = 0x0100;
  801403:	c7 05 04 40 80 00 00 	movl   $0x100,0x804004
  80140a:	01 00 00 
  80140d:	e9 b3 03 00 00       	jmp    8017c5 <vprintfmt+0x3d7>
			putch(ch, putdat);
  801412:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801416:	89 04 24             	mov    %eax,(%esp)
  801419:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80141c:	89 f3                	mov    %esi,%ebx
  80141e:	8d 73 01             	lea    0x1(%ebx),%esi
  801421:	0f b6 03             	movzbl (%ebx),%eax
  801424:	83 f8 25             	cmp    $0x25,%eax
  801427:	75 d6                	jne    8013ff <vprintfmt+0x11>
  801429:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80142d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801434:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80143b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801442:	ba 00 00 00 00       	mov    $0x0,%edx
  801447:	eb 1d                	jmp    801466 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801449:	89 de                	mov    %ebx,%esi
			padc = '-';
  80144b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80144f:	eb 15                	jmp    801466 <vprintfmt+0x78>
		switch (ch = *(unsigned char *) fmt++) {
  801451:	89 de                	mov    %ebx,%esi
			padc = '0';
  801453:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801457:	eb 0d                	jmp    801466 <vprintfmt+0x78>
				width = precision, precision = -1;
  801459:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80145c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80145f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801466:	8d 5e 01             	lea    0x1(%esi),%ebx
  801469:	0f b6 0e             	movzbl (%esi),%ecx
  80146c:	0f b6 c1             	movzbl %cl,%eax
  80146f:	83 e9 23             	sub    $0x23,%ecx
  801472:	80 f9 55             	cmp    $0x55,%cl
  801475:	0f 87 2a 03 00 00    	ja     8017a5 <vprintfmt+0x3b7>
  80147b:	0f b6 c9             	movzbl %cl,%ecx
  80147e:	ff 24 8d 80 22 80 00 	jmp    *0x802280(,%ecx,4)
  801485:	89 de                	mov    %ebx,%esi
  801487:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  80148c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80148f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801493:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801496:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801499:	83 fb 09             	cmp    $0x9,%ebx
  80149c:	77 36                	ja     8014d4 <vprintfmt+0xe6>
			for (precision = 0; ; ++fmt) {
  80149e:	83 c6 01             	add    $0x1,%esi
			}
  8014a1:	eb e9                	jmp    80148c <vprintfmt+0x9e>
			precision = va_arg(ap, int);
  8014a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8014a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8014ac:	8b 00                	mov    (%eax),%eax
  8014ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014b1:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8014b3:	eb 22                	jmp    8014d7 <vprintfmt+0xe9>
  8014b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014b8:	85 c9                	test   %ecx,%ecx
  8014ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bf:	0f 49 c1             	cmovns %ecx,%eax
  8014c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014c5:	89 de                	mov    %ebx,%esi
  8014c7:	eb 9d                	jmp    801466 <vprintfmt+0x78>
  8014c9:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8014cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8014d2:	eb 92                	jmp    801466 <vprintfmt+0x78>
  8014d4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  8014d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014db:	79 89                	jns    801466 <vprintfmt+0x78>
  8014dd:	e9 77 ff ff ff       	jmp    801459 <vprintfmt+0x6b>
			lflag++;
  8014e2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8014e5:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8014e7:	e9 7a ff ff ff       	jmp    801466 <vprintfmt+0x78>
			putch(va_arg(ap, int), putdat);
  8014ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ef:	8d 50 04             	lea    0x4(%eax),%edx
  8014f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014f9:	8b 00                	mov    (%eax),%eax
  8014fb:	89 04 24             	mov    %eax,(%esp)
  8014fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  801501:	e9 18 ff ff ff       	jmp    80141e <vprintfmt+0x30>
			err = va_arg(ap, int);
  801506:	8b 45 14             	mov    0x14(%ebp),%eax
  801509:	8d 50 04             	lea    0x4(%eax),%edx
  80150c:	89 55 14             	mov    %edx,0x14(%ebp)
  80150f:	8b 00                	mov    (%eax),%eax
  801511:	99                   	cltd   
  801512:	31 d0                	xor    %edx,%eax
  801514:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801516:	83 f8 0f             	cmp    $0xf,%eax
  801519:	7f 0b                	jg     801526 <vprintfmt+0x138>
  80151b:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  801522:	85 d2                	test   %edx,%edx
  801524:	75 20                	jne    801546 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
  801526:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80152a:	c7 44 24 08 47 21 80 	movl   $0x802147,0x8(%esp)
  801531:	00 
  801532:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	89 04 24             	mov    %eax,(%esp)
  80153c:	e8 85 fe ff ff       	call   8013c6 <printfmt>
  801541:	e9 d8 fe ff ff       	jmp    80141e <vprintfmt+0x30>
				printfmt(putch, putdat, "%s", p);
  801546:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80154a:	c7 44 24 08 d2 20 80 	movl   $0x8020d2,0x8(%esp)
  801551:	00 
  801552:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	89 04 24             	mov    %eax,(%esp)
  80155c:	e8 65 fe ff ff       	call   8013c6 <printfmt>
  801561:	e9 b8 fe ff ff       	jmp    80141e <vprintfmt+0x30>
		switch (ch = *(unsigned char *) fmt++) {
  801566:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801569:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80156c:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8d 50 04             	lea    0x4(%eax),%edx
  801575:	89 55 14             	mov    %edx,0x14(%ebp)
  801578:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80157a:	85 f6                	test   %esi,%esi
  80157c:	b8 40 21 80 00       	mov    $0x802140,%eax
  801581:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801584:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801588:	0f 84 97 00 00 00    	je     801625 <vprintfmt+0x237>
  80158e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801592:	0f 8e 9b 00 00 00    	jle    801633 <vprintfmt+0x245>
				for (width -= strnlen(p, precision); width > 0; width--)
  801598:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80159c:	89 34 24             	mov    %esi,(%esp)
  80159f:	e8 c4 02 00 00       	call   801868 <strnlen>
  8015a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015a7:	29 c2                	sub    %eax,%edx
  8015a9:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8015ac:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8015b3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8015b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015bc:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8015be:	eb 0f                	jmp    8015cf <vprintfmt+0x1e1>
					putch(padc, putdat);
  8015c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015c7:	89 04 24             	mov    %eax,(%esp)
  8015ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8015cc:	83 eb 01             	sub    $0x1,%ebx
  8015cf:	85 db                	test   %ebx,%ebx
  8015d1:	7f ed                	jg     8015c0 <vprintfmt+0x1d2>
  8015d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015d9:	85 d2                	test   %edx,%edx
  8015db:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e0:	0f 49 c2             	cmovns %edx,%eax
  8015e3:	29 c2                	sub    %eax,%edx
  8015e5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015e8:	89 d7                	mov    %edx,%edi
  8015ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015ed:	eb 50                	jmp    80163f <vprintfmt+0x251>
				if (altflag && (ch < ' ' || ch > '~'))
  8015ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015f3:	74 1e                	je     801613 <vprintfmt+0x225>
  8015f5:	0f be d2             	movsbl %dl,%edx
  8015f8:	83 ea 20             	sub    $0x20,%edx
  8015fb:	83 fa 5e             	cmp    $0x5e,%edx
  8015fe:	76 13                	jbe    801613 <vprintfmt+0x225>
					putch('?', putdat);
  801600:	8b 45 0c             	mov    0xc(%ebp),%eax
  801603:	89 44 24 04          	mov    %eax,0x4(%esp)
  801607:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80160e:	ff 55 08             	call   *0x8(%ebp)
  801611:	eb 0d                	jmp    801620 <vprintfmt+0x232>
					putch(ch, putdat);
  801613:	8b 55 0c             	mov    0xc(%ebp),%edx
  801616:	89 54 24 04          	mov    %edx,0x4(%esp)
  80161a:	89 04 24             	mov    %eax,(%esp)
  80161d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801620:	83 ef 01             	sub    $0x1,%edi
  801623:	eb 1a                	jmp    80163f <vprintfmt+0x251>
  801625:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801628:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80162b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80162e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801631:	eb 0c                	jmp    80163f <vprintfmt+0x251>
  801633:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801636:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801639:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80163c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80163f:	83 c6 01             	add    $0x1,%esi
  801642:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801646:	0f be c2             	movsbl %dl,%eax
  801649:	85 c0                	test   %eax,%eax
  80164b:	74 27                	je     801674 <vprintfmt+0x286>
  80164d:	85 db                	test   %ebx,%ebx
  80164f:	78 9e                	js     8015ef <vprintfmt+0x201>
  801651:	83 eb 01             	sub    $0x1,%ebx
  801654:	79 99                	jns    8015ef <vprintfmt+0x201>
  801656:	89 f8                	mov    %edi,%eax
  801658:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80165b:	8b 75 08             	mov    0x8(%ebp),%esi
  80165e:	89 c3                	mov    %eax,%ebx
  801660:	eb 1a                	jmp    80167c <vprintfmt+0x28e>
				putch(' ', putdat);
  801662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801666:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80166d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80166f:	83 eb 01             	sub    $0x1,%ebx
  801672:	eb 08                	jmp    80167c <vprintfmt+0x28e>
  801674:	89 fb                	mov    %edi,%ebx
  801676:	8b 75 08             	mov    0x8(%ebp),%esi
  801679:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80167c:	85 db                	test   %ebx,%ebx
  80167e:	7f e2                	jg     801662 <vprintfmt+0x274>
  801680:	89 75 08             	mov    %esi,0x8(%ebp)
  801683:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801686:	e9 93 fd ff ff       	jmp    80141e <vprintfmt+0x30>
	if (lflag >= 2)
  80168b:	83 fa 01             	cmp    $0x1,%edx
  80168e:	7e 16                	jle    8016a6 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  801690:	8b 45 14             	mov    0x14(%ebp),%eax
  801693:	8d 50 08             	lea    0x8(%eax),%edx
  801696:	89 55 14             	mov    %edx,0x14(%ebp)
  801699:	8b 50 04             	mov    0x4(%eax),%edx
  80169c:	8b 00                	mov    (%eax),%eax
  80169e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8016a4:	eb 32                	jmp    8016d8 <vprintfmt+0x2ea>
	else if (lflag)
  8016a6:	85 d2                	test   %edx,%edx
  8016a8:	74 18                	je     8016c2 <vprintfmt+0x2d4>
		return va_arg(*ap, long);
  8016aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ad:	8d 50 04             	lea    0x4(%eax),%edx
  8016b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b3:	8b 30                	mov    (%eax),%esi
  8016b5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016b8:	89 f0                	mov    %esi,%eax
  8016ba:	c1 f8 1f             	sar    $0x1f,%eax
  8016bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016c0:	eb 16                	jmp    8016d8 <vprintfmt+0x2ea>
		return va_arg(*ap, int);
  8016c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c5:	8d 50 04             	lea    0x4(%eax),%edx
  8016c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016cb:	8b 30                	mov    (%eax),%esi
  8016cd:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016d0:	89 f0                	mov    %esi,%eax
  8016d2:	c1 f8 1f             	sar    $0x1f,%eax
  8016d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  8016d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  8016de:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8016e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016e7:	0f 89 80 00 00 00    	jns    80176d <vprintfmt+0x37f>
				putch('-', putdat);
  8016ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016f1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016f8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8016fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801701:	f7 d8                	neg    %eax
  801703:	83 d2 00             	adc    $0x0,%edx
  801706:	f7 da                	neg    %edx
			base = 10;
  801708:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80170d:	eb 5e                	jmp    80176d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80170f:	8d 45 14             	lea    0x14(%ebp),%eax
  801712:	e8 58 fc ff ff       	call   80136f <getuint>
			base = 10;
  801717:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80171c:	eb 4f                	jmp    80176d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  80171e:	8d 45 14             	lea    0x14(%ebp),%eax
  801721:	e8 49 fc ff ff       	call   80136f <getuint>
            base = 8;
  801726:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  80172b:	eb 40                	jmp    80176d <vprintfmt+0x37f>
			putch('0', putdat);
  80172d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801731:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801738:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80173b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80173f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801746:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  801749:	8b 45 14             	mov    0x14(%ebp),%eax
  80174c:	8d 50 04             	lea    0x4(%eax),%edx
  80174f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801752:	8b 00                	mov    (%eax),%eax
  801754:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  801759:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80175e:	eb 0d                	jmp    80176d <vprintfmt+0x37f>
			num = getuint(&ap, lflag);
  801760:	8d 45 14             	lea    0x14(%ebp),%eax
  801763:	e8 07 fc ff ff       	call   80136f <getuint>
			base = 16;
  801768:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80176d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801771:	89 74 24 10          	mov    %esi,0x10(%esp)
  801775:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801778:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80177c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801780:	89 04 24             	mov    %eax,(%esp)
  801783:	89 54 24 04          	mov    %edx,0x4(%esp)
  801787:	89 fa                	mov    %edi,%edx
  801789:	8b 45 08             	mov    0x8(%ebp),%eax
  80178c:	e8 ef fa ff ff       	call   801280 <printnum>
			break;
  801791:	e9 88 fc ff ff       	jmp    80141e <vprintfmt+0x30>
			putch(ch, putdat);
  801796:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80179a:	89 04 24             	mov    %eax,(%esp)
  80179d:	ff 55 08             	call   *0x8(%ebp)
			break;
  8017a0:	e9 79 fc ff ff       	jmp    80141e <vprintfmt+0x30>
			putch('%', putdat);
  8017a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017a9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017b0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017b3:	89 f3                	mov    %esi,%ebx
  8017b5:	eb 03                	jmp    8017ba <vprintfmt+0x3cc>
  8017b7:	83 eb 01             	sub    $0x1,%ebx
  8017ba:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017be:	75 f7                	jne    8017b7 <vprintfmt+0x3c9>
  8017c0:	e9 59 fc ff ff       	jmp    80141e <vprintfmt+0x30>
}
  8017c5:	83 c4 3c             	add    $0x3c,%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5f                   	pop    %edi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 28             	sub    $0x28,%esp
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	74 30                	je     80181e <vsnprintf+0x51>
  8017ee:	85 d2                	test   %edx,%edx
  8017f0:	7e 2c                	jle    80181e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801803:	89 44 24 04          	mov    %eax,0x4(%esp)
  801807:	c7 04 24 a9 13 80 00 	movl   $0x8013a9,(%esp)
  80180e:	e8 db fb ff ff       	call   8013ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801813:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801816:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181c:	eb 05                	jmp    801823 <vsnprintf+0x56>
		return -E_INVAL;
  80181e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80182b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80182e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801832:	8b 45 10             	mov    0x10(%ebp),%eax
  801835:	89 44 24 08          	mov    %eax,0x8(%esp)
  801839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	89 04 24             	mov    %eax,(%esp)
  801846:	e8 82 ff ff ff       	call   8017cd <vsnprintf>
	va_end(ap);

	return rc;
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    
  80184d:	66 90                	xchg   %ax,%ax
  80184f:	90                   	nop

00801850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801856:	b8 00 00 00 00       	mov    $0x0,%eax
  80185b:	eb 03                	jmp    801860 <strlen+0x10>
		n++;
  80185d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801860:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801864:	75 f7                	jne    80185d <strlen+0xd>
	return n;
}
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801871:	b8 00 00 00 00       	mov    $0x0,%eax
  801876:	eb 03                	jmp    80187b <strnlen+0x13>
		n++;
  801878:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80187b:	39 d0                	cmp    %edx,%eax
  80187d:	74 06                	je     801885 <strnlen+0x1d>
  80187f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801883:	75 f3                	jne    801878 <strnlen+0x10>
	return n;
}
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801891:	89 c2                	mov    %eax,%edx
  801893:	83 c2 01             	add    $0x1,%edx
  801896:	83 c1 01             	add    $0x1,%ecx
  801899:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80189d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018a0:	84 db                	test   %bl,%bl
  8018a2:	75 ef                	jne    801893 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8018a4:	5b                   	pop    %ebx
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 08             	sub    $0x8,%esp
  8018ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018b1:	89 1c 24             	mov    %ebx,(%esp)
  8018b4:	e8 97 ff ff ff       	call   801850 <strlen>
	strcpy(dst + len, src);
  8018b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018c0:	01 d8                	add    %ebx,%eax
  8018c2:	89 04 24             	mov    %eax,(%esp)
  8018c5:	e8 bd ff ff ff       	call   801887 <strcpy>
	return dst;
}
  8018ca:	89 d8                	mov    %ebx,%eax
  8018cc:	83 c4 08             	add    $0x8,%esp
  8018cf:	5b                   	pop    %ebx
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
  8018d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018dd:	89 f3                	mov    %esi,%ebx
  8018df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018e2:	89 f2                	mov    %esi,%edx
  8018e4:	eb 0f                	jmp    8018f5 <strncpy+0x23>
		*dst++ = *src;
  8018e6:	83 c2 01             	add    $0x1,%edx
  8018e9:	0f b6 01             	movzbl (%ecx),%eax
  8018ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8018ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8018f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8018f5:	39 da                	cmp    %ebx,%edx
  8018f7:	75 ed                	jne    8018e6 <strncpy+0x14>
	}
	return ret;
}
  8018f9:	89 f0                	mov    %esi,%eax
  8018fb:	5b                   	pop    %ebx
  8018fc:	5e                   	pop    %esi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	8b 75 08             	mov    0x8(%ebp),%esi
  801907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80190d:	89 f0                	mov    %esi,%eax
  80190f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801913:	85 c9                	test   %ecx,%ecx
  801915:	75 0b                	jne    801922 <strlcpy+0x23>
  801917:	eb 1d                	jmp    801936 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801919:	83 c0 01             	add    $0x1,%eax
  80191c:	83 c2 01             	add    $0x1,%edx
  80191f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801922:	39 d8                	cmp    %ebx,%eax
  801924:	74 0b                	je     801931 <strlcpy+0x32>
  801926:	0f b6 0a             	movzbl (%edx),%ecx
  801929:	84 c9                	test   %cl,%cl
  80192b:	75 ec                	jne    801919 <strlcpy+0x1a>
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	eb 02                	jmp    801933 <strlcpy+0x34>
  801931:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  801933:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801936:	29 f0                	sub    %esi,%eax
}
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801942:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801945:	eb 06                	jmp    80194d <strcmp+0x11>
		p++, q++;
  801947:	83 c1 01             	add    $0x1,%ecx
  80194a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80194d:	0f b6 01             	movzbl (%ecx),%eax
  801950:	84 c0                	test   %al,%al
  801952:	74 04                	je     801958 <strcmp+0x1c>
  801954:	3a 02                	cmp    (%edx),%al
  801956:	74 ef                	je     801947 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801958:	0f b6 c0             	movzbl %al,%eax
  80195b:	0f b6 12             	movzbl (%edx),%edx
  80195e:	29 d0                	sub    %edx,%eax
}
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80196c:	89 c3                	mov    %eax,%ebx
  80196e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801971:	eb 06                	jmp    801979 <strncmp+0x17>
		n--, p++, q++;
  801973:	83 c0 01             	add    $0x1,%eax
  801976:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801979:	39 d8                	cmp    %ebx,%eax
  80197b:	74 15                	je     801992 <strncmp+0x30>
  80197d:	0f b6 08             	movzbl (%eax),%ecx
  801980:	84 c9                	test   %cl,%cl
  801982:	74 04                	je     801988 <strncmp+0x26>
  801984:	3a 0a                	cmp    (%edx),%cl
  801986:	74 eb                	je     801973 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801988:	0f b6 00             	movzbl (%eax),%eax
  80198b:	0f b6 12             	movzbl (%edx),%edx
  80198e:	29 d0                	sub    %edx,%eax
  801990:	eb 05                	jmp    801997 <strncmp+0x35>
		return 0;
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801997:	5b                   	pop    %ebx
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8019a4:	eb 07                	jmp    8019ad <strchr+0x13>
		if (*s == c)
  8019a6:	38 ca                	cmp    %cl,%dl
  8019a8:	74 0f                	je     8019b9 <strchr+0x1f>
	for (; *s; s++)
  8019aa:	83 c0 01             	add    $0x1,%eax
  8019ad:	0f b6 10             	movzbl (%eax),%edx
  8019b0:	84 d2                	test   %dl,%dl
  8019b2:	75 f2                	jne    8019a6 <strchr+0xc>
			return (char *) s;
	return 0;
  8019b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8019c5:	eb 07                	jmp    8019ce <strfind+0x13>
		if (*s == c)
  8019c7:	38 ca                	cmp    %cl,%dl
  8019c9:	74 0a                	je     8019d5 <strfind+0x1a>
	for (; *s; s++)
  8019cb:	83 c0 01             	add    $0x1,%eax
  8019ce:	0f b6 10             	movzbl (%eax),%edx
  8019d1:	84 d2                	test   %dl,%dl
  8019d3:	75 f2                	jne    8019c7 <strfind+0xc>
			break;
	return (char *) s;
}
  8019d5:	5d                   	pop    %ebp
  8019d6:	c3                   	ret    

008019d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	57                   	push   %edi
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019e3:	85 c9                	test   %ecx,%ecx
  8019e5:	74 36                	je     801a1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019ed:	75 28                	jne    801a17 <memset+0x40>
  8019ef:	f6 c1 03             	test   $0x3,%cl
  8019f2:	75 23                	jne    801a17 <memset+0x40>
		c &= 0xFF;
  8019f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8019f8:	89 d3                	mov    %edx,%ebx
  8019fa:	c1 e3 08             	shl    $0x8,%ebx
  8019fd:	89 d6                	mov    %edx,%esi
  8019ff:	c1 e6 18             	shl    $0x18,%esi
  801a02:	89 d0                	mov    %edx,%eax
  801a04:	c1 e0 10             	shl    $0x10,%eax
  801a07:	09 f0                	or     %esi,%eax
  801a09:	09 c2                	or     %eax,%edx
  801a0b:	89 d0                	mov    %edx,%eax
  801a0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a0f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801a12:	fc                   	cld    
  801a13:	f3 ab                	rep stos %eax,%es:(%edi)
  801a15:	eb 06                	jmp    801a1d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1a:	fc                   	cld    
  801a1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a1d:	89 f8                	mov    %edi,%eax
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5f                   	pop    %edi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	57                   	push   %edi
  801a28:	56                   	push   %esi
  801a29:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a32:	39 c6                	cmp    %eax,%esi
  801a34:	73 35                	jae    801a6b <memmove+0x47>
  801a36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a39:	39 d0                	cmp    %edx,%eax
  801a3b:	73 2e                	jae    801a6b <memmove+0x47>
		s += n;
		d += n;
  801a3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a40:	89 d6                	mov    %edx,%esi
  801a42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a4a:	75 13                	jne    801a5f <memmove+0x3b>
  801a4c:	f6 c1 03             	test   $0x3,%cl
  801a4f:	75 0e                	jne    801a5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a51:	83 ef 04             	sub    $0x4,%edi
  801a54:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a57:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801a5a:	fd                   	std    
  801a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a5d:	eb 09                	jmp    801a68 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a5f:	83 ef 01             	sub    $0x1,%edi
  801a62:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801a65:	fd                   	std    
  801a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a68:	fc                   	cld    
  801a69:	eb 1d                	jmp    801a88 <memmove+0x64>
  801a6b:	89 f2                	mov    %esi,%edx
  801a6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a6f:	f6 c2 03             	test   $0x3,%dl
  801a72:	75 0f                	jne    801a83 <memmove+0x5f>
  801a74:	f6 c1 03             	test   $0x3,%cl
  801a77:	75 0a                	jne    801a83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801a7c:	89 c7                	mov    %eax,%edi
  801a7e:	fc                   	cld    
  801a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a81:	eb 05                	jmp    801a88 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801a83:	89 c7                	mov    %eax,%edi
  801a85:	fc                   	cld    
  801a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a88:	5e                   	pop    %esi
  801a89:	5f                   	pop    %edi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a92:	8b 45 10             	mov    0x10(%ebp),%eax
  801a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	89 04 24             	mov    %eax,(%esp)
  801aa6:	e8 79 ff ff ff       	call   801a24 <memmove>
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab8:	89 d6                	mov    %edx,%esi
  801aba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801abd:	eb 1a                	jmp    801ad9 <memcmp+0x2c>
		if (*s1 != *s2)
  801abf:	0f b6 02             	movzbl (%edx),%eax
  801ac2:	0f b6 19             	movzbl (%ecx),%ebx
  801ac5:	38 d8                	cmp    %bl,%al
  801ac7:	74 0a                	je     801ad3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ac9:	0f b6 c0             	movzbl %al,%eax
  801acc:	0f b6 db             	movzbl %bl,%ebx
  801acf:	29 d8                	sub    %ebx,%eax
  801ad1:	eb 0f                	jmp    801ae2 <memcmp+0x35>
		s1++, s2++;
  801ad3:	83 c2 01             	add    $0x1,%edx
  801ad6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  801ad9:	39 f2                	cmp    %esi,%edx
  801adb:	75 e2                	jne    801abf <memcmp+0x12>
	}

	return 0;
  801add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801af4:	eb 07                	jmp    801afd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801af6:	38 08                	cmp    %cl,(%eax)
  801af8:	74 07                	je     801b01 <memfind+0x1b>
	for (; s < ends; s++)
  801afa:	83 c0 01             	add    $0x1,%eax
  801afd:	39 d0                	cmp    %edx,%eax
  801aff:	72 f5                	jb     801af6 <memfind+0x10>
			break;
	return (void *) s;
}
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	57                   	push   %edi
  801b07:	56                   	push   %esi
  801b08:	53                   	push   %ebx
  801b09:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b0f:	eb 03                	jmp    801b14 <strtol+0x11>
		s++;
  801b11:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801b14:	0f b6 0a             	movzbl (%edx),%ecx
  801b17:	80 f9 09             	cmp    $0x9,%cl
  801b1a:	74 f5                	je     801b11 <strtol+0xe>
  801b1c:	80 f9 20             	cmp    $0x20,%cl
  801b1f:	74 f0                	je     801b11 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801b21:	80 f9 2b             	cmp    $0x2b,%cl
  801b24:	75 0a                	jne    801b30 <strtol+0x2d>
		s++;
  801b26:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801b29:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2e:	eb 11                	jmp    801b41 <strtol+0x3e>
  801b30:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  801b35:	80 f9 2d             	cmp    $0x2d,%cl
  801b38:	75 07                	jne    801b41 <strtol+0x3e>
		s++, neg = 1;
  801b3a:	8d 52 01             	lea    0x1(%edx),%edx
  801b3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b46:	75 15                	jne    801b5d <strtol+0x5a>
  801b48:	80 3a 30             	cmpb   $0x30,(%edx)
  801b4b:	75 10                	jne    801b5d <strtol+0x5a>
  801b4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b51:	75 0a                	jne    801b5d <strtol+0x5a>
		s += 2, base = 16;
  801b53:	83 c2 02             	add    $0x2,%edx
  801b56:	b8 10 00 00 00       	mov    $0x10,%eax
  801b5b:	eb 10                	jmp    801b6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	75 0c                	jne    801b6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801b61:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801b63:	80 3a 30             	cmpb   $0x30,(%edx)
  801b66:	75 05                	jne    801b6d <strtol+0x6a>
		s++, base = 8;
  801b68:	83 c2 01             	add    $0x1,%edx
  801b6b:	b0 08                	mov    $0x8,%al
		base = 10;
  801b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b75:	0f b6 0a             	movzbl (%edx),%ecx
  801b78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b7b:	89 f0                	mov    %esi,%eax
  801b7d:	3c 09                	cmp    $0x9,%al
  801b7f:	77 08                	ja     801b89 <strtol+0x86>
			dig = *s - '0';
  801b81:	0f be c9             	movsbl %cl,%ecx
  801b84:	83 e9 30             	sub    $0x30,%ecx
  801b87:	eb 20                	jmp    801ba9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801b89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	3c 19                	cmp    $0x19,%al
  801b90:	77 08                	ja     801b9a <strtol+0x97>
			dig = *s - 'a' + 10;
  801b92:	0f be c9             	movsbl %cl,%ecx
  801b95:	83 e9 57             	sub    $0x57,%ecx
  801b98:	eb 0f                	jmp    801ba9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  801b9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801b9d:	89 f0                	mov    %esi,%eax
  801b9f:	3c 19                	cmp    $0x19,%al
  801ba1:	77 16                	ja     801bb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801ba3:	0f be c9             	movsbl %cl,%ecx
  801ba6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801ba9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801bac:	7d 0f                	jge    801bbd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  801bae:	83 c2 01             	add    $0x1,%edx
  801bb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801bb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801bb7:	eb bc                	jmp    801b75 <strtol+0x72>
  801bb9:	89 d8                	mov    %ebx,%eax
  801bbb:	eb 02                	jmp    801bbf <strtol+0xbc>
  801bbd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bc3:	74 05                	je     801bca <strtol+0xc7>
		*endptr = (char *) s;
  801bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801bca:	f7 d8                	neg    %eax
  801bcc:	85 ff                	test   %edi,%edi
  801bce:	0f 44 c3             	cmove  %ebx,%eax
}
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    
  801bd6:	66 90                	xchg   %ax,%ax
  801bd8:	66 90                	xchg   %ax,%ax
  801bda:	66 90                	xchg   %ax,%ax
  801bdc:	66 90                	xchg   %ax,%ax
  801bde:	66 90                	xchg   %ax,%ax

00801be0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 10             	sub    $0x10,%esp
  801be8:	8b 75 08             	mov    0x8(%ebp),%esi
  801beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bee:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int r;
	// LAB 4: Your code here.

    if(pg == NULL){
  801bf1:	85 c0                	test   %eax,%eax
        pg = (void *)KERNBASE; // Should not be mapping kernel entries.
  801bf3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801bf8:	0f 44 c2             	cmove  %edx,%eax
    }

    r = sys_ipc_recv(pg);
  801bfb:	89 04 24             	mov    %eax,(%esp)
  801bfe:	e8 91 e7 ff ff       	call   800394 <sys_ipc_recv>
    if(r < 0){
  801c03:	85 c0                	test   %eax,%eax
  801c05:	79 16                	jns    801c1d <ipc_recv+0x3d>
        // Fails, so we set things to zero as instructed.
        if(from_env_store != NULL){
  801c07:	85 f6                	test   %esi,%esi
  801c09:	74 06                	je     801c11 <ipc_recv+0x31>
            *from_env_store = 0;
  801c0b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        if(perm_store != NULL){
  801c11:	85 db                	test   %ebx,%ebx
  801c13:	74 2c                	je     801c41 <ipc_recv+0x61>
            *perm_store = 0;
  801c15:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c1b:	eb 24                	jmp    801c41 <ipc_recv+0x61>
        }
        return r;
    }


    if(from_env_store != NULL){
  801c1d:	85 f6                	test   %esi,%esi
  801c1f:	74 0a                	je     801c2b <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801c21:	a1 08 40 80 00       	mov    0x804008,%eax
  801c26:	8b 40 74             	mov    0x74(%eax),%eax
  801c29:	89 06                	mov    %eax,(%esi)
    }

    if(perm_store != NULL){
  801c2b:	85 db                	test   %ebx,%ebx
  801c2d:	74 0a                	je     801c39 <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  801c2f:	a1 08 40 80 00       	mov    0x804008,%eax
  801c34:	8b 40 78             	mov    0x78(%eax),%eax
  801c37:	89 03                	mov    %eax,(%ebx)
    }


   // panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c39:	a1 08 40 80 00       	mov    0x804008,%eax
  801c3e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	57                   	push   %edi
  801c4c:	56                   	push   %esi
  801c4d:	53                   	push   %ebx
  801c4e:	83 ec 1c             	sub    $0x1c,%esp
  801c51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int r;

    if(pg == NULL){
  801c5a:	85 db                	test   %ebx,%ebx
        pg = (void *)KERNBASE;
  801c5c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801c61:	0f 44 d8             	cmove  %eax,%ebx
    }
    while(1){
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801c64:	8b 45 14             	mov    0x14(%ebp),%eax
  801c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c73:	89 3c 24             	mov    %edi,(%esp)
  801c76:	e8 f6 e6 ff ff       	call   800371 <sys_ipc_try_send>
        if(r == 0){
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	74 28                	je     801ca7 <ipc_send+0x5f>
            return;
        }
        if(r != -E_IPC_NOT_RECV){
  801c7f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c82:	74 1c                	je     801ca0 <ipc_send+0x58>
            panic("ipc_send: Fail to send");
  801c84:	c7 44 24 08 40 24 80 	movl   $0x802440,0x8(%esp)
  801c8b:	00 
  801c8c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801c93:	00 
  801c94:	c7 04 24 57 24 80 00 	movl   $0x802457,(%esp)
  801c9b:	e8 c6 f4 ff ff       	call   801166 <_panic>
        }
        sys_yield();
  801ca0:	e8 ba e4 ff ff       	call   80015f <sys_yield>
    }
  801ca5:	eb bd                	jmp    801c64 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801ca7:	83 c4 1c             	add    $0x1c,%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cbd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cc3:	8b 52 50             	mov    0x50(%edx),%edx
  801cc6:	39 ca                	cmp    %ecx,%edx
  801cc8:	75 0d                	jne    801cd7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ccd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cd2:	8b 40 40             	mov    0x40(%eax),%eax
  801cd5:	eb 0e                	jmp    801ce5 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  801cd7:	83 c0 01             	add    $0x1,%eax
  801cda:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cdf:	75 d9                	jne    801cba <ipc_find_env+0xb>
	return 0;
  801ce1:	66 b8 00 00          	mov    $0x0,%ax
}
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ced:	89 d0                	mov    %edx,%eax
  801cef:	c1 e8 16             	shr    $0x16,%eax
  801cf2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cf9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801cfe:	f6 c1 01             	test   $0x1,%cl
  801d01:	74 1d                	je     801d20 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801d03:	c1 ea 0c             	shr    $0xc,%edx
  801d06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d0d:	f6 c2 01             	test   $0x1,%dl
  801d10:	74 0e                	je     801d20 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d12:	c1 ea 0c             	shr    $0xc,%edx
  801d15:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d1c:	ef 
  801d1d:	0f b7 c0             	movzwl %ax,%eax
}
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	66 90                	xchg   %ax,%ax
  801d24:	66 90                	xchg   %ax,%ax
  801d26:	66 90                	xchg   %ax,%ax
  801d28:	66 90                	xchg   %ax,%ax
  801d2a:	66 90                	xchg   %ax,%ax
  801d2c:	66 90                	xchg   %ax,%ax
  801d2e:	66 90                	xchg   %ax,%ax

00801d30 <__udivdi3>:
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	83 ec 0c             	sub    $0xc,%esp
  801d36:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d46:	85 c0                	test   %eax,%eax
  801d48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d4c:	89 ea                	mov    %ebp,%edx
  801d4e:	89 0c 24             	mov    %ecx,(%esp)
  801d51:	75 2d                	jne    801d80 <__udivdi3+0x50>
  801d53:	39 e9                	cmp    %ebp,%ecx
  801d55:	77 61                	ja     801db8 <__udivdi3+0x88>
  801d57:	85 c9                	test   %ecx,%ecx
  801d59:	89 ce                	mov    %ecx,%esi
  801d5b:	75 0b                	jne    801d68 <__udivdi3+0x38>
  801d5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d62:	31 d2                	xor    %edx,%edx
  801d64:	f7 f1                	div    %ecx
  801d66:	89 c6                	mov    %eax,%esi
  801d68:	31 d2                	xor    %edx,%edx
  801d6a:	89 e8                	mov    %ebp,%eax
  801d6c:	f7 f6                	div    %esi
  801d6e:	89 c5                	mov    %eax,%ebp
  801d70:	89 f8                	mov    %edi,%eax
  801d72:	f7 f6                	div    %esi
  801d74:	89 ea                	mov    %ebp,%edx
  801d76:	83 c4 0c             	add    $0xc,%esp
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi
  801d80:	39 e8                	cmp    %ebp,%eax
  801d82:	77 24                	ja     801da8 <__udivdi3+0x78>
  801d84:	0f bd e8             	bsr    %eax,%ebp
  801d87:	83 f5 1f             	xor    $0x1f,%ebp
  801d8a:	75 3c                	jne    801dc8 <__udivdi3+0x98>
  801d8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d90:	39 34 24             	cmp    %esi,(%esp)
  801d93:	0f 86 9f 00 00 00    	jbe    801e38 <__udivdi3+0x108>
  801d99:	39 d0                	cmp    %edx,%eax
  801d9b:	0f 82 97 00 00 00    	jb     801e38 <__udivdi3+0x108>
  801da1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da8:	31 d2                	xor    %edx,%edx
  801daa:	31 c0                	xor    %eax,%eax
  801dac:	83 c4 0c             	add    $0xc,%esp
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    
  801db3:	90                   	nop
  801db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db8:	89 f8                	mov    %edi,%eax
  801dba:	f7 f1                	div    %ecx
  801dbc:	31 d2                	xor    %edx,%edx
  801dbe:	83 c4 0c             	add    $0xc,%esp
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    
  801dc5:	8d 76 00             	lea    0x0(%esi),%esi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	8b 3c 24             	mov    (%esp),%edi
  801dcd:	d3 e0                	shl    %cl,%eax
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd6:	29 e8                	sub    %ebp,%eax
  801dd8:	89 c1                	mov    %eax,%ecx
  801dda:	d3 ef                	shr    %cl,%edi
  801ddc:	89 e9                	mov    %ebp,%ecx
  801dde:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801de2:	8b 3c 24             	mov    (%esp),%edi
  801de5:	09 74 24 08          	or     %esi,0x8(%esp)
  801de9:	89 d6                	mov    %edx,%esi
  801deb:	d3 e7                	shl    %cl,%edi
  801ded:	89 c1                	mov    %eax,%ecx
  801def:	89 3c 24             	mov    %edi,(%esp)
  801df2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801df6:	d3 ee                	shr    %cl,%esi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	d3 e2                	shl    %cl,%edx
  801dfc:	89 c1                	mov    %eax,%ecx
  801dfe:	d3 ef                	shr    %cl,%edi
  801e00:	09 d7                	or     %edx,%edi
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	89 f8                	mov    %edi,%eax
  801e06:	f7 74 24 08          	divl   0x8(%esp)
  801e0a:	89 d6                	mov    %edx,%esi
  801e0c:	89 c7                	mov    %eax,%edi
  801e0e:	f7 24 24             	mull   (%esp)
  801e11:	39 d6                	cmp    %edx,%esi
  801e13:	89 14 24             	mov    %edx,(%esp)
  801e16:	72 30                	jb     801e48 <__udivdi3+0x118>
  801e18:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e1c:	89 e9                	mov    %ebp,%ecx
  801e1e:	d3 e2                	shl    %cl,%edx
  801e20:	39 c2                	cmp    %eax,%edx
  801e22:	73 05                	jae    801e29 <__udivdi3+0xf9>
  801e24:	3b 34 24             	cmp    (%esp),%esi
  801e27:	74 1f                	je     801e48 <__udivdi3+0x118>
  801e29:	89 f8                	mov    %edi,%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	e9 7a ff ff ff       	jmp    801dac <__udivdi3+0x7c>
  801e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e38:	31 d2                	xor    %edx,%edx
  801e3a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3f:	e9 68 ff ff ff       	jmp    801dac <__udivdi3+0x7c>
  801e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e48:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	83 c4 0c             	add    $0xc,%esp
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    
  801e54:	66 90                	xchg   %ax,%ax
  801e56:	66 90                	xchg   %ax,%ax
  801e58:	66 90                	xchg   %ax,%ax
  801e5a:	66 90                	xchg   %ax,%ax
  801e5c:	66 90                	xchg   %ax,%ax
  801e5e:	66 90                	xchg   %ax,%ax

00801e60 <__umoddi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	83 ec 14             	sub    $0x14,%esp
  801e66:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e6e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e72:	89 c7                	mov    %eax,%edi
  801e74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e78:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e80:	89 34 24             	mov    %esi,(%esp)
  801e83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e87:	85 c0                	test   %eax,%eax
  801e89:	89 c2                	mov    %eax,%edx
  801e8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e8f:	75 17                	jne    801ea8 <__umoddi3+0x48>
  801e91:	39 fe                	cmp    %edi,%esi
  801e93:	76 4b                	jbe    801ee0 <__umoddi3+0x80>
  801e95:	89 c8                	mov    %ecx,%eax
  801e97:	89 fa                	mov    %edi,%edx
  801e99:	f7 f6                	div    %esi
  801e9b:	89 d0                	mov    %edx,%eax
  801e9d:	31 d2                	xor    %edx,%edx
  801e9f:	83 c4 14             	add    $0x14,%esp
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    
  801ea6:	66 90                	xchg   %ax,%ax
  801ea8:	39 f8                	cmp    %edi,%eax
  801eaa:	77 54                	ja     801f00 <__umoddi3+0xa0>
  801eac:	0f bd e8             	bsr    %eax,%ebp
  801eaf:	83 f5 1f             	xor    $0x1f,%ebp
  801eb2:	75 5c                	jne    801f10 <__umoddi3+0xb0>
  801eb4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801eb8:	39 3c 24             	cmp    %edi,(%esp)
  801ebb:	0f 87 e7 00 00 00    	ja     801fa8 <__umoddi3+0x148>
  801ec1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ec5:	29 f1                	sub    %esi,%ecx
  801ec7:	19 c7                	sbb    %eax,%edi
  801ec9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ecd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ed1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ed5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ed9:	83 c4 14             	add    $0x14,%esp
  801edc:	5e                   	pop    %esi
  801edd:	5f                   	pop    %edi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    
  801ee0:	85 f6                	test   %esi,%esi
  801ee2:	89 f5                	mov    %esi,%ebp
  801ee4:	75 0b                	jne    801ef1 <__umoddi3+0x91>
  801ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  801eeb:	31 d2                	xor    %edx,%edx
  801eed:	f7 f6                	div    %esi
  801eef:	89 c5                	mov    %eax,%ebp
  801ef1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ef5:	31 d2                	xor    %edx,%edx
  801ef7:	f7 f5                	div    %ebp
  801ef9:	89 c8                	mov    %ecx,%eax
  801efb:	f7 f5                	div    %ebp
  801efd:	eb 9c                	jmp    801e9b <__umoddi3+0x3b>
  801eff:	90                   	nop
  801f00:	89 c8                	mov    %ecx,%eax
  801f02:	89 fa                	mov    %edi,%edx
  801f04:	83 c4 14             	add    $0x14,%esp
  801f07:	5e                   	pop    %esi
  801f08:	5f                   	pop    %edi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    
  801f0b:	90                   	nop
  801f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f10:	8b 04 24             	mov    (%esp),%eax
  801f13:	be 20 00 00 00       	mov    $0x20,%esi
  801f18:	89 e9                	mov    %ebp,%ecx
  801f1a:	29 ee                	sub    %ebp,%esi
  801f1c:	d3 e2                	shl    %cl,%edx
  801f1e:	89 f1                	mov    %esi,%ecx
  801f20:	d3 e8                	shr    %cl,%eax
  801f22:	89 e9                	mov    %ebp,%ecx
  801f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f28:	8b 04 24             	mov    (%esp),%eax
  801f2b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f2f:	89 fa                	mov    %edi,%edx
  801f31:	d3 e0                	shl    %cl,%eax
  801f33:	89 f1                	mov    %esi,%ecx
  801f35:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f39:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f3d:	d3 ea                	shr    %cl,%edx
  801f3f:	89 e9                	mov    %ebp,%ecx
  801f41:	d3 e7                	shl    %cl,%edi
  801f43:	89 f1                	mov    %esi,%ecx
  801f45:	d3 e8                	shr    %cl,%eax
  801f47:	89 e9                	mov    %ebp,%ecx
  801f49:	09 f8                	or     %edi,%eax
  801f4b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f4f:	f7 74 24 04          	divl   0x4(%esp)
  801f53:	d3 e7                	shl    %cl,%edi
  801f55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f59:	89 d7                	mov    %edx,%edi
  801f5b:	f7 64 24 08          	mull   0x8(%esp)
  801f5f:	39 d7                	cmp    %edx,%edi
  801f61:	89 c1                	mov    %eax,%ecx
  801f63:	89 14 24             	mov    %edx,(%esp)
  801f66:	72 2c                	jb     801f94 <__umoddi3+0x134>
  801f68:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f6c:	72 22                	jb     801f90 <__umoddi3+0x130>
  801f6e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f72:	29 c8                	sub    %ecx,%eax
  801f74:	19 d7                	sbb    %edx,%edi
  801f76:	89 e9                	mov    %ebp,%ecx
  801f78:	89 fa                	mov    %edi,%edx
  801f7a:	d3 e8                	shr    %cl,%eax
  801f7c:	89 f1                	mov    %esi,%ecx
  801f7e:	d3 e2                	shl    %cl,%edx
  801f80:	89 e9                	mov    %ebp,%ecx
  801f82:	d3 ef                	shr    %cl,%edi
  801f84:	09 d0                	or     %edx,%eax
  801f86:	89 fa                	mov    %edi,%edx
  801f88:	83 c4 14             	add    $0x14,%esp
  801f8b:	5e                   	pop    %esi
  801f8c:	5f                   	pop    %edi
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    
  801f8f:	90                   	nop
  801f90:	39 d7                	cmp    %edx,%edi
  801f92:	75 da                	jne    801f6e <__umoddi3+0x10e>
  801f94:	8b 14 24             	mov    (%esp),%edx
  801f97:	89 c1                	mov    %eax,%ecx
  801f99:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801f9d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801fa1:	eb cb                	jmp    801f6e <__umoddi3+0x10e>
  801fa3:	90                   	nop
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801fac:	0f 82 0f ff ff ff    	jb     801ec1 <__umoddi3+0x61>
  801fb2:	e9 1a ff ff ff       	jmp    801ed1 <__umoddi3+0x71>
