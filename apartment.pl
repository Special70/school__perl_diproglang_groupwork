#/usr/bin/perl

use strict; use warnings; use DBI;
$| = 1; # Disable output buffering

system("cls");


print("Conneting Database...\n"); sleep 1;

my $myConnection = DBI->connect("DBI:SQLite:dbname=apartmentDB.db", "", "");
print("\nDatabase Connected!\n"); sleep 1; system("cls");

sub is_invalid {
	my ($choice, $min, $max) = @_; #parameters for args
	return ($choice !~ /^\d+$/ || $choice < $min || $choice > $max); #returns boolean
	#checks whether the $choice is a whole number and whether its below min or above max.
}

sub db_display {
	my $query = $myConnection->prepare('Select * from tenants');
	$query->execute();
	print("Tenant ID    | Full Name            | Floor Number |  Room Number\n");
	print("-" x 66, "\n");
	
	#row is array that holds values of fetchrow_array
	while (my @row = $query->fetchrow_array) {
	printf("%-12s | %-20s | %-12s | %-6s\n", @row), "\n";
	}
}

while (1) {
	system("cls");
	print("Welcome to PERL's Apartment Management System\n");
	print("[1] Start the Program\n[0] Exit\n");
	print("\n\tEnter Choice: ");
	my $choice = <STDIN>;
	chomp $choice;
	
	if (is_invalid($choice, 0, 1)) {
		print("\n\tInvalid Option. Please try again.\n");
		sleep 1;
	}
	
	
	elsif ($choice == 0) {
			print("\nThank you for using PERL’s Apartment Management System.\n");
			sleep 1;
			exit;
	}
	
	elsif ($choice == 1){ #Main Program na to
		
		my $menuChoice = 1;
		
		while (is_invalid($menuChoice, 0, 0)) {
			my $flag = 1;
			system("cls");
			
			print("\nApartment Management Main Menu\n");
			print("\n[1] Tenant Log\n[2] Register Tenant\n[3] Update Tenant Details\n[4] Terminate Lease\n[5] Compute Rent\n[0] Terminate Program");
			print("\n\n\tEnter Choice: ");
			$menuChoice = <STDIN>;
			chomp $menuChoice;
			
			if (is_invalid($menuChoice, 0, 5)) {
				print("\n\tInvalid Option. Please try again.\n");
				sleep 1;
				}
				
			elsif ($menuChoice == 1) {
				
				while (1) {
					system("cls");
					print("\nTenant Log Viewer\n");
					print("\n[1] Display All Tenant Records\n[2] Display Specific Tenant Records [tenant_id]\n[0] Return to Main Menu");
					print("\n\n\tChoice: ");
					$choice = <STDIN>;
					chomp $choice;
					
					if (is_invalid($choice, 0, 2)) {
					print("\n\tInvalid Option. Please try again.\n");
					sleep 1;
					}
					
					elsif ($choice == 0) {
					print("\n\tReturning to Main Menu...\n");
					sleep 1;
					last;
					}
					
					elsif ($choice == 1){
						db_display();
						print("\n\tPress any key to continue.");
						<STDIN>;
					}
					
					elsif ($choice == 2) {
						while (1) {
							print("\n\tEnter the Tenant's ID: ");
							my $tenant_id = <STDIN>;
							chomp $tenant_id;
							
							#get number of how many tenants for max.  selectrow_array() combines the prepare, execute, and fetchrow
							my $count = $myConnection->selectrow_array('Select count(*) from tenants');
							
							if (is_invalid($tenant_id, 1, $count)) {
								print("\n\tInvalid Tenant ID. Please try again.\n");
							}
							else { 
								#get list of tenants to check if input is in tenants
								my @tenantIdList = $myConnection->selectcol_arrayref('Select tenant_id from tenants');
								
								if (grep($tenant_id, @tenantIdList)) {
									print("\nFetching Tenant's Records...\n");
									sleep 1;
									print("\nTenant Records Fetched!\n\n");
									
									my $query = $myConnection->prepare('Select * from tenants where tenant_id =  ?');
									$query->execute($tenant_id);
									
									print("Tenant ID    | Full Name            | Floor Number |  Room Number\n");
									print("-" x 66, "\n");
									
									#row is array that holds values of fetchrow_array
									while (my @row = $query->fetchrow_array) {
										printf("%-12s | %-20s | %-12s | %-6s\n", @row), "\n";
									}

								}
								last;
							}
						}
				
						#runs after the while loop ends / successful display of tenant
						print("\n\tPress any key to continue.");
						<STDIN>;
					}
				}
			}
			
			
			elsif ($menuChoice == 2){
				while ($flag == 1) {
					system("cls");
					print("\nTenant Registration Menu\n");
					print("\n\tEnter Tenant Name: ");
					my $full_name = <STDIN>;
					chomp $full_name;
				
					print("\n\tEnter Floor Number: ");
					my $floor_num = <STDIN>;
					chomp $floor_num;
				
					print("\n\tEnter Room Number: ");
					my $room_num = <STDIN>;
					chomp $room_num;
					
					#get number of matching names
					my $query = $myConnection->prepare('Select count(*) from tenants where full_name like ?');
					$query->execute("%$full_name%");
					my $count = $query->fetchrow_array();
					
					#get available room per floor: 1 floor has 10 rooms. Max is 5 floors.
					$query= $myConnection->prepare('Select count(*) from tenants where floor_num = ? and room_num = ?');
					$query->execute($floor_num, $room_num);
					my $takenRoom = $query->fetchrow_array();
					
					if ((is_invalid($floor_num, 1, 5)) || (is_invalid($room_num, 1, 10))) {
						print("\n\tRoom/Floor is Invalid and or Occupied. Please try again.\n");
						sleep 1;
						$flag = 0;
					}
					
					elsif ($takenRoom > 0){
						print("\n\tRoom $room_num in Floor $floor_num is already occupied. Please try again.\n");
						sleep 1;
					}
					
					elsif ($count > 0) {
						print("\n\tTenant is already stored in Tenant Logs.\n");
						sleep 1;
					}
					
					else {
						my $query = $myConnection->prepare('Insert into tenants (full_name, floor_num, room_num) values (?,?,?)');
						$query->execute($full_name, $floor_num, $room_num);
						print("\n\tTenant Successfully Added!\n");
						sleep 1.5;
						last;
					}
				}
			}

			# update tenant details
			elsif ($menuChoice == 3){
				choice3:
				system('cls');
				print("\nTenant Logs Updater Menu\n");
				db_display();
				print("\n\tWhich Tenant would you like to make modifications?\n\n");
				
				# asks for either tenant id/name
				my $userInput = <STDIN>;
				chomp($userInput);
				
				my $query = $myConnection->prepare("select exists (select * from tenants where tenant_id= ? or full_name= ?)");
				$query->execute($userInput, $userInput);
				my $exists = $query->fetchrow_array;

				# if tenant id/name does not exist
				if (!$exists) {
					print("\nInvalid Tenant ID or Tenant Name. Please try again.");
					sleep 1;
					goto choice3;
				} 

				modif_prompt:

				print("\nEnter a floor number: ");
				my $floor_num = <STDIN>;
				$floor_num += 0;
				chomp($floor_num);

				print("\nEnter a room number: ");
				my $room_num = <STDIN>;
				$room_num += 0;
				chomp($room_num);

				# checks if provided floor & room number doesn't exist (meaning, not occupied yet)
				$query = $myConnection->prepare("SELECT EXISTS (SELECT 1 FROM tenants WHERE floor_num = CAST(? AS INTEGER) AND room_num = CAST(? AS INTEGER))");
				$query->execute($floor_num, $room_num);
				$exists = $query->fetchrow_array;

				if ($exists) { # if said room is occupied
					print("\nEntered room in said floor is already taken. Please try again");
					sleep 1;
					goto modif_prompt;
				} elsif (is_invalid($floor_num, 1, 5) || is_invalid($room_num, 1, 10)) { # if user input is invalid
					print("\nEntered floor/room is invalid. Please try again");
					sleep 1;
					goto modif_prompt;
				}

				$query = $myConnection->prepare("update tenants set floor_num= ?, room_num= ? where (tenant_id= ? or full_name= ?)");
				$query->execute($floor_num, $room_num, $userInput, $userInput);

				print("\nDone modifying tenant details");
				sleep 1;

				
			}
			
			elsif ($menuChoice == 4){
				print("\n\nLease Termination Menu\n\n");
				db_display();
				
				while (1){
					print("\n\tEnter Tenant ID to be Deleted [X to Cancel]: ");
					my $tenant_id = <STDIN>;
					chomp $tenant_id;
					
					#get tenant list
					my @tenantIdList = $myConnection->prepare('Select tenant_id from tenants');
					
					#get number of tenants for max
					my $count = $myConnection->selectrow_array('Select count(*) from tenants');
					
					if (uc($tenant_id) eq 'X') {
						print("\n\tReturning to Main Menu...\n");
						sleep 1;
						last;
					}
					
					elsif (is_invalid($tenant_id, 1, $count)) {
						print("\n\tTenant ID is Invalid. Please try again.");
						sleep 1;
						}
					
					elsif ($count == 0){
						print("\n\tEmployee does not exist.\n");
						sleep 1;
					}
					else {
						my $delete = $myConnection->prepare('Delete from tenants where tenant_id = ?');
						$delete->execute($tenant_id);
			
						print("\n\tEmployee Record Successfully Deleted!\n");
						sleep 1;
					}
				}
			}
				
			elsif ($menuChoice == 5){
				print("\nDisplay Summary of Salary records");
			}
			
		}
		print("\n\tThank you for using PERL's Business and Employee Payroll System.\n");
		sleep 3;
		exit;
	}
}