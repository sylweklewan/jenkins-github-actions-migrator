package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
)

type GitHubActionDefinition struct {
	File    string            `json:"file"`
	Content string            `json:"content"`
	Lables  map[string]string `json:"labels"`
}

func main() {
	actionsDir := flag.String("actions-dir", "../../../github-actions/workflows", "Directory where github actions are stored")
	flag.Parse()
	actionsFiles, err := os.ReadDir(*actionsDir)

	if err != nil {
		log.Fatal(err)
	}

	githubActionDefinitions, err := PrepareGitHubActionDefinitions(*actionsDir, actionsFiles)
	if err != nil {
		log.Fatal(err)
	}

	jsonDefinitions, err := json.Marshal(githubActionDefinitions)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(string(jsonDefinitions))

}

func PrepareGitHubActionDefinitions(actionsDir string, githubActionDefinitionsEntries []os.DirEntry) ([]GitHubActionDefinition, error) {
	githubActionDefinitions := make([]GitHubActionDefinition, len(githubActionDefinitionsEntries))
	for _, ad := range githubActionDefinitionsEntries {
		adp := filepath.Join(actionsDir, ad.Name())

		actionRawContent, err := os.ReadFile(adp)
		if err != nil {
			return nil, err
		}

		absActionPath, err := filepath.Abs(adp)
		if err != nil {
			return nil, err
		}

		action, err := NewGitHubActionDefinition(absActionPath, string(actionRawContent))
		if err != nil {
			return nil, err
		}
		githubActionDefinitions = append(githubActionDefinitions, *action)
	}
	return githubActionDefinitions, nil
}

func NewGitHubActionDefinition(absActionPath string, actionContent string) (*GitHubActionDefinition, error) {
	definition := new(GitHubActionDefinition)

	definition.File = absActionPath
	definition.Content = actionContent
	definition.Lables = generateLabels(actionContent)

	return definition, nil
}

func generateLabels(actionContent string) map[string]string {
	labels := make(map[string]string)

	lines := strings.Split(actionContent, "\n")

	for _, line := range lines {
		line, hasPrefix := strings.CutPrefix(line, "##")
		if !hasPrefix {
			break
		}
		keyAndValue := strings.Split(line, ":")
		labels[strings.TrimSpace(keyAndValue[0])] = strings.TrimSpace(keyAndValue[1])
	}
	return labels
}
