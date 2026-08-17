# Progress

> 세션 시작 시 가장 먼저 읽는 파일.

## 새 세션 시작 방법

1. 작업 디렉터리를 **`Study/<프로젝트 이름>/`** 로 잡는다.
   (`Study/` 루트의 `CLAUDE.md`는 정책 파일이며 모든 프로젝트가 공유한다.
   따라서 어느 프로젝트인지 먼저 지정해야 한다.)
2. `CLAUDE.md` §2의 세션 프로토콜대로 `progress.md` → `spec.md` → `background.md`
   순서로 읽는다. 이 3개를 읽기 전에 어떤 수학도 쓰지 않는다.
   **매 턴 끝에 세 파일을 모두 확인한다.** 바뀔 것이 없으면 없다고 확인만 한다.
   (`background.md`는 Phase 1 산출물이라 대개 바뀔 것이 없지만, 「없음」을
   확인하는 것까지가 절차다.)
   **Phase 1을 진행 중이면 `Study/` 루트의 `PHASE1_PROBE_GUIDE.md`도 읽는다.**
   probe 선정과 K등급 판정은 그 파일이 정본이다.
3. 검사를 **이 순서로** 돌린다 (아래 「검사 스크립트」 참조).
   `sh tex/check.sh` → `sh md-check.sh` → (프로젝트별 검사기)
   `md-check.sh`가 `.aux`를 읽으므로 빌드가 먼저다.
4. 아래 「현재 상태」의 *다음 작업*부터 이어간다.

첫 프롬프트 예시:
> `<프로젝트 이름>` 폴더의 프로젝트를 이어서 진행할게.
> CLAUDE.md와 progress.md / spec.md / background.md를 읽고 현재 상태를 알려줘.

**세션 간에 남지 않는 것:** 임시 스크래치패드에 추출해 둔 PDF 텍스트.
필요하면 `pdftotext -layout`으로 다시 만든다. `refs/` 원본은 그대로 남는다.

**스캔본 주의.** 원문 PDF의 텍스트 레이어가 손상된 경우
(numdam·E-Periodica 등의 스캔본), 진술을 옮겨 적기 전에
`pdftoppm -r 150 -f N -l N -png`로 해당 쪽을 이미지로 렌더링해 직접 읽는다.
**텍스트 레이어가 멀쩡해 보여도** $\liminf$의 밑줄 같은 것은 소실되므로,
진술의 성패가 걸린 기호는 이미지로 확인한다. 각 자료의 읽는 법과 페이지 대응은
`refs/NOTES.md`에 적는다.

## 현재 상태

- 현재 Phase:
- 마지막 승인 지점:
- 다음 작업:
- 대기 중인 질문:
- **K2 이상 (재설명 금지):**
- **K0 (전면 서술):**

> 마지막 두 줄은 `background.md`를 매번 뒤지지 않기 위한 요약이다.
> Phase 1이 끝나면 채우고, 이후 매 턴 이것만 보고 재설명 금지 규칙을 지킨다.
> **노드 이름만 나열한다** — 등급의 뜻을 여기서 풀어 쓰지 않는다
> (`CLAUDE.md` § 사용자에게 말하는 법).

## 승인 로그

| 날짜 | 항목 | 승인 여부 | 비고 |
|---|---|---|---|
| | | | |

## 검사 스크립트

빌드가 먼저다 (`md-check.sh`가 `.aux`를 읽는다).

| 스크립트 | 대상 | 검사 항목 |
|---|---|---|
| `sh tex/check.sh` | `tex/` | 비ASCII, clean-room 빌드, 로그(`grep -a`) |
| `sh md-check.sh` | 루트의 공유 정책 파일 + **프로젝트 아래 모든 `.md`** (`refs/NOTES.md` 포함) | ① 백틱 밖 프로젝트 매크로 ② 표 안 수식의 세로줄 ③ 표 열 개수 ④ 한 줄에서 안 닫힌 인라인 수식 ⑤ 우리 항목 번호를 `tex/**/*.aux`와 대조 (한국어 「`chNN` 비고 N.N」과 영어 약식 「`ChNN` Rmk N.N」 두 형태 모두) ⑥ `\uXXXX` 이스케이프 누출 ⑦ 「챕터 진행 현황」·「논문 정독 현황」의 승인 열 ↔ 승인 로그 ⑧ 등급 열(`사용 방식`·`직접`·`추정`·`확정 K`·`깊이`)이 기호를 잃고 평문으로 풀어 쓰였는가 |
| `sh tex/notation-check.sh` | **`tex/` 아래 모든 `.tex`** (머리말·부록 포함) | `notation.sty` 매크로의 전개형을 손으로 쓴 곳 |
| `sh tex/import-check.sh` | `tex/IMPORTS` | 다른 프로젝트에서 가져온 장의 **원본이 바뀌었는가** |

**프로젝트별로 하나 더 만든다: 원문 정리 번호 대조기.** 본문이 텍스트로 적은
원문 항목 번호(`Thm.~8.1` 등)는 `\ref`를 거치지 않으므로 **아무것도 검사하지
않는다.** 원문 PDF에서 (종류, 번호) 표를 뽑아 본문과 대조하는 스크립트를
만들어 둔다 (`tex/<원문>-check.sh`). 어느 프로젝트에서는 Phase 5 중 손으로 3건을
찾았고, 이 스크립트를 처음 돌리자 4번째가 나왔다.

## 빌드 검증 규칙

