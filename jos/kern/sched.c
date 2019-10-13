#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.

    /*Okay, I've been thinking about this and my first implementation is wrong.
     * I'm going to keep it here for thoughts
     *
     *   int i = 0;
     *   //cprintf("%d\n", NENV);
     *   if (curenv != NULL){
     *       i = ENVX(curenv->env_id);
     *   }
     *   for (; i < NENV; i++) {
     *       if (envs[i].env_status == ENV_RUNNABLE)
     *           env_run(&envs[i]);
     *   }
     *
     *  if (curenv != NULL && curenv->env_status == ENV_RUNNING)
     *       env_run(curenv);
     */


    int i;
    int envid = 0;
    if (curenv != NULL)
        envid = ENVX(curenv->env_id);
    for(i = envid; i < envid+NENV ; i++) {
        if (envs[i%NENV].env_status == ENV_RUNNABLE){
            //cprintf("i Value:%d\n", i);
     //1       cprintf("Curenv: %d\n", envid); // KEY PRINTFS, READ EXPLANATION BELOW
            //cprintf("Nenv: %d\n", NENV);
            env_run(&envs[i%NENV]);
            //cprintf("Curenv: %d\n", envid); // KEY PRINTFS, READ EXPLANATION BELOW
        }
    }
    if(curenv && curenv->env_status == ENV_RUNNING) {
        env_run(curenv);
    }

    /* Bug: Currently, user-primes does not work, Here's the stats
     * Stops @ prime number 853
     * Curenv maxes out at 147
     *
     */

    /* Okay, so let's talk about the new thing.
     * First, we need to talk about "NENV", it's just the number of possible environments we may support
     * So, run qemu-nox to see where that starts, notice that the baseline environment is a pretty large number
     * Look through each of those print statemenmts for a good refresher.
     * So we can have up to 1024 environments, so we need to cycle through them "thus round robin"
     * "Round robin", so we go back around with this statement. How? Look at the print statements
     * Something you'll notice is how "curenv"'s number constantly matches the thing.
     * You should also notice that curenv changes, this is why we CAN'T have a single curenv
     * It's a bit confusing to think about, so it's best to draw it out
     *  Iteration 1: 0 -> env run -> 1 -> env_run -> 2... until 5
     *  Notice that the iteration is based on the first environment, so once it hits 5
     *  it wraps back around to 0 and iteration goes up.
     *  Iteration 2: 0 -> ... -> 5 -> 0 so on and so forth.
     *
     *  I've included the modudlo operator to stop it front going past 1024.
     */

	// sched_halt never returns
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
        // LAB 4:
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}

