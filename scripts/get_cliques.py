from os import listdir, stat
from os.path import dirname, realpath, join, relpath
import click
import yaml
import json

PROJECT_DIR = dirname(dirname(realpath(__file__)))


@click.group()
def cli():
    pass


@cli.command("from-reports")
@click.option("--run-id", "-i", type=str, help="Run id.")
@click.option("--top-cliques", "-t", type=int, help="Top number of cliques to return.")
@click.option("--report-yaml", "-r", type=str, help="Report.yaml file output from boomerang.")
def from_reports(run_id: str, top_cliques: int, report_yaml: str):
    mapping = run_id.replace("mondo_", "").replace("_", "-")
    boomer_output_dir = join(PROJECT_DIR, mapping, "boomer_output", run_id)
    json_files = [x for x in listdir(boomer_output_dir) if (x.endswith(".json") and not x.startswith("singleton"))]
    sorted_list_of_json_files = sorted(
        json_files, key=lambda x: stat(join(boomer_output_dir, x)).st_size, reverse=True
    )[: (top_cliques)]
    # sorted_list_of_clique_pngs = [x.replace(".json", ".png") for x in sorted_list_of_json_files]
    top_clique_ids = [x.replace(".json", "") for x in sorted_list_of_json_files]

    # with open(report_yaml, "r") as y:
    #     reports = yaml.safe_load(y)

    # top_cliques_reports = [x for x in reports['clusters'] if x['id'] in top_clique_ids]
    subset_report = report_yaml.replace(".yaml", ".md")

    markdown_content = []
    for id in top_clique_ids:
        json_file = join(relpath(boomer_output_dir), id+".json")
        image_path = join(relpath(boomer_output_dir), id+".png")

        # Create an empty list to store the Markdown content
        
        markdown_content.append("```json")
        with open(json_file, "r") as f:
            json_data = f.read()
            markdown_content.append(json_data)
        markdown_content.append("```")
        # Add the image
        markdown_content.append(f"![Alt text](../{id}.png)")

        # Join the Markdown content list into a single string
    markdown_output = "\n".join(markdown_content)

    # Write the Markdown content to a file
    with open(subset_report, "w") as f:
        f.write(markdown_output)


if __name__ == "__main__":
    cli()