`tex/`에는 **그 자체로 빌드되는 뼈대**가 들어 있다 (`main.tex`, `preamble.sty`,
`notation.sty`, `refs.bib`). 복사한 직후 `sh tex/check.sh`를 돌려 통과를 확인한
뒤 시작한다 — 이후 무엇이 깨지든 우리가 넣은 것이 원인이다. 먼저 채울 것은
`main.tex`의 제목 블록(`spec.md`의 서지 그대로)과 `notation.sty`이고, 장은
승인될 때마다 `main.tex`의 `\include` 줄을 하나씩 살린다. **첫 `\cite`가
생기면 `main.tex`의 `\nocite{*}`를 지운다.**

장과 절의 형식은 `tex/chapters/ch00-example.tex`와 `tex/paper/sec00-example.tex`를
복사해 시작한다 — 머리 상자(Purpose / Assumed / Supports / How far things are
proved)와 맨 끝의 「Summary: where this chapter is used」 표(Item / Here /
Used in)가 형식의 전부다. **그 표가 챕터 확정 검사의 도구다**: 위에서 번호가
붙은 항목은 전부 표에 나타나야 하고, 각 행은 그것이 쓰이는 자리를 가리켜야
한다. 가리킬 곳이 없는 항목은 지우거나, 본문에서 필요한 직관이라고 밝힌다.
두 예시 파일은 `main.tex`에 포함되어 있지 않다.

빌드 부산물(`.aux`, `.log`, `.toc`, `.bbl` 등)은 **지우지 않는다.**
`md-check.sh`가 `.aux`를 읽고, 분량 실측이 `main.toc`와 `main.log`를 읽는다.
저장소에 올라가지 않도록 `.gitignore`에만 넣어 둔다.

**챕터를 확정하기 전 반드시 `sh tex/check.sh`를 돌린다.** 임기응변 `grep`으로
로그를 확인하지 않는다. 사유는 `CLAUDE.md` 검증 규칙 참조 (비ASCII 한 글자가
`main.log`를 binary로 만들어 `grep`을 침묵시킨다).

규칙: **`tex/` 아래는 전부 ASCII.** 한국어 메모는 관리 문서에만 둔다.

## 챕터 진행 현황

| Ch | 제목 | 출처 | 집필 | 검사 통과 | 컴파일 | 승인 |
|---|---|---|---|---|---|---|
| 01 | | 신규 | ☐ | ☐ | ☐ | ☐ |

> **승인을 받으면 이 표의 「승인」 열과 위의 「승인 로그」를 *같은 턴에 함께*
> 채운다.** `md-check.sh`에 항목 ⑦로 대조를 넣었다.
> 규칙을 글로만 적어 두는 것으로는 막히지 않았다는 것이 그 경위다.

> 「출처」는 **신규** 또는 **import: `<프로젝트>/<파일>`**. import한 장은
> `tex/IMPORTS`에도 등록하고 `sh tex/import-check.sh`로 표류를 감시한다
> (CLAUDE.md 「교차 프로젝트 재사용」).

> 검사 = CLAUDE.md Phase 4의 5개 항목

## 논문 정독 현황 (Phase 5)

| § | 파일 | 분량 | 상태 | 미해결 사항 |
|---|---|---|---|---|
| | | | ☐ | |

## 분량 실측표 — **이것이 정본**

측정법: clean-room 빌드 후 `tex/main.toc`의 `\contentsline{chapter}` 시작 쪽을
읽고 다음 항목(챕터 또는 `\part`)의 시작 쪽에서 뺀다. 마지막 챕터는 참고문헌
시작 쪽(`main.log`의 `(./main.bbl [NNN`)을 끝으로 삼는다.
**`\part` 표지 쪽을 빼먹지 않는다** — 이것으로 두 번 틀린 적이 있다.

분량은 **여기 한 곳에만** 적는다. `background.md`나 `spec.md`에 중복하면
반드시 어긋난다.

| Ch | 쪽 범위 | 분량 | 비고 |
|---|---|---|---|
| | | | |

## 본문 검증 표시

`\UNVERIFIED` / `\uncertain` / `\OWNPROOF` / `\OWNCHECK`의 현재 건수와 전수 목록.
Phase 6에서 최종본 방침을 결정한다.

전수 목록을 뽑는 명령:

```sh
cd tex && python3 - <<'EOF'
import re,glob,os
lab={}
for a in glob.glob('**/*.aux', recursive=True):
    for m in re.finditer(r'\\newlabel\{([^}]*)\}\{\{([^}]*)\}\{([^}]*)\}',open(a,errors='ignore').read()):
        lab[m.group(1)]=(m.group(2),m.group(3))
for f in sorted(glob.glob('**/*.tex', recursive=True)):
    L=open(f,errors='ignore').read().split('\n'); cur=None
    for i,l in enumerate(L):
        m=re.search(r'\\label\{([^}]*)\}',l)
        if m: cur=m.group(1)
        for mac in ('\\OWNPROOF','\\OWNCHECK','\\uncertain{','\\UNVERIFIED'):
            if mac in l:
                n,p=lab.get(cur,('?','?'))
                print(f"{mac:12s} {f:38s} L{i+1:4d} item {n:6s} p{p:4s} [{cur}]")
EOF
```

## 미해결

> **앞으로 할 일이 남은 것만** 적는다. 해결되는 즉시 지우고, 경위를 남길
> 필요가 있으면 승인 로그나 세션 이력으로 옮긴다.

-

## 세션 이력

> 시간 순(위가 오래된 것).

| # | 날짜 | 한 일 | 남긴 문제 |
|---|---|---|---|
| 1 | | | |
