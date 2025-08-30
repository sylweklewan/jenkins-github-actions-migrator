package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
)

type GitHubActionDefinition struct {
	file    string
	content string
	lables  map[string]string
}

func main() {
	actionsDir := flag.String("actions-dir", "../../../github-actions/workflows", "Directory where github actions are stored")
	flag.Parse()
	actionsFiles, err := os.ReadDir(*actionsDir)

	if err != nil {
		log.Fatal(err)
	}
	for _, af := range actionsFiles {
		fmt.Println(af.Name())
	}

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

	definition.file = absActionPath
	definition.content = actionContent
	definition.lables = generateLabels(actionContent)

	return definition, nil
}

func generateLabels(actionContent string) map[string]string {
	labels := make(map[string]string)

	return labels
}

// func main() {
//     file, err := os.Open("text.txt")
//     if err != nil {
//         fmt.Println(err)
//     }
//     defer file.Close()

//     scanner := bufio.NewScanner(file)
//     for scanner.Scan() {
//         fmt.Println(scanner.Text())
//     }

//     if err := scanner.Err(); err != nil {
//         fmt.Println(err)
//     }
// }
