package binny

import (
	"os"
	"os/exec"
)

func Build(config Config) error {
	cmd := exec.Command("docker", "build", "-t", config.Image, config.Build)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
