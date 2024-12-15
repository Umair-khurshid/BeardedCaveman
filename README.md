
# Breaded Caveman

Breaded Caveman is a command-line interactive assistant built with Bash, designed to help with IT tasks, system administration, Bash scripting, DevOps, and speech capabilities. It integrates OpenAI’s GPT API for intelligent responses and features text-to-speech and animated text displays to create an engaging user experience.

## Features

- **Interactive Assistant**: Provides intelligent, real-time responses using OpenAI’s API.
- **Text-to-Speech**: Converts assistant's responses into speech using `espeak`.
- **Text Animation**: Displays responses with smooth animated text in the terminal.
- **Multi-tasking and Context Awareness**: Remembers previous conversations and can handle multiple tasks at once.
- **Debug Mode**: Logs API requests and responses for troubleshooting.

## Requirements

Make sure you have the following installed:

- `jq` - JSON processor
- `curl` - For making API requests
- `espeak` - Text-to-speech tool

## Installation

### 1. Clone the repository:

```bash
git clone https://github.com/Umair-khurshid/BeardedCaveman.git
cd BeardedCaveman
```
### 2. Install dependencies:

Ensure that the required tools are installed:

```bash
sudo apt-get install jq curl espeak
```

These tools are needed to interact with the OpenAI API (`curl`), process JSON data (`jq`), and convert the assistant's text responses to speech (`espeak`).


### 3.Add API key in secret.cfg file:

You need an API key from OpenAI. Once you have the key add it in the secret.cfg directory with the following content:

```bash
api_key="YOUR_OPENAI_API_KEY"
```

This file stores your OpenAI API key, which is necessary for authenticating requests to the API.


### 4. Run Breaded Caveman:

Once everything is set up, execute the script:

```bash
./breaded_caveman.sh
```

The assistant will greet you, and you can begin interacting with it. Type `exit` to quit the script.

## Usage

### Available commands:

- `exit` - Quits the script.
- `help` - Displays help information about interacting with Breaded Caveman.

### Debug Mode:

To enable debugging, set the debug variable to `1` in the script. This will log the API requests and responses to `BreadedCaveman.log`.

```bash
debug='1'  # Enable debug mode
```

## Customizing Breaded Caveman:

- Modify the `initprompt` variable in the script to change the assistant's personality and initial behavior.
- Modify the `--arg model` to change the model. I'm using gpt-3.5-turbo because of the cost.
