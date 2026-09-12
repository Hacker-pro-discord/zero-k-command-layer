"""Fetch public source metadata and produce a review-only Zero-K rule candidate.

Run outside the game. No command bridge, automatic promotion or executable downloads.
"""
import argparse
import datetime
import json
import re
import urllib.parse
import urllib.request
from pathlib import Path

TOPICS = {
    'reconnaissance': {
        'concept': 'Gather information with a limited mobile detachment.',
        'game_rule': 'Use at most two assigned SCOUT/RAIDER units to revisit corridor edges; radar remains unidentified.',
        'sources': ['https://www.nam.ac.uk/explore/weapons-western-front', 'https://zero-k.info/mediawiki/Strategy_Treatise'],
    },
    'combined-arms': {
        'concept': 'Coordinate complementary roles rather than relying on one unit type.',
        'game_rule': 'Keep main-force role zones together; retain AA/support and artillery depth during native Fight advances.',
        'sources': ['https://www.nam.ac.uk/explore/1918-victory', 'https://zero-k.info/mediawiki/Strategy_Treatise'],
    },
    'reserves': {
        'concept': 'Retain suitable mobile strength for later contingencies.',
        'game_rule': 'Candidate only: retain 20% compatible mobile combat value; define game-state commitment triggers before implementation.',
        'sources': ['https://www.nam.ac.uk/explore/cavalry-western-front'],
    },
}
ALLOWED = {'www.nam.ac.uk', 'zero-k.info'}


class SourceRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        parsed = urllib.parse.urlparse(newurl)
        if parsed.scheme != 'https' or parsed.hostname not in ALLOWED:
            raise ValueError('Source redirected outside the reviewed public domains')
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def fetch_metadata(url):
    opener = urllib.request.build_opener(SourceRedirect())
    try:
        request = urllib.request.Request(url, headers={'User-Agent': 'ZeroKCommandLayer-Research/1.0'})
        with opener.open(request, timeout=15) as response:
            body = response.read(2_000_001)
            if len(body) > 2_000_000:
                raise ValueError('Source exceeds metadata-fetch limit')
            html = body.decode('utf-8', errors='replace')
        match = re.search(r'<title[^>]*>(.*?)</title>', html, re.I | re.S)
        title = re.sub(r'<[^>]+>', '', match.group(1)) if match else 'Title unavailable'
        return {'url': url, 'title': ' '.join(title.split()[:20]), 'status': 'FETCHED_METADATA_ONLY'}
    except Exception as exc:
        return {'url': url, 'status': 'UNAVAILABLE', 'error': str(exc)[:200]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('topic', choices=TOPICS)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    topic = TOPICS[args.topic]
    candidate = {
        'status': 'CANDIDATE_REQUIRES_HUMAN_REVIEW_AND_GAME_TESTS',
        'topic': args.topic,
        'checked_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'sources': [fetch_metadata(url) for url in topic['sources']],
        'abstract_concept': topic['concept'],
        'zero_k_interpretation': topic['game_rule'],
        'interpretation_origin': 'Curated template; not generated or validated by fetched web text.',
        'required_validation': ['Review sources', 'Validate roles and LOS restrictions', 'Run regression and isolated game tests', 'Explicit code review and version promotion'],
        'execution_enabled': False,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(candidate, indent=2) + '\n', encoding='utf-8')
    print(args.output)
    for source in candidate['sources']:
        print(source['status'], source['url'])


if __name__ == '__main__':
    main()
