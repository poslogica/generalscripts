"""Script to generate change logs based on GitHub changes.

Module: generate_change_logs

This module provides functionality to generate change logs based on GitHub changes. It interacts
with the GitHub API to fetch commit data, formats the change logs, and saves them to a file.

Classes:
    - ReleaseNotesGenerator: A class to fetch GitHub commits, 
    generate change logs, and save them to a file.

Methods:
    - __init__(repository: str, auth_token: str, log_instance):
        Initializes the ReleaseNotesGenerator with the repository, 
        authentication token, and logger instance.
    - fetch_github_commits() -> list:
        Fetches the latest commits from the GitHub repository using the GitHub API.
    - generate_change_logs(commit_list: list) -> str:
        Generates change logs based on the list of commits.
    - save_change_logs(path: str, change_logs: str):
        Saves the generated change logs to a file.

Usage:
    >>> from generate_change_logs import ReleaseNotesGenerator
    >>> generator = ReleaseNotesGenerator("owner/repo", "your_token", logger)
    >>> commits = generator.fetch_github_commits()
    >>> notes = generator.generate_change_logs(commits)
    >>> generator.save_change_logs("change_logs.txt", notes)

CLI:
    Run the script directly to generate change logs:
    >>> python generate_change_logs.py

Features:
    - Fetches commit data from GitHub using the GitHub API.
    - Formats change logs with commit messages and authors.
    - Saves change logs to a file for distribution or archival.
    - Includes logging for debugging and error handling.

Dependencies:
    - requests: Library for making HTTP requests to the GitHub API.
    - logging: Python's built-in logging framework for logging operations.
    - datetime: Library for generating timestamps for change logs.
    - os: Library for file path manipulation.
"""

import os
import logging
from datetime import datetime
from collections import defaultdict
import requests

# Configure logger
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Constants
UNKNOWN_DATE = "Unknown Date"
UNKNOWN_MESSAGE = "No commit message"
UNKNOWN_AUTHOR = "Unknown Author"


