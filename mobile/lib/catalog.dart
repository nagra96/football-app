import 'package:flutter/material.dart';

import 'models.dart';

const categoryLabels = <SessionCategory, String>{
  SessionCategory.invoicing: 'Invoicing',
  SessionCategory.quoting: 'Quoting',
  SessionCategory.social: 'Social & Marketing',
  SessionCategory.admin: 'General Admin',
  SessionCategory.other: 'Other',
};

const taskTypeLabels = <TaskType, String>{
  TaskType.quote: 'Quote to send',
  TaskType.invoice: 'Invoice to chase',
  TaskType.social: 'Social post',
  TaskType.admin: 'Admin task',
  TaskType.other: 'Other',
};

const taskTypeIcons = <TaskType, String>{
  TaskType.quote: '📝',
  TaskType.invoice: '💷',
  TaskType.social: '📱',
  TaskType.admin: '🗂️',
  TaskType.other: '📌',
};

class DurationOption {
  const DurationOption(this.minutes, this.hint, this.reward);
  final int minutes;
  final String hint;
  final int reward;
}

const durationOptions = [
  DurationOption(25, 'Quick job', 5),
  DurationOption(45, 'Half shift', 10),
  DurationOption(60, 'Full clock-in', 15),
];

int rewardForDuration(int minutes) => durationOptions
    .firstWhere((d) => d.minutes == minutes, orElse: () => durationOptions.first)
    .reward;

const zoneLabels = <ItemZone, String>{
  ItemZone.workshop: 'Workshop',
  ItemZone.garage: 'Garage',
  ItemZone.van: 'Van',
};

const zoneIcons = <ItemZone, String>{
  ItemZone.workshop: '🛠️',
  ItemZone.garage: '🚪',
  ItemZone.van: '🚐',
};

const workshopItems = <WorkshopItem>[
  WorkshopItem(id: 'workbench', name: 'Workbench', zone: ItemZone.workshop, cost: 10, emoji: '🪚'),
  WorkshopItem(id: 'pegboard', name: 'Tool Pegboard', zone: ItemZone.workshop, cost: 15, emoji: '🧰'),
  WorkshopItem(id: 'drill', name: 'Cordless Drill', zone: ItemZone.workshop, cost: 20, emoji: '🔩'),
  WorkshopItem(id: 'shelving', name: 'Steel Shelving', zone: ItemZone.workshop, cost: 25, emoji: '🗄️'),
  WorkshopItem(id: 'radio', name: 'Job Site Radio', zone: ItemZone.workshop, cost: 30, emoji: '📻'),
  WorkshopItem(id: 'ladder', name: 'Step Ladder', zone: ItemZone.garage, cost: 15, emoji: '🪜'),
  WorkshopItem(id: 'toolbox', name: 'Rolling Toolbox', zone: ItemZone.garage, cost: 20, emoji: '🧳'),
  WorkshopItem(id: 'compressor', name: 'Air Compressor', zone: ItemZone.garage, cost: 35, emoji: '🛞'),
  WorkshopItem(id: 'lift', name: 'Vehicle Lift', zone: ItemZone.garage, cost: 60, emoji: '⚙️'),
  WorkshopItem(id: 'sign', name: 'Business Sign', zone: ItemZone.garage, cost: 40, emoji: '🪧'),
  WorkshopItem(id: 'racks', name: 'Van Shelving Racks', zone: ItemZone.van, cost: 25, emoji: '📦'),
  WorkshopItem(id: 'ladderRack', name: 'Roof Ladder Rack', zone: ItemZone.van, cost: 35, emoji: '🚧'),
  WorkshopItem(id: 'wrap', name: 'Custom Van Wrap', zone: ItemZone.van, cost: 50, emoji: '🎨'),
  WorkshopItem(id: 'gps', name: 'Fleet GPS Tracker', zone: ItemZone.van, cost: 45, emoji: '📍'),
  WorkshopItem(id: 'coffee', name: 'Site Coffee Machine', zone: ItemZone.van, cost: 20, emoji: '☕'),
];

/// The guard crew: miniature buddies assigned to sit on distracting apps.
const miniBuddyRoster = <MiniBuddy>[
  MiniBuddy(
    id: 'nut',
    name: 'Nut',
    color: Color(0xFFE8890C),
    tool: '🔧',
    catchLine: "Oi! Nut caught you sneaking off to %s. Back on the clock!",
  ),
  MiniBuddy(
    id: 'bolt',
    name: 'Bolt',
    color: Color(0xFF2E86D4),
    tool: '🔨',
    catchLine: "Bolt saw that. %s can wait till the job's done.",
  ),
  MiniBuddy(
    id: 'rivet',
    name: 'Rivet',
    color: Color(0xFFD8434E),
    tool: '🪛',
    catchLine: "Rivet's sitting on %s for a reason, boss.",
  ),
  MiniBuddy(
    id: 'sprocket',
    name: 'Sprocket',
    color: Color(0xFF3FA65C),
    tool: '🪚',
    catchLine: "Sprocket says: %s is off limits till knock-off.",
  ),
  MiniBuddy(
    id: 'chip',
    name: 'Chip',
    color: Color(0xFF8A5CD6),
    tool: '🛠️',
    catchLine: "Chip clocked you opening %s. Nice try.",
  ),
  MiniBuddy(
    id: 'washer',
    name: 'Washer',
    color: Color(0xFF2AA8A0),
    tool: '🖌️',
    catchLine: "Washer's painting over %s till the shift ends.",
  ),
];

MiniBuddy miniBuddyById(String id) => miniBuddyRoster
    .firstWhere((b) => b.id == id, orElse: () => miniBuddyRoster.first);

const suggestedBlockedApps = [
  'Instagram',
  'TikTok',
  'Facebook',
  'X / Twitter',
  'YouTube',
  'Snapchat',
];
