

pthread_mutex_t adapt_non_preemptive_mutex;

void adapt_init() {
	pthread_mutex_init(&adapt_non_preemptive_mutex);
}


void adapt_start_non_preemptive_execution ()
{
	pthread_mutex_lock(&adapt_non_preemptive_mutex);
}

void adapt_end_non_preemptive_execution ()
{
	pthread_mutex_unlock(&adapt_non_preemptive_mutex);
}

