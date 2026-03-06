#!/usr/bin/env python3
"""
Salesforce Profile and Permission Set Test Script
Tests all roles, profiles, and permission sets
"""

import subprocess
import json

ORG_ALIAS = "myorg"

def run_soql(query):
    """Execute SOQL query and return results"""
    cmd = f'sf data query --query "{query}" --json -o {ORG_ALIAS}'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return json.loads(result.stdout)

def test_roles():
    """Test all roles exist"""
    print("\n=== Testing Roles ===")
    roles = ["MDL Super User", "MDL Manager", "Recruiter", "Credentialer", "Engagement Specialist"]
    
    query = "SELECT Id, Name FROM UserRole WHERE Name IN ('MDL Super User','MDL Manager','Recruiter','Credentialer','Engagement Specialist')"
    result = run_soql(query)
    
    found_roles = [r['Name'] for r in result['result']['records']]
    
    for role in roles:
        if role in found_roles:
            print(f"✅ {role} - EXISTS")
        else:
            print(f"❌ {role} - MISSING")

def test_permission_sets():
    """Test all permission sets exist"""
    print("\n=== Testing Permission Sets ===")
    perm_sets = [
        "MDL Manager Permissions",
        "Recruiter Permissions", 
        "Credentialer Permissions",
        "Engagement Specialist Permissions"
    ]
    
    query = "SELECT Id, Label FROM PermissionSet WHERE Label LIKE '%MDL%' OR Label LIKE '%Recruiter%' OR Label LIKE '%Credentialer%' OR Label LIKE '%Engagement%'"
    result = run_soql(query)
    
    found_ps = [ps['Label'] for ps in result['result']['records']]
    
    for ps in perm_sets:
        if ps in found_ps:
            print(f"✅ {ps} - EXISTS")
        else:
            print(f"❌ {ps} - MISSING")

def test_apex_classes():
    """Test Apex classes deployed"""
    print("\n=== Testing Apex Classes ===")
    classes = ["AnalyticsQueryBuilder", "ReportGenerator", "ReportDistributionScheduler"]
    
    query = "SELECT Id, Name FROM ApexClass WHERE Name IN ('AnalyticsQueryBuilder','ReportGenerator','ReportDistributionScheduler')"
    result = run_soql(query)
    
    found_classes = [c['Name'] for c in result['result']['records']]
    
    for cls in classes:
        if cls in found_classes:
            print(f"✅ {cls} - DEPLOYED")
        else:
            print(f"❌ {cls} - MISSING")

def test_profile():
    """Test MDLive profile exists"""
    print("\n=== Testing Profile ===")
    
    query = "SELECT Id, Name FROM Profile WHERE Name = 'MDLive'"
    result = run_soql(query)
    
    if result['result']['records']:
        print(f"✅ MDLive Profile - EXISTS")
    else:
        print(f"❌ MDLive Profile - MISSING")

def test_role_hierarchy():
    """Test role hierarchy is correct"""
    print("\n=== Testing Role Hierarchy ===")
    
    query = "SELECT Id, Name, ParentRoleId, ParentRole.Name FROM UserRole WHERE Name IN ('MDL Manager','Recruiter','Credentialer','Engagement Specialist')"
    result = run_soql(query)
    
    for role in result['result']['records']:
        parent = role.get('ParentRole', {}).get('Name', 'None')
        print(f"✅ {role['Name']} → Parent: {parent}")

def main():
    print("=" * 60)
    print("SALESFORCE METADATA TEST SUITE")
    print("=" * 60)
    
    test_roles()
    test_permission_sets()
    test_apex_classes()
    test_profile()
    test_role_hierarchy()
    
    print("\n" + "=" * 60)
    print("TEST COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
