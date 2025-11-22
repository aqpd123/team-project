#!/usr/bin/env python3
"""
Simple PlantUML(.puml) → StarUML(.mdj) generator (classes & packages)

Purpose
- Parse a subset of PlantUML class diagram syntax from an existing .puml
- Create a StarUML .mdj project with matching packages and classes

Notes
- This focuses on packages, classes, attributes, and operations.
- Associations/relations are not generated (fast, robust baseline). You can add them in StarUML after import.
- Tested with the project's class_diagram.puml style.

Usage
  python documents/tools/puml_to_mdj.py documents/class_diagram.puml documents/converted_from_puml.mdj
"""

from __future__ import annotations

import json
import re
import sys
import uuid
from dataclasses import dataclass, field
from typing import Dict, List, Optional


def gen_id(prefix: str = "ID") -> str:
    return f"{prefix}-{uuid.uuid4()}"


@dataclass
class UmlOperation:
    name: str
    return_type: Optional[str] = None

    def to_mdj(self) -> Dict:
        return {
            "_type": "UMLOperation",
            "_id": gen_id("OP"),
            "name": self.name,
            "visibility": "public",
            **({"returnType": self.return_type} if self.return_type else {}),
        }


@dataclass
class UmlAttribute:
    name: str
    type_: Optional[str] = None
    visibility: str = "public"

    def to_mdj(self) -> Dict:
        return {
            "_type": "UMLAttribute",
            "_id": gen_id("AT"),
            "name": self.name,
            **({"type": self.type_} if self.type_ else {}),
            "visibility": self.visibility,
        }


@dataclass
class UmlClass:
    name: str
    attributes: List[UmlAttribute] = field(default_factory=list)
    operations: List[UmlOperation] = field(default_factory=list)
    mdj_id: Optional[str] = None

    def to_mdj(self) -> Dict:
        return {
            "_type": "UMLClass",
            "_id": self.mdj_id or gen_id("CL"),
            "name": self.name,
            "attributes": [a.to_mdj() for a in self.attributes] if self.attributes else [],
            "operations": [op.to_mdj() for op in self.operations] if self.operations else [],
        }


@dataclass
class UmlPackage:
    name: str
    classes: List[UmlClass] = field(default_factory=list)
    subpackages: Dict[str, "UmlPackage"] = field(default_factory=dict)

    def ensure(self, path: List[str]) -> "UmlPackage":
        node = self
        for p in path:
            if p not in node.subpackages:
                node.subpackages[p] = UmlPackage(p)
            node = node.subpackages[p]
        return node

    def to_mdj(self) -> Dict:
        owned: List[Dict] = []
        # packages first
        for sp in self.subpackages.values():
            owned.append(sp.to_mdj())
        # classes
        for c in self.classes:
            owned.append(c.to_mdj())
        return {
            "_type": "UMLPackage",
            "_id": gen_id("PK"),
            "name": self.name,
            "ownedElements": owned,
        }


@dataclass
class UmlRelation:
    kind: str  # association | dependency | composition
    src: str
    dst: str
    label: Optional[str] = None
    mult_src: Optional[str] = None
    mult_dst: Optional[str] = None
    directed: bool = False  # for association '-->'


