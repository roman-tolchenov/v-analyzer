module utils

import os

pub fn is_proc_exists(pid int) bool {
	return C.kill(pid, 0) == 0
}

pub fn expand_tilde_to_home(path string) string {
	norm_path := os.norm_path(path)
	return os.expand_tilde_to_home(norm_path)
}
