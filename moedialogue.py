#! /usr/bin/python3
import sys
import json

class DialogueAttr:
    def __init__(self, name: str, value):
        self.name = name
        self.value = value
    
    def __repr__(self) -> str:
        return f'DialogueAttr({self.name}, {self.value})'
    
    def as_dict(self):
        return {
            'name': self.name,
            'value': self.value
        }

    
class DialogueEvent:
    def __init__(self, name: str, args: list) -> None:
        self.name = name
        self.args = args
    
    def __repr__(self) -> str:
        return f'DialogueEvent({self.name}, {self.args})'

    def as_dict(self):
        return {
            'name': self.name,
            'args': self.args
        }

class DialogueBlock:
    def __init__(self, name: str, text: str, attrs: list[DialogueAttr], events: list[DialogueEvent]) -> None:
        self.name = name
        self.text = text
        self.attrs = attrs
        self.events = events
        self.choices = []
    
    def __repr__(self):
        return f'DialogueBlock({self.name}, {self.text}, {self.attrs}, {self.events})'

    def as_dict(self):
        event_dicts = []
        attr_dicts = []
        choices_dicts = []
        for ev in self.events:
            event_dicts.append(ev.as_dict())
        for at in self.attrs:
            attr_dicts.append(at.as_dict())
        for ch in self.choices:
            choices_dicts.append(ch.as_dict())
        return {
            'name': self.name,
            'text': self.text,
            'attrs': attr_dicts,
            'events': event_dicts,
            'choices': choices_dicts
        }

class Choice:
    def __init__(self, text: str, event: DialogueEvent):
        self.text = text
        self.event = event
    
    def as_dict(self):
        return {
            'text': self.text,
            'event': self.event.as_dict()
        }

DEFAULTS_FILE = 'defaults.json'
BRANCH_SEPERATOR = '///'
TEXT_SEPERATOR = ':'
DIALOGUE_EVENT_START_CHAR = '['
DIALOGUE_EVENT_END_CHAR = ']'
DIALOGUE_ATTR_START_CHAR = '{'
DIALOGUE_ATTR_END_CHAR = '}'
DIALOGUE_EVENT_SEPERATOR = '|'
DIALOGUE_EVENT_PARAM_SEPERATOR = ','

def is_number(text: str):
    try:
        float(text)
        return True
    except:
        return False

def parse_dialogue(lines: list[str]) -> list:
    dialogue_blocks = []
    last_dialogue_block: DialogueBlock
    defaults = None
    for l in lines:
        line = l.strip()
        if not line.startswith('->'): #if not a choice
            name = ""
            text = line[line.index(TEXT_SEPERATOR)+1:].strip()
            attrs: list[DialogueAttr] = []
            events: list[DialogueEvent] = []
            
            with open(DEFAULTS_FILE) as f:
                defaults = json.load(f)

            has_events = DIALOGUE_EVENT_START_CHAR in line[:line.index(TEXT_SEPERATOR)] and DIALOGUE_EVENT_END_CHAR in line[:line.index(TEXT_SEPERATOR)] 
            has_attrs = DIALOGUE_ATTR_START_CHAR in line[:line.index(TEXT_SEPERATOR)] and DIALOGUE_ATTR_END_CHAR in line[:line.index(TEXT_SEPERATOR)] 
            if has_attrs:
                data_start = line.index(DIALOGUE_ATTR_START_CHAR)
                data_end = line.index(DIALOGUE_ATTR_END_CHAR)
                data_substr = line[data_start+1:data_end]
                for data in data_substr.split(','):
                    attr_name, attr_value = "", ""
                    data_split = data.split('=')
                    attr_name = data_split[0].strip()
                    attr_value = data_split[1].strip()
                    if is_number(attr_value):
                        attr_value = float(attr_value)
                    attr = DialogueAttr(attr_name, attr_value)
                    attrs.append(attr)
            if has_events:
                data_start = line.index(DIALOGUE_EVENT_START_CHAR)
                data_end = line.index(DIALOGUE_EVENT_END_CHAR)
                data_substr = line[data_start+1:data_end]
                for data in data_substr.split(DIALOGUE_EVENT_SEPERATOR):
                    args: list = data.split(DIALOGUE_EVENT_PARAM_SEPERATOR)
                    ev_name = args[0]
                    args.remove(args[0])
                    for i in range(0, len(args)):
                        args[i] = args[i].strip()
                        if is_number(args[i]):
                            args[i] = float(args[i])
                    ev = DialogueEvent(ev_name, args)
                    events.append(ev)
            if not has_attrs and not has_events:
                name = line[:line.index(TEXT_SEPERATOR)]
            elif has_attrs and not has_events or has_attrs and has_events:
                name = line[:line.index(DIALOGUE_ATTR_START_CHAR)]
            elif has_events and not has_attrs:
                name = line[:line.index(DIALOGUE_EVENT_START_CHAR)]


            new_attrs = attrs.copy()
            for item in defaults['defaults']:
                if name == item['name']:
                    for attr in attrs:
                        for default_attr in item['attrs']:
                            if default_attr['name'] in attr.name:
                                continue
                            else:
                                new_attrs.append(DialogueAttr(default_attr['name'], default_attr['value']))
            attrs = new_attrs.copy()
            dialogue_block = DialogueBlock(name, text, attrs, events)
            last_dialogue_block = dialogue_block
            dialogue_blocks.append(dialogue_block)
        else: # is a choice
            text = line[line.index('->')+2:line.index(TEXT_SEPERATOR)].strip()
            event_data: list = line[line.index(TEXT_SEPERATOR)+1:].strip().split(DIALOGUE_EVENT_PARAM_SEPERATOR)
            event_name = event_data[0]
            event_data.remove(event_name)
            for i in range(0, len(event_data)):
                event_data[i] = event_data[i].strip()
                if is_number(event_data[i]):
                    event_data[i] = float(event_data[i])
            event = DialogueEvent(event_name, event_data)
            last_dialogue_block.choices.append(Choice(text, event))
                    


    return dialogue_blocks
    

if __name__ == '__main__':
    filename = sys.argv[1]
    content = ""
    with open(filename) as f:
        print(f"Opening file '{filename}'")
        content = f.read()
        print(f"Contents of '{filename} read'")

    branches_data = content.split(BRANCH_SEPERATOR)
    branches_data.remove(branches_data[0])

    branches: dict[str, list[DialogueBlock]] = {}

    for branch_data in branches_data:
        lines = branch_data.split('\n')
        branch_name = lines[0]
        if len(branch_name) > 0:
            lines.remove(lines[0])
            lines.pop()
            branches[branch_name] = dialogue_blocks = parse_dialogue(lines)
    

    with open(sys.argv[2] if len(sys.argv) > 2 else 'out.json', 'w') as f:
        print(f"Writing data to '{f.name}'")
        dialogue_data = []
        for key in branches.keys():
            thing = []
            for ok in branches[key]:
                thing.append(ok.as_dict())
            dialogue_data.append({key: thing})
        dialogue_data = {'dialogue': dialogue_data, 'branches': [b for b in branches.keys()]}
        json.dump(dialogue_data, f, indent=2)
        print(f"Data written to '{f.name}'")
        
    