class PumlParser:
    CLASS_OPEN_RE = re.compile(r"^\s*class\s+\"?([^\"{<]+?)\"?\s*(?:<<[^>]+>>)?\s*(\{)?")
    PACKAGE_OPEN_RE = re.compile(r"^\s*package\s+\"([^\"]+)\"(?:\s+as\s+\w+)?\s*\{")
    REL_RE = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?:\"([^\"]+)\")?\s*(\*--|-->|--|\.\.>)\s*(?:\"([^\"]+)\")?\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?::\s*(.*))?$")

    def __init__(self, text: str) -> None:
        self.lines = text.splitlines()
        self.root = UmlPackage("root")
        self.relations: List[UmlRelation] = []

    def parse(self) -> UmlPackage:
        pkg_stack: List[str] = []
        block_stack: List[str] = []  # 'pkg' | 'other'
        i = 0
        in_class = False
        cur_class: Optional[UmlClass] = None

        while i < len(self.lines):
            line = self.lines[i].rstrip()

            # close braces handling
            if line.strip() == "}" and in_class:
                # end of class
                pkg = self.root.ensure(pkg_stack)
                if cur_class:
                    pkg.classes.append(cur_class)
                in_class = False
                cur_class = None
                i += 1
                continue
            elif line.strip() == "}":
                # end of some scope
                if block_stack:
                    kind = block_stack.pop()
                    if kind == "pkg" and pkg_stack:
                        pkg_stack.pop()
                i += 1
                continue

            if not in_class:
                # package open
                m_pkg = self.PACKAGE_OPEN_RE.match(line)
                if m_pkg:
                    pkg_stack.append(m_pkg.group(1))
                    block_stack.append("pkg")
                    i += 1
                    continue

                # class open
                m_cls = self.CLASS_OPEN_RE.match(line)
                if m_cls:
                    name = m_cls.group(1).strip()
                    has_brace = m_cls.group(2) is not None
                    cur_class = UmlClass(name=name)
                    if has_brace:
                        in_class = True
                    else:
                        # one-line class without body
                        pkg = self.root.ensure(pkg_stack)
                        pkg.classes.append(cur_class)
                        cur_class = None
                    i += 1
                    continue
                # any other block open like: together {, note {, etc.
                if line.strip().endswith("{"):
                    block_stack.append("other")
                    i += 1
                    continue
                # relation lines
                m_rel = self.REL_RE.match(line)
                if m_rel:
                    src, mult_src, arrow, mult_dst, dst, label = m_rel.groups()
                    if arrow == "..>":
                        self.relations.append(UmlRelation(kind="dependency", src=src, dst=dst, label=label))
                    elif arrow == "*--":
                        self.relations.append(UmlRelation(kind="composition", src=src, dst=dst, label=label, mult_src=mult_src, mult_dst=mult_dst))
                    elif arrow == "-->":
                        self.relations.append(UmlRelation(kind="association", src=src, dst=dst, label=label, mult_src=mult_src, mult_dst=mult_dst, directed=True))
                    elif arrow == "--":
                        self.relations.append(UmlRelation(kind="association", src=src, dst=dst, label=label, mult_src=mult_src, mult_dst=mult_dst, directed=False))
                    i += 1
                    continue

            else:
                # inside class: parse attribute/operation
                s = line.strip()
                if not s:
                    i += 1
                    continue
                if s[0] in "+-#":
                    body = s[1:].strip()
                    # operation if it contains '(' ')'
                    if "(" in body and ")" in body:
                        # name(args): return
                        name = body
                        ret: Optional[str] = None
                        if ":" in body:
                            name_part, ret_part = body.split(":", 1)
                            name = name_part.strip()
                            ret = ret_part.strip()
                        else:
                            name = body
                        # strip args
                        name = re.sub(r"\(.*\)", "", name).strip()
                        cur_class.operations.append(UmlOperation(name=name, return_type=ret))
                    else:
                        # attribute name: type
                        if ":" in body:
                            n, t = body.split(":", 1)
                            cur_class.attributes.append(UmlAttribute(name=n.strip(), type_=t.strip(), visibility={"+":"public","-":"private","#":"protected"}[s[0]]))
                        else:
                            cur_class.attributes.append(UmlAttribute(name=body.strip(), visibility={"+":"public","-":"private","#":"protected"}[s[0]]))
                i += 1
                continue

            i += 1

        return self.root


def assign_ids(pkg: UmlPackage, class_id_map: Dict[str, str]) -> None:
    for c in pkg.classes:
        c.mdj_id = gen_id("CL")
        class_id_map[c.name] = c.mdj_id
    for sp in pkg.subpackages.values():
        assign_ids(sp, class_id_map)


def build_mdj(root_pkg: UmlPackage, relations: List[UmlRelation], project_name: str = "사주분석_앱(자동변환)") -> Dict:
    model_id = gen_id("MDL")
    # assign class ids first, and build class_id_map
    class_id_map: Dict[str, str] = {}
    for sp in root_pkg.subpackages.values():
        assign_ids(sp, class_id_map)

    model = {
        "_type": "UMLModel",
        "_id": model_id,
        "name": project_name,
        "ownedElements": [sp.to_mdj() for sp in root_pkg.subpackages.values()],
        "diagrams": [
            {
                "_type": "UMLClassDiagram",
                "_id": gen_id("DG"),
                "name": "AutoGenerated",
                "model": model_id,
                "ownedViews": [],
            }
        ],
    }

    # build relations
    for r in relations:
        if r.src not in class_id_map or r.dst not in class_id_map:
            continue
        if r.kind in ("association", "composition"):
            assoc = {
                "_type": "UMLAssociation",
                "_id": gen_id("AS"),
                "name": (r.label or "")[:50],
                "end1": {
                    "_type": "UMLAssociationEnd",
                    "_id": gen_id("AE"),
                    "reference": class_id_map[r.src],
                    **({"multiplicity": r.mult_src} if r.mult_src else {}),
                    **({"isNavigable": False} if r.directed else {}),
                    **({"aggregation": "composite"} if r.kind == "composition" else {"aggregation": "none"}),
                },
                "end2": {
                    "_type": "UMLAssociationEnd",
                    "_id": gen_id("AE"),
                    "reference": class_id_map[r.dst],
                    **({"multiplicity": r.mult_dst} if r.mult_dst else {}),
                    **({"isNavigable": True} if r.directed else {}),
                    "aggregation": "none",
                },
            }
            model["ownedElements"].append(assoc)
        elif r.kind == "dependency":
            dep = {
                "_type": "UMLDependency",
                "_id": gen_id("DP"),
                "name": (r.label or "")[:50],
                "source": class_id_map[r.src],
                "target": class_id_map[r.dst],
            }
            model["ownedElements"].append(dep)

    project = {
        "_type": "Project",
        "_id": gen_id("PRJ"),
        "name": project_name,
        "ownedElements": [model],
    }
    return project


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: python documents/tools/puml_to_mdj.py <input.puml> <output.mdj>")
        sys.exit(1)
    src = sys.argv[1]
    dst = sys.argv[2]
    with open(src, "r", encoding="utf-8") as f:
        text = f.read()
    parser = PumlParser(text)
    root = parser.parse()
    mdj = build_mdj(root, parser.relations)
    with open(dst, "w", encoding="utf-8") as f:
        json.dump(mdj, f, ensure_ascii=False, indent=2)
    print(f"MDJ written: {dst}")


if __name__ == "__main__":
    main()