class ChangeLogsGenerator:
    """
    A class to generate change logs based on GitHub changes.

    This class provides methods to:
      - Fetch commit data from a GitHub repository using the GitHub API.
      - Generate change logs in plain text and Markdown formats, grouped by commit date.
      - Save the generated change logs to a file.

    Args:
        repository (str): GitHub repository in the format "owner/repo".
        auth_token (str): GitHub personal access token.

    Methods:
        fetch_github_commits() -> list:
            Fetch all commits from the GitHub repository using the GitHub API, handling pagination.

        generate_change_logs_txt(commit_list: list) -> str:
            Generate change logs in plain text format, grouped by date.

        generate_change_logs_markdown(commit_list: list) -> str:
            Generate change logs in Markdown format, grouped by date.

        save_change_logs(path: str, change_logs: str) -> bool:
            Save the generated change logs to a file.

    Usage Example:
        >>> generator = ChangeLogsGenerator("owner/repo", "your_token")
        >>> commits = generator.fetch_github_commits()
        >>> notes_txt = generator.generate_change_logs_txt(commits)
        >>> generator.save_change_logs("change_logs.txt", notes_txt)
    """

    def __init__(self, repository: str, auth_token: str):
        """
        Initialize the ChangeLogsGenerator.

        Args:
            repository (str): GitHub repository in the format "owner/repo".
            auth_token (str): GitHub personal access token.
        """
        self.repository = repository
        self.auth_token = auth_token
        self.logger = logger

    def fetch_github_commits(self) -> list:
        """
        Fetch all commits from the GitHub repository using the GitHub API, handling pagination.

        Returns:
            list: List of all commits fetched from the GitHub API.
        """
        url = f"https://api.github.com/repos/{self.repository}/commits"
        headers = {"Authorization": f"token {self.auth_token}"}
        params = {"per_page": 100, "page": 1}
        all_commits = []
        try:
            while True:
                response = requests.get(url, headers=headers, params=params, timeout=10)
                if response.status_code == 200:
                    commits_response = response.json()
                    if not commits_response:
                        break
                    all_commits.extend(commits_response)
                    params["page"] += 1
                else:
                    self.logger.error(
                        "Error fetching commits: %s - %s", response.status_code, response.text
                    )
                    break
            self.logger.info(
                "Successfully fetched %d commits from %s", len(all_commits), self.repository
            )
        except requests.RequestException as e:
            self.logger.error("Request error while fetching commits: %s", e)
        return all_commits

    def generate_change_logs_txt(self, commit_list: list) -> str:
        """
        Generate change logs based on the list of commits, grouped by date.

        Args:
            commit_list (list): List of commits fetched from the GitHub API.

        Returns:
            str: Generated change logs as a string.
        """
        change_logs = f"Change Logs - {datetime.now().strftime('%Y-%m-%d')}\n"
        change_logs += "=" * 50 + "\n"

        # Group commits by date
        commits_by_date = defaultdict(list)
        for commit in commit_list:
            date = commit.get("commit", {}).get("author", {}).get("date", UNKNOWN_DATE)
            date_str = date[:10] if date != UNKNOWN_DATE else date
            commits_by_date[date_str].append(commit)

        for date_str in sorted(commits_by_date.keys(), reverse=True):
            change_logs += f"{date_str}\n"
            for commit in commits_by_date[date_str]:
                message = commit.get("commit", {}).get("message", UNKNOWN_MESSAGE)
                author = commit.get("commit", {}).get("author", {}).get("name", UNKNOWN_AUTHOR)
                change_logs += f"- {message} (by {author})\n"
            change_logs += "\n"

        change_logs += "=" * 50
        self.logger.info("Generated change logs with %d commits", len(commit_list))
        return change_logs

    def generate_change_logs_markdown(self, commit_list: list) -> str:
        """
        Generate change logs in Markdown format based on the list of commits, grouped by date.

        Args:
            commit_list (list): List of commits fetched from the GitHub API.

        Returns:
            str: Generated change logs as a Markdown string.
        """
        change_logs = f"# Change Logs - {datetime.now().strftime('%Y-%m-%d')}\n\n"

        # Group commits by date
        commits_by_date = defaultdict(list)
        for commit in commit_list:
            date = commit.get("commit", {}).get("author", {}).get("date", UNKNOWN_DATE)
            date_str = date[:10] if date != UNKNOWN_DATE else date
            commits_by_date[date_str].append(commit)

        for i, date_str in enumerate(sorted(commits_by_date.keys(), reverse=True)):
            # Add blank line before heading (MD022) - except for the first heading
            if i == 0:
                change_logs += f"## {date_str}\n\n"
            else:
                change_logs += f"\n## {date_str}\n\n"
            
            # Add blank line before list (MD032)
            for commit in commits_by_date[date_str]:
                message = commit.get("commit", {}).get("message", UNKNOWN_MESSAGE)
                author = commit.get("commit", {}).get("author", {}).get("name", UNKNOWN_AUTHOR)
                sha = commit.get("sha", "")[:7]
                url = commit.get("html_url", "")
                
                # Clean commit message (remove extra whitespace and newlines)
                message = " ".join(message.split())
                
                if url:
                    change_logs += f"- [`{sha}`]({url}) **{message}**\n"
                    change_logs += f"  *by {author}*\n"
                else:
                    change_logs += f"- **{message}**\n"
                    change_logs += f"  *by {author}*\n"
            
            # Add blank line after list (MD032)
            change_logs += "\n"

        # Ensure file ends with single newline
        return change_logs.rstrip() + "\n"

    def save_change_logs(self, path: str, change_logs: str) -> bool:
        """
        Save change logs to a file.

        Args:
            path (str): Path to save the change logs file.
            change_logs (str): Release notes content.

        Returns:
            bool: True if save was successful, False otherwise.
        """
        try:
            with open(path, "w", encoding="utf-8") as f:
                f.write(change_logs)
            self.logger.info("Release notes saved to %s", path)
            return True
        except IOError:
            self.logger.error("Error saving change logs", exc_info=True)
            return False


if __name__ == "__main__":
    repo = os.getenv("GITHUB_REPOSITORY", "")  # Example: "owner/repo"
    token = os.getenv("GITHUB_TOKEN", "")  # GitHub token passed via GitHub Actions

    if not repo or not token:
        logger.error("GITHUB_REPOSITORY or GITHUB_TOKEN is not set.")
        exit(1)

    generator = ChangeLogsGenerator(repo, token)
    commits = generator.fetch_github_commits()
    logs_txt = generator.generate_change_logs_txt(commits)
    logs_md = generator.generate_change_logs_markdown(commits)
    file_path_txt = os.path.join(os.getcwd(), "change_logs.txt")
    file_path_md = os.path.join(os.getcwd(), "changelog.md")
    generator.save_change_logs(file_path_txt, logs_txt)
    generator.save_change_logs(file_path_md, logs_md)